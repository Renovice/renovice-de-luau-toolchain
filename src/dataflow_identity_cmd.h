// dataflow_identity_cmd.h -- stock dataflow identity gate (2026-10-09).
//
// CFG-ID (cfg_identity_cmd.h) is register-free: MOVE, LOADNIL and CAPTURE are epsilon and register
// operands are not compared. It cannot see WHICH value an operation reads. Documented wrong outputs
// that passed it: #41 (loop-carried nil reset every iteration), #47 (loop-entry LOADNIL dropped),
// #52 (by-value capture bound to a flat local the loop rewrites) and SetVortexWindPerZone (a register
// read before its assignment). This gate is an INDEPENDENT property scored per prototype (PITFALLS
// B9); it never changes CFG-ID's verdict.
//
// Model (reuses CFG-ID's per-prototype model: labels, folds F1-F3/N5, dispatch webs, liveness).
// 1. Per side, the instruction graph is expanded by the dispatch environment exactly as
//    cfg_identity_resolve walks it (same liveness pruning, emitter state definitions and statically
//    decided state tests), with successors in instruction order and canonical branch order
//    (CfgIdentityNode::base_succ, recorded before S1 repositions pure nodes).
// 2. SYNC nodes are the observable non-pure operations (cfg_identity_resolve returns the node itself;
//    not a LOAD/NEWTABLE/DUPTABLE/GETIMPORT, whose order S1 canonicalizes). Their relative order is
//    what CFG-ID matches, so both sides are walked in LOCKSTEP from sync node to sync node: labels
//    (upvalue slots up to CFG-ID's bijection) and arity must agree, and successor k pairs with
//    successor k. Between sync nodes each side executes its own instructions in their real order.
// 3. A forward may-analysis over that product graph gives, per side and register, the set of value
//    ORIGINS reaching each sync node. Origins are register-free and shared by both sides:
//      K:<v>   a constant (LOADN/LOADK/LOADB/LOADNIL, emitter state load, GETIMPORT path): immutable
//              values compare by value
//      P<r>    parameter r on entry;  U  any other register on entry (compiled stock code never reads it)
//      D<p>#k  result k of the operation at product node p: the SAME token on both sides, so the
//              comparison is exact and path-sensitive (a duplicated or shared block is its own node)
//      N:<i>   a table created by a pure NEWTABLE/DUPTABLE; stock and candidate correspond iff CFG-ID's
//              bisimulation paired the two instructions
//    MOVE copies origins; NAMECALL's self copies its object; an N5-folded NOT copies its operand; a
//    folded F3 (MOVE; JUMPIF; MOVE/LOAD) is ONE operation defining its target (stock native
//    OR/AND[K]) and reads the alternative as its second operand; F1/F2 scratch loads are not operands
//    (stock EQK/<OP>K/SUBRK carry the constant in the instruction).
// Facts compared at every product node: every register operand SLOT of the operation (argument and
// operand order kept, EQ's two operands unordered, LT/LE ordered, multret tails as one slot) carries
// the same origin set. Each CAPTURE of a CLOSURE is a slot:
//   VAL   origins of the captured register at closure creation
//   REF   the same plus every origin WRITTEN to that register while the upvalue is open (reachable
//         from the capture before a covering CLOSEUPVALS or a RETURN). A REF capture with no such
//         write, whose child never writes the upvalue, is a VAL capture (the shared variable never
//         changes), so the capture MODE alone is not compared.
//   UPVAL upvalue slot, under CFG-ID's upvalue bijection.
// Verdict per prototype: EQUAL (lockstep complete, no difference), DIFF (a decisive difference, also
// when the lockstep stopped at a mismatch: the matched prefix is still a pair of corresponding
// paths), UNPAIRED (lockstep incomplete, or a table origin whose instruction CFG-ID never paired,
// and no decisive difference), MODEL_ERROR (fail closed: unknown register effects, a budget, a walk
// that splits into two sync nodes, or a lockstep mismatch although CFG-ID passed).
// Limitations (not claimed): values a callee writes through a REF upvalue during a call are not
// modelled; table contents are not dataflow (which table is read is); prototypes are paired by index.
#pragma once
#include <algorithm>
#include <bitset>
#include <deque>
#include <map>
#include <set>
#include <string>
#include <vector>

struct DfToken { char kind = 'U'; std::string value; int node = -1; int k = 0; char side = 0; };
static const int DF_MULTRET = 1000;

struct DfSets {
    std::vector<std::vector<int>> sets{std::vector<int>{}};
    std::map<std::vector<int>, int> ids{{std::vector<int>{}, 0}};
    std::map<std::pair<int, int>, int> unions;
    int intern(std::vector<int> v) {
        std::sort(v.begin(), v.end());
        v.erase(std::unique(v.begin(), v.end()), v.end());
        auto it = ids.find(v);
        if (it != ids.end()) return it->second;
        const int id = (int)sets.size();
        sets.push_back(v);
        ids.emplace(sets.back(), id);
        return id;
    }
    int join(int a, int b) {
        if (a == b || b == 0) return a;
        if (a == 0) return b;
        const std::pair<int, int> key = a < b ? std::make_pair(a, b) : std::make_pair(b, a);
        auto it = unions.find(key);
        if (it != unions.end()) return it->second;
        std::vector<int> v = sets[(size_t)a];
        v.insert(v.end(), sets[(size_t)b].begin(), sets[(size_t)b].end());
        const int id = intern(v);
        unions[key] = id;
        return id;
    }
};

struct DfSlot {
    std::string tag;          // "" register operand, "MR" multret tail, "CAP VAL", "CAP REF", "CAP UPVAL"
    int set = 0;
    int writes = -1;          // CAP REF: origins written while the upvalue is open
    int upval = -1;           // CAP UPVAL: parent upvalue slot
    int ordinal = -1;         // capture slots: the child's upvalue index
};

struct DfRecord {
    std::vector<DfSlot> slots;
    bool unordered_pair = false;
    int child = -1;                 // CLOSURE: flat child prototype (capture slots follow its upvalues)
};

struct DfSide {
    const ir::IProto* ip = nullptr;
    const CfgIdentityProto* model = nullptr;
    const std::vector<ir::IProto>* module = nullptr;
    const std::vector<std::set<int>>* used_upvalues = nullptr;   // per flat proto, reachable uses
    char name = 'a';
    int regs = 1;                   // maxstack; register `regs` is the multret TOP pseudo register
    std::vector<int> e_instr;
    std::vector<CfgIdentityEnv> e_env;
    std::vector<std::vector<int>> e_succ;            // -1 = falls off the end
    std::map<std::pair<int, std::string>, int> e_index;
    std::vector<signed char> sync;
    std::vector<int> f3_alt_of;
    std::vector<char> f3_branch;
    std::vector<std::bitset<256>> live;             // per expanded node: registers live on entry
    std::string error;
};

struct DfProduct {
    DfSide a, b;
    std::vector<DfToken> tokens;
    std::map<std::string, int> token_ids;
    DfSets sets;
    std::vector<std::pair<int, int>> pnode;
    std::map<std::pair<int, int>, int> pindex;
    std::vector<std::vector<int>> ina, inb;
    std::vector<std::vector<int>> psucc;           // >=0 product node, -1 end, -2 spin, -3 unmatched
    std::vector<char> queued;
    std::string mismatch;
    std::map<int, int> up_ab, up_ba;
    std::set<std::pair<int, int>> paired;          // CFG-ID trace: (stock instr, candidate instr)
    std::set<int> explored_a, explored_b;
};

