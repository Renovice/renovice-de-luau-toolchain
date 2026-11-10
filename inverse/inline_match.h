// inline_match.h -- recognise -O2 inlined copies of a module's own functions (2026-11-10).
//
// Luau -O2 inlines a call to a local function: the callee's body is copied into the caller with
// its registers shifted, every `return X` becomes "X into the result register; JUMP after the
// copy" (the last one falls through), and tests on a parameter that received a constant argument
// fold away together with the dead branch. This matcher walks the callee and the caller in
// lockstep and reports the caller region [start, end), the result register, and each parameter's
// binding (a caller register or a folded constant).
//
//   derecomp inline-scan FILE    lists the matches it finds (diagnostic)
#pragma once
#include <map>
#include <set>
#include <string>
#include <vector>

namespace inl {

struct Binding { int reg = -1; int truth = -1; };   // a caller register, or a folded truthiness
struct Match {
    int callee = -1, start = -1, end = -1, result = -1;
    std::vector<Binding> params;
};

class Matcher {
public:
    Matcher(const ir::IProto& caller, const ir::IProto& callee) : P(caller), H(callee) {}

    // Try a match whose callee pc 0 lines up with caller pc `s`.
    bool at(int s, Match& m) {
        best_ok = false;
        State st; st.params.assign((size_t)H.nparams, Binding());
        st.reg.clear(); st.pcmap.assign(H.code.size(), -1);
        walk(0, s, st, 0);
        if (!best_ok) return false;
        m = best; return true;
    }

private:
    const ir::IProto& P;
    const ir::IProto& H;
    struct State {
        std::map<int, int> reg;            // callee register -> caller register
        std::vector<Binding> params;
        std::vector<int> pcmap;            // callee pc -> caller pc
        int result = -1, join = -1, last_p = -1;
        std::map<int, int> upv;            // callee upvalue -> caller upvalue
    };
    Match best; bool best_ok = false;

    const ir::IInsn& HI(int pc) const { return H.code[(size_t)pc]; }
    const ir::IInsn& PI(int pc) const { return P.code[(size_t)pc]; }
    bool is_param(int r) const { return r < H.nparams; }

    // map a callee register read; parameters bind on first read
    bool read(State& st, int hr, int pr) {
        if (is_param(hr)) {
            Binding& b = st.params[(size_t)hr];
            if (b.truth >= 0) return false;
            if (b.reg < 0) { b.reg = pr; return true; }
            return b.reg == pr;
        }
        auto it = st.reg.find(hr);
        return it != st.reg.end() && it->second == pr;
    }
    void write(State& st, int hr, int pr) { st.reg[hr] = pr; }

    // operands other than registers must be identical
    // constant operands compare by meaning: indices into each function's own constant table differ
    bool same_static(const ir::IInsn& a, const ir::IInsn& b) const {
        if (a.name != b.name || a.note != b.note) return false;
        if (a.name == "LOADN" || a.name == "LOADB") return a.B == b.B && a.C == b.C;
        if (a.name == "LOADK" || a.name == "LOADKX") return kval(H, a) == kval(P, b);
        // register-pair compares keep the second register in aux (checked as a register read)
        if (a.name == "JUMPIFEQ" || a.name == "JUMPIFNOTEQ" || a.name == "JUMPIFLT" || a.name == "JUMPIFLE"
            || a.name == "JUMPIFNOTLT" || a.name == "JUMPIFNOTLE") return true;
        // constant compares: the NOT flag and the constant value
        if (a.name.rfind("JUMPXEQK", 0) == 0) {
            if ((a.aux & 0x80000000u) != (b.aux & 0x80000000u)) return false;
            if (a.name == "JUMPXEQKNIL" || a.name == "JUMPXEQKB") return (a.aux & 0x7fffffffu) == (b.aux & 0x7fffffffu);
            const int ka = (int)(a.aux & 0xffffffu), kb = (int)(b.aux & 0xffffffu);
            return ka < (int)H.consts.size() && kb < (int)P.consts.size()
                && ir::value_text(H.consts[(size_t)ka]) == ir::value_text(P.consts[(size_t)kb]);
        }
        if (a.name == "GETUPVAL" || a.name == "SETUPVAL") return true;          // index mapped by walk()
        if (!a.note.empty()) return true;
        return a.aux == b.aux;
    }
    static std::string kval(const ir::IProto& ip, const ir::IInsn& in) {
        const int k = in.name == "LOADKX" ? (int)in.aux : in.B;
        return k >= 0 && k < (int)ip.consts.size() ? ir::value_text(ip.consts[(size_t)k]) : std::string("?");
    }

