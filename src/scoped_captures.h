// scoped_captures.h -- BLOCK-SCOPED LOCALS CAPTURED BY REFERENCE (2026-10-10, captures campaign).
//
// The emitter names every register with one function-lifetime local `vR`. A source local that a
// closure captures BY REFERENCE (`CAPTURE REF R`) inside a block is a fresh variable every time the
// block runs: Luau ends its lifetime with `CLOSEUPVALS R` at the block end (and before a break or
// continue leaving it). With the flat name
//   * closures created in different iterations of a loop all shared ONE variable: per-element
//     callbacks saw the last element's value (luau.exe: `1 2` became `2 2`);
//   * every later write of the register (the next statement reusing the slot as a temporary) was a
//     write into the variable the closure still reads;
// and the rebuilt bytecode had no CLOSEUPVALS (CFG-ID `LABEL CLOSEUPVALS -> ...`, dataflow
// `CLOSURE REFWRITES` / `TAG CAP VAL->CAP REF`).
//
// expr.h prints each non-trivial CLOSEUPVALS as a marker line `--[[RENOVICE_CLOSEUPVALS <pc>]]` at its
// position in the block (scoped_capture_marker). This pass runs on the raw emitted body of one
// prototype, before any other text pass, and for a marker at indentation d:
//   1. takes the registers r >= A of every REF capture whose closure reaches this CLOSEUPVALS before
//      any other CLOSEUPVALS covering r (bytecode walk) and that are dead after it (prototype
//      liveness: nothing after the scope reads the local's value);
//   2. finds, in the marker's block (the lines above it at indentation >= d up to the block opener),
//      the closure placeholder `function<P|...>` naming `v<r>` in that capture slot, and before the
//      top-level statement that holds it the LAST top-level plain assignment `v<r> = <rhs>` whose rhs
//      does not read v<r>;
//   3. wraps the lines from the earliest such assignment to the marker in `do ... end` and declares
//      each of those assignments `local v<r> = <rhs>`.
// Exactness of the rewrite (independent of the stock declaration point): the assignment is a
// top-level statement of the do-block, so it dominates every later line of the block and no value
// written before it is read after it; every read of v<r> after the do-block ends is dead in the
// bytecode (step 1); a `local` declared at the top level of the wrapped range must not be referenced
// after it (checked, otherwise the marker is refused). Shapes that do not match (the closure in
// another dispatcher state than the declaration, a recursive `v<r> = function<...v<r>...>`) keep the
// flat name. Every marker line is removed. RENOVICE_NO_SCOPED_CAPTURE_LOCALS keeps the flat names and
// prints no markers; RENOVICE_SCOPED_CAPTURE_TRACE prints each decision.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <set>
#include <map>
#include <string>
#include <vector>
#include "ir.h"
#include "expr.h"

