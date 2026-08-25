// semantic_ir/fixtures.h -- native positive/negative invariant fixtures.
#pragma once
#include "json.h"
#include "verify.h"
#include "value_flow.h"
#include "local_lifetime.h"
#include "value_web.h"
#include "expression_semantics.h"
#include "predicate_semantics.h"
#include <functional>

namespace sir {

inline Node fixture_node(int id, int parent, NodeKind kind) {
    Node node; node.id = NodeId(id); node.parent = NodeId(parent); node.kind = kind; return node;
}

inline Model valid_fixture() {
    Model model;
    model.prototype = PrototypeId(0); model.root = NodeId(0); model.renderer_ready = true;
    model.reachable_blocks = {BlockId(0), BlockId(1), BlockId(2)};
    model.block_instruction_ranges = {{0, {0, 0}}, {1, {1, 1}}, {2, {2, 6}}};
    model.block_dominators = {{0, {0}}, {1, {0, 1}}, {2, {0, 1, 2}}};
    model.observable_effects = {EffectId(0), EffectId(2)};
    model.authoritative_effect_order = {EffectId(0), EffectId(2)};
    model.semantic_effect_order = model.authoritative_effect_order;
    model.authoritative_prototypes = {PrototypeId(0)};
    CaptureContract capture;
    capture.capture = CaptureId(11); capture.owner = PrototypeId(0);
    capture.target = PrototypeId(1); capture.closure_instruction = 10;
    capture.slot = 0; capture.mode = CaptureMode::Value; capture.source = 0;
    capture.source_origins = {ValueOriginContract{0, -1, 0}};
    model.authoritative_captures = {capture};
    ClosureContract closure_contract;
    closure_contract.owner = PrototypeId(0); closure_contract.target = PrototypeId(1);
    closure_contract.instruction = 10; closure_contract.destination_register = 2;
    closure_contract.expected_capture_count = 1; closure_contract.captures = {capture};
    model.authoritative_closures = {closure_contract};

    Node function = fixture_node(0, -1, NodeKind::Function);
    function.prototype = PrototypeId(0); function.parameter_count = 1;
    function.maximum_register_count = 4; function.upvalue_count = 0;
    function.accepts_varargs = true; function.returns_multiple = true;
    LocalValueContract parameter_value;
    parameter_value.owner = PrototypeId(0);
    parameter_value.identity = ValueOriginContract{0, -1, 0};
    parameter_value.definition_block = BlockId(0);
    parameter_value.declaration_block = BlockId(0);
    parameter_value.parameter = true;
    parameter_value.uses = {LocalUseSite{BlockId(0), 0}};
    parameter_value.lifetimes = {LocalBlockLifetime{BlockId(0), 0, 0, true, true}};
    parameter_value.copied_by_captures = {CaptureId(11)};
    function.local_values = {parameter_value};
    ValueWebContract parameter_web;
    parameter_web.owner = PrototypeId(0); parameter_web.id = 0;
    parameter_web.reg = 0; parameter_web.declaration_block = BlockId(0);
    parameter_web.members = {parameter_value.identity};
    parameter_web.uses = parameter_value.uses;
    function.value_webs = {parameter_web};
    function.children = {NodeId(1)};
    Node sequence = fixture_node(1, 0, NodeKind::Sequence);
    sequence.children = {NodeId(2), NodeId(5), NodeId(6), NodeId(100), NodeId(102), NodeId(3)};
    Node loop = fixture_node(2, 1, NodeKind::GenericFor);
    loop.children = {NodeId(4), NodeId(7)}; loop.blocks = {BlockId(0)}; loop.loop = LoopId(0);
    loop.loop_body = {BlockId(0), BlockId(1)}; loop.loop_latches = {BlockId(1)};
    loop.loop_exits = {Exit{BlockId(1), BlockId(2), ExitKind::Normal}};
    Node ret = fixture_node(3, 1, NodeKind::Return);
    ret.blocks = {BlockId(2)}; ret.effects = {EffectId(2)};
    ret.control_source = BlockId(2);
    ret.control_edges = {Edge{BlockId(2), BlockId(), EdgeKind::Return}};
    ret.control_instruction = 2; ret.control_opcode = "RETURN";
    ret.return_block = BlockId(2); ret.return_instruction = 2;
    ret.return_effect_order = 1; ret.return_first_register = 0;
    ret.return_value_count = 1;
    ret.return_fixed_values = {{ValueOriginContract{0, -1, 0}}};
    Node body = fixture_node(4, 2, NodeKind::Call);
    body.blocks = {BlockId(1)}; body.effects = {EffectId(0)}; body.children = {NodeId(8)};
    body.call_block = BlockId(1); body.call_instruction = 0; body.call_effect_order = 0;
    body.call_base_register = 0; body.call_argument_first = 1;
    body.call_argument_count = 1; body.call_explicit_argument_first = 1;
    body.call_explicit_argument_count = 1; body.call_result_first = 0;
    body.call_result_count = 1;
    body.call_callee_origins = {ValueOriginContract{0, -1, 0}};
    body.call_fixed_argument_origins = {{ValueOriginContract{0, -1, 0}}};
    Node closure = fixture_node(5, 1, NodeKind::Closure);
    closure.closure_prototype = PrototypeId(1);
    closure.closure_instruction = 10; closure.closure_destination_register = 2;
    closure.target_upvalue_count = 1; closure.captures = {capture};
    Node unknown = fixture_node(6, 1, NodeKind::UnknownPreservedOperation);
    unknown.preserved_opcode = "DE_OP_7f";
    TableOperationContract table_contract;
    table_contract.owner = PrototypeId(0); table_contract.block = BlockId(2);
    table_contract.instruction = 5; table_contract.kind = TableOperationKind::NewTable;
    table_contract.table_register = 3;
    table_contract.table_origins = {ValueOriginContract{2, 5, 3}};
    table_contract.raw_a = 3;
    Node table = fixture_node(100, 1, NodeKind::TableConstructor);
    table.has_table_operation = true; table.table_operation = table_contract;
    ScopeCloseContract scope_contract;
    scope_contract.owner = PrototypeId(0); scope_contract.block = BlockId(2);
    scope_contract.instruction = 6; scope_contract.first_register = 2;
    Node scope_close = fixture_node(102, 1, NodeKind::ScopeClose);
    scope_close.has_scope_close = true; scope_close.scope_close = scope_contract;
    Node entry_control = fixture_node(7, 2, NodeKind::Fallthrough);
    entry_control.control_source = BlockId(0);
    entry_control.control_edges = {Edge{BlockId(0), BlockId(1), EdgeKind::Sequence}};
    entry_control.control_instruction = 0; entry_control.control_opcode = "MOVE";
    Node loop_control = fixture_node(8, 4, NodeKind::UnresolvedControl);
    loop_control.control_source = BlockId(1);
    loop_control.control_edges = {
        Edge{BlockId(1), BlockId(0), EdgeKind::LoopBack},
        Edge{BlockId(1), BlockId(2), EdgeKind::LoopExit}
    };
    loop_control.control_instruction = 1; loop_control.control_opcode = "FORGLOOP";
    model.nodes = {{function.id, function}, {sequence.id, sequence}, {loop.id, loop},
                   {ret.id, ret}, {body.id, body}, {closure.id, closure},
                   {unknown.id, unknown}, {table.id, table}, {scope_close.id, scope_close},
                   {entry_control.id, entry_control},
                   {loop_control.id, loop_control}};

    AuthoritativeLoop authoritative;
    authoritative.id = LoopId(0); authoritative.body = loop.loop_body;
    authoritative.latches = loop.loop_latches; authoritative.exits = loop.loop_exits;
    model.authoritative_loops[authoritative.id] = authoritative;
    model.cfg_edges = {
        Edge{BlockId(0), BlockId(1), EdgeKind::Sequence},
        Edge{BlockId(1), BlockId(0), EdgeKind::LoopBack},
        Edge{BlockId(1), BlockId(2), EdgeKind::LoopExit},
        Edge{BlockId(2), BlockId(), EdgeKind::Return}
    };
    CallContract call;
    call.owner = PrototypeId(0); call.block = BlockId(1); call.instruction = 0;
    call.effect_order = 0; call.base_register = 0; call.argument_first = 1;
    call.argument_count = 1; call.explicit_argument_first = 1;
    call.explicit_argument_count = 1; call.result_first = 0; call.result_count = 1;
    call.callee_origins = {ValueOriginContract{0, -1, 0}};
    call.fixed_argument_origins = {{ValueOriginContract{0, -1, 0}}};
    model.authoritative_calls.insert(call);
    ReturnContract return_contract;
    return_contract.owner = PrototypeId(0); return_contract.block = BlockId(2);
    return_contract.instruction = 2; return_contract.effect_order = 1;
    return_contract.first_register = 0; return_contract.value_count = 1;
    return_contract.fixed_values = {{ValueOriginContract{0, -1, 0}}};
    model.authoritative_returns.insert(return_contract);
    model.authoritative_table_operations.insert(table_contract);
    model.authoritative_scope_closes.insert(scope_contract);
    model.authoritative_local_values.insert(parameter_value);
    model.authoritative_value_webs.insert(parameter_web);
    return model;
}

inline Model virtual_exit_branch_fixture() {
    Model model;
    model.prototype = PrototypeId(0); model.root = NodeId(0); model.renderer_ready = true;
    model.reachable_blocks = {BlockId(0), BlockId(1), BlockId(2)};
    model.authoritative_prototypes = {PrototypeId(0)};
    Node function = fixture_node(0, -1, NodeKind::Function);
    function.prototype = PrototypeId(0); function.maximum_register_count = 1;
    function.children = {NodeId(1)};
    Node sequence = fixture_node(1, 0, NodeKind::Sequence);
    sequence.children = {NodeId(2), NodeId(3), NodeId(4)};
    Node source = fixture_node(2, 1, NodeKind::UnknownPreservedOperation);
    source.blocks = {BlockId(0)}; source.preserved_opcode = "predicate";
    source.children = {NodeId(5)};
    Node true_arm = fixture_node(3, 1, NodeKind::UnknownPreservedOperation);
    true_arm.blocks = {BlockId(1)}; true_arm.preserved_opcode = "true_terminal";
    true_arm.children = {NodeId(6)};
    Node false_arm = fixture_node(4, 1, NodeKind::UnknownPreservedOperation);
    false_arm.blocks = {BlockId(2)}; false_arm.preserved_opcode = "false_terminal";
    false_arm.children = {NodeId(7)};
    const Edge true_edge{BlockId(0), BlockId(1), EdgeKind::BranchTrue};
    const Edge false_edge{BlockId(0), BlockId(2), EdgeKind::BranchFalse};
    const Edge true_return{BlockId(1), BlockId(), EdgeKind::Return};
    const Edge false_return{BlockId(2), BlockId(), EdgeKind::Return};
    Node predicate = fixture_node(5, 2, NodeKind::IfElse);
    predicate.control_source = BlockId(0); predicate.control_edges = {true_edge, false_edge};
    predicate.control_instruction = 0; predicate.control_opcode = "JUMPIF";
    predicate.branch_true_target = BlockId(1); predicate.branch_false_target = BlockId(2);
    predicate.branch_virtual_exit_join = true; predicate.branch_role = BranchRole::Region;
    predicate.branch_true_blocks = {BlockId(1)};
    predicate.branch_false_blocks = {BlockId(2)};
    Node true_return_node = fixture_node(6, 3, NodeKind::Return);
    true_return_node.control_source = BlockId(1); true_return_node.control_edges = {true_return};
    true_return_node.control_instruction = 1; true_return_node.control_opcode = "RETURN";
    Node false_return_node = fixture_node(7, 4, NodeKind::Return);
    false_return_node.control_source = BlockId(2); false_return_node.control_edges = {false_return};
    false_return_node.control_instruction = 2; false_return_node.control_opcode = "RETURN";
    model.nodes = {{function.id, function}, {sequence.id, sequence}, {source.id, source},
                   {true_arm.id, true_arm}, {false_arm.id, false_arm},
                   {predicate.id, predicate}, {true_return_node.id, true_return_node},
                   {false_return_node.id, false_return_node}};
    model.cfg_edges = {true_edge, false_edge, true_return, false_return};
    BranchContract contract;
    contract.source = BlockId(0); contract.true_target = BlockId(1);
    contract.false_target = BlockId(2); contract.virtual_exit_join = true;
    contract.role = BranchRole::Region; contract.true_blocks = {BlockId(1)};
    contract.false_blocks = {BlockId(2)};
    model.authoritative_branches = {contract};
    return model;
}

inline Model short_circuit_branch_fixture() {
    Model model = virtual_exit_branch_fixture();
    model.reachable_blocks.insert(BlockId(3));
    Node& outer = model.nodes[NodeId(5)];
    outer.kind = NodeKind::BooleanShortCircuit;
    outer.branch_virtual_exit_join = false;
    outer.branch_role = BranchRole::ShortCircuitSharedTrue;
    outer.branch_chain_next = BlockId(2);
    outer.branch_chain_shared_target = BlockId(1);
    outer.branch_true_blocks.clear(); outer.branch_false_blocks.clear();
    const Edge child_return{BlockId(2), BlockId(), EdgeKind::Return};
    const Edge child_true{BlockId(2), BlockId(1), EdgeKind::BranchTrue};
    const Edge child_false{BlockId(2), BlockId(3), EdgeKind::BranchFalse};
    const Edge final_return{BlockId(3), BlockId(), EdgeKind::Return};
    model.cfg_edges.erase(child_return);
    model.cfg_edges.insert(child_true); model.cfg_edges.insert(child_false);
    model.cfg_edges.insert(final_return);
    Node& child = model.nodes[NodeId(7)];
    child.kind = NodeKind::UnresolvedBranch;
    child.control_edges = {child_true, child_false}; child.control_opcode = "JUMPIF";
    child.branch_true_target = BlockId(1); child.branch_false_target = BlockId(3);
    child.branch_role = BranchRole::Unresolved;
    Node final_block = fixture_node(8, 1, NodeKind::UnknownPreservedOperation);
    final_block.blocks = {BlockId(3)}; final_block.preserved_opcode = "final_terminal";
    final_block.children = {NodeId(9)};
    Node final_return_node = fixture_node(9, 8, NodeKind::Return);
    final_return_node.control_source = BlockId(3);
    final_return_node.control_edges = {final_return};
    final_return_node.control_instruction = 3; final_return_node.control_opcode = "RETURN";
    model.nodes[NodeId(8)] = final_block; model.nodes[NodeId(9)] = final_return_node;
    model.nodes[NodeId(1)].children.push_back(NodeId(8));
    BranchContract outer_contract;
    outer_contract.source = BlockId(0); outer_contract.true_target = BlockId(1);
    outer_contract.false_target = BlockId(2);
    outer_contract.role = BranchRole::ShortCircuitSharedTrue;
    outer_contract.chain_next = BlockId(2);
    outer_contract.chain_shared_target = BlockId(1);
    BranchContract child_contract;
    child_contract.source = BlockId(2); child_contract.true_target = BlockId(1);
    child_contract.false_target = BlockId(3); child_contract.role = BranchRole::Unresolved;
    model.authoritative_branches = {outer_contract, child_contract};
    return model;
}

inline Model loop_action_branch_fixture(BranchRole role) {
    Model model = valid_fixture();
    model.reachable_blocks.insert(BlockId(3)); model.reachable_blocks.insert(BlockId(4));
    Node& loop = model.nodes[NodeId(2)];
    loop.loop_body.insert(BlockId(3)); loop.loop_body.insert(BlockId(4));
    loop.loop_canonical_latch = BlockId(1);
    loop.children.push_back(NodeId(9)); loop.children.push_back(NodeId(11));
    AuthoritativeLoop& authoritative = model.authoritative_loops[LoopId(0)];
    authoritative.body.insert(BlockId(3)); authoritative.body.insert(BlockId(4));
    authoritative.canonical_latch = BlockId(1);
    const Edge old_entry{BlockId(0), BlockId(1), EdgeKind::Sequence};
    const Edge new_entry{BlockId(0), BlockId(3), EdgeKind::Sequence};
    model.cfg_edges.erase(old_entry); model.cfg_edges.insert(new_entry);
    model.nodes[NodeId(7)].control_edges = {new_entry};
    const Edge inside_to_latch{BlockId(4), BlockId(1), EdgeKind::Sequence};
    model.cfg_edges.insert(inside_to_latch);
    Node source = fixture_node(9, 2, NodeKind::UnknownPreservedOperation);
    source.blocks = {BlockId(3)}; source.preserved_opcode = "loop_action_source";
    source.children = {NodeId(10)};
    Node action = fixture_node(10, 9, NodeKind::ConditionalBreak);
    action.control_source = BlockId(3); action.control_instruction = 3;
    action.control_opcode = "JUMPIF"; action.control_loop = LoopId(0);
    action.branch_role = role;
    BlockId true_target, false_target;
    if (role == BranchRole::ConditionalBreak) {
        action.kind = NodeKind::ConditionalBreak;
        true_target = BlockId(4); false_target = BlockId(2);
    } else if (role == BranchRole::ConditionalContinue) {
        action.kind = NodeKind::ConditionalContinue;
        true_target = BlockId(1); false_target = BlockId(4);
    } else {
        action.kind = NodeKind::ConditionalBreakContinue;
        true_target = BlockId(1); false_target = BlockId(2);
    }
    const Edge true_edge{BlockId(3), true_target, EdgeKind::BranchTrue};
    const Edge false_edge{BlockId(3), false_target,
        false_target == BlockId(2) ? EdgeKind::LoopExit : EdgeKind::BranchFalse};
    action.control_edges = {true_edge, false_edge};
    action.branch_true_target = true_target; action.branch_false_target = false_target;
    model.cfg_edges.insert(true_edge); model.cfg_edges.insert(false_edge);
    if (false_target == BlockId(2)) {
        const Exit exit{BlockId(3), BlockId(2), ExitKind::Normal};
        loop.loop_exits.insert(exit); authoritative.exits.insert(exit);
    }
    Node inside = fixture_node(11, 2, NodeKind::UnknownPreservedOperation);
    inside.blocks = {BlockId(4)}; inside.preserved_opcode = "loop_action_inside";
    inside.children = {NodeId(12)};
    Node inside_control = fixture_node(12, 11, NodeKind::Fallthrough);
    inside_control.control_source = BlockId(4);
    inside_control.control_edges = {inside_to_latch};
    inside_control.control_instruction = 4; inside_control.control_opcode = "MOVE";
    model.nodes[NodeId(9)] = source; model.nodes[NodeId(10)] = action;
    model.nodes[NodeId(11)] = inside; model.nodes[NodeId(12)] = inside_control;
    BranchContract contract;
    contract.source = BlockId(3); contract.true_target = true_target;
    contract.false_target = false_target; contract.role = role; contract.loop = LoopId(0);
    model.authoritative_branches = {contract};
    return model;
}

struct FixtureResult { int assertions = 0; int passed = 0; std::vector<std::string> failures; };

inline FixtureResult run_fixtures() {
    FixtureResult result;
    auto check = [&](bool condition, const std::string& name) {
        ++result.assertions;
        if (condition) ++result.passed; else result.failures.push_back(name);
    };

    // Compound predicate truth tables pin the Soul Punch failure family: a
    // fresh target test must never be discarded in favour of a carried flag.
    auto compound = [](bool negate_fresh) {
        PredicateExpressionContract expression;
        expression.owner = PrototypeId(0); expression.block = BlockId(0);
        PredicateExpressionNodeContract fresh;
        fresh.kind = PredicateExpressionKind::Test;
        fresh.test.instruction = 10;
        expression.nodes.push_back(fresh);
        int left = 0;
        if (negate_fresh) {
            PredicateExpressionNodeContract negate;
            negate.kind = PredicateExpressionKind::Not; negate.left = 0;
            expression.nodes.push_back(negate); left = 1;
        }
        PredicateExpressionNodeContract carried;
        carried.kind = PredicateExpressionKind::Test;
        carried.test.instruction = 20;
        expression.nodes.push_back(carried);
        PredicateExpressionNodeContract either;
        either.kind = PredicateExpressionKind::Or;
        either.left = left; either.right = (int)expression.nodes.size() - 1;
        expression.nodes.push_back(either);
        expression.root = (int)expression.nodes.size() - 1;
        return expression;
    };
    for (int fresh = 0; fresh <= 1; ++fresh)
        for (int carried = 0; carried <= 1; ++carried) {
            bool known = true;
            const bool direct = predicates::evaluate_shape(
                compound(false), compound(false).root,
                {{10, fresh != 0}, {20, carried != 0}}, known);
            check(known && direct == ((fresh != 0) || (carried != 0)),
                  "compound predicate fresh-or-carried truth table");
            known = true;
            const PredicateExpressionContract inverted = compound(true);
            const bool negated = predicates::evaluate_shape(
                inverted, inverted.root,
                {{10, fresh != 0}, {20, carried != 0}}, known);
            check(known && negated == (!(fresh != 0) || (carried != 0)),
                  "compound predicate not-fresh-or-carried truth table");
        }
    const std::vector<std::pair<std::string, std::function<void(Model&)>>> mutations = {
        {"SIR_BLOCK_COVERAGE", [](Model& m) { m.nodes[NodeId(3)].blocks.clear(); }},
        {"SIR_EFFECT_COVERAGE", [](Model& m) { m.nodes[NodeId(3)].effects = {EffectId(0)}; }},
        {"SIR_LOOP_IDENTITY", [](Model& m) { m.nodes[NodeId(2)].loop = LoopId(); }},
        {"SIR_LOOP_FOREST", [](Model& m) { m.nodes[NodeId(2)].loop_body.erase(BlockId(1)); }},
        {"SIR_EDGE_COVERAGE", [](Model& m) { m.nodes[NodeId(8)].control_edges.erase(
            Edge{BlockId(1), BlockId(0), EdgeKind::LoopBack}); }},
        {"SIR_EXIT_COVERAGE", [](Model& m) { m.nodes[NodeId(2)].loop_exits.clear(); }},
        {"SIR_PROTOTYPE_CAPTURE", [](Model& m) { m.nodes[NodeId(0)].prototype = PrototypeId(9); }},
        {"SIR_SCOPE_LIFETIME", [](Model& m) {
             m.nodes[NodeId(102)].scope_close.first_register = 4; }},
        {"SIR_LOCAL_LIFETIME", [](Model& m) {
             LocalValueContract value = *m.nodes[NodeId(0)].local_values.begin();
             m.nodes[NodeId(0)].local_values.clear();
             value.declaration_block = BlockId(2);
             m.nodes[NodeId(0)].local_values.insert(value); }},
        {"SIR_VALUE_WEB", [](Model& m) {
             ValueWebContract web = *m.nodes[NodeId(0)].value_webs.begin();
             m.nodes[NodeId(0)].value_webs.clear();
             web.declaration_block = BlockId(2);
             m.nodes[NodeId(0)].value_webs.insert(web); }},
        {"SIR_EXPRESSION_SEMANTICS", [](Model& m) {
             ExpressionDefinitionContract expression;
             expression.owner = m.prototype; expression.block = BlockId(0);
             expression.identity = ValueOriginContract{2, 0, 1};
             expression.kind = ExpressionKind::Move;
             expression.raw_a = 1;
             expression.operands = {{ValueOriginContract{0, -1, 0}}};
             m.authoritative_expressions.insert(expression); }},
        {"SIR_STATEMENT_SELECTION", [](Model& m) {
             DefinitionEmissionContract emission;
             emission.owner = m.prototype;
             emission.identity = ValueOriginContract{2, 0, 1};
             emission.group_leader = emission.identity;
             emission.emits_statement = true;
             m.authoritative_definition_emissions.insert(emission); }},
        {"SIR_CALL_ARITY", [](Model& m) { m.nodes[NodeId(4)].call_result_count = 2; }},
        {"SIR_RETURN_CONTRACT", [](Model& m) {
             m.nodes[NodeId(3)].return_fixed_values.clear(); }},
        {"SIR_TABLE_CONTRACT", [](Model& m) {
             m.nodes[NodeId(100)].table_operation.table_register = 2; }},
        {"SIR_STORE_CONTRACT", [](Model& m) {
             StoreOperationContract store;
             store.owner = m.prototype; store.block = BlockId(0);
             store.instruction = 0; store.effect_order = 0;
             store.name = "fixtureGlobal";
             store.value_origins = {ValueOriginContract{0, -1, 0}};
             m.authoritative_store_operations.insert(store); }},
        {"SIR_PREDICATE_TEST", [](Model& m) {
             PredicateTestContract test;
             test.owner = m.prototype; test.block = BlockId(0);
             test.instruction = 0; test.kind = PredicateTestKind::Truthy;
             test.operands = {{ValueOriginContract{0, -1, 0}}};
             m.authoritative_predicate_tests.insert(test); }},
        {"SIR_EVALUATION_ORDER", [](Model& m) { std::swap(m.semantic_effect_order[0],
                                                           m.semantic_effect_order[1]); }},
        {"SIR_RENDER_OWNERSHIP", [](Model& m) { m.nodes[NodeId(4)].parent = NodeId(1); }}
    };
    for (const auto& mutation : mutations) {
        Model positive = valid_fixture();
        check(verify(positive).ok(), mutation.first + " positive");
        Model negative = valid_fixture(); mutation.second(negative);
        check(verify(negative).has(mutation.first), mutation.first + " negative");
    }
    Model bad_call_effect = valid_fixture();
    bad_call_effect.nodes[NodeId(4)].effects = {EffectId(1)};
    check(verify(bad_call_effect).has("SIR_CALL_ARITY"),
          "call effect identity negative");
    Model bad_call_base = valid_fixture();
    bad_call_base.nodes[NodeId(4)].call_base_register = 4;
    check(verify(bad_call_base).has("SIR_CALL_ARITY"),
          "call base register range negative");
    Model bad_call_callee = valid_fixture();
    bad_call_callee.nodes[NodeId(4)].call_callee_origins.clear();
    check(verify(bad_call_callee).has("SIR_CALL_ARITY"),
          "call missing callee value identity negative");
    Model bad_call_argument = valid_fixture();
    bad_call_argument.nodes[NodeId(4)].call_fixed_argument_origins.clear();
    check(verify(bad_call_argument).has("SIR_CALL_ARITY"),
          "call missing ordered argument identity negative");
    Model bad_method_receiver = valid_fixture();
    bad_method_receiver.nodes[NodeId(4)].call_is_method = true;
    check(verify(bad_method_receiver).has("SIR_CALL_ARITY"),
          "method receiver contract negative");
    Model open_call = valid_fixture();
    open_call.authoritative_calls.clear();
    Node& open_call_node = open_call.nodes[NodeId(4)];
    open_call_node.call_argument_count = -1;
    open_call_node.call_explicit_argument_count = -1;
    open_call_node.call_result_count = -1;
    open_call_node.call_fixed_argument_origins.clear();
    open_call_node.call_open_argument_origin_kind = (int)vf::TopKind::OpenCall;
    open_call_node.call_open_argument_origin_instruction = 0;
    open_call_node.call_open_argument_origin_base = 1;
    CallContract open_contract;
    open_contract.owner = PrototypeId(0); open_contract.block = BlockId(1);
    open_contract.instruction = 0; open_contract.effect_order = 0;
    open_contract.base_register = 0; open_contract.argument_first = 1;
    open_contract.argument_count = -1; open_contract.explicit_argument_first = 1;
    open_contract.explicit_argument_count = -1; open_contract.result_first = 0;
    open_contract.result_count = -1;
    open_contract.callee_origins = {ValueOriginContract{0, -1, 0}};
    open_contract.open_argument_origin_kind = (int)vf::TopKind::OpenCall;
    open_contract.open_argument_origin_instruction = 0;
    open_contract.open_argument_origin_base = 1;
    open_call.authoritative_calls.insert(open_contract);
    check(verify(open_call).ok(), "open call argument and result contract positive");
    Model zero_return = valid_fixture();
    zero_return.authoritative_returns.clear();
    Node& zero_return_node = zero_return.nodes[NodeId(3)];
    zero_return_node.return_first_register = 4;
    zero_return_node.return_value_count = 0;
    zero_return_node.return_fixed_values.clear();
    ReturnContract zero_return_contract;
    zero_return_contract.owner = PrototypeId(0); zero_return_contract.block = BlockId(2);
    zero_return_contract.instruction = 2; zero_return_contract.effect_order = 1;
    zero_return_contract.first_register = 4; zero_return_contract.value_count = 0;
    zero_return.authoritative_returns.insert(zero_return_contract);
    check(verify(zero_return).ok(), "zero-value return contract positive");

    Model open_return_model = valid_fixture();
    open_return_model.authoritative_returns.clear();
    Node& open_return_node = open_return_model.nodes[NodeId(3)];
    open_return_node.return_value_count = -1;
    open_return_node.return_fixed_values = {
        {ValueOriginContract{0, -1, 0}}};
    open_return_node.return_open_origin_kind = (int)vf::TopKind::OpenCall;
    open_return_node.return_open_origin_instruction = 0;
    open_return_node.return_open_origin_base = 1;
    ReturnContract open_return_contract;
    open_return_contract.owner = PrototypeId(0); open_return_contract.block = BlockId(2);
    open_return_contract.instruction = 2; open_return_contract.effect_order = 1;
    open_return_contract.first_register = 0; open_return_contract.value_count = -1;
    open_return_contract.fixed_values = {
        {ValueOriginContract{0, -1, 0}}};
    open_return_contract.open_origin_kind = (int)vf::TopKind::OpenCall;
    open_return_contract.open_origin_instruction = 0;
    open_return_contract.open_origin_base = 1;
    open_return_model.authoritative_returns.insert(open_return_contract);
    check(verify(open_return_model).ok(), "symbolic open return contract positive");

    Model bad_return_effect = valid_fixture();
    bad_return_effect.nodes[NodeId(3)].effects = {EffectId(1)};
    check(verify(bad_return_effect).has("SIR_RETURN_CONTRACT"),
          "return effect identity negative");
    Model bad_open_return = open_return_model;
    bad_open_return.nodes[NodeId(3)].return_open_origin_instruction = -1;
    check(verify(bad_open_return).has("SIR_RETURN_CONTRACT"),
          "open return missing producer negative");
    Model bad_open_return_prefix = open_return_model;
    bad_open_return_prefix.nodes[NodeId(3)].return_fixed_values.clear();
    check(verify(bad_open_return_prefix).has("SIR_RETURN_CONTRACT"),
          "open return fixed prefix truncated negative");

    Model fixed_setlist = valid_fixture();
    fixed_setlist.observable_effects.insert(EffectId(20));
    fixed_setlist.authoritative_effect_order.push_back(EffectId(20));
    fixed_setlist.semantic_effect_order.push_back(EffectId(20));
    fixed_setlist.nodes[NodeId(1)].children.push_back(NodeId(101));
    TableOperationContract fixed_list_contract;
    fixed_list_contract.owner = PrototypeId(0); fixed_list_contract.block = BlockId(2);
    fixed_list_contract.instruction = 20; fixed_list_contract.effect_order = 2;
    fixed_list_contract.kind = TableOperationKind::SetList;
    fixed_list_contract.table_register = 3;
    fixed_list_contract.table_origins = {ValueOriginContract{2, 5, 3}};
    fixed_list_contract.list_first_register = 0;
    fixed_list_contract.list_value_count = 2; fixed_list_contract.list_start_index = 1;
    fixed_list_contract.list_fixed_values = {
        {ValueOriginContract{0, -1, 0}}, {ValueOriginContract{0, -1, 1}}};
    fixed_list_contract.raw_a = 3; fixed_list_contract.raw_b = 0;
    fixed_list_contract.raw_c = 3; fixed_list_contract.raw_aux = 1;
    Node fixed_list_node = fixture_node(101, 1, NodeKind::Assignment);
    fixed_list_node.effects = {EffectId(20)};
    fixed_list_node.has_table_operation = true;
    fixed_list_node.table_operation = fixed_list_contract;
    fixed_setlist.nodes[NodeId(101)] = fixed_list_node;
    fixed_setlist.authoritative_table_operations.insert(fixed_list_contract);
    check(verify(fixed_setlist).ok(), "fixed SETLIST identity and value batch positive");

    Model open_setlist = fixed_setlist;
    open_setlist.authoritative_table_operations.erase(fixed_list_contract);
    TableOperationContract open_list_contract = fixed_list_contract;
    open_list_contract.list_value_count = -1;
    open_list_contract.list_fixed_values.clear();
    open_list_contract.list_open_origin_kind = (int)vf::TopKind::OpenCall;
    open_list_contract.list_open_origin_instruction = 0;
    open_list_contract.list_open_origin_base = 1;
    open_list_contract.list_fixed_values = {
        {ValueOriginContract{0, -1, 0}}};
    open_list_contract.raw_c = 0;
    open_setlist.nodes[NodeId(101)].table_operation = open_list_contract;
    open_setlist.authoritative_table_operations.insert(open_list_contract);
    check(verify(open_setlist).ok(), "open SETLIST symbolic VM top positive");

    Model bad_table_identity = fixed_setlist;
    bad_table_identity.nodes[NodeId(101)].table_operation.table_origins.clear();
    check(verify(bad_table_identity).has("SIR_TABLE_CONTRACT"),
          "table write missing identity negative");
    Model bad_table_order = fixed_setlist;
    bad_table_order.nodes[NodeId(101)].table_operation.effect_order = 1;
    check(verify(bad_table_order).has("SIR_TABLE_CONTRACT"),
          "table update order mismatch negative");
    Model bad_fixed_setlist = fixed_setlist;
    bad_fixed_setlist.nodes[NodeId(101)].table_operation.list_fixed_values.pop_back();
    check(verify(bad_fixed_setlist).has("SIR_TABLE_CONTRACT"),
          "fixed SETLIST truncated value batch negative");
    Model bad_open_setlist = open_setlist;
    bad_open_setlist.nodes[NodeId(101)].table_operation.list_open_origin_instruction = -1;
    check(verify(bad_open_setlist).has("SIR_TABLE_CONTRACT"),
          "open SETLIST missing producer negative");
    Model bad_open_setlist_prefix = open_setlist;
    bad_open_setlist_prefix.nodes[NodeId(101)].table_operation.list_fixed_values.clear();
    check(verify(bad_open_setlist_prefix).has("SIR_TABLE_CONTRACT"),
          "open SETLIST fixed prefix truncated negative");

    ir::IProto straight_proto;
    straight_proto.maxstack = 2; straight_proto.nparams = 1;
    ir::IInsn move; move.idx = 0; move.op = 0x14; move.A = 1; move.B = 0;
    ir::IInsn ret_value; ret_value.idx = 1; ret_value.op = 0x29;
    ret_value.A = 1; ret_value.B = 2;
    straight_proto.code = {move, ret_value};
    sem::Manifest straight_manifest;
    straight_manifest.reachable_block_ids = {0};
    straight_manifest.block_instruction_ranges[0] = {0, 1};
    vf::Analysis straight_flow = vf::analyze(straight_proto, straight_manifest);
    check(straight_flow.known && straight_flow.converged
              && straight_flow.definitions.size() == 1 && straight_flow.uses.size() == 2
              && straight_flow.uses[0].reaching.size() == 1
              && straight_flow.uses[0].reaching.begin()->kind == vf::OriginKind::Parameter
              && straight_flow.uses[1].reaching.size() == 1
              && straight_flow.uses[1].reaching.begin()->instruction == 0,
          "straight-line reaching definition positive");

    straight_manifest.block_dominators[0] = {0};
    locals::Analysis straight_locals = locals::analyze(
        straight_proto, straight_manifest, straight_flow, PrototypeId(0));
    check(straight_locals.known && straight_locals.values.size() == 2,
          "straight-line parameter and definition lifetimes positive");
    expressions::Analysis straight_expressions = expressions::analyze(
        straight_proto, straight_manifest, straight_flow, PrototypeId(0));
    check(straight_expressions.known && straight_expressions.definitions.size() == 1
              && straight_expressions.definitions.begin()->kind == ExpressionKind::Move
              && straight_expressions.definitions.begin()->operands.size() == 1
              && straight_expressions.definitions.begin()->operands[0]
                     == std::set<ValueOriginContract>{{0, -1, 0}},
          "MOVE expression retains ordered reaching operand positive");

    ir::IProto literal_proto = straight_proto;
    literal_proto.code[0].op = 0x12; literal_proto.code[0].A = 1;
    literal_proto.code[0].Bx = 7;
    vf::Analysis literal_flow = vf::analyze(literal_proto, straight_manifest);
    locals::Analysis literal_locals = locals::analyze(
        literal_proto, straight_manifest, literal_flow, PrototypeId(0));
    webs::Analysis literal_webs = webs::analyze(
        straight_manifest, literal_flow, PrototypeId(0), literal_locals.values);
    expressions::Analysis literal_expressions = expressions::analyze(
        literal_proto, straight_manifest, literal_flow, PrototypeId(0));
    Model literal_model;
    literal_model.prototype = PrototypeId(0);
    literal_model.block_dominators = straight_manifest.block_dominators;
    literal_model.authoritative_local_values = literal_locals.values;
    literal_model.authoritative_value_webs = literal_webs.webs;
    literal_model.authoritative_expressions = literal_expressions.definitions;
    selection::Analysis literal_selection = selection::analyze(literal_model);
    check(literal_selection.known && literal_selection.definitions.size() == 1
              && literal_selection.definitions.begin()->disposition
                     == EmissionDisposition::InlineLiteral
              && !literal_selection.definitions.begin()->emits_statement,
          "single-use dominated literal selects safe inline positive");
    Model captured_literal_model = literal_model;
    std::set<LocalValueContract> captured_values;
    for (LocalValueContract value : captured_literal_model.authoritative_local_values) {
        if (!value.parameter) value.copied_by_captures.insert(CaptureId(99));
        captured_values.insert(std::move(value));
    }
    captured_literal_model.authoritative_local_values = captured_values;
    selection::Analysis captured_literal_selection =
        selection::analyze(captured_literal_model);
    check(captured_literal_selection.known
              && captured_literal_selection.definitions.begin()->disposition
                     == EmissionDisposition::ExplicitStatement,
          "captured literal remains explicit statement negative boundary");

    Model grouped_call_model;
    grouped_call_model.prototype = PrototypeId(0);
    for (int reg = 0; reg < 2; ++reg) {
        const ValueOriginContract identity{2, 4, reg};
        LocalValueContract value;
        value.owner = PrototypeId(0); value.identity = identity;
        value.definition_block = BlockId(0); value.declaration_block = BlockId(0);
        grouped_call_model.authoritative_local_values.insert(value);
        ValueWebContract web;
        web.owner = PrototypeId(0); web.id = reg; web.reg = reg;
        web.declaration_block = BlockId(0); web.members = {identity};
        grouped_call_model.authoritative_value_webs.insert(web);
        ExpressionDefinitionContract expression;
        expression.owner = PrototypeId(0); expression.block = BlockId(0);
        expression.identity = identity; expression.kind = ExpressionKind::CallResult;
        expression.result_slot = reg; expression.raw_a = 0;
        grouped_call_model.authoritative_expressions.insert(expression);
    }
    selection::Analysis grouped_call_selection = selection::analyze(grouped_call_model);
    int grouped_call_owners = 0;
    for (const DefinitionEmissionContract& emission : grouped_call_selection.definitions)
        if (emission.emits_statement) ++grouped_call_owners;
    check(grouped_call_selection.known && grouped_call_selection.definitions.size() == 2
              && grouped_call_owners == 1,
          "multi-result producer has one statement owner positive");

    ir::IProto join_proto;
    join_proto.maxstack = 2; join_proto.nparams = 1;
    ir::IInsn test; test.idx = 0; test.op = 0x4b; test.A = 0;
    ir::IInsn left_def; left_def.idx = 1; left_def.op = 0x13; left_def.A = 1;
    ir::IInsn right_def = left_def; right_def.idx = 2;
    ir::IInsn join_return = ret_value; join_return.idx = 3;
    join_proto.code = {test, left_def, right_def, join_return};
    sem::Manifest join_manifest;
    join_manifest.reachable_block_ids = {0, 1, 2, 3};
    join_manifest.block_instruction_ranges[0] = {0, 0};
    join_manifest.block_instruction_ranges[1] = {1, 1};
    join_manifest.block_instruction_ranges[2] = {2, 2};
    join_manifest.block_instruction_ranges[3] = {3, 3};
    join_manifest.block_predecessors[1] = {0};
    join_manifest.block_predecessors[2] = {0};
    join_manifest.block_predecessors[3] = {1, 2};
    join_manifest.block_dominators[0] = {0};
    join_manifest.block_dominators[1] = {0, 1};
    join_manifest.block_dominators[2] = {0, 2};
    join_manifest.block_dominators[3] = {0, 3};
    vf::Analysis join_flow = vf::analyze(join_proto, join_manifest);
    check(join_flow.known && join_flow.converged && join_flow.uses.size() == 2
              && join_flow.uses[1].reaching.size() == 2,
          "branch join preserves both reaching definitions positive");
    locals::Analysis join_locals = locals::analyze(
        join_proto, join_manifest, join_flow, PrototypeId(0));
    int join_hoisted = 0, join_values_reaching_use = 0;
    for (const LocalValueContract& value : join_locals.values) {
        if (!value.parameter && value.declaration_block == BlockId(0)) ++join_hoisted;
        for (const LocalUseSite& use : value.uses)
            if (use.instruction == 3) ++join_values_reaching_use;
    }
    check(join_locals.known && join_hoisted == 2 && join_values_reaching_use == 2,
          "branch alternatives retain distinct identities with common declaration positive");
    webs::Analysis unproven_join_webs = webs::analyze(
        join_manifest, join_flow, PrototypeId(0), join_locals.values);
    check(unproven_join_webs.known && unproven_join_webs.merges.size() == 1
              && unproven_join_webs.merges.begin()->kind == ValueMergeKind::Preserved,
          "join without proven CFG region remains preserved positive");
    sem::PredicatePlan join_predicate;
    join_predicate.block = 0; join_predicate.instruction = 0;
    join_predicate.true_target = 1; join_predicate.false_target = 2;
    join_predicate.join = 3; join_predicate.role = "branch_region";
    join_predicate.true_blocks = {1}; join_predicate.false_blocks = {2};
    join_predicate.proven = true;
    join_manifest.predicates = {join_predicate};
    webs::Analysis conditional_join_webs = webs::analyze(
        join_manifest, join_flow, PrototypeId(0), join_locals.values);
    check(conditional_join_webs.known && conditional_join_webs.merges.size() == 1
              && conditional_join_webs.merges.begin()->kind
                     == ValueMergeKind::Conditional
              && conditional_join_webs.merges.begin()->conditional_source == BlockId(0),
          "proven branch alternatives classify as conditional merge positive");

    ir::IProto loop_proto;
    loop_proto.maxstack = 3; loop_proto.nparams = 0;
    ir::IInsn initial = left_def; initial.idx = 0;
    ir::IInsn loop_use = move; loop_use.idx = 1; loop_use.A = 2; loop_use.B = 1;
    ir::IInsn loop_def = left_def; loop_def.idx = 2;
    loop_proto.code = {initial, loop_use, loop_def};
    sem::Manifest loop_manifest;
    loop_manifest.reachable_block_ids = {0, 1};
    loop_manifest.block_instruction_ranges[0] = {0, 0};
    loop_manifest.block_instruction_ranges[1] = {1, 2};
    loop_manifest.block_predecessors[1] = {0, 1};
    loop_manifest.block_dominators[0] = {0};
    loop_manifest.block_dominators[1] = {0, 1};
    sem::LoopPlan loop_plan;
    loop_plan.header = 1; loop_plan.body = {1}; loop_plan.latches = {1};
    loop_plan.backedges = {{1, 1}};
    loop_manifest.loops[1] = loop_plan;
    vf::Analysis loop_flow = vf::analyze(loop_proto, loop_manifest);
    check(loop_flow.known && loop_flow.converged && loop_flow.uses.size() == 1
              && loop_flow.uses[0].reaching.size() == 2,
          "loop-carried reaching definitions converge positive");
    locals::Analysis loop_locals = locals::analyze(
        loop_proto, loop_manifest, loop_flow, PrototypeId(0));
    int loop_values_reaching_use = 0;
    for (const LocalValueContract& value : loop_locals.values)
        for (const LocalUseSite& use : value.uses)
            if (use.instruction == 1) ++loop_values_reaching_use;
    check(loop_locals.known && loop_values_reaching_use == 2,
          "loop-carried alternatives retain distinct lifetime identities positive");
    webs::Analysis loop_value_webs = webs::analyze(
        loop_manifest, loop_flow, PrototypeId(0), loop_locals.values);
    check(loop_value_webs.known && loop_value_webs.merges.size() == 1
              && loop_value_webs.merges.begin()->kind == ValueMergeKind::LoopCarried
              && loop_value_webs.merges.begin()->loop == LoopId(1),
          "authoritative backedge classifies loop-carried merge positive");

    ir::IProto mixed_proto;
    mixed_proto.maxstack = 3; mixed_proto.nparams = 1;
    ir::IInsn mixed_initial = left_def; mixed_initial.idx = 0; mixed_initial.A = 1;
    ir::IInsn mixed_test = test; mixed_test.idx = 1; mixed_test.A = 0;
    ir::IInsn mixed_left = left_def; mixed_left.idx = 2; mixed_left.A = 1;
    ir::IInsn mixed_right = left_def; mixed_right.idx = 3; mixed_right.A = 1;
    ir::IInsn mixed_use = move; mixed_use.idx = 4; mixed_use.A = 2; mixed_use.B = 1;
    mixed_proto.code = {mixed_initial, mixed_test, mixed_left, mixed_right, mixed_use};
    sem::Manifest mixed_manifest;
    mixed_manifest.reachable_block_ids = {0, 1, 2, 3, 4};
    for (int block = 0; block <= 4; ++block)
        mixed_manifest.block_instruction_ranges[block] = {block, block};
    mixed_manifest.block_predecessors[1] = {0, 4};
    mixed_manifest.block_predecessors[2] = {1};
    mixed_manifest.block_predecessors[3] = {1};
    mixed_manifest.block_predecessors[4] = {2, 3};
    mixed_manifest.block_dominators[0] = {0};
    mixed_manifest.block_dominators[1] = {0, 1};
    mixed_manifest.block_dominators[2] = {0, 1, 2};
    mixed_manifest.block_dominators[3] = {0, 1, 3};
    mixed_manifest.block_dominators[4] = {0, 1, 4};
    sem::PredicatePlan mixed_predicate;
    mixed_predicate.block = 1; mixed_predicate.instruction = 1;
    mixed_predicate.true_target = 2; mixed_predicate.false_target = 3;
    mixed_predicate.join = 4; mixed_predicate.role = "branch_region";
    mixed_predicate.true_blocks = {2}; mixed_predicate.false_blocks = {3};
    mixed_predicate.proven = true;
    mixed_manifest.predicates = {mixed_predicate};
    sem::LoopPlan mixed_loop;
    mixed_loop.header = 1; mixed_loop.body = {1, 2, 3, 4};
    mixed_loop.latches = {4}; mixed_loop.backedges = {{4, 1}};
    mixed_manifest.loops[1] = mixed_loop;
    vf::Analysis mixed_flow = vf::analyze(mixed_proto, mixed_manifest);
    locals::Analysis mixed_locals = locals::analyze(
        mixed_proto, mixed_manifest, mixed_flow, PrototypeId(0));
    webs::Analysis mixed_webs = webs::analyze(
        mixed_manifest, mixed_flow, PrototypeId(0), mixed_locals.values);
    check(mixed_flow.known && mixed_flow.converged && mixed_locals.known
              && mixed_webs.known && mixed_webs.merges.size() == 1
              && mixed_webs.merges.begin()->kind == ValueMergeKind::ConditionalLoop
              && mixed_webs.merges.begin()->conditional_source == BlockId(1)
              && mixed_webs.merges.begin()->loop == LoopId(1),
          "branch alternatives crossing authoritative backedge classify mixed merge positive");

    ir::IProto overwrite_proto;
    overwrite_proto.maxstack = 1;
    ir::IInsn first_definition; first_definition.idx = 0;
    first_definition.op = 0x13; first_definition.A = 0;
    ir::IInsn overwrite_definition = first_definition; overwrite_definition.idx = 1;
    overwrite_proto.code = {first_definition, overwrite_definition};
    sem::Manifest overwrite_manifest;
    overwrite_manifest.reachable_block_ids = {0};
    overwrite_manifest.block_instruction_ranges[0] = {0, 1};
    overwrite_manifest.block_dominators[0] = {0};
    vf::Analysis overwrite_flow = vf::analyze(overwrite_proto, overwrite_manifest);
    locals::Analysis overwrite_locals = locals::analyze(
        overwrite_proto, overwrite_manifest, overwrite_flow, PrototypeId(0));
    bool dead_definition_segment = false;
    for (const LocalValueContract& value : overwrite_locals.values)
        if (value.identity.instruction == 0 && value.uses.empty()
            && value.lifetimes.size() == 1
            && value.lifetimes.begin()->first_instruction == 0
            && value.lifetimes.begin()->last_instruction == 0)
            dead_definition_segment = true;
    check(overwrite_locals.known && overwrite_locals.values.size() == 2
              && dead_definition_segment,
          "overwritten value without read remains a point lifetime positive");

    ir::IProto top_chain_proto;
    top_chain_proto.maxstack = 4;
    ir::IInsn inner_call; inner_call.idx = 0; inner_call.op = 0x54;
    inner_call.A = 2; inner_call.B = 1; inner_call.C = 0;
    ir::IInsn outer_call = inner_call; outer_call.idx = 1;
    outer_call.A = 0; outer_call.B = 0;
    ir::IInsn open_return; open_return.idx = 2; open_return.op = 0x29;
    open_return.A = 0; open_return.B = 0;
    top_chain_proto.code = {inner_call, outer_call, open_return};
    sem::Manifest top_chain_manifest;
    top_chain_manifest.reachable_block_ids = {0};
    top_chain_manifest.block_instruction_ranges[0] = {0, 2};
    vf::TopAnalysis top_chain = vf::analyze_top(top_chain_proto, top_chain_manifest);
    check(top_chain.known && top_chain.converged && top_chain.uses.size() == 2
              && top_chain.uses[0].reaching.size() == 1
              && top_chain.uses[0].reaching.begin()->kind == vf::TopKind::OpenCall
              && top_chain.uses[0].reaching.begin()->instruction == 0
              && top_chain.uses[1].reaching.begin()->instruction == 1,
          "nested open calls preserve symbolic VM top positive");
    check(vf::top_contracts_closed(top_chain_proto, top_chain_manifest, top_chain),
          "open producer-consumer bijection positive");

    ir::IProto fixed_top_proto;
    fixed_top_proto.maxstack = 2;
    ir::IInsn fixed_zero = left_def; fixed_zero.idx = 0; fixed_zero.A = 0;
    ir::IInsn fixed_one = left_def; fixed_one.idx = 1; fixed_one.A = 1;
    ir::IInsn fixed_return = open_return; fixed_return.idx = 2;
    fixed_top_proto.code = {fixed_zero, fixed_one, fixed_return};
    sem::Manifest fixed_top_manifest;
    fixed_top_manifest.reachable_block_ids = {0};
    fixed_top_manifest.block_instruction_ranges[0] = {0, 2};
    vf::TopAnalysis fixed_top = vf::analyze_top(fixed_top_proto, fixed_top_manifest);
    check(fixed_top.known && fixed_top.converged && fixed_top.uses.size() == 1
              && fixed_top.uses[0].reaching.size() == 1
              && fixed_top.uses[0].reaching.begin()->kind == vf::TopKind::Fixed
              && fixed_top.uses[0].reaching.begin()->fixed_top == 1,
          "fixed VM top consumer positive");

    ir::IProto vararg_top_proto;
    vararg_top_proto.maxstack = 3; vararg_top_proto.vararg = true;
    ir::IInsn open_vararg; open_vararg.idx = 0; open_vararg.op = 0x4c;
    open_vararg.A = 0; open_vararg.B = 0;
    open_return.idx = 1;
    vararg_top_proto.code = {open_vararg, open_return};
    sem::Manifest vararg_top_manifest;
    vararg_top_manifest.reachable_block_ids = {0};
    vararg_top_manifest.block_instruction_ranges[0] = {0, 1};
    vf::TopAnalysis vararg_top = vf::analyze_top(vararg_top_proto, vararg_top_manifest);
    check(vararg_top.known && vararg_top.converged && vararg_top.uses.size() == 1
              && vararg_top.uses[0].reaching.size() == 1
              && vararg_top.uses[0].reaching.begin()->kind == vf::TopKind::OpenVararg,
          "open vararg VM top positive");

    ir::IProto joined_top_proto;
    joined_top_proto.maxstack = 3; joined_top_proto.nparams = 1;
    ir::IInsn top_test = test; top_test.idx = 0;
    ir::IInsn left_call = inner_call; left_call.idx = 1; left_call.A = 0;
    ir::IInsn right_call = inner_call; right_call.idx = 2; right_call.A = 0;
    ir::IInsn joined_return = open_return; joined_return.idx = 3;
    joined_top_proto.code = {top_test, left_call, right_call, joined_return};
    sem::Manifest joined_top_manifest;
    joined_top_manifest.reachable_block_ids = {0, 1, 2, 3};
    joined_top_manifest.block_instruction_ranges[0] = {0, 0};
    joined_top_manifest.block_instruction_ranges[1] = {1, 1};
    joined_top_manifest.block_instruction_ranges[2] = {2, 2};
    joined_top_manifest.block_instruction_ranges[3] = {3, 3};
    joined_top_manifest.block_predecessors[1] = {0};
    joined_top_manifest.block_predecessors[2] = {0};
    joined_top_manifest.block_predecessors[3] = {1, 2};
    vf::TopAnalysis joined_top = vf::analyze_top(joined_top_proto, joined_top_manifest);
    check(joined_top.known && joined_top.converged && joined_top.uses.size() == 1
              && joined_top.uses[0].reaching.size() == 2,
          "branch join preserves both symbolic VM tops positive");
    check(!vf::top_contracts_closed(joined_top_proto, joined_top_manifest, joined_top),
          "ambiguous open top fails closed negative");
    const std::string first = to_json(valid_fixture());
    const std::string second = to_json(valid_fixture());
    check(first == second, "deterministic JSON repeated serialization");
    check(first.find("\"kind\":\"GenericFor\"") != std::string::npos,
          "deterministic JSON semantic node content");

    Model repeated_target = valid_fixture();
    CaptureContract second_capture = repeated_target.nodes[NodeId(5)].captures[0];
    second_capture.capture = CaptureId(21); second_capture.closure_instruction = 20;
    Node second_closure = fixture_node(9, 1, NodeKind::Closure);
    second_closure.closure_prototype = PrototypeId(1);
    second_closure.closure_instruction = 20; second_closure.closure_destination_register = 3;
    second_closure.target_upvalue_count = 1; second_closure.captures = {second_capture};
    repeated_target.nodes[NodeId(9)] = second_closure;
    repeated_target.nodes[NodeId(1)].children.push_back(NodeId(9));
    ClosureContract second_contract;
    second_contract.owner = PrototypeId(0); second_contract.target = PrototypeId(1);
    second_contract.instruction = 20; second_contract.destination_register = 3;
    second_contract.expected_capture_count = 1; second_contract.captures = {second_capture};
    repeated_target.authoritative_closures.insert(second_contract);
    repeated_target.authoritative_captures.insert(second_capture);
    {
        LocalValueContract value = *repeated_target.nodes[NodeId(0)].local_values.begin();
        repeated_target.nodes[NodeId(0)].local_values.clear();
        repeated_target.authoritative_local_values.clear();
        value.copied_by_captures.insert(CaptureId(21));
        repeated_target.nodes[NodeId(0)].local_values.insert(value);
        repeated_target.authoritative_local_values.insert(value);
    }
    check(verify(repeated_target).ok(), "repeated child prototype closure sites positive");

    Model upvalue_capture = valid_fixture();
    upvalue_capture.authoritative_upvalue_count = 1;
    upvalue_capture.nodes[NodeId(0)].upvalue_count = 1;
    CaptureContract inherited = upvalue_capture.nodes[NodeId(5)].captures[0];
    inherited.mode = CaptureMode::Upvalue; inherited.source = 0;
    inherited.source_origins.clear(); inherited.parent_upvalue_slot = 0;
    upvalue_capture.nodes[NodeId(5)].captures = {inherited};
    upvalue_capture.authoritative_captures = {inherited};
    ClosureContract inherited_closure = *upvalue_capture.authoritative_closures.begin();
    inherited_closure.captures = {inherited};
    upvalue_capture.authoritative_closures = {inherited_closure};
    {
        LocalValueContract value = *upvalue_capture.nodes[NodeId(0)].local_values.begin();
        upvalue_capture.nodes[NodeId(0)].local_values.clear();
        upvalue_capture.authoritative_local_values.clear();
        value.copied_by_captures.clear();
        upvalue_capture.nodes[NodeId(0)].local_values.insert(value);
        upvalue_capture.authoritative_local_values.insert(value);
    }
    check(verify(upvalue_capture).ok(), "parent upvalue capture positive");

    Model reference_capture = valid_fixture();
    CaptureContract reference = reference_capture.nodes[NodeId(5)].captures[0];
    reference.mode = CaptureMode::Reference;
    reference.reference_cell_register = reference.source;
    reference_capture.nodes[NodeId(5)].captures = {reference};
    reference_capture.authoritative_captures = {reference};
    ClosureContract reference_closure = *reference_capture.authoritative_closures.begin();
    reference_closure.captures = {reference};
    reference_capture.authoritative_closures = {reference_closure};
    {
        LocalValueContract value = *reference_capture.nodes[NodeId(0)].local_values.begin();
        reference_capture.nodes[NodeId(0)].local_values.clear();
        reference_capture.authoritative_local_values.clear();
        value.copied_by_captures.clear();
        value.shared_by_captures.insert(CaptureId(11));
        reference_capture.nodes[NodeId(0)].local_values.insert(value);
        reference_capture.authoritative_local_values.insert(value);
    }
    check(verify(reference_capture).ok(), "reference capture shared-cell identity positive");

    Model missing_capture = valid_fixture();
    missing_capture.nodes[NodeId(5)].captures.clear();
    check(verify(missing_capture).has("SIR_PROTOTYPE_CAPTURE"),
          "capture count mismatch negative");
    Model bad_register = valid_fixture();
    bad_register.nodes[NodeId(5)].captures[0].source = 4;
    check(verify(bad_register).has("SIR_PROTOTYPE_CAPTURE"),
          "capture register range negative");
    Model bad_mode = valid_fixture();
    bad_mode.nodes[NodeId(5)].captures[0].mode = (CaptureMode)3;
    check(verify(bad_mode).has("SIR_PROTOTYPE_CAPTURE"),
          "capture mode negative");
    Model missing_capture_origin = valid_fixture();
    missing_capture_origin.nodes[NodeId(5)].captures[0].source_origins.clear();
    check(verify(missing_capture_origin).has("SIR_PROTOTYPE_CAPTURE"),
          "value capture missing reaching value negative");
    Model bad_reference_cell = reference_capture;
    bad_reference_cell.nodes[NodeId(5)].captures[0].reference_cell_register = 1;
    check(verify(bad_reference_cell).has("SIR_PROTOTYPE_CAPTURE"),
          "reference capture wrong shared-cell identity negative");
    Model bad_parent_upvalue = upvalue_capture;
    bad_parent_upvalue.nodes[NodeId(5)].captures[0].source = 1;
    check(verify(bad_parent_upvalue).has("SIR_PROTOTYPE_CAPTURE"),
          "parent upvalue range negative");
    Model wrong_upvalue_declaration = valid_fixture();
    wrong_upvalue_declaration.nodes[NodeId(0)].upvalue_count = 1;
    check(verify(wrong_upvalue_declaration).has("SIR_PROTOTYPE_CAPTURE"),
          "function upvalue declaration negative");

    Model two_exit_targets = valid_fixture();
    const Exit second_target{BlockId(1), BlockId(3), ExitKind::Normal};
    two_exit_targets.nodes[NodeId(2)].loop_exits.insert(second_target);
    two_exit_targets.authoritative_loops[LoopId(0)].exits.insert(second_target);
    check(verify(two_exit_targets).ok(), "one source with two loop-exit targets positive");

    Model ambiguous_exit = valid_fixture();
    const Exit conflicting_meaning{BlockId(1), BlockId(2), ExitKind::Break};
    ambiguous_exit.nodes[NodeId(2)].loop_exits.insert(conflicting_meaning);
    ambiguous_exit.authoritative_loops[LoopId(0)].exits.insert(conflicting_meaning);
    check(verify(ambiguous_exit).has("SIR_EXIT_COVERAGE"),
          "same loop-exit edge with two meanings negative");

    Model branch_control = valid_fixture();
    const Edge old_sequence{BlockId(0), BlockId(1), EdgeKind::Sequence};
    branch_control.cfg_edges.erase(old_sequence);
    branch_control.nodes[NodeId(7)].control_edges.clear();
    branch_control.nodes[NodeId(7)].kind = NodeKind::If;
    const Edge true_arm{BlockId(0), BlockId(1), EdgeKind::BranchTrue};
    const Edge false_arm{BlockId(0), BlockId(2), EdgeKind::BranchFalse};
    branch_control.cfg_edges.insert(true_arm); branch_control.cfg_edges.insert(false_arm);
    const Edge branch_fixture_backedge{BlockId(1), BlockId(0), EdgeKind::LoopBack};
    branch_control.cfg_edges.erase(branch_fixture_backedge);
    branch_control.nodes[NodeId(8)].control_edges.erase(branch_fixture_backedge);
    branch_control.nodes[NodeId(7)].control_edges = {true_arm, false_arm};
    branch_control.nodes[NodeId(7)].branch_true_target = BlockId(1);
    branch_control.nodes[NodeId(7)].branch_false_target = BlockId(2);
    branch_control.nodes[NodeId(7)].branch_join = BlockId(2);
    branch_control.nodes[NodeId(7)].branch_role = BranchRole::Region;
    branch_control.nodes[NodeId(7)].branch_true_blocks = {BlockId(1)};
    BranchContract fixture_branch;
    fixture_branch.source = BlockId(0); fixture_branch.true_target = BlockId(1);
    fixture_branch.false_target = BlockId(2); fixture_branch.join = BlockId(2);
    fixture_branch.role = BranchRole::Region; fixture_branch.true_blocks = {BlockId(1)};
    branch_control.authoritative_branches = {fixture_branch};
    check(verify(branch_control).ok(), "semantic branch edge ownership positive");
    check(verify(branch_control).ok(), "shared-entry guarded branch positive");

    Model missing_shared_entry_body = branch_control;
    missing_shared_entry_body.nodes[NodeId(7)].branch_true_blocks.clear();
    BranchContract missing_body_contract = fixture_branch;
    missing_body_contract.true_blocks.clear();
    missing_shared_entry_body.authoritative_branches = {missing_body_contract};
    check(verify(missing_shared_entry_body).has("SIR_EDGE_COVERAGE"),
          "shared-entry branch missing target body negative");

    Model escaping_shared_entry_body = branch_control;
    const Edge body_to_join{BlockId(1), BlockId(2), EdgeKind::LoopExit};
    const Edge body_to_source{BlockId(1), BlockId(0), EdgeKind::Unconditional};
    escaping_shared_entry_body.cfg_edges.erase(body_to_join);
    escaping_shared_entry_body.cfg_edges.insert(body_to_source);
    escaping_shared_entry_body.nodes[NodeId(8)].control_edges.erase(body_to_join);
    escaping_shared_entry_body.nodes[NodeId(8)].control_edges.insert(body_to_source);
    check(verify(escaping_shared_entry_body).has("SIR_EDGE_COVERAGE"),
          "shared-entry branch escaping its body negative");

    Model overlapping_region = branch_control;
    overlapping_region.nodes[NodeId(7)].branch_false_blocks = {BlockId(1)};
    BranchContract overlapping_contract = fixture_branch;
    overlapping_contract.false_blocks = {BlockId(1)};
    overlapping_region.authoritative_branches = {overlapping_contract};
    check(verify(overlapping_region).has("SIR_EDGE_COVERAGE"),
          "overlapping semantic branch arms negative");

    Model loop_condition = branch_control;
    loop_condition.nodes[NodeId(7)].kind = NodeKind::LoopCondition;
    loop_condition.nodes[NodeId(7)].branch_join = BlockId();
    loop_condition.nodes[NodeId(7)].branch_role = BranchRole::LoopCondition;
    loop_condition.nodes[NodeId(7)].branch_true_blocks.clear();
    loop_condition.nodes[NodeId(7)].control_loop = LoopId(0);
    BranchContract loop_condition_contract;
    loop_condition_contract.source = BlockId(0);
    loop_condition_contract.true_target = BlockId(1);
    loop_condition_contract.false_target = BlockId(2);
    loop_condition_contract.role = BranchRole::LoopCondition;
    loop_condition_contract.loop = LoopId(0);
    loop_condition.authoritative_branches = {loop_condition_contract};
    check(verify(loop_condition).ok(), "loop condition branch contract positive");

    Model bad_loop_condition = loop_condition;
    const Edge old_false_arm{BlockId(0), BlockId(2), EdgeKind::BranchFalse};
    const Edge inside_false_arm{BlockId(0), BlockId(0), EdgeKind::BranchFalse};
    bad_loop_condition.cfg_edges.erase(old_false_arm);
    bad_loop_condition.cfg_edges.insert(inside_false_arm);
    bad_loop_condition.nodes[NodeId(7)].control_edges.erase(old_false_arm);
    bad_loop_condition.nodes[NodeId(7)].control_edges.insert(inside_false_arm);
    bad_loop_condition.nodes[NodeId(7)].branch_false_target = BlockId(0);
    BranchContract bad_loop_condition_contract = loop_condition_contract;
    bad_loop_condition_contract.false_target = BlockId(0);
    bad_loop_condition.authoritative_branches = {bad_loop_condition_contract};
    check(verify(bad_loop_condition).has("SIR_EDGE_COVERAGE"),
          "loop condition with both targets inside negative");

    Model redundant_predicate = valid_fixture();
    redundant_predicate.nodes[NodeId(7)].kind = NodeKind::RedundantPredicate;
    redundant_predicate.nodes[NodeId(7)].branch_true_target = BlockId(1);
    redundant_predicate.nodes[NodeId(7)].branch_false_target = BlockId(1);
    redundant_predicate.nodes[NodeId(7)].branch_join = BlockId(1);
    redundant_predicate.nodes[NodeId(7)].branch_role = BranchRole::Redundant;
    BranchContract redundant_contract;
    redundant_contract.source = BlockId(0);
    redundant_contract.true_target = BlockId(1);
    redundant_contract.false_target = BlockId(1);
    redundant_contract.join = BlockId(1);
    redundant_contract.role = BranchRole::Redundant;
    redundant_predicate.authoritative_branches = {redundant_contract};
    check(verify(redundant_predicate).ok(), "redundant predicate contract positive");

    Model bad_redundant_predicate = redundant_predicate;
    bad_redundant_predicate.nodes[NodeId(7)].branch_true_blocks = {BlockId(1)};
    redundant_contract.true_blocks = {BlockId(1)};
    bad_redundant_predicate.authoritative_branches = {redundant_contract};
    check(verify(bad_redundant_predicate).has("SIR_EDGE_COVERAGE"),
          "redundant predicate with semantic arm negative");

    Model unresolved_branch = branch_control;
    unresolved_branch.nodes[NodeId(7)].kind = NodeKind::UnresolvedBranch;
    unresolved_branch.nodes[NodeId(7)].branch_join = BlockId();
    unresolved_branch.nodes[NodeId(7)].branch_role = BranchRole::Unresolved;
    unresolved_branch.nodes[NodeId(7)].branch_false_blocks = {BlockId(1)};
    BranchContract unresolved_contract = fixture_branch;
    unresolved_contract.join = BlockId();
    unresolved_contract.role = BranchRole::Unresolved;
    unresolved_contract.false_blocks = {BlockId(1)};
    unresolved_branch.authoritative_branches = {unresolved_contract};
    check(verify(unresolved_branch).ok(), "unresolved branch preserves exact contract positive");

    Model mismatched_unresolved_branch = unresolved_branch;
    mismatched_unresolved_branch.nodes[NodeId(7)].branch_false_blocks.clear();
    check(verify(mismatched_unresolved_branch).has("SIR_EDGE_COVERAGE"),
          "unresolved branch contract mismatch negative");

    Model preserved_shared = unresolved_branch;
    preserved_shared.nodes[NodeId(7)].kind = NodeKind::PreservedSharedBranch;
    preserved_shared.nodes[NodeId(7)].branch_role = BranchRole::PreservedShared;
    BranchContract preserved_shared_contract = *preserved_shared.authoritative_branches.begin();
    preserved_shared_contract.role = BranchRole::PreservedShared;
    preserved_shared.authoritative_branches = {preserved_shared_contract};
    check(verify(preserved_shared).ok(), "preserved shared branch positive");
    Model false_shared = preserved_shared;
    false_shared.nodes[NodeId(7)].branch_false_blocks.clear();
    BranchContract false_shared_contract = preserved_shared_contract;
    false_shared_contract.false_blocks.clear();
    false_shared.authoritative_branches = {false_shared_contract};
    check(verify(false_shared).has("SIR_EDGE_COVERAGE"),
          "preserved shared branch without overlap negative");

    Model preserved_cyclic = preserved_shared;
    preserved_cyclic.nodes[NodeId(7)].kind = NodeKind::PreservedCyclicBranch;
    preserved_cyclic.nodes[NodeId(7)].branch_role = BranchRole::PreservedCyclic;
    preserved_cyclic.nodes[NodeId(7)].branch_true_blocks.insert(BlockId(0));
    BranchContract preserved_cyclic_contract = preserved_shared_contract;
    preserved_cyclic_contract.role = BranchRole::PreservedCyclic;
    preserved_cyclic_contract.true_blocks.insert(BlockId(0));
    preserved_cyclic.authoritative_branches = {preserved_cyclic_contract};
    check(verify(preserved_cyclic).ok(), "preserved cyclic branch positive");
    Model false_cyclic = preserved_cyclic;
    false_cyclic.nodes[NodeId(7)].branch_true_blocks.erase(BlockId(0));
    BranchContract false_cyclic_contract = preserved_cyclic_contract;
    false_cyclic_contract.true_blocks.erase(BlockId(0));
    false_cyclic.authoritative_branches = {false_cyclic_contract};
    check(verify(false_cyclic).has("SIR_EDGE_COVERAGE"),
          "preserved cyclic branch without source cycle negative");

    Model preserved_escaping = unresolved_branch;
    preserved_escaping.nodes[NodeId(7)].kind = NodeKind::PreservedEscapingBranch;
    preserved_escaping.nodes[NodeId(7)].branch_role = BranchRole::PreservedEscaping;
    preserved_escaping.nodes[NodeId(7)].branch_false_blocks.clear();
    preserved_escaping.nodes[NodeId(7)].branch_true_escapes_region = true;
    BranchContract preserved_escaping_contract = *preserved_escaping.authoritative_branches.begin();
    preserved_escaping_contract.role = BranchRole::PreservedEscaping;
    preserved_escaping_contract.false_blocks.clear();
    preserved_escaping_contract.true_escapes_region = true;
    preserved_escaping.authoritative_branches = {preserved_escaping_contract};
    check(verify(preserved_escaping).ok(), "preserved escaping branch positive");
    Model false_escaping = preserved_escaping;
    false_escaping.nodes[NodeId(7)].branch_true_escapes_region = false;
    BranchContract false_escaping_contract = preserved_escaping_contract;
    false_escaping_contract.true_escapes_region = false;
    false_escaping.authoritative_branches = {false_escaping_contract};
    check(verify(false_escaping).has("SIR_EDGE_COVERAGE"),
          "preserved escaping branch without escape evidence negative");

    Model virtual_exit_branch = virtual_exit_branch_fixture();
    check(verify(virtual_exit_branch).ok(), "virtual-exit terminal branch positive");
    Model escaping_virtual_arm = virtual_exit_branch_fixture();
    const Edge replaced_return{BlockId(1), BlockId(), EdgeKind::Return};
    const Edge escaping_edge{BlockId(1), BlockId(2), EdgeKind::Sequence};
    escaping_virtual_arm.cfg_edges.erase(replaced_return);
    escaping_virtual_arm.cfg_edges.insert(escaping_edge);
    escaping_virtual_arm.nodes[NodeId(6)].kind = NodeKind::Fallthrough;
    escaping_virtual_arm.nodes[NodeId(6)].control_edges = {escaping_edge};
    escaping_virtual_arm.nodes[NodeId(6)].control_opcode = "MOVE";
    check(verify(escaping_virtual_arm).has("SIR_EDGE_COVERAGE"),
          "virtual-exit arm escaping into sibling negative");

    Model short_circuit = short_circuit_branch_fixture();
    check(verify(short_circuit).ok(), "short-circuit shared-true chain positive");
    Model wrong_short_circuit_mode = short_circuit_branch_fixture();
    wrong_short_circuit_mode.nodes[NodeId(5)].branch_role =
        BranchRole::ShortCircuitSharedFalse;
    std::set<BranchContract> wrong_mode_contracts;
    for (BranchContract contract : wrong_short_circuit_mode.authoritative_branches) {
        if (contract.source == BlockId(0))
            contract.role = BranchRole::ShortCircuitSharedFalse;
        wrong_mode_contracts.insert(contract);
    }
    wrong_short_circuit_mode.authoritative_branches = std::move(wrong_mode_contracts);
    check(verify(wrong_short_circuit_mode).has("SIR_EDGE_COVERAGE"),
          "short-circuit child outcome mismatch negative");
    Model wrong_short_circuit_next = short_circuit_branch_fixture();
    wrong_short_circuit_next.nodes[NodeId(5)].branch_chain_next = BlockId(3);
    std::set<BranchContract> wrong_next_contracts;
    for (BranchContract contract : wrong_short_circuit_next.authoritative_branches) {
        if (contract.source == BlockId(0)) contract.chain_next = BlockId(3);
        wrong_next_contracts.insert(contract);
    }
    wrong_short_circuit_next.authoritative_branches = std::move(wrong_next_contracts);
    check(verify(wrong_short_circuit_next).has("SIR_EDGE_COVERAGE"),
          "short-circuit next predicate mismatch negative");

    check(verify(loop_action_branch_fixture(BranchRole::ConditionalBreak)).ok(),
          "conditional break loop contract positive");
    check(verify(loop_action_branch_fixture(BranchRole::ConditionalContinue)).ok(),
          "conditional continue loop contract positive");
    check(verify(loop_action_branch_fixture(BranchRole::ConditionalBreakContinue)).ok(),
          "conditional break-continue loop contract positive");
    Model mixed_as_break = loop_action_branch_fixture(
        BranchRole::ConditionalBreakContinue);
    mixed_as_break.nodes[NodeId(10)].kind = NodeKind::ConditionalBreak;
    mixed_as_break.nodes[NodeId(10)].branch_role = BranchRole::ConditionalBreak;
    BranchContract mixed_as_break_contract = *mixed_as_break.authoritative_branches.begin();
    mixed_as_break_contract.role = BranchRole::ConditionalBreak;
    mixed_as_break.authoritative_branches = {mixed_as_break_contract};
    check(verify(mixed_as_break).has("SIR_EDGE_COVERAGE"),
          "break-continue dispatch mislabeled as break negative");

    Model duplicate_edge = valid_fixture();
    Node duplicate_control = fixture_node(9, 2, NodeKind::UnresolvedControl);
    duplicate_control.control_source = BlockId(0);
    duplicate_control.control_edges = {old_sequence};
    duplicate_control.control_instruction = 0; duplicate_control.control_opcode = "JUMP";
    duplicate_edge.nodes[NodeId(9)] = duplicate_control;
    duplicate_edge.nodes[NodeId(2)].children.push_back(NodeId(9));
    check(verify(duplicate_edge).has("SIR_EDGE_COVERAGE"),
          "duplicate semantic edge owner negative");
    Model wrong_edge_source = valid_fixture();
    wrong_edge_source.nodes[NodeId(7)].control_source = BlockId(1);
    check(verify(wrong_edge_source).has("SIR_EDGE_COVERAGE"),
          "wrong semantic edge source negative");
    Model malformed_return = valid_fixture();
    malformed_return.nodes[NodeId(3)].control_edges = {
        Edge{BlockId(2), BlockId(0), EdgeKind::Return}
    };
    check(verify(malformed_return).has("SIR_EDGE_COVERAGE"),
          "return with target negative");

    auto unconditional_fixture = [&]() {
        Model model = valid_fixture();
        const Edge sequence{BlockId(0), BlockId(1), EdgeKind::Sequence};
        const Edge unconditional{BlockId(0), BlockId(1), EdgeKind::Unconditional};
        model.cfg_edges.erase(sequence); model.cfg_edges.insert(unconditional);
        Node& control = model.nodes[NodeId(7)];
        control.control_edges = {unconditional}; control.control_opcode = "JUMP";
        control.control_target_predecessor_count = 2;
        control.control_source_dominates_target = true;
        return model;
    };
    Model loop_entry = unconditional_fixture();
    loop_entry.authoritative_loops[LoopId(0)].prep = BlockId(0);
    loop_entry.nodes[NodeId(7)].kind = NodeKind::LoopEntry;
    loop_entry.nodes[NodeId(7)].control_loop = LoopId(0);
    loop_entry.nodes[NodeId(7)].control_opcode = "FORGPREP";
    check(verify(loop_entry).ok(), "generic loop entry positive");
    Model bad_loop_entry = loop_entry;
    bad_loop_entry.nodes[NodeId(7)].control_loop = LoopId(9);
    check(verify(bad_loop_entry).has("SIR_EDGE_COVERAGE"),
          "generic loop entry owner negative");

    Model boolean_skip = unconditional_fixture();
    boolean_skip.nodes[NodeId(7)].kind = NodeKind::BooleanSkipTransfer;
    boolean_skip.nodes[NodeId(7)].control_opcode = "LOADB";
    check(verify(boolean_skip).ok(), "LOADB boolean skip positive");
    Model bad_boolean_skip = boolean_skip;
    bad_boolean_skip.nodes[NodeId(7)].control_opcode = "JUMP";
    check(verify(bad_boolean_skip).has("SIR_EDGE_COVERAGE"),
          "LOADB boolean skip opcode negative");

    Model linear_transfer = unconditional_fixture();
    linear_transfer.nodes[NodeId(7)].kind = NodeKind::LinearTransfer;
    linear_transfer.nodes[NodeId(7)].control_target_predecessor_count = 1;
    check(verify(linear_transfer).ok(), "linear unconditional transfer positive");
    Model bad_linear_transfer = linear_transfer;
    bad_linear_transfer.nodes[NodeId(7)].control_source_dominates_target = false;
    check(verify(bad_linear_transfer).has("SIR_EDGE_COVERAGE"),
          "linear transfer dominance negative");

    Model join_transfer = unconditional_fixture();
    join_transfer.nodes[NodeId(7)].kind = NodeKind::JoinTransfer;
    check(verify(join_transfer).ok(), "join transfer positive");
    Model bad_join_transfer = join_transfer;
    bad_join_transfer.nodes[NodeId(7)].control_target_predecessor_count = 1;
    check(verify(bad_join_transfer).has("SIR_EDGE_COVERAGE"),
          "join predecessor count negative");

    Model loop_latch = valid_fixture();
    const Edge loop_exit_edge{BlockId(1), BlockId(2), EdgeKind::LoopExit};
    loop_latch.cfg_edges.erase(loop_exit_edge);
    loop_latch.nodes[NodeId(8)].control_edges.erase(loop_exit_edge);
    loop_latch.nodes[NodeId(8)].kind = NodeKind::LoopLatch;
    loop_latch.nodes[NodeId(8)].control_loop = LoopId(0);
    check(verify(loop_latch).ok(), "natural loop latch positive");
    Model bad_loop_latch = loop_latch;
    bad_loop_latch.nodes[NodeId(8)].control_loop = LoopId(9);
    check(verify(bad_loop_latch).has("SIR_EDGE_COVERAGE"),
          "natural loop latch owner negative");

    Model loop_exit_transfer = valid_fixture();
    const Edge loop_back_edge{BlockId(1), BlockId(0), EdgeKind::LoopBack};
    loop_exit_transfer.cfg_edges.erase(loop_back_edge);
    loop_exit_transfer.nodes[NodeId(8)].control_edges.erase(loop_back_edge);
    loop_exit_transfer.nodes[NodeId(8)].kind = NodeKind::LoopExitTransfer;
    loop_exit_transfer.nodes[NodeId(8)].control_loop = LoopId(0);
    check(verify(loop_exit_transfer).ok(), "unstructured loop exit transfer positive");
    Model bad_loop_exit = loop_exit_transfer;
    bad_loop_exit.cfg_edges.erase(loop_exit_edge);
    bad_loop_exit.nodes[NodeId(8)].control_edges.erase(loop_exit_edge);
    const Edge inside_exit{BlockId(1), BlockId(0), EdgeKind::LoopExit};
    bad_loop_exit.cfg_edges.insert(inside_exit);
    bad_loop_exit.nodes[NodeId(8)].control_edges.insert(inside_exit);
    check(verify(bad_loop_exit).has("SIR_EDGE_COVERAGE"),
          "loop exit target inside body negative");
    return result;
}

} // namespace sir
