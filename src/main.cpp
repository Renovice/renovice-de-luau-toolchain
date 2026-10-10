// DeNativeRecompiler - one C++ toolchain for DE "Luau".  Milestone M1: drive the real Luau compiler
// (luau-compile.exe) to turn Luau source into Luau bytecode. M2+ add the DE transcoder (09 03) in C++.
#include <cstdio>
#include <cstdlib>
#include <string>
#include <fstream>
#include <iterator>
#include <windows.h>
#include <filesystem>
#include <algorithm>
#include <vector>
#include <set>
#include <map>
#include <sstream>
#include "luau_bc.h"
#include "de_container.h"
#include "de_namehash.h"
#include "de_build_profile.h"
#include "transcode.h"
#include "ir.h"
#include "expr.h"
#include "structur.h"
#include "structan.h"
#include "emit.h"
namespace fs = std::filesystem;

// Everything is resolved RELATIVE to this exe's own folder -> the tool is self-contained (no hardcoded external paths).
static std::string exe_dir() {
    char buf[MAX_PATH]; DWORD n = GetModuleFileNameA(nullptr, buf, MAX_PATH);
    std::string p(buf, n ? n : 0);
    size_t s = p.find_last_of("\\/");
    return (s == std::string::npos) ? std::string(".") : p.substr(0, s);
}
// luau-compile.exe ships INSIDE the folder (bin/ next to derecomp.exe).
static std::string luau_compile_path() { return exe_dir() + "\\luau-compile.exe"; }

// Windows silently refuses paths at/near MAX_PATH unless they carry the \\?\ extended-length prefix
// (and are absolute, with backslashes). Four corpus scripts have names long enough to trip this; the
// open FAILED, `read_file` returned EMPTY, and the caller reported "not a 09 03 container" — a
// misleading error that blamed the FILE for a limitation of the reader. The identical bytes decompile
// perfectly from a short path.
static std::string long_path(const std::string& p) {
#ifdef _WIN32
    if (p.size() >= 4 && p.compare(0, 4, "\\\\?\\") == 0) return p;
    std::error_code ec;
    std::string a = fs::absolute(fs::path(p), ec).string();
    if (ec) return p;
    // Gate on the ABSOLUTE length, not the given one. A 179-char RELATIVE path resolves to 241
    // absolute — testing the input length returned early, the prefix was never applied, and the four
    // longest corpus scripts kept failing with the misleading "not a 09 03 container".
    if (a.size() < 240) return p;
    for (char& c : a) if (c == '/') c = '\\';
    return "\\\\?\\" + a;
#else
    return p;
#endif
}

static std::string read_file(const std::string& p) {
    std::ifstream f(long_path(p), std::ios::binary);
    return std::string((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
}
static bool write_file(const std::string& p, const std::string& d) {
    std::ofstream f(p, std::ios::binary);
    if (!f) return false;
    f.write(d.data(), (std::streamsize)d.size());
    return (bool)f;
}

// Luau source file -> standard Luau bytecode, via the real compiler (redirect binary stdout to a temp file).
static std::string compile_luau(const std::string& src_path, std::string& err) {
    // Process-unique. A FIXED name here means two concurrent derecomp runs overwrite each other's
    // compiler output and silently produce garbage — the same defect as the oracle's `_emit_probe`
    // file (#36), and it made a parallel round-trip report 31% when the real answer was 100%.
    const std::string tmp = "_derecomp_luaubc_"
                          + std::to_string((long long)GetCurrentProcessId()) + ".tmp";
    const std::string errtmp = "_derecomp_luauerr_"
                             + std::to_string((long long)GetCurrentProcessId()) + ".tmp";
    std::string inner = std::string("\"") + luau_compile_path() + "\" --binary \""
                      + src_path + "\" > \"" + tmp + "\" 2> \"" + errtmp + "\"";
    // cmd.exe strips one leading+trailing quote off the whole /c line; wrap in an extra pair so the inner stays balanced.
    std::string cmd = "\"" + inner + "\"";
    int rc = std::system(cmd.c_str());
    std::string bc = read_file(tmp);
    const std::string compiler_error = read_file(errtmp);
    std::remove(tmp.c_str());
    std::remove(errtmp.c_str());
    if (rc != 0) {
        err = compiler_error.empty()
            ? "luau-compile.exe returned " + std::to_string(rc)
            : compiler_error;
        return {};
    }
    if (bc.empty()) { err = "empty bytecode (compile error?)"; return {}; }
    return bc;
}

// M2 verify: parse a .luaubc and print the SAME summary as luau_read.py (for byte-for-byte diffing).
static int cmd_dump(int argc, char** argv) {
    std::string bc = read_file(argv[2]);
    if (bc.empty()) { std::fprintf(stderr, "[derecomp] cannot read %s\n", argv[2]); return 1; }
    luau::Module m;
    try { m = luau::read(bc); }
    catch (const std::exception& e) { std::fprintf(stderr, "[derecomp] parse error: %s\n", e.what()); return 1; }
    std::printf("version=%d typeversion=%d strings=%d protos=%d mainid=%d\n",
                m.version, m.typeversion, (int)m.strings.size(), (int)m.protos.size(), (int)m.mainid);
    for (size_t i = 0; i < m.protos.size(); ++i) {
        const luau::Proto& p = m.protos[i];
        std::string kids = "[";
        for (size_t k = 0; k < p.kids.size(); ++k) { if (k) kids += ", "; kids += std::to_string(p.kids[k]); }
        kids += "]";
        std::printf("proto[%d] mx=%d npar=%d nups=%d vararg=%d insns=%d consts=%d kids=%s\n",
                    (int)i, p.mx, p.npar, p.nups, p.isvararg, (int)p.insns.size(), (int)p.consts.size(), kids.c_str());
    }
    if (argc > 3) {                                          // optional: disasm one proto (matches luau_read.py)
        int idx = std::atoi(argv[3]);
        if (idx < 0 || idx >= (int)m.protos.size()) { std::fprintf(stderr, "bad proto idx\n"); return 1; }
        const luau::Proto& p = m.protos[idx];
        for (size_t j = 0; j < p.insns.size(); ++j) {
            const luau::Insn& in = p.insns[j];
            std::string extra;
            const char* nm = in.name();
            bool named = !std::strcmp(nm,"NAMECALL")||!std::strcmp(nm,"GETGLOBAL")||!std::strcmp(nm,"SETGLOBAL")||
                         !std::strcmp(nm,"GETTABLEKS")||!std::strcmp(nm,"SETTABLEKS");
            if (named && in.has_aux && in.aux < p.consts.size()) {
                const luau::Const& k = p.consts[in.aux];
                if (k.tag == luau::C_STR) extra = " ['" + luau::sstr(m, k.u) + "']";
            }
            std::string auxs = in.has_aux ? (" aux=" + std::to_string(in.aux)) : std::string();
            std::printf("  [%2d] %-14s A=%d B=%d C=%d D=%d%s%s\n",
                        (int)j, nm, in.A, in.B, in.C, in.D, auxs.c_str(), extra.c_str());
        }
    }
    return 0;
}

// M3 verify: read a DE 09 03 .lua_B, reconstruct consts from parsed form, re-emit BYTE-EXACT.
// Output mirrors encode_luab.round_trip so it can be diffed against the Python.  Exit 0 iff byte-exact.
static int cmd_de_roundtrip(int argc, char** argv) {
    std::string b = read_file(argv[2]);
    if (b.empty()) { std::fprintf(stderr, "[derecomp] cannot read %s\n", argv[2]); return 1; }
    de::Module m;
    try { m = de::walk(b); }
    catch (const std::exception& e) { std::printf("%-40s WALK ERROR %s\n", argv[2], e.what()); return 1; }
    int const_ok = 0;
    try {
        for (const de::Proto& p : m.protos)
            if (de::enc_consts(p.sizek, p.consts) == p.consts_span) ++const_ok;
    } catch (const std::exception& e) { std::printf("%-40s ENCODE ERROR %s\n", argv[2], e.what()); return 1; }
    std::string re;
    try { re = de::encode(m); }
    catch (const std::exception& e) { std::printf("%-40s ENCODE ERROR %s\n", argv[2], e.what()); return 1; }
    bool same = (re == b);
    std::printf("nps=%-4d consts re-encode exact: %d/%d  FULL BODY identical: %s%s\n",
                m.nps, const_ok, (int)m.protos.size(), same ? "True" : "False",
                same ? "" : ("  (len " + std::to_string(re.size()) + " vs " + std::to_string(b.size()) + ")").c_str());
    return (same && const_ok == (int)m.protos.size()) ? 0 : 1;
}

// M3 exhaustive: round-trip every *.lua_B in a directory in-process (no per-file process spawn).
static int cmd_de_roundtrip_batch(int argc, char** argv) {
    fs::path dir = argv[2];
    if (!fs::exists(dir) || !fs::is_directory(dir)) { std::fprintf(stderr, "[derecomp] not a directory: %s\n", argv[2]); return 1; }
    int total = 0, exact = 0, mismatch = 0, walkerr = 0, skipped = 0;
    std::vector<std::string> fails;
    for (const auto& e : fs::directory_iterator(dir)) {
        if (!e.is_regular_file() || e.path().extension() != ".lua_B") continue;
        std::string b = read_file(e.path().string());
        if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) { ++skipped; continue; }
        ++total;
        try {
            de::Module m = de::walk(b);
            std::string re = de::encode(m);
            bool same = (re == b);
            int cok = 0; for (const auto& pr : m.protos) if (de::enc_consts(pr.sizek, pr.consts) == pr.consts_span) ++cok;
            if (same && cok == (int)m.protos.size()) ++exact;
            else { ++mismatch; if (fails.size() < 60) fails.push_back(e.path().filename().string() + "  body_same=" + (same?"1":"0") + " consts=" + std::to_string(cok) + "/" + std::to_string(m.protos.size())); }
        } catch (const std::exception& ex) {
            ++walkerr; if (fails.size() < 60) fails.push_back(e.path().filename().string() + "  WALK: " + ex.what());
        }
    }
    std::printf("DE round-trip batch: %d files (09 03) | byte-exact=%d  mismatch=%d  walk-error=%d  (skipped non-0903=%d)\n",
                total, exact, mismatch, walkerr, skipped);
    for (const auto& f : fails) std::printf("  FAIL %s\n", f.c_str());
    if (fails.size() >= 60) std::printf("  ... (truncated at 60)\n");
    return (exact == total && total > 0) ? 0 : 1;
}

// M3 coverage: const-tag histogram + edge-shape census across a corpus (what did we actually exercise?).
static int cmd_de_stats(int argc, char** argv) {
    fs::path dir = argv[2];
    if (!fs::exists(dir) || !fs::is_directory(dir)) { std::fprintf(stderr, "[derecomp] not a directory: %s\n", argv[2]); return 1; }
    long long tag[16] = {0}, invalid = 0, files = 0, protos = 0, inline_src = 0, nametab = 0;
    long long tag5items = 0, tag8items = 0; int minp = 1 << 30, maxp = 0;
    for (const auto& e : fs::directory_iterator(dir)) {
        if (!e.is_regular_file() || e.path().extension() != ".lua_B") continue;
        std::string b = read_file(e.path().string());
        if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) continue;
        de::Module m;
        try { m = de::walk(b); } catch (...) { continue; }
        ++files; protos += m.protos.size();
        if ((int)m.protos.size() < minp) minp = (int)m.protos.size();
        if ((int)m.protos.size() > maxp) maxp = (int)m.protos.size();
        // pool name-table flag
        try { size_t o = 2; uint64_t ns = de::rd_vi(b, o); for (uint64_t i = 0; i < ns; ++i) { uint64_t ln = de::rd_vi(b, o); o += (size_t)ln; } if ((uint8_t)b[o] != 0) ++nametab; } catch (...) {}
        for (const de::Proto& p : m.protos) {
            size_t hp = p.h0 + 5; try { if (de::rd_vi(b, hp) > 0) ++inline_src; } catch (...) {}   // non-empty inline srcname
            for (const de::Const& c : p.consts) {
                if (c.tag >= 0 && c.tag <= 9) ++tag[c.tag]; else ++invalid;
                if (c.tag == 5) tag5items += (long long)c.list.size();
                if (c.tag == 8) tag8items += (long long)c.items.size();
            }
        }
    }
    std::printf("== DE corpus coverage ==\n");
    std::printf("files=%lld  protos=%lld  protos/file min=%d max=%d\n", files, protos, minp, maxp);
    const char* names[10] = {"0 nil","1 u32","2 f64","3 str","4 typed","5 table","6 closure","7 vec3","8 tablearr","9 int64"};
    for (int t = 0; t <= 9; ++t) std::printf("  const tag %-11s : %lld%s\n", names[t], tag[t], tag[t] == 0 ? "   <-- UNTESTED (handled but never seen)" : "");
    std::printf("  invalid-tag consts: %lld\n", invalid);
    std::printf("edge shapes: non-empty inline srcname protos=%lld | pool name-table flag files=%lld\n", inline_src, nametab);
    std::printf("table sizes: tag5 total items=%lld  tag8 total items=%lld\n", tag5items, tag8items);
    return 0;
}

// M4: name hash (self-test vs known native pairs).
static int cmd_namehash(int argc, char** argv) {
    // Show BOTH: the plain FNV, and the resolver the transcoder actually uses. The resolver honors the
    // `RealName__aabbccdd` convention, which is how a name we could not reverse still round-trips exactly.
    uint32_t raw = de::de_name_hash(argv[2]);
    uint32_t res = de::resolve_name_hash(argv[2]);
    std::printf("raw=0x%08X  resolved=0x%08X%s\n", raw, res, res != raw ? "   (__suffix honored)" : "");
    return 0;
}

// M4: Luau bytecode -> DE 09 03 body (for byte-diffing against luau_to_de.py).
static int cmd_transcode(int argc, char** argv) {
    std::string bc = read_file(argv[2]);
    if (bc.empty()) { std::fprintf(stderr, "[derecomp] cannot read %s\n", argv[2]); return 1; }
    std::string de_body;
    try { de_body = tc::transcode(bc); }
    catch (const std::exception& e) { std::fprintf(stderr, "[derecomp] transcode error: %s\n", e.what()); return 1; }
    if (!write_file(argv[3], de_body)) { std::fprintf(stderr, "[derecomp] cannot write %s\n", argv[3]); return 1; }
    std::printf("[derecomp] transcode %s -> %s : %zu bytes DE 09 03\n", argv[2], argv[3], de_body.size());
    return 0;
}

// M4: full recompile — Luau source -> Luau bytecode (M1) -> transcode (M4) -> DE 09 03.  Verifies it re-parses.
static int cmd_recompile(int argc, char** argv) {
    const std::string source = read_file(argv[2]);
    if (source.empty()) { std::fprintf(stderr, "[derecomp] cannot read %s\n", argv[2]); return 1; }
    std::set<std::string> hashed_globals, hashed_fields;
    try {
        hashed_globals = tc::parse_hashed_global_directives(source);
        hashed_fields = tc::parse_hashed_field_directives(source);
        // A declared hash namespace must be the one this mode targets. Raw-hash sources carry
        // exact stock hashes, so combining one with a U43 alias map would be ambiguous.
        uint32_t declared_seed = 0;
        if (tc::parse_name_hash_seed_directive(source, declared_seed)) {
            if (declared_seed != de::active_namehash_seed) {
                std::fprintf(stderr, "[derecomp] source declares name-hash seed %08x but this mode "
                             "targets %08x\n", declared_seed, de::active_namehash_seed);
                return 1;
            }
            if (!de::source_aliases.empty()) {
                std::fprintf(stderr, "[derecomp] raw-hash source must not be combined with a "
                             "source alias map\n");
                return 1;
            }
            de::raw_source_hashes = true;
        }
        tc::import_class_overrides = tc::parse_import_class_directives(source);
        sp::shared_proto_lines() = sp::parse_shared_proto_markers(source);
    }
    catch (const std::exception& e) {
        std::fprintf(stderr, "[derecomp] source metadata error: %s\n", e.what()); return 1;
    }
    std::string err;
    std::string bc = compile_luau(argv[2], err);
    if (bc.empty()) { std::fprintf(stderr, "[derecomp] luau compile failed: %s\n", err.c_str()); return 1; }
    std::string de_body;
    try {
        de_body = tc::transcode(bc, hashed_globals, hashed_fields);
        if (de::active_namehash_seed == 0x768e5ed0u) de_body = de::change_build_profile(de_body, true);
    }
    catch (const std::exception& e) { std::fprintf(stderr, "[derecomp] transcode error: %s\n", e.what()); return 1; }
    // sanity: the emitted body must re-parse as a valid DE container (offline load check)
    bool loads = true; int nps = -1;
    try { de::Module m = de::walk(de_body); nps = m.nps; } catch (const std::exception&) { loads = false; }
    if (!write_file(argv[3], de_body)) { std::fprintf(stderr, "[derecomp] cannot write %s\n", argv[3]); return 1; }
    std::printf("[derecomp] recompile %s -> %s : %zu bytes, nps=%d, re-parses=%s, "
                "hashed-globals=%zu, hashed-fields=%zu%s\n", argv[2], argv[3], de_body.size(), nps,
                loads ? "yes" : "NO", hashed_globals.size(), hashed_fields.size(),
                de::raw_source_hashes ? ", raw-hash-source=yes" : "");
    const sp::MergeReport& shared = tc::last_shared_proto_report();
    if (shared.groups || !shared.refused.empty())
        std::printf("[derecomp] shared prototypes: groups=%d merged=%d unequal=%d%s%s\n", shared.groups,
                    shared.merged, shared.unequal, shared.refused.empty() ? "" : " REFUSED: ",
                    shared.refused.c_str());
    return loads ? 0 : 2;
}

// Regression for the live Batch-02 failure: globals must stay native DE 0x17/0x02 operations.
// The retired `_G` compatibility route synthesized GET/SETFIELD with cache slot C=255, which the
// real VM treats as out of range and can turn into register corruption or an access violation.
static int cmd_transcode_global_selftest() {
    luau::Proto proto;
    proto.mx = 3;

    luau::Insn get;
    get.op = 7; // Luau GETGLOBAL
    get.A = 1; get.C = 37; get.has_aux = true; get.aux = 0;
    proto.insns.push_back(get);

    luau::Insn set;
    set.op = 8; // Luau SETGLOBAL
    set.A = 2; set.C = 91; set.has_aux = true; set.aux = 1;
    proto.insns.push_back(set);

    const tc::CodeResult result = tc::transcode_code(proto, {}, {});
    const bool shape = result.code.size() == 16 && result.sizecode == 4
        && result.maxstack == proto.mx;
    const bool get_ok = shape
        && (unsigned char)result.code[0] == 0x17
        && (unsigned char)result.code[1] == 1
        && (unsigned char)result.code[2] == 0
        && (unsigned char)result.code[3] == 37;
    const bool set_ok = shape
        && (unsigned char)result.code[8] == 0x02
        && (unsigned char)result.code[9] == 2
        && (unsigned char)result.code[10] == 0
        && (unsigned char)result.code[11] == 91;
    // Shared import/field-key regression: upstream Luau intentionally reuses `rhinoRoar` for the
    // `_T.rhinoRoar` import and SETTABLEKS write. Stock DE preserves the same tag-3 string constant
    // in BOTH positions. Splitting the import to a hash avoids the SETFIELD GPF but leaves the later
    // GETIMPORT nil in the live VM, so exact shared-string ownership is required.
    luau::Module shared_module;
    shared_module.strings = {"_T", "rhinoRoar"};
    luau::Proto shared_proto;
    luau::Const root_name; root_name.tag = luau::C_STR; root_name.u = 1;
    luau::Const field_name; field_name.tag = luau::C_STR; field_name.u = 2;
    luau::Const import_path; import_path.tag = luau::C_IMPORT;
    import_path.u = (2u << 30) | (0u << 20) | (1u << 10);
    shared_proto.consts = {root_name, field_name, import_path};
    luau::Insn import_read;
    import_read.op = 12; // Luau GETIMPORT
    import_read.A = 0;
    import_read.B = 2;
    import_read.C = 0;
    import_read.D = 2;
    import_read.has_aux = true;
    import_read.aux = import_path.u;
    shared_proto.insns.push_back(import_read);
    luau::Insn field_write;
    field_write.op = 16; // Luau SETTABLEKS
    field_write.has_aux = true;
    field_write.aux = 1;
    shared_proto.insns.push_back(field_write);

    std::vector<std::string> shared_pool;
    std::map<std::string, int> shared_s2i;
    std::map<uint32_t, uint32_t> shared_remap;
    std::map<uint32_t, uint32_t> shared_import_remap;
    const std::vector<de::Const> shared_consts =
        tc::transcode_consts(shared_module, shared_proto, shared_pool, shared_s2i,
                             shared_remap, shared_import_remap);
    uint32_t remapped_import = 0;
    if (shared_consts.size() > 2 && shared_consts[2].raw.size() == 4)
        std::memcpy(&remapped_import, shared_consts[2].raw.data(), 4);
    const tc::CodeResult shared_code =
        tc::transcode_code(shared_proto, shared_remap, shared_import_remap);
    uint32_t remapped_instruction_import = 0;
    uint32_t field_write_key = 0;
    if (shared_code.code.size() == 16) {
        std::memcpy(&remapped_instruction_import, shared_code.code.data() + 4, 4);
        std::memcpy(&field_write_key, shared_code.code.data() + 12, 4);
    }
    const bool shared_ok = shared_consts.size() == 3
        && shared_consts[1].tag == 3
        && shared_remap.count(1) == 0
        && ((remapped_import >> 30) & 3) == 2
        && ((remapped_import >> 20) & 0x3ff) == 0
        && ((remapped_import >> 10) & 0x3ff) == 1
        && shared_code.code.size() == 16
        && (unsigned char)shared_code.code[0] == 0x46
        && remapped_instruction_import == remapped_import
        && (unsigned char)shared_code.code[8] == 0x15
        && field_write_key == 1;

    // Corpus-wide ability-card regression: the stock compiler represents all
    // `_T.AbilityLevelQueryParms.Level` paths as hash/string/string, while
    // ordinary library paths such as `table.insert` are hash/hash. These two
    // witnesses prevent both the previous all-hash UI failure and an unsafe
    // all-string overcorrection.
    luau::Module import_module;
    import_module.strings = {"_T", "AbilityLevelQueryParms", "Level", "table", "insert"};
    luau::Proto import_proto;
    for (uint32_t string_id = 1; string_id <= 5; ++string_id) {
        luau::Const value;
        value.tag = luau::C_STR;
        value.u = string_id;
        import_proto.consts.push_back(value);
    }
    luau::Const shared_path;
    shared_path.tag = luau::C_IMPORT;
    shared_path.u = (3u << 30) | (0u << 20) | (1u << 10) | 2u;
    import_proto.consts.push_back(shared_path);
    luau::Const library_path;
    library_path.tag = luau::C_IMPORT;
    library_path.u = (2u << 30) | (3u << 20) | (4u << 10);
    import_proto.consts.push_back(library_path);
    std::vector<std::string> import_pool;
    std::map<std::string, int> import_s2i;
    std::map<uint32_t, uint32_t> import_hash_remap;
    std::map<uint32_t, uint32_t> import_descriptor_remap;
    const std::vector<de::Const> import_consts = tc::transcode_consts(
        import_module, import_proto, import_pool, import_s2i,
        import_hash_remap, import_descriptor_remap);
    uint32_t shared_path_output = 0;
    uint32_t library_path_output = 0;
    if (import_consts.size() == 7 && import_consts[5].raw.size() == 4
        && import_consts[6].raw.size() == 4) {
        std::memcpy(&shared_path_output, import_consts[5].raw.data(), 4);
        std::memcpy(&library_path_output, import_consts[6].raw.data(), 4);
    }
    const bool import_path_ok = import_consts.size() == 7
        && import_consts[0].tag == 1
        && import_consts[1].tag == 3
        && import_consts[2].tag == 3
        && import_consts[3].tag == 1
        && import_consts[4].tag == 1
        && shared_path_output == shared_path.u
        && library_path_output == library_path.u
        && import_hash_remap.empty();

    // Lossless global-kind regression. The DE corpus contains two semantically distinct global
    // classes that upstream Luau flattens to the same source syntax. Force projectileType to the
    // hashed class while leaving ordinaryGlobal string-keyed. Sharing projectileType with a field
    // operation also proves that only the global instructions are remapped to the hash duplicate.
    luau::Module global_module;
    global_module.strings = {"ordinaryGlobal", "projectileType"};
    luau::Proto global_proto;
    luau::Const ordinary_name; ordinary_name.tag = luau::C_STR; ordinary_name.u = 1;
    luau::Const property_name; property_name.tag = luau::C_STR; property_name.u = 2;
    global_proto.consts = {ordinary_name, property_name};
    auto add_global_instruction = [&](int op, int reg, uint32_t key) {
        luau::Insn instruction;
        instruction.op = op; instruction.A = reg; instruction.has_aux = true;
        instruction.aux = key; global_proto.insns.push_back(instruction);
    };
    add_global_instruction(7, 0, 0);  // GETGLOBAL ordinaryGlobal
    add_global_instruction(8, 1, 0);  // SETGLOBAL ordinaryGlobal
    add_global_instruction(7, 0, 1);  // GETGLOBAL projectileType
    add_global_instruction(8, 1, 1);  // SETGLOBAL projectileType
    luau::Insn property_field;
    property_field.op = 16; // SETTABLEKS, deliberately shares the same source string
    property_field.has_aux = true; property_field.aux = 1;
    global_proto.insns.push_back(property_field);
    luau::Insn property_field_read;
    property_field_read.op = 15; // GETTABLEKS, same source string but hashed read class
    property_field_read.has_aux = true; property_field_read.aux = 1;
    global_proto.insns.push_back(property_field_read);
    std::vector<std::string> global_pool;
    std::map<std::string, int> global_s2i;
    std::map<uint32_t, uint32_t> global_hash_remap;
    std::map<uint32_t, uint32_t> global_import_remap;
    const std::vector<de::Const> global_consts = tc::transcode_consts(
        global_module, global_proto, global_pool, global_s2i, global_hash_remap,
        global_import_remap, {"projectileType"}, {"projectileType"});
    const tc::CodeResult global_code = tc::transcode_code(
        global_proto, global_hash_remap, global_import_remap);
    auto aux_at = [&](size_t offset) {
        uint32_t value = UINT32_MAX;
        if (offset + 8 <= global_code.code.size())
            std::memcpy(&value, global_code.code.data() + offset + 4, 4);
        return value;
    };
    uint32_t property_hash = 0;
    if (global_consts.size() == 3 && global_consts[2].raw.size() >= 4)
        std::memcpy(&property_hash, global_consts[2].raw.data(), 4);
    const bool global_kind_ok = global_consts.size() == 3
        && global_consts[0].tag == 3
        && global_consts[1].tag == 3
        && global_consts[2].tag == 1
        && property_hash == de::resolve_name_hash("projectileType")
        && global_hash_remap.count(1) && global_hash_remap.at(1) == 2
        && global_code.code.size() == 48
        && (unsigned char)global_code.code[0] == 0x17 && aux_at(0) == 0
        && (unsigned char)global_code.code[8] == 0x02 && aux_at(8) == 0
        && (unsigned char)global_code.code[16] == 0x17 && aux_at(16) == 2
        && (unsigned char)global_code.code[24] == 0x02 && aux_at(24) == 2
        && (unsigned char)global_code.code[32] == 0x15 && aux_at(32) == 1
        && (unsigned char)global_code.code[40] == 0x3d && aux_at(40) == 2;
    const std::set<std::string> parsed_metadata = tc::parse_hashed_global_directives(
        "-- RENOVICE_HASH_GLOBAL: projectileType\r\n"
        "-- RENOVICE_HASH_GLOBAL: fightingProjectileType\nlocal x = 1\n");
    const bool metadata_ok = parsed_metadata
        == std::set<std::string>{"fightingProjectileType", "projectileType"}
        && tc::parse_hashed_field_directives(
            "-- RENOVICE_HASH_FIELD: projectileType\n")
            == std::set<std::string>{"projectileType"};

    if (!get_ok || !set_ok || !shared_ok || !import_path_ok
        || !global_kind_ok || !metadata_ok) {
        std::fprintf(stderr,
                     "TRANSCODE_GLOBAL_SELFTEST FAIL shape=%d get=%d set=%d shared_import_field=%d "
                     "dynamic_import_path=%d global_kind=%d metadata=%d bytes=%zu\n",
                     shape ? 1 : 0, get_ok ? 1 : 0, set_ok ? 1 : 0, shared_ok ? 1 : 0,
                     import_path_ok ? 1 : 0, global_kind_ok ? 1 : 0, metadata_ok ? 1 : 0,
                     result.code.size());
        return 1;
    }
    std::printf("TRANSCODE_GLOBAL_SELFTEST PASS native_get=0x17 native_set=0x02 "
                "cache_slots=37,91 synthetic_cache_255=0 shared_import_field_string=1 "
                "dynamic_T_import_strings=1 library_import_hashes=1 "
                "hashed_global_metadata=1 hashed_field_metadata=1 "
                "dual_global_field_remap=1\n");
    return 0;
}

