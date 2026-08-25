// semantic_ir/expression_semantics.h -- exact producer contracts for register definitions.
#pragma once
#include "value_web.h"
#include "../ir.h"
#include <map>
#include <set>

namespace sir::expressions {

struct Analysis {
    bool known = true;
    std::string failure;
    std::set<ExpressionDefinitionContract> definitions;
};

inline const char* kind_name(ExpressionKind kind) {
    switch (kind) {
        case ExpressionKind::Number: return "number";
        case ExpressionKind::Constant: return "constant";
        case ExpressionKind::Nil: return "nil";
        case ExpressionKind::Boolean: return "boolean";
        case ExpressionKind::Move: return "move";
        case ExpressionKind::UpvalueRead: return "upvalue_read";
        case ExpressionKind::GlobalRead: return "global_read";
        case ExpressionKind::ImportRead: return "import_read";
        case ExpressionKind::FieldRead: return "field_read";
        case ExpressionKind::IndexRead: return "index_read";
        case ExpressionKind::NumberIndexRead: return "number_index_read";
        case ExpressionKind::NewTable: return "new_table";
        case ExpressionKind::DuplicateTable: return "duplicate_table";
        case ExpressionKind::ClosureValue: return "closure";
        case ExpressionKind::VarargResult: return "vararg_result";
        case ExpressionKind::Unary: return "unary";
        case ExpressionKind::Concatenate: return "concatenate";
        case ExpressionKind::Binary: return "binary";
        case ExpressionKind::MethodFunction: return "method_function";
        case ExpressionKind::MethodReceiver: return "method_receiver";
        case ExpressionKind::CallResult: return "call_result";
        case ExpressionKind::NumericLoopState: return "numeric_loop_state";
        case ExpressionKind::GenericLoopResult: return "generic_loop_result";
        case ExpressionKind::Preserved: return "preserved";
    }
    return "invalid";
}

inline const char* binary_operator(uint8_t opcode) {
    switch (opcode) {
        case 0x49: case 0x38: return "+";
        case 0x07: case 0x3e: case 0x06: return "-";
        case 0x22: case 0x09: return "*";
        case 0x1a: case 0x32: case 0x3b: return "/";
        case 0x55: case 0x3c: return "%";
        case 0x45: case 0x08: return "^";
        case 0x00: case 0x24: return "//";
        case 0x2f: case 0x31: return "and";
        case 0x2b: case 0x51: return "or";
        default: return nullptr;
    }
}

inline Analysis analyze(const ir::IProto& proto, const sem::Manifest& manifest,
                        const vf::Analysis& flow, PrototypeId owner) {
    Analysis out;
    std::map<int, int> instruction_block;
    for (const auto& item : manifest.block_instruction_ranges)
        for (int instruction = item.second.first;
             instruction <= item.second.second
                 && instruction < (int)proto.code.size(); ++instruction)
            if (instruction >= 0) instruction_block[instruction] = item.first;
    std::map<std::pair<int, int>, std::set<ValueOriginContract>> origins;
    for (const vf::Use& use : flow.uses)
        for (const vf::Origin& origin : use.reaching)
            origins[{use.instruction, use.reg}].insert(
                ValueOriginContract{(int)origin.kind, origin.instruction, origin.reg});

    auto constant = [&](ExpressionDefinitionContract& value, int index) {
        value.constant_index = index;
        if (index < 0 || index >= (int)proto.consts.size()) {
            out.known = false; out.failure = "expression constant index out of range";
            return;
        }
        value.constant_kind = (int)proto.consts[(size_t)index].kind;
        value.constant_text = ir::value_text(proto.consts[(size_t)index]);
    };

    for (const vf::Definition& definition : flow.definitions) {
        const int instruction_index = definition.origin.instruction;
        auto block = instruction_block.find(instruction_index);
        if (block == instruction_block.end() || instruction_index < 0
            || instruction_index >= (int)proto.code.size()) {
            out.known = false; out.failure = "expression definition block unavailable";
            return out;
        }
        const ir::IInsn& instruction = proto.code[(size_t)instruction_index];
        ExpressionDefinitionContract value;
        value.owner = owner; value.block = BlockId(block->second);
        value.identity = ValueOriginContract{(int)definition.origin.kind,
                                             instruction_index, definition.origin.reg};
        value.opcode = instruction.name;
        value.result_slot = definition.origin.reg - instruction.A;
        value.open_result = definition.open_range;
        value.raw_a = instruction.A; value.raw_b = instruction.B;
        value.raw_c = instruction.C; value.raw_bx = instruction.Bx;
        value.raw_aux = instruction.aux;
        auto operand = [&](int reg) {
            auto found = origins.find({instruction_index, reg});
            if (found == origins.end() || found->second.empty()) {
                out.known = false; out.failure = "expression operand origin unavailable";
                value.operands.push_back({});
            } else value.operands.push_back(found->second);
        };

        const uint8_t op = instruction.op;
        if (op == 0x12) {
            value.kind = ExpressionKind::Number;
            value.constant_text = std::to_string((int)(int16_t)instruction.Bx);
        } else if (op == 0x4e) {
            value.kind = ExpressionKind::Constant; constant(value, instruction.Bx);
        } else if (op == 0x0d) value.kind = ExpressionKind::Nil;
        else if (op == 0x04) {
            value.kind = ExpressionKind::Boolean;
            value.constant_text = instruction.B ? "true" : "false";
        } else if (op == 0x14) { value.kind = ExpressionKind::Move; operand(instruction.B); }
        else if (op == 0x13) {
            value.kind = ExpressionKind::UpvalueRead; value.upvalue_slot = instruction.B;
        } else if (op == 0x17) {
            value.kind = ExpressionKind::GlobalRead; value.name = instruction.note;
        } else if (op == 0x46) {
            value.kind = ExpressionKind::ImportRead; value.name = instruction.note;
        } else if (op == 0x3d) {
            value.kind = ExpressionKind::FieldRead; value.name = instruction.note;
            operand(instruction.B);
        } else if (op == 0x01) {
            value.kind = ExpressionKind::IndexRead;
            operand(instruction.B); operand(instruction.C);
        } else if (op == 0x44) {
            value.kind = ExpressionKind::NumberIndexRead;
            value.constant_text = std::to_string((int)instruction.C + 1);
            operand(instruction.B);
        } else if (op == 0x2c) value.kind = ExpressionKind::NewTable;
        else if (op == 0x4f) {
            value.kind = ExpressionKind::DuplicateTable; constant(value, instruction.Bx);
        } else if (op == 0x16 || op == 0x42) {
            value.kind = ExpressionKind::ClosureValue;
            if (op == 0x16 && instruction.Bx < proto.kids.size())
                value.closure_target = (int)proto.kids[instruction.Bx];
            else if (op == 0x42 && instruction.Bx < proto.consts.size()
                     && proto.consts[instruction.Bx].kind == ir::KKind::Closure) {
                value.closure_target = (int)proto.consts[instruction.Bx].sub;
                constant(value, instruction.Bx);
            }
            if (value.closure_target < 0) {
                out.known = false; out.failure = "expression closure target unavailable";
            }
        } else if (op == 0x4c) value.kind = ExpressionKind::VarargResult;
        else if (op == 0x0e || op == 0x50 || op == 0x4d) {
            value.kind = ExpressionKind::Unary;
            value.operator_text = op == 0x0e ? "-" : (op == 0x50 ? "not" : "#");
            operand(instruction.B);
        } else if (op == 0x28) {
            value.kind = ExpressionKind::Concatenate; value.operator_text = "..";
            for (int reg = instruction.B; reg <= instruction.C; ++reg) operand(reg);
        } else if (const char* operation = binary_operator(op)) {
            value.kind = ExpressionKind::Binary; value.operator_text = operation;
            const bool constant_right = op == 0x38 || op == 0x3e || op == 0x09
                || op == 0x32 || op == 0x3c || op == 0x08 || op == 0x24
                || op == 0x31 || op == 0x51;
            const bool constant_left = op == 0x06 || op == 0x3b;
            if (constant_left) { constant(value, instruction.B); operand(instruction.C); }
            else if (constant_right) { operand(instruction.B); constant(value, instruction.C); }
            else { operand(instruction.B); operand(instruction.C); }
        } else if (op == 0x2d) {
            value.kind = definition.origin.reg == instruction.A
                ? ExpressionKind::MethodFunction : ExpressionKind::MethodReceiver;
            value.name = instruction.note; value.compiler_scaffolding = true;
            operand(instruction.B);
        } else if (op == 0x54) {
            value.kind = ExpressionKind::CallResult;
            value.open_operands = instruction.B == 0;
            const int last = instruction.B == 0 ? instruction.A
                : (int)instruction.A + (int)instruction.B - 1;
            for (int reg = instruction.A; reg <= last; ++reg) operand(reg);
        } else if (op == 0x0a) {
            value.kind = ExpressionKind::NumericLoopState;
            value.compiler_scaffolding = true;
            for (int reg = instruction.A; reg <= (int)instruction.A + 2; ++reg)
                operand(reg);
        } else if (op == 0x1e) {
            value.kind = ExpressionKind::GenericLoopResult;
            value.compiler_scaffolding = true;
            for (int reg = instruction.A; reg <= (int)instruction.A + 2; ++reg)
                operand(reg);
        } else {
            value.kind = ExpressionKind::Preserved;
        }
        out.definitions.insert(std::move(value));
        if (!out.known) return out;
    }
    return out;
}

} // namespace sir::expressions
