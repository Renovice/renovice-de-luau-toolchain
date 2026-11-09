// u44_raw_cmd.h -- U44 raw-hash decompile/recompile path and the stock constant-identity gate.
//
// Root cause (RESEARCH/U44_RAW_HASH_RECOMPILE_2026-09-29.md): U44 bytecode carries native-name
// hashes under seed 768e5ed0. The legacy path decompiled it with the U43 namebase (so nearly every
// native name rendered as an opaque `Name__<u44 hash>`), emitted no hash-class metadata, and then
// `recompile-u44` treated each `__<hex>` suffix as a U43 alias. Unmapped field reads silently
// became tag-3 strings, `_T` was not recognized, and the source fixed-point gate still passed
// because it compared our output only with itself.
//
// The raw path keeps one namespace end to end:
//   decompile-mod-u44 / semantic-ir-render-module-u44
//     U44 opcodes -> U43 canonical opcodes in memory (hashes untouched), U44-seeded namebase,
//     `-- RENOVICE_NAME_HASH_SEED: 768e5ed0` plus RENOVICE_HASH_GLOBAL/FIELD and
//     RENOVICE_IMPORT_CLASS metadata.
//   recompile-u44 (source declares the seed) or recompile-u44-raw
//     suffix hashes pass through verbatim; plain names hash with the U44 seed.
//   const-identity
//     per-prototype hash/string constant multisets and name-key use classes versus stock.
#pragma once
#include <array>
#include <set>
#include <map>
#include <string>
#include <vector>

// Module-wide name classes as the decompiler will render them (after raw aliasing).
struct U44NameScan {
    std::array<std::set<std::string>, 2> hashed;   // 0 = global, 1 = field read
    std::array<std::set<std::string>, 2> strings;
    std::map<std::string, std::string> import_classes;   // rendered path -> "HS.." when not default
    std::string failure;
};

// Record a GETIMPORT path whose component classes differ from the transcoder's default rule.
static bool u44_scan_import(const ir::IProto& proto, const ir::KVal& import, U44NameScan& scan) {
    int count = 0, parts[3];
    ir::import_parts(import.import_id, count, parts);
    if (count < 1 || count > 3) return true;
    std::string path, classes;
    for (int position = 0; position < count; ++position) {
        if (parts[position] < 0 || parts[position] >= (int)proto.consts.size()) return true;
        const ir::KVal& part = proto.consts[(size_t)parts[position]];
        std::string text = part.str;
        if (part.kind == ir::KKind::NameHash && !ex::is_ident(text)) text = raw_hash_alias(text, part.hash);
        // Only identifier paths reach Luau as GETIMPORT; anything else is left to the stock gate.
        if (!ex::is_ident(text)) return true;
        if (position) path += '.';
        path += text;
        classes += part.kind == ir::KKind::NameHash ? 'H' : 'S';
    }
    std::string expected = "H";
    const bool shared_T = path == "_T" || path.compare(0, 3, "_T.") == 0;
    for (int position = 1; position < count; ++position) expected += shared_T ? 'S' : 'H';
    if (classes == expected) return true;
    const auto inserted = scan.import_classes.emplace(path, classes);
    if (!inserted.second && inserted.first->second != classes) {
        scan.failure = "import path used with two hash classes: " + path; return false;
    }
    return true;
}

static bool u44_scan_names(const std::string& path, U44NameScan& scan) {
    const std::string bytes = read_de_input(path);
    if (bytes.empty() && !g_input_profile_failure.empty()) { scan.failure = g_input_profile_failure; return false; }
    de::Module module;
    try { module = de::walk(bytes); }
    catch (const std::exception& e) { scan.failure = std::string("walk error: ") + e.what(); return false; }
    const std::vector<std::string> pool = ir::parse_pool(bytes);
    for (size_t index = 0; index < module.protos.size(); ++index) {
        const ir::IProto proto = ir_annotate(module.protos[index], (int)index, pool, g_nb);
        for (const ir::KVal& constant : proto.consts)
            if (constant.kind == ir::KKind::Import && !u44_scan_import(proto, constant, scan)) return false;
        for (const ir::IInsn& instruction : proto.code) {
            const int name_class = u44_name_class((uint8_t)instruction.op);
            if (name_class < 0) continue;
            const uint32_t key = instruction.aux & 0xffffu;
            // An out-of-range key is the annotator's to report; it is not a name-class decision.
            if (key >= proto.consts.size()) continue;
            const ir::KKind kind = proto.consts[key].kind;
            if (kind == ir::KKind::NameHash) scan.hashed[name_class].insert(instruction.note);
            else if (kind == ir::KKind::Str) scan.strings[name_class].insert(instruction.note);
            else continue;
        }
    }
    return true;
}

// Enable the U44 input profile (or, for a module valid only under U43, route it through its own
// profile: select_u44_entry_profile) and precompute the module's mixed hashed/string spellings.
static bool u44_prepare(const std::string& path, std::string& failure) {
    select_u44_entry_profile(path);
    g_raw_hash_names = true;
    static std::unordered_set<uint32_t> module_words;
    if (!std::getenv("RENOVICE_FULL_NAMEBASE")) {
        const std::string bytes = read_de_input(path);
        for (size_t at = 0; at + 4 <= bytes.size(); ++at) {
            uint32_t word;
            std::memcpy(&word, bytes.data() + at, 4);
            module_words.insert(word);
        }
        if (!bytes.empty()) g_nb_filter = &module_words;
    }
    ir_load_namebase();
    g_nb_filter = nullptr;
    g_u44_mixed_names.clear();
    U44NameScan scan;
    if (!u44_scan_names(path, scan)) { failure = scan.failure; return false; }
    for (int name_class = 0; name_class < 2; ++name_class)
        for (const std::string& name : scan.hashed[name_class])
            if (scan.strings[name_class].count(name)) g_u44_mixed_names.insert({name_class, name});
    return true;
}

