// One-off tool (2026-10-26): patch EventVendor.lua_B proto[20]'s single JUMPIFEQ instruction so the
// weekly-rotation equality compares a register against itself (always true), instead of
// week_counter % eligible_count == this_item_position. Operates on the CANONICAL (U43-numbered) form
// via de::change_build_profile(bytes, false/true) with no name map (opcode-only conversion, proven
// safe by cfg_identity_cmd.h's identical call), so it never needs the U44 native-name map that this
// module's calls are missing from. Never touches any byte outside the targeted instruction's A operand.
#include "../../src/de_build_profile.h"
#include "../../src/transcode.h"

#include <cstdio>
#include <cstring>
#include <fstream>
#include <sstream>
#include <string>

static std::string read_file(const std::string& path) {
    std::ifstream f(path, std::ios::binary);
    if (!f) throw std::runtime_error("cannot read " + path);
    std::ostringstream ss; ss << f.rdbuf();
    return ss.str();
}
static void write_file(const std::string& path, const std::string& data) {
    std::ofstream f(path, std::ios::binary);
    if (!f) throw std::runtime_error("cannot write " + path);
    f.write(data.data(), (std::streamsize)data.size());
}

int main(int argc, char** argv) {
    if (argc != 3) { std::fprintf(stderr, "usage: %s <stock EventVendor.lua_B> <out .lua_B>\n", argv[0]); return 1; }
    try {
        const std::string stock = read_file(argv[1]);
        // raw U44 -> canonical (U43 opcode numbering), names=nullptr: opcode-only, no native-name lowering.
        const std::string canonical = de::change_build_profile(stock, /*to_u44=*/false);

        de::Module m = de::walk(canonical);
        const int pidx = 20;             // as labelled by `ir-u44` / `cfg-identity --u44` on the canonical form
        const uint8_t findop = 0x37;      // JUMPIFEQ
        const int nth = 0;                // the one occurrence in this proto
        const int newA = 21;              // was 22 (compares R22==R21); make it R21==R21 (always true)
        if (pidx < 0 || pidx >= (int)m.protos.size()) throw std::runtime_error("bad proto index");
        de::Proto& p = m.protos[pidx];
        size_t o = 0; int seen = 0, idx = 0; bool done = false;
        while (o + 4 <= p.code.size()) {
            uint32_t w; std::memcpy(&w, p.code.data() + o, 4);
            uint8_t op = w & 0xff;
            bool wide = tc::is_de_width8(op);
            if (op == findop) {
                if (seen == nth) {
                    const uint8_t beforeA = (uint8_t)p.code[o + 1];
                    p.code[o + 1] = (char)newA;
                    std::printf("patched proto[%d] insn %d @0x%zx : JUMPIFEQ A %d -> %d (opcode and every other byte unchanged)\n",
                                pidx, idx, o, beforeA, newA);
                    done = true; break;
                }
                ++seen;
            }
            o += wide ? 8 : 4; ++idx;
        }
        if (!done) throw std::runtime_error("target instruction not found (nth occurrence missing)");

        const std::string canonical_patched = de::encode(m);
        // canonical -> raw U44, names=nullptr again: same opcode-only conversion, reversed.
        const std::string raw_patched = de::change_build_profile(canonical_patched, /*to_u44=*/true);
        write_file(argv[2], raw_patched);
        std::printf("wrote %s (%zu bytes, stock was %zu bytes)\n", argv[2], raw_patched.size(), stock.size());
        return 0;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "error: %s\n", e.what());
        return 1;
    }
}
