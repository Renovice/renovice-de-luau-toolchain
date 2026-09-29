// semantic_ir/readable_naming.h -- evidence-backed identifier view for Semantic IR.
//
// This layer never rewrites rendered text and never changes the verified Model.
// It proposes names for value webs, records why each proposal was selected, and
// lets source_renderer apply those names at its single identifier boundary.
#pragma once
#include "source_renderer.h"
#include <cctype>
#include <fstream>
#include <map>
#include <set>
#include <sstream>

namespace sir::readable {

enum class Confidence {
    Structural = 0,
    CorpusCatalog = 1,
    ApiContract = 2,
    ExactExport = 3,
};

inline const char* confidence_name(Confidence value) {
    switch (value) {
        case Confidence::Structural: return "STRUCTURAL";
        case Confidence::CorpusCatalog: return "CORPUS_CATALOG";
        case Confidence::ApiContract: return "API_CONTRACT";
        case Confidence::ExactExport: return "EXACT_EXPORT";
    }
    return "UNKNOWN";
}

struct Alias {
    int prototype = -1;
    int web = -1;
    std::string canonical;
    std::string readable;
    Confidence confidence = Confidence::Structural;
    std::string evidence;
};

struct TypeFact {
    int prototype = -1;
    int web = -1;
    std::string canonical;
    std::string type;
    Confidence confidence = Confidence::Structural;
    std::string evidence;
};

struct ApiDescriptor {
    std::string id;
    std::string kind;
    std::string owner;
    std::string name;
    std::string min_args;
    std::string max_args;
    std::set<int> observed_args;
    bool observed_open_args = false;
    std::string parameters;
    std::string returns;
    std::string confidence;
    std::string status;
    std::string evidence;
    std::string source_kinds;
};

struct Plan {
    source::Naming naming;
    std::vector<Alias> aliases;
    std::vector<TypeFact> types;
    std::vector<ApiDescriptor> api_descriptors;
    std::vector<std::string> diagnostics;
    bool semantic_sdk_requested = false;
    bool semantic_sdk_loaded = false;
};

struct ApiHint {
    std::string owner;
    std::string result;
    std::vector<std::string> parameters;
    std::vector<std::string> parameter_types;
    Confidence confidence = Confidence::CorpusCatalog;
    std::string evidence;
};

struct ApiHints {
    std::map<std::string, std::vector<ApiHint>> methods;
    std::map<std::string, std::vector<ApiHint>> globals;
    std::map<std::string, std::vector<ApiHint>> fields;
};

inline std::string trim(std::string value) {
    while (!value.empty() && std::isspace((unsigned char)value.front()))
        value.erase(value.begin());
    while (!value.empty() && std::isspace((unsigned char)value.back()))
        value.pop_back();
    return value;
}

inline std::vector<std::string> split(const std::string& value, char delimiter) {
    std::vector<std::string> out;
    std::string item;
    std::istringstream input(value);
    while (std::getline(input, item, delimiter)) out.push_back(item);
    if (!value.empty() && value.back() == delimiter) out.emplace_back();
    return out;
}

inline std::map<std::string, size_t> header_map(const std::string& line) {
    std::map<std::string, size_t> out;
    const std::vector<std::string> columns = split(line, '\t');
    for (size_t index = 0; index < columns.size(); ++index)
        out[columns[index]] = index;
    return out;
}

inline std::string column(const std::vector<std::string>& row,
                          const std::map<std::string, size_t>& header,
                          const std::string& name) {
    auto found = header.find(name);
    return found == header.end() || found->second >= row.size()
        ? std::string() : row[found->second];
}

inline std::vector<std::string> parameter_names(const std::string& value) {
    std::vector<std::string> out;
    if (value.empty() || value == "-") return out;
    for (std::string parameter : split(value, ';')) {
        parameter = trim(parameter);
        const size_t colon = parameter.find(':');
        std::string name = trim(parameter.substr(0, colon));
        if (!name.empty() && name != "-") out.push_back(name);
    }
    return out;
}

inline std::vector<std::string> parameter_types(const std::string& value) {
    std::vector<std::string> out;
    if (value.empty() || value == "-") return out;
    for (std::string parameter : split(value, ';')) {
        parameter = trim(parameter);
        const size_t colon = parameter.find(':');
        std::string type = colon == std::string::npos
            ? std::string("unknown") : trim(parameter.substr(colon + 1));
        out.push_back(type.empty() ? "unknown" : type);
    }
    return out;
}

inline int strict_decimal(const std::string& value) {
    if (value.empty()) return -1;
    int result = 0;
    for (const char character : value) {
        if (character < '0' || character > '9') return -1;
        if (result > (std::numeric_limits<int>::max() - (character - '0')) / 10)
            return -1;
        result = result * 10 + character - '0';
    }
    return result;
}

inline bool parse_observed_arguments(const std::string& value,
                                     std::set<int>& arguments) {
    arguments.clear();
    if (value.empty()) return true;
    for (const std::string& part : split(value, ';')) {
        const int parsed = strict_decimal(part);
        if (parsed < 0 || !arguments.insert(parsed).second) return false;
    }
    return true;
}

inline bool load_contracts(const std::string& path, ApiHints& hints,
                           std::vector<std::string>& diagnostics) {
    std::ifstream input(path);
    if (!input) {
        diagnostics.push_back("READABLE_API_CONTRACTS_UNAVAILABLE:" + path);
        return false;
    }
    std::string line;
    if (!std::getline(input, line)) {
        diagnostics.push_back("READABLE_API_CONTRACTS_EMPTY:" + path);
        return false;
    }
    const auto header = header_map(line);
    while (std::getline(input, line)) {
        if (line.empty()) continue;
        const auto row = split(line, '\t');
        const std::string kind = column(row, header, "kind");
        const std::string name = column(row, header, "name");
        if (name.empty()) continue;
        ApiHint hint;
        hint.owner = column(row, header, "owner");
        hint.result = column(row, header, "returns");
        hint.parameters = parameter_names(column(row, header, "parameters"));
        hint.parameter_types = parameter_types(column(row, header, "parameters"));
        hint.confidence = Confidence::ApiContract;
        hint.evidence = "contracts.tsv:" + column(row, header, "evidence");
        if (kind == "field") {
            if (!hint.parameter_types.empty()) hint.result = hint.parameter_types[0];
            hints.fields[name].push_back(std::move(hint));
        } else if (kind == "method") hints.methods[name].push_back(std::move(hint));
        else if (kind == "global_function")
            hints.globals[name].push_back(std::move(hint));
    }
    return true;
}

inline bool load_semantic_sdk(const std::string& path, ApiHints& hints,
                              std::vector<std::string>& diagnostics,
                              std::vector<ApiDescriptor>* descriptors = nullptr) {
    std::ifstream input(path);
    if (!input) {
        diagnostics.push_back("READABLE_SEMANTIC_SDK_UNAVAILABLE:" + path);
        return false;
    }
    std::string line;
    if (!std::getline(input, line)) {
        diagnostics.push_back("READABLE_SEMANTIC_SDK_EMPTY:" + path);
        return false;
    }
    const std::vector<std::string> header_columns = split(line, '\t');
    const auto header = header_map(line);
    if (header.size() != header_columns.size()) {
        diagnostics.push_back("READABLE_SEMANTIC_SDK_DUPLICATE_COLUMN:" + path);
        return false;
    }
    static const std::set<std::string> required{
        "schema_version", "generator", "id", "kind", "owner", "name",
        "min_args", "max_args", "observed_args", "observed_open_args",
        "parameters", "returns",
        "confidence", "status", "evidence", "source_kinds"
    };
    for (const std::string& name : required) {
        if (header.count(name)) continue;
        diagnostics.push_back("READABLE_SEMANTIC_SDK_MISSING_COLUMN:" + name);
        return false;
    }
    size_t rows = 0;
    std::set<std::string> ids;
    while (std::getline(input, line)) {
        if (line.empty()) continue;
        const auto row = split(line, '\t');
        if (row.size() != header_columns.size()) {
            diagnostics.push_back("READABLE_SEMANTIC_SDK_MALFORMED_ROW:"
                + std::to_string(rows + 1));
            return false;
        }
        if (column(row, header, "schema_version") != "1") {
            diagnostics.push_back("READABLE_SEMANTIC_SDK_SCHEMA_UNSUPPORTED:"
                + column(row, header, "schema_version"));
            return false;
        }
        if (column(row, header, "generator") != "RENOVICE_SEMANTIC_SDK_V1") {
            diagnostics.push_back("READABLE_SEMANTIC_SDK_GENERATOR_MISMATCH:"
                + column(row, header, "generator"));
            return false;
        }
        const std::string id = column(row, header, "id");
        const std::string kind = column(row, header, "kind");
        const std::string owner = column(row, header, "owner");
        const std::string name = column(row, header, "name");
        if (id.empty() || owner.empty() || name.empty()
            || (kind != "field" && kind != "method"
                && kind != "global_function")) {
            diagnostics.push_back("READABLE_SEMANTIC_SDK_INVALID_IDENTITY:"
                + std::to_string(rows + 1));
            return false;
        }
        if (!ids.insert(id).second) {
            diagnostics.push_back("READABLE_SEMANTIC_SDK_DUPLICATE_ID:" + id);
            return false;
        }
        std::set<int> observed_arguments;
        if (!parse_observed_arguments(column(row, header, "observed_args"),
                                      observed_arguments)) {
            diagnostics.push_back("READABLE_SEMANTIC_SDK_INVALID_OBSERVED_ARGS:"
                + id);
            return false;
        }
        const std::string observed_open = column(row, header,
            "observed_open_args");
        if (observed_open != "true" && observed_open != "false") {
            diagnostics.push_back("READABLE_SEMANTIC_SDK_INVALID_OBSERVED_OPEN_ARGS:"
                + id);
            return false;
        }
        ApiHint hint;
        hint.owner = owner;
        hint.result = column(row, header, "returns");
        hint.parameters = parameter_names(column(row, header, "parameters"));
        hint.parameter_types = parameter_types(column(row, header, "parameters"));
        const std::string sources = column(row, header, "source_kinds");
        hint.confidence = sources.find("DEEP_CONTRACT") != std::string::npos
            ? Confidence::ApiContract : Confidence::CorpusCatalog;
        hint.evidence = "semantic-sdk:" + id
            + "; confidence=" + column(row, header, "confidence")
            + "; status=" + column(row, header, "status")
            + "; evidence=" + column(row, header, "evidence");
        if (descriptors)
            descriptors->push_back(ApiDescriptor{
                id,
                kind,
                owner,
                name,
                column(row, header, "min_args"),
                column(row, header, "max_args"),
                std::move(observed_arguments),
                observed_open == "true",
                column(row, header, "parameters"),
                column(row, header, "returns"),
                column(row, header, "confidence"),
                column(row, header, "status"),
                column(row, header, "evidence"),
                sources,
            });
        if (kind == "field") {
            if (!hint.parameter_types.empty()) hint.result = hint.parameter_types[0];
            hints.fields[name].push_back(std::move(hint));
        } else if (kind == "method") hints.methods[name].push_back(std::move(hint));
        else
            hints.globals[name].push_back(std::move(hint));
        ++rows;
    }
    if (rows == 0) {
        diagnostics.push_back("READABLE_SEMANTIC_SDK_NO_SYMBOLS:" + path);
        return false;
    }
    return true;
}

inline bool load_catalog(const std::string& path, ApiHints& hints,
                         std::vector<std::string>& diagnostics) {
    std::ifstream input(path);
    if (!input) {
        diagnostics.push_back("READABLE_API_CATALOG_UNAVAILABLE:" + path);
        return false;
    }
    std::string line;
    if (!std::getline(input, line)) {
        diagnostics.push_back("READABLE_API_CATALOG_EMPTY:" + path);
        return false;
    }
    const auto header = header_map(line);
    while (std::getline(input, line)) {
        if (line.empty()) continue;
        const auto row = split(line, '\t');
        const std::string kind = column(row, header, "kind");
        const std::string name = column(row, header, "name");
        if (name.empty()) continue;
        ApiHint hint;
        hint.owner = column(row, header, "owner_hint");
        hint.result = column(row, header, "return_family_hint");
        hint.confidence = Confidence::CorpusCatalog;
        hint.evidence = "selected_catalog.tsv:" +
            column(row, header, "evidence_grade");
        if (kind == "method") hints.methods[name].push_back(std::move(hint));
        else if (kind == "global_function")
            hints.globals[name].push_back(std::move(hint));
    }
    return true;
}

inline bool lua_keyword(const std::string& value) {
    static const std::set<std::string> words{
        "and", "break", "continue", "do", "else", "elseif", "end", "export",
        "false", "for", "function", "if", "in", "local", "nil", "not", "or",
        "repeat", "return", "then", "true", "type", "until", "while"
    };
    return words.count(value) != 0;
}

inline std::string words_to_identifier(const std::string& input) {
    std::string out;
    bool upper = false;
    for (char raw : input) {
        const unsigned char ch = (unsigned char)raw;
        if (std::isalnum(ch) || raw == '_') {
            char value = raw;
            if (out.empty()) value = (char)std::tolower(ch);
            else if (upper) value = (char)std::toupper(ch);
            out.push_back(value);
            upper = false;
        } else upper = !out.empty();
    }
    while (!out.empty() && out.front() == '_') out.erase(out.begin());
    if (out.empty()) return out;
    if (std::isdigit((unsigned char)out.front())) out = "value" + out;
    if (lua_keyword(out)) out += "Value";
    return out;
}

inline std::string type_identifier(std::string value) {
    const size_t pipe = value.find('|');
    if (pipe != std::string::npos) value.resize(pipe);
    const size_t generic = value.find('<');
    if (generic != std::string::npos) value.resize(generic);
    value = trim(value);
    if (value.size() > 5 && value.compare(value.size() - 5, 5, "OrNil") == 0)
        value.resize(value.size() - 5);
    if (value.empty() || value == "-" || value == "nil" || value == "ignored"
        || value == "any" || value == "unknown" || value == "MULTI"
        || value == "boolean" || value == "number" || value == "string"
        || value == "value" || value == "object") return {};
    return words_to_identifier(value);
}

inline std::string semantic_type(std::string value) {
    value = trim(value);
    if (value.empty() || value == "-" || value == "nil" || value == "ignored"
        || value == "MULTI" || value == "any" || value == "unknown"
        || value == "value" || value == "object") return {};
    return value;
}

// Compare only type alternatives that are explicit in the SDK spelling.  This
// is deliberately not an engine inheritance table: `AvatarOrEntity` says that
// Avatar is an admitted alternative, while unrelated names remain unrelated.
// Nullable/reference suffixes retain their full spelling in the sidecar but do
// not prevent a receiver from matching the named object family.
inline std::set<std::string> semantic_type_atoms(std::string value) {
    value = trim(value);
    for (const std::string& suffix : {
             std::string("_ref_or_null_unresolved"),
             std::string("_ref_or_null")}) {
        if (value.size() > suffix.size()
            && value.compare(value.size() - suffix.size(), suffix.size(), suffix) == 0) {
            value.resize(value.size() - suffix.size());
            break;
        }
    }
    std::set<std::string> atoms;
    std::size_t begin = 0;
    for (std::size_t index = 1; index + 2 < value.size(); ++index) {
        if (value[index] != 'O' || value[index + 1] != 'r'
            || !std::islower(static_cast<unsigned char>(value[index - 1]))
            || !std::isupper(static_cast<unsigned char>(value[index + 2])))
            continue;
        atoms.insert(value.substr(begin, index - begin));
        begin = index + 2;
        index = begin;
    }
    if (begin < value.size()) atoms.insert(value.substr(begin));
    atoms.erase("Nil");
    atoms.erase("");
    return atoms;
}

inline bool semantic_type_refines(const std::string& specific,
                                  const std::string& admitted) {
    const std::set<std::string> left = semantic_type_atoms(specific);
    const std::set<std::string> right = semantic_type_atoms(admitted);
    if (left.empty() || right.empty()) return specific == admitted;
    return std::includes(right.begin(), right.end(), left.begin(), left.end());
}

inline std::string result_from_call_name(std::string name) {
    if (name.rfind("Get", 0) == 0 && name.size() > 3) name.erase(0, 3);
    else if (name.rfind("Create", 0) == 0 && name.size() > 6) name.erase(0, 6);
    else if (name.rfind("Find", 0) == 0 && name.size() > 4) name.erase(0, 4);
    else if (name.rfind("Is", 0) == 0 && name.size() > 2)
        return "is" + name.substr(2);
    else if (name.rfind("Has", 0) == 0 && name.size() > 3)
        return "has" + name.substr(3);
    std::string result = words_to_identifier(name);
    static const std::set<std::string> action_prefixes{
        "set", "add", "remove", "destroy", "notify", "play", "stop",
        "deactivate", "activate", "update"
    };
    if (action_prefixes.count(result)) return {};
    return result;
}

inline std::string root_identifier(const std::string& path) {
    size_t end = path.find_first_of(".[");
    return path.substr(0, end);
}

inline std::string tsv_escape(std::string value) {
    for (char& ch : value)
        if (ch == '\t' || ch == '\n' || ch == '\r') ch = ' ';
    return value;
}

inline std::string to_tsv(const Plan& plan) {
    std::ostringstream out;
    out << "prototype\tweb\tcanonical\treadable\tconfidence\tevidence"
           "\tsemantic_type\ttype_confidence\ttype_evidence\n";
    std::map<std::pair<int, int>, const Alias*> aliases;
    std::map<std::pair<int, int>, const TypeFact*> types;
    std::set<std::pair<int, int>> identities;
    for (const Alias& alias : plan.aliases) {
        aliases[{alias.prototype, alias.web}] = &alias;
        identities.insert({alias.prototype, alias.web});
    }
    for (const TypeFact& type : plan.types) {
        types[{type.prototype, type.web}] = &type;
        identities.insert({type.prototype, type.web});
    }
    for (const auto& identity : identities) {
        const Alias* alias = aliases.count(identity) ? aliases[identity] : nullptr;
        const TypeFact* type = types.count(identity) ? types[identity] : nullptr;
        out << identity.first << '\t' << identity.second << '\t'
            << tsv_escape(alias ? alias->canonical : type->canonical) << '\t'
            << tsv_escape(alias ? alias->readable : std::string()) << '\t'
            << (alias ? confidence_name(alias->confidence) : "") << '\t'
            << tsv_escape(alias ? alias->evidence : std::string()) << '\t'
            << tsv_escape(type ? type->type : std::string()) << '\t'
            << (type ? confidence_name(type->confidence) : "") << '\t'
            << tsv_escape(type ? type->evidence : std::string()) << '\n';
    }
    return out.str();
}

namespace detail {

struct Candidate {
    std::string name;
    int score = 0;
    Confidence confidence = Confidence::Structural;
    std::string evidence;
};

struct TypeCandidate {
    std::string type;
    int score = 0;
    Confidence confidence = Confidence::Structural;
    std::string evidence;
};

inline int web_for(const std::set<ValueOriginContract>& origins,
                   const std::map<ValueOriginContract, int>& webs) {
    if (origins.empty()) return -1;
    int result = -1;
    for (const ValueOriginContract& origin : origins) {
        auto found = webs.find(origin);
        if (found == webs.end()) return -1;
        if (result >= 0 && result != found->second) return -1;
        result = found->second;
    }
    return result;
}

inline bool unresolved_name(const std::string& name) {
    return name.rfind("Name__", 0) == 0 || name.rfind("G_", 0) == 0;
}

inline void propose(std::map<int, std::vector<Candidate>>& candidates, int web,
                    std::string name, int score, Confidence confidence,
                    std::string evidence) {
    name = words_to_identifier(name);
    if (web < 0 || name.empty() || unresolved_name(name)) return;
    candidates[web].push_back(Candidate{
        std::move(name), score, confidence, std::move(evidence)});
}

inline void propose_type(std::map<int, std::vector<TypeCandidate>>& candidates,
                         int web, std::string type, int score,
                         Confidence confidence, std::string evidence) {
    type = semantic_type(std::move(type));
    if (web < 0 || type.empty()) return;
    candidates[web].push_back(TypeCandidate{
        std::move(type), score, confidence, std::move(evidence)});
}

inline const ApiHint* unique_hint(const std::map<std::string, std::vector<ApiHint>>& source,
                                  const std::string& name,
                                  bool require_owner,
                                  bool require_result) {
    auto found = source.find(name);
    if (found == source.end() || found->second.empty()) return nullptr;
    const ApiHint* best = nullptr;
    std::string owner, result;
    for (const ApiHint& hint : found->second) {
        if (require_owner && hint.owner.empty()) continue;
        if (require_result && semantic_type(hint.result).empty()) continue;
        if (!best || (int)hint.confidence > (int)best->confidence) {
            best = &hint; owner = hint.owner; result = hint.result;
        } else if ((int)hint.confidence == (int)best->confidence) {
            if (require_owner && hint.owner != owner) return nullptr;
            if (require_result && hint.result != result) return nullptr;
        }
    }
    return best;
}

inline std::string call_name(const CallContract& call,
                             const std::map<ValueOriginContract,
                                            const ExpressionDefinitionContract*>& expressions,
                             const Model& model,
                             const ExpressionDefinitionContract** receiver = nullptr) {
    if (receiver) *receiver = nullptr;
    if (call.method_call) {
        std::string name;
        for (const ExpressionDefinitionContract& expression
             : model.authoritative_expressions) {
            if (expression.identity.instruction != call.namecall_instruction) continue;
            if (expression.kind == ExpressionKind::MethodFunction)
                name = expression.name;
            else if (receiver && expression.kind == ExpressionKind::MethodReceiver)
                *receiver = &expression;
        }
        return name;
    }
    if (call.callee_origins.size() != 1) return {};
    auto found = expressions.find(*call.callee_origins.begin());
    if (found == expressions.end()) return {};
    const ExpressionDefinitionContract& expression = *found->second;
    if (expression.kind == ExpressionKind::GlobalRead
        || expression.kind == ExpressionKind::ImportRead
        || expression.kind == ExpressionKind::FieldRead)
        return expression.name;
    return {};
}

} // namespace detail

inline Plan build_plan(const std::map<int, Model>& models,
                       const std::string& contracts_path = "api/warframe/contracts.tsv",
                       const std::string& catalog_path = "api/warframe/selected_catalog.tsv",
                       const std::string& semantic_sdk_path = std::string()) {
    Plan plan;
    ApiHints api;
    plan.semantic_sdk_requested = !semantic_sdk_path.empty();
    if (plan.semantic_sdk_requested) {
        plan.semantic_sdk_loaded = load_semantic_sdk(
            semantic_sdk_path, api, plan.diagnostics, &plan.api_descriptors);
    } else {
        load_catalog(catalog_path, api, plan.diagnostics);
        load_contracts(contracts_path, api, plan.diagnostics);
    }

    std::set<std::string> reserved{
        "_G", "error", "ipairs", "pairs", "select", "table"
    };
    for (const auto& owner : models) {
        for (const StoreOperationContract& store
             : owner.second.authoritative_store_operations)
            if (store.kind == StoreOperationKind::Global)
                reserved.insert(root_identifier(store.name));
        for (const ExpressionDefinitionContract& expression
             : owner.second.authoritative_expressions)
            if (expression.kind == ExpressionKind::GlobalRead
                || expression.kind == ExpressionKind::ImportRead)
                reserved.insert(root_identifier(expression.name));
    }

    for (const auto& owner : models) {
        const Model& model = owner.second;
        std::map<ValueOriginContract, int> webs;
        std::map<ValueOriginContract, const ExpressionDefinitionContract*> expressions;
        std::set<int> parameter_webs;
        std::map<int, int> parameter_registers;
        for (const ValueWebContract& web : model.authoritative_value_webs)
            for (const ValueOriginContract& origin : web.members)
                webs[origin] = web.id;
        for (const ExpressionDefinitionContract& expression
             : model.authoritative_expressions)
            expressions[expression.identity] = &expression;
        for (const LocalValueContract& local : model.authoritative_local_values) {
            if (!local.parameter) continue;
            auto found = webs.find(local.identity);
            if (found == webs.end()) continue;
            parameter_webs.insert(found->second);
            parameter_registers[found->second] = local.identity.reg;
        }

        std::map<int, std::vector<detail::Candidate>> candidates;
        std::map<int, std::vector<detail::TypeCandidate>> type_candidates;

        // Exact engine-global spelling is enough to replace mechanical webs
        // with a distinct, non-shadowing local role.  Do not reuse the global
        // identifier itself: `local gRegion; gRegion = gRegion` would change
        // semantics.  Unknown globals intentionally remain canonical.
        for (const ExpressionDefinitionContract& expression
             : model.authoritative_expressions) {
            if (expression.kind != ExpressionKind::GlobalRead
                && expression.kind != ExpressionKind::ImportRead) continue;
            const int web = detail::web_for({expression.identity}, webs);
            std::string role;
            if (expression.name == "gRegion") role = "region";
            else if (expression.name == "mOwner") role = "ownerReference";
            else if (expression.name == "ZERO_ROTATION") role = "zeroRotation";
            else if (expression.name == "ZERO_VECTOR") role = "zeroVector";
            else if (expression.name == "_T") role = "sharedState";
            if (!role.empty())
                detail::propose(candidates, web, role, 88,
                    Confidence::Structural,
                    "exact engine global " + expression.name);
            if (expression.name == "gRegion")
                detail::propose_type(type_candidates, web, "Region", 95,
                    Confidence::ExactExport, "exact engine global gRegion");
        }

        // An exported closure's public slot is exact evidence of its role.  A
        // distinct `Function` suffix avoids shadowing that global when the
        // renderer later emits `ExportName = localFunction`.
        for (const StoreOperationContract& store
             : model.authoritative_store_operations) {
            if (store.kind != StoreOperationKind::Global
                || detail::unresolved_name(store.name)) continue;
            const int web = detail::web_for(store.value_origins, webs);
            bool closure = false;
            for (const ValueOriginContract& origin : store.value_origins) {
                auto value = expressions.find(origin);
                if (value != expressions.end()
                    && value->second->kind == ExpressionKind::ClosureValue)
                    closure = true;
                for (const ClosureContract& item : model.authoritative_closures)
                    if (item.instruction == origin.instruction
                        && item.destination_register == origin.reg)
                        closure = true;
            }
            if (closure)
                detail::propose(candidates, web, store.name + " Function", 100,
                    Confidence::ExactExport, "global store " + store.name);
        }

        for (const CallContract& call : model.authoritative_calls) {
            const ExpressionDefinitionContract* receiver = nullptr;
            const std::string name = detail::call_name(
                call, expressions, model, &receiver);
            if (name.empty() || detail::unresolved_name(name)) continue;
            const auto& hint_table = call.method_call ? api.methods : api.globals;

            // Receiver type is a catalog/contract claim, never an exact fact.
            if (call.method_call && receiver && receiver->operands.size() == 1) {
                const int web = detail::web_for(receiver->operands[0], webs);
                const ApiHint* hint = detail::unique_hint(hint_table, name, true, false);
                if (hint) {
                    const std::string receiver_name = type_identifier(hint->owner);
                    detail::propose(candidates, web, receiver_name,
                        hint->confidence == Confidence::ApiContract ? 86 : 72,
                        hint->confidence, hint->evidence + "; receiver of " + name);
                    detail::propose_type(type_candidates, web, hint->owner,
                        hint->confidence == Confidence::ApiContract ? 96 : 82,
                        hint->confidence, hint->evidence + "; receiver of " + name);
                }
                if (!hint && name == "GetAvatarOwner")
                    detail::propose(candidates, web, "source Ability", 64,
                        Confidence::Structural,
                        "receiver role implied by GetAvatarOwner");
            }

            const ApiHint* argument_hint = detail::unique_hint(
                hint_table, name, false, false);
            if (argument_hint && !argument_hint->parameters.empty()) {
                const size_t count = std::min(argument_hint->parameters.size(),
                                              call.fixed_argument_origins.size());
                for (size_t index = 0; index < count; ++index) {
                    const int web = detail::web_for(
                        call.fixed_argument_origins[index], webs);
                    const std::string parameter = argument_hint->parameters[index];
                    const bool generic = parameter == "value" || parameter == "item"
                        || parameter == "object" || parameter == "source"
                        || parameter == "amount" || parameter == "context";
                    detail::propose(candidates, web,
                        parameter, generic ? 50 : 90,
                        Confidence::ApiContract,
                        argument_hint->evidence + "; argument "
                            + std::to_string(index) + " of " + name);
                    if (index < argument_hint->parameter_types.size())
                        detail::propose_type(type_candidates, web,
                            argument_hint->parameter_types[index], 94,
                            Confidence::ApiContract,
                            argument_hint->evidence + "; argument type "
                                + std::to_string(index) + " of " + name);
                }
            }

            std::string result_name;
            Confidence result_confidence = Confidence::Structural;
            std::string result_evidence = "call result of " + name;
            const ApiHint* result_hint = detail::unique_hint(
                hint_table, name, false, true);
            if (result_hint) {
                result_name = type_identifier(result_hint->result);
                result_confidence = result_hint->confidence;
                result_evidence = result_hint->evidence + "; result of " + name;
            }
            if (result_name.empty()) result_name = result_from_call_name(name);
            for (const ExpressionDefinitionContract& expression
                 : model.authoritative_expressions) {
                if (expression.kind != ExpressionKind::CallResult
                    || expression.identity.instruction != call.instruction) continue;
                const int web = detail::web_for({expression.identity}, webs);
                std::string candidate = result_name;
                if (call.result_count > 1)
                    candidate += " " + std::to_string(expression.result_slot + 1);
                detail::propose(candidates, web, candidate,
                    result_hint
                        ? (result_confidence == Confidence::ApiContract ? 84 : 76)
                        : 78,
                    result_confidence, result_evidence);
                if (result_hint)
                    detail::propose_type(type_candidates, web,
                        result_hint->result,
                        result_confidence == Confidence::ApiContract ? 96 : 90,
                        result_confidence, result_evidence);
            }
        }

        // Field reads and tables are useful last-resort labels.  They lose to
        // any API or export evidence and are skipped entirely on ambiguity.
        for (const ExpressionDefinitionContract& expression
             : model.authoritative_expressions) {
            const int web = detail::web_for({expression.identity}, webs);
            if (expression.kind == ExpressionKind::FieldRead
                && !detail::unresolved_name(expression.name)) {
                detail::propose(candidates, web, expression.name + " Value", 45,
                    Confidence::Structural, "field read " + expression.name);
                const ApiHint* hint = detail::unique_hint(
                    api.fields, expression.name, true, true);
                if (hint) {
                    detail::propose_type(type_candidates, web, hint->result, 96,
                        hint->confidence, hint->evidence + "; field read "
                            + expression.name);
                    if (expression.operands.size() == 1) {
                        const int receiver_web = detail::web_for(
                            expression.operands[0], webs);
                        detail::propose_type(type_candidates, receiver_web,
                            hint->owner, 94, hint->confidence,
                            hint->evidence + "; owner of field "
                                + expression.name);
                    }
                }
            } else if (expression.kind == ExpressionKind::NewTable)
                detail::propose(candidates, web, "table Value", 35,
                    Confidence::Structural, "verified NEWTABLE value");
        }

        // SETFIELD operations carry both the table and value origin sets, so
        // confirmed field contracts can type both sides without guessing an
        // object layout. Unknown or overloaded fields remain untyped.
        for (const TableOperationContract& operation
             : model.authoritative_table_operations) {
            if (operation.kind != TableOperationKind::SetField
                || detail::unresolved_name(operation.field_name)) continue;
            const ApiHint* hint = detail::unique_hint(
                api.fields, operation.field_name, true, true);
            if (!hint) continue;
            detail::propose_type(type_candidates,
                detail::web_for(operation.table_origins, webs), hint->owner, 94,
                hint->confidence, hint->evidence + "; owner of field write "
                    + operation.field_name);
            detail::propose_type(type_candidates,
                detail::web_for(operation.value_origins, webs), hint->result, 96,
                hint->confidence, hint->evidence + "; value of field write "
                    + operation.field_name);
        }

        std::set<std::string> used = reserved;
        for (const ValueWebContract& web : model.authoritative_value_webs) {
            auto found = candidates.find(web.id);
            if (found == candidates.end()) continue;
            int best_score = -1;
            std::set<std::string> best_names;
            const detail::Candidate* best = nullptr;
            for (const detail::Candidate& candidate : found->second) {
                if (candidate.score > best_score) {
                    best_score = candidate.score;
                    best_names = {candidate.name};
                    best = &candidate;
                } else if (candidate.score == best_score) {
                    best_names.insert(candidate.name);
                    if (best && (int)candidate.confidence > (int)best->confidence)
                        best = &candidate;
                }
            }
            if (!best || best_names.size() != 1) {
                plan.diagnostics.push_back("READABLE_ALIAS_AMBIGUOUS:proto="
                    + std::to_string(owner.first) + ":web="
                    + std::to_string(web.id));
                continue;
            }
            std::string readable = best->name;
            if (used.count(readable)) {
                const std::string base = readable;
                int suffix = 2;
                do { readable = base + std::to_string(suffix++); }
                while (used.count(readable));
            }
            used.insert(readable);
            plan.naming.web_names[owner.first][web.id] = readable;
            std::string canonical;
            auto parameter = parameter_registers.find(web.id);
            if (parameter != parameter_registers.end())
                canonical = "p" + std::to_string(owner.first) + "_"
                    + std::to_string(parameter->second);
            else canonical = "v" + std::to_string(owner.first) + "_"
                    + std::to_string(web.id);
            plan.aliases.push_back(Alias{owner.first, web.id, canonical,
                readable, best->confidence, best->evidence});
        }

        for (const ValueWebContract& web : model.authoritative_value_webs) {
            auto found = type_candidates.find(web.id);
            if (found == type_candidates.end()) continue;
            int best_score = -1;
            std::vector<const detail::TypeCandidate*> best;
            for (const detail::TypeCandidate& candidate : found->second) {
                if (candidate.score > best_score) {
                    best_score = candidate.score;
                    best = {&candidate};
                } else if (candidate.score == best_score) {
                    best.push_back(&candidate);
                }
            }
            const detail::TypeCandidate* selected = nullptr;
            for (const detail::TypeCandidate* candidate : best) {
                bool refines_all = true;
                for (const detail::TypeCandidate* other : best)
                    if (!semantic_type_refines(candidate->type, other->type)) {
                        refines_all = false;
                        break;
                    }
                if (!refines_all) continue;
                if (!selected
                    || semantic_type_atoms(candidate->type).size()
                        < semantic_type_atoms(selected->type).size()
                    || (semantic_type_atoms(candidate->type)
                            == semantic_type_atoms(selected->type)
                        && candidate->type.size() < selected->type.size())
                    || (candidate->type == selected->type
                        && static_cast<int>(candidate->confidence)
                            > static_cast<int>(selected->confidence)))
                    selected = candidate;
            }
            if (!selected) {
                plan.diagnostics.push_back("READABLE_TYPE_AMBIGUOUS:proto="
                    + std::to_string(owner.first) + ":web="
                    + std::to_string(web.id));
                continue;
            }
            std::string canonical;
            auto parameter = parameter_registers.find(web.id);
            if (parameter != parameter_registers.end())
                canonical = "p" + std::to_string(owner.first) + "_"
                    + std::to_string(parameter->second);
            else canonical = "v" + std::to_string(owner.first) + "_"
                    + std::to_string(web.id);
            plan.types.push_back(TypeFact{owner.first, web.id, canonical,
                selected->type, selected->confidence, selected->evidence});
        }
    }
    std::sort(plan.aliases.begin(), plan.aliases.end(),
        [](const Alias& left, const Alias& right) {
            if (left.prototype != right.prototype)
                return left.prototype < right.prototype;
            return left.web < right.web;
        });
    std::sort(plan.types.begin(), plan.types.end(),
        [](const TypeFact& left, const TypeFact& right) {
            if (left.prototype != right.prototype)
                return left.prototype < right.prototype;
            return left.web < right.web;
        });
    return plan;
}

struct SourceLocation {
    size_t offset = 0;
    size_t length = 0;
    size_t line = 0;
    size_t column = 0;
};

inline SourceLocation source_location(const std::string& source,
                                      const source::Result::CallSourceSpan& span) {
    SourceLocation out{span.offset, span.length, 1, 1};
    if (span.offset > source.size() || span.length > source.size() - span.offset)
        return SourceLocation{};
    for (size_t index = 0; index < span.offset; ++index) {
        if (source[index] == '\r') {
            if (index + 1 < span.offset && source[index + 1] == '\n') ++index;
            ++out.line; out.column = 1;
        } else if (source[index] == '\n') {
            ++out.line; out.column = 1;
        } else ++out.column;
    }
    return out;
}

inline std::string web_list(const std::vector<int>& values) {
    std::ostringstream out;
    for (size_t index = 0; index < values.size(); ++index) {
        if (index) out << ';';
        out << values[index];
    }
    return out.str();
}

inline std::string callsites_to_tsv(const std::map<int, Model>& models,
                                    const Plan& plan,
                                    const source::Result& fidelity,
                                    const source::Result& readable,
                                    std::string& failure) {
    if (fidelity.call_spans.size() != readable.call_spans.size()) {
        failure = "CALLSITE_SPAN_VIEW_COUNT_DRIFT"; return {};
    }
    for (const auto& span : fidelity.call_spans) {
        const auto found = readable.call_spans.find(span.first);
        if (found == readable.call_spans.end()) {
            failure = "CALLSITE_SPAN_VIEW_IDENTITY_DRIFT"; return {};
        }
        if (found->second.size() != span.second.size()) {
            failure = "CALLSITE_SPAN_VIEW_OCCURRENCE_DRIFT"; return {};
        }
    }

    std::map<std::pair<int, int>, const TypeFact*> types;
    for (const TypeFact& type : plan.types)
        types[{type.prototype, type.web}] = &type;

    std::ostringstream out;
    out << "schema_version\tprototype\tblock\tinstruction\tsource_occurrence\teffect_order\tkind\tname\tname_hash"
           "\tcallee_web\treceiver_web\treceiver_type\treceiver_type_confidence"
           "\treceiver_type_evidence\tdescriptor_join\targument_webs\texplicit_argument_count\topen_arguments"
           "\tresult_webs\tresult_count\topen_results\tdescriptor\tcontract_confidence"
           "\tcontract_status\tevidence\tparameters\treturns\tcontract_match\treadable_offset"
           "\treadable_length\treadable_line\treadable_column\tfidelity_offset\tfidelity_length"
           "\tfidelity_line\tfidelity_column\n";
    for (const auto& span_item : fidelity.call_spans) {
        const int prototype = span_item.first.first;
        const int instruction = span_item.first.second;
        auto model_item = models.find(prototype);
        if (model_item == models.end()) {
            failure = "CALLSITE_MODEL_MISSING"; return {};
        }
        const Model& model = model_item->second;
        const CallContract* call = nullptr;
        for (const CallContract& candidate : model.authoritative_calls)
            if (candidate.instruction == instruction) {
                if (call) { failure = "CALLSITE_CALL_DUPLICATE"; return {}; }
                call = &candidate;
            }
        if (!call) { failure = "CALLSITE_CALL_MISSING"; return {}; }

        std::map<ValueOriginContract, int> webs;
        std::map<ValueOriginContract, const ExpressionDefinitionContract*> expressions;
        for (const ValueWebContract& web : model.authoritative_value_webs)
            for (const ValueOriginContract& origin : web.members) webs[origin] = web.id;
        for (const ExpressionDefinitionContract& expression : model.authoritative_expressions)
            expressions[expression.identity] = &expression;
        const ExpressionDefinitionContract* receiver_expression = nullptr;
        const std::string name = detail::call_name(
            *call, expressions, model, &receiver_expression);
        const std::string kind = call->method_call ? "method"
            : name.empty() ? "dynamic_function" : "global_function";
        const int callee_web = detail::web_for(call->callee_origins, webs);
        int receiver_web = -1;
        if (receiver_expression && receiver_expression->operands.size() == 1)
            receiver_web = detail::web_for(receiver_expression->operands[0], webs);
        std::vector<int> argument_webs;
        for (const auto& origins : call->fixed_argument_origins)
            argument_webs.push_back(detail::web_for(origins, webs));
        std::vector<std::pair<int, int>> result_slots;
        for (const ExpressionDefinitionContract& expression : model.authoritative_expressions)
            if (expression.kind == ExpressionKind::CallResult
                && expression.identity.instruction == call->instruction)
                result_slots.push_back({expression.result_slot,
                    detail::web_for({expression.identity}, webs)});
        std::sort(result_slots.begin(), result_slots.end());
        std::vector<int> result_webs;
        for (const auto& result : result_slots) result_webs.push_back(result.second);

        const TypeFact* receiver_type = nullptr;
        if (receiver_web >= 0) {
            auto receiver_type_item = types.find({prototype, receiver_web});
            if (receiver_type_item != types.end()) receiver_type = receiver_type_item->second;
        }
        std::vector<const ApiDescriptor*> descriptors;
        if (kind == "method" || kind == "global_function")
            for (const ApiDescriptor& descriptor : plan.api_descriptors)
                if (descriptor.kind == kind && descriptor.name == name)
                    descriptors.push_back(&descriptor);
        const std::size_t name_candidate_count = descriptors.size();
        std::string descriptor_join = descriptors.empty() ? "NONE"
            : kind == "global_function" ? "STATIC_NAME"
            : descriptors.size() == 1 ? "UNIQUE_METHOD_NAME" : "AMBIGUOUS";
        if (kind == "method" && receiver_type && !descriptors.empty()) {
            std::vector<const ApiDescriptor*> compatible;
            for (const ApiDescriptor* candidate : descriptors)
                if (semantic_type_refines(receiver_type->type, candidate->owner))
                    compatible.push_back(candidate);
            if (!compatible.empty()) {
                std::size_t narrowest = std::numeric_limits<std::size_t>::max();
                for (const ApiDescriptor* candidate : compatible)
                    narrowest = std::min(narrowest,
                        semantic_type_atoms(candidate->owner).size());
                std::vector<const ApiDescriptor*> narrow;
                for (const ApiDescriptor* candidate : compatible)
                    if (semantic_type_atoms(candidate->owner).size() == narrowest)
                        narrow.push_back(candidate);
                descriptors = std::move(narrow);
                descriptor_join = descriptors.size() == 1
                    ? "RECEIVER_TYPE" : "AMBIGUOUS";
            } else if (descriptors.size() == 1) {
                descriptor_join = "RECEIVER_TYPE_CONFLICT";
            } else {
                descriptors.clear();
                descriptor_join = "RECEIVER_TYPE_CONFLICT";
            }
        }
        if (name_candidate_count == 1 && descriptors.size() == 1
            && descriptor_join == "RECEIVER_TYPE" && receiver_type
            && receiver_type->evidence.find("semantic-sdk:" + descriptors.front()->id)
                != std::string::npos
            && receiver_type->evidence.find("; receiver of " + name)
                != std::string::npos)
            descriptor_join = "UNIQUE_METHOD_NAME";
        const ApiDescriptor* descriptor = descriptors.size() == 1
            ? descriptors.front() : nullptr;
        std::string match = descriptors.empty() ? "UNREGISTERED"
            : descriptors.size() > 1 ? "AMBIGUOUS" : "UNSPECIFIED";
        if (descriptor) {
            if (call->explicit_argument_count < 0) match = "OPEN_ARGUMENTS";
            else {
                const int minimum = strict_decimal(descriptor->min_args);
                const int maximum = strict_decimal(descriptor->max_args);
                const bool deep_contract = descriptor->source_kinds.find(
                    "DEEP_CONTRACT") != std::string::npos;
                if (!deep_contract && !descriptor->observed_args.empty())
                    match = descriptor->observed_args.count(
                        call->explicit_argument_count) ? "MATCH" : "OBSERVED_MISMATCH";
                else if (!deep_contract) match = "UNSPECIFIED";
                else if (minimum < 0 || maximum < minimum) match = "UNSPECIFIED";
                else if (call->explicit_argument_count >= minimum
                         && call->explicit_argument_count <= maximum)
                    match = "MATCH";
                // A descriptor proves the recorded call shape, not that every
                // overload for the same receiver/name has that arity.  The SDK
                // currently has no exhaustive-overload flag, so an out-of-range
                // stock call is evidence of another form rather than a violation
                // of the confirmed observation.
                else match = "OBSERVED_MISMATCH";
            }
        }
        std::string hash;
        if (name.rfind("Name__", 0) == 0 && name.size() == 14)
            hash = "0x" + name.substr(6);
        const auto& fidelity_spans = span_item.second;
        const auto& readable_spans = readable.call_spans.at(span_item.first);
        for (size_t occurrence = 0; occurrence < fidelity_spans.size(); ++occurrence) {
            const SourceLocation fidelity_location = source_location(
                fidelity.source, fidelity_spans[occurrence]);
            const SourceLocation readable_location = source_location(
                readable.source, readable_spans[occurrence]);
            if (!fidelity_location.line || !readable_location.line) {
                failure = "CALLSITE_SOURCE_SPAN_INVALID"; return {};
            }
            out << "2\t" << prototype << '\t' << call->block.value << '\t'
            << instruction << '\t' << occurrence << '\t' << call->effect_order << '\t' << kind << '\t'
            << tsv_escape(name) << '\t' << hash << '\t' << callee_web << '\t'
            << receiver_web << '\t'
            << tsv_escape(receiver_type ? receiver_type->type : std::string()) << '\t'
            << (receiver_type ? confidence_name(receiver_type->confidence) : "") << '\t'
            << tsv_escape(receiver_type ? receiver_type->evidence : std::string()) << '\t'
            << descriptor_join << '\t' << web_list(argument_webs) << '\t'
            << call->explicit_argument_count << '\t'
            << (call->explicit_argument_count < 0 ? "true" : "false") << '\t'
            << web_list(result_webs) << '\t' << call->result_count << '\t'
            << (call->result_count < 0 ? "true" : "false") << '\t'
            << tsv_escape(descriptor ? descriptor->id : std::string()) << '\t'
            << tsv_escape(descriptor ? descriptor->confidence : std::string()) << '\t'
            << tsv_escape(descriptor ? descriptor->status : std::string()) << '\t'
            << tsv_escape(descriptor ? descriptor->evidence : std::string()) << '\t'
            << tsv_escape(descriptor ? descriptor->parameters : std::string()) << '\t'
            << tsv_escape(descriptor ? descriptor->returns : std::string()) << '\t'
            << match << '\t'
            << readable_location.offset << '\t' << readable_location.length << '\t'
            << readable_location.line << '\t' << readable_location.column << '\t'
            << fidelity_location.offset << '\t' << fidelity_location.length << '\t'
            << fidelity_location.line << '\t' << fidelity_location.column << '\n';
        }
    }
    return out.str();
}

struct SelfTestResult {
    int assertions = 0;
    int passed = 0;
    std::vector<std::string> failures;
};

inline SelfTestResult run_selftest() {
    SelfTestResult result;
    auto expect = [&](bool condition, const std::string& name) {
        ++result.assertions;
        if (condition) ++result.passed;
        else result.failures.push_back(name);
    };
    expect(words_to_identifier("Impact Burst") == "impactBurst",
           "READABLE_IDENTIFIER_WORDS");
    expect(words_to_identifier("end") == "endValue",
           "READABLE_IDENTIFIER_KEYWORD");
    expect(type_identifier("WeaponOrNil") == "weapon",
           "READABLE_RESULT_OR_NIL");
    expect(type_identifier("boolean").empty(),
           "READABLE_GENERIC_RESULT_REJECTED");
    expect(result_from_call_name("GetAvatarOwner") == "avatarOwner",
           "READABLE_GETTER_RESULT");
    expect(result_from_call_name("IsMaster") == "isMaster",
           "READABLE_BOOLEAN_RESULT");
    expect(semantic_type("AvatarOrEntity") == "AvatarOrEntity",
           "READABLE_SEMANTIC_TYPE_PRESERVED");
    expect(semantic_type_atoms("AvatarOrEntity")
            == std::set<std::string>({"Avatar", "Entity"}),
           "READABLE_EXPLICIT_TYPE_ALTERNATIVES");
    expect(semantic_type_refines("Avatar_ref_or_null_unresolved", "AvatarOrEntity"),
           "READABLE_NULLABLE_REFERENCE_REFINES_OWNER");
    expect(!semantic_type_refines("UIMovie", "AvatarOrEntity"),
           "READABLE_UNRELATED_RECEIVER_REJECTED");

    Model model;
    model.prototype = PrototypeId(0);
    const ValueOriginContract closure_origin{2, 3, 0};
    ValueWebContract web;
    web.owner = PrototypeId(0); web.id = 5; web.reg = 0;
    web.members = {closure_origin};
    model.authoritative_value_webs.insert(web);
    ExpressionDefinitionContract closure;
    closure.owner = PrototypeId(0); closure.identity = closure_origin;
    closure.kind = ExpressionKind::ClosureValue; closure.closure_target = 1;
    model.authoritative_expressions.insert(closure);
    StoreOperationContract store;
    store.owner = PrototypeId(0); store.instruction = 4;
    store.kind = StoreOperationKind::Global;
    store.value_origins = {closure_origin}; store.name = "ImpactBurst";
    model.authoritative_store_operations.insert(store);
    const Plan plan = build_plan({{0, model}}, "__missing_contracts__",
                                 "__missing_catalog__");
    const std::string* alias = plan.naming.find(0, 5);
    expect(alias && *alias == "impactBurstFunction",
           "READABLE_EXACT_EXPORT_ALIAS");
    expect(plan.aliases.size() == 1
           && plan.aliases[0].confidence == Confidence::ExactExport,
           "READABLE_EXACT_EXPORT_PROVENANCE");
    expect(to_tsv(plan).find("0\t5\tv0_5\timpactBurstFunction\tEXACT_EXPORT")
           != std::string::npos,
           "READABLE_TSV_PROVENANCE");
    return result;
}

} // namespace sir::readable