static int df_token(DfProduct& g, char kind, const std::string& value, int node, int k, char side) {
    std::string key(1, kind);
    key += "|" + value + "|" + std::to_string(node) + "|" + std::to_string(k) + "|" + std::string(1, side ? side : '-');
    auto it = g.token_ids.find(key);
    if (it != g.token_ids.end()) return it->second;
    DfToken t; t.kind = kind; t.value = value; t.node = node; t.k = k; t.side = side;
    const int id = (int)g.tokens.size();
    g.tokens.push_back(t);
    g.token_ids[key] = id;
    return id;
}

static int df_single(DfProduct& g, char kind, const std::string& value, int node, int k, char side = 0) {
    return g.sets.intern({df_token(g, kind, value, node, k, side)});
}

static void df_prune(const DfSide& s, int i, CfgIdentityEnv& env) {
    const CfgIdentityProto& proto = *s.model;
    const CfgIdentityNode& node = proto.nodes[(size_t)i];
    if (proto.live_in.empty() || node.floating) return;
    for (auto it = env.begin(); it != env.end();) {
        auto reg = proto.web_register.find(it->first);
        const bool live = (node.state_test && node.state_web == it->first)
            || (reg != proto.web_register.end() && reg->second < (int)proto.live_in[(size_t)i].size()
                && proto.live_in[(size_t)i][(size_t)reg->second]);
        it = live ? std::next(it) : env.erase(it);
    }
}

static bool df_expand(DfSide& s, size_t limit) {
    const int n = (int)s.ip->code.size();
    if (!n) return true;
    std::deque<int> queue;
    auto intern = [&](int i, CfgIdentityEnv env) -> int {
        df_prune(s, i, env);
        const std::pair<int, std::string> key{i, cfg_identity_env_key(env)};
        auto it = s.e_index.find(key);
        if (it != s.e_index.end()) return it->second;
        const int id = (int)s.e_instr.size();
        s.e_index[key] = id;
        s.e_instr.push_back(i);
        s.e_env.push_back(env);
        s.e_succ.emplace_back();
        queue.push_back(id);
        return id;
    };
    intern(0, CfgIdentityEnv());
    while (!queue.empty()) {
        if (s.e_instr.size() > limit) { s.error = "expansion over budget"; return false; }
        const int e = queue.front(); queue.pop_front();
        const int i = s.e_instr[(size_t)e];
        CfgIdentityEnv env = s.e_env[(size_t)e];
        const CfgIdentityNode& node = s.model->nodes[(size_t)i];
        std::vector<int> targets = node.base_succ;
        if (node.state_def) {
            env[node.state_web] = node.def_value;
        } else if (node.state_test && env.count(node.state_web) && targets.size() == 2) {
            targets = {targets[env[node.state_web] == node.test_value ? 0 : 1]};
        }
        std::vector<int> succ;
        for (int t : targets) succ.push_back(t >= 0 && t < n ? intern(t, env) : -1);
        s.e_succ[(size_t)e] = succ;
    }
    return true;
}

// Value materializations never synchronize the lockstep: S1 canonicalizes their order, and a LOADB
// with a skip is a LOAD plus an epsilon jump (stock `return x == nil` shares one RETURN behind a
// skipping LOADB, the rebuild may duplicate the RETURN behind two plain LOADBs).
static bool df_pure_class(const ir::IInsn& in) {
    return in.op == 0x12 || in.op == 0x4e || in.op == 0x04 || in.op == 0x2c || in.op == 0x4f || in.op == 0x46;
}

static bool df_sync(DfSide& s, int e) {
    signed char& known = s.sync[(size_t)e];
    if (known >= 0) return known != 0;
    const int i = s.e_instr[(size_t)e];
    bool result = false;
    if (!df_pure_class(s.ip->code[(size_t)i])) {
        CfgIdentityEnv env = s.e_env[(size_t)e];
        result = cfg_identity_resolve(*s.model, i, env) == i;
    }
    known = result ? 1 : 0;
    return result;
}

static bool df_is_arith_rr(uint8_t op) {
    return op == 0x49 || op == 0x07 || op == 0x22 || op == 0x1a || op == 0x55 || op == 0x45 || op == 0x00;
}

static void df_roles(DfSide& s) {
    const int n = (int)s.ip->code.size();
    s.f3_alt_of.assign((size_t)n, -1);
    s.f3_branch.assign((size_t)n, 0);
    for (int i = 0; i + 1 < n; ++i) {
        const ir::IInsn& br = s.ip->code[(size_t)i];
        if (br.op != 0x4b && br.op != 0x18) continue;
        const std::string& label = s.model->nodes[(size_t)i].label;
        if (label == "OR" || label == "AND" || label.compare(0, 4, "ORK ") == 0 || label.compare(0, 5, "ANDK ") == 0) {
            s.f3_branch[(size_t)i] = 1;
            s.f3_alt_of[(size_t)i + 1] = i;
        }
    }
}

// Applies instruction e to the origin state S. A def by a sync node is D<node>; any other def that is
// not a value/copy is side-local ('X', never equal to anything: fail closed).
static void df_transfer(DfProduct& g, DfSide& s, int e, std::vector<int>& S, int node_id, std::vector<int>* defined) {
    const ir::IProto& p = *s.ip;
    const int i = s.e_instr[(size_t)e];
    const ir::IInsn& in = p.code[(size_t)i];
    const CfgIdentityNode& node = s.model->nodes[(size_t)i];
    const int R = s.regs;
    auto set = [&](int r, int value) {
        if (r < 0 || r >= R) return;
        S[(size_t)r] = value;
        if (defined) defined->push_back(r);
    };
    auto def = [&](int r, int k) {
        set(r, node_id >= 0 ? df_single(g, 'D', "", node_id, k) : df_single(g, 'X', "", i, k, s.name));
    };
    if (s.f3_alt_of[(size_t)i] >= 0) return;      // folded F3 alternative: the OR node defines A
    switch (in.op) {
        case 0x14: set(in.A, in.B < R ? S[(size_t)in.B] : 0); return;
        case 0x0d: case 0x12: case 0x4e: case 0x04:
            // an emitter dispatch-state load is an S token: equal to the same constant at a read, but
            // not a program value in the live-value comparison
            set(in.A, df_single(g, node.state_def ? 'S' : 'K', cfg_identity_load_value(p, in), -1, 0)); return;
        case 0x46: set(in.A, df_single(g, 'K', "IMP:" + cfg_identity_const(p, in.Bx, false), -1, 0)); return;
        case 0x2c: case 0x4f: set(in.A, df_single(g, 'N', node.label, i, 0, s.name)); return;
        case 0x50:
            if (node.epsilon) set(in.A, in.B < R ? S[(size_t)in.B] : 0);     // N5: a test of the operand
            else def(in.A, 0);
            return;
        case 0x2d: {
            const int self = in.B < R ? S[(size_t)in.B] : 0;
            def(in.A, 0);
            set((int)in.A + 1, self);
            return;
        }
        case 0x54: case 0x4c: {
            const int count = in.op == 0x54 ? (int)in.C : (int)in.B;
            if (count == 0) {
                const int mr = node_id >= 0 ? df_single(g, 'D', "", node_id, DF_MULTRET)
                                            : df_single(g, 'X', "", i, DF_MULTRET, s.name);
                for (int r = in.A; r < R; ++r) set(r, mr);
                // TOP remembers where the open multret range starts (side-local, never compared)
                S[(size_t)R] = df_single(g, 'M', std::to_string((int)in.A), -1, 0, s.name);
            } else {
                for (int k = 0; k + 1 < count; ++k) def((int)in.A + k, k);
            }
            return;
        }
        case 0x4b: case 0x18:
            if (s.f3_branch[(size_t)i]) def(in.A, 0);
            return;
        case 0x0a: def((int)in.A + 2, 2); return;
        case 0x1e: {
            const int nvars = (int)(in.aux & 0xff);
            for (int r = (int)in.A + 2; r <= (int)in.A + 2 + nvars; ++r) def(r, r - (int)in.A);
            return;
        }
        default: break;
    }
    std::set<int> uses, defs;
    if (!lv::register_effects(p, in, uses, defs)) { if (s.error.empty()) s.error = "register effects unknown"; return; }
    for (int r : defs) def(r, r - (int)in.A);
}

