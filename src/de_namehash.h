// de_namehash.h - DE (Warframe EE-Lua) global/method NAME HASH.  C++ port of de_namehash.py.
// = FNV-1a over raw UTF-8 name bytes, then finalizer (bitwise-NOT, then rotate-left-17), build-specific seed.
// Used for DE tag-1 name constants (GETGLOBAL/NAMECALL/GETFIELD/import path parts).
// Self-test: de_name_hash("GetConfigBool") == 0x4AEC2DAC for seed 0x7E5AF8E9 (build 2026.06.19.13.22).
#pragma once
#include <cstdint>
#include <string>
#include <cctype>
#include <cstdlib>

namespace de {

static const uint32_t NAMEHASH_SEED_2026_06_19 = 0x7E5AF8E9u;

inline uint32_t de_name_hash(const std::string& name, uint32_t seed = NAMEHASH_SEED_2026_06_19) {
    uint32_t h = seed;
    for (unsigned char by : name) h = (h ^ (uint32_t)by) * 0x01000193u;   // FNV-1a (prime 16777619), uint32 wrap
    h = ~h;                                                                // finalizer 1: bitwise NOT
    return (h << 17) | (h >> 15);                                          // finalizer 2: rotate-left 17
}

// Honors the decompiler's `RealName__aabbccdd` convention: the __<8 hex> suffix IS the true 32-bit hash
// (for natives whose name couldn't be resolved). Plain names hash normally.
inline uint32_t resolve_name_hash(const std::string& name) {
    size_t sz = name.size();
    if (sz >= 10 && name[sz - 9] == '_' && name[sz - 10] == '_') {
        bool hex = true;
        for (size_t i = sz - 8; i < sz; ++i) if (!std::isxdigit((unsigned char)name[i])) { hex = false; break; }
        if (hex) return (uint32_t)std::strtoul(name.substr(sz - 8).c_str(), nullptr, 16);
    }
    return de_name_hash(name);
}

} // namespace de
