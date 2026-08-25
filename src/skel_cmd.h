// skel_cmd.h — SEMANTIC SKELETON: an instruction-level equivalence signature.
//
// Every oracle we had compares our output to ITSELF (decompile -> recompile -> decompile). That is
// SELF-CONSISTENCY, and it is structurally blind to a consistent misreading: #56 (NEWCLOSURE resolved
// against the wrong table, so the WRONG FUNCTION was inlined) survived 5,386/5,386 round-trips and
// 150/150 behavioural traces, because `recompile` faithfully writes back whatever `decompile` misread.
//
// The decompiler literature calls the missing piece instruction-level equivalence alignment. We cannot
// run DE bytecode offline and the original sources do not exist — but we HAVE both bytecodes, so we
// can align them directly.
//
// The skeleton keeps what is SEMANTIC and drops what is an allocation detail:
//   KEEP  : calls and the NAME called, field/global/import ACCESS BY NAME, table ops, branch shape,
//           returns, closure creation and WHICH proto it binds
//   DROP  : register numbers, MOVE/LOADNIL (our materialisation adds these by design), instruction
//           order within a straight run of loads
// Two protos with the same skeleton do the same things to the same named entities in the same order.
// This would have caught #56 (wrong proto bound) and #57 (`{x, y}` reading globals) immediately, with
// no execution required.
#pragma once

static const char* skel_class(uint8_t op) {
    switch (op) {
        case 0x54: return "CALL";
        case 0x2d: return "NAMECALL";
        case 0x29: return "RETURN";
        case 0x02: return "SETGLOBAL";
        case 0x17: return "GETGLOBAL";
        case 0x46: return "GETIMPORT";
        case 0x3d: return "GETFIELD";
        case 0x15: return "SETFIELD";
        case 0x2a: return "SETINDEX";
        case 0x28: return "GETINDEX";
        case 0x2c: return "NEWTABLE";
        case 0x4f: return "DUPTABLE";
        case 0x3f: return "SETLIST";
        // ONE class for both. DUPCLOSURE caches a pre-created closure, NEWCLOSURE builds a
        // fresh one, and Luau picks between them by whether the closure captures anything —
        // our lexical nesting gives captures where DE had none, so the OPCODE differs while
        // the BOUND PROTO is identical. Comparing the target is the semantic content.
        // CAVEAT: this means closure-IDENTITY/caching differences are NOT detected here.
        case 0x16: case 0x42: return "CLOSURE";
        case 0x13: return "GETUPVAL";
        case 0x53: return "SETUPVAL";
        case 0x35: return "CAPTURE";
        case 0x47: return "FORNPREP";
        case 0x0a: return "FORNLOOP";
        case 0x1e: return "FORGLOOP";
        case 0x30: case 0x1b: case 0x0b: return "FORGPREP";
        // branches: shape matters, target register does not
        case 0x4b: case 0x18: case 0x37: case 0x27: case 0x21: case 0x1c: case 0x23: case 0x33:
        case 0x20: case 0x41: case 0x34: case 0x3a: return "BRANCH";
        case 0x40: case 0x25: return "JUMP";
        default: return nullptr;                  // arithmetic/loads: allocation detail, skipped
    }
}

// One line per semantically-relevant instruction: CLASS<TAB>NAME. The NAME is what makes this strong —
// two GETIMPORTs of DIFFERENT paths are different behaviour even though the opcode histogram matches.
// Which INSTRUCTIONS sit in blocks the CFG can actually reach? The emitter drops unreachable blocks by
// design (M6b established they are benign compiler dead code), so the original bytecode legitimately
// contains named accesses that never appear in our output. Comparing raw totals therefore charges us
// for code that can never run. Returns all-live when no CFG can be built, so the filter can only ever
// remove instructions we have positively PROVEN unreachable.
static std::vector<char> live_mask(const ir::IProto& ip) {
    std::vector<char> live(ip.code.size(), 0);
    st::Graph g;
    if (!build_graph(ip, g)) { std::fill(live.begin(), live.end(), 1); return live; }
    for (const st::Node& nd : g.n)
        if (nd.reach)
            for (int q = nd.first; q <= nd.last && q < (int)live.size(); ++q) live[q] = 1;
    return live;
}