    void walk(int h, int p, State st, int depth) {
        if (best_ok || depth > 64) return;
        while (h < (int)H.code.size()) {
            if (p >= (int)P.code.size()) return;
            const int known = st.pcmap[(size_t)h];
            if (std::getenv("RENOVICE_INLINE_DBG")) std::fprintf(stderr, "INL_AT h=%d p=%d known=%d%c", h, p, known, 10);
            if (known >= 0 && known != p) return;                    // reached twice, differently
            if (known <= -2 && -2 - known != p) return;              // a branch promised another pc
            st.pcmap[(size_t)h] = p;
            const ir::IInsn& a = HI(h);
            // RETURN Rk 1: the value must already sit in the result register; then JUMP join
            // (or the region ends here)
            if (a.name == "RETURN") {
                if (a.B != 2) return;                                    // exactly one value
                auto it = st.reg.find(a.A);
                int pr = it == st.reg.end() ? (is_param(a.A) ? st.params[(size_t)a.A].reg : -1) : it->second;
                if (pr < 0) return;
                if (st.result < 0) st.result = pr; else if (st.result != pr) return;
                if (h + 1 >= (int)H.code.size()) { finish(st, p); return; }
                const ir::IInsn& j = PI(p);
                if (j.name != "JUMP") { finish(st, p); return; }       // last return falls through
                if (st.join < 0) st.join = j.target; else if (st.join != j.target) return;
                ++h; ++p; continue;
            }
            const ir::IInsn& b = PI(p);
            // a test on a parameter that is not in the caller: the argument was a constant
            if (b.name != a.name && (a.name == "JUMPIF" || a.name == "JUMPIFNOT") && is_param(a.A)
                && st.params[(size_t)a.A].reg < 0) {
                for (int truth : {1, 0}) {
                    State s2 = st;
                    s2.params[(size_t)a.A].truth = truth;
                    const bool jumps = (a.name == "JUMPIF") == (truth == 1);
                    walk(jumps ? a.target : h + 1, p, s2, depth + 1);
                }
                return;
            }
            if (std::getenv("RENOVICE_INLINE_DBG"))
                std::fprintf(stderr, "INL h=%d %s [%s|%u|%d,%d] p=%d %s [%s|%u|%d,%d]\n", h, a.name.c_str(), a.note.c_str(), (unsigned)a.aux, a.B, a.C, p, b.name.c_str(), b.note.c_str(), (unsigned)b.aux, b.B, b.C);
            if (!same_static(a, b)) return;
            if (a.name == "GETUPVAL" || a.name == "SETUPVAL") {
                auto it = st.upv.find(a.B);
                if (it == st.upv.end()) st.upv[a.B] = b.B; else if (it->second != b.B) return;
            }
            if (a.name == "CALL") {
                if (a.B != b.B || a.C != b.C) return;
            }
            // registers: A is a write for most loads/ops, a read for stores/tests/calls
            std::set<int> ua, da, ub, db;
            if (!lv::register_effects(H, a, ua, da) || !lv::register_effects(P, b, ub, db)) return;
            if (std::getenv("RENOVICE_INLINE_DBG")) {
                std::fprintf(stderr, "INL_REGS uses");
                for (int r : ua) std::fprintf(stderr, " %d", r);
                std::fprintf(stderr, " |");
                for (int r : ub) std::fprintf(stderr, " %d", r);
                std::fprintf(stderr, " defs");
                for (int r : da) std::fprintf(stderr, " %d", r);
                std::fprintf(stderr, " |");
                for (int r : db) std::fprintf(stderr, " %d", r);
                std::fprintf(stderr, "%c", 10);
            }
            if (ua.size() != ub.size() || da.size() != db.size()) return;
            // pair reads in register order
            auto ia = ua.begin(); auto ib = ub.begin();
            for (; ia != ua.end(); ++ia, ++ib) if (!read(st, *ia, *ib)) return;
            ia = da.begin(); ib = db.begin();
            for (; ia != da.end(); ++ia, ++ib) write(st, *ia, *ib);
            // branch targets must map consistently (forward targets are checked on arrival)
            if (a.branch && a.target >= 0) {
                if (a.target <= h) { if (st.pcmap[(size_t)a.target] != b.target) return; }
                else pending_target(st, a.target, b.target);
            }
            ++h; ++p;
        }
        finish(st, p);
    }
    void pending_target(State& st, int ht, int pt) {
        if (ht < (int)st.pcmap.size() && st.pcmap[(size_t)ht] < 0) st.pcmap[(size_t)ht] = -2 - pt;
    }
    void finish(State& st, int p) {
        if (st.result < 0) return;
        if (st.join >= 0 && st.join != p) return;
        best.start = -1; best.end = p; best.result = st.result; best.params = st.params;
        best_ok = true;
    }
};

} // namespace inl

static int cmd_inline_scan(int argc, char** argv) {
    ir_load_namebase();
    for (int a = 2; a < argc; ++a) {
        const std::string path = argv[a];
        if (path == "--u44") { g_input_profile_u44 = true; continue; }
        const std::string b = read_de_input(path);
        if (b.empty()) continue;
        de::Module m;
        try { m = de::walk(b); } catch (...) { continue; }
        const std::vector<std::string> pool = ir::parse_pool(b);
        std::vector<ir::IProto> ps;
        for (size_t i = 0; i < m.protos.size(); ++i) ps.push_back(ir_annotate(m.protos[i], (int)i, pool, g_nb));
        for (size_t p = 0; p < ps.size(); ++p) {
            if (!ps[p].ok) continue;
            for (size_t h = 0; h < ps.size(); ++h) {
                if (h == p || !ps[h].ok || ps[h].code.size() < 4) continue;
                for (int s = 0; s < (int)ps[p].code.size(); ++s) {
                    inl::Matcher mt(ps[p], ps[h]);
                    inl::Match r;
                    if (!mt.at(s, r)) continue;
                    if (r.end - s < 4) continue;
                    std::printf("INLINE proto=%zu callee=%zu region=[%d,%d) result=R%d params=", p, h, s, r.end, r.result);
                    for (const auto& b2 : r.params) {
                        if (b2.reg >= 0) std::printf("R%d ", b2.reg);
                        else if (b2.truth >= 0) std::printf("%s ", b2.truth ? "truthy" : "falsy");
                        else std::printf("? ");
                    }
                    std::printf("\n");
                    s = r.end - 1;
                }
            }
        }
    }
    return 0;
}
