// Fast focused Warframe native-API contract checker.
//
// This is intentionally not a corpus scanner. It checks API calls in one
// authored/reconstructed source file against api/warframe/contracts.tsv.
// Receiver types are not inferred yet, so method overloads are matched by name
// and visible argument count. Qualified global functions (for example
// Engine.RadialDamageData) are matched exactly.

#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <vector>

namespace wfapi
{
    struct Contract
    {
        std::string kind;
        std::string owner;
        std::string name;
        int minArgs = -1;
        int maxArgs = -1;
        std::string parameters;
        std::string returns;
        int callbackArity = -1;
        std::string callbackParameters;
        std::string confidence;
        std::string status;
        std::string evidence;
    };

    struct Call
    {
        std::string kind;
        std::string name;
        int args = -1;
        int callbackArity = -1;
        int line = 1;
    };

    struct CatalogEntry
    {
        std::string kind;
        std::string owner;
        std::string name;
        std::string labels;
        std::string visibleArgs;
        std::string evidenceGrade;
    };

    struct RegistryStats
    {
        size_t evidenceIds = 0;
        size_t negativeContracts = 0;
        size_t coreApis = 0;
        size_t highConfidenceApis = 0;
        size_t catalogDeepContracts = 0;
    };

    static bool readFile(const std::string &path, std::string &out)
    {
        std::ifstream f(path, std::ios::binary);
        if (!f)
            return false;
        std::ostringstream ss;
        ss << f.rdbuf();
        out = ss.str();
        return true;
    }

    static std::vector<std::string> splitTabs(const std::string &line)
    {
        std::vector<std::string> fields;
        size_t from = 0;
        while (true)
        {
            size_t at = line.find('\t', from);
            fields.push_back(line.substr(from, at == std::string::npos
                                                   ? std::string::npos
                                                   : at - from));
            if (at == std::string::npos)
                break;
            from = at + 1;
        }
        if (!fields.empty() && !fields.back().empty() && fields.back().back() == '\r')
            fields.back().pop_back();
        return fields;
    }

    static int parseCount(const std::string &value)
    {
        if (value.empty() || value == "-")
            return -1;
        return std::atoi(value.c_str());
    }

    static bool loadContracts(const std::string &path,
                              std::vector<Contract> &contracts,
                              std::string &error)
    {
        std::string text;
        if (!readFile(path, text))
        {
            error = "cannot read contract registry: " + path;
            return false;
        }
        std::istringstream input(text);
        std::string line;
        bool header = true;
        int lineNo = 0;
        std::set<std::string> identities;
        while (std::getline(input, line))
        {
            ++lineNo;
            if (line.empty() || line[0] == '#')
                continue;
            std::vector<std::string> f = splitTabs(line);
            if (header)
            {
                header = false;
                if (f.size() != 15 || f[0] != "kind" || f[2] != "name")
                {
                    error = "unexpected contracts.tsv header";
                    return false;
                }
                continue;
            }
            if (f.size() != 15)
            {
                error = "contracts.tsv line " + std::to_string(lineNo) +
                        " has " + std::to_string(f.size()) + " fields; expected 15";
                return false;
            }
            Contract c;
            c.kind = f[0];
            c.owner = f[1];
            c.name = f[2];
            c.minArgs = parseCount(f[3]);
            c.maxArgs = parseCount(f[4]);
            c.parameters = f[5];
            c.returns = f[6];
            c.callbackArity = parseCount(f[7]);
            c.callbackParameters = f[8];
            c.confidence = f[11];
            c.status = f[12];
            c.evidence = f[13];
            if (c.minArgs >= 0 && (c.maxArgs < c.minArgs))
            {
                error = "contracts.tsv line " + std::to_string(lineNo) +
                        " has an invalid argument range";
                return false;
            }
            if (c.confidence != "LIVE_CONFIRMED" &&
                c.confidence != "STOCK_BYTECODE" &&
                c.confidence != "OFFLINE_FIXTURE" &&
                c.confidence != "UNRESOLVED")
            {
                error = "contracts.tsv line " + std::to_string(lineNo) +
                        " has an unknown confidence: " + c.confidence;
                return false;
            }
            std::string identity = c.kind + "|" + c.owner + "|" + c.name + "|" +
                                   f[3] + "|" + f[4] + "|" + f[7];
            if (!identities.insert(identity).second)
            {
                error = "duplicate contract identity at line " +
                        std::to_string(lineNo) + ": " + identity;
                return false;
            }
            if (c.status == "CONFIRMED")
                contracts.push_back(c);
        }
        return true;
    }