// Identifying a closure target by its proto INDEX is only meaningful WITHIN one module. Our emission
// order legitimately differs from the original (inlining decides order; a duplicated target shifts
// everything after it), so `proto#5` on each side is usually a DIFFERENT FUNCTION and comparing the
// indices reports a difference that says nothing. Identify the target by a RECURSIVE CONTENT SIGNATURE
// instead: the hash of its own skeleton, with its closure references replaced by their signatures.
// Order-independent, and strictly STRONGER at catching #56 (wrong proto bound) than an index compare.
struct SkelCtx {
    const std::vector<ir::IProto>* ips = nullptr;
    std::vector<uint64_t> sig;
    std::vector<char>     state;          // 0 unvisited, 1 in-progress, 2 done
    bool live_only = false;
};
static std::string skeleton_of(const ir::IProto& ip, SkelCtx* ctx);

static uint64_t proto_sig(SkelCtx& ctx, int idx) {
    if (!ctx.ips || idx < 0 || idx >= (int)ctx.ips->size()) return 0;
    if (ctx.state[idx] == 2) return ctx.sig[idx];
    if (ctx.state[idx] == 1) return 0xC1C1C1C1C1C1C1C1ull;   // cycle: one fixed token, both sides alike
    ctx.state[idx] = 1;
    std::string s = skeleton_of((*ctx.ips)[idx], &ctx);
    // Hash ONLY the lines the comparison actually treats as semantic: NAMED entity accesses. Branch
    // lines must be excluded or the signature inherits exactly the control-flow encoding differences
    // we have already decided are ours-to-choose (Proper-region state tests, JUMPXEQK lowering) — which
    // would make every single closure target mismatch and drown the real signal.
    uint64_t h = 1469598103934665603ull;
    size_t pos = 0;
    while (pos < s.size()) {
        size_t e = s.find('\n', pos); if (e == std::string::npos) e = s.size();
        std::string ln = s.substr(pos, e - pos); pos = e + 1;
        if (ln.find('\t') == std::string::npos) continue;              // unnamed op: allocation detail
        if (ln.compare(0, 7, "BRANCH\t") == 0) continue;               // control-flow encoding: ours
        for (unsigned char c : ln) { h ^= c; h *= 1099511628211ull; }
        h ^= '\n'; h *= 1099511628211ull;
    }
    ctx.state[idx] = 2; ctx.sig[idx] = h;
    return h;
}

