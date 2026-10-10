// m6e_cmd.h — M6e driver.
//
//   decompile <file.lua_B> [proto] [output]   emit Luau source
//   emit-validate <dir>              COMPILABILITY ORACLE: does our output actually compile?
//
// This is the first check in the whole project that tests MEANING rather than completeness. If
// luau-compile.exe rejects the output, it is not Luau — no amount of structural green matters.
#pragma once

// Emit one proto as an ANONYMOUS function expression, for inlining at a closure site.
static std::string decompile_proto_anon(const ir::IProto& ip, int idx,
                                        bool& ok, std::string& why);

// Set when a closure could not be decompiled and a placeholder was substituted.
static std::string g_inline_fail;
static bool g_primary_ability_loop_scope = false;

// Capture substitution can make two formerly distinct child registers name the same recovered
// lexical local. A native MOVE between them then becomes `__renovice_local_N =
// __renovice_local_N` only after the per-prototype emitter has finished. Delete that exact generated
// no-op after substitution; ordinary identifiers, globals, and indexed writes are not candidates.
static int remove_inlined_generated_self_assignments(std::string& source) {
    std::vector<std::string> lines;
    size_t pos = 0;
    while (pos < source.size()) {
        size_t end = source.find('\n', pos);
        if (end == std::string::npos) end = source.size();
        lines.push_back(source.substr(pos, end - pos));
        pos = end + (end < source.size() ? 1 : 0);
    }
    int changed = 0;
    for (size_t i = lines.size(); i-- > 0;) {
        size_t indent = 0;
        while (indent < lines[i].size() && lines[i][indent] == ' ') ++indent;
        const std::string text = lines[i].substr(indent);
        if (text.compare(0, 17, "__renovice_local_") != 0) continue;
        const size_t assign = text.find(" = ");
        if (assign == std::string::npos) continue;
        const std::string left = text.substr(0, assign);
        if (text.substr(assign + 3) != left || left.size() <= 17) continue;
        size_t digit = 17;
        for (; digit < left.size(); ++digit)
            if (!std::isdigit((unsigned char)left[digit])) break;
        if (digit != left.size()) continue;
        lines.erase(lines.begin() + (std::ptrdiff_t)i);
        ++changed;
    }
    if (changed) {
        std::string rewritten;
        for (size_t i = 0; i < lines.size(); ++i) {
            rewritten += lines[i];
            if (i + 1 < lines.size() || (!source.empty() && source.back() == '\n'))
                rewritten += '\n';
        }
        source.swap(rewritten);
    }
    return changed;
}

static bool is_primary_ability_module_path(std::string path) {
    for (char& character : path)
        if (character == '\\' || character == '/') character = '_';
    return path.find("Lotus_Powersuits_") != std::string::npos
        && (path.find("_Abilities_") != std::string::npos
            || path.find("_ArchwingAbilities_") != std::string::npos
            || path.find("_PeltAbilities_") != std::string::npos);
}