static bool df_join_state(DfSets& sets, std::vector<int>& into, const std::vector<int>& from) {
    if (into.empty()) { into = from; return true; }
    bool changed = false;
    for (size_t r = 0; r < from.size(); ++r) {
        const int j = sets.join(into[r], from[r]);
        if (j != into[r]) { into[r] = j; changed = true; }
    }
    return changed;
}

struct DfWalk {
    std::map<int, std::vector<int>> reached;   // sync expanded node -> joined state on arrival
    bool end = false, closed = false;
    int writes = 0;                            // watch mode: origins written to the watched register
};

// From expanded node `start`, execute non-sync instructions in order until sync nodes are reached.
// With watch >= 0, paths stop at a CLOSEUPVALS covering the register and writes to it are collected.
static DfWalk df_walk(DfProduct& g, DfSide& s, int start, const std::vector<int>& state, int watch = -1) {
    DfWalk w;
    if (start < 0) { w.end = true; return w; }
    std::map<int, std::vector<int>> seen;
    std::deque<std::pair<int, std::vector<int>>> work;
    work.push_back({start, state});
    size_t steps = 0;
    while (!work.empty()) {
        if (++steps > 200000) { if (s.error.empty()) s.error = "walk budget"; break; }
        const int e = work.front().first;
        std::vector<int> S = work.front().second;
        work.pop_front();
        if (df_sync(s, e)) { df_join_state(g.sets, w.reached[e], S); continue; }
        const ir::IInsn& in = s.ip->code[(size_t)s.e_instr[(size_t)e]];
        if (watch >= 0 && in.op == 0x39 && in.A <= watch) { w.closed = true; continue; }
        auto it = seen.find(e);
        if (it == seen.end()) seen[e] = S;
        else {
            if (!df_join_state(g.sets, it->second, S)) continue;
            S = it->second;
        }
        std::vector<int> defined;
        df_transfer(g, s, e, S, -1, watch >= 0 ? &defined : nullptr);
        if (watch >= 0 && std::find(defined.begin(), defined.end(), watch) != defined.end())
            w.writes = g.sets.join(w.writes, S[(size_t)watch]);
        for (int t : s.e_succ[(size_t)e]) {
            if (t < 0) w.end = true;
            else work.push_back({t, S});
        }
    }
    return w;
}

// Does the child prototype (or a descendant it passes the upvalue to) write its upvalue `slot`?
static bool df_child_writes(const std::vector<ir::IProto>& module, int child, int slot, int depth) {
    if (child < 0 || child >= (int)module.size() || depth > 8) return true;     // unknown: keep REF
    const ir::IProto& p = module[(size_t)child];
    for (size_t i = 0; i < p.code.size(); ++i) {
        const ir::IInsn& in = p.code[i];
        if (in.op == 0x53 && in.B == slot) return true;
        if (in.op != 0x16 && in.op != 0x42) continue;
        int grandchild = -1;
        if (in.op == 0x16 && in.Bx < p.kids.size()) grandchild = (int)p.kids[in.Bx];
        if (in.op == 0x42 && in.Bx < p.consts.size() && p.consts[in.Bx].kind == ir::KKind::Closure)
            grandchild = (int)p.consts[in.Bx].sub;
        int ordinal = 0;
        for (size_t j = i + 1; j < p.code.size() && p.code[j].op == 0x35; ++j, ++ordinal)
            if (p.code[j].A == 2 && p.code[j].B == slot && df_child_writes(module, grandchild, ordinal, depth + 1))
                return true;
    }
    return false;
}

static int df_side_node(const DfProduct& g, const DfSide& s, int pid) {
    return &s == &g.a ? g.pnode[(size_t)pid].first : g.pnode[(size_t)pid].second;
}

static const std::vector<int>& df_side_in(const DfProduct& g, const DfSide& s, int pid) {
    return &s == &g.a ? g.ina[(size_t)pid] : g.inb[(size_t)pid];
}

// Origins written to register r on side s while an upvalue captured at product node `from` is open.
static int df_open_writes(DfProduct& g, DfSide& s, int from, int r) {
    int writes = 0;
    std::set<int> visited;
    std::vector<int> stack;
    auto edges = [&](int pid, std::vector<int> S) {
        const int e = df_side_node(g, s, pid);
        for (size_t q = 0; q < s.e_succ[(size_t)e].size(); ++q) {
            DfWalk w = df_walk(g, s, s.e_succ[(size_t)e][q], S, r);
            writes = g.sets.join(writes, w.writes);
            if (!w.reached.empty() && q < g.psucc[(size_t)pid].size() && g.psucc[(size_t)pid][q] >= 0)
                stack.push_back(g.psucc[(size_t)pid][q]);
        }
    };
    {
        std::vector<int> S = df_side_in(g, s, from);
        df_transfer(g, s, df_side_node(g, s, from), S, from, nullptr);
        edges(from, S);
    }
    while (!stack.empty()) {
        const int pid = stack.back(); stack.pop_back();
        if (!visited.insert(pid).second) continue;
        const int e = df_side_node(g, s, pid);
        const ir::IInsn& in = s.ip->code[(size_t)s.e_instr[(size_t)e]];
        if (in.op == 0x29 || (in.op == 0x39 && in.A <= r)) continue;
        std::vector<int> S = df_side_in(g, s, pid);
        if (S.empty()) continue;
        std::vector<int> defined;
        df_transfer(g, s, e, S, pid, &defined);
        if (std::find(defined.begin(), defined.end(), r) != defined.end()) writes = g.sets.join(writes, S[(size_t)r]);
        edges(pid, S);
    }
    return writes;
}

