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

// Enable the U44 input profile and precompute the module's mixed hashed/string spellings.
static bool u44_prepare(const std::string& path, std::string& failure) {
    g_input_profile_u44 = true;
    ir_load_namebase();
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
    char seed[16]; std::snprintf(seed, sizeof seed, "%08x", de::NAMEHASH_SEED_U44);
    std::string out = std::string(tc::name_hash_seed_directive_prefix()) + seed + "\n";
    for (const std::string& name : scan.hashed[0]) out += tc::hashed_global_directive_prefix() + name + "\n";
    for (const std::string& name : scan.hashed[1]) out += tc::hashed_field_directive_prefix() + name + "\n";
    for (const auto& item : scan.import_classes)
        out += tc::import_class_directive_prefix() + item.first + "=" + item.second + "\n";
    header = out;
    return true;
}

static int cmd_decompile_mod_u44(int argc, char** argv) {
    if (std::getenv("RENOVICE_COMPILER_CANONICALIZE")) {
        std::fprintf(stderr, "decompile-mod-u44: compiler canonicalization is U43-only\n");
        return 1;
    }
    std::string failure, source, header;
    if (!u44_prepare(argv[2], failure)) {
        std::fprintf(stderr, "decompile-mod-u44: %s\n", failure.c_str()); return 1;
    }
    if (!decompile_module_source(argv[2], source, failure)) {
        std::fprintf(stderr, "decompile-mod-u44: %s\n", failure.c_str()); return 1;
    }
    if (!u44_source_header(argv[2], header, failure)) {
        std::fprintf(stderr, "decompile-mod-u44: %s\n", failure.c_str()); return 1;
    }
    source = header + source;
    if (argc >= 4) {
        if (!write_file(argv[3], source)) {
            std::fprintf(stderr, "decompile-mod-u44: cannot write %s\n", argv[3]); return 1;
        }
    } else {
        std::printf("%s\n", source.c_str());
    }
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
    char seed[16]; std::snprintf(seed, sizeof seed, "%08x", de::NAMEHASH_SEED_U44);
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