    static std::string siblingPath(const std::string &path, const char *name)
    {
        size_t slash = path.find_last_of("/\\");
        if (slash == std::string::npos)
            return name;
        return path.substr(0, slash + 1) + name;
    }

    static std::vector<std::string> splitSemicolon(const std::string &value)
    {
        std::vector<std::string> result;
        size_t from = 0;
        while (from <= value.size())
        {
            size_t at = value.find(';', from);
            std::string item = value.substr(from, at == std::string::npos
                                                      ? std::string::npos
                                                      : at - from);
            if (!item.empty() && item != "-")
                result.push_back(item);
            if (at == std::string::npos)
                break;
            from = at + 1;
        }
        return result;
    }

    static std::vector<std::string> splitPipe(const std::string &value)
    {
        std::vector<std::string> result;
        size_t from = 0;
        while (from <= value.size())
        {
            size_t at = value.find('|', from);
            result.push_back(value.substr(from, at == std::string::npos
                                                    ? std::string::npos
                                                    : at - from));
            if (at == std::string::npos)
                break;
            from = at + 1;
        }
        return result;
    }

    static bool validateEvidence(const std::string &contractPath,
                                 const std::vector<Contract> &contracts,
                                 RegistryStats &stats,
                                 std::string &error)
    {
        const std::string evidencePath = siblingPath(contractPath, "evidence.tsv");
        std::string text;
        if (!readFile(evidencePath, text))
        {
            error = "cannot read evidence registry: " + evidencePath;
            return false;
        }
        std::set<std::string> ids;
        std::istringstream input(text);
        std::string line;
        bool header = true;
        int lineNo = 0;
        while (std::getline(input, line))
        {
            ++lineNo;
            if (line.empty() || line[0] == '#')
                continue;
            std::vector<std::string> f = splitTabs(line);
            if (header)
            {
                header = false;
                if (f.size() != 6 || f[0] != "evidence_id")
                {
                    error = "unexpected evidence.tsv header";
                    return false;
                }
                continue;
            }
            if (f.size() != 6 || f[0].empty())
            {
                error = "evidence.tsv line " + std::to_string(lineNo) +
                        " must have 6 fields and a non-empty ID";
                return false;
            }
            if (!ids.insert(f[0]).second)
            {
                error = "duplicate evidence ID: " + f[0];
                return false;
            }
        }
        for (const Contract &c : contracts)
            for (const std::string &id : splitSemicolon(c.evidence))
                if (!ids.count(id))
                {
                    error = "contract " + c.owner + ":" + c.name +
                            " references missing evidence ID " + id;
                    return false;
                }

        const std::string negativePath = siblingPath(contractPath, "negative_contracts.tsv");
        if (!readFile(negativePath, text))
        {
            error = "cannot read negative-contract registry: " + negativePath;
            return false;
        }
        std::istringstream negatives(text);
        header = true;
        lineNo = 0;
        size_t negativeCount = 0;
        while (std::getline(negatives, line))
        {
            ++lineNo;
            if (line.empty() || line[0] == '#')
                continue;
            std::vector<std::string> f = splitTabs(line);
            if (header)
            {
                header = false;
                if (f.size() != 4 || f[0] != "hypothesis")
                {
                    error = "unexpected negative_contracts.tsv header";
                    return false;
                }
                continue;
            }
            if (f.size() != 4 || !ids.count(f[2]))
            {
                error = "negative_contracts.tsv line " + std::to_string(lineNo) +
                        " has an invalid shape or missing evidence ID";
                return false;
            }
            ++negativeCount;
        }
        stats.evidenceIds = ids.size();
        stats.negativeContracts = negativeCount;
        return true;
    }