static DfRecord df_record(DfProduct& g, DfSide& s, int pid) {
    const int e = df_side_node(g, s, pid);
    const int i = s.e_instr[(size_t)e];
    const ir::IProto& p = *s.ip;
    const ir::IInsn& in = p.code[(size_t)i];
    const CfgIdentityNode& node = s.model->nodes[(size_t)i];
    const std::vector<int>& S = df_side_in(g, s, pid);
    const int R = s.regs;
    DfRecord rec;
    auto reg = [&](int r, const std::string& tag = "") {
        DfSlot slot; slot.tag = tag; slot.set = (r >= 0 && r < R) ? S[(size_t)r] : 0;
        rec.slots.push_back(slot);
    };
    auto multret_tail = [&](int first) {
        const std::vector<int>& top = g.sets.sets[(size_t)S[(size_t)R]];
        int base = -1;
        for (int t : top) {
            const int b = std::atoi(g.tokens[(size_t)t].value.c_str());
            if (base >= 0 && b != base) { base = -2; break; }
            base = b;
        }
        if (top.empty() || base < first) {
            if (s.error.empty()) s.error = "multret base unresolved at " + std::to_string(i);
            return;
        }
        for (int r = first; r < base; ++r) reg(r);
        DfSlot slot; slot.tag = "MR"; slot.set = base < R ? S[(size_t)base] : 0;
        rec.slots.push_back(slot);
    };
    const std::string& label = node.label;
    switch (in.op) {
        case 0x01: reg(in.B); reg(in.C); break;
        case 0x2a: reg(in.A); reg(in.B); reg(in.C); break;
        case 0x44: case 0x3d: case 0x2d: reg(in.B); break;
        case 0x2e: case 0x15: reg(in.A); reg(in.B); break;
        case 0x02: case 0x53: reg(in.A); break;
        case 0x54:
            if (in.B) for (int r = in.A; r < (int)in.A + (int)in.B; ++r) reg(r);
            else multret_tail(in.A);
            break;
        case 0x29:
            if (in.B) for (int r = in.A; r + 1 < (int)in.A + (int)in.B; ++r) reg(r);
            else multret_tail(in.A);
            break;
        case 0x3f:
            reg(in.A);
            if (in.C) for (int r = in.B; r + 1 < (int)in.B + (int)in.C; ++r) reg(r);
            else multret_tail(in.B);
            break;
        case 0x0e: case 0x50: case 0x4d: reg(in.B); break;
        case 0x28: for (int r = in.B; r <= (int)in.C; ++r) reg(r); break;
        case 0x2b: case 0x2f: reg(in.B); reg(in.C); break;
        case 0x38: case 0x3e: case 0x09: case 0x32: case 0x3c: case 0x08: case 0x24: case 0x31: case 0x51:
            reg(in.B); break;
        case 0x06: case 0x3b: reg(in.C); break;
        case 0x4b: case 0x18:
            reg(in.A);
            if (s.f3_branch[(size_t)i] && (label == "OR" || label == "AND") && i + 1 < (int)p.code.size())
                reg(p.code[(size_t)i + 1].B);
            break;
        case 0x37: case 0x27:
            if (label.compare(0, 7, "IF EQK ") == 0) {
                reg(node.test_at == i ? node.test_reg : (int)p.code[(size_t)node.test_at].A);
            } else {
                reg(in.A); reg((int)(in.aux & 0xff));
                rec.unordered_pair = true;
            }
            break;
        case 0x21: case 0x1c: case 0x23: case 0x33: reg(in.A); reg((int)(in.aux & 0xff)); break;
        case 0x20: case 0x41: case 0x3a: case 0x34: reg(in.A); break;
        case 0x47: case 0x0a: case 0x30: case 0x1b: case 0x0b: case 0x1e:
            reg(in.A); reg((int)in.A + 1); reg((int)in.A + 2); break;
        case 0x16: case 0x42: {
            std::vector<int> out = S;
            df_transfer(g, s, e, out, pid, nullptr);
            int child = -1;
            if (in.op == 0x16 && in.Bx < p.kids.size()) child = (int)p.kids[in.Bx];
            if (in.op == 0x42 && in.Bx < p.consts.size() && p.consts[in.Bx].kind == ir::KKind::Closure)
                child = (int)p.consts[in.Bx].sub;
            rec.child = child;
            int ordinal = 0;
            for (size_t j = (size_t)i + 1; j < p.code.size() && p.code[j].op == 0x35; ++j, ++ordinal) {
                const ir::IInsn& cap = p.code[j];
                // a capture the child never reads or writes in reachable code is unobservable (stock
                // keeps captures that only dead code after an unconditional return uses)
                if (s.used_upvalues && child >= 0 && child < (int)s.used_upvalues->size()
                    && !(*s.used_upvalues)[(size_t)child].count(ordinal))
                    continue;
                DfSlot slot;
                slot.ordinal = ordinal;
                if (cap.A == 2) { slot.tag = "CAP UPVAL"; slot.upval = cap.B; rec.slots.push_back(slot); continue; }
                slot.set = cap.B < R ? out[(size_t)cap.B] : 0;
                slot.tag = "CAP VAL";
                if (cap.A == 1) {
                    const int writes = df_open_writes(g, s, pid, cap.B);
                    if (writes != 0 || df_child_writes(*s.module, child, ordinal, 0)) {
                        slot.tag = "CAP REF"; slot.writes = writes;
                    }
                }
                rec.slots.push_back(slot);
            }
            break;
        }
        default:
            if (df_is_arith_rr(in.op)) {
                const char* name = cfg_identity_arith_name(in.op);
                const std::string rk = std::string(name) + "RK ", k = std::string(name) + "K ";
                if (label.compare(0, rk.size(), rk) == 0) reg(in.C);
                else if (label.compare(0, k.size(), k) == 0) reg(in.B);
                else { reg(in.B); reg(in.C); }
            }
            break;
    }
    return rec;
}

static bool df_side_setup(DfSide& s) {
    const CfgIdentityProto& model = *s.model;
    if (!model.failure.empty()) { s.error = "cfg model: " + model.failure; return false; }
    if (model.live_in.empty() && !s.ip->code.empty()) { s.error = "register effects unknown"; return false; }
    s.regs = std::max(1, s.ip->maxstack);
    df_roles(s);
    if (!df_expand(s, 400000)) return false;
    s.sync.assign(s.e_instr.size(), -1);
    // Liveness over the expanded graph (dispatch-environment sensitive, so an infeasible emitter
    // state path keeps nothing alive). A folded F3 reads its alternative's operand and defines A.
    const size_t E = s.e_instr.size();
    std::vector<std::bitset<256>> uses(E), defs(E);
    std::vector<std::vector<int>> preds(E);
    for (size_t e = 0; e < E; ++e) {
        const int i = s.e_instr[e];
        const ir::IInsn& in = s.ip->code[(size_t)i];
        std::set<int> u, d;
        if (s.f3_branch[(size_t)i]) {
            u.insert(in.A); d.insert(in.A);
            const ir::IInsn& alt = s.ip->code[(size_t)i + 1];
            if (alt.op == 0x14) u.insert(alt.B);
        } else if (!lv::register_effects(*s.ip, in, u, d)) { s.error = "register effects unknown"; return false; }
        // A truthiness test CFG-ID folds as unobservable (S3: both arms reach the same node, e.g. a
        // stock empty `if p then end`) reads nothing that matters: it must not keep a value alive.
        if ((in.op == 0x4b || in.op == 0x18) && !s.f3_branch[(size_t)i] && !df_sync(s, (int)e)) u.clear();
        for (int r : u) if (r >= 0 && r < 256) uses[e].set((size_t)r);
        for (int r : d) if (r >= 0 && r < 256) defs[e].set((size_t)r);
        for (int t : s.e_succ[e]) if (t >= 0) preds[(size_t)t].push_back((int)e);
    }
    s.live.assign(E, std::bitset<256>());
    std::deque<int> work;
    std::vector<char> queued(E, 1);
    for (size_t e = E; e-- > 0;) work.push_back((int)e);
    while (!work.empty()) {
        const int e = work.front(); work.pop_front(); queued[(size_t)e] = 0;
        std::bitset<256> out;
        for (int t : s.e_succ[(size_t)e]) if (t >= 0) out |= s.live[(size_t)t];
        const std::bitset<256> in = uses[(size_t)e] | (out & ~defs[(size_t)e]);
        if (in == s.live[(size_t)e]) continue;
        s.live[(size_t)e] = in;
        for (int p : preds[(size_t)e]) if (!queued[(size_t)p]) { queued[(size_t)p] = 1; work.push_back(p); }
    }
    return true;
}

static std::vector<int> df_entry_state(DfProduct& g, const DfSide& s) {
    std::vector<int> entry((size_t)s.regs + 1, 0);
    for (int r = 0; r < s.regs; ++r)
        entry[(size_t)r] = r < s.ip->nparams ? df_single(g, 'P', "", -1, r) : df_single(g, 'U', "", -1, 0);
    return entry;
}

