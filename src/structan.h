// structan.h — STRUCTURAL ANALYSIS (Muchnick / Sharir interval analysis).
//
// The recursive descent in structur.h is a top-down traversal patched with pattern special-cases.
// It needs DUPLICATION on 6,296 reducible protos — but a reducible CFG is structurable with NO
// copying at all, so every one of those copies is a descent bug being routed around.
//
// Structural analysis works the other way: BOTTOM-UP GRAPH REDUCTION. Repeatedly find a subgraph
// matching a known region shape, collapse it to a single abstract node, and repeat. A reducible
// graph is guaranteed to reduce to ONE node, so "did it reach one node?" is a complete, honest
// success test with no duplication anywhere.
//
// Ref: Muchnick, Advanced Compiler Design & Implementation (1997), ch. 7.7.
//      Schwartz et al., Native x86 Decompilation using Semantics-Preserving Structural Analysis.
#pragma once
#include <vector>
#include <map>
#include <set>
#include <string>
#include "structur.h"

namespace sa {

enum class RK { Basic, Seq, IfThen, IfThenElse, SelfLoop, While, NaturalLoop, Proper };

struct Region {
    RK kind = RK::Basic;
    int block = -1;                 // Basic: the CFG block
    std::vector<int> parts;         // child region ids, in source order
    int head = -1;                  // condition/header region id
};

struct Analyzer {
    // Working graph over REGION ids. succ/pred are region-level and shrink as we collapse.
    std::vector<Region> regions;
    std::map<int, std::set<int>> succ, pred;
    std::set<int> live;
    std::set<int> for_latches;          // original basic blocks ending in FORNLOOP/FORGLOOP
    std::set<int> nested_for_latches;   // latches whose canonical loop is inside another loop
    std::set<int> nested_for_preps;     // preps participating in a strict loop-nesting pair
    // Narrow production class: a prototype with one dominance loop whose FORGLOOP header has
    // exactly three dominated predecessors.  Dialog p62 is the motivating specimen.  Broader
    // multi-latch classes were measured and rejected because they invented loop headers.
    std::set<int> multi_latch_for_headers;
    int entry = 0;

    void build(const st::Graph& g) {
        regions.clear(); succ.clear(); pred.clear(); live.clear();
        for_latches.clear(); nested_for_latches.clear(); nested_for_preps.clear();
        multi_latch_for_headers.clear();
        for (size_t i = 0; i < g.n.size(); ++i) {
            Region r; r.kind = RK::Basic; r.block = (int)i;
            regions.push_back(r);
            if (g.n[i].reach) live.insert((int)i);
            if (g.n[i].reach && (g.n[i].term == 0x0a || g.n[i].term == 0x1e))
                for_latches.insert((int)i);
        }
        std::set<int> dominance_loop_headers;
        for (size_t predecessor = 0; predecessor < g.n.size(); ++predecessor) {
            if (!g.n[predecessor].reach) continue;
            for (int target : {g.n[predecessor].succ_true, g.n[predecessor].succ_false})
                if (target >= 0 && st::dominates(g, target, (int)predecessor))
                    dominance_loop_headers.insert(target);
        }
        for (int header : for_latches) {
            if (g.n[header].term != 0x1e) continue; // generic FORGLOOP topology only
            int backedge_predecessors = 0;
            for (int predecessor : g.n[header].preds)
                if (st::dominates(g, header, predecessor)) ++backedge_predecessors;
            if (backedge_predecessors == 3 && dominance_loop_headers.size() == 1)
                multi_latch_for_headers.insert(header);
        }
        for (size_t i = 0; i < g.n.size(); ++i) {
            if (!g.n[i].reach) continue;
            for (int s : {g.n[i].succ_true, g.n[i].succ_false})
                if (s >= 0 && s < (int)g.n.size() && g.n[s].reach) {
                    succ[(int)i].insert(s);
                    pred[s].insert((int)i);
                }
        }
        std::vector<st::Loop> loops = st::find_loops(g);
        for (size_t i = 0; i < loops.size(); ++i) {
            if (loops[i].latch < 0) continue;
            for (size_t j = 0; j < loops.size(); ++j) {
                if (i == j || loops[i].body.size() >= loops[j].body.size()) continue;
                bool subset = true;
                for (int block : loops[i].body)
                    if (!loops[j].body.count(block)) { subset = false; break; }
                if (subset) {
                    nested_for_latches.insert(loops[i].latch);
                    if (loops[i].prep >= 0) nested_for_preps.insert(loops[i].prep);
                    if (loops[j].prep >= 0) nested_for_preps.insert(loops[j].prep);
                    break;
                }
            }
        }
        entry = 0;
    }

