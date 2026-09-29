// m6d_cmd.h — M6d driver.  Included from main.cpp after ir_annotate / build_cfg / expr.h exist.
//
//   struct-validate <dir>   THE ACCEPTANCE METRIC: how many protos reduce to fully structured
//                           control flow, and for those that do not, WHY.
//
// Luau has no `goto`, so an unstructured residue is not a cosmetic problem — it is source we cannot
// emit at all. Every failure is therefore counted and named rather than silently flattened.
#pragma once

// Build the richer CFG that structuring needs: predecessors, and the branch-taken successor kept
// distinct from the fallthrough (build_cfg's flat successor list loses that distinction).
static long long g_cov_ok=0, g_cov_bad=0, g_cov_missing=0, g_cov_dupd=0;
static long long g_zerodup_ok=0, g_needed_dup=0;
static long long g_red_before=0, g_red_after=0, g_red_total=0;
static long long g_sclive_blocked=0, g_sclive_exact=0, g_sclive_unknown=0;
static long long g_sclive_nodef=0, g_sclive_multidef=0, g_sclive_nonsingle=0;
static long long g_sclive_earlyuse=0, g_sclive_liveout=0;
static std::map<std::string, long long> g_sclive_exact_shapes;
static bool build_graph(const ir::IProto& ip, st::Graph& g) {
    std::vector<Blk> bl; std::string why;
    std::string code = ir_code_bytes(ip);
    if (!build_cfg(code, bl, why)) return false;
    std::map<int,int> start2blk;
    for (size_t i = 0; i < bl.size(); ++i) start2blk[bl[i].first] = (int)i;
    g.n.assign(bl.size(), st::Node{});
    for (size_t i = 0; i < bl.size(); ++i) {
        st::Node& n = g.n[i];
        n.first = bl[i].first; n.last = bl[i].last; n.reach = bl[i].reach;
        if (n.last < 0 || n.last >= (int)ip.code.size()) continue;
        const ir::IInsn& t = ip.code[n.last];
        n.term = t.op;
        n.is_return = (t.op == 0x29);
        // FORGPREP (0x30 / 0x1b / 0x0b) is an UNCONDITIONAL jump to the FORGLOOP — it never falls
        // through. Treating it as conditional invents a PHANTOM fallthrough edge into the loop body,
        // giving the loop a second entry and making a perfectly ordinary `for k,v in pairs(t)`
        // measure IRREDUCIBLE. That single phantom edge is why ~8,800 protos looked irreducible.
        // FORNPREP (0x47) is genuinely conditional: it jumps to the loop EXIT when the loop will not
        // run, and otherwise falls through to the body — so it keeps both edges.
        n.is_uncond = (t.op == 0x40 || t.op == 0x25 ||
                       t.op == 0x30 || t.op == 0x1b || t.op == 0x0b);
        // LOADB with C != 0 skips the next C instructions — an UNCONDITIONAL jump that carries the
        // false arm of a value-producing comparison past the true arm. Without this edge the arms run
        // in sequence and `return a < b` yields a constant `true`.
        bool loadb_skip = (t.op == 0x04 && t.C != 0);
        if (loadb_skip) n.is_uncond = true;
        n.is_branch = t.branch && !n.is_uncond;
        if (loadb_skip) {
            auto it = start2blk.find(n.last + 1 + (int)t.C);
            if (it != start2blk.end()) n.succ_true = it->second;
        } else if (t.branch && t.target >= 0) {
            auto it = start2blk.find(t.target);
            if (it != start2blk.end()) n.succ_true = it->second;
        }
        if (!n.is_uncond && !n.is_return && n.last + 1 < (int)ip.code.size()) {
            auto it = start2blk.find(n.last + 1);
            if (it != start2blk.end()) n.succ_false = it->second;
        }
        if (n.is_uncond) { n.succ_false = -1; }
    }
    auto rebuild_preds = [&]() {
        for (auto& nd : g.n) nd.preds.clear();
        for (size_t i = 0; i < g.n.size(); ++i)
            for (int s : {g.n[i].succ_true, g.n[i].succ_false})
                if (s >= 0 && s < (int)g.n.size()) g.n[s].preds.push_back((int)i);
    };
    rebuild_preds();
    // Snapshot liveness on the original CFG, before short-circuit merging rewrites edges and marks
    // blocks unreachable. This is instrumentation-only for now; no merge consults it unless a future
    // flag-backed candidate is added after the measured population is understood.
    lv::Analysis sc_liveness;
    bool need_sc_liveness = std::getenv("RENOVICE_SCLIVE")
                         || std::getenv("RENOVICE_SC_LOADN_FOLD");
    if (need_sc_liveness) sc_liveness = lv::analyze(ip, g);
    // A condition merge rewrites CFG node identity before loop structuring. Even when the value fold
    // is expression-correct, merging a loop header/body/latch/prep can change the later loop forest
    // (BoosterInfo: one additional header lost and the surrounding Proper state machine reshaped).
    // Excluding only the loop's own blocks was still insufficient: an adjacent acyclic condition in
    // Foundry/ResearchSelection changed the reducer boundary and lost a later loop. The first safe
    // candidate therefore runs only in prototypes whose authoritative pre-merge loop forest is empty.
    bool sc_proto_has_loops = false;
    if (std::getenv("RENOVICE_SC_LOADN_FOLD")) {
        st::compute_dom(g);
        sc_proto_has_loops = !st::find_loops(g).empty();
    }

    // Luau compiles goto-less structured source, so its output CANNOT be irreducible. If a graph
    // measures irreducible, we built it wrong. The short-circuit merge below REWRITES EDGES, so it
    // is the prime suspect: record reducibility before and after to find out.
    g_red_before += st::is_reducible_raw(g) ? 1 : 0;
    ++g_red_total;

    // ---- COLLAPSE SHORT-CIRCUIT CHAINS -------------------------------------------------------
    // `if a and b then` compiles to two conditional blocks that jump to the SAME target:
    //     B: JUMPIFNOT a -> L        F: JUMPIFNOT b -> L
    // so L is reached from both arms of what looks like a diamond. A plain recursive descent then
    // emits L inside the inner `if` and tries to emit it AGAIN for the outer one — which is exactly
    // the "revisit of block" residue (23,524 nodes, the single biggest structuring failure).
    // Merging F into B turns the pair back into ONE condition, which is what the source actually
    // said. `or` is the mirror image: B's branch target coincides with F's FALLTHROUGH.
    // INSTRUMENTATION (RENOVICE_SCDBG=1). Measures WHY a short-circuit merge is refused, so the
    // size of each blocked population is known before anyone tries to enlarge the rule. Counting
    // only; no behaviour change. Shape clustering showed ~36% of Proper regions would stop being
    // Proper if short-circuit merging reached further, and this says which restriction holds them.
    int sc_merged = 0, sc_blk_stmt = 0, sc_blk_preds = 0, sc_blk_shape = 0;
    std::set<unsigned long long> sclive_seen_pairs;
    bool merged = true; int guard = 0;
    while (merged && guard++ < 200) {
        merged = false;
        for (size_t i = 0; i < g.n.size(); ++i) {
            st::Node& B = g.n[i];
            if (!B.is_branch || B.succ_true < 0 || B.succ_false < 0) continue;
            int f = B.succ_false;
            if (f < 0 || f >= (int)g.n.size() || f == (int)i) continue;
            st::Node& F = g.n[f];
            if (!F.is_branch || F.succ_true < 0 || F.succ_false < 0) continue;
            if (F.preds.size() != 1) { ++sc_blk_preds; continue; }  // F must be private to B
            // A loop prep/latch is control structure, never the second leaf of `a and b`/`a or b`.
            // Merging a comparison with an adjacent FORNLOOP erased the comparison's loop-exit edge
            // and dropped source `break` on the next cycle (BattleMap). Preserve all verified loop
            // controls as graph nodes before considering a short-circuit fold.
            auto loop_control = [](uint8_t op) {
                return op == 0x0a || op == 0x1e || op == 0x47
                    || op == 0x30 || op == 0x1b || op == 0x0b;
            };
            if (loop_control(B.term) || loop_control(F.term))
                continue;
            // F must be a PURE TEST. If it holds any statement before its terminator, that statement
            // is GUARDED by B's test — merging hoists it out of the guard and it runs unconditionally.
            // `t and t.x and t.x.y` became `v1 = v0.x` executed before the `t` check, so it indexed
            // nil. A short-circuit chain is only sound when the later tests have no side effects.
            bool andlike0 = (B.succ_true == F.succ_true);
            bool orlike0  = (B.succ_true == F.succ_false);
            bool fold_loadn = false;
            if (std::getenv("RENOVICE_SC_LOADN_FOLD") && andlike0
                && sc_liveness.known && sc_liveness.converged
                && !sc_proto_has_loops
                && F.first >= 0 && F.last == F.first + 1
                && F.last < (int)ip.code.size()) {
                const ir::IInsn& setup = ip.code[F.first];
                const ir::IInsn& test = ip.code[F.last];
                bool reg_compare = test.op == 0x37 || test.op == 0x27 || test.op == 0x21
                                || test.op == 0x1c || test.op == 0x23 || test.op == 0x33;
                int rhs = (int)(test.aux & 0xff);
                int occurrences = (test.A == setup.A ? 1 : 0) + (rhs == setup.A ? 1 : 0);
                fold_loadn = setup.op == 0x12 && reg_compare && occurrences == 1
                          && (size_t)f < sc_liveness.live_out.size()
                          && !sc_liveness.live_out[f].count(setup.A);
                if (fold_loadn) {
                    F.chain_loadn_literals[F.last][setup.A] = (int)(int16_t)setup.Bx;
                    F.chain_setup_insns.insert(F.first);
                }
            }
            if (F.first != F.last) {
                // Count it ONLY when the shape is otherwise a valid short-circuit, so the number
                // means "merges this rule alone is refusing", not "blocks that failed anyway".
                if (andlike0 || orlike0) {
                    ++sc_blk_stmt;
                    unsigned long long sclive_pair =
                        ((unsigned long long)(unsigned int)i << 32) | (unsigned int)f;
                    if (std::getenv("RENOVICE_SCLIVE")
                        && sclive_seen_pairs.insert(sclive_pair).second) {
                        ++g_sclive_blocked;
                        bool exact = sc_liveness.known && sc_liveness.converged;
                        bool unknown = !exact, nodef = false, multidef = false;
                        bool nonsingle = false, earlyuse = false, liveout = false;
                        std::map<int, int> def_at, def_count, use_count, first_use;
                        for (int q = F.first; q <= F.last && q >= 0
                             && q < (int)ip.code.size(); ++q) {
                            std::set<int> uses, defs;
                            if (!lv::register_effects(ip, ip.code[q], uses, defs)) {
                                exact = false; unknown = true; continue;
                            }
                            if (q < F.last && defs.empty()) { exact = false; nodef = true; }
                            for (int reg : uses) {
                                ++use_count[reg];
                                if (!first_use.count(reg)) first_use[reg] = q;
                            }
                            if (q < F.last) for (int reg : defs) {
                                ++def_count[reg];
                                if (!def_at.count(reg)) def_at[reg] = q;
                            }
                        }
                        for (const auto& entry : def_count) {
                            int reg = entry.first;
                            if (entry.second != 1) { exact = false; multidef = true; }
                            if (use_count[reg] != 1) { exact = false; nonsingle = true; }
                            auto use_it = first_use.find(reg);
                            if (use_it == first_use.end() || use_it->second <= def_at[reg]) {
                                exact = false; earlyuse = true;
                            }
                            if (F.first >= 0 && (size_t)f < sc_liveness.live_out.size()
                                && sc_liveness.live_out[f].count(reg)) {
                                exact = false; liveout = true;
                            }
                        }
                        if (exact && !def_count.empty()) {
                            ++g_sclive_exact;
                            std::string shape;
                            for (int q = F.first; q < F.last && q >= 0
                                 && q < (int)ip.code.size(); ++q) {
                                if (!shape.empty()) shape += "+";
                                shape += ip.code[q].name;
                            }
                            shape += "->" + ip.code[F.last].name;
                            ++g_sclive_exact_shapes[shape];
                        }
                        else {
                            if (unknown) ++g_sclive_unknown;
                            if (nodef || def_count.empty()) ++g_sclive_nodef;
                            if (multidef) ++g_sclive_multidef;
                            if (nonsingle) ++g_sclive_nonsingle;
                            if (earlyuse) ++g_sclive_earlyuse;
                            if (liveout) ++g_sclive_liveout;
                        }
                    }
                    // Dump the opcodes F actually holds. Whether the rule can be widened depends
                    // entirely on whether these can be HOISTED above B's test without changing
                    // behaviour -- a register move can, a field read cannot (it may index nil).
                    // Measure the population instead of assuming a "safe list".
                    if (std::getenv("RENOVICE_SCOPS"))
                        for (int q = F.first; q < F.last && q >= 0 && q < (int)ip.code.size(); ++q)
                            fprintf(stderr, "SCOP %02x\n", ip.code[q].op);
                    // FOLDABILITY PROBE (RENOVICE_SCFOLD). Hoisting F's statements is unsound, so the
                    // only sound widening is to FOLD them into the condition as an expression. That
                    // needs them to form ONE expression tree feeding the test. Two cheap proxies:
                    //   nstmt        - how much code is in F at all (a 20-statement block is not an
                    //                  expression, whatever else is true of it);
                    //   tail_feeds   - the instruction immediately before the test writes the very
                    //                  register the test reads, i.e. the chain terminates in the test.
                    // Deliberately a PROXY, not a proof: a real single-use/no-escape check needs
                    // cross-block liveness, which does not exist at this point in the pipeline.
                    if (std::getenv("RENOVICE_SCFOLD") && F.last > F.first
                        && F.last < (int)ip.code.size() && F.first >= 0) {
                        int nstmt = F.last - F.first;
                        int tail_feeds = (nstmt >= 1 && ip.code[F.last - 1].A == ip.code[F.last].A) ? 1 : 0;
                        fprintf(stderr, "SCF nstmt=%d tail=%d\n", nstmt, tail_feeds);
                    }
                }
                if (!fold_loadn) continue;
            }
            bool andlike = andlike0;
            bool orlike  = orlike0;
            if (!andlike && !orlike) { ++sc_blk_shape; continue; }
            st::PredicatePtr left = B.branch_predicate
                                  ? B.branch_predicate : st::pred_test(B.last);
            st::PredicatePtr right = F.branch_predicate
                                   ? F.branch_predicate : st::pred_test(F.last);
            // Both branch-taken predicates reach F.true: P OR Q. Mirror topology reaches
            // F.true only when P was false and Q is true: (NOT P) AND Q. This must be a tree:
            // when P is compound, the mirror requires grouped inversion of the whole predicate.
            B.branch_predicate = andlike
                ? st::pred_or(left, right)
                : st::pred_and(st::pred_not(left), right);
            if (B.chain.empty()) B.chain.push_back(B.last);    // seed with B's own test
            // Node::chain stores BRANCH-TAKEN predicates, not the original source-positive tests.
            // When both tests branch to the same target, reaching that target is B_taken OR F_taken.
            // Retained as legacy metadata for chain length and diagnostics. cond_of renders the exact
            // predicate tree above; the LOADN experiment also records its literal substitutions here.
            B.chain_and.push_back(fold_loadn ? false : andlike);
            if (F.chain.empty()) B.chain.push_back(F.last);
            else { for (size_t q = 0; q < F.chain.size(); ++q) B.chain.push_back(F.chain[q]);
                   for (size_t q = 0; q + 1 < F.chain.size(); ++q) B.chain_and.push_back(F.chain_and[q]); }
            for (const auto& test_entry : F.chain_loadn_literals)
                for (const auto& reg_entry : test_entry.second)
                    B.chain_loadn_literals[test_entry.first][reg_entry.first] = reg_entry.second;
            B.chain_setup_insns.insert(F.chain_setup_insns.begin(), F.chain_setup_insns.end());
            B.succ_true  = F.succ_true;                        // B inherits F's exits
            B.succ_false = F.succ_false;
            B.last       = F.last;                             // and F's instructions
            B.term       = F.term;
            F.reach = false; F.succ_true = F.succ_false = -1;  // F no longer exists on its own
            merged = true; ++sc_merged;
        }
        if (merged) rebuild_preds();
    }
    if (std::getenv("RENOVICE_SCDBG"))
        fprintf(stderr, "SC merged=%d blocked_stmt=%d blocked_preds=%d blocked_shape=%d\n",
                sc_merged, sc_blk_stmt, sc_blk_preds, sc_blk_shape);
    g_red_after += st::is_reducible_raw(g) ? 1 : 0;
    return true;
}