// Seed declaration plus hash-class metadata for the rendered module. Fails closed if a spelling is
// still ambiguous between classes or cannot be written as an identifier.
static bool u44_source_header(const std::string& path, std::string& header, std::string& failure) {
    U44NameScan scan;
    if (!u44_scan_names(path, scan)) { failure = scan.failure; return false; }
    for (int name_class = 0; name_class < 2; ++name_class)
        for (const std::string& name : scan.hashed[name_class]) {
            if (scan.strings[name_class].count(name)) { failure = "mixed hashed/string name " + name; return false; }
            if (!ex::is_ident(name)) { failure = "hashed name is not an identifier: " + name; return false; }
        }
    char seed[16]; std::snprintf(seed, sizeof seed, "%08x", g_source_seed);
    std::string out = std::string(tc::name_hash_seed_directive_prefix()) + seed + "\n";
    for (const std::string& name : scan.hashed[0]) out += tc::hashed_global_directive_prefix() + name + "\n";
    for (const std::string& name : scan.hashed[1]) out += tc::hashed_field_directive_prefix() + name + "\n";
    for (const auto& item : scan.import_classes)
        out += tc::import_class_directive_prefix() + item.first + "=" + item.second + "\n";
    header = out;
    return true;
}

// SHORT-CIRCUIT FOLD SELECTION (RENOVICE_SC_EXPR_FOLD). The fold changes which renderer owns a
// prototype, and the downstream renderers/canonicalizers still have shape-specific limits. The
// input bytecode is the authority: render the module with and without the fold, rebuild both, and
// keep the folded source only when it is at least as faithful on every identity gate and strictly
// better on control flow. Child processes run with RENOVICE_SC_EXPR_FOLD_CHILD so this never nests.
static std::string sc_fold_run(const std::string& args) {
    char self[MAX_PATH]; const DWORD self_len = GetModuleFileNameA(nullptr, self, MAX_PATH);
    std::string cmd = "\"\"" + std::string(self, self_len) + "\" " + args + " 2>&1\"";
    std::string out;
    FILE* pipe = _popen(cmd.c_str(), "r");
    if (!pipe) return out;
    char buf[4096];
    while (std::fgets(buf, sizeof buf, pipe)) out += buf;
    _pclose(pipe);
    return out;
}
static long sc_fold_field(const std::string& text, const std::string& key) {
    const size_t at = text.find(key + "=");
    if (at == std::string::npos) return -1;
    return std::strtol(text.c_str() + at + key.size() + 1, nullptr, 10);
}
struct ScFoldScore {
    long cfg = -1, hash = -1, str = -1, key = -1, df = -1, protos = -1, df_protos = -1;
    bool built = false;
    std::set<int> bad;   // prototypes any identity gate reports (`proto N ...` lines)
    // Every identity count equals the prototype count: nothing can beat this rendering.
    bool perfect() const {
        return built && protos > 0 && cfg == protos && hash == protos && str == protos
            && key == protos && df == df_protos;
    }
};
static ScFoldScore sc_fold_score(const std::string& input, const std::string& source_path,
                                 const std::string& bytecode_path) {
    ScFoldScore score;
    const std::string q = "\"";
    sc_fold_run("recompile-u44 " + q + source_path + q + " " + q + bytecode_path + q);
    if (!fs::exists(long_path(bytecode_path))) return score;
    score.built = true;
    const std::string pair = q + input + q + " " + q + bytecode_path + q + " --u44";
    const std::string all = sc_fold_run("identity-all " + pair);
    const size_t con_at = all.find("CONST_IDENTITY");
    const size_t df_at = all.find("DATAFLOW_IDENTITY");
    const std::string cfg = all.substr(0, std::min(con_at, all.size()));
    const std::string con = con_at == std::string::npos ? std::string() : all.substr(con_at);
    const std::string df = df_at == std::string::npos ? std::string() : all.substr(df_at);
    score.cfg = sc_fold_field(cfg, "cfg_equal");
    score.hash = sc_fold_field(con, "hash_equal");
    score.str = sc_fold_field(con, "string_equal");
    score.key = sc_fold_field(con, "keyuse_equal");
    score.df = sc_fold_field(df, "df_equal");
    score.protos = sc_fold_field(cfg, "protos_stock");
    score.df_protos = sc_fold_field(df, "protos_stock");
    size_t line = 0;
    while (line < all.size()) {
        size_t end = all.find('\n', line);
        if (end == std::string::npos) end = all.size();
        if (all.compare(line, 6, "proto ") == 0)
            score.bad.insert(std::atoi(all.c_str() + line + 6));
        line = end + 1;
    }
    return score;
}