static std::string skeleton_of(const ir::IProto& ip, SkelCtx* ctx) {
    std::string out;
    std::vector<char> live;
    bool live_only = ctx && ctx->live_only;
    if (live_only) live = live_mask(ip);
    for (size_t idx = 0; idx < ip.code.size(); ++idx) {
        if (live_only && !live[idx]) continue;
        const ir::IInsn& in = ip.code[idx];
        const char* c = skel_class(in.op);
        if (!c) continue;
        std::string name;
        // Branches must be normalised BY VALUE, not by whatever `note` happens to hold. 0x34
        // (JUMPXEQKB) compares a boolean IMMEDIATE -- `aux & 1` IS the value and there is NO const
        // index -- so reading `note` there reports a phantom constant and the oracle flags its own
        // rendering artefact as a defect. 0x20/0x41 carry a const index in the low bits; 0x3a is nil.
        if (in.op == 0x34) {
            name = std::string("bool:") + ((in.aux & 1) ? "true" : "false");
        } else if (in.op == 0x3a) {
            name = "nil";
        } else if (in.op == 0x20 || in.op == 0x41) {
            int ki = (int)(in.aux & 0x7fffffffu);
            name = (ki >= 0 && ki < (int)ip.consts.size()) ? ir::value_text(ip.consts[ki]) : "?";
        } else if (skel_class(in.op) == std::string("BRANCH")) {
            name.clear();                                   // reg-reg compare: no constant involved
        } else if (!in.note.empty()) name = in.note;
        else if (in.op == 0x16) {                 // NEWCLOSURE: WHICH proto, via the child list
            name = (in.Bx < (int)ip.kids.size()) ? ("proto#" + std::to_string(ip.kids[in.Bx]))
                                                 : ("child?" + std::to_string(in.Bx));
        } else if (in.op == 0x42) {               // DUPCLOSURE: WHICH proto, via the constant
            if (in.Bx < (int)ip.consts.size() && ip.consts[in.Bx].kind == ir::KKind::Closure)
                name = "proto#" + std::to_string((int)ip.consts[in.Bx].sub);
        }
        // `note` wins above, but for closures the RESOLVED TARGET must win over any note text
        // (ir renders a tag-6 const as "<proto N>", which would not compare equal to our token).
        int tgt = -1;
        if (in.op == 0x16) tgt = (in.Bx < (int)ip.kids.size()) ? (int)ip.kids[in.Bx] : -1;
        else if (in.op == 0x42 && in.Bx < (int)ip.consts.size()
                 && ip.consts[in.Bx].kind == ir::KKind::Closure)
            tgt = (int)ip.consts[in.Bx].sub;
        if (in.op == 0x16 || in.op == 0x42) {
            if (tgt < 0) name = "child?" + std::to_string(in.Bx);
            else if (ctx && ctx->ips) {
                char hb[32];
                std::snprintf(hb, sizeof hb, "proto:%016llx",
                              (unsigned long long)proto_sig(*ctx, tgt));
                name = hb;
            } else name = "proto#" + std::to_string(tgt);
        }
        out += c;
        if (!name.empty()) { out += "\t"; out += name; }
        out += "\n";
    }
    return out;
}

// Which protos are REACHABLE from the chunk? A proto that no closure instruction can create is dead
// code that can never execute; `decompile-mod` emits only reachable code, so dropping one is expected
// rather than a loss. Closure sites in unreachable blocks do not make their targets reachable.
static std::vector<char> reachable_proto_mask(const std::vector<ir::IProto>& ips) {
    size_t n = ips.size();
    std::vector<char> seen(n, 0);
    std::vector<int> stk;
    if (n) { stk.push_back((int)n - 1); seen[n - 1] = 1; }      // the chunk is the LAST proto
    while (!stk.empty()) {
        int p = stk.back(); stk.pop_back();
        if (p < 0 || p >= (int)n) continue;
        // Only closure sites in LIVE blocks count. The emitter drops unreachable blocks, so a closure
        // created solely in dead code is statically "reachable" yet never emitted — counting it made
        // a benign drop look like a lost proto.
        st::Graph g; std::vector<char> live(ips[p].code.size(), 0);
        if (build_graph(ips[p], g)) {
            for (const st::Node& nd : g.n)
                if (nd.reach)
                    for (int q = nd.first; q <= nd.last && q < (int)live.size(); ++q) live[q] = 1;
        } else {
            for (size_t q = 0; q < live.size(); ++q) live[q] = 1;   // no CFG: be conservative
        }
        for (size_t ii = 0; ii < ips[p].code.size(); ++ii) {
            if (!live[ii]) continue;
            const ir::IInsn& in = ips[p].code[ii];
            int t = -1;
            if (in.op == 0x16 && in.Bx < (int)ips[p].kids.size()) t = (int)ips[p].kids[in.Bx];
            else if (in.op == 0x42 && in.Bx < (int)ips[p].consts.size()
                     && ips[p].consts[in.Bx].kind == ir::KKind::Closure)
                t = (int)ips[p].consts[in.Bx].sub;
            if (t >= 0 && t < (int)n && !seen[t]) { seen[t] = 1; stk.push_back(t); }
        }
    }
    return seen;
}

