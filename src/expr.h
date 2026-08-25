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
#include "ir.h"

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
            if (is_ident(e->text)) return wrap(e->a, 99) + "." + e->text;
            return wrap(e->a, 99) + "[" + ir::quote_lua(e->text) + "]";
        case EK::Index:  return wrap(e->a, 99) + "[" + render(e->b) + "]";
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
            std::string s = wrap(e->a, 99) + "(";
            for (size_t i = 0; i < e->list.size(); ++i) { if (i) s += ", "; s += render(e->list[i]); }
            return s + ")";
        }
        case EK::Method: {
            std::string s = wrap(e->a, 99) + ":" + e->text + "(";
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

inline void fold_pure_setup_move(std::vector<Stmt>& statements, EP& value) {
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
                if (!retargeted && !std::getenv("RENOVICE_NO_TABLEMOVECOALESCE")) {
                    if (prior.k == SK::Assign && prior.rhs && prior.rhs->k == EK::Table
                        && prior.insn == i - 1 && prior.lhs && prior.lhs->k == EK::Reg
                        && prior.lhs->reg == in.B) {
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
            // NEWCLOSURE (0x16) takes the sub-proto index DIRECTLY, but DUPCLOSURE (0x42) takes a
            // CONSTANT index whose tag-6 payload holds the sub-proto index. Treating DUPCLOSURE's Bx
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
            for (int q = i + 1; q < (int)ip.code.size() && ip.code[q].op == 0x35; ++q) {
                if (!e->text.empty()) e->text += ",";
                const ir::IInsn& c = ip.code[q];
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
                for (EP& item : e->list) fold_pure_setup_move(bo.stmts, item);
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
                fold_pure_setup_move(bo.stmts, call->a);
                for (EP& arg : call->list) fold_pure_setup_move(bo.stmts, arg);
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
                    for (EP& item : tbl->list) fold_pure_setup_move(bo.stmts, item);
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
                if (safe_merge) bo.stmts.erase(bo.stmts.begin() + empty_def);
                def_(in.A, tbl);
            } else {
                for (int r = in.B; r < vend; ++r) {
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
                for (EP& item : s.list) fold_pure_setup_move(bo.stmts, item);
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