static std::map<std::string,long long> g_structdiag;

// One structuring attempt at a given duplication allowance.
static st::Result structure_once(const ir::IProto& ip, int budget, int cap, bool quiet);

// ADAPTIVE BUDGET. Duplication is semantically exact but it BLOATS the output, and the cost is wildly
// uneven: the vast majority of protos need almost none, while a handful need thousands. A single
// global budget therefore forces a bad choice — small starves the hard protos, large bloats all
// 82,042 of them. Measured at a uniform budget:
//     200 -> 99.944% with  24k duplications
//   2,000 -> 99.972% with  74k
//  20,000 -> 99.992% with 274k
// 200,000 -> 99.996% with 887k
// Escalating only for protos that actually fail keeps the common case cheap and still pays whatever
// the hard ones need.
static st::Result structure_proto(const ir::IProto& ip) {
    // Escalate the per-block cap ALONGSIDE the budget. Measured separately, each was a bad trade:
    // a tight cap starves protos needing lots of legitimate duplication (cap 4 -> ~150 fallbacks),
    // while no cap lets one proto burn 199,928 duplications and still fail. They are not the same
    // regime, so no single (budget, cap) pair suits every proto — try several.
    struct Cfg { int budget, cap; };
    static const Cfg ladder[] = {
        // ZERO-DUPLICATION FIRST. A reducible CFG is structurable with if/while/for and NO copying
        // at all, so this rung measures how much of the corpus the descent handles HONESTLY versus
        // how much duplication is papering over descent bugs.
        {0, 0},
        {24, 4}, {200, 8}, {2000, 32}, {20000, 128}, {200000, 1024},
        {200000, 1000000000},                      // cap effectively off
        // LARGE budget with a TIGHT per-block cap. The runaway protos need exactly this combination
        // and the ladder never offered it: small caps were only ever paired with small budgets, so a
        // proto needing wide duplication AND cycle protection had no rung that fit.
        {2000000, 2}, {2000000, 6}, {2000000, 16}, {2000000, 64},
        {2000000, 1000000000},                     // last resort: very large budget, no cap
    };
    bool first = true;
    for (const Cfg& c : ladder) {
        st::Result r = structure_once(ip, c.budget, c.cap, true);
        if (!r.via_state_machine) { if (first) ++g_zerodup_ok; else ++g_needed_dup; return r; }
        first = false;
    }
    return structure_once(ip, 2000000, 1000000000, false);   // diagnostics on the final attempt
}