static int cmd_decompile_mod_u44(int argc, char** argv) {
    if (std::getenv("RENOVICE_COMPILER_CANONICALIZE")) {
        std::fprintf(stderr, "decompile-mod-u44: compiler canonicalization is U43-only\n");
        return 1;
    }
    std::string failure, source, header;
    auto stamp = [](const char* what) {
        static auto last = std::chrono::steady_clock::now();
        const auto now = std::chrono::steady_clock::now();
        if (std::getenv("RENOVICE_TIMING"))
            std::fprintf(stderr, "TIMING step=%s ms=%.1f\n", what,
                         std::chrono::duration<double, std::milli>(now - last).count());
        last = now;
    };
    if (std::getenv("RENOVICE_TIMING")) {
        FILETIME created, exited, kernel, user, now;
        GetProcessTimes(GetCurrentProcess(), &created, &exited, &kernel, &user);
        GetSystemTimeAsFileTime(&now);
        auto as64 = [](const FILETIME& f) { return ((unsigned long long)f.dwHighDateTime << 32) | f.dwLowDateTime; };
        std::fprintf(stderr, "TIMING since_process_start_ms=%.1f\n", (as64(now) - as64(created)) / 10000.0);
    }
    stamp("start");
    g_sc_expr_fold_wide = !std::getenv("RENOVICE_NO_SC_EXPR_FOLD")
                       && !std::getenv("RENOVICE_SC_EXPR_FOLD_CHILD")
                       && !std::getenv("RENOVICE_NO_SC_EXPR_FOLD_SELECT");
    if (!u44_prepare(argv[2], failure)) {
        std::fprintf(stderr, "decompile-mod-u44: %s\n", failure.c_str()); return 1;
    }
    stamp("u44_prepare");
    if (!decompile_module_source(argv[2], source, failure)) {
        std::fprintf(stderr, "decompile-mod-u44: %s\n", failure.c_str()); return 1;
    }
    if (std::getenv("RENOVICE_TIMING")) {
        auto t = proto_timings();
        double total = 0; for (auto& x : t) total += x.ms;
        std::sort(t.begin(), t.end(), [](const ProtoTiming& l, const ProtoTiming& r) { return l.ms > r.ms; });
        std::fprintf(stderr, "TIMING protos=%zu render_ms=%.1f (nested renders counted in parents too)\n", t.size(), total);
        for (size_t k = 0; k < t.size() && k < 6; ++k)
            std::fprintf(stderr, "TIMING proto=%d ms=%.1f\n", t[k].idx, t[k].ms);
    }
    stamp("decompile_module_source");
    if (!u44_source_header(argv[2], header, failure)) {
        std::fprintf(stderr, "decompile-mod-u44: %s\n", failure.c_str()); return 1;
    }
    stamp("u44_source_header");
    source = header + source;
    std::string chosen_env;   // environment reproducing the selected fold render (inverse stage)
    // the selection stages run only in the top-level process, never in their child renders
    const bool top_level = !std::getenv("RENOVICE_SC_EXPR_FOLD_CHILD") && !std::getenv("RENOVICE_INVERSE_CHILD");
    if (!std::getenv("RENOVICE_NO_SC_EXPR_FOLD") && !std::getenv("RENOVICE_SC_EXPR_FOLD_CHILD")
        && !std::getenv("RENOVICE_NO_SC_EXPR_FOLD_SELECT")) {
        _putenv("RENOVICE_SC_EXPR_FOLD_CHILD=1");      // children never select again
        char tmp_dir[MAX_PATH]; GetTempPathA(MAX_PATH, tmp_dir);
        char stem[MAX_PATH]; GetTempFileNameA(tmp_dir, "scf", 0, stem);
        const std::string base_src = std::string(stem) + ".base.luau";
        const std::string fold_src = std::string(stem) + ".fold.luau";
        const std::string q = "\"";
        // Cheap path first: without any fold the base render is identical, and a folded render
        // that already reproduces every identity of the input cannot be improved on.
        const bool any_fold = g_sc_expr_fold_applied > 0;
        ScFoldScore f;
        if (any_fold && write_file(fold_src, source)) {
            f = sc_fold_score(argv[2], fold_src, std::string(stem) + ".fold.lua_B");
        }
        // Candidates in order: wide fold (already rendered), narrow fold, no fold. A fold
        // candidate is kept only when it is not worse than the unfolded render on any identity
        // count and strictly better on control flow; among those the higher control-flow count wins.
        const char* chosen = "fold";
        if (any_fold && !f.perfect()) {
            // Alternatives render in a fresh child process: a second render inside this process
            // inherits emitter/analysis state from the first and is not the same output.
            auto render = [&](bool strict, bool suspend) {
                const std::string out_path = std::string(stem) + (suspend ? ".base.luau" : ".narrow.luau");
                _putenv(strict ? "RENOVICE_SC_EXPR_FOLD_STRICT=1" : "RENOVICE_SC_EXPR_FOLD_STRICT=");
                _putenv(suspend ? "RENOVICE_NO_SC_EXPR_FOLD=1" : "RENOVICE_NO_SC_EXPR_FOLD=");
                sc_fold_run("decompile-mod-u44 " + q + argv[2] + q + " " + q + out_path + q);
                _putenv("RENOVICE_SC_EXPR_FOLD_STRICT=");
                _putenv("RENOVICE_NO_SC_EXPR_FOLD=");
                return read_file(out_path);
            };
            const std::string narrow = render(true, false);
            const std::string narrow_src = std::string(stem) + ".narrow.luau";
            ScFoldScore n;
            if (!narrow.empty() && narrow != source && write_file(narrow_src, narrow))
                n = sc_fold_score(argv[2], narrow_src, std::string(stem) + ".narrow.lua_B");
            else if (narrow == source)
                n = f;
            if (n.perfect()) {
                source = narrow; chosen = "narrow"; chosen_env = "RENOVICE_SC_EXPR_FOLD_STRICT=1";
            } else {
                const std::string base = render(false, true);
                if (!base.empty()) write_file(base_src, base);
                const ScFoldScore b = base.empty() ? ScFoldScore()
                    : sc_fold_score(argv[2], base_src, std::string(stem) + ".base.lua_B");
                auto qualifies = [&](const ScFoldScore& c) {
                    return c.built && b.built && c.hash >= b.hash && c.str >= b.str && c.key >= b.key
                        && c.df >= b.df && c.cfg > b.cfg;
                };
                const bool wide_ok = qualifies(f), narrow_ok = qualifies(n);
                long best_cfg = b.cfg;
                if (wide_ok && (!narrow_ok || f.cfg >= n.cfg)) { chosen = "fold"; best_cfg = f.cfg; }
                else if (narrow_ok) { source = narrow; chosen = "narrow"; chosen_env = "RENOVICE_SC_EXPR_FOLD_STRICT=1"; best_cfg = n.cfg; }
                else if (!base.empty()) { source = base; chosen = "base"; chosen_env = "RENOVICE_NO_SC_EXPR_FOLD=1"; }
                // Per-prototype mix: each prototype takes the first fold level (none, narrow, wide)
                // under which no identity gate reports it. One fold level can fix one function and
                // disturb another in the same module; the module-wide choice cannot express that.
                if (b.built && b.protos > 0 && !std::getenv("RENOVICE_NO_SC_EXPR_FOLD_MIX")) {
                    std::string spec;
                    bool uses_fold = false;
                    for (long proto = 0; proto < b.protos; ++proto) {
                        int level = 0;
                        if (b.bad.count((int)proto)) {
                            if (n.built && !n.bad.count((int)proto)) level = 1;
                            else if (f.built && !f.bad.count((int)proto)) level = 2;
                        }
                        if (level) uses_fold = true;
                        spec += (spec.empty() ? "" : ",") + std::to_string(proto) + ":" + std::to_string(level);
                    }
                    if (uses_fold) {
                        const std::string mix_src = std::string(stem) + ".mix.luau";
                        _putenv(("RENOVICE_SC_EXPR_FOLD_LEVELS=" + spec).c_str());
                        sc_fold_run("decompile-mod-u44 " + q + argv[2] + q + " " + q + mix_src + q);
                        _putenv("RENOVICE_SC_EXPR_FOLD_LEVELS=");
                        const std::string mix = read_file(mix_src);
                        if (!mix.empty()) {
                            const ScFoldScore m = sc_fold_score(argv[2], mix_src,
                                                                std::string(stem) + ".mix.lua_B");
                            if (qualifies(m) && m.cfg > best_cfg) { source = mix; chosen = "mix"; chosen_env = "RENOVICE_SC_EXPR_FOLD_LEVELS=" + spec; best_cfg = m.cfg; }
                            if (std::getenv("RENOVICE_SC_EXPR_FOLD_TRACE"))
                                std::fprintf(stderr, "SC_EXPR_FOLD_SELECT mix cfg %ld\n", m.cfg);
                        }
                        std::error_code mix_ec;
                        fs::remove(long_path(mix_src), mix_ec);
                        fs::remove(long_path(std::string(stem) + ".mix.lua_B"), mix_ec);
                    }
                }
                if (std::getenv("RENOVICE_SC_EXPR_FOLD_TRACE"))
                    std::fprintf(stderr, "SC_EXPR_FOLD_SELECT cfg wide %ld narrow %ld base %ld -> %s\n",
                                 f.cfg, n.cfg, b.cfg, chosen);
            }
            std::error_code ec;
            fs::remove(long_path(narrow_src), ec);
            fs::remove(long_path(std::string(stem) + ".narrow.lua_B"), ec);
        } else if (std::getenv("RENOVICE_SC_EXPR_FOLD_TRACE") && any_fold) {
            std::fprintf(stderr, "SC_EXPR_FOLD_SELECT perfect -> fold\n");
        }
        for (const char* suffix : {".base.luau", ".fold.luau", ".base.lua_B", ".fold.lua_B", ""}) {
            std::error_code ec; fs::remove(long_path(std::string(stem) + suffix), ec);
        }
    }
    // INVERSE STAGE (inverse/inverse_emit.h, opt-in RENOVICE_INVERSE_SELECT): re-render only the
    // prototypes an identity gate still reports with the compiler-inverse walker, under the same
    // fold environment, and keep that render only when the compiler confirms it is better on control
    // flow and not worse on any other identity count. Production output stays for every other proto.
    if (std::getenv("RENOVICE_INVERSE_SELECT") && top_level && !std::getenv("RENOVICE_INVERSE_EMIT")) {
        char tmp_dir[MAX_PATH]; GetTempPathA(MAX_PATH, tmp_dir);
        char stem[MAX_PATH]; GetTempFileNameA(tmp_dir, "inv", 0, stem);
        const std::string cur_src = std::string(stem) + ".cur.luau", inv_src = std::string(stem) + ".inv.luau";
        const std::string q = "\"";
        // skip very large modules outright (their renders alone approach the gate timeout)
        const bool small_enough = source.size() < 400000;
        const ScFoldScore cur = small_enough && write_file(cur_src, source)
            ? sc_fold_score(argv[2], cur_src, std::string(stem) + ".cur.lua_B") : ScFoldScore();
        if (cur.built && !cur.perfect() && !cur.bad.empty()) {
            std::string protos;
            for (int proto : cur.bad) protos += (protos.empty() ? "" : ",") + std::to_string(proto);
            if (chosen_env.empty() && g_sc_expr_fold_wide && cur.protos > 0) {
                // the in-process wide fold has no child switch: spell it as per-prototype levels
                chosen_env = "RENOVICE_SC_EXPR_FOLD_LEVELS=";
                for (long proto = 0; proto < cur.protos; ++proto)
                    chosen_env += (proto ? "," : "") + std::to_string(proto) + ":2";
            }
            // two candidates: only the reported prototypes, then every prototype (a walker render
            // of a passing prototype can also fix its neighbours' numbering); best compiler score wins
            ScFoldScore best = cur;
            const auto stage_start = std::chrono::steady_clock::now();
            // candidates: (fold environment, prototypes). The production fold choice first, then
            // the other fold levels: the walker sees a different graph under each.
            std::string wide_env = "RENOVICE_SC_EXPR_FOLD_LEVELS=";
            for (long proto = 0; proto < cur.protos; ++proto)
                wide_env += (proto ? "," : "") + std::to_string(proto) + ":2";
            std::vector<std::pair<std::string, bool>> cands = {
                {chosen_env, true}, {chosen_env, false}, {wide_env, false},
                {"RENOVICE_SC_EXPR_FOLD_STRICT=1", false}, {"RENOVICE_NO_SC_EXPR_FOLD=1", false}};
            // walker output with its locals rebuilt from Luau's allocator (STACK LOCALS), under each
            // fold level, with the text look-ahead and with bytecode temporary verdicts
            // (a candidate's environment is a ';'-separated list)
            for (const char* extra : {"RENOVICE_INVERSE_STACK_LOCALS=1",
                                      "RENOVICE_INVERSE_STACK_LOCALS=1;RENOVICE_STACK_BYTECODE_TEMPS=1"})
                for (const std::string& fold : {chosen_env, wide_env, std::string("RENOVICE_SC_EXPR_FOLD_STRICT=1"),
                                                std::string("RENOVICE_NO_SC_EXPR_FOLD=1")})
                    for (bool only_bad : {true, false})
                        cands.push_back({fold.empty() ? std::string(extra) : fold + ";" + extra, only_bad});
            // most productive first (measured 2026-11-09): stack-locals renders, then plain fold levels
            std::stable_partition(cands.begin(), cands.end(), [](const std::pair<std::string, bool>& c) {
                return c.first.find("STACK_LOCALS") != std::string::npos; });
            std::set<std::pair<std::string, bool>> seen;
            for (int pass = 0; pass < (int)cands.size(); ++pass) {
                const std::string env = cands[(size_t)pass].first;
                if (!seen.insert(cands[(size_t)pass]).second) continue;
                // time budget: the gates run each module under a fixed timeout; a large module's
                // extra renders must not turn a correct production decompile into a timeout
                if (std::chrono::duration<double>(std::chrono::steady_clock::now() - stage_start).count() > 90.0)
                    break;
                _putenv("RENOVICE_SC_EXPR_FOLD_CHILD=1");
                _putenv("RENOVICE_INVERSE_CHILD=1");
                _putenv("RENOVICE_INVERSE_EMIT=1");
                if (cands[(size_t)pass].second) _putenv(("RENOVICE_INVERSE_PROTOS=" + protos).c_str());
                std::vector<std::string> parts;
                for (size_t at = 0; at <= env.size() && !env.empty();) {
                    size_t e = env.find(';', at); if (e == std::string::npos) e = env.size();
                    parts.push_back(env.substr(at, e - at)); at = e + 1;
                }
                for (const std::string& part : parts) _putenv(part.c_str());
                sc_fold_run("decompile-mod-u44 " + q + argv[2] + q + " " + q + inv_src + q);
                for (const std::string& part : parts) _putenv((part.substr(0, part.find('=') + 1)).c_str());
                _putenv("RENOVICE_INVERSE_PROTOS=");
                _putenv("RENOVICE_INVERSE_EMIT=");
                _putenv("RENOVICE_INVERSE_CHILD=");
                const std::string inv = read_file(inv_src);
                if (inv.empty() || inv == source) continue;
                const ScFoldScore s = sc_fold_score(argv[2], inv_src, std::string(stem) + ".inv.lua_B");
                // no prototype may newly fail any gate (count totals can hide a trade)
                bool no_new_bad = true;
                for (int proto : s.bad) if (!cur.bad.count(proto)) no_new_bad = false;
                const bool better = s.built && no_new_bad && s.hash >= best.hash && s.str >= best.str
                    && s.key >= best.key && s.df >= best.df && s.cfg > best.cfg;
                if (better) { source = inv; best = s; }
                if (std::getenv("RENOVICE_INVERSE_TRACE"))
                    std::fprintf(stderr, "INVERSE_SELECT pass %d cfg %ld -> %ld %s\n", pass, cur.cfg, s.cfg,
                                 better ? "taken" : "kept");
                if (best.perfect()) break;
            }
        }
        for (const char* suffix : {".cur.luau", ".cur.lua_B", ".inv.luau", ".inv.lua_B", ""}) {
            std::error_code ec; fs::remove(long_path(std::string(stem) + suffix), ec);
        }
    }
    if (argc >= 4) {
        if (!write_file(argv[3], source)) {
            std::fprintf(stderr, "decompile-mod-u44: cannot write %s\n", argv[3]); return 1;
        }
    } else {
        std::printf("%s\n", source.c_str());
    }
    // The output is written; tearing down the process-wide analysis tables (name base, caches)
    // only costs time. Flush and leave without running static destructors.
    stamp("selection_and_write");
    std::fflush(stdout);
    std::fflush(stderr);
    if (!std::getenv("RENOVICE_FULL_TEARDOWN")) _exit(0);
    return 0;
}

