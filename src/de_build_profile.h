#pragma once
#include "de_container.h"
#include "de_opcode_profile.h"
#include <cstring>
#include <cstdio>
#include <map>

namespace de {
// Structured version lowering: operands, AUX words, prototype topology, constants
// other than proven native-name hashes, and debug data retain their exact values.
inline std::string change_build_profile(const std::string& input, bool to_u44,
    const std::map<std::uint32_t, std::uint32_t>* names = nullptr) {
    Module module = walk(input);
    for (Proto& p : module.protos) {
        for (size_t offset = 0; offset < p.code.size();) {
            const auto raw = static_cast<std::uint8_t>(p.code[offset]);
            if (raw >= renovice::bytecode::u43_to_u44.size())
                throw std::runtime_error("profile: unsupported opcode " + std::to_string(raw));
            const auto canonical = renovice::bytecode::canonical_opcode(raw, !to_u44);
            const size_t width = renovice::bytecode::canonical_has_aux(canonical) ? 8 : 4;
            if (offset + width > p.code.size()) throw std::runtime_error("profile: truncated AUX word");
            p.code[offset] = static_cast<char>(to_u44 ? renovice::bytecode::u43_to_u44[canonical] : canonical);
            offset += width;
        }
        if (names) for (Const& c : p.consts) {
            if (c.tag != 1) continue;
            std::uint32_t before = 0;
            std::memcpy(&before, c.raw.data(), sizeof(before));
            const auto found = names->find(before);
            if (found == names->end()) {
                char text[80]; std::snprintf(text, sizeof(text), "profile: unresolved native name %08x", before);
                throw std::runtime_error(text);
            }
            std::memcpy(c.raw.data(), &found->second, sizeof(found->second));
        }
    }
    return encode(module);
}
}