static st::Result structure_once(const ir::IProto& ip, int budget, int cap, bool quiet) {
    st::Result res;
    st::Graph g;
    if (!build_graph(ip, g)) { res.ok = false; res.why = "cfg build failed"; return res; }
    if (g.n.empty()) { res.ok = false; res.why = "empty proto"; return res; }
    st::compute_dom(g);
    std::vector<std::set<int>> pd;
    st::compute_postdom(g, pd);
    std::vector<st::Loop> loops = st::find_loops(g);
    st::Ctx C; C.g = &g; C.pd = &pd; C.loops = &loops; C.res = &res; C.diag = quiet ? nullptr : &g_structdiag;
    C.split_budget = budget;
    C.dup_cap = cap;                            // small fixed allowance: enough for the shared
                                                    // branching joins, far too small to thrash
    auto seq = st::structure_seq(C, 0, -1, -1, -1);
    res.root = st::mksn(st::SK2::Seq);
    res.root->body = seq;
    // any REACHABLE block never placed into the tree is unstructured residue
    int missed = 0;
    for (size_t i = 0; i < g.n.size(); ++i)
        if (g.n[i].reach && !C.emitted.count((int)i)) ++missed;
    if (missed) { res.n_unstructured += missed; res.why = "unplaced blocks";
                  for (size_t i = 0; i < g.n.size(); ++i) if (g.n[i].reach && !C.emitted.count((int)i)) {
                      char kb[96];
                      int id = (i < g.idom.size()) ? g.idom[i] : -2;
                      bool idom_placed = (id >= 0 && C.emitted.count(id));
                      std::snprintf(kb,sizeof kb,"unplaced preds=%zu idom=%s",
                                    g.n[i].preds.size(),
                                    id < 0 ? "NONE" : (idom_placed ? "placed" : "ALSO-UNPLACED"));
                      if (!quiet) g_structdiag[kb]++; } }
    if (res.n_unstructured > 0) {
        // Natural structuring failed. Fall back to the dispatch loop, which is EXACT for any CFG,
        // reducible or not. Counted separately — correct-but-unreadable must never be reported as
        // if it were readable.
        int nst = 0;
        res.root = st::build_state_machine(g, nst);
        res.sm_states = nst;
        res.via_state_machine = true;
        res.was_reducible = st::is_reducible(g);
        res.n_unstructured = 0;
    }
    res.ok = true;                    // every proto now has a valid structured representation
    return res;
}