// Opcode histogram over REAL .lua_B (reuses the proven de::walk parser + tc::is_de_width8 widths).
// clean_walk = protos where WIDTH8-based walking lands EXACTLY on the code end (self-consistency check;
// a wrong width would desync and leave o != code end). This is the ground-truth disk opcode census.
static int cmd_histops(int argc, char** argv) {
    fs::path dir = argv[2];
    if (!fs::exists(dir)) { std::fprintf(stderr, "[derecomp] not found: %s\n", argv[2]); return 1; }
    long long hist[256] = {0}, wideCount[256] = {0};
    long long files = 0, protos = 0, clean = 0, dirty = 0;
    auto do_file = [&](const std::string& path) {
        std::string b = read_file(path);
        if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) return;
        de::Module m;
        try { m = de::walk(b); } catch (...) { return; }
        ++files;
        for (const de::Proto& p : m.protos) {
            ++protos;
            const std::string& code = p.code;
            size_t o = 0;
            while (o + 4 <= code.size()) {
                uint8_t op = (uint8_t)code[o];
                ++hist[op];
                bool wide = tc::is_de_width8(op);
                if (wide) ++wideCount[op];
                size_t adv = wide ? 8 : 4;
                if (o + adv > code.size()) break;
                o += adv;
            }
            if (o == code.size()) ++clean; else ++dirty;
        }
    };
    if (fs::is_directory(dir)) {
        for (const auto& e : fs::directory_iterator(dir))
            if (e.is_regular_file() && e.path().extension() == ".lua_B") do_file(e.path().string());
    } else do_file(dir.string());
    std::printf("files=%lld protos=%lld  clean_walk=%lld dirty_walk=%lld (%.2f%% clean)\n",
                files, protos, clean, dirty, protos ? 100.0 * clean / protos : 0.0);
    std::vector<std::pair<long long, int>> v;
    for (int i = 0; i < 256; ++i) if (hist[i]) v.emplace_back(hist[i], i);
    std::sort(v.rbegin(), v.rend());
    std::printf("byte  count      width\n");
    for (auto& pr : v)
        std::printf("  0x%02x  %-9lld  %s\n", pr.second, pr.first, tc::is_de_width8(pr.second) ? "8B" : "4B");
    return 0;
}

// Compact, machine-parseable structural summary for idempotence certification. Unlike de-disasm,
// this does not print constants or every instruction, so a ten-cycle gate can record EVERY cycle
// without moving hundreds of megabytes through stdout. The gate intentionally tracks both the full
// opcode histogram and the per-prototype maxstack vector: equal file sizes can hide offsetting drift.
static int cmd_de_summary(int argc, char** argv) {
    fs::path file = argv[2];
    if (!fs::exists(file) || !fs::is_regular_file(file)) {
        std::fprintf(stderr, "[derecomp] not a file: %s\n", argv[2]);
        return 1;
    }
    std::string b = read_file(file.string());
    if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) {
        std::fprintf(stderr, "[derecomp] not a DE 09 03 container: %s\n", argv[2]);
        return 1;
    }
    de::Module m;
    try { m = de::walk(b); }
    catch (const std::exception& e) {
        std::fprintf(stderr, "[derecomp] walk failed: %s\n", e.what());
        return 1;
    }

    long long hist[256] = {0};
    long long instructions = 0, code_bytes = 0, maxstack_sum = 0;
    int maxstack_max = 0, dirty = 0;
    std::vector<int> maxstacks;
    for (const de::Proto& p : m.protos) {
        int stack = p.hdr.empty() ? -1 : (int)(uint8_t)p.hdr[0];
        maxstacks.push_back(stack);
        if (stack >= 0) {
            maxstack_sum += stack;
            maxstack_max = std::max(maxstack_max, stack);
        }
        code_bytes += (long long)p.code.size();
        size_t o = 0;
        while (o + 4 <= p.code.size()) {
            uint8_t op = (uint8_t)p.code[o];
            size_t width = tc::is_de_width8(op) ? 8 : 4;
            if (o + width > p.code.size()) break;
            ++hist[op];
            ++instructions;
            o += width;
        }
        if (o != p.code.size()) ++dirty;
    }

    std::printf("bytes=%zu protos=%zu instructions=%lld code_bytes=%lld dirty_walk=%d maxstack_sum=%lld maxstack_max=%d\n",
                b.size(), m.protos.size(), instructions, code_bytes, dirty, maxstack_sum, maxstack_max);
    std::printf("maxstacks=");
    for (size_t i = 0; i < maxstacks.size(); ++i) {
        if (i) std::printf(",");
        std::printf("%d", maxstacks[i]);
    }
    std::printf("\n");
    for (int op = 0; op < 256; ++op)
        if (hist[op]) std::printf("op=0x%02x count=%lld\n", op, hist[op]);
    return dirty ? 2 : 0;
}

// DE disassembler for a real .lua_B: prints each proto's instructions (op byte, A/B/C, aux, width).
// For source<->bytecode correlation. proto index optional (default all).
static int cmd_de_disasm(int argc, char** argv) {
    std::string b = read_file(argv[2]);
    if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) { std::fprintf(stderr, "not 09 03\n"); return 1; }
    de::Module m;
    try { m = de::walk(b); } catch (const std::exception& e) { std::fprintf(stderr, "walk: %s\n", e.what()); return 1; }
    int want = (argc >= 4) ? std::atoi(argv[3]) : -1;
    for (size_t pi = 0; pi < m.protos.size(); ++pi) {
        if (want >= 0 && (int)pi != want) continue;
        const de::Proto& p = m.protos[pi];
        int h_mx = p.hdr.size() > 0 ? (uint8_t)p.hdr[0] : -1, h_npar = p.hdr.size() > 1 ? (uint8_t)p.hdr[1] : -1;
        int h_nups = p.hdr.size() > 2 ? (uint8_t)p.hdr[2] : -1, h_va = p.hdr.size() > 3 ? (uint8_t)p.hdr[3] : -1;
        std::printf("== proto[%zu] sizecode-bytes=%zu nconsts=%zu maxstack=%d nparams=%d nups=%d vararg=%d ==\n",
                    pi, p.code.size(), p.consts.size(), h_mx, h_npar, h_nups, h_va);
        for (size_t ci = 0; ci < p.consts.size(); ++ci) {
            const de::Const& c = p.consts[ci];
            std::printf("    k[%zu] tag=%d", ci, c.tag);
            if (c.tag == 1 && c.raw.size() >= 4) { uint32_t h; std::memcpy(&h, c.raw.data(), 4); std::printf(" hash=0x%08x", h); }
            else if (c.tag == 3) std::printf(" strpool_idx=%llu", static_cast<unsigned long long>(c.idx));
            else if (c.tag == 4 && c.raw.size() >= 4) { uint32_t u; std::memcpy(&u, c.raw.data(), 4); std::printf(" import=0x%08x", u); }
            std::printf("\n");
        }
        const std::string& code = p.code;
        size_t o = 0; int idx = 0;
        while (o + 4 <= code.size()) {
            uint32_t w; std::memcpy(&w, code.data() + o, 4);
            uint8_t op = w & 0xff, A = (w >> 8) & 0xff, B = (w >> 16) & 0xff, C = (w >> 24) & 0xff;
            uint16_t Bx = (w >> 16) & 0xffff;
            bool wide = tc::is_de_width8(op);
            uint32_t aux = 0; if (wide && o + 8 <= code.size()) std::memcpy(&aux, code.data() + o + 4, 4);
            if (wide) std::printf("  [%3d] @%04zx op=0x%02x A=%d B=%d C=%d Bx=%d aux=0x%08x %s\n", idx, o, op, A, B, C, Bx, aux, "[8B]");
            else      std::printf("  [%3d] @%04zx op=0x%02x A=%d B=%d C=%d Bx=%d %s\n", idx, o, op, A, B, C, Bx, "");
            o += wide ? 8 : 4; ++idx;
        }
    }
    return 0;
}

// Per-file opcode-count CSV (name + 256 counts) for source<->opcode statistical correlation.
static int cmd_histcsv(int argc, char** argv) {
    fs::path dir = argv[2];
    std::ofstream out(argv[3]);
    if (!out) { std::fprintf(stderr, "cannot write %s\n", argv[3]); return 1; }
    out << "name";
    for (int i = 0; i < 256; ++i) out << ",x" << std::hex << i << std::dec;
    out << "\n";
    long long files = 0;
    for (const auto& e : fs::directory_iterator(dir)) {
        if (!e.is_regular_file() || e.path().extension() != ".lua_B") continue;
        std::string b = read_file(e.path().string());
        if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) continue;
        de::Module m; try { m = de::walk(b); } catch (...) { continue; }
        long long h[256] = {0};
        for (const de::Proto& p : m.protos) {
            const std::string& code = p.code; size_t o = 0;
            while (o + 4 <= code.size()) {
                uint8_t op = (uint8_t)code[o]; ++h[op];
                o += tc::is_de_width8(op) ? 8 : 4;
            }
        }
        std::string nm = e.path().stem().string();
        out << nm;
        for (int i = 0; i < 256; ++i) out << "," << h[i];
        out << "\n";
        ++files;
    }
    std::printf("wrote %lld rows to %s\n", files, argv[3]);
    return 0;
}

// ---- M5: DECODE VALIDATION -------------------------------------------------------------------
// Bytecode-grounded soundness sweep. Uses NO decompiled source (v13/v14 were produced by the old,
// wrong opcode map and are a contaminated oracle). For every instruction in every proto we check the
// operands our decode map implies are actually in range. A wrong decode shows up as an impossible
// operand: a register past maxstack, a const index past nconsts, or a branch landing off-boundary.
struct OpInfo { const char* name; bool wide; bool branch; int regmask; int auxconst; int bxconst; };
// regmask bits: 1=A 2=B 4=C   auxconst: aux&0xffff indexes K[]   bxconst: Bx indexes K[]
static const OpInfo* opinfo(uint8_t op) {
    static std::map<uint8_t, OpInfo> t = {
        {0x01,{"GETTABLE",0,0,7,0,0}},   {0x2a,{"SETTABLE",0,0,7,0,0}},
        {0x3d,{"GETFIELD",1,0,3,1,0}},   {0x15,{"SETFIELD",1,0,3,1,0}},
        {0x17,{"GETGLOBAL",1,0,1,1,0}},  {0x02,{"SETGLOBAL",1,0,1,1,0}},
        {0x44,{"GETTABLEN",0,0,3,0,0}},  {0x2e,{"SETTABLEN",0,0,3,0,0}},
        {0x2d,{"NAMECALL",1,0,3,1,0}},   {0x46,{"GETIMPORT",1,0,1,0,0}},
        {0x12,{"LOADN",0,0,1,0,0}},      {0x4e,{"LOADK",0,0,1,0,1}},
        {0x0d,{"LOADNIL",0,0,1,0,0}},    {0x04,{"LOADB",0,0,1,0,0}},
        {0x14,{"MOVE",0,0,3,0,0}},       {0x54,{"CALL",0,0,1,0,0}},
        {0x29,{"RETURN",0,0,0,0,0}},     {0x13,{"GETUPVAL",0,0,1,0,0}},
        {0x53,{"SETUPVAL",0,0,1,0,0}},   {0x16,{"NEWCLOSURE",0,0,1,0,0}},
        {0x42,{"DUPCLOSURE",0,0,1,0,1}}, {0x35,{"CAPTURE",0,0,0,0,0}},
        {0x39,{"CLOSEUPVALS",0,0,1,0,0}},{0x2c,{"NEWTABLE",1,0,1,0,0}},
        {0x4f,{"DUPTABLE",0,0,1,0,1}},   {0x3f,{"SETLIST",1,0,3,0,0}},
        {0x49,{"ADD",0,0,7,0,0}},        {0x07,{"SUB",0,0,7,0,0}},
        {0x22,{"MUL",0,0,7,0,0}},        {0x1a,{"DIV",0,0,7,0,0}},
        {0x55,{"MOD",0,0,7,0,0}},        {0x45,{"POW",0,0,7,0,0}},
        {0x0e,{"MINUS",0,0,3,0,0}},      {0x50,{"NOT",0,0,3,0,0}},
        {0x4d,{"LENGTH",0,0,3,0,0}},     {0x28,{"CONCAT",0,0,7,0,0}},
        {0x40,{"JUMP",0,1,0,0,0}},       {0x25,{"JUMPBACK",0,1,0,0,0}},
        {0x4b,{"JUMPIF",0,1,1,0,0}},     {0x18,{"JUMPIFNOT",0,1,1,0,0}},
        {0x20,{"JUMPIFEQ",1,1,1,0,0}},   {0x27,{"JUMPIFNOTEQ",1,1,1,0,0}},
        {0x21,{"JUMPIFLT",1,1,1,0,0}},   {0x1c,{"JUMPIFNOTLT",1,1,1,0,0}},
        {0x23,{"JUMPIFLE",1,1,1,0,0}},   {0x33,{"JUMPIFNOTLE",1,1,1,0,0}},
        {0x37,{"JUMPIFEQ2",1,1,1,0,0}},  {0x3a,{"CMPK_A",1,1,1,0,0}},
        {0x34,{"JUMPXEQKB",1,1,1,0,0}},     {0x41,{"CMPK_S",1,1,1,0,0}},
        {0x47,{"FORNPREP",0,1,1,0,0}},   {0x0a,{"FORNLOOP",0,1,1,0,0}},
        {0x30,{"FORGPREP",0,1,1,0,0}},   {0x1b,{"FORGPREP_INEXT",0,1,1,0,0}},
        {0x1e,{"FORGLOOP",1,1,1,0,0}},   {0x0b,{"FORGPREP?",0,1,1,0,0}},
        {0x11,{"PREPVARARGS",0,0,0,0,0}},{0x4c,{"GETVARARGS",0,0,1,0,0}},
        {0x38,{"ADDK",0,0,3,0,0}},       {0x09,{"MULK",0,0,3,0,0}},
        {0x32,{"DIVK",0,0,3,0,0}},       {0x3c,{"MODK",0,0,3,0,0}},
        {0x08,{"POWK",0,0,3,0,0}},       {0x24,{"IDIVK",0,0,3,0,0}},
        {0x3e,{"SUBK",0,0,3,0,0}},       {0x06,{"SUBRK",0,0,5,0,0}},
        {0x3b,{"DIVRK",0,0,5,0,0}},      {0x31,{"ANDK",0,0,3,0,0}},
        {0x2b,{"OR",0,0,7,0,0}},         {0x2f,{"AND",0,0,7,0,0}},
        {0x51,{"ORK",0,0,3,0,0}},    {0x00,{"IDIV",0,0,7,0,0}},
        {0x19,{"FASTCALL1",0,0,0,0,0}},  {0x10,{"FASTCALL",0,0,0,0,0}},
        {0x0c,{"FASTCALL2K",1,0,0,0,0}}, {0x26,{"FASTCALL2",1,0,0,0,0}},
        {0x4a,{"FASTCALLX",1,0,0,0,0}},
    };
    auto it = t.find(op);
    return it == t.end() ? nullptr : &it->second;
}

