// cfg_identity_cmd.h -- stock control-flow identity gate (2026-09-29).
//
// CONST-ID (u44_raw_cmd.h) compares per-prototype constant multisets and name-key use classes. It
// cannot see control flow or operation order: the SyndicateScarves NewLokaScarfUpdate mis-render
// (loop body first, prologue last, `while` lost) passed CONST-ID 17/17. This gate compares the
// ORDER OF OPERATIONS and the CONTROL-FLOW GRAPH of each stock prototype with the same-index
// prototype of a candidate, modulo register allocation and the documented transcoder lowerings.
//
// Model. Each instruction becomes a node with a register-free LABEL (opcode class plus every
// non-register operand: constant/key identity with hash/string class, upvalue index, child proto,
// call arity, return arity, loop variable count) and ORDERED successors. Conditional successors are
// canonicalized to [predicate true, predicate false] so JUMPIF/JUMPIFNOT and EQ/NOTEQ polarity do
// not matter. Epsilon instructions (MOVE, LOADNIL, CAPTURE, FASTCALL*, JUMP/JUMPBACK,
// PREPVARARGS) are bypassed. Two prototypes are equal iff their entry nodes are BISIMILAR: equal
// labels and pairwise-bisimilar successors, explored from the entry. Bisimulation makes block
// splitting, jump threading, shared versus duplicated RETURN blocks and unreachable code irrelevant,
// while any reordering, dropped/added operation, changed branch target or lost loop is a mismatch.
//
// Benign lowerings folded back to their stock form (transcode.h, production defaults):
//   F1  LOADK/LOADN/LOADB/LOADNIL scratch [+ MOVE] + JUMPIFEQ2/JUMPIFNOTEQ  ->  IF EQK <k>
//       (DE has no JUMPXEQKN/KS/KB emission in production; stock uses 0x20/0x41/0x34)
//   F2  LOADK/LOADN scratch + reg-reg arithmetic with the scratch as right operand -> <OP>K <k>
//       (SUBK is lowered to LOADK + SUB); scratch as left operand of SUB/DIV -> SUBRK/DIVRK <k>
//   F3  MOVE A<-B ; JUMPIF/JUMPIFNOT A -> +2 ; MOVE/LOAD A  ->  OR/AND[K <k>]
//       (DE has no AND/OR emission in production)
//   N1  FORGPREP/FORGPREP_INEXT/0x0b -> FORGPREP; FORGLOOP ipairs bit dropped (generic for)
//   N2  NEWCLOSURE/DUPCLOSURE -> CLOSURE <flat proto>; CAPTURE mode is not compared
//   N3  LOADN and LOADK of a number are the same LOAD
//   S1  pure materializations are sunk within a block to their first reader (operand slot kept)
//   S2  (2026-09-30) unread ones go to the block end unless the terminator transfers control, and
//       a repositioned node never prunes the dispatch environment (RENOVICE_CFGID_LEGACY_TAIL=1
//       restores the pre-S2 rule for A/B)
//   S3  (2026-09-30) a truthiness test whose two successors resolve to the same node and dispatch
//       state is bypassed: it has no observable effect (RENOVICE_CFGID_LEGACY_TRUTHY_NOOP=1)
//   S4  (2026-09-30) a value read by a loop op (FOR*PREP / FOR*LOOP, range A..A+2) is slotted by its
//       offset from A, not by a coincidental B/C match (RENOVICE_CFGID_LEGACY_LOOP_SLOT=1)
//   S5  (2026-09-30) a folded F3 (OR/AND) does not end the straight-line block for S1/S2, so a
//       pure load before it sinks as it does before stock's native ORK (RENOVICE_CFGID_LEGACY_OR_BLOCK=1)
// Limitations (measured separately, never claimed by this gate): register dataflow is not compared
// (a read of the wrong register, e.g. the SetVortexWindPerZone `Normalize(nil)` class, is invisible);
// operand order of reg-reg comparisons is not compared; LOADNIL/MOVE-only effects are invisible.
#pragma once
#include <functional>
#include <map>
#include <set>
#include <string>
#include <vector>

struct CfgIdentityNode {
    std::string label;
    std::vector<int> succ;      // instruction indices, canonical order ([true, false] for tests)
    bool epsilon = false;
    // Equality-with-constant test on a register (native EQK or folded F1): the register read and
    // the instruction that reads it (the lowering's MOVE copy, or the test itself).
    int test_reg = -1, test_at = -1;
    std::string test_value;
    // Dispatch-state resolution (N4): a constant definition of, or a test on, a dispatch-only web.
    int state_web = -1;
    bool state_def = false, state_test = false;
    // A pure materialization repositioned by S1: its original instruction's liveness does not
    // describe the point where it now sits, so it must not prune the dispatch environment.
    bool floating = false;
    std::string def_value;
    // Successors in instruction order with canonical branch order, recorded before S1 repositions
    // pure nodes (read only by dataflow_identity_cmd.h; empty when register effects are unknown).
    std::vector<int> base_succ;
};

struct CfgIdentityProto {
    std::vector<CfgIdentityNode> nodes;
    std::vector<std::vector<bool>> live_in;   // per instruction, per register (empty if unknown)
    std::map<int, int> web_register;          // dispatch web -> register
    int entry = 0;
    size_t dispatch_webs = 0;
    std::string failure;        // non-empty => the proto could not be modeled
};

static std::string cfg_identity_escape(const std::string& text) {
    std::string out;
    for (unsigned char c : text) {
        if (c >= 0x20 && c < 0x7f && c != '\\' && c != '"') out.push_back((char)c);
        else { char b[8]; std::snprintf(b, sizeof b, "\\x%02x", c); out += b; }
    }
    return out;
}

// Constant identity. Key positions keep the hash/string class; value positions resolve the DE tag-1
// overload (0/1 = boolean, see ir.h value_text).
static std::string cfg_identity_const(const ir::IProto& proto, int index, bool value_position, int depth = 0) {
    if (index < 0 || index >= (int)proto.consts.size()) return "K?" + std::to_string(index);
    const ir::KVal& k = proto.consts[(size_t)index];
    char b[64];
    switch (k.kind) {
        case ir::KKind::Nil: return "nil";
        case ir::KKind::NameHash:
            if (value_position && k.hash <= 1) return k.hash ? "B:true" : "B:false";
            std::snprintf(b, sizeof b, "H:%08x", k.hash); return b;
        case ir::KKind::Number: return "N:" + ir::fmt_num(k.num);
        case ir::KKind::Str: return "S:\"" + cfg_identity_escape(k.str) + "\"";
        case ir::KKind::Import: {
            int count = 0, parts[3]; ir::import_parts(k.import_id, count, parts);
            std::string out = "I:";
            for (int q = 0; q < count && q < 3; ++q)
                out += (q ? "." : "") + (depth < 2 ? cfg_identity_const(proto, parts[q], false, depth + 1) : "?");
            return out;
        }
        case ir::KKind::TableTpl: {
            std::string out = "T:{";
            if (!k.tpl_keys.empty())
                for (size_t q = 0; q < k.tpl_keys.size(); ++q)     // keys-only == every value nil
                    out += (q ? "," : "") + (depth < 2 ? cfg_identity_const(proto, (int)k.tpl_keys[q], false, depth + 1) : "?")
                         + "=nil";
            else
                for (size_t q = 0; q < k.tpl_items.size(); ++q) {
                    out += (q ? "," : "") + (depth < 2 ? cfg_identity_const(proto, (int)k.tpl_items[q].first, false, depth + 1) : "?");
                    out += "=";
                    out += k.tpl_items[q].second == 0xFFFFFFFFu ? std::string("nil")
                         : (depth < 2 ? cfg_identity_const(proto, (int)k.tpl_items[q].second, true, depth + 1) : "?");
                }
            return out + "}";
        }
        case ir::KKind::Closure: return "C:p" + std::to_string((unsigned long long)k.sub);
        case ir::KKind::Vector: return "V:" + k.text;
        case ir::KKind::Int64: return "I64:" + k.text;
        default: return "K?";
    }
}