static int cmd_orphans(int argc, char** argv) {
    ir_load_namebase();
    std::string b = read_file(argv[2]);
    de::Module m;
    try { m = de::walk(b); } catch (const std::exception& e) {
        std::fprintf(stderr, "walk error: %s\n", e.what()); return 1; }
    std::vector<std::string> pool = ir::parse_pool(b);
    size_t n = m.protos.size();
    std::vector<ir::IProto> ips;
    for (size_t i = 0; i < n; ++i) ips.push_back(ir_annotate(m.protos[i], (int)i, pool, g_nb));
    std::vector<char> seen = reachable_proto_mask(ips);
    size_t reach = 0; for (char c : seen) reach += c ? 1 : 0;
    std::printf("protos=%zu reachable=%zu orphans=%zu\n", n, reach, n - reach);
    if (argc >= 4 && std::string(argv[3]) == "-v") {
        for (size_t target = 0; target < n; ++target) {
            if (seen[target]) continue;
            std::printf("orphan[%zu]", target);
            bool referenced = false;
            for (size_t parent = 0; parent < n; ++parent) {
                st::Graph g; std::vector<char> live(ips[parent].code.size(), 0);
                if (build_graph(ips[parent], g)) {
                    for (const st::Node& nd : g.n)
                        if (nd.reach)
                            for (int q = nd.first; q <= nd.last && q < (int)live.size(); ++q)
                                live[(size_t)q] = 1;
                } else {
                    std::fill(live.begin(), live.end(), 1);
                }
                for (size_t ii = 0; ii < ips[parent].code.size(); ++ii) {
                    const ir::IInsn& in = ips[parent].code[ii];
                    int resolved = -1;
                    if (in.op == 0x16 && in.Bx < (int)ips[parent].kids.size())
                        resolved = (int)ips[parent].kids[in.Bx];
                    else if (in.op == 0x42 && in.Bx < (int)ips[parent].consts.size()
                             && ips[parent].consts[in.Bx].kind == ir::KKind::Closure)
                        resolved = (int)ips[parent].consts[in.Bx].sub;
                    if (resolved != (int)target) continue;
                    std::printf(" %sparent=%zu@%zu", referenced ? "," : "refs=",
                                parent, ii);
                    std::printf("(%s)", live[ii] ? "live" : "dead");
                    referenced = true;
                }
            }
            if (!referenced) std::printf(" refs=none");
            std::printf("\n");
        }
    }
    return 0;
}

// BACK EDGES: the structural invariant we were missing. An edge u->v is a back edge iff v DOMINATES
// u, and each back edge must correspond to EXACTLY ONE loop construct in the output. Comparing the
// back-edge count of the ORIGINAL against our RECOMPILE measures loop recovery DIRECTLY, instead of
// inferring it from loop-opcode counts (which conflate a lost loop with a re-encoded one, and cannot
// see a loop emitted twice around one body). Standard across the literature (dcc, Ghidra, Phoenix);
// the OOPSLA-2024 decompiler-bug study names this failure class "region restoration".
static int cmd_backedges(int argc, char** argv) {
    ir_load_namebase();
    std::string b = read_file(argv[2]);
    de::Module m;
    try { m = de::walk(b); } catch (const std::exception& e) {
        std::fprintf(stderr, "walk error: %s\n", e.what()); return 1; }
    std::vector<std::string> pool = ir::parse_pool(b);
    bool verbose = false;
    for (int i = 3; i < argc; ++i) if (std::string(argv[i]) == "-v") verbose = true;
    long total = 0, headers = 0, mapped = 0;
    for (size_t i = 0; i < m.protos.size(); ++i) {
        ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
        st::Graph g;
        if (!build_graph(ip, g)) continue;
        st::compute_dom(g);
        int n = 0;
        std::set<int> hdrs;                         // distinct back-edge TARGETS
        for (size_t u = 0; u < g.n.size(); ++u) {
            if (!g.n[u].reach) continue;            // dead code cannot loop at runtime
            int ss[2] = { g.n[u].succ_true, g.n[u].succ_false };
            if (ss[0] == ss[1]) ss[1] = -1;         // one edge, not two
            for (int k = 0; k < 2; ++k) {
                int v = ss[k];
                if (v < 0 || v >= (int)g.n.size()) continue;
                if (g.dom[u].count(v)) { ++n; hdrs.insert(v); }  // v dom u => (u,v) is a back edge
            }
        }
        // COMPLETENESS CHECK for the authoritative loop map: the number of loops find_loops reports
        // must equal the number of distinct back-edge headers the CFG actually has. If the map is
        // short, it cannot be used to gate emission — that is exactly what made #67 lose loops.
        std::set<int> maph;
        for (const st::Loop& L : st::find_loops(g)) if (L.header >= 0) maph.insert(L.header);
        mapped += (long)maph.size();
        total += n; headers += (long)hdrs.size();
        if (verbose && (n || maph.size()))
            std::printf("proto[%zu] backedges=%d headers=%zu map=%zu%s\n", i, n, hdrs.size(),
                        maph.size(), (maph.size() == hdrs.size() ? "" : "   <== MAP MISMATCH"));
    }
    // BOTH numbers, because they answer different questions. Two back edges targeting the SAME header
    // are ONE loop with two latches (e.g. a `continue`), not two loops — so LOOP COUNT is the header
    // count, while the back-edge count also catches a latch being lost or invented. Reporting only one
    // of them would silently pick a side on an invariant we have not yet established.
    std::printf("TOTAL backedges=%ld headers=%ld mapped=%ld\n", total, headers, mapped);
    return 0;
}