static int cmd_de_validate(int argc, char** argv) {
    fs::path dir = argv[2];
    long long files=0, protos=0, insns=0;
    long long bad_walk=0, bad_reg=0, bad_const=0, bad_jump=0, unknown_op=0;
    std::map<uint8_t,long long> unk_ops, reg_off, const_off, jump_off;
    auto do_file = [&](const std::string& path) {
        std::string b = read_file(path);
        if (b.size() < 2 || (uint8_t)b[0]!=0x09 || (uint8_t)b[1]!=0x03) return;
        de::Module m; try { m = de::walk(b); } catch (...) { return; }
        ++files;
        for (const de::Proto& p : m.protos) {
            ++protos;
            int maxstack = p.hdr.size()>0 ? (uint8_t)p.hdr[0] : 255;
            int nconsts  = (int)p.consts.size();
            const std::string& code = p.code;
            size_t o=0;
            while (o + 4 <= code.size()) {
                uint32_t w; std::memcpy(&w, code.data()+o, 4);
                uint8_t op=w&0xff, A=(w>>8)&0xff, B=(w>>16)&0xff, C=(w>>24)&0xff;
                uint16_t Bx=(w>>16)&0xffff;
                bool wide = tc::is_de_width8(op);
                uint32_t aux=0; if (wide && o+8<=code.size()) std::memcpy(&aux, code.data()+o+4, 4);
                ++insns;
                const OpInfo* oi = opinfo(op);
                if (!oi) { ++unknown_op; unk_ops[op]++; }
                else {
                    if (((oi->regmask&1)&&A>=maxstack) || ((oi->regmask&2)&&B>=maxstack) ||
                        ((oi->regmask&4)&&C>=maxstack)) { ++bad_reg; reg_off[op]++; }
                    if (oi->auxconst && (int)(aux&0xffff) >= nconsts && !(aux&0x80000000)) { ++bad_const; const_off[op]++; }
                    if (oi->bxconst  && (int)Bx >= nconsts)                                { ++bad_const; const_off[op]++; }
                    if (oi->branch) {
                        int32_t sBx = (int16_t)Bx;
                        long long tgt = (long long)o + 4 + (long long)sBx*4;
                        if (tgt < 0 || tgt > (long long)code.size() || (tgt % 4) != 0) { ++bad_jump; jump_off[op]++; }
                    }
                }
                size_t adv = wide ? 8 : 4;
                if (o + adv > code.size()) break;
                o += adv;
            }
            if (o != code.size()) ++bad_walk;
        }
    };
    if (fs::is_directory(dir)) { for (auto& e : fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    std::printf("== DECODE VALIDATION (bytecode-grounded; no decompiled source involved) ==\n");
    std::printf("files=%lld protos=%lld instructions=%lld\n", files, protos, insns);
    std::printf("  unclean walks        : %lld\n", bad_walk);
    std::printf("  unknown opcodes      : %lld\n", unknown_op);
    std::printf("  register out of range: %lld\n", bad_reg);
    std::printf("  const idx out of range: %lld\n", bad_const);
    std::printf("  bad jump targets     : %lld\n", bad_jump);
    auto dumpmap=[&](const char* t, std::map<uint8_t,long long>& mm){
        if (mm.empty()) return;
        std::printf("  %s:", t);
        for (auto& kv : mm) std::printf(" 0x%02x=%lld", kv.first, kv.second);
        std::printf("\n");
    };
    dumpmap("unknown ops", unk_ops); dumpmap("reg offenders", reg_off);
    dumpmap("const offenders", const_off); dumpmap("jump offenders", jump_off);
    long long tot = bad_walk+unknown_op+bad_reg+bad_const+bad_jump;
    std::printf("\n  VERDICT: %s (%lld violations over %lld instructions)\n",
                tot==0 ? "CLEAN — decode map is self-consistent on ALL real bytecode" : "VIOLATIONS FOUND", tot, insns);
    return tot==0 ? 0 : 1;
}

// ---- M5: INSTRUCTION-LEVEL ROUND-TRIP --------------------------------------------------------
// Stronger than the container round-trip (which keeps `code` as an opaque raw span). Here we fully
// DECODE every instruction, store each branch as a TARGET INSTRUCTION INDEX, then REBUILD the byte
// stream — recomputing every jump offset from that index rather than copying the original Bx. Any
// error in the width table, the op+4 jump base, or the operand model changes the emitted bytes.
// Byte-identical output over the whole corpus proves the instruction model is LOSSLESS, which is
// exactly what the M6 decompiler must rely on.
struct RInsn { uint8_t op,A,B,C; uint16_t Bx; uint32_t aux; bool wide, branch; int target; size_t off; int idx; };

static bool recode_proto(const std::string& code, std::string& out, std::string& why) {
    std::vector<RInsn> ins;
    std::map<size_t,int> off2idx;
    size_t o=0;
    while (o + 4 <= code.size()) {
        uint32_t w; std::memcpy(&w, code.data()+o, 4);
        RInsn r{}; r.op=w&0xff; r.A=(w>>8)&0xff; r.B=(w>>16)&0xff; r.C=(w>>24)&0xff;
        r.Bx=(w>>16)&0xffff; r.off=o; r.wide=tc::is_de_width8(r.op); r.idx=(int)ins.size();
        if (r.wide) { if (o+8>code.size()) { why="truncated aux"; return false; } std::memcpy(&r.aux, code.data()+o+4, 4); }
        const OpInfo* oi = opinfo(r.op);
        r.branch = (oi && oi->branch);
        off2idx[o]=r.idx;
        ins.push_back(r);
        o += r.wide ? 8 : 4;
    }
    if (o != code.size()) { why="unclean walk"; return false; }
    off2idx[code.size()] = (int)ins.size();                        // one-past-the-end is a legal target
    for (auto& r : ins) {                                          // branches -> instruction INDEX
        if (!r.branch) { r.target=-1; continue; }
        long long tb = (long long)r.off + 4 + (long long)(int16_t)r.Bx * 4;
        auto it = (tb < 0) ? off2idx.end() : off2idx.find((size_t)tb);
        if (it == off2idx.end()) { why="branch target off-boundary"; return false; }
        r.target = it->second;
    }
    std::vector<size_t> pos(ins.size()+1); size_t p=0;             // recompute layout
    for (size_t i=0;i<ins.size();++i){ pos[i]=p; p += ins[i].wide?8:4; }
    pos[ins.size()]=p;
    out.clear();
    for (auto& r : ins) {
        uint32_t w;
        if (r.branch) {
            long long d = ((long long)pos[r.target] - ((long long)pos[r.idx] + 4)) / 4;
            w = (uint32_t)r.op | (uint32_t)r.A<<8 | (((uint32_t)(int16_t)d) & 0xffff)<<16;
        } else {
            w = (uint32_t)r.op | (uint32_t)r.A<<8 | (uint32_t)r.B<<16 | (uint32_t)r.C<<24;
        }
        char b[4]; std::memcpy(b,&w,4); out.append(b,4);
        if (r.wide) { char a[4]; std::memcpy(a,&r.aux,4); out.append(a,4); }
    }
    return true;
}

// ---- M6b: CONTROL-FLOW GRAPH -----------------------------------------------------------------
// Build basic blocks from the index-resolved instruction IR (proven lossless in M5). A block starts
// at the entry, at any branch TARGET, and immediately after any branch/terminator. Edges: fallthrough,
// branch-taken, and back-edges (target index <= source index => a loop).
// Self-validating: every edge must land exactly on a block START, and every block must be reachable
// from the entry. A decompiler cannot be built on a graph that fails either property.
static int cmd_de_cfg(int argc, char** argv);
struct Blk { int first, last; std::vector<int> succ; bool reach=false; };

static bool build_cfg(const std::string& code, std::vector<Blk>& blocks, std::string& why) {
    std::vector<RInsn> ins;
    std::map<size_t,int> off2idx;
    size_t o=0;
    while (o + 4 <= code.size()) {
        uint32_t w; std::memcpy(&w, code.data()+o, 4);
        RInsn r{}; r.op=w&0xff; r.A=(w>>8)&0xff; r.B=(w>>16)&0xff; r.C=(w>>24)&0xff;
        r.Bx=(w>>16)&0xffff; r.off=o; r.wide=tc::is_de_width8(r.op); r.idx=(int)ins.size();
        if (r.wide) { if (o+8>code.size()) { why="truncated aux"; return false; } std::memcpy(&r.aux, code.data()+o+4, 4); }
        const OpInfo* oi = opinfo(r.op);
        r.branch = (oi && oi->branch);
        off2idx[o]=r.idx; ins.push_back(r); o += r.wide?8:4;
    }
    if (o != code.size()) { why="unclean walk"; return false; }
    off2idx[code.size()] = (int)ins.size();
    int n = (int)ins.size();
    if (n == 0) { why="empty proto"; return false; }
    for (auto& r : ins) {                                   // resolve branch targets to indices
        if (!r.branch) { r.target=-1; continue; }
        long long tb = (long long)r.off + 4 + (long long)(int16_t)r.Bx * 4;
        auto it = (tb < 0) ? off2idx.end() : off2idx.find((size_t)tb);
        if (it == off2idx.end()) { why="branch target off-boundary"; return false; }
        r.target = it->second;
    }
    // leaders
    std::set<int> lead; lead.insert(0);
    for (auto& r : ins) {
        // RETURN does not fall through, so whatever follows it starts a NEW block. Without this the
        // tail of a mid-block RETURN inherits that block's reachability and dead code is counted live
        // (measured: 501 instructions in 387 protos). Stock Luau emits exactly this in an if/else
        // inside a loop where one arm returns: LOADB/RETURN/JUMP all share one leader.
        if (r.op == 0x29) { if (r.idx + 1 < n) lead.insert(r.idx + 1); continue; }
        // LOADB `C` is a SKIP COUNT: LOADB A B C sets R[A]=B and then skips the next C instructions.
        // It is how Luau compiles a VALUE-producing comparison — `return a < b` becomes
        //   JUMPIFLT -> [true arm];  LOADB R,false,skip 1;  LOADB R,true;  RETURN
        // Unmodelled, the false arm falls straight into the true arm and `R = true` runs
        // unconditionally, so `a < b` decompiles to a constant `true`. It is a real control-flow edge,
        // not a decoding curiosity — both the skip target and the fallthrough must be leaders.
        if (r.op == 0x04 && r.C != 0) {
            if (r.idx + 1 < n) lead.insert(r.idx + 1);
            int tgt = r.idx + 1 + (int)r.C;
            if (tgt < n) lead.insert(tgt);
            continue;
        }
        if (!r.branch) continue;
        if (r.target < n) lead.insert(r.target);
        if (r.idx + 1 < n) lead.insert(r.idx + 1);           // fallthrough of a conditional
    }
    std::vector<int> starts(lead.begin(), lead.end());
    std::map<int,int> start2blk;
    blocks.clear();
    for (size_t i=0;i<starts.size();++i) {
        Blk b; b.first=starts[i]; b.last=(i+1<starts.size()? starts[i+1]-1 : n-1);
        start2blk[b.first]=(int)blocks.size(); blocks.push_back(b);
    }
    bool uncond_jump_only;
    for (size_t bi=0; bi<blocks.size(); ++bi) {
        Blk& b = blocks[bi];
        const RInsn& t = ins[b.last];
        uncond_jump_only = (t.op==0x40 || t.op==0x25);       // JUMP / JUMPBACK: no fallthrough
        if (t.branch) {
            if (t.target <= n) {
                if (t.target == n) { /* jump to end == exit */ }
                else {
                    auto it = start2blk.find(t.target);
                    if (it == start2blk.end()) { why="branch target not a block start"; return false; }
                    b.succ.push_back(it->second);
                }
            }
        }
        bool terminator = (t.op==0x29);                       // RETURN
        if (!uncond_jump_only && !terminator && b.last+1 < n) {
            auto it = start2blk.find(b.last+1);
            if (it == start2blk.end()) { why="fallthrough not a block start"; return false; }
            b.succ.push_back(it->second);
        }
    }
    // reachability from entry
    std::vector<int> stack{0};
    if (!blocks.empty()) blocks[0].reach = true;
    while (!stack.empty()) {
        int b = stack.back(); stack.pop_back();
        for (int s : blocks[b].succ) if (!blocks[s].reach) { blocks[s].reach = true; stack.push_back(s); }
    }
    return true;
}

static int cmd_de_cfg(int argc, char** argv) {
    fs::path dir = argv[2];
    long long files=0, protos=0, okp=0, err=0, blocks=0, edges=0, backedges=0, unreach=0, protos_unreach=0;
    std::map<std::string,long long> reasons;
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        ++files;
        for (const de::Proto& p : m.protos) {
            ++protos;
            std::vector<Blk> bl; std::string why;
            if (!build_cfg(p.code, bl, why)) { ++err; reasons[why]++; continue; }
            ++okp; blocks += (long long)bl.size();
            long long ur=0;
            for (size_t i=0;i<bl.size();++i) {
                edges += (long long)bl[i].succ.size();
                for (int s : bl[i].succ) if (s <= (int)i) ++backedges;
                if (!bl[i].reach) ++ur;
            }
            if (ur) { unreach += ur; ++protos_unreach; }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    std::printf("== CFG CONSTRUCTION (M6b) ==\n");
    std::printf("files=%lld protos=%lld\n", files, protos);
    std::printf("  CFG built cleanly : %lld  (%.4f%%)\n", okp, protos? 100.0*okp/protos : 0.0);
    std::printf("  build errors      : %lld\n", err);
    for (auto& kv : reasons) std::printf("      %-34s %lld\n", kv.first.c_str(), kv.second);
    std::printf("  basic blocks      : %lld  (avg %.1f/proto)\n", blocks, okp? (double)blocks/okp : 0.0);
    std::printf("  edges             : %lld   back-edges (loops): %lld\n", edges, backedges);
    std::printf("  unreachable blocks: %lld  in %lld protos\n", unreach, protos_unreach);
    std::printf("\n  VERDICT: %s\n", (err==0) ? "every proto forms a well-formed CFG"
                                              : "some protos failed CFG construction");
    return err==0 ? 0 : 1;
}

static int cmd_de_recode(int argc, char** argv) {
    fs::path dir = argv[2];
    long long files=0, protos=0, exact=0, diff=0, err=0;
    std::map<std::string,long long> reasons;
    std::vector<std::string> examples;
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        ++files;
        for (size_t pi=0; pi<m.protos.size(); ++pi) {
            ++protos; std::string out, why;
            if (!recode_proto(m.protos[pi].code, out, why)) { ++err; reasons[why]++; continue; }
            if (out == m.protos[pi].code) ++exact;
            else { ++diff; reasons["byte mismatch"]++;
                   if (examples.size()<5) examples.push_back(fs::path(path).filename().string()+" p"+std::to_string(pi)); }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    double pct = protos ? 100.0*exact/protos : 0.0;
    std::printf("== INSTRUCTION-LEVEL ROUND-TRIP (decode -> index-resolved IR -> re-emit) ==\n");
    std::printf("files=%lld protos=%lld\n", files, protos);
    std::printf("  byte-identical : %lld  (%.4f%%)\n", exact, pct);
    std::printf("  byte mismatch  : %lld\n", diff);
    std::printf("  decode errors  : %lld\n", err);
    for (auto& kv : reasons) std::printf("    %-40s %lld\n", kv.first.c_str(), kv.second);
    for (auto& e : examples) std::printf("    e.g. %s\n", e.c_str());
    std::printf("\n  VERDICT: %s\n", (diff==0&&err==0) ? "LOSSLESS — every instruction decodes and re-encodes exactly"
                                                       : "NOT lossless yet");
    return (diff==0&&err==0)?0:1;
}

// ---- M6a: FNV REVERSE TABLE ------------------------------------------------------------------
// tag-1 name constants store only a hash, so method/global names look opaque. But the corpus itself
// contains the plaintext: every .lua_B carries a STRING POOL. Harvest every string from every pool,
// hash each one, and invert the map -> most tag-1 hashes resolve back to a real identifier. This is
// what makes decompiled output readable instead of `obj:__a1cb3c13()`.
static std::vector<std::string> read_pool(const std::string& b) {
    std::vector<std::string> out;
    try {
        size_t o = 2;
        uint64_t n = de::rd_vi(b, o);
        if (n > 200000) return out;
        for (uint64_t i = 0; i < n; ++i) {
            uint64_t ln = de::rd_vi(b, o);
            if (ln > b.size() || o + ln > b.size()) break;
            out.push_back(b.substr(o, (size_t)ln));
            o += (size_t)ln;
        }
    } catch (...) {}
    return out;
}

static int cmd_namebase(int argc, char** argv) {
    fs::path dir = argv[2];
    std::map<uint32_t, std::string> rev;      // hash -> name
    long long premerged = 0;                  // seed from data/namebase_merged.tsv if present
    {   std::string mg = read_file("data/namebase_merged.tsv");
        size_t i = 0;
        while (i < mg.size()) {
            size_t e = mg.find('\n', i); if (e == std::string::npos) e = mg.size();
            size_t t = mg.find('\t', i);
            if (t != std::string::npos && t < e && t - i == 8) {
                uint32_t h = (uint32_t)std::strtoul(mg.substr(i, 8).c_str(), nullptr, 16);
                if (!rev.count(h)) { rev[h] = mg.substr(t + 1, e - t - 1); ++premerged; }
            }
            i = e + 1;
        }
    }
    std::map<uint32_t, int> collide;
    long long strings = 0, files = 0;
    for (const auto& e : fs::directory_iterator(dir)) {
        if (!e.is_regular_file() || e.path().extension() != ".lua_B") continue;
        std::string b = read_file(e.path().string());
        if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) continue;
        ++files;
        for (const std::string& s : read_pool(b)) {
            ++strings;
            uint32_t h = de::de_name_hash(s);
            auto it = rev.find(h);
            if (it == rev.end()) rev[h] = s;
            else if (it->second != s) collide[h]++;
        }
    }
    // how many tag-1 hash constants in the corpus can we now name?
    long long tag1 = 0, resolved = 0;
    std::map<uint32_t,long long> unresolved;
    for (const auto& e : fs::directory_iterator(dir)) {
        if (!e.is_regular_file() || e.path().extension() != ".lua_B") continue;
        std::string b = read_file(e.path().string());
        if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) continue;
        de::Module m; try { m = de::walk(b); } catch (...) { continue; }
        for (const de::Proto& p : m.protos)
            for (const de::Const& c : p.consts)
                if (c.tag == 1 && c.raw.size() >= 4) {
                    uint32_t h; std::memcpy(&h, c.raw.data(), 4);
                    ++tag1;
                    if (rev.count(h)) ++resolved; else unresolved[h]++;
                }
    }
    std::printf("== FNV REVERSE TABLE ==\n  seeded from data/namebase_merged.tsv: %lld entries\n", premerged);
    std::printf("files=%lld  strings harvested=%lld  distinct hashes=%zu  collisions=%zu\n",
                files, strings, rev.size(), collide.size());
    std::printf("tag-1 name constants: %lld   resolved=%lld (%.2f%%)   unresolved-distinct=%zu\n",
                tag1, resolved, tag1 ? 100.0*resolved/tag1 : 0.0, unresolved.size());
    if (argc >= 4) {                                   // optional: write the table out
        std::string out;
        for (auto& kv : rev) { char ln[32]; std::snprintf(ln, sizeof ln, "%08x\t", kv.first); out += ln; out += kv.second; out += "\n"; }
        write_file(argv[3], out);
        std::printf("wrote %zu entries -> %s\n", rev.size(), argv[3]);
    }
    {                                                   // dump the unresolved set as cracker targets
        std::string u;
        for (const auto& kv : unresolved) {
            char bb[16];
            std::snprintf(bb, sizeof bb, "%08x\n", kv.first);
            u += bb;
        }
        write_file("data/unresolved.txt", u);
        std::printf("wrote %zu unresolved hashes -> data/unresolved.txt\n", unresolved.size());
    }
    int shown = 0;
    std::printf("top unresolved hashes:");
    for (auto& kv : unresolved) { if (shown++ >= 8) break; std::printf(" %08x(x%lld)", kv.first, kv.second); }
    std::printf("\n");
    return 0;
}

// ---------------------------------------------------------------------------------------------
// de-unreach  <dir> <out.tsv>   (M6b follow-up, READ-ONLY)
// Reuses build_cfg verbatim, then CLASSIFIES every unreachable block instead of just counting it.
// The question this answers: are the 1090 unreachable blocks (a) benign dead code the DE compiler
// emits, or (b) evidence that our decode map mis-classifies some opcode's control flow?
// The distinguishing signal is the PRECEDING instruction: dead code can only exist after something
// that does not fall through. If an unreachable block follows an op that SHOULD fall through, our
// map is wrong.
// ---------------------------------------------------------------------------------------------
static int cmd_de_unreach(int argc, char** argv) {
    fs::path dir = argv[2];
    std::string outp = (argc >= 4) ? argv[3] : "";
    std::string tsv = "file\tproto\tnblk\tblk\tislast\tninsn\tprev_op\tprev_name\tprev_tgt_rel\t"
                      "first_op\tfirst_name\tlast_op\tlast_name\tnsucc\tfeeds_reachable\tops\n";
    long long protos_unreach=0, ub=0, uinsn=0, roots=0;
    std::map<std::string,long long> root_prev;
    std::string roottsv;
    std::map<std::string,long long> by_prev, by_first, by_shape;
    long long feeds_reachable=0, islands=0, lastblk=0, single=0;
    auto opname=[&](int op)->std::string{ if(op<0) return "-"; const OpInfo* oi=opinfo((uint8_t)op);
        char b[16]; if(oi) return oi->name; std::snprintf(b,sizeof b,"OP_%02X",op); return b; };
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        std::string base = fs::path(path).filename().string();
        for (size_t pi=0; pi<m.protos.size(); ++pi) {
            const de::Proto& p = m.protos[pi];
            std::vector<Blk> bl; std::string why;
            if (!build_cfg(p.code, bl, why)) continue;
            // re-decode so we can name the instructions the CFG was built from
            std::vector<RInsn> ins; size_t o=0;
            while (o+4<=p.code.size()) { uint32_t w; std::memcpy(&w,p.code.data()+o,4);
                RInsn r{}; r.op=w&0xff; r.A=(w>>8)&0xff; r.Bx=(w>>16)&0xffff; r.off=o;
                r.wide=tc::is_de_width8(r.op); r.idx=(int)ins.size();
                const OpInfo* oi=opinfo(r.op); r.branch=(oi&&oi->branch);
                ins.push_back(r); o += r.wide?8:4; }
            // ROOT vs CASCADE: a dead block whose PREDECESSOR IS REACHABLE is a root. Only roots can
            // indict the decode map — a dead block preceded by dead code is just the tail of a region.
            std::map<int,int> ins2blk; for (size_t q=0;q<bl.size();++q) ins2blk[bl[q].first]=(int)q;
            auto blk_of=[&](int insn)->int{ auto it=ins2blk.upper_bound(insn);
                if (it==ins2blk.begin()) return -1;
                --it;
                return it->second;
            };
            bool any=false;
            for (size_t i=0;i<bl.size();++i) {
                if (bl[i].reach) continue;
                int pv = bl[i].first-1;
                int pvb = (pv>=0)? blk_of(pv) : -1;
                bool root = (pvb>=0 && bl[pvb].reach);   // reachable code sits immediately above
                if (root) { ++roots; root_prev[opname(ins[pv].op)]++;
                    char rl[512]; std::snprintf(rl,sizeof rl,"%s\tproto=%zu\tblk=%zu\tprev=%s@%d\tfirst=%s\tn=%d\n",
                        base.c_str(), pi, i, opname(ins[pv].op).c_str(), pv,
                        opname(ins[bl[i].first].op).c_str(), bl[i].last-bl[i].first+1);
                    roottsv += rl; }
                any=true; ++ub;
                const Blk& B = bl[i];
                int n = B.last-B.first+1; uinsn += n;
                int prev = B.first-1;
                int pop = (prev>=0)? (int)ins[prev].op : -1;
                long long ptgt = (prev>=0 && ins[prev].branch)
                    ? (long long)(int16_t)ins[prev].Bx : 0;
                bool fr=false; for (int s : B.succ) if (bl[s].reach) fr=true;
                bool last = (i+1==bl.size());
                if (fr) ++feeds_reachable; else ++islands;
                if (last) ++lastblk;
                if (n==1) ++single;
                std::string ops; for (int k=B.first;k<=B.last && k<B.first+6;++k)
                    { if(!ops.empty()) ops+=","; ops+=opname(ins[k].op); }
                std::string shape = opname(pop) + " -> [" + opname(ins[B.first].op)
                    + (n>1 ? std::string("..")+opname(ins[B.last].op) : std::string("")) + "]";
                by_prev[opname(pop)]++; by_first[opname(ins[B.first].op)]++; by_shape[shape]++;
                char line[1024];
                std::snprintf(line,sizeof line,"%s\t%zu\t%zu\t%zu\t%d\t%d\t%d\t%s\t%lld\t%d\t%s\t%d\t%s\t%zu\t%d\t%s\n",
                    base.c_str(), pi, bl.size(), i, last?1:0, n, pop, opname(pop).c_str(), ptgt,
                    ins[B.first].op, opname(ins[B.first].op).c_str(),
                    ins[B.last].op, opname(ins[B.last].op).c_str(),
                    B.succ.size(), fr?1:0, ops.c_str());
                tsv += line;
            }
            if (any) ++protos_unreach;
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    if (!outp.empty()) { std::ofstream f(outp, std::ios::binary); f << tsv; }
    std::printf("== UNREACHABLE-BLOCK CLASSIFICATION ==\n");
    std::printf("unreachable blocks=%lld  in %lld protos   instructions=%lld\n", ub, protos_unreach, uinsn);
    std::printf("  single-instruction blocks : %lld (%.1f%%)\n", single, ub?100.0*single/ub:0);
    std::printf("  last block in proto       : %lld (%.1f%%)\n", lastblk, ub?100.0*lastblk/ub:0);
    std::printf("  ISLANDS (no reachable succ): %lld    FEEDS REACHABLE CODE: %lld\n", islands, feeds_reachable);
    std::printf("\n  ROOT dead blocks (predecessor is REACHABLE) : %lld\n", roots);
    std::printf("  CASCADE (tail of an already-dead region)   : %lld\n", ub-roots);
    std::printf("\n-- ROOT: op that failed to fall through (ONLY THESE CAN INDICT THE DECODE MAP) --\n");
    { std::vector<std::pair<long long,std::string>> rv;
      for (auto& kv:root_prev) rv.push_back({kv.second,kv.first});
      std::sort(rv.rbegin(),rv.rend());
      for (auto& q:rv) std::printf("  %-16s %lld\n", q.second.c_str(), q.first); }
    if (!outp.empty()) { std::ofstream f2(outp+".roots.tsv", std::ios::binary); f2 << roottsv; }
    std::printf("\n-- preceding instruction (what failed to fall through) --\n");
    std::vector<std::pair<long long,std::string>> v;
    for (auto& kv:by_prev) v.push_back({kv.second,kv.first});
    std::sort(v.rbegin(),v.rend()); for (auto& q:v) std::printf("  %-16s %lld\n", q.second.c_str(), q.first);
    std::printf("\n-- first instruction of the dead block --\n");
    v.clear(); for (auto& kv:by_first) v.push_back({kv.second,kv.first});
    std::sort(v.rbegin(),v.rend()); for (auto& q:v) std::printf("  %-16s %lld\n", q.second.c_str(), q.first);
    std::printf("\n-- top shapes --\n");
    v.clear(); for (auto& kv:by_shape) v.push_back({kv.second,kv.first});
    std::sort(v.rbegin(),v.rend());
    for (size_t i=0;i<v.size() && i<25;++i) std::printf("  %-44s %lld\n", v[i].second.c_str(), v[i].first);
    return 0;
}

// ---------------------------------------------------------------------------------------------
// de-deadaudit <dir>   (READ-ONLY)  — FALSIFICATION TESTS on the "dead code is benign" verdict.
// The verdict rests on: 0x40/0x25 never fall through, and we model every control-flow edge. Each
// test below is designed to BREAK that, not confirm it. A test that finds 0 is a passed falsification.
//   T1  is any block we call dead actually the TARGET of some branch in its own proto?
//   T2  LOADB(0x04) C!=0 and FASTCALL{0x19,0x10,0x0c,0x26,0x4a} C!=0 carry skip-offsets upstream and
//       are branch=0 for us. Do their implied targets land in blocks we called dead? (missing edges)
//   T3  does 0x25 JUMPBACK ever jump FORWARD, or 0x40 JUMP ever have a 0 offset? (decode sanity)
//   T4  does any proto END on 0x40/0x25? (a function cannot fall off the end of an unconditional jump)
//   T5  what are the dead instructions really? full opcode histogram + side-effecting ops + closures.
// ---------------------------------------------------------------------------------------------
static int cmd_de_deadaudit(int argc, char** argv) {
    fs::path dir = argv[2];
    long long t1_targeted=0, t2_loadb=0, t2_fc=0, t2_offbound=0, t2_into_dead=0, t2_loadb_c=0, t2_fc_c=0;
    long long t3_jb_fwd=0, t3_jmp_zero=0, t3_jb_tot=0, t3_jmp_tot=0, t4_endjump=0;
    long long t6_after_ret=0, t6_protos=0; std::string t6_examples;
    std::map<std::string,long long> deadops;
    long long dead_sidefx=0, dead_closure=0, dead_total=0, biggest=0;
    std::string biggest_where, t1_examples, t2_examples, t4_examples, sidefx_examples;
    std::vector<std::pair<int,std::string>> bigblocks;
    auto opname=[&](int op)->std::string{ const OpInfo* oi=opinfo((uint8_t)op);
        char b[16]; if(oi) return oi->name; std::snprintf(b,sizeof b,"OP_%02X",op); return b; };
    auto is_sidefx=[&](uint8_t op){ return op==0x54||op==0x2d||op==0x15||op==0x02||op==0x53||op==0x2a
                                       ||op==0x2e||op==0x3f||op==0x39; };
    auto is_closure=[&](uint8_t op){ return op==0x16||op==0x42; };
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        std::string base = fs::path(path).filename().string();
        for (size_t pi=0; pi<m.protos.size(); ++pi) {
            const de::Proto& p = m.protos[pi];
            std::vector<Blk> bl; std::string why;
            if (!build_cfg(p.code, bl, why)) continue;
            std::vector<RInsn> ins; std::map<size_t,int> off2idx; size_t o=0;
            while (o+4<=p.code.size()) { uint32_t w; std::memcpy(&w,p.code.data()+o,4);
                RInsn r{}; r.op=w&0xff; r.A=(w>>8)&0xff; r.B=(w>>16)&0xff; r.C=(w>>24)&0xff;
                r.Bx=(w>>16)&0xffff; r.off=o; r.wide=tc::is_de_width8(r.op); r.idx=(int)ins.size();
                const OpInfo* oi=opinfo(r.op); r.branch=(oi&&oi->branch);
                off2idx[o]=r.idx; ins.push_back(r); o += r.wide?8:4; }
            off2idx[p.code.size()]=(int)ins.size();
            int n=(int)ins.size(); if(!n) continue;
            // which instruction indexes live in an unreachable block
            std::vector<char> dead(n,0);
            for (auto& B : bl) if (!B.reach) for (int k=B.first;k<=B.last;++k) dead[k]=1;
            bool anydead=false; for (int k=0;k<n;++k) if (dead[k]) anydead=true;
            // T6: build_cfg does not treat RETURN as a leader-maker, so instructions sitting AFTER a
            // RETURN inside an otherwise-live block are dead but counted live. Measure the undercount.
            { bool hit=false;
              for (auto& B : bl) { if (!B.reach) continue;
                for (int k=B.first;k<B.last;++k) if (ins[k].op==0x29) {
                    long long cnt = B.last-k; t6_after_ret += cnt; hit=true;
                    if (t6_examples.size()<900) { char L[220];
                        std::snprintf(L,sizeof L,"        %s p%zu: RETURN@%d then %lld live-marked insn(s) (%s...)\n",
                            base.c_str(),pi,k,cnt,opname(ins[k+1].op).c_str()); t6_examples+=L; }
                    break; } }
              if (hit) ++t6_protos; }

            for (int k=0;k<n;++k) {
                const RInsn& r = ins[k];
                if (r.op==0x25) { ++t3_jb_tot; if ((int16_t)r.Bx >= 0) ++t3_jb_fwd; }
                if (r.op==0x40) { ++t3_jmp_tot; if ((int16_t)r.Bx == 0) ++t3_jmp_zero; }
                // ONLY a branch from LIVE code can indict us. Dead code branching into dead code is
                // just the interior of a dead region — the same cascade contamination that made the
                // raw prev_op histogram look alarming.
                if (dead[k]) continue;
                // T1: every real branch target — does it land inside a dead block?
                if (r.branch) {
                    long long tb=(long long)r.off+4+(long long)(int16_t)r.Bx*4;
                    auto it=(tb<0)?off2idx.end():off2idx.find((size_t)tb);
                    if (it!=off2idx.end() && it->second<n && dead[it->second]) {
                        ++t1_targeted;
                        if (t1_examples.size()<2000) { char L[256];
                            std::snprintf(L,sizeof L,"  %s p%zu: %s@%d -> DEAD insn %d\n",
                                base.c_str(),pi,opname(r.op).c_str(),k,it->second); t1_examples+=L; }
                    }
                }
                // T2: unmodelled skip-offsets
                bool lb = (r.op==0x04), fc = (r.op==0x19||r.op==0x10||r.op==0x0c||r.op==0x26||r.op==0x4a);
                if (lb) ++t2_loadb;
                if (fc) ++t2_fc;
                if ((lb||fc) && r.C!=0) {
                    if (lb) ++t2_loadb_c; else ++t2_fc_c;
                    long long tb=(long long)r.off+4+(long long)r.C*4;
                    auto it=(tb<0)?off2idx.end():off2idx.find((size_t)tb);
                    if (it==off2idx.end()) ++t2_offbound;
                    else if (it->second<n && dead[it->second]) { ++t2_into_dead;
                        if (t2_examples.size()<1500) { char L[256];
                            std::snprintf(L,sizeof L,"  %s p%zu: %s@%d C=%d -> DEAD insn %d\n",
                                base.c_str(),pi,opname(r.op).c_str(),k,r.C,it->second); t2_examples+=L; } }
                }
            }
            // T4: proto ending on an unconditional jump that leaves the function
            if (ins[n-1].op==0x40 || ins[n-1].op==0x25) { ++t4_endjump;
                if (t4_examples.size()<600) { char L[160];
                    std::snprintf(L,sizeof L,"  %s p%zu ends on %s\n",base.c_str(),pi,opname(ins[n-1].op).c_str());
                    t4_examples+=L; } }
            // T5: what the dead code actually is
            if (anydead) for (auto& B : bl) { if (B.reach) continue;
                int sz=B.last-B.first+1;
                if (sz>biggest) { biggest=sz; char L[160];
                    std::snprintf(L,sizeof L,"%s proto=%zu blk insns %d..%d (%d)",base.c_str(),pi,B.first,B.last,sz);
                    biggest_where=L; }
                if (sz>=4) { char L[160]; std::snprintf(L,sizeof L,"%s p%zu insns %d..%d",base.c_str(),pi,B.first,B.last);
                    bigblocks.push_back({sz,L}); }
                for (int k=B.first;k<=B.last;++k) { ++dead_total; deadops[opname(ins[k].op)]++;
                    if (is_sidefx(ins[k].op)) { ++dead_sidefx;
                        if (sidefx_examples.size()<1800) { char L[200];
                            std::snprintf(L,sizeof L,"  %s p%zu insn %d = %s (block %d..%d)\n",
                                base.c_str(),pi,k,opname(ins[k].op).c_str(),B.first,B.last); sidefx_examples+=L; } }
                    if (is_closure(ins[k].op)) ++dead_closure; } }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());

    std::printf("== DEAD-CODE FALSIFICATION AUDIT ==\n\n");
    std::printf("T1  branches landing INSIDE a block we called dead : %lld   %s\n",
        t1_targeted, t1_targeted? "<<< CFG BUG" : "(passed: nothing targets dead code)");
    if (t1_targeted) std::printf("%s", t1_examples.c_str());
    std::printf("\nT2  unmodelled skip-offsets (upstream-Luau semantics)\n");
    std::printf("      LOADB total=%lld  with C!=0 = %lld\n", t2_loadb, t2_loadb_c);
    std::printf("      FASTCALL total=%lld  with C!=0 = %lld\n", t2_fc, t2_fc_c);
    std::printf("      implied targets OFF instruction boundary : %lld  %s\n", t2_offbound,
        t2_offbound? "(encoding assumption suspect)" : "(all land on boundaries)");
    std::printf("      implied targets landing in a DEAD block  : %lld   %s\n", t2_into_dead,
        t2_into_dead? "<<< MISSING EDGES — dead count is WRONG" : "(passed: adds no reachability)");
    if (t2_into_dead) std::printf("%s", t2_examples.c_str());
    std::printf("\nT3  decode sanity\n");
    std::printf("      JUMPBACK 0x25 total=%lld  jumping FORWARD (Bx>=0): %lld  %s\n", t3_jb_tot, t3_jb_fwd,
        t3_jb_fwd? "<<< 0x25 is not purely a back-jump" : "(passed: always backwards)");
    std::printf("      JUMP     0x40 total=%lld  with offset 0     : %lld\n", t3_jmp_tot, t3_jmp_zero);
    std::printf("\nT6  INTRA-BLOCK dead code (insns after a RETURN inside a 'reachable' block).\n"
                "    build_cfg does not split at RETURN, so these are counted reachable but are not:\n");
    std::printf("      instructions after a RETURN inside a live block : %lld  in %lld protos\n",
                t6_after_ret, t6_protos);
    std::printf("      => the 1418 dead-instruction figure is an UNDERCOUNT by this amount\n");
    if (!t6_examples.empty()) std::printf("%s", t6_examples.c_str());
    std::printf("\nT4  protos ENDING on an unconditional jump : %lld  %s\n", t4_endjump,
        t4_endjump? "<<< suspicious" : "(passed: none)");
    if (t4_endjump) std::printf("%s", t4_examples.c_str());
    std::printf("\nT5  what the dead instructions ARE (%lld total)\n", dead_total);
    { std::vector<std::pair<long long,std::string>> v;
      for (auto& kv:deadops) v.push_back({kv.second,kv.first});
      std::sort(v.rbegin(),v.rend());
      for (auto& q:v) std::printf("      %-16s %lld\n", q.second.c_str(), q.first); }
    std::printf("      SIDE-EFFECTING dead instructions : %lld\n", dead_sidefx);
    if (dead_sidefx) std::printf("%s", sidefx_examples.c_str());
    std::printf("      dead NEWCLOSURE/DUPCLOSURE       : %lld\n", dead_closure);
    std::printf("      largest dead block               : %lld insns  @ %s\n", biggest, biggest_where.c_str());
    std::sort(bigblocks.rbegin(), bigblocks.rend());
    std::printf("      dead blocks with >=4 insns       : %d\n", (int)bigblocks.size());
    for (size_t i=0;i<bigblocks.size() && i<12;++i)
        std::printf("        %3d  %s\n", bigblocks[i].first, bigblocks[i].second.c_str());
    return 0;
}

// =============================================================================================
// M6a — ANNOTATED IR.  Every operand resolved: constants materialised, name-hashes looked up,
// import ids expanded to dotted paths, branch offsets turned into instruction indices.
// Operand-class tables below say WHERE each opcode's constant reference lives. Getting these wrong
// is silent corruption, so ir-validate cross-checks every reference against the const table's TAG.
// =============================================================================================
static long long tpl_entries=0, tpl_novalue=0;   // table-template entry stats (de-ktags/ir-validate)
static bool k_in_bx (uint8_t op){ return op==0x4e||op==0x4f||op==0x42; }               // LOADK DUPTABLE DUPCLOSURE
static bool k_in_c  (uint8_t op){ return op==0x51||op==0x38||op==0x3e||op==0x09||op==0x32||      // ADDK SUBK MULK DIVK
                                         op==0x3c||op==0x08||op==0x24||op==0x31; }     // MODK POWK IDIVK ANDK
static bool k_in_b  (uint8_t op){ return op==0x06||op==0x3b; }                          // SUBRK DIVRK
static bool k_aux_str(uint8_t op){ return op==0x3d||op==0x15||op==0x17||op==0x02; }     // GET/SETFIELD GET/SETGLOBAL
static bool k_aux_name(uint8_t op){ return op==0x2d; }                                  // NAMECALL (tag-1 hash)
static bool k_aux_cmp(uint8_t op){ return op==0x20||op==0x41; }   // aux = K index (0x20 number, 0x41 string)
// 0x34 JUMPXEQKB and 0x3a JUMPXEQKNIL carry an IMMEDIATE in aux, not a const index. Proven by
// de-auxhist over the corpus: 0x34 takes exactly two low-aux values {0,1} across 2591 instances
// (a boolean literal), and 0x3a is always 0 across 19571. By contrast 0x20/0x41 spread over 64+
// values with ZERO out-of-range, which is what a real const index looks like.
static bool reg_in_aux(uint8_t op){ return op==0x37||op==0x27||op==0x21||op==0x1c||op==0x23||op==0x33; }

// ---- U44 raw-hash input profile (RESEARCH/U44_RAW_HASH_RECOMPILE_2026-09-29.md) ----------------
// Set only by the *-u44 decompile modes. The input is lowered to U43 canonical opcodes in memory
// (native-name hashes untouched) and names resolve through a U44-seeded namebase, never the U43
// one: a U44 hash that happens to equal an unrelated U43 hash would otherwise render a wrong name
// that recompiles to a different U44 hash. Legacy (U43) modes never set these.
static bool g_input_profile_u44 = false;
// Input-profile routing (de::input_profile_routing_enabled). A U44 entry point that is given a
// module valid ONLY under the U43 opcode numbering decompiles it through its own profile: no opcode
// lowering, names through the namebase under the U43 seed, and the same raw-hash source contract
// (seed declaration + hash-class metadata) with the U43 seed. g_raw_hash_names marks that contract
// independent of the opcode profile; g_source_seed is the seed the source declares.
static bool g_input_profile_routed_u43 = false;
static bool g_raw_hash_names = false;
static uint32_t g_source_seed = de::NAMEHASH_SEED_U44;
// Select the profile of a U44 entry point's input. Must run before the namebase is loaded.
static void select_u44_entry_profile(const std::string& path) {
    g_input_profile_u44 = true;
    g_input_profile_routed_u43 = false;
    g_source_seed = de::NAMEHASH_SEED_U44;
    if (!de::input_profile_routing_enabled()) return;
    try {
        const std::string bytes = read_file(path);
        if (bytes.empty() || !de::is_u43_only_profile(de::walk(bytes))) return;
    } catch (const std::exception&) { return; }   // container errors are reported by the walk later
    g_input_profile_u44 = false;
    g_input_profile_routed_u43 = true;
    g_source_seed = de::NAMEHASH_SEED_2026_06_19;
    std::fprintf(stderr, "input profile: U43-profile bytecode, handled through the U43 profile "
                 "(opcodes U43, name-hash seed %08x)\n", g_source_seed);
}
// (0 = global, 1 = field read) spellings that occur BOTH hashed and string-keyed in one module.
// Their hashed occurrences render with the exact raw suffix so both classes survive the source.
static std::set<std::pair<int, std::string>> g_u44_mixed_names;
static int u44_name_class(uint8_t op) { return (op == 0x17 || op == 0x02) ? 0 : (op == 0x3d ? 1 : -1); }
static std::string raw_hash_alias(const std::string& name, uint32_t hash) {
    uint32_t existing = 0;
    if (de::parse_hash_suffix(name, existing) && existing == hash) return name;
    char suffix[16]; std::snprintf(suffix, sizeof suffix, "__%08x", hash);
    return (ex::is_ident(name) ? name : std::string("Name")) + suffix;
}
// Every decompiler entry point that accepts U44 input reads through here.
// A U44 entry point must not reinterpret a module that is not U44 bytecode. The 44.1.1 cache still
// ships 13 stale U43-profile modules; read with the U44 table their AUX words decode as "opcodes"
// 86/87/90 or as a garbled CFG. Detect the profile structurally (de::profile_walk_problem) and fail
// with the exact reason. RENOVICE_NO_INPUT_PROFILE_CHECK restores the unchecked lowering.
static std::string g_input_profile_failure;
static std::string read_de_input(const std::string& path) {
    g_input_profile_failure.clear();
    std::string bytes = read_file(path);
    if (!g_input_profile_u44 || bytes.empty()) return bytes;
    if (!std::getenv("RENOVICE_NO_INPUT_PROFILE_CHECK")) {
        try {
            const de::Module module = de::walk(bytes);
            const std::string as_u44 = de::profile_walk_problem(module, true);
            if (!as_u44.empty()) {
                const std::string as_u43 = de::profile_walk_problem(module, false);
                g_input_profile_failure = as_u43.empty()
                    ? "input is U43-profile bytecode, not U44 (U44 walk: " + as_u44 + ")"
                    : "input is valid under neither opcode profile (U44 walk: " + as_u44
                      + "; U43 walk: " + as_u43 + ")";
                std::fprintf(stderr, "u44 input profile: %s\n", g_input_profile_failure.c_str());
                return std::string();
            }
        } catch (const std::exception&) {
            // Container errors are reported by the caller's own walk below.
        }
    }
    try { return de::change_build_profile(bytes, false); }
    catch (const std::exception& e) {
        g_input_profile_failure = std::string("u44 input profile: ") + e.what();
        std::fprintf(stderr, "u44 input profile: %s\n", e.what());
        return std::string();
    }
}

static ir::IProto ir_annotate(const de::Proto& p, int pidx,
                              const std::vector<std::string>& pool, const ir::NameBase& nb) {
    ir::IProto ip; ip.index = pidx; ip.kids = p.kids;
    if (p.hdr.size() >= 4) { ip.maxstack=(uint8_t)p.hdr[0]; ip.nparams=(uint8_t)p.hdr[1];
                             ip.nups=(uint8_t)p.hdr[2];    ip.vararg=((uint8_t)p.hdr[3])!=0; }
    for (const de::Const& c : p.consts) ip.consts.push_back(ir::resolve_const(c, pool, nb));
    // second pass: an import path names OTHER consts, so it can only be built once all exist
    for (ir::KVal& k : ip.consts) {
        if (k.kind != ir::KKind::Import) continue;
        int cnt, ix[3]; ir::import_parts(k.import_id, cnt, ix);
        std::string path; bool good = (cnt>=1 && cnt<=3);
        // DE replaced import-path name STRINGS with tag-1 FNV hashes, so a component is either a
        // tag-3 string or a tag-1 name-hash. Both carry their text in .str (hashes resolved via the
        // namebase, falling back to the lossless Name__aabbccdd form).
        for (int q=0; q<cnt && good; ++q) {
            if (ix[q] < 0 || ix[q] >= (int)ip.consts.size()) { good=false; break; }
            const ir::KVal& part = ip.consts[ix[q]];
            if (part.kind != ir::KKind::Str && part.kind != ir::KKind::NameHash) { good=false; break; }
            if (q) path += ".";
            // A namebase entry may be a deliberately mined hash preimage rather than a readable
            // identifier (ChatRedux: DE hash 2898f6ea -> "899c4c"). Rendering that as a global
            // forces expr.h to use _G["899c4c"], which recompiles as GETIMPORT _G + GETFIELD and
            // destroys the original one-part GETIMPORT representation. The transcoder already
            // recognizes Name__<8 hex> and restores its exact DE hash, so use that lossless source
            // alias for invalid NAME-HASH import components. Do not rewrite tag-3 strings: those are
            // literal names and do not carry a recoverable DE hash payload.
            if (!std::getenv("RENOVICE_ALLOW_INVALID_IMPORT_PREIMAGE")
                && part.kind == ir::KKind::NameHash && !ex::is_ident(part.str)) {
                char alias[32]; std::snprintf(alias, sizeof alias, "Name__%08x", part.hash);
                path += alias;
            } else {
                path += part.str;
            }
        }
        if (good) { k.text = path; k.str = path; }
        else { k.resolved=false; char b[48]; std::snprintf(b,sizeof b,"<import %08x?>",k.import_id); k.text=b; }
    }
    // TABLE TEMPLATES also name other consts, so they expand in the same second pass.
    // A tag-8 entry is (key const index, 4-byte payload). The payload is the VALUE's const index —
    // which means a template gives us a genuine VALUE POSITION, so an overloaded tag-1 boolean in a
    // table constructor can be disambiguated exactly like one in LOADK. Without this, `{on = true}`
    // would reconstruct as `{on = Name__00000001}` — a nil global read instead of true.
    for (ir::KVal& k : ip.consts) {
        if (k.kind != ir::KKind::TableTpl) continue;
        auto kname = [&](uint64_t ki) -> std::string {
            if (ki >= ip.consts.size()) return "<?>";
            const ir::KVal& e = ip.consts[(size_t)ki];
            return (e.kind==ir::KKind::Str || e.kind==ir::KKind::NameHash) ? e.str : e.text; };
        std::string body; bool bad=false;
        if (!k.tpl_keys.empty()) {                                   // tag 5: keys only
            for (size_t q=0;q<k.tpl_keys.size();++q) {
                if (k.tpl_keys[q] >= ip.consts.size()) { bad=true; break; }
                if (q) body += ", ";
                // A keys-only template PRE-ALLOCATES these keys; the values are assigned later by
                // SETFIELD. Emitting the bare key made it an ARRAY ELEMENT reading a GLOBAL of that
                // name — `{ x, y }` reads globals x,y into slots 1,2 instead of declaring keys x,y.
                // Wrong value AND wrong shape, and it compiles, so every gate stayed green.
                body += kname(k.tpl_keys[q]) + " = nil";
            }
        } else if (!k.tpl_items.empty()) {                           // tag 8: key = value
            for (size_t q=0;q<k.tpl_items.size();++q) {
                uint64_t ki = k.tpl_items[q].first; uint32_t vi = k.tpl_items[q].second;
                if (ki >= ip.consts.size()) { bad=true; break; }
                if (q) body += ", ";
                // 0xFFFFFFFF = NO constant value: DUPTABLE pre-allocates the key and the value is
                // assigned at runtime by a following SETFIELD. Any OTHER out-of-range payload would
                // mean we have the entry layout wrong, so it is flagged rather than rendered.
                if (vi == 0xFFFFFFFFu) { body += kname(ki) + " = nil"; ++tpl_novalue; }
                else if (vi < ip.consts.size()) { body += kname(ki) + " = " + ir::value_text(ip.consts[vi]); }
                else { body += kname(ki) + " = <BAD k#" + std::to_string(vi) + ">"; bad = true; }
                ++tpl_entries;
            }
        }
        if (bad) { k.resolved = false; k.text = "<table tpl BAD KEY INDEX>"; }
        else if (!body.empty()) k.text = "{ " + body + " }";
    }
    // decode
    std::map<size_t,int> off2idx; size_t o=0;
    while (o+4 <= p.code.size()) {
        uint32_t w; std::memcpy(&w, p.code.data()+o, 4);
        ir::IInsn in; in.idx=(int)ip.code.size(); in.off=o;
        in.op=w&0xff; in.A=(w>>8)&0xff; in.B=(w>>16)&0xff; in.C=(w>>24)&0xff; in.Bx=(w>>16)&0xffff;
        in.wide = tc::is_de_width8(in.op);
        if (in.wide) { if (o+8>p.code.size()) { ip.ok=false; ip.why="truncated aux"; return ip; }
                       std::memcpy(&in.aux, p.code.data()+o+4, 4); }
        const OpInfo* oi = opinfo(in.op);
        in.name = oi ? oi->name : "OP_??"; in.branch = (oi && oi->branch);
        if (!oi) { in.annotated=false; in.unresolved="unknown opcode"; }
        off2idx[o]=in.idx; ip.code.push_back(in); o += in.wide?8:4;
    }
    if (o != p.code.size()) { ip.ok=false; ip.why="unclean walk"; return ip; }
    off2idx[p.code.size()] = (int)ip.code.size();
    const int nk = (int)ip.consts.size();
    auto kindname = [](ir::KKind k) -> const char* {
        switch (k) { case ir::KKind::Nil: return "nil"; case ir::KKind::NameHash: return "namehash";
                     case ir::KKind::Number: return "number"; case ir::KKind::Str: return "string";
                     case ir::KKind::Import: return "import"; case ir::KKind::TableTpl: return "tabletpl";
                     case ir::KKind::Closure: return "closure"; case ir::KKind::Vector: return "vector";
                     case ir::KKind::Int64: return "int64"; default: return "unknown"; } };
    auto kref = [&](ir::IInsn& in, int ki, const char* want) -> const ir::KVal* {
        if (ki < 0 || ki >= nk) { in.annotated=false;
            in.unresolved = std::string("const index out of range in ") + in.name; return nullptr; }
        const ir::KVal& k = ip.consts[ki];
        if (!k.resolved) { in.annotated=false; in.unresolved="unresolved const"; }
        // TAG CHECK. A field key and a NAMECALL key must carry TEXT — either a tag-3 string or a
        // tag-1 FNV name-hash (DE substitutes hashes for many name strings). Anything else means our
        // operand-class table points at the wrong field, which is silent corruption, so name the
        // actual kind rather than bucketing it.
        if (want && (k.kind != ir::KKind::Str && k.kind != ir::KKind::NameHash)) {
            in.annotated=false;
            in.unresolved = std::string(in.name) + ": key const is " + kindname(k.kind) + ", not text";
        }
        return &k;
    };
    // annotate
    for (ir::IInsn& in : ip.code) {
        if (in.branch) {
            long long tb = (long long)in.off + 4 + (long long)(int16_t)in.Bx * 4;
            auto it = (tb<0) ? off2idx.end() : off2idx.find((size_t)tb);
            if (it == off2idx.end()) { in.annotated=false; in.unresolved="branch target off-boundary"; }
            else in.target = it->second;
        }
        char buf[512];
        if (in.op==0x46) {                                        // GETIMPORT: Bx -> tag-4 import const
            const ir::KVal* k = kref(in, in.Bx, nullptr);
            if (k && k->kind != ir::KKind::Import) { in.annotated=false; in.unresolved="expected import const"; }
            in.note = k ? k->text : "";
            std::snprintf(buf,sizeof buf,"R%d <- %s", in.A, in.note.c_str());
        } else if (k_aux_name(in.op)) {                            // NAMECALL
            const ir::KVal* k = kref(in, (int)(in.aux & 0xffff), "name");
            in.note = k ? k->str : "";
            if ((g_input_profile_u44 || g_raw_hash_names) && k && k->kind == ir::KKind::NameHash
                && !ex::is_ident(in.note))
                in.note = raw_hash_alias(in.note, k->hash);
            std::snprintf(buf,sizeof buf,"R%d R%d :%s", in.A, in.B, in.note.c_str());
        } else if (k_aux_str(in.op)) {                              // GET/SETFIELD, GET/SETGLOBAL
            const ir::KVal* k = kref(in, (int)(in.aux & 0xffff), "str");
            in.note = k ? k->str : "";
            if ((g_input_profile_u44 || g_raw_hash_names) && k && k->kind == ir::KKind::NameHash) {
                const int name_class = u44_name_class(in.op);
                if (!ex::is_ident(in.note)
                    || (name_class >= 0 && g_u44_mixed_names.count({name_class, in.note})))
                    in.note = raw_hash_alias(in.note, k->hash);
            }
            if (in.op==0x3d)      std::snprintf(buf,sizeof buf,"R%d <- R%d.%s", in.A, in.B, in.note.c_str());
            else if (in.op==0x15) std::snprintf(buf,sizeof buf,"R%d.%s <- R%d", in.B, in.note.c_str(), in.A);
            else if (in.op==0x17) std::snprintf(buf,sizeof buf,"R%d <- _ENV.%s", in.A, in.note.c_str());
            else                  std::snprintf(buf,sizeof buf,"_ENV.%s <- R%d", in.note.c_str(), in.A);
        // VALUE positions: route through value_text so an overloaded tag-1 boolean renders as
        // true/false rather than as the bogus name Name__00000001. See ir.h.
        } else if (in.op==0x16) {                                   // NEWCLOSURE: Bx is a CHILD-LIST index
            if ((size_t)in.Bx >= ip.kids.size()) {
                in.annotated = false;
                in.unresolved = "NEWCLOSURE child index out of range";
                std::snprintf(buf,sizeof buf,"R%d <- closure(child[%d] -> OOB; children=%zu)",
                              in.A, (int)in.Bx, ip.kids.size());
            } else {
                std::snprintf(buf,sizeof buf,"R%d <- closure(child[%d] -> proto[%u])",
                              in.A, (int)in.Bx, ip.kids[(size_t)in.Bx]);
            }
        } else if (in.op==0x42) {                                   // DUPCLOSURE: Bx is a CLOSURE-CONST index
            const ir::KVal* k = kref(in, in.Bx, nullptr);
            if (k && k->kind != ir::KKind::Closure) {
                in.annotated = false;
                in.unresolved = "DUPCLOSURE const is not a closure";
            }
            if (k && k->kind == ir::KKind::Closure) {
                std::snprintf(buf,sizeof buf,"R%d <- closure(const[%d] -> proto[%llu])",
                              in.A, (int)in.Bx, (unsigned long long)k->sub);
            } else {
                std::snprintf(buf,sizeof buf,"R%d <- closure(const[%d] -> INVALID)",
                              in.A, (int)in.Bx);
            }
        } else if (k_in_bx(in.op)) {                                // LOADK / DUPTABLE
            const ir::KVal* k = kref(in, in.Bx, nullptr);
            in.note = k ? ir::value_text(*k) : "";
            std::snprintf(buf,sizeof buf,"R%d <- %s", in.A, in.note.c_str());
        } else if (k_in_c(in.op)) {                                 // arithmetic / ANDK with a constant
            const ir::KVal* k = kref(in, in.C, nullptr);
            in.note = k ? ir::value_text(*k) : "";
            std::snprintf(buf,sizeof buf,"R%d <- R%d %s %s", in.A, in.B, in.name.c_str(), in.note.c_str());
        } else if (k_in_b(in.op)) {                                 // SUBRK / DIVRK (const on the left)
            const ir::KVal* k = kref(in, in.B, nullptr);
            in.note = k ? ir::value_text(*k) : "";
            std::snprintf(buf,sizeof buf,"R%d <- %s %s R%d", in.A, in.note.c_str(), in.name.c_str(), in.C);
        } else if (k_aux_cmp(in.op)) {
            const ir::KVal* k = kref(in, (int)(in.aux & 0x7fffffff), nullptr);
            in.note = k ? k->text : "";
            std::snprintf(buf,sizeof buf,"R%d %s %s -> [%d]", in.A,
                (in.aux & 0x80000000u) ? "~=" : "==", in.note.c_str(), in.target);
        } else if (in.op==0x3a) {                                   // JUMPXEQKNIL: aux is polarity only
            if ((in.aux & 0x7fffffffu) != 0) { in.annotated=false; in.unresolved="nil-compare aux carries a payload"; }
            std::snprintf(buf,sizeof buf,"R%d %s nil -> [%d]", in.A,
                (in.aux & 0x80000000u) ? "~=" : "==", in.target);
        } else if (in.op==0x34) {                                   // JUMPXEQKB: aux low bit IS the boolean
            uint32_t lo = in.aux & 0x7fffffffu;
            if (lo > 1) { in.annotated=false; in.unresolved="boolean-compare aux is not 0 or 1"; }
            std::snprintf(buf,sizeof buf,"R%d %s %s -> [%d]", in.A,
                (in.aux & 0x80000000u) ? "~=" : "==", lo ? "true" : "false", in.target);
        } else if (reg_in_aux(in.op)) {
            if ((int)in.aux >= ip.maxstack) { in.annotated=false; in.unresolved="aux register past maxstack"; }
            std::snprintf(buf,sizeof buf,"R%d %s R%u -> [%d]", in.A, in.name.c_str(), in.aux, in.target);
        } else if (in.branch) {
            std::snprintf(buf,sizeof buf,"%s-> [%d]", in.op==0x40||in.op==0x25?"":"R%d ", in.target);
            if (in.op!=0x40 && in.op!=0x25) std::snprintf(buf,sizeof buf,"R%d -> [%d]", in.A, in.target);
            else                            std::snprintf(buf,sizeof buf,"-> [%d]", in.target);
        } else if (in.op==0x54) { std::snprintf(buf,sizeof buf,"R%d nargs=%d nres=%d", in.A, (int)in.B-1, (int)in.C-1);
        } else if (in.op==0x29) { std::snprintf(buf,sizeof buf,"R%d nret=%d", in.A, (int)in.B-1);
        } else if (in.op==0x14) { std::snprintf(buf,sizeof buf,"R%d <- R%d", in.A, in.B);
        } else if (in.op==0x12) { std::snprintf(buf,sizeof buf,"R%d <- %d", in.A, (int)(int16_t)in.Bx);
        } else if (in.op==0x13) { std::snprintf(buf,sizeof buf,"R%d <- U%d", in.A, in.B);
        } else if (in.op==0x53) { std::snprintf(buf,sizeof buf,"U%d <- R%d", in.B, in.A);
        } else                  { std::snprintf(buf,sizeof buf,"A=%d B=%d C=%d", in.A, in.B, in.C); }
        in.text = buf;
    }
    return ip;
}

static ir::NameBase g_nb;
// U44 namebase: every namebase entry is a verified U43 preimage (FNV(name, 7e5af8e9) == hash for
// all rows), so the NAME is build-independent and its U44 hash is FNV(name, 768e5ed0). A U44 hash
// reached by two different names is ambiguous and stays raw. A name that itself parses as a raw
// `X__aabbccdd` spelling would recompile as that suffix rather than its own hash, so it stays raw.
static long long g_u44_namebase_ambiguous = 0, g_u44_namebase_suffix_skipped = 0;
static void ir_load_seeded_namebase(const std::string& tsv, uint32_t seed) {
    std::unordered_map<uint32_t, std::string> names;
    std::set<uint32_t> ambiguous;
    size_t i = 0;
    while (i < tsv.size()) {
        size_t e = tsv.find('\n', i);
        if (e == std::string::npos) e = tsv.size();
        size_t line_end = e;
        while (line_end > i && tsv[line_end - 1] == '\r') --line_end;
        const size_t tab = tsv.find('\t', i);
        if (tab != std::string::npos && tab < line_end) {
            const std::string name = tsv.substr(tab + 1, line_end - tab - 1);
            uint32_t suffix = 0;
            if (de::parse_hash_suffix(name, suffix)) ++g_u44_namebase_suffix_skipped;
            else {
                const uint32_t hash = de::de_name_hash(name, seed);
                auto inserted = names.emplace(hash, name);
                if (!inserted.second && inserted.first->second != name) ambiguous.insert(hash);
            }
        }
        i = e + 1;
    }
    for (uint32_t hash : ambiguous) names.erase(hash);
    g_u44_namebase_ambiguous = (long long)ambiguous.size();
    g_nb.m = std::move(names);
    g_nb.entries = (long long)g_nb.m.size();
    g_nb.loaded = true;
}

static void ir_load_namebase() {
    if (g_nb.loaded) return;
    std::string t = read_file(exe_dir() + "\\..\\data\\namebase_merged.tsv");
    if (t.empty()) t = read_file("data/namebase_merged.tsv");
    if (g_input_profile_u44) { ir_load_seeded_namebase(t, de::NAMEHASH_SEED_U44); return; }
    // A routed U43 module uses the same raw-hash contract under its own seed.
    if (g_input_profile_routed_u43) { ir_load_seeded_namebase(t, de::NAMEHASH_SEED_2026_06_19); return; }
    g_nb.load(t);
}

static int cmd_ir(int argc, char** argv) {
    ir_load_namebase();
    std::string b = read_de_input(argv[2]);
    de::Module m; try { m = de::walk(b); } catch (const std::exception& e) {
        std::fprintf(stderr, "walk error: %s\n", e.what()); return 1; }
    std::vector<std::string> pool = ir::parse_pool(b);
    int only = (argc >= 4) ? std::atoi(argv[3]) : -1;
    std::printf("namebase=%lld entries   string pool=%zu   protos=%zu\n", g_nb.entries, pool.size(), m.protos.size());
    if (g_input_profile_u44)
        std::printf("u44 namebase: ambiguous hashes left raw=%lld, suffix-shaped names left raw=%lld\n",
                    g_u44_namebase_ambiguous, g_u44_namebase_suffix_skipped);
    for (size_t i = 0; i < m.protos.size(); ++i) {
        if (only >= 0 && (int)i != only) continue;
        ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
        std::printf("\n== proto[%d] maxstack=%d nparams=%d nups=%d vararg=%d insns=%zu consts=%zu ==\n",
                    ip.index, ip.maxstack, ip.nparams, ip.nups, ip.vararg?1:0, ip.code.size(), ip.consts.size());
        if (!ip.ok) { std::printf("  DECODE FAILED: %s\n", ip.why.c_str()); continue; }
        for (size_t q = 0; q < ip.consts.size(); ++q)
            std::printf("   k[%zu] %s\n", q, ip.consts[q].text.c_str());
        for (const ir::IInsn& in : ip.code)
            std::printf("  [%4d] %-14s %-52s%s\n", in.idx, in.name.c_str(), in.text.c_str(),
                        in.annotated ? "" : ("   <<< " + in.unresolved).c_str());
    }
    return 0;
}

static int cmd_closure_index_selftest() {
    int checks = 0;
    int failures = 0;
    auto check = [&](bool condition, const char* label) {
        ++checks;
        if (condition) std::printf("PASS %s\n", label);
        else { ++failures; std::fprintf(stderr, "FAIL %s\n", label); }
    };
    auto make_proto = [](uint8_t op, uint8_t a, uint16_t bx) {
        de::Proto p;
        p.hdr.assign({(char)8, (char)0, (char)0, (char)0});
        const uint32_t word = (uint32_t)op | ((uint32_t)a << 8) | ((uint32_t)bx << 16);
        p.code.resize(sizeof word);
        std::memcpy(p.code.data(), &word, sizeof word);
        return p;
    };
    const std::vector<std::string> pool;
    const ir::NameBase names;

    de::Proto fresh = make_proto(0x16, 3, 1);
    fresh.kids = {7, 42};
    ir::IProto fresh_ir = ir_annotate(fresh, 100, pool, names);
    check(fresh_ir.code.size() == 1 && fresh_ir.code[0].annotated,
          "NEWCLOSURE valid child index accepted");
    check(fresh_ir.code.size() == 1
          && fresh_ir.code[0].text == "R3 <- closure(child[1] -> proto[42])",
          "NEWCLOSURE labels child index and resolved global prototype separately");

    de::Proto oob = make_proto(0x16, 2, 2);
    oob.kids = {9, 10};
    ir::IProto oob_ir = ir_annotate(oob, 101, pool, names);
    check(oob_ir.code.size() == 1 && !oob_ir.code[0].annotated
          && oob_ir.code[0].unresolved == "NEWCLOSURE child index out of range",
          "NEWCLOSURE out-of-range child index fails closed");
    check(oob_ir.code.size() == 1
          && oob_ir.code[0].text == "R2 <- closure(child[2] -> OOB; children=2)",
          "NEWCLOSURE out-of-range diagnostic preserves operand and child count");

    de::Proto duplicate = make_proto(0x42, 4, 0);
    de::Const closure_constant;
    closure_constant.tag = 6;
    closure_constant.idx = 99;
    duplicate.consts.push_back(closure_constant);
    ir::IProto duplicate_ir = ir_annotate(duplicate, 102, pool, names);
    check(duplicate_ir.code.size() == 1 && duplicate_ir.code[0].annotated,
          "DUPCLOSURE valid closure constant accepted");
    check(duplicate_ir.code.size() == 1
          && duplicate_ir.code[0].text == "R4 <- closure(const[0] -> proto[99])",
          "DUPCLOSURE labels constant index and resolved global prototype separately");

    de::Proto invalid_duplicate = make_proto(0x42, 5, 0);
    de::Const number_constant;
    number_constant.tag = 2;
    number_constant.raw.assign(8, '\0');
    invalid_duplicate.consts.push_back(number_constant);
    ir::IProto invalid_duplicate_ir = ir_annotate(invalid_duplicate, 103, pool, names);
    check(invalid_duplicate_ir.code.size() == 1 && !invalid_duplicate_ir.code[0].annotated
          && invalid_duplicate_ir.code[0].unresolved == "DUPCLOSURE const is not a closure",
          "DUPCLOSURE wrong constant type fails closed");

    std::printf("CLOSURE INDEX SELFTEST %s checks=%d failures=%d\n",
                failures == 0 ? "PASS" : "FAIL", checks, failures);
    return failures == 0 ? 0 : 1;
}

// The M6a acceptance metric: annotate every instruction in the corpus, count what does not resolve.
static int cmd_ir_validate(int argc, char** argv) {
    ir_load_namebase();
    fs::path dir = argv[2];
    long long files=0, protos=0, insns=0, bad=0, badproto=0, kconsts=0, kunres=0;
    long long names=0, names_real=0, imports=0, imports_ok=0;
    std::map<std::string,long long> reasons;
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        std::vector<std::string> pool = ir::parse_pool(b);
        ++files;
        for (size_t i=0;i<m.protos.size();++i) {
            ir::IProto ip = ir_annotate(m.protos[i], (int)i, pool, g_nb);
            ++protos;
            if (!ip.ok) { ++badproto; reasons[ip.why]++; continue; }
            for (const ir::KVal& k : ip.consts) { ++kconsts; if (!k.resolved) ++kunres;
                if (k.kind==ir::KKind::NameHash) { ++names; if (k.str.compare(0,6,"Name__")!=0) ++names_real; }
                if (k.kind==ir::KKind::Import)   { ++imports; if (k.resolved) ++imports_ok; } }
            for (const ir::IInsn& in : ip.code) { ++insns; if (!in.annotated) { ++bad; reasons[in.unresolved]++; } }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    std::printf("== M6a ANNOTATED-IR VALIDATION ==\n");
    std::printf("namebase entries loaded : %lld\n", g_nb.entries);
    std::printf("files=%lld protos=%lld instructions=%lld\n", files, protos, insns);
    std::printf("  protos that failed to decode : %lld\n", badproto);
    std::printf("  instructions fully annotated : %lld  (%.4f%%)\n", insns-bad, insns? 100.0*(insns-bad)/insns : 0.0);
    std::printf("  instructions with an unresolved operand : %lld\n", bad);
    for (auto& kv : reasons) std::printf("      %-38s %lld\n", kv.first.c_str(), kv.second);
    std::printf("\n  constants resolved : %lld / %lld  (%.4f%%)\n", kconsts-kunres, kconsts,
                kconsts? 100.0*(kconsts-kunres)/kconsts : 0.0);
    std::printf("  import paths expanded : %lld / %lld  (%.4f%%)\n", imports_ok, imports,
                imports? 100.0*imports_ok/imports : 0.0);
    std::printf("  name-hashes with a REAL recovered name : %lld / %lld  (%.2f%%)\n", names_real, names,
                names? 100.0*names_real/names : 0.0);
    std::printf("      (the rest render as Name__aabbccdd, which round-trips losslessly)\n");
    std::printf("\n  table-template entries expanded : %lld\n", tpl_entries);
    std::printf("      of which NO const value (0xFFFFFFFF sentinel, assigned at runtime) : %lld\n", tpl_novalue);
    std::printf("      any OTHER out-of-range payload marks its const unresolved, so the 100%%\n");
    std::printf("      constant-resolution rate above is what proves 0xFFFFFFFF is the only sentinel\n");
    std::printf("\n  VERDICT: %s\n", (bad==0 && badproto==0)
        ? "every instruction in the corpus annotates with no unresolved operand"
        : "some operands did not resolve — see the breakdown above");
    return (bad==0 && badproto==0) ? 0 : 1;
}

// de-auxhist <dir> <op>  — histogram the aux payload of one opcode across the corpus.
// Discriminates "aux is a CONST INDEX" (values spread 0..nconsts) from "aux is an IMMEDIATE"
// (values confined to a tiny set). Also reports how often aux exceeds the proto's const count,
// which a const index can never legitimately do.
static int cmd_de_auxhist(int argc, char** argv) {
    fs::path dir = argv[2];
    uint8_t want = (uint8_t)std::strtol(argv[3], nullptr, 0);
    std::map<uint32_t,long long> hist; long long tot=0, oob=0, hi=0;
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        for (const de::Proto& p : m.protos) {
            int nk=(int)p.consts.size(); size_t o=0;
            while (o+4<=p.code.size()) {
                uint32_t w; std::memcpy(&w,p.code.data()+o,4);
                uint8_t op=w&0xff; bool wide=tc::is_de_width8(op);
                uint32_t aux=0; if (wide && o+8<=p.code.size()) std::memcpy(&aux,p.code.data()+o+4,4);
                if (op==want && wide) { ++tot; uint32_t lo=aux&0x7fffffffu;
                    if (aux&0x80000000u) ++hi;
                    if ((int)lo >= nk) ++oob;
                    if (hist.size()<64 || hist.count(lo)) hist[lo]++; }
                o += wide?8:4;
            }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    std::printf("op 0x%02x : %lld instances   bit31 set: %lld   (aux&0x7fffffff) >= nconsts: %lld\n",
                want, tot, hi, oob);
    std::printf("distinct low-aux values seen (capped at 64): %zu\n", hist.size());
    std::vector<std::pair<long long,uint32_t>> v;
    for (auto& kv:hist) v.push_back({kv.second,kv.first});
    std::sort(v.rbegin(),v.rend());
    for (size_t i=0;i<v.size() && i<20;++i) std::printf("    aux_lo=%-6u %lld\n", v[i].second, v[i].first);
    return 0;
}

// =============================================================================================
// de-fieldaudit <dir>  — GENERALISATION OF THE 0x34 BUG.
//
// Structural checks (round-trip, recode, de-validate) cannot catch a field being INTERPRETED wrongly,
// because a bogus const index is still a valid index. This sweeps EVERY (opcode, field) pair, derives
// what the field empirically looks like from its value distribution, and compares that against what
// our decode model CLAIMS it is. Disagreements are printed as suspects.
//
// Discriminators, per field:
//   %>=maxstack  a register can never exceed the proto's stack size
//   %>=nconsts   a const index can never exceed the proto's const count   <- this is what caught 0x34
//   distinct     an immediate is confined to a tiny set; an index spreads
// =============================================================================================
struct FStat {
    long long n=0, oob_reg=0, oob_k=0; uint32_t maxv=0;
    std::set<uint32_t> vals;                        // capped
    void add(uint32_t v, int mx, int nk) {
        ++n; if (v>maxv) maxv=v;
        if ((int)v >= mx) ++oob_reg;
        if ((int)v >= nk) ++oob_k;
        if (vals.size() < 400) vals.insert(v);
    }
};
static int cmd_de_fieldaudit(int argc, char** argv) {
    fs::path dir = argv[2];
    std::map<uint8_t, std::map<std::string, FStat>> st;
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        for (const de::Proto& p : m.protos) {
            int mx = p.hdr.size()>0 ? (uint8_t)p.hdr[0] : 255;
            int nk = (int)p.consts.size(); size_t o=0;
            while (o+4<=p.code.size()) {
                uint32_t w; std::memcpy(&w,p.code.data()+o,4);
                uint8_t op=w&0xff, A=(w>>8)&0xff, B=(w>>16)&0xff, C=(w>>24)&0xff;
                uint16_t Bx=(w>>16)&0xffff;
                bool wide=tc::is_de_width8(op);
                auto& s = st[op];
                s["A"].add(A,mx,nk); s["B"].add(B,mx,nk); s["C"].add(C,mx,nk); s["Bx"].add(Bx,mx,nk);
                if (wide && o+8<=p.code.size()) { uint32_t aux; std::memcpy(&aux,p.code.data()+o+4,4);
                    s["aux"].add(aux & 0x7fffffffu, mx, nk); }
                o += wide?8:4;
            }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());

    // what our model claims about each field
    auto claims_reg = [](uint8_t op, const std::string& f)->bool{
        const OpInfo* oi=opinfo(op); if(!oi) return false;
        if (f=="A") return (oi->regmask&1)!=0;
        if (f=="B") return (oi->regmask&2)!=0;
        if (f=="C") return (oi->regmask&4)!=0;
        return false; };
    auto claims_k = [](uint8_t op, const std::string& f)->bool{
        if (f=="Bx")  return k_in_bx(op);
        if (f=="C")   return k_in_c(op);
        if (f=="B")   return k_in_b(op);
        if (f=="aux") return k_aux_str(op)||k_aux_name(op)||k_aux_cmp(op);
        return false; };

    std::printf("== FIELD-SEMANTICS AUDIT (does each field behave like what we claim it is?) ==\n\n");
    std::vector<std::string> suspects;
    for (auto& [op, fields] : st) {
        const OpInfo* oi = opinfo(op);
        std::printf("op 0x%02x %-16s\n", op, oi?oi->name:"OP_??");
        for (const char* fn : {"A","B","C","Bx","aux"}) {
            auto it = fields.find(fn); if (it==fields.end() || !it->second.n) continue;
            FStat& s = it->second; std::string f = fn;
            bool cr = claims_reg(op,f), ck = claims_k(op,f);
            const char* model = cr ? "REG" : (ck ? "K-IDX" : "-");
            std::printf("    %-3s n=%-9lld distinct=%-4zu max=%-6u  >=maxstack %6.2f%%  >=nconsts %6.2f%%   model=%s\n",
                fn, s.n, s.vals.size(), s.maxv,
                100.0*s.oob_reg/s.n, 100.0*s.oob_k/s.n, model);
            char msg[300];
            if (cr && s.oob_reg) {
                std::snprintf(msg,sizeof msg,"0x%02x %s field %s: model says REGISTER but %.2f%% exceed maxstack",
                    op, oi?oi->name:"?", fn, 100.0*s.oob_reg/s.n); suspects.push_back(msg); }
            if (ck && s.oob_k) {
                std::snprintf(msg,sizeof msg,"0x%02x %s field %s: model says CONST INDEX but %lld (%.2f%%) exceed nconsts",
                    op, oi?oi->name:"?", fn, s.oob_k, 100.0*s.oob_k/s.n); suspects.push_back(msg); }
            if (ck && s.vals.size() <= 4) {
                std::snprintf(msg,sizeof msg,"0x%02x %s field %s: model says CONST INDEX but only %zu distinct values -> looks like an IMMEDIATE",
                    op, oi?oi->name:"?", fn, s.vals.size()); suspects.push_back(msg); }
            // an unmodelled field that never leaves const range and spreads widely may be a const
            // index we are ignoring; only interesting for aux/Bx, which is where indices live
            if (!cr && !ck && (f=="aux") && s.oob_k==0 && s.vals.size()>8) {
                std::snprintf(msg,sizeof msg,"0x%02x %s field aux: UNMODELLED, but 0%% exceed nconsts over %lld uses with %zu distinct -> possible const index",
                    op, oi?oi->name:"?", s.n, s.vals.size()); suspects.push_back(msg); }
        }
    }
    std::printf("\n== SUSPECTS (%zu) ==\n", suspects.size());
    for (auto& s : suspects) std::printf("  !! %s\n", s.c_str());
    if (suspects.empty()) std::printf("  none — every field behaves consistently with our declared model\n");
    return 0;
}

// =============================================================================================
// de-ktags <dir>  — THE decisive semantic check on constant references.
// Range checks only prove an index is in bounds. This asks what the referenced constant actually IS.
// An arithmetic op must reference a NUMBER; a field key must reference text (tag-3 string or tag-1
// FNV hash); DUPCLOSURE must reference a closure. If an op's references scatter across implausible
// tags, our operand model points at the wrong field — the exact failure mode that hid 0x34.
// =============================================================================================
static int cmd_de_ktags(int argc, char** argv) {
    fs::path dir = argv[2];
    std::map<uint8_t, std::map<int,long long>> tags;      // op -> const tag -> count
    std::map<uint8_t, long long> oob;
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        for (const de::Proto& p : m.protos) {
            int nk=(int)p.consts.size(); size_t o=0;
            while (o+4<=p.code.size()) {
                uint32_t w; std::memcpy(&w,p.code.data()+o,4);
                uint8_t op=w&0xff, B=(w>>16)&0xff, C=(w>>24)&0xff;
                uint16_t Bx=(w>>16)&0xffff;
                bool wide=tc::is_de_width8(op);
                uint32_t aux=0; if (wide && o+8<=p.code.size()) std::memcpy(&aux,p.code.data()+o+4,4);
                int ki = -1;
                if      (k_in_bx(op))   ki = Bx;
                else if (k_in_c(op))    ki = C;
                else if (k_in_b(op))    ki = B;
                else if (op==0x46)      ki = Bx;                        // GETIMPORT
                else if (k_aux_str(op)||k_aux_name(op)) ki = (int)(aux & 0xffff);
                else if (k_aux_cmp(op)) ki = (int)(aux & 0x7fffffffu);
                else if (op==0x0c)      ki = (int)(aux & 0x7fffffffu);  // FASTCALL2K 2nd arg (upstream Luau)
                if (ki >= 0) { if (ki >= nk) oob[op]++; else tags[op][p.consts[ki].tag]++; }
                o += wide?8:4;
            }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    const char* tn[10] = {"nil","namehash","number","string","import","tabletpl5","closure","vector","tabletpl8","int64"};
    auto expect = [](uint8_t op) -> const char* {
        if (op==0x38||op==0x3e||op==0x09||op==0x32||op==0x3c||op==0x08||op==0x24||op==0x06||op==0x3b)
            return "number";                                            // arithmetic-with-constant
        if (op==0x3d||op==0x15||op==0x17||op==0x02) return "text";       // field / global key
        if (op==0x2d) return "namehash";                                 // NAMECALL
        if (op==0x46) return "import";
        if (op==0x42) return "closure";
        if (op==0x4f) return "tabletpl";
        if (op==0x20) return "number";                                   // JUMPXEQKN
        if (op==0x41) return "text";                                     // JUMPXEQKS
        return nullptr; };
    std::printf("== CONSTANT-REFERENCE TAG AUDIT ==\n(what KIND of constant does each op point at?)\n\n");
    std::vector<std::string> suspects;
    for (auto& kv2 : tags) {
        uint8_t op = kv2.first; auto& th = kv2.second;
        const OpInfo* oi = opinfo(op);
        long long tot=0; for (auto& kv:th) tot+=kv.second;
        std::printf("op 0x%02x %-16s n=%-8lld ", op, oi?oi->name:"OP_??", tot);
        for (auto& kv : th) std::printf("%s=%lld(%.1f%%) ", (kv.first>=0&&kv.first<10)?tn[kv.first]:"?",
                                        kv.second, 100.0*kv.second/tot);
        if (oob.count(op)) std::printf("  OUT-OF-RANGE=%lld", oob[op]);
        std::printf("\n");
        const char* e = expect(op);
        if (e) for (auto& kv : th) {
            const char* got = (kv.first>=0&&kv.first<10)?tn[kv.first]:"?";
            bool ok;
            if (!std::strcmp(e,"text"))          ok = (kv.first==3 || kv.first==1);
            else if (!std::strcmp(e,"tabletpl")) ok = (kv.first==5 || kv.first==8);
            else if (!std::strcmp(e,"number"))   ok = (kv.first==2 || kv.first==9);
            else ok = !std::strcmp(e,got);
            if (!ok) { char m[260]; std::snprintf(m,sizeof m,
                "0x%02x %s references a %s const %lld times (%.2f%%) but should reference %s",
                op, oi?oi->name:"?", got, kv.second, 100.0*kv.second/tot, e); suspects.push_back(m); }
        }
        if (oob.count(op)) { char m[220]; std::snprintf(m,sizeof m,
            "0x%02x %s has %lld OUT-OF-RANGE const references — that field is not a const index",
            op, oi?oi->name:"?", oob[op]); suspects.push_back(m); }
    }
    std::printf("\n== SUSPECTS (%zu) ==\n", suspects.size());
    for (auto& s : suspects) std::printf("  !! %s\n", s.c_str());
    if (suspects.empty()) std::printf("  none — every constant reference points at a plausible constant kind\n");
    return 0;
}

// de-globalaudit <dir> -- classify DE module-environment keys by their actual constant kind.
// GETGLOBAL/SETGLOBAL accept both tag-1 FNV names and tag-3 strings in shipped bytecode. Treating
// them as interchangeable is unsound: the hashed form is used by engine-injected script properties
// (for example BardMusic.projectileType), while ordinary module exports commonly use strings. This
// audit establishes whether a source-level name is ever used in BOTH classes inside one module; that
// decides whether a module-level recompile hint is sufficiently precise or must be per instruction.
static int cmd_de_globalaudit(int argc, char** argv) {
    ir_load_namebase();
    fs::path dir = argv[2];
    const bool abilities_only = argc >= 4 && std::string(argv[3]) == "--abilities";
    struct Uses { long long hash_get=0, string_get=0, hash_set=0, string_set=0; };
    std::map<std::pair<std::string, std::string>, Uses> uses;
    std::map<std::pair<std::string, std::string>, Uses> fields;
    long long files=0, protos=0, globals=0, field_ops=0, bad=0;
    auto do_file = [&](const std::string& path) {
        if (abilities_only) {
            std::string normalized = path;
            for (char& character : normalized)
                if (character == '\\' || character == '/') character = '_';
            const bool primary_ability = normalized.find("Lotus_Powersuits_") != std::string::npos
                && (normalized.find("_Abilities_") != std::string::npos
                    || normalized.find("_ArchwingAbilities_") != std::string::npos
                    || normalized.find("_PeltAbilities_") != std::string::npos);
            if (!primary_ability) return;
        }
        const std::string bytes = read_file(path);
        if (bytes.size()<2 || (uint8_t)bytes[0]!=0x09 || (uint8_t)bytes[1]!=0x03) return;
        de::Module module;
        try { module = de::walk(bytes); } catch (...) { return; }
        const std::vector<std::string> pool = ir::parse_pool(bytes);
        ++files;
        const std::string file = fs::path(path).filename().string();
        for (size_t pi=0; pi<module.protos.size(); ++pi) {
            ++protos;
            const ir::IProto annotated = ir_annotate(module.protos[pi], (int)pi, pool, g_nb);
            if (!annotated.ok) { ++bad; continue; }
            for (const ir::IInsn& instruction : annotated.code) {
                const bool global = instruction.op == 0x17 || instruction.op == 0x02;
                const bool field = instruction.op == 0x3d || instruction.op == 0x15;
                if (!global && !field) continue;
                if (global) ++globals; else ++field_ops;
                const uint32_t key = instruction.aux & 0xffffu;
                if (key >= annotated.consts.size()) { ++bad; continue; }
                const ir::KVal& value = annotated.consts[key];
                Uses& entry = (global ? uses : fields)[{file, instruction.note}];
                if (instruction.op == 0x17 || instruction.op == 0x3d) {
                    if (value.kind == ir::KKind::NameHash) ++entry.hash_get;
                    else if (value.kind == ir::KKind::Str) ++entry.string_get;
                    else ++bad;
                } else {
                    if (value.kind == ir::KKind::NameHash) ++entry.hash_set;
                    else if (value.kind == ir::KKind::Str) ++entry.string_set;
                    else ++bad;
                }
            }
        }
    };
    if (fs::is_directory(dir)) {
        for (const auto& entry : fs::directory_iterator(dir))
            if (entry.is_regular_file() && entry.path().extension()==".lua_B")
                do_file(entry.path().string());
    } else do_file(dir.string());

    struct Summary {
        long long hash_get=0, string_get=0, hash_set=0, string_set=0;
        int hash_names=0, string_names=0, mixed_names=0, mixed_get_names=0;
        std::vector<std::string> mixed_examples;
    };
    auto summarize = [](const std::map<std::pair<std::string, std::string>, Uses>& input) {
        Summary summary;
        for (const auto& item : input) {
            const Uses& u = item.second;
            summary.hash_get += u.hash_get; summary.string_get += u.string_get;
            summary.hash_set += u.hash_set; summary.string_set += u.string_set;
            const bool hashed = u.hash_get || u.hash_set;
            const bool strings = u.string_get || u.string_set;
            if (hashed) ++summary.hash_names;
            if (strings) ++summary.string_names;
            if (u.hash_get && u.string_get) ++summary.mixed_get_names;
            if (hashed && strings) {
                ++summary.mixed_names;
                if (summary.mixed_examples.size() < 40) {
                    std::ostringstream line;
                    line << item.first.first << " :: " << item.first.second
                         << " hash(get=" << u.hash_get << ",set=" << u.hash_set << ')'
                         << " string(get=" << u.string_get << ",set=" << u.string_set << ')';
                    summary.mixed_examples.push_back(line.str());
                }
            }
        }
        return summary;
    };
    const Summary global_summary = summarize(uses);
    const Summary field_summary = summarize(fields);
    std::printf("== GLOBAL KEY-KIND AUDIT ==\n");
    std::printf("scope=%s files=%lld protos=%lld global_ops=%lld field_ops=%lld bad=%lld\n",
                abilities_only ? "abilities" : "all", files, protos, globals, field_ops, bad);
    std::printf("GETGLOBAL hash=%lld string=%lld | SETGLOBAL hash=%lld string=%lld\n",
                global_summary.hash_get, global_summary.string_get,
                global_summary.hash_set, global_summary.string_set);
    std::printf("module/name identities: hashed=%d string=%d mixed=%d\n",
                global_summary.hash_names, global_summary.string_names,
                global_summary.mixed_names);
    for (const std::string& example : global_summary.mixed_examples)
        std::printf("  GLOBAL_MIXED %s\n", example.c_str());
    std::printf("GETFIELD hash=%lld string=%lld | SETFIELD hash=%lld string=%lld\n",
                field_summary.hash_get, field_summary.string_get,
                field_summary.hash_set, field_summary.string_set);
    std::printf("module/name field identities: hashed=%d string=%d mixed_any=%d mixed_get=%d\n",
                field_summary.hash_names, field_summary.string_names,
                field_summary.mixed_names, field_summary.mixed_get_names);
    for (const std::string& example : field_summary.mixed_examples)
        std::printf("  FIELD_MIXED %s\n", example.c_str());
    const bool exact = global_summary.mixed_names == 0
        && field_summary.mixed_get_names == 0 && bad == 0;
    std::printf("VERDICT: %s\n", exact
        ? "module-level name classification is exact for globals and fields"
        : "classification must be more precise than module plus source name");
    return exact ? 0 : 1;
}

// de-find <dir> <op> [limit] — locate occurrences of an opcode (file / proto / instruction index).
static int cmd_de_find(int argc, char** argv) {
    fs::path dir = argv[2];
    uint8_t want = (uint8_t)std::strtol(argv[3], nullptr, 0);
    int limit = (argc >= 5) ? std::atoi(argv[4]) : 20;
    int shown = 0;
    auto do_file=[&](const std::string& path){
        if (shown >= limit) return;
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        for (size_t pi=0; pi<m.protos.size() && shown<limit; ++pi) {
            const de::Proto& p = m.protos[pi]; size_t o=0; int idx=0;
            while (o+4<=p.code.size()) {
                uint32_t w; std::memcpy(&w,p.code.data()+o,4);
                uint8_t op=w&0xff; bool wide=tc::is_de_width8(op);
                if (op==want && shown<limit) {
                    std::printf("  %-56s proto=%-4zu insn=%d\n",
                        fs::path(path).filename().string().c_str(), pi, idx);
                    ++shown;
                }
                o += wide?8:4; ++idx;
            }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    std::printf("(%d shown)\n", shown);
    return 0;
}

// =============================================================================================
// de-tag1audit <dir> — is DE's tag-1 constant ALWAYS an FNV name hash, or is it OVERLOADED?
//
// Upstream Luau's tag 1 is BOOLEAN. DE repurposed it to carry 4-byte FNV name hashes (round-trip
// proves it is 4 bytes wide, not 1). But `ANDK` was seen referencing a tag-1 const whose raw value
// is literally 1, and the corpus contains exactly two unresolvable "hashes": 0x00000000 and
// 0x00000001 — the signature of false/true.
//
// FALSIFICATION: if tag-1 is purely a name hash, values {0,1} should appear in NAME contexts
// (NAMECALL / field / global keys) just like any other hash. If instead they appear ONLY in
// value contexts (LOADK / ANDK / ORK), tag 1 is overloaded and we are rendering booleans as
// "Name__00000001", which would be a decompiler bug.
// =============================================================================================
static int cmd_de_tag1audit(int argc, char** argv) {
    fs::path dir = argv[2];
    struct Cnt { long long small=0, big=0; };
    std::map<uint8_t, Cnt> byop;
    std::map<uint32_t,long long> smallvals;
    auto is_name_ctx = [](uint8_t op){ return op==0x2d||op==0x3d||op==0x15||op==0x17||op==0x02||op==0x46; };
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        for (const de::Proto& p : m.protos) {
            int nk=(int)p.consts.size(); size_t o=0;
            auto tag1val=[&](int ki, uint32_t& v)->bool{
                if (ki<0||ki>=nk||p.consts[ki].tag!=1||p.consts[ki].raw.size()<4) return false;
                std::memcpy(&v, p.consts[ki].raw.data(), 4); return true; };
            while (o+4<=p.code.size()) {
                uint32_t w; std::memcpy(&w,p.code.data()+o,4);
                uint8_t op=w&0xff, B=(w>>16)&0xff, C=(w>>24)&0xff;
                uint16_t Bx=(w>>16)&0xffff;
                bool wide=tc::is_de_width8(op);
                uint32_t aux=0; if (wide && o+8<=p.code.size()) std::memcpy(&aux,p.code.data()+o+4,4);
                std::vector<int> kis;
                if      (k_in_bx(op)||op==0x46) kis.push_back(Bx);
                else if (k_in_c(op))            kis.push_back(C);
                else if (k_in_b(op))            kis.push_back(B);
                else if (k_aux_str(op)||k_aux_name(op)) kis.push_back((int)(aux & 0xffff));
                else if (k_aux_cmp(op))         kis.push_back((int)(aux & 0x7fffffffu));
                // GETIMPORT path components are consts too
                if (op==0x46 && Bx>=0 && Bx<nk && p.consts[Bx].tag==4 && p.consts[Bx].raw.size()>=4) {
                    uint32_t id; std::memcpy(&id, p.consts[Bx].raw.data(), 4);
                    int cnt, ix[3]; ir::import_parts(id, cnt, ix);
                    for (int q=0;q<cnt && q<3;++q) kis.push_back(ix[q]);
                }
                for (int ki : kis) { uint32_t v;
                    if (!tag1val(ki, v)) continue;
                    if (v <= 1) { byop[op].small++; smallvals[v]++; } else byop[op].big++; }
                o += wide?8:4;
            }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    std::printf("== TAG-1 CONSTANT AUDIT (name hash, or overloaded boolean?) ==\n\n");
    std::printf("%-24s %14s %14s   context\n", "op", "value 0 or 1", "value > 1");
    long long name_small=0, val_small=0;
    for (auto& kv : byop) {
        const OpInfo* oi = opinfo(kv.first);
        bool nc = is_name_ctx(kv.first);
        std::printf("0x%02x %-19s %14lld %14lld   %s\n", kv.first, oi?oi->name:"?",
                    kv.second.small, kv.second.big, nc ? "NAME" : "value");
        if (nc) name_small += kv.second.small; else val_small += kv.second.small;
    }
    std::printf("\ntag-1 refs with value 0/1 in a NAME context  : %lld\n", name_small);
    std::printf("tag-1 refs with value 0/1 in a VALUE context : %lld\n", val_small);
    std::printf("distinct small values seen: ");
    for (auto& kv : smallvals) std::printf("%u(x%lld) ", kv.first, kv.second);
    std::printf("\n\nVERDICT: %s\n", name_small == 0 && val_small > 0
        ? "tag 1 IS OVERLOADED — values 0/1 appear ONLY in value contexts, i.e. they are BOOLEANS"
        : (val_small == 0 ? "no small tag-1 values referenced — tag 1 behaves purely as a name hash"
                          : "MIXED — small tag-1 values appear in NAME contexts too; not simply booleans"));
    return 0;
}

// =============================================================================================
// de-forgprep <dir> — which generic-for PREP opcode is which?
// Luau has three prep variants (FORGPREP generic / FORGPREP_INEXT for ipairs / FORGPREP_NEXT for
// pairs) and DE has three bytes: 0x30, 0x1b and 0x0b. We map 0x30 for BOTH generic and _NEXT and
// have never identified 0x0b (its decode name is literally "FORGPREP?").
// Two independent signals identify each: the ITERATOR that feeds the loop (the import name resolved
// from the nearest preceding GETIMPORT), and the aux of the FORGLOOP that closes it (upstream Luau
// sets bit31 for the inext flavour).
// =============================================================================================
static int cmd_de_forgprep(int argc, char** argv) {
    ir_load_namebase();
    fs::path dir = argv[2];
    std::map<uint8_t, std::map<std::string,long long>> iter;   // prep op -> iterator name -> count
    std::map<uint8_t, std::map<uint32_t,long long>> loopaux;   // prep op -> closing FORGLOOP aux -> count
    std::map<uint8_t, long long> tot;
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        std::vector<std::string> pool = ir::parse_pool(b);
        for (size_t pi=0; pi<m.protos.size(); ++pi) {
            ir::IProto ip = ir_annotate(m.protos[pi], (int)pi, pool, g_nb);
            if (!ip.ok) continue;
            for (size_t q=0; q<ip.code.size(); ++q) {
                uint8_t op = ip.code[q].op;
                if (op!=0x30 && op!=0x1b && op!=0x0b) continue;
                ++tot[op];
                // nearest preceding GETIMPORT names the iterator (pairs / ipairs / string.gmatch / ...)
                std::string it = "<none>";
                for (int r=(int)q-1; r>=0 && r>(int)q-12; --r)
                    if (ip.code[r].op==0x46) { it = ip.code[r].note; break; }
                iter[op][it]++;
                // the FORGLOOP this prep jumps to
                int t = ip.code[q].target;
                if (t>=0 && t<(int)ip.code.size() && ip.code[t].op==0x1e) loopaux[op][ip.code[t].aux]++;
                else loopaux[op][0xDEADBEEF]++;
            }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    for (auto& kv : tot) {
        uint8_t op = kv.first;
        std::printf("\n== prep op 0x%02x   n=%lld ==\n", op, kv.second);
        std::printf("  iterator feeding the loop (nearest preceding GETIMPORT):\n");
        std::vector<std::pair<long long,std::string>> v;
        for (auto& e : iter[op]) v.push_back({e.second,e.first});
        std::sort(v.rbegin(),v.rend());
        for (size_t i=0;i<v.size() && i<8;++i)
            std::printf("      %-28s %lld (%.1f%%)\n", v[i].second.c_str(), v[i].first, 100.0*v[i].first/kv.second);
        std::printf("  aux of the closing FORGLOOP:\n");
        for (auto& e : loopaux[op])
            std::printf("      0x%08x  %lld%s\n", e.first, e.second,
                        e.first==0xDEADBEEF ? "   (target was NOT a FORGLOOP)" : "");
    }
    return 0;
}

// =============================================================================================
// de-patchop <in> <out> <proto> <findop> <nth> <newop> [A B C]   — BYTECODE SURGERY.
//
// Some DE opcodes cannot be reached by compiling Luau at all: upstream Luau dropped TESTSET (a Lua
// 5.1 op) and has no reversed-operand MOD, so no source produces 0x51 or 0x00 and the native-emission
// knob has nothing to switch on. The only way to certify them is to emit a carrier instruction with
// the same operand layout (MOVE for TESTSET, MUL for MODR) and rewrite its opcode byte.
//
// Everything except the patched instruction is re-emitted byte-exactly by de::encode, so the change
// is surgical and the rest of the module is untouched.
// =============================================================================================
static int cmd_de_patchop(int argc, char** argv) {
    std::string b = read_file(argv[2]);
    de::Module m;
    try { m = de::walk(b); } catch (const std::exception& e) {
        std::fprintf(stderr, "walk error: %s\n", e.what()); return 1; }
    int pidx   = std::atoi(argv[4]);
    uint8_t findop = (uint8_t)std::strtol(argv[5], nullptr, 0);
    int nth    = std::atoi(argv[6]);
    uint8_t newop  = (uint8_t)std::strtol(argv[7], nullptr, 0);
    int setA = (argc > 8)  ? std::atoi(argv[8])  : -1;
    int setB = (argc > 9)  ? std::atoi(argv[9])  : -1;
    int setC = (argc > 10) ? std::atoi(argv[10]) : -1;
    if (pidx < 0 || pidx >= (int)m.protos.size()) { std::fprintf(stderr, "bad proto\n"); return 1; }
    de::Proto& p = m.protos[pidx];
    size_t o = 0; int seen = 0, idx = 0; bool done = false;
    while (o + 4 <= p.code.size()) {
        uint32_t w; std::memcpy(&w, p.code.data() + o, 4);
        uint8_t op = w & 0xff;
        bool wide = tc::is_de_width8(op);
        if (op == findop) {
            if (seen == nth) {
                // WIDTH must match or every following instruction shifts and the module is garbage.
                if (tc::is_de_width8(newop) != wide) {
                    std::fprintf(stderr, "REFUSED: 0x%02x and 0x%02x differ in width (4B vs 8B)\n", findop, newop);
                    return 1;
                }
                p.code[o] = (char)newop;
                if (setA >= 0) p.code[o+1] = (char)setA;
                if (setB >= 0) p.code[o+2] = (char)setB;
                if (setC >= 0) p.code[o+3] = (char)setC;
                std::printf("patched proto[%d] insn %d @0x%zx : 0x%02x -> 0x%02x  A=%d B=%d C=%d\n",
                            pidx, idx, o, findop, newop,
                            (uint8_t)p.code[o+1], (uint8_t)p.code[o+2], (uint8_t)p.code[o+3]);
                done = true; break;
            }
            ++seen;
        }
        o += wide ? 8 : 4; ++idx;
    }
    if (!done) { std::fprintf(stderr, "no occurrence #%d of op 0x%02x in proto %d\n", nth, findop, pidx); return 1; }
    std::string out = de::encode(m);
    if (!write_file(argv[3], out)) { std::fprintf(stderr, "write failed\n"); return 1; }
    std::printf("wrote %s (%zu bytes)\n", argv[3], out.size());
    return 0;
}

// =============================================================================================
// de-fastcall <dir> — prove the 5 FASTCALL-family opcodes really ARE skippable hints.
//
// This is the ONE property the decompiler depends on. M6 DROPS 0x19/0x26/0x10/0x0c/0x4a assuming
// they are optimisation hints whose complete slow path follows. If any of them is something else,
// M6 silently DELETES REAL CODE — a failure that yields plausible, wrong source.
//
// A genuine FASTCALL is defined by its structure: its skip offset lands exactly ONE INSTRUCTION
// PAST A CALL, because the span it skips IS the slow path (argument setup + GETIMPORT + CALL).
//     target = off + 4 + C*4   must land on an instruction boundary
//     the instruction immediately BEFORE that target must be CALL (0x54)
// If that holds everywhere, dropping them is provably safe: the slow path computes the same value
// and control rejoins at the same instruction.
// =============================================================================================
static int cmd_de_fastcall(int argc, char** argv) {
    fs::path dir = argv[2];
    struct S { long long n=0, offb=0, call_before=0, other_before=0, back=0, zeroC=0;
               std::map<std::string,long long> before; };
    std::map<uint8_t,S> st;
    auto isfc=[](uint8_t o){ return o==0x19||o==0x26||o==0x10||o==0x0c||o==0x4a; };
    std::string examples;
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        for (size_t pi=0; pi<m.protos.size(); ++pi) {
            const de::Proto& p = m.protos[pi];
            std::vector<std::pair<size_t,uint8_t>> ins;
            std::map<size_t,int> off2idx;
            size_t o=0;
            while (o+4<=p.code.size()) {
                uint32_t w; std::memcpy(&w,p.code.data()+o,4);
                uint8_t op=w&0xff;
                off2idx[o]=(int)ins.size(); ins.push_back({o,op});
                o += tc::is_de_width8(op)?8:4;
            }
            off2idx[p.code.size()]=(int)ins.size();
            for (size_t q=0;q<ins.size();++q) {
                uint8_t op=ins[q].second; if(!isfc(op)) continue;
                uint32_t w; std::memcpy(&w,p.code.data()+ins[q].first,4);
                uint8_t C=(w>>24)&0xff;
                S& s=st[op]; ++s.n;
                if (C==0) { ++s.zeroC; continue; }
                long long tb=(long long)ins[q].first+4+(long long)C*4;
                auto it=(tb<0)?off2idx.end():off2idx.find((size_t)tb);
                if (it==off2idx.end()) { ++s.offb; continue; }
                int ti=it->second;
                if (ti<=(int)q) { ++s.back; continue; }
                // The target IS the CALL itself, not the instruction after it. FASTCALL skips only the
                // function/argument setup; the CALL sits at the landing site and completes the call.
                // Verified by hand on AnchorMgr p5: FASTCALL1 C=2, GETIMPORT (8B, 2 words), CALL.
                uint8_t prev = (ti<(int)ins.size()) ? ins[ti].second : 0xFF;
                if (prev==0x54) ++s.call_before;
                else {
                    ++s.other_before;
                    const OpInfo* oi=opinfo(prev);
                    s.before[oi?oi->name:"OP_??"]++;
                    if (examples.size()<900) { char L[220];
                        std::snprintf(L,sizeof L,"    %s p%zu insn %zu (0x%02x C=%d) -> target %d is %s\n",
                            fs::path(path).filename().string().c_str(), pi, q, op, C, ti, oi?oi->name:"OP_??");
                        examples+=L; }
                }
            }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    std::printf("== FASTCALL SKIPPABILITY PROOF ==\n(does each skip offset land exactly ON a CALL?)\n\n");
    long long tot=0, ok=0, bad=0, zc=0;
    for (auto& kv : st) {
        S& s = kv.second; tot += s.n; ok += s.call_before; zc += s.zeroC;
        bad += s.other_before + s.offb + s.back;
        const OpInfo* oi=opinfo(kv.first);
        long long denom = s.n - s.zeroC; if (!denom) denom = 1;
        std::printf("0x%02x %-12s n=%-7lld  target IS a CALL: %lld (%.4f%%)   C==0: %lld  off-boundary: %lld  backwards: %lld\n",
            kv.first, oi?oi->name:"?", s.n, s.call_before, 100.0*s.call_before/denom, s.zeroC, s.offb, s.back);
        for (auto& e : s.before) std::printf("        target is instead      %-14s %lld\n", e.first.c_str(), e.second);
    }
    std::printf("\ntotal FASTCALL-family instructions   : %lld\n", tot);
    std::printf("  skip target lands exactly ON a CALL   : %lld\n", ok);
    std::printf("  C==0 (no skip encoded)               : %lld\n", zc);
    std::printf("  anything else                        : %lld\n", bad);
    if (!examples.empty()) std::printf("\n  counter-examples:\n%s", examples.c_str());
    std::printf("\n  VERDICT: %s\n", bad==0
        ? "every FASTCALL skips exactly a call sequence -> DROPPING THEM IS PROVABLY SAFE"
        : "some do NOT skip a call sequence -> the decompiler may be deleting real code");
    return bad==0 ? 0 : 1;
}

// =============================================================================================
// M6 GROUND TRUTH.  The old decompiled corpus CANNOT validate the decompiler: it was produced with
// the wrong opcode map, so agreeing with it would mean being wrong in the same way. Generate source
// we KNOW instead, and compare PROGRAMS rather than text:
//
//   S --luau-compile--> LBC1 --transcode--> DE1 --decompile--> S' --luau-compile--> LBC2
//                        |                                                          |
//                        +-------------------- lbc-cmp -----------------------------+
//
// If S' compiles to the same Luau bytecode as S did, S' IS the same program — independent of
// formatting, identifier names and register allocation.
//
//   rt-build <srcdir>              compile + transcode every case; report coverage
//   lbc-cmp  <a.luaubc> <b.luaubc> graded comparison of two Luau bytecode files
// =============================================================================================
static int cmd_rt_build(int argc, char** argv) {
    fs::path src = argv[2];
    // Optional tag -> a SECOND ground-truth set built with different transcoder settings. Used to
    // cover the decode-only opcodes: they are absent from normal ground truth precisely because we
    // lower or drop them, so RENOVICE_NATIVE=... forces them into the generated bytecode.
    std::string tag = (argc >= 4) ? std::string("_") + argv[3] : std::string();
    fs::path bcdir = src.parent_path() / ("bc" + tag);
    fs::path dedir = src.parent_path() / ("de" + tag);
    fs::create_directories(bcdir); fs::create_directories(dedir);
    int total=0, compiled=0, transcoded=0;
    std::vector<std::string> cfail, tfail;
    std::map<std::string,long long> ophist;
    std::vector<fs::path> files;
    for (auto& e : fs::directory_iterator(src))
        if (e.is_regular_file() && e.path().extension()==".luau") files.push_back(e.path());
    std::sort(files.begin(), files.end());
    for (auto& f : files) {
        ++total;
        std::string stem = f.stem().string(), err;
        std::string lbc = compile_luau(f.string(), err);
        if (lbc.empty()) { cfail.push_back(stem + ": " + err); continue; }
        ++compiled;
        write_file((bcdir / (stem + ".luaubc")).string(), lbc);
        try {
            luau::Module lm = luau::read(lbc);
            for (const luau::Proto& p : lm.protos)
                for (const luau::Insn& in : p.insns) ophist[in.name()]++;
            std::string de = tc::transcode(lbc);
            write_file((dedir / (stem + ".lua_B")).string(), de);
            de::Module chk = de::walk(de); (void)chk;      // must re-parse as a valid container
            ++transcoded;
        } catch (const std::exception& ex) { tfail.push_back(stem + ": " + ex.what()); }
    }
    std::printf("== M6 GROUND-TRUTH BUILD ==\n");
    std::printf("cases                 : %d\n", total);
    std::printf("  compiled (Luau)     : %d\n", compiled);
    std::printf("  transcoded (DE)     : %d   -> %s\n", transcoded, dedir.string().c_str());
    for (auto& s : cfail) std::printf("  COMPILE FAIL   %s\n", s.c_str());
    for (auto& s : tfail) std::printf("  TRANSCODE FAIL %s\n", s.c_str());
    std::printf("\ndistinct Luau opcodes exercised: %zu\n", ophist.size());
    std::vector<std::pair<long long,std::string>> v;
    for (auto& kv : ophist) v.push_back({kv.second, kv.first});
    std::sort(v.rbegin(), v.rend());
    std::string line;
    for (auto& q : v) { line += q.second + "(" + std::to_string(q.first) + ") ";
        if (line.size() > 96) { std::printf("  %s\n", line.c_str()); line.clear(); } }
    if (!line.empty()) std::printf("  %s\n", line.c_str());
    return (cfail.empty() && tfail.empty()) ? 0 : 1;
}

// Graded comparison: report the STRONGEST level that holds, so partial progress is visible rather
// than collapsing to pass/fail.
static int cmd_lbc_cmp(int argc, char** argv) {
    std::string a = read_file(argv[2]), b = read_file(argv[3]);
    if (a.empty() || b.empty()) { std::fprintf(stderr, "cannot read inputs\n"); return 2; }
    luau::Module A, B;
    try { A = luau::read(a); B = luau::read(b); }
    catch (const std::exception& e) { std::printf("PARSE ERROR: %s\n", e.what()); return 2; }
    if (a == b) { std::printf("IDENTICAL (byte-exact)\n"); return 0; }
    if (A.protos.size() != B.protos.size()) {
        std::printf("DIFFER: proto count %zu vs %zu\n", A.protos.size(), B.protos.size()); return 1; }
    int opseq_ok = 0, operand_ok = 0;
    std::string firstdiff;
    for (size_t i = 0; i < A.protos.size(); ++i) {
        const luau::Proto& pa = A.protos[i]; const luau::Proto& pb = B.protos[i];
        bool seq = (pa.insns.size() == pb.insns.size()), ops = seq;
        if (seq) {
            for (size_t j = 0; j < pa.insns.size(); ++j) {
                if (std::strcmp(pa.insns[j].name(), pb.insns[j].name()) != 0) {
                    seq = ops = false;
                    if (firstdiff.empty()) { char L[200]; std::snprintf(L,sizeof L,
                        "proto %zu insn %zu: %s vs %s", i, j, pa.insns[j].name(), pb.insns[j].name());
                        firstdiff = L; }
                    break;
                }
                const luau::Insn& x = pa.insns[j]; const luau::Insn& y = pb.insns[j];
                if (x.A!=y.A || x.B!=y.B || x.C!=y.C || x.D!=y.D) ops = false;
            }
        } else if (firstdiff.empty()) { char L[160]; std::snprintf(L,sizeof L,
            "proto %zu length %zu vs %zu", i, pa.insns.size(), pb.insns.size()); firstdiff = L; }
        if (seq) ++opseq_ok;
        if (ops) ++operand_ok;
    }
    size_t n = A.protos.size();
    std::printf("protos=%zu  same opcode SEQUENCE: %d/%zu   same OPERANDS too: %d/%zu\n",
                n, opseq_ok, n, operand_ok, n);
    if ((size_t)opseq_ok == n)
        std::printf("EQUIVALENT: identical opcode sequence in every proto -> same program\n");
    else
        std::printf("DIFFER: %s\n", firstdiff.c_str());
    return ((size_t)opseq_ok == n) ? 0 : 1;
}

// Per-prototype DE comparison for fixed-point work. Whole-file deltas hide which closure changed;
// this keeps the container parser authoritative and reports code/header/constant differences plus
// opcode deltas without generating or modifying source.
static int cmd_de_proto_diff(int argc, char** argv) {
    const std::string left_bytes = read_file(argv[2]);
    const std::string right_bytes = read_file(argv[3]);
    if (left_bytes.empty() || right_bytes.empty()) {
        std::fprintf(stderr, "cannot read inputs\n");
        return 2;
    }
    de::Module left, right;
    try {
        left = de::walk(left_bytes);
        right = de::walk(right_bytes);
    } catch (const std::exception& error) {
        std::fprintf(stderr, "walk: %s\n", error.what());
        return 2;
    }
    auto const_equal = [](const de::Const& a, const de::Const& b) {
        return a.tag == b.tag && a.raw == b.raw && a.idx == b.idx && a.list == b.list
            && a.items == b.items && a.sign == b.sign && a.val == b.val;
    };
    auto instruction_metrics = [](const de::Proto& proto, long long (&histogram)[256]) {
        long long instructions = 0;
        for (size_t offset = 0; offset + 4 <= proto.code.size();) {
            const uint8_t opcode = (uint8_t)proto.code[offset];
            ++histogram[opcode];
            ++instructions;
            offset += tc::is_de_width8(opcode) ? 8 : 4;
        }
        return instructions;
    };

    const size_t shared = std::min(left.protos.size(), right.protos.size());
    int changed = left.protos.size() == right.protos.size() ? 0 : 1;
    std::printf("protos=%zu->%zu shared=%zu\n", left.protos.size(), right.protos.size(), shared);
    for (size_t pidx = 0; pidx < shared; ++pidx) {
        const de::Proto& a = left.protos[pidx];
        const de::Proto& b = right.protos[pidx];
        bool constants_equal = a.consts.size() == b.consts.size();
        for (size_t index = 0; constants_equal && index < a.consts.size(); ++index)
            constants_equal = const_equal(a.consts[index], b.consts[index]);
        const bool header_equal = a.hdr == b.hdr;
        const bool code_equal = a.code == b.code;
        const bool post_equal = a.post == b.post;
        if (header_equal && code_equal && constants_equal && post_equal) continue;
        changed = 1;
        long long left_histogram[256] = {};
        long long right_histogram[256] = {};
        const long long left_instructions = instruction_metrics(a, left_histogram);
        const long long right_instructions = instruction_metrics(b, right_histogram);
        const int left_stack = a.hdr.empty() ? -1 : (uint8_t)a.hdr[0];
        const int right_stack = b.hdr.empty() ? -1 : (uint8_t)b.hdr[0];
        std::printf("pidx=%zu code_bytes=%zu->%zu (%+lld) instructions=%lld->%lld (%+lld) "
                    "maxstack=%d->%d header=%d constants=%zu->%zu equal=%d post=%d ops=",
                    pidx, a.code.size(), b.code.size(),
                    (long long)b.code.size() - (long long)a.code.size(),
                    left_instructions, right_instructions,
                    right_instructions - left_instructions, left_stack, right_stack,
                    header_equal ? 1 : 0, a.consts.size(), b.consts.size(),
                    constants_equal ? 1 : 0, post_equal ? 1 : 0);
        bool first = true;
        for (int opcode = 0; opcode < 256; ++opcode) {
            const long long delta = right_histogram[opcode] - left_histogram[opcode];
            if (!delta) continue;
            std::printf("%s0x%02x:%+lld", first ? "" : ",", opcode, delta);
            first = false;
        }
        if (first) std::printf("none");
        std::printf("\n");
    }
    return changed;
}

// =============================================================================================
// de-builtins <dir> — recover DE's BUILTIN-ID table from the corpus, offline.
//
// FASTCALL's A is a builtin id. To EMIT fastcalls we would pass Luau's id straight through, which is
// only safe if DE kept upstream Luau's numbering. Getting this wrong is the nastiest class of bug:
// a wrong id still returns a NUMBER, just the wrong one — no crash, no error, no log line.
//
// The corpus answers it directly. Every fastcall is followed by its own slow path, and the function
// that slow path calls IS the builtin:
//     FASTCALL1 A=<id> B=<arg> C=<skip>
//     GETIMPORT R_base <- <the function>      <- this names the builtin
//     ...args...
//     CALL R_base                             <- the skip target
// Find the CALL at the skip target, take its base register, and find the GETIMPORT in between that
// loaded it. That maps id -> name with no guessing.
// =============================================================================================
static int cmd_de_builtins(int argc, char** argv) {
    ir_load_namebase();
    fs::path dir = argv[2];
    std::map<int, std::map<std::string,long long>> tbl;    // builtin id -> name -> count
    long long fc=0, mapped=0;
    auto isfc=[](uint8_t o){ return o==0x19||o==0x26||o==0x10||o==0x0c||o==0x4a; };
    auto do_file=[&](const std::string& path){
        std::string b=read_file(path);
        if (b.size()<2||(uint8_t)b[0]!=0x09||(uint8_t)b[1]!=0x03) return;
        de::Module m; try{m=de::walk(b);}catch(...){return;}
        std::vector<std::string> pool = ir::parse_pool(b);
        for (size_t pi=0; pi<m.protos.size(); ++pi) {
            ir::IProto ip = ir_annotate(m.protos[pi], (int)pi, pool, g_nb);
            if (!ip.ok) continue;
            std::map<size_t,int> off2idx;
            for (size_t q=0;q<ip.code.size();++q) off2idx[ip.code[q].off]=(int)q;
            for (size_t q=0;q<ip.code.size();++q) {
                const ir::IInsn& in = ip.code[q];
                if (!isfc(in.op) || in.C==0) continue;
                ++fc;
                auto it = off2idx.find(in.off + 4 + (size_t)in.C*4);
                if (it==off2idx.end()) continue;
                int t = it->second;
                if (t>=(int)ip.code.size() || ip.code[t].op!=0x54) continue;
                int base = ip.code[t].A;
                for (int k=t-1; k>(int)q; --k) {
                    const ir::IInsn& s = ip.code[k];
                    if (s.op==0x46 && s.A==base) { tbl[in.A][s.note]++; ++mapped; break; }
                    if (s.op==0x13 && s.A==base) { tbl[in.A]["<upvalue>"]++;  ++mapped; break; }
                    if (s.op==0x3d && s.A==base) { tbl[in.A]["."+s.note]++;   ++mapped; break; }
                }
            }
        }
    };
    if (fs::is_directory(dir)) { for (auto& e: fs::directory_iterator(dir))
        if (e.is_regular_file() && e.path().extension()==".lua_B") do_file(e.path().string()); }
    else do_file(dir.string());
    std::printf("== DE BUILTIN-ID TABLE (from %lld fastcalls, %lld resolved) ==\n\n", fc, mapped);
    std::printf("%-5s %-8s %s\n", "id", "uses", "function(s) the slow path calls");
    int ambiguous = 0;
    for (auto& kv : tbl) {
        long long tot=0; for (auto& e : kv.second) tot += e.second;
        std::vector<std::pair<long long,std::string>> v;
        for (auto& e : kv.second) v.push_back({e.second, e.first});
        std::sort(v.rbegin(), v.rend());
        std::string s;
        for (size_t i=0;i<v.size() && i<3;++i) { if (i) s += ", ";
            s += v[i].second + "(" + std::to_string(v[i].first) + ")"; }
        if (v.size()>3) s += ", +" + std::to_string(v.size()-3) + " more";
        bool amb = (v.size()>1) && (v[0].first < tot*9/10);
        if (amb) ++ambiguous;
        std::printf("%-5d %-8lld %s%s\n", kv.first, tot, s.c_str(), amb ? "   <-- AMBIGUOUS" : "");
    }
    std::printf("\ndistinct builtin ids: %zu   ambiguous: %d\n", tbl.size(), ambiguous);
    return 0;
}

#include "m6c_cmd.h"
#include "m6d_cmd.h"
#include "m6e_cmd.h"
#include "skel_cmd.h"
#include "semantic_plan_cmd.h"
#include "semantic_ir/command.h"
#include "closure_map_cmd.h"
#include "u44_raw_cmd.h"
#include "cfg_identity_cmd.h"
#include "dataflow_identity_cmd.h"
#include "loop_exit_scan_cmd.h"

// The fixed-point rules below were A/B tested, then certified together at 360/360 in raw mode,
// with five witnesses stable through ten cycles and 19 executable behavior fixtures. Keep that
// proven behavior in the actual binary;
// requiring callers to reconstruct a long environment profile made ordinary `decompile` silently
// fall back to the older, less stable renderer. The single opt-out exists for research comparisons.
static void install_certified_decompiler_defaults() {
    if (std::getenv("RENOVICE_NO_CERTIFIED_DEFAULT_PROFILE")) return;
    static const char* const defaults[] = {
        "RENOVICE_LOCAL_BUDGET_195",
        "RENOVICE_NO_PROPER_WHOLE_PROMOTION",
        "RENOVICE_STRUCTURED_RAW_FORNPREP",
        "RENOVICE_REMOVE_PURE_EMPTY_TRUTHINESS",
        "RENOVICE_CANONICAL_SCC_GUARD_LOOP",
        "RENOVICE_DIRECT_STATE_SPELLING",
        "RENOVICE_FINAL_STATE_SPELLING",
        "RENOVICE_REDUNDANT_POST_BREAK_GUARDS",
        "RENOVICE_COLLAPSE_NESTED_SINGLE_ARM_AND",
        "RENOVICE_CFG_SKIP_FOR_PREP_WHILE",
        "RENOVICE_CFG_EARLY_RETURN_JOIN",
        "RENOVICE_CFG_GUARD_STRUCTURED_JOIN",
        "RENOVICE_CFG_STRUCTURED_LOOP_TRIANGLE",
        "RENOVICE_CFG_DUPLICATE_BARE_RETURNS",
        "RENOVICE_CFG_PRIVATE_RETURN_LOOP_ARMS",
        "RENOVICE_CFG_EXACT_RETURN_GUARD",
        "RENOVICE_CFG_GUARD_BOUNDARY_TRIANGLE",
        "RENOVICE_CFG_GUARD_ACYCLIC_DISPATCH",
        "RENOVICE_CFG_SKIP_SMALL_NESTED_TERMINAL_REPEAT",
        "RENOVICE_CFG_RETRY_OWNERSHIP_COLLISION",
        "RENOVICE_CFG_RETRY_LOOP_ACYCLIC_DISPATCH",
        "RENOVICE_CFG_TERMINAL_DISPATCH_RETURN",
        "RENOVICE_CFG_STRUCTURED_EXACT_RETURN_ARM",
        "RENOVICE_CFG_ALLOW_MIXED_FOR_WHILE",
        "RENOVICE_CAPTURED_INDEX_KEY_TEMPORARIES",
        "RENOVICE_GENERATED_FRAME_TEMPORARIES",
        "RENOVICE_LINEAR_BREAK_REPEAT_STATES",
        "RENOVICE_COMPOUND_COMPARISON_WHILE_GUARDS",
        "RENOVICE_CANONICAL_EMPTY_ELSE_RETURN",
        "RENOVICE_CANONICAL_EMPTY_OR_TRUTHINESS",
        "RENOVICE_CANONICAL_EMPTY_RETURN_CONTINUATION",
        "RENOVICE_CANONICAL_INLINE_GUARD_CHAIN",
        "RENOVICE_CANONICAL_LATE_RETURNING_REPEAT_ARM",
        "RENOVICE_CANONICAL_LEADING_REPEAT_GUARDS",
        "RENOVICE_CANONICAL_LINEAR_RETURN_GUARDS",
        "RENOVICE_CANONICAL_LITERAL_RETURN_TAIL",
        "RENOVICE_CANONICAL_NESTED_RETURN_GUARDS",
        "RENOVICE_CANONICAL_NIL_WHILE",
        "RENOVICE_CANONICAL_OR_VALUE_TEMPORARIES",
        "RENOVICE_CANONICAL_PREDICATE_ASSOCIATION",
        "RENOVICE_CANONICAL_RETURN_ELSEIF",
        "RENOVICE_CANONICAL_RETURNING_REPEAT_ARM",
        "RENOVICE_CANONICAL_ROOT_REPEAT_LITERAL_TAIL",
        "RENOVICE_CANONICAL_ROOT_REPEAT_RETURN_TAIL",
        "RENOVICE_CANONICAL_ROOT_RETURN_TAIL",
        "RENOVICE_CFG_DISTINCT_GUARD_DISPATCH",
        "RENOVICE_CFG_EARLY_GUARD_JOIN",
        "RENOVICE_CFG_EFFECTFUL_LATCH_GUARD_REPEAT",
        "RENOVICE_CFG_EXPANDED_BOUNDARY_RETRY",
        "RENOVICE_CFG_EXPANDED_GUARD_EXIT_TAIL",
        "RENOVICE_CFG_GUARD_ATOMIC_JOIN",
        "RENOVICE_CFG_GUARD_PRIVATE_TERMINALS",
        "RENOVICE_CFG_GUARD_TERMINALS_INITIAL_RETRY",
        "RENOVICE_CFG_INTERIOR_EXIT_WHILE",
        "RENOVICE_CFG_INTERIOR_GUARD_CHAIN",
        "RENOVICE_CFG_LOOP_EARLY_RETURN_JOIN",
        "RENOVICE_CFG_PARTITION_SHARED_GUARD",
        "RENOVICE_CFG_PENDING_GUARD_JOIN",
        "RENOVICE_CFG_PREFER_PRIVATE_RETURN_TRIANGLE",
        "RENOVICE_CFG_PREFER_STRUCTURED_PLAIN",
        "RENOVICE_CFG_PRIVATE_TAIL_RETURN_GUARD",
        "RENOVICE_CFG_REJECT_OWNERSHIP_NOOP",
        "RENOVICE_CFG_RESPECT_OUTER_JOIN",
        "RENOVICE_CFG_RETRY_COMPLETE_LOOP_DISPATCH",
        "RENOVICE_CFG_SHARED_TERMINAL_EFFECT",
        "RENOVICE_CFG_TRANSPARENT_LOOP_EXIT",
        "RENOVICE_EXACT_ORDERED_PREDICATES",
        "RENOVICE_LEGACY_UNCONDITIONAL_FOR_BREAK",
        "RENOVICE_LOCALIZED_INDEX_STORE_LIFETIMES",
        "RENOVICE_MAPPED_EXIT_STATE_RELAYS",
        "RENOVICE_MULTIPLE_FORNPREP_ZERO_LIFETIMES",
        "RENOVICE_NESTED_INDEX_RESULT_LIFETIMES",
        "RENOVICE_SCOPED_STATE_PREFIX_REUSE",
    };
    for (const char* feature : defaults)
        if (!std::getenv(feature)) _putenv_s(feature, "1");
}

int main(int argc, char** argv) {
    install_certified_decompiler_defaults();
    std::string mode = (argc >= 2) ? argv[1] : "";
    if (mode == "recompile-u44" && argc >= 4) {
        if (argc >= 5) {
            std::ifstream map(long_path(argv[4]));
            if (!map) { std::fprintf(stderr, "profile: cannot read source alias map\n"); return 1; }
            std::uint32_t old_hash, new_hash;
            while (map >> std::hex >> old_hash >> new_hash) {
                const auto existing = de::source_aliases.find(old_hash);
                if (existing != de::source_aliases.end() && existing->second != new_hash) {
                    std::fprintf(stderr, "profile: ambiguous source alias\n"); return 1;
                }
                de::source_aliases[old_hash] = new_hash;
            }
            if (!map.eof()) { std::fprintf(stderr, "profile: invalid source alias map\n"); return 1; }
        }
        de::active_namehash_seed = 0x768e5ed0u;
        // Input-profile routing: a source decompiled from U43-profile bytecode by a U44 entry point
        // declares the U43 seed (select_u44_entry_profile); it is rebuilt in its own format (U43
        // opcodes and seed), the format of the stock module it came from. An alias map is a U43 ->
        // U44 translation and never applies to it.
        if (de::input_profile_routing_enabled() && argc < 5) {
            uint32_t declared = 0;
            bool has_declaration = false;
            try { has_declaration = tc::parse_name_hash_seed_directive(read_file(argv[2]), declared); }
            catch (const std::exception&) {}   // reported by cmd_recompile's own metadata parse
            if (has_declaration && declared == de::NAMEHASH_SEED_2026_06_19) {
                de::active_namehash_seed = de::NAMEHASH_SEED_2026_06_19;
                std::printf("[derecomp] source declares the U43 name-hash seed %08x: built in the U43 profile\n",
                            declared);
            }
        }
        return cmd_recompile(argc, argv);
    }
    if (mode == "recompile-u44-raw" && argc >= 4) {
        de::active_namehash_seed = de::NAMEHASH_SEED_U44;
        de::raw_source_hashes = true;
        return cmd_recompile(argc, argv);
    }
    if (mode == "decompile-mod-u44" && argc >= 3) return cmd_decompile_mod_u44(argc, argv);
    if (mode == "semantic-ir-render-module-u44" && argc >= 4)
        return cmd_semantic_ir_render_module_u44(argc, argv);
    if (mode == "ir-u44" && argc >= 3) { select_u44_entry_profile(argv[2]); return cmd_ir(argc, argv); }
    if (mode == "const-identity" && argc >= 4) return cmd_const_identity(argc, argv);
    if (mode == "cfg-identity" && argc >= 4) return cmd_cfg_identity(argc, argv);
    if (mode == "loop-exit-scan" && argc >= 3) return cmd_loop_exit_scan(argc, argv);
    if (mode == "dataflow-identity" && argc >= 4) return cmd_dataflow_identity(argc, argv);
    if (mode == "u44-rawhash-selftest") return cmd_u44_rawhash_selftest();
    if ((mode == "profile-to-u44" || mode == "profile-from-u44") && argc == 5) {
        try {
            std::ifstream stream(long_path(argv[4]));
            if (!stream) throw std::runtime_error("profile: cannot read native-name map");
            std::map<std::uint32_t, std::uint32_t> names;
            std::string line;
            while (std::getline(stream, line)) {
                if (line.empty() || line[0] == '#') continue;
                std::istringstream row(line);
                std::uint32_t a = 0, b = 0;
                if (!(row >> std::hex >> a >> b)) throw std::runtime_error("profile: invalid name map row");
                if (mode == "profile-from-u44") std::swap(a, b);
                const auto previous = names.find(a);
                if (previous != names.end() && previous->second != b) throw std::runtime_error("profile: ambiguous native-name map");
                names[a] = b;
            }
            const auto result = de::change_build_profile(read_file(argv[2]), mode == "profile-to-u44", &names);
            if (!write_file(argv[3], result)) throw std::runtime_error("profile: cannot write output");
            std::printf("PROFILE PASS %s bytes=%zu\n", mode.c_str(), result.size());
            return 0;
        } catch (const std::exception& e) { std::fprintf(stderr, "%s\n", e.what()); return 1; }
    }
    if (mode == "transcode-global-selftest") return cmd_transcode_global_selftest();
    if (mode == "closure-index-selftest") return cmd_closure_index_selftest();
    if (mode == "closure-map" && argc >= 4) return cmd_closure_map(argc, argv);
    if (mode == "semantic-ir-selftest") return cmd_semantic_ir_selftest(argc, argv);
    if (mode == "semantic-ir-readable-selftest")
        return cmd_semantic_ir_readable_selftest();
    if (mode == "semantic-ir-lowering-selftest")
        return cmd_semantic_ir_lowering_selftest(argc, argv);
    if (mode == "semantic-ir-verify" && argc >= 3) return cmd_semantic_ir_verify(argc, argv);
    if (mode == "semantic-ir-render" && argc >= 4) return cmd_semantic_ir_render(argc, argv);
    if (mode == "semantic-ir-render-module" && argc >= 4)
        return cmd_semantic_ir_render_module(argc, argv);
    if (mode == "semantic-ir-render-module-readable" && argc >= 6)
        return cmd_semantic_ir_render_module_readable(argc, argv);
    if (mode == "semantic-ir-render-module-corpus" && argc >= 3)
        return cmd_semantic_ir_render_module_corpus(argc, argv);
    if (mode == "semantic-ir-verify-corpus" && argc >= 3)
        return cmd_semantic_ir_verify_corpus(argc, argv);
    if (mode == "expr" && argc >= 3) return cmd_expr(argc, argv);
    if (mode == "struct-validate" && argc >= 3) return cmd_struct_validate(argc, argv);
    if (mode == "struct-dump" && argc >= 4) return cmd_struct_dump(argc, argv);
    if (mode == "sa-validate" && argc >= 3) return cmd_sa_validate(argc, argv);
    if (mode == "decompile" && argc >= 3) return cmd_decompile(argc, argv);
    if (mode == "decompile-mod" && argc >= 3) return cmd_decompile_mod(argc, argv);
    if (mode == "decompile-mod-raw" && argc >= 3) return cmd_decompile_mod(argc, argv, false);
    if (mode == "decompile-mod-stable" && argc >= 3)
        return cmd_decompile_mod(argc, argv, true, true);
    if (mode == "decompile-corpus" && argc >= 4) return cmd_decompile_corpus(argc, argv);
    if (mode == "skeleton" && argc >= 3) return cmd_skeleton(argc, argv);
    if (mode == "orphans" && argc >= 3) return cmd_orphans(argc, argv);
    if (mode == "backedges" && argc >= 3) return cmd_backedges(argc, argv);
    if (mode == "loop-identity" && argc >= 3) return cmd_loop_identity(argc, argv);
    if (mode == "loopfork" && argc >= 3) return cmd_loopfork(argc, argv);
    if (mode == "plan-verify" && argc >= 3) return cmd_plan_verify(argc, argv);
    if (mode == "plan-verify-corpus" && argc >= 3) return cmd_plan_verify_corpus(argc, argv);
    if (mode == "emit-validate" && argc >= 3) return cmd_emit_validate(argc, argv);
    if (mode == "expr-validate" && argc >= 3) return cmd_expr_validate(argc, argv);
    if (mode == "de-builtins" && argc >= 3) return cmd_de_builtins(argc, argv);
    if (mode == "rt-build" && argc >= 3) return cmd_rt_build(argc, argv);
    if (mode == "lbc-cmp"  && argc >= 4) return cmd_lbc_cmp(argc, argv);
    if (mode == "de-proto-diff" && argc >= 4) return cmd_de_proto_diff(argc, argv);
    if (mode == "de-fastcall" && argc >= 3) return cmd_de_fastcall(argc, argv);
    if (mode == "de-patchop" && argc >= 8) return cmd_de_patchop(argc, argv);
    if (mode == "de-forgprep" && argc >= 3) return cmd_de_forgprep(argc, argv);
    if (mode == "de-tag1audit" && argc >= 3) return cmd_de_tag1audit(argc, argv);
    if (mode == "de-globalaudit" && argc >= 3) return cmd_de_globalaudit(argc, argv);
    if (mode == "de-find" && argc >= 4) return cmd_de_find(argc, argv);
    if (mode == "de-ktags" && argc >= 3) return cmd_de_ktags(argc, argv);
    if (mode == "de-fieldaudit" && argc >= 3) return cmd_de_fieldaudit(argc, argv);
    if (mode == "de-auxhist" && argc >= 4) return cmd_de_auxhist(argc, argv);
    if (mode == "ir" && argc >= 3) return cmd_ir(argc, argv);
    if (mode == "ir-validate" && argc >= 3) return cmd_ir_validate(argc, argv);
    if (mode == "de-deadaudit" && argc >= 3) return cmd_de_deadaudit(argc, argv);
    if (mode == "de-unreach" && argc >= 3) return cmd_de_unreach(argc, argv);
    if (mode == "histops" && argc >= 3) return cmd_histops(argc, argv);
    if (mode == "de-summary" && argc >= 3) return cmd_de_summary(argc, argv);
    if (mode == "de-validate" && argc >= 3) return cmd_de_validate(argc, argv);
    if (mode == "de-recode" && argc >= 3) return cmd_de_recode(argc, argv);
    if (mode == "de-cfg" && argc >= 3) return cmd_de_cfg(argc, argv);
    if (mode == "namebase" && argc >= 3) return cmd_namebase(argc, argv);
    if (mode == "de-disasm" && argc >= 3) return cmd_de_disasm(argc, argv);
    if (mode == "histcsv" && argc >= 4) return cmd_histcsv(argc, argv);
    if (mode == "namehash" && argc >= 3) return cmd_namehash(argc, argv);
    if (mode == "transcode" && argc >= 4) return cmd_transcode(argc, argv);
    if (mode == "recompile" && argc >= 4) return cmd_recompile(argc, argv);
    if (mode == "dump" && argc >= 3) return cmd_dump(argc, argv);
    if (mode == "de-roundtrip" && argc >= 3) return cmd_de_roundtrip(argc, argv);
    if (mode == "de-roundtrip-batch" && argc >= 3) return cmd_de_roundtrip_batch(argc, argv);
    if (mode == "de-stats" && argc >= 3) return cmd_de_stats(argc, argv);
    if (mode == "compile" && argc >= 4) {
        std::string err;
        std::string bc = compile_luau(argv[2], err);
        if (bc.empty()) { std::fprintf(stderr, "[derecomp] compile failed: %s\n", err.c_str()); return 1; }
        if (!write_file(argv[3], bc)) { std::fprintf(stderr, "[derecomp] cannot write %s\n", argv[3]); return 1; }
        std::printf("[derecomp] %s -> %s : %zu bytes, luau-bytecode version byte=0x%02x\n",
                    argv[2], argv[3], bc.size(), (unsigned char)bc[0]);
        std::printf("           (M1 ok: real Luau compiler drives from C++. DE 09 03 transcode = M2-M4.)\n");
        return 0;
    }
    std::printf("DeNativeRecompiler (M1-M4)\n"
                "  compile      <in.luau> <out.luaubc>   Luau source -> Luau bytecode (via luau-compile.exe)\n"
                "  dump         <in.luaubc> [protoIdx]   parse Luau bytecode -> structure (M2 parser)\n"
                "  de-roundtrip <in.lua_B>               parse+re-emit DE 09 03, verify byte-exact (M3)\n"
                "  de-stats     <dir>                    const-tag + edge census over a corpus\n"
                "  de-proto-diff <left.lua_B> <right.lua_B> per-prototype fixed-point deltas\n"
                "  decompile    <in.lua_B> [proto] [output] native Luau source pass\n"
                "  decompile-mod <in.lua_B> [output]      recompilable module source pass\n"
                "  decompile-mod-raw <in.lua_B> [output]  one-pass source (bypass compiler canonicalization)\n"
                "  decompile-mod-stable <in.lua_B> [output] compiler-closed deterministic source pass\n"
                "  decompile-corpus <in> <out> [--abilities] native batch module source pass\n"
                "  plan-verify <in.lua_B> [proto]         pre-render semantic ownership audit\n"
                "  plan-verify-corpus <dir> [--abilities] [--json-out file] corpus ownership audit\n"
                "  semantic-ir-selftest [--json]         Phase-1 Semantic IR verifier fixtures\n"
                "  semantic-ir-readable-selftest         identifier/provenance regression fixtures\n"
                "  semantic-ir-lowering-selftest         execute exact source-lowering semantics oracles\n"
                "  semantic-ir-verify <lua_B> [proto]     build and verify read-only Semantic IR\n"
                "  semantic-ir-render <lua_B> <out> [proto] isolated fail-closed Semantic IR renderer\n"
                "  semantic-ir-render-module <lua_B> <out> render verified prototype/capture tree\n"
                "  semantic-ir-render-module-readable <lua_B> <fidelity> <readable> <map.tsv> [--semantic-sdk symbols.tsv] [--call-map calls.tsv] [--failure-readable source.luau]\n"
                "  semantic-ir-render-module-corpus <dir> [--abilities] [--compile-rendered] [--readable] [--semantic-sdk symbols.tsv]\n"
                "  semantic-ir-verify-corpus <dir> [--abilities] [--limit N] [--json-out file]\n"
                "  transcode-global-selftest              native global lowering regression\n"
                "  closure-index-selftest                 child/constant/global closure-index regression\n"
                "  closure-map <lua_B> <out.tsv>          closure edges plus exact upvalue capture contracts\n"
                "  namehash     <name>                   DE FNV name hash (self-test: GetConfigBool=0x4aec2dac)\n"
                "  transcode    <in.luaubc> <out.lua_B>  Luau bytecode -> DE 09 03 (M4 transcoder)\n"
                "  recompile    <in.luau>  <out.lua_B>   full: Luau source -> DE 09 03 (M1+M4)\n"
                "  decompile-mod-u44 <u44.lua_B> [output] U44 module source in the raw U44 name-hash namespace\n"
                "  semantic-ir-render-module-u44 <u44.lua_B> <out> Semantic IR render of U44 input\n"
                "  recompile-u44 <in.luau> <out.lua_B> [alias-map] U44 build; raw when the source declares the seed\n"
                "  recompile-u44-raw <in.luau> <out.lua_B> U44 build; X__<hex> suffixes are raw U44 hashes\n"
                "  const-identity <stock.lua_B> <candidate.lua_B> [--u44] per-prototype hash/string/key-use gate\n"
                "  cfg-identity <stock.lua_B> <candidate.lua_B> [--u44] per-prototype control-flow/operation-order gate\n"
                "  dataflow-identity <stock.lua_B> <candidate.lua_B> [--u44] [--dump=N] per-prototype reaching-origin/capture gate\n");
    return (mode.empty() ? 0 : 2);
}