static bool cfg_identity_is_load(uint8_t op) {
    return op == 0x12 || op == 0x4e || op == 0x04 || op == 0x0d;   // LOADN LOADK LOADB LOADNIL
}

static std::string cfg_identity_load_value(const ir::IProto& proto, const ir::IInsn& in) {
    switch (in.op) {
        case 0x12: return "N:" + ir::fmt_num((double)(int16_t)in.Bx);
        case 0x4e: return cfg_identity_const(proto, in.Bx, true);
        case 0x04: return in.B ? "B:true" : "B:false";
        default:   return "nil";
    }
}

static const char* cfg_identity_arith_name(uint8_t op) {
    switch (op) {
        case 0x49: return "ADD"; case 0x07: return "SUB"; case 0x22: return "MUL"; case 0x1a: return "DIV";
        case 0x55: return "MOD"; case 0x45: return "POW"; case 0x00: return "IDIV";
        case 0x2b: return "OR";  case 0x2f: return "AND";
        default: return nullptr;
    }
}

static const char* cfg_identity_arithk_name(uint8_t op) {
    switch (op) {
        case 0x38: return "ADD"; case 0x3e: return "SUB"; case 0x09: return "MUL"; case 0x32: return "DIV";
        case 0x3c: return "MOD"; case 0x08: return "POW"; case 0x24: return "IDIV";
        case 0x31: return "AND"; case 0x51: return "OR";
        default: return nullptr;
    }
}

