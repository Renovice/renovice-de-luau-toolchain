// liveness.h -- shared register use/def and backwards liveness over the DE CFG.
//
// This is deliberately source-neutral. It centralises the 77-opcode register-effect model that was
// previously buried in Emit::allocate_registers so the structurer and allocator can rely on the same
// facts. Unknown operand shapes fail closed for the entire prototype.
#pragma once
#include <algorithm>
#include <set>
#include <vector>
#include "ir.h"
#include "structur.h"

namespace lv {

inline void add_reg(std::set<int>& values, int reg, int maxstack) {
    if (reg >= 0 && reg < maxstack) values.insert(reg);
}

inline void add_regs(std::set<int>& values, int first, int last, int maxstack) {
    if (last >= maxstack) last = maxstack - 1;
    for (int reg = std::max(0, first); reg <= last; ++reg) values.insert(reg);
}

// Exact register effects for every opcode accepted by the current reader. False means the caller
// must not make a liveness-based transformation for this prototype.
inline bool register_effects(const ir::IProto& ip, const ir::IInsn& in,
                             std::set<int>& uses, std::set<int>& defs) {
    const int mx = ip.maxstack;
    auto use = [&](int reg) { add_reg(uses, reg, mx); };
    auto def  = [&](int reg) { add_reg(defs, reg, mx); };
    auto use_range = [&](int first, int last) { add_regs(uses, first, last, mx); };
    auto def_range = [&](int first, int last) { add_regs(defs, first, last, mx); };
    switch (in.op) {
        case 0x12: case 0x4e: case 0x0d: case 0x04: case 0x13: case 0x17:
        case 0x46: case 0x2c: case 0x4f: case 0x16: case 0x42:
            def(in.A); break;
        case 0x14: def(in.A); use(in.B); break;
        case 0x3d: case 0x44: def(in.A); use(in.B); break;
        case 0x01: def(in.A); use(in.B); use(in.C); break;
        case 0x0e: case 0x50: case 0x4d: def(in.A); use(in.B); break;
        case 0x28: def(in.A); use_range(in.B, in.C); break;
        case 0x49: case 0x07: case 0x22: case 0x1a: case 0x55: case 0x45:
        case 0x00: case 0x2f: case 0x2b:
            def(in.A); use(in.B); use(in.C); break;
        case 0x38: case 0x3e: case 0x09: case 0x32: case 0x3c: case 0x08:
        case 0x24: case 0x31: case 0x51:
            def(in.A); use(in.B); break;
        case 0x06: case 0x3b: def(in.A); use(in.C); break;
        case 0x2d:                         // NAMECALL writes function + implicit self
            use(in.B); def(in.A); def((int)in.A + 1); break;
        case 0x54: {                       // CALL A B C
            int nargs = (int)in.B - 1;
            use_range(in.A, nargs < 0 ? mx - 1 : (int)in.A + nargs);
            int nres = (int)in.C - 1;
            if (nres != 0) def_range(in.A, nres < 0 ? mx - 1 : (int)in.A + nres - 1);
            break;
        }
        case 0x02: case 0x53: use(in.A); break;
        case 0x15: case 0x2e: use(in.A); use(in.B); break;
        case 0x2a: use(in.A); use(in.B); use(in.C); break;
        case 0x3f: {                       // table A plus C-1 values beginning at B
            use(in.A);
            int count = (int)in.C - 1;
            use_range(in.B, count < 0 ? mx - 1 : (int)in.B + count - 1);
            break;
        }
        case 0x29: {                       // RETURN A B
            int count = (int)in.B - 1;
            use_range(in.A, count < 0 ? mx - 1 : (int)in.A + count - 1);
            break;
        }
        case 0x4b: case 0x18: case 0x20: case 0x34: case 0x3a: case 0x41:
            use(in.A); break;
        case 0x27: case 0x21: case 0x1c: case 0x23: case 0x33: case 0x37:
            use(in.A); use((int)(in.aux & 0xff)); break;
        case 0x47: case 0x0b: case 0x30: case 0x1b:
            use_range(in.A, (int)in.A + 2); break;
        case 0x0a:
            use_range(in.A, (int)in.A + 2);
            // Measured DE numeric-for layout is [limit, step, index] at
            // A..A+2.  Unlike FORGLOOP, there is no separate visible value at
            // A+3 (ctrl_fornum has no such register in its frame at all).
            def((int)in.A + 2); break;
        case 0x1e: {
            use_range(in.A, (int)in.A + 2);
            int nvars = (int)(in.aux & 0xff);
            def_range((int)in.A + 2, (int)in.A + 2 + nvars);
            break;
        }
        case 0x4c: {
            int count = (int)in.B - 1;
            def_range(in.A, count <= 0 ? mx - 1 : (int)in.A + count - 1);
            break;
        }
        case 0x35:                         // CAPTURE: B is a register for VAL and REF
            if (in.A != 2) use(in.B);
            break;
        case 0x40: case 0x25: case 0x39: case 0x11:
        case 0x19: case 0x10: case 0x0c: case 0x26: case 0x4a:
            break;                          // control/prologue/fastcall hints have no source value
        default: return false;
    }
    return true;
}

struct Analysis {
    bool known = true;
    bool converged = true;
    std::vector<std::set<int>> block_use;
    std::vector<std::set<int>> block_def;
    std::vector<std::set<int>> live_in;
    std::vector<std::set<int>> live_out;
};

inline Analysis analyze(const ir::IProto& ip, const st::Graph& g) {
    Analysis a;
    const size_t count = g.n.size();
    a.block_use.resize(count); a.block_def.resize(count);
    a.live_in.resize(count); a.live_out.resize(count);
    for (size_t b = 0; b < count; ++b) {
        if (!g.n[b].reach) continue;
        for (int i = g.n[b].first; i <= g.n[b].last && i < (int)ip.code.size(); ++i) {
            std::set<int> uses, defs;
            if (!register_effects(ip, ip.code[i], uses, defs)) a.known = false;
            for (int reg : uses)
                if (!a.block_def[b].count(reg)) a.block_use[b].insert(reg);
            a.block_def[b].insert(defs.begin(), defs.end());
        }
    }
    if (!a.known) return a;

    bool changed = true;
    int guard = 0;
    while (changed && guard++ < 10000) {
        changed = false;
        for (int b = (int)count - 1; b >= 0; --b) {
            if (!g.n[b].reach) continue;
            std::set<int> next_out;
            for (int s : {g.n[b].succ_true, g.n[b].succ_false})
                if (s >= 0 && s < (int)count)
                    next_out.insert(a.live_in[s].begin(), a.live_in[s].end());
            std::set<int> next_in = a.block_use[b];
            for (int reg : next_out)
                if (!a.block_def[b].count(reg)) next_in.insert(reg);
            if (next_out != a.live_out[b] || next_in != a.live_in[b]) {
                a.live_out[b].swap(next_out); a.live_in[b].swap(next_in); changed = true;
            }
        }
    }
    a.converged = !changed;
    return a;
}

} // namespace lv
