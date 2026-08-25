// Build the curated Warframe API catalog from the audited per-call census.
//
// This tool does not infer engine types.  It binds every curated API identity
// to measurable bytecode facts (hash, sites, modules, prototypes, call/result
// widths and consumption categories) and marks deeper hand-checked contracts.

#include <algorithm>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <vector>

namespace
{
struct Seed
{
    std::string kind, owner, name, labels, returnFamily, rationale;
};

struct Aggregate
{
    std::set<std::string> hashes, modules, prototypes, encodedArgs, results, categories;
    std::size_t sites = 0;
};

std::vector<std::string> split(const std::string &line, char separator)
{
    std::vector<std::string> result;
    std::size_t from = 0;
    for (;;)
    {
        const std::size_t at = line.find(separator, from);
        result.push_back(line.substr(from, at == std::string::npos ? at : at - from));
        if (at == std::string::npos)
            break;
        from = at + 1;
    }
    if (!result.empty() && !result.back().empty() && result.back().back() == '\r')
        result.back().pop_back();
    return result;
}

std::string join(const std::set<std::string> &values)
{
    std::string out;
    for (const std::string &value : values)
    {
        if (!out.empty())
            out += '|';
        out += value;
    }
    return out.empty() ? "-" : out;
}

bool hasLabel(const std::string &labels, const std::string &wanted)
{
    const std::vector<std::string> values = split(labels, ';');
    return std::find(values.begin(), values.end(), wanted) != values.end();
}

bool readSeeds(const std::string &path, std::vector<Seed> &seeds, std::string &error)
{
    std::ifstream input(path, std::ios::binary);
    if (!input)
    {
        error = "cannot read seeds: " + path;
        return false;
    }
    std::string line;
    int lineNo = 0;
    std::set<std::string> identities;
    while (std::getline(input, line))
    {
        ++lineNo;
        if (line.empty() || line[0] == '#')
            continue;
        const std::vector<std::string> f = split(line, '\t');
        if (lineNo == 1)
        {
            if (f.size() != 6 || f[0] != "kind" || f[2] != "name")
            {
                error = "unexpected seed header";
                return false;
            }
            continue;
        }
        if (f.size() != 6)
        {
            error = "seed line " + std::to_string(lineNo) + " must have 6 fields";
            return false;
        }
        Seed seed{f[0], f[1], f[2], f[3], f[4], f[5]};
        const std::string identity = seed.kind + '|' + seed.owner + '|' + seed.name;
        if (!identities.insert(identity).second)
        {
            error = "duplicate seed identity: " + identity;
            return false;
        }
        seeds.push_back(seed);
    }
    return true;
}

bool readContractNames(const std::string &path, std::set<std::string> &names,
                       std::string &error)
{
    std::ifstream input(path, std::ios::binary);
    if (!input)
    {
        error = "cannot read contracts: " + path;
        return false;
    }
    std::string line;
    int lineNo = 0;
    while (std::getline(input, line))
    {
        ++lineNo;
        if (line.empty() || line[0] == '#')
            continue;
        const std::vector<std::string> f = split(line, '\t');
        if (lineNo == 1)
            continue;
        if (f.size() != 15)
        {
            error = "contract line " + std::to_string(lineNo) + " must have 15 fields";
            return false;
        }
        if (f[12] == "CONFIRMED")
            names.insert(f[0] + '|' + f[2]);
    }
    return true;
}

bool readCensus(const std::string &path, std::map<std::string, Aggregate> &byName,
                std::size_t &siteRows, std::string &error)
{
    std::ifstream input(path, std::ios::binary);
    if (!input)
    {
        error = "cannot read census: " + path;
        return false;
    }
    std::string line;
    int lineNo = 0;
    while (std::getline(input, line))
    {
        ++lineNo;
        if (line.empty() || line[0] == '#')
            continue;
        const std::vector<std::string> f = split(line, '\t');
        if (lineNo == 1)
        {
            if (f.size() != 9 || f[0] != "module" || f[3] != "method")
            {
                error = "unexpected census header";
                return false;
            }
            continue;
        }
        if (f.size() != 9)
        {
            error = "census line " + std::to_string(lineNo) + " must have 9 fields";
            return false;
        }
        Aggregate &a = byName[f[3]];
        ++a.sites;
        ++siteRows;
        a.hashes.insert(f[4]);
        a.modules.insert(f[0]);
        a.prototypes.insert(f[0] + '#' + f[1]);
        a.encodedArgs.insert(f[5]);
        a.results.insert(f[6]);
        a.categories.insert(f[7]);
    }
    return true;
}

std::string visibleArgs(const Seed &seed, const Aggregate &aggregate)
{
    if (seed.kind != "method")
        return "contract_only";
    std::set<std::string> visible;
    for (const std::string &encoded : aggregate.encodedArgs)
    {
        if (encoded == "-1")
            visible.insert("open");
        else
        {
            const int count = std::atoi(encoded.c_str());
            visible.insert(std::to_string(std::max(0, count - 1)));
        }
    }
    return join(visible);
}

std::string structuralStatus(const Aggregate *aggregate, bool deepContract)
{
    if (deepContract)
        return "DEEP_CONTRACT";
    if (!aggregate || aggregate->sites == 0)
        return "UNSUPPORTED";
    const bool stableArgs = aggregate->encodedArgs.size() == 1 &&
                            !aggregate->encodedArgs.count("-1");
    const bool stableResults = aggregate->results.size() == 1 &&
                               !aggregate->results.count("-1");
    if (stableArgs && stableResults)
        return "OBSERVED_STABLE_SHAPE";
    if (stableArgs)
        return "OBSERVED_STABLE_ARGS";
    return "OBSERVED_VARIABLE_OR_OPEN";
}
}

