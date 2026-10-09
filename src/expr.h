// expr.h — M6c: EXPRESSION RECONSTRUCTION.
//
// Turns the annotated IR (ir.h) into expression trees and statements, per basic block.
//
// Model: abstract interpretation over registers. Each instruction either
//   DEFINES  a register  -> reg[A] = <expression tree>
//   EMITS    a statement -> assignment / call-for-effect / return
//   is CONTROL FLOW      -> recorded for M6d to structure (not reconstructed here)
//   is SKIPPED           -> optimisation hints and prologue markers that carry no source meaning
//
// The acceptance metric is deliberately harsh: EVERY instruction must fall into one of those four
// buckets, and anything else is COUNTED as unhandled rather than silently ignored. Silence is how a
// decompiler ends up emitting plausible, wrong source.
//
// Scope of M6c: straight-line reconstruction WITHIN a basic block. Values that cross block
// boundaries stay as named locals; turning those into structured control flow is M6d.
#pragma once
#include <string>
#include <vector>
#include <memory>
#include <map>
#include <set>
#include <bitset>
#include <functional>
#include <cstdint>
#include "ir.h"
#include "liveness.h"

namespace ex {

enum class EK {
    Const,      // literal, already rendered by ir::KVal
    Reg,        // a register we have no better name for (crosses a block boundary)
    Upval,
    Global,     // _ENV.name  or an import path
    Field,      // obj.name
    Index,      // obj[key]
    Bin, Un, Concat,
    Call, Method,
    Table,
    Vararg,
    Closure,
    Unknown
};

struct Expr;
using EP = std::shared_ptr<Expr>;

struct Expr {
    EK k = EK::Unknown;
    std::string text;              // Const/Global/Field name/Bin op/Un op
    int reg = -1, idx = -1;        // Reg index / Upval index / Closure proto
    EP a, b;                       // operands / object
    std::vector<EP> list;          // call args, concat parts, table items
    int nres = 1;                  // Call: number of results (-1 = multret)
    bool multret = false;
};

inline EP mk(EK k) { auto e = std::make_shared<Expr>(); e->k = k; return e; }
inline EP mkconst(const std::string& t) { auto e = mk(EK::Const); e->text = t; return e; }
inline EP mkreg(int r) { auto e = mk(EK::Reg); e->reg = r; return e; }

// ---- precedence, so rendering parenthesises only where Lua requires it ----
inline int prec(const Expr& e) {
    if (e.k == EK::Bin) {
        const std::string& o = e.text;
        if (o == "or") return 1;
        if (o == "and") return 2;
        if (o == "<" || o == ">" || o == "<=" || o == ">=" || o == "~=" || o == "==") return 3;
        if (o == "..") return 4;
        if (o == "+" || o == "-") return 5;
        if (o == "*" || o == "/" || o == "//" || o == "%") return 6;
        if (o == "^") return 8;
    }
    if (e.k == EK::Un) return 7;
    return 99;                                   // atoms
}

inline std::string render(const EP& e);

inline std::string wrap(const EP& child, int parent_prec) {
    std::string s = render(child);
    if (child && prec(*child) < parent_prec) return "(" + s + ")";
    return s;
}

// A Lua postfix expression cannot begin with a primitive literal or an arbitrary value expression.
// Precedence alone is insufficient here because constants are classified as atoms: `nil.field`,
// `true[1]`, and `nil()` are still syntax errors even though no precedence parentheses are needed.
// Keep already-valid prefix/postfix forms unchanged and parenthesize every other base.  Besides
// making undefined-register recovery recompilable, this preserves the intended runtime failure
// (`(nil).field`) instead of turning a valid bytecode operation into invalid source.
inline std::string render_postfix_base(const EP& child) {
    const std::string rendered = render(child);
    if (!child) return "(nil)";
    switch (child->k) {
        case EK::Reg:
        case EK::Upval:
        case EK::Global:
        case EK::Field:
        case EK::Index:
        case EK::Call:
        case EK::Method:
            return rendered;
        default:
            return "(" + rendered + ")";
    }
}

inline bool is_ident(const std::string& s) {
    if (s.empty() || (!isalpha((unsigned char)s[0]) && s[0] != '_')) return false;
    for (char c : s) if (!isalnum((unsigned char)c) && c != '_') return false;
    static const std::set<std::string> kw = {"and","break","do","else","elseif","end","false","for",
        "function","if","in","local","nil","not","or","repeat","return","then","true","until","while",
        // NOTE: `type`, `export` and `continue` are CONTEXTUAL keywords in Luau, not reserved words —
        // `type` in particular is the STDLIB FUNCTION and appears constantly as a plain identifier.
        // Treating it as reserved sent every `type(x)` through the `_G[...]` fallback, emitting
        // `_G.type` where the original had a direct global read.
        };
    return !kw.count(s);
}

// `a`, or `math.floor`, or `Engine.Foo.Bar` — every dot-separated component a valid identifier.
inline bool is_dotted_path(const std::string& s) {
    if (s.empty()) return false;
    size_t i = 0;
    while (i <= s.size()) {
        size_t d = s.find('.', i);
        if (d == std::string::npos) d = s.size();
        if (!is_ident(s.substr(i, d - i))) return false;
        if (d == s.size()) break;
        i = d + 1;
    }
    return true;
}

inline std::string render(const EP& e) {
    if (!e) return "nil";
    char b[32];
    switch (e->k) {
        case EK::Const:  return e->text;
        case EK::Reg:    std::snprintf(b, sizeof b, "v%d", e->reg); return b;
        case EK::Upval:  std::snprintf(b, sizeof b, "u%d", e->idx); return b;
        // A recovered global name is not guaranteed to be a valid Lua identifier — a name-hash
        // resolving to e.g. "899c4c" emitted bare kills the whole file with "Malformed number".
        // But EK::Global ALSO carries IMPORT PATHS (`math.floor`), which are legitimately dotted;
        // testing with plain is_ident rewrote `math.floor` to `_G["math.floor"]` and regressed
        // ground truth 142 -> 136. Accept a dotted path, quote only what is genuinely unusable.
        case EK::Global:
            return is_dotted_path(e->text) ? e->text : ("_G[" + ir::quote_lua(e->text) + "]");
        case EK::Field:
            if (is_ident(e->text)) return render_postfix_base(e->a) + "." + e->text;
            return render_postfix_base(e->a) + "[" + ir::quote_lua(e->text) + "]";
        case EK::Index:  return render_postfix_base(e->a) + "[" + render(e->b) + "]";
        case EK::Bin: {
            int p = prec(*e);
            // ^ and .. are right-associative in Lua; the rest left.
            bool rightassoc = (e->text == "^" || e->text == "..");
            std::string L = wrap(e->a, rightassoc ? p + 1 : p);
            std::string R = wrap(e->b, rightassoc ? p : p + 1);
            return L + " " + e->text + " " + R;
        }
        case EK::Un: {
            std::string s = wrap(e->a, prec(*e));
            return (e->text == "not") ? ("not " + s) : (e->text + s);
        }
        case EK::Concat: {
            std::string s;
            for (size_t i = 0; i < e->list.size(); ++i) { if (i) s += " .. "; s += wrap(e->list[i], 5); }
            return s;
        }
        case EK::Call: {
            std::string s = render_postfix_base(e->a) + "(";
            for (size_t i = 0; i < e->list.size(); ++i) { if (i) s += ", "; s += render(e->list[i]); }
            return s + ")";
        }
        case EK::Method: {
            std::string s = render_postfix_base(e->a) + ":" + e->text + "(";
            for (size_t i = 0; i < e->list.size(); ++i) { if (i) s += ", "; s += render(e->list[i]); }
            return s + ")";
        }
        case EK::Table: {
            if (e->list.empty() && e->text.empty()) return "{}";
            if (!e->text.empty()) return e->text;                  // template rendered by ir.h
            std::string s = "{";
            for (size_t i = 0; i < e->list.size(); ++i) { if (i) s += ", "; s += render(e->list[i]); }
            return s + "}";
        }
        case EK::Vararg:  return "...";
        case EK::Closure:
            // `function<N|capture,capture,...>` — the captures let the inliner bind the sub-proto's
            // upvalues to real names in this scope.
            return "function<" + std::to_string(e->idx)
                 + (e->text.empty() ? "" : "|" + e->text) + ">";
        default:          return "--[[?]]nil";
    }
}

// ---------------------------------------------------------------- statements
enum class SK { Assign, Local, ExprStmt, Return, Branch, LoopCtl, Comment };

struct Stmt {
    SK k = SK::Comment;
    EP lhs, rhs;                       // Assign
    std::vector<EP> list;              // Return values
    std::string text;                  // Branch condition / comment
    int target = -1;                   // Branch target block
    int insn = -1;                     // source instruction index
    // CALL result registers before and after compiler-spill coalescing. Kept as integers so a
    // multi-result CALL followed by several MOVEs can retarget one output at a time without parsing
    // rendered source text.
    std::vector<int> call_sources, call_targets;
};

inline bool expr_uses_reg(const EP& e, int reg) {
    if (!e) return false;
    if (e->k == EK::Reg && e->reg == reg) return true;
    if (expr_uses_reg(e->a, reg) || expr_uses_reg(e->b, reg)) return true;
    for (const EP& item : e->list) if (expr_uses_reg(item, reg)) return true;
    return false;
}

inline bool stmt_uses_reg(const Stmt& s, int reg) {
    if (expr_uses_reg(s.lhs, reg) || expr_uses_reg(s.rhs, reg)) return true;
    for (const EP& item : s.list) if (expr_uses_reg(item, reg)) return true;
    return false;
}

// ---------------------------------------------------------------------------------------------
// INSTRUCTION-LEVEL REGISTER LIVENESS over the whole prototype (2026-10-09, DEFECTS #63/#64).
// The register coalescing rules below delete a register definition and let another register stand
// in for it. That is only the same program when the deleted register's value is read by nothing
// else, on ANY path -- including blocks after the current one. A scan of the current block's
// statements cannot see a read in a later block (the conditional reassignment + later read of a
// local), so those rules used to delete live locals. This is a backward may-liveness fixpoint over
// the bytecode CFG with the same edge model as m6d build_graph (JUMP/JUMPBACK/FORGPREP* are
// unconditional, LOADB C skips, RETURN ends, every other branch has target + fallthrough) and the
// shared register-effect model of liveness.h. Any instruction with an unknown register effect makes
// the whole prototype unknown, and every query then answers "live" (fail closed: no coalescing).
// Cached per prototype CONTENT (prototypes are annotated into temporaries whose addresses recur).
struct InsnLiveness {
    bool valid = false, known = false;
    int index = -1, maxstack = -1;
    size_t size = 0;
    uint64_t fingerprint = 0;
    std::vector<std::bitset<256>> defs, live_out;
};

inline uint64_t proto_code_fingerprint(const ir::IProto& ip) {
    uint64_t h = 1469598103934665603ull;
    auto mix = [&](uint64_t v) { h ^= v; h *= 1099511628211ull; };
    for (const ir::IInsn& in : ip.code) {
        mix(in.op); mix(in.A); mix(in.B); mix(in.C); mix((uint64_t)in.aux);
        mix((uint64_t)(int64_t)in.target); mix(in.branch ? 1 : 0);
    }
    return h;
}

inline void insn_successors(const ir::IProto& ip, int pc, std::vector<int>& out) {
    out.clear();
    const int n = (int)ip.code.size();
    const ir::IInsn& in = ip.code[(size_t)pc];
    auto add = [&](int s) { if (s >= 0 && s < n) out.push_back(s); };
    if (in.op == 0x29) return;                                                   // RETURN
    if (in.op == 0x04 && in.C) { add(pc + 1 + (int)in.C); return; }              // LOADB skip
    if (in.op == 0x40 || in.op == 0x25 || in.op == 0x30 || in.op == 0x1b || in.op == 0x0b) {
        if (in.branch) add(in.target);                                           // unconditional
        return;
    }
    if (in.branch) add(in.target);
    add(pc + 1);
}

inline const InsnLiveness& insn_liveness(const ir::IProto& ip) {
    static thread_local InsnLiveness cache;
    const uint64_t fingerprint = proto_code_fingerprint(ip);
    if (cache.valid && cache.index == ip.index && cache.maxstack == ip.maxstack
        && cache.size == ip.code.size() && cache.fingerprint == fingerprint) return cache;
    InsnLiveness a;
    a.valid = true; a.index = ip.index; a.maxstack = ip.maxstack; a.size = ip.code.size();
    a.fingerprint = fingerprint;
    const int n = (int)ip.code.size();
    std::vector<std::bitset<256>> uses((size_t)n), live_in((size_t)n);
    a.defs.assign((size_t)n, {}); a.live_out.assign((size_t)n, {});
    std::vector<std::vector<int>> succ((size_t)n);
    a.known = ip.maxstack <= 256;
    for (int pc = 0; a.known && pc < n; ++pc) {
        std::set<int> u, d;
        if (!lv::register_effects(ip, ip.code[(size_t)pc], u, d)) { a.known = false; break; }
        for (int r : u) if (r >= 0 && r < 256) uses[(size_t)pc].set((size_t)r);
        for (int r : d) if (r >= 0 && r < 256) a.defs[(size_t)pc].set((size_t)r);
        insn_successors(ip, pc, succ[(size_t)pc]);
    }
    if (a.known) {
        bool changed = true;
        int guard = 0;
        while (changed && guard++ < 100000) {
            changed = false;
            for (int pc = n - 1; pc >= 0; --pc) {
                std::bitset<256> out;
                for (int s : succ[(size_t)pc]) out |= live_in[(size_t)s];
                std::bitset<256> in = uses[(size_t)pc] | (out & ~a.defs[(size_t)pc]);
                if (out != a.live_out[(size_t)pc] || in != live_in[(size_t)pc]) {
                    a.live_out[(size_t)pc] = out; live_in[(size_t)pc] = in; changed = true;
                }
            }
        }
        if (changed) a.known = false;                                            // no fixpoint: fail closed
    }
    cache = std::move(a);
    return cache;
}

// Is the value register `reg` holds right after instruction `pc` read on any path? True (live)
// whenever the prototype's effects are unknown. An instruction that itself writes `reg` ends the
// value it read, so the register is dead after it.
inline bool register_live_after(const ir::IProto& ip, int pc, int reg) {
    if (pc < 0 || pc >= (int)ip.code.size() || reg < 0 || reg >= 256) return true;
    const InsnLiveness& a = insn_liveness(ip);
    if (!a.known) return true;
    if (a.defs[(size_t)pc].test((size_t)reg)) return false;
    return a.live_out[(size_t)pc].test((size_t)reg);
}

// Does any instruction strictly between `from` and `to` (straight-line, same block) write `reg`?
inline bool register_written_between(const ir::IProto& ip, int from, int to, int reg) {
    if (reg < 0 || reg >= 256) return true;
    const InsnLiveness& a = insn_liveness(ip);
    if (!a.known) return true;
    for (int pc = from + 1; pc < to && pc < (int)ip.code.size(); ++pc)
        if (pc >= 0 && a.defs[(size_t)pc].test((size_t)reg)) return true;
    return false;
}

// `use_pc` is the instruction that consumes the folded value (CALL, CONCAT, SETLIST or RETURN).
inline void fold_pure_setup_move(std::vector<Stmt>& statements, EP& value,
                                 const ir::IProto& ip, int use_pc) {
    if (!value || value->k != EK::Reg) return;
    int reg = value->reg, candidate = -1;
    for (int q = (int)statements.size() - 1; q >= 0; --q) {
        const Stmt& stmt = statements[q];
        if (stmt.k != SK::Assign || !stmt.lhs || stmt.lhs->k != EK::Reg
            || stmt.lhs->reg != reg) continue;
        if (stmt.rhs && stmt.rhs->k == EK::Reg) candidate = q;
        break;
    }
    if (candidate < 0) return;
    for (int q = candidate + 1; q < (int)statements.size(); ++q)
        if (stmt_uses_reg(statements[q], reg)) return;
    // LIVE DESTINATION GUARD (2026-10-09, DEFECTS #63). Deleting `vR = vS` is only exact when the
    // copy's value is read by THIS use and nothing else. The statement scan above sees the rest of
    // this block only; a local copied here and read again in a later block (`local target =
    // entity; if target:IsA(k) then target = target:GetOwner() end; target:Name()`) lost its only
    // assignment and the later read saw nil. Require the destination to be dead after the use on
    // every path (prototype-wide liveness) and not rewritten between the copy and the use (a
    // multi-target `vR, vX = f()` is invisible to the statement scan).
    // RENOVICE_NO_COALESCE_LIVE_DEST_GUARD restores the block-local rule for A/B.
    static const bool live_dest_guard = !std::getenv("RENOVICE_NO_COALESCE_LIVE_DEST_GUARD");
    if (live_dest_guard) {
        const int copy_pc = statements[candidate].insn;
        if (copy_pc < 0 || copy_pc >= use_pc) return;
        if (register_written_between(ip, copy_pc, use_pc, reg)) return;
        if (register_live_after(ip, use_pc, reg)) return;
    }
    // The fold reads the copy's SOURCE register at the use instead of at the MOVE. That is the
    // same value only if no later statement in this block rewrites the source. An inlined call
    // result built in a scratch register (`vB = {..}; vA = vB; vB = scaleAmount; f(vA, vB)`)
    // otherwise passed scaleAmount twice and lost the table. RENOVICE_NO_CALLCOALESCE_SOURCE_GUARD
    // restores the unguarded fold for A/B.
    static const bool unguarded = std::getenv("RENOVICE_NO_CALLCOALESCE_SOURCE_GUARD") != nullptr;
    const EP& source = statements[candidate].rhs;
    if (!unguarded && source && source->k == EK::Reg) {
        const int src = source->reg;
        const std::string word = "v" + std::to_string(src);
        for (int q = candidate + 1; q < (int)statements.size(); ++q) {
            const Stmt& later = statements[q];
            if (later.k != SK::Assign || !later.lhs) continue;
            if (later.lhs->k == EK::Reg && later.lhs->reg == src) return;
            for (int target : later.call_targets) if (target == src) return;
            if (later.lhs->k == EK::Const) {           // multi-target `vA, vB` text: fail closed
                const std::string& t = later.lhs->text;
                for (size_t at = t.find(word); at != std::string::npos; at = t.find(word, at + 1)) {
                    const size_t end = at + word.size();
                    const bool left = at == 0 || !std::isalnum((unsigned char)t[at - 1]);
                    const bool right = end >= t.size() || !std::isalnum((unsigned char)t[end]);
                    if (left && right) return;
                }
            }
        }
    }
    value = statements[candidate].rhs;
    statements.erase(statements.begin() + candidate);
}

// Per-instruction disposition — this IS the acceptance metric.
enum class Disp { Expr, Stmt, Ctrl, Skip, UNHANDLED };

struct BlockOut {
    int first = 0, last = 0;
    std::vector<Stmt> stmts;
};

struct ProtoOut {
    std::vector<BlockOut> blocks;
    long long n_expr = 0, n_stmt = 0, n_ctrl = 0, n_skip = 0, n_unhandled = 0;
    std::map<std::string, long long> unhandled;
};

// ---------------------------------------------------------------------------------------------
// Reconstruct one basic block. Registers are an abstract environment: reg[r] holds the expression
// that produced the value currently in r. A register we have not seen defined in THIS block is a
// value that crossed a block boundary, so it renders as a named local (v<N>) — resolving those into
// real control flow and scoping is M6d's job, not a fudge here.
// ---------------------------------------------------------------------------------------------
struct RegEnv {
    std::map<int, EP> r;
    // `top` = highest register written so far. Luau encodes "all values up to the top of the stack"
    // as B==0 / C==0 (multret): `f(g(x))`, `return f(x)`, `{...}` with a trailing call. Treating that
    // as ZERO values silently drops arguments and return values — `math.floor(math.abs(a))` came out
    // as `math.floor()`. Tracking the high-water mark resolves those ranges concretely.
    int top = -1;
    EP get(int i) { auto it = r.find(i); return it != r.end() ? it->second : mkreg(i); }
    void set(int i, EP e) { r[i] = e; if (i > top) top = i; }
    void kill(int i) { r.erase(i); }
};

inline const char* binop_for(uint8_t op) {
    switch (op) {
        case 0x49: case 0x38: return "+";
        case 0x07: case 0x3e: case 0x06: return "-";
        case 0x22: case 0x09: return "*";
        case 0x1a: case 0x32: case 0x3b: return "/";
        case 0x55: case 0x3c: return "%";
        case 0x45: case 0x08: return "^";
        case 0x00: case 0x24: return "//";
        case 0x2f: case 0x31: return "and";
        case 0x2b: case 0x51: return "or";
        default: return nullptr;
    }
}

// DEFECTS #51: does anything read table register `reg` between its latest NEWTABLE/DUPTABLE
// creation (scanning back in instruction order) and instruction `at`? Any other definition, an
// unknown effect model or a read on any intervening path answers yes (fail safe: the caller then
// stores into the existing table, which is exact either way).
inline bool setlist_table_observed(const ir::IProto& ip, int at, int reg) {
    for (int q = at - 1; q >= 0 && q < (int)ip.code.size(); --q) {
        const ir::IInsn& in = ip.code[q];
        std::set<int> uses, defs;
        if (!lv::register_effects(ip, in, uses, defs)) return true;
        if (uses.count(reg)) return true;
        if (defs.count(reg)) return !(in.op == 0x2c || in.op == 0x4f);
    }
    return true;
}

// LATER SETLIST BATCH MERGE (2026-10-09, DEFECTS #66). A list constructor with more than 16 items
// compiles to NEWTABLE, items 1..16 into temporaries, SETLIST aux=1, items 17.. into the SAME
// temporaries, SETLIST aux=17, ... The first batch became `vA = {v1, ..., v16}`; every later batch
// was printed as index stores `vA[17] = v1` (SETTABLEN), which is not the stock program shape.
// Merge a later batch into the constructor itself: `vA = {v1, ..., v16, <item 17>, ...}`, with each
// later item's computation substituted from the statements that produced it. Exact only when
//   - the latest statement defining vA in this block is that constructor (plain list, no template,
//     not multret) holding exactly aux-1 items, and every statement after it is a single-register
//     assignment (the later batch's item computations, nothing else);
//   - every value those statements compute is consumed exactly once, by a later one of them or by an
//     item (no computation dropped or duplicated) and its register is dead after the SETLIST;
//   - no remaining register read inside the merged items is written by those statements, and none
//     reads vA (moving the computations to the constructor must not change any value they read);
//   - the effectful computations (anything but a constant or a register copy) keep their order:
//     the left-to-right evaluation order of the merged items equals the statement order;
//   - when vA is captured BY REFERENCE anywhere in the prototype, no merged item can run code (a
//     call, method call, indexing, arithmetic, length or concatenation could reach a closure that
//     observes the partially filled table); a by-value capture cannot observe it (no computation
//     here creates a closure). No computation is a closure (its capture list names registers
//     textually).
// Otherwise the index-store form is kept. RENOVICE_NO_SETLIST_BATCH_MERGE restores it everywhere.
inline bool merge_setlist_batch(std::vector<Stmt>& stmts, const ir::IProto& ip, int setlist_pc,
                                int table_reg, int aux, const std::vector<EP>& items, bool multret) {
    static const bool trace = std::getenv("RENOVICE_SETLIST_TRACE") != nullptr;
    auto refuse = [&](int reason) {
        if (trace) std::fprintf(stderr, "SETLIST_BATCH_MERGE proto=%d pc=%d aux=%d refused=%d\n",
                                ip.index, setlist_pc, aux, reason);
        return false;
    };
    int ctor = -1;
    for (int q = (int)stmts.size() - 1; q >= 0; --q) {
        const Stmt& s = stmts[(size_t)q];
        if (s.k == SK::Assign && s.lhs && s.lhs->k == EK::Reg && s.lhs->reg == table_reg) { ctor = q; break; }
    }
    if (ctor < 0) return refuse(1);
    Stmt& c = stmts[(size_t)ctor];
    if (!c.rhs || c.rhs->k != EK::Table || !c.rhs->text.empty() || c.rhs->multret
        || (int)c.rhs->list.size() != aux - 1) return refuse(2);
    bool ref_captured = false;
    for (const ir::IInsn& in : ip.code)
        if (in.op == 0x35 && in.A == 1 && (int)in.B == table_reg) ref_captured = true;
    struct Avail { EP expr; bool consumed = false; };
    std::map<int, Avail> avail;
    std::set<int> written;
    std::map<const Expr*, int> effect_id;
    std::vector<int> effectful;
    bool ok = true;
    // copy-on-write substitution of available register values
    std::function<EP(const EP&)> subst = [&](const EP& e) -> EP {
        if (!e || !ok) return e;
        if (e->k == EK::Closure) { ok = false; return e; }
        if (e->k == EK::Reg) {
            if (e->reg == table_reg) { ok = false; return e; }
            auto it = avail.find(e->reg);
            if (it != avail.end() && !it->second.consumed) { it->second.consumed = true; return it->second.expr; }
            if (written.count(e->reg)) ok = false;             // a rewritten or twice-read value
            return e;
        }
        EP a = subst(e->a), b = subst(e->b);
        std::vector<EP> list;
        bool changed = a != e->a || b != e->b;
        for (const EP& item : e->list) { list.push_back(subst(item)); if (list.back() != item) changed = true; }
        if (!changed) return e;
        auto copy = std::make_shared<Expr>(*e);
        copy->a = a; copy->b = b; copy->list = list;
        return copy;
    };
    for (size_t q = (size_t)ctor + 1; q < stmts.size() && ok; ++q) {
        const Stmt& s = stmts[q];
        if (s.k != SK::Assign || !s.lhs || s.lhs->k != EK::Reg || !s.rhs) return refuse(4);
        if (s.call_sources.size() > 1 || s.call_targets.size() > 1) return refuse(5);
        const int r = s.lhs->reg;
        if (r == table_reg) return refuse(6);
        EP value = subst(s.rhs);
        if (!ok) return refuse(7);
        auto prior = avail.find(r);
        if (prior != avail.end() && !prior->second.consumed) return refuse(8);     // a computation dropped
        if (value->k != EK::Const && value->k != EK::Reg) {
            value = std::make_shared<Expr>(*value);                            // unique node per statement
            effect_id[value.get()] = (int)q;
            effectful.push_back((int)q);
        }
        avail[r] = Avail{value, false};
        written.insert(r);
    }
    std::vector<EP> merged;
    for (const EP& item : items) { merged.push_back(subst(item)); if (!ok) return refuse(9); }
    for (const auto& entry : avail) if (!entry.second.consumed) return false;
    for (int r : written) if (register_live_after(ip, setlist_pc, r)) return refuse(10);
    std::vector<int> order;
    bool runs_code = false;
    std::function<void(const EP&)> post = [&](const EP& e) {
        if (!e) return;
        if (e->k == EK::Call || e->k == EK::Method || e->k == EK::Field || e->k == EK::Index
            || e->k == EK::Bin || e->k == EK::Un || e->k == EK::Concat) runs_code = true;
        post(e->a); post(e->b);
        for (const EP& item : e->list) post(item);
        auto it = effect_id.find(e.get());
        if (it != effect_id.end()) order.push_back(it->second);
    };
    for (const EP& item : merged) post(item);
    if (order != effectful) return refuse(11);
    if (ref_captured && runs_code) return refuse(3);
    auto table = std::make_shared<Expr>(*c.rhs);
    for (const EP& item : merged) table->list.push_back(item);
    table->multret = multret;
    c.rhs = table;
    // The constructor now completes at this SETLIST: keep the convention of the single-batch
    // constructor (statement instruction = its last SETLIST), which the adjacent table-move retarget
    // (`NEWTABLE..SETLIST; MOVE dst, tmp`) relies on. Leaving the first batch's pc made every round
    // trip keep `tmp = {...}; dst = tmp` and declare one more local (compiler closure diverged).
    c.insn = setlist_pc;
    stmts.erase(stmts.begin() + ctor + 1, stmts.end());
    return true;
}

inline void reconstruct_block(const ir::IProto& ip, int first, int last,
                              ProtoOut& out, BlockOut& bo) {
    RegEnv env;
    auto K = [&](int i) -> EP {
        if (i < 0 || i >= (int)ip.consts.size()) return mkconst("nil");
        return mkconst(ir::value_text(ip.consts[i]));
    };
    for (int i = first; i <= last && i < (int)ip.code.size(); ++i) {
        const ir::IInsn& in = ip.code[i];
        uint8_t op = in.op;
        Disp d = Disp::UNHANDLED;

        // MATERIALISE every register definition as a real assignment. The previous model propagated
        // the defining EXPRESSION into the register and only emitted it where it was consumed, which
        // is wrong in two ways: (1) a value defined in one block and read in another was NEVER
        // assigned -- it silently read nil, and since every register is declared local at function
        // top it still COMPILED; (2) identity-bearing values were re-materialised at each use, so
        // `local t={a,b}; t[a]=b; return t` built three separate tables. Emitting `vA = <expr>` at
        // the definition point is a literal translation of the register machine and cannot be wrong.
        // Re-inlining single-use temporaries is a readability pass that must be proven separately.
        auto def_ = [&](int a, EP e) {
            Stmt s; s.k = SK::Assign; s.lhs = mkreg(a); s.rhs = e; s.insn = i;
            bo.stmts.push_back(s);
            env.set(a, mkreg(a));
        };

        // ---- pure value definitions -------------------------------------------------
        if      (op == 0x12) { def_(in.A, mkconst(std::to_string((int)(int16_t)in.Bx))); d = Disp::Expr; }
        else if (op == 0x4e) { def_(in.A, K(in.Bx)); d = Disp::Expr; }
        else if (op == 0x0d) {
            // `local a, b, ...` compiles to entry LOADNIL instructions. This emitter already writes
            // the matching function-scope `local` declaration, so materialising those same LOADNILs
            // as `a = nil` creates one additional explicit initializer on every round trip. Suppress
            // only the entry prologue and never a parameter reset or a later semantic nil assignment.
            bool prologue_nil = !std::getenv("RENOVICE_NO_PROLOGUE_NIL") && first == 0
                             && in.A >= ip.nparams;
            for (int q = 0; prologue_nil && q < i; ++q)
                if (ip.code[q].op != 0x0d && ip.code[q].op != 0x11) prologue_nil = false;
            // LOOP-HEADED ENTRY (2026-09-30, DEFECTS #47). When the function body IS a loop whose
            // first statement is `local x = nil` (`while true do local idx = nil; for ... end end`),
            // instruction 0 is also the loop header: a back edge targets it and the LOADNIL resets
            // x on EVERY iteration. Suppressing it as prologue carried the previous iteration's
            // value forward (cfg-identity cannot see it: LOADNIL is epsilon). Keep it as `x = nil`
            // when any branch targets the entry block. RENOVICE_NO_LOOP_ENTRY_NIL restores the old
            // suppression.
            static const bool loop_entry_nil = !std::getenv("RENOVICE_NO_LOOP_ENTRY_NIL");
            for (size_t q = 0; prologue_nil && loop_entry_nil && q < ip.code.size(); ++q)
                if (ip.code[q].target == 0) prologue_nil = false;
            if (prologue_nil) env.set(in.A, mkreg(in.A));
            else def_(in.A, mkconst("nil"));
            d = Disp::Expr;
        }
        else if (op == 0x04) { def_(in.A, mkconst(in.B ? "true" : "false")); d = Disp::Expr; }
        else if (op == 0x14) {
            // Luau places a CALL above every function-scope local, then commonly moves the one
            // result back down on the next instruction. Materialising that compiler spill as a new
            // permanent source local makes the next compiler place its call frame even higher.
            // Retarget the immediately preceding single-result call instead: the MOVE has no
            // independent value or timing, and CALL already defined exactly the value being moved.
            bool retargeted = false;
            if (!std::getenv("RENOVICE_NO_CALLCOALESCE") && !bo.stmts.empty()) {
                Stmt& prior = bo.stmts.back();
                if (prior.k == SK::Assign && prior.rhs
                    && (prior.rhs->k == EK::Call || prior.rhs->k == EK::Method)) {
                    if (prior.rhs->nres == 1 && prior.insn == i - 1 && prior.lhs
                        && prior.lhs->k == EK::Reg && prior.lhs->reg == in.B) {
                        prior.lhs = mkreg(in.A);
                        env.kill(in.B);
                        env.set(in.A, mkreg(in.A));
                        retargeted = true;
                    } else if (prior.rhs->nres > 1
                               && prior.call_sources.size() == prior.call_targets.size()) {
                        int slot = -1;
                        for (size_t q = 0; q < prior.call_sources.size(); ++q)
                            if (prior.call_sources[q] == in.B
                                && prior.call_targets[q] == prior.call_sources[q]) {
                                slot = (int)q; break;
                            }
                        // No emitted statement may intervene: successfully folded earlier result
                        // MOVEs leave this CALL as bo.stmts.back(). Raw result MOVEs are consecutive.
                        //
                        // LIVE SOURCE GUARD (2026-10-09, DEFECTS #64, multi-result form). Retargeting
                        // removes the result's own register; only exact when it is dead after the
                        // MOVE. `local b, c = G(); a, d = b, c` retargeted both results into a, d and
                        // left the locals b, c unassigned (read later as nil). The single-result
                        // form is restored at render time (emit.h RESTORE_LIVE_CALL_MOVE); the
                        // multi-result `vA, vB = call` form had no such check.
                        // RENOVICE_NO_CALLMOVE_LIVE_SOURCE_GUARD restores the unguarded retarget.
                        static const bool call_live_source_guard
                            = !std::getenv("RENOVICE_NO_CALLMOVE_LIVE_SOURCE_GUARD");
                        if (slot >= 0 && call_live_source_guard && in.A != in.B
                            && register_live_after(ip, i, (int)in.B)) slot = -1;
                        if (slot >= 0 && i == prior.insn + 1 + slot) {
                            prior.call_targets[slot] = in.A;
                            std::string targets;
                            for (size_t q = 0; q < prior.call_targets.size(); ++q) {
                                if (q) targets += ", ";
                                targets += "v" + std::to_string(prior.call_targets[q]);
                            }
                            prior.lhs = mkconst(targets);
                            env.kill(in.B);
                            env.set(in.A, mkreg(in.A));
                            retargeted = true;
                        }
                    }
                }

                // Luau also allocates a table above function-scope locals, then immediately moves
                // the new identity into its real destination:
                //
                //     DUPTABLE R13; MOVE R8, R13
                //
                // If emitted literally, R13 becomes a declared source local. On recompilation that
                // declaration pushes the next DUPTABLE to R14, producing an unbounded
                // LOADNIL+DUPTABLE+MOVE chain. Retargeting the allocation statement to R8 preserves
                // the allocation point and the single table identity; only the compiler's pure,
                // adjacent copy is removed. Keep this deliberately narrower than general expression
                // coalescing: calls have their separately proven rule above, and other expressions
                // may observe evaluation order or register reuse differently.
                //
                // LIVE SOURCE GUARD (2026-10-09, DEFECTS #64). The retarget deletes the table's
                // own register: only exact when that register is dead after the MOVE. `local names
                // = {}; table.insert(names, x); ...; Create(names)` copies the local into the
                // argument slot and reads it again later; retargeting left `names` unassigned.
                // RENOVICE_NO_TABLEMOVE_LIVE_SOURCE_GUARD restores the unguarded retarget for A/B.
                static const bool table_live_source_guard
                    = !std::getenv("RENOVICE_NO_TABLEMOVE_LIVE_SOURCE_GUARD");
                if (!retargeted && !std::getenv("RENOVICE_NO_TABLEMOVECOALESCE")) {
                    if (prior.k == SK::Assign && prior.rhs && prior.rhs->k == EK::Table
                        && prior.insn == i - 1 && prior.lhs && prior.lhs->k == EK::Reg
                        && prior.lhs->reg == in.B
                        && !(table_live_source_guard && in.A != in.B
                             && register_live_after(ip, i, (int)in.B))) {
                        prior.lhs = mkreg(in.A);
                        env.kill(in.B);
                        env.set(in.A, mkreg(in.A));
                        retargeted = true;
                    }
                }
            }
            if (!retargeted) def_(in.A, env.get(in.B));
            d = Disp::Expr;
        }
        else if (op == 0x13) { auto e = mk(EK::Upval); e->idx = in.B; def_(in.A, e); d = Disp::Expr; }
        else if (op == 0x17 || op == 0x46) {                       // GETGLOBAL / GETIMPORT
            auto e = mk(EK::Global); e->text = in.note.empty() ? "nil" : in.note;
            def_(in.A, e); d = Disp::Expr;
        }
        else if (op == 0x3d) {                                     // GETFIELD
            auto e = mk(EK::Field); e->a = env.get(in.B); e->text = in.note;
            def_(in.A, e); d = Disp::Expr;
        }
        else if (op == 0x01) {                                     // GETTABLE (register key)
            auto e = mk(EK::Index); e->a = env.get(in.B); e->b = env.get(in.C);
            def_(in.A, e); d = Disp::Expr;
        }
        else if (op == 0x44) {                                     // GETTABLEN (small int key)
            auto e = mk(EK::Index); e->a = env.get(in.B); e->b = mkconst(std::to_string(in.C + 1));
            def_(in.A, e); d = Disp::Expr;
        }
        else if (op == 0x2c) { def_(in.A, mk(EK::Table)); d = Disp::Expr; }   // NEWTABLE
        else if (op == 0x4f) {                                                   // DUPTABLE
            auto e = mk(EK::Table);
            if (in.Bx < (int)ip.consts.size()) e->text = ip.consts[in.Bx].text;
            def_(in.A, e); d = Disp::Expr;
        }
        else if (op == 0x16 || op == 0x42) {                                     // NEW/DUPCLOSURE
            // The CAPTURE instructions that FOLLOW a closure say where each of its upvalues comes
            // from in THIS proto: `CAPTURE A B` with A = 0 VAL / 1 REF (B is a register) or 2 UPVAL
            // (B is one of our OWN upvalues). Without recording them the inlined body emits a bare
            // `u0`, which is bound to nothing and silently reads a nil GLOBAL. Carry the list in the
            // placeholder so the inliner can rewrite `u<i>` to the parent's name.
            // NEWCLOSURE (0x16) takes an index into the CURRENT PROTO'S CHILD LIST, while
            // DUPCLOSURE (0x42) takes a CONSTANT index whose tag-6 payload holds the flat/global
            // sub-proto index. Treating either Bx as the other namespace silently selects the wrong
            // function. Treating DUPCLOSURE's Bx
            // as a proto index inlines the WRONG FUNCTION -- `f` came out as its own inner closure `g`
            // -- and it compiles fine because any proto is syntactically a valid function.
            auto e = mk(EK::Closure);
            if (op == 0x42 && in.Bx < (int)ip.consts.size()
                && ip.consts[in.Bx].kind == ir::KKind::Closure)
                e->idx = (int)ip.consts[in.Bx].sub;          // DUPCLOSURE: constant -> proto index
            else if (op == 0x16 && in.Bx < (int)ip.kids.size())
                e->idx = (int)ip.kids[in.Bx];                // NEWCLOSURE: CHILD index -> proto index
            else
                e->idx = in.Bx;
            // BY-VALUE CAPTURE SNAPSHOT (2026-09-30, DEFECTS #52). `CAPTURE 0 R` copies R's value
            // into the closure at creation. The source local it names is flat here (`vR`, one
            // variable per register for the whole function), so when anything else in the function
            // also writes R -- the next iteration of a loop, or a later local reusing the register
            // -- a closure capturing `vR` by name saw the LAST value instead of its own
            // (EE_Interface_Components_List Redraw p54 pc 308: per-element transition callbacks
            // all targeted the last element). Snapshot such a register into a fresh block local
            // just before the closure and capture that. RENOVICE_NO_CAPTURE_SNAPSHOT restores the
            // shared name.
            static const bool capture_snapshot = !std::getenv("RENOVICE_NO_CAPTURE_SNAPSHOT");
            // Is `reg` written by an instruction reachable from the closure (loop back edges
            // included)? Only such a write can change what a by-name capture would read later.
            auto register_written_elsewhere = [&](int reg) {
                const int n = (int)ip.code.size();
                std::vector<char> seen((size_t)n, 0);
                std::vector<int> todo{i + 1};
                while (!todo.empty()) {
                    const int pc = todo.back(); todo.pop_back();
                    if (pc < 0 || pc >= n || seen[(size_t)pc]) continue;
                    seen[(size_t)pc] = 1;
                    const ir::IInsn& other = ip.code[(size_t)pc];
                    std::set<int> uses, defs;
                    if (!lv::register_effects(ip, other, uses, defs)) return true;   // fail safe
                    if (defs.count(reg) && other.op != 0x35) return true;
                    const int op2 = other.op;
                    if (op2 == 0x29) continue;                                        // RETURN
                    if (op2 == 0x40 || op2 == 0x25 || op2 == 0x30 || op2 == 0x1b || op2 == 0x0b) {
                        todo.push_back(other.target); continue;                        // jumps / FORGPREP
                    }
                    if (other.branch) todo.push_back(other.target);
                    if (op2 == 0x04 && other.C) { todo.push_back(pc + 1 + other.C); continue; }
                    todo.push_back(pc + 1);
                }
                return false;
            };
            for (int q = i + 1; q < (int)ip.code.size() && ip.code[q].op == 0x35; ++q) {
                if (!e->text.empty()) e->text += ",";
                const ir::IInsn& c = ip.code[q];
                if (capture_snapshot && c.A == 0 && register_written_elsewhere((int)c.B)) {
                    // Name = prototype + ordinal of this CAPTURE among the prototype's CAPTUREs,
                    // so a re-decompile of our own output reproduces the same name.
                    int capture_ordinal = 0;
                    for (int k = 0; k < q; ++k) if (ip.code[(size_t)k].op == 0x35) ++capture_ordinal;
                    const std::string snapshot = "__renovice_capture_" + std::to_string(ip.index)
                                               + "_" + std::to_string(capture_ordinal);
                    // Compiler closure: our own snapshot `local s = vX` compiles to MOVE R <- X with
                    // R read only by CAPTUREs. Re-snapshotting R added `vR = vX` plus a new local on
                    // every round. When R is read by nothing but captures and its latest definition
                    // in this block is that copy, turn the copy itself back into the snapshot.
                    // The value a copy at `from` writes into R is read only by CAPTUREs: follow
                    // every path from `from` until R is written again.
                    auto copy_only_captured = [&](int from) {
                        const int n = (int)ip.code.size();
                        std::vector<char> seen((size_t)n, 0);
                        std::vector<int> todo{from + 1};
                        while (!todo.empty()) {
                            const int pc = todo.back(); todo.pop_back();
                            if (pc < 0 || pc >= n || seen[(size_t)pc]) continue;
                            seen[(size_t)pc] = 1;
                            const ir::IInsn& other = ip.code[(size_t)pc];
                            std::set<int> uses, defs;
                            if (!lv::register_effects(ip, other, uses, defs)) return false;
                            if (uses.count((int)c.B) && other.op != 0x35) return false;
                            if (defs.count((int)c.B)) continue;
                            const int op2 = other.op;
                            if (op2 == 0x29) continue;
                            if (op2 == 0x40 || op2 == 0x25 || op2 == 0x30 || op2 == 0x1b || op2 == 0x0b) {
                                todo.push_back(other.target); continue;
                            }
                            if (other.branch) todo.push_back(other.target);
                            if (op2 == 0x04 && other.C) { todo.push_back(pc + 1 + other.C); continue; }
                            todo.push_back(pc + 1);
                        }
                        return true;
                    };
                    bool reused_copy = false;
                    for (int k = (int)bo.stmts.size() - 1; k >= 0; --k) {
                        Stmt& prior = bo.stmts[(size_t)k];
                        if (prior.k == SK::Assign && prior.lhs && prior.lhs->k == EK::Reg
                            && prior.lhs->reg == (int)c.B && prior.rhs
                            && prior.insn >= 0 && prior.insn < (int)ip.code.size()
                            && ip.code[(size_t)prior.insn].op == 0x14
                            && !expr_uses_reg(prior.rhs, (int)c.B)
                            && copy_only_captured(prior.insn)) {
                            prior.lhs = mkconst("local " + snapshot);
                            reused_copy = true;
                            break;
                        }
                        if (stmt_uses_reg(prior, (int)c.B)) break;
                    }
                    if (!reused_copy) {
                        Stmt s; s.k = SK::Assign; s.lhs = mkconst("local " + snapshot);
                        s.rhs = mkreg((int)c.B); s.insn = i;
                        bo.stmts.push_back(s);
                    }
                    e->text += snapshot;
                    continue;
                }
                e->text += (c.A == 2 ? "u" : "v") + std::to_string((int)c.B);
            }
            def_(in.A, e); d = Disp::Expr;
        }
        else if (op == 0x4c) {                                                   // GETVARARGS A B
            // B-1 values land in A..A+B-2, so `local a, b = ...` writes TWO registers. Defining only
            // A left the rest unassigned (silently nil). B == 0 is multret and must stay propagated.
            int nv = (int)in.B - 1;
            if (nv <= 0) { env.set(in.A, mk(EK::Vararg)); env.top = in.A; }
            else if (nv == 1) def_(in.A, mk(EK::Vararg));
            else {
                std::string tgt;
                for (int r = in.A; r < in.A + nv; ++r) {
                    if (r > in.A) tgt += ", ";
                    tgt += "v" + std::to_string(r);
                }
                Stmt s; s.k = SK::Assign; s.lhs = mkconst(tgt); s.rhs = mk(EK::Vararg); s.insn = i;
                bo.stmts.push_back(s);
                for (int r = in.A; r < in.A + nv; ++r) env.set(r, mkreg(r));
            }
            d = Disp::Expr;
        }
        else if (op == 0x0e || op == 0x50 || op == 0x4d) {                        // MINUS / NOT / LENGTH
            auto e = mk(EK::Un); e->text = (op==0x0e) ? "-" : (op==0x50 ? "not" : "#");
            e->a = env.get(in.B); def_(in.A, e); d = Disp::Expr;
        }
        else if (op == 0x28) {                                                   // CONCAT B..C
            auto e = mk(EK::Concat);
            for (int r = in.B; r <= in.C; ++r) e->list.push_back(env.get(r));
            if (!std::getenv("RENOVICE_NO_CALLCOALESCE"))
                for (EP& item : e->list) fold_pure_setup_move(bo.stmts, item, ip, i);
            def_(in.A, e); d = Disp::Expr;
        }
        else if (const char* bo_op = binop_for(op)) {
            auto e = mk(EK::Bin); e->text = bo_op;
            // three operand shapes: reg-reg, reg-const (C), const-reg (B)
            bool kc = (op==0x38||op==0x3e||op==0x09||op==0x32||op==0x3c||op==0x08||op==0x24||
                       op==0x31||op==0x51);
            bool kb = (op==0x06||op==0x3b);
            if (kb) { e->a = K(in.B); e->b = env.get(in.C); }
            else if (kc) { e->a = env.get(in.B); e->b = K(in.C); }
            else { e->a = env.get(in.B); e->b = env.get(in.C); }
            def_(in.A, e); d = Disp::Expr;
        }
        // ---- calls -------------------------------------------------------------------
        else if (op == 0x2d) {                                                   // NAMECALL
            auto e = mk(EK::Method); e->a = env.get(in.B); e->text = in.note;
            env.set(in.A, e);                       // completed by the CALL that follows
            d = Disp::Expr;
        }
        else if (op == 0x54) {                                                   // CALL
            EP fn = env.get(in.A);
            int nargs = (int)in.B - 1, nres = (int)in.C - 1;
            EP call;
            if (fn && fn->k == EK::Method) { call = fn; }                        // NAMECALL set it up
            else { call = mk(EK::Call); call->a = fn; }
            // A method call's `self` occupies A+1, so its explicit arguments start at A+2 and the
            // count includes self.
            bool ismeth = (fn && fn->k == EK::Method);
            int argbase = ismeth ? in.A + 2 : in.A + 1;
            int argend;                                        // one past the last argument register
            if (nargs < 0) { call->multret = true; argend = env.top + 1; }   // B==0: up to stack top
            else argend = argbase + nargs - (ismeth ? 1 : 0);
            for (int r = argbase; r < argend; ++r) call->list.push_back(env.get(r));
            call->nres = nres;
            if (!std::getenv("RENOVICE_NO_CALLCOALESCE")) {
                // Fold only pure MOVE setup slots. Moving an arbitrary RHS into the call could move
                // allocation or a nested call across observable statements; a register copy has no
                // such timing. The destination must have no intervening emitted use.
                // A method call reads its object at the NAMECALL that set it up (which then writes
                // A and A+1), not at the CALL: that is the use point of the folded object.
                int object_pc = i;
                if (ismeth)
                    for (int q = i - 1; q >= first; --q)
                        if (ip.code[(size_t)q].op == 0x2d && ip.code[(size_t)q].A == in.A) { object_pc = q; break; }
                fold_pure_setup_move(bo.stmts, call->a, ip, object_pc);
                for (EP& arg : call->list) fold_pure_setup_move(bo.stmts, arg, ip, i);
            }
            // A call COLLAPSES the stack back to its own base: the argument registers are consumed.
            // `top` must therefore be reset here, not left as a high-water mark, or the next multret
            // instruction picks up dead argument registers as if they were values.
            if (nres == 0) {
                Stmt s; s.k = SK::ExprStmt; s.rhs = call; s.insn = i; bo.stmts.push_back(s);
                for (int r = in.A; r <= env.top; ++r) env.kill(r);
                env.top = in.A - 1;
            } else {
                for (int r = in.A; r <= env.top; ++r) env.kill(r);
                if (nres < 0) {
                    // Multret is the ONE case that must stay propagated: the results span A..top and
                    // are consumed by an enclosing multret op in THIS block (a stack-top range cannot
                    // cross a block boundary). Materialising would truncate to a single result.
                    env.r[in.A] = call;
                    env.top = in.A;
                } else {
                    std::string tgt;                 // a call may define A..A+nres-1
                    for (int r = in.A; r < in.A + nres; ++r) {
                        if (r > in.A) tgt += ", ";
                        tgt += "v" + std::to_string(r);
                    }
                    Stmt s; s.k = SK::Assign;
                    s.lhs = nres == 1 ? mkreg(in.A) : mkconst(tgt);
                    s.rhs = call; s.insn = i;
                    for (int r = in.A; r < in.A + nres; ++r) {
                        s.call_sources.push_back(r);
                        s.call_targets.push_back(r);
                    }
                    bo.stmts.push_back(s);
                    for (int r = in.A; r < in.A + nres; ++r) env.r[r] = mkreg(r);
                    env.top = in.A + nres - 1;
                }
            }
            d = Disp::Stmt;
        }
        // ---- stores ------------------------------------------------------------------
        else if (op == 0x02 || op == 0x53 || op == 0x15 || op == 0x2a || op == 0x2e) {
            Stmt s; s.k = SK::Assign; s.insn = i; s.rhs = env.get(in.A);
            if (op == 0x02) { auto g = mk(EK::Global); g->text = in.note; s.lhs = g; }
            else if (op == 0x53) { auto u = mk(EK::Upval); u->idx = in.B; s.lhs = u; }
            else if (op == 0x15) { auto f = mk(EK::Field); f->a = env.get(in.B); f->text = in.note; s.lhs = f; }
            else if (op == 0x2a) { auto x = mk(EK::Index); x->a = env.get(in.B); x->b = env.get(in.C); s.lhs = x; }
            else { auto x = mk(EK::Index); x->a = env.get(in.B); x->b = mkconst(std::to_string(in.C + 1)); s.lhs = x; }
            bo.stmts.push_back(s); d = Disp::Stmt;
        }
        else if (op == 0x3f) {
            // SETLIST A B C aux: append C-1 values starting at register B into the table in A,
            // beginning at array index aux. C==0 means "everything up to the top of the stack".
            // Without this a table constructor decompiles to `{}` and every element is LOST.
            EP tbl = env.get(in.A);
            if (!tbl || tbl->k != EK::Table) { tbl = mk(EK::Table); }
            int cnt = (int)in.C - 1;
            int vend = (cnt < 0) ? env.top + 1 : in.B + cnt;    // C==0: everything up to stack top
            if (cnt < 0) tbl->multret = true;
            // A constructor with more than 16 array elements is emitted as SEVERAL SETLIST batches,
            // each with its own starting index in `aux`. Rebuilding the constructor per batch REBINDS
            // the register, so only the LAST batch survived: {1..20} decompiled to {17,18,19,20}.
            // Only the batch starting at index 1 is the constructor; later batches are appends.
            if (in.aux <= 1) {
                for (int r = in.B; r < vend; ++r) tbl->list.push_back(env.get(r));
                if (!std::getenv("RENOVICE_NO_CALLCOALESCE"))
                    for (EP& item : tbl->list) fold_pure_setup_move(bo.stmts, item, ip, i);
                // NEWTABLE was materialised earlier as `vA = {}`. Emitting another assignment here
                // (`vA = {values}`) makes the empty precursor survive recompilation, so every later
                // decompile adds one more orphan. Remove that precursor only when it is the latest
                // definition and NOTHING between it and this SETLIST observes vA. Keeping the
                // filled assignment here preserves value-evaluation order; moving it up to the
                // NEWTABLE site would read item temporaries before they are assigned.
                int empty_def = -1;
                for (int q = (int)bo.stmts.size() - 1; q >= 0; --q) {
                    const Stmt& prior = bo.stmts[q];
                    if (prior.k != SK::Assign || !prior.lhs || prior.lhs->k != EK::Reg
                        || prior.lhs->reg != in.A) continue;
                    if (prior.rhs && prior.rhs->k == EK::Table && prior.rhs->list.empty()
                        && prior.rhs->text.empty()) empty_def = q;
                    break;                              // latest definition was not an empty NEWTABLE
                }
                bool safe_merge = empty_def >= 0;
                for (int q = empty_def + 1; safe_merge && q < (int)bo.stmts.size(); ++q)
                    if (stmt_uses_reg(bo.stmts[q], in.A)) safe_merge = false;
                for (const EP& item : tbl->list)
                    if (safe_merge && expr_uses_reg(item, in.A)) safe_merge = false;
                // SETLIST INTO AN EXISTING TABLE (2026-09-30, DEFECTS #51). `{ a = 1, b = 2, f(x) }`
                // compiles to NEWTABLE, SETFIELD a, SETFIELD b, then SETLIST into the SAME table.
                // When the table was already observed or filled (no empty NEWTABLE is its latest
                // definition, or something reads it before the SETLIST), rebuilding it as
                // `vA = {values}` REPLACED the table and lost every field (44.0.2
                // EE_Interface_Components_List CreateList p86: the list object lost all its fields).
                // Store the values into the existing table instead (`vA[k] = value`).
                // RENOVICE_NO_SETLIST_EXISTING_TABLE restores the rebuild.
                static const bool existing_table_setlist = !std::getenv("RENOVICE_NO_SETLIST_EXISTING_TABLE");
                // A multret tail (C == 0) has no exact index-store spelling without a temporary;
                // it does not occur on 44.0.2 (0 of 23 observed-table sites) and keeps the rebuild.
                if (existing_table_setlist && cnt >= 0 && setlist_table_observed(ip, i, in.A)) {
                    if (std::getenv("RENOVICE_SETLIST_TRACE"))
                        std::fprintf(stderr, "SETLIST_EXISTING pc=%d A=%d count=%d\n", i, (int)in.A, cnt);
                    // The item list was built above and fold_pure_setup_move already REMOVED each
                    // item's setup MOVE from bo.stmts, folding its source into tbl->list. Reading the
                    // register again (env.get) then names a register nothing assigns any more: the
                    // implicit-nil pass printed `vR = nil; vA[k] = vR` and every list element of
                    // `{ k = v, a, b }` became nil (44.1.1 DarkKuvaEximusShootPatternsLib p1, pattern
                    // positions; fixture setlist_mixed `#t` 4 -> 0). Store the folded items.
                    // RENOVICE_NO_SETLIST_EXISTING_FOLDED_ITEMS restores the register reads for A/B.
                    static const bool folded_items = !std::getenv("RENOVICE_NO_SETLIST_EXISTING_FOLDED_ITEMS");
                    for (int r = in.B; r < vend; ++r) {
                        auto ix = mk(EK::Index);
                        ix->a = mkreg(in.A);
                        ix->b = mkconst(std::to_string((in.aux ? (int)in.aux : 1) + (r - in.B)));
                        const size_t item = (size_t)(r - in.B);
                        EP value = (folded_items && item < tbl->list.size() && tbl->list[item])
                            ? tbl->list[item] : env.get(r);
                        Stmt s; s.k = SK::Assign; s.lhs = ix; s.rhs = value; s.insn = i;
                        bo.stmts.push_back(s);
                    }
                } else {
                    if (safe_merge) bo.stmts.erase(bo.stmts.begin() + empty_def);
                    def_(in.A, tbl);
                }
            } else {
                static const bool batch_merge = !std::getenv("RENOVICE_NO_SETLIST_BATCH_MERGE");
                std::vector<EP> batch_items;
                for (int r = in.B; r < vend; ++r) batch_items.push_back(env.get(r));
                const bool merged = batch_merge && in.aux > 1
                    && merge_setlist_batch(bo.stmts, ip, i, (int)in.A, (int)in.aux, batch_items, cnt < 0);
                for (int r = in.B; !merged && r < vend; ++r) {
                    auto ix = mk(EK::Index);
                    ix->a = mkreg(in.A);
                    ix->b = mkconst(std::to_string((int)in.aux + (r - in.B)));
                    Stmt s; s.k = SK::Assign; s.lhs = ix; s.rhs = env.get(r); s.insn = i;
                    bo.stmts.push_back(s);
                }
            }
            d = Disp::Expr;
        }
        else if (op == 0x29) {                                                   // RETURN
            Stmt s; s.k = SK::Return; s.insn = i;
            int n = (int)in.B - 1;
            if (n < 0) {
                // B==0 => return every value from A to the top of the stack. This is what a tail
                // position like `return f(x)` compiles to. Treating it as "zero values" silently
                // produced a bare `return` and threw the result away.
                for (int r = in.A; r <= env.top; ++r) s.list.push_back(env.get(r));
                if (s.list.empty()) s.list.push_back(env.get(in.A));
                if (s.list.back()) s.list.back()->multret = true;
            } else {
                for (int r = in.A; r < in.A + n; ++r) s.list.push_back(env.get(r));
            }
            if (!std::getenv("RENOVICE_NO_CALLCOALESCE"))
                for (EP& item : s.list) fold_pure_setup_move(bo.stmts, item, ip, i);
            bo.stmts.push_back(s); d = Disp::Stmt;
        }
        // ---- control flow: recorded, structured by M6d --------------------------------
        else if (in.branch) {
            Stmt s; s.k = SK::Branch; s.insn = i; s.target = in.target;
            s.text = in.name + " " + in.text;
            bo.stmts.push_back(s); d = Disp::Ctrl;
        }
        // ---- carries no source meaning -------------------------------------------------
        else if (op == 0x19 || op == 0x10 || op == 0x0c || op == 0x26 || op == 0x4a) d = Disp::Skip; // FASTCALL*
        else if (op == 0x35) d = Disp::Skip;                                     // CAPTURE (part of closure)
        else if (op == 0x39) d = Disp::Skip;                                     // CLOSEUPVALS (scope marker)
        else if (op == 0x11) d = Disp::Skip;                                     // PREPVARARGS (prologue)

        switch (d) {
            case Disp::Expr: ++out.n_expr; break;
            case Disp::Stmt: ++out.n_stmt; break;
            case Disp::Ctrl: ++out.n_ctrl; break;
            case Disp::Skip: ++out.n_skip; break;
            default: ++out.n_unhandled; out.unhandled[in.name]++; break;
        }
    }
}

} // namespace ex