    static bool validateSelectionCatalog(const std::string &contractPath,
                                         std::vector<CatalogEntry> &entries,
                                         RegistryStats &stats,
                                         std::string &error)
    {
        const std::string seedPath = siblingPath(contractPath, "selection_seeds.tsv");
        const std::string catalogPath = siblingPath(contractPath, "selected_catalog.tsv");
        std::string text;
        if (!readFile(seedPath, text))
        {
            error = "cannot read API selection: " + seedPath;
            return false;
        }

        std::set<std::string> seedIds;
        size_t seedCore = 0, seedHigh = 0;
        std::istringstream seeds(text);
        std::string line;
        bool header = true;
        int lineNo = 0;
        while (std::getline(seeds, line))
        {
            ++lineNo;
            if (line.empty() || line[0] == '#')
                continue;
            std::vector<std::string> f = splitTabs(line);
            if (header)
            {
                header = false;
                if (f.size() != 6 || f[0] != "kind" || f[3] != "labels")
                {
                    error = "unexpected selection_seeds.tsv header";
                    return false;
                }
                continue;
            }
            if (f.size() != 6)
            {
                error = "selection_seeds.tsv line " + std::to_string(lineNo) +
                        " must have 6 fields";
                return false;
            }
            const std::vector<std::string> labelList = splitSemicolon(f[3]);
            const bool core = std::find(labelList.begin(), labelList.end(), "CORE") !=
                              labelList.end();
            const bool high = std::find(labelList.begin(), labelList.end(),
                                        "HIGH_CONFIDENCE") != labelList.end();
            if (!core || (high && !core))
            {
                error = "selection_seeds.tsv line " + std::to_string(lineNo) +
                        " must label every row CORE and HIGH_CONFIDENCE only as a subset";
                return false;
            }
            const std::string id = f[0] + "|" + f[1] + "|" + f[2];
            if (!seedIds.insert(id).second)
            {
                error = "duplicate API selection: " + id;
                return false;
            }
            ++seedCore;
            seedHigh += high ? 1 : 0;
        }

        if (!readFile(catalogPath, text))
        {
            error = "cannot read generated API catalog: " + catalogPath;
            return false;
        }
        std::set<std::string> catalogIds;
        size_t catalogCore = 0, catalogHigh = 0, catalogDeep = 0;
        std::istringstream catalog(text);
        header = true;
        lineNo = 0;
        while (std::getline(catalog, line))
        {
            ++lineNo;
            if (line.empty() || line[0] == '#')
                continue;
            std::vector<std::string> f = splitTabs(line);
            if (header)
            {
                header = false;
                if (f.size() != 16 || f[0] != "kind" || f[13] != "evidence_grade")
                {
                    error = "unexpected selected_catalog.tsv header";
                    return false;
                }
                continue;
            }
            if (f.size() != 16)
            {
                error = "selected_catalog.tsv line " + std::to_string(lineNo) +
                        " must have 16 fields";
                return false;
            }
            const std::vector<std::string> labels = splitSemicolon(f[3]);
            const bool core = std::find(labels.begin(), labels.end(), "CORE") != labels.end();
            const bool high = std::find(labels.begin(), labels.end(),
                                        "HIGH_CONFIDENCE") != labels.end();
            const std::string id = f[0] + "|" + f[1] + "|" + f[2];
            if (!catalogIds.insert(id).second)
            {
                error = "duplicate generated API catalog identity: " + id;
                return false;
            }
            if (high && (f[13] == "OBSERVED_VARIABLE_OR_OPEN" ||
                         f[13] == "UNSUPPORTED"))
            {
                error = "high-confidence API lacks stable/deep evidence: " + id;
                return false;
            }
            entries.push_back({f[0], f[1], f[2], f[3], f[10], f[13]});
            ++catalogCore;
            catalogHigh += high ? 1 : 0;
            catalogDeep += f[14] == "yes" ? 1 : 0;
            if (!core)
            {
                error = "generated API catalog contains a non-core row: " + id;
                return false;
            }
        }
        if (seedIds != catalogIds || seedCore != 150 || seedHigh != 100 ||
            catalogCore != 150 || catalogHigh != 100)
        {
            error = "API selection/catalog gate failed: expected matching 150 CORE / "
                    "100 HIGH_CONFIDENCE identities";
            return false;
        }
        stats.coreApis = catalogCore;
        stats.highConfidenceApis = catalogHigh;
        stats.catalogDeepContracts = catalogDeep;
        return true;
    }

