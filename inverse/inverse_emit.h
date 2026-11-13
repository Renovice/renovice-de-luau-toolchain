// inverse_emit.h -- compiler-inverse renderer, milestone 2 (2026-11-08). Opt-in: RENOVICE_INVERSE_EMIT=1.
//
// Walks the prototype in LAYOUT order with the inverse_scan.h grammar (loops by back edge, for by
// prep/latch pair, if by its skip target, break/continue by threaded landing) and prints statements
// with the certified Emitter primitives only: emit_block (straight-line statements), cond_of
// (conditions incl. merged short-circuit chains) and for_header. Any construct the grammar cannot
// explain fails the whole prototype closed; emit_function then falls back to the production paths.
#pragma once
#include <cctype>
#include <functional>
#include <map>
#include <tuple>
#include <set>
#include <string>
#include <vector>

namespace inv {

struct EmitCtx {
    int exit = -1;     // JUMP landing here = break
    int cont = -1;     // JUMP landing here = continue
    int latch = -1;    // the loop's own back-edge instruction: emits nothing
};

class Walker {
public:
    explicit Walker(em::Emitter& e) : E(e), ip(*e.ip), g(*e.g), n((int)e.ip->code.size()) {
        node_at.assign((size_t)n, -1);
        for (size_t b = 0; b < g.n.size(); ++b) {
            const st::Node& nd = g.n[b];
            if (!nd.reach || nd.first < 0 || nd.first >= n) continue;
            if (node_at[(size_t)nd.first] >= 0) { ok = false; why = "DUP_NODE"; }
            node_at[(size_t)nd.first] = (int)b;
        }
    }
    bool run(int depth) {
        if (!ok) return false;
        EmitCtx none;
        return seq(0, n, none, depth, -1) && !E.bad;
    }
    std::string why;
    int at = -1;

private:
    em::Emitter& E;
    const ir::IProto& ip;
    const st::Graph& g;
    const int n;
    std::vector<int> node_at;
    std::set<int> silent;      // else-skipping JUMPs: part of the if, not statements
    bool ok = true;
    lv::Analysis LA;
    bool la_ready = false;

    // register `r` is read on entry to the node starting at pc (bytecode liveness)
    bool live_at(int pc, int r) {
        if (!la_ready) { LA = lv::analyze(ip, g); la_ready = true; }
        if (!LA.known || !LA.converged) return true;
        if (pc < 0 || pc >= n) return false;
        const int b = node_at[(size_t)pc];
        if (b < 0 || b >= (int)LA.live_in.size()) return true;
        return LA.live_in[(size_t)b].count(r) != 0;
    }
    bool defines(int first, int last, int r) const {
        for (int q = first; q < last; ++q) {
            std::set<int> u, d;
            if (!lv::register_effects(ip, I(q), u, d)) return true;
            if (d.count(r)) return true;
        }
        return false;
    }

    bool fail(const char* w, int pc) { why = w; at = pc; return false; }
    const ir::IInsn& I(int pc) const { return ip.code[(size_t)pc]; }
    static bool uncond(const ir::IInsn& in) { return in.name == "JUMP" || in.name == "JUMPBACK"; }
    static bool forgprep(const ir::IInsn& in) { return in.name.rfind("FORGPREP", 0) == 0; }
    bool lands(int t, int e) const {
        for (int step = 0; step < 16 && e >= 0 && e < n; ++step) {
            if (e == t) return true;
            if (!uncond(I(e))) return false;
            e = I(e).target;
        }
        return e == t && t >= 0;
    }
    std::string ind(int d) const { return std::string((size_t)d * 2, ' '); }

    // statements covering exactly [pc, end)
    bool seq(int pc, int end, const EmitCtx& ctx, int depth, int no_loop_at, int fol = -1) {
        while (pc < end) {
            const int b = node_at[(size_t)pc];
            if (b < 0) {
                // unreachable code the graph dropped: skip to the next reachable node
                int q = pc + 1;
                while (q < end && node_at[(size_t)q] < 0) ++q;
                bool reachable_inside = false;
                for (size_t k = 0; k < g.n.size(); ++k)
                    if (g.n[k].reach && g.n[k].first < pc && g.n[k].last >= pc) reachable_inside = true;
                if (reachable_inside) return fail("MID_NODE", pc);
                pc = q;
                continue;
            }
            const int next = stmt(b, end, ctx, depth, pc == no_loop_at, fol);
            if (next < 0) return false;
            if (next > end) return fail("PAST_END", pc);
            pc = next;
        }
        return pc == end || fail("OVERRUN", pc);
    }

    // `if cond then break/continue end` / plain jump statements
    bool jump_stmt(int target, const EmitCtx& ctx, int depth, int pc, const std::string& cond) {
        const char* word = nullptr;
        if (lands(target, ctx.exit)) word = "break";
        else if (lands(target, ctx.cont)) word = "continue";
        if (!word) return fail("STRAY_JUMP", pc);
        if (cond.empty()) E.out += ind(depth) + word + "\n";
        else E.out += ind(depth) + "if " + cond + " then " + word + " end\n";
        return true;
    }

