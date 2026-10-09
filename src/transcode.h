// transcode.h - transcode STOCK Luau bytecode (from luau-compile.exe) into a DE `09 03` .lua_B body.
// C++ port of RENOVICE_Toolkit/compiler/luau_to_de.py. Pipeline BACK end: your.lua -> luau-compile --binary
// -> [luau_bc.h parse] -> [here] -> DE bytecode. Reuses de_container.h primitives (enc_vi/enc_consts) and
// de_namehash.h. Verified target: byte-identical to luau_to_de.py output (which is proven in-game).
#pragma once
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstring>
#include <cstdlib>
#include <climits>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <stdexcept>
#include "luau_bc.h"
#include "de_container.h"
#include "de_namehash.h"
#include "shared_protos.h"

namespace tc {

// Lossless source metadata emitted by the decompiler. DE distinguishes ordinary string-keyed
// module globals from FNV-hashed engine-injected script properties, even though both render as the
// same Luau identifier. Upstream Luau bytecode erases that distinction, so preserve it explicitly
// across the editable-source boundary. One name per line keeps diffs readable and parsing strict.
inline const char* hashed_global_directive_prefix() { return "-- RENOVICE_HASH_GLOBAL: "; }
inline const char* hashed_field_directive_prefix() { return "-- RENOVICE_HASH_FIELD: "; }

inline std::set<std::string> parse_name_directives(const std::string& source,
                                                   const std::string& prefix) {
    std::set<std::string> result;
    size_t start = 0;
    while (start <= source.size()) {
        const size_t end = source.find('\n', start);
        std::string line = source.substr(start,
            end == std::string::npos ? std::string::npos : end - start);
        if (!line.empty() && line.back() == '\r') line.pop_back();
        if (line.compare(0, prefix.size(), prefix) == 0) {
            const std::string name = line.substr(prefix.size());
            if (name.empty() || name.find_first_of(" \t\r\n,") != std::string::npos)
                throw std::runtime_error("invalid Renovice name-kind directive");
            result.insert(name);
        }
        if (end == std::string::npos) break;
        start = end + 1;
    }
    return result;
}

inline std::set<std::string> parse_hashed_global_directives(const std::string& source) {
    return parse_name_directives(source, hashed_global_directive_prefix());
}

inline std::set<std::string> parse_hashed_field_directives(const std::string& source) {
    return parse_name_directives(source, hashed_field_directive_prefix());
}

// Name-hash namespace declaration. A source carrying `-- RENOVICE_NAME_HASH_SEED: 768e5ed0` was
// decompiled from U44 bytecode: plain names are hashed with that seed and every `X__aabbccdd`
// suffix is the RAW stock hash in that namespace (see de::raw_source_hashes). Absent => legacy
// contract. More than one distinct declaration, or a malformed seed, is rejected.
inline const char* name_hash_seed_directive_prefix() { return "-- RENOVICE_NAME_HASH_SEED: "; }

inline bool parse_name_hash_seed_directive(const std::string& source, uint32_t& seed) {
    const std::set<std::string> values =
        parse_name_directives(source, name_hash_seed_directive_prefix());
    if (values.empty()) return false;
    if (values.size() != 1) throw std::runtime_error("conflicting RENOVICE_NAME_HASH_SEED directives");
    const std::string& text = *values.begin();
    if (text.size() != 8) throw std::runtime_error("invalid RENOVICE_NAME_HASH_SEED directive");
    for (char c : text)
        if (!std::isxdigit((unsigned char)c)) throw std::runtime_error("invalid RENOVICE_NAME_HASH_SEED directive");
    seed = (uint32_t)std::strtoul(text.c_str(), nullptr, 16);
    return true;
}

// In a raw-hash source, an identifier carrying an explicit hash suffix can only denote a native
// name slot, so hashed-capable positions (global reads/writes, field reads) keep the hash class
// even when no RENOVICE_HASH_* directive names it. Legacy sources are unaffected.
inline bool raw_hash_spelling(const std::string& name) {
    uint32_t ignored = 0;
    return de::raw_source_hashes && de::parse_hash_suffix(name, ignored);
}

// ---- little-endian packers ----
inline std::string pack_u32(uint32_t v) { char b[4]; std::memcpy(b, &v, 4); return std::string(b, 4); }
inline std::string pack_i32(int32_t v)  { char b[4]; std::memcpy(b, &v, 4); return std::string(b, 4); }
inline std::string pack_f64(double v)   { char b[8]; std::memcpy(b, &v, 8); return std::string(b, 8); }

// ---- Luau op name -> DE op number (empirically confirmed vs DE cache). -1 = drop (e.g. PREPVARARGS). ----
inline const std::map<std::string, int>& OPMAP() {
    static const std::map<std::string, int> m = {
        // --- VALIDATED (proven in-game; see OPCODE_MAP.md) ---
        // NAMECALL=0x2d (corpus: every 0x2d is followed by 0x54 CALL = obj:method(); 0x36 appears ZERO times).
        // GETGLOBAL UNMAPPED: 0x2d is NAMECALL not a global read (this was the cert_v6 "index number with boolean"
        // crash). DE lowers globals to GETIMPORT; bare GETGLOBAL TODO (lower->GETIMPORT). Unmapped => safe compile-error.
        {"GETIMPORT",0x46},{"NAMECALL",0x2d},{"SETGLOBAL",0x02},{"CALL",0x54},{"CALLFB",0x54},
        {"LOADN",0x12},{"LOADK",0x4e},{"LOADNIL",0x0d},{"LOADB",0x04},{"MOVE",0x14},{"CONCAT",0x28},
        // REG-KEY table ops, corpus-derived by DATAFLOW (0x15/0x3d are the const-STRING-key field ops, not these):
        //   GETTABLE (read  t[k]) = 0x01  R[A]=R[B][R[C]]  — AnchorMgr p4: R7=R8[R6] with R6 = for-loop index,
        //                                  and R7 is immediately dereferenced as a table on the next insn.
        //   SETTABLE (write t[k]) = 0x2a  R[B][R[C]]=R[A]  — DragScroll p1: the SAME R6 stored into two different
        //                                  tables at key R5; p2 does LOADNIL R7 then 0x2a (t[k]=nil). Read is impossible.
        // Both 4B, and both match Luau's operand layout verbatim (A=dest/value, B=table, C=key) -> direct passthrough.
        // NOTE: 0x2a was previously mis-mapped as GETTABLE (a WRITE emitted for every read); reg-key reads were unused
        // until now (cert_v7 only exercises .field access = 0x3d/0x15), so nothing shipped with the bad mapping.
        {"RETURN",0x29},{"GETUPVAL",0x13},{"SETUPVAL",0x53},{"GETTABLE",0x01},{"SETTABLE",0x2a},
        // PREPVARARGS = 0x11, NOT droppable: DE needs the vararg prologue to set up `...` (corpus: every
        // vararg proto starts with 0x11 — SpatialLib p2, CheckSourceObjectType p1). Dropping it made
        // GETVARARGS read nothing (in-game V_ONE failure). A = number of fixed params (direct passthrough).
        {"NEWTABLE",0x2c},{"SETLIST",0x3f},{"GETVARARGS",0x4c},{"PREPVARARGS",0x11},
        // FASTCALL* are pure OPTIMIZATION HINTS: Luau emits the complete slow path right after them
        // (arg MOVE/LOADK + GETIMPORT fn + CALL), so DROPPING them yields correct code via the normal
        // call path — only the builtin fast path is lost. DE's compiler has no fastcall equivalent.
        // COVERAGE is a profiling no-op. (Dropped ops are skipped before any width/jump handling.)
        {"FASTCALL",-1},{"FASTCALL1",-1},{"FASTCALL2",-1},{"FASTCALL2K",-1},{"FASTCALL3",-1},{"COVERAGE",-1},
        {"ADD",0x49},{"NOT",0x50},{"LENGTH",0x4d},
        {"DUPCLOSURE",0x42},{"NEWCLOSURE",0x16},
        // JUMPBACK has its own DE byte (0x25) but 0x40 JUMP is proven and works for both directions;
        // emit the real 0x25 for certification with RENOVICE_NATIVE=JUMPBACK.
        {"JUMP",0x40},{"JUMPBACK",0x40},{"JUMPIF",0x4b},{"JUMPIFNOT",0x18},
        {"FORNPREP",0x47},{"FORNLOOP",0x0a},
        // GENERIC FOR (corpus-derived, 3 files): prep jumps FORWARD to the loop op, loop jumps BACK to the body,
        // both with the standard op+4 offset base. `pairs`/custom-iterator prep = 0x30, `ipairs` prep = 0x1b.
        // FORGLOOP = 0x1e (8B); its aux is a DIRECT passthrough of Luau's (nvars, bit31 set = inext flavour) —
        // verified identical: pairs aux=0x00000002, ipairs aux=0x80000002 in both Luau and the DE corpus.
        // FORGPREP (generic) = 0x0b, CERTIFIED in-game 2026-07-25 (V13_FORGPREP sum=60 count=3
        // calls=4). It was 0x30, which is FORGPREP_NEXT — the pairs-SPECIALISED prep. That worked
        // only because the specialised preps validate their iterator and fall back to generic
        // behaviour, which is exactly why the v10 generic-for cert passed and hid the error.
        {"FORGPREP",0x0b},{"FORGPREP_NEXT",0x30},{"FORGPREP_INEXT",0x1b},{"FORGLOOP",0x1e},
        // SETTABLEKS=0x15 (corpus field-write t.field=v; 0x0c was a cache-variant -> the access-violation CRASH).
        {"SETTABLEN",0x2e},{"SETTABLEKS",0x15},{"ADDK",0x38},{"CAPTURE",0x35},{"DIVK",0x32},
        // --- ARITH: corpus-derived (proto-level source<->bytecode) THEN isolated-probe CONFIRMED in-game
        // (bracket-check via ordered compares; deterministic 3x, zero flip-flop). Real bug was ONLY MUL 0x09->0x22.
        // CONFIRMED: SUB=0x07 (SUB07_OK/SUB06_hi), MUL=0x22 (MUL22_OK/MUL09_lo), DIV=0x1a (DIV1a_OK/DIV32_hi),
        // MOD=0x55 (MOD55_OK/MOD45_hi), MINUS/UNM=0x0e (MINUS0e_OK). All R[A]=R[B] op R[C], normal order.
        // POW: 0x08 is POWK (pow-by-CONSTANT; `x^2`); reg-reg `a^b` needs a different byte (TBD, rare, not
        // needed for Mallet damage/10). EasingLib proto[0] `unk*unk2/unk3+unk4` = 0x22 0x1a 0x49 anchored MUL/DIV.
        {"SUB",0x07},{"MUL",0x22},{"DIV",0x1a},{"MOD",0x55},{"MINUS",0x0e},{"MODK",0x3c},
        // POWK=0x08 CONFIRMED byte-faithful vs corpus (MechEventRepeater proto[0] `(cl+1)^2.5`: 0x08 R[A]=R[B]^K[C],
        // exponent = tag-2 number const, identical structure to ours). MULK=0x09 (the `*0.0045` right after).
        {"POWK",0x08},{"MULK",0x09},{"SUBRK",0x06},   // SUBRK (const-reg) = 0x06 R[A]=K[B]-R[C]. SUBK (reg-const) LOWERED (no DE op).
        // Found by value-reporting substitution probes (they print the observed result, so semantics are read
        // off directly rather than guessed).  Both were previously declared UNSUPPORTABLE — they were in the
        // corpus all along, just mis-bucketed as "specialized variants of ops we already emit".
        {"POW",0x45},    // reg-reg power: 2^10 -> 1024 in-game (QPW), matches the POWK control (QPK)
        {"IDIVK",0x24},  // floor-div by constant R[A]=R[B]//K[C]: 10//4 -> 2 and 10//3 -> 3 (rules out MODK/ANDK)
        {"DIVRK",0x3b},   // K[B]/R[C] — EXT DIV_K, the const-numerator counterpart of DIVK 0x32
        // IDIV (reg-reg `a // b`) = 0x00, CERTIFIED in-game 2026-07-25: V14_MODR reported r=3 for
        // 17 op 5, i.e. 17//5. It was decoded as "MODR" (R[C]%R[B]) AND separately declared
        // "unmapped, no DE byte exists" so `a // b` hard-errored. Both wrong: it is the reg-reg
        // partner of IDIVK 0x24 and was in the corpus the whole time, mislabelled.
        {"IDIV",0x00},
        {"NOP",-1},       // no-op: drop
        // POW (reg-reg `a^b`) still TBD: 0x08 is POWK not reg-reg POW (probe POW08_lo). Find real reg-reg POW byte.
        // GETTABLEKS (field read t.field) = 0x3d GETFIELD_c (corpus: 0x15 write + 0x3d read share key+slot; 0x17
        // does NOT read the field -> returned nil). tag-3 string key, Luau cache-slot in C. NOT 0x17.
        {"GETTABLEN",0x44},{"CLOSEUPVALS",0x39},{"DUPTABLE",0x4f},{"GETTABLEKS",0x3d},
        // fused compare-and-branch. Layout A=lhs, offset in D, aux=rhs; jump base op+4. Op = the DE compare whose
        // x86 jump-condition (EXT hint) matches the Luau branch: 0x23=jb(<) 0x21=jbe(<=) 0x1c=ja(>) 0x33=jae(>=).
        // MEASURED in-game (6-probe truth table): 0x1c=jae(>=), 0x33=ja(>), 0x23=jb(<), 0x21=jbe(<=).
        // NOTLT=jump-if->= -> 0x1c ; NOTLE=jump-if-> -> 0x33 ; LT=jump-if-< -> 0x23 ; LE=jump-if-<= -> 0x21.
        // NOTEQ=0x20 (cert). JUMPIFEQ (0x3a) still miscalibrated -> avoid `~=` in source (use `==...else`).
        // JUMPIFNOTEQ=0x27 (CMP_EQ_disp2, the value-comparing variant) MEASURED in-game: it jumps on not-equal
        // (base 0x20/0x3a are tag-only and never jump). JUMPIFEQ still calibrating.
        // JUMPIFLT/JUMPIFLE were SWAPPED. Measured in-game at the BOUNDARY (a<=a must be true, a<a must be
        // false) via value-producing compares: LT21_OK + LE23_OK (0x21 never jumped on 3<=3 => it is strict <).
        // The old calibration only ever exercised the jump-if-NOT polarity, so the swap went unnoticed; it made
        // every `repeat ... until` overshoot by one iteration. NOT-forms (0x1c/0x33) are boundary-verified correct.
        {"JUMPIFEQ",0x37},{"JUMPIFNOTEQ",0x27},{"JUMPIFLT",0x21},{"JUMPIFNOTLT",0x1c},{"JUMPIFLE",0x23},{"JUMPIFNOTLE",0x33},
        // NOTE STILL TODO: variable-width NEWCLOSURE (nups>0, needs DE upvalue-descriptor format),
        // SETLIST/SETTABLEN operand semantics (count/base, -1 bias), SUBK/POWK/SUBRK/IDIV (no DE target).
    };
    return m;
}

inline bool is_bx_op(const std::string& n)   { return n=="LOADN"||n=="LOADK"||n=="DUPCLOSURE"||n=="NEWCLOSURE"||n=="DUPTABLE"; }
inline bool is_jump_op(const std::string& n) { return n=="JUMP"||n=="JUMPBACK"||n=="JUMPIF"||n=="JUMPIFNOT"||n=="FORNPREP"||n=="FORNLOOP"
                                                   ||n=="FORGPREP"||n=="FORGPREP_NEXT"||n=="FORGPREP_INEXT"; }   // 4B generic-for preps
// Fused compare-and-branch: 8 bytes (op word carries A=lhs + recomputed branch offset; aux word = rhs reg).
inline bool is_fused_cmp(const std::string& n) {
    return n=="JUMPIFEQ"||n=="JUMPIFLT"||n=="JUMPIFLE"||n=="JUMPIFNOTEQ"||n=="JUMPIFNOTLE"||n=="JUMPIFNOTLT";
}
// 8-byte branch ops: op word carries A + the recomputed offset, aux word is passed through verbatim.
// FORGLOOP (0x1e) has the same shape as a fused compare; its aux = nvars | bit31(inext), same in Luau and DE.
inline bool is_jump8_op(const std::string& n) { return is_fused_cmp(n) || n=="FORGLOOP"; }
inline bool is_name_aux_op(const std::string& n) { return n=="NAMECALL"||n=="GETGLOBAL"||n=="SETGLOBAL"||n=="GETTABLEKS"||n=="SETTABLEKS"; }
// const-RHS equality jumps (`if x == <literal>`). DE has NO jump-if-not-equal-to-const op, so we LOWER these to
// LOAD<const> scratch + reg-reg fused compare (0x27 NOTEQ / 0x20 EQ) — all proven ops. (DE itself lowers const ops.)
inline bool is_jumpxeqk(const std::string& n) { return n=="JUMPXEQKN"||n=="JUMPXEQKS"||n=="JUMPXEQKB"; }  // KNIL handled natively by 0x3a

// ---------------------------------------------------------------------------------------------
// NATIVE-EMISSION KNOB (certification only — production output must keep the proven lowerings).
//
// 18 DE opcodes appear in real scripts but are never emitted by us: we either LOWER them to proven
// primitives or DROP them. That makes them impossible to certify in-game — nothing we compile
// reaches them — so their meanings rest on corpus inference alone. They are precisely what the M6
// DECOMPILER must read, so being wrong about one produces plausible-looking WRONG source.
//
// RENOVICE_NATIVE=<comma list> makes a chosen op emit natively so a cert CAN reach it.
//   e.g. RENOVICE_NATIVE=AND,OR,SUBK,JUMPBACK,JUMPXEQKN,JUMPXEQKS,JUMPXEQKB
// ALWAYS confirm with `derecomp histops <module>` that the opcode really is present, and that a
// knob-off build has zero — a cert that never reaches the code proves nothing.
// ---------------------------------------------------------------------------------------------
inline bool native_on(const char* name) {
    const char* e = std::getenv("RENOVICE_NATIVE");
    if (!e || !*e) return false;
    std::string hay = e, needle = name;
    for (auto& c : hay) c = (char)std::toupper((unsigned char)c);
    for (auto& c : needle) c = (char)std::toupper((unsigned char)c);
    size_t p = 0;
    while ((p = hay.find(needle, p)) != std::string::npos) {          // match whole comma-separated items only
        bool lok = (p == 0) || hay[p-1] == ',';
        size_t e2 = p + needle.size();
        bool rok = (e2 == hay.size()) || hay[e2] == ',';
        if (lok && rok) return true;
        p = e2;
    }
    return false;
}
// NAMECALL always resolves its name by FNV hash. Globals and field reads are classified separately
// from lossless source metadata because the shipped corpus uses BOTH forms: ordinary exports such as
// OnInit are string-keyed, while engine-native names and injected properties may be hashed. Field
// writes remain string-keyed. Upstream Luau bytecode alone cannot retain these distinctions.
inline bool is_read_name_op(const std::string& n) { return n=="NAMECALL"; }
inline bool is_de_width8(int op) {
    // full DE width-8 (op+aux) set (ee_disasm_rt2 WIDTH8). 0x17=GETTABLEKS carries its name-hash aux.
    static const std::set<int> w = {0x02,0x03,0x0c,0x0f,0x15,0x17,0x1c,0x1e,0x20,0x21,0x23,0x26,0x27,0x2c,
                                    0x2d,0x33,0x34,0x36,0x37,0x3a,0x3d,0x3f,0x41,0x43,0x46,0x4a};
    return w.count(op) != 0;
}

// OPMAP lookup with per-op env override (for in-game calibration, e.g. RENOVICE_NEQ_OP=0x37). Returns the DE
// op number, -1 for drop, or INT_MIN if the Luau op has no mapping.
inline int opmap_lookup(const std::string& nm) {
    std::string ev = "RENOVICE_OP_" + nm;                                  // per-op override, e.g. RENOVICE_OP_SUB=0x07
    const char* e = std::getenv(ev.c_str());
    if (e && *e) return (int)std::strtol(e, nullptr, 0);
    auto it = OPMAP().find(nm);
    return (it == OPMAP().end()) ? INT_MIN : it->second;
}

// const indices that are unconditionally hashed NAME strings (NAMECALL + import path parts).
inline std::set<uint32_t> classify_names(const luau::Proto& p) {
    std::set<uint32_t> names;
    for (const luau::Insn& ins : p.insns)
        if (is_read_name_op(ins.name()) && ins.has_aux) names.insert(ins.aux & 0xFFFF);   // reads hash; writes stay tag-3 string
    for (const luau::Const& c : p.consts) {
        if (c.tag == luau::C_IMPORT) {
            uint32_t v = c.u;
            int cnt = (v >> 30) & 3;
            uint32_t ids[3] = { (v >> 20) & 0x3ff, (v >> 10) & 0x3ff, v & 0x3ff };
            for (int k = 0; k < cnt; ++k) names.insert(ids[k]);
        }
    }
    return names;
}

inline bool import_root_is_shared_T(const luau::Module& module, const luau::Proto& proto,
                                    uint32_t descriptor) {
    const int count = (descriptor >> 30) & 3;
    const uint32_t root = (descriptor >> 20) & 0x3ff;
    if (count < 1 || root >= proto.consts.size() || proto.consts[root].tag != luau::C_STR)
        return false;
    const std::string name = luau::sstr(module, proto.consts[root].u);
    if (name == "_T") return true;
    // Raw-hash sources may spell the shared-table root by its exact hash (`Name__9828c6d9` in U44).
    // It is the same native name, so the same import-path rule applies.
    uint32_t hash = 0;
    return de::raw_source_hashes && de::parse_hash_suffix(name, hash)
        && hash == de::de_name_hash("_T");
}

// Import-path hash classes that differ from the default rule (root hashed; members strings under
// `_T`, hashed otherwise). Stock U44 also keeps members of engine-injected script properties
// (`EndColor.x`, `floatTime.minValue`) and of string-keyed roots (`package.seeall`) as tag-3
// strings, which the source spelling alone cannot express. The U44 decompiler records every such
// path as `-- RENOVICE_IMPORT_CLASS: EndColor.x=HS` (one class letter per component).
inline const char* import_class_directive_prefix() { return "-- RENOVICE_IMPORT_CLASS: "; }
inline std::map<std::string, std::string> import_class_overrides;

inline std::map<std::string, std::string> parse_import_class_directives(const std::string& source) {
    std::map<std::string, std::string> result;
    for (const std::string& entry : parse_name_directives(source, import_class_directive_prefix())) {
        const size_t equals = entry.rfind('=');
        if (equals == std::string::npos || equals == 0)
            throw std::runtime_error("invalid RENOVICE_IMPORT_CLASS directive");
        const std::string path = entry.substr(0, equals), classes = entry.substr(equals + 1);
        const size_t components = 1 + (size_t)std::count(path.begin(), path.end(), '.');
        if (classes.empty() || classes.size() != components || components > 3
            || classes.find_first_not_of("HS") != std::string::npos)
            throw std::runtime_error("invalid RENOVICE_IMPORT_CLASS directive");
        const auto inserted = result.emplace(path, classes);
        if (!inserted.second && inserted.first->second != classes)
            throw std::runtime_error("conflicting RENOVICE_IMPORT_CLASS directives for " + path);
    }
    return result;
}

// Per-position hash class of one GETIMPORT descriptor.
inline std::array<bool, 3> import_component_hashed(const luau::Module& module, const luau::Proto& proto,
                                                   uint32_t descriptor) {
    const bool shared_T = import_root_is_shared_T(module, proto, descriptor);
    std::array<bool, 3> hashed = { true, !shared_T, !shared_T };
    if (import_class_overrides.empty()) return hashed;
    const int count = (descriptor >> 30) & 3;
    const uint32_t ids[3] = { (descriptor >> 20) & 0x3ff, (descriptor >> 10) & 0x3ff, descriptor & 0x3ff };
    std::string path;
    for (int position = 0; position < count; ++position) {
        if (ids[position] >= proto.consts.size() || proto.consts[ids[position]].tag != luau::C_STR)
            return hashed;
        if (position) path += '.';
        path += luau::sstr(module, proto.consts[ids[position]].u);
    }
    const auto found = import_class_overrides.find(path);
    if (found == import_class_overrides.end()) return hashed;
    if ((int)found->second.size() != count)
        throw std::runtime_error("RENOVICE_IMPORT_CLASS component count mismatch for " + path);
    for (int position = 0; position < count; ++position) hashed[position] = found->second[position] == 'H';
    return hashed;
}

// Raw-hash sources only: constants whose GETTABLEKS / GETGLOBAL / SETGLOBAL uses are string-keyed.
// A dual-use constant (string here, hashed elsewhere, e.g. as an import member) receives a hash
// duplicate; these string-class instructions must keep the original tag-3 operand.
struct NameUseClasses { std::set<uint32_t> string_fields, string_globals; };

inline uint32_t remap_import_component(uint32_t descriptor, int position, uint32_t index) {
    if (index > 0x3ff)
        throw std::runtime_error("GETIMPORT remapped constant exceeds 10-bit descriptor range");
    const int shifts[3] = {20, 10, 0};
    const uint32_t mask = 0x3ffu << shifts[position];
    return (descriptor & ~mask) | (index << shifts[position]);
}

// Luau consts -> DE const list (names -> tag1 hash; value strings -> tag3 pool).
// SHARED-CONST AND IMPORT-PATH RULES, proven against the full original ability corpus and live Rhino:
//  * NAMECALL + any string-context use: keep STRING for the string use, append HASH, remap NAMECALL.
//  * `_T` compound imports: hash the root but preserve every nested path component as a tag-3 STRING.
//    The original 286-module ability corpus contains 8,280/8,280 such compound paths and no exception.
//  * non-`_T` compound imports (for example `table.insert`): hash every path component. The original
//    ability corpus contains 6,719/6,719 such paths and no exception.
//  * a constant needed by both hashed and string contexts receives one hash duplicate; only the hashed
//    instruction/import uses are remapped. This preserves mutable `_T` identity without weakening
//    ordinary library imports.
inline std::vector<de::Const> transcode_consts(const luau::Module& m, const luau::Proto& p,
                                               std::vector<std::string>& pool, std::map<std::string, int>& s2i,
                                               std::map<uint32_t, uint32_t>& hash_remap,
                                               std::map<uint32_t, uint32_t>& import_descriptor_remap,
                                               const std::set<std::string>& hashed_globals = {},
                                               const std::set<std::string>& hashed_fields = {},
                                               NameUseClasses* name_classes = nullptr) {
    std::set<uint32_t> hash_set, str_set;
    // A string constant can also be an import/method name in the same
    // prototype. Value operands must keep tag-3 strings, even when no field
    // write exists. Omitting these uses turned `type(x) == "table"` into a
    // comparison with the FNV name hash when that prototype used table.concat.
    const auto value_use = [&](uint32_t index) {
        if (index >= p.consts.size())
            throw std::runtime_error("value constant index outside prototype");
        if (p.consts[index].tag == luau::C_STR) str_set.insert(index);
    };
    for (const luau::Insn& ins : p.insns) {
        const std::string nm = ins.name();
        if (nm == "LOADK") value_use(static_cast<uint32_t>(ins.B | (ins.C << 8)));
        else if (nm == "LOADKX" || nm == "FASTCALL2K") value_use(ins.aux);
        else if (nm == "JUMPXEQKS") value_use(ins.aux & 0x00ffffffu);
        else if (nm == "ADDK" || nm == "SUBK" || nm == "MULK" || nm == "DIVK"
            || nm == "MODK" || nm == "POWK" || nm == "IDIVK"
            || nm == "ANDK" || nm == "ORK") value_use(ins.C);
        else if (nm == "SUBRK" || nm == "DIVRK") value_use(ins.B);
        if (nm == "NAMECALL" && ins.has_aux) {
            hash_set.insert(ins.aux & 0xFFFF);
        }
        else if ((nm == "SETGLOBAL" || nm == "GETGLOBAL") && ins.has_aux) {
            const uint32_t index = ins.aux & 0xffffu;
            const bool hash = index < p.consts.size()
                && p.consts[index].tag == luau::C_STR
                && (hashed_globals.count(luau::sstr(m, p.consts[index].u))
                    || raw_hash_spelling(luau::sstr(m, p.consts[index].u)));
            (hash ? hash_set : str_set).insert(index);
            if (!hash && name_classes) name_classes->string_globals.insert(index);
        }
        else if (nm == "GETTABLEKS" && ins.has_aux) {
            const uint32_t index = ins.aux & 0xffffu;
            const bool hash = index < p.consts.size()
                && p.consts[index].tag == luau::C_STR
                && (hashed_fields.count(luau::sstr(m, p.consts[index].u))
                    || raw_hash_spelling(luau::sstr(m, p.consts[index].u)));
            (hash ? hash_set : str_set).insert(index);
            if (!hash && name_classes) name_classes->string_fields.insert(index);
        }
        // Field writes are always tag-3 in the full corpus, including when a read of the same source
        // name is hashed. The dual-use remap therefore applies only to GETTABLEKS below.
        else if (nm == "SETTABLEKS" && ins.has_aux) str_set.insert(ins.aux & 0xFFFF);
    }
    for (const luau::Const& c : p.consts) {
        if (c.tag == luau::C_TABLE) {
            for (uint32_t key : c.keys) value_use(key);
        } else if (c.tag == luau::C_TABLEK) {
            for (const auto& item : c.items) {
                value_use(item.first);
                if (item.second >= 0) value_use(static_cast<uint32_t>(item.second));
            }
        }
    }
    for (const luau::Const& c : p.consts) if (c.tag == luau::C_IMPORT) {
        uint32_t v = c.u; int cnt = (v >> 30) & 3; uint32_t ids[3] = { (v >> 20) & 0x3ff, (v >> 10) & 0x3ff, v & 0x3ff };
        const std::array<bool, 3> hashed = import_component_hashed(m, p, v);
        for (int k = 0; k < cnt; ++k) {
            if (!hashed[k]) str_set.insert(ids[k]);
            else hash_set.insert(ids[k]);
        }
    }

    // Original constant indices stay stable. Pre-assign appended hash indices
    // so tag-4 import descriptors can be rewritten during the first pass.
    uint32_t next_hash_index = static_cast<uint32_t>(p.consts.size());
    for (size_t i = 0; i < p.consts.size(); ++i)
        if (p.consts[i].tag == luau::C_STR && hash_set.count(static_cast<uint32_t>(i))
            && str_set.count(static_cast<uint32_t>(i)))
            hash_remap[static_cast<uint32_t>(i)] = next_hash_index++;

    for (const luau::Const& c : p.consts) if (c.tag == luau::C_IMPORT) {
        uint32_t rewritten = c.u;
        const int count = (c.u >> 30) & 3;
        const uint32_t ids[3] = {
            (c.u >> 20) & 0x3ff, (c.u >> 10) & 0x3ff, c.u & 0x3ff,
        };
        const std::array<bool, 3> hashed = import_component_hashed(m, p, c.u);
        for (int position = 0; position < count; ++position) {
            const bool hashed_context = hashed[position];
            auto remap = hash_remap.find(ids[position]);
            if (hashed_context && remap != hash_remap.end())
                rewritten = remap_import_component(rewritten, position, remap->second);
        }
        import_descriptor_remap[c.u] = rewritten;
    }

    std::vector<de::Const> out;
    std::vector<std::pair<uint32_t, std::string>> dual;                     // (luau idx, string) needing a hash dup
    for (size_t i = 0; i < p.consts.size(); ++i) {
        const luau::Const& c = p.consts[i];
        de::Const d;
        switch (c.tag) {
            case luau::C_NIL:     d.tag = 0; break;
            // DE OVERLOADS tag 1: it is upstream Luau's BOOLEAN *and* DE's 4-byte FNV name hash,
            // disambiguated by operand POSITION. Proven by `derecomp de-tag1audit` over the corpus:
            // 1,263,066 tag-1 refs from NAME positions never carry payload 0/1, while all 42 refs
            // from VALUE positions carry only 0/1. So a boolean emits as tag 1 with a 4-byte 0/1.
            // Without this case the transcoder THREW on any `{ flag = true }` — i.e. a very common
            // table constructor could not be recompiled at all.
            case luau::C_BOOL:    d.tag = 1; d.raw = pack_u32(c.bval ? 1u : 0u); break;
            case luau::C_NUM:     d.tag = 2; d.raw = pack_f64(c.num); break;
            case luau::C_INT:     d.tag = 9; d.sign = (c.inum >= 0) ? 0 : 1; d.val = (uint64_t)(c.inum >= 0 ? c.inum : -c.inum); break;
            case luau::C_IMPORT: {
                d.tag = 4;
                auto rewritten = import_descriptor_remap.find(c.u);
                d.raw = pack_u32(rewritten == import_descriptor_remap.end() ? c.u : rewritten->second);
            } break;
            case luau::C_VEC:     d.tag = 7; { char b[16]; std::memcpy(b, c.vec, 16); d.raw.assign(b, 16); } break;
            case luau::C_CLOSURE: d.tag = 6; d.idx = c.u; break;
            case luau::C_TABLE:   d.tag = 5; for (uint32_t k : c.keys) d.list.push_back(k); break;
            case luau::C_TABLEK:  d.tag = 8; for (auto& it : c.items) d.items.emplace_back(it.first, pack_i32(it.second)); break;
            case luau::C_STR: {
                std::string s = luau::sstr(m, c.u);
                const bool dual_use = hash_remap.count(static_cast<uint32_t>(i)) != 0;
                if (hash_set.count((uint32_t)i) && !str_set.count((uint32_t)i)) {
                    d.tag = 1; d.raw = pack_u32(de::resolve_name_hash(s));
                }
                else {
                    auto it = s2i.find(s);
                    int idx;
                    if (it == s2i.end()) { idx = (int)pool.size(); s2i[s] = idx; pool.push_back(s); }
                    else idx = it->second;
                    d.tag = 3; d.idx = (uint32_t)(idx + 1);                 // 1-based pool index
                    if (dual_use) dual.push_back({ (uint32_t)i, s });
                }
            } break;
            default: throw std::runtime_error("unhandled luau const tag " + std::to_string(c.tag));
        }
        out.push_back(std::move(d));
    }
    for (auto& du : dual) {                                                // append tag-1 hash dups for hashed uses
        de::Const h; h.tag = 1; h.raw = pack_u32(de::resolve_name_hash(du.second));
        if (hash_remap.at(du.first) != out.size())
            throw std::runtime_error("internal hash-remap index drift");
        out.push_back(std::move(h));
    }
    return out;
}

// Luau insns -> DE code bytes + sizecode + maxstack (may grow if a JUMPXEQK is lowered w/ a scratch reg).
struct CodeResult { std::string code; int sizecode; int maxstack; };
inline CodeResult transcode_code(const luau::Proto& p,
                                 const std::map<uint32_t, uint32_t>& hash_remap,
                                 const std::map<uint32_t, uint32_t>& import_descriptor_remap,
                                 const NameUseClasses* name_classes = nullptr) {
    const auto& ins = p.insns;
    int n = (int)ins.size();
    int maxstack = p.mx;
    std::vector<int> luau_wpos(n);
    int w = 0;
    for (int i = 0; i < n; ++i) { luau_wpos[i] = w; w += ins[i].has_aux ? 2 : 1; }
    int end_word = w;
    std::map<int, int> wpos_to_idx;
    for (int i = 0; i < n; ++i) wpos_to_idx[luau_wpos[i]] = i;
    auto luau_target = [&](int i) -> int {                                 // -1 == None (unresolved)
        // Luau branch offset D is relative to pc AFTER the OP WORD (VM: insn=*pc++; pc+=D; aux is skipped
        // separately), so the base is +1 regardless of aux -- NOT +2 for fused compares.
        int tw = luau_wpos[i] + 1 + ins[i].D;
        if (tw == end_word) return n;                                      // jump-to-END sentinel
        auto it = wpos_to_idx.find(tw);
        return it == wpos_to_idx.end() ? -1 : it->second;
    };

    auto fastcall_target = [&](int i) -> int {   // FASTCALL's skip offset lives in C, base = pc after the op word
        int tw = luau_wpos[i] + 1 + ins[i].C;
        if (tw == end_word) return n;
        auto it = wpos_to_idx.find(tw);
        return it == wpos_to_idx.end() ? -1 : it->second;
    };

    // jt   = target as a LUAU instruction index (resolved via luau2de)
    // jt_dei = target as an absolute DE instruction index (for jumps INTERNAL to a lowered sequence)
    // ct = FASTCALL's skip target as a LUAU instruction index. Like jt it must be RECOMPUTED in DE
    // instruction space, because DE instruction widths differ from Luau's — copying Luau's C verbatim
    // would land the skip in the middle of an instruction.
    struct DI { int op = 0, A = 0, sz = 4, B = 0, C = 0, Bx = 0, jt = -1, jt_dei = -1, ct = -1, o = 0; bool has_jt = false, has_ct = false, bx = false, fused = false; uint32_t aux = 0; };
    std::vector<DI> de;
    std::vector<int> luau2de;
    for (int i = 0; i < n; ++i) {
        luau2de.push_back((int)de.size());
        const std::string nm = ins[i].name();
        if (nm == "JUMPXEQKNIL") {
            // DE has a DEDICATED nil-compare: 0x3a, polarity in aux bit31 — the SAME encoding Luau uses,
            // so aux passes through verbatim. Corpus: `p2 == nil` -> 0x3a aux=0x80000000 ;
            // `x ~= nil` -> 0x3a aux=0x00000000.
            // The old lowering (LOADNIL scratch + reg-reg compare) was WRONG: after a closure writes nil
            // through SETUPVAL the value still reports type=nil but no longer compares equal via the
            // tag-sensitive fused compares (proven in-game: type=nil yet every equality form said "not nil";
            // truthiness and never-assigned captures were fine).
            DI d; d.op = 0x3a; d.A = ins[i].A; d.sz = 8; d.has_jt = true; d.fused = true;
            d.jt = luau_target(i); d.aux = ins[i].has_aux ? ins[i].aux : 0;
            de.push_back(d);
            continue;
        }
        // ANDK has a NATIVE DE opcode (0x31) that we normally do not use — the lowering below is
        // proven, so it stays the default. But because we never emit 0x31, nothing we compile can
        // exercise it, and its DECODE meaning (`R[A] = R[B] and K[C]`, inferred from only 22 corpus
        // instances) had no way to be certified in-game. RENOVICE_NATIVE_ANDK=1 emits it natively so
        // a cert CAN reach it. Confirmation knob only; leave it off for production output.
        if ((nm == "ANDK" && (native_on("ANDK") || [](){ const char* e=std::getenv("RENOVICE_NATIVE_ANDK"); return e && *e=='1'; }()))
            || (nm == "AND" && native_on("AND")) || (nm == "OR" && native_on("OR"))
            || (nm == "ORK" && native_on("ORK"))) {
            // 0x51 = ORK, certified in-game (V15_ORK t=7 f=5 n=5). It was decoded as "TESTSET",
            // an op upstream Luau does not even have; its C is a CONST INDEX, not a flag.
            int op = (nm == "ANDK") ? 0x31 : (nm == "AND") ? 0x2f : (nm == "ORK") ? 0x51 : 0x2b;
            DI d; d.op = op; d.A = ins[i].A; d.B = ins[i].B; d.C = ins[i].C;
            de.push_back(d); continue;
        }
        if (nm == "AND" || nm == "OR" || nm == "ANDK" || nm == "ORK") {
            // DE has no and/or select op -> lower to proven primitives (3 insns, internal forward branch):
            //   MOVE A<-B ; JUMPIFNOT/JUMPIF A -> end ; MOVE A<-C | LOADK A,K[C] ; end:
            // AND keeps R[B] when falsey (JUMPIFNOT skips the alt), OR keeps R[B] when truthy (JUMPIF skips).
            bool isor = (nm == "OR" || nm == "ORK");
            bool isk  = (nm == "ANDK" || nm == "ORK");
            // ALIASED ALTERNATIVE (2026-10-09, DEFECTS #65). The sequence below writes A before it
            // reads C, so when C == A (and B != A) the alternative read B's value instead of A's old
            // value: `value = IsMissing(value) or value` became `... or IsMissing(value)`. Aliasing
            // cases: A == B is exact (the first MOVE is a no-op); B == C is exact (both arms copy B);
            // A == B == C is exact. Only C == A != B is wrong. For it, save C in a scratch register
            // first (p.mx, like the SUBK/JUMPXEQK lowerings) and use the scratch as the alternative:
            //   MOVE scr <- A ; MOVE A <- B ; JUMPIF/JUMPIFNOT A -> end ; MOVE A <- scr ; end:
            // The last three instructions keep the exact F3 shape cfg-identity folds back to OR/AND.
            // Every non-aliased site is emitted byte-identically to before.
            // RENOVICE_LEGACY_ORAND_LOWERING restores the aliased three-instruction form for A/B.
            static const bool legacy_orand = std::getenv("RENOVICE_LEGACY_ORAND_LOWERING") != nullptr;
            const bool alias_alt = !isk && !legacy_orand && ins[i].C == ins[i].A && ins[i].B != ins[i].A;
            int alt_reg = ins[i].C;
            if (alias_alt) {
                const int scr = p.mx;
                if (scr > 254) throw std::runtime_error("OR/AND lowering: no scratch register above maxstack 255");
                maxstack = std::max(maxstack, scr + 1);
                DI save; save.op = 0x14; save.A = scr; save.B = ins[i].A; de.push_back(save);   // MOVE scr <- A
                alt_reg = scr;
            }
            int base = (int)de.size();
            DI mv; mv.op = 0x14; mv.A = ins[i].A; mv.B = ins[i].B; de.push_back(mv);            // MOVE A <- B
            DI br; br.op = isor ? 0x4b : 0x18; br.A = ins[i].A;                                 // JUMPIF / JUMPIFNOT
            br.has_jt = true; br.jt_dei = base + 3; de.push_back(br);                           // -> just past the alt
            DI alt;
            if (isk) { alt.op = 0x4e; alt.A = ins[i].A; alt.bx = true; alt.Bx = ins[i].C; }     // LOADK A, K[C]
            else     { alt.op = 0x14; alt.A = ins[i].A; alt.B = alt_reg; }                      // MOVE  A <- C
            de.push_back(alt);
            continue;
        }
        if (nm == "LOADKX") {                                              // extended LOADK: const index lives in aux
            DI d; d.op = 0x4e; d.A = ins[i].A; d.bx = true; d.Bx = (int)((ins[i].has_aux ? ins[i].aux : 0) & 0xFFFF);
            de.push_back(d); continue;
        }
        // Native globals are the faithful DE representation. Real corpus modules pair SETGLOBAL 0x02 with
        // GETGLOBAL 0x17 against the implicit module environment. The old compatibility lowering mirrored
        // every write through an imported `_G` table and emitted synthetic field operations with cache slot
        // C=255. DE reserves valid field-cache slots to 0..254; the invalid slot corrupted adjacent registers
        // in live ability callbacks and caused both script errors and a native GPF.
        if (nm == "GETGLOBAL") {
            DI d; d.op = 0x17; d.A = ins[i].A; d.sz = 8; d.B = 0; d.C = ins[i].C;
            d.aux = ins[i].has_aux ? (ins[i].aux & 0xFFFF) : 0;
            auto remap = hash_remap.find(d.aux);
            if (remap != hash_remap.end()
                && !(name_classes && name_classes->string_globals.count(d.aux))) d.aux = remap->second;
            de.push_back(d); continue;
        }
        if (nm == "SETGLOBAL") {
            DI d; d.op = 0x02; d.A = ins[i].A; d.sz = 8; d.B = ins[i].B; d.C = ins[i].C;
            d.aux = ins[i].has_aux ? ins[i].aux : 0;
            auto remap = hash_remap.find(d.aux & 0xffffu);
            if (remap != hash_remap.end()
                && !(name_classes && name_classes->string_globals.count(d.aux & 0xffffu))) d.aux = remap->second;
            de.push_back(d); continue;
        }
        // FASTCALL family. Dropping them yields CORRECT code (the complete slow path follows) but
        // loses the builtin fast path on every recompiled script. Emitting them is safe because DE
        // kept upstream Luau's builtin numbering EXACTLY — verified corpus-wide by `de-builtins`
        // (165,557/165,605 resolved: id 1=assert, 2=math.abs, 12=math.floor, 18=math.max, 40=type,
        // 52=table.insert, 63=tostring ... all matching LuauBuiltinFunction). DE also ADDED builtins
        // beyond upstream (id 133 = IsNull, 130,895 uses = 79% of all fastcalls in the game).
        // DEFAULT ON since 2026-07-25 (V16_FASTCALL certified in-game). Set RENOVICE_NO_FASTCALL=1
        // to fall back to dropping them. Dropping produced CORRECT but SLOWER code: every
        // recompiled script ran math.*/table.insert/tostring through the slow path.
        if (nm.rfind("FASTCALL", 0) == 0 && !std::getenv("RENOVICE_NO_FASTCALL")) {
            int op;
            if      (nm == "FASTCALL")   op = 0x10;
            else if (nm == "FASTCALL1")  op = 0x19;
            else if (nm == "FASTCALL2")  op = 0x26;
            else if (nm == "FASTCALL2K") op = 0x0c;
            // FASTCALL3 = 0x4a. Corpus ImageSlideShow p50 carries `FASTCALLX A=45 B=1 C=4` and our
            // luau-compile emits `FASTCALL3 A=45 ... C=4` for string.sub(s,1,-7) — same builtin id,
            // same operand shape, both 8B. It was the last opcode with no generated test case.
            else if (nm == "FASTCALL3")  op = 0x4a;
            else throw std::runtime_error("no DE mapping for " + nm);
            DI d; d.op = op; d.A = ins[i].A; d.B = ins[i].B;
            d.sz = is_de_width8(op) ? 8 : 4;
            d.aux = ins[i].has_aux ? ins[i].aux : 0;
            d.has_ct = true; d.ct = fastcall_target(i);
            if (d.ct < 0) throw std::runtime_error(nm + ": unresolvable skip target");
            de.push_back(d); continue;
        }
        if (nm == "SUBK" && native_on("SUBK")) {                            // certification knob: real 0x3e
            DI d; d.op = 0x3e; d.A = ins[i].A; d.B = ins[i].B; d.C = ins[i].C;
            de.push_back(d); continue;
        }
        if (is_jumpxeqk(nm) && native_on(nm.c_str())) {                     // certification knob: 0x20 / 0x41 / 0x34
            // Luau's aux already carries bit31 = polarity and the low bits = const index (N/S) or
            // boolean value (B) — the same layout DE uses, exactly as for JUMPXEQKNIL -> 0x3a above.
            int op = (nm == "JUMPXEQKN") ? 0x20 : (nm == "JUMPXEQKS") ? 0x41 : 0x34;
            DI d; d.op = op; d.A = ins[i].A; d.sz = 8; d.has_jt = true; d.fused = true;
            d.jt = luau_target(i); d.aux = ins[i].has_aux ? ins[i].aux : 0;
            de.push_back(d); continue;
        }
        if (nm == "SUBK") {                                                // `x - const`: DE has no SUBK -> LOADK scratch + reg-reg SUB(0x07)
            int scr = p.mx; maxstack = std::max(maxstack, scr + 1);
            DI ld; ld.op = 0x4e; ld.A = scr; ld.bx = true; ld.Bx = ins[i].C; // LOADK scr = K[C]
            de.push_back(ld);
            DI sub; sub.op = 0x07; sub.A = ins[i].A; sub.B = ins[i].B; sub.C = scr; // SUB R[A]=R[B]-R[scr]
            de.push_back(sub);
            continue;
        }
        if (is_jumpxeqk(nm)) {                                             // LOWER `x == <const>` -> LOAD scratch + reg-reg cmp
            int scro = 0; { const char* e = std::getenv("RENOVICE_SCRATCH_OFF"); if (e && *e) scro = (int)std::strtol(e,nullptr,0); }
            int scr = p.mx + scro; maxstack = std::max(maxstack, scr + 1);   // scratch reg (offset tunable for calibration)
            uint32_t aux = ins[i].has_aux ? ins[i].aux : 0;
            int notbit = (aux >> 31) & 1;                                  // Luau bit31 = jump-if-NOT-equal
            DI ld; ld.A = scr;
            if (nm == "JUMPXEQKN" || nm == "JUMPXEQKS") { ld.op = 0x4e; ld.bx = true; ld.Bx = (int)(aux & 0x00FFFFFF); } // LOADK K[idx]
            else if (nm == "JUMPXEQKB") { ld.op = 0x04; ld.B = (int)(aux & 1); }                                        // LOADB bool
            else { ld.op = 0x0d; }                                                                                       // LOADNIL
            de.push_back(ld);
            // NOTE: comparing the lhs register DIRECTLY is wrong when that local was REF-captured by a
            // closure — the fused compare then sees the capture cell, not the value (proven in-game: the
            // no-capture control passes, every scratch offset fails). Copying the lhs through MOVE first
            // normalises it (a plain MOVE reads the value correctly, as tostring() demonstrated).
            int lhs = scr + 1; maxstack = std::max(maxstack, lhs + 1);
            DI mv2; mv2.op = 0x14; mv2.A = lhs; mv2.B = ins[i].A; de.push_back(mv2);                                     // MOVE lhs <- R[A]
            DI cmp; cmp.op = notbit ? 0x27 : 0x37; cmp.A = lhs; cmp.sz = 8;                                              // 0x27 NOTEQ / 0x20 EQ
            cmp.has_jt = true; cmp.fused = true; cmp.jt = luau_target(i); cmp.aux = (uint32_t)scr;                       // rhs = scratch reg
            de.push_back(cmp);
            continue;
        }
        if (nm == "JUMPBACK" && native_on("JUMPBACK")) {           // certification knob: real 0x25
            DI d; d.op = 0x25; d.A = ins[i].A; d.has_jt = true; d.jt = luau_target(i);
            de.push_back(d); continue;
        }
        int de_op = opmap_lookup(nm);
        // GENERIC FORGPREP is 0x0b, not 0x30. Corpus proof (derecomp de-forgprep): 0x1b is fed by
        // ipairs 87% with FORGLOOP aux bit31 SET (=INEXT); 0x30 by pairs 83% (=NEXT); 0x0b by
        // ARBITRARY iterators (gRegion/IsNull/string.gmatch, 33% none) = the generic form. Stock
        // luau-compile confirms the same 3-way split. We emit 0x30 (the pairs-SPECIALISED op) for
        // generic iterators; it works because the specialised preps validate and fall back, which is
        // why the v10 generic-for cert passed. RENOVICE_NATIVE=FORGPREP emits the correct 0x0b.
        if (nm == "FORGPREP" && native_on("FORGPREP")) de_op = 0x0b;                                      // env-overridable (RENOVICE_NEQ_OP etc.)
        if (de_op == INT_MIN) throw std::runtime_error("no DE mapping for Luau op " + nm);
        if (de_op == -1) continue;                                         // PREPVARARGS etc. -> drop
        DI d; d.op = de_op; d.A = ins[i].A;
        if (is_jump_op(nm)) { d.sz = 4; d.has_jt = true; d.jt = luau_target(i); }
        else if (is_jump8_op(nm)) { d.sz = 8; d.has_jt = true; d.fused = true; d.jt = luau_target(i); d.aux = ins[i].has_aux ? ins[i].aux : 0; }  // op+offset word, aux=rhs reg / FORGLOOP nvars
        else if (is_bx_op(nm)) {
            d.sz = 4; d.bx = true; d.Bx = ins[i].D & 0xFFFF;
            // NEWCLOSURE's operand indexes THIS PROTO'S CHILD LIST (`p->p[D]`), but DE uses a FLAT,
            // module-wide proto index. Copying D verbatim binds whatever module proto happens to sit at
            // that position — in EE_Interface_Components_Grid it bound a 1-parameter helper where a
            // 5-parameter, 2450-line function belonged, so `CreateGrid` exported the WRONG function.
            // It failed SILENTLY: a wrong index is still structurally valid bytecode, so every
            // structural gate passed it. Remap through `kids`, and REFUSE rather than guess.
            if (nm == "NEWCLOSURE") {
                uint32_t kidx = ins[i].D;
                if (kidx >= p.kids.size())
                    throw std::runtime_error("NEWCLOSURE child index " + std::to_string(kidx) +
                                             " out of range (proto has " + std::to_string(p.kids.size()) +
                                             " children) - refusing to emit a wrong proto index");
                // DE reads NEWCLOSURE's operand as a CHILD index, exactly like Luau (#56, and
                // upstream: "child proto indices"). So the operand passes through UNCHANGED; the
                // child->flat conversion that used to live here (#52) was wrong, and it only ever
                // looked right because the DECOMPILER also read flat at the time — transcoder and
                // decompiler agreeing on the same mistake is self-consistency, not correctness.
                // The kids list itself is still emitted below (flat indices), which is what DE
                // resolves the child index THROUGH.
                d.Bx = kidx & 0xFFFF;
            }
        }
        else if (is_de_width8(de_op)) { d.sz = 8; d.B = ins[i].B; d.C = ins[i].C; d.aux = ins[i].has_aux ? ins[i].aux : 0;
            if (nm == "NAMECALL") { d.C = 0;                                // DE NAMECALL C byte is always 0 (corpus); Luau C is junk
                auto it = hash_remap.find(d.aux & 0xFFFF);                 // dual-use name -> its appended hash-const
                if (it != hash_remap.end()) d.aux = it->second;
            }
            else if (nm == "GETTABLEKS") {
                auto it = hash_remap.find(d.aux & 0xffffu);
                if (it != hash_remap.end()
                    && !(name_classes && name_classes->string_fields.count(d.aux & 0xffffu))) d.aux = it->second;
            }
            else if (nm == "GETIMPORT") {
                auto it = import_descriptor_remap.find(d.aux);
                if (it != import_descriptor_remap.end()) d.aux = it->second;
            }
        }
            // GETTABLEKS/SETTABLEKS: PRESERVE Luau's C = the inline-cache slot (corpus uses 0..254 real slots,
            // NEVER 255). Forcing 255 = an out-of-range slot -> VM cache-handling corrupts an adjacent register.
        else { d.sz = 4; d.B = ins[i].B; d.C = ins[i].C; }
        de.push_back(d);
    }
    luau2de.push_back((int)de.size());                                     // END sentinel

    int off = 0;
    for (auto& d : de) { d.o = off; off += d.sz; }
    int total = off;
    std::string out;
    for (auto& d : de) {
        if (d.has_jt) {
            int sBx;
            if (d.jt_dei >= 0) {                                            // internal target: absolute DE index
                int tgt_byte = (d.jt_dei >= (int)de.size()) ? total : de[d.jt_dei].o;
                sBx = (tgt_byte - (d.o + 4)) / 4;
            }
            else if (d.jt < 0) sBx = 0;
            else {
                int tgt_de = (d.jt < (int)luau2de.size()) ? luau2de[d.jt] : (int)de.size();
                int tgt_byte = (tgt_de >= (int)de.size()) ? total : de[tgt_de].o;
                sBx = (tgt_byte - (d.o + 4)) / 4;                           // base = op+4 (after the OP WORD; the
                                                                           // aux word is excluded even for 8B fused
                                                                           // compares) -- matches the DE VM + Python.
            }
            out += pack_u32((d.op & 0xFF) | ((d.A & 0xFF) << 8) | ((sBx & 0xFFFF) << 16));
            if (d.fused) out += pack_u32(d.aux);                           // fused compare: aux word = rhs register
        } else if (d.has_ct) {
            int tgt_de   = (d.ct < (int)luau2de.size()) ? luau2de[d.ct] : (int)de.size();
            int tgt_byte = (tgt_de >= (int)de.size()) ? total : de[tgt_de].o;
            int c = (tgt_byte - (d.o + 4)) / 4;                      // same base as a branch: op+4
            if (c < 0 || c > 255) throw std::runtime_error("FASTCALL skip out of range");
            out += pack_u32((d.op & 0xFF) | ((d.A & 0xFF) << 8) | ((d.B & 0xFF) << 16) | ((c & 0xFF) << 24));
            if (d.sz == 8) out += pack_u32(d.aux);
        } else if (d.bx) {
            out += pack_u32((d.op & 0xFF) | ((d.A & 0xFF) << 8) | ((d.Bx & 0xFFFF) << 16));
        } else if (d.sz == 8) {
            out += pack_u32((d.op & 0xFF) | ((d.A & 0xFF) << 8) | ((d.B & 0xFF) << 16) | ((d.C & 0xFF) << 24));
            out += pack_u32(d.aux);
        } else {
            out += pack_u32((d.op & 0xFF) | ((d.A & 0xFF) << 8) | ((d.B & 0xFF) << 16) | ((d.C & 0xFF) << 24));
        }
    }
    int sizecode = 0;
    for (auto& d : de) sizecode += (d.sz == 8) ? 2 : 1;
    return { out, sizecode, maxstack };
}

inline sp::MergeReport& last_shared_proto_report() { static sp::MergeReport report; return report; }

// stock Luau module bytes -> DE 09 03 body bytes.  (assembly mirrors luau_to_de.transcode exactly)
inline std::string transcode(const std::string& luau_bytes,
                             const std::set<std::string>& hashed_globals = {},
                             const std::set<std::string>& hashed_fields = {}) {
    luau::Module m = luau::read(luau_bytes);
    // Literals the decompiler marked as copies of one shared stock prototype (shared_protos.h).
    last_shared_proto_report() = sp::merge_shared_protos(m, sp::shared_proto_lines());
    std::vector<std::string> pool;
    std::map<std::string, int> s2i;
    struct Blob { int mx, npar, nups, isvararg, sizecode; std::string code; std::vector<de::Const> consts; std::vector<uint32_t> kids; };
    std::vector<Blob> blobs;
    for (const luau::Proto& p : m.protos) {
        std::map<uint32_t, uint32_t> hash_remap;
        std::map<uint32_t, uint32_t> import_descriptor_remap;
        // Legacy sources keep the historical name-level dual-use remap; raw-hash sources remap
        // only the instructions whose own class is hashed.
        NameUseClasses name_classes;
        NameUseClasses* classes = de::raw_source_hashes ? &name_classes : nullptr;
        std::vector<de::Const> consts = transcode_consts(
            m, p, pool, s2i, hash_remap, import_descriptor_remap,
            hashed_globals, hashed_fields, classes);
        auto cs = transcode_code(p, hash_remap, import_descriptor_remap, classes);
        blobs.push_back({ cs.maxstack, p.npar, p.nups, p.isvararg, cs.sizecode, cs.code, std::move(consts), p.kids });
    }
    std::string out = "\x09\x03";
    out += de::enc_vi(pool.size());
    for (const std::string& s : pool) { out += de::enc_vi(s.size()); out += s; }
    out += '\x00';                                                         // name-table flag
    out += de::enc_vi(blobs.size());                                       // nps
    for (const Blob& pb : blobs) {
        out += (char)(pb.mx & 0xFF); out += (char)(pb.npar & 0xFF); out += (char)(pb.nups & 0xFF);
        out += (char)(pb.isvararg & 0xFF); out += '\x00';
        out += '\x00';                                                     // inline srcname len = 0
        out += de::enc_vi(pb.sizecode);
        out += pb.code;
        out += de::enc_consts((uint32_t)pb.consts.size(), pb.consts);
        out += de::enc_vi(pb.kids.size());
        for (uint32_t k : pb.kids) out += de::enc_vi(k);
        out += de::enc_vi(0);                                              // linedefined
        out += de::enc_vi(0);                                              // srcname
        out += '\x00';                                                     // g1 lineinfo gate
        out += '\x00';                                                     // g2 debug gate
    }
    out += de::enc_vi(m.mainid);                                           // root proto index
    return out;
}

} // namespace tc