static bool df_labels_match(DfProduct& g, int ea, int eb, std::string& why) {
    const CfgIdentityNode& p = g.a.model->nodes[(size_t)g.a.e_instr[(size_t)ea]];
    const CfgIdentityNode& q = g.b.model->nodes[(size_t)g.b.e_instr[(size_t)eb]];
    bool upvalue = false;
    for (const char* prefix : {"GETUPVAL u", "SETUPVAL u"}) {
        if (p.label.compare(0, 10, prefix) != 0 || q.label.compare(0, 10, prefix) != 0) continue;
        const int ua = std::atoi(p.label.c_str() + 10), ub = std::atoi(q.label.c_str() + 10);
        auto fa = g.up_ab.find(ua); auto fb = g.up_ba.find(ub);
        if ((fa != g.up_ab.end() && fa->second != ub) || (fb != g.up_ba.end() && fb->second != ua)) {
            why = "UPVALUE " + p.label + " -> " + q.label; return false;
        }
        g.up_ab[ua] = ub; g.up_ba[ub] = ua;
        upvalue = true;
    }
    if (!upvalue && p.label != q.label) { why = "LABEL " + p.label + " -> " + q.label; return false; }
    if (g.a.e_succ[(size_t)ea].size() != g.b.e_succ[(size_t)eb].size()) { why = "ARITY " + p.label; return false; }
    return true;
}

// Pairs the sync nodes two walks reach. Returns a product node, -1 (both end), -2 (both spin) or -3.
static int df_pair(DfProduct& g, const DfWalk& wa, const DfWalk& wb, std::deque<int>& work) {
    auto shape = [](const DfWalk& w) {
        if (w.reached.size() > 1 || (!w.reached.empty() && w.end)) return -3;
        if (w.reached.size() == 1) return 0;
        return w.end ? -1 : -2;
    };
    const int sa = shape(wa), sb = shape(wb);
    if (sa == -3 || sb == -3) { if (g.mismatch.empty()) g.mismatch = "walk reaches two sync nodes"; return -3; }
    if (sa != sb) { if (g.mismatch.empty()) g.mismatch = "END/SPIN shape differs"; return -3; }
    if (sa < 0) return sa;
    const int ea = wa.reached.begin()->first, eb = wb.reached.begin()->first;
    int pid;
    auto it = g.pindex.find({ea, eb});
    if (it != g.pindex.end()) pid = it->second;
    else {
        std::string why;
        if (!df_labels_match(g, ea, eb, why)) {
            if (g.mismatch.empty())
                g.mismatch = why + " at stock[" + std::to_string(g.a.e_instr[(size_t)ea]) + "] candidate["
                           + std::to_string(g.b.e_instr[(size_t)eb]) + "]";
            return -3;
        }
        pid = (int)g.pnode.size();
        g.pindex[{ea, eb}] = pid;
        g.pnode.push_back({ea, eb});
        g.ina.emplace_back(); g.inb.emplace_back(); g.psucc.emplace_back(); g.queued.push_back(1);
        work.push_back(pid);
    }
    const bool ca = df_join_state(g.sets, g.ina[(size_t)pid], wa.reached.begin()->second);
    const bool cb = df_join_state(g.sets, g.inb[(size_t)pid], wb.reached.begin()->second);
    if ((ca || cb) && !g.queued[(size_t)pid]) { g.queued[(size_t)pid] = 1; work.push_back(pid); }
    return pid;
}

static bool df_build(DfProduct& g, size_t limit) {
    std::deque<int> work;
    if (g.a.e_instr.empty() || g.b.e_instr.empty()) {
        if (g.a.e_instr.size() != g.b.e_instr.size()) g.mismatch = "empty prototype on one side";
        return true;
    }
    {
        const DfWalk wa = df_walk(g, g.a, 0, df_entry_state(g, g.a));
        const DfWalk wb = df_walk(g, g.b, 0, df_entry_state(g, g.b));
        df_pair(g, wa, wb, work);
    }
    size_t steps = 0;
    while (!work.empty()) {
        if (++steps > 4000000 || g.pnode.size() > limit) { g.a.error = "product budget"; return false; }
        if (!g.a.error.empty() || !g.b.error.empty()) return false;
        const int pid = work.front(); work.pop_front();
        g.queued[(size_t)pid] = 0;
        const int ea = g.pnode[(size_t)pid].first, eb = g.pnode[(size_t)pid].second;
        std::vector<int> Sa = g.ina[(size_t)pid], Sb = g.inb[(size_t)pid];
        df_transfer(g, g.a, ea, Sa, pid, nullptr);
        df_transfer(g, g.b, eb, Sb, pid, nullptr);
        const size_t k = g.a.e_succ[(size_t)ea].size();
        std::vector<int> succ(k, -3);
        for (size_t q = 0; q < k; ++q) {
            const DfWalk wa = df_walk(g, g.a, g.a.e_succ[(size_t)ea][q], Sa);
            const DfWalk wb = df_walk(g, g.b, g.b.e_succ[(size_t)eb][q], Sb);
            succ[q] = df_pair(g, wa, wb, work);
        }
        g.psucc[(size_t)pid] = succ;
    }
    return g.a.error.empty() && g.b.error.empty();
}

static std::string df_token_text(const DfProduct& g, int t) {
    const DfToken& token = g.tokens[(size_t)t];
    switch (token.kind) {
        case 'K': return "K:" + cfg_identity_escape(token.value);
        case 'P': return "P" + std::to_string(token.k);
        case 'U': return "U";
        case 'N': return std::string("N") + token.side + std::to_string(token.node) + "<" + cfg_identity_escape(token.value) + ">";
        case 'X': return std::string("X") + token.side + std::to_string(token.node) + "#" + std::to_string(token.k);
        case 'M': return "M";
        case 'S': return "S:" + cfg_identity_escape(token.value);
        default: {
            const int ea = g.pnode[(size_t)token.node].first;
            const std::string label = cfg_identity_escape(g.a.model->nodes[(size_t)g.a.e_instr[(size_t)ea]].label);
            return "D" + std::to_string(token.node) + "<" + label + ">#"
                 + (token.k == DF_MULTRET ? std::string("*") : std::to_string(token.k));
        }
    }
}

static std::string df_set_text(const DfProduct& g, int set) {
    std::string out = "{";
    for (int t : g.sets.sets[(size_t)set]) out += (out.size() > 1 ? "," : "") + df_token_text(g, t);
    return out + "}";
}

static std::string df_token_kind(const DfProduct& g, int t) {
    const DfToken& token = g.tokens[(size_t)t];
    switch (token.kind) {
        case 'K': return token.value == "nil" ? "NIL" : "K";
        case 'P': return "PARAM";
        case 'U': return "UNDEF";
        case 'N': return "N:" + cfg_identity_op_class(token.value);
        case 'X': return "X";
        case 'M': return "M";
        case 'S': return "STATE";
        default: {
            const int ea = g.pnode[(size_t)token.node].first;
            return "D:" + cfg_identity_op_class(g.a.model->nodes[(size_t)g.a.e_instr[(size_t)ea]].label);
        }
    }
}

static bool df_related(const DfProduct& g, int ta, int tb) {
    if (ta == tb) return g.tokens[(size_t)ta].kind != 'X';
    const DfToken& x = g.tokens[(size_t)ta];
    const DfToken& y = g.tokens[(size_t)tb];
    if ((x.kind == 'S' || x.kind == 'K') && (y.kind == 'S' || y.kind == 'K')) return x.value == y.value;
    return x.kind == 'N' && y.kind == 'N' && x.side == 'a' && y.side == 'b' && g.paired.count({x.node, y.node}) != 0;
}