static int cmd_semantic_ir_render_module_u44(int argc, char** argv) {
    std::string failure;
    if (!u44_prepare(argv[2], failure)) {
        std::fprintf(stderr, "semantic-ir-render-module-u44: %s\n", failure.c_str()); return 1;
    }
    const int rc = cmd_semantic_ir_render_module(argc, argv);
    if (rc != 0) return rc;
    // The renderer already wrote hash-class metadata; add the namespace declaration and the
    // import-path classes it does not know about.
    U44NameScan scan;
    if (!u44_scan_names(argv[2], scan)) {
        std::fprintf(stderr, "semantic-ir-render-module-u44: %s\n", scan.failure.c_str()); return 1;
    }
    char seed[16]; std::snprintf(seed, sizeof seed, "%08x", g_source_seed);
    std::string header = std::string(tc::name_hash_seed_directive_prefix()) + seed + "\n";
    for (const auto& item : scan.import_classes)
        header += tc::import_class_directive_prefix() + item.first + "=" + item.second + "\n";
    const std::string rendered = read_file(argv[3]);
    if (!write_file(argv[3], header + rendered)) {
        std::fprintf(stderr, "semantic-ir-render-module-u44: cannot write %s\n", argv[3]); return 2;
    }
    return 0;
}

// ---------------------------------------------------------------------------------------------
// const-identity: the gate the source fixed point cannot replace. For each prototype index compare
//   HASH    multiset of tag-1 payloads other than 0/1 (native-name hashes; 0/1 are booleans,
//           reported separately and not part of the verdict)
//   STRING  multiset of tag-3 strings (resolved through each module's own pool)
//   KEYUSE  set of (access, key class, key): GLOBAL = GETGLOBAL or a GETIMPORT root, FIELD =
//           GETFIELD or a GETIMPORT member, SETGLOBAL, SETFIELD, NAMECALL -- the hash-class
//           decision at the use site. A fused import and a GETFIELD reading the same key with the
//           same class are the same access; a hash/string difference never is.
// Constant ORDER and instruction layout are deliberately not compared (the upstream compiler may
// order constants differently); exact byte identity is a separate measurement.
// ---------------------------------------------------------------------------------------------
struct ConstIdentityProto {
    std::multiset<uint32_t> hashes;      // tag-1 payloads other than 0/1 (native-name hashes)
    std::multiset<uint32_t> booleans;    // tag-1 payloads 0/1 (value booleans; informational)
    std::multiset<std::string> strings;
    std::set<std::string> key_uses;
};