    static bool identStart(char c)
    {
        return std::isalpha(static_cast<unsigned char>(c)) || c == '_';
    }

    static bool identChar(char c)
    {
        return std::isalnum(static_cast<unsigned char>(c)) || c == '_';
    }

    // Remove comments and strings while preserving line breaks and source
    // offsets. That keeps call line numbers deterministic and prevents API-like
    // text inside documentation from becoming a false call.
    static std::string sanitize(const std::string &source)
    {
        std::string out = source;
        enum State
        {
            Code,
            SingleQuote,
            DoubleQuote,
            LineComment,
            BlockComment,
            LongString
        } state = Code;

        for (size_t i = 0; i < source.size(); ++i)
        {
            char c = source[i];
            char n = i + 1 < source.size() ? source[i + 1] : '\0';
            if (state == Code)
            {
                if (c == '-' && n == '-')
                {
                    bool block = i + 3 < source.size() && source[i + 2] == '[' &&
                                 source[i + 3] == '[';
                    out[i] = out[i + 1] = ' ';
                    if (block)
                    {
                        out[i + 2] = out[i + 3] = ' ';
                        i += 3;
                        state = BlockComment;
                    }
                    else
                    {
                        ++i;
                        state = LineComment;
                    }
                }
                else if (c == '\'')
                {
                    out[i] = ' ';
                    state = SingleQuote;
                }
                else if (c == '"')
                {
                    out[i] = ' ';
                    state = DoubleQuote;
                }
                else if (c == '[' && n == '[')
                {
                    out[i] = out[i + 1] = ' ';
                    ++i;
                    state = LongString;
                }
            }
            else if (state == LineComment)
            {
                if (c == '\n')
                    state = Code;
                else
                    out[i] = ' ';
            }
            else if (state == BlockComment || state == LongString)
            {
                if (c == ']' && n == ']')
                {
                    out[i] = out[i + 1] = ' ';
                    ++i;
                    state = Code;
                }
                else if (c != '\n' && c != '\r')
                {
                    out[i] = ' ';
                }
            }
            else
            {
                char quote = state == SingleQuote ? '\'' : '"';
                if (c == '\\')
                {
                    out[i] = ' ';
                    if (i + 1 < source.size())
                    {
                        if (source[i + 1] != '\n' && source[i + 1] != '\r')
                            out[i + 1] = ' ';
                        ++i;
                    }
                }
                else if (c == quote)
                {
                    out[i] = ' ';
                    state = Code;
                }
                else if (c != '\n' && c != '\r')
                {
                    out[i] = ' ';
                }
            }
        }
        return out;
    }

    static size_t skipSpace(const std::string &s, size_t i)
    {
        while (i < s.size() && std::isspace(static_cast<unsigned char>(s[i])))
            ++i;
        return i;
    }

    static int countLine(const std::string &s, size_t at)
    {
        return 1 + static_cast<int>(std::count(s.begin(), s.begin() + at, '\n'));
    }

    static int callbackParameterCount(const std::string &s, size_t open)
    {
        size_t i = skipSpace(s, open + 1);
        if (s.compare(i, 8, "function") != 0 ||
            (i + 8 < s.size() && identChar(s[i + 8])))
            return -1;
        i = skipSpace(s, i + 8);
        if (i >= s.size() || s[i] != '(')
            return -1;
        size_t close = s.find(')', i + 1);
        if (close == std::string::npos)
            return -1;
        std::string params = s.substr(i + 1, close - i - 1);
        size_t p = skipSpace(params, 0);
        if (p == params.size())
            return 0;
        int count = 1;
        for (char c : params)
            if (c == ',')
                ++count;
        return count;
    }