// LOOP IDENTITY: counts alone cannot distinguish "one real loop was lost and one unrelated loop was
// duplicated" from exact recovery.  Report the authoritative dominance/pattern loop forest and the
// structural regions that claim it, preserving the facts needed to compare identity: kind, header,
// prep, every back-edge latch, body, exits, and nesting parent.  This command is diagnostic-only; it
// does not participate in emission and therefore cannot change generated source.
static const char* loop_identity_kind(const st::Loop& loop, const st::Graph& g,
                                      const std::set<int>& latches) {
    if (loop.kind == st::Loop::ForNum) return "ForNum";
    if (loop.kind == st::Loop::ForGen) return "ForGen";
    bool header_tests_exit = false;
    if (loop.header >= 0 && loop.header < (int)g.n.size() && g.n[loop.header].is_branch)
        for (int succ : {g.n[loop.header].succ_true, g.n[loop.header].succ_false})
            if (succ >= 0 && !loop.body.count(succ)) header_tests_exit = true;
    if (header_tests_exit) return "WhileLike";
    for (int latch : latches) {
        if (latch < 0 || latch >= (int)g.n.size() || !g.n[latch].is_branch) continue;
        bool returns = g.n[latch].succ_true == loop.header || g.n[latch].succ_false == loop.header;
        bool exits = (g.n[latch].succ_true >= 0 && !loop.body.count(g.n[latch].succ_true))
            || (g.n[latch].succ_false >= 0 && !loop.body.count(g.n[latch].succ_false));
        if (returns && exits) return "RepeatLike";
    }
    return "EndlessLike";
}

static const char* loop_identity_region_kind(sa::RK kind) {
    switch (kind) {
        case sa::RK::Basic: return "Basic";
        case sa::RK::Seq: return "Seq";
        case sa::RK::IfThen: return "IfThen";
        case sa::RK::IfThenElse: return "IfThenElse";
        case sa::RK::SelfLoop: return "SelfLoop";
        case sa::RK::While: return "While";
        case sa::RK::NaturalLoop: return "NaturalLoop";
        case sa::RK::Proper: return "Proper";
    }
    return "Unknown";
}

static void loop_identity_print_set(const std::set<int>& values) {
    bool first = true;
    for (int value : values) {
        if (!first) std::printf(",");
        std::printf("%d", value);
        first = false;
    }
    if (first) std::printf("-");
}