static std::string const_identity_escape(const std::string& text) {
    std::string out;
    for (unsigned char c : text) {
        if (c >= 0x20 && c < 0x7f && c != '\\' && c != '"') out.push_back((char)c);
        else { char b[8]; std::snprintf(b, sizeof b, "\\x%02x", c); out += b; }
    }
    return out;
}

static bool const_identity_load(const std::string& path, bool u44, std::vector<ConstIdentityProto>& out,
                                std::string& failure) {
    const std::string bytes = read_file(path);
    de::Module module;
    try { module = de::walk(bytes); }
    catch (const std::exception& e) { failure = path + ": walk error: " + e.what(); return false; }
    const std::vector<std::string> pool = ir::parse_pool(bytes);
    auto key_text = [&](const de::Proto& proto, uint32_t index, std::string& text) -> bool {
        if (index >= proto.consts.size()) { text = "OOB:" + std::to_string(index); return true; }
        const de::Const& c = proto.consts[index];
        if (c.tag == 1 && c.raw.size() == 4) {
            uint32_t hash = 0; std::memcpy(&hash, c.raw.data(), 4);
            char b[16]; std::snprintf(b, sizeof b, "H:%08x", hash); text = b; return true;
        }
        if (c.tag == 3) {
            text = "S:" + const_identity_escape(c.idx >= 1 && c.idx <= pool.size() ? pool[c.idx - 1] : std::string());
            return true;
        }
        text = "T" + std::to_string(c.tag) + ":?";
        return true;
    };
    for (const de::Proto& proto : module.protos) {
        ConstIdentityProto result;
        for (const de::Const& c : proto.consts) {
            if (c.tag == 1 && c.raw.size() == 4) {
                // de-tag1audit: name positions never carry 0/1 and value positions carry only 0/1.
                uint32_t hash = 0; std::memcpy(&hash, c.raw.data(), 4);
                (hash <= 1 ? result.booleans : result.hashes).insert(hash);
            } else if (c.tag == 3) {
                result.strings.insert(c.idx >= 1 && c.idx <= pool.size() ? pool[c.idx - 1] : std::string());
            }
        }
        for (size_t offset = 0; offset + 4 <= proto.code.size();) {
            const uint8_t raw = (uint8_t)proto.code[offset];
            const uint8_t op = renovice::bytecode::canonical_opcode(raw, u44);
            const size_t width = renovice::bytecode::canonical_has_aux(op) ? 8 : 4;
            if (offset + width > proto.code.size()) { failure = path + ": truncated instruction"; return false; }
            uint32_t word = 0, aux = 0;
            std::memcpy(&word, proto.code.data() + offset, 4);
            if (width == 8) std::memcpy(&aux, proto.code.data() + offset + 4, 4);
            const char* use = op == 0x17 ? "GLOBAL" : op == 0x02 ? "SETGLOBAL" : op == 0x3d ? "FIELD"
                            : op == 0x15 ? "SETFIELD" : op == 0x2d ? "NAMECALL" : nullptr;
            std::string text;
            if (use) {
                if (!key_text(proto, aux & 0xffffu, text)) { failure = path + ": key out of range"; return false; }
                result.key_uses.insert(std::string(use) + " " + text);
            } else if (op == 0x46) {
                const uint32_t import_index = word >> 16;
                if (import_index < proto.consts.size() && proto.consts[import_index].tag == 4
                    && proto.consts[import_index].raw.size() == 4) {
                    uint32_t id = 0; std::memcpy(&id, proto.consts[import_index].raw.data(), 4);
                    int count = 0, parts[3]; ir::import_parts(id, count, parts);
                    for (int position = 0; position < count && position < 3; ++position) {
                        if (!key_text(proto, (uint32_t)parts[position], text)) {
                            failure = path + ": import component out of range"; return false;
                        }
                        result.key_uses.insert(std::string(position ? "FIELD " : "GLOBAL ") + text);
                    }
                }
            }
            offset += width;
        }
        out.push_back(std::move(result));
    }
    return true;
}

