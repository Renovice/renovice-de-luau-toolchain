// semantic_ir/statement_selection.h -- fail-closed definition emission planning.
#pragma once
#include "expression_semantics.h"
#include <map>
#include <set>

namespace sir::selection {

struct Analysis {
    bool known = true;
    std::string failure;
    std::set<DefinitionEmissionContract> definitions;
};

inline bool literal_kind(ExpressionKind kind) {
    return kind == ExpressionKind::Number || kind == ExpressionKind::Constant
        || kind == ExpressionKind::Nil || kind == ExpressionKind::Boolean;
}

inline const char* disposition_name(EmissionDisposition disposition) {
    switch (disposition) {
        case EmissionDisposition::ExplicitStatement: return "explicit_statement";
        case EmissionDisposition::InlineLiteral: return "inline_literal";
        case EmissionDisposition::StructuralScaffolding: return "structural_scaffolding";
    }
    return "invalid";
}

inline Analysis analyze(const Model& model) {
    Analysis out;
    std::map<ValueOriginContract, const LocalValueContract*> locals;
    for (const LocalValueContract& local : model.authoritative_local_values)
        locals[local.identity] = &local;
    std::map<ValueOriginContract, int> web_ids;
    std::map<int, size_t> web_sizes;
    for (const ValueWebContract& web : model.authoritative_value_webs) {
        web_sizes[web.id] = web.members.size();
        for (const ValueOriginContract& member : web.members) web_ids[member] = web.id;
    }
    std::map<std::pair<LocalUseSite, int>, std::set<ValueOriginContract>> use_origins;
    for (const LocalValueContract& local : model.authoritative_local_values)
        for (const LocalUseSite& use : local.uses)
            use_origins[{use, local.identity.reg}].insert(local.identity);
    std::map<int, ValueOriginContract> leaders;
    for (const ExpressionDefinitionContract& expression : model.authoritative_expressions) {
        auto found = leaders.find(expression.identity.instruction);
        if (found == leaders.end() || expression.identity < found->second)
            leaders[expression.identity.instruction] = expression.identity;
    }

    for (const ExpressionDefinitionContract& expression : model.authoritative_expressions) {
        auto local = locals.find(expression.identity);
        auto web = web_ids.find(expression.identity);
        if (local == locals.end() || web == web_ids.end()) {
            out.known = false;
            out.failure = "definition selection identity unavailable";
            return out;
        }
        DefinitionEmissionContract emission;
        emission.owner = model.prototype;
        emission.identity = expression.identity;
        emission.group_leader = leaders[expression.identity.instruction];
        emission.web_id = web->second;
        emission.single_use = local->second->uses.size() == 1;
        emission.capture_free = local->second->copied_by_captures.empty()
            && local->second->shared_by_captures.empty();
        if (emission.single_use) {
            emission.inline_use = *local->second->uses.begin();
            auto origins = use_origins.find({emission.inline_use, expression.identity.reg});
            emission.single_origin_at_use = origins != use_origins.end()
                && origins->second == std::set<ValueOriginContract>{expression.identity};
            auto dominators = model.block_dominators.find(emission.inline_use.block.value);
            emission.dominance_proven = dominators != model.block_dominators.end()
                && dominators->second.count(expression.block.value)
                && (expression.block != emission.inline_use.block
                    || expression.identity.instruction < emission.inline_use.instruction);
        }

        if (expression.compiler_scaffolding) {
            bool structurally_owned = false;
            if (expression.kind == ExpressionKind::MethodFunction
                || expression.kind == ExpressionKind::MethodReceiver) {
                for (const CallContract& call : model.authoritative_calls)
                    if (call.method_call
                        && call.namecall_instruction == expression.identity.instruction
                        && ((expression.kind == ExpressionKind::MethodFunction
                             && expression.identity.reg == call.base_register)
                            || (expression.kind == ExpressionKind::MethodReceiver
                                && expression.identity.reg == call.receiver_register))) {
                        structurally_owned = true; break;
                    }
            } else if (expression.kind == ExpressionKind::NumericLoopState
                       || expression.kind == ExpressionKind::GenericLoopResult) {
                for (const auto& loop : model.authoritative_loops)
                    if (loop.first.value == expression.block.value
                        || loop.second.latches.count(expression.block)) {
                        structurally_owned = true; break;
                    }
            }
            if (!structurally_owned) {
                out.known = false;
                out.failure = std::string("compiler scaffolding lacks call/loop structural owner:")
                    + expressions::kind_name(expression.kind)
                    + ":instruction=" + std::to_string(expression.identity.instruction)
                    + ":block=" + std::to_string(expression.block.value)
                    + ":reg=" + std::to_string(expression.identity.reg);
                return out;
            }
            emission.disposition = EmissionDisposition::StructuralScaffolding;
        } else if (literal_kind(expression.kind) && emission.single_use
                   && emission.single_origin_at_use && emission.dominance_proven
                   && emission.capture_free && web_sizes[emission.web_id] == 1) {
            emission.disposition = EmissionDisposition::InlineLiteral;
        } else {
            emission.disposition = EmissionDisposition::ExplicitStatement;
            emission.emits_statement = emission.identity == emission.group_leader;
        }
        out.definitions.insert(std::move(emission));
    }
    return out;
}

} // namespace sir::selection