static int cmd_struct_validate(int argc, char** argv) {
    ir_load_namebase();
    fs::path dir = argv[2];
    long long files=0, protos=0, ok=0, bad=0, badcfg=0;
    long long n_if=0, n_wh=0, n_rp=0, n_fn=0, n_fg=0, resid=0;
    std::map<std::string,long long> why;
    auto do_file=[&](const std::string& path){
        std::string b = read_file(path);
        if (b.size() < 2 || (uint8_t)b[0]!=0x09 || (uint8_t)b[1]!=0x03) return;
        de::Module m; try { m = de::walk(b); } catch (...) { return; }
        std::vector<std::string> pool = ir::parse_pool(b);
        ++files;
        for (size_t i = 0; i < m.protos.size(); ++i) {
            ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
            ++protos;
            if (!ip.ok) { ++badcfg; continue; }
            st::Result r = structure_proto(ip);
            n_if += r.n_if; n_wh += r.n_while; n_rp += r.n_repeat;
            n_fn += r.n_fornum; n_fg += r.n_forgen;
            // `ok` is now always true (every proto has SOME valid representation), so the meaningful
            // split is natural structuring vs the state-machine fallback. Reporting them together
            // would hide correct-but-unreadable output inside a 100% headline.
            if (r.via_state_machine) { ++bad; resid += r.sm_states;
                std::printf("  !! FALLBACK %s proto=%zu blocks=%d %s\n",
                            fs::path(path).filename().string().c_str(), i, r.sm_states,
                            r.was_reducible ? "REDUCIBLE" : "irreducible");
                why[r.was_reducible ? "fallback BUT REDUCIBLE (structurer bug)"
                                    : "fallback, genuinely irreducible"]++; }
            else ++ok;
        }
    };
    if (fs::is_directory(dir)) {
        for (auto& e : fs::directory_iterator(dir))
            if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string());
    } else do_file(dir.string());
    std::printf("== M6d CONTROL-FLOW STRUCTURING ==\n");
    std::printf("files=%lld protos=%lld  (annotate-failed: %lld)\n", files, protos, badcfg);
    std::printf("  NATURALLY STRUCTURED  : %lld  (%.4f%%)   <- readable if/while/for output\n",
                ok, protos ? 100.0*ok/protos : 0.0);
    std::printf("  state-machine fallback: %lld  (%.4f%%, %lld states)  <- correct but UNREADABLE\n",
                bad, protos ? 100.0*bad/protos : 0.0, resid);
    std::printf("  UNREPRESENTABLE       : 0\n");
    // A reducible CFG needs NO duplication. This split says how much of the corpus the descent
    // handles HONESTLY versus how much is being papered over by copying blocks.
    std::printf("  structured with ZERO duplication : %lld  (%.4f%%)\n",
                g_zerodup_ok, protos ? 100.0*g_zerodup_ok/protos : 0.0);
    std::printf("  needed duplication              : %lld  (%.4f%%)\n",
                g_needed_dup, protos ? 100.0*g_needed_dup/protos : 0.0);
    // Luau compiles goto-less source, so its output CANNOT be irreducible. Any drop between these
    // two lines is the short-circuit merge CREATING irreducibility by rewriting edges.
    std::printf("  reducible BEFORE short-circuit merge: %lld / %lld\n", g_red_before, g_red_total);
    std::printf("  reducible AFTER  short-circuit merge: %lld / %lld\n", g_red_after,  g_red_total);
    for (auto& kv : why) std::printf("      %-28s %lld\n", kv.first.c_str(), kv.second);
    {   // WHAT shape defeated us. Without this the residue is an undifferentiated 19% and every
        // proposed fix is a guess rather than a response to evidence.
        std::vector<std::pair<long long,std::string>> dv;
        for (auto& kv : g_structdiag) dv.push_back({kv.second, kv.first});
        std::sort(dv.rbegin(), dv.rend());
        std::printf("  -- failure shapes --\n");
        for (size_t i = 0; i < dv.size() && i < 14; ++i)
            std::printf("      %-34s %lld\n", dv[i].second.c_str(), dv[i].first);
    }
    std::printf("  recovered: if=%lld while=%lld repeat=%lld for-num=%lld for-gen=%lld\n",
                n_if, n_wh, n_rp, n_fn, n_fg);
    std::printf("\n  VERDICT: %s\n", bad==0 ? "every proto reduces to structured control flow"
                                            : "some protos retain unstructured control flow");
    return bad==0 ? 0 : 1;
}