static int cmd_loop_identity(int argc, char** argv) {
    ir_load_namebase();
    std::string bytes = read_file(argv[2]);
    de::Module module;
    try { module = de::walk(bytes); }
    catch (const std::exception& e) {
        std::fprintf(stderr, "walk error: %s\n", e.what()); return 1;
    }
    int selected_proto = -1;
    for (int i = 3; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--proto" && i + 1 < argc) selected_proto = std::atoi(argv[++i]);
    }
    if (selected_proto >= (int)module.protos.size()) {
        std::fprintf(stderr, "prototype index out of range: %d (count=%zu)\n",
                     selected_proto, module.protos.size());
        return 1;
    }
    std::vector<std::string> pool = ir::parse_pool(bytes);
    long total_cfg = 0, total_regions = 0, total_unclaimed = 0, total_ambiguous = 0;
    for (size_t proto = 0; proto < module.protos.size(); ++proto) {
        if (selected_proto >= 0 && (int)proto != selected_proto) continue;
        ir::IProto ip = ir_annotate(module.protos[proto], (int)proto, pool, g_nb);
        st::Graph graph;
        if (!build_graph(ip, graph)) {
            std::printf("== proto[%zu] CFG-ERROR ==\n", proto);
            continue;
        }
        st::compute_dom(graph);
        std::vector<st::Loop> loops = st::find_loops(graph);
        sa::Analyzer analyzer; analyzer.build(graph);
        int steps = 0; analyzer.reduce(steps);

        std::vector<std::set<int>> loop_latches(loops.size()), loop_exits(loops.size());
        std::vector<int> parent(loops.size(), -1), depth(loops.size(), 0);
        for (size_t i = 0; i < loops.size(); ++i) {
            for (size_t block = 0; block < graph.n.size(); ++block) {
                if (!graph.n[block].reach) continue;
                for (int succ : {graph.n[block].succ_true, graph.n[block].succ_false}) {
                    if (succ == loops[i].header && st::dominates(graph, loops[i].header, (int)block))
                        loop_latches[i].insert((int)block);
                    if (loops[i].body.count((int)block) && succ >= 0
                        && !loops[i].body.count(succ)) loop_exits[i].insert(succ);
                }
            }
            size_t parent_size = (size_t)-1;
            for (size_t candidate = 0; candidate < loops.size(); ++candidate) {
                if (candidate == i || loops[candidate].body.size() <= loops[i].body.size()) continue;
                bool subset = true;
                for (int block : loops[i].body)
                    if (!loops[candidate].body.count(block)) { subset = false; break; }
                if (subset && loops[candidate].body.size() < parent_size) {
                    parent[i] = (int)candidate;
                    parent_size = loops[candidate].body.size();
                }
            }
        }
        for (size_t i = 0; i < loops.size(); ++i) {
            std::set<int> seen;
            for (int cursor = parent[i]; cursor >= 0 && cursor < (int)loops.size()
                 && seen.insert(cursor).second; cursor = parent[(size_t)cursor]) ++depth[i];
        }

        std::vector<std::set<int>> region_blocks(analyzer.regions.size());
        auto collect_region = [&](auto&& self, int region, std::set<int>& blocks,
                                  std::set<int>& seen) -> void {
            if (region < 0 || region >= (int)analyzer.regions.size()
                || !seen.insert(region).second) return;
            const sa::Region& item = analyzer.regions[(size_t)region];
            if (item.kind == sa::RK::Basic) { blocks.insert(item.block); return; }
            for (int child : item.parts) self(self, child, blocks, seen);
        };
        for (size_t region = 0; region < analyzer.regions.size(); ++region) {
            std::set<int> seen;
            collect_region(collect_region, (int)region, region_blocks[region], seen);
        }

        std::vector<int> loop_regions;
        for (size_t region = 0; region < analyzer.regions.size(); ++region) {
            sa::RK kind = analyzer.regions[region].kind;
            if (kind == sa::RK::SelfLoop || kind == sa::RK::While || kind == sa::RK::NaturalLoop)
                loop_regions.push_back((int)region);
        }
        // A loop region owns the innermost authoritative loop containing the region's OWN head
        // block.  Merely asking which loop headers occur anywhere in the region mislabels a valid
        // outer loop as also owning all nested loops inside its body (Rhino p10 region 91).
        std::map<int, std::set<int>> region_candidates;
        for (int region : loop_regions) {
            const sa::Region& item = analyzer.regions[(size_t)region];
            int head_block = -1;
            if (item.head >= 0 && item.head < (int)region_blocks.size()
                && !region_blocks[(size_t)item.head].empty())
                head_block = *region_blocks[(size_t)item.head].begin();
            size_t smallest_body = (size_t)-1;
            for (const st::Loop& loop : loops) {
                if (head_block < 0 || !loop.body.count(head_block)) continue;
                if (loop.body.size() < smallest_body) {
                    region_candidates[region].clear();
                    smallest_body = loop.body.size();
                }
                if (loop.body.size() == smallest_body)
                    region_candidates[region].insert(loop.header);
            }
        }
        std::printf("== proto[%zu] blocks=%zu cfg_loops=%zu loop_regions=%zu reduced_live=%zu steps=%d ==\n",
                    proto, graph.n.size(), loops.size(), loop_regions.size(), analyzer.live.size(), steps);
        for (size_t i = 0; i < loops.size(); ++i) {
            std::set<int> claims;
            for (int region : loop_regions)
                if (region_candidates[region].count(loops[i].header)) claims.insert(region);
            if (claims.empty()) ++total_unclaimed;
            if (claims.size() > 1) ++total_ambiguous;
            std::printf("CFG loop[%zu] kind=%s header=%d prep=%d primary_latch=%d parent_header=%d "
                        "depth=%d body_count=%zu latches=",
                        i, loop_identity_kind(loops[i], graph, loop_latches[i]), loops[i].header,
                        loops[i].prep, loops[i].latch,
                        parent[i] >= 0 ? loops[(size_t)parent[i]].header : -1,
                        depth[i], loops[i].body.size());
            loop_identity_print_set(loop_latches[i]);
            std::printf(" exits="); loop_identity_print_set(loop_exits[i]);
            std::printf(" claims="); loop_identity_print_set(claims);
            std::printf(" body="); loop_identity_print_set(loops[i].body);
            std::printf("\n");
        }
        for (int region : loop_regions) {
            const sa::Region& item = analyzer.regions[(size_t)region];
            const std::set<int>& heads = region_candidates[region];
            int head_block = -1;
            if (item.head >= 0 && item.head < (int)region_blocks.size()
                && !region_blocks[(size_t)item.head].empty())
                head_block = *region_blocks[(size_t)item.head].begin();
            std::printf("REGION id=%d kind=%s head_region=%d head_block=%d block_count=%zu "
                        "candidate_headers=", region, loop_identity_region_kind(item.kind),
                        item.head, head_block, region_blocks[(size_t)region].size());
            loop_identity_print_set(heads);
            std::printf(" blocks="); loop_identity_print_set(region_blocks[(size_t)region]);
            std::printf("\n");
        }
        total_cfg += (long)loops.size();
        total_regions += (long)loop_regions.size();
    }
    std::printf("TOTAL cfg_loops=%ld loop_regions=%ld unclaimed=%ld ambiguous=%ld\n",
                total_cfg, total_regions, total_unclaimed, total_ambiguous);
    return 0;
}