static CfgIdentityProto cfg_identity_model(const ir::IProto& proto) {
    CfgIdentityProto out;
    const int n = (int)proto.code.size();
    if (!proto.ok) { out.failure = "decode: " + proto.why; return out; }
    out.nodes.resize((size_t)n);
    std::vector<int> preds((size_t)n + 1, 0);
    auto next = [&](int i) { return i + 1 < n ? i + 1 : -1; };
    // Pass 1: raw labels and successors.
    for (int i = 0; i < n; ++i) {
        const ir::IInsn& in = proto.code[(size_t)i];
        CfgIdentityNode& node = out.nodes[(size_t)i];
        const uint8_t op = in.op;
        auto key = [&](bool value) { return cfg_identity_const(proto, (int)(in.aux & 0xffffu), value); };
        auto cond = [&](const std::string& predicate, bool taken_when_true) {
            node.label = "IF " + predicate;
            node.succ = taken_when_true ? std::vector<int>{in.target, next(i)} : std::vector<int>{next(i), in.target};
        };
        node.succ = {next(i)};
        switch (op) {
            case 0x14: case 0x0d: case 0x35: case 0x11:                       // MOVE LOADNIL CAPTURE PREPVARARGS
            case 0x19: case 0x10: case 0x0c: case 0x26: case 0x4a:            // FASTCALL family (slow path follows)
                node.epsilon = true; break;
            case 0x40: case 0x25: node.epsilon = true; node.succ = {in.target}; break;   // JUMP JUMPBACK
            case 0x01: node.label = "GETTABLE"; break;
            case 0x2a: node.label = "SETTABLE"; break;
            case 0x44: node.label = "GETTABLEN " + std::to_string(in.C + 1); break;
            case 0x2e: node.label = "SETTABLEN " + std::to_string(in.C + 1); break;
            case 0x3d: node.label = "GETFIELD " + key(false); break;
            case 0x15: node.label = "SETFIELD " + key(false); break;
            case 0x17: node.label = "GETGLOBAL " + key(false); break;
            case 0x02: node.label = "SETGLOBAL " + key(false); break;
            case 0x2d: node.label = "NAMECALL " + key(false); break;
            case 0x46: node.label = "GETIMPORT " + cfg_identity_const(proto, in.Bx, false); break;
            case 0x12: case 0x4e: node.label = "LOAD " + cfg_identity_load_value(proto, in); break;
            case 0x04:
                node.label = "LOAD " + cfg_identity_load_value(proto, in);
                if (in.C) node.succ = {i + 1 + in.C < n ? i + 1 + in.C : -1};
                break;
            case 0x54:
                node.label = "CALL " + (in.B ? std::to_string(in.B - 1) : std::string("*")) + " "
                           + (in.C ? std::to_string(in.C - 1) : std::string("*"));
                break;
            case 0x29:
                node.label = "RETURN " + (in.B ? std::to_string(in.B - 1) : std::string("*"));
                node.succ.clear();
                break;
            case 0x13: node.label = "GETUPVAL u" + std::to_string(in.B); break;
            case 0x53: node.label = "SETUPVAL u" + std::to_string(in.B); break;
            case 0x16:
                node.label = in.Bx < proto.kids.size() ? "CLOSURE p" + std::to_string(proto.kids[in.Bx])
                                                       : std::string("CLOSURE ?");
                break;
            case 0x42: {
                const std::string k = cfg_identity_const(proto, in.Bx, false);
                node.label = k.compare(0, 3, "C:p") == 0 ? "CLOSURE " + k.substr(2) : "CLOSURE ?";
                break;
            }
            case 0x39: node.label = "CLOSEUPVALS"; break;
            case 0x2c: node.label = "NEWTABLE"; break;
            case 0x4f: node.label = "DUPTABLE " + cfg_identity_const(proto, in.Bx, false); break;
            case 0x3f: node.label = "SETLIST " + (in.C ? std::to_string(in.C - 1) : std::string("*")); break;
            case 0x0e: node.label = "MINUS"; break;
            case 0x50: node.label = "NOT"; break;
            case 0x4d: node.label = "LENGTH"; break;
            case 0x28: node.label = "CONCAT " + std::to_string((int)in.C - (int)in.B + 1); break;
            case 0x06: node.label = "SUBRK " + cfg_identity_const(proto, in.B, true); break;
            case 0x3b: node.label = "DIVRK " + cfg_identity_const(proto, in.B, true); break;
            case 0x4b: cond("TRUTHY", true); break;
            case 0x18: cond("TRUTHY", false); break;
            case 0x37: cond("EQ", true); break;
            case 0x27: cond("EQ", false); break;
            case 0x21: cond("LT", true); break;
            case 0x1c: cond("LT", false); break;
            case 0x23: cond("LE", true); break;
            case 0x33: cond("LE", false); break;
            case 0x20: case 0x41: case 0x3a: case 0x34: {
                node.test_value = op == 0x3a ? std::string("nil")
                                : op == 0x34 ? std::string((in.aux & 1u) ? "B:true" : "B:false")
                                : cfg_identity_const(proto, (int)(in.aux & 0x7fffffffu), true);
                node.test_reg = in.A; node.test_at = i;
                cond("EQK " + node.test_value, !(in.aux & 0x80000000u));
                break;
            }
            case 0x47: node.label = "FORNPREP"; node.succ = {next(i), in.target}; break;
            case 0x0a: node.label = "FORNLOOP"; node.succ = {in.target, next(i)}; break;
            case 0x30: case 0x1b: case 0x0b: node.label = "FORGPREP"; node.succ = {in.target}; break;
            case 0x1e:
                node.label = "FORGLOOP " + std::to_string(in.aux & 0xffu);
                node.succ = {in.target, next(i)};
                break;
            case 0x4c: node.label = "GETVARARGS " + (in.B ? std::to_string(in.B - 1) : std::string("*")); break;
            default: {
                if (const char* name = cfg_identity_arith_name(op)) { node.label = name; break; }
                if (const char* name = cfg_identity_arithk_name(op)) {
                    node.label = std::string(name) + "K " + cfg_identity_const(proto, in.C, true);
                    break;
                }
                char b[16]; std::snprintf(b, sizeof b, "OP_%02x", op); node.label = b;
                break;
            }
        }
        if (in.branch && in.target < 0) { out.failure = "unresolved branch target"; return out; }
        for (int s : node.succ) if (s >= 0 && s <= n) ++preds[(size_t)s];
    }
    auto private_to_fallthrough = [&](int j) { return j >= 0 && j < n && preds[(size_t)j] == 1; };
    // Pass 2: fold the documented lowerings back to their stock form.
    std::vector<char> f3_branch((size_t)n, 0);      // S5: the JUMPIF/JUMPIFNOT of a folded F3
    for (int i = 0; i + 1 < n; ++i) {
        const ir::IInsn& a = proto.code[(size_t)i];
        // F3: MOVE A<-B ; JUMPIF/JUMPIFNOT A -> i+3 ; MOVE A<-C | LOAD A
        if (a.op == 0x14 && i + 2 < n) {
            const ir::IInsn& br = proto.code[(size_t)i + 1];
            const ir::IInsn& alt = proto.code[(size_t)i + 2];
            if ((br.op == 0x4b || br.op == 0x18) && br.A == a.A && br.target == i + 3
                && ((alt.op == 0x14 && alt.A == a.A) || (cfg_identity_is_load(alt.op) && alt.A == a.A
                                                          && !(alt.op == 0x04 && alt.C)))
                && private_to_fallthrough(i + 1) && private_to_fallthrough(i + 2)) {
                std::string label = br.op == 0x4b ? "OR" : "AND";
                if (alt.op != 0x14) label += "K " + cfg_identity_load_value(proto, alt);
                CfgIdentityNode& node = out.nodes[(size_t)i + 1];
                node.label = label; node.succ = {i + 3 < n ? i + 3 : -1};
                out.nodes[(size_t)i + 2].epsilon = true;
                f3_branch[(size_t)i + 1] = 1;
                i += 2;
                continue;
            }
        }
        if (!cfg_identity_is_load(a.op) || (a.op == 0x04 && a.C)) continue;
        int j = i + 1;
        // F1 allows one intervening MOVE that does not overwrite the scratch (the lowering copies lhs).
        if (j < n && proto.code[(size_t)j].op == 0x14 && proto.code[(size_t)j].A != a.A
            && private_to_fallthrough(j)) ++j;
        if (j >= n || !private_to_fallthrough(j)) continue;
        const ir::IInsn& b = proto.code[(size_t)j];
        const std::string value = cfg_identity_load_value(proto, a);
        if ((b.op == 0x37 || b.op == 0x27) && (b.A == a.A || b.aux == a.A)
            && !(b.A == a.A && b.aux == a.A)) {                                      // F1
            CfgIdentityNode& node = out.nodes[(size_t)j];
            node.label = "IF EQK " + value;
            node.test_value = value;
            const int other = b.A == a.A ? (int)b.aux : (int)b.A;
            const ir::IInsn& copy = proto.code[(size_t)i + 1];
            if (j == i + 2 && copy.A == other) { node.test_reg = copy.B; node.test_at = i + 1; }
            else { node.test_reg = other; node.test_at = j; }
            out.nodes[(size_t)i].epsilon = true;
            continue;
        }
        if (j != i + 1 || a.op == 0x04 || a.op == 0x0d) continue;
        if (const char* name = cfg_identity_arith_name(b.op)) {                     // F2
            const std::string op = name;
            if (op == "AND" || op == "OR") continue;
            if (b.C == a.A && b.B != a.A) {
                out.nodes[(size_t)j].label = op + "K " + value;
                out.nodes[(size_t)i].epsilon = true;
            } else if (b.B == a.A && b.C != a.A && (op == "SUB" || op == "DIV")) {
                out.nodes[(size_t)j].label = op + "RK " + value;
                out.nodes[(size_t)i].epsilon = true;
            }
        }
    }
    // Pass 3: register effects, instruction liveness, dead constant loads and dispatch webs. Any
    // opcode without a register model disables these refinements for the prototype (fail closed:
    // the plain labels above still apply).
    std::vector<std::set<int>> uses((size_t)n), defs((size_t)n);
    bool effects_known = true;
    for (int i = 0; i < n && effects_known; ++i)
        effects_known = lv::register_effects(proto, proto.code[(size_t)i], uses[(size_t)i], defs[(size_t)i]);
    std::vector<std::vector<int>> raw_succ((size_t)n);
    for (int i = 0; i < n; ++i) {
        const ir::IInsn& in = proto.code[(size_t)i];
        std::vector<int> succ;
        if (in.op == 0x29) {}
        else if (in.op == 0x40 || in.op == 0x25 || in.op == 0x30 || in.op == 0x1b || in.op == 0x0b) succ = {in.target};
        else if (in.branch) succ = {in.target, i + 1};
        else if (in.op == 0x04 && in.C) succ = {i + 1 + in.C};
        else succ = {i + 1};
        for (int t : succ) if (t >= 0 && t < n) raw_succ[(size_t)i].push_back(t);
    }
    int entry_node = 0;
    if (effects_known) {
        const int regs = std::max(1, proto.maxstack);
        out.live_in.assign((size_t)n, std::vector<bool>((size_t)regs, false));
        std::vector<std::vector<bool>> live_out((size_t)n, std::vector<bool>((size_t)regs, false));
        bool changed = true;
        for (int guard = 0; changed && guard < 100000; ++guard) {
            changed = false;
            for (int i = n - 1; i >= 0; --i) {
                std::vector<bool> lo((size_t)regs, false);
                for (int t : raw_succ[(size_t)i])
                    for (int r = 0; r < regs; ++r) if (out.live_in[(size_t)t][(size_t)r]) lo[(size_t)r] = true;
                std::vector<bool> li = lo;
                for (int r : defs[(size_t)i]) if (r < regs) li[(size_t)r] = false;
                for (int r : uses[(size_t)i]) if (r < regs) li[(size_t)r] = true;
                if (lo != live_out[(size_t)i] || li != out.live_in[(size_t)i]) {
                    live_out[(size_t)i].swap(lo); out.live_in[(size_t)i].swap(li); changed = true;
                }
            }
        }
        // Dead constant loads are unobservable (declaration prologues, unused comparison results).
        for (int i = 0; i < n; ++i) {
            const ir::IInsn& in = proto.code[(size_t)i];
            if (cfg_identity_is_load(in.op) && !(in.op == 0x04 && in.C) && in.A < regs
                && !live_out[(size_t)i][(size_t)in.A])
                out.nodes[(size_t)i].epsilon = true;
        }
        // N4 dispatch webs. A register tested only for equality with constants, whose reaching
        // definitions are all constant loads, is a dispatch state (the emitter's Proper state machine
        // and SCC loops). Its tests are decided statically during the bisimulation, so a flag-guarded
        // rendering is compared by the paths it actually executes.
        std::set<int> tested;
        for (int i = 0; i < n; ++i)
            if (out.nodes[(size_t)i].test_reg >= 0) tested.insert(out.nodes[(size_t)i].test_reg);
        int web_serial = 0;
        for (int r : tested) {
            // reaching definitions of r; -1 = the value on entry (parameter or undefined)
            std::vector<std::set<int>> rd_in((size_t)n);
            if (n) rd_in[0].insert(-1);
            bool moved = true;
            for (int guard = 0; moved && guard < 100000; ++guard) {
                moved = false;
                for (int i = 0; i < n; ++i) {
                    const std::set<int> out_set = defs[(size_t)i].count(r) ? std::set<int>{i} : rd_in[(size_t)i];
                    for (int t : raw_succ[(size_t)i]) {
                        const size_t before = rd_in[(size_t)t].size();
                        rd_in[(size_t)t].insert(out_set.begin(), out_set.end());
                        if (rd_in[(size_t)t].size() != before) moved = true;
                    }
                }
            }
            std::map<int, int> parent;
            std::function<int(int)> find = [&](int x) -> int {
                auto it = parent.find(x);
                if (it == parent.end()) { parent[x] = x; return x; }
                if (it->second == x) return x;
                const int root = find(it->second);
                parent[x] = root;
                return root;
            };
            std::vector<int> use_sites;
            for (int i = 0; i < n; ++i) {
                if (!uses[(size_t)i].count(r) || rd_in[(size_t)i].empty()) continue;
                use_sites.push_back(i);
                const int first = *rd_in[(size_t)i].begin();
                for (int d : rd_in[(size_t)i]) {
                    const int a = find(d), b = find(first);
                    if (a != b) parent[a] = b;
                }
            }
            std::map<int, bool> dispatch;
            std::vector<int> members;
            for (const auto& item : parent) members.push_back(item.first);
            for (int d : members) {
                const int root = find(d);
                if (!dispatch.count(root)) dispatch[root] = true;
                const bool constant = d >= 0 && cfg_identity_is_load(proto.code[(size_t)d].op)
                    && !(proto.code[(size_t)d].op == 0x04 && proto.code[(size_t)d].C)
                    && proto.code[(size_t)d].A == r && defs[(size_t)d].size() == 1;
                if (!constant) dispatch[root] = false;
            }
            std::map<int, std::vector<int>> tests_of_use;   // use site -> test nodes reading r there
            for (int j = 0; j < n; ++j)
                if (out.nodes[(size_t)j].test_reg == r) tests_of_use[out.nodes[(size_t)j].test_at].push_back(j);
            for (int u : use_sites) {
                const int root = find(*rd_in[(size_t)u].begin());
                const ir::IInsn& in = proto.code[(size_t)u];
                auto tests = tests_of_use.find(u);
                const bool allowed = tests != tests_of_use.end()
                    && ((in.op == 0x14 && in.B == r) || tests->second.front() == u);
                if (!allowed) dispatch[root] = false;
            }
            std::map<int, int> web_id;
            for (const auto& item : dispatch)
                if (item.second) {
                    web_id[item.first] = web_serial;
                    out.web_register[web_serial] = r;
                    ++web_serial;
                }
            for (int d : members) {
                auto web = web_id.find(find(d));
                if (d < 0 || web == web_id.end()) continue;
                CfgIdentityNode& node = out.nodes[(size_t)d];
                node.state_def = true; node.state_web = web->second;
                node.def_value = cfg_identity_load_value(proto, proto.code[(size_t)d]);
                node.epsilon = false;
            }
            for (int u : use_sites) {
                auto web = web_id.find(find(*rd_in[(size_t)u].begin()));
                if (web == web_id.end()) continue;
                for (int j : tests_of_use[u]) {
                    out.nodes[(size_t)j].state_test = true;
                    out.nodes[(size_t)j].state_web = web->second;
                }
            }
        }
        out.dispatch_webs = (size_t)web_serial;
        // S6 (2026-10-09): dead constant loads under a dispatcher. The rule above decides "dead" with
        // path-insensitive liveness, so in a prototype with a dispatch web a load whose value every
        // FEASIBLE path overwrites still looked live through a path the state values exclude (state
        // 5 jumping past the state-5 assignment). Stock `local i = 1; if c then i = a else i = b end`
        // has a dead LOADN (epsilon); the decompiler's state machine kept it observable and the
        // identical program compared as GETIMPORT -> LOAD (ModularArloAvatarRandomizer p4).
        // Liveness is recomputed on the product of instructions and dispatch environments, where a
        // state test with a known value has only its decided successor (the same decision the
        // bisimulation makes). A load is epsilon only if it is dead in EVERY reachable environment.
        // Fails closed (no change) when the product exceeds its bound or a decided successor is not
        // a real CFG successor. RENOVICE_CFGID_LEGACY_DISPATCH_LIVENESS=1 disables S6.
        if (web_serial > 0 && !std::getenv("RENOVICE_CFGID_LEGACY_DISPATCH_LIVENESS")) {
            using PEnv = std::map<int, std::string>;
            auto penv_key = [](const PEnv& env) {
                std::string key;
                for (const auto& item : env) key += std::to_string(item.first) + "=" + item.second + ";";
                return key;
            };
            struct PState { int i; PEnv env; };
            std::vector<PState> states;
            std::map<std::string, int> index;
            std::vector<std::vector<int>> psucc;
            auto key_of = [&](int i, const PEnv& env) {
                return std::to_string(i) + "|" + penv_key(env);
            };
            auto intern = [&](int i, const PEnv& env) -> int {
                const std::string key = key_of(i, env);
                auto it = index.find(key);
                if (it != index.end()) return it->second;
                const int id = (int)states.size();
                index[key] = id;
                states.push_back({i, env});
                psucc.emplace_back();
                return id;
            };
            bool bounded = true;
            const size_t kMaxStates = 200000;
            intern(0, PEnv());
            for (size_t head = 0; head < states.size() && bounded; ++head) {
                const int i = states[head].i;
                PEnv env = states[head].env;
                const CfgIdentityNode& node = out.nodes[(size_t)i];
                std::vector<int> next = raw_succ[(size_t)i];
                if (node.state_def) env[node.state_web] = node.def_value;
                if (node.state_test && node.succ.size() == 2) {
                    auto known = env.find(node.state_web);
                    if (known != env.end()) {
                        const int chosen = known->second == node.test_value ? node.succ[0] : node.succ[1];
                        if (std::find(next.begin(), next.end(), chosen) == next.end()) { bounded = false; break; }
                        next = {chosen};
                    }
                }
                for (int t : next) {
                    const int id = intern(t, env);
                    psucc[head].push_back(id);
                }
                if (states.size() > kMaxStates) bounded = false;
            }
            if (bounded) {
                const size_t m = states.size();
                std::vector<std::vector<bool>> plive_in(m, std::vector<bool>((size_t)regs, false));
                std::vector<std::vector<bool>> plive_out(m, std::vector<bool>((size_t)regs, false));
                bool again = true;
                for (int guard = 0; again && guard < 100000; ++guard) {
                    again = false;
                    for (size_t s = m; s-- > 0;) {
                        std::vector<bool> lo((size_t)regs, false);
                        for (int t : psucc[s])
                            for (int r = 0; r < regs; ++r) if (plive_in[(size_t)t][(size_t)r]) lo[(size_t)r] = true;
                        std::vector<bool> li = lo;
                        const int i = states[s].i;
                        for (int r : defs[(size_t)i]) if (r < regs) li[(size_t)r] = false;
                        for (int r : uses[(size_t)i]) if (r < regs) li[(size_t)r] = true;
                        if (lo != plive_out[s] || li != plive_in[s]) {
                            plive_out[s].swap(lo); plive_in[s].swap(li); again = true;
                        }
                    }
                }
                std::vector<int> reached((size_t)n, 0), live_somewhere((size_t)n, 0);
                for (size_t s = 0; s < m; ++s) {
                    const int i = states[s].i;
                    const ir::IInsn& in = proto.code[(size_t)i];
                    ++reached[(size_t)i];
                    if (in.A < regs && plive_out[s][(size_t)in.A]) live_somewhere[(size_t)i] = 1;
                }
                for (int i = 0; i < n; ++i) {
                    const ir::IInsn& in = proto.code[(size_t)i];
                    CfgIdentityNode& node = out.nodes[(size_t)i];
                    if (node.epsilon || node.state_def || node.state_test || !reached[(size_t)i]) continue;
                    if (!cfg_identity_is_load(in.op) || (in.op == 0x04 && in.C) || in.A >= regs) continue;
                    if (!live_somewhere[(size_t)i]) node.epsilon = true;
                }
            }
        }
        // N5: NOT r2 <- r1 ; JUMPIF/JUMPIFNOT r2 (r2 dead afterwards) is a test of r1 with the
        // opposite polarity (`local t = not x; if t then`).
        for (int i = 0; i + 1 < n; ++i) {
            const ir::IInsn& neg = proto.code[(size_t)i];
            const ir::IInsn& br = proto.code[(size_t)i + 1];
            if (neg.op != 0x50 || (br.op != 0x4b && br.op != 0x18) || br.A != neg.A || neg.A >= regs) continue;
            if (!private_to_fallthrough(i + 1) || out.nodes[(size_t)i + 1].succ.size() != 2) continue;
            bool live_after = false;
            for (int t : raw_succ[(size_t)i + 1])
                if (out.live_in[(size_t)t][(size_t)neg.A]) live_after = true;
            if (live_after) continue;
            out.nodes[(size_t)i].epsilon = true;
            std::swap(out.nodes[(size_t)i + 1].succ[0], out.nodes[(size_t)i + 1].succ[1]);
        }
        // CLOSEUPVALS immediately followed (through epsilons) by RETURN is a no-op: RETURN closes
        // every open upvalue itself.
        for (int i = 0; i < n; ++i) {
            if (proto.code[(size_t)i].op != 0x39 || out.nodes[(size_t)i].epsilon) continue;
            int k = out.nodes[(size_t)i].succ.empty() ? -1 : out.nodes[(size_t)i].succ[0];
            for (int guard = 0; guard < 64 && k >= 0 && k < n && out.nodes[(size_t)k].epsilon; ++guard)
                k = out.nodes[(size_t)k].succ.empty() ? -1 : out.nodes[(size_t)k].succ[0];
            if (k >= 0 && k < n && proto.code[(size_t)k].op == 0x29) out.nodes[(size_t)i].epsilon = true;
        }
        for (auto& node : out.nodes) node.base_succ = node.succ;
        // S1: pure value materializations (constant loads, NEWTABLE, DUPTABLE, GETIMPORT) are
        // unobservable until their value is first read. Within each straight-line block, sink every
        // such node to just before the first real reader of its value (following MOVE copies), or to
        // the block end; nodes sunk to the same point are ordered by label. Both sides are
        // canonicalized the same way. GETIMPORT is treated as pure because Luau resolves imports at
        // load time in a safe environment.
        auto pure = [&](int i) {
            const CfgIdentityNode& node = out.nodes[(size_t)i];
            if (node.epsilon || node.state_def || node.state_test) return false;
            const ir::IInsn& in = proto.code[(size_t)i];
            return in.op == 0x12 || in.op == 0x4e || (in.op == 0x04 && !in.C) || in.op == 0x2c
                || in.op == 0x4f || in.op == 0x46;
        };
        std::vector<int> pred_count((size_t)n, 0);
        for (int i = 0; i < n; ++i) for (int t : raw_succ[(size_t)i]) ++pred_count[(size_t)t];
        // RENOVICE_CFGID_LEGACY_TAIL=1 restores the pre-S2 sinking exactly (tail placement and pruning).
        const bool legacy_tail = std::getenv("RENOVICE_CFGID_LEGACY_TAIL") != nullptr;
        const bool legacy_loop_slot = std::getenv("RENOVICE_CFGID_LEGACY_LOOP_SLOT") != nullptr;
        std::map<int, int> redirect;               // old block start -> new first node
        std::vector<bool> chained((size_t)n + 1, false);   // edges rewritten inside a block
        // S5 (2026-09-30): a folded F3 is ONE operation (stock DE emits native OR/AND[K]), but its
        // lowering is three instructions with a branch, so it split the straight-line block and a
        // pure load before it could not sink past it. `_T.X = _T.X or 0` then compared as
        // GETIMPORT _T -> GETIMPORT _T.X (44.0.2 DialogTree). The branch -> alternative -> join
        // triple is treated as straight-line for block segmentation; the alternative is epsilon.
        // RENOVICE_CFGID_LEGACY_OR_BLOCK=1 restores the split.
        const bool or_block = std::getenv("RENOVICE_CFGID_LEGACY_OR_BLOCK") == nullptr;
        auto straight = [&](int e) {
            if (raw_succ[(size_t)e].size() == 1 && raw_succ[(size_t)e][0] == e + 1
                && pred_count[(size_t)e + 1] == 1 && out.nodes[(size_t)e].succ.size() == 1
                && out.nodes[(size_t)e].succ[0] == e + 1)
                return true;
            if (!or_block) return false;
            if (f3_branch[(size_t)e] && pred_count[(size_t)e + 1] == 1 && e + 2 < n)
                return true;                                             // branch -> alternative
            return e >= 1 && f3_branch[(size_t)e - 1] && pred_count[(size_t)e + 1] == 2
                && raw_succ[(size_t)e].size() == 1 && raw_succ[(size_t)e][0] == e + 1;   // -> join
        };
        for (int s = 0; s < n;) {
            int e = s;
            while (e + 1 < n && straight(e))
                ++e;
            bool any = false;
            for (int i = s; i <= e; ++i) if (pure(i)) { any = true; break; }
            if (any && e > s) {
                // anchor[i] = instruction before which pure node i is placed (e + 1 = block end)
                std::map<int, std::vector<int>> before;
                std::map<int, int> slot;                 // sunk node -> operand slot at its reader
                std::vector<int> fixed;
                for (int i = s; i <= e; ++i) {
                    if (!pure(i)) { fixed.push_back(i); continue; }
                    const int dest = proto.code[(size_t)i].A;
                    std::set<int> holders{dest};
                    int anchor = e + 1;
                    for (int k = i + 1; k <= e && !holders.empty(); ++k) {
                        const ir::IInsn& in = proto.code[(size_t)k];
                        // S5: the alternative MOVE of a folded F3 is the OR/AND's second operand,
                        // read by the folded node itself (stock: native OR A B C reads C there).
                        if (or_block && k >= 1 && f3_branch[(size_t)k - 1] && in.op == 0x14
                            && holders.count(in.B) && k - 1 > i) {
                            anchor = k - 1;
                            slot[i] = 2;
                            break;
                        }
                        if (in.op == 0x14 && holders.count(in.B)) { holders.insert(in.A); continue; }
                        int read = -1;
                        for (int r : uses[(size_t)k]) if (holders.count(r)) { read = r; break; }
                        if (read >= 0) {
                            anchor = k;
                            // Operand slot of the value at its reader, so argument/element/operand
                            // order stays visible after sinking (a swap is still a mismatch).
                            const ir::IInsn& reader = proto.code[(size_t)k];
                            if (or_block && f3_branch[(size_t)k]) slot[i] = 1;   // S5: OR's first operand
                            else if (reader.op == 0x54 || reader.op == 0x29) slot[i] = read - reader.A;
                            // S4 (2026-09-30): loop ops read the register RANGE A..A+2 (limit,
                            // step, index / generator, state, control); B and C are not registers.
                            // Matching A+1/A+2 against B/C gave coincidental slots that depended on
                            // register allocation, so identical `for i = 400, 415` preps compared
                            // as LOAD -> LOAD. RENOVICE_CFGID_LEGACY_LOOP_SLOT=1 restores it.
                            else if (!legacy_loop_slot
                                     && (reader.op == 0x47 || reader.op == 0x0b || reader.op == 0x30
                                         || reader.op == 0x1b || reader.op == 0x0a || reader.op == 0x1e))
                                slot[i] = read - reader.A;
                            else if (reader.op == 0x3f || reader.op == 0x28) slot[i] = read - reader.B;
                            else if (read == reader.A) slot[i] = 0;
                            else if (read == reader.B) slot[i] = 1;
                            else if (read == reader.C) slot[i] = 2;
                            else if ((int)(reader.aux & 0xff) == read) slot[i] = 3;
                            else slot[i] = 1000 + read;
                            break;
                        }
                        for (int r : defs[(size_t)k]) holders.erase(r);
                    }
                    // The block terminator keeps its position; a pure terminator anchors at itself.
                    if (i == e) anchor = e + 1;
                    before[anchor].push_back(i);
                    out.nodes[(size_t)i].floating = !legacy_tail;
                }
                auto by_label = [&](int a, int b) {
                    const int sa = slot.count(a) ? slot[a] : -1, sb = slot.count(b) ? slot[b] : -1;
                    if (sa != sb) return sa < sb;
                    if (out.nodes[(size_t)a].label != out.nodes[(size_t)b].label)
                        return out.nodes[(size_t)a].label < out.nodes[(size_t)b].label;
                    return a < b;
                };
                // Pure nodes with no reader in the block go just before a terminator that transfers
                // control (a branch, loop op or return: its model successors are not just the next
                // instruction), and otherwise to the very end of the block. S2 (2026-09-30): a
                // fall-through terminator (CALL, SETFIELD, ...) or an epsilon one (the MOVE result copy
                // the emitter adds after a CALL) no longer decides the position. Before, the same
                // stock `local t = 0; x:A(); y:B()` block placed the load before the last CALL
                // when the block ended in that CALL and after it when a MOVE followed, which
                // manufactured LOAD -> CALL / LOAD -> GETIMPORT mismatches for identical programs.
                const CfgIdentityNode& last = out.nodes[(size_t)e];
                const bool transfers = !last.epsilon
                    && (last.succ.size() != 1 || last.succ[0] != e + 1 || proto.code[(size_t)e].op == 0x29);
                auto tail = before.find(e + 1);
                if (tail != before.end() && !fixed.empty() && fixed.back() == e && (legacy_tail || transfers)) {
                    before[e].insert(before[e].end(), tail->second.begin(), tail->second.end());
                    before.erase(e + 1);
                }
                std::vector<int> order;
                for (int k : fixed) {
                    auto it = before.find(k);
                    if (it != before.end()) {
                        std::sort(it->second.begin(), it->second.end(), by_label);
                        order.insert(order.end(), it->second.begin(), it->second.end());
                    }
                    order.push_back(k);
                }
                tail = before.find(e + 1);
                if (tail != before.end()) {
                    std::sort(tail->second.begin(), tail->second.end(), by_label);
                    order.insert(order.end(), tail->second.begin(), tail->second.end());
                }
                // If the terminator itself was pure it now sits in the tail group; the block's
                // outgoing edges belong to whichever node is last.
                const std::vector<int> exits = out.nodes[(size_t)e].succ;
                for (size_t q = 0; q + 1 < order.size(); ++q) {
                    out.nodes[(size_t)order[q]].succ = {order[q + 1]};
                    chained[(size_t)order[q]] = true;
                }
                out.nodes[(size_t)order.back()].succ = exits;
                if (order.front() != s) redirect[s] = order.front();
            }
            s = e + 1;
        }
        if (!redirect.empty()) {
            for (size_t i = 0; i < out.nodes.size(); ++i) {
                if (i < chained.size() && chained[i]) continue;
                for (int& t : out.nodes[i].succ) {
                    auto it = redirect.find(t);
                    if (it != redirect.end()) t = it->second;
                }
            }
            auto entry = redirect.find(0);
            if (entry != redirect.end()) entry_node = entry->second;
        }
    }
    CfgIdentityNode spin; spin.label = "SPIN"; spin.succ = {n};
    out.nodes.push_back(spin);                   // synthetic node n: an empty infinite loop
    out.entry = entry_node;
    return out;
}