    int stmt(int b, int end, const EmitCtx& ctx, int depth, bool no_loop, int fol) {
        const st::Node& nd = g.n[(size_t)b];
        const int first = nd.first;
        // loop headed here: the last back edge into this node inside [first, end)
        if (!no_loop) {
            int L = -1;
            for (int p : nd.preds) {
                if (p < 0 || p >= (int)g.n.size() || !g.n[(size_t)p].reach) continue;
                const st::Node& pn = g.n[(size_t)p];
                if (pn.first < first || pn.last >= end) continue;
                const ir::IInsn& t = I(pn.last);
                if (t.name == "FORNLOOP" || t.name == "FORGLOOP") continue;
                if (!t.branch || t.target != first) continue;
                if (L < 0 || pn.last > g.n[(size_t)L].last) L = p;
            }
            if (L >= 0) {
                const int j = g.n[(size_t)L].last;
                EmitCtx in; in.exit = j + 1; in.cont = first; in.latch = j;
                if (uncond(I(j))) {
                    E.out += ind(depth) + "while true do\n";
                    if (!seq(first, j + 1, in, depth + 1, first, first)) return -1;
                    E.out += ind(depth) + "end\n";
                    return j + 1;
                }
                // repeat ... until: the latch's taken branch returns to the head
                const st::Node& ln = g.n[(size_t)L];
                if (ln.succ_true < 0 || g.n[(size_t)ln.succ_true].first != first)
                    return fail("REPEAT_POLARITY", j), -1;
                E.out += ind(depth) + "repeat\n";
                if (!seq(first, j + 1, in, depth + 1, first, first)) return -1;
                E.out += ind(depth) + "until " + E.cond_of(L, true) + "\n";
                return j + 1;
            }
        }
        const int last = nd.last;
        const ir::IInsn& term = I(last);
        // for-loops: header first so the frame MOVEs are folded out of the prep block
        if (term.name == "FORNPREP" || forgprep(term)) {
            int latch = -1;
            if (term.name == "FORNPREP") {
                for (int q = last + 1; q < end; ++q)
                    if (I(q).name == "FORNLOOP" && I(q).target == last + 1 && I(q).A == term.A) { latch = q; break; }
                // the skip may land on a different but identical `return` (the compiler merges
                // jumps to equal RETURNs): same landing semantics as falling out of the loop
                auto same_return = [&](int a, int b2) {
                    if (a < 0 || b2 < 0 || a >= n || b2 >= n) return false;
                    const ir::IInsn& x = I(a); const ir::IInsn& y = I(b2);
                    return x.name == "RETURN" && y.name == "RETURN" && x.A == y.A && x.B == y.B && x.B == 1
                        && !std::getenv("RENOVICE_INVERSE_NO_RETURN_MERGE");
                };
                if (latch < 0 || !(lands(term.target, latch + 1) || same_return(term.target, latch + 1)))
                    return fail("FORN_SHAPE", last), -1;
            } else {
                latch = term.target;
                if (latch <= last || latch >= end || I(latch).name != "FORGLOOP" || I(latch).target == latch + 1)
                    return fail("FORG_SHAPE", last), -1;
            }
            std::string hdr;
            if (!E.for_header(b, hdr)) return fail("FOR_HEADER", last), -1;
            const auto mv = E.for_move_candidates.find(b);
            if (mv != E.for_move_candidates.end()) E.suppress_insns.insert(mv->second.begin(), mv->second.end());
            E.emit_block(b, depth);
            E.out += ind(depth) + hdr + "\n";
            EmitCtx in; in.exit = latch + 1; in.cont = latch; in.latch = latch;
            if (term.name == "FORNPREP") {
                if (!seq(last + 1, latch + 1, in, depth + 1, -1, latch)) return -1;
            } else {
                if (!seq(last + 1, latch, in, depth + 1, -1, latch)) return -1;
                if (node_at[(size_t)latch] < 0) return fail("FORG_LATCH_NODE", latch), -1;
                const st::Node& ln = g.n[(size_t)node_at[(size_t)latch]];
                if (ln.first != latch || ln.last != latch) return fail("FORG_LATCH_BLOCK", latch), -1;
            }
            E.out += ind(depth) + "end\n";
            return latch + 1;
        }
        if (term.name == "FORNLOOP" || term.name == "FORGLOOP") {
            if (last != ctx.latch) return fail("STRAY_LOOP_OP", last), -1;
            E.emit_block(b, depth);
            return last + 1;
        }
        if (term.name == "LOADB" && term.C != 0 && !silent.count(last)) return fail("STRAY_LOADB_SKIP", last), -1;
        const size_t blk_mark = E.out.size();
        E.emit_block(b, depth);
        if (nd.is_return || term.name == "RETURN") return last + 1;
        if (nd.is_branch && !uncond(term)) {
            const int r = cond_value_stmt(b, end, depth, blk_mark);
            if (r >= 0) return r;
        }
        if (uncond(term)) {
            if (last == ctx.latch || silent.count(last)) return last + 1;
            // a jump over unreachable code only (the inline rewrite's padding) is a fall-through
            if (term.target > last + 1 && term.target <= end) {
                bool dead = true;
                for (int q = last + 1; q < term.target && dead; ++q) {
                    if (node_at[(size_t)q] >= 0) dead = false;
                    for (size_t k = 0; k < g.n.size() && dead; ++k)
                        if (g.n[k].reach && g.n[k].first <= q && g.n[k].last >= q) dead = false;
                }
                if (dead) return last + 1;
            }
            return jump_stmt(term.target, ctx, depth, last, "") ? last + 1 : -1;
        }
        if (!nd.is_branch || nd.succ_true < 0 || nd.succ_false < 0) return last + 1;   // fall-through
        if (last == ctx.latch) return fail("COND_LATCH", last), -1;
        const int tpc = g.n[(size_t)nd.succ_true].first, fpc = g.n[(size_t)nd.succ_false].first;
        const int S = last + 1;
        int T; bool then_is_taken;
        if (fpc == S) { T = tpc; then_is_taken = false; }
        else if (tpc == S) { T = fpc; then_is_taken = true; }
        else return fail("NO_FALLTHROUGH", last), -1;
        // the skip target T: break / continue guard, or the end of the then-block
        if (lands(T, ctx.exit) || lands(T, ctx.cont))
            return jump_stmt(T, ctx, depth, last, E.cond_of(b, then_is_taken)) ? S : -1;
        const size_t mark = E.out.size();
        const std::set<int> silent_mark = silent;
        const int r = if_rest(S, T, E.cond_of(b, !then_is_taken), end, ctx, depth, fol, E.cond_of(b, then_is_taken));
        if (r >= 0) return r;
        // SAME-REGISTER THREADING: a JUMPIF/JUMPIFNOT r landing on a later test of r has a known
        // outcome there, so the compiler sends it straight to that test's destination
        // (`r = a or b; if r then` -> the first test skips the second). Retry with the skip
        // ending at that later test.
        if ((term.name == "JUMPIF" || term.name == "JUMPIFNOT") && !then_is_taken) {
            const bool truthy = term.name == "JUMPIF";
            for (int e = S + 1; e < end && e < T; ++e) {
                const ir::IInsn& x = I(e);
                if ((x.name != "JUMPIF" && x.name != "JUMPIFNOT") || x.A != term.A || node_at[(size_t)e] < 0) continue;
                const int dest = (x.name == "JUMPIF") == truthy ? x.target : e + 1;
                if (dest != T) continue;
                E.out.resize(mark);
                silent = silent_mark;
                const int r3 = if_rest(S, e, E.cond_of(b, !then_is_taken), end, ctx, depth, fol);
                if (r3 >= 0) return r3;
            }
        }
        // CONDITION CHAIN: `a or b`, `a and (b or c)` ... whose later tests carry setup code
        // (calls, loads) and therefore were not merged into one graph node.
        const std::string why0 = why; const int at0 = at;
        std::vector<int> nodes{b};
        for (int k = 2; k <= 48; ++k) {
            const int np = g.n[(size_t)nodes.back()].last + 1;
            if (np >= end) break;
            const int nb = node_at[(size_t)np];
            if (nb < 0) break;
            const st::Node& c = g.n[(size_t)nb];
            if (!c.is_branch || c.succ_true < 0 || c.succ_false < 0 || !c.chain.empty() || c.branch_predicate)
                break;
            const ir::IInsn& ct = I(c.last);
            if (uncond(ct) || ct.name.rfind("FOR", 0) == 0 || ct.name == "LOADB" || ct.target <= c.last) break;
            bool clean = true;
            for (int q = c.first; q < c.last; ++q) if (I(q).branch || I(q).name == "RETURN") clean = false;
            if (!clean) break;
            nodes.push_back(nb);
            E.out.resize(mark);
            silent = silent_mark;
            const int r2 = chain_if(nodes, end, ctx, depth, fol);
            if (r2 >= 0) return r2;
        }
        E.out.resize(mark);
        silent = silent_mark;
        why = why0; at = at0;
        return -1;
    }