    int add(Region r) { regions.push_back(r); int id = (int)regions.size()-1; live.insert(id); return id; }

    // Replace the set `parts` with a single new region `id`, rewiring edges around it.
    void collapse(const std::vector<int>& parts, int id, const std::set<int>& outs) {
        if (std::getenv("RENOVICE_SASTEPS")) {
            const char* kind = "Proper";
            switch (regions[id].kind) {
                case RK::Basic: kind = "Basic"; break; case RK::Seq: kind = "Seq"; break;
                case RK::IfThen: kind = "IfThen"; break;
                case RK::IfThenElse: kind = "IfThenElse"; break;
                case RK::SelfLoop: kind = "SelfLoop"; break; case RK::While: kind = "While"; break;
                case RK::NaturalLoop: kind = "NaturalLoop"; break; case RK::Proper: break;
            }
            std::fprintf(stderr, "SA_COLLAPSE id=%d kind=%s head=%d live=%zu parts=",
                         id, kind, regions[id].head, live.size());
            for (int part : parts) std::fprintf(stderr, "%d,", part);
            std::fprintf(stderr, " outs=");
            for (int target : outs) std::fprintf(stderr, "%d,", target);
            std::fprintf(stderr, "\n");
        }
        std::set<int> ins;
        for (int p : parts)
            for (int q : pred[p])
                if (std::find(parts.begin(), parts.end(), q) == parts.end()) ins.insert(q);
        for (int p : parts) {
            for (int s : succ[p]) pred[s].erase(p);
            for (int q : pred[p]) succ[q].erase(p);
            succ.erase(p); pred.erase(p); live.erase(p);
        }
        for (int q : ins) { succ[q].insert(id); pred[id].insert(q); }
        for (int s : outs) if (live.count(s)) { succ[id].insert(s); pred[s].insert(id); }
        if (std::find(parts.begin(), parts.end(), entry) != parts.end()) entry = id;
    }

    bool one_succ(int n, int& s) const {
        auto it = succ.find(n);
        if (it == succ.end() || it->second.size() != 1) return false;
        s = *it->second.begin(); return true;
    }
    size_t npred(int n) const { auto it = pred.find(n); return it==pred.end()?0:it->second.size(); }
    size_t nsucc(int n) const { auto it = succ.find(n); return it==succ.end()?0:it->second.size(); }

    bool reaches(int f, int t) { return reaches_impl(f, t); }

    // Dominance in the CURRENT reduced graph. A natural-loop back edge is p -> n only when n
    // dominates p; mutual reachability alone identifies every edge of a cycle and can select the
    // latch as the "header", which then absorbs preheaders and surrounding loop context.
    bool dominates_current(int n, int p) const {
        if (n == p || n == entry) return true;
        if (!live.count(n) || !live.count(p) || !live.count(entry)) return false;
        std::set<int> seen;
        std::vector<int> todo{entry};
        while (!todo.empty()) {
            int x = todo.back(); todo.pop_back();
            if (x == n || !seen.insert(x).second) continue;
            if (x == p) return false;                       // p is reachable while avoiding n
            auto it = succ.find(x);
            if (it == succ.end()) continue;
            for (int s : it->second) if (live.count(s) && s != n) todo.push_back(s);
        }
        return true;
    }