// 0 equal, 1 decisive difference, 2 undecided (a table origin CFG-ID never paired).
static int df_set_compare(const DfProduct& g, int sa, int sb, std::set<std::string>& extra, std::set<std::string>& missing) {
    int result = 0;
    const std::vector<int>& A = g.sets.sets[(size_t)sa];
    const std::vector<int>& B = g.sets.sets[(size_t)sb];
    auto undecided = [&](const DfToken& t) {
        return t.kind == 'N' && !(t.side == 'a' ? g.explored_a : g.explored_b).count(t.node);
    };
    for (int ta : A) {
        bool found = false;
        for (int tb : B) if (df_related(g, ta, tb)) { found = true; break; }
        if (found) continue;
        if (undecided(g.tokens[(size_t)ta])) { if (result != 1) result = 2; continue; }
        missing.insert(df_token_kind(g, ta)); result = 1;
    }
    for (int tb : B) {
        bool found = false;
        for (int ta : A) if (df_related(g, ta, tb)) { found = true; break; }
        if (found) continue;
        if (undecided(g.tokens[(size_t)tb])) { if (result != 1) result = 2; continue; }
        extra.insert(df_token_kind(g, tb)); result = 1;
    }
    return result;
}

static int df_slot_compare(DfProduct& g, const DfSlot& x, const DfSlot& y, std::string& kind,
                           std::set<std::string>& extra, std::set<std::string>& missing) {
    if (x.tag != y.tag) { kind = "TAG " + x.tag + "->" + y.tag; return 1; }
    if (x.tag == "CAP UPVAL") {
        auto fa = g.up_ab.find(x.upval); auto fb = g.up_ba.find(y.upval);
        if ((fa != g.up_ab.end() && fa->second != y.upval) || (fb != g.up_ba.end() && fb->second != x.upval)) {
            kind = "UPVAL"; return 1;
        }
        g.up_ab[x.upval] = y.upval; g.up_ba[y.upval] = x.upval;
        return 0;
    }
    int r = df_set_compare(g, x.set, y.set, extra, missing);
    if (x.tag == "CAP REF") {
        std::set<std::string> e2, m2;
        const int w = df_set_compare(g, x.writes, y.writes, e2, m2);
        if (w == 1) {
            if (r != 1) kind = "REFWRITES";
            for (const auto& item : e2) extra.insert("W" + item);
            for (const auto& item : m2) missing.insert("W" + item);
        }
        r = (r == 1 || w == 1) ? 1 : std::max(r, w);
    }
    if (r == 1 && kind.empty()) kind = x.tag.empty() ? "VALUE" : x.tag;
    return r;
}

// Live dynamic values at a product node on one side: the origin sets of the registers live at the
// sync node (dispatch-environment liveness), without emitter state tokens. A lone materialization
// (one constant or one table) is skipped because S1 may legitimately float it past this point on the
// other side; a lone undefined entry value is skipped (a read of it is reported at the read).
static std::vector<int> df_live_sets(DfProduct& g, DfSide& s, int pid) {
    const int e = df_side_node(g, s, pid);
    const std::vector<int>& S = df_side_in(g, s, pid);
    std::set<int> out;
    for (int r = 0; r < s.regs && r < 256; ++r) {
        if (!s.live[(size_t)e].test((size_t)r)) continue;
        std::vector<int> v;
        for (int t : g.sets.sets[(size_t)S[(size_t)r]]) if (g.tokens[(size_t)t].kind != 'S') v.push_back(t);
        if (v.empty()) continue;
        if (v.size() == 1) {
            const char k = g.tokens[(size_t)v[0]].kind;
            if (k == 'K' || k == 'N' || k == 'U') continue;
        }
        out.insert(g.sets.intern(v));
    }
    return std::vector<int>(out.begin(), out.end());
}

static std::string df_set_kinds(const DfProduct& g, int set) {
    std::set<std::string> kinds;
    for (int t : g.sets.sets[(size_t)set]) kinds.insert(df_token_kind(g, t));
    std::string out;
    for (const auto& k : kinds) out += (out.empty() ? "" : "|") + k;
    return out;
}

// 0 equal, 1 different, 2 undecided. `extra`/`missing` describe unmatched candidate/stock sets.
static int df_live_compare(DfProduct& g, int pid, std::string& extra, std::string& missing,
                           std::string& extra_text, std::string& missing_text) {
    const std::vector<int> A = df_live_sets(g, g.a, pid), B = df_live_sets(g, g.b, pid);
    int result = 0;
    std::set<std::string> ex, mi;
    auto match = [&](int x, int y) {
        std::set<std::string> e, m;
        return df_set_compare(g, x, y, e, m);
    };
    for (int x : A) {
        int best = 1;
        for (int y : B) { const int r = match(x, y); if (r == 0) { best = 0; break; } if (r == 2) best = 2; }
        if (best == 0) continue;
        if (best == 2) { if (result != 1) result = 2; continue; }
        result = 1; mi.insert(df_set_kinds(g, x));
        missing_text += df_set_text(g, x);
    }
    for (int y : B) {
        int best = 1;
        for (int x : A) { const int r = match(x, y); if (r == 0) { best = 0; break; } if (r == 2) best = 2; }
        if (best == 0) continue;
        if (best == 2) { if (result != 1) result = 2; continue; }
        result = 1; ex.insert(df_set_kinds(g, y));
        extra_text += df_set_text(g, y);
    }
    for (const auto& k : ex) extra += (extra.empty() ? "" : ",") + k;
    for (const auto& k : mi) missing += (missing.empty() ? "" : ",") + k;
    return result;
}

// Non-mutating slot equality probe (used to pair capture slots the child never reads).
static bool df_slot_probe(const DfProduct& g, const DfSlot& x, const DfSlot& y) {
    if (x.tag != y.tag) return false;
    if (x.tag == "CAP UPVAL") {
        auto fa = g.up_ab.find(x.upval); auto fb = g.up_ba.find(y.upval);
        return !((fa != g.up_ab.end() && fa->second != y.upval) || (fb != g.up_ba.end() && fb->second != x.upval));
    }
    std::set<std::string> e, m;
    if (df_set_compare(g, x.set, y.set, e, m) == 1) return false;
    return x.tag != "CAP REF" || df_set_compare(g, x.writes, y.writes, e, m) != 1;
}

// Upvalue indices each prototype reads, writes or passes on (CAPTURE UPVAL) in code reachable from
// its entry.
static std::vector<std::set<int>> df_used_upvalues(const std::vector<ir::IProto>& module) {
    std::vector<std::set<int>> out(module.size());
    for (size_t index = 0; index < module.size(); ++index) {
        const ir::IProto& p = module[index];
        const int n = (int)p.code.size();
        std::vector<char> seen((size_t)n, 0);
        std::vector<int> stack;
        if (n) stack.push_back(0);
        while (!stack.empty()) {
            const int i = stack.back(); stack.pop_back();
            if (i < 0 || i >= n || seen[(size_t)i]) continue;
            seen[(size_t)i] = 1;
            const ir::IInsn& in = p.code[(size_t)i];
            if (in.op == 0x13 || in.op == 0x53) out[index].insert(in.B);
            if (in.op == 0x35 && in.A == 2) out[index].insert(in.B);
            if (in.op == 0x29) continue;
            if (in.op == 0x40 || in.op == 0x25 || in.op == 0x30 || in.op == 0x1b || in.op == 0x0b) { stack.push_back(in.target); continue; }
            if (in.branch) stack.push_back(in.target);
            stack.push_back(in.op == 0x04 && in.C ? i + 1 + in.C : i + 1);
        }
    }
    return out;
}