    static int argumentCount(const std::string &s, size_t open)
    {
        int paren = 1, brace = 0, bracket = 0;
        bool any = false;
        int commas = 0;
        std::vector<std::string> blocks;
        bool skipLoopDo = false;

        for (size_t i = open + 1; i < s.size(); ++i)
        {
            char c = s[i];
            if (identStart(c))
            {
                size_t e = i + 1;
                while (e < s.size() && identChar(s[e]))
                    ++e;
                std::string word = s.substr(i, e - i);
                if (paren == 1 && brace == 0 && bracket == 0)
                {
                    any = true;
                    if (word == "function" || word == "if")
                        blocks.push_back("end");
                    else if (word == "for" || word == "while")
                    {
                        blocks.push_back("end");
                        skipLoopDo = true;
                    }
                    else if (word == "do")
                    {
                        if (skipLoopDo)
                            skipLoopDo = false;
                        else
                            blocks.push_back("end");
                    }
                    else if (word == "repeat")
                        blocks.push_back("until");
                    else if (word == "end" && !blocks.empty() && blocks.back() == "end")
                        blocks.pop_back();
                    else if (word == "until" && !blocks.empty() && blocks.back() == "until")
                        blocks.pop_back();
                }
                i = e - 1;
                continue;
            }
            if (c == '(')
                ++paren;
            else if (c == ')')
            {
                --paren;
                if (paren == 0)
                    return any ? commas + 1 : 0;
            }
            else if (c == '{')
                ++brace;
            else if (c == '}')
                --brace;
            else if (c == '[')
                ++bracket;
            else if (c == ']')
                --bracket;
            else if (c == ',' && paren == 1 && brace == 0 && bracket == 0 &&
                     blocks.empty())
                ++commas;
            else if (!std::isspace(static_cast<unsigned char>(c)) && paren == 1 &&
                     brace == 0 && bracket == 0 && blocks.empty())
                any = true;
        }
        return -1;
    }

    static std::vector<Call> findCalls(const std::string &source,
                                       const std::vector<Contract> &contracts)
    {
        std::string s = sanitize(source);
        std::set<std::string> globalOwners;
        std::set<std::string> globalNames;
        for (const Contract &c : contracts)
        {
            if (c.kind == "global_function")
            {
                if (c.owner == "_GLOBAL")
                    globalNames.insert(c.name);
                else
                    globalOwners.insert(c.owner);
            }
        }

        std::vector<Call> calls;
        for (size_t i = 0; i < s.size(); ++i)
        {
            if (s[i] == ':')
            {
                size_t b = skipSpace(s, i + 1);
                if (!identStart(b < s.size() ? s[b] : '\0'))
                    continue;
                size_t e = b + 1;
                while (e < s.size() && identChar(s[e]))
                    ++e;
                size_t open = skipSpace(s, e);
                if (open >= s.size() || s[open] != '(')
                    continue;
                Call call;
                call.kind = "method";
                call.name = s.substr(b, e - b);
                call.args = argumentCount(s, open);
                call.callbackArity = callbackParameterCount(s, open);
                call.line = countLine(s, i);
                calls.push_back(call);
                i = e - 1;
                continue;
            }

            if (!identStart(s[i]) || (i > 0 && identChar(s[i - 1])))
                continue;
            size_t e = i + 1;
            while (e < s.size() && identChar(s[e]))
                ++e;
            std::string first = s.substr(i, e - i);

            size_t dot = skipSpace(s, e);
            if (dot < s.size() && s[dot] == '.' && globalOwners.count(first))
            {
                size_t nb = skipSpace(s, dot + 1);
                if (!identStart(nb < s.size() ? s[nb] : '\0'))
                    continue;
                size_t ne = nb + 1;
                while (ne < s.size() && identChar(s[ne]))
                    ++ne;
                size_t open = skipSpace(s, ne);
                if (open < s.size() && s[open] == '(')
                {
                    Call call;
                    call.kind = "global_function";
                    call.name = first + "." + s.substr(nb, ne - nb);
                    call.args = argumentCount(s, open);
                    call.callbackArity = callbackParameterCount(s, open);
                    call.line = countLine(s, i);
                    calls.push_back(call);
                }
                i = ne - 1;
                continue;
            }

            size_t open = skipSpace(s, e);
            if (open < s.size() && s[open] == '(' && globalNames.count(first))
            {
                Call call;
                call.kind = "global_function";
                call.name = first;
                call.args = argumentCount(s, open);
                call.callbackArity = callbackParameterCount(s, open);
                call.line = countLine(s, i);
                calls.push_back(call);
            }
            i = e - 1;
        }
        return calls;
    }