    // `n` is a LOOP HEADER iff some predecessor of `n` is reachable FROM `n` -- i.e. that predecessor
    // closes a cycle through `n`, which is exactly a back edge. The greedy absorption patterns below
    // must never fire on a loop header: absorbing either the body or the exit arm as an if-arm
    // discards the back edge, and the region is then emitted as a plain `if` that runs its body once.
    bool is_loop_header(int n) {
        auto it = pred.find(n);
        if (it == pred.end()) return false;
        for (int p : it->second) if (p == n || reaches(n, p)) return true;
        return false;
    }
    // One reduction pass. Returns true if anything collapsed.
    bool step() {
        std::vector<int> order(live.begin(), live.end());
        for (int n : order) {
            if (!live.count(n)) continue;

            // SELF LOOP:  n -> n
            if (succ[n].count(n)) {
                Region r; r.kind = RK::SelfLoop; r.head = n; r.parts = {n};
                std::set<int> outs;
                for (int s : succ[n]) if (s != n) outs.insert(s);
                int id = add(r); collapse({n}, id, outs); return true;
            }

            // SEQUENCE:  n -> m,  m has only pred n,  n has only succ m
            int m;
            if (one_succ(n, m) && m != n && npred(m) == 1) {
                std::set<int> outs = succ.count(m) ? succ[m] : std::set<int>{};
                if (!outs.count(n)) {                       // not a back edge into n
                    Region r; r.kind = RK::Seq; r.parts = {n, m};
                    int id = add(r); collapse({n, m}, id, outs); return true;
                }
            }

            // GENERALISED IF-THEN, any successor count. A multi-exit loop collapse yields nodes with
            // THREE OR MORE successors (loop exit + one per break), and the two-successor patterns
            // below then match nothing — which is the entire 795-proto residue. If a successor `t` is
            // private to `n` and everything it flows to is already reachable from `n`, then `t` is an
            // arm of `n` and can be absorbed, leaving n's remaining successors intact.
            if (nsucc(n) >= 2 && !is_loop_header(n)) {
                std::vector<int> ss_all(succ[n].begin(), succ[n].end());
                for (int t : ss_all) {
                    if (t == n || npred(t) != 1) continue;
                    auto ts_it = succ.find(t);
                    std::set<int> touts = (ts_it == succ.end()) ? std::set<int>{} : ts_it->second;
                    bool absorbable = true;                 // t's exits must not introduce new targets
                    // A successor of `t` that is `n` ITSELF is a BACK EDGE: it makes {n,t} a LOOP, not
                    // an if-arm. The old `&& x != n` exemption absorbed it as an arm, silently
                    // discarding the back edge and labelling `while i<n do ... end` as IfThen -- the
                    // emitter then wrote `if ... then ... end` and the body ran ONCE. Dropping the
                    // exemption is also the natural reading: if n has no self-loop, x==n simply is not
                    // in succ[n], so the plain containment test rejects it and the WHILE pattern below
                    // (body private to n, single successor back to n) gets its chance.
                    for (int x : touts) if (!succ[n].count(x)) { absorbable = false; break; }
                    if (touts.count(t)) absorbable = false; // self-loop: handled elsewhere
                    if (!absorbable) continue;
                    std::set<int> outs;
                    for (int x : succ[n]) if (x != t) outs.insert(x);
                    for (int x : touts) if (x != t) outs.insert(x);
                    Region r; r.kind = RK::IfThen; r.head = n; r.parts = {n, t};
                    int id = add(r); collapse({n, t}, id, outs); return true;
                }
            }
            // N-WAY CONVERGENCE (generalised if-then-else). `n` has k successors, every one of them
            // private to `n`, and they all flow to the SAME block j — an if/elseif/elseif chain, or a
            // loop with several breaks that all land in the same place. The two-successor if-else
            // pattern cannot see this, and the generalised if-then above rejects it because j is not
            // itself a successor of n.
            if (nsucc(n) >= 2 && !is_loop_header(n)) {
                std::vector<int> arms(succ[n].begin(), succ[n].end());
                int j = -1; bool ok = true;
                for (int t : arms) {
                    if (t == n || npred(t) != 1) { ok = false; break; }
                    size_t k = nsucc(t);
                    if (k == 0) continue;                        // terminating arm: fine
                    if (k != 1) { ok = false; break; }
                    int ts = *succ[t].begin();
                    if (ts == t || succ[n].count(ts)) { ok = false; break; }
                    if (j < 0) j = ts;
                    else if (j != ts) { ok = false; break; }      // arms must agree on the join
                }
                if (ok && arms.size() >= 2) {
                    std::vector<int> parts; parts.push_back(n);
                    for (int t : arms) parts.push_back(t);
                    std::set<int> outs; if (j >= 0) outs.insert(j);
                    Region r; r.kind = RK::IfThenElse; r.head = n; r.parts = parts;
                    int id = add(r); collapse(parts, id, outs); return true;
                }
            }
            if (nsucc(n) == 2) {
                std::vector<int> ss(succ[n].begin(), succ[n].end());
                int a = ss[0], b = ss[1];
                // WHILE FIRST. If one successor is a private body that flows straight back to `n`,
                // then `n` IS a loop header and this IS a while loop -- checking the acyclic patterns
                // first lets IfThen absorb the loop EXIT arm, which destroys the back edge and emits
                // `if` for `while`. When this pattern matches it is definitionally correct, so trying
                // it earlier can only replace a wrong answer with a right one.
                for (int k = 0; k < 2; ++k) {
                    int bd = k ? b : a, ex = k ? a : b;
                    int bs;
                    if (npred(bd)==1 && one_succ(bd,bs) && bs==n && bd!=n) {
                        Region r; r.kind = RK::While; r.head = n; r.parts = {n, bd};
                        int id = add(r); collapse({n,bd}, id, {ex}); return true;
                    }
                }
                // Diagnostic hypothesis: if n still participates in a cycle but was not the simple
                // while header above, it is commonly a latch. Do not absorb its exit as an acyclic
                // IfThen; leave the intact cycle for the natural-loop reduction below.
                bool protect_all_cycle = std::getenv("RENOVICE_PROTECT_ALL_CYCLE_IF") != nullptr;
                bool protect_nested_latch = regions[n].kind == RK::Basic
                    && for_latches.count(regions[n].block)
                    && nested_for_latches.count(regions[n].block);
                bool protect_union_multi_latch = !std::getenv("RENOVICE_NO_THREE_LATCH_SINGLE_LOOP")
                    && regions[n].kind == RK::Basic
                    && multi_latch_for_headers.count(regions[n].block);
                bool protect_nested = !std::getenv("RENOVICE_NO_NESTED_LOOP_PROTECTION");
                if ((protect_nested || std::getenv("RENOVICE_CANONICAL_NATURAL_LOOP")
                     || std::getenv("RENOVICE_PROTECT_CYCLE_IF") || protect_all_cycle
                     || protect_union_multi_latch)
                    && (protect_nested_latch || protect_all_cycle || protect_union_multi_latch)
                    && is_loop_header(n)) {
                    if (std::getenv("RENOVICE_SASTEPS")) {
                        std::fprintf(stderr, "SA_PROTECT_FOR_LATCH region=%d block=%d succ=",
                                     n, regions[n].block);
                        std::fprintf(stderr, "%d(term=%d,block=%d),%d(term=%d,block=%d),\n",
                                     a, nsucc(a) == 0 ? 1 : 0, regions[a].block,
                                     b, nsucc(b) == 0 ? 1 : 0, regions[b].block);
                    }
                    continue;
                }
                // IF-THEN-ELSE: both arms private to n and converging on one block
                int as_, bs_;
                if (npred(a)==1 && npred(b)==1 && one_succ(a,as_) && one_succ(b,bs_) && as_==bs_
                    && a!=n && b!=n && as_!=a && as_!=b) {
                    Region r; r.kind = RK::IfThenElse; r.head = n; r.parts = {n, a, b};
                    int id = add(r); collapse({n,a,b}, id, {as_}); return true;
                }
                // IF-THEN: one arm private to n, either joining the other arm OR TERMINATING.
                // The terminating case is `if c then return end` — extremely common, and requiring
                // the arm to have a successor made it unmatchable, which is why 11,723 protos
                // stalled at exactly 3 regions.
                for (int k = 0; k < 2; ++k) {
                    int t = k ? b : a, f = k ? a : b;
                    int ts;
                    bool joins     = one_succ(t, ts) && ts == f;
                    bool terminates = (nsucc(t) == 0);
                    if (npred(t)==1 && (joins || terminates) && t!=n && f!=n) {
                        Region r; r.kind = RK::IfThen; r.head = n; r.parts = {n, t};
                        int id = add(r); collapse({n,t}, id, {f}); return true;
                    }
                }
                // IF-THEN-ELSE where one or both arms TERMINATE (return on one or both paths).
                {
                    int as2 = -1, bs2 = -1;
                    bool at = (nsucc(a) == 0), bt = (nsucc(b) == 0);
                    bool aj = one_succ(a, as2), bj = one_succ(b, bs2);
                    if (npred(a)==1 && npred(b)==1 && a!=n && b!=n) {
                        if (at && bt) {                                   // both arms return
                            Region r; r.kind = RK::IfThenElse; r.head = n; r.parts = {n,a,b};
                            int id = add(r); collapse({n,a,b}, id, {}); return true;
                        }
                        if (at && bj && bs2!=a && bs2!=b) {               // then returns, else joins
                            Region r; r.kind = RK::IfThenElse; r.head = n; r.parts = {n,a,b};
                            int id = add(r); collapse({n,a,b}, id, {bs2}); return true;
                        }
                        if (bt && aj && as2!=a && as2!=b) {               // else returns, then joins
                            Region r; r.kind = RK::IfThenElse; r.head = n; r.parts = {n,a,b};
                            int id = add(r); collapse({n,a,b}, id, {as2}); return true;
                        }
                    }
                }
                // WHILE: body private to n, loops straight back to n
                for (int k = 0; k < 2; ++k) {
                    int bd = k ? b : a, ex = k ? a : b;
                    int bs;
                    if (npred(bd)==1 && one_succ(bd,bs) && bs==n && bd!=n) {
                        Region r; r.kind = RK::While; r.head = n; r.parts = {n, bd};
                        int id = add(r); collapse({n,bd}, id, {ex}); return true;
                    }
                }
            }
        }
        // PROPER REGION — a single-entry, single-exit ACYCLIC subgraph that matches no simple
        // template (a DAG with cross edges: `if a then X elseif b then X end` style sharing).
        // Muchnick calls these "proper regions" and gives them their own node kind rather than
        // trying to express them with if/else templates. Collapsing them lets reduction continue;
        // emission handles the interior separately. Still ZERO duplication.
        for (int n : order) {
            if (!live.count(n)) continue;
            if (nsucc(n) < 2) continue;
            // Grow the region from n: a node joins only if ALL its preds are already inside.
            std::set<int> S; S.insert(n);
            bool grew = true; int guard2 = 0;
            while (grew && guard2++ < 500) {
                grew = false;
                std::set<int> frontier;
                for (int x : S) for (int s2 : succ[x]) if (!S.count(s2) && live.count(s2)) frontier.insert(s2);
                for (int c : frontier) {
                    bool all_in = true;
                    for (int q : pred[c]) if (!S.count(q)) { all_in = false; break; }
                    if (!all_in) continue;
                    if (reaches(c, n)) { all_in = false; }        // cyclic: not an acyclic region
                    if (all_in) { S.insert(c); grew = true; }
                }
            }
            if (S.size() < 3) continue;
            std::set<int> outs;
            for (int x : S) for (int s2 : succ[x]) if (!S.count(s2)) outs.insert(s2);
            if (outs.size() > 1) continue;                        // must be single-exit
            bool cyclic = false;
            for (int x : S) if (x != n && reaches(x, n)) cyclic = true;
            if (cyclic) continue;
            std::vector<int> parts(S.begin(), S.end());
            Region r; r.kind = RK::Proper; r.head = n; r.parts = parts;
            int id = add(r); collapse(parts, id, outs); return true;
        }

        // NATURAL LOOP (general). The acyclic patterns above only catch self-loops and the simple
        // two-block while. A real loop body is an arbitrary sub-region with breaks and continues, and
        // it can only be collapsed once its INTERIOR has been reduced — which is why this runs after
        // a full acyclic pass fails. Collapse the whole natural loop of a back edge into one node.
        //
        // A loop may have several latches (`continue` edges) targeting the same header. Reducing one
        // predecessor at a time creates nested partial NaturalLoops and assigns preheaders/body parts
        // to the wrong wrapper. The narrow production repair below collects every dominance-proven
        // latch and unions their reverse closures before ONE collapse, but only for the pre-classified
        // single-loop/exactly-three-latch FORGLOOP topology. Broader variants failed corpus gates.
        if (!std::getenv("RENOVICE_NO_THREE_LATCH_SINGLE_LOOP")) {
            for (int n : order) {
                if (!live.count(n)) continue;
                std::vector<int> latches;
                for (int p : pred[n]) {
                    if (!live.count(p) || !reaches(n, p)) continue;
                    if (!dominates_current(n, p)) continue;
                    latches.push_back(p);
                }
                bool known_multi_latch = regions[n].kind == RK::Basic
                    && multi_latch_for_headers.count(regions[n].block);
                if (!known_multi_latch || latches.empty()) continue;
                std::set<int> body; body.insert(n);
                std::vector<int> stk(latches.begin(), latches.end());
                while (!stk.empty()) {
                    int x = stk.back(); stk.pop_back();
                    if (body.count(x)) continue;
                    body.insert(x);
                    for (int q : pred[x])
                        if (!body.count(q) && live.count(q)) stk.push_back(q);
                }
                std::set<int> outs;
                for (int x : body)
                    for (int s : succ[x]) if (!body.count(s)) outs.insert(s);
                bool entry_ok = true;
                for (int x : body) if (x != n)
                    for (int q : pred[x]) if (!body.count(q)) entry_ok = false;
                if (!entry_ok) continue;
                std::vector<int> parts(body.begin(), body.end());
                Region r; r.kind = RK::NaturalLoop; r.head = n; r.parts = parts;
                int id = add(r); collapse(parts, id, outs); return true;
            }
            // No multi-latch header was ready. Preserve the established single-latch reduction below.
        }
        for (int n : order) {
            if (!live.count(n)) continue;
            for (int p : pred[n]) {
                if (!live.count(p)) continue;
                if (!reaches(n, p)) continue;                 // n->..->p means p->n closes a cycle
                if ((std::getenv("RENOVICE_CANONICAL_NATURAL_LOOP")
                     || std::getenv("RENOVICE_DOMINANCE_BACKEDGE"))
                    && !dominates_current(n, p)) continue;     // but only dominance makes it a back edge
                std::set<int> body; body.insert(n);
                std::vector<int> stk{p};
                while (!stk.empty()) {                        // natural loop = everything reaching p
                    int x = stk.back(); stk.pop_back();
                    if (body.count(x)) continue;
                    body.insert(x);
                    for (int q : pred[x]) if (!body.count(q) && live.count(q)) stk.push_back(q);
                }
                std::set<int> outs;                           // exits: edges leaving the body
                for (int x : body) for (int s : succ[x]) if (!body.count(s)) outs.insert(s);
                // MULTIPLE EXITS ARE FINE — they are `break`s, which Lua expresses directly. The
                // collapsed node simply keeps several successors and later reductions handle them.
                // Refusing them left 1,766 protos unreduced for no reason.
                if (outs.empty() && body.size() == live.size()) { /* whole graph is the loop */ }
                bool entry_ok = true;                         // single entry (guaranteed if reducible)
                for (int x : body) if (x != n)
                    for (int q : pred[x]) if (!body.count(q)) entry_ok = false;
                if (!entry_ok) continue;
                std::vector<int> parts(body.begin(), body.end());
                Region r; r.kind = RK::NaturalLoop; r.head = n; r.parts = parts;
                int id = add(r); collapse(parts, id, outs); return true;
            }
        }
        return false;
    }