// Capture slot k of a CLOSURE is the child's upvalue k, and CFG-ID compares a child's upvalues up to
// a bijection (the numbering is the compiler's choice). Candidate slots are reordered by the child's
// bijection; slots the child never reads (no mapping) are paired with an equal slot when one exists.
static std::vector<DfSlot> df_capture_order(const DfProduct& g, const DfRecord& x, const DfRecord& y,
                                            const std::map<int, int>* bijection) {
    const size_t n = y.slots.size();
    std::vector<int> perm(n, -1);
    std::vector<char> used(n, 0);
    if (bijection)
        for (size_t q = 0; q < n; ++q) {
            auto it = bijection->find(x.slots[q].ordinal);
            if (it == bijection->end()) continue;
            for (size_t j = 0; j < n; ++j)
                if (!used[j] && y.slots[j].ordinal == it->second) { perm[q] = (int)j; used[j] = 1; break; }
        }
    for (size_t q = 0; q < n; ++q) {
        if (perm[q] >= 0) continue;
        for (size_t j = 0; j < n; ++j)
            if (!used[j] && df_slot_probe(g, x.slots[q], y.slots[j])) { perm[q] = (int)j; used[j] = 1; break; }
    }
    for (size_t q = 0; q < n; ++q) {
        if (perm[q] >= 0) continue;
        for (size_t j = 0; j < n; ++j) if (!used[j]) { perm[q] = (int)j; used[j] = 1; break; }
    }
    std::vector<DfSlot> out;
    for (size_t q = 0; q < n; ++q) out.push_back(y.slots[(size_t)perm[q]]);
    return out;
}

struct DfProtoResult {
    std::string verdict;        // EQUAL DIFF UNPAIRED MODEL_ERROR
    std::string detail, cls;
    size_t nodes = 0, slots = 0, diff_slots = 0, live_diffs = 0;
};

static DfProtoResult df_compare_proto(const ir::IProto& pa, const CfgIdentityProto& ma, const std::vector<ir::IProto>& moda,
                                      const ir::IProto& pb, const CfgIdentityProto& mb, const std::vector<ir::IProto>& modb,
                                      bool dump, const std::vector<std::map<int, int>>& child_upvalues,
                                      const std::vector<std::set<int>>* used_a, const std::vector<std::set<int>>* used_b) {
    DfProtoResult res;
    if (!ma.failure.empty() || !mb.failure.empty()) {
        res.verdict = "MODEL_ERROR"; res.detail = "cfg model: " + ma.failure + "|" + mb.failure; res.cls = "MODEL_ERROR cfg model";
        return res;
    }
    CfgIdentityMismatch why;
    bool exhausted = false;
    CfgIdentityTrace trace;
    const bool cfg_equal = cfg_identity_equal(ma, mb, why, 400000, exhausted, &trace);
    DfProduct g;
    g.a.ip = &pa; g.a.model = &ma; g.a.module = &moda; g.a.name = 'a';
    g.b.ip = &pb; g.b.model = &mb; g.b.module = &modb; g.b.name = 'b';
    g.a.used_upvalues = used_a; g.b.used_upvalues = used_b;
    for (const auto& pair : trace.pairs) {
        g.paired.insert({pair.x, pair.y});
        g.explored_a.insert(pair.x); g.explored_b.insert(pair.y);
    }
    for (const auto& item : trace.upvalues) { g.up_ab[item.first] = item.second; g.up_ba[item.second] = item.first; }
    if (!df_side_setup(g.a) || !df_side_setup(g.b) || !df_build(g, 400000)) {
        res.verdict = "MODEL_ERROR";
        res.detail = "stock: " + g.a.error + " | candidate: " + g.b.error;
        res.cls = "MODEL_ERROR " + (!g.a.error.empty() ? g.a.error : g.b.error);
        return res;
    }
    res.nodes = g.pnode.size();
    std::vector<DfRecord> ra, rb;
    for (size_t pid = 0; pid < g.pnode.size(); ++pid) {
        ra.push_back(df_record(g, g.a, (int)pid));
        rb.push_back(df_record(g, g.b, (int)pid));
    }
    if (!g.a.error.empty() || !g.b.error.empty()) {
        res.verdict = "MODEL_ERROR";
        res.detail = "stock: " + g.a.error + " | candidate: " + g.b.error;
        res.cls = "MODEL_ERROR " + (!g.a.error.empty() ? g.a.error : g.b.error);
        return res;
    }
    if (dump) {
        std::printf("DFMODEL product nodes=%zu mismatch=\"%s\" cfg_equal=%d\n", g.pnode.size(), g.mismatch.c_str(), cfg_equal);
        for (size_t pid = 0; pid < g.pnode.size(); ++pid) {
            for (int side = 0; side < 2; ++side) {
                const DfSide& s = side ? g.b : g.a;
                const DfRecord& rec = side ? rb[pid] : ra[pid];
                const int e = side ? g.pnode[pid].second : g.pnode[pid].first;
                const int i = s.e_instr[(size_t)e];
                std::printf("  p%-4zu %s [%4d] %-34s", pid, side ? "cand " : "stock", i,
                            cfg_identity_escape(s.model->nodes[(size_t)i].label).c_str());
                for (const DfSlot& slot : rec.slots) {
                    std::printf(" | %s%s", slot.tag.empty() ? "" : (slot.tag + " ").c_str(),
                                slot.tag == "CAP UPVAL" ? ("u" + std::to_string(slot.upval)).c_str()
                                                        : df_set_text(g, slot.set).c_str());
                    if (slot.writes >= 0) std::printf(" W%s", df_set_text(g, slot.writes).c_str());
                }
                std::printf("\n");
            }
        }
    }
    // The reported difference is the first SLOT difference (which value an operation reads) when there
    // is one; a live-value difference is reported only for prototypes without a slot difference.
    bool undecided = false, diff = false, live_found = false;
    size_t slot_nodes = 0, live_nodes = 0;
    std::string live_cls, live_detail;
    for (size_t pid = 0; pid < g.pnode.size(); ++pid) {
        const DfRecord& x = ra[pid];
        DfRecord y = rb[pid];
        if (x.child >= 0 && x.child == y.child && x.slots.size() == y.slots.size())
            y.slots = df_capture_order(g, x, y, x.child < (int)child_upvalues.size() ? &child_upvalues[(size_t)x.child] : nullptr);
        std::string kind;
        std::set<std::string> extra, missing;
        int slot_index = -1, outcome = 0;
        if (x.slots.size() != y.slots.size()) {
            kind = "SLOT_COUNT " + std::to_string(x.slots.size()) + "->" + std::to_string(y.slots.size());
            outcome = 1;
        } else if (x.unordered_pair && y.unordered_pair && x.slots.size() == 2) {
            res.slots += 2;
            std::string k1, k3;
            std::set<std::string> e1, m1, e3, m3;
            int straight = std::max(df_slot_compare(g, x.slots[0], y.slots[0], k1, e1, m1),
                                    df_slot_compare(g, x.slots[1], y.slots[1], k1, e1, m1));
            if (straight != 0) {
                const int crossed = std::max(df_slot_compare(g, x.slots[0], y.slots[1], k3, e3, m3),
                                             df_slot_compare(g, x.slots[1], y.slots[0], k3, e3, m3));
                if (crossed < straight) straight = crossed;
            }
            if (straight == 1) { kind = k1; extra = e1; missing = m1; slot_index = 0; ++res.diff_slots; }
            outcome = straight;
        } else {
            for (size_t q = 0; q < x.slots.size(); ++q) {
                ++res.slots;
                std::string k;
                std::set<std::string> e, m;
                const int r = df_slot_compare(g, x.slots[q], y.slots[q], k, e, m);
                if (r == 2) undecided = true;
                if (r == 1) {
                    ++res.diff_slots;
                    if (outcome != 1) { kind = k; extra = e; missing = m; slot_index = (int)q; }
                    outcome = 1;
                }
            }
        }
        std::string live_extra, live_missing, live_extra_text, live_missing_text;
        bool live_diff = false;
        if (outcome != 1) {
            const int live = df_live_compare(g, (int)pid, live_extra, live_missing, live_extra_text, live_missing_text);
            if (live == 2) undecided = true;
            if (live == 1) { live_diff = true; outcome = 1; ++res.live_diffs; }
        }
        if (outcome == 2) undecided = true;
        if (outcome != 1) continue;
        if (live_diff) {
            ++live_nodes;
            if (live_found) continue;
            live_found = true;
            const int ia = g.a.e_instr[(size_t)g.pnode[pid].first], ib = g.b.e_instr[(size_t)g.pnode[pid].second];
            live_cls = "LIVE " + cfg_identity_op_class(ma.nodes[(size_t)ia].label)
                     + (live_extra.empty() ? "" : " +" + live_extra) + (live_missing.empty() ? "" : " -" + live_missing);
            live_detail = "p" + std::to_string(pid) + " stock[" + std::to_string(ia) + "]=\"" + cfg_identity_escape(ma.nodes[(size_t)ia].label)
                        + "\" candidate[" + std::to_string(ib) + "]=\"" + cfg_identity_escape(mb.nodes[(size_t)ib].label)
                        + "\" kind=LIVE stock_only=" + live_missing_text + " candidate_only=" + live_extra_text;
            continue;
        }
        ++slot_nodes;
        if (diff) continue;
        diff = true;
        const int ia = g.a.e_instr[(size_t)g.pnode[pid].first], ib = g.b.e_instr[(size_t)g.pnode[pid].second];
        std::string ex, mi;
        for (const auto& item : extra) ex += (ex.empty() ? "" : ",") + item;
        for (const auto& item : missing) mi += (mi.empty() ? "" : ",") + item;
        res.cls = cfg_identity_op_class(ma.nodes[(size_t)ia].label) + " " + kind + (ex.empty() ? "" : " +" + ex)
                + (mi.empty() ? "" : " -" + mi);
        res.detail = "p" + std::to_string(pid) + " stock[" + std::to_string(ia) + "]=\"" + cfg_identity_escape(ma.nodes[(size_t)ia].label)
                   + "\" candidate[" + std::to_string(ib) + "]=\"" + cfg_identity_escape(mb.nodes[(size_t)ib].label)
                   + "\" slot=" + std::to_string(slot_index) + " kind=" + kind;
        if (slot_index >= 0 && slot_index < (int)x.slots.size()) {
            const DfSlot& sx = x.slots[(size_t)slot_index];
            const DfSlot& sy = y.slots[(size_t)slot_index];
            res.detail += " stock=" + df_set_text(g, sx.set) + " candidate=" + df_set_text(g, sy.set);
            if (sx.writes >= 0 || sy.writes >= 0)
                res.detail += " stock_writes=" + (sx.writes >= 0 ? df_set_text(g, sx.writes) : std::string("-"))
                            + " candidate_writes=" + (sy.writes >= 0 ? df_set_text(g, sy.writes) : std::string("-"));
        }
    }
    if (!diff && live_found) { diff = true; res.cls = live_cls; res.detail = live_detail; }
    if (diff) {
        res.verdict = "DIFF";
        res.detail += " slot_diff_nodes=" + std::to_string(slot_nodes) + " live_diff_nodes=" + std::to_string(live_nodes);
        return res;
    }
    if (!g.mismatch.empty()) {
        if (cfg_equal) {          // CFG-ID matched everything, the lockstep did not: a gap in this model
            res.verdict = "MODEL_ERROR"; res.cls = "MODEL_ERROR lockstep"; res.detail = "lockstep: " + g.mismatch;
            return res;
        }
        res.verdict = "UNPAIRED"; res.cls = "UNPAIRED lockstep"; res.detail = g.mismatch;
        return res;
    }
    if (undecided) { res.verdict = "UNPAIRED"; res.cls = "UNPAIRED table origin"; return res; }
    res.verdict = "EQUAL";
    return res;
}

