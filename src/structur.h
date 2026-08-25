// structur.h — M6d: CONTROL-FLOW STRUCTURING.
//
// Luau has NO `goto` (verified: `::label::` is a syntax error). There is therefore no escape hatch —
// every CFG must be reduced to if / while / repeat / for / break / continue, or we cannot emit valid
// source at all. That makes this a hard prerequisite for M6e, not a readability nicety.
//
// The job is tractable because this bytecode is COMPILER OUTPUT, not hand-written or obfuscated:
// the CFGs are reducible and use a small number of stereotyped shapes. We exploit that, but we do
// NOT assume it — anything that fails to reduce is COUNTED and NAMED, never papered over.
//
// Method: dominators -> natural loops from back-edges -> if-regions via convergence points.
#pragma once
#include <vector>
#include <map>
#include <set>
#include <string>
#include <algorithm>
#include <memory>

namespace st {

struct Predicate;
using PredicatePtr = std::shared_ptr<Predicate>;
struct Predicate {
    enum Kind { Test, Not, And, Or } kind = Test;
    int test_insn = -1;
    PredicatePtr left, right;
};

inline PredicatePtr pred_test(int insn) {
    auto p = std::make_shared<Predicate>(); p->kind = Predicate::Test; p->test_insn = insn; return p;
}
inline PredicatePtr pred_not(PredicatePtr value) {
    auto p = std::make_shared<Predicate>(); p->kind = Predicate::Not; p->left = std::move(value); return p;
}
inline PredicatePtr pred_and(PredicatePtr left, PredicatePtr right) {
    auto p = std::make_shared<Predicate>(); p->kind = Predicate::And;
    p->left = std::move(left); p->right = std::move(right); return p;
}
inline PredicatePtr pred_or(PredicatePtr left, PredicatePtr right) {
    auto p = std::make_shared<Predicate>(); p->kind = Predicate::Or;
    p->left = std::move(left); p->right = std::move(right); return p;
}

// A richer CFG than build_cfg's: we need predecessors, and we need the TRUE branch distinguished
// from the fallthrough, which a bare successor list loses.
struct Node {
    int first = 0, last = 0;
    int succ_true = -1;      // branch-taken target (-1 = none)
    int succ_false = -1;     // fallthrough
    std::vector<int> preds;
    bool reach = false;
    uint8_t term = 0;        // terminator opcode
    bool is_branch = false, is_return = false, is_uncond = false;
    // A short-circuit chain collapsed into this block. Each entry is the instruction index of one
    // condition test, in source order, with `chain_and[i]` saying whether test i joins the next with
    // `and` (true) or `or` (false). WITHOUT this the merge silently discards every condition but the
    // last, so `if a and b then` would emit as `if b then` — correct control flow, wrong program.
    std::vector<int> chain;
    std::vector<bool> chain_and;
    // Exact branch-taken predicate tree. The historical flat chain cannot represent mirror merges:
    // reaching Q.true when P.true skips to Q.false is `(not P) and Q`, and P may itself be compound.
    // Populated for merged predicates; a single-test branch leaves this null and uses the established
    // one-instruction inversion renderer, avoiding needless `not (not x)` source churn.
    PredicatePtr branch_predicate;
    // Experiment-only, liveness-proven short-circuit setup folding. Keyed first by the exact test
    // instruction, then by the temporary register used in that test. Keeping the substitution tied
    // to one test prevents a register reused by an earlier chain member from receiving the literal.
    std::map<int, std::map<int, int>> chain_loadn_literals;
    std::set<int> chain_setup_insns;   // exact LOADN materialisations represented by those literals
};

struct Graph {
    std::vector<Node> n;
    std::vector<int> idom;               // immediate dominator
    std::vector<std::set<int>> dom;      // dominator sets
};

// ---- LOOP FOREST -------------------------------------------------------------------------------
// Authoritative loop identification, derived from DOMINATORS and read-only thereafter. This layer
// owns the question "is this a loop, and where are its header/latches/body?" — the emitter must never
// re-derive it by scanning opcodes. Every major decompiler orders it this way: Ghidra runs
// orderLoopBodies() before collapseInternal(), angr/Phoenix structures cyclic regions before acyclic,
// Cifuentes identifies loops before conditionals. Re-deriving it at emission time creates a SECOND,
// inconsistent detector, which is exactly how one loop gets emitted twice (measured: +588 invented
// loop headers across 300 files).
//
// THE INVARIANT IS ONE LOOP PER HEADER, NOT ONE PER BACK EDGE. Two back edges into the same header
// are ONE loop with two latches (a `continue`), and must be merged — cf. LLVM LoopInfo ("a node can
// be the header of at most one loop"), Havlak's union-find, and Ghidra's mergeIdenticalHeads().
// NOTE: `struct Loop` and `find_loops` already exist further down this header and ALREADY handle the
// FORNPREP/FORGPREP asymmetry correctly. They are the authoritative loop map; the emitter simply was
// not consulting them, and re-derived loop structure from opcodes instead. That second, inconsistent
// detector is what invented +588 loop headers across 300 files.

// ---- dominators: straightforward iterative fixpoint. n is small (avg 10 blocks/proto). ----
inline bool is_reducible(const Graph& g);
inline void compute_dom(Graph& g) {
    int N = (int)g.n.size();
    g.dom.assign(N, {});
    if (!N) return;
    std::set<int> all;
    for (int i = 0; i < N; ++i) all.insert(i);
    g.dom[0] = {0};
    for (int i = 1; i < N; ++i) g.dom[i] = all;
    bool changed = true;
    int guard = 0;
    while (changed && guard++ < 1000) {
        changed = false;
        for (int i = 1; i < N; ++i) {
            if (!g.n[i].reach) continue;
            std::set<int> inter;
            bool first = true;
            for (int p : g.n[i].preds) {
                if (!g.n[p].reach) continue;
                if (first) { inter = g.dom[p]; first = false; }
                else {
                    std::set<int> t;
                    std::set_intersection(inter.begin(), inter.end(),
                                          g.dom[p].begin(), g.dom[p].end(),
                                          std::inserter(t, t.begin()));
                    inter = std::move(t);
                }
            }
            inter.insert(i);
            if (inter != g.dom[i]) { g.dom[i] = std::move(inter); changed = true; }
        }
    }
    g.idom.assign(N, -1);
    for (int i = 1; i < N; ++i) {
        if (!g.n[i].reach) continue;
        int best = -1;
        for (int d : g.dom[i]) {
            if (d == i) continue;
            if (best < 0 || g.dom[d].size() > g.dom[best].size()) best = d;
        }
        g.idom[i] = best;
    }
}

inline bool dominates(const Graph& g, int a, int b) {
    if (a < 0 || b < 0 || b >= (int)g.dom.size()) return false;
    return g.dom[b].count(a) != 0;
}

// ---- natural loops ----
struct Loop {
    int header = -1, latch = -1;
    // The PREHEADER: the block holding the FOR*PREP. It is NOT part of the loop - LLVM's definition is
    // "the preheader dominates the loop without itself being part of the loop" - so it is a SIBLING
    // that precedes the loop and is emitted by the enclosing sequence. Recorded here purely so the
    // emitter can ask "does this prep block belong to a REAL loop?" instead of assuming that any prep
    // it happens to find in a subtree is one.
    int prep = -1;
    std::set<int> body;
    enum Kind { While, Repeat, ForNum, ForGen } kind = While;
};

inline std::vector<Loop> find_loops(const Graph& g) {
    std::vector<Loop> out;
    int N = (int)g.n.size();
    // FOR-LOOPS MUST BE FOUND BY PATTERN, NOT BY DOMINANCE. The prep instruction jumps FORWARD to
    // the loop instruction, so there is a path reaching the loop that SKIPS the body — the body
    // therefore does not dominate the loop instruction and the back edge is invisible to the
    // standard natural-loop test. Detecting only by dominance found 50 generic for-loops in a
    // corpus containing ~13,750 FORGPREP instructions.
    for (int b0 = 0; b0 < N; ++b0) {
        if (!g.n[b0].reach) continue;
        uint8_t t = g.n[b0].term;
        bool prep_num = (t == 0x47);                                  // FORNPREP
        bool prep_gen = (t == 0x30 || t == 0x1b || t == 0x0b);        // FORGPREP / _INEXT / generic
        if (!prep_num && !prep_gen) continue;
        // THE TWO PREPS ARE NOT SYMMETRIC.
        //   FORGPREP  jumps TO the FORGLOOP        (target IS the loop instruction)
        //   FORNPREP  jumps to the loop EXIT       (target is PAST the FORNLOOP)
        // Requiring FORNLOOP at the target made the numeric branch DEAD CODE: it never fired once,
        // and numeric for-loops were only ever found by the dominance finder. For FORNPREP the loop
        // instruction is the block that jumps BACK to the body (the prep's fallthrough).
        int body = g.n[b0].succ_false;
        int loopblk = -1;
        if (prep_gen) {
            loopblk = g.n[b0].succ_true;
            if (loopblk < 0 || loopblk >= N || g.n[loopblk].term != 0x1e) continue;
        } else {
            if (body < 0 || body >= N) continue;
            for (int q = 0; q < N; ++q)                                // find the FORNLOOP for THIS body
                if (g.n[q].reach && g.n[q].term == 0x0a && g.n[q].succ_true == body) { loopblk = q; break; }
            if (loopblk < 0) continue;
        }
        Loop L; L.latch = loopblk; L.prep = b0;                       // b0 holds the FOR*PREP
        // THE HEADER IS NOT THE SAME BLOCK FOR THE TWO KINDS, and using "body start" for both is why
        // the pattern entry and the dominance entry never merged: they disagreed about the header, so
        // dedup-by-header kept both. Measured over-reporting: 18 loops mapped where the CFG has 11
        // back-edge headers (Utilities 38 vs 24, Hub 161 vs 117).
        //   NUMERIC: FORNPREP is CONDITIONAL and falls through into the body, and FORNLOOP back-edges
        //     to that same block -> header = body start.
        //   GENERIC: FORGPREP is UNCONDITIONAL and jumps to FORGLOOP; every entry to the body passes
        //     through FORGLOOP, so FORGLOOP DOMINATES the body and IS the header. The back edge is
        //     last-body-block -> FORGLOOP. (Luau Bytecode.h + the Fiu interpreter; see FINDINGS #66.)
        L.header = prep_gen ? loopblk : body;
        if (L.header < 0) L.header = g.n[loopblk].succ_true;
        L.kind = prep_num ? Loop::ForNum : Loop::ForGen;
        // A numeric/generic loop's bytecode interval can contain a dead block left by compiler
        // layout.  Dead blocks have no executable loop membership and are intentionally absent from
        // the reachable region tree.  Including them made 36 otherwise complete ability loops look
        // ownerless and encouraged later layers to resurrect unreachable code.  Authoritative loop
        // bodies contain reachable CFG nodes only.
        for (int x = L.header; x >= 0 && x <= loopblk && x < N; ++x)
            if (g.n[x].reach) L.body.insert(x);
        if (loopblk >= 0 && loopblk < N && g.n[loopblk].reach) L.body.insert(loopblk);
        if (L.header >= 0) out.push_back(std::move(L));
    }
    for (int b = 0; b < N; ++b) {
        if (!g.n[b].reach) continue;
        for (int s : {g.n[b].succ_true, g.n[b].succ_false}) {
            if (s < 0 || s >= N) continue;
            if (!dominates(g, s, b)) continue;          // a back edge: target dominates source
            Loop L; L.header = s; L.latch = b;
            L.body.insert(s);
            std::vector<int> stk{b};
            while (!stk.empty()) {
                int x = stk.back(); stk.pop_back();
                if (x < 0 || x >= N || !g.n[x].reach) continue;
                if (L.body.count(x)) continue;
                L.body.insert(x);
                for (int p : g.n[x].preds)
                    if (p >= 0 && p < N && g.n[p].reach && !L.body.count(p)) stk.push_back(p);
            }
            out.push_back(std::move(L));
        }
    }
    // ---- DE-DUPLICATE ------------------------------------------------------------------------
    // The pattern finder and the dominance finder BOTH claim for-loops, registering the same loop
    // twice with different kinds AND different bodies (measured on NemesisMission p25: 6 duplicate
    // headers, e.g. ForNum body {98,99,100} alongside While body {98,100}). `loop_for_header` then
    // picks whichever is larger while the rest of the descent may follow the other, so the two
    // disagree about which blocks belong to the loop — the structural cause of the split runaways.
    // Keep ONE loop per header: the more specific KIND (a for-loop knows its shape), with the LARGER
    // body, since the pattern finder's range can miss blocks the dominance closure found.
    std::vector<Loop> dedup;
    for (Loop& L : out) {
        bool merged_in = false;
        for (Loop& D : dedup) {
            if (D.header != L.header) continue;
            bool L_specific = (L.kind == Loop::ForNum || L.kind == Loop::ForGen);
            bool D_specific = (D.kind == Loop::ForNum || D.kind == Loop::ForGen);
            if (L_specific && !D_specific) { D.kind = L.kind; D.latch = L.latch; }
            for (int x : L.body)
                if (x >= 0 && x < N && g.n[x].reach) D.body.insert(x); // union reachable blocks
            merged_in = true;
            break;
        }
        if (!merged_in) dedup.push_back(L);
    }
    return dedup;
}

// ---- structured tree ----
enum class SK2 { Seq, Block, If, While, Repeat, ForNum, ForGen, Break, Continue, Return,
                 StateMachine, Unstructured };

struct SNode;
using SP = std::shared_ptr<SNode>;

struct SNode {
    SK2 k = SK2::Block;
    int blk = -1;                    // Block: which CFG node
    int cond_blk = -1;               // If/While/Repeat: block holding the condition
    bool negate = false;
    std::vector<SP> body, orelse;    // If: then/else ; loops: body
    std::string why;                 // Unstructured: the reason
};

inline SP mksn(SK2 k) { auto s = std::make_shared<SNode>(); s->k = k; return s; }

struct Result {
    SP root;
    bool ok = true;
    bool via_state_machine = false;
    bool was_reducible = false;      // reduced by FALLBACK, not by natural structuring
    std::string why;
    int n_if = 0, n_while = 0, n_repeat = 0, n_fornum = 0, n_forgen = 0, n_unstructured = 0;
    int sm_states = 0;
};

// ---------------------------------------------------------------------------------------------
// STATE-MACHINE FALLBACK.
//
// Luau has no `goto`, so a CFG with genuine cross-arm jumps (one branch ENTERING another rather than
// joining it) cannot be written with if/while/for at all. Every such graph can still be expressed
// EXACTLY as a dispatch loop:
//
//     local state = 0
//     while true do
//         if state == 0 then <block 0 stmts>  state = <succ>
//         elseif state == 1 then ...
//         end
//     end
//
// This is semantically exact for ANY control flow, reducible or not — each block runs, then names
// its successor. It is verbose, so it is a FALLBACK used only where natural structuring fails, and
// it is COUNTED SEPARATELY rather than folded into the "structured" number: a proto emitted this way
// is correct but unreadable, and that distinction must stay visible.
// ---------------------------------------------------------------------------------------------
inline SP build_state_machine(const Graph& g, int& nstates) {
    auto sm = mksn(SK2::StateMachine);
    nstates = 0;
    for (size_t i = 0; i < g.n.size(); ++i) {
        if (!g.n[i].reach) continue;
        auto b = mksn(SK2::Block);
        b->blk = (int)i;
        sm->body.push_back(b);
        ++nstates;
    }
    return sm;
}

// ---- post-dominators: the same fixpoint on the REVERSED graph. An `if` converges at the
// immediate post-dominator of its branch block, which is where the then/else arms rejoin.
inline void compute_postdom(Graph& g, std::vector<std::set<int>>& pd) {
    int N = (int)g.n.size();
    pd.assign(N, {});
    if (!N) return;
    std::vector<int> exits;
    for (int i = 0; i < N; ++i)
        if (g.n[i].reach && g.n[i].succ_true < 0 && g.n[i].succ_false < 0) exits.push_back(i);
    std::set<int> all;
    for (int i = 0; i < N; ++i) all.insert(i);
    for (int i = 0; i < N; ++i) pd[i] = all;
    for (int e : exits) pd[e] = {e};
    bool changed = true; int guard = 0;
    while (changed && guard++ < 1000) {
        changed = false;
        for (int i = N - 1; i >= 0; --i) {
            if (!g.n[i].reach) continue;
            bool isexit = false; for (int e : exits) if (e == i) isexit = true;
            if (isexit) continue;
            std::set<int> inter; bool first = true;
            for (int s : {g.n[i].succ_true, g.n[i].succ_false}) {
                if (s < 0 || s >= N || !g.n[s].reach) continue;
                if (first) { inter = pd[s]; first = false; }
                else { std::set<int> t;
                    std::set_intersection(inter.begin(), inter.end(), pd[s].begin(), pd[s].end(),
                                          std::inserter(t, t.begin()));
                    inter = std::move(t); }
            }
            inter.insert(i);
            if (inter != pd[i]) { pd[i] = std::move(inter); changed = true; }
        }
    }
}

inline int ipostdom(const std::vector<std::set<int>>& pd, int i) {
    if (i < 0 || i >= (int)pd.size()) return -1;
    int best = -1;
    for (int d : pd[i]) {
        if (d == i) continue;
        if (best < 0 || pd[d].size() > pd[best].size()) best = d;
    }
    return best;
}

// ---------------------------------------------------------------------------------------------
// Recursive descent over the CFG. `stop` bounds the region; `loop_hdr`/`loop_exit` give the current
// loop so that an edge leaving it becomes `break` and an edge back to its header becomes `continue`.
// Anything that does not fit a known shape becomes an Unstructured node carrying a REASON — that is
// the honest failure mode, and those are what the metric counts.
// ---------------------------------------------------------------------------------------------
struct Ctx {
    Graph* g;
    std::vector<std::set<int>>* pd;
    std::vector<Loop>* loops;
    Result* res;
    std::set<int> emitted;
    int depth = 0;
    // Diagnostics: WHAT shape defeated us, not just that something did. Without this the residue is
    // an undifferentiated 19% and every "fix" is a guess.
    std::map<std::string,long long>* diag = nullptr;
    // ACTIVE STOP POINTS. A single `stop` parameter only knows about the innermost region, so an
    // arm that legitimately runs to an OUTER region's join looked like a revisit and was rejected.
    // Every enclosing follow-point must be a clean stop.
    std::set<int> stops;
    // Enclosing loop headers/exits. `loop_hdr`/`loop_exit` are the INNERMOST only, so a revisit of an
    // OUTER loop's header or exit was not recognised as continue/break and became residue.
    std::vector<int> loop_hdrs, loop_exits;
    int split_budget = 0;               // node-splitting allowance for irreducible graphs
    // PER-BLOCK duplication cap. A global budget alone does not stop the chain from walking around a
    // CYCLE, duplicating the same blocks forever: one 75-block proto burned 199,928 duplications and
    // still failed. Capping each block individually bounds the walk without limiting legitimate
    // duplication elsewhere.
    std::map<int,int> dup_count;
    std::map<int,int> split_count;   // per-block node-split counter (see runaway note)
    int dup_cap = 1000000000;   // effectively OFF: every finite cap measured WORSE (4->150, 512->23, 4096->12 fallbacks vs 3 uncapped). The 199,928 duplications on one proto were genuine, not a cycle.
    void note(const std::string& k) { if (diag) (*diag)[k]++; }
};

inline std::vector<SP> structure_seq(Ctx& C, int entry, int stop, int loop_hdr, int loop_exit);

// The loop's exit is the target of ANY edge leaving the body — not just from the header or latch.
// A `while true do ... break ... end` has NO exit from either, so looking only there yields -1, the
// traversal stops dead, and every block after the loop (including the break target) is never placed.
// Is this CFG REDUCIBLE? A reducible graph can ALWAYS be expressed with if/while/for plus node
// splitting — no `goto` required. So if a proto we failed to structure turns out to be reducible,
// the fault is in the STRUCTURER, not in the graph, and the state-machine fallback is masking a bug
// rather than handling a genuine impossibility. Test: every retreating edge (u -> v where v is an
// ancestor of u in the DFS tree) must have v dominating u.
// Reducibility on a graph whose dominators have NOT been computed yet — computes them locally.
inline bool is_reducible_raw(Graph g) {           // by value: we mutate dom[]
    compute_dom(g);
    return is_reducible(g);
}

inline bool is_reducible(const Graph& g) {
    int N = (int)g.n.size();
    if (!N) return true;
    std::vector<int> state(N, 0);            // 0 = unvisited, 1 = on stack, 2 = done
    std::vector<std::pair<int,int>> stk;
    stk.push_back({0, 0});
    state[0] = 1;
    bool reducible = true;
    while (!stk.empty()) {
        // DO NOT hold a reference into `stk` across a push_back — the vector can reallocate and the
        // reference dangles. That bug made this test report ~8,800 reducible graphs as irreducible,
        // which in turn made "genuinely irreducible" counts throughout this work far too high.
        int u  = stk.back().first;
        int ei = stk.back().second;
        int nxt = -1;
        if (ei == 0)      { nxt = g.n[u].succ_true;  stk.back().second = 1; }
        else if (ei == 1) { nxt = g.n[u].succ_false; stk.back().second = 2; }
        else { state[u] = 2; stk.pop_back(); continue; }
        if (nxt < 0 || nxt >= N || !g.n[nxt].reach) continue;
        if (state[nxt] == 1) {                                  // retreating edge u -> nxt
            if (!dominates(g, nxt, u)) reducible = false;        // target must dominate source
        } else if (state[nxt] == 0) {
            state[nxt] = 1; stk.push_back({nxt, 0});
        }
    }
    return reducible;
}

inline int loop_exit_of(const Graph& g, const Loop& L) {
    // PRIORITY MATTERS. The natural exit is the edge leaving the loop from its HEADER (a `while`
    // whose test fails) or its LATCH (a `repeat`/`for` that finishes). Scanning the whole body and
    // taking the lowest index instead picks a `break` target and mis-sites the loop end — that
    // measured 92.94% vs 93.73%. The body-wide scan is only a FALLBACK for loops with no exit from
    // either, i.e. `while true do ... break ... end`, where the break target IS the exit.
    auto outside = [&](int b, int& ex) {
        if (b < 0 || b >= (int)g.n.size()) return false;
        for (int s : {g.n[b].succ_true, g.n[b].succ_false})
            if (s >= 0 && !L.body.count(s)) { ex = s; return true; }
        return false;
    };
    int ex = -1;
    if (outside(L.header, ex)) return ex;
    if (outside(L.latch, ex))  return ex;
    int best = -1;
    for (int b : L.body) {
        if (b < 0 || b >= (int)g.n.size()) continue;
        for (int s : {g.n[b].succ_true, g.n[b].succ_false})
            if (s >= 0 && !L.body.count(s)) { if (best < 0 || s < best) best = s; }
    }
    return best;
}

inline const Loop* loop_for_header(Ctx& C, int b) {
    const Loop* best = nullptr;
    for (const Loop& L : *C.loops)
        if (L.header == b && (!best || L.body.size() > best->body.size())) best = &L;
    return best;
}

inline std::vector<SP> structure_seq(Ctx& C, int entry, int stop, int loop_hdr, int loop_exit) {
    std::vector<SP> out;
    int cur = entry;
    int guard = 0;
    Graph& g = *C.g;
    // Blocks placed by THIS invocation. A region that ends early — on a return, a break, a continue,
    // or a stop — may still OWN unplaced dominator-tree children. The three existing sweep sites only
    // cover an `if` join, straight-line flow, and a loop exit; every other exit abandoned them. That
    // is what leaves 3,324 single-predecessor blocks unplaced, and a block with ONE predecessor is
    // always dominated by it, so it is always placeable.
    std::vector<int> mine;
    if (++C.depth > 20000) {   // raised: duplication on a 150+ block graph legitimately nests deep                                  // pathological nesting: bail LOUDLY
        auto u = mksn(SK2::Unstructured); u->why = "nesting depth exceeded";
        ++C.res->n_unstructured; out.push_back(u); --C.depth; return out;
    }
    while (cur >= 0 && cur != stop && cur < (int)g.n.size() && guard++ < 4000) {
        if (!g.n[cur].reach) break;
        if (cur == loop_hdr) {                               // back to our own header
            if (!out.empty()) { auto c = mksn(SK2::Continue); out.push_back(c); }
            break;                                           // the latch edge itself is implicit
        }
        if (C.stops.count(cur)) break;                     // an enclosing region owns this block
        // Reaching ANY enclosing loop's header or exit is a loop edge, not unstructured flow.
        // Luau has no labelled break, so an OUTER exit cannot be written directly — but stopping
        // here is still correct: the enclosing region will place what follows.
        for (size_t li = 0; li + 1 < C.loop_hdrs.size(); ++li)
            if (C.loop_hdrs[li] == cur) { C.note("outer-loop header reached"); goto done_seq; }
        for (size_t li = 0; li + 1 < C.loop_exits.size(); ++li)
            if (C.loop_exits[li] == cur) { C.note("outer-loop exit reached"); goto done_seq; }
        if (cur == loop_exit && loop_exit >= 0) {          // an edge leaving the loop IS a break
            auto br = mksn(SK2::Break); out.push_back(br); break;
        }
        // NOTE: node splitting must be done as a GRAPH PRE-PASS (materialise duplicate nodes with
        // their own indices), NOT during traversal. Erasing from `emitted` mid-descent lets the same
        // block split over and over: measured 113,088 splits for +0.29pp, with the budget exhausting
        // before convergence. Disabled deliberately until implemented properly.
        // Re-enabled, but ONLY for a block whose whole dominated sub-region is small. The earlier
        // unbounded version split anything and thrashed (113,088 splits, +0.29pp). Restricting it to
        // small owned regions bounds the duplication to something a reader can still follow.
        // A LOOP HEADER OR LATCH MUST NOT BE SPLIT. Those blocks belong to the loop machinery;
        // duplicating one re-enters the loop and splits it again, forever — the same runaway as
        // back-edge duplication, just via the branch path (1,128,310 splits on one proto).
        // MEASURED: blanket-refusing to split loop headers/latches costs 6.6pp (99.998 -> 93.40) and
        // breaks ground truth (294 -> 290) — legitimate splits frequently land on them. The runaway
        // is not "splitting a loop block", it is splitting the SAME block over and over, so cap the
        // split count PER BLOCK instead (duplication stays uncapped; only splits thrash).
        if (C.emitted.count(cur) && C.split_budget > 0 && g.n[cur].is_branch
            && C.split_count[cur] < C.dup_cap) {   // escalates with the ladder
            ++C.split_count[cur];
            // NODE SPLITTING. A block reachable by more than one path cannot be written once in a
            // goto-less language, but DUPLICATING it is semantically exact: each path gets its own
            // copy of the same code. This is the general solution for irreducible flow, and it also
            // rescues reducible graphs whose join the descent mis-sited. Bounded by split_budget so
            // a pathological graph cannot expand without limit.
            if (C.dup_count[cur] >= C.dup_cap) { C.note("split refused: per-block cap"); }
            else {
                --C.split_budget; ++C.dup_count[cur];
                C.emitted.erase(cur);
                C.note("node split");
            }
        }
        if (C.emitted.count(cur)) {
            // A SHARED TAIL is not unstructured control flow. When several arms fall into the same
            // small straight-line block (overwhelmingly a lone `return`), Lua cannot express the
            // join — but DUPLICATING the block is exactly equivalent, and is what the original
            // source looked like before the compiler shared it. Only safe for blocks that do not
            // branch, so no control flow is invented.
            const Node& rv0 = g.n[cur];
            if (!rv0.is_branch) {
                // Duplication is semantically EXACT for any straight-line block — no branching
                // decision is being invented, the same statements simply appear on both paths (which
                // is how the source read before the compiler shared the tail). The earlier 8-insn cap
                // was arbitrary. Blocks that BRANCH are still refused: duplicating those would
                // duplicate a decision, which is not the same program.
                // Duplicate the TAIL ONLY — do not chain onward through its successors. Chaining
                // took duplications from 7,921 to 73,560 for a 0.4pp structuring gain: an order of
                // magnitude of code bloat bought almost nothing.
                if (!(rv0.is_return || (rv0.succ_true < 0 && rv0.succ_false < 0))) {
                    // A NON-TERMINAL straight-line block reached twice. Duplicating it is just as
                    // exact as duplicating a tail — it contains no branching decision, only
                    // statements — so the only reason to refuse was the unbounded chaining that
                    // once produced 73,560 duplicates. With split_budget in place that risk is
                    // capped, so chain from here instead of giving up.
                    // NEVER duplicate ACROSS A BACK EDGE. A block ending in JUMPBACK is not a
                    // branch, so it lands in this path — and following its back edge duplicates the
                    // whole loop, then arrives at the same block again, forever. That is the runaway:
                    // 1,999,316 duplications on a 75-block proto, consuming a 2,000,000 budget.
                    // A loop latch must be handled as a loop edge, not copied.
                    int nxt2 = (rv0.succ_false >= 0) ? rv0.succ_false : rv0.succ_true;
                    bool backedge = (rv0.term == 0x25) || (nxt2 >= 0 && nxt2 <= cur);
                    if (backedge) {
                        C.note("dup refused: back edge");
                        break;                       // the loop machinery owns this edge
                    }
                    if (C.split_budget > 0 && C.dup_count[cur] < C.dup_cap) {
                        --C.split_budget; ++C.dup_count[cur];
                        auto dup2 = mksn(SK2::Block); dup2->blk = cur; out.push_back(dup2);
                        C.note("non-terminal duplicated");
                        cur = nxt2;
                        continue;
                    }
                    auto u2 = mksn(SK2::Unstructured);
                    u2->why = "non-terminal shared block " + std::to_string(cur);
                    C.note("revisit non-terminal (budget exhausted)");
                    ++C.res->n_unstructured; out.push_back(u2); break;
                }
                auto dup = mksn(SK2::Block); dup->blk = cur; out.push_back(dup);
                C.note("shared tail duplicated");
                break;
            }
            auto u = mksn(SK2::Unstructured);
            u->why = "revisit of block " + std::to_string(cur);
            {   const Node& rv = g.n[cur];
                char kb[96];
                std::snprintf(kb, sizeof kb, "revisit preds=%zu term=0x%02x%s%s",
                              rv.preds.size(), rv.term,
                              rv.is_return ? " RET" : "", rv.is_branch ? " BR" : "");
                C.note(kb);
                C.note(loop_hdr >= 0 ? "revisit inside-loop" : "revisit outside-loop"); }
            ++C.res->n_unstructured; out.push_back(u); break;
        }
        // A FOR-PREP block IS the loop entry. Reaching it first and treating it as a generic
        // two-way branch builds a bogus `if` whose else-arm walks straight into the loop body —
        // that was 10,606 revisits, the single largest failure shape.
        {   uint8_t pt = g.n[cur].term;
            bool isprep = (pt == 0x47 || pt == 0x30 || pt == 0x1b || pt == 0x0b);
            if (isprep && !C.emitted.count(cur)) {
                const Loop* FL = nullptr;
                for (const Loop& q : *C.loops) if (q.latch == g.n[cur].succ_true) { FL = &q; break; }
                if (FL) {
                    C.emitted.insert(cur); mine.push_back(cur);   // sweep must see loop preps too
                    auto blkp = mksn(SK2::Block); blkp->blk = cur; out.push_back(blkp);
                    auto n = mksn(FL->kind == Loop::ForNum ? SK2::ForNum : SK2::ForGen);
                    if (FL->kind == Loop::ForNum) ++C.res->n_fornum; else ++C.res->n_forgen;
                    n->cond_blk = FL->latch;
                    int ex = loop_exit_of(g, *FL);
                    {   bool addex = (ex >= 0 && !C.stops.count(ex));
                        if (addex) C.stops.insert(ex);
                        C.loop_hdrs.push_back(FL->latch); C.loop_exits.push_back(ex);
                        n->body = structure_seq(C, g.n[cur].succ_false, FL->latch, FL->latch, ex);
                        C.loop_hdrs.pop_back(); C.loop_exits.pop_back();
                        if (addex) C.stops.erase(ex); }
                    C.emitted.insert(FL->latch); mine.push_back(FL->latch);
                    out.push_back(n);
                    // same dom-child sweep as after an `if`: if the exit is already placed, continue with
                    // a dominator-tree child we still own rather than abandoning the region.
                    if (ex >= 0 && !C.emitted.count(ex)) cur = ex;
                    else { int ch = -1;
                           for (size_t q = 0; q < g.n.size(); ++q)
                               if (g.n[q].reach && !C.emitted.count((int)q) && g.idom[q] == cur) { ch = (int)q; break; }
                           cur = ch; }
                    continue;
                }
            }
        }
        const Loop* L = loop_for_header(C, cur);
        if (L && cur != loop_hdr) {                          // a loop starts here
            C.emitted.insert(cur); mine.push_back(cur);   // and loop headers
            auto n = mksn(SK2::While);
            const Node& h = g.n[L->header];
            // exit = the successor of the header (or latch) that is OUTSIDE the loop body
            int ex = loop_exit_of(g, *L);
            // The loop KIND is decided by the LATCH, not the header. For `for k,v in pairs(t)` the
            // natural-loop header is the BODY start (that is what the back edge targets) and the
            // FORGLOOP sits at the latch — reading the header's terminator found only 151 generic
            // for-loops in a corpus containing ~13,750 FORGPREP instructions.
            uint8_t lt = g.n[L->latch].term;
            uint8_t t  = h.term;
            if (L->kind == Loop::ForNum || lt == 0x0a || t == 0x47) { n->k = SK2::ForNum; ++C.res->n_fornum; }
            else if (L->kind == Loop::ForGen) { n->k = SK2::ForGen; ++C.res->n_forgen; }
            else if (lt == 0x1e || t == 0x30 || t == 0x1b || t == 0x0b) { n->k = SK2::ForGen; ++C.res->n_forgen; }
            else if (h.is_branch) { n->k = SK2::While; ++C.res->n_while; }
            else { n->k = SK2::Repeat; ++C.res->n_repeat; }
            n->cond_blk = L->header;
            int binner = (h.succ_false >= 0 && L->body.count(h.succ_false)) ? h.succ_false : h.succ_true;
            {   bool addex = (ex >= 0 && !C.stops.count(ex));
                if (addex) C.stops.insert(ex);
                C.loop_hdrs.push_back(L->header); C.loop_exits.push_back(ex);
                n->body = structure_seq(C, binner, L->header, L->header, ex);
                C.loop_hdrs.pop_back(); C.loop_exits.pop_back();
                if (addex) C.stops.erase(ex); }
            out.push_back(n);
            // same dom-child sweep as after an `if`: if the exit is already placed, continue with
            // a dominator-tree child we still own rather than abandoning the region.
            if (ex >= 0 && !C.emitted.count(ex)) cur = ex;
            else { int ch = -1;
                   for (size_t q = 0; q < g.n.size(); ++q)
                       if (g.n[q].reach && !C.emitted.count((int)q) && g.idom[q] == cur) { ch = (int)q; break; }
                   cur = ch; }
            continue;
        }
        const Node& nd = g.n[cur];
        C.emitted.insert(cur);
        mine.push_back(cur);
        auto blk = mksn(SK2::Block); blk->blk = cur; out.push_back(blk);
        if (nd.is_return || (nd.succ_true < 0 && nd.succ_false < 0)) break;
        if (nd.is_branch && nd.succ_true >= 0 && nd.succ_false >= 0) {
            int follow = ipostdom(*C.pd, cur);
            // A JOIN MUST BE DOMINATED BY THE BRANCH. If the immediate post-dominator is not, it is
            // not this `if`'s join at all — it belongs to an enclosing region — and using it as the
            // arm boundary lets one arm run past its own end and into the other arm's blocks, which
            // is the "revisit" residue. Note this gates the FOLLOW, not the ARMS: gating the arms on
            // dominance was measured at -3pp and is a different (wrong) idea.
            // MEASURED -2.1pp (97.13 -> 95.03): gating the join on `dominates(cur, follow)` is the
            // THIRD dominance-gating idea to lose to plain edge-following here. The ad-hoc loop and
            // short-circuit machinery already establishes region boundaries that dominance-gating
            // then overrides incorrectly. Left disabled with the number attached.
            //   if (follow >= 0 && !dominates(g, cur, follow)) follow = stop;
            if (follow < 0 || follow == cur) follow = stop;
            auto n = mksn(SK2::If); n->cond_blk = cur; ++C.res->n_if;
            // THE DOMINANCE RULE. Only descend into an arm that this block DOMINATES. A successor
            // not dominated by `cur` is reachable some other way too, so an ANCESTOR owns it — it is
            // the join, or a break/continue target. Because every block has exactly one immediate
            // dominator, following the dominator tree emits each block exactly once BY CONSTRUCTION,
            // which is what makes revisits impossible on a reducible graph rather than merely rare.
            bool addstop = (follow >= 0 && !C.stops.count(follow));
            if (addstop) C.stops.insert(follow);
            // MEASURED: gating the ARMS on dominance costs ~3pp (94.51 -> 91.33). The arms are
            // followed by edge; dominance is used only to decide where to CONTINUE afterwards, plus
            // the dom-child sweep below to place joins that are not direct successors.
            n->body   = structure_seq(C, nd.succ_false, follow, loop_hdr, loop_exit);
            n->orelse = structure_seq(C, nd.succ_true,  follow, loop_hdr, loop_exit);
            if (addstop) C.stops.erase(follow);
            out.push_back(n);
            // The OTHER HALF of the dominance rule. Ownership decides what we may descend into;
            // it does not by itself place the JOIN. A block whose immediate dominator is `cur` must
            // still be emitted inside cur's region even when it is not a direct successor — the join
            // of a nested if is exactly that. Without this the joins are simply never placed, which
            // measured 89.55% vs 94.51%.
            if (follow >= 0 && !C.emitted.count(follow)) cur = follow;
            else {
                int child = -1;
                for (size_t q = 0; q < g.n.size(); ++q)
                    if (g.n[q].reach && !C.emitted.count((int)q) && g.idom[q] == cur) { child = (int)q; break; }
                cur = child;
            }
            continue;
        }
        {   // straight line / unconditional jump: same rule, same second half.
            int nx = (nd.succ_false >= 0) ? nd.succ_false : nd.succ_true;
            if (nx >= 0 && !C.emitted.count(nx)) cur = nx;
            else {
                int child = -1;
                for (size_t q = 0; q < g.n.size(); ++q)
                    if (g.n[q].reach && !C.emitted.count((int)q) && g.idom[q] == cur) { child = (int)q; break; }
                cur = child;
            }
        }
    }
    done_seq:
    // SWEEP: place any dominator-tree child this region owns but never reached. Correct by
    // construction — a block whose immediate dominator sits in this region belongs to this region,
    // and nowhere else can legitimately place it.
    for (size_t mi = 0; mi < mine.size(); ++mi) {
        int b = mine[mi];
        for (size_t q = 0; q < g.n.size(); ++q) {
            if (!g.n[q].reach || C.emitted.count((int)q)) continue;
            if (g.idom[q] != b) continue;
            // Do NOT skip blocks registered as a `stop`. The assumption was that the enclosing
            // region would place them, but an ancestor only places ITS OWN follow — anything
            // registered by a different enclosing region falls through the gap and is never placed
            // at all (measured: 8,908 candidates skipped this way). `C.emitted` already prevents
            // double-placement, so the worst case here is nesting a block deeper than ideal, which
            // is strictly better than omitting it.
            C.note("dom-child swept at region exit");
            auto sub = structure_seq(C, (int)q, stop, loop_hdr, loop_exit);
            for (auto& sp : sub) out.push_back(sp);
        }
    }
    --C.depth;
    return out;
}

} // namespace st
