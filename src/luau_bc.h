// luau_bc.h - parse STOCK Luau bytecode (as emitted by our luau-compile.exe, v12/typeversion3) into a
// structured module: string table + per-proto (header, insns[], consts[], child protos).  C++ port of the
// proven RENOVICE_Toolkit/compiler/luau_read.py (format from luau BytecodeBuilder.cpp).  This is the FRONT
// of the Luau->DE transcoder (M2).  Header-only so the build stays a single translation unit.
#pragma once
#include <cstdint>
#include <cstring>
#include <string>
#include <vector>
#include <stdexcept>

namespace luau {

// stock Luau opcode ordinals (Common/include/Luau/Bytecode.h enum order)
static const char* const OPS[] = {
 "NOP","BREAK","LOADNIL","LOADB","LOADN","LOADK","MOVE","GETGLOBAL","SETGLOBAL","GETUPVAL",
 "SETUPVAL","CLOSEUPVALS","GETIMPORT","GETTABLE","SETTABLE","GETTABLEKS","SETTABLEKS","GETTABLEN",
 "SETTABLEN","NEWCLOSURE","NAMECALL","CALL","RETURN","JUMP","JUMPBACK","JUMPIF","JUMPIFNOT","JUMPIFEQ",
 "JUMPIFLE","JUMPIFLT","JUMPIFNOTEQ","JUMPIFNOTLE","JUMPIFNOTLT","ADD","SUB","MUL","DIV","MOD","POW",
 "ADDK","SUBK","MULK","DIVK","MODK","POWK","AND","OR","ANDK","ORK","CONCAT","NOT","MINUS","LENGTH",
 "NEWTABLE","DUPTABLE","SETLIST","FORNPREP","FORNLOOP","FORGLOOP","FORGPREP_INEXT","FASTCALL3",
 "FORGPREP_NEXT","NATIVECALL","GETVARARGS","DUPCLOSURE","PREPVARARGS","LOADKX","JUMPX","FASTCALL",
 "COVERAGE","CAPTURE","SUBRK","DIVRK","FASTCALL1","FASTCALL2","FASTCALL2K","FORGPREP","JUMPXEQKNIL",
 "JUMPXEQKB","JUMPXEQKN","JUMPXEQKS","IDIV","IDIVK","GETUDATAKS","SETUDATAKS","NAMECALLUDATA",
 "NEWCLASSMEMBER","CALLFB","CMPPROTO"};
static const int NOPS = (int)(sizeof(OPS)/sizeof(OPS[0]));

inline const char* op_name(uint8_t op) { return op < NOPS ? OPS[op] : "OP_?"; }

// ops that consume a following AUX word
inline bool op_has_aux(uint8_t op) {
    static const char* const AUX[] = {"GETGLOBAL","SETGLOBAL","GETIMPORT","GETTABLEKS","SETTABLEKS",
     "NAMECALL","JUMPIFEQ","JUMPIFLE","JUMPIFLT","JUMPIFNOTEQ","JUMPIFNOTLE","JUMPIFNOTLT","NEWTABLE",
     "SETLIST","FORGLOOP","LOADKX","FASTCALL2","FASTCALL2K","FASTCALL3","JUMPXEQKNIL","JUMPXEQKB",
     "JUMPXEQKN","JUMPXEQKS","GETUDATAKS","SETUDATAKS","NAMECALLUDATA","NEWCLASSMEMBER","CALLFB"};
    static bool table[256]; static bool built = false;
    if (!built) {
        for (int i = 0; i < 256; ++i) table[i] = false;
        for (const char* a : AUX) for (int i = 0; i < NOPS; ++i) if (std::strcmp(a, OPS[i]) == 0) { table[i] = true; break; }
        built = true;
    }
    // `op` is uint8_t, so every possible value is already within this table.
    return table[op];
}

// const tags (LBC_CONSTANT_*)
enum { C_NIL, C_BOOL, C_NUM, C_STR, C_IMPORT, C_TABLE, C_CLOSURE, C_VEC, C_TABLEK, C_INT, C_CLASS };

struct Const {
    int tag = C_NIL;
    bool bval = false;                                   // C_BOOL
    double num = 0;                                      // C_NUM
    uint32_t u = 0;                                      // C_STR (1-based idx) / C_IMPORT / C_CLOSURE
    long long inum = 0;                                  // C_INT (signed)
    float vec[4] = {0,0,0,0};                            // C_VEC
    std::vector<uint32_t> keys;                          // C_TABLE
    std::vector<std::pair<uint32_t,int32_t>> items;      // C_TABLEK
};

struct Insn {
    uint32_t word = 0;
    uint8_t op = 0;
    int A = 0, B = 0, C = 0, D = 0;
    bool has_aux = false;
    uint32_t aux = 0;
    const char* name() const { return op_name(op); }
};

struct Proto {
    int mx = 0, npar = 0, nups = 0, isvararg = 0, flags = 0;
    std::vector<Insn> insns;
    std::vector<Const> consts;
    std::vector<uint32_t> kids;
    uint32_t linedefined = 0, debugname = 0;
};

struct Module {
    int version = 0, typeversion = 0;
    std::vector<std::string> strings;
    std::vector<Proto> protos;
    uint32_t mainid = 0;
};

// ---- primitive readers (bounds-checked) ----
inline uint8_t rd_u8(const std::string& b, size_t& o) {
    if (o >= b.size()) throw std::runtime_error("rd_u8: past end");
    return (uint8_t)b[o++];
}
inline uint64_t rd_vi(const std::string& b, size_t& o) {   // LEB128-style varint
    uint64_t r = 0; int sh = 0;
    while (true) {
        uint8_t x = rd_u8(b, o);
        r |= (uint64_t)(x & 0x7F) << sh;
        if (!(x & 0x80)) return r;
        sh += 7;
    }
}
inline uint32_t rd_u32(const std::string& b, size_t& o) {
    if (o + 4 > b.size()) throw std::runtime_error("rd_u32: past end");
    uint32_t v; std::memcpy(&v, b.data() + o, 4); o += 4; return v;
}
inline int32_t rd_i32(const std::string& b, size_t& o) {
    if (o + 4 > b.size()) throw std::runtime_error("rd_i32: past end");
    int32_t v; std::memcpy(&v, b.data() + o, 4); o += 4; return v;
}
inline double rd_f64(const std::string& b, size_t& o) {
    if (o + 8 > b.size()) throw std::runtime_error("rd_f64: past end");
    double v; std::memcpy(&v, b.data() + o, 8); o += 8; return v;
}

inline std::vector<Const> read_consts(const std::string& b, size_t& o) {
    uint64_t n = rd_vi(b, o);
    std::vector<Const> cs; cs.reserve((size_t)n);
    for (uint64_t i = 0; i < n; ++i) {
        Const c; c.tag = rd_u8(b, o);
        switch (c.tag) {
            case C_NIL: break;
            case C_BOOL: c.bval = rd_u8(b, o) != 0; break;
            case C_NUM:  c.num  = rd_f64(b, o); break;
            case C_STR:  c.u    = (uint32_t)rd_vi(b, o); break;      // 1-based string-table index
            case C_IMPORT: c.u  = (uint32_t)rd_i32(b, o); break;
            case C_TABLE: { uint64_t ln = rd_vi(b, o); for (uint64_t k = 0; k < ln; ++k) c.keys.push_back((uint32_t)rd_vi(b, o)); } break;
            case C_CLOSURE: c.u = (uint32_t)rd_vi(b, o); break;
            case C_VEC: for (int k = 0; k < 4; ++k) { uint32_t r = rd_u32(b, o); std::memcpy(&c.vec[k], &r, 4); } break;
            case C_TABLEK: { uint64_t ln = rd_vi(b, o); for (uint64_t k = 0; k < ln; ++k) { uint32_t key = (uint32_t)rd_vi(b, o); int32_t cv = rd_i32(b, o); c.items.emplace_back(key, cv); } } break;
            case C_INT: { uint8_t sign = rd_u8(b, o); uint64_t mag = rd_vi(b, o); c.inum = sign ? -(long long)mag : (long long)mag; } break;
            default: throw std::runtime_error("unhandled const tag " + std::to_string(c.tag));
        }
        cs.push_back(std::move(c));
    }
    return cs;
}

// writeLineInfo: [u8 logspan][ncode bytes][intervals * i32 baseline]  (ncode = total word count incl. aux)
inline void skip_lineinfo(const std::string& b, size_t& o, uint64_t ncode) {
    uint8_t logspan = rd_u8(b, o);
    o += (size_t)ncode;
    uint64_t intervals = ncode > 0 ? (((ncode - 1) >> logspan) + 1) : 0;
    o += 4 * (size_t)intervals;
}

inline Proto read_func(const std::string& b, size_t o) {
    Proto p;
    p.mx = rd_u8(b, o); p.npar = rd_u8(b, o); p.nups = rd_u8(b, o); p.isvararg = rd_u8(b, o); p.flags = rd_u8(b, o);
    uint64_t tsize = rd_vi(b, o); o += (size_t)tsize;                 // typeinfo (skip)
    uint64_t ncode = rd_vi(b, o);
    uint64_t i = 0;
    while (i < ncode) {
        Insn ins; ins.word = rd_u32(b, o); ++i;
        ins.op = ins.word & 0xFF;
        ins.A = (ins.word >> 8) & 0xFF;
        ins.B = (ins.word >> 16) & 0xFF;
        ins.C = (ins.word >> 24) & 0xFF;
        int d = (ins.word >> 16) & 0xFFFF; if (d >= 0x8000) d -= 0x10000;   // signed D
        ins.D = d;
        if (op_has_aux(ins.op)) { ins.has_aux = true; ins.aux = rd_u32(b, o); ++i; }
        p.insns.push_back(ins);
    }
    p.consts = read_consts(b, o);
    uint64_t nk = rd_vi(b, o);
    for (uint64_t k = 0; k < nk; ++k) p.kids.push_back((uint32_t)rd_vi(b, o));
    p.linedefined = (uint32_t)rd_vi(b, o);
    p.debugname = (uint32_t)rd_vi(b, o);
    if (rd_u8(b, o)) skip_lineinfo(b, o, ncode);                      // hasLines
    if (rd_u8(b, o)) {                                                // hasDebug
        uint64_t nloc = rd_vi(b, o);
        for (uint64_t k = 0; k < nloc; ++k) { rd_vi(b, o); rd_vi(b, o); rd_vi(b, o); rd_u8(b, o); }
        uint64_t nup = rd_vi(b, o);
        for (uint64_t k = 0; k < nup; ++k) rd_vi(b, o);
    }
    return p;
}

inline Module read(const std::string& b) {
    Module m;
    if (b.size() < 2) throw std::runtime_error("bytecode too short");
    m.version = (uint8_t)b[0]; m.typeversion = (uint8_t)b[1];
    size_t o = 2;
    uint64_t ns = rd_vi(b, o);
    for (uint64_t i = 0; i < ns; ++i) { uint64_t ln = rd_vi(b, o); if (o + ln > b.size()) throw std::runtime_error("string past end"); m.strings.emplace_back(b, o, (size_t)ln); o += (size_t)ln; }
    while (rd_u8(b, o) != 0) { rd_vi(b, o); }                         // userdata type map, 0-terminated
    uint64_t nf = rd_vi(b, o);
    for (uint64_t i = 0; i < nf; ++i) {
        uint64_t dsize = rd_vi(b, o);                                // per-func size prefix (LuauBytecodeCostModel)
        size_t end = o + (size_t)dsize;
        m.protos.push_back(read_func(b, o));
        o = end;
    }
    m.mainid = (uint32_t)rd_vi(b, o);
    return m;
}

inline std::string sstr(const Module& m, uint32_t idx) {
    return (idx >= 1 && idx <= m.strings.size()) ? m.strings[idx - 1] : ("<s" + std::to_string(idx) + ">");
}

} // namespace luau
