// de_container.h - read/write the DE "Luau" 09 03 .lua_B container in C++.  C++ port of the proven
// parse_luab.py + _flat_loader.py + encode_luab.py (grammar cracked from VM-A luaU_undump FUN_14197c9f0).
// M3 goal: walk a real .lua_B into (prefix | per-proto[hdr|code|consts|post] | trailer), RECONSTRUCT the
// const table from parsed form, and re-emit BYTE-EXACT.  Header/code/post stay raw spans (never edited);
// only consts are structurally re-encoded (the surface M4 edits).  Verified vs encode_luab.py zero-diff.
#pragma once
#include <cstdint>
#include <string>
#include <vector>
#include <stdexcept>

namespace de {

// ---- bounds-checked byte read (throws past end, like rd_vi) ----
inline uint8_t rd_u8(const std::string& b, size_t& o) {
    if (o >= b.size()) throw std::runtime_error("rd_u8: past end");
    return (uint8_t)b[o++];
}

// ---- varint (LEB128), identical to parse_luab.vi / encode_luab.enc_vi ----
inline uint64_t rd_vi(const std::string& b, size_t& o) {
    uint64_t r = 0; int sh = 0;
    while (true) {
        if (o >= b.size()) throw std::runtime_error("rd_vi: past end");
        uint8_t x = (uint8_t)b[o++];
        r |= (uint64_t)(x & 0x7F) << sh;
        if (!(x & 0x80)) return r;
        sh += 7;
    }
}
inline std::string enc_vi(uint64_t n) {
    std::string out;
    while (true) {
        uint8_t b = n & 0x7F; n >>= 7;
        out.push_back((char)(b | (n ? 0x80 : 0)));
        if (!n) return out;
    }
}

// ---- structured const (mirrors parse_luab.parse_consts / encode_luab.enc_consts) ----
struct Const {
    int tag = 0;                                            // 0..9 (0=nil)
    std::string raw;                                        // tags 1(4B) 2(8B) 4(4B) 7(16B): exact payload
    uint64_t idx = 0;                                       // tag 3 (str pool idx) / tag 6 (sub-proto idx)
    std::vector<uint64_t> list;                             // tag 5: varint list
    std::vector<std::pair<uint64_t, std::string>> items;   // tag 8: (varint, 4B fixup)
    uint8_t sign = 0;                                       // tag 9 sign byte
    uint64_t val = 0;                                       // tag 9 magnitude varint
};

struct Proto {
    size_t h0 = 0, co = 0, blen = 0, end = 0;
    int sc = 0;                                            // sizecode (capped <200000 by header_at)
    uint32_t sizek = 0;                                   // const count — wide enough that enc_vi never sign-extends
    std::string hdr, code, consts_span, post;              // raw spans (byte-exact preservation)
    std::vector<Const> consts;                             // structured (re-encoded on write)
    // The post-const region opens with [nsub][nsub * kid] — the proto's CHILD LIST. It was parsed
    // and DISCARDED, so nothing could contradict the assumption that NEWCLOSURE's operand is a flat
    // module index. Upstream Luau documents it as a CHILD index, and the capture counts only make
    // sense that way. Read-only: the writer still emits the original raw span byte-for-byte.
    std::vector<uint32_t> kids;                            // child proto indices, in order
};

struct Module {
    std::string prefix;                                    // 09 03 + pool + name-table + nps  (raw)
    int nps = 0;
    std::vector<Proto> protos;
    std::string trailer;                                   // root-index varint + tail  (raw)
};

// ---- readers (byte-exact to the VM undump) ----

// 5 raw header bytes + inline source-name [slen vi][slen bytes] + [sizecode vi]; code = sizecode*4 bytes.
inline bool header_at(const std::string& b, size_t o, size_t& co, size_t& blen, int& sc) {
    size_t n = b.size();
    if (o + 6 > n) return false;
    size_t p = o + 5;
    uint64_t slen = rd_vi(b, p);
    if (slen >= (1u << 24) || p + slen > n) return false;
    p += (size_t)slen;
    if (p + 1 > n) return false;
    uint64_t sizecode = rd_vi(b, p);                        // p now = code start
    if (!(sizecode >= 1 && sizecode < 200000) || p + sizecode * 4 > n) return false;
    co = p; blen = (size_t)sizecode * 4; sc = (int)sizecode;
    return true;
}

// const dispatch (tag-1 index into jump table @0x197db68); tags 1..9 valid, 0/>9 = nil-default.
inline void parse_consts(const std::string& b, size_t o, uint32_t& sizek_out, std::vector<Const>& consts, size_t& cend) {
    size_t n = b.size();
    uint64_t sizek = rd_vi(b, o);
    sizek_out = (uint32_t)sizek;
    consts.clear();
    for (uint64_t i = 0; i < sizek; ++i) {
        if (o >= n) break;
        uint8_t tag = (uint8_t)b[o++];
        Const c; c.tag = tag;
        switch (tag) {
            case 3: c.idx = rd_vi(b, o); break;                                            // string pool idx
            case 1: c.raw = b.substr(o, 4);  o += 4;  break;                               // u32
            case 2: c.raw = b.substr(o, 8);  o += 8;  break;                               // f64
            case 4: c.raw = b.substr(o, 4);  o += 4;  break;                               // typed u32
            case 7: c.raw = b.substr(o, 16); o += 16; break;                               // vector3 (3f32+pad)
            case 6: c.idx = rd_vi(b, o); break;                                            // sub-proto idx
            case 5: { uint64_t cnt = rd_vi(b, o); for (uint64_t k = 0; k < cnt; ++k) c.list.push_back(rd_vi(b, o)); } break;
            case 8: { uint64_t cnt = rd_vi(b, o); for (uint64_t k = 0; k < cnt; ++k) { uint64_t v = rd_vi(b, o); std::string fx = b.substr(o, 4); o += 4; c.items.emplace_back(v, fx); } } break;
            case 9: { c.sign = (o < n) ? (uint8_t)b[o] : 0; ++o; c.val = rd_vi(b, o); } break;
            case 0: break;
            default: throw std::runtime_error("invalid const tag " + std::to_string((int)tag));   // desync/drift
        }
        consts.push_back(std::move(c));
    }
    cend = o;
}

// post-const region: [nsub vi][nsub*kid vi][linedefined vi][srcname vi][g1 lineinfo?][g2 locvars/upvals?]
// Only the END offset matters (we keep the bytes as a raw span). Bounds-hardened like parse_postconst.
inline size_t parse_postconst(const std::string& b, size_t cend, int sizecode,
                              std::vector<uint32_t>* out_kids = nullptr) {
    size_t n = b.size(), o = cend;
    auto clamp = [&](size_t x) { return x < n ? x : n; };
    try {
        if (o >= n) return clamp(o);
        uint64_t nsub = rd_vi(b, o);
        if (!(nsub < (1u << 24))) return clamp(o);
        for (uint64_t k = 0; k < nsub; ++k) { if (o >= n) return n; uint64_t kid = rd_vi(b, o);
            if (out_kids) out_kids->push_back((uint32_t)kid); }
        if (o >= n) return n;
        rd_vi(b, o);                                        // linedefined
        if (o >= n) return n;
        rd_vi(b, o);                                        // srcname
        if (o >= n) return n;
        uint8_t g1 = (uint8_t)b[o++];                       // lineinfo gate
        if (g1 != 0) {
            if (o >= n) return n;
            uint8_t kk = (uint8_t)b[o++];
            o += (size_t)sizecode;                          // 1 delta byte per instruction word
            kk &= 0x3F;
            uint64_t nabs = sizecode > 0 ? (((uint64_t)(sizecode - 1) >> kk) + 1) : 0;
            o += 4 * (size_t)nabs;                          // abs-line table (u32 each)
        }
        if (o >= n) return clamp(o);
        uint8_t g2 = (uint8_t)b[o++];                       // locvar+upvalue gate
        if (g2 != 0) {
            uint64_t nloc = rd_vi(b, o);
            for (uint64_t k = 0; k < nloc; ++k) { if (o >= n) return n; rd_vi(b, o); rd_vi(b, o); rd_vi(b, o); o += 1; }
            if (o < n) { uint64_t nup = rd_vi(b, o); for (uint64_t k = 0; k < nup; ++k) { if (o >= n) return n; rd_vi(b, o); } }
        }
    } catch (const std::exception&) {
        return clamp(o);
    }
    return clamp(o);
}

// pool + name-table flag + nps; return byte offset just past nps (start of first proto).
inline void parse_pool_and_nps(const std::string& b, size_t& pool_nps_end, int& nps_out) {
    if (b.size() < 2 || (uint8_t)b[0] != 0x09 || (uint8_t)b[1] != 0x03) throw std::runtime_error("not a 09 03 container");
    size_t o = 2;
    uint64_t nstr = rd_vi(b, o);
    for (uint64_t i = 0; i < nstr; ++i) {
        uint64_t ln = rd_vi(b, o);
        if (ln > b.size() - o) throw std::runtime_error("string length past end");   // guard oversized pool entry (was SIGSEGV)
        o += (size_t)ln;
    }
    uint8_t flag = rd_u8(b, o);                                                       // bounds-checked (was unguarded b[o++])
    if (flag != 0) { while (true) { rd_vi(b, o); uint8_t nb = rd_u8(b, o); if (nb == 0) break; } }
    uint64_t nps = rd_vi(b, o);
    nps_out = (int)nps;
    pool_nps_end = o;
}

// ---- walk: full structure with byte spans ----
inline Module walk(const std::string& b) {
    Module m;
    size_t pool_nps_end; int nps;
    parse_pool_and_nps(b, pool_nps_end, nps);
    m.prefix = b.substr(0, pool_nps_end);
    m.nps = nps;
    size_t o = pool_nps_end;
    for (int i = 0; i < nps; ++i) {
        Proto p; p.h0 = o;
        size_t co, blen; int sc;
        if (!header_at(b, o, co, blen, sc)) throw std::runtime_error("bad header at proto " + std::to_string(i));
        p.co = co; p.blen = blen; p.sc = sc;
        p.hdr = b.substr(p.h0, co - p.h0);
        p.code = b.substr(co, blen);
        size_t cbase = co + blen, cend;
        parse_consts(b, cbase, p.sizek, p.consts, cend);
        p.consts_span = b.substr(cbase, cend - cbase);
        size_t end = parse_postconst(b, cend, sc, &p.kids);
        p.post = b.substr(cend, end - cend);
        p.end = end;
        m.protos.push_back(std::move(p));
        o = end;
    }
    m.trailer = b.substr(o);
    return m;
}

// ---- writer: re-encode consts from parsed form (inverse of parse_consts) ----
inline std::string enc_consts(uint32_t sizek, const std::vector<Const>& consts) {
    std::string out = enc_vi((uint64_t)sizek);
    for (const Const& c : consts) {
        switch (c.tag) {
            case 3: out.push_back(3); out += enc_vi(c.idx); break;
            case 1: case 2: case 4: case 7: out.push_back((char)c.tag); out += c.raw; break;
            case 6: out.push_back(6); out += enc_vi(c.idx); break;
            case 5: out.push_back(5); out += enc_vi(c.list.size()); for (uint64_t x : c.list) out += enc_vi(x); break;
            case 8: out.push_back(8); out += enc_vi(c.items.size()); for (auto& it : c.items) { out += enc_vi(it.first); out += it.second; } break;
            case 9: out.push_back(9); out.push_back((char)c.sign); out += enc_vi(c.val); break;
            case 0: out.push_back(0); break;
            default: throw std::runtime_error("enc: unknown const tag " + std::to_string(c.tag));
        }
    }
    return out;
}

// full body: prefix + per-proto(hdr | code | reconstructed consts | post) + trailer.
inline std::string encode(const Module& m) {
    std::string out = m.prefix;
    for (const Proto& p : m.protos) {
        out += p.hdr;
        out += p.code;
        out += enc_consts(p.sizek, p.consts);
        out += p.post;
    }
    out += m.trailer;
    return out;
}

} // namespace de