static bool df_load(const std::string& path, bool u44, std::vector<ir::IProto>& protos,
                    std::vector<CfgIdentityProto>& models, std::string& failure) {
    std::string bytes = read_file(path);
    if (bytes.empty()) { failure = path + ": empty or unreadable"; return false; }
    try {
        if (u44) bytes = de::change_build_profile(bytes, false);
        const de::Module module = de::walk(bytes);
        const std::vector<std::string> pool = ir::parse_pool(bytes);
        for (size_t index = 0; index < module.protos.size(); ++index)
            protos.push_back(ir_annotate(module.protos[index], (int)index, pool, g_nb));
        for (const ir::IProto& proto : protos) models.push_back(cfg_identity_model(proto));
    } catch (const std::exception& e) { failure = path + ": " + e.what(); return false; }
    return true;
}

static int cmd_dataflow_identity(int argc, char** argv) {
    bool u44 = false;
    int dump = -1;
    for (int argument = 4; argument < argc; ++argument) {
        const std::string text = argv[argument];
        if (text == "--u44") u44 = true;
        else if (text.compare(0, 7, "--dump=") == 0) dump = std::atoi(text.c_str() + 7);
    }
    std::vector<ir::IProto> stock, candidate;
    std::vector<CfgIdentityProto> stock_models, candidate_models;
    std::string failure;
    if (!df_load(argv[2], u44, stock, stock_models, failure)
        || !df_load(argv[3], u44, candidate, candidate_models, failure)) {
        std::printf("DATAFLOW_IDENTITY verdict=ERROR %s\n", failure.c_str());
        return 2;
    }
    const size_t shared = std::min(stock.size(), candidate.size());
    // Each prototype's upvalue bijection (CFG-ID), used to align the capture slots of its CLOSUREs.
    std::vector<std::map<int, int>> child_upvalues(shared);
    const std::vector<std::set<int>> used_stock = df_used_upvalues(stock), used_candidate = df_used_upvalues(candidate);
    for (size_t index = 0; index < shared; ++index) {
        if (!stock_models[index].failure.empty() || !candidate_models[index].failure.empty()) continue;
        CfgIdentityMismatch why;
        bool exhausted = false;
        CfgIdentityTrace trace;
        cfg_identity_equal(stock_models[index], candidate_models[index], why, 400000, exhausted, &trace);
        child_upvalues[index] = trace.upvalues;
    }
    size_t equal = 0, diff = 0, unpaired = 0, model_errors = 0, nodes = 0, slots = 0;
    std::map<std::string, size_t> classes;
    for (size_t index = 0; index < shared; ++index) {
        const DfProtoResult r = df_compare_proto(stock[index], stock_models[index], stock,
                                                 candidate[index], candidate_models[index], candidate,
                                                 (int)index == dump, child_upvalues, &used_stock, &used_candidate);
        nodes += r.nodes; slots += r.slots;
        if (r.verdict == "EQUAL") { ++equal; continue; }
        ++classes[r.cls];
        if (r.verdict == "UNPAIRED") {
            ++unpaired;
            std::printf("proto %zu DF_UNPAIRED %s\n", index, r.detail.c_str());
        } else if (r.verdict == "MODEL_ERROR") {
            ++model_errors;
            std::printf("proto %zu DF_MODEL_ERROR %s\n", index, r.detail.c_str());
        } else {
            ++diff;
            std::printf("proto %zu DF_DIFF %s class=\"%s\"\n", index, r.detail.c_str(), r.cls.c_str());
        }
    }
    std::string census;
    for (const auto& item : classes)
        census += (census.empty() ? "" : ";") + item.first + ":" + std::to_string(item.second);
    std::printf("DF_CLASSES {%s}\n", census.c_str());
    const bool pass = stock.size() == candidate.size() && equal == shared;
    std::printf("DATAFLOW_IDENTITY protos_stock=%zu protos_candidate=%zu df_equal=%zu df_diff=%zu df_unpaired=%zu "
                "df_model_errors=%zu product_nodes=%zu slots=%zu verdict=%s\n",
                stock.size(), candidate.size(), equal, diff, unpaired, model_errors, nodes, slots,
                pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}
