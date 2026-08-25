#include <cstdint>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

namespace {
constexpr std::uint64_t image_base = 0x140000000ULL;
constexpr std::uint64_t text_rva = 0x1000ULL;
constexpr std::size_t text_file_offset = 0x400;
constexpr std::size_t text_file_size = 33706496;

std::uint64_t file_offset_to_va(std::size_t offset)
{
    return image_base + text_rva + (offset - text_file_offset);
}
}

int main(int argc, char** argv)
{
    if (argc != 3)
    {
        std::cerr << "usage: find_rel32_xrefs <Warframe.x64.exe> <target-va-hex>\n";
        return 2;
    }

    const std::uint64_t target = std::stoull(argv[2], nullptr, 16);
    std::ifstream input(argv[1], std::ios::binary);
    if (!input)
    {
        std::cerr << "cannot open input\n";
        return 3;
    }
    const std::vector<std::uint8_t> bytes{
        std::istreambuf_iterator<char>(input), std::istreambuf_iterator<char>()};
    const std::size_t text_end = std::min(
        bytes.size(), text_file_offset + text_file_size);

    std::size_t count = 0;
    for (std::size_t offset = text_file_offset; offset + 5 <= text_end; ++offset)
    {
        if (bytes[offset] != 0xE8) continue;
        std::int32_t displacement = 0;
        std::memcpy(&displacement, bytes.data() + offset + 1, sizeof(displacement));
        const std::uint64_t callsite = file_offset_to_va(offset);
        const std::uint64_t destination = static_cast<std::uint64_t>(
            static_cast<std::int64_t>(callsite + 5)
            + static_cast<std::int64_t>(displacement));
        if (destination != target) continue;
        std::cout << "callsite_va=0x" << std::hex << std::uppercase << callsite
                  << " file_offset=0x" << offset << '\n';
        ++count;
    }
    std::cout << "count=" << std::dec << count << '\n';
    return 0;
}
