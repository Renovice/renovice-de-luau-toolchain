// ir.h — M6a: the ANNOTATED IR.  Turns a raw DE proto into instructions whose every operand is
#include <cmath>
// resolved: constants materialised to real values, name-hashes resolved through the namebase, import
// ids expanded to dotted paths, branch offsets turned into instruction indices.
//
// This is the decompiler's foundation. It is deliberately READ-ONLY and completely separate from the
// byte-exact write path in de_container.h — nothing here can perturb the 5382/5382 round-trip.
//
// The correctness bar is the same one used everywhere else in this project: a corpus-wide count with
// ZERO unexplained cases. `derecomp ir-validate` reports, per instruction, whether every operand it
// carries was resolvable. Anything unresolved is COUNTED and CATEGORISED, never silently rendered.
#pragma once
#include <cstdint>
#include <cstring>
#include <cstdio>
#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include "de_container.h"
#include "de_namehash.h"

namespace ir {

// ---------------------------------------------------------------------------------------------
// string pool — parsed separately from de::walk so the proven writer path stays untouched
// ---------------------------------------------------------------------------------------------
inline std::vector<std::string> parse_pool(const std::string& b) {
    std::vector<std::string> out;
    if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) return out;
    size_t o = 2;
    uint64_t nstr = de::rd_vi(b, o);
    out.reserve((size_t)nstr);
    for (uint64_t i = 0; i < nstr; ++i) {
        uint64_t ln = de::rd_vi(b, o);
        if (ln > b.size() - o) break;
        out.push_back(b.substr(o, (size_t)ln));
        o += (size_t)ln;
    }
    return out;
}

// ---------------------------------------------------------------------------------------------
// namebase: hash -> name.  Loaded once. Unresolved hashes render as Name__aabbccdd, which is
// LOSSLESS: resolve_name_hash() parses that suffix back to the original hash on recompile.
// ---------------------------------------------------------------------------------------------
struct NameBase {
    std::unordered_map<uint32_t, std::string> m;
    bool loaded = false;
    long long entries = 0;
    void load(const std::string& tsv_text) {
        size_t i = 0, n = tsv_text.size();
        while (i < n) {
            size_t e = tsv_text.find('\n', i);
            if (e == std::string::npos) e = n;
            size_t lineend = e;
            while (lineend > i && (tsv_text[lineend-1] == '\r')) --lineend;
            size_t t = tsv_text.find('\t', i);
            if (t != std::string::npos && t < lineend) {
                uint32_t h = (uint32_t)std::strtoul(tsv_text.substr(i, t-i).c_str(), nullptr, 16);
                m.emplace(h, tsv_text.substr(t+1, lineend-t-1));
                ++entries;
            }
            i = e + 1;
        }
        loaded = true;
    }
    // Always returns something usable. `ok` reports whether it was a real recovered name.
    std::string get(uint32_t h, bool* ok = nullptr) const {
        auto it = m.find(h);
        if (it != m.end()) { if (ok) *ok = true; return it->second; }
        if (ok) *ok = false;
        char b[32]; std::snprintf(b, sizeof b, "Name__%08x", h);
        return b;
    }
};

// ---------------------------------------------------------------------------------------------
// resolved constant
// ---------------------------------------------------------------------------------------------
enum class KKind { Nil, NameHash, Number, Str, Import, TableTpl, Closure, Vector, Int64, Unknown };

struct KVal {
    KKind kind = KKind::Unknown;
    int tag = -1;
    std::string text;          // fully rendered, ready to paste into Luau source
    std::string str;           // raw string body for Str / resolved name for NameHash
    double num = 0;
    int64_t i64 = 0;
    uint32_t hash = 0;         // NameHash
    uint32_t import_id = 0;    // Import
    uint64_t sub = 0;          // Closure: sub-proto index
    std::vector<uint64_t> tpl_keys;                        // tag 5: key const indices
    std::vector<std::pair<uint64_t,uint32_t>> tpl_items;   // tag 8: (key const idx, 4-byte payload)
    bool resolved = true;      // false => we could not fully explain it
};

