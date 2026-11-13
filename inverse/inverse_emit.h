// inverse_emit.h -- compiler-inverse renderer, milestone 2 (2026-11-08). Opt-in: RENOVICE_INVERSE_EMIT=1.
//
// Walks the prototype in LAYOUT order with the inverse_scan.h grammar (loops by back edge, for by
// prep/latch pair, if by its skip target, break/continue by threaded landing) and prints statements
// with the certified Emitter primitives only: emit_block (straight-line statements), cond_of
// (conditions incl. merged short-circuit chains) and for_header. Any construct the grammar cannot
// explain fails the whole prototype closed; emit_function then falls back to the production paths.
#pragma once
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
        E.emit_block(b, depth);
        if (nd.is_return || term.name == "RETURN") return last + 1;
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
                && (live_at(S, t.A) || live_at(T, t.A))) { undo(); return -1; }
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