    // one emitted line `[local ]lhs = rhs` (instruction tags stripped); false when not exactly that
    static bool parse_assign(std::string t, std::string& lhs, std::string& rhs, bool& is_local) {
        while (!t.empty() && (t.back() == '\n' || t.back() == ' ')) t.pop_back();
        if (t.find('\n') != std::string::npos) return false;
        size_t a = 0; while (a < t.size() && t[a] == ' ') ++a;
        t = t.substr(a);
        for (size_t tag; (tag = t.find(" --@")) != std::string::npos;) {
            size_t e = tag + 4; while (e < t.size() && std::isdigit((unsigned char)t[e])) ++e;
            t.erase(tag, e - tag);
        }
        is_local = t.rfind("local ", 0) == 0;
        if (is_local) t = t.substr(6);
        const size_t eq = t.find(" = ");
        if (eq == std::string::npos || eq == 0) return false;
        lhs = t.substr(0, eq); rhs = t.substr(eq + 3);
        return lhs.find_first_of(",()[]. ") == std::string::npos && !rhs.empty();
    }

    // CONDITION VALUE (inverse of Luau compileExprAndOr -> compileConditionValue): `x = <and/or
    // expression>` whose terms jump straight to the merge M with the value already in R, the last
    // term falling into M. Grammar per the compiler: and/or with onlyTruth = !and; a term with a
    // target is `R = e; JUMPIF[NOT] R -> M` or `LOADB R b; <compare> -> M`; a term without target is
    // a plain condition jumping to the enclosing else label.
    // parenthesise a term that carries its own and/or so precedence cannot regroup it
    static std::string wrap(const std::string& x) {
        if (x.find(" and ") == std::string::npos && x.find(" or ") == std::string::npos) return x;
        if (x.size() > 1 && x.front() == '(' && x.back() == ')') {
            int d = 0; bool whole = true;
            for (size_t q = 0; q < x.size(); ++q) {
                if (x[q] == '(') ++d; else if (x[q] == ')') --d;
                if (d == 0 && q + 1 < x.size()) { whole = false; break; }
            }
            if (whole) return x;
        }
        return "(" + x + ")";
    }
    // `vX = e` lines feeding the block's last line: substitute each into its single use when vX is a
    // bytecode temp dead at `after` (the operand order is the register order the compiler used)
    std::string fold_temps(const std::string& txt, int after) {
        std::vector<std::string> lines;
        for (size_t p = 0; p < txt.size();) {
            size_t e = txt.find('\n', p);
            if (e == std::string::npos) e = txt.size();
            std::string l = txt.substr(p, e - p);
            if (l.find_first_not_of(' ') != std::string::npos) lines.push_back(l);
            p = e + 1;
        }
        if (lines.size() < 2) return txt;
        std::string L, r; bool lc = false;
        if (!parse_assign(lines.back(), L, r, lc)) return txt;
        for (int q = (int)lines.size() - 2; q >= 0; --q) {
            std::string x, ex; bool xl = false;
            if (!parse_assign(lines[(size_t)q], x, ex, xl) || xl || x.size() < 2 || x[0] != 'v') return txt;
            if (x.find_first_not_of("0123456789", 1) != std::string::npos) return txt;
            if (live_at(after, std::atoi(x.c_str() + 1))) return txt;
            auto ident = [](char c) { return std::isalnum((unsigned char)c) || c == '_'; };
            size_t hit = std::string::npos; int count = 0;
            for (size_t f = r.find(x); f != std::string::npos; f = r.find(x, f + 1)) {
                const bool lb = f == 0 || !ident(r[f - 1]);
                const bool rb = f + x.size() >= r.size() || !ident(r[f + x.size()]);
                if (lb && rb) { ++count; hit = f; }
            }
            if (count != 1) return txt;
            const bool simple = ex.find(' ') == std::string::npos;
            r.replace(hit, x.size(), simple ? ex : "(" + ex + ")");
        }
        return (lc ? "local " : "") + L + " = " + r + "\n";
    }
    // T re-tests r (same-register threading: the chain's jump there has a known outcome) and r is
    // dead on both of that test's successors
    bool retest(int T, int r) {
        if (T < 0 || T >= n) return false;
        const ir::IInsn& x = I(T);
        if ((x.name != "JUMPIF" && x.name != "JUMPIFNOT") || x.A != r) return false;
        return !live_at(T + 1, r) && !live_at(x.target, r);
    }
    int cvbail(int code, int b) const {
        if (std::getenv("RENOVICE_CV_TRACE"))
            std::fprintf(stderr, "CV_BAIL pidx=%d code=%d at=%d\n", E.pidx, code, g.n[(size_t)b].last);
        return -1;
    }
    int cond_value_stmt(int b, int end, int depth, size_t blk_mark) {
        if (std::getenv("RENOVICE_INVERSE_NO_CV")) return cvbail(1, b);
        std::vector<int> nodes{b};
        int pc = g.n[(size_t)b].last + 1;
        while ((int)nodes.size() < 24) {
            if (pc >= end) return cvbail(2, b);
            const int nb = node_at[(size_t)pc];
            if (nb < 0) return cvbail(3, b);
            nodes.push_back(nb);
            const st::Node& c = g.n[(size_t)nb];
            if (!c.is_branch) break;
            const ir::IInsn& t = I(c.last);
            if (uncond(t) || t.name.rfind("FOR", 0) == 0 || t.name == "LOADB" || t.target <= c.last) return cvbail(4, b);
            if (c.succ_true < 0 || c.succ_false < 0 || g.n[(size_t)c.succ_false].first != c.last + 1) return cvbail(5, b);
            pc = c.last + 1;
        }
        const int k = (int)nodes.size();
        const st::Node& fin = g.n[(size_t)nodes.back()];
        if (k < 2 || fin.is_branch || fin.is_return) return cvbail(6, b);
        const ir::IInsn& ft = I(fin.last);
        if (ft.branch || uncond(ft) || ft.name == "RETURN" || ft.name.rfind("FOR", 0) == 0) return cvbail(7, b);
        const int M = fin.last + 1;
        if (M > end) return cvbail(8, b);
        std::set<int> fu, fd;
        if (!lv::register_effects(ip, ft, fu, fd) || fd.size() != 1) return cvbail(9, b);
        const int R = *fd.begin();
        std::vector<int> start(k), tgt(k, -1);
        for (int i = 0; i < k; ++i) start[(size_t)i] = g.n[(size_t)nodes[(size_t)i]].first;
        auto start_of = [&](int j) { return j < k ? start[(size_t)j] : M; };
        for (int i = 0; i + 1 < k; ++i) {
            const st::Node& c = g.n[(size_t)nodes[(size_t)i]];
            const int t = g.n[(size_t)c.succ_true].first;
            bool okt = t == M;
            for (int m = i + 1; m < k; ++m) if (t == start[(size_t)m]) okt = true;
            if (!okt) return cvbail(10, b);
            tgt[(size_t)i] = t;
        }
        // the final term: its block must render as exactly `lhs = rhs`
        std::string lhs, frhs; bool loc_f = false;
        {
            const size_t mk = E.out.size();
            E.emit_block(nodes.back(), depth);
            const std::string txt = E.out.substr(mk);
            E.out.resize(mk);
            if (!parse_assign(fold_temps(txt, M), lhs, frhs, loc_f)) {
                if (std::getenv("RENOVICE_CV_TRACE")) std::fprintf(stderr, "CV_FINAL[%s]\n", txt.c_str());
                return cvbail(11, b);
            }
        }
        // node 0 already emitted its statements: if it is a term with a target, its last line is
        // `lhs = <term>` and comes back out of the statement list
        const ir::IInsn& t0 = I(g.n[(size_t)b].last);
        const bool t0_tests_R = (t0.name == "JUMPIF" || t0.name == "JUMPIFNOT") && t0.A == R;
        std::string leaf0; bool loc0 = false; size_t line0 = std::string::npos;
        {
            const std::string blk = E.out.substr(blk_mark);
            size_t e = blk.size();
            while (e > 0 && blk[e - 1] == '\n') --e;
            const size_t ls = e ? blk.rfind('\n', e - 1) : std::string::npos;
            const size_t s0 = (ls == std::string::npos) ? 0 : ls + 1;
            std::string l2, r2; bool lc = false;
            if (e > 0 && parse_assign(blk.substr(s0, e - s0), l2, r2, lc) && l2 == lhs) {
                leaf0 = r2; loc0 = lc; line0 = blk_mark + s0;
            }
        }
        const bool t0_cmp = !t0_tests_R && t0.name != "JUMPIF" && t0.name != "JUMPIFNOT"
                            && (leaf0 == "true" || leaf0 == "false");
        const bool node0_leaf = t0_tests_R || t0_cmp;
        if (node0_leaf && leaf0.empty()) return cvbail(12, b);
        // later tests: their setup folds into the term / condition
        st::Graph& mg = const_cast<st::Graph&>(g);
        std::vector<std::pair<int, int>> injected;
        std::vector<int> cmpB(k, -1);
        for (int i = 1; i + 1 < k; ++i) {
            st::Node& c = mg.n[(size_t)nodes[(size_t)i]];
            const ir::IInsn& tt = I(c.last);
            int f0 = c.first;
            if (tt.name != "JUMPIF" && tt.name != "JUMPIFNOT" && I(f0).name == "LOADB" && I(f0).A == R && I(f0).C == 0) {
                cmpB[(size_t)i] = I(f0).B ? 1 : 0;
                ++f0;
            }
            if (c.last > f0 && !c.chain_expr_setup.count(c.last)) {
                c.chain_expr_setup[c.last] = {f0, c.last - 1};
                injected.push_back({nodes[(size_t)i], c.last});
            }
        }
        if (t0_cmp) cmpB[0] = leaf0 == "true" ? 1 : 0;
        auto undo = [&]() { for (const auto& x : injected) mg.n[(size_t)x.first].chain_expr_setup.erase(x.second); };
        std::map<std::tuple<int, int, int, int, int>, std::pair<bool, std::string>> memo;
        // plain condition over [i, j): true <=> control reaches Lt
        std::function<bool(int, int, int, int, std::string&)> dec =
            [&](int i, int j, int Lt, int Lf, std::string& o) -> bool {
                const auto key = std::make_tuple(0, i, j, Lt, Lf);
                const auto h = memo.find(key);
                if (h != memo.end()) { o = h->second.second; return h->second.first; }
                memo[key] = {false, std::string()};
                bool ok2 = false;
                if (j - i == 1) {
                    if (i == 0 && node0_leaf) return false;
                    if (cmpB[(size_t)i] >= 0) return false;
                    const ir::IInsn& tt = I(g.n[(size_t)nodes[(size_t)i]].last);
                    if ((tt.name == "JUMPIF" || tt.name == "JUMPIFNOT") && tt.A == R) return false;
                    const int t = tgt[(size_t)i], F = start_of(i + 1);
                    if (t == Lt && F == Lf) { o = wrap(E.cond_of(nodes[(size_t)i], false)); ok2 = true; }
                    else if (t == Lf && F == Lt) { o = wrap(E.cond_of(nodes[(size_t)i], true)); ok2 = true; }
                } else {
                    for (int m = i + 1; m < j && !ok2; ++m) {
                        std::string a, c2;
                        if (dec(i, m, Lt, start_of(m), a) && dec(m, j, Lt, Lf, c2)) { o = "(" + a + " or " + c2 + ")"; ok2 = true; }
                        else if (dec(i, m, start_of(m), Lf, a) && dec(m, j, Lt, Lf, c2)) { o = "(" + a + " and " + c2 + ")"; ok2 = true; }
                    }
                }
                memo[key] = {ok2, o};
                return ok2;
            };
        // value with target over [i, j), onlyTruth ot: interesting results jump to M with R set
        std::function<bool(int, int, int, std::string&)> cvt =
            [&](int i, int j, int ot, std::string& o) -> bool {
                const auto key = std::make_tuple(1, i, j, ot, 0);
                const auto h = memo.find(key);
                if (h != memo.end()) { o = h->second.second; return h->second.first; }
                memo[key] = {false, std::string()};
                bool ok2 = false;
                if (j - i == 1) {
                    if (tgt[(size_t)i] != M) return false;
                    const int nb = nodes[(size_t)i];
                    const ir::IInsn& tt = I(g.n[(size_t)nb].last);
                    if (cmpB[(size_t)i] >= 0) {
                        if (cmpB[(size_t)i] != ot) return false;
                        o = wrap(E.cond_of(nb, ot ? false : true));
                        ok2 = o.size() > 2;
                    } else if (tt.name == (ot ? "JUMPIF" : "JUMPIFNOT") && tt.A == R) {
                        if (i == 0) o = wrap(leaf0);
                        else {
                            const st::Node& c = g.n[(size_t)nb];
                            if (!defines(c.first, c.last, R)) return false;
                            o = E.cond_of(nb, ot ? false : true);
                        }
                        // a leading `not` is the value itself only when the setup ends in NOT -> R
                        const int pl = g.n[(size_t)nb].last - 1;
                        const bool own_not = pl >= 0 && I(pl).name == "NOT" && I(pl).A == R;
                        ok2 = !o.empty() && (o.rfind("not ", 0) != 0 || own_not);
                        if (ok2) o = wrap(o);
                    }
                } else {
                    for (int m = i + 1; m < j && !ok2; ++m) {
                        std::string a, c2;
                        // a op b where op == (ot ? and : or): a is a plain condition to the else label
                        const bool lok = ot ? dec(i, m, start_of(m), start_of(j), a) : dec(i, m, start_of(j), start_of(m), a);
                        if (lok && cvt(m, j, ot, c2)) { o = "(" + a + (ot ? " and " : " or ") + c2 + ")"; ok2 = true; break; }
                        if (cvt(i, m, ot, a) && cvt(m, j, ot, c2)) { o = "(" + a + (ot ? " or " : " and ") + c2 + ")"; ok2 = true; }
                    }
                }
                memo[key] = {ok2, o};
                return ok2;
            };
        // the right operand: the final term, or a nested value over [i, k)
        std::function<bool(int, std::string&)> pv = [&](int i, std::string& o) -> bool {
            if (i == k - 1) { o = wrap(frhs); return true; }
            for (int m2 = k - 1; m2 > i; --m2)
                for (int ot2 = 0; ot2 <= 1; ++ot2) {
                    std::string a2, b2;
                    if (cvt(i, m2, ot2, a2) && pv(m2, b2)) { o = "(" + a2 + (ot2 ? " or " : " and ") + b2 + ")"; return true; }
                }
            return false;
        };
        std::string expr;
        bool ok3 = false;
        for (int m = k - 1; m >= 1 && !ok3; --m) {
            for (int ot = 0; ot <= 1 && !ok3; ++ot) {
                std::string a, rr;
                if (cvt(0, m, ot, a) && pv(m, rr)) { expr = wrap(a) + (ot ? " or " : " and ") + rr; ok3 = true; }
            }
        }
        if (!ok3) { undo(); return cvbail(13, b); }
        if (node0_leaf) E.out.resize(line0);
        E.out += ind(depth) + ((loc0 || loc_f) ? "local " : "") + lhs + " = " + expr + "\n";
        return M;
    }