static bool cfg_identity_load(const std::string& path, bool u44, std::vector<CfgIdentityProto>& out,
                              std::string& failure) {
    std::string bytes = read_file(path);
    if (bytes.empty()) { failure = path + ": empty or unreadable"; return false; }
    try {
        if (u44) bytes = de::change_build_profile(bytes, false);
        const de::Module module = de::walk(bytes);
        const std::vector<std::string> pool = ir::parse_pool(bytes);
        for (size_t index = 0; index < module.protos.size(); ++index)
            out.push_back(cfg_identity_model(ir_annotate(module.protos[index], (int)index, pool, g_nb)));
    } catch (const std::exception& e) { failure = path + ": " + e.what(); return false; }
    return true;
}

struct CfgIdentityMismatch {
    int stock = -1, candidate = -1;
    std::string stock_label, candidate_label, kind;
    size_t depth = 0;
};

// Dispatch environment: web -> constant value. Only webs whose register is live are kept, so a
// finished state machine does not multiply the product states that follow it.
using CfgIdentityEnv = std::map<int, std::string>;

static std::string cfg_identity_env_key(const CfgIdentityEnv& env) {
    std::string key;
    for (const auto& item : env) key += std::to_string(item.first) + "=" + item.second + ";";
    return key;
}

// Follow epsilon, dispatch definitions and statically decided dispatch tests from `i` to the next
// observable node. Returns -1 for "falls off the end", SPIN (= nodes.size()-1) for a cycle that
// performs no observable operation.
static int cfg_identity_resolve(const CfgIdentityProto& proto, int i, CfgIdentityEnv& env, int nesting = 0) {
    static const bool legacy_truthy = std::getenv("RENOVICE_CFGID_LEGACY_TRUTHY_NOOP") != nullptr;
    const int spin = (int)proto.nodes.size() - 1;
    std::set<std::string> walked;
    while (true) {
        if (i < 0 || i >= spin) {
            env.clear();
            return i == spin ? spin : -1;
        }
        const CfgIdentityNode& node = proto.nodes[(size_t)i];
        // A floating (S1-repositioned) node is skipped: pruning there would use the liveness of a
        // different program point and could forget a state defined just before it (S2, 2026-09-30).
        // Keeping an entry longer never changes a decision: a web's tests read only its own defs.
        if (!proto.live_in.empty() && !node.floating) {
            for (auto it = env.begin(); it != env.end();) {
                auto reg = proto.web_register.find(it->first);
                // The lowering copies the state into a scratch one instruction before the test,
                // so the test itself still needs the value although the register is dead there.
                const bool live = (node.state_test && node.state_web == it->first)
                    || (reg != proto.web_register.end()
                        && reg->second < (int)proto.live_in[(size_t)i].size()
                        && proto.live_in[(size_t)i][(size_t)reg->second]);
                it = live ? std::next(it) : env.erase(it);
            }
        }
        if (!walked.insert(std::to_string(i) + "|" + cfg_identity_env_key(env)).second) {
            env.clear();
            return spin;
        }
        if (node.state_def) {
            env[node.state_web] = node.def_value;
            i = node.succ.empty() ? -1 : node.succ[0];
            continue;
        }
        if (node.state_test) {
            auto known = env.find(node.state_web);
            if (known != env.end() && node.succ.size() == 2) {
                i = known->second == node.test_value ? node.succ[0] : node.succ[1];
                continue;
            }
        }
        if (node.epsilon) {
            i = node.succ.empty() ? -1 : node.succ[0];
            continue;
        }
        // S3 (2026-09-30): a truthiness test whose two successors reach the same observable node in
        // the same dispatch state is a no-op -- reading a register's truthiness runs no metamethod.
        // Stock keeps such a test for an empty-bodied `if a and b then end`; the decompiler prints
        // the operand evaluation without the dead test. Comparisons (EQ/LT/LE) are NOT folded:
        // they can invoke __eq/__lt/__le. RENOVICE_CFGID_LEGACY_TRUTHY_NOOP=1 disables S3 for A/B.
        if (!legacy_truthy && nesting < 4 && node.label == "IF TRUTHY" && node.succ.size() == 2) {
            CfgIdentityEnv taken = env, fallthrough = env;
            const int a = cfg_identity_resolve(proto, node.succ[0], taken, nesting + 1);
            const int b = cfg_identity_resolve(proto, node.succ[1], fallthrough, nesting + 1);
            if (a == b && cfg_identity_env_key(taken) == cfg_identity_env_key(fallthrough)) {
                env = taken;
                return a;
            }
        }
        return i;
    }
}