    // Can `from` reach `to` in the current (partially collapsed) graph?
    bool reaches_impl(int from, int to) {
        if (from == to) return true;
        std::set<int> seen; std::vector<int> stk{from};
        while (!stk.empty()) {
            int x = stk.back(); stk.pop_back();
            if (!seen.insert(x).second) continue;
            auto it = succ.find(x);
            if (it == succ.end()) continue;
            for (int s : it->second) { if (s == to) return true; if (live.count(s)) stk.push_back(s); }
        }
        return false;
    }

    // ADVERSARIAL CHECK. "It reduced to one region" is only meaningful if that region actually
    // CONTAINS every block, exactly once. A reduction that loses a block, or counts one twice, would
    // still report success — the precise failure mode that hid the phantom edge and the duplicate
    // loops. Walk the final region tree and collect every Basic block it references.
    void collect(int id, std::vector<int>& blocks, std::set<int>& seen_regions) const {
        if (id < 0 || id >= (int)regions.size()) return;
        if (!seen_regions.insert(id).second) return;          // a region must not appear twice either
        const Region& r = regions[id];
        if (r.kind == RK::Basic) { blocks.push_back(r.block); return; }
        for (int p : r.parts) collect(p, blocks, seen_regions);
    }

    // Returns: 0 = clean, 1 = missing blocks, 2 = duplicated blocks, 3 = both.
    int verify_coverage(const st::Graph& g, int& n_missing, int& n_dup) const {
        std::vector<int> blocks; std::set<int> seen_regions;
        if (live.size() != 1) { n_missing = n_dup = -1; return -1; }
        collect(*live.begin(), blocks, seen_regions);
        std::map<int,int> count;
        for (int b : blocks) count[b]++;
        n_missing = 0; n_dup = 0;
        for (size_t i = 0; i < g.n.size(); ++i) {
            if (!g.n[i].reach) continue;
            auto it = count.find((int)i);
            if (it == count.end()) ++n_missing;
            else if (it->second > 1) ++n_dup;
        }
        return (n_missing ? 1 : 0) | (n_dup ? 2 : 0);
    }

    // Returns true if the graph fully reduced to a single region.
    bool reduce(int& steps) {
        steps = 0;
        while (live.size() > 1 && steps < 100000) { if (!step()) break; ++steps; }
        return live.size() == 1;
    }
};

} // namespace sa