template <class Container>
static std::string const_identity_list(const Container& values, size_t limit = 12) {
    std::string out = "[";
    size_t count = 0;
    for (const auto& value : values) {
        if (count == limit) { out += " ..."; break; }
        if (count++) out += ", ";
        out += value;
    }
    return out + "]";
}

static int cmd_const_identity(int argc, char** argv) {
    bool u44 = false;
    for (int argument = 4; argument < argc; ++argument)
        if (std::string(argv[argument]) == "--u44") u44 = true;
    {   // input-profile routing: a U43-only stock module is gated under its own profile
        std::string profile_note;
        const std::string mismatch = de::resolve_gate_profile(read_file(argv[2]), read_file(argv[3]), u44, profile_note);
        if (!profile_note.empty()) std::printf("INPUT_PROFILE %s\n", profile_note.c_str());
        if (!mismatch.empty()) { std::printf("%s verdict=ERROR %s\n", "CONST_IDENTITY", mismatch.c_str()); return 2; }
    }
    std::vector<ConstIdentityProto> stock, candidate;
    std::string failure;
    if (!const_identity_load(argv[2], u44, stock, failure) || !const_identity_load(argv[3], u44, candidate, failure)) {
        std::printf("CONST_IDENTITY verdict=ERROR %s\n", failure.c_str());
        return 2;
    }
    const size_t shared = std::min(stock.size(), candidate.size());
    size_t hash_equal = 0, string_equal = 0, key_equal = 0, boolean_differs = 0, class_swaps = 0,
           other_key_diffs = 0;
    for (size_t index = 0; index < shared; ++index) {
        const ConstIdentityProto& a = stock[index];
        const ConstIdentityProto& b = candidate[index];
        const bool hashes = a.hashes == b.hashes, strings = a.strings == b.strings, keys = a.key_uses == b.key_uses;
        hash_equal += hashes; string_equal += strings; key_equal += keys;
        if (a.booleans != b.booleans) ++boolean_differs;
        if (!hashes) {
            std::vector<std::string> only_a, only_b;
            std::multiset<uint32_t> rest_b = b.hashes;
            for (uint32_t h : a.hashes) {
                auto found = rest_b.find(h);
                if (found != rest_b.end()) rest_b.erase(found);
                else { char t[16]; std::snprintf(t, sizeof t, "%08x", h); only_a.push_back(t); }
            }
            std::multiset<uint32_t> rest_a = a.hashes;
            for (uint32_t h : b.hashes) {
                auto found = rest_a.find(h);
                if (found != rest_a.end()) rest_a.erase(found);
                else { char t[16]; std::snprintf(t, sizeof t, "%08x", h); only_b.push_back(t); }
            }
            std::printf("proto %zu HASH only-stock=%s only-candidate=%s\n", index,
                        const_identity_list(only_a).c_str(), const_identity_list(only_b).c_str());
        }
        if (!strings) {
            std::vector<std::string> only_a, only_b;
            std::multiset<std::string> rest_b = b.strings, rest_a = a.strings;
            for (const std::string& s : a.strings) {
                auto found = rest_b.find(s);
                if (found != rest_b.end()) rest_b.erase(found); else only_a.push_back("\"" + const_identity_escape(s) + "\"");
            }
            for (const std::string& s : b.strings) {
                auto found = rest_a.find(s);
                if (found != rest_a.end()) rest_a.erase(found); else only_b.push_back("\"" + const_identity_escape(s) + "\"");
            }
            std::printf("proto %zu STRING only-stock=%s only-candidate=%s\n", index,
                        const_identity_list(only_a).c_str(), const_identity_list(only_b).c_str());
        }
        if (!keys) {
            std::vector<std::string> only_a, only_b;
            for (const std::string& k : a.key_uses) if (!b.key_uses.count(k)) only_a.push_back(k);
            for (const std::string& k : b.key_uses) if (!a.key_uses.count(k)) only_b.push_back(k);
            std::printf("proto %zu KEYUSE only-stock=%s only-candidate=%s\n", index,
                        const_identity_list(only_a).c_str(), const_identity_list(only_b).c_str());
            // Hash-class swaps: the same operation and native name, but hash on one side and a
            // string on the other -- exactly the silent defect this gate exists for.
            auto hash_of = [&](const std::string& text) {
                uint32_t suffix = 0;
                if (de::parse_hash_suffix(text, suffix)) return suffix;
                return de::de_name_hash(text, u44 ? de::NAMEHASH_SEED_U44 : de::NAMEHASH_SEED_2026_06_19);
            };
            auto swapped = [&](const std::string& h_item, const std::vector<std::string>& other) {
                const size_t space = h_item.find(' ');
                if (space == std::string::npos || h_item.compare(space + 1, 2, "H:") != 0) return false;
                const std::string op = h_item.substr(0, space);
                const uint32_t hash = (uint32_t)std::strtoul(h_item.c_str() + space + 3, nullptr, 16);
                for (const std::string& item : other)
                    if (item.compare(0, op.size() + 3, op + " S:") == 0 && hash_of(item.substr(op.size() + 3)) == hash)
                        return true;
                return false;
            };
            std::set<std::string> swap_members;
            for (const std::string& item : only_a) if (swapped(item, only_b)) { ++class_swaps; swap_members.insert(item); }
            for (const std::string& item : only_b) if (swapped(item, only_a)) { ++class_swaps; swap_members.insert(item); }
            // The string-side partner of each swap is part of the same defect, not a separate one.
            std::set<std::string> partners;
            for (const std::string& item : swap_members) {
                const size_t space = item.find(' ');
                const std::string op = item.substr(0, space);
                const uint32_t hash = (uint32_t)std::strtoul(item.c_str() + space + 3, nullptr, 16);
                for (const auto* side : {&only_a, &only_b})
                    for (const std::string& other : *side)
                        if (other.compare(0, op.size() + 3, op + " S:") == 0 && hash_of(other.substr(op.size() + 3)) == hash)
                            partners.insert(other);
            }
            for (const auto* side : {&only_a, &only_b})
                for (const std::string& item : *side)
                    if (!swap_members.count(item) && !partners.count(item)) ++other_key_diffs;
        }
    }
    // Informational code-byte census (not part of the verdict): which operand fields differ in
    // prototypes whose code has equal length, so byte-identity misses can be attributed.
    size_t code_equal = 0, code_size_differs = 0;
    std::map<std::string, size_t> field_diffs;
    try {
        const de::Module left = de::walk(read_file(argv[2])), right = de::walk(read_file(argv[3]));
        for (size_t index = 0; index < std::min(left.protos.size(), right.protos.size()); ++index) {
            const std::string& a = left.protos[index].code;
            const std::string& b = right.protos[index].code;
            if (a == b) { ++code_equal; continue; }
            if (a.size() != b.size()) { ++code_size_differs; continue; }
            for (size_t offset = 0; offset + 4 <= a.size();) {
                const uint8_t op = renovice::bytecode::canonical_opcode((uint8_t)a[offset], u44);
                const size_t width = renovice::bytecode::canonical_has_aux(op) ? 8 : 4;
                static const char* fields[8] = {"op", "A", "B", "C", "aux", "aux", "aux", "aux"};
                for (size_t byte = 0; byte < width && offset + byte < a.size(); ++byte)
                    if (a[offset + byte] != b[offset + byte]) {
                        char key[32]; std::snprintf(key, sizeof key, "%02x.%s", op, fields[byte]);
                        ++field_diffs[key];
                    }
                offset += width;
            }
        }
    } catch (const std::exception&) {}
    std::string census;
    for (const auto& item : field_diffs)
        census += (census.empty() ? "" : ",") + item.first + ":" + std::to_string(item.second);
    std::printf("BOOLEANS protos_with_boolean_constant_differences=%zu (value constants; not part of the verdict)\n",
                boolean_differs);
    std::printf("CLASS_SWAPS hash_string_class_swaps=%zu other_keyuse_differences=%zu\n",
                class_swaps, other_key_diffs);
    std::printf("CODE_DIFF protos_code_equal=%zu protos_code_size_differs=%zu differing_bytes_by_canonical_op_field={%s}\n",
                code_equal, code_size_differs, census.c_str());
    const bool pass = stock.size() == candidate.size() && hash_equal == shared
        && string_equal == shared && key_equal == shared;
    std::printf("CONST_IDENTITY protos_stock=%zu protos_candidate=%zu hash_equal=%zu string_equal=%zu "
                "keyuse_equal=%zu verdict=%s\n", stock.size(), candidate.size(), hash_equal, string_equal,
                key_equal, pass ? "PASS" : "FAIL");
    return pass ? 0 : 1;
}