// Optional read-only trace of a bisimulation (dataflow_identity_cmd.h): every matched pair of
// observable nodes with its dispatch environments, in breadth-first order, and the upvalue
// bijection. Recording it never changes the verdict.
struct CfgIdentityTrace {
    struct Pair { int x = -1, y = -1; std::string env_x, env_y; };
    std::vector<Pair> pairs;
    std::map<int, int> upvalues;              // stock upvalue slot -> candidate upvalue slot
};

// Deterministic bisimulation of (node, dispatch environment) pairs from the entries; reports the
// first mismatch in breadth-first order. `limit` bounds the explored product (fail closed).
static bool cfg_identity_equal(const CfgIdentityProto& a, const CfgIdentityProto& b, CfgIdentityMismatch& why,
                               size_t limit, bool& exhausted, CfgIdentityTrace* trace = nullptr) {
    exhausted = false;
    struct Side { int node; CfgIdentityEnv env; };
    struct Item { Side x, y; size_t depth; };
    std::set<std::string> seen;
    std::map<int, int> up_ab, up_ba;
    std::vector<Item> queue;
    {
        Item first; first.depth = 0;
        first.x.node = cfg_identity_resolve(a, a.entry, first.x.env);
        first.y.node = cfg_identity_resolve(b, b.entry, first.y.env);
        queue.push_back(first);
    }
    for (size_t head = 0; head < queue.size(); ++head) {
        const Item item = queue[head];
        const std::string key = std::to_string(item.x.node) + "|" + cfg_identity_env_key(item.x.env) + "#"
                              + std::to_string(item.y.node) + "|" + cfg_identity_env_key(item.y.env);
        if (!seen.insert(key).second) continue;
        if (seen.size() > limit) { exhausted = true; return false; }
        const int x = item.x.node, y = item.y.node;
        if (x < 0 || y < 0) {
            if (x == y) continue;
            why = {x, y, x < 0 ? "<end>" : a.nodes[(size_t)x].label, y < 0 ? "<end>" : b.nodes[(size_t)y].label,
                   "FALLOFF", item.depth};
            return false;
        }
        const CfgIdentityNode& p = a.nodes[(size_t)x];
        const CfgIdentityNode& q = b.nodes[(size_t)y];
        // Upvalue slots are compared up to one consistent bijection per prototype: the closure's
        // capture order is a numbering choice, the variable identity is not.
        auto upvalue = [](const std::string& label, std::string& op) -> int {
            for (const char* prefix : {"GETUPVAL u", "SETUPVAL u"})
                if (label.compare(0, 10, prefix) == 0) { op = prefix; return std::atoi(label.c_str() + 10); }
            return -1;
        };
        std::string op_a, op_b;
        const int ua = upvalue(p.label, op_a), ub = upvalue(q.label, op_b);
        if (ua >= 0 && ub >= 0 && op_a == op_b) {
            auto fa = up_ab.find(ua); auto fb = up_ba.find(ub);
            if ((fa != up_ab.end() && fa->second != ub) || (fb != up_ba.end() && fb->second != ua)) {
                why = {x, y, p.label, q.label, "UPVALUE", item.depth}; return false;
            }
            up_ab[ua] = ub; up_ba[ub] = ua;
            if (trace) trace->upvalues[ua] = ub;
        } else if (p.label != q.label) { why = {x, y, p.label, q.label, "LABEL", item.depth}; return false; }
        if (p.succ.size() != q.succ.size()) { why = {x, y, p.label, q.label, "ARITY", item.depth}; return false; }
        if (trace) {
            CfgIdentityTrace::Pair pair;
            pair.x = x; pair.y = y;
            pair.env_x = cfg_identity_env_key(item.x.env); pair.env_y = cfg_identity_env_key(item.y.env);
            trace->pairs.push_back(pair);
        }
        for (size_t s = 0; s < p.succ.size(); ++s) {
            Item next; next.depth = item.depth + 1;
            next.x.env = item.x.env; next.y.env = item.y.env;
            next.x.node = cfg_identity_resolve(a, p.succ[s], next.x.env);
            next.y.node = cfg_identity_resolve(b, q.succ[s], next.y.env);
            queue.push_back(next);
        }
    }
    return true;
}