inline std::string quote_lua(const std::string& s) {
    std::string o = "\"";
    for (unsigned char c : s) {
        switch (c) {
            case '"':  o += "\\\""; break;
            case '\\': o += "\\\\"; break;
            case '\n': o += "\\n";  break;
            case '\r': o += "\\r";  break;
            case '\t': o += "\\t";  break;
            default:
                if (c < 0x20 || c == 0x7f) { char b[8]; std::snprintf(b, sizeof b, "\\%d", (int)c); o += b; }
                else o.push_back((char)c);
        }
    }
    return o + "\"";
}

inline std::string fmt_num(double d) {
    // `%g` renders these as `inf` / `-inf` / `nan`, none of which are Luau literals — the compiler
    // rejects the whole FILE with "Malformed number". They are representable, just not as literals.
    if (std::isnan(d)) return "(0/0)";
    // `1e9999` overflows to inf in the LEXER, so it stays a NUMBER CONSTANT — exactly what the original
    // holds. `math.huge` instead emits GETIMPORT math + GETFIELD huge: extra named accesses for the same
    // value, and it breaks silently if `math` is shadowed. Measured: prints `inf` / `-inf`.
    if (std::isinf(d)) return d < 0 ? "-1e9999" : "1e9999";
    if (d == (double)(int64_t)d && d > -1e15 && d < 1e15) {
        char b[32]; std::snprintf(b, sizeof b, "%lld", (long long)d); return b;
    }
    char b[40]; std::snprintf(b, sizeof b, "%.17g", d);
    // prefer the shortest representation that round-trips exactly
    for (int prec = 1; prec <= 17; ++prec) {
        char t[40]; std::snprintf(t, sizeof t, "%.*g", prec, d);
        if (std::strtod(t, nullptr) == d) return t;
    }
    return b;
}

// Import ids pack up to three string-const indices, 10 bits each, count in the top 2 bits
// (upstream Luau encoding). Verified corpus-wide by ir-validate: every field must index a tag-3 string.
inline void import_parts(uint32_t id, int& count, int idx[3]) {
    count  = (int)(id >> 30);
    idx[0] = (int)((id >> 20) & 1023);
    idx[1] = (int)((id >> 10) & 1023);
    idx[2] = (int)(id & 1023);
}

// DE OVERLOADS const tag 1. Upstream Luau's tag 1 is BOOLEAN; DE reused the same tag for its 4-byte
// FNV name hashes (round-trip proves the payload is 4 bytes, not 1), and disambiguates BY POSITION.
// Proven corpus-wide by `derecomp de-tag1audit`: across 1,263,066 tag-1 references from NAME positions
// (NAMECALL / field / global / import path) ZERO carry payload 0 or 1, while all 42 references from
// VALUE positions (LOADK / ANDK) carry ONLY 0 or 1. So in a value position a tag-1 const is a boolean.
// Rendering it as a name would produce `x and Name__00000001` — a nil global read instead of `true`.
inline std::string value_text(const KVal& k) {
    if (k.kind == KKind::NameHash && k.hash <= 1) return k.hash ? "true" : "false";
    // A tag-1 name-hash with a REAL hash in a value position loads the interned NAME, i.e. a string —
    // emitting it bare makes it a global read, and if the recovered name is not a valid identifier
    // (e.g. "899c4c") the whole file dies with "Malformed number". Quote it.
    if (k.kind == KKind::NameHash) return quote_lua(k.str);
    return k.text;
}