// THE FORK. The workflow's designated fork agent crashed on infrastructure (worktree needs git), so
// this measurement — the one that decides emitter-fix vs structurer-fix — was never actually made.
// Per proto: does the number of loop-KIND regions the structurer classifies (SelfLoop/While/
// NaturalLoop) equal the number of distinct back-edge HEADERS the CFG actually has? Each loop-kind
// region is created exactly once at classification time, so the count is unambiguous — unlike the
// region `head` field, which is a region id renumbered through reduction. If the two counts agree per
// proto, the structurer classifies loops correctly and the bug is purely in the EMITTER's second
// detector. If they diverge, the structurer itself is misclassifying and no emitter change converges.
static int cmd_loopfork(int argc, char** argv) {
    ir_load_namebase();
    std::string b = read_file(argv[2]);
    de::Module m;
    try { m = de::walk(b); } catch (const std::exception& e) {
        std::fprintf(stderr, "walk error: %s\n", e.what()); return 1; }
    std::vector<std::string> pool = ir::parse_pool(b);
    long clean = 0, more = 0, fewer = 0, nprotos = 0, propers = 0, propers_compound = 0, propers_loopkind = 0;
    for (size_t i = 0; i < m.protos.size(); ++i) {
        ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
        st::Graph g;
        if (!build_graph(ip, g)) continue;
        st::compute_dom(g);
        // distinct back-edge headers
        std::set<int> hdrs;
        for (size_t u = 0; u < g.n.size(); ++u) {
            if (!g.n[u].reach) continue;
            int ss[2] = { g.n[u].succ_true, g.n[u].succ_false };
            if (ss[0] == ss[1]) ss[1] = -1;
            for (int k = 0; k < 2; ++k) {
                int v = ss[k];
                if (v >= 0 && v < (int)g.n.size() && g.dom[u].count(v)) hdrs.insert(v);
            }
        }
        // loop-kind regions the structurer classified
        sa::Analyzer A; A.build(g);
        int steps = 0; A.reduce(steps);
        int loopregs = 0;
        for (const sa::Region& r : A.regions)
            if (r.kind == sa::RK::SelfLoop || r.kind == sa::RK::While || r.kind == sa::RK::NaturalLoop)
                ++loopregs;
        // Does any Proper region DIRECTLY contain a compound (non-Basic) part, and specifically a
        // LOOP-KIND one? The Proper emitter flattens its parts to bare blocks via collect_blocks, so a
        // loop-kind sub-region there would lose its for/while wrapper entirely. Verifying the shape
        // EXISTS before building a fix for it — the diagnosis that proposed this cited worked examples
        // its own adversary showed were a different mechanism.
        for (const sa::Region& rr : A.regions) {
            if (rr.kind != sa::RK::Proper) continue;
            ++propers;
            bool compound = false, loopkind = false;
            for (int pid : rr.parts) {
                if (pid < 0 || pid >= (int)A.regions.size()) continue;
                sa::RK pk = A.regions[pid].kind;
                if (pk != sa::RK::Basic) compound = true;
                if (pk == sa::RK::SelfLoop || pk == sa::RK::While || pk == sa::RK::NaturalLoop)
                    loopkind = true;
            }
            if (compound) ++propers_compound;
            if (loopkind) ++propers_loopkind;
        }
        ++nprotos;
        if (loopregs == (int)hdrs.size()) ++clean;
        else if (loopregs > (int)hdrs.size()) ++more;   // structurer classified MORE loops than exist
        else ++fewer;                                   // structurer classified FEWER
        bool verbose = false;
        for (int a = 3; a < argc; ++a) if (std::string(argv[a]) == "-v") verbose = true;
        if (verbose && loopregs != (int)hdrs.size())
            std::printf("proto[%zu] headers=%zu loopregs=%d\n", i, hdrs.size(), loopregs);
    }
    std::printf("PROTOS=%ld CLEAN=%ld MORE=%ld FEWER=%ld PROPER=%ld PCOMPOUND=%ld PLOOPKIND=%ld\n", nprotos, clean, more, fewer, propers, propers_compound, propers_loopkind);
    return 0;
}