namespace scap {

inline bool enabled() {
    static const bool on = !std::getenv("RENOVICE_NO_SCOPED_CAPTURE_LOCALS");
    return on;
}

inline const char* marker_prefix() { return "--[[RENOVICE_CLOSEUPVALS "; }

inline std::string marker_text(int pc) { return std::string(marker_prefix()) + std::to_string(pc) + "]]"; }

struct Line { std::string text; int indent = 0; };

inline int indent_of(const std::string& s) {
    int n = 0;
    while (n < (int)s.size() && s[(size_t)n] == ' ') ++n;
    return n;
}

inline bool ident_char(char c) { return std::isalnum((unsigned char)c) || c == '_'; }

// Whole-token occurrences of `name` in `s`, outside string literals and comments.
inline std::vector<size_t> token_positions(const std::string& s, const std::string& name) {
    std::vector<size_t> out;
    size_t i = 0;
    while (i < s.size()) {
        const char c = s[i];
        if (c == '"' || c == '\'') {
            const char q = c; ++i;
            while (i < s.size()) {
                if (s[i] == '\\' && i + 1 < s.size()) { i += 2; continue; }
                if (s[i++] == q) break;
            }
            continue;
        }
        if (c == '-' && i + 1 < s.size() && s[i + 1] == '-') {
            if (i + 3 < s.size() && s[i + 2] == '[' && s[i + 3] == '[') {
                const size_t e = s.find("]]", i + 4);
                i = e == std::string::npos ? s.size() : e + 2;
                continue;
            }
            break;                                            // line comment: rest of the line
        }
        if (c == '[' && i + 1 < s.size() && s[i + 1] == '[') {
            const size_t e = s.find("]]", i + 2);
            i = e == std::string::npos ? s.size() : e + 2;
            continue;
        }
        if (s.compare(i, name.size(), name) == 0 && (i == 0 || !ident_char(s[i - 1]))
            && (i + name.size() >= s.size() || !ident_char(s[i + name.size()]))) {
            out.push_back(i);
            i += name.size();
            continue;
        }
        ++i;
    }
    return out;
}

// The capture list of every closure placeholder `function<P|a,b,...>` in a line.
struct Placeholder { int proto = -1; std::vector<std::string> captures; };
inline std::vector<Placeholder> placeholders(const std::string& s) {
    std::vector<Placeholder> out;
    size_t at = 0;
    while ((at = s.find("function<", at)) != std::string::npos) {
        size_t p = at + 9, e = s.find('>', p);
        if (e == std::string::npos) break;
        Placeholder ph;
        const std::string inner = s.substr(p, e - p);
        const size_t bar = inner.find('|');
        ph.proto = std::atoi(inner.substr(0, bar).c_str());
        if (bar != std::string::npos) {
            std::string item;
            for (size_t k = bar + 1; k <= inner.size(); ++k) {
                if (k == inner.size() || inner[k] == ',') { ph.captures.push_back(item); item.clear(); }
                else item += inner[k];
            }
        }
        out.push_back(ph);
        at = e;
    }
    return out;
}

// Closure creation sites of the prototype: pc, child proto index and capture list.
struct Site { int pc = -1, proto = -1; std::vector<std::pair<int, int>> captures; };
inline std::vector<Site> closure_sites(const ir::IProto& ip) {
    std::vector<Site> out;
    for (int i = 0; i < (int)ip.code.size(); ++i) {
        const ir::IInsn& in = ip.code[(size_t)i];
        if (in.op != 0x16 && in.op != 0x42) continue;
        Site s; s.pc = i;
        if (in.op == 0x42 && in.Bx < ip.consts.size() && ip.consts[in.Bx].kind == ir::KKind::Closure)
            s.proto = (int)ip.consts[in.Bx].sub;
        else if (in.op == 0x16 && in.Bx < ip.kids.size()) s.proto = (int)ip.kids[in.Bx];
        else s.proto = in.Bx;
        for (int q = i + 1; q < (int)ip.code.size() && ip.code[(size_t)q].op == 0x35; ++q)
            s.captures.push_back({(int)ip.code[(size_t)q].A, (int)ip.code[(size_t)q].B});
        out.push_back(s);
    }
    return out;
}

// Does a path from the closure at `from` reach the CLOSEUPVALS at `close` without first passing
// another CLOSEUPVALS that covers `reg`?
inline bool closure_reaches_close(const ir::IProto& ip, int from, int close, int reg) {
    const int n = (int)ip.code.size();
    std::vector<char> seen((size_t)n, 0);
    std::vector<int> todo{from + 1}, succ;
    while (!todo.empty()) {
        const int pc = todo.back(); todo.pop_back();
        if (pc < 0 || pc >= n || seen[(size_t)pc]) continue;
        seen[(size_t)pc] = 1;
        const ir::IInsn& in = ip.code[(size_t)pc];
        if (in.op == 0x39 && (int)in.A <= reg) {
            if (pc == close) return true;
            continue;
        }
        ex::insn_successors(ip, pc, succ);
        for (int s : succ) todo.push_back(s);
    }
    return false;
}

inline std::vector<Line> split_lines(const std::string& body) {
    std::vector<Line> lines;
    size_t at = 0;
    while (at < body.size()) {
        size_t e = body.find('\n', at);
        if (e == std::string::npos) e = body.size();
        Line l; l.text = body.substr(at, e - at); l.indent = indent_of(l.text);
        lines.push_back(l);
        at = e + 1;
    }
    return lines;
}

inline bool continuation_keyword(const std::string& t, int indent) {
    const std::string s = t.substr((size_t)std::min<int>(indent, (int)t.size()));
    for (const char* k : {"end", "else", "elseif", "until"}) {
        const size_t n = std::char_traits<char>::length(k);
        if (s.compare(0, n, k) == 0 && (s.size() == n || !ident_char(s[n]))) return true;
    }
    return false;
}

inline bool is_marker(const std::string& t, int* pc = nullptr) {
    const size_t at = t.find(marker_prefix());
    if (at == std::string::npos) return false;
    for (size_t k = 0; k < at; ++k) if (t[k] != ' ') return false;
    if (pc) *pc = std::atoi(t.c_str() + at + std::char_traits<char>::length(marker_prefix()));
    return true;
}

// Names declared by a top-level `local a, b = ...` / `local a` line (empty when not a local line).
inline std::vector<std::string> declared_names(const std::string& t, int indent) {
    std::vector<std::string> out;
    const std::string s = t.substr((size_t)std::min<int>(indent, (int)t.size()));
    if (s.compare(0, 6, "local ") != 0) return out;
    size_t k = 6;
    if (s.compare(k, 9, "function ") == 0) k += 9;
    while (k < s.size()) {
        while (k < s.size() && (s[k] == ' ' || s[k] == ',')) ++k;
        size_t b = k;
        while (k < s.size() && ident_char(s[k])) ++k;
        if (k == b) break;
        out.push_back(s.substr(b, k - b));
        while (k < s.size() && s[k] == ' ') ++k;
        if (k >= s.size() || s[k] != ',') break;
    }
    return out;
}

// Returns the number of do-blocks introduced. `body` loses every marker line either way.
inline int scope_captured_block_locals(std::string& body, const ir::IProto& ip) {
    if (body.find(marker_prefix()) == std::string::npos) return 0;
    static const bool trace = std::getenv("RENOVICE_SCOPED_CAPTURE_TRACE") != nullptr;
    // Measurement control: print and strip the markers without rewriting anything. Its output must
    // equal the RENOVICE_NO_SCOPED_CAPTURE_LOCALS output byte for byte (markers alone change nothing).
    static const bool markers_only = std::getenv("RENOVICE_SCOPED_CAPTURE_MARKERS_ONLY") != nullptr;
    std::vector<Line> lines = split_lines(body);
    const std::vector<Site> sites = closure_sites(ip);
    int wrapped = 0;
    auto refuse = [&](int pc, int reg, const char* why) {
        if (trace) std::fprintf(stderr, "SCOPED_CAPTURE proto=%d close=%d reg=%d refused=%s\n",
                                ip.index, pc, reg, why);
    };
    // Bottom-up: an enclosing scope's marker is below the markers of the scopes it contains.
    for (int m = (int)lines.size() - 1; m >= 0 && !markers_only; --m) {
        int close = -1;
        if (!is_marker(lines[(size_t)m].text, &close)) continue;
        const int d = lines[(size_t)m].indent;
        if (close < 0 || close >= (int)ip.code.size() || ip.code[(size_t)close].op != 0x39) {
            refuse(close, -1, "marker"); continue;
        }
        const int A = (int)ip.code[(size_t)close].A;
        // a `repeat` body's locals stay visible in its `until` test, which follows the marker
        {
            int next = m + 1;
            while (next < (int)lines.size() && (lines[(size_t)next].text.empty()
                                                || is_marker(lines[(size_t)next].text))) ++next;
            if (next < (int)lines.size() && lines[(size_t)next].indent < d) {
                const std::string& t = lines[(size_t)next].text;
                const size_t at = (size_t)lines[(size_t)next].indent;
                if (t.compare(at, 5, "until") == 0) { refuse(close, -1, "repeat_until"); lines.erase(lines.begin() + m); continue; }
            }
        }
        // the block holding the marker: lines above it at indentation >= d
        int block_first = m;
        while (block_first > 0 && (lines[(size_t)block_first - 1].indent >= d
                                   || lines[(size_t)block_first - 1].text.empty()))
            --block_first;
        // top-level statement start lines of that block, above the marker
        std::vector<int> tops;
        for (int k = block_first; k < m; ++k)
            if (lines[(size_t)k].indent == d && !lines[(size_t)k].text.empty()
                && !continuation_keyword(lines[(size_t)k].text, d) && !is_marker(lines[(size_t)k].text))
                tops.push_back(k);
        auto top_of = [&](int line) {
            int best = -1;
            for (int t : tops) if (t <= line) best = t;
            return best;
        };
        std::map<int, int> decl_line;                     // register -> line declared local
        std::set<int> regs;
        for (const Site& s : sites)
            for (const auto& cap : s.captures)
                if (cap.first == 1 && cap.second >= A && cap.second >= ip.nparams)
                    if (closure_reaches_close(ip, s.pc, close, cap.second)) regs.insert(cap.second);
        bool ok = !regs.empty();
        if (!ok) refuse(close, -1, "no_ref_capture");
        for (int r : regs) {
            if (!ok) break;
            if (ex::register_live_after(ip, close, r)) { refuse(close, r, "live_after"); ok = false; break; }
            const std::string name = "v" + std::to_string(r);
            // the placeholder of a closure of this scope that names v<r> in a REF slot
            int holder = -1;
            for (int k = block_first; k < m && holder < 0; ++k) {
                for (const Placeholder& ph : placeholders(lines[(size_t)k].text)) {
                    for (const Site& s : sites) {
                        if (s.proto != ph.proto || s.captures.size() != ph.captures.size()) continue;
                        for (size_t q = 0; q < s.captures.size(); ++q)
                            if (s.captures[q].first == 1 && s.captures[q].second == r
                                && ph.captures[q] == name && closure_reaches_close(ip, s.pc, close, r))
                                holder = k;
                    }
                }
            }
            if (holder < 0) { refuse(close, r, "no_placeholder_in_block"); ok = false; break; }
            const int holder_top = top_of(holder);
            if (holder_top < 0) { refuse(close, r, "no_holder_statement"); ok = false; break; }
            int chosen = -1;
            const std::string lead = name + " = ";
            for (int t : tops) {
                if (t >= holder_top) break;
                const std::string& text = lines[(size_t)t].text;
                if (text.compare((size_t)d, lead.size(), lead) != 0) continue;
                if (!token_positions(text.substr((size_t)d + lead.size()), name).empty()) continue;
                // a multi-line statement (`v = function<...>` is one line; tables are one line);
                // require the next line to start another statement of the block or the marker
                const int next = t + 1;
                if (next < m && lines[(size_t)next].indent > d) continue;
                chosen = t;
            }
            if (chosen < 0) { refuse(close, r, "no_toplevel_definition"); ok = false; break; }
            decl_line[r] = chosen;
        }
        if (ok) {
            int start = m;
            for (const auto& entry : decl_line) start = std::min(start, entry.second);
            // locals declared at the top level of the wrapped range must not be read after it
            std::string after;
            for (int k = m + 1; k < (int)lines.size(); ++k) { after += lines[(size_t)k].text; after += '\n'; }
            for (int t : tops) {
                if (t < start) continue;
                for (const std::string& n : declared_names(lines[(size_t)t].text, d))
                    if (!token_positions(after, n).empty()) { refuse(close, -1, "local_used_after"); ok = false; }
            }
            if (ok) {
                const std::string pad = std::string((size_t)d, ' ');
                for (int k = start; k < m; ++k) {
                    if (lines[(size_t)k].text.empty()) continue;
                    lines[(size_t)k].text = "  " + lines[(size_t)k].text;
                    lines[(size_t)k].indent += 2;
                }
                // The scoped local gets its own name instead of shadowing `v<r>`: the flat
                // declaration list and the later text passes (implicit-nil hoisting, register
                // renaming) read `v<r>` tokens without scope, and a shadowing `local v<r>` made
                // them keep the flat slot too, so every re-decompile moved the local one register
                // up (compiler closure diverged). The name is the prototype and the ordinal of the
                // first CAPTURE REF of r reaching this close among the prototype's CAPTUREs, which a
                // re-decompile of the output reproduces (the snapshot naming of DEFECTS #52).
                for (const auto& entry : decl_line) {
                    const int r = entry.first;
                    int ordinal = 0, chosen_ordinal = -1;
                    for (const Site& s : sites) {
                        for (const auto& cap : s.captures) {
                            if (chosen_ordinal < 0 && cap.first == 1 && cap.second == r
                                && closure_reaches_close(ip, s.pc, close, r))
                                chosen_ordinal = ordinal;
                            ++ordinal;
                        }
                    }
                    const std::string from = "v" + std::to_string(r);
                    const std::string to = "__renovice_scope_" + std::to_string(ip.index) + "_"
                                         + std::to_string(chosen_ordinal);
                    for (int k = entry.second; k < m; ++k) {
                        std::string& text = lines[(size_t)k].text;
                        const std::vector<size_t> at = token_positions(text, from);
                        for (size_t q = at.size(); q-- > 0;) text.replace(at[q], from.size(), to);
                    }
                    lines[(size_t)entry.second].text.insert((size_t)d + 2, "local ");
                }
                lines[(size_t)m].text = pad + "end";
                lines[(size_t)m].indent = d;
                Line open; open.text = pad + "do"; open.indent = d;
                lines.insert(lines.begin() + start, open);
                ++wrapped;
                if (trace)
                    std::fprintf(stderr, "SCOPED_CAPTURE proto=%d close=%d wrapped regs=%d lines=%d\n",
                                 ip.index, close, (int)decl_line.size(), m - start);
                // the marker line became `end` and one line was inserted above it: the next
                // iteration must look at the line that was directly above the marker (a nested
                // break-path marker), which now sits at index m
                ++m;
                continue;
            }
        }
        lines.erase(lines.begin() + m);
    }
    std::string out;
    for (const Line& l : lines) {
        if (is_marker(l.text)) continue;
        out += l.text; out += '\n';
    }
    if (!body.empty() && body.back() != '\n' && !out.empty()) out.pop_back();
    body.swap(out);
    return wrapped;
}

// ---------------------------------------------------------------------------------------------
// UNSHARED SNAPSHOT CLOSURES (2026-10-10, captures campaign). Luau shares a closure (DUPCLOSURE)
// when every upvalue is an immutable local declared at the top level of the main chunk outside any
// loop (Compiler.cpp shouldShareClosure). The by-value capture snapshots of DEFECTS #52 are exactly
// such locals when the closure sits at the chunk's top level, so a stock NEWCLOSURE whose captured
// locals were not top-level (DE's -O2 inliner copied a local function's closure into the chunk:
// its upvalues are the inlined function's locals) came back as DUPCLOSURE, and the shared-prototype
// merge (#78) refused StatsLib (one prototype referenced through NEWCLOSURE in one function and
// DUPCLOSURE constants in another). `repeat ... until true` compiles to no instruction (a constant
// `until` emits no back jump) and puts the snapshots at loop depth 1, which makes Luau pick
// NEWCLOSURE again. Applied only in the main chunk (`main_proto_index`, set by the module
// decompiler), only when every stock site of that prototype in this function is NEWCLOSURE with
// by-value captures only, every capture of the placeholder is a snapshot declared on the lines
// directly above it and read nowhere else, and the statement is not already inside a loop.
// RENOVICE_NO_UNSHARED_SNAPSHOT_CLOSURE restores the shared spelling.
inline int& main_proto_index() { static int index = -1; return index; }

inline int unshare_snapshot_closures(std::string& body, const ir::IProto& ip) {
    static const bool off = std::getenv("RENOVICE_NO_UNSHARED_SNAPSHOT_CLOSURE") != nullptr;
    if (off || ip.index != main_proto_index() || body.find("__renovice_capture_") == std::string::npos)
        return 0;
    std::vector<Line> lines = split_lines(body);
    const std::vector<Site> sites = closure_sites(ip);
    int wrapped = 0;
    for (int k = 0; k < (int)lines.size(); ++k) {
        const std::vector<Placeholder> phs = placeholders(lines[(size_t)k].text);
        if (phs.size() != 1 || phs[0].captures.empty()) continue;
        const Placeholder& ph = phs[0];
        bool all_snapshots = true;
        for (const std::string& c : ph.captures)
            if (c.compare(0, 19, "__renovice_capture_") != 0) all_snapshots = false;
        if (!all_snapshots) continue;
        bool stock_new = false, stock_other = false;
        for (const Site& s : sites) {
            if (s.proto != ph.proto) continue;
            bool by_value = s.captures.size() == ph.captures.size();
            for (const auto& cap : s.captures) if (cap.first != 0) by_value = false;
            if (ip.code[(size_t)s.pc].op == 0x16 && by_value) stock_new = true;
            else stock_other = true;
        }
        if (!stock_new || stock_other) continue;
        const int d = lines[(size_t)k].indent;
        if (k + 1 < (int)lines.size() && lines[(size_t)k + 1].indent > d) continue;   // one-line statement
        // not already inside a loop: no enclosing opener is a loop
        bool in_loop = false;
        int need = d;
        for (int up = k - 1; up >= 0 && need > 0; --up) {
            const Line& l = lines[(size_t)up];
            if (l.text.empty() || l.indent >= need) continue;
            need = l.indent;
            const std::string t = l.text.substr((size_t)l.indent);
            if (t.compare(0, 4, "for ") == 0 || t.compare(0, 6, "while ") == 0 || t == "repeat")
                in_loop = true;
        }
        if (in_loop) continue;
        // the snapshot declarations directly above, one per capture
        std::set<std::string> wanted(ph.captures.begin(), ph.captures.end());
        int first = k;
        while (first > 0 && !wanted.empty()) {
            const Line& l = lines[(size_t)first - 1];
            if (l.indent != d) break;
            const std::vector<std::string> names = declared_names(l.text, d);
            if (names.size() != 1 || !wanted.count(names[0])) break;
            wanted.erase(names[0]);
            --first;
        }
        if (!wanted.empty()) continue;
        // the snapshots are read by this placeholder only
        bool private_names = true;
        for (const std::string& c : ph.captures) {
            for (int q = 0; q < (int)lines.size() && private_names; ++q) {
                if (q >= first && q <= k) continue;
                if (!token_positions(lines[(size_t)q].text, c).empty()) private_names = false;
            }
        }
        if (!private_names) continue;
        const std::string pad((size_t)d, ' ');
        for (int q = first; q <= k; ++q) { lines[(size_t)q].text = "  " + lines[(size_t)q].text; lines[(size_t)q].indent += 2; }
        Line open; open.text = pad + "repeat"; open.indent = d;
        Line close; close.text = pad + "until true"; close.indent = d;
        lines.insert(lines.begin() + k + 1, close);
        lines.insert(lines.begin() + first, open);
        k += 2;
        ++wrapped;
    }
    if (!wrapped) return 0;
    std::string out;
    for (const Line& l : lines) { out += l.text; out += '\n'; }
    if (!body.empty() && body.back() != '\n' && !out.empty()) out.pop_back();
    body.swap(out);
    return wrapped;
}

} // namespace scap