inline KVal resolve_const(const de::Const& c, const std::vector<std::string>& pool, const NameBase& nb) {
    KVal k; k.tag = c.tag;
    auto rd32 = [&](const std::string& r) -> uint32_t {
        uint32_t v = 0; if (r.size() >= 4) std::memcpy(&v, r.data(), 4); return v; };
    switch (c.tag) {
        case 0: k.kind = KKind::Nil; k.text = "nil"; break;
        case 1: {
            k.kind = KKind::NameHash; k.hash = rd32(c.raw);
            bool ok = false; k.str = nb.get(k.hash, &ok); k.text = k.str; k.resolved = true;
            break;                                     // Name__hash fallback is lossless, so still resolved
        }
        case 2: {
            k.kind = KKind::Number;
            if (c.raw.size() >= 8) std::memcpy(&k.num, c.raw.data(), 8); else k.resolved = false;
            k.text = fmt_num(k.num);
            break;
        }
        case 3: {
            k.kind = KKind::Str;
            if (c.idx >= 1 && c.idx <= pool.size()) { k.str = pool[(size_t)c.idx - 1]; k.text = quote_lua(k.str); }
            else if (c.idx == 0) { k.str = ""; k.text = "\"\""; }
            else { k.resolved = false; char b[48]; std::snprintf(b, sizeof b, "<str#%llu OOB>", (unsigned long long)c.idx); k.text = b; }
            break;
        }
        case 4: {
            k.kind = KKind::Import; k.import_id = rd32(c.raw);
            int cnt, ix[3]; import_parts(k.import_id, cnt, ix);
            k.text = "<import>";                       // filled in by annotate() which has the const table
            if (cnt < 1 || cnt > 3) k.resolved = false;
            break;
        }
        case 5: case 8: {
            k.kind = KKind::TableTpl;
            if (c.tag == 5) k.tpl_keys = c.list;
            else for (auto& it : c.items) {
                uint32_t v = 0; if (it.second.size() >= 4) std::memcpy(&v, it.second.data(), 4);
                k.tpl_items.emplace_back(it.first, v);
            }
            char b[48]; std::snprintf(b, sizeof b, "<table tpl %zu keys>",
                c.tag == 5 ? c.list.size() : c.items.size());
            k.text = b;                                    // expanded by annotate(), which sees all consts
            break;
        }
        case 6: { k.kind = KKind::Closure; k.sub = c.idx;  // tag 6 stores the sub-proto index in .idx
                  char b[32]; std::snprintf(b, sizeof b, "<proto %llu>", (unsigned long long)k.sub); k.text = b; break; }
        case 7: {
            k.kind = KKind::Vector; float v[4] = {0,0,0,0};
            if (c.raw.size() >= 16) std::memcpy(v, c.raw.data(), 16); else k.resolved = false;
            char b[96]; std::snprintf(b, sizeof b, "Vector3(%g, %g, %g)", v[0], v[1], v[2]); k.text = b; break;
        }
        case 9: {
            k.kind = KKind::Int64; k.i64 = c.sign ? -(int64_t)c.val : (int64_t)c.val;
            char b[32]; std::snprintf(b, sizeof b, "%lld", (long long)k.i64); k.text = b; break;
        }
        default: k.kind = KKind::Unknown; k.resolved = false; k.text = "<unknown const>"; break;
    }
    return k;
}

// ---------------------------------------------------------------------------------------------
// annotated instruction
// ---------------------------------------------------------------------------------------------
struct IInsn {
    int idx = 0; size_t off = 0;
    uint8_t op = 0, A = 0, B = 0, C = 0;
    uint16_t Bx = 0; uint32_t aux = 0;
    bool wide = false, branch = false;
    std::string name;          // mnemonic
    int target = -1;           // branch target as an instruction INDEX
    std::string note;          // resolved operand: field name, import path, constant value, ...
    std::string text;          // full rendering
    bool annotated = true;     // false => an operand we could not resolve
    std::string unresolved;    // why, when annotated == false
};

struct IProto {
    int index = 0;
    int maxstack = 0, nparams = 0, nups = 0; bool vararg = false;
    // The proto's CHILD LIST. NEWCLOSURE's operand indexes THIS, not the flat module table.
    std::vector<uint32_t> kids;
    std::vector<KVal> consts;
    std::vector<IInsn> code;
    bool ok = true;
    std::string why;
};

} // namespace ir