// struct-dump <file> <proto> — the graph, the loops, and where structuring stalls.
// Fable's order of operations: VERIFY THE GRAPH before blaming the traversal. A single mis-resolved
// branch target creates a phantom edge, and a phantom edge makes a fine graph unstructurable — which
// would hit exactly the handful of protos containing that rare encoding.
static int cmd_struct_dump(int argc, char** argv) {
    ir_load_namebase();
    std::string b = read_file(argv[2]);
    de::Module m; try { m = de::walk(b); } catch (...) { std::printf("walk failed\n"); return 1; }
    std::vector<std::string> pool = ir::parse_pool(b);
    int pi = std::atoi(argv[3]);
    if (pi < 0 || pi >= (int)m.protos.size()) { std::printf("bad proto\n"); return 1; }
    ir::IProto ip = ir_annotate(m.protos[pi], pi, pool, g_nb);
    if (!ip.ok) { std::printf("annotate failed: %s\n", ip.why.c_str()); return 1; }
    st::Graph g;
    if (!build_graph(ip, g)) { std::printf("build_graph failed\n"); return 1; }
    st::compute_dom(g);
    std::vector<st::Loop> loops = st::find_loops(g);
    std::printf("proto[%d] blocks=%zu insns=%zu reducible=%s\n",
                pi, g.n.size(), ip.code.size(), st::is_reducible(g) ? "YES" : "no");
    std::printf("\n%-4s %-8s %-6s %-6s %-6s %-5s %s\n","blk","insns","term","true","false","idom","preds");
    for (size_t i = 0; i < g.n.size(); ++i) {
        const st::Node& n = g.n[i];
        if (!n.reach) { std::printf("%-4zu  (merged/unreachable)\n", i); continue; }
        std::string pr;
        for (int p : n.preds) { pr += std::to_string(p); pr += " "; }
        const OpInfo* oi = opinfo(n.term);
        std::printf("%-4zu %3d..%-4d %-6s %-6d %-6d %-5d %s\n",
                    i, n.first, n.last, oi ? oi->name : "??",
                    n.succ_true, n.succ_false, (i<g.idom.size()?g.idom[i]:-1), pr.c_str());
    }
    std::printf("\nloops found: %zu\n", loops.size());
    for (size_t i = 0; i < loops.size(); ++i) {
        const st::Loop& L = loops[i];
        std::printf("  loop%zu header=%-4d latch=%-4d kind=%s body={", i, L.header, L.latch,
                    L.kind==st::Loop::ForNum?"ForNum":L.kind==st::Loop::ForGen?"ForGen":"While/Rep");
        for (int x : L.body) std::printf("%d ", x);
        std::printf("} size=%zu\n", L.body.size());
    }
    // OVERLAP CHECK — Fable's hunch: two loop-finders claiming the same block with different bodies.
    int overlaps = 0;
    for (size_t i = 0; i < loops.size(); ++i)
        for (size_t j = i+1; j < loops.size(); ++j) {
            bool inter=false, nest_ij=true, nest_ji=true;
            for (int x : loops[i].body) if (loops[j].body.count(x)) inter = true;
            for (int x : loops[i].body) if (!loops[j].body.count(x)) nest_ij = false;
            for (int x : loops[j].body) if (!loops[i].body.count(x)) nest_ji = false;
            if (inter && !nest_ij && !nest_ji) {
                std::printf("  !! loop%zu and loop%zu OVERLAP without nesting (headers %d / %d)\n",
                            i, j, loops[i].header, loops[j].header);
                ++overlaps;
            }
            if (loops[i].header == loops[j].header)
                std::printf("  !! loop%zu and loop%zu share header %d (bodies %zu vs %zu)\n",
                            i, j, loops[i].header, loops[i].body.size(), loops[j].body.size());
        }
    std::printf("non-nesting overlaps: %d\n", overlaps);
    return 0;
}

