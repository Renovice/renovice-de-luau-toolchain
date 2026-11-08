// inverse_scan.h -- compiler-inverse statement grammar, milestone 1 (coverage), 2026-11-08.
//
//   derecomp inverse-scan [--u44] [--verbose] FILE...
//
// Parses every prototype's instruction stream with a recursive-descent grammar that mirrors the
// Luau compiler's statement generators (see inverse/README.md). A prototype PASSES when the grammar
// consumes every instruction and explains every jump. Read-only: no decompiler behaviour changes.
// Output: one INVERSE_FAIL line per failing prototype (--verbose) and a summary line
//   INVERSE_SCAN files=<n> protos=<n> parsed=<n> failed=<n>
#pragma once
#include <map>
#include <set>
#include <string>
#include <vector>

namespace inv {

struct LoopCtx {
    int exit = -1;   // a JUMP here is `break`
    int cont = -1;   // a JUMP / JUMPBACK here is `continue`
};

class Grammar {
public:
    explicit Grammar(const ir::IProto& p) : ip(p), n((int)p.code.size()) {
        for (int i = 0; i < n; ++i) {
            const ir::IInsn& in = ip.code[(size_t)i];
            if (in.branch && in.target >= 0 && in.target <= i) back_into[in.target].push_back(i);
        }
    }

    bool parse(std::string& why, int& at) {
        LoopCtx none;
        const bool ok = seq(0, n, none);
        why = fail_why; at = fail_at;
        return ok;
    }

private:
    const ir::IProto& ip;
    const int n;
    std::map<int, std::vector<int>> back_into;   // loop head -> backward jumps into it
    std::string fail_why; int fail_at = -1;

    // Keep the DEEPEST failure (largest pc): an outer IF_CHAIN only reports that some inner
    // construct did not parse; the innermost unexplained instruction is the real reason.
    bool fail(const char* why, int at) {
        if (at >= fail_at) { fail_why = why; fail_at = at; }
        return false;
    }
    const ir::IInsn& I(int pc) const { return ip.code[(size_t)pc]; }
    // JUMP THREADING: the compiler sends a jump that would land on an unconditional JUMP straight
    // to that JUMP's destination. `t` lands at position `e` when e == t or e starts a chain of
    // unconditional JUMPs ending at t.
    bool lands(int t, int e) const {
        for (int step = 0; step < 16 && e >= 0 && e < n; ++step) {
            if (e == t) return true;
            const ir::IInsn& j = I(e);
            if (j.name != "JUMP" && j.name != "JUMPBACK") return false;
            e = j.target;
        }
        return e == t;
    }
    static bool is_uncond(const ir::IInsn& in) { return in.name == "JUMP" || in.name == "JUMPBACK"; }
    static bool is_fornprep(const ir::IInsn& in) { return in.name == "FORNPREP"; }
    static bool is_forgprep(const ir::IInsn& in) { return in.name.rfind("FORGPREP", 0) == 0; }
    static bool is_loop_op(const ir::IInsn& in) {
        return in.name == "FORNLOOP" || in.name == "FORGLOOP" || is_fornprep(in) || is_forgprep(in);
    }
    static bool is_loadb_skip(const ir::IInsn& in) { return in.name == "LOADB" && in.C != 0; }
    bool is_cond(int pc) const {
        const ir::IInsn& in = I(pc);
        return in.branch && !is_uncond(in) && !is_loop_op(in) && !is_loadb_skip(in);
    }

    // statements from pc up to exactly `end`
    bool seq(int pc, int end, const LoopCtx& ctx) {
        while (pc < end) {
            const int next = stmt(pc, end, ctx);
            if (next < 0) return false;
            if (next > end) return fail("STMT_PAST_END", pc);
            pc = next;
        }
        return pc == end || fail("SEQ_OVERRUN", pc);
    }

    // one statement at pc; returns the next pc or -1
    int stmt(int pc, int end, const LoopCtx& ctx) {
        // a loop whose head is pc: the LAST backward jump into pc inside [pc, end)
        auto bi = back_into.find(pc);
        if (bi != back_into.end()) {
            int j = -1;
            for (int b : bi->second) if (b < end && b > j) j = b;
            if (j >= pc) {
                const ir::IInsn& tail = I(j);
                LoopCtx inner; inner.exit = j + 1; inner.cont = pc;
                if (is_uncond(tail)) {                       // while / while true
                    if (!seq(pc, j, inner)) return -1;
                    return j + 1;
                }
                if (is_cond(j)) {                            // repeat ... until
                    if (!seq(pc, j, inner)) return -1;
                    return j + 1;
                }
                // FORNLOOP / FORGLOOP back edges are owned by their prep
            }
        }
        const ir::IInsn& in = I(pc);
        if (in.name == "RETURN") return pc + 1;
        if (is_fornprep(in)) {
            // the latch is the FORNLOOP whose back edge returns to pc+1; the prep's exit target may
            // be threaded past the latch's fall-through
            int latch = -1;
            for (int q = pc + 1; q < end; ++q)
                if (I(q).name == "FORNLOOP" && I(q).target == pc + 1 && I(q).A == in.A) { latch = q; break; }
            if (latch < 0 || !lands(in.target, latch + 1)) return fail("FORN_SHAPE", pc), -1;
            const int exit = latch + 1;
            LoopCtx inner; inner.exit = exit; inner.cont = latch;
            if (!seq(pc + 1, latch, inner)) return -1;
            return exit;
        }
        if (is_forgprep(in)) {
            const int latch = in.target;
            if (latch <= pc || latch >= end || I(latch).name != "FORGLOOP") return fail("FORG_SHAPE", pc), -1;
            LoopCtx inner; inner.exit = latch + 1; inner.cont = latch;
            if (I(latch).target == latch + 1) {               // degenerate `for .. do break end`
                for (int q = pc + 1; q < latch; ++q) {}       // dead body: accepted unparsed
                return latch + 1;
            }
            if (!seq(pc + 1, latch, inner)) return -1;
            return latch + 1;
        }
        if (is_uncond(in)) {
            if (lands(in.target, ctx.exit) || lands(in.target, ctx.cont)) return pc + 1;   // break / continue
            return fail("STRAY_JUMP", pc), -1;
        }
        if (is_loadb_skip(in)) return fail("STRAY_LOADB_SKIP", pc), -1;
        if (is_loop_op(in)) return fail("STRAY_LOOP_OP", pc), -1;
        if (is_cond(pc)) return if_stmt(pc, end, ctx);
        return pc + 1;                                         // straight-line instruction
    }