    // nodes[0] already emitted its statements; nodes[1..] contribute setup+test to the condition
    int chain_if(const std::vector<int>& nodes, int end, const EmitCtx& ctx, int depth, int fol) {
        const int k = (int)nodes.size();
        std::vector<int> start(k), tgt(k);
        const int S = g.n[(size_t)nodes.back()].last + 1;
        auto at_end = [&](int t) { return lands(t, end) || (fol >= 0 && lands(t, fol)); };
        for (int i = 0; i < k; ++i) {
            const st::Node& c = g.n[(size_t)nodes[(size_t)i]];
            start[(size_t)i] = c.first;
            tgt[(size_t)i] = g.n[(size_t)c.succ_true].first;   // branch-taken target
            if (g.n[(size_t)c.succ_false].first != c.last + 1) return -1;
        }
        // the false label: the one target that is neither the then-start nor a later test
        int T = -1;
        for (int i = 0; i < k; ++i) {
            int t = tgt[(size_t)i];
            bool inner = t == S;
            for (int m = i + 1; m < k; ++m) if (t == start[(size_t)m]) inner = true;
            if (inner) continue;
            if (t > end && at_end(t)) t = end;
            if (T < 0) T = t;
            else if (T != t) return -1;
        }
        if (T < 0) return -1;
        auto norm = [&](int t) { return (t > end && at_end(t)) ? end : t; };
        // inline the later tests' setup into their conditions (the emitter's fold substitution)
        st::Graph& mg = const_cast<st::Graph&>(g);
        std::vector<std::pair<int, int>> injected;
        for (int i = 1; i < k; ++i) {
            st::Node& c = mg.n[(size_t)nodes[(size_t)i]];
            if (c.last > c.first && !c.chain_expr_setup.count(c.last)) {
                c.chain_expr_setup[c.last] = {c.first, c.last - 1};
                injected.push_back({nodes[(size_t)i], c.last});
            }
        }
        std::map<std::tuple<int, int, int, int>, std::pair<bool, std::string>> memo;
        std::function<bool(int, int, int, int, std::string&)> dec =
            [&](int i, int j, int Lt, int Lf, std::string& outc) -> bool {
                const auto key = std::make_tuple(i, j, Lt, Lf);
                const auto hit = memo.find(key);
                if (hit != memo.end()) { outc = hit->second.second; return hit->second.first; }
                memo[key] = {false, std::string()};
                if (j - i == 1) {
                    const int t = norm(tgt[(size_t)i]);
                    const int F = i + 1 < k ? start[(size_t)i + 1] : S;
                    if (t == Lt && F == Lf) { outc = E.cond_of(nodes[(size_t)i], false); return true; }
                    if (t == Lf && F == Lt) { outc = E.cond_of(nodes[(size_t)i], true); return true; }
                    return false;
                }
                for (int m = i + 1; m < j; ++m) {
                    std::string a, c2;
                    if (dec(i, m, Lt, start[(size_t)m], a) && dec(m, j, Lt, Lf, c2)) {
                        outc = "(" + a + " or " + c2 + ")"; memo[key] = {true, outc}; return true;
                    }
                    if (dec(i, m, start[(size_t)m], Lf, a) && dec(m, j, Lt, Lf, c2)) {
                        outc = "(" + a + " and " + c2 + ")"; memo[key] = {true, outc}; return true;
                    }
                }
                return false;
            };
        auto undo = [&]() {
            for (const auto& x : injected) mg.n[(size_t)x.first].chain_expr_setup.erase(x.second);
        };
        // CONDITION VALUE (`x = a and b and (f() or g()) or false`, Luau compileConditionValue):
        // the later tests write their value into R and JUMPIF R to the merge T; the fallback is a
        // single constant load into R right after the last test.
        if (S + 1 == T && T <= end && !std::getenv("RENOVICE_INVERSE_NO_COND_VALUE")) {
            const ir::IInsn& lt = I(g.n[(size_t)nodes.back()].last);
            const ir::IInsn& fb = I(S);
            const int R = lt.A;
            std::string fbx;
            if (fb.A == R) {
                if (fb.name == "LOADB" && fb.C == 0) fbx = fb.B ? "true" : "false";
                else if (fb.name == "LOADNIL" && fb.B == 0) fbx = "nil";
                else if (fb.name == "LOADN") fbx = std::to_string((int16_t)fb.Bx);
            }
            std::function<bool(int, int, int, std::string&)> decV =
                [&](int i, int j, int Lf, std::string& outv) -> bool {
                    if (j - i == 1) {
                        const st::Node& c = g.n[(size_t)nodes[(size_t)i]];
                        const ir::IInsn& t = I(c.last);
                        const int F = i + 1 < k ? start[(size_t)i + 1] : S;
                        if (i < 1 || t.name != "JUMPIF" || t.A != R || tgt[(size_t)i] != T || F != Lf
                            || !c.chain.empty() || c.branch_predicate || !defines(c.first, c.last, R))
                            return false;
                        outv = E.cond_of(nodes[(size_t)i], false);
                        return !outv.empty() && outv.rfind("not ", 0) != 0;
                    }
                    for (int m = i + 1; m < j; ++m) {
                        std::string a, b2;
                        if (dec(i, m, start[(size_t)m], Lf, a) && decV(m, j, Lf, b2)) {
                            outv = "(" + a + " and " + b2 + ")"; return true;
                        }
                        if (decV(i, m, start[(size_t)m], a) && decV(m, j, Lf, b2)) {
                            outv = "(" + a + " or " + b2 + ")"; return true;
                        }
                    }
                    return false;
                };
            std::string v;
            if (!fbx.empty() && decV(0, k, S, v)) {
                E.out += ind(depth) + "v" + std::to_string(R) + " = " + v + " or " + fbx + "\n";
                silent.insert(S);
                return T;
            }
        }
        // a later test whose setup writes a register read after the chain is a VALUE, not a
        // condition: folding its setup into the condition would drop the assignment
        for (int i = 1; i < k; ++i) {
            const st::Node& c = g.n[(size_t)nodes[(size_t)i]];
            const ir::IInsn& t = I(c.last);
            if ((t.name == "JUMPIF" || t.name == "JUMPIFNOT") && defines(c.first, c.last, t.A)
                && (live_at(S, t.A) || (live_at(T, t.A) && !retest(T, t.A))) && !std::getenv("RENOVICE_INVERSE_NO_LIVE_GUARD")) {
                if (std::getenv("RENOVICE_CV_TRACE"))
                    std::fprintf(stderr, "LIVE_GUARD pidx=%d test=%d reg=%d S=%d T=%d liveS=%d liveT=%d\n", E.pidx, c.last, (int)t.A, S, T,
                                 live_at(S, t.A) ? 1 : 0, live_at(T, t.A) ? 1 : 0);
                undo(); return -1;
            }
        }
        if (lands(T, ctx.exit) || lands(T, ctx.cont)) {
            // `if c then break end`: c is the condition for reaching T
            std::string c;
            if (!dec(0, k, T, S, c)) { undo(); return -1; }
            if (!jump_stmt(T, ctx, depth, g.n[(size_t)nodes.back()].last, c)) { undo(); return -1; }
            return S;
        }
        std::string cond_S;
        if (!dec(0, k, S, T, cond_S)) { undo(); return -1; }
        const int r = if_rest(S, T, cond_S, end, ctx, depth, fol);
        if (r < 0) undo();
        return r;
    }