int main(int argc, char **argv)
{
    if (argc != 5)
    {
        std::cerr << "usage: wf_api_catalog SEEDS.TSV CENSUS_SITES.TSV "
                     "CONTRACTS.TSV OUTPUT.TSV\n";
        return 2;
    }

    std::vector<Seed> seeds;
    std::map<std::string, Aggregate> census;
    std::set<std::string> contractNames;
    std::string error;
    std::size_t censusRows = 0;
    if (!readSeeds(argv[1], seeds, error) ||
        !readCensus(argv[2], census, censusRows, error) ||
        !readContractNames(argv[3], contractNames, error))
    {
        std::cerr << "wf_api_catalog: " << error << '\n';
        return 2;
    }
    if (censusRows != 55709)
    {
        std::cerr << "wf_api_catalog: expected audited 55709 census rows, got "
                  << censusRows << '\n';
        return 2;
    }

    std::ofstream output(argv[4], std::ios::binary | std::ios::trunc);
    if (!output)
    {
        std::cerr << "wf_api_catalog: cannot write output: " << argv[4] << '\n';
        return 2;
    }
    output << "kind\towner_hint\tname\tlabels\treturn_family_hint\thash\tsites\tmodules"
              "\tprototypes\tencoded_args_including_receiver\tvisible_args\tobserved_results"
              "\tconsumption_categories\tevidence_grade\tdeep_contract\trationale\n";

    std::size_t core = 0, high = 0, supported = 0, deep = 0;
    for (const Seed &seed : seeds)
    {
        core += hasLabel(seed.labels, "CORE") ? 1 : 0;
        high += hasLabel(seed.labels, "HIGH_CONFIDENCE") ? 1 : 0;
        const auto found = census.find(seed.name);
        const Aggregate *aggregate = found == census.end() ? nullptr : &found->second;
        const bool deepContract = contractNames.count(seed.kind + '|' + seed.name) != 0;
        const bool hasSupport = (aggregate && aggregate->sites) || deepContract;
        supported += hasSupport ? 1 : 0;
        deep += deepContract ? 1 : 0;
        if (!hasSupport)
        {
            std::cerr << "wf_api_catalog: unsupported selection " << seed.kind << ':'
                      << seed.owner << ':' << seed.name << '\n';
            return 1;
        }
        const Aggregate empty;
        const Aggregate &a = aggregate ? *aggregate : empty;
        output << seed.kind << '\t' << seed.owner << '\t' << seed.name << '\t'
               << seed.labels << '\t' << seed.returnFamily << '\t'
               << join(a.hashes) << '\t' << a.sites << '\t' << a.modules.size() << '\t'
               << a.prototypes.size() << '\t' << join(a.encodedArgs) << '\t'
               << visibleArgs(seed, a) << '\t' << join(a.results) << '\t'
               << join(a.categories) << '\t'
               << structuralStatus(aggregate, deepContract) << '\t'
               << (deepContract ? "yes" : "no") << '\t' << seed.rationale << '\n';
    }
    output.close();

    if (seeds.size() != 150 || core != 150 || high != 100 || supported != 150)
    {
        std::cerr << "wf_api_catalog: selection gate failed rows=" << seeds.size()
                  << " core=" << core << " high=" << high
                  << " supported=" << supported << '\n';
        return 1;
    }
    std::cout << "CATALOG PASS rows=150 core=150 high_confidence=100 supported=150"
              << " deep_contracts=" << deep << " census_rows=" << censusRows << '\n';
    return 0;
}
