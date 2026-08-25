#include <algorithm>
#include <array>
#include <cctype>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace
{
constexpr std::size_t header_size = 8;
constexpr std::size_t entry_size = 96;

struct RawEntry
{
    std::int64_t cache_offset = 0;
    std::uint32_t parent_directory = 0;
    std::string name;
};

std::uint32_t read_u32(const std::array<unsigned char, entry_size>& bytes, std::size_t offset)
{
    return static_cast<std::uint32_t>(bytes[offset])
        | (static_cast<std::uint32_t>(bytes[offset + 1]) << 8)
        | (static_cast<std::uint32_t>(bytes[offset + 2]) << 16)
        | (static_cast<std::uint32_t>(bytes[offset + 3]) << 24);
}

std::int64_t read_i64(const std::array<unsigned char, entry_size>& bytes, std::size_t offset)
{
    const auto low = static_cast<std::uint64_t>(read_u32(bytes, offset));
    const auto high = static_cast<std::uint64_t>(read_u32(bytes, offset + 4));
    return static_cast<std::int64_t>(low | (high << 32));
}

std::string lower(std::string_view input)
{
    std::string result(input);
    std::transform(result.begin(), result.end(), result.begin(), [](unsigned char ch)
    {
        return static_cast<char>(std::tolower(ch));
    });
    return result;
}

std::optional<std::string> build_directory_path(
    std::size_t index,
    const std::vector<RawEntry>& directories,
    std::vector<std::optional<std::string>>& cache,
    std::vector<bool>& visiting)
{
    if (index >= directories.size())
    {
        return std::nullopt;
    }
    if (cache[index])
    {
        return cache[index];
    }
    if (visiting[index])
    {
        return std::nullopt;
    }

    visiting[index] = true;
    const auto& directory = directories[index];
    const auto parent = static_cast<std::size_t>(directory.parent_directory);
    if (parent == index)
    {
        visiting[index] = false;
        return std::nullopt;
    }
    const auto parent_path = build_directory_path(parent, directories, cache, visiting);
    visiting[index] = false;
    if (!parent_path)
    {
        return std::nullopt;
    }

    cache[index] = *parent_path + "/" + directory.name;
    return cache[index];
}

std::optional<std::vector<std::string>> resolve_paths(const std::vector<RawEntry>& records)
{
    // parent_directory indexes this directory-only array. Index zero is the
    // synthetic root; flat TOC record indexes are deliberately never used.
    std::vector<RawEntry> directories{{-1, 0, ""}};
    std::vector<RawEntry> files;
    directories.reserve(records.size() + 1);
    files.reserve(records.size());
    for (const auto& record : records)
    {
        if (record.cache_offset == -1)
        {
            directories.push_back(record);
        }
        else
        {
            files.push_back(record);
        }
    }

    std::vector<std::optional<std::string>> directory_paths(directories.size());
    std::vector<bool> visiting(directories.size(), false);
    directory_paths[0] = std::string{};
    for (std::size_t index = 1; index < directories.size(); ++index)
    {
        if (!build_directory_path(index, directories, directory_paths, visiting))
        {
            return std::nullopt;
        }
    }

    std::vector<std::string> paths;
    paths.reserve((directories.size() - 1) + files.size());
    for (std::size_t index = 1; index < directories.size(); ++index)
    {
        paths.push_back(*directory_paths[index]);
    }
    for (const auto& file : files)
    {
        const auto parent = static_cast<std::size_t>(file.parent_directory);
        if (parent >= directory_paths.size() || !directory_paths[parent])
        {
            return std::nullopt;
        }
        paths.push_back(*directory_paths[parent] + "/" + file.name);
    }
    return paths;
}

bool self_test()
{
    const std::vector<RawEntry> records{
        {-1, 0, "Lotus"},
        {100, 1, "root-file.bin"},
        {-1, 1, "Powersuits"},
        {200, 2, "suit-file.bin"},
        {-1, 2, "Bard"},
        {300, 3, "BardMusic.lua"},
    };
    const auto paths = resolve_paths(records);
    const std::vector<std::string> expected{
        "/Lotus",
        "/Lotus/Powersuits",
        "/Lotus/Powersuits/Bard",
        "/Lotus/root-file.bin",
        "/Lotus/Powersuits/suit-file.bin",
        "/Lotus/Powersuits/Bard/BardMusic.lua",
    };
    if (!paths || *paths != expected)
    {
        std::cerr << "SELFTEST FAIL: directory-only parent indexing\n";
        return false;
    }
    std::cout << "SELFTEST PASS: directory-only parent indexing\n";
    return true;
}
}

int main(int argc, char** argv)
{
    if (argc == 2 && std::string_view(argv[1]) == "--selftest")
    {
        return self_test() ? 0 : 1;
    }
    if (argc < 3)
    {
        std::cerr << "usage: toc_path_search <file.toc> <term> [term ...]\n"
                     "       toc_path_search --selftest\n";
        return 2;
    }

    const std::filesystem::path toc_path = argv[1];
    std::ifstream input(toc_path, std::ios::binary);
    if (!input)
    {
        std::cerr << "error: cannot open " << toc_path.string() << '\n';
        return 3;
    }
    input.seekg(0, std::ios::end);
    const auto raw_size = input.tellg();
    if (raw_size < static_cast<std::streamoff>(header_size)
        || (raw_size - static_cast<std::streamoff>(header_size))
            % static_cast<std::streamoff>(entry_size) != 0)
    {
        std::cerr << "error: invalid TOC size " << raw_size << '\n';
        return 4;
    }
    const auto count = static_cast<std::size_t>(
        (raw_size - static_cast<std::streamoff>(header_size))
        / static_cast<std::streamoff>(entry_size));
    input.seekg(static_cast<std::streamoff>(header_size), std::ios::beg);

    std::vector<RawEntry> records;
    records.reserve(count);
    for (std::size_t index = 0; index < count; ++index)
    {
        std::array<unsigned char, entry_size> bytes{};
        if (!input.read(reinterpret_cast<char*>(bytes.data()), bytes.size()))
        {
            std::cerr << "error: short read at entry " << (index + 1) << '\n';
            return 5;
        }
        const auto name_begin = reinterpret_cast<const char*>(bytes.data() + 32);
        const auto name_end = std::find(name_begin, name_begin + 64, '\0');
        records.push_back({
            read_i64(bytes, 0),
            read_u32(bytes, 28),
            std::string(name_begin, name_end),
        });
    }

    const auto paths = resolve_paths(records);
    if (!paths)
    {
        std::cerr << "error: invalid directory-only parent graph\n";
        return 6;
    }

    std::vector<std::string> terms;
    for (int i = 2; i < argc; ++i)
    {
        terms.emplace_back(lower(argv[i]));
    }

    std::size_t matches = 0;
    for (const auto& path : *paths)
    {
        const auto folded = lower(path);
        const bool matched = std::any_of(terms.begin(), terms.end(), [&](const std::string& term)
        {
            return folded.find(term) != std::string::npos;
        });
        if (matched)
        {
            std::cout << path << '\n';
            ++matches;
        }
    }

    std::cerr << "records=" << records.size() << " paths=" << paths->size()
              << " matches=" << matches << '\n';
    return 0;
}