static int cmd_skeleton(int argc, char** argv) {
    ir_load_namebase();
    std::string b = read_file(argv[2]);
    de::Module m;
    try { m = de::walk(b); }
    catch (const std::exception& e) { std::fprintf(stderr, "walk error: %s\n", e.what()); return 1; }
    SkelCtx ctx;
    bool reachable_only = false;
    for (int i = 3; i < argc; ++i) {
        if (std::string(argv[i]) == "--live") ctx.live_only = true;
        if (std::string(argv[i]) == "--reachable") reachable_only = true;
    }
    std::vector<std::string> pool = ir::parse_pool(b);
    std::vector<ir::IProto> ips;
    for (size_t i = 0; i < m.protos.size(); ++i)
        ips.push_back(ir_annotate(m.protos[i], (int)i, pool, g_nb));
    ctx.ips = &ips; ctx.sig.assign(ips.size(), 0); ctx.state.assign(ips.size(), 0);
    std::vector<char> reachable;
    if (reachable_only) reachable = reachable_proto_mask(ips);
    for (size_t i = 0; i < ips.size(); ++i) {
        if (reachable_only && !reachable[i]) continue;
        std::printf("== proto[%zu] nparams=%d vararg=%d ==\n", i, ips[i].nparams, ips[i].vararg ? 1 : 0);
        std::printf("%s", skeleton_of(ips[i], &ctx).c_str());
    }
    return 0;
}