    // comparison value: cmp -> pc+2 ; LOADB r,0,1 ; LOADB r,1,0
    bool cmp_value(int pc) const {
        return pc + 2 < n && I(pc).target == pc + 2 && I(pc + 1).name == "LOADB" && I(pc + 1).C == 1
            && I(pc + 2).name == "LOADB";
    }

    // if-statement whose condition chain starts with the test at pc
    int if_stmt(int pc, int end, const LoopCtx& ctx) {
        if (cmp_value(pc)) return pc + 3;
        // A test jumping to break / continue is `if c then break end` (no then-block).
        if (lands(I(pc).target, ctx.exit) || lands(I(pc).target, ctx.cont)) return pc + 1;
        // Grow the chain: tests at increasing pcs; candidate then-start S = after a test.
        std::vector<int> tests{pc};
        std::vector<int> starts{pc};   // chain boundary positions (setup of each test begins here)
        for (int k = pc; k < end; ) {
            const int S = k + 1;
            // targets must be the false label T (common, > S), S itself, or a later boundary
            int T = -1; bool ok = true;
            for (int t : tests) {
                const int tg = I(t).target;
                if (tg == S) continue;
                if (tg > S) { if (T < 0) T = tg; else if (T != tg) { ok = false; break; } }
                else {
                    bool boundary = false;
                    for (int b : starts) if (b == tg && b > t) boundary = true;
                    if (!boundary) { ok = false; break; }
                }
            }
            if (ok && T > end && lands(T, end)) T = end;
            if (ok && T > S && T <= end) {
                const int r = if_body(S, T, end, ctx);
                if (r >= 0) return r;
            }
            // extend the chain to the next test: setup instructions must be straight-line
            int q = S;
            while (q < end && !is_cond(q)) {
                const ir::IInsn& x = I(q);
                if (x.branch || x.name == "RETURN") break;
                ++q;
            }
            if (q >= end || !is_cond(q)) break;
            starts.push_back(S);
            tests.push_back(q);
            k = q;
        }
        return fail("IF_CHAIN", pc), -1;
    }

    int if_body(int S, int T, int end, const LoopCtx& ctx) {
        // else: a forward JUMP E at T-1 (not break/continue) with an else-block [T, E)
        if (T - 1 >= S) {
            const ir::IInsn& j = I(T - 1);
            int E = j.target;
            if (j.name == "JUMP" && E > end && lands(E, end)) E = end;
            if (j.name == "JUMP" && E > T && E <= end
                && !lands(j.target, ctx.exit) && !lands(j.target, ctx.cont)) {
                if (seq(S, T - 1, ctx) && seq(T, E, ctx)) return E;
                return -1;
            }
        }
        if (!seq(S, T, ctx)) return -1;
        return T;
    }
};

} // namespace inv

static int cmd_inverse_scan(int argc, char** argv) {
    ir_load_namebase();
    int files = 0, protos = 0, parsed = 0;
    bool verbose = false;
    std::map<std::string, int> reasons;
    for (int a = 2; a < argc; ++a) {
        const std::string path = argv[a];
        if (path == "--u44") { g_input_profile_u44 = true; continue; }
        if (path == "--verbose") { verbose = true; continue; }
        const std::string b = read_de_input(path);
        if (b.empty()) continue;
        de::Module m;
        try { m = de::walk(b); } catch (...) { continue; }
        ++files;
        const std::vector<std::string> pool = ir::parse_pool(b);
        for (size_t i = 0; i < m.protos.size(); ++i) {
            ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
            if (!ip.ok) continue;
            ++protos;
            inv::Grammar gr(ip);
            std::string why; int at = -1;
            if (gr.parse(why, at)) { ++parsed; continue; }
            ++reasons[why];
            if (verbose)
                std::printf("INVERSE_FAIL %s p%zu at=%d why=%s op=%s\n", path.c_str(), i, at, why.c_str(),
                            at >= 0 && at < (int)ip.code.size() ? ip.code[(size_t)at].name.c_str() : "-");
        }
    }
    std::printf("INVERSE_SCAN files=%d protos=%d parsed=%d failed=%d\n", files, protos, parsed, protos - parsed);
    for (const auto& r : reasons) std::printf("INVERSE_REASON %s %d\n", r.first.c_str(), r.second);
    return 0;
}