static bool loop_identity_repair_enabled() {
    if (std::getenv("RENOVICE_NO_LOOP_IDENTITY_REPAIR")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_EXACT_SIX_SHELL_NESTED_OUTER")
        || std::getenv("RENOVICE_COMPLETE_STRUCTURE_SURPLUS_GENERIC")
        || std::getenv("RENOVICE_LOOP_IDENTITY_REPAIR");
}

static bool proper_generic_two_exit_enabled() {
    if (std::getenv("RENOVICE_NO_PROPER_GENERIC_LOOP_TWO_EXIT_PROMOTION")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_PROPER_GENERIC_LOOP_TWO_EXIT_PROMOTION");
}

static bool multi_latch_generic_body_scope_enabled() {
    if (std::getenv("RENOVICE_NO_MULTI_LATCH_GENERIC_BODY_SCOPE")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_MULTI_LATCH_GENERIC_BODY_SCOPE");
}

static bool gyre_second_generic_nested_enabled() {
    if (std::getenv("RENOVICE_NO_GYRE_SECOND_GENERIC_NESTED")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_GYRE_SECOND_GENERIC_SCOPE");
}

static bool gyre_energized_outer_enabled() {
    if (std::getenv("RENOVICE_NO_GYRE_ENERGIZED_OUTER")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_GYRE_ENERGIZED_OUTER");
}

static bool pulse_four_latch_generic_dedup_enabled() {
    if (std::getenv("RENOVICE_NO_PULSE_FOUR_LATCH_GENERIC_DEDUP")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_PULSE_FOUR_LATCH_GENERIC_DEDUP");
}

static bool pulse_two_exit_match_fold_enabled() {
    if (std::getenv("RENOVICE_NO_PULSE_TWO_EXIT_MATCH_FOLD")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_TWO_BLOCK_TWO_EXIT_REVERSED_GENERIC");
}

static bool authoritative_region_nested_outer_enabled() {
    if (std::getenv("RENOVICE_NO_AUTHORITATIVE_REGION_NESTED_OUTER")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_AUTHORITATIVE_REGION_NESTED_OUTER");
}

static bool split_for_whole_part_enabled() {
    if (std::getenv("RENOVICE_NO_SPLIT_FOR_WHOLE_PART")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_SPLIT_FOR_WHOLE_PART");
}

static bool parent_first_exact_outer_enabled() {
    if (std::getenv("RENOVICE_NO_PARENT_FIRST_EXACT_OUTER")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_PARENT_FIRST_EXACT_OUTER");
}

static bool parent_first_child_coalesce_enabled() {
    if (std::getenv("RENOVICE_NO_PARENT_FIRST_CHILD_COALESCE")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_PARENT_FIRST_CHILD_COALESCE");
}

static bool parent_first_reversed_generic_enabled() {
    if (std::getenv("RENOVICE_NO_PARENT_FIRST_REVERSED_GENERIC")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_PARENT_FIRST_REVERSED_GENERIC");
}

static bool repaired_generic_child_coalesce_enabled() {
    if (std::getenv("RENOVICE_NO_REPAIRED_GENERIC_CHILD_COALESCE")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_REPAIRED_GENERIC_CHILD_COALESCE");
}

static bool seq_generic_for_coalesce_enabled() {
    if (std::getenv("RENOVICE_NO_SEQ_GENERIC_FOR_COALESCE")) return false;
    return g_primary_ability_loop_scope
        || std::getenv("RENOVICE_SEQ_GENERIC_FOR_COALESCE");
}

static size_t emitted_loop_region_count(const sa::Analyzer& analyzer) {
    size_t count = 0;
    for (const sa::Region& region : analyzer.regions)
        if (region.kind == sa::RK::SelfLoop || region.kind == sa::RK::While
            || region.kind == sa::RK::NaturalLoop) ++count;
    return count;
}

static bool has_exact_six_shell_nested_numeric(const std::vector<st::Loop>& loops) {
    for (const st::Loop& outer : loops) {
        if (outer.kind == st::Loop::ForNum || outer.kind == st::Loop::ForGen) continue;
        size_t contained = 0;
        const st::Loop* nested_numeric = nullptr;
        for (const st::Loop& candidate : loops) {
            bool subset = true;
            for (int block : candidate.body)
                if (!outer.body.count(block)) { subset = false; break; }
            if (!subset) continue;
            ++contained;
            if (&candidate != &outer && candidate.kind == st::Loop::ForNum
                && candidate.prep >= 0) {
                if (nested_numeric) { nested_numeric = nullptr; break; }
                nested_numeric = &candidate;
            }
        }
        if (contained == 2 && nested_numeric
            && outer.body.size() == nested_numeric->body.size() + 6) return true;
    }
    return false;
}

static void trace_nested_numeric_shapes(const std::vector<st::Loop>& loops, int proto) {
    if (!std::getenv("RENOVICE_PLANDBG")) return;
    for (const st::Loop& outer : loops) {
        if (outer.kind == st::Loop::ForNum || outer.kind == st::Loop::ForGen) continue;
        for (const st::Loop& inner : loops) {
            if (&inner == &outer || inner.kind != st::Loop::ForNum) continue;
            bool subset = true;
            for (int block : inner.body)
                if (!outer.body.count(block)) { subset = false; break; }
            if (subset)
                std::fprintf(stderr,
                             "NESTED_NUMERIC_SHAPE p=%d outer=%d/%zu inner=%d/%zu shell=%zu\n",
                             proto, outer.header, outer.body.size(), inner.header, inner.body.size(),
                             outer.body.size() - inner.body.size());
        }
    }
}

// ---- Orphan prototypes ---------------------------------------------------------------------------
// The compiler turns EVERY function literal into a prototype, including a literal inside code that it
// folds away (`if <constant false> then ... function ... end`). That prototype has no closure site
// anywhere in the module (NEWCLOSURE child / DUPCLOSURE constant): an orphan. The emitter only
// reaches prototypes through closure sites, so the rebuilt module lost every orphan and every later
// prototype index shifted (42 of the 72 U44.1.1 proto-count failures; ReplayLib p10, Zariman p13-19).
//
// Prototype numbering is post-order over the source (children before their function, siblings in
// source order). An orphan root O therefore belongs at the END of the body of the lowest-index
// prototype N > O that is reachable from the chunk: every reachable child of N is below O, N above
// it. There it is written as a dead literal, `if false then local _ = function ... end end`: the
// compiler folds the branch (no instruction, no closure site) yet still compiles the literal, so O
// keeps its index and its code. Its upvalues bind to fresh dead locals initialized with `{}` (not a
// constant), so constant folding cannot turn an upvalue read into a constant. Orphan subtrees (an
// orphan's own closure children) follow through the ordinary inlining recursion.
// RENOVICE_NO_ORPHAN_PROTOS restores the previous behavior (orphans dropped).
static std::map<int, std::vector<int>> g_orphans_by_host;

static void compute_orphan_hosts(const de::Module& m, int root) {
    g_orphans_by_host.clear();
    if (std::getenv("RENOVICE_NO_ORPHAN_PROTOS") || root < 0 || root >= (int)m.protos.size()) return;
    const int count = (int)m.protos.size();
    std::vector<std::vector<int>> sites((size_t)count);
    std::vector<int> refs((size_t)count, 0);
    for (int index = 0; index < count; ++index) {
        const de::Proto& proto = m.protos[(size_t)index];
        size_t offset = 0;
        while (offset + 4 <= proto.code.size()) {
            const int op = (uint8_t)proto.code[offset];
            const int bx = (uint8_t)proto.code[offset + 2] | ((uint8_t)proto.code[offset + 3] << 8);
            int target = -1;
            if (op == 0x16 && bx < (int)proto.kids.size()) target = (int)proto.kids[(size_t)bx];
            else if (op == 0x42 && bx < (int)proto.consts.size() && proto.consts[(size_t)bx].tag == 6)
                target = (int)proto.consts[(size_t)bx].idx;
            if (target >= 0 && target < count) { sites[(size_t)index].push_back(target); ++refs[(size_t)target]; }
            offset += tc::is_de_width8(op) ? 8 : 4;
        }
    }
    std::vector<char> live((size_t)count, 0);
    std::vector<int> work{root};
    while (!work.empty()) {
        const int at = work.back(); work.pop_back();
        if (live[(size_t)at]) continue;
        live[(size_t)at] = 1;
        for (int child : sites[(size_t)at]) work.push_back(child);
    }
    for (int index = 0; index < count; ++index) {
        if (live[(size_t)index] || refs[(size_t)index] != 0) continue;
        int host = -1;
        for (int above = index + 1; above < count; ++above)
            if (live[(size_t)above]) { host = above; break; }
        if (host >= 0) g_orphans_by_host[host].push_back(index);
    }
}

// ---- Shared prototypes (O2 inlining) --------------------------------------------------------------
// DE inlines small local functions (-O2); an inlined body that contains a function literal makes every
// inlined copy reference THE SAME prototype, so one stock prototype has several closure sites (44.1.1:
// 31 prototypes in 29 modules). The emitter writes one literal per site, which the compiler turns into
// one prototype per site: every later prototype index shifted (PROTO_COUNT). Each literal of a
// prototype with two or more closure sites is marked `-- RENOVICE_SHARED_PROTO <index>` on its
// `function(` line; the recompiler merges copies that compile to the identical prototype
// (src/shared_protos.h). Re-inlining instead is not reproducible: Luau's inliner decides by an AST cost
// model and the register-faithful emission is costlier than the original source (11 of 31 rejected).
// RENOVICE_NO_SHARED_PROTO_MARKER disables the marker.
static std::set<int> g_shared_protos;

static void compute_shared_protos(const de::Module& m) {
    g_shared_protos.clear();
    if (std::getenv("RENOVICE_NO_SHARED_PROTO_MARKER")) return;
    const int count = (int)m.protos.size();
    std::vector<int> refs((size_t)count, 0);
    for (const de::Proto& proto : m.protos) {
        size_t offset = 0;
        while (offset + 4 <= proto.code.size()) {
            const int op = (uint8_t)proto.code[offset];
            const int bx = (uint8_t)proto.code[offset + 2] | ((uint8_t)proto.code[offset + 3] << 8);
            int target = -1;
            if (op == 0x16 && bx < (int)proto.kids.size()) target = (int)proto.kids[(size_t)bx];
            else if (op == 0x42 && bx < (int)proto.consts.size() && proto.consts[(size_t)bx].tag == 6)
                target = (int)proto.consts[(size_t)bx].idx;
            if (target >= 0 && target < count) ++refs[(size_t)target];
            offset += tc::is_de_width8(op) ? 8 : 4;
        }
    }
    for (int index = 0; index < count; ++index)
        if (refs[(size_t)index] >= 2) g_shared_protos.insert(index);
}

// Append the marker to the `function(...)` header line of an emitted literal.
static void mark_shared_literal(std::string& body, int proto) {
    if (!g_shared_protos.count(proto) || body.compare(0, 9, "function(") != 0) return;
    size_t eol = body.find('\n');
    if (eol == std::string::npos) return;
    if (eol > 0 && body[eol - 1] == '\r') --eol;
    body.insert(eol, std::string(" ") + sp::shared_proto_marker() + std::to_string(proto));
}

// Insert the dead orphan literals hosted by `host` before the closing `end` of its function text.
// Placeholders are expanded by the caller's inline_closures pass like any closure site.
static bool append_orphan_literals(std::string& fn, int host, const de::Module& m) {
    const auto found = g_orphans_by_host.find(host);
    if (found == g_orphans_by_host.end()) return true;
    const size_t last = fn.find_last_not_of(" \t\r\n");
    if (last == std::string::npos || last < 2 || fn.compare(last - 2, 3, "end") != 0) return false;
    const size_t end_line = fn.rfind('\n', last - 2);
    if (end_line == std::string::npos) return false;
    // A bare trailing `return` must stay the last statement of its block; refuse instead of
    // producing source the compiler rejects.
    const size_t previous_end = fn.find_last_not_of(" \t\r\n", end_line);
    if (previous_end != std::string::npos) {
        size_t previous_line = fn.rfind('\n', previous_end);
        previous_line = previous_line == std::string::npos ? 0 : previous_line + 1;
        size_t text = previous_line;
        while (text < fn.size() && fn[text] == ' ') ++text;
        if (fn.compare(text, 7, "return ") == 0 || fn.compare(text, 7, "return\n") == 0) return false;
    }
    const size_t end_column = (last - 2) - (end_line + 1);
    const std::string indent(end_column + 2, ' ');
    std::string block;
    for (int orphan : found->second) {
        const de::Proto& proto = m.protos[(size_t)orphan];
        const int upvalues = proto.hdr.size() > 2 ? (uint8_t)proto.hdr[2] : 0;
        std::string names, values, caps;
        for (int slot = 0; slot < upvalues; ++slot) {
            const std::string name = "__renovice_orphan_" + std::to_string(orphan) + "_u" + std::to_string(slot);
            names += (slot ? ", " : "") + name;
            values += slot ? ", {}" : "{}";
            caps += (slot ? "," : "") + name;
        }
        block += indent + "if false then\n";
        if (upvalues) block += indent + "  local " + names + " = " + values + "\n";
        block += indent + "  local _ = function<" + std::to_string(orphan)
               + (upvalues ? "|" + caps : std::string()) + ">\n";
        block += indent + "end\n";
    }
    fn.insert(end_line + 1, block);
    return true;
}

// Length of the Lua string literal starting at `at` ("..." / '...' with escapes, or a long bracket
// [[...]] / [==[...]==]); 0 when `at` does not start one. The inline renaming passes below rewrite
// `v<digit>` / `u<digit>` TOKENS; without this guard they also rewrote text inside string literals
// (Settings p423: "v2.20" became "c424v2.20"). RENOVICE_NO_INLINE_STRING_GUARD disables the guard.
static size_t lua_string_span(const std::string& text, size_t at) {
    if (at >= text.size() || std::getenv("RENOVICE_NO_INLINE_STRING_GUARD")) return 0;
    const char open = text[at];
    if (open == '-' && at + 1 < text.size() && text[at + 1] == '-') {   // comment: never renamed
        const size_t bracket = (at + 2 < text.size() && text[at + 2] == '[') ? lua_string_span(text, at + 2) : 0;
        if (bracket) return 2 + bracket;
        const size_t line_end = text.find('\n', at);
        return (line_end == std::string::npos ? text.size() : line_end) - at;
    }
    if (open == '"' || open == '\'') {
        size_t z = at + 1;
        while (z < text.size() && text[z] != open) {
            if (text[z] == '\\' && z + 1 < text.size()) ++z;
            ++z;
        }
        return z < text.size() ? z + 1 - at : 0;
    }
    if (open == '[') {
        size_t z = at + 1, level = 0;
        while (z < text.size() && text[z] == '=') { ++level; ++z; }
        if (z >= text.size() || text[z] != '[') return 0;
        const std::string close = "]" + std::string(level, '=') + "]";
        const size_t end = text.find(close, z + 1);
        return end == std::string::npos ? 0 : end + close.size() - at;
    }
    return 0;
}

// ---- Dead tails after an endless loop ------------------------------------------------------------
// Source such as `while true do ... end  print("exit")` compiles the statements after the loop even
// though no path reaches them (the loop has no exit test). The emitter walks reachable blocks only,
// so the rebuilt prototype lost those instructions and their constants (44.1.1: 43 such tails in 31
// modules, e.g. PatrolScript "exit", DayNightTests "... Complete!"). The upstream compiler keeps code
// after `while true do ... end` (it is not an always-terminating statement), so re-emitting the
// tail after the loop reproduces it.
// Accepted shape only: the maximal unreachable SUFFIX of the code, directly after a JUMPBACK (endless
// loop) or a RETURN, closed (no branch leaves it), containing at least one op other than
// RETURN/JUMP/JUMPBACK. The tail is decompiled as a synthetic prototype whose code is that suffix
// (relative branch offsets are unchanged by the shift). After a JUMPBACK its statements are spliced
// before the function's final `do return end`; after a RETURN the final `do return X end` is spelled
// `repeat return X until true` (same instruction; not a terminator to the upstream compiler's
// dead-code rule, which drops statements after `return`) and the tail follows it. Register names are register-derived (`v<N>`); a tail using a lexical
// `__renovice_local_` name, or a function not ending in `do return end`, is left as before.
// RENOVICE_NO_DEAD_TAIL disables the mechanism.
static size_t dead_tail_start(const de::Proto& proto, int* previous_op = nullptr) {
    const std::string& code = proto.code;
    std::vector<size_t> offsets; std::vector<int> ops;
    for (size_t offset = 0; offset + 4 <= code.size();) {
        const int op = (uint8_t)code[offset];
        offsets.push_back(offset); ops.push_back(op);
        offset += tc::is_de_width8(op) ? 8 : 4;
    }
    if (offsets.size() < 2) return std::string::npos;
    std::map<size_t, size_t> at;
    for (size_t index = 0; index < offsets.size(); ++index) at[offsets[index]] = index;
    auto branch_target = [&](size_t index, long long& target) -> bool {
        switch (ops[index]) {
        case 0x40: case 0x25: case 0x4b: case 0x18: case 0x37: case 0x27: case 0x21:
        case 0x1c: case 0x23: case 0x33: case 0x20: case 0x41: case 0x34: case 0x3a:
        case 0x47: case 0x0a: case 0x0b: case 0x30: case 0x1b: case 0x1e: {
            const size_t offset = offsets[index];
            const int bx = (int16_t)(uint16_t)((uint8_t)code[offset + 2] | ((uint8_t)code[offset + 3] << 8));
            target = (long long)offset + 4 + (long long)bx * 4;
            return true;
        }
        default: return false;
        }
    };
    std::vector<char> reach(offsets.size(), 0);
    std::vector<size_t> work{0};
    while (!work.empty()) {
        const size_t index = work.back(); work.pop_back();
        if (index >= offsets.size() || reach[index]) continue;
        reach[index] = 1;
        const int op = ops[index];
        if (op == 0x29) continue;                                   // RETURN
        long long target = 0;
        if (branch_target(index, target)) {
            const auto found = at.find((size_t)target);
            if (target < 0 || found == at.end()) return std::string::npos;   // malformed: refuse
            work.push_back(found->second);
            if (op == 0x40 || op == 0x25 || op == 0x0b || op == 0x30 || op == 0x1b) continue;
        }
        if (op == 0x04 && (uint8_t)code[offsets[index] + 3]) {     // LOADB with skip
            const auto found = at.find(offsets[index] + 4 + 4 * (size_t)(uint8_t)code[offsets[index] + 3]);
            if (found == at.end()) return std::string::npos;
            work.push_back(found->second);
        }
        work.push_back(index + 1);
    }
    size_t first = offsets.size();
    while (first > 0 && !reach[first - 1]) --first;
    if (first == offsets.size() || first == 0) return std::string::npos;
    // An endless loop closes with JUMPBACK in stock; our transcoder lowers JUMPBACK to a backward
    // JUMP, so a re-decompile of our own output must accept that spelling too (compiler closure).
    long long back_target = 0;
    const bool backward_jump = ops[first - 1] == 0x40 && branch_target(first - 1, back_target)
                               && back_target < (long long)offsets[first - 1];
    if (ops[first - 1] != 0x25 && ops[first - 1] != 0x29 && !backward_jump) return std::string::npos;
    if (previous_op) *previous_op = backward_jump ? 0x25 : ops[first - 1];
    bool substantive = false;
    for (size_t index = first; index < offsets.size(); ++index) {
        // RETURN/JUMP/JUMPBACK and CLOSEUPVALS (0x39, the implicit end of a function with captured
        // locals) are compiler glue: a tail of only these is the function's own implicit end and
        // has no source statement (SkyboxEffects p4).
        if (ops[index] != 0x29 && ops[index] != 0x40 && ops[index] != 0x25 && ops[index] != 0x39)
            substantive = true;
        long long target = 0;
        if (branch_target(index, target) && target < (long long)offsets[first]) return std::string::npos;
    }
    return substantive ? offsets[first] : std::string::npos;
}

// Fill em::late_scope_locals() for one module before any of its prototypes is emitted: the
// emitter's exact local-limit rule must count the locals added to a prototype's own scope AFTER its
// emission. Orphan literal blocks are sequential `if false then` blocks, so the reserve is the
// largest single block (its upvalue names + `_`). A dead-tail splice declares locals the emitter
// cannot predict: unknown (-1, the rule fails closed). Requires compute_orphan_hosts first.
static void compute_late_scope_locals(const de::Module& m) {
    std::map<int, int>& reserved = em::late_scope_locals();
    reserved.clear();
    for (const auto& host : g_orphans_by_host) {
        int widest = 0;
        for (int orphan : host.second) {
            const de::Proto& proto = m.protos[(size_t)orphan];
            const int upvalues = proto.hdr.size() > 2 ? (uint8_t)proto.hdr[2] : 0;
            widest = std::max(widest, upvalues + 1);
        }
        reserved[host.first] = widest;
    }
    if (std::getenv("RENOVICE_NO_DEAD_TAIL")) return;
    for (size_t index = 0; index < m.protos.size(); ++index)
        if (dead_tail_start(m.protos[index]) != std::string::npos) reserved[(int)index] = -1;
}

static bool splice_dead_tail(std::string& fn, const de::Proto& proto, int idx,
                             const std::vector<std::string>& pool) {
    if (std::getenv("RENOVICE_NO_DEAD_TAIL")) return false;
    int previous_op = -1;
    const size_t start = dead_tail_start(proto, &previous_op);
    if (start == std::string::npos) return false;
    auto refuse = [&](const char* reason) {
        if (std::getenv("RENOVICE_DEAD_TAIL_TRACE"))
            std::fprintf(stderr, "DEAD_TAIL refused proto=%d reason=%s\n", idx, reason);
        return false;
    };
    de::Proto tail_proto = proto;
    tail_proto.code = proto.code.substr(start);
    tail_proto.sc = (int)(tail_proto.code.size() / 4);
    const ir::IProto annotated = ir_annotate(tail_proto, idx, pool, g_nb);
    if (!annotated.ok) return refuse("annotate");
    bool ok = false; std::string why;
    const std::string tail = decompile_proto_anon(annotated, idx, ok, why);
    // Closure placeholders in the tail (`function<N|caps>`) name the same child indices and the same
    // register-derived capture names as the host, so the caller's inlining pass expands them like
    // any other site; the tail follows every live literal, as it did in the original source.
    if (!ok) return refuse("tail decompile");
    if (tail.find("__renovice_local_") != std::string::npos) return refuse("lexical local in tail");
    auto split = [](const std::string& text) {
        std::vector<std::string> lines; size_t pos = 0;
        while (pos <= text.size()) {
            size_t end = text.find('\n', pos);
            if (end == std::string::npos) end = text.size();
            lines.push_back(text.substr(pos, end - pos));
            if (end == text.size()) break;
            pos = end + 1;
        }
        while (!lines.empty() && lines.back().find_first_not_of(" \t\r") == std::string::npos) lines.pop_back();
        return lines;
    };
    const std::vector<std::string> tail_lines = split(tail);
    std::vector<std::string> fn_lines = split(fn);
    if (tail_lines.size() < 3 || fn_lines.size() < 3) return refuse("short text");
    if (tail_lines.back().find_first_not_of(' ') == std::string::npos
        || tail_lines.back().substr(tail_lines.back().find_first_not_of(' ')) != "end") return refuse("tail end");
    if (fn_lines.back().substr(fn_lines.back().find_first_not_of(' ')) != "end") return refuse("host end");
    std::string& final_return = fn_lines[fn_lines.size() - 2];
    const size_t body_indent = final_return.find_first_not_of(' ');
    if (body_indent == std::string::npos) return refuse("indent");
    const std::string final_text = final_return.substr(body_indent);
    if (previous_op == 0x25 && final_text != "do return end") return refuse("loop host final statement is not do return end");
    if (previous_op == 0x29) {
        // Live flow ends in a RETURN. The upstream compiler drops statements after an always-
        // terminating `return`, so spell that return as `repeat return ... until true`: the same
        // single RETURN instruction (verified with bin/luau-compile.exe -O1), but not a terminator
        // to the compiler's dead-code rule, so the tail after it is compiled as in stock.
        if (final_text.compare(0, 9, "do return") != 0) return refuse("return host final statement is not do return");
        if (final_text.size() < 13 || final_text.compare(final_text.size() - 4, 4, " end") != 0) return refuse("return host final statement shape");
        const std::string values = final_text.substr(9, final_text.size() - 9 - 4);
        final_return = std::string(body_indent, ' ') + "repeat return" + values + " until true";
    }
    auto declared_names = [](const std::vector<std::string>& lines, size_t indent, size_t first, size_t last,
                             std::set<std::string>& names) {
        for (size_t index = first; index < last; ++index) {
            const std::string& line = lines[index];
            if (line.size() <= indent + 6 || line.compare(0, indent, std::string(indent, ' ')) != 0
                || line.compare(indent, 6, "local ") != 0) continue;
            std::string list = line.substr(indent + 6);
            const size_t assign = list.find(" = ");
            if (assign != std::string::npos) list = list.substr(0, assign);
            size_t pos = 0;
            while (pos < list.size()) {
                size_t comma = list.find(',', pos);
                if (comma == std::string::npos) comma = list.size();
                std::string name = list.substr(pos, comma - pos);
                name.erase(0, name.find_first_not_of(' '));
                name.erase(name.find_last_not_of(' ') + 1);
                if (!name.empty()) names.insert(name);
                pos = comma + 1;
            }
        }
    };
    // The tail's body: drop its header line, its leading register declarations, its closing `end`.
    size_t tail_first = 1;
    std::set<std::string> tail_declared, fn_declared;
    while (tail_first + 1 < tail_lines.size()
           && tail_lines[tail_first].compare(0, body_indent + 6, std::string(body_indent, ' ') + "local ") == 0) {
        declared_names(tail_lines, body_indent, tail_first, tail_first + 1, tail_declared);
        ++tail_first;
    }
    declared_names(fn_lines, body_indent, 1, fn_lines.size() - 2, fn_declared);
    // Parameters are declared by the function header on both sides.
    // Declare in REGISTER order: locals are allocated in declaration order, so `v10` listed before
    // `v2` (string order) bound the names to scrambled registers and every re-decompile renamed
    // the tail again (CoHUpgrades p31: no compiler fixed point).
    auto register_number = [](const std::string& name) -> long {
        if (name.size() < 2 || name[0] != 'v') return -1;
        long value = 0;
        for (size_t at = 1; at < name.size(); ++at) {
            if (!std::isdigit((unsigned char)name[at])) return -1;
            value = value * 10 + (name[at] - '0');
        }
        return value;
    };
    std::vector<std::string> missing_names;
    for (const std::string& name : tail_declared)
        if (!fn_declared.count(name)) missing_names.push_back(name);
    std::stable_sort(missing_names.begin(), missing_names.end(),
                     [&](const std::string& left, const std::string& right) {
                         const long a = register_number(left), b = register_number(right);
                         if ((a < 0) != (b < 0)) return a >= 0;
                         return a < b;
                     });
    std::string missing;
    for (const std::string& name : missing_names) missing += (missing.empty() ? "" : ", ") + name;
    std::string block;
    if (!missing.empty()) block += std::string(body_indent, ' ') + "local " + missing + "\n";
    for (size_t index = tail_first; index + 1 < tail_lines.size(); ++index) block += tail_lines[index] + "\n";
    std::string rebuilt;
    for (size_t index = 0; index + 2 < fn_lines.size(); ++index) rebuilt += fn_lines[index] + "\n";
    if (previous_op == 0x29) rebuilt += fn_lines[fn_lines.size() - 2] + "\n" + block + fn_lines.back();
    else {
        // The tail ends with the function's own final RETURN (`do return end`); the host's
        // synthetic final return after it would be a second, uncompiled terminator.
        const std::string& tail_last = tail_lines[tail_lines.size() - 2];
        const size_t tail_text = tail_last.find_first_not_of(' ');
        const bool tail_returns = tail_text != std::string::npos
                                  && tail_last.compare(tail_text, std::string::npos, "do return end") == 0;
        rebuilt += block + (tail_returns ? std::string() : fn_lines[fn_lines.size() - 2] + "\n")
                 + fn_lines.back();
    }
    fn = rebuilt;
    return true;
}

// Closures are referenced as `function<N>` by the expression layer, which has no access to the
// module and so cannot recurse. Substitute each placeholder with the actual emitted sub-function.
// Without this every DUPCLOSURE/NEWCLOSURE site emits a token that is not Luau at all — the single
// largest cause of compile rejection (45.58% -> see FINDINGS).
static std::string inline_closures(const std::string& src, const de::Module& m,
                                   const std::vector<std::string>& pool, int depth) {
    if (depth > 64) return src;                     // pathological nesting guard (was 8: real scripts nest deeper, and stopping early left a proto uninlined -> a REACHABLE proto lost)
    std::string out; size_t i = 0;
    while (i < src.size()) {
        size_t p = src.find("function<", i);
        if (p == std::string::npos) { out += src.substr(i); break; }
        size_t q = src.find('>', p);
        if (q == std::string::npos) { out += src.substr(i); break; }
        // placeholder body is "N" or "N|cap0,cap1,..."
        std::string spec = src.substr(p + 9, q - p - 9);
        std::vector<std::string> caps;
        size_t bar = spec.find('|');
        if (bar != std::string::npos) {
            std::string rest = spec.substr(bar + 1);
            spec = spec.substr(0, bar);
            for (size_t z = 0; z <= rest.size(); ) {
                size_t e2 = rest.find(',', z);
                if (e2 == std::string::npos) e2 = rest.size();
                if (e2 > z) caps.push_back(rest.substr(z, e2 - z));
                z = e2 + 1;
            }
        }
        int sub = std::atoi(spec.c_str());
        out += src.substr(i, p - i);
        // `function() end(x)` and `function() end.f` are SYNTAX ERRORS — a function expression can
        // only be called or indexed through parentheses. Wrap when a call/index suffix follows.
        // Parens are semantically neutral here: a function expression is always single-valued, so
        // there is no multret to truncate.
        char nx = (q + 1 < src.size()) ? src[q + 1] : '\0';
        bool wrap = (nx == '(' || nx == '.' || nx == ':' || nx == '[');
        // A failed sub-proto used to become `function() end` — syntactically valid, semantically a
        // DELETED FUNCTION, and invisible to every gate. `ToggleFocus` exported a 7-parameter function
        // in one pass and an empty one in the other for exactly this reason. Record the failure so the
        // caller can refuse to emit, instead of shipping a plausible lie.
        std::string body = "function() end";
        if (sub >= 0 && sub < (int)m.protos.size()) {
            ir::IProto sp = ir_annotate(m.protos[sub], sub, pool, g_nb);
            bool sok = false; std::string swhy;
            std::string t = sp.ok ? decompile_proto_anon(sp, sub, sok, swhy) : std::string();
            if (sok) splice_dead_tail(t, m.protos[sub], sub, pool);
            if (sok && !append_orphan_literals(t, sub, m)) {
                sok = false;
                swhy = "orphan host has no insertion point before its closing end";
            }
            if (sok) {
                body = inline_closures(t, m, pool, depth + 1);
                mark_shared_literal(body, sub);
            }
            else g_inline_fail = "proto " + std::to_string(sub) + ": " +
                                 (sp.ok ? swhy : sp.why);
        } else g_inline_fail = "closure index " + std::to_string(sub) + " out of range";
        // An inlined body declares its OWN registers as locals, and those names collide with the
        // parent's: the sub-proto's `local v0` SHADOWS the parent `v0`, so a capture bound to `v0`
        // reads the inner nil instead. Give this body a unique register prefix first. Captures are
        // `u<i>` and so are untouched here, and the parent names substituted afterwards are
        // parent-scoped by construction.
        {
            static int serial = 0; ++serial;
            if (std::getenv("RENOVICE_INLINE_TRACE"))
                std::fprintf(stderr, "INLINE_SERIAL serial=%d proto=%d depth=%d\n",
                             serial, sub, depth);
            std::string tag = "c" + std::to_string(serial) + "v";
            std::string outb; size_t z = 0;
            while (z < body.size()) {
                if (const size_t literal = lua_string_span(body, z)) {
                    outb.append(body, z, literal); z += literal; continue;
                }
                if (body[z] != 'v') { outb += body[z++]; continue; }
                size_t h = z;
                char before = h ? body[h - 1] : ' ';
                bool start = !(std::isalnum((unsigned char)before) || before == '_');
                bool num   = (h + 1 < body.size()) && std::isdigit((unsigned char)body[h + 1]);
                outb += body.substr(z, h - z);
                outb += (start && num) ? tag : std::string("v");
                z = h + 1;
            }
            body.swap(outb);
        }
        // Bind the sub-proto's upvalues to names that exist HERE. Recursion runs first, so a nested
        // closure has already reduced its own captures to this proto's `u<i>`/`v<i>`; only then is
        // this level's mapping applied, which resolves a whole capture chain correctly. This MUST
        // be one simultaneous token pass. Sequential replacements corrupt chains such as
        // `u0 -> u1, u1 -> v0`: the old loop rewrote the newly produced `u1` a second time and made
        // both captures refer to `v0`. Whole-token parsing also keeps `u1` distinct from `u10`.
        {
            std::string outb;
            size_t z = 0;
            while (z < body.size()) {
                if (const size_t literal = lua_string_span(body, z)) {
                    outb.append(body, z, literal); z += literal; continue;
                }
                const unsigned char current = (unsigned char)body[z];
                const unsigned char before = z ? (unsigned char)body[z - 1] : (unsigned char)' ';
                const bool token_start = current == (unsigned char)'u'
                    && z + 1 < body.size()
                    && std::isdigit((unsigned char)body[z + 1])
                    && !(std::isalnum(before) || before == (unsigned char)'_');
                if (!token_start) {
                    outb += body[z++];
                    continue;
                }

                size_t after = z + 1;
                size_t slot = 0;
                while (after < body.size() && std::isdigit((unsigned char)body[after])) {
                    slot = slot * 10 + (size_t)(body[after] - '0');
                    ++after;
                }
                const unsigned char following = after < body.size()
                    ? (unsigned char)body[after] : (unsigned char)' ';
                if ((std::isalnum(following) || following == (unsigned char)'_')
                    || slot >= caps.size()) {
                    outb.append(body, z, after - z);
                } else {
                    outb += caps[slot];
                }
                z = after;
            }
            body.swap(outb);
        }
        remove_inlined_generated_self_assignments(body);
        while (!body.empty() && (body.back() == '\n' || body.back() == '\r')) body.pop_back();
        // Re-indent the spliced body to the CALL SITE's column. Without this an inlined closure's
        // statements land at the same indent as module level, which is still correct Luau
        // (indentation is not semantic) but is unreadable AND defeats any indentation-based scope
        // analysis — a check built on that assumption reported 153 false defects in 300 files.
        {
            size_t ls = out.rfind('\n');
            ls = (ls == std::string::npos) ? 0 : ls + 1;
            size_t base = 0;
            while (ls + base < out.size() && out[ls + base] == ' ') ++base;
            std::string pad(base, ' ');
            std::string ind2;
            for (size_t z = 0; z < body.size(); ++z) {
                ind2 += body[z];
                if (body[z] == '\n') ind2 += pad;
            }
            body.swap(ind2);
        }
        out += wrap ? ("(" + body + ")") : body;
        i = q + 1;
    }
    return out;
}

static void conddiag(const sa::Analyzer& A, int idx) {
    // Diagnostic (loops campaign 2026-10-09): RENOVICE_SATREE_PIDX=N prints prototype N's final
    // region tree (kind, head, blocks) so loop nesting choices can be read without the emitter.
    if (const char* tree_pidx = std::getenv("RENOVICE_SATREE_PIDX")) {
        if (std::atoi(tree_pidx) == idx && !A.live.empty()) {
            std::function<void(int, int)> dump = [&](int r, int depth) {
                if (r < 0 || r >= (int)A.regions.size()) return;
                const sa::Region& R = A.regions[r];
                static const char* names[] = {"Basic", "Seq", "IfThen", "IfThenElse", "SelfLoop",
                                              "While", "NaturalLoop", "Proper"};
                std::set<int> blocks; A.region_block_set(r, blocks);
                std::fprintf(stderr, "SATREE %*s%d %s head=%d blocks=", depth * 2, "", r,
                             names[(int)R.kind], R.head);
                for (int b : blocks) std::fprintf(stderr, "%d,", b);
                std::fputc('\n', stderr);
                if (R.kind != sa::RK::Basic) for (int c : R.parts) dump(c, depth + 1);
            };
            dump(*A.live.begin(), 0);
        }
    }
    if (std::getenv("RENOVICE_CONDDIAG")) {
        // Diagnostic (conditions campaign 2026-10-09): loop-body DAG decisions and NaturalLoop
        // regions left with an unreduced multi-part interior, per prototype.
        std::fprintf(stderr, "CONDDIAG pidx=%d dag=", idx);
        for (const auto& d : A.dag_log) std::fprintf(stderr, "%d:%d,", d.first, d.second);
        int unreduced = 0, while_tail = 0;
        std::string branchy;   // NaturalLoops whose unreduced parts branch to >= 2 other non-head parts
        std::function<void(int)> walk = [&](int r) {
            if (r < 0 || r >= (int)A.regions.size()) return;
            const sa::Region& L = A.regions[r];
            if (L.kind == sa::RK::NaturalLoop && L.parts.size() > 1) {
                ++unreduced;
                std::map<int, int> owner;
                for (int part : L.parts) {
                    std::set<int> pb; A.region_block_set(part, pb);
                    for (int b : pb) owner[b] = part;
                }
                bool is_branchy = false;
                for (int part : L.parts) {
                    std::set<int> pb; A.region_block_set(part, pb);
                    std::set<int> targets;
                    for (int b : pb) {
                        if (b < 0 || b >= (int)A.block_edges.size()) continue;
                        for (int t : {A.block_edges[b].t, A.block_edges[b].f}) {
                            auto it = owner.find(t);
                            if (it != owner.end() && it->second != part && it->second != L.head) targets.insert(it->second);
                        }
                    }
                    if (targets.size() >= 2) is_branchy = true;
                }
                if (is_branchy) branchy += std::to_string(L.head) + ";";
            }
            if (L.kind == sa::RK::While && L.parts.size() >= 2
                && A.regions[L.parts[0]].kind != sa::RK::Basic) {
                // While whose test is not the head region's first block (emit.h head_block).
                std::function<int(int)> first_block = [&](int x) -> int {
                    if (x < 0 || x >= (int)A.regions.size()) return -1;
                    if (A.regions[x].kind == sa::RK::Basic) return A.regions[x].block;
                    return A.regions[x].parts.empty() ? -1 : first_block(A.regions[x].parts[0]);
                };
                const int body = first_block(L.parts[1]);
                std::set<int> hbset; A.region_block_set(L.parts[0], hbset);
                int test = -1, matches = 0;
                for (int b : hbset)
                    if (b >= 0 && b < (int)A.block_edges.size()
                        && (A.block_edges[b].t == body || A.block_edges[b].f == body)) { test = b; ++matches; }
                if (matches == 1 && test != first_block(L.parts[0])) ++while_tail;
            }
            for (int c : L.parts) walk(c);
        };
        if (!A.live.empty()) walk(*A.live.begin());
        std::fprintf(stderr, " unreduced_loops=%d while_tail=%d branchy=%s\n", unreduced, while_tail, branchy.c_str());
    }
}

static void proper_text_diag(const std::string& text, int idx) {
    // Diagnostic (proper campaign 2026-10-09): selector variables left in one prototype's own text
    // (nested closures are still placeholders here). No output change.
    if (!std::getenv("RENOVICE_PROPERDIAG")) return;
    std::set<std::string> names;
    const std::string prefix = "__renovice_state_";
    for (size_t at = text.find(prefix); at != std::string::npos; at = text.find(prefix, at + 1)) {
        size_t end = at + prefix.size();
        while (end < text.size() && std::isdigit((unsigned char)text[end])) ++end;
        names.insert(text.substr(at, end - at));
    }
    std::fprintf(stderr, "PDIAG_TEXT pidx=%d selectors=%zu\n", idx, names.size());
}

static std::string decompile_proto_text(const ir::IProto& ip, int idx, bool& ok, std::string& why) {
    ok = false;
    st::Graph g;
    if (!build_graph(ip, g)) { why = "cfg build failed"; return ""; }
    if (g.n.empty()) { why = "empty proto"; return ""; }
    st::compute_dom(g);
    sa::Analyzer A; A.build(g);
    int steps = 0;
    if (std::getenv("RENOVICE_SASTEPS")) std::fprintf(stderr, "SA_BEGIN pidx=%d\n", idx);
    if (!A.reduce(steps)) { why = "did not reduce to one region"; return ""; }
    conddiag(A, idx);
    em::Emitter E; E.ip = &ip; E.g = &g; E.A = &A; E.pidx = idx;
    // Authoritative loop map, computed from dominators BEFORE emission. The emitter reads it
    // instead of re-deriving loop structure from opcodes (see structur.h find_loops).
    const std::vector<st::Loop> _loops = st::find_loops(g);
    E.authoritative_loops = _loops;
    for (const st::Loop& L : _loops) {
        if (L.header >= 0) E.authoritative_loop_bodies[L.header] = L.body;
        if (L.latch >= 0) E.latch_of_loop.insert(L.latch);
        if (L.header >= 0) E.header_of_loop.insert(L.header);
        if (L.header >= 0) {                       // every entry point to this loop -> its header
            E.block2loop[L.header] = L.header;
            if (L.latch >= 0) E.block2loop[L.latch] = L.header;
            if (L.prep  >= 0) E.block2loop[L.prep]  = L.header;
        }
        if (L.prep >= 0 && L.latch >= 0) E.prep2latch[L.prep] = L.latch;
    }
    E.assign_loop_owners(_loops);   // decide which region wraps each loop BEFORE emitting
    E.assign_emit_owners(_loops);   // RENOVICE_OWNEMIT: single wrapper owner per loop
    E.enable_exact_six_shell_outer =
        loop_identity_repair_enabled()
        && has_exact_six_shell_nested_numeric(_loops);
    E.enable_proper_generic_two_exit = proper_generic_two_exit_enabled();
    E.enable_multi_latch_generic_body_scope = multi_latch_generic_body_scope_enabled();
    E.enable_gyre_second_generic_nested = gyre_second_generic_nested_enabled();
    E.enable_gyre_energized_outer = gyre_energized_outer_enabled();
    E.enable_pulse_four_latch_generic_dedup = pulse_four_latch_generic_dedup_enabled();
    E.enable_two_block_two_exit_reversed_generic = pulse_two_exit_match_fold_enabled();
    E.enable_authoritative_region_nested_outer =
        authoritative_region_nested_outer_enabled();
    E.enable_split_for_whole_part = split_for_whole_part_enabled();
    E.enable_parent_first_child_coalesce = parent_first_child_coalesce_enabled();
    E.enable_parent_first_reversed_generic = parent_first_reversed_generic_enabled();
    E.enable_repaired_generic_child_coalesce = repaired_generic_child_coalesce_enabled();
    E.enable_seq_generic_for_coalesce = seq_generic_for_coalesce_enabled();
    trace_nested_numeric_shapes(_loops, idx);
    char nm[32]; std::snprintf(nm, sizeof nm, "proto_%d", idx);
    // PLAN pass: identical walk, output discarded, recording every loop claim and its nesting.
    // Then RENDER with duplicates already resolved, so no wrapper is ever removed after placement.
    if (true) {   // PLAN/RENDER is now the default path (FINDINGS #93)
        em::Emitter P = E; P.planning = true;
        P.emit_function(nm);
        if (parent_first_exact_outer_enabled()) {
            E.parent_first_outer_headers =
                E.derive_parent_first_outer_headers(_loops, P);
            if (!E.parent_first_outer_headers.empty()) {
                em::Emitter scoped = E; scoped.planning = true;
                scoped.emit_function(nm);
                P = scoped;
            }
        }
        bool single_loop_structure_surplus =
            loop_identity_repair_enabled()
            && P.header_of_loop.size() == 1
            && emitted_loop_region_count(A) == P.header_of_loop.size()
            && P.plan_claim.size() > P.header_of_loop.size();
        bool replan_surplus_generic =
            single_loop_structure_surplus
            || (!std::getenv("RENOVICE_NO_REVERSED_GENERIC_CONTINUE")
                && P.has_reversed_generic_natural
                && P.plan_claim.size() > P.header_of_loop.size());
        if (replan_surplus_generic || !P.terminal_arm_loop_latches.empty()) {
            // The first planning walk discovers terminal-arm loop latches.  Claimants visited before
            // that discovery used prep/body keys, so repeat planning once with the complete latch set
            // and obtain one canonical winner per logical loop. Prototypes outside this narrow family
            // retain the established two-pass plan/render cost.
            E.terminal_arm_loop_latches = P.terminal_arm_loop_latches;
            E.enable_surplus_generic_collision = replan_surplus_generic;
            em::Emitter Q = E; Q.planning = true;
            Q.emit_function(nm);
            bool collision_exact = !replan_surplus_generic
                || Q.plan_claim.size() == Q.header_of_loop.size();
            if (collision_exact) {
                E.accept_planning_result(Q);
            } else {
                // Canonical collision identity is safe only when it reconciles the complete
                // authoritative header set.  If it undershoots, it merged distinct missing-loop
                // placeholders and must be rejected as a unit.
                E.enable_surplus_generic_collision = false;
                if (!P.terminal_arm_loop_latches.empty()) {
                    em::Emitter R = E; R.planning = true;
                    R.emit_function(nm);
                    E.accept_planning_result(R);
                } else {
                    E.accept_planning_result(P);
                }
            }
        } else {
            E.accept_planning_result(P);
        }
        // Activate proven loop-frame suppression before rendering begins. A containing Seq may emit
        // the PREP block before traversal reaches the winning loop region, so activating at the
        // wrapper itself is too late. Only planning keys that have a resolved winner are eligible.
        for (const auto& kv : P.planned_for_moves)
            if (E.plan_winner.count(kv.first))
                E.suppress_insns.insert(kv.second.begin(), kv.second.end());
        if (std::getenv("RENOVICE_PLANDBG"))
            std::fprintf(stderr, "PLAN claims=%zu winners=%zu\n",
                         P.plan_claim.size(), E.plan_winner.size());
    }
    std::string src = E.emit_function(nm);
    if (E.bad) { why = E.why; return src; }
    proper_text_diag(src, idx);
    ok = true;
    return src;
}

static std::string decompile_proto_anon(const ir::IProto& ip, int idx,
                                        bool& ok, std::string& why) {
    ok = false;
    st::Graph g;
    if (!build_graph(ip, g)) { why = "cfg build failed"; return ""; }
    if (g.n.empty()) { why = "empty proto"; return ""; }
    st::compute_dom(g);
    sa::Analyzer A; A.build(g);
    int steps = 0;
    if (std::getenv("RENOVICE_SASTEPS")) std::fprintf(stderr, "SA_BEGIN pidx=%d\n", idx);
    if (!A.reduce(steps)) { why = "did not reduce"; return ""; }
    conddiag(A, idx);
    em::Emitter E; E.ip = &ip; E.g = &g; E.A = &A; E.pidx = idx;
    // Authoritative loop map, computed from dominators BEFORE emission. The emitter reads it
    // instead of re-deriving loop structure from opcodes (see structur.h find_loops).
    const std::vector<st::Loop> _loops = st::find_loops(g);
    E.authoritative_loops = _loops;
    for (const st::Loop& L : _loops) {
        if (L.header >= 0) E.authoritative_loop_bodies[L.header] = L.body;
        if (L.latch >= 0) E.latch_of_loop.insert(L.latch);
        if (L.header >= 0) E.header_of_loop.insert(L.header);
        if (L.header >= 0) {                       // every entry point to this loop -> its header
            E.block2loop[L.header] = L.header;
            if (L.latch >= 0) E.block2loop[L.latch] = L.header;
            if (L.prep  >= 0) E.block2loop[L.prep]  = L.header;
        }
        if (L.prep >= 0 && L.latch >= 0) E.prep2latch[L.prep] = L.latch;
    }
    E.assign_loop_owners(_loops);   // decide which region wraps each loop BEFORE emitting
    E.assign_emit_owners(_loops);   // RENOVICE_OWNEMIT: single wrapper owner per loop
    E.enable_exact_six_shell_outer =
        loop_identity_repair_enabled()
        && has_exact_six_shell_nested_numeric(_loops);
    E.enable_proper_generic_two_exit = proper_generic_two_exit_enabled();
    E.enable_multi_latch_generic_body_scope = multi_latch_generic_body_scope_enabled();
    E.enable_gyre_second_generic_nested = gyre_second_generic_nested_enabled();
    E.enable_gyre_energized_outer = gyre_energized_outer_enabled();
    E.enable_pulse_four_latch_generic_dedup = pulse_four_latch_generic_dedup_enabled();
    E.enable_two_block_two_exit_reversed_generic = pulse_two_exit_match_fold_enabled();
    E.enable_authoritative_region_nested_outer =
        authoritative_region_nested_outer_enabled();
    E.enable_split_for_whole_part = split_for_whole_part_enabled();
    E.enable_parent_first_child_coalesce = parent_first_child_coalesce_enabled();
    E.enable_parent_first_reversed_generic = parent_first_reversed_generic_enabled();
    E.enable_repaired_generic_child_coalesce = repaired_generic_child_coalesce_enabled();
    E.enable_seq_generic_for_coalesce = seq_generic_for_coalesce_enabled();
    trace_nested_numeric_shapes(_loops, idx);
    if (true) {   // PLAN/RENDER is now the default path (FINDINGS #93)
        em::Emitter P = E; P.planning = true;
        P.emit_function("");
        if (parent_first_exact_outer_enabled()) {
            E.parent_first_outer_headers =
                E.derive_parent_first_outer_headers(_loops, P);
            if (!E.parent_first_outer_headers.empty()) {
                em::Emitter scoped = E; scoped.planning = true;
                scoped.emit_function("");
                P = scoped;
            }
        }
        bool single_loop_structure_surplus =
            loop_identity_repair_enabled()
            && P.header_of_loop.size() == 1
            && emitted_loop_region_count(A) == P.header_of_loop.size()
            && P.plan_claim.size() > P.header_of_loop.size();
        bool replan_surplus_generic =
            single_loop_structure_surplus
            || (!std::getenv("RENOVICE_NO_REVERSED_GENERIC_CONTINUE")
                && P.has_reversed_generic_natural
                && P.plan_claim.size() > P.header_of_loop.size());
        if (replan_surplus_generic || !P.terminal_arm_loop_latches.empty()) {
            E.terminal_arm_loop_latches = P.terminal_arm_loop_latches;
            E.enable_surplus_generic_collision = replan_surplus_generic;
            em::Emitter Q = E; Q.planning = true;
            Q.emit_function("");
            bool collision_exact = !replan_surplus_generic
                || Q.plan_claim.size() == Q.header_of_loop.size();
            if (collision_exact) {
                E.accept_planning_result(Q);
            } else {
                E.enable_surplus_generic_collision = false;
                if (!P.terminal_arm_loop_latches.empty()) {
                    em::Emitter R = E; R.planning = true;
                    R.emit_function("");
                    E.accept_planning_result(R);
                } else {
                    E.accept_planning_result(P);
                }
            }
        } else {
            E.accept_planning_result(P);
        }
        for (const auto& kv : P.planned_for_moves)
            if (E.plan_winner.count(kv.first))
                E.suppress_insns.insert(kv.second.begin(), kv.second.end());
        if (std::getenv("RENOVICE_PLANDBG"))
            std::fprintf(stderr, "PLAN claims=%zu winners=%zu\n",
                         P.plan_claim.size(), E.plan_winner.size());
    }
    std::string fn = E.emit_function("");
    if (E.bad) { why = E.why; return fn; }
    // emit_function("") yields "function (params)...end"; drop the space to get the anonymous form.
    size_t sp = fn.find("function (");
    if (sp != std::string::npos) fn = "function(" + fn.substr(sp + 10);
    proper_text_diag(fn, idx);
    ok = true;
    return fn;
}

static int cmd_decompile(int argc, char** argv) {
    ir_load_namebase();
    g_primary_ability_loop_scope = is_primary_ability_module_path(argv[2]);
    std::string b = read_file(argv[2]);
    de::Module m;
    try { m = de::walk(b); }
    catch (const std::exception& e) { std::fprintf(stderr, "walk error: %s\n", e.what()); return 1; }
    std::vector<std::string> pool = ir::parse_pool(b);
    int only = (argc >= 4) ? std::atoi(argv[3]) : -1;
    std::string rendered;
    for (size_t i = 0; i < m.protos.size(); ++i) {
        if (only >= 0 && (int)i != only) continue;
        ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
        if (!ip.ok) {
            rendered += "-- proto[" + std::to_string(i) + "] ANNOTATE FAILED: "
                     + ip.why + "\n";
            continue;
        }
        bool ok = false; std::string why;
        std::string src = decompile_proto_text(ip, (int)i, ok, why);
        src = inline_closures(src, m, pool, 0);
        if (!ok)
            rendered += "-- proto[" + std::to_string(i) + "] EMIT PROBLEM: "
                     + why + "\n";
        rendered += src + "\n";
    }
    if (argc >= 5) {
        if (!write_file(argv[4], rendered)) {
            std::fprintf(stderr, "decompile: cannot write %s\n", argv[4]);
            return 1;
        }
    } else {
        std::printf("%s", rendered.c_str());
    }
    return 0;
}

// Emit one MODULE as a recompilable script.  Shared by the single-file command and the native
// corpus batch command so promotion scans do not launch one process per file.
static bool decompile_module_source(const std::string& path, std::string& src, std::string& why,
                                    size_t* prototype_count = nullptr) {
    g_primary_ability_loop_scope = is_primary_ability_module_path(path);
    std::string b = read_de_input(path);
    if (b.empty() && !g_input_profile_failure.empty()) { why = g_input_profile_failure; return false; }
    de::Module m;
    try { m = de::walk(b); }
    catch (const std::exception& e) { why = std::string("walk error: ") + e.what(); return false; }
    std::vector<std::string> pool = ir::parse_pool(b);
    if (m.protos.empty()) { why = "no protos"; return false; }
    if (prototype_count) *prototype_count = m.protos.size();
    int root = (int)m.protos.size() - 1;              // the chunk is the LAST proto
    ir::IProto ip = ir_annotate(m.protos[root], root, pool, g_nb);
    if (!ip.ok) { why = std::string("annotate failed: ") + ip.why; return false; }
    bool ok = false;
    // Orphan hosts depend only on the module; computed before the root is emitted so the emitter's
    // local-limit rule can count the orphan locals added to the root afterwards.
    compute_orphan_hosts(m, root);
    compute_late_scope_locals(m);
    src = decompile_proto_text(ip, root, ok, why);
    if (!ok) {
        why = std::string("emit problem: ") + why;
        g_orphans_by_host.clear(); em::late_scope_locals().clear();
        return false;
    }
    g_inline_fail.clear();
    splice_dead_tail(src, m.protos[root], root, pool);
    if (!append_orphan_literals(src, root, m)) {
        why = "orphan host has no insertion point before its closing end";
        g_orphans_by_host.clear(); em::late_scope_locals().clear();
        return false;
    }
    compute_shared_protos(m);
    src = inline_closures(src, m, pool, 0);
    g_orphans_by_host.clear();          // module-scoped: never leak into another module's inlining
    em::late_scope_locals().clear();
    g_shared_protos.clear();
    if (!g_inline_fail.empty()) {
        why = std::string("closure inline failed: ") + g_inline_fail;
        return false;
    }
    // strip the synthetic `function proto_N(...)` wrapper and its trailing `end`
    size_t nl = src.find('\n');
    if (nl != std::string::npos) src = src.substr(nl + 1);
    // Strip the wrapper's closing `end` — which is the LAST LINE, not the last OCCURRENCE of the
    // substring. `rfind("end")` also matches an `end` belonging to a nested `function ... end` that
    // happens to be the chunk's final statement, truncating real code and yielding
    // "Expected 'end' (to close 'function' ...)" or "Expected <eof>, got 'end'".
    size_t e = src.find_last_not_of(" \t\r\n");
    if (e != std::string::npos && e >= 2 && src.compare(e - 2, 3, "end") == 0) {
        size_t ls = src.rfind('\n', e - 2);
        src = (ls == std::string::npos) ? std::string() : src.substr(0, ls + 1);
    }
    return true;
}

// Close the decompiler over the real compiler when explicitly requested.  Most modules are already
// one-pass fixed points.  A smaller family needs several compiler-aware normalization passes before
// the same source spelling is recovered.  This is one general operation over source/bytecode, not a
// filename or prototype exception.
//
// A repeated source state is a genuine deterministic cycle.  Selecting the lexicographically least
// member makes every entry point into that cycle publish the same representative.  A non-repeating
// sequence that reaches the bounded pass limit is left unchanged: guessing a representative for an
// open-ended sequence would manufacture a false fixed point.
static bool canonicalize_module_source(const std::string& original_path, std::string& source,
                                       std::string& why) {
    // The largest currently measured convergent module, LotusUtilities, reaches its exact source
    // fixed point on pass 13 after the primitive-postfix syntax repair.  Sixteen leaves a small
    // diagnostic margin while every already-stable module exits on its first repeated state.
    int max_passes = 16;
    if (const char* configured = std::getenv("RENOVICE_COMPILER_CANONICAL_PASSES")) {
        const int parsed = std::atoi(configured);
        if (parsed >= 2 && parsed <= 16) max_passes = parsed;
    }

    std::error_code ec;
    const fs::path temp_root = fs::temp_directory_path(ec);
    if (ec) {
        why = std::string("cannot resolve temporary directory: ") + ec.message();
        return false;
    }
    const fs::path temp = temp_root /
        ("renovice-compiler-canonical-" + std::to_string((long long)GetCurrentProcessId())
         + "-" + std::to_string((unsigned long long)GetTickCount64()));
    if (!fs::create_directories(temp, ec) || ec) {
        why = std::string("cannot create compiler-canonicalization directory: ") + ec.message();
        return false;
    }

    struct TempCleanup {
        fs::path path;
        ~TempCleanup() { std::error_code ignored; fs::remove_all(path, ignored); }
    } cleanup{temp};

    const std::string original_source = source;
    std::vector<std::string> seen{source};
    const std::string original_name = fs::path(original_path).filename().string();

    for (int pass = 1; pass <= max_passes; ++pass) {
        const fs::path source_path = temp / ("pass-" + std::to_string(pass) + ".luau");
        const fs::path de_path = temp /
            ("pass-" + std::to_string(pass) + "-" + original_name);
        const fs::path next_path = temp / ("pass-" + std::to_string(pass) + ".next.luau");
        const fs::path error_path = temp / ("pass-" + std::to_string(pass) + ".error.txt");
        if (!write_file(source_path.string(), seen.back())) {
            why = std::string("cannot write compiler-canonicalization source: ")
                + source_path.string();
            return false;
        }

        // Run both stages in fresh processes. The certified fixed-point harness does this too.
        // Reusing the current process is observably different because the legacy renderer still has
        // mutable diagnostic/planning globals; Codex was the witness (external cycle 2 fixed,
        // in-process cycle 8 still changing).
        const std::string recompile_inner = std::string("\"") + exe_dir()
            + "\\derecomp.exe\" recompile \"" + source_path.string() + "\" \""
            + de_path.string() + "\" > NUL 2> \"" + error_path.string() + "\"";
        const int recompile_rc = std::system(("\"" + recompile_inner + "\"").c_str());
        if (recompile_rc != 0 || !fs::is_regular_file(de_path)) {
            const std::string detail = read_file(error_path.string());
            why = std::string("compiler-canonicalization recompile failed")
                + (detail.empty() ? std::string() : std::string(": ") + detail);
            return false;
        }

        const std::string decompile_inner = std::string("\"") + exe_dir()
            + "\\derecomp.exe\" decompile-mod-raw \"" + de_path.string() + "\" \""
            + next_path.string() + "\" > NUL 2> \"" + error_path.string() + "\"";
        const int decompile_rc = std::system(("\"" + decompile_inner + "\"").c_str());
        if (decompile_rc != 0 || !fs::is_regular_file(next_path)) {
            const std::string detail = read_file(error_path.string());
            why = std::string("compiler-canonicalization raw decompile failed")
                + (detail.empty() ? std::string() : std::string(": ") + detail);
            return false;
        }
        const std::string next = read_file(next_path.string());
        if (next == seen.back()) {
            source = next;
            if (std::getenv("RENOVICE_COMPILER_CANONICAL_TRACE"))
                std::fprintf(stderr, "COMPILER_CANONICAL fixed passes=%d file=%s\n",
                             pass, original_name.c_str());
            return true;
        }

        auto repeated = std::find(seen.begin(), seen.end(), next);
        if (repeated != seen.end()) {
            source = *std::min_element(repeated, seen.end());
            if (std::getenv("RENOVICE_COMPILER_CANONICAL_TRACE"))
                std::fprintf(stderr,
                             "COMPILER_CANONICAL cycle passes=%d period=%zu file=%s\n",
                             pass, (size_t)(seen.end() - repeated), original_name.c_str());
            return true;
        }
        seen.push_back(std::move(next));
    }

    source = original_source;
    if (std::getenv("RENOVICE_COMPILER_CANONICAL_TRACE"))
        std::fprintf(stderr, "COMPILER_CANONICAL open passes=%d file=%s\n",
                     max_passes, original_name.c_str());
    return true;
}

// Emit the MODULE as a recompilable script: the chunk proto's BODY, with every closure inlined.
// `decompile` prints each proto standalone for reading, which is NOT a module — recompiling that
// would produce a different proto layout. The chunk body alone IS the original script.
static int cmd_decompile_mod(int argc, char** argv, bool allow_canonicalization = true,
                             bool force_canonicalization = false) {
    ir_load_namebase();
    std::string src, why;
    if (!decompile_module_source(argv[2], src, why)) {
        std::fprintf(stderr, "decompile-mod: %s\n", why.c_str());
        return 1;
    }
    if (allow_canonicalization
        && (force_canonicalization || std::getenv("RENOVICE_COMPILER_CANONICALIZE"))
        && !canonicalize_module_source(argv[2], src, why)) {
        std::fprintf(stderr, "decompile-mod: %s\n", why.c_str());
        return 1;
    }
    if (argc >= 4) {
        if (!write_file(argv[3], src)) {
            std::fprintf(stderr, "decompile-mod: cannot write %s\n", argv[3]);
            return 1;
        }
    } else {
        std::printf("%s\n", src.c_str());
    }
    return 0;
}

// Native high-volume source pass.  The previous Python gate launched derecomp once per file and per
// configuration; on 286 abilities that was 572 Windows process launches before any real oracle ran.
// One invocation now parses and emits the complete selected corpus, writing exact source bytes for a
// collision-free directory comparison.  Expensive rebuild/category gates can then run only on files
// whose emitted source actually changed.
static int cmd_decompile_corpus(int argc, char** argv) {
    ir_load_namebase();
    fs::path input = argv[2], output = argv[3];
    bool abilities_only = argc >= 5 && std::string(argv[4]) == "--abilities";
    if (!fs::is_directory(input)) {
        std::fprintf(stderr, "decompile-corpus: input is not a directory: %s\n",
                     input.string().c_str());
        return 2;
    }
    std::error_code error;
    fs::create_directories(output, error);
    if (error) {
        std::fprintf(stderr, "decompile-corpus: cannot create output: %s\n",
                     error.message().c_str());
        return 2;
    }
    std::vector<fs::path> files;
    for (const auto& entry : fs::directory_iterator(input)) {
        if (!entry.is_regular_file() || entry.path().extension() != ".lua_B") continue;
        std::string path = entry.path().string();
        if (abilities_only && !is_primary_ability_module_path(path)) continue;
        files.push_back(entry.path());
    }
    std::sort(files.begin(), files.end(), [](const fs::path& left, const fs::path& right) {
        return left.filename().string() < right.filename().string();
    });
    int failed = 0;
    for (const fs::path& file : files) {
        std::string src, why;
        size_t prototype_count = 0;
        if (!decompile_module_source(file.string(), src, why, &prototype_count)) {
            ++failed;
            std::fprintf(stderr, "ERROR\t%s\t%s\n", file.filename().string().c_str(), why.c_str());
            continue;
        }
        fs::path destination = output / (file.filename().string() + ".luau");
        std::ofstream stream(destination, std::ios::binary);
        if (!stream) {
            ++failed;
            std::fprintf(stderr, "ERROR\t%s\tcannot open output\n",
                         file.filename().string().c_str());
            continue;
        }
        stream.write(src.data(), (std::streamsize)src.size());
        if (!stream) {
            ++failed;
            std::fprintf(stderr, "ERROR\t%s\tcannot write output\n",
                         file.filename().string().c_str());
        }
        std::printf("FILE\t%s\tprototypes=%zu\n",
                    file.filename().string().c_str(), prototype_count);
    }
    std::printf("DECOMPILE_CORPUS files=%zu failed=%d output=%s\n",
                files.size(), failed, output.string().c_str());
    return failed == 0 ? 0 : 1;
}

// THE COMPILABILITY ORACLE. Emit each proto, hand it to the real Luau compiler, and count how many
// come back as valid Luau. A structural metric cannot fail here on our behalf: either the compiler
// accepts the text or it does not.
static int cmd_emit_validate(int argc, char** argv) {
    ir_load_namebase();
    fs::path dir = argv[2];
    long long files = 0, protos = 0, emitted = 0, compiled = 0, emit_fail = 0;
    std::map<std::string, long long> why_emit;
    std::map<std::string, long long> why_compile;
    int show = 0;
    auto do_file = [&](const std::string& path) {
        g_primary_ability_loop_scope = is_primary_ability_module_path(path);
        std::string b = read_file(path);
        if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) return;
        de::Module m;
        try { m = de::walk(b); } catch (...) { return; }
        std::vector<std::string> pool = ir::parse_pool(b);
        ++files;
        for (size_t i = 0; i < m.protos.size(); ++i) {
            ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
            ++protos;
            if (!ip.ok) { ++emit_fail; why_emit["annotate failed"]++; continue; }
            bool ok = false; std::string why;
            std::string src = decompile_proto_text(ip, (int)i, ok, why);
            if (!ok) { ++emit_fail; why_emit[why.empty() ? "unknown" : why]++; continue; }
            src = inline_closures(src, m, pool, 0);
            ++emitted;
            // Process-unique: two concurrent emit-validate runs sharing one probe file clobber each
            // other and report ~28% instead of 100%. A harness that cannot run twice at once will
            // silently produce garbage rather than fail.
            static const std::string tmp =
                "_emit_probe_" + std::to_string((long long)GetCurrentProcessId()) + ".luau";
            write_file(tmp, src);
            std::string err;
            std::string bc = compile_luau(tmp, err);
            std::remove(tmp.c_str());
            if (!bc.empty()) ++compiled;
            else {
                std::string e1 = err.substr(0, err.find_first_of("\r\n"));
                size_t cp = e1.find(": ");
                if (cp != std::string::npos) e1 = e1.substr(cp + 2);
                why_compile[e1.empty() ? "unknown" : e1]++;
                if (show < 3) {                       // show a few so failures are actionable
                    std::printf("---- REJECTED %s proto=%zu ----\n%s\n",
                                fs::path(path).filename().string().c_str(), i, src.c_str());
                    ++show;
                }
            }
        }
    };
    if (fs::is_directory(dir)) {
        for (auto& e : fs::directory_iterator(dir))
            if (e.is_regular_file() && e.path().extension() == ".lua_B") do_file(e.path().string());
    } else do_file(dir.string());
    std::printf("== M6e COMPILABILITY ORACLE ==\n");
    std::printf("files=%lld protos=%lld\n", files, protos);
    std::printf("  emitted source        : %lld  (%.4f%%)\n", emitted, protos ? 100.0*emitted/protos : 0.0);
    std::printf("  COMPILES as valid Luau: %lld  (%.4f%%)\n", compiled, protos ? 100.0*compiled/protos : 0.0);
    std::printf("  emit failures         : %lld\n", emit_fail);
    for (auto& kv : why_emit)    std::printf("      emit    %-34s %lld\n", kv.first.c_str(), kv.second);
    for (auto& kv : why_compile) std::printf("      compile %-34s %lld\n", kv.first.c_str(), kv.second);
    return (compiled == protos) ? 0 : 1;
}