static std::string cfg_identity_op_class(const std::string& label) {
    if (label.compare(0, 3, "IF ") == 0) {
        const size_t space = label.find(' ', 3);
        return label.substr(0, space);
    }
    return label.substr(0, label.find(' '));
}

static int cmd_cfg_identity(int argc, char** argv) {
    bool u44 = false;
    int dump = -1;                                 // --dump=N prints both models of proto N
    for (int argument = 4; argument < argc; ++argument) {
        const std::string text = argv[argument];
        if (text == "--u44") u44 = true;
        else if (text.compare(0, 7, "--dump=") == 0) dump = std::atoi(text.c_str() + 7);
    }
    std::vector<CfgIdentityProto> stock, candidate;
    std::string failure;
    if (!cfg_identity_load(argv[2], u44, stock, failure) || !cfg_identity_load(argv[3], u44, candidate, failure)) {
        std::printf("CFG_IDENTITY verdict=ERROR %s\n", failure.c_str());
        return 2;
    }
    if (dump >= 0) {
        for (const auto* side : {&stock, &candidate}) {
            if (dump >= (int)side->size()) continue;
            const CfgIdentityProto& model = (*side)[(size_t)dump];
            std::printf("MODEL %s proto %d webs=%zu failure=\"%s\"\n", side == &stock ? "stock" : "candidate",
                        dump, model.dispatch_webs, model.failure.c_str());
            for (size_t i = 0; i < model.nodes.size(); ++i) {
                const CfgIdentityNode& node = model.nodes[i];
                std::string succ;
                for (int s : node.succ) succ += (succ.empty() ? "" : ",") + std::to_string(s);
                std::printf("  [%4zu] %-3s %-44s -> %-10s%s%s\n", i, node.epsilon ? "eps" : "",
                            cfg_identity_escape(node.label).c_str(), succ.c_str(),
                            node.state_def ? (" DEF w" + std::to_string(node.state_web) + "=" + node.def_value).c_str() : "",
                            node.state_test ? (" TEST w" + std::to_string(node.state_web) + "==" + node.test_value).c_str()
                                            : (node.test_reg >= 0 ? (" test r" + std::to_string(node.test_reg) + "@"
                                                                     + std::to_string(node.test_at)).c_str() : ""));
            }
        }
    }
    const size_t shared = std::min(stock.size(), candidate.size());
    size_t equal = 0, model_failures = 0, dispatch_webs = 0;
    std::map<std::string, size_t> classes;
    for (size_t index = 0; index < shared; ++index) {
        if (!stock[index].failure.empty() || !candidate[index].failure.empty()) {
            ++model_failures;
            std::printf("proto %zu MODEL_ERROR stock=\"%s\" candidate=\"%s\"\n", index,
                        stock[index].failure.c_str(), candidate[index].failure.c_str());
            ++classes["MODEL_ERROR"];
            continue;
        }
        CfgIdentityMismatch why;
        bool exhausted = false;
        dispatch_webs += candidate[index].dispatch_webs;
        if (cfg_identity_equal(stock[index], candidate[index], why, 400000, exhausted)) { ++equal; continue; }
        if (exhausted) {
            ++model_failures; ++classes["STATE_LIMIT"];
            std::printf("proto %zu STATE_LIMIT product exceeded 400000 states\n", index);
            continue;
        }
        const std::string cls = why.kind + " " + cfg_identity_op_class(why.stock_label) + " -> "
                              + cfg_identity_op_class(why.candidate_label);
        ++classes[cls];
        std::printf("proto %zu CFG_DIFF kind=%s depth=%zu stock[%d]=\"%s\" candidate[%d]=\"%s\" class=\"%s\"\n",
                    index, why.kind.c_str(), why.depth, why.stock, cfg_identity_escape(why.stock_label).c_str(),
                    why.candidate, cfg_identity_escape(why.candidate_label).c_str(), cls.c_str());
    }
    std::string census;
    for (const auto& item : classes)
        census += (census.empty() ? "" : ";") + item.first + ":" + std::to_string(item.second);
    std::printf("CFG_CLASSES {%s}\n", census.c_str());
    const bool pass = stock.size() == candidate.size() && equal == shared;
    std::printf("CFG_IDENTITY protos_stock=%zu protos_candidate=%zu cfg_equal=%zu model_errors=%zu "
                "candidate_dispatch_webs=%zu verdict=%s\n",
                stock.size(), candidate.size(), equal, model_failures, dispatch_webs, pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}