// ---------------------------------------------------------------------------------------------
// u44-rawhash-selftest: offline regression for the raw-hash recompile contract (no game data).
// ---------------------------------------------------------------------------------------------
static int cmd_u44_rawhash_selftest() {
    int checks = 0, failures = 0;
    auto check = [&](bool condition, const char* label) {
        ++checks;
        if (condition) std::printf("PASS %s\n", label);
        else { ++failures; std::printf("FAIL %s\n", label); }
    };
    const uint32_t saved_seed = de::active_namehash_seed;
    const bool saved_raw = de::raw_source_hashes;
    const auto saved_imports = tc::import_class_overrides;
    const auto saved_aliases = de::source_aliases;
    auto u32 = [](const de::Const& c) { uint32_t v = 0; if (c.raw.size() == 4) std::memcpy(&v, c.raw.data(), 4); return v; };
    auto str_const = [](uint32_t string_id) { luau::Const c; c.tag = luau::C_STR; c.u = string_id; return c; };
    auto import_const = [](int count, uint32_t a, uint32_t b, uint32_t c) {
        luau::Const k; k.tag = luau::C_IMPORT; k.u = ((uint32_t)count << 30) | (a << 20) | (b << 10) | c; return k;
    };
    auto keyed = [](uint8_t op, uint32_t key) { luau::Insn i; i.op = op; i.has_aux = true; i.aux = key; return i; };

    de::active_namehash_seed = de::NAMEHASH_SEED_U44;
    check(de::de_name_hash("_T") == 0x9828c6d9u, "U44 seed: FNV(_T) == 9828c6d9");

    // Legacy U44 alias contract is unchanged: an unmapped suffix is rejected, never rehashed.
    de::raw_source_hashes = false; de::source_aliases.clear();
    bool rejected = false;
    try { (void)de::resolve_name_hash("Name__c614a8c6"); } catch (const std::exception&) { rejected = true; }
    check(rejected, "alias mode rejects an unmapped suffix");

    de::raw_source_hashes = true;
    check(de::resolve_name_hash("Name__c614a8c6") == 0xc614a8c6u, "raw mode: suffix passes through verbatim");
    check(de::resolve_name_hash("SetButtons__d339ce1f") == 0xd339ce1fu, "raw mode: named alias suffix verbatim");
    check(de::resolve_name_hash("require") == de::de_name_hash("require", de::NAMEHASH_SEED_U44),
          "raw mode: plain names hash with the U44 seed");
    uint32_t declared = 0;
    check(tc::parse_name_hash_seed_directive("-- RENOVICE_NAME_HASH_SEED: 768e5ed0\nlocal x = 1\n", declared)
          && declared == de::NAMEHASH_SEED_U44, "seed directive parses");

    // 1) opaque field read without directive keeps the hash class; ordinary field stays a string.
    // 2) `Name__9828c6d9` import root is `_T`: root hashed, member string.
    // 3) RENOVICE_IMPORT_CLASS keeps an injected-property member (`EndColor.x`) a string.
    // 4) a string-keyed GETTABLEKS sharing its constant with a hashed import member keeps tag 3.
    luau::Module module;
    module.strings = {"Name__c614a8c6", "plain", "Name__9828c6d9", "Levels", "EndColor", "x",
                      "table", "bank", "spinAxis"};
    luau::Proto proto;
    for (uint32_t id = 1; id <= 9; ++id) proto.consts.push_back(str_const(id));
    proto.consts.push_back(import_const(2, 2, 3, 0));   // k9  Name__9828c6d9.Levels
    proto.consts.push_back(import_const(2, 4, 5, 0));   // k10 EndColor.x
    proto.consts.push_back(import_const(2, 6, 7, 0));   // k11 table.bank  (default: all hashed)
    proto.insns.push_back(keyed(15, 0));                // GETTABLEKS Name__c614a8c6
    proto.insns.push_back(keyed(15, 1));                // GETTABLEKS plain
    proto.insns.push_back(keyed(15, 7));                // GETTABLEKS bank (string class)
    tc::import_class_overrides = tc::parse_import_class_directives("-- RENOVICE_IMPORT_CLASS: EndColor.x=HS\n");
    std::vector<std::string> pool; std::map<std::string, int> s2i;
    std::map<uint32_t, uint32_t> hash_remap, import_remap;
    tc::NameUseClasses classes;
    const std::vector<de::Const> out = tc::transcode_consts(module, proto, pool, s2i, hash_remap, import_remap,
                                                            {}, {}, &classes);
    check(out.size() > 11 && out[0].tag == 1 && u32(out[0]) == 0xc614a8c6u, "opaque field read -> tag-1 raw hash");
    check(out[1].tag == 3, "ordinary field read stays tag-3");
    check(out[2].tag == 1 && u32(out[2]) == 0x9828c6d9u && out[3].tag == 3, "Name__9828c6d9 root treated as _T");
    check(out[4].tag == 1 && out[5].tag == 3, "import-class override keeps EndColor.x member a string");
    check(out[6].tag == 1, "library import root hashed");
    check(out[7].tag == 3 && hash_remap.count(7) == 1, "dual-use member gets a hash duplicate");
    const tc::CodeResult code = tc::transcode_code(proto, hash_remap, import_remap, &classes);
    uint32_t bank_key = 0xffffffffu;
    if (code.code.size() >= 24) std::memcpy(&bank_key, code.code.data() + 20, 4);
    check(bank_key == 7, "string-class GETTABLEKS is not redirected to the hash duplicate");
    const tc::CodeResult legacy = tc::transcode_code(proto, hash_remap, import_remap);
    uint32_t legacy_key = 0;
    if (legacy.code.size() >= 24) std::memcpy(&legacy_key, legacy.code.data() + 20, 4);
    check(legacy_key == hash_remap.at(7), "legacy remap behavior unchanged without raw classes");

    bool conflict = false;
    try { tc::parse_import_class_directives("-- RENOVICE_IMPORT_CLASS: a.b=HS\n-- RENOVICE_IMPORT_CLASS: a.b=HH\n"); }
    catch (const std::exception&) { conflict = true; }
    check(conflict, "conflicting import-class directives rejected");

    de::active_namehash_seed = saved_seed; de::raw_source_hashes = saved_raw;
    tc::import_class_overrides = saved_imports; de::source_aliases = saved_aliases;
    std::printf("U44_RAWHASH_SELFTEST checks=%d failed=%d\n", checks, failures);
    return failures ? 1 : 0;
}