    // if-statement with then-block starting at S and skip target T
    int if_rest(int S, int T, const std::string& cond_S, int end, const EmitCtx& ctx, int depth, int fol,
                const std::string& cond_T = std::string()) {
        // where control goes after this sequence: a skip may be threaded straight there
        auto at_end = [&](int t) { return lands(t, end) || (fol >= 0 && lands(t, fol)); };
        if (T > end && at_end(T)) T = end;
        if (T == S) {                     // empty then-block (both edges meet): `if c then end`
            E.out += ind(depth) + "if " + cond_S + " then\n" + ind(depth) + "end\n";
            return S;
        }
        if (T <= S || T > end) return fail("IF_TARGET", S - 1), -1;
        // else: a forward JUMP at T-1 that is not a break / continue
        if (T - 1 >= S) {
            const ir::IInsn& j = I(T - 1);
            int Ee = j.name == "LOADB" ? T + j.C : j.target;   // LOADB skip carries no IR target
            // `JUMP E`, or the comparison-value form `LOADB r, b, skip` (Luau's
            // `x = a < b` lowering: then-arm LOADB jumps over the else-arm LOADB)
            const bool skip = j.name == "JUMP" || (j.name == "LOADB" && j.C != 0);
            if (skip && Ee > end && at_end(Ee)) Ee = end;
            if (skip && Ee > T && Ee <= end && T - 1 != ctx.latch
                && !lands(j.target, ctx.exit) && !lands(j.target, ctx.cont)) {
                // COMPARISON VALUE (`x = a < b`): both arms are one LOADB into the same register.
                // Print the boolean assignment; the if/else spelling compiles to another jump shape.
                if (j.name == "LOADB" && S == T - 1 && Ee == T + 1 && I(T).name == "LOADB" && I(T).A == j.A
                    && I(T).C == 0 && j.B != I(T).B && !std::getenv("RENOVICE_INVERSE_NO_CMP_VALUE")) {
                    const std::string& c = I(T).B ? cond_T : cond_S;    // condition reaching the true arm
                    if (!c.empty()) {
                        E.out += ind(depth) + "v" + std::to_string(j.A) + " = " + c + "\n";
                        return Ee;
                    }
                }
                silent.insert(T - 1);
                E.out += ind(depth) + "if " + cond_S + " then\n";
                const int f2 = Ee == end ? fol : Ee;
                if (!seq(S, T, ctx, depth + 1, -1, f2)) return -1;
                E.out += ind(depth) + "else\n";
                if (!seq(T, Ee, ctx, depth + 1, -1, f2)) return -1;
                E.out += ind(depth) + "end\n";
                return Ee;
            }
        }
        const size_t mark = E.out.size();
        const std::set<int> silent_mark = silent;
        E.out += ind(depth) + "if " + cond_S + " then\n";
        if (seq(S, T, ctx, depth + 1, -1, T == end ? fol : T)) {
            E.out += ind(depth) + "end\n";
            return T;
        }
        // IMPLICIT ELSE: Luau emits no JUMP over the else-block when the then-block ends in
        // return / break / continue, so `if c then A; return end B` and `if c then A; return else
        // B end` share a layout. They differ only in where jumps inside A that leave the if land:
        // after B. Retry with the else ending at each such landing point, nearest first.
        const ir::IInsn& tail = I(T - 1);
        const bool terminates = tail.name == "RETURN"
            || (uncond(tail) && (lands(tail.target, ctx.exit) || lands(tail.target, ctx.cont)));
        if (!terminates) return -1;
        std::set<int> ends;
        for (int q = S; q < T; ++q) {
            const ir::IInsn& x = I(q);
            if (!x.branch || x.target <= T || x.name == "FORNPREP" || forgprep(x)) continue;
            if (x.target <= end) ends.insert(x.target);
            else if (at_end(x.target)) ends.insert(end);
        }
        for (int Ee : ends) {
            E.out.resize(mark);
            silent = silent_mark;
            const int f2 = Ee == end ? fol : Ee;
            E.out += ind(depth) + "if " + cond_S + " then\n";
            if (!seq(S, T, ctx, depth + 1, -1, f2)) continue;
            E.out += ind(depth) + "else\n";
            if (!seq(T, Ee, ctx, depth + 1, -1, f2)) continue;
            E.out += ind(depth) + "end\n";
            return Ee;
        }
        return -1;
    }
};

inline bool render(em::Emitter& E, int depth) {
    // RENOVICE_INVERSE_PROTOS=<i,j,..>: only these prototypes (the per-prototype selection stage)
    if (const char* only = std::getenv("RENOVICE_INVERSE_PROTOS")) {
        if (!*only) return false;
        bool listed = false;
        for (const char* c = only; *c;) {
            if (std::atoi(c) == E.pidx) { listed = true; break; }
            while (*c && *c != ',') ++c;
            if (*c == ',') ++c;
        }
        if (!listed) return false;
    }
    Walker w(E);
    const size_t before = E.out.size();
    const bool ok = w.run(depth);
    if (const char* d = std::getenv("RENOVICE_INVERSE_DUMP"))
        if (std::atoi(d) == E.pidx)
            std::fprintf(stderr, "INVERSE_DUMP pidx=%d ok=%d before=%zu after=%zu\n", E.pidx, ok ? 1 : 0,
                         before, E.out.size());
    if (!ok && std::getenv("RENOVICE_INVERSE_TRACE"))
        std::fprintf(stderr, "INVERSE_EMIT_FAIL pidx=%d why=%s at=%d\n", E.pidx, w.why.c_str(), w.at);
    return ok;
}

struct HookInstaller { HookInstaller() { em::Emitter::inverse_hook = &render; } };
static HookInstaller hook_installer;

} // namespace inv
