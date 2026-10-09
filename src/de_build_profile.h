#pragma once
#include "de_container.h"
#include "de_opcode_profile.h"
#include <cstring>
#include <cstdio>
#include <map>

namespace de {
// Structural validity of every prototype's code under ONE opcode numbering (u44 = native U44
// handler numbers lowered through u44_to_u43; otherwise canonical U43 numbers). Returns "" when
// valid, else the first violation. Valid means: every opcode byte is inside the 86-entry table, the
// AUX-width walk lands exactly on the code end, and every branch target (signed Bx, base op+4)
// lands on an instruction boundary inside the code. No opcode SEMANTICS beyond widths and branch
// positions (OPCODE_MAP section 0) are assumed.
// Measured 2026-10-09 (44.1.1 stock, 5,478 modules): 5,465 valid only as U44, 13 valid only as
// U43 (stale debug/ImGui/Cmd scripts + HighwayVehicle, byte-identical to the U43 corpus), 0 valid
// under both; U43 corpus control 5,386/5,386 valid only as U43.
inline std::string profile_walk_problem(const Module& module, bool u44) {
    for (size_t index = 0; index < module.protos.size(); ++index) {
        const std::string& code = module.protos[index].code;
        std::vector<char> boundary(code.size() + 1, 0);
        std::vector<std::pair<size_t, long long>> branches;
        size_t offset = 0;
        while (offset < code.size()) {
            const auto raw = static_cast<std::uint8_t>(code[offset]);
            if (raw >= renovice::bytecode::u43_to_u44.size())
                return "proto " + std::to_string(index) + " opcode byte " + std::to_string(raw)
                     + " outside the 86-entry table at byte " + std::to_string(offset);
            const auto op = renovice::bytecode::canonical_opcode(raw, u44);
            boundary[offset] = 1;
            switch (op) {
            case 0x40: case 0x25: case 0x4b: case 0x18: case 0x37: case 0x27: case 0x21:
            case 0x1c: case 0x23: case 0x33: case 0x20: case 0x41: case 0x34: case 0x3a:
            case 0x47: case 0x0a: case 0x0b: case 0x30: case 0x1b: case 0x1e: {
                if (offset + 4 > code.size()) break;
                const int bx = static_cast<std::int16_t>(
                    static_cast<std::uint16_t>((std::uint8_t)code[offset + 2]
                                               | ((std::uint8_t)code[offset + 3] << 8)));
                branches.emplace_back(offset, (long long)offset + 4 + (long long)bx * 4);
                break;
            }
            default: break;
            }
            offset += renovice::bytecode::canonical_has_aux(op) ? 8 : 4;
        }
        if (offset != code.size())
            return "proto " + std::to_string(index) + " width walk overruns the code end";
        for (const auto& branch : branches)
            if (branch.second < 0 || branch.second >= (long long)code.size() || !boundary[(size_t)branch.second])
                return "proto " + std::to_string(index) + " branch at byte " + std::to_string(branch.first)
                     + " targets byte " + std::to_string(branch.second) + " (not an instruction boundary)";
    }
    return "";
}

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
