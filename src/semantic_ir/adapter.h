// semantic_ir/adapter.h -- read-only bridge from existing CFG manifest facts.
#pragma once
#include "model.h"
#include "value_flow.h"
#include "local_lifetime.h"
#include "value_web.h"
#include "expression_semantics.h"
#include "statement_selection.h"
#include "predicate_semantics.h"
#include "../ir.h"
#include "../semantic_plan.h"
#include <algorithm>
#include <sstream>

namespace sir {

struct Adaptation {
    Model model;
    std::vector<std::string> failures;
    std::vector<std::string> observations;
    bool ok() const { return failures.empty(); }
};

inline EdgeKind adapt_edge_kind(sem::EdgeKind kind) {
    switch (kind) {
        case sem::EdgeKind::ConditionalTrue: return EdgeKind::BranchTrue;
        case sem::EdgeKind::ConditionalFalse: return EdgeKind::BranchFalse;
        case sem::EdgeKind::Backedge: return EdgeKind::LoopBack;
        case sem::EdgeKind::LoopExit: return EdgeKind::LoopExit;
        case sem::EdgeKind::Return: return EdgeKind::Return;
        case sem::EdgeKind::Fallthrough:
            return EdgeKind::Sequence;
        case sem::EdgeKind::Unconditional: return EdgeKind::Unconditional;
    }
    return EdgeKind::Sequence;
}

inline NodeKind adapt_loop_kind(const std::string& form) {
    if (form == "for_numeric") return NodeKind::NumericFor;
    if (form == "for_generic") return NodeKind::GenericFor;
    if (form == "repeat") return NodeKind::Repeat;
    return NodeKind::While;
}

inline int closure_target(const ir::IProto& proto, const ir::IInsn& instruction) {
    if (instruction.op == 0x16) {
        if (instruction.Bx >= proto.kids.size()) return -1;
        return (int)proto.kids[instruction.Bx];
    }
    if (instruction.op == 0x42) {
        if (instruction.Bx >= proto.consts.size()
            || proto.consts[instruction.Bx].kind != ir::KKind::Closure) return -1;
        return (int)proto.consts[instruction.Bx].sub;
    }
    return -1;
}

inline Adaptation adapt_manifest(const ir::IProto& proto, const sem::Manifest& manifest,
                                 const std::vector<ir::IProto>& module_prototypes) {
    Adaptation result;
    Model& model = result.model;
    model.prototype = PrototypeId(manifest.prototype);
    model.root = NodeId(0);
    model.authoritative_prototypes.insert(model.prototype);

    Node function;
    function.id = NodeId(0); function.kind = NodeKind::Function;
    function.prototype = model.prototype; function.parameter_count = proto.nparams;
    function.maximum_register_count = proto.maxstack; function.upvalue_count = proto.nups;
    function.accepts_varargs = proto.vararg; function.returns_multiple = true;
    function.children = {NodeId(1)};
    Node sequence;
    sequence.id = NodeId(1); sequence.parent = function.id; sequence.kind = NodeKind::Sequence;
    model.nodes[function.id] = function; model.nodes[sequence.id] = sequence;
    model.authoritative_upvalue_count = proto.nups;
    const vf::Analysis value_flow = vf::analyze(proto, manifest);
    const vf::TopAnalysis top_flow = vf::analyze_top(proto, manifest);
    if (!value_flow.known || !value_flow.converged)
        result.failures.push_back("SIR_VALUE_FLOW_UNAVAILABLE");
    if (!vf::top_contracts_closed(proto, manifest, top_flow))
        result.failures.push_back("SIR_TOP_FLOW_CONTRACT");

    for (int block : manifest.reachable_block_ids) model.reachable_blocks.insert(BlockId(block));
    model.block_instruction_ranges = manifest.block_instruction_ranges;
    model.block_dominators = manifest.block_dominators;
    for (const sem::EffectPlan& effect : manifest.effects) {
        model.observable_effects.insert(EffectId(effect.instruction));
        model.authoritative_effect_order.push_back(EffectId(effect.instruction));
        model.semantic_effect_order.push_back(EffectId(effect.instruction));
    }
    for (const sem::EdgePlan& edge : manifest.edges) {
        Edge adapted{BlockId(edge.source), BlockId(edge.target), adapt_edge_kind(edge.kind)};
        model.cfg_edges.insert(adapted);
    }

    std::map<int, NodeId> loop_nodes;
    int next_node = 2;
    for (const auto& item : manifest.loops) loop_nodes[item.first] = NodeId(next_node++);
    for (const auto& item : manifest.loops) {
        const sem::LoopPlan& source = item.second;
        AuthoritativeLoop authoritative;
        authoritative.id = LoopId(source.header); authoritative.parent = LoopId(source.parent_header);
        authoritative.prep = BlockId(source.prep);
        authoritative.canonical_latch = BlockId(source.canonical_latch);
        for (int child : source.child_headers) authoritative.children.insert(LoopId(child));
        for (int block : source.body) authoritative.body.insert(BlockId(block));
        for (int latch : source.latches) authoritative.latches.insert(BlockId(latch));
        for (const auto& exit_pair : source.exits)
            authoritative.exits.insert({BlockId(exit_pair.first), BlockId(exit_pair.second),
                                        ExitKind::Normal});
        model.authoritative_loops[authoritative.id] = authoritative;

        Node node;
        node.id = loop_nodes[source.header]; node.kind = adapt_loop_kind(source.source_form);
        node.loop = authoritative.id; node.loop_parent = authoritative.parent;
        node.loop_children = authoritative.children; node.loop_body = authoritative.body;
        node.loop_latches = authoritative.latches; node.loop_exits = authoritative.exits;
        node.loop_canonical_latch = authoritative.canonical_latch;
        node.parent = source.parent_header >= 0 && loop_nodes.count(source.parent_header)
            ? loop_nodes[source.parent_header] : sequence.id;
        model.nodes[node.id] = node;
    }

    std::map<NodeId, std::vector<std::pair<int, NodeId>>> ordered_children;
    for (const auto& item : manifest.loops) {
        const sem::LoopPlan& loop = item.second;
        int key = loop.body.empty() ? loop.header : *loop.body.begin();
        ordered_children[model.nodes[loop_nodes[item.first]].parent].push_back({key,
                                                                              loop_nodes[item.first]});
    }
    std::map<int, std::vector<EffectId>> effects_by_block;
    std::map<int, int> effect_order_by_instruction;
    std::map<int, std::set<Edge>> edges_by_block;
    std::map<std::pair<int, int>, int> edge_loop_header;
    std::map<int, sem::PredicatePlan> predicates_by_block;
    std::map<std::pair<int, int>, std::set<ValueOriginContract>> value_origins;
    for (const vf::Use& use : value_flow.uses)
        for (const vf::Origin& origin : use.reaching)
            value_origins[{use.instruction, use.reg}].insert(
                ValueOriginContract{(int)origin.kind, origin.instruction, origin.reg});
    std::map<int, vf::TopUse> top_use_by_instruction;
    for (const vf::TopUse& use : top_flow.uses) top_use_by_instruction[use.instruction] = use;
    std::map<int, ReturnContract> return_by_block;
    for (size_t effect_order = 0; effect_order < manifest.effects.size(); ++effect_order) {
        const sem::EffectPlan& effect = manifest.effects[effect_order];
        effects_by_block[effect.block].push_back(EffectId(effect.instruction));
        effect_order_by_instruction[effect.instruction] = (int)effect_order;
    }
    for (const Edge& edge : model.cfg_edges) edges_by_block[edge.source.value].insert(edge);
    for (const sem::EdgePlan& edge : manifest.edges)
        if (edge.loop_header >= 0)
            edge_loop_header[{edge.source, edge.target}] = edge.loop_header;
    for (const sem::PredicatePlan& predicate : manifest.predicates) {
        predicates_by_block[predicate.block] = predicate;
        BranchContract branch;
        branch.source = BlockId(predicate.block);
        branch.true_target = BlockId(predicate.true_target);
        branch.false_target = BlockId(predicate.false_target);
        branch.join = BlockId(predicate.join);
        branch.virtual_exit_join = predicate.virtual_exit_join;
        branch.chain_next = BlockId(predicate.chain_next);
        branch.chain_shared_target = BlockId(predicate.chain_shared_target);
        branch.true_escapes_region = predicate.true_escapes_region;
        branch.false_escapes_region = predicate.false_escapes_region;
        branch.true_has_terminal = predicate.true_has_terminal;
        branch.false_has_terminal = predicate.false_has_terminal;
        branch.loop = LoopId(predicate.loop_header);
        if (predicate.role == "loop_condition") branch.role = BranchRole::LoopCondition;
        else if (predicate.role == "redundant_predicate") branch.role = BranchRole::Redundant;
        else if (predicate.role == "short_circuit_shared_true")
            branch.role = BranchRole::ShortCircuitSharedTrue;
        else if (predicate.role == "short_circuit_shared_false")
            branch.role = BranchRole::ShortCircuitSharedFalse;
        else if (predicate.role == "conditional_break")
            branch.role = BranchRole::ConditionalBreak;
        else if (predicate.role == "conditional_continue")
            branch.role = BranchRole::ConditionalContinue;
        else if (predicate.role == "conditional_break_continue")
            branch.role = BranchRole::ConditionalBreakContinue;
        else if (predicate.role == "preserved_cyclic")
            branch.role = BranchRole::PreservedCyclic;
        else if (predicate.role == "preserved_shared")
            branch.role = BranchRole::PreservedShared;
        else if (predicate.role == "preserved_escaping")
            branch.role = BranchRole::PreservedEscaping;
        else branch.role = predicate.proven ? BranchRole::Region : BranchRole::Unresolved;
        for (int value : predicate.true_blocks) branch.true_blocks.insert(BlockId(value));
        for (int value : predicate.false_blocks) branch.false_blocks.insert(BlockId(value));
        model.authoritative_branches.insert(branch);
    }
    std::map<int, PredicateTestContract> predicate_tests_by_block;
    std::map<int, PredicateExpressionContract> predicate_expressions_by_block;
    st::Graph predicate_graph;
    if (!build_graph(proto, predicate_graph))
        result.failures.push_back("SIR_PREDICATE_GRAPH_UNAVAILABLE");
    const predicates::Analysis predicate_analysis = predicates::analyze(
        proto, manifest, value_flow, model.prototype, predicate_graph);
    if (!predicate_analysis.known) {
        result.failures.push_back("SIR_PREDICATE_TEST_UNAVAILABLE:"
                                  + predicate_analysis.failure);
    } else {
        model.authoritative_predicate_tests = predicate_analysis.tests;
        model.authoritative_predicate_expressions = predicate_analysis.expressions;
        for (const PredicateTestContract& test : predicate_analysis.tests)
            predicate_tests_by_block[test.block.value] = test;
        for (const PredicateExpressionContract& expression : predicate_analysis.expressions)
            predicate_expressions_by_block[expression.block.value] = expression;
    }
    for (int block : manifest.reachable_block_ids) {
        int owner_header = -1; size_t owner_size = (size_t)-1;
        for (const auto& item : manifest.loops)
            if (item.second.body.count(block) && item.second.body.size() < owner_size) {
                owner_header = item.first; owner_size = item.second.body.size();
            }
        Node node;
        node.id = NodeId(next_node++); node.kind = NodeKind::UnknownPreservedOperation;
        node.parent = owner_header >= 0 ? loop_nodes[owner_header] : sequence.id;
        node.blocks.insert(BlockId(block));
        std::ostringstream provenance;
        provenance << "decoded_block=" << block;
        auto range = manifest.block_instruction_ranges.find(block);
        if (range == manifest.block_instruction_ranges.end()) {
            result.failures.push_back("SIR_ADAPTER_BLOCK_RANGE_MISSING");
        } else {
            for (int instruction = range->second.first;
                 instruction <= range->second.second && instruction < (int)proto.code.size();
                 ++instruction) {
                provenance << ";i" << instruction << '=' << proto.code[instruction].text;
                if (!proto.code[instruction].annotated)
                    result.failures.push_back("SIR_ADAPTER_INSTRUCTION_UNRESOLVED");
            }
        }
        node.preserved_opcode = provenance.str();
        model.nodes[node.id] = node;
        ordered_children[node.parent].push_back({block, node.id});

        if (range == manifest.block_instruction_ranges.end()) continue;
        std::set<EffectId> dedicated_effects;
        auto origins_for = [&](int instruction_index, int reg) {
            auto found = value_origins.find({instruction_index, reg});
            return found == value_origins.end() ? std::set<ValueOriginContract>{}
                                                : found->second;
        };
        for (int instruction_index = range->second.first;
             instruction_index <= range->second.second
                 && instruction_index < (int)proto.code.size(); ++instruction_index) {
            const ir::IInsn& instruction = proto.code[instruction_index];
            if (instruction.op == 0x39) { // CLOSEUPVALS A
                ScopeCloseContract authoritative;
                authoritative.owner = model.prototype;
                authoritative.block = BlockId(block);
                authoritative.instruction = instruction_index;
                authoritative.first_register = instruction.A;
                model.authoritative_scope_closes.insert(authoritative);
                Node close;
                close.id = NodeId(next_node++); close.parent = node.id;
                close.kind = NodeKind::ScopeClose; close.has_scope_close = true;
                close.scope_close = authoritative;
                model.nodes[close.id] = close;
                ordered_children[node.id].push_back({instruction_index, close.id});
                continue;
            }
            if (instruction.op == 0x02 || instruction.op == 0x53) {
                StoreOperationContract authoritative;
                authoritative.owner = model.prototype;
                authoritative.block = BlockId(block);
                authoritative.instruction = instruction_index;
                auto effect_order = effect_order_by_instruction.find(instruction_index);
                if (effect_order == effect_order_by_instruction.end()) {
                    result.failures.push_back("SIR_STORE_EFFECT_MISSING");
                    continue;
                }
                authoritative.effect_order = effect_order->second;
                authoritative.kind = instruction.op == 0x02
                    ? StoreOperationKind::Global : StoreOperationKind::Upvalue;
                authoritative.value_origins = origins_for(instruction_index, instruction.A);
                if (authoritative.value_origins.empty())
                    result.failures.push_back("SIR_STORE_VALUE_ORIGIN_MISSING");
                if (instruction.op == 0x02) authoritative.name = instruction.note;
                else authoritative.upvalue_slot = instruction.B;
                authoritative.raw_a = instruction.A;
                authoritative.raw_b = instruction.B;
                model.authoritative_store_operations.insert(authoritative);
                dedicated_effects.insert(EffectId(instruction_index));
                Node store;
                store.id = NodeId(next_node++); store.parent = node.id;
                store.kind = NodeKind::Assignment;
                store.has_store_operation = true;
                store.store_operation = authoritative;
                store.effects.push_back(EffectId(instruction_index));
                model.nodes[store.id] = store;
                ordered_children[node.id].push_back({instruction_index, store.id});
                continue;
            }
            if (instruction.op == 0x2c || instruction.op == 0x4f
                || instruction.op == 0x15 || instruction.op == 0x2a
                || instruction.op == 0x2e || instruction.op == 0x3f) {
                TableOperationContract authoritative;
                authoritative.owner = model.prototype; authoritative.block = BlockId(block);
                authoritative.instruction = instruction_index;
                authoritative.raw_a = instruction.A; authoritative.raw_b = instruction.B;
                authoritative.raw_c = instruction.C; authoritative.raw_bx = instruction.Bx;
                authoritative.raw_aux = instruction.aux;
                const bool allocation = instruction.op == 0x2c || instruction.op == 0x4f;
                if (instruction.op == 0x2c) authoritative.kind = TableOperationKind::NewTable;
                else if (instruction.op == 0x4f)
                    authoritative.kind = TableOperationKind::DuplicateTemplate;
                else if (instruction.op == 0x15)
                    authoritative.kind = TableOperationKind::SetField;
                else if (instruction.op == 0x2a)
                    authoritative.kind = TableOperationKind::SetIndex;
                else if (instruction.op == 0x2e)
                    authoritative.kind = TableOperationKind::SetNumber;
                else authoritative.kind = TableOperationKind::SetList;
                if (allocation) {
                    authoritative.table_register = instruction.A;
                    authoritative.table_origins.insert(
                        ValueOriginContract{2, instruction_index, instruction.A});
                } else {
                    auto effect_order = effect_order_by_instruction.find(instruction_index);
                    if (effect_order == effect_order_by_instruction.end()) {
                        result.failures.push_back("SIR_TABLE_EFFECT_MISSING");
                        continue;
                    }
                    authoritative.effect_order = effect_order->second;
                    authoritative.table_register = instruction.op == 0x3f
                        ? instruction.A : instruction.B;
                    authoritative.table_origins = origins_for(
                        instruction_index, authoritative.table_register);
                    if (authoritative.table_origins.empty())
                        result.failures.push_back("SIR_TABLE_IDENTITY_MISSING");
                    dedicated_effects.insert(EffectId(instruction_index));
                }
                if (instruction.op == 0x15 || instruction.op == 0x2a
                    || instruction.op == 0x2e) {
                    authoritative.value_register = instruction.A;
                    authoritative.value_origins = origins_for(instruction_index, instruction.A);
                    if (authoritative.value_origins.empty())
                        result.failures.push_back("SIR_TABLE_VALUE_MISSING");
                }
                if (instruction.op == 0x15) authoritative.field_name = instruction.note;
                if (instruction.op == 0x2a) {
                    authoritative.key_register = instruction.C;
                    authoritative.key_origins = origins_for(instruction_index, instruction.C);
                    if (authoritative.key_origins.empty())
                        result.failures.push_back("SIR_TABLE_KEY_MISSING");
                }
                if (instruction.op == 0x2e) authoritative.numeric_key = instruction.C + 1;
                if (instruction.op == 0x3f) {
                    authoritative.list_first_register = instruction.B;
                    authoritative.list_value_count = instruction.C == 0 ? -1
                        : (int)instruction.C - 1;
                    authoritative.list_start_index = (int)instruction.aux;
                    if (authoritative.list_value_count >= 0) {
                        for (int offset = 0; offset < authoritative.list_value_count; ++offset) {
                            std::set<ValueOriginContract> origins = origins_for(
                                instruction_index, (int)instruction.B + offset);
                            if (origins.empty())
                                result.failures.push_back("SIR_TABLE_LIST_VALUE_MISSING");
                            authoritative.list_fixed_values.push_back(std::move(origins));
                        }
                    } else {
                        auto top = top_use_by_instruction.find(instruction_index);
                        if (top == top_use_by_instruction.end()
                            || top->second.reaching.size() != 1) {
                            result.failures.push_back("SIR_TABLE_TOP_ORIGIN_MISSING");
                        } else {
                            const vf::TopOrigin& origin = *top->second.reaching.begin();
                            authoritative.list_open_origin_kind = (int)origin.kind;
                            authoritative.list_open_origin_instruction = origin.instruction;
                            authoritative.list_open_origin_base = origin.base;
                            // SETLIST C=0 consumes every register from B through VM top.
                            // An open producer may begin above B, leaving a fixed prefix
                            // that must precede its variable result tail.  Keep those
                            // identities explicitly; recording only the top producer
                            // silently dropped values such as R4 in [R4, call R5..top].
                            if (origin.base < authoritative.list_first_register) {
                                result.failures.push_back("SIR_TABLE_TOP_BASE_BEFORE_LIST");
                            } else {
                                for (int reg = authoritative.list_first_register;
                                     reg < origin.base; ++reg) {
                                    std::set<ValueOriginContract> origins = origins_for(
                                        instruction_index, reg);
                                    if (origins.empty())
                                        result.failures.push_back(
                                            "SIR_TABLE_LIST_PREFIX_VALUE_MISSING");
                                    authoritative.list_fixed_values.push_back(
                                        std::move(origins));
                                }
                            }
                        }
                    }
                }
                model.authoritative_table_operations.insert(authoritative);
                Node table_node;
                table_node.id = NodeId(next_node++); table_node.parent = node.id;
                table_node.kind = allocation ? NodeKind::TableConstructor : NodeKind::Assignment;
                table_node.has_table_operation = true;
                table_node.table_operation = authoritative;
                if (!allocation) table_node.effects.push_back(EffectId(instruction_index));
                model.nodes[table_node.id] = table_node;
                ordered_children[node.id].push_back({instruction_index, table_node.id});
                continue;
            }
            if (instruction.op == 0x29) {
                ReturnContract authoritative;
                authoritative.owner = model.prototype;
                authoritative.block = BlockId(block);
                authoritative.instruction = instruction_index;
                auto effect_order = effect_order_by_instruction.find(instruction_index);
                if (effect_order == effect_order_by_instruction.end()) {
                    result.failures.push_back("SIR_RETURN_EFFECT_MISSING");
                    continue;
                }
                authoritative.effect_order = effect_order->second;
                authoritative.first_register = instruction.A;
                authoritative.value_count = instruction.B == 0 ? -1
                    : (int)instruction.B - 1;
                if (authoritative.value_count >= 0) {
                    for (int offset = 0; offset < authoritative.value_count; ++offset) {
                        auto origins = value_origins.find({instruction_index,
                                                          (int)instruction.A + offset});
                        if (origins == value_origins.end() || origins->second.empty())
                            result.failures.push_back("SIR_RETURN_VALUE_ORIGIN_MISSING");
                        authoritative.fixed_values.push_back(origins == value_origins.end()
                            ? std::set<ValueOriginContract>{} : origins->second);
                    }
                } else {
                    auto top = top_use_by_instruction.find(instruction_index);
                    if (top == top_use_by_instruction.end() || top->second.reaching.size() != 1) {
                        result.failures.push_back("SIR_RETURN_TOP_ORIGIN_MISSING");
                    } else {
                        const vf::TopOrigin& origin = *top->second.reaching.begin();
                        authoritative.open_origin_kind = (int)origin.kind;
                        authoritative.open_origin_instruction = origin.instruction;
                        authoritative.open_origin_base = origin.base;
                        // RETURN B=0 returns every register from A through VM top.
                        // Preserve values below the open producer base as the fixed
                        // prefix of the source return list.
                        if (origin.base < authoritative.first_register) {
                            result.failures.push_back("SIR_RETURN_TOP_BASE_BEFORE_FIRST");
                        } else {
                            for (int reg = authoritative.first_register;
                                 reg < origin.base; ++reg) {
                                auto origins = value_origins.find(
                                    {instruction_index, reg});
                                if (origins == value_origins.end()
                                    || origins->second.empty())
                                    result.failures.push_back(
                                        "SIR_RETURN_PREFIX_VALUE_ORIGIN_MISSING");
                                authoritative.fixed_values.push_back(
                                    origins == value_origins.end()
                                        ? std::set<ValueOriginContract>{}
                                        : origins->second);
                            }
                        }
                    }
                }
                model.authoritative_returns.insert(authoritative);
                if (!return_by_block.emplace(block, authoritative).second)
                    result.failures.push_back("SIR_RETURN_BLOCK_DUPLICATE");
                dedicated_effects.insert(EffectId(instruction_index));
                continue;
            }
            if (instruction.op == 0x54) {
                CallContract authoritative;
                authoritative.owner = model.prototype;
                authoritative.block = BlockId(block);
                authoritative.instruction = instruction_index;
                auto effect_order = effect_order_by_instruction.find(instruction_index);
                if (effect_order == effect_order_by_instruction.end()) {
                    result.failures.push_back("SIR_CALL_EFFECT_MISSING");
                    continue;
                }
                authoritative.effect_order = effect_order->second;
                authoritative.base_register = instruction.A;
                authoritative.method_call = instruction_index > range->second.first
                    && proto.code[instruction_index - 1].op == 0x2d
                    && proto.code[instruction_index - 1].A == instruction.A;
                authoritative.namecall_instruction = authoritative.method_call
                    ? instruction_index - 1 : -1;
                authoritative.receiver_register = authoritative.method_call
                    ? (int)instruction.A + 1 : -1;
                authoritative.argument_first = (int)instruction.A + 1;
                authoritative.argument_count = instruction.B == 0 ? -1
                    : (int)instruction.B - 1;
                authoritative.explicit_argument_first = (int)instruction.A
                    + (authoritative.method_call ? 2 : 1);
                authoritative.explicit_argument_count = instruction.B == 0 ? -1
                    : std::max(0, (int)instruction.B - 1
                                      - (authoritative.method_call ? 1 : 0));
                authoritative.result_first = instruction.A;
                authoritative.result_count = instruction.C == 0 ? -1
                    : (int)instruction.C - 1;
                authoritative.callee_origins = origins_for(
                    instruction_index, authoritative.base_register);
                if (authoritative.callee_origins.empty())
                    result.failures.push_back("SIR_CALL_CALLEE_ORIGIN_MISSING");
                if (authoritative.method_call) {
                    authoritative.receiver_origins = origins_for(
                        instruction_index, authoritative.receiver_register);
                    if (authoritative.receiver_origins.empty())
                        result.failures.push_back("SIR_CALL_RECEIVER_ORIGIN_MISSING");
                }
                if (authoritative.explicit_argument_count >= 0) {
                    for (int offset = 0;
                         offset < authoritative.explicit_argument_count; ++offset) {
                        std::set<ValueOriginContract> origins = origins_for(
                            instruction_index,
                            authoritative.explicit_argument_first + offset);
                        if (origins.empty())
                            result.failures.push_back("SIR_CALL_ARGUMENT_ORIGIN_MISSING");
                        authoritative.fixed_argument_origins.push_back(std::move(origins));
                    }
                } else {
                    auto top = top_use_by_instruction.find(instruction_index);
                    if (top == top_use_by_instruction.end()
                        || top->second.reaching.size() != 1) {
                        result.failures.push_back("SIR_CALL_TOP_ORIGIN_MISSING");
                    } else {
                        const vf::TopOrigin& origin = *top->second.reaching.begin();
                        authoritative.open_argument_origin_kind = (int)origin.kind;
                        authoritative.open_argument_origin_instruction = origin.instruction;
                        authoritative.open_argument_origin_base = origin.base;
                        for (int reg = authoritative.explicit_argument_first;
                             reg < origin.base; ++reg) {
                            std::set<ValueOriginContract> origins = origins_for(
                                instruction_index, reg);
                            if (origins.empty())
                                result.failures.push_back(
                                    "SIR_CALL_FIXED_PREFIX_ORIGIN_MISSING");
                            authoritative.fixed_argument_origins.push_back(
                                std::move(origins));
                        }
                    }
                }
                model.authoritative_calls.insert(authoritative);

                Node call;
                call.id = NodeId(next_node++); call.parent = node.id;
                call.kind = NodeKind::Call; call.call_block = authoritative.block;
                call.call_instruction = authoritative.instruction;
                call.call_effect_order = authoritative.effect_order;
                call.call_base_register = authoritative.base_register;
                call.call_is_method = authoritative.method_call;
                call.call_namecall_instruction = authoritative.namecall_instruction;
                call.call_receiver_register = authoritative.receiver_register;
                call.call_argument_first = authoritative.argument_first;
                call.call_argument_count = authoritative.argument_count;
                call.call_explicit_argument_first = authoritative.explicit_argument_first;
                call.call_explicit_argument_count = authoritative.explicit_argument_count;
                call.call_result_first = authoritative.result_first;
                call.call_result_count = authoritative.result_count;
                call.call_callee_origins = authoritative.callee_origins;
                call.call_receiver_origins = authoritative.receiver_origins;
                call.call_fixed_argument_origins = authoritative.fixed_argument_origins;
                call.call_open_argument_origin_kind =
                    authoritative.open_argument_origin_kind;
                call.call_open_argument_origin_instruction =
                    authoritative.open_argument_origin_instruction;
                call.call_open_argument_origin_base =
                    authoritative.open_argument_origin_base;
                call.effects.push_back(EffectId(instruction_index));
                dedicated_effects.insert(EffectId(instruction_index));
                model.nodes[call.id] = call;
                ordered_children[node.id].push_back({instruction_index, call.id});
                continue;
            }
            if (instruction.op != 0x16 && instruction.op != 0x42) continue;
            const int target = closure_target(proto, instruction);
            if (target < 0 || target >= (int)module_prototypes.size()) {
                result.failures.push_back("SIR_CLOSURE_TARGET_INVALID");
                continue;
            }
            ClosureContract authoritative;
            authoritative.owner = model.prototype;
            authoritative.target = PrototypeId(target);
            authoritative.instruction = instruction_index;
            authoritative.destination_register = instruction.A;
            authoritative.expected_capture_count = module_prototypes[target].nups;
            int cursor = instruction_index + 1;
            while (cursor < (int)proto.code.size() && proto.code[cursor].op == 0x35) {
                const ir::IInsn& raw_capture = proto.code[cursor];
                CaptureContract capture;
                capture.capture = CaptureId(cursor);
                capture.owner = model.prototype;
                capture.target = PrototypeId(target);
                capture.closure_instruction = instruction_index;
                capture.slot = (int)authoritative.captures.size();
                capture.mode = (CaptureMode)raw_capture.A;
                capture.source = raw_capture.B;
                if (raw_capture.A < 2) {
                    capture.source_origins = origins_for(cursor, raw_capture.B);
                    if (capture.source_origins.empty())
                        result.failures.push_back("SIR_CAPTURE_VALUE_ORIGIN_MISSING");
                    if (raw_capture.A == 1)
                        capture.reference_cell_register = raw_capture.B;
                } else if (raw_capture.A == 2) {
                    capture.parent_upvalue_slot = raw_capture.B;
                }
                authoritative.captures.push_back(capture);
                if (raw_capture.A > 2)
                    result.failures.push_back("SIR_CAPTURE_MODE_INVALID");
                else if (raw_capture.A < 2 && raw_capture.B >= proto.maxstack)
                    result.failures.push_back("SIR_CAPTURE_REGISTER_INVALID");
                else if (raw_capture.A == 2 && raw_capture.B >= proto.nups)
                    result.failures.push_back("SIR_CAPTURE_UPVALUE_INVALID");
                ++cursor;
            }
            if ((int)authoritative.captures.size() != authoritative.expected_capture_count)
                result.failures.push_back("SIR_CAPTURE_COUNT_MISMATCH");
            model.authoritative_closures.insert(authoritative);
            for (const CaptureContract& capture : authoritative.captures)
                model.authoritative_captures.insert(capture);

            Node closure;
            closure.id = NodeId(next_node++); closure.parent = node.id;
            closure.kind = NodeKind::Closure; closure.closure_prototype = PrototypeId(target);
            closure.closure_instruction = instruction_index;
            closure.closure_destination_register = instruction.A;
            closure.target_upvalue_count = authoritative.expected_capture_count;
            closure.captures = authoritative.captures;
            auto effect = std::find(effects_by_block[block].begin(), effects_by_block[block].end(),
                                    EffectId(instruction_index));
            if (effect != effects_by_block[block].end()) {
                closure.effects.push_back(*effect);
                dedicated_effects.insert(*effect);
            }
            model.nodes[closure.id] = closure;
            ordered_children[node.id].push_back({instruction_index, closure.id});
        }
        for (EffectId effect : effects_by_block[block])
            if (!dedicated_effects.count(effect)) model.nodes[node.id].effects.push_back(effect);

        if (!edges_by_block[block].empty()) {
            Node control;
            control.id = NodeId(next_node++); control.parent = node.id;
            control.control_source = BlockId(block);
            control.control_edges = edges_by_block[block];
            control.control_instruction = range->second.second;
            if (control.control_instruction >= 0
                && control.control_instruction < (int)proto.code.size())
                control.control_opcode = proto.code[control.control_instruction].name;
            if (control.control_edges.size() == 1
                && control.control_edges.begin()->target.valid()) {
                const int target = control.control_edges.begin()->target.value;
                auto predecessors = manifest.block_predecessors.find(target);
                if (predecessors != manifest.block_predecessors.end())
                    control.control_target_predecessor_count = (int)predecessors->second.size();
                auto dominators = manifest.block_dominators.find(target);
                if (dominators != manifest.block_dominators.end())
                    control.control_source_dominates_target = dominators->second.count(block) != 0;
            }
            bool has_return = false;
            for (const Edge& edge : control.control_edges)
                if (edge.kind == EdgeKind::Return) has_return = true;
            if (has_return) {
                control.kind = NodeKind::Return;
                auto contract = return_by_block.find(block);
                if (contract == return_by_block.end()) {
                    result.failures.push_back("SIR_RETURN_CONTRACT_MISSING");
                } else {
                    const ReturnContract& source = contract->second;
                    control.return_block = source.block;
                    control.return_instruction = source.instruction;
                    control.return_effect_order = source.effect_order;
                    control.return_first_register = source.first_register;
                    control.return_value_count = source.value_count;
                    control.return_fixed_values = source.fixed_values;
                    control.return_open_origin_kind = source.open_origin_kind;
                    control.return_open_origin_instruction = source.open_origin_instruction;
                    control.return_open_origin_base = source.open_origin_base;
                    control.effects.push_back(EffectId(source.instruction));
                }
            }
            else if (predicates_by_block.count(block)) {
                const sem::PredicatePlan& predicate = predicates_by_block.at(block);
                auto predicate_test = predicate_tests_by_block.find(block);
                if (predicate_test == predicate_tests_by_block.end()) {
                    result.failures.push_back("SIR_PREDICATE_TEST_MISSING");
                } else {
                    control.has_predicate_test = true;
                    control.predicate_test = predicate_test->second;
                }
                auto predicate_expression = predicate_expressions_by_block.find(block);
                if (predicate_expression == predicate_expressions_by_block.end()) {
                    result.failures.push_back("SIR_PREDICATE_EXPRESSION_MISSING");
                } else {
                    control.has_predicate_expression = true;
                    control.predicate_expression = predicate_expression->second;
                }
                control.branch_true_target = BlockId(predicate.true_target);
                control.branch_false_target = BlockId(predicate.false_target);
                control.branch_join = BlockId(predicate.join);
                control.branch_virtual_exit_join = predicate.virtual_exit_join;
                control.branch_chain_next = BlockId(predicate.chain_next);
                control.branch_chain_shared_target = BlockId(
                    predicate.chain_shared_target);
                control.branch_true_escapes_region = predicate.true_escapes_region;
                control.branch_false_escapes_region = predicate.false_escapes_region;
                control.branch_true_has_terminal = predicate.true_has_terminal;
                control.branch_false_has_terminal = predicate.false_has_terminal;
                control.control_loop = LoopId(predicate.loop_header);
                for (int value : predicate.true_blocks)
                    control.branch_true_blocks.insert(BlockId(value));
                for (int value : predicate.false_blocks)
                    control.branch_false_blocks.insert(BlockId(value));
                if (predicate.role == "redundant_predicate" && predicate.proven) {
                    control.kind = NodeKind::RedundantPredicate;
                    control.branch_role = BranchRole::Redundant;
                } else if (predicate.role == "loop_condition" && predicate.proven) {
                    control.kind = NodeKind::LoopCondition;
                    control.branch_role = BranchRole::LoopCondition;
                } else if ((predicate.role == "short_circuit_shared_true"
                            || predicate.role == "short_circuit_shared_false")
                           && predicate.proven) {
                    control.kind = NodeKind::BooleanShortCircuit;
                    control.branch_role = predicate.role == "short_circuit_shared_true"
                        ? BranchRole::ShortCircuitSharedTrue
                        : BranchRole::ShortCircuitSharedFalse;
                } else if (predicate.role == "conditional_break" && predicate.proven) {
                    control.kind = NodeKind::ConditionalBreak;
                    control.branch_role = BranchRole::ConditionalBreak;
                } else if (predicate.role == "conditional_continue" && predicate.proven) {
                    control.kind = NodeKind::ConditionalContinue;
                    control.branch_role = BranchRole::ConditionalContinue;
                } else if (predicate.role == "conditional_break_continue"
                           && predicate.proven) {
                    control.kind = NodeKind::ConditionalBreakContinue;
                    control.branch_role = BranchRole::ConditionalBreakContinue;
                } else if (predicate.role == "preserved_cyclic") {
                    control.kind = NodeKind::PreservedCyclicBranch;
                    control.branch_role = BranchRole::PreservedCyclic;
                } else if (predicate.role == "preserved_shared") {
                    control.kind = NodeKind::PreservedSharedBranch;
                    control.branch_role = BranchRole::PreservedShared;
                } else if (predicate.role == "preserved_escaping") {
                    control.kind = NodeKind::PreservedEscapingBranch;
                    control.branch_role = BranchRole::PreservedEscaping;
                } else if (predicate.proven) {
                    control.kind = predicate.true_blocks.empty() || predicate.false_blocks.empty()
                        ? NodeKind::If : NodeKind::IfElse;
                    control.branch_role = BranchRole::Region;
                } else {
                    control.kind = NodeKind::UnresolvedBranch;
                    control.branch_role = BranchRole::Unresolved;
                }
            }
            else if (control.control_edges.size() == 1
                     && control.control_edges.begin()->kind == EdgeKind::Sequence)
                control.kind = NodeKind::Fallthrough;
            else if (control.control_edges.size() == 1
                     && control.control_edges.begin()->kind == EdgeKind::Unconditional) {
                const int target = control.control_edges.begin()->target.value;
                int entry_loop = -1;
                for (const auto& loop_item : manifest.loops)
                    if (loop_item.second.prep == block
                        && (loop_item.second.body.count(target)
                            || loop_item.second.header == target)) {
                        entry_loop = loop_item.first; break;
                    }
                if (entry_loop >= 0) {
                    control.kind = NodeKind::LoopEntry;
                    control.control_loop = LoopId(entry_loop);
                } else if (control.control_opcode == "LOADB") {
                    control.kind = NodeKind::BooleanSkipTransfer;
                } else if (control.control_target_predecessor_count == 1
                           && control.control_source_dominates_target) {
                    control.kind = NodeKind::LinearTransfer;
                } else if (control.control_target_predecessor_count > 1) {
                    control.kind = NodeKind::JoinTransfer;
                } else {
                    control.kind = NodeKind::UnresolvedControl;
                }
            }
            else if (control.control_edges.size() == 1
                     && control.control_edges.begin()->kind == EdgeKind::LoopBack) {
                const Edge& edge = *control.control_edges.begin();
                auto loop = edge_loop_header.find({edge.source.value, edge.target.value});
                if (loop != edge_loop_header.end() && manifest.loops.count(loop->second)
                    && manifest.loops.at(loop->second).latches.count(block)) {
                    control.kind = NodeKind::LoopLatch;
                    control.control_loop = LoopId(loop->second);
                } else control.kind = NodeKind::UnresolvedControl;
            }
            else if (control.control_edges.size() == 1
                     && control.control_edges.begin()->kind == EdgeKind::LoopExit) {
                const Edge& edge = *control.control_edges.begin();
                auto loop = edge_loop_header.find({edge.source.value, edge.target.value});
                if (loop != edge_loop_header.end() && manifest.loops.count(loop->second)
                    && manifest.loops.at(loop->second).body.count(block)
                    && !manifest.loops.at(loop->second).body.count(edge.target.value)) {
                    control.kind = NodeKind::LoopExitTransfer;
                    control.control_loop = LoopId(loop->second);
                } else control.kind = NodeKind::UnresolvedControl;
            }
            else
                control.kind = NodeKind::UnresolvedControl;
            model.nodes[control.id] = control;
            ordered_children[node.id].push_back({range->second.second + 1, control.id});
        }
    }
    const locals::Analysis local_analysis = locals::analyze(
        proto, manifest, value_flow, model.prototype);
    if (!local_analysis.known) {
        result.failures.push_back("SIR_LOCAL_LIFETIME_UNAVAILABLE:" + local_analysis.failure);
    } else {
        std::set<LocalValueContract> enriched;
        for (LocalValueContract value : local_analysis.values) {
            for (const CaptureContract& capture : model.authoritative_captures) {
                if (capture.mode == CaptureMode::Upvalue) continue;
                if (!capture.source_origins.count(value.identity)) continue;
                if (capture.mode == CaptureMode::Value)
                    value.copied_by_captures.insert(capture.capture);
                else value.shared_by_captures.insert(capture.capture);
            }
            enriched.insert(std::move(value));
        }
        model.authoritative_local_values = enriched;
        model.nodes[model.root].local_values = enriched;
        const webs::Analysis web_analysis = webs::analyze(
            manifest, value_flow, model.prototype, enriched);
        if (!web_analysis.known) {
            result.failures.push_back("SIR_VALUE_WEB_UNAVAILABLE:" + web_analysis.failure);
        } else {
            model.authoritative_value_webs = web_analysis.webs;
            model.authoritative_value_merges = web_analysis.merges;
            model.nodes[model.root].value_webs = web_analysis.webs;
            model.nodes[model.root].value_merges = web_analysis.merges;
        }
    }

    const expressions::Analysis expression_analysis = expressions::analyze(
        proto, manifest, value_flow, model.prototype);
    if (!expression_analysis.known) {
        result.failures.push_back("SIR_EXPRESSION_UNAVAILABLE:"
                                  + expression_analysis.failure);
    } else {
        model.authoritative_expressions = expression_analysis.definitions;
        model.nodes[model.root].expressions = expression_analysis.definitions;
    }
    if (expression_analysis.known) {
        const selection::Analysis selection_analysis = selection::analyze(model);
        if (!selection_analysis.known) {
            result.failures.push_back("SIR_STATEMENT_SELECTION_UNAVAILABLE:"
                                      + selection_analysis.failure);
        } else {
            model.authoritative_definition_emissions = selection_analysis.definitions;
            model.nodes[model.root].definition_emissions = selection_analysis.definitions;
        }
    }

    for (auto& item : ordered_children) {
        std::sort(item.second.begin(), item.second.end(),
                  [](const auto& left, const auto& right) {
                      return left.first != right.first ? left.first < right.first
                                                       : left.second < right.second;
                  });
        std::vector<NodeId>& children = model.nodes[item.first].children;
        for (const auto& child : item.second) children.push_back(child.second);
    }

    // Keep every legacy planner diagnostic visible, but do not let an old renderer-region claimant
    // veto independently verified block/effect/loop/edge ownership in the new IR. Adapter failures
    // and verifier invariants remain fatal.
    for (const sem::Failure& failure : manifest.failures)
        result.observations.push_back("LEGACY_" + failure.code);
    model.ownership_conflicts = result.failures;
    model.renderer_ready = result.failures.empty();
    return result;
}

} // namespace sir
