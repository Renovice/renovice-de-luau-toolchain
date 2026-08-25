// semantic_ir/predicate_semantics.h -- exact branch-taken test operands.
#pragma once
#include "model.h"
#include "value_flow.h"
#include "../ir.h"
#include "../semantic_plan.h"
#include "../structur.h"
#include <map>
#include <set>
#include <functional>

namespace sir::predicates {

struct Analysis {
    bool known = true;
    std::string failure;
    std::set<PredicateTestContract> tests;
    std::set<PredicateExpressionContract> expressions;
};

// Test oracle for the expression topology.  Leaf values are the VM's
// branch-taken truth values keyed by bytecode instruction.
inline bool evaluate_shape(const PredicateExpressionContract& expression,
                           int node_index, const std::map<int, bool>& leaves,
                           bool& known) {
    if (node_index < 0 || node_index >= (int)expression.nodes.size()) {
        known = false; return false;
    }
    const PredicateExpressionNodeContract& node = expression.nodes[(size_t)node_index];
    if (node.kind == PredicateExpressionKind::Test) {
        auto value = leaves.find(node.test.instruction);
        if (value == leaves.end()) { known = false; return false; }
        return value->second;
    }
    const bool left = evaluate_shape(expression, node.left, leaves, known);
    if (!known) return false;
    if (node.kind == PredicateExpressionKind::Not) return !left;
    const bool right = evaluate_shape(expression, node.right, leaves, known);
    if (!known) return false;
    return node.kind == PredicateExpressionKind::And ? left && right : left || right;
}

inline Analysis analyze(const ir::IProto& proto, const sem::Manifest& manifest,
                        const vf::Analysis& flow, PrototypeId owner,
                        const st::Graph& graph) {
    Analysis out;
    std::map<std::pair<int, int>, std::set<ValueOriginContract>> origins;
    for (const vf::Use& use : flow.uses)
        for (const vf::Origin& origin : use.reaching)
            origins[{use.instruction, use.reg}].insert(
                ValueOriginContract{(int)origin.kind, origin.instruction, origin.reg});
    auto decode_test = [&](int instruction_index, int owner_block,
                           PredicateTestContract& test) {
        if (instruction_index < 0 || instruction_index >= (int)proto.code.size()) {
            out.known = false; out.failure = "predicate instruction unavailable"; return out;
        }
        const ir::IInsn& instruction = proto.code[(size_t)instruction_index];
        test.owner = owner; test.block = BlockId(owner_block);
        test.instruction = instruction_index; test.opcode = instruction.name;
        test.raw_a = instruction.A; test.raw_aux = instruction.aux;
        auto operand = [&](int reg) {
            auto found = origins.find({instruction_index, reg});
            if (found == origins.end() || found->second.empty()) {
                out.known = false; out.failure = "predicate operand origin unavailable";
                test.operands.push_back({});
            } else test.operands.push_back(found->second);
        };
        auto constant = [&](int index) {
            test.constant_index = index;
            if (index < 0 || index >= (int)proto.consts.size()) {
                out.known = false; out.failure = "predicate constant index unavailable"; return;
            }
            test.constant_kind = (int)proto.consts[(size_t)index].kind;
            test.constant_text = ir::value_text(proto.consts[(size_t)index]);
        };
        switch (instruction.op) {
            case 0x4b: test.kind = PredicateTestKind::Truthy; operand(instruction.A); break;
            case 0x18: test.kind = PredicateTestKind::Falsey; operand(instruction.A); break;
            case 0x37: test.kind = PredicateTestKind::Equal;
                       operand(instruction.A); operand((int)(instruction.aux & 0xff)); break;
            case 0x27: test.kind = PredicateTestKind::NotEqual;
                       operand(instruction.A); operand((int)(instruction.aux & 0xff)); break;
            case 0x21: test.kind = PredicateTestKind::Less;
                       operand(instruction.A); operand((int)(instruction.aux & 0xff)); break;
            case 0x1c: test.kind = PredicateTestKind::Less;
                       operand(instruction.A); operand((int)(instruction.aux & 0xff));
                       test.branch_on_true = false; break;
            case 0x23: test.kind = PredicateTestKind::LessEqual;
                       operand(instruction.A); operand((int)(instruction.aux & 0xff)); break;
            case 0x33: test.kind = PredicateTestKind::LessEqual;
                       operand(instruction.A); operand((int)(instruction.aux & 0xff));
                       test.branch_on_true = false; break;
            case 0x3a:
                test.kind = (instruction.aux & 0x80000000u)
                    ? PredicateTestKind::NotEqual : PredicateTestKind::Equal;
                operand(instruction.A); test.constant_text = "nil"; break;
            case 0x34:
                test.kind = (instruction.aux & 0x80000000u)
                    ? PredicateTestKind::NotEqual : PredicateTestKind::Equal;
                operand(instruction.A);
                test.constant_text = (instruction.aux & 1u) ? "true" : "false";
                break;
            case 0x20: case 0x41:
                test.kind = (instruction.aux & 0x80000000u)
                    ? PredicateTestKind::NotEqual : PredicateTestKind::Equal;
                operand(instruction.A); constant((int)(instruction.aux & 0x7fffffffu));
                break;
            case 0x47:
                test.kind = PredicateTestKind::NumericForExhausted;
                operand(instruction.A); operand((int)instruction.A + 1);
                operand((int)instruction.A + 2); break;
            case 0x0a:
                test.kind = PredicateTestKind::NumericForAdvance;
                operand(instruction.A); operand((int)instruction.A + 1);
                operand((int)instruction.A + 2); break;
            case 0x1e:
                test.kind = PredicateTestKind::GenericForAdvance;
                operand(instruction.A); operand((int)instruction.A + 1);
                operand((int)instruction.A + 2); break;
            default:
                test.kind = PredicateTestKind::Preserved;
                out.known = false;
                out.failure = "unmodeled predicate opcode:" + instruction.name;
                break;
        }
        return out;
    };
    for (const sem::PredicatePlan& plan : manifest.predicates) {
        PredicateExpressionContract expression;
        expression.owner = owner;
        expression.block = BlockId(plan.block);
        std::function<int(const st::PredicatePtr&)> append =
            [&](const st::PredicatePtr& source) -> int {
                if (!source) return -1;
                PredicateExpressionNodeContract node;
                node.kind = source->kind == st::Predicate::Test
                    ? PredicateExpressionKind::Test
                    : source->kind == st::Predicate::Not
                        ? PredicateExpressionKind::Not
                        : source->kind == st::Predicate::And
                            ? PredicateExpressionKind::And
                            : PredicateExpressionKind::Or;
                if (source->kind == st::Predicate::Test) {
                    decode_test(source->test_insn, plan.block, node.test);
                    if (!out.known) return -1;
                    out.tests.insert(node.test);
                } else {
                    node.left = append(source->left);
                    if (!out.known || node.left < 0) return -1;
                    if (source->kind == st::Predicate::And
                        || source->kind == st::Predicate::Or) {
                        node.right = append(source->right);
                        if (!out.known || node.right < 0) return -1;
                    }
                }
                expression.nodes.push_back(std::move(node));
                return (int)expression.nodes.size() - 1;
            };
        st::PredicatePtr source;
        if (plan.block >= 0 && plan.block < (int)graph.n.size())
            source = graph.n[(size_t)plan.block].branch_predicate;
        if (!source) source = st::pred_test(plan.instruction);
        expression.root = append(source);
        if (!out.known || expression.root < 0) return out;
        out.expressions.insert(std::move(expression));
    }
    return out;
}

} // namespace sir::predicates
