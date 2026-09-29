// semantic_ir/json.h -- deterministic, dependency-free debug serialization.
#pragma once
#include "model.h"
#include "expression_semantics.h"
#include "statement_selection.h"
#include <sstream>

namespace sir {

inline std::string json_escape(const std::string& value) {
    std::string out;
    for (unsigned char character : value) {
        switch (character) {
            case '\\': out += "\\\\"; break; case '"': out += "\\\""; break;
            case '\n': out += "\\n"; break; case '\r': out += "\\r"; break;
            case '\t': out += "\\t"; break;
            default:
                if (character < 0x20) {
                    char buffer[7]; std::snprintf(buffer, sizeof buffer, "\\u%04x", character);
                    out += buffer;
                } else out += (char)character;
        }
    }
    return out;
}

template<class IdType>
inline void json_ids(std::ostringstream& out, const std::set<IdType>& values) {
    out << '['; bool first = true;
    for (IdType value : values) { if (!first) out << ','; first = false; out << value.value; }
    out << ']';
}

template<class IdType>
inline void json_id_vector(std::ostringstream& out, const std::vector<IdType>& values) {
    out << '[';
    for (size_t index = 0; index < values.size(); ++index) {
        if (index) out << ',';
        out << values[index].value;
    }
    out << ']';
}

inline void json_exits(std::ostringstream& out, const std::set<Exit>& exits) {
    out << '['; bool first = true;
    for (const Exit& exit_plan : exits) {
        if (!first) out << ',';
        first = false;
        out << "{\"source\":" << exit_plan.source.value << ",\"target\":"
            << exit_plan.target.value << ",\"kind\":" << (int)exit_plan.kind << '}';
    }
    out << ']';
}

inline void json_edges(std::ostringstream& out, const std::set<Edge>& edges) {
    out << '['; bool first = true;
    for (const Edge& edge : edges) {
        if (!first) out << ',';
        first = false;
        out << "{\"source\":" << edge.source.value << ",\"target\":"
            << edge.target.value << ",\"kind\":" << (int)edge.kind << '}';
    }
    out << ']';
}

inline void json_value_origins(std::ostringstream& out,
                               const std::set<ValueOriginContract>& origins) {
    out << '['; bool first = true;
    for (const ValueOriginContract& origin : origins) {
        if (!first) out << ',';
        first = false;
        out << "{\"kind\":" << origin.kind << ",\"instruction\":"
            << origin.instruction << ",\"reg\":" << origin.reg << '}';
    }
    out << ']';
}

inline void json_predicate_test(std::ostringstream& out,
                                const PredicateTestContract& test) {
    out << "{\"owner\":" << test.owner.value << ",\"block\":" << test.block.value
        << ",\"instruction\":" << test.instruction << ",\"kind\":" << (int)test.kind
        << ",\"opcode\":\"" << json_escape(test.opcode) << "\",\"operands\":[";
    for (size_t index = 0; index < test.operands.size(); ++index) {
        if (index) out << ',';
        json_value_origins(out, test.operands[index]);
    }
    out << "],\"constant_index\":" << test.constant_index
        << ",\"constant_kind\":" << test.constant_kind
        << ",\"constant_text\":\"" << json_escape(test.constant_text)
        << "\",\"branch_on_true\":" << (test.branch_on_true ? "true" : "false")
        << ",\"raw_a\":" << test.raw_a << ",\"raw_aux\":" << test.raw_aux << '}';
}

inline void json_predicate_expression(std::ostringstream& out,
                                      const PredicateExpressionContract& expression) {
    out << "{\"owner\":" << expression.owner.value
        << ",\"block\":" << expression.block.value
        << ",\"root\":" << expression.root << ",\"nodes\":[";
    for (size_t index = 0; index < expression.nodes.size(); ++index) {
        if (index) out << ',';
        const PredicateExpressionNodeContract& node = expression.nodes[index];
        out << "{\"kind\":" << (int)node.kind << ",\"left\":" << node.left
            << ",\"right\":" << node.right << ",\"test\":";
        json_predicate_test(out, node.test);
        out << '}';
    }
    out << "]}";
}

inline void json_captures(std::ostringstream& out,
                          const std::vector<CaptureContract>& captures) {
    out << '[';
    for (size_t index = 0; index < captures.size(); ++index) {
        if (index) out << ',';
        const CaptureContract& capture = captures[index];
        out << "{\"id\":" << capture.capture.value << ",\"owner\":"
            << capture.owner.value << ",\"target\":" << capture.target.value
            << ",\"closure_instruction\":" << capture.closure_instruction
            << ",\"slot\":" << capture.slot << ",\"mode\":" << (int)capture.mode
            << ",\"source\":" << capture.source << ",\"source_origins\":";
        json_value_origins(out, capture.source_origins);
        out << ",\"reference_cell_register\":" << capture.reference_cell_register
            << ",\"parent_upvalue_slot\":" << capture.parent_upvalue_slot << '}';
    }
    out << ']';
}

inline std::string to_json(const Model& model) {
    std::ostringstream out;
    out << "{\"schema\":1,\"prototype\":" << model.prototype.value
        << ",\"root\":" << model.root.value << ",\"renderer_ready\":"
        << (model.renderer_ready ? "true" : "false") << ",\"reachable_blocks\":";
    json_ids(out, model.reachable_blocks);
    out << ",\"observable_effects\":"; json_ids(out, model.observable_effects);
    out << ",\"effect_order\":"; json_id_vector(out, model.semantic_effect_order);
    out << ",\"nodes\":[";
    bool first_node = true;
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (!first_node) out << ',';
        first_node = false;
        out << "{\"id\":" << node.id.value << ",\"parent\":" << node.parent.value
            << ",\"kind\":\"" << node_kind_name(node.kind) << "\",\"children\":";
        json_id_vector(out, node.children);
        out << ",\"blocks\":"; json_ids(out, node.blocks);
        out << ",\"effects\":"; json_id_vector(out, node.effects);
        out << ",\"control_source\":" << node.control_source.value
            << ",\"control_edges\":"; json_edges(out, node.control_edges);
        out << ",\"control_instruction\":" << node.control_instruction
            << ",\"control_opcode\":\"" << json_escape(node.control_opcode) << '"'
            << ",\"control_target_predecessor_count\":"
            << node.control_target_predecessor_count
            << ",\"control_source_dominates_target\":"
            << (node.control_source_dominates_target ? "true" : "false")
            << ",\"control_loop\":" << node.control_loop.value;
        out << ",\"has_predicate_expression\":"
            << (node.has_predicate_expression ? "true" : "false")
            << ",\"predicate_expression\":";
        json_predicate_expression(out, node.predicate_expression);
        out << ",\"branch_true_target\":" << node.branch_true_target.value
            << ",\"branch_false_target\":" << node.branch_false_target.value
            << ",\"branch_join\":" << node.branch_join.value
            << ",\"branch_virtual_exit_join\":"
            << (node.branch_virtual_exit_join ? "true" : "false")
            << ",\"branch_chain_next\":" << node.branch_chain_next.value
            << ",\"branch_chain_shared_target\":"
            << node.branch_chain_shared_target.value
            << ",\"branch_true_escapes_region\":"
            << (node.branch_true_escapes_region ? "true" : "false")
            << ",\"branch_false_escapes_region\":"
            << (node.branch_false_escapes_region ? "true" : "false")
            << ",\"branch_true_has_terminal\":"
            << (node.branch_true_has_terminal ? "true" : "false")
            << ",\"branch_false_has_terminal\":"
            << (node.branch_false_has_terminal ? "true" : "false")
            << ",\"branch_role\":" << (int)node.branch_role
            << ",\"branch_true_blocks\":";
        json_ids(out, node.branch_true_blocks);
        out << ",\"branch_false_blocks\":"; json_ids(out, node.branch_false_blocks);
        out << ",\"loop\":" << node.loop.value << ",\"loop_parent\":"
            << node.loop_parent.value << ",\"loop_children\":";
        json_ids(out, node.loop_children);
        out << ",\"loop_body\":"; json_ids(out, node.loop_body);
        out << ",\"loop_latches\":"; json_ids(out, node.loop_latches);
        out << ",\"loop_canonical_latch\":" << node.loop_canonical_latch.value;
        out << ",\"loop_exits\":"; json_exits(out, node.loop_exits);
        out << ",\"prototype\":"
            << node.prototype.value << ",\"closure_prototype\":"
            << node.closure_prototype.value << ",\"maximum_register_count\":"
            << node.maximum_register_count << ",\"upvalue_count\":"
            << node.upvalue_count << ",\"closure_instruction\":"
            << node.closure_instruction << ",\"closure_destination_register\":"
            << node.closure_destination_register << ",\"target_upvalue_count\":"
            << node.target_upvalue_count << ",\"captures\":";
        json_captures(out, node.captures);
        out << ",\"parameter_count\":"
            << node.parameter_count << ",\"accepts_varargs\":"
            << (node.accepts_varargs ? "true" : "false")
            << ",\"fixed_result_count\":" << node.fixed_result_count
            << ",\"returns_multiple\":" << (node.returns_multiple ? "true" : "false")
            << ",\"has_scope_close\":" << (node.has_scope_close ? "true" : "false")
            << ",\"scope_close_instruction\":" << node.scope_close.instruction
            << ",\"scope_close_first_register\":" << node.scope_close.first_register
            << ",\"preserved_opcode\":\""
            << json_escape(node.preserved_opcode) << "\"}";
    }
    out << "],\"loops\":[";
    bool first_loop = true;
    for (const auto& pair : model.authoritative_loops) {
        if (!first_loop) out << ',';
        first_loop = false;
        const AuthoritativeLoop& loop = pair.second;
        out << "{\"id\":" << loop.id.value << ",\"parent\":" << loop.parent.value
            << ",\"prep\":" << loop.prep.value << ",\"children\":";
        json_ids(out, loop.children);
        out << ",\"body\":"; json_ids(out, loop.body);
        out << ",\"latches\":"; json_ids(out, loop.latches);
        out << ",\"exits\":"; json_exits(out, loop.exits); out << '}';
    }
    out << "],\"terminal_numeric_fors\":[";
    bool first_terminal_for = true;
    for (const auto& pair : model.authoritative_terminal_numeric_fors) {
        if (!first_terminal_for) out << ',';
        first_terminal_for = false;
        const TerminalNumericFor& terminal = pair.second;
        out << "{\"prep\":" << terminal.prep.value
            << ",\"body\":" << terminal.body.value
            << ",\"exit\":" << terminal.exit.value
            << ",\"region_blocks\":";
        json_ids(out, terminal.region_blocks);
        out << '}';
    }
    out << "],\"cfg_edges\":"; json_edges(out, model.cfg_edges);
    out << ",\"calls\":[";
    size_t call_index = 0;
    for (const CallContract& call : model.authoritative_calls) {
        if (call_index++) out << ',';
        out << "{\"owner\":" << call.owner.value << ",\"block\":" << call.block.value
            << ",\"instruction\":" << call.instruction
            << ",\"effect_order\":" << call.effect_order
            << ",\"base_register\":" << call.base_register
            << ",\"method_call\":" << (call.method_call ? "true" : "false")
            << ",\"namecall_instruction\":" << call.namecall_instruction
            << ",\"receiver_register\":" << call.receiver_register
            << ",\"argument_first\":" << call.argument_first
            << ",\"argument_count\":" << call.argument_count
            << ",\"explicit_argument_first\":" << call.explicit_argument_first
            << ",\"explicit_argument_count\":" << call.explicit_argument_count
            << ",\"result_first\":" << call.result_first
            << ",\"result_count\":" << call.result_count
            << ",\"callee_origins\":";
        json_value_origins(out, call.callee_origins);
        out << ",\"receiver_origins\":";
        json_value_origins(out, call.receiver_origins);
        out << ",\"fixed_argument_origins\":[";
        for (size_t argument = 0;
             argument < call.fixed_argument_origins.size(); ++argument) {
            if (argument) out << ',';
            json_value_origins(out, call.fixed_argument_origins[argument]);
        }
        out << "],\"open_argument_origin_kind\":"
            << call.open_argument_origin_kind
            << ",\"open_argument_origin_instruction\":"
            << call.open_argument_origin_instruction
            << ",\"open_argument_origin_base\":"
            << call.open_argument_origin_base << '}';
    }
    out << "],\"returns\":[";
    size_t return_index = 0;
    for (const ReturnContract& value : model.authoritative_returns) {
        if (return_index++) out << ',';
        out << "{\"owner\":" << value.owner.value << ",\"block\":" << value.block.value
            << ",\"instruction\":" << value.instruction
            << ",\"effect_order\":" << value.effect_order
            << ",\"first_register\":" << value.first_register
            << ",\"value_count\":" << value.value_count << ",\"fixed_values\":[";
        for (size_t offset = 0; offset < value.fixed_values.size(); ++offset) {
            if (offset) out << ',';
            out << '[';
            bool first_origin = true;
            for (const ValueOriginContract& origin : value.fixed_values[offset]) {
                if (!first_origin) out << ',';
                first_origin = false;
                out << "{\"kind\":" << origin.kind << ",\"instruction\":"
                    << origin.instruction << ",\"reg\":" << origin.reg << '}';
            }
            out << ']';
        }
        out << "],\"open_origin_kind\":" << value.open_origin_kind
            << ",\"open_origin_instruction\":" << value.open_origin_instruction
            << ",\"open_origin_base\":" << value.open_origin_base << '}';
    }
    out << "],\"table_operations\":[";
    size_t table_index = 0;
    for (const TableOperationContract& operation :
         model.authoritative_table_operations) {
        if (table_index++) out << ',';
        out << "{\"owner\":" << operation.owner.value
            << ",\"block\":" << operation.block.value
            << ",\"instruction\":" << operation.instruction
            << ",\"effect_order\":" << operation.effect_order
            << ",\"kind\":" << (int)operation.kind
            << ",\"table_register\":" << operation.table_register
            << ",\"table_origins\":[";
        bool first_origin = true;
        for (const ValueOriginContract& origin : operation.table_origins) {
            if (!first_origin) out << ',';
            first_origin = false;
            out << "{\"kind\":" << origin.kind << ",\"instruction\":"
                << origin.instruction << ",\"reg\":" << origin.reg << '}';
        }
        out << "],\"value_register\":" << operation.value_register
            << ",\"value_origins\":[";
        first_origin = true;
        for (const ValueOriginContract& origin : operation.value_origins) {
            if (!first_origin) out << ',';
            first_origin = false;
            out << "{\"kind\":" << origin.kind << ",\"instruction\":"
                << origin.instruction << ",\"reg\":" << origin.reg << '}';
        }
        out << "],\"key_register\":" << operation.key_register
            << ",\"key_origins\":[";
        first_origin = true;
        for (const ValueOriginContract& origin : operation.key_origins) {
            if (!first_origin) out << ',';
            first_origin = false;
            out << "{\"kind\":" << origin.kind << ",\"instruction\":"
                << origin.instruction << ",\"reg\":" << origin.reg << '}';
        }
        out << "],\"field_name\":\"" << json_escape(operation.field_name)
            << "\",\"numeric_key\":" << operation.numeric_key
            << ",\"list_first_register\":" << operation.list_first_register
            << ",\"list_value_count\":" << operation.list_value_count
            << ",\"list_start_index\":" << operation.list_start_index
            << ",\"list_fixed_values\":[";
        for (size_t value_index = 0;
             value_index < operation.list_fixed_values.size(); ++value_index) {
            if (value_index) out << ',';
            out << '[';
            first_origin = true;
            for (const ValueOriginContract& origin :
                 operation.list_fixed_values[value_index]) {
                if (!first_origin) out << ',';
                first_origin = false;
                out << "{\"kind\":" << origin.kind << ",\"instruction\":"
                    << origin.instruction << ",\"reg\":" << origin.reg << '}';
            }
            out << ']';
        }
        out << "],\"list_open_origin_kind\":"
            << operation.list_open_origin_kind
            << ",\"list_open_origin_instruction\":"
            << operation.list_open_origin_instruction
            << ",\"list_open_origin_base\":" << operation.list_open_origin_base
            << ",\"raw_a\":" << operation.raw_a
            << ",\"raw_b\":" << operation.raw_b
            << ",\"raw_c\":" << operation.raw_c
            << ",\"raw_bx\":" << operation.raw_bx
            << ",\"raw_aux\":" << operation.raw_aux << '}';
    }
    out << "],\"scope_closes\":[";
    size_t scope_index = 0;
    for (const ScopeCloseContract& close : model.authoritative_scope_closes) {
        if (scope_index++) out << ',';
        out << "{\"owner\":" << close.owner.value
            << ",\"block\":" << close.block.value
            << ",\"instruction\":" << close.instruction
            << ",\"first_register\":" << close.first_register << '}';
    }
    out << "],\"local_values\":[";
    size_t local_index = 0;
    for (const LocalValueContract& value : model.authoritative_local_values) {
        if (local_index++) out << ',';
        out << "{\"owner\":" << value.owner.value
            << ",\"identity\":{\"kind\":" << value.identity.kind
            << ",\"instruction\":" << value.identity.instruction
            << ",\"reg\":" << value.identity.reg << "}"
            << ",\"definition_block\":" << value.definition_block.value
            << ",\"declaration_block\":" << value.declaration_block.value
            << ",\"parameter\":" << (value.parameter ? "true" : "false")
            << ",\"uses\":[";
        bool first_use = true;
        for (const LocalUseSite& use : value.uses) {
            if (!first_use) out << ',';
            first_use = false;
            out << "{\"block\":" << use.block.value
                << ",\"instruction\":" << use.instruction << '}';
        }
        out << "],\"lifetimes\":[";
        bool first_lifetime = true;
        for (const LocalBlockLifetime& lifetime : value.lifetimes) {
            if (!first_lifetime) out << ',';
            first_lifetime = false;
            out << "{\"block\":" << lifetime.block.value
                << ",\"first_instruction\":" << lifetime.first_instruction
                << ",\"last_instruction\":" << lifetime.last_instruction
                << ",\"live_in\":" << (lifetime.live_in ? "true" : "false")
                << ",\"live_out\":" << (lifetime.live_out ? "true" : "false")
                << '}';
        }
        out << "],\"copied_by_captures\":";
        json_ids(out, value.copied_by_captures);
        out << ",\"shared_by_captures\":";
        json_ids(out, value.shared_by_captures);
        out << '}';
    }
    out << "],\"value_webs\":[";
    size_t web_index = 0;
    for (const ValueWebContract& web : model.authoritative_value_webs) {
        if (web_index++) out << ',';
        out << "{\"owner\":" << web.owner.value << ",\"id\":" << web.id
            << ",\"reg\":" << web.reg
            << ",\"declaration_block\":" << web.declaration_block.value
            << ",\"members\":";
        json_value_origins(out, web.members);
        out << ",\"uses\":[";
        bool first_use = true;
        for (const LocalUseSite& use : web.uses) {
            if (!first_use) out << ',';
            first_use = false;
            out << "{\"block\":" << use.block.value
                << ",\"instruction\":" << use.instruction << '}';
        }
        out << "],\"merge_uses\":[";
        first_use = true;
        for (const LocalUseSite& use : web.merge_uses) {
            if (!first_use) out << ',';
            first_use = false;
            out << "{\"block\":" << use.block.value
                << ",\"instruction\":" << use.instruction << '}';
        }
        out << "]}";
    }
    out << "],\"value_merges\":[";
    size_t merge_index = 0;
    for (const ValueMergeContract& merge : model.authoritative_value_merges) {
        if (merge_index++) out << ',';
        out << "{\"owner\":" << merge.owner.value
            << ",\"web_id\":" << merge.web_id
            << ",\"block\":" << merge.use.block.value
            << ",\"instruction\":" << merge.use.instruction
            << ",\"reg\":" << merge.reg << ",\"origins\":";
        json_value_origins(out, merge.origins);
        out << ",\"kind\":" << (int)merge.kind
            << ",\"conditional_source\":" << merge.conditional_source.value
            << ",\"loop\":" << merge.loop.value << '}';
    }
    out << "],\"expressions\":[";
    size_t expression_index = 0;
    for (const ExpressionDefinitionContract& expression :
         model.authoritative_expressions) {
        if (expression_index++) out << ',';
        out << "{\"owner\":" << expression.owner.value
            << ",\"block\":" << expression.block.value
            << ",\"identity\":{"
            << "\"kind\":" << expression.identity.kind
            << ",\"instruction\":" << expression.identity.instruction
            << ",\"reg\":" << expression.identity.reg << '}'
            << ",\"kind\":\""
            << json_escape(expressions::kind_name(expression.kind)) << '\"'
            << ",\"opcode\":\"" << json_escape(expression.opcode) << '\"'
            << ",\"operator\":\"" << json_escape(expression.operator_text) << '\"'
            << ",\"operands\":[";
        for (size_t operand = 0; operand < expression.operands.size(); ++operand) {
            if (operand) out << ',';
            json_value_origins(out, expression.operands[operand]);
        }
        out << "],\"result_slot\":" << expression.result_slot
            << ",\"open_result\":" << (expression.open_result ? "true" : "false")
            << ",\"open_operands\":" << (expression.open_operands ? "true" : "false")
            << ",\"constant_index\":" << expression.constant_index
            << ",\"constant_kind\":" << expression.constant_kind
            << ",\"constant_text\":\"" << json_escape(expression.constant_text) << '\"'
            << ",\"name\":\"" << json_escape(expression.name) << '\"'
            << ",\"upvalue_slot\":" << expression.upvalue_slot
            << ",\"closure_target\":" << expression.closure_target
            << ",\"compiler_scaffolding\":"
            << (expression.compiler_scaffolding ? "true" : "false")
            << ",\"raw\":{\"a\":" << expression.raw_a
            << ",\"b\":" << expression.raw_b
            << ",\"c\":" << expression.raw_c
            << ",\"bx\":" << expression.raw_bx
            << ",\"aux\":" << expression.raw_aux << "}}";
    }
    out << "],\"definition_emissions\":[";
    size_t emission_index = 0;
    for (const DefinitionEmissionContract& emission :
         model.authoritative_definition_emissions) {
        if (emission_index++) out << ',';
        out << "{\"owner\":" << emission.owner.value
            << ",\"identity\":{\"kind\":" << emission.identity.kind
            << ",\"instruction\":" << emission.identity.instruction
            << ",\"reg\":" << emission.identity.reg << '}'
            << ",\"disposition\":\""
            << selection::disposition_name(emission.disposition) << '\"'
            << ",\"group_leader\":{\"kind\":" << emission.group_leader.kind
            << ",\"instruction\":" << emission.group_leader.instruction
            << ",\"reg\":" << emission.group_leader.reg << '}'
            << ",\"emits_statement\":"
            << (emission.emits_statement ? "true" : "false")
            << ",\"inline_use\":{\"block\":" << emission.inline_use.block.value
            << ",\"instruction\":" << emission.inline_use.instruction << '}'
            << ",\"web_id\":" << emission.web_id
            << ",\"single_use\":" << (emission.single_use ? "true" : "false")
            << ",\"single_origin_at_use\":"
            << (emission.single_origin_at_use ? "true" : "false")
            << ",\"dominance_proven\":"
            << (emission.dominance_proven ? "true" : "false")
            << ",\"capture_free\":" << (emission.capture_free ? "true" : "false")
            << '}';
    }
    out << "],\"predicate_expressions\":[";
    size_t predicate_expression_index = 0;
    for (const PredicateExpressionContract& expression :
         model.authoritative_predicate_expressions) {
        if (predicate_expression_index++) out << ',';
        json_predicate_expression(out, expression);
    }
    out << "],\"ownership_conflicts\":[";
    for (size_t index = 0; index < model.ownership_conflicts.size(); ++index) {
        if (index) out << ',';
        out << '"' << json_escape(model.ownership_conflicts[index]) << '"';
    }
    out << "]}";
    return out.str();
}

} // namespace sir