// sa-validate <dir> — STRUCTURAL ANALYSIS acceptance metric.
// A reducible CFG must reduce to ONE region with NO duplication. This is the honest test the
// descent could not pass: "did the graph collapse completely?" has no crutch available.
static int cmd_sa_validate(int argc, char** argv) {
    ir_load_namebase();
    fs::path dir = argv[2];
    long long files=0, protos=0, full=0, partial=0; long long resid=0;
    std::map<int,long long> leftover;
    auto do_file=[&](const std::string& path){
        std::string b = read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try { m = de::walk(b); } catch (...) { return; }
        std::vector<std::string> pool = ir::parse_pool(b);
        ++files;
        for (size_t i = 0; i < m.protos.size(); ++i) {
            ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
            ++protos;
            if (!ip.ok) continue;
            st::Graph g;
            if (!build_graph(ip, g)) continue;
            st::compute_dom(g);
            sa::Analyzer A; A.build(g);
            int steps = 0;
            if (A.reduce(steps)) {
                ++full;
                int miss=0, dup=0;
                int rc = A.verify_coverage(g, miss, dup);
                if (rc != 0) { ++g_cov_bad; g_cov_missing += miss; g_cov_dupd += dup; }
                else ++g_cov_ok;
            }
            else { ++partial; resid += (long long)A.live.size();
                   leftover[(int)std::min<size_t>(A.live.size(), 20)]++;
                   if (getenv("RENOVICE_SA_DUMP") && partial <= 3) {
                       std::printf("\n-- RESIDUAL %s proto=%zu : %zu regions --\n",
                                   fs::path(path).filename().string().c_str(), i, A.live.size());
                       for (int r : A.live) {
                           std::printf("   r%-4d kind=%d succ={", r, (int)A.regions[r].kind);
                           for (int s2 : A.succ[r]) std::printf("%d ", s2);
                           std::printf("} pred={");
                           for (int q : A.pred[r]) std::printf("%d ", q);
                           std::printf("}%s\n", r == A.entry ? "  <-- ENTRY" : "");
                       }
                   } }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e : fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    std::printf("== STRUCTURAL ANALYSIS (pure reduction, ZERO duplication) ==\n");
    std::printf("protos=%lld\n", protos);
    std::printf("  fully reduced to ONE region : %lld  (%.4f%%)\n", full, protos?100.0*full/protos:0.0);
    std::printf("  irreducible residue         : %lld  (%lld regions left over)\n", partial, resid);
    std::printf("  ADVERSARIAL coverage check (every block present EXACTLY once):\n");
    std::printf("      clean protos          : %lld\n", g_cov_ok);
    std::printf("      BAD protos            : %lld   (missing blocks %lld, duplicated blocks %lld)\n",
                g_cov_bad, g_cov_missing, g_cov_dupd);
    std::printf("  leftover-size histogram (capped at 20):\n");
    for (auto& kv : leftover) std::printf("      %3d regions : %lld protos\n", kv.first, kv.second);
    if (std::getenv("RENOVICE_SCLIVE")) {
        std::printf("  statement-bearing short-circuit liveness audit:\n");
        std::printf("      blocked candidates   : %lld\n", g_sclive_blocked);
        std::printf("      exact closed chains  : %lld\n", g_sclive_exact);
        std::printf("      rejected unknown     : %lld\n", g_sclive_unknown);
        std::printf("      rejected no-def      : %lld\n", g_sclive_nodef);
        std::printf("      rejected multi-def   : %lld\n", g_sclive_multidef);
        std::printf("      rejected not-single  : %lld\n", g_sclive_nonsingle);
        std::printf("      rejected early-use   : %lld\n", g_sclive_earlyuse);
        std::printf("      rejected live-out    : %lld\n", g_sclive_liveout);
        std::vector<std::pair<long long, std::string>> shapes;
        for (const auto& entry : g_sclive_exact_shapes)
            shapes.push_back({entry.second, entry.first});
        std::sort(shapes.begin(), shapes.end(), [](const auto& a, const auto& b) {
            return a.first != b.first ? a.first > b.first : a.second < b.second;
        });
        std::printf("      top exact shapes     :\n");
        for (size_t i = 0; i < shapes.size() && i < 15; ++i)
            std::printf("        %7lld  %s\n", shapes[i].first, shapes[i].second.c_str());
    }
    return partial==0 ? 0 : 1;
}