    static std::string displayName(const Contract &c)
    {
        if (c.kind == "global_function" && c.owner == "_GLOBAL")
            return c.name;
        return c.owner + (c.kind == "method" ? ":" : ".") + c.name;
    }

    static bool catalogAllowsArgs(const CatalogEntry &entry, int args)
    {
        if (args < 0)
            return true;
        const std::vector<std::string> observed = splitPipe(entry.visibleArgs);
        for (const std::string &value : observed)
            if (value == "open" || std::atoi(value.c_str()) == args)
                return true;
        return false;
    }

    static bool catalogHighConfidence(const CatalogEntry &entry)
    {
        const std::vector<std::string> labels = splitSemicolon(entry.labels);
        return std::find(labels.begin(), labels.end(), "HIGH_CONFIDENCE") !=
               labels.end();
    }
}

int main(int argc, char **argv)
{
    if (argc < 3 || argc > 5)
    {
        std::fprintf(stderr,
                     "usage: wf_api_check CONTRACTS.TSV SOURCE.LUAU "
                     "[--show-unknown] [--strict-unknown]\n");
        return 2;
    }
    bool showUnknown = false, strictUnknown = false;
    for (int i = 3; i < argc; ++i)
    {
        std::string option = argv[i];
        if (option == "--show-unknown")
            showUnknown = true;
        else if (option == "--strict-unknown")
            showUnknown = strictUnknown = true;
        else
        {
            std::fprintf(stderr, "unknown option: %s\n", argv[i]);
            return 2;
        }
    }

    std::vector<wfapi::Contract> contracts;
    std::string error;
    if (!wfapi::loadContracts(argv[1], contracts, error))
    {
        std::fprintf(stderr, "wf_api_check: %s\n", error.c_str());
        return 2;
    }
    wfapi::RegistryStats registryStats;
    if (!wfapi::validateEvidence(argv[1], contracts, registryStats, error))
    {
        std::fprintf(stderr, "wf_api_check: %s\n", error.c_str());
        return 2;
    }
    std::vector<wfapi::CatalogEntry> catalogEntries;
    if (!wfapi::validateSelectionCatalog(argv[1], catalogEntries,
                                         registryStats, error))
    {
        std::fprintf(stderr, "wf_api_check: %s\n", error.c_str());
        return 2;
    }
    std::string source;
    if (!wfapi::readFile(argv[2], source))
    {
        std::fprintf(stderr, "wf_api_check: cannot read source: %s\n", argv[2]);
        return 2;
    }

    std::map<std::string, std::vector<const wfapi::Contract *>> methods;
    std::map<std::string, std::vector<const wfapi::Contract *>> globals;
    std::map<std::string, const wfapi::CatalogEntry *> catalogCalls;
    for (const wfapi::Contract &c : contracts)
    {
        if (c.kind == "method")
            methods[c.name].push_back(&c);
        else if (c.kind == "global_function")
        {
            std::string key = c.owner == "_GLOBAL" ? c.name : c.owner + "." + c.name;
            globals[key].push_back(&c);
        }
    }
    for (const wfapi::CatalogEntry &entry : catalogEntries)
    {
        std::string callName = entry.name;
        if (entry.kind == "global_function" && entry.owner != "_GLOBAL")
            callName = entry.owner + "." + entry.name;
        catalogCalls[entry.kind + "|" + callName] = &entry;
    }

    std::vector<wfapi::Call> calls = wfapi::findCalls(source, contracts);
    std::printf("REGISTRY contracts=%zu evidence_ids=%zu negative_contracts=%zu "
                "core_apis=%zu high_confidence_apis=%zu catalog_deep_contracts=%zu\n",
                contracts.size(), registryStats.evidenceIds,
                registryStats.negativeContracts, registryStats.coreApis,
                registryStats.highConfidenceApis, registryStats.catalogDeepContracts);
    int verified = 0, catalogMatched = 0, catalogHigh = 0;
    int violations = 0, unknown = 0;
    std::set<std::string> unknownNames;
    for (const wfapi::Call &call : calls)
    {
        auto &index = call.kind == "method" ? methods : globals;
        auto found = index.find(call.name);
        if (found == index.end())
        {
            const auto catalogFound = catalogCalls.find(call.kind + "|" + call.name);
            if (catalogFound == catalogCalls.end())
            {
                ++unknown;
                unknownNames.insert(call.kind + ":" + call.name);
                continue;
            }
            const wfapi::CatalogEntry &entry = *catalogFound->second;
            if (!wfapi::catalogAllowsArgs(entry, call.args))
            {
                ++violations;
                std::printf("VIOLATION line=%d call=%s args=%d catalog_expected=%s "
                            "evidence_grade=%s\n",
                            call.line, call.name.c_str(), call.args,
                            entry.visibleArgs.c_str(), entry.evidenceGrade.c_str());
                continue;
            }
            ++catalogMatched;
            const bool high = wfapi::catalogHighConfidence(entry);
            catalogHigh += high ? 1 : 0;
            std::printf("CATALOG_%s line=%d call=%s args=%d owner_hint=%s "
                        "observed_args=%s evidence_grade=%s\n",
                        high ? "VERIFIED" : "KNOWN_CORE", call.line,
                        call.name.c_str(), call.args, entry.owner.c_str(),
                        entry.visibleArgs.c_str(), entry.evidenceGrade.c_str());
            continue;
        }

        const wfapi::Contract *matched = nullptr;
        for (const wfapi::Contract *candidate : found->second)
        {
            bool argsOk = candidate->minArgs < 0 || call.args < 0 ||
                          (call.args >= candidate->minArgs && call.args <= candidate->maxArgs);
            bool callbackOk = candidate->callbackArity < 0 || call.callbackArity < 0 ||
                              candidate->callbackArity == call.callbackArity;
            if (argsOk && callbackOk)
            {
                matched = candidate;
                break;
            }
        }

        if (!matched)
        {
            ++violations;
            std::printf("VIOLATION line=%d call=%s args=%d callback_arity=%d expected=",
                        call.line, call.name.c_str(), call.args, call.callbackArity);
            for (size_t i = 0; i < found->second.size(); ++i)
            {
                const wfapi::Contract &c = *found->second[i];
                if (i)
                    std::printf(" OR ");
                std::printf("%s(%d..%d)", wfapi::displayName(c).c_str(),
                            c.minArgs, c.maxArgs);
                if (c.callbackArity >= 0)
                    std::printf(" callback/%d", c.callbackArity);
            }
            std::printf("\n");
            continue;
        }

        ++verified;
        std::printf("VERIFIED line=%d call=%s args=%d contract=%s confidence=%s",
                    call.line, call.name.c_str(), call.args,
                    wfapi::displayName(*matched).c_str(), matched->confidence.c_str());
        if (matched->callbackArity >= 0)
            std::printf(" callback=%s", matched->callbackParameters.c_str());
        std::printf("\n");
    }

    if (showUnknown)
        for (const std::string &name : unknownNames)
            std::printf("UNVERIFIED %s\n", name.c_str());

    std::printf("SUMMARY contract_verified=%d catalog_matched=%d "
                "catalog_high_confidence=%d violations=%d unverified_calls=%d "
                "unverified_unique=%zu strict_unknown=%s\n",
                verified, catalogMatched, catalogHigh, violations, unknown, unknownNames.size(),
                strictUnknown ? "yes" : "no");
    if (violations || (strictUnknown && unknown))
        return 1;
    return 0;
}
