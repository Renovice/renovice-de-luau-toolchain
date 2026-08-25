// semantic_ir/source_renderer.h -- isolated, fail-closed Semantic IR source renderer.
//
// Source is printed only from verified semantic contracts, without consulting mutable VM
// registers or the legacy renderer. Unsupported node kinds fail closed.
#pragma once
#include "model.h"
#include "value_flow.h"
#include "../expr.h"
#include <algorithm>
#include <functional>
#include <iterator>
#include <map>
#include <sstream>

namespace sir::source {

struct Result {
    bool ok = false;
    std::string source;
    std::vector<std::string> failures;
    std::set<BlockId> missing_blocks;
    BlockId first_duplicate_block;
    int first_duplicate_prototype = -1;
    BlockId duplicate_first_region_start;
    BlockId duplicate_first_region_stop;
    BlockId duplicate_second_region_start;
    BlockId duplicate_second_region_stop;
    bool used_dispatcher = false;
    bool used_frame_storage = false;
};

inline std::string global_name(const std::string& name) {
    return ex::is_dotted_path(name) ? name : "_G[" + ir::quote_lua(name) + "]";
}

inline std::string global_slot(const std::string& name) {
    return ex::is_ident(name) ? name : "_G[" + ir::quote_lua(name) + "]";
}

// Source-level lowering for DE SETLIST B C=0 after its symbolic VM-top producer
// and fixed prefix have been verified. Kept outside Renderer so the runtime
// lowering oracle executes the exact production template rather than a copied
// approximation of it.
inline std::string open_setlist_lowering_source(
    const std::string& table, int list_start_index,
    const std::vector<std::string>& fixed_values,
    const std::string& open_values, const std::string& index,
    const std::string& values) {
    std::ostringstream out;
    const int open_start = list_start_index + (int)fixed_values.size();
    out << "do\n"
        << "    local " << values << " = table.pack(" << open_values << ")\n";
    for (size_t fixed = 0; fixed < fixed_values.size(); ++fixed)
        out << "    " << table << '[' << list_start_index + (int)fixed << "] = "
            << fixed_values[fixed] << '\n';
    out << "    for " << index << " = 1, " << values << ".n do\n"
        << "        " << table << '[' << open_start << " + " << index
        << " - 1] = " << values << '[' << index << "]\n"
        << "    end\n"
        << "end";
    return out.str();
}

inline std::string return_lowering_source(
    const std::vector<std::string>& fixed_values,
    const std::string& open_values = "") {
    std::ostringstream out;
    out << "return";
    for (size_t index = 0; index < fixed_values.size(); ++index)
        out << (index ? ", " : " ") << fixed_values[index];
    if (!open_values.empty())
        out << (fixed_values.empty() ? " " : ", ") << open_values;
    return out.str();
}

class Renderer {
    const Model& model_;
    const std::map<int, Model>* module_models_ = nullptr;
    std::vector<std::string> upvalue_names_;
    std::map<ValueOriginContract, int> web_by_origin_;
    std::map<ValueOriginContract, const ExpressionDefinitionContract*> expression_by_origin_;
    std::map<ValueOriginContract, const DefinitionEmissionContract*> emission_by_origin_;
    std::map<int, std::vector<const ExpressionDefinitionContract*>> expressions_by_instruction_;
    std::map<int, const CallContract*> calls_;
    std::map<int, const ReturnContract*> returns_;
    std::map<int, const StoreOperationContract*> stores_;
    std::map<int, const TableOperationContract*> tables_;
    std::map<int, const ClosureContract*> closures_;
    std::map<int, const BranchContract*> branches_by_block_;
    std::map<int, const PredicateTestContract*> predicates_by_block_;
    std::map<int, const PredicateExpressionContract*> predicate_expressions_by_block_;
    std::map<int, const AuthoritativeLoop*> loops_by_header_;
    std::map<int, const AuthoritativeLoop*> numeric_loops_by_prep_;
    std::map<int, NodeKind> loop_kind_by_header_;
    std::map<int, const BranchContract*> loop_condition_by_header_;
    std::map<int, const PredicateTestContract*> numeric_prep_test_by_loop_;
    std::set<int> open_result_producers_;
    std::map<int, int> open_result_consumers_;
    // Canonical stock `ipairs`/`pairs` calls whose exact three results feed only
    // their paired generic loop.  Rendering the materialised triplet as
    // `for ... in f, s, i` makes Luau choose generic FORGPREP (DE 0x0b).
    // Warframe's compiler used the specialised FORGPREP_INEXT/NEXT forms; live
    // Rhino proved that routing an `ipairs` C iterator through 0x0b can GPF
    // before the first body instruction.  Fold only the fully proved producer
    // back into `for ... in ipairs(x)` / `pairs(x)` so Luau restores the native
    // specialised prep.  Custom iterators remain materialised and generic.
    std::map<int, int> specialised_iterator_call_by_loop_;
    std::set<int> specialised_iterator_call_producers_;
    std::set<int> specialised_iterator_scaffolding_instructions_;
    std::set<int> rendering_open_calls_;
    std::set<int> active_loops_;
    std::map<int, std::string> cyclic_loop_skip_variables_;
    std::set<int> parameter_webs_;
    std::map<int, int> parameter_reg_by_web_;
    bool frame_storage_ = false;

    void fail(const std::string& message) {
        if (std::find(failures_.begin(), failures_.end(), message) == failures_.end())
            failures_.push_back(message);
    }
    std::vector<std::string> failures_;
    BlockId first_duplicate_block_;
    int first_duplicate_prototype_ = -1;
    BlockId duplicate_first_region_start_;
    BlockId duplicate_first_region_stop_;
    BlockId duplicate_second_region_start_;
    BlockId duplicate_second_region_stop_;
    std::map<int, std::pair<BlockId, BlockId>> first_emission_regions_;
    std::vector<std::pair<BlockId, BlockId>> region_stack_;
    bool used_dispatcher_ = false;
    bool used_frame_storage_ = false;

    std::string web_name(int web) const {
        auto parameter = parameter_reg_by_web_.find(web);
        if (parameter != parameter_reg_by_web_.end())
            return "p" + std::to_string(model_.prototype.value) + "_"
                + std::to_string(parameter->second);
        if (frame_storage_)
            return "frame_" + std::to_string(model_.prototype.value)
                + "[" + std::to_string(web) + "]";
        // A child function names reference captures using the parent's source
        // names. Prototype-qualified locals prevent those lexical references
        // from being shadowed by an unrelated child web with the same id.
        return "v" + std::to_string(model_.prototype.value) + "_"
            + std::to_string(web);
    }

    std::string origin_value(const std::set<ValueOriginContract>& origins) {
        if (origins.empty()) { fail("RENDER_VALUE_ORIGIN_EMPTY"); return "nil"; }
        int web = -1;
        for (const ValueOriginContract& origin : origins) {
            auto found = web_by_origin_.find(origin);
            if (found == web_by_origin_.end()) {
                fail("RENDER_VALUE_WEB_MISSING"); return "nil";
            }
            if (web >= 0 && web != found->second) {
                fail("RENDER_VALUE_ORIGINS_CROSS_WEBS"); return "nil";
            }
            web = found->second;
        }
        if (origins.size() == 1) {
            const ValueOriginContract& origin = *origins.begin();
            auto emission = emission_by_origin_.find(origin);
            auto expression = expression_by_origin_.find(origin);
            if (emission != emission_by_origin_.end()
                && emission->second->disposition == EmissionDisposition::InlineLiteral
                && expression != expression_by_origin_.end())
                return literal(*expression->second);
        }
        return web_name(web);
    }

    std::string literal(const ExpressionDefinitionContract& expression) {
        switch (expression.kind) {
            case ExpressionKind::Number:
            case ExpressionKind::Constant:
            case ExpressionKind::Boolean:
                if (expression.constant_text.empty()) {
                    fail("RENDER_LITERAL_TEXT_MISSING"); return "nil";
                }
                return expression.constant_text;
            case ExpressionKind::Nil: return "nil";
            default: fail("RENDER_NON_LITERAL_INLINE"); return "nil";
        }
    }

    std::string expression(const ExpressionDefinitionContract& value) {
        auto operand = [&](size_t index) {
            if (index >= value.operands.size()) {
                fail("RENDER_EXPRESSION_OPERAND_MISSING"); return std::string("nil");
            }
            return origin_value(value.operands[index]);
        };
        switch (value.kind) {
            case ExpressionKind::Number:
            case ExpressionKind::Constant:
            case ExpressionKind::Boolean: return literal(value);
            case ExpressionKind::Nil: return "nil";
            case ExpressionKind::Move: return operand(0);
            case ExpressionKind::GlobalRead: return global_slot(value.name);
            case ExpressionKind::ImportRead: return global_name(value.name);
            case ExpressionKind::FieldRead: {
                const std::string base = operand(0);
                return ex::is_ident(value.name) ? "(" + base + ")." + value.name
                    : "(" + base + ")[" + ir::quote_lua(value.name) + "]";
            }
            case ExpressionKind::IndexRead: return operand(0) + "[" + operand(1) + "]";
            case ExpressionKind::NumberIndexRead:
                return operand(0) + "[" + value.constant_text + "]";
            case ExpressionKind::NewTable: return "{}";
            case ExpressionKind::Unary:
                return "(" + value.operator_text
                    + (value.operator_text == "not" ? " " : "") + operand(0) + ")";
            case ExpressionKind::Concatenate: {
                std::string out = "(";
                for (size_t index = 0; index < value.operands.size(); ++index) {
                    if (index) out += " .. ";
                    out += operand(index);
                }
                return out + ")";
            }
            case ExpressionKind::Binary: {
                const bool constant_right = value.raw_a == value.identity.reg
                    && (value.opcode == "ADDK" || value.opcode == "SUBK"
                        || value.opcode == "MULK" || value.opcode == "DIVK"
                        || value.opcode == "MODK" || value.opcode == "POWK"
                        || value.opcode == "IDIVK" || value.opcode == "ANDK"
                        || value.opcode == "ORK");
                const bool constant_left = value.opcode == "SUBRK" || value.opcode == "DIVRK";
                std::string left, right;
                if (constant_left) { left = value.constant_text; right = operand(0); }
                else if (constant_right) { left = operand(0); right = value.constant_text; }
                else { left = operand(0); right = operand(1); }
                if (left.empty() || right.empty()) fail("RENDER_BINARY_CONSTANT_MISSING");
                return "(" + left + " " + value.operator_text + " " + right + ")";
            }
            case ExpressionKind::VarargResult:
                // A fixed-width GETVARARGS defines one distinct value per
                // result slot. Repeating `...` in an assignment reads the
                // first vararg each time because non-final expressions are
                // truncated to one value. Parenthesized select preserves the
                // exact slot and still yields exactly one result (including
                // nil); only an open result may remain raw `...`.
                if (value.open_result) return "...";
                return "(select(" + std::to_string(value.result_slot + 1)
                    + ", ...))";
            case ExpressionKind::DuplicateTable:
                if (value.constant_text.empty() || value.constant_text.front() != '{') {
                    fail("RENDER_DUPLICATE_TABLE_TEMPLATE_MISSING"); return "{}";
                }
                return value.constant_text;
            case ExpressionKind::UpvalueRead:
                if (value.upvalue_slot < 0
                    || value.upvalue_slot >= (int)upvalue_names_.size()) {
                    fail("RENDER_UPVALUE_CONTEXT_MISSING"); return "nil";
                }
                return upvalue_names_[(size_t)value.upvalue_slot];
            case ExpressionKind::ClosureValue:
                fail("RENDER_CLOSURE_PENDING"); return "nil";
            case ExpressionKind::CallResult:
            case ExpressionKind::MethodFunction:
            case ExpressionKind::MethodReceiver:
            case ExpressionKind::NumericLoopState:
            case ExpressionKind::GenericLoopResult:
                fail("RENDER_STRUCTURAL_EXPRESSION_AS_VALUE"); return "nil";
            case ExpressionKind::Preserved:
                fail("RENDER_PRESERVED_EXPRESSION"); return "nil";
        }
        fail("RENDER_EXPRESSION_KIND_INVALID"); return "nil";
    }

    std::string call(const CallContract& value) {
        if (!rendering_open_calls_.insert(value.instruction).second) {
            fail("RENDER_OPEN_CALL_CYCLE"); return "nil()";
        }
        std::string out;
        std::string explicit_self;
        if (value.method_call) {
            std::string method;
            const ExpressionDefinitionContract* receiver_copy = nullptr;
            for (const auto& item : model_.authoritative_expressions)
                if (item.identity.instruction == value.namecall_instruction) {
                    if (item.kind == ExpressionKind::MethodFunction) method = item.name;
                    else if (item.kind == ExpressionKind::MethodReceiver)
                        receiver_copy = &item;
                }
            if (method.empty()) fail("RENDER_METHOD_NAME_MISSING");
            if (!receiver_copy || receiver_copy->operands.size() != 1) {
                fail("RENDER_METHOD_RECEIVER_SOURCE_MISSING");
                return "nil()";
            }
            // NAMECALL writes a compiler-only copy of the source receiver to A+1.
            // The call contract's receiver_origins therefore names scaffolding, not a
            // source value. Render the verified MethodReceiver operand that fed the copy.
            const std::string receiver = origin_value(receiver_copy->operands[0]);
            if (!ex::is_ident(method)) fail("RENDER_METHOD_NAME_NOT_IDENTIFIER");
            // Keep the NAMECALL semantic form even when storage makes the receiver a
            // complex prefix expression. Luau accepts `(expr):method()` and compiles it
            // back to NAMECALL. The old explicit-self lowering
            // `(expr).method(expr, ...)` compiled as GETFIELD+CALL; that can bypass the
            // native NAMECALL dispatch used by Warframe userdata and also evaluates the
            // receiver expression twice. A standalone parenthesized call is protected by
            // the existing lexical `do` boundary below.
            if (ex::is_ident(receiver)) out = receiver + ":" + method;
            else out = "(" + receiver + "):" + method;
        } else out = origin_value(value.callee_origins);
        out += "(";
        if (!explicit_self.empty()) out += explicit_self;
        for (size_t index = 0; index < value.fixed_argument_origins.size(); ++index) {
            if (index || !explicit_self.empty()) out += ", ";
            out += origin_value(value.fixed_argument_origins[index]);
        }
        if (value.open_argument_origin_kind >= 0) {
            if (value.open_argument_origin_kind == (int)vf::TopKind::OpenCall) {
                auto producer = calls_.find(value.open_argument_origin_instruction);
                if (producer == calls_.end())
                    fail("RENDER_OPEN_ARGUMENT_PRODUCER_MISSING");
                else {
                    if (!value.fixed_argument_origins.empty()
                        || !explicit_self.empty()) out += ", ";
                    out += call(*producer->second);
                }
            } else if (value.open_argument_origin_kind
                       == (int)vf::TopKind::OpenVararg) {
                const Node& root = model_.nodes.at(model_.root);
                if (!root.accepts_varargs)
                    fail("RENDER_OPEN_ARGUMENT_VARARG_CONTEXT_MISSING");
                else {
                    if (!value.fixed_argument_origins.empty()
                        || !explicit_self.empty()) out += ", ";
                    out += "...";
                }
            } else {
                fail("RENDER_OPEN_ARGUMENT_KIND_INVALID");
            }
        }
        rendering_open_calls_.erase(value.instruction);
        return out + ")";
    }

    std::string specialised_iterator_call(const CallContract& value) {
        if (value.callee_origins.size() != 1
            || value.fixed_argument_origins.size() != 1) {
            fail("RENDER_SPECIALISED_ITERATOR_CALL_SHAPE"); return "nil()";
        }
        auto callee = expression_by_origin_.find(*value.callee_origins.begin());
        if (callee == expression_by_origin_.end()
            || (callee->second->name != "ipairs"
                && callee->second->name != "pairs")) {
            fail("RENDER_SPECIALISED_ITERATOR_CALLEE_MISSING"); return "nil()";
        }
        // Spell the recognised builtin directly.  Going through its materialised
        // value (`frame[n](arg)`) prevents Luau from selecting INEXT/NEXT even
        // though the callee is semantically the same function.
        return callee->second->name + "("
            + origin_value(value.fixed_argument_origins[0]) + ")";
    }

    std::string table_write(const TableOperationContract& value) {
        const std::string table = origin_value(value.table_origins);
        if (value.kind == TableOperationKind::SetField)
            return (ex::is_ident(value.field_name) ? table + "." + value.field_name
                : table + "[" + ir::quote_lua(value.field_name) + "]")
                + " = " + origin_value(value.value_origins);
        if (value.kind == TableOperationKind::SetIndex)
            return table + "[" + origin_value(value.key_origins) + "] = "
                + origin_value(value.value_origins);
        if (value.kind == TableOperationKind::SetNumber)
            return table + "[" + std::to_string(value.numeric_key) + "] = "
                + origin_value(value.value_origins);
        if (value.kind == TableOperationKind::SetList) {
            std::ostringstream out;
            if (value.list_open_origin_kind < 0) {
                for (size_t index = 0; index < value.list_fixed_values.size(); ++index) {
                    if (index) out << '\n';
                    out << table << '[' << value.list_start_index + (int)index << "] = "
                        << origin_value(value.list_fixed_values[index]);
                }
                return out.str();
            }

            std::string open_values;
            if (value.list_open_origin_kind == (int)vf::TopKind::OpenCall) {
                auto producer = calls_.find(value.list_open_origin_instruction);
                if (producer == calls_.end())
                    fail("RENDER_OPEN_SETLIST_PRODUCER_MISSING");
                else if (producer->second->result_first
                         != value.list_open_origin_base)
                    fail("RENDER_OPEN_SETLIST_BASE_MISMATCH");
                else open_values = call(*producer->second);
            } else if (value.list_open_origin_kind
                       == (int)vf::TopKind::OpenVararg) {
                const Node& root = model_.nodes.at(model_.root);
                if (!root.accepts_varargs)
                    fail("RENDER_OPEN_SETLIST_VARARG_CONTEXT_MISSING");
                else open_values = "...";
            } else fail("RENDER_OPEN_SETLIST_KIND_INVALID");

            if (!open_values.empty()) {
                const std::string index = "setlist_index_"
                    + std::to_string(model_.prototype.value) + "_"
                    + std::to_string(value.instruction);
                const std::string values = "setlist_values_"
                    + std::to_string(model_.prototype.value) + "_"
                    + std::to_string(value.instruction);
                // The producer CALL precedes SETLIST in the authoritative effect
                // order. Capture its exact tail before performing any table write;
                // writing the fixed prefix first changes behavior if the producer
                // observes the table or raises an error.
                std::vector<std::string> fixed_values;
                fixed_values.reserve(value.list_fixed_values.size());
                for (const auto& fixed : value.list_fixed_values)
                    fixed_values.push_back(origin_value(fixed));
                out << open_setlist_lowering_source(
                    table, value.list_start_index, fixed_values, open_values,
                    index, values);
            }
            return out.str();
        }
        fail("RENDER_TABLE_ALLOCATION_AS_WRITE"); return "";
    }

    std::string predicate_leaf(const PredicateTestContract& test,
                               bool requested_negation = false) {
        auto operand = [&](size_t index) {
            if (index >= test.operands.size()) {
                fail("RENDER_PREDICATE_OPERAND_MISSING"); return std::string("nil");
            }
            return origin_value(test.operands[index]);
        };
        std::string value;
        bool negated = requested_negation != !test.branch_on_true;
        switch (test.kind) {
            case PredicateTestKind::Truthy: value = operand(0); break;
            case PredicateTestKind::Falsey:
                value = operand(0); negated = !negated; break;
            case PredicateTestKind::Equal:
            case PredicateTestKind::NotEqual: {
                const std::string right = test.constant_text.empty()
                    ? operand(1) : test.constant_text;
                value = operand(0) + (test.kind == PredicateTestKind::Equal
                    ? " == " : " ~= ") + right;
                break;
            }
            case PredicateTestKind::Less:
                value = operand(0) + " < " + operand(1); break;
            case PredicateTestKind::LessEqual:
                value = operand(0) + " <= " + operand(1); break;
            case PredicateTestKind::NumericForExhausted:
            case PredicateTestKind::NumericForAdvance:
            case PredicateTestKind::GenericForAdvance:
                fail("RENDER_LOOP_PREDICATE_AS_BRANCH"); value = "false"; break;
            case PredicateTestKind::Preserved:
                fail("RENDER_PRESERVED_PREDICATE"); value = "false"; break;
        }
        if (negated) value = "not (" + value + ")";
        return value;
    }

    std::string predicate_expression(const PredicateExpressionContract& expression,
                                     int node_index, bool negated = false) {
        if (node_index < 0 || node_index >= (int)expression.nodes.size()) {
            fail("RENDER_PREDICATE_EXPRESSION_NODE_INVALID"); return "false";
        }
        const PredicateExpressionNodeContract& node =
            expression.nodes[(size_t)node_index];
        if (node.kind == PredicateExpressionKind::Test) {
            return predicate_leaf(node.test, negated);
        }
        if (node.kind == PredicateExpressionKind::Not)
            return predicate_expression(expression, node.left, !negated);
        // Push inversion to the leaves.  This is exact De Morgan
        // normalisation, not a heuristic rewrite, and avoids compiler-hostile
        // forms such as `not ((not a and not b))` becoming extra CFG shells.
        const std::string left = predicate_expression(expression, node.left, negated);
        const std::string right = predicate_expression(expression, node.right, negated);
        const bool render_and = negated
            ? node.kind == PredicateExpressionKind::Or
            : node.kind == PredicateExpressionKind::And;
        return "(" + left + (render_and ? " and " : " or ") + right + ")";
    }

    std::string predicate(const PredicateTestContract& test, bool negated = false) {
        auto exact = predicate_expressions_by_block_.find(test.block.value);
        if (exact == predicate_expressions_by_block_.end())
            return predicate_leaf(test, negated);
        return predicate_expression(*exact->second, exact->second->root, negated);
    }

    bool compound_predicate(const PredicateTestContract& test) const {
        auto exact = predicate_expressions_by_block_.find(test.block.value);
        if (exact == predicate_expressions_by_block_.end()) return false;
        int leaves = 0;
        for (const PredicateExpressionNodeContract& node : exact->second->nodes)
            if (node.kind == PredicateExpressionKind::Test) ++leaves;
        return leaves > 1;
    }

    void emit_instruction(int instruction, int indent, std::ostringstream& out) {
        if (specialised_iterator_scaffolding_instructions_.count(instruction)) return;
        const std::string padding((size_t)indent * 4, ' ');
        auto closure_value = closures_.find(instruction);
        if (closure_value != closures_.end()) {
            const ClosureContract& closure = *closure_value->second;
            if (!module_models_) {
                fail("RENDER_CLOSURE_MODULE_CONTEXT_MISSING"); return;
            }
            auto target = module_models_->find(closure.target.value);
            if (target == module_models_->end()) {
                fail("RENDER_CLOSURE_TARGET_MODEL_MISSING"); return;
            }
            const ValueOriginContract identity{2, instruction,
                                               closure.destination_register};
            auto web = web_by_origin_.find(identity);
            if (web == web_by_origin_.end()) {
                fail("RENDER_CLOSURE_RESULT_WEB_MISSING"); return;
            }
            std::vector<std::string> captures;
            std::vector<std::string> deferred_self_snapshots;
            for (const CaptureContract& capture : closure.captures) {
                if (capture.mode == CaptureMode::Value) {
                    const std::string snapshot = "cap_" + std::to_string(model_.prototype.value)
                        + "_" + std::to_string(instruction) + "_"
                        + std::to_string(capture.slot);
                    const bool self_capture = capture.source_origins.size() == 1
                        && *capture.source_origins.begin() == identity;
                    if (self_capture) {
                        // DUPCLOSURE writes its result before the following
                        // CAPTURE reads that same register. Initialising this
                        // snapshot before the function assignment captures nil
                        // and breaks recursion. Declare the lexical cell now,
                        // then bind it to the completed closure immediately
                        // after the destination assignment.
                        out << padding << "local " << snapshot << '\n';
                        deferred_self_snapshots.push_back(snapshot);
                    } else {
                        out << padding << "local " << snapshot << " = "
                            << origin_value(capture.source_origins) << '\n';
                    }
                    captures.push_back(snapshot);
                } else if (capture.mode == CaptureMode::Reference) {
                    captures.push_back(origin_value(capture.source_origins));
                } else {
                    if (capture.parent_upvalue_slot < 0
                        || capture.parent_upvalue_slot >= (int)upvalue_names_.size()) {
                        fail("RENDER_PARENT_UPVALUE_CONTEXT_MISSING");
                        captures.push_back("nil");
                    } else captures.push_back(
                        upvalue_names_[(size_t)capture.parent_upvalue_slot]);
                }
            }
            Renderer child(target->second, module_models_, captures);
            Result function = child.render_function_literal(indent);
            if (function.used_dispatcher) used_dispatcher_ = true;
            if (function.used_frame_storage) used_frame_storage_ = true;
            for (const std::string& failure : function.failures) fail(failure);
            if (first_duplicate_prototype_ < 0
                && function.first_duplicate_prototype >= 0) {
                first_duplicate_block_ = function.first_duplicate_block;
                first_duplicate_prototype_ = function.first_duplicate_prototype;
                duplicate_first_region_start_ =
                    function.duplicate_first_region_start;
                duplicate_first_region_stop_ =
                    function.duplicate_first_region_stop;
                duplicate_second_region_start_ =
                    function.duplicate_second_region_start;
                duplicate_second_region_stop_ =
                    function.duplicate_second_region_stop;
            }
            if (function.ok) {
                out << padding << web_name(web->second) << " = " << function.source << '\n';
                for (const std::string& snapshot : deferred_self_snapshots)
                    out << padding << snapshot << " = "
                        << web_name(web->second) << '\n';
            }
            return;
        }
        auto call_value = calls_.find(instruction);
        if (call_value != calls_.end()) {
            if (specialised_iterator_call_producers_.count(instruction)) return;
            if (open_result_producers_.count(instruction)) return;
            if (call_value->second->result_count < 0) {
                fail("RENDER_OPEN_CALL_RESULTS_UNCONSUMED"); return;
            }
            std::vector<const ExpressionDefinitionContract*> results;
            for (const auto* item : expressions_by_instruction_[instruction])
                if (item->kind == ExpressionKind::CallResult) results.push_back(item);
            std::sort(results.begin(), results.end(), [](const auto* left, const auto* right) {
                return left->result_slot < right->result_slot;
            });
            out << padding;
            for (size_t index = 0; index < results.size(); ++index) {
                if (index) out << ", ";
                out << web_name(web_by_origin_.at(results[index]->identity));
            }
            if (!results.empty()) out << " = ";
            const std::string rendered_call = call(*call_value->second);
            // A standalone call whose prefix expression begins with `(` can be
            // parsed as a continuation of the previous statement.  A lexical
            // `do` boundary is accepted by Luau in every statement position and
            // does not alter the call's evaluation or result-discard semantics.
            if (results.empty() && !rendered_call.empty()
                && rendered_call.front() == '(')
                out << "do " << rendered_call << " end\n";
            else out << rendered_call << '\n';
            return;
        }
        auto returned = returns_.find(instruction);
        if (returned != returns_.end()) {
            std::vector<std::string> fixed_values;
            fixed_values.reserve(returned->second->fixed_values.size());
            for (const auto& fixed : returned->second->fixed_values)
                fixed_values.push_back(origin_value(fixed));
            std::string open_values;
            if (returned->second->open_origin_kind >= 0) {
                if (returned->second->open_origin_kind
                    == (int)vf::TopKind::OpenCall) {
                    auto producer = calls_.find(
                        returned->second->open_origin_instruction);
                    if (producer == calls_.end())
                        fail("RENDER_OPEN_RETURN_PRODUCER_MISSING");
                    else if (producer->second->result_first
                             != returned->second->open_origin_base)
                        fail("RENDER_OPEN_RETURN_BASE_MISMATCH");
                    else open_values = call(*producer->second);
                } else if (returned->second->open_origin_kind
                           == (int)vf::TopKind::OpenVararg) {
                    const Node& root = model_.nodes.at(model_.root);
                    if (!root.accepts_varargs)
                        fail("RENDER_OPEN_RETURN_VARARG_CONTEXT_MISSING");
                    else open_values = "...";
                } else fail("RENDER_OPEN_RETURN_KIND_INVALID");
            }
            out << padding << return_lowering_source(fixed_values, open_values) << '\n';
            return;
        }
        auto store = stores_.find(instruction);
        if (store != stores_.end()) {
            std::string target;
            if (store->second->kind == StoreOperationKind::Upvalue) {
                const int slot = store->second->upvalue_slot;
                if (slot < 0 || slot >= (int)upvalue_names_.size()) {
                    fail("RENDER_UPVALUE_CONTEXT_MISSING"); target = "nil";
                } else target = upvalue_names_[(size_t)slot];
            } else target = global_slot(store->second->name);
            out << padding << target << " = "
                << origin_value(store->second->value_origins) << '\n';
            return;
        }
        auto table = tables_.find(instruction);
        if (table != tables_.end()
            && table->second->kind != TableOperationKind::NewTable
            && table->second->kind != TableOperationKind::DuplicateTemplate) {
            std::istringstream lines(table_write(*table->second));
            std::string line;
            while (std::getline(lines, line)) out << padding << line << '\n';
            return;
        }
        auto expressions = expressions_by_instruction_.find(instruction);
        if (expressions == expressions_by_instruction_.end()) return;
        std::vector<const ExpressionDefinitionContract*> emitted;
        for (const auto* item : expressions->second) {
            auto disposition = emission_by_origin_.find(item->identity);
            if (disposition != emission_by_origin_.end()
                && disposition->second->disposition == EmissionDisposition::ExplicitStatement)
                emitted.push_back(item);
        }
        std::sort(emitted.begin(), emitted.end(), [](const auto* left, const auto* right) {
            return left->result_slot < right->result_slot;
        });
        if (emitted.empty()) return;
        out << padding;
        for (size_t index = 0; index < emitted.size(); ++index) {
            if (index) out << ", ";
            out << web_name(web_by_origin_.at(emitted[index]->identity));
        }
        out << " = ";
        for (size_t index = 0; index < emitted.size(); ++index) {
            if (index) out << ", ";
            out << expression(*emitted[index]);
        }
        out << '\n';
    }

    bool block_returns(int block) const {
        auto range = model_.block_instruction_ranges.find(block);
        if (range == model_.block_instruction_ranges.end()) return false;
        return returns_.count(range->second.second) != 0;
    }

    bool block_has_source_events(BlockId block) const {
        auto range = model_.block_instruction_ranges.find(block.value);
        if (range == model_.block_instruction_ranges.end()) return true;
        for (int instruction = range->second.first;
             instruction <= range->second.second; ++instruction) {
            if (calls_.count(instruction) || returns_.count(instruction)
                || stores_.count(instruction) || tables_.count(instruction)
                || closures_.count(instruction)) return true;
            auto expressions = expressions_by_instruction_.find(instruction);
            if (expressions == expressions_by_instruction_.end()) continue;
            for (const auto* expression : expressions->second) {
                auto disposition = emission_by_origin_.find(expression->identity);
                if (disposition != emission_by_origin_.end()
                    && disposition->second->disposition
                        == EmissionDisposition::ExplicitStatement)
                    return true;
            }
        }
        return false;
    }

    struct CollapsedBranch {
        std::string test;
        const PredicateTestContract* source_test = nullptr;
        BlockId true_target;
        BlockId false_target;
        BlockId join;
        bool virtual_exit_join = false;
        std::set<BlockId> true_blocks;
        std::set<BlockId> false_blocks;
        bool true_has_terminal = false;
        bool false_has_terminal = false;
    };

    struct SharedTailBranch {
        BlockId entry;
        BlockId continuation;
        const AuthoritativeLoop* recurrence_loop = nullptr;
        const BranchContract* false_gate = nullptr;
        BlockId false_gate_escape;
        std::set<BlockId> shared_blocks;
        std::set<BlockId> true_prefix;
        std::set<BlockId> false_prefix;
    };

    struct CyclicNumericHeaderExit {
        const AuthoritativeLoop* loop = nullptr;
        bool true_is_latch = false;
        BlockId latch_path_start;
        BlockId exit_start;
        BlockId outside;
        BlockId normal_outside;
        std::set<BlockId> exit_blocks;
        std::set<BlockId> latch_path_blocks;
        std::set<BlockId> normal_bridge_blocks;
    };

    struct CyclicNumericHeaderTerminal {
        const AuthoritativeLoop* loop = nullptr;
        bool true_is_latch = false;
        BlockId latch_path_start;
        BlockId terminal_start;
        std::set<BlockId> latch_path_blocks;
        std::set<BlockId> terminal_blocks;
    };

    struct CyclicWhileIteration {
        const AuthoritativeLoop* loop = nullptr;
        BlockId shared_entry;
        std::set<BlockId> true_prefix;
        std::set<BlockId> false_prefix;
        std::set<BlockId> shared_blocks;
    };

    bool recover_cyclic_iteration_arm(const AuthoritativeLoop& loop,
                                      BlockId start,
                                      std::set<BlockId>& blocks) const {
        if (start == loop.canonical_latch) return true;
        if (!loop.body.count(start) || start.value == loop.id.value
            || loop.latches.count(start)) return false;
        std::vector<BlockId> pending{start};
        bool saw_latch = false;
        while (!pending.empty()) {
            const BlockId block = pending.back(); pending.pop_back();
            if (!blocks.insert(block).second) continue;
            if (!loop.body.count(block) || block.value == loop.id.value
                || loop.latches.count(block) || block_returns(block.value))
                return false;
            bool has_successor = false;
            for (const Edge& edge : model_.cfg_edges) {
                if (edge.source != block) continue;
                if (!edge.target.valid()) return false;
                has_successor = true;
                if (edge.target == loop.canonical_latch) {
                    saw_latch = true;
                    continue;
                }
                if (!loop.body.count(edge.target)
                    || edge.target.value == loop.id.value
                    || loop.latches.count(edge.target)) return false;
                auto dominators = model_.block_dominators.find(block.value);
                if (dominators != model_.block_dominators.end()
                    && dominators->second.count(edge.target.value)) return false;
                pending.push_back(edge.target);
            }
            if (!has_successor) return false;
        }
        return saw_latch;
    }

    bool decompose_cyclic_while_iteration(const BranchContract& branch,
                                          CyclicWhileIteration& result) const {
        if (branch.role != BranchRole::PreservedCyclic) return false;
        auto owner = model_.authoritative_loops.find(LoopId(branch.source.value));
        auto kind = loop_kind_by_header_.find(branch.source.value);
        if (owner == model_.authoritative_loops.end()
            || kind == loop_kind_by_header_.end()
            || kind->second != NodeKind::While
            || owner->second.exits.size() != 0
            || owner->second.latches.size() != 1
            || !owner->second.canonical_latch.valid()) return false;
        const AuthoritativeLoop& loop = owner->second;
        std::set<BlockId> true_iteration, false_iteration;
        if (!recover_cyclic_iteration_arm(loop, branch.true_target,
                                          true_iteration)
            || !recover_cyclic_iteration_arm(loop, branch.false_target,
                                              false_iteration)) return false;
        std::set_intersection(true_iteration.begin(), true_iteration.end(),
                              false_iteration.begin(), false_iteration.end(),
                              std::inserter(result.shared_blocks,
                                            result.shared_blocks.begin()));
        std::set_difference(true_iteration.begin(), true_iteration.end(),
                            result.shared_blocks.begin(), result.shared_blocks.end(),
                            std::inserter(result.true_prefix,
                                          result.true_prefix.begin()));
        std::set_difference(false_iteration.begin(), false_iteration.end(),
                            result.shared_blocks.begin(), result.shared_blocks.end(),
                            std::inserter(result.false_prefix,
                                          result.false_prefix.begin()));
        if (!result.shared_blocks.empty()) {
            std::set<BlockId> entries;
            if (result.shared_blocks.count(branch.true_target))
                entries.insert(branch.true_target);
            if (result.shared_blocks.count(branch.false_target))
                entries.insert(branch.false_target);
            for (const Edge& edge : model_.cfg_edges)
                if (edge.target.valid() && result.shared_blocks.count(edge.target)
                    && !result.shared_blocks.count(edge.source)
                    && (true_iteration.count(edge.source)
                        || false_iteration.count(edge.source)))
                    entries.insert(edge.target);
            if (entries.size() != 1) return false;
            result.shared_entry = *entries.begin();
        }
        const BlockId true_stop = result.shared_blocks.empty()
            ? loop.canonical_latch : result.shared_entry;
        const BlockId false_stop = true_stop;
        if ((!result.true_prefix.empty()
             && !result.true_prefix.count(branch.true_target))
            || (result.true_prefix.empty() && branch.true_target != true_stop)
            || (!result.false_prefix.empty()
                && !result.false_prefix.count(branch.false_target))
            || (result.false_prefix.empty() && branch.false_target != false_stop))
            return false;
        for (const Edge& edge : model_.cfg_edges) {
            if (result.true_prefix.count(edge.source)) {
                if (!edge.target.valid()
                    || (edge.target != true_stop
                        && !result.true_prefix.count(edge.target))) return false;
            } else if (result.false_prefix.count(edge.source)) {
                if (!edge.target.valid()
                    || (edge.target != false_stop
                        && !result.false_prefix.count(edge.target))) return false;
            } else if (result.shared_blocks.count(edge.source)) {
                if (!edge.target.valid()
                    || (edge.target != loop.canonical_latch
                        && !result.shared_blocks.count(edge.target))) return false;
            }
        }
        if (result.true_prefix.empty() && result.false_prefix.empty()) return false;
        result.loop = &loop;
        return true;
    }

    bool recover_numeric_latch_path(const AuthoritativeLoop& loop,
                                    BlockId start,
                                    std::set<BlockId>& blocks) const {
        if (start == loop.canonical_latch) return true;
        if (!loop.body.count(start) || start.value == loop.id.value
            || loop.latches.count(start)) return false;
        std::vector<BlockId> pending{start};
        bool saw_latch = false;
        while (!pending.empty()) {
            const BlockId block = pending.back(); pending.pop_back();
            if (!blocks.insert(block).second) continue;
            if (!loop.body.count(block) || block.value == loop.id.value
                || loop.latches.count(block) || block_returns(block.value))
                return false;
            bool has_successor = false;
            for (const Edge& edge : model_.cfg_edges) {
                if (edge.source != block) continue;
                if (!edge.target.valid()) return false;
                has_successor = true;
                if (edge.target == loop.canonical_latch) {
                    saw_latch = true;
                    continue;
                }
                if (!loop.body.count(edge.target)
                    || edge.target.value == loop.id.value
                    || loop.latches.count(edge.target)) return false;
                auto dominators = model_.block_dominators.find(block.value);
                if (dominators != model_.block_dominators.end()
                    && dominators->second.count(edge.target.value)) return false;
                pending.push_back(edge.target);
            }
            if (!has_successor) return false;
        }
        return saw_latch;
    }

    bool decompose_cyclic_numeric_header_terminal(
            const BranchContract& branch,
            CyclicNumericHeaderTerminal& result) const {
        if (branch.role != BranchRole::PreservedCyclic
            || !branch.virtual_exit_join || branch.join.valid()
            || !branch.true_has_terminal || !branch.false_has_terminal)
            return false;
        auto loop_item = model_.authoritative_loops.find(LoopId(branch.source.value));
        auto kind = loop_kind_by_header_.find(branch.source.value);
        if (loop_item == model_.authoritative_loops.end()
            || kind == loop_kind_by_header_.end()
            || kind->second != NodeKind::NumericFor) return false;
        const AuthoritativeLoop& loop = loop_item->second;
        std::set<BlockId> true_latch_blocks, false_latch_blocks;
        const bool true_latch = recover_numeric_latch_path(
            loop, branch.true_target, true_latch_blocks);
        const bool false_latch = recover_numeric_latch_path(
            loop, branch.false_target, false_latch_blocks);
        if (true_latch == false_latch) return false;
        const BlockId terminal_start = true_latch ? branch.false_target
                                                  : branch.true_target;
        if (!loop.body.count(terminal_start)
            || terminal_start.value == loop.id.value
            || loop.latches.count(terminal_start)) return false;
        std::vector<BlockId> pending{terminal_start};
        bool saw_return = false;
        while (!pending.empty()) {
            const BlockId block = pending.back(); pending.pop_back();
            if (!result.terminal_blocks.insert(block).second) continue;
            if (!loop.body.count(block) || block.value == loop.id.value
                || loop.latches.count(block)) return false;
            bool has_successor = false, block_return = false;
            for (const Edge& edge : model_.cfg_edges) {
                if (edge.source != block) continue;
                if (!edge.target.valid()) {
                    if (edge.kind != EdgeKind::Return) return false;
                    block_return = true;
                    saw_return = true;
                    continue;
                }
                if (block_return || !loop.body.count(edge.target)
                    || edge.target.value == loop.id.value
                    || loop.latches.count(edge.target)) return false;
                has_successor = true;
                auto dominators = model_.block_dominators.find(block.value);
                if (dominators != model_.block_dominators.end()
                    && dominators->second.count(edge.target.value)) return false;
                pending.push_back(edge.target);
            }
            if ((block_return && has_successor)
                || (!has_successor && !block_return)) return false;
        }
        if (!saw_return) return false;
        result.loop = &loop;
        result.true_is_latch = true_latch;
        result.latch_path_start = true_latch ? branch.true_target
                                             : branch.false_target;
        result.latch_path_blocks = true_latch ? true_latch_blocks
                                               : false_latch_blocks;
        result.terminal_start = terminal_start;
        return true;
    }

    bool decompose_cyclic_numeric_header_exit(
            const BranchContract& branch, CyclicNumericHeaderExit& result) const {
        if (branch.role != BranchRole::PreservedCyclic || !branch.join.valid())
            return false;
        auto loop_item = model_.authoritative_loops.find(LoopId(branch.source.value));
        auto kind = loop_kind_by_header_.find(branch.source.value);
        if (loop_item == model_.authoritative_loops.end()
            || kind == loop_kind_by_header_.end()
            || kind->second != NodeKind::NumericFor) return false;
        const AuthoritativeLoop& loop = loop_item->second;
        std::set<BlockId> true_latch_blocks, false_latch_blocks;
        const bool true_latch = recover_numeric_latch_path(
            loop, branch.true_target, true_latch_blocks);
        const bool false_latch = recover_numeric_latch_path(
            loop, branch.false_target, false_latch_blocks);
        if (true_latch == false_latch) return false;
        std::set<BlockId> normal_outside_targets;
        for (const Edge& edge : model_.cfg_edges)
            if (edge.source == loop.canonical_latch && edge.target.valid()
                && !loop.body.count(edge.target))
                normal_outside_targets.insert(edge.target);
        if (normal_outside_targets.size() != 1) return false;
        const BlockId normal_outside = *normal_outside_targets.begin();
        const BlockId exit_start = true_latch ? branch.false_target
                                              : branch.true_target;
        if (!loop.body.count(exit_start) || exit_start.value == loop.id.value
            || loop.latches.count(exit_start)) return false;
        std::vector<BlockId> pending{exit_start};
        bool saw_exit = false;
        while (!pending.empty()) {
            const BlockId block = pending.back(); pending.pop_back();
            if (!result.exit_blocks.insert(block).second) continue;
            if (!loop.body.count(block) || block.value == loop.id.value
                || loop.latches.count(block) || block_returns(block.value)) return false;
            bool has_successor = false;
            for (const Edge& edge : model_.cfg_edges) {
                if (edge.source != block) continue;
                if (!edge.target.valid()) return false;
                has_successor = true;
                if (!loop.body.count(edge.target)) {
                    if (edge.target != branch.join) return false;
                    saw_exit = true;
                    continue;
                }
                if (edge.target.value == loop.id.value
                    || loop.latches.count(edge.target)) return false;
                auto dominators = model_.block_dominators.find(block.value);
                if (dominators != model_.block_dominators.end()
                    && dominators->second.count(edge.target.value)) return false;
                pending.push_back(edge.target);
            }
            if (!has_successor) return false;
        }
        if (!saw_exit) return false;
        if (normal_outside != branch.join) {
            std::vector<BlockId> bridge_pending{normal_outside};
            bool bridge_reaches_join = false;
            while (!bridge_pending.empty()) {
                const BlockId block = bridge_pending.back();
                bridge_pending.pop_back();
                if (block == branch.join) {
                    bridge_reaches_join = true; continue;
                }
                if (!model_.reachable_blocks.count(block) || loop.body.count(block))
                    return false;
                if (!result.normal_bridge_blocks.insert(block).second) continue;
                if (block_returns(block.value)) return false;
                bool has_successor = false;
                for (const Edge& edge : model_.cfg_edges) {
                    if (edge.source != block || !edge.target.valid()) continue;
                    has_successor = true;
                    if (edge.target == branch.join) {
                        bridge_reaches_join = true; continue;
                    }
                    if (loop.body.count(edge.target)) return false;
                    auto dominators = model_.block_dominators.find(block.value);
                    if (dominators != model_.block_dominators.end()
                        && dominators->second.count(edge.target.value)) return false;
                    bridge_pending.push_back(edge.target);
                }
                if (!has_successor) return false;
            }
            if (!bridge_reaches_join || result.normal_bridge_blocks.empty())
                return false;
        }
        result.loop = &loop;
        result.true_is_latch = true_latch;
        result.latch_path_start = true_latch ? branch.true_target
                                             : branch.false_target;
        result.latch_path_blocks = true_latch ? true_latch_blocks
                                               : false_latch_blocks;
        result.exit_start = exit_start;
        result.outside = branch.join;
        result.normal_outside = normal_outside;
        return true;
    }

    bool decompose_shared_tail(const BranchContract& branch,
                               SharedTailBranch& result) const {
        const bool terminal_shared_tail = !branch.join.valid()
            && branch.virtual_exit_join
            && branch.true_has_terminal
            && branch.false_has_terminal;
        if (branch.role != BranchRole::PreservedShared) return false;
        std::set_intersection(branch.true_blocks.begin(), branch.true_blocks.end(),
                              branch.false_blocks.begin(), branch.false_blocks.end(),
                              std::inserter(result.shared_blocks,
                                            result.shared_blocks.begin()));
        if (result.shared_blocks.empty()) return false;
        std::set_difference(branch.true_blocks.begin(), branch.true_blocks.end(),
                            result.shared_blocks.begin(), result.shared_blocks.end(),
                            std::inserter(result.true_prefix,
                                          result.true_prefix.begin()));
        std::set_difference(branch.false_blocks.begin(), branch.false_blocks.end(),
                            result.shared_blocks.begin(), result.shared_blocks.end(),
                            std::inserter(result.false_prefix,
                                          result.false_prefix.begin()));

        std::set<BlockId> entries;
        if (result.shared_blocks.count(branch.true_target)) entries.insert(branch.true_target);
        if (result.shared_blocks.count(branch.false_target)) entries.insert(branch.false_target);
        for (const Edge& edge : model_.cfg_edges)
            if (edge.target.valid() && result.shared_blocks.count(edge.target)
                && !result.shared_blocks.count(edge.source)) entries.insert(edge.target);
        if (entries.size() != 1) return false;
        result.entry = *entries.begin();
        if ((!result.true_prefix.empty() && !result.true_prefix.count(branch.true_target))
            || (result.true_prefix.empty() && branch.true_target != result.entry)
            || (!result.false_prefix.empty() && !result.false_prefix.count(branch.false_target))
            || (result.false_prefix.empty() && branch.false_target != result.entry)) return false;

        bool recurrence_shared_tail = false;
        if (!branch.join.valid() && branch.virtual_exit_join
            && !terminal_shared_tail) {
            const AuthoritativeLoop* owner = nullptr;
            for (const auto& candidate : model_.authoritative_loops) {
                if (!candidate.second.body.count(branch.source)) continue;
                if (!owner || candidate.second.body.size() < owner->body.size())
                    owner = &candidate.second;
            }
            bool all_inside = owner != nullptr;
            if (owner)
                for (BlockId block : result.shared_blocks)
                    if (!owner->body.count(block)) { all_inside = false; break; }
            size_t exits = 0;
            bool internal_backedge = false, invalid_exit = false;
            if (all_inside) {
                for (const Edge& edge : model_.cfg_edges) {
                    if (!result.shared_blocks.count(edge.source)) continue;
                    if (!edge.target.valid()) { invalid_exit = true; continue; }
                    if (!result.shared_blocks.count(edge.target)) {
                        ++exits;
                        if (edge.target.value != owner->id.value
                            || edge.kind != EdgeKind::LoopBack)
                            invalid_exit = true;
                        continue;
                    }
                    auto dominators = model_.block_dominators.find(edge.source.value);
                    if (edge.kind == EdgeKind::LoopBack
                        || (dominators != model_.block_dominators.end()
                            && dominators->second.count(edge.target.value)))
                        internal_backedge = true;
                }
            }
            recurrence_shared_tail = all_inside && exits == 1
                && !internal_backedge && !invalid_exit;
            if (recurrence_shared_tail) {
                result.continuation = BlockId(owner->id.value);
                result.recurrence_loop = owner;
            }
        }
        if (!branch.join.valid() && !terminal_shared_tail
            && !recurrence_shared_tail) return false;

        // A common compiler shape is a direct true path into one shared tail and
        // a false-side short-circuit chain which chooses that same tail or one
        // enclosing continuation.  Prove the whole prefix is exactly that chain;
        // this lets the emitter materialize one decision without duplicating the
        // shared body or treating the continuation as locally owned code.
        if (result.true_prefix.empty() && !result.false_prefix.empty()
            && branch.true_target == result.entry) {
            auto gate = branches_by_block_.find(branch.false_target.value);
            if (gate != branches_by_block_.end()
                && (gate->second->role == BranchRole::ShortCircuitSharedTrue
                    || gate->second->role == BranchRole::ShortCircuitSharedFalse)) {
                const BranchContract* current = gate->second;
                std::set<BlockId> chain_sources;
                std::set<BlockId> seen;
                while ((current->role == BranchRole::ShortCircuitSharedTrue
                        || current->role == BranchRole::ShortCircuitSharedFalse)
                       && seen.insert(current->source).second) {
                    chain_sources.insert(current->source);
                    auto child = branches_by_block_.find(current->chain_next.value);
                    if (child == branches_by_block_.end()) {
                        current = nullptr;
                        break;
                    }
                    current = child->second;
                }
                if (current) chain_sources.insert(current->source);
                if (current && chain_sources == result.false_prefix) {
                    std::set<BlockId> outside_targets;
                    for (const Edge& edge : model_.cfg_edges)
                        if (result.false_prefix.count(edge.source)
                            && edge.target.valid()
                            && edge.target != result.entry
                            && edge.target != branch.join
                            && !result.false_prefix.count(edge.target))
                            outside_targets.insert(edge.target);
                    if (outside_targets.size() == 1) {
                        const BlockId escape = *outside_targets.begin();
                        const bool terminal_selects_pair =
                            (current->true_target == result.entry
                             && current->false_target == escape)
                            || (current->false_target == result.entry
                                && current->true_target == escape);
                        bool proven_escape = false;
                        if (terminal_selects_pair
                            && current->role == BranchRole::PreservedEscaping
                            && current->virtual_exit_join
                            && !current->join.valid()) {
                            size_t enclosing_arm_size = (size_t)-1;
                            for (const BranchContract& candidate
                                 : model_.authoritative_branches) {
                                if (candidate.source == branch.source) continue;
                                const bool in_true = candidate.true_blocks.count(
                                    branch.source) != 0;
                                const bool in_false = candidate.false_blocks.count(
                                    branch.source) != 0;
                                if (in_true == in_false) continue;
                                const std::set<BlockId>& arm = in_true
                                    ? candidate.true_blocks : candidate.false_blocks;
                                if (arm.size() >= enclosing_arm_size) continue;
                                if (escape == candidate.join
                                    || escape == candidate.source
                                    || arm.count(escape)) {
                                    proven_escape = true;
                                    enclosing_arm_size = arm.size();
                                }
                            }
                        }
                        if (proven_escape) {
                            result.false_gate = gate->second;
                            result.false_gate_escape = escape;
                        }
                    }
                }
            }
        }

        auto structural_exit = [&](const Edge& edge) {
            if (edge.kind == EdgeKind::LoopBack || edge.kind == EdgeKind::LoopExit
                || edge.kind == EdgeKind::Break || edge.kind == EdgeKind::Continue
                || edge.kind == EdgeKind::Return) return true;
            auto branch = branches_by_block_.find(edge.source.value);
            return branch != branches_by_block_.end()
                && (branch->second->role == BranchRole::ConditionalBreak
                    || branch->second->role == BranchRole::ConditionalContinue
                    || branch->second->role
                        == BranchRole::ConditionalBreakContinue);
        };
        if (terminal_shared_tail) {
            bool saw_return = false;
            std::set<BlockId> continuations;
            for (const Edge& edge : model_.cfg_edges) {
                if (!result.shared_blocks.count(edge.source)) continue;
                if (!edge.target.valid()) {
                    if (edge.kind != EdgeKind::Return) return false;
                    saw_return = true;
                } else if (!result.shared_blocks.count(edge.target)) {
                    continuations.insert(edge.target);
                }
            }
            if (!saw_return || continuations.size() > 1) return false;
            if (!continuations.empty()) {
                result.continuation = *continuations.begin();
                const BranchContract* enclosing = nullptr;
                const std::set<BlockId>* enclosing_arm = nullptr;
                size_t enclosing_arm_size = (size_t)-1;
                for (const BranchContract& candidate
                     : model_.authoritative_branches) {
                    if (candidate.source == branch.source) continue;
                    const bool in_true = candidate.true_blocks.count(branch.source) != 0;
                    const bool in_false = candidate.false_blocks.count(branch.source) != 0;
                    if (in_true == in_false) continue;
                    const std::set<BlockId>& arm = in_true
                        ? candidate.true_blocks : candidate.false_blocks;
                    const bool owns_continuation =
                        result.continuation == candidate.source
                        || result.continuation == candidate.join
                        || arm.count(result.continuation) != 0;
                    if (!owns_continuation) continue;
                    if (!enclosing || arm.size() < enclosing_arm_size) {
                        enclosing = &candidate;
                        enclosing_arm = &arm;
                        enclosing_arm_size = arm.size();
                    }
                }
                if (!enclosing || !enclosing_arm)
                    return false;
            }
        }
        // Prove two disjoint prefixes and one shared tail. Edges may leave this
        // partition only through the original join or an authoritative loop/return
        // transfer; arbitrary cross-prefix or forward escapes remain rejected.
        for (const Edge& edge : model_.cfg_edges) {
            if (result.shared_blocks.count(edge.source)) {
                if (edge.target.valid() && edge.target != branch.join
                    && edge.target != result.continuation
                    && !result.shared_blocks.count(edge.target)
                    && (!structural_exit(edge) || terminal_shared_tail)) return false;
            } else if (result.true_prefix.count(edge.source)) {
                if (edge.target.valid() && edge.target != branch.join
                    && edge.target != result.entry
                    && !result.true_prefix.count(edge.target)
                    && !structural_exit(edge)) return false;
            } else if (result.false_prefix.count(edge.source)) {
                if (edge.target.valid() && edge.target != branch.join
                    && edge.target != result.entry
                    && !result.false_prefix.count(edge.target)
                    && !(result.false_gate
                         && edge.target == result.false_gate_escape)
                    && !structural_exit(edge)) return false;
            }
        }
        return true;
    }

    bool collapse_short_circuit(const BranchContract& branch, int indent,
                                std::set<BlockId>& emitted_blocks,
                                std::ostringstream& out, std::set<BlockId>& seen,
                                bool consume_source, CollapsedBranch& collapsed) {
        if (!seen.insert(branch.source).second) {
            fail("RENDER_SHORT_CIRCUIT_CYCLE"); return false;
        }
        auto test = predicates_by_block_.find(branch.source.value);
        if (test == predicates_by_block_.end()) {
            fail("RENDER_BRANCH_TEST_MISSING"); return false;
        }
        if (consume_source) {
            if (block_has_source_events(branch.source)) {
                fail("RENDER_SHORT_CIRCUIT_SOURCE_HAS_EVENTS"); return false;
            }
            emit_block_events(branch.source, indent, emitted_blocks, out);
            if (!failures_.empty()) return false;
        }
        if (branch.role == BranchRole::Region) {
            collapsed.test = predicate(*test->second);
            collapsed.source_test = test->second;
            collapsed.true_target = branch.true_target;
            collapsed.false_target = branch.false_target;
            collapsed.join = branch.join;
            collapsed.virtual_exit_join = branch.virtual_exit_join;
            collapsed.true_blocks = branch.true_blocks;
            collapsed.false_blocks = branch.false_blocks;
            collapsed.true_has_terminal = branch.true_has_terminal;
            collapsed.false_has_terminal = branch.false_has_terminal;
            return failures_.empty();
        }
        if (branch.role != BranchRole::ShortCircuitSharedTrue
            && branch.role != BranchRole::ShortCircuitSharedFalse) {
            fail("RENDER_SHORT_CIRCUIT_CHILD_ROLE_PENDING"); return false;
        }
        auto child = branches_by_block_.find(branch.chain_next.value);
        if (child == branches_by_block_.end()) {
            fail("RENDER_SHORT_CIRCUIT_CHILD_MISSING"); return false;
        }
        CollapsedBranch right;
        if (!collapse_short_circuit(*child->second, indent, emitted_blocks, out,
                                    seen, true, right)) return false;
        const std::string left = predicate(*test->second);
        if (branch.role == BranchRole::ShortCircuitSharedTrue) {
            if (right.true_target != branch.chain_shared_target) {
                fail("RENDER_SHORT_CIRCUIT_TRUE_TARGET_MISMATCH"); return false;
            }
            collapsed.test = "(" + left + ") or (" + right.test + ")";
            collapsed.true_target = right.true_target;
            collapsed.false_target = right.false_target;
            collapsed.true_blocks = right.true_blocks;
            collapsed.false_blocks = right.false_blocks;
            collapsed.true_has_terminal = right.true_has_terminal;
            collapsed.false_has_terminal = right.false_has_terminal;
        } else {
            if (right.false_target != branch.chain_shared_target) {
                fail("RENDER_SHORT_CIRCUIT_FALSE_TARGET_MISMATCH"); return false;
            }
            collapsed.test = "(" + left + ") or not (" + right.test + ")";
            collapsed.true_target = right.false_target;
            collapsed.false_target = right.true_target;
            collapsed.true_blocks = right.false_blocks;
            collapsed.false_blocks = right.true_blocks;
            collapsed.true_has_terminal = right.false_has_terminal;
            collapsed.false_has_terminal = right.true_has_terminal;
        }
        collapsed.join = right.join;
        collapsed.virtual_exit_join = right.virtual_exit_join;
        return failures_.empty();
    }

    bool recover_bounded_region(BlockId start, BlockId stop,
                                std::set<BlockId>& blocks) const {
        std::vector<BlockId> pending;
        if (start != stop) pending.push_back(start);
        while (!pending.empty()) {
            const BlockId block = pending.back(); pending.pop_back();
            if (block == stop || blocks.count(block)) continue;
            if (!model_.reachable_blocks.count(block)) return false;
            blocks.insert(block);
            bool has_successor = false;
            for (const Edge& edge : model_.cfg_edges) {
                if (edge.source != block || !edge.target.valid()) continue;
                has_successor = true;
                if (edge.target == stop) continue;
                auto dominators = model_.block_dominators.find(block.value);
                if (dominators != model_.block_dominators.end()
                    && dominators->second.count(edge.target.value)) return false;
                pending.push_back(edge.target);
            }
            if (!has_successor || block_returns(block.value)) return false;
        }
        return true;
    }

    bool recover_bounded_or_terminal_region(BlockId start, BlockId stop,
                                            std::set<BlockId>& blocks,
                                            bool& reaches_stop,
                                            bool& reaches_terminal) const {
        reaches_stop = start == stop;
        reaches_terminal = false;
        std::vector<BlockId> pending;
        if (start != stop) pending.push_back(start);
        while (!pending.empty()) {
            const BlockId block = pending.back(); pending.pop_back();
            if (block == stop) { reaches_stop = true; continue; }
            if (blocks.count(block)) continue;
            if (!model_.reachable_blocks.count(block)) return false;
            blocks.insert(block);
            if (block_returns(block.value)) {
                reaches_terminal = true;
                continue;
            }
            bool has_successor = false;
            for (const Edge& edge : model_.cfg_edges) {
                if (edge.source != block || !edge.target.valid()) continue;
                has_successor = true;
                if (edge.target == stop) {
                    reaches_stop = true;
                    continue;
                }
                auto dominators = model_.block_dominators.find(block.value);
                if (dominators != model_.block_dominators.end()
                    && dominators->second.count(edge.target.value)) return false;
                pending.push_back(edge.target);
            }
            if (!has_successor) return false;
        }
        return reaches_stop;
    }

    bool analyze_short_terminal(const BranchContract& branch,
                                std::set<BlockId>& seen,
                                CollapsedBranch& collapsed) {
        if (!seen.insert(branch.source).second) {
            fail("RENDER_SHORT_CIRCUIT_CYCLE"); return false;
        }
        if (branch.role == BranchRole::Region
            || branch.role == BranchRole::PreservedEscaping
            || branch.role == BranchRole::ConditionalBreak
            || branch.role == BranchRole::ConditionalContinue
            || branch.role == BranchRole::ConditionalBreakContinue) {
            collapsed.true_target = branch.true_target;
            collapsed.false_target = branch.false_target;
            collapsed.join = branch.join;
            collapsed.virtual_exit_join = branch.virtual_exit_join;
            collapsed.true_blocks = branch.true_blocks;
            collapsed.false_blocks = branch.false_blocks;
            collapsed.true_has_terminal = branch.true_has_terminal;
            collapsed.false_has_terminal = branch.false_has_terminal;
            if (branch.role == BranchRole::PreservedEscaping
                && branch.join.valid()) {
                if (branch.true_escapes_region && collapsed.true_blocks.empty()
                    && !recover_bounded_region(branch.true_target, branch.join,
                                               collapsed.true_blocks)) {
                    fail("RENDER_ESCAPING_TRUE_ARM_NOT_BOUNDED"); return false;
                }
                if (branch.false_escapes_region && collapsed.false_blocks.empty()
                    && !recover_bounded_region(branch.false_target, branch.join,
                                               collapsed.false_blocks)) {
                    fail("RENDER_ESCAPING_FALSE_ARM_NOT_BOUNDED"); return false;
                }
                std::vector<BlockId> overlap;
                std::set_intersection(collapsed.true_blocks.begin(),
                                      collapsed.true_blocks.end(),
                                      collapsed.false_blocks.begin(),
                                      collapsed.false_blocks.end(),
                                      std::back_inserter(overlap));
                if (!overlap.empty()) {
                    fail("RENDER_ESCAPING_ARMS_OVERLAP"); return false;
                }
            }
            return true;
        }
        if (branch.role != BranchRole::ShortCircuitSharedTrue
            && branch.role != BranchRole::ShortCircuitSharedFalse) {
            fail("RENDER_SHORT_CIRCUIT_CHILD_ROLE_PENDING"); return false;
        }
        auto child = branches_by_block_.find(branch.chain_next.value);
        if (child == branches_by_block_.end()) {
            fail("RENDER_SHORT_CIRCUIT_CHILD_MISSING"); return false;
        }
        CollapsedBranch right;
        if (!analyze_short_terminal(*child->second, seen, right)) return false;
        if (branch.role == BranchRole::ShortCircuitSharedTrue) {
            if (right.true_target != branch.chain_shared_target) {
                fail("RENDER_SHORT_CIRCUIT_TRUE_TARGET_MISMATCH"); return false;
            }
            collapsed.true_target = right.true_target;
            collapsed.false_target = right.false_target;
            collapsed.true_blocks = right.true_blocks;
            collapsed.false_blocks = right.false_blocks;
            collapsed.true_has_terminal = right.true_has_terminal;
            collapsed.false_has_terminal = right.false_has_terminal;
        } else {
            if (right.false_target != branch.chain_shared_target) {
                fail("RENDER_SHORT_CIRCUIT_FALSE_TARGET_MISMATCH"); return false;
            }
            collapsed.true_target = right.false_target;
            collapsed.false_target = right.true_target;
            collapsed.true_blocks = right.false_blocks;
            collapsed.false_blocks = right.true_blocks;
            collapsed.true_has_terminal = right.false_has_terminal;
            collapsed.false_has_terminal = right.true_has_terminal;
        }
        collapsed.join = right.join;
        collapsed.virtual_exit_join = right.virtual_exit_join;
        return true;
    }

    void emit_short_decision(const BranchContract& branch, const std::string& result,
                             bool invert, bool consume_source, int indent,
                             std::set<BlockId>& emitted_blocks,
                             std::ostringstream& out) {
        if (consume_source) emit_block_events(branch.source, indent, emitted_blocks, out);
        if (!failures_.empty()) return;
        auto test = predicates_by_block_.find(branch.source.value);
        if (test == predicates_by_block_.end()) {
            fail("RENDER_BRANCH_TEST_MISSING"); return;
        }
        const std::string padding((size_t)indent * 4, ' ');
        if (branch.role == BranchRole::Region
            || branch.role == BranchRole::PreservedEscaping
            || branch.role == BranchRole::ConditionalBreak
            || branch.role == BranchRole::ConditionalContinue
            || branch.role == BranchRole::ConditionalBreakContinue) {
            out << padding << result << " = "
                << predicate(*test->second, invert) << '\n';
            return;
        }
        auto child = branches_by_block_.find(branch.chain_next.value);
        if (child == branches_by_block_.end()) {
            fail("RENDER_SHORT_CIRCUIT_CHILD_MISSING"); return;
        }
        out << padding << "if " << predicate(*test->second) << " then\n"
            << padding << "    " << result << " = "
            << (invert ? "false" : "true") << "\n"
            << padding << "else\n";
        const bool child_invert = branch.role == BranchRole::ShortCircuitSharedFalse
            ? !invert : invert;
        emit_short_decision(*child->second, result, child_invert, true,
                            indent + 1, emitted_blocks, out);
        out << padding << "end\n";
    }

    bool short_chain_has_joined_escape(const BranchContract& branch,
                                       std::set<BlockId>& seen) const {
        if (!seen.insert(branch.source).second) return false;
        if (branch.role == BranchRole::PreservedEscaping)
            return branch.join.valid()
                && (branch.true_escapes_region || branch.false_escapes_region);
        if (branch.role != BranchRole::ShortCircuitSharedTrue
            && branch.role != BranchRole::ShortCircuitSharedFalse) return false;
        auto child = branches_by_block_.find(branch.chain_next.value);
        return child != branches_by_block_.end()
            && short_chain_has_joined_escape(*child->second, seen);
    }

    const BranchContract* short_terminal_contract(const BranchContract& branch) const {
        const BranchContract* current = &branch;
        std::set<BlockId> seen;
        while ((current->role == BranchRole::ShortCircuitSharedTrue
                || current->role == BranchRole::ShortCircuitSharedFalse)
               && seen.insert(current->source).second) {
            auto child = branches_by_block_.find(current->chain_next.value);
            if (child == branches_by_block_.end()) return nullptr;
            current = child->second;
        }
        return current;
    }

    void emit_block_events(BlockId block, int indent, std::set<BlockId>& emitted_blocks,
                           std::ostringstream& out) {
        const std::pair<BlockId, BlockId> current_region = region_stack_.empty()
            ? std::make_pair(BlockId(), BlockId()) : region_stack_.back();
        if (!emitted_blocks.insert(block).second) {
            if (first_duplicate_prototype_ < 0) {
                first_duplicate_block_ = block;
                first_duplicate_prototype_ = model_.prototype.value;
                auto first = first_emission_regions_.find(block.value);
                if (first != first_emission_regions_.end()) {
                    duplicate_first_region_start_ = first->second.first;
                    duplicate_first_region_stop_ = first->second.second;
                }
                duplicate_second_region_start_ = current_region.first;
                duplicate_second_region_stop_ = current_region.second;
            }
            fail("RENDER_BLOCK_EMITTED_TWICE"); return;
        }
        first_emission_regions_[block.value] = current_region;
        auto range = model_.block_instruction_ranges.find(block.value);
        if (range == model_.block_instruction_ranges.end()) {
            fail("RENDER_BLOCK_RANGE_MISSING"); return;
        }
        for (int instruction = range->second.first;
             instruction <= range->second.second; ++instruction)
            emit_instruction(instruction, indent, out);
    }

    void emit_loop(const AuthoritativeLoop& loop, BlockId stop,
                   const std::set<BlockId>* outer_domain, int indent,
                   std::set<BlockId>& emitted_blocks, std::ostringstream& out) {
        auto kind = loop_kind_by_header_.find(loop.id.value);
        if (kind == loop_kind_by_header_.end()) {
            fail("RENDER_LOOP_SHAPE_MISSING"); return;
        }
        auto header_branch = branches_by_block_.find(loop.id.value);
        CyclicWhileIteration cyclic_while;
        if (header_branch != branches_by_block_.end()
            && decompose_cyclic_while_iteration(*header_branch->second,
                                                cyclic_while)) {
            auto header_test = predicates_by_block_.find(loop.id.value);
            if (header_test == predicates_by_block_.end()) {
                fail("RENDER_LOOP_TEST_MISSING"); return;
            }
            const std::string padding((size_t)indent * 4, ' ');
            const std::string branch_test = predicate(*header_test->second);
            const BlockId prefix_stop = cyclic_while.shared_blocks.empty()
                ? loop.canonical_latch : cyclic_while.shared_entry;
            active_loops_.insert(loop.id.value);
            out << padding << "while true do\n";
            emit_block_events(BlockId(loop.id.value), indent + 1,
                              emitted_blocks, out);
            if (!cyclic_while.true_prefix.empty()) {
                out << padding << "    if " << branch_test << " then\n";
                emit_region(header_branch->second->true_target, prefix_stop,
                            &cyclic_while.true_prefix, indent + 2,
                            emitted_blocks, out);
                if (!cyclic_while.false_prefix.empty()) {
                    out << padding << "    else\n";
                    emit_region(header_branch->second->false_target, prefix_stop,
                                &cyclic_while.false_prefix, indent + 2,
                                emitted_blocks, out);
                }
                out << padding << "    end\n";
            } else {
                out << padding << "    if not (" << branch_test << ") then\n";
                emit_region(header_branch->second->false_target, prefix_stop,
                            &cyclic_while.false_prefix, indent + 2,
                            emitted_blocks, out);
                out << padding << "    end\n";
            }
            if (!cyclic_while.shared_blocks.empty())
                emit_region(cyclic_while.shared_entry, loop.canonical_latch,
                            &cyclic_while.shared_blocks, indent + 1,
                            emitted_blocks, out);
            emit_block_events(loop.canonical_latch, indent + 1,
                              emitted_blocks, out);
            out << padding << "end\n";
            active_loops_.erase(loop.id.value);
            for (BlockId block : loop.body)
                if (!emitted_blocks.count(block))
                    fail("RENDER_LOOP_BLOCK_COVERAGE");
            return;
        }
        auto condition_item = loop_condition_by_header_.find(loop.id.value);
        if (condition_item == loop_condition_by_header_.end()) {
            fail("RENDER_LOOP_SHAPE_MISSING"); return;
        }
        const BranchContract& condition = *condition_item->second;
        auto test = predicates_by_block_.find(condition.source.value);
        if (test == predicates_by_block_.end()) {
            fail("RENDER_LOOP_TEST_MISSING"); return;
        }
        const bool true_inside = loop.body.count(condition.true_target) != 0;
        const bool false_inside = loop.body.count(condition.false_target) != 0;
        if (true_inside == false_inside) {
            fail("RENDER_LOOP_CONDITION_DIRECTION"); return;
        }
        const BlockId inside = true_inside ? condition.true_target : condition.false_target;
        const BlockId outside = true_inside ? condition.false_target : condition.true_target;
        const std::string padding((size_t)indent * 4, ' ');
        active_loops_.insert(loop.id.value);
        CyclicNumericHeaderExit cyclic_header_exit;
        CyclicNumericHeaderTerminal cyclic_header_terminal;
        bool has_cyclic_header_exit = false;
        bool has_cyclic_header_terminal = false;
        if (header_branch != branches_by_block_.end()
            && header_branch->second->role == BranchRole::PreservedCyclic) {
            has_cyclic_header_exit = decompose_cyclic_numeric_header_exit(
                *header_branch->second, cyclic_header_exit);
            if (!has_cyclic_header_exit)
                has_cyclic_header_terminal =
                    decompose_cyclic_numeric_header_terminal(
                        *header_branch->second, cyclic_header_terminal);
            if ((!has_cyclic_header_exit && !has_cyclic_header_terminal)
                || (has_cyclic_header_exit
                    && cyclic_header_exit.normal_outside != outside)) {
                fail("RENDER_CYCLIC_HEADER_EXIT_OUTSIDE_MISMATCH");
                active_loops_.erase(loop.id.value); return;
            }
            if (!cyclic_header_exit.normal_bridge_blocks.empty()) {
                const std::string skip = "skip_normal_exit_"
                    + std::to_string(model_.prototype.value) + "_"
                    + std::to_string(loop.id.value);
                cyclic_loop_skip_variables_[loop.id.value] = skip;
                out << padding << "local " << skip << " = false\n";
            }
        }
        if (kind->second == NodeKind::NumericFor) {
            auto prep = numeric_prep_test_by_loop_.find(loop.id.value);
            if (prep == numeric_prep_test_by_loop_.end()
                || prep->second->operands.size() != 3) {
                fail("RENDER_NUMERIC_FOR_PREP_MISSING");
                active_loops_.erase(loop.id.value); return;
            }
            const PredicateTestContract& header = *prep->second;
            const ExpressionDefinitionContract* variable = nullptr;
            for (const auto& value : model_.authoritative_expressions)
                if (value.kind == ExpressionKind::NumericLoopState
                    && value.identity.instruction == test->second->instruction
                    && value.identity.reg == header.raw_a + 2) {
                        if (variable) { variable = nullptr; break; }
                        variable = &value;
                }
            // DE FORNLOOP owns [limit, step, index] at A..A+2.  A+2 is the
            // source-visible loop variable; A+3 belongs only to generic-for
            // layouts and may be outside this prototype's frame entirely.
            if (!variable) {
                fail("RENDER_NUMERIC_FOR_VARIABLE_MISSING");
                active_loops_.erase(loop.id.value); return;
            }
            const std::string variable_target =
                web_name(web_by_origin_.at(variable->identity));
            const std::string iterator_name = frame_storage_
                ? "for_value_" + std::to_string(model_.prototype.value) + "_"
                    + std::to_string(loop.id.value)
                : variable_target;
            out << padding << "for " << iterator_name
                << " = " << origin_value(header.operands[2])
                << ", " << origin_value(header.operands[0])
                << ", " << origin_value(header.operands[1]) << " do\n";
            if (frame_storage_)
                out << padding << "    "
                    << variable_target << " = " << iterator_name << "\n";
            if (BlockId(loop.id.value) == loop.canonical_latch)
                emit_block_events(loop.canonical_latch, indent + 1,
                                  emitted_blocks, out);
            else
                emit_region(BlockId(loop.id.value), loop.canonical_latch, &loop.body,
                            indent + 1, emitted_blocks, out);
            if (!emitted_blocks.count(loop.canonical_latch)) {
                if (block_has_source_events(loop.canonical_latch))
                    fail("RENDER_FOR_LATCH_HAS_SOURCE_EVENTS");
                else emit_block_events(loop.canonical_latch, indent + 1,
                                       emitted_blocks, out);
            }
            out << padding << "end\n";
        } else if (kind->second == NodeKind::GenericFor) {
            if (test->second->kind != PredicateTestKind::GenericForAdvance
                || test->second->operands.size() != 3) {
                fail("RENDER_GENERIC_FOR_TEST_INVALID");
                active_loops_.erase(loop.id.value); return;
            }
            std::vector<const ExpressionDefinitionContract*> variables;
            for (const auto& value : model_.authoritative_expressions)
                if (value.kind == ExpressionKind::GenericLoopResult
                    && value.identity.instruction == test->second->instruction
                    && value.identity.reg >= test->second->raw_a + 3)
                    variables.push_back(&value);
            std::sort(variables.begin(), variables.end(), [](const auto* left,
                                                              const auto* right) {
                return left->identity.reg < right->identity.reg;
            });
            const int expected = (int)(test->second->raw_aux & 0xffu);
            if (expected < 1 || (int)variables.size() != expected) {
                fail("RENDER_GENERIC_FOR_VARIABLES_MISSING");
                active_loops_.erase(loop.id.value); return;
            }
            if (!emitted_blocks.count(condition.source)) {
                if (block_has_source_events(condition.source))
                    fail("RENDER_FOR_HEADER_HAS_SOURCE_EVENTS");
                else emit_block_events(condition.source, indent, emitted_blocks, out);
            }
            out << padding << "for ";
            std::vector<std::string> iterator_names;
            for (size_t index = 0; index < variables.size(); ++index) {
                if (index) out << ", ";
                iterator_names.push_back(frame_storage_
                    ? "for_value_" + std::to_string(model_.prototype.value) + "_"
                        + std::to_string(loop.id.value) + "_"
                        + std::to_string(index)
                    : web_name(web_by_origin_.at(variables[index]->identity)));
                out << iterator_names.back();
            }
            auto specialised = specialised_iterator_call_by_loop_.find(
                loop.id.value);
            if (specialised != specialised_iterator_call_by_loop_.end()) {
                auto producer = calls_.find(specialised->second);
                if (producer == calls_.end())
                    fail("RENDER_SPECIALISED_ITERATOR_PRODUCER_MISSING");
                else out << " in "
                         << specialised_iterator_call(*producer->second)
                         << " do\n";
            } else {
                out << " in " << origin_value(test->second->operands[0])
                    << ", " << origin_value(test->second->operands[1])
                    << ", " << origin_value(test->second->operands[2]) << " do\n";
            }
            if (frame_storage_) {
                out << padding << "    ";
                for (size_t index = 0; index < variables.size(); ++index) {
                    if (index) out << ", ";
                    out << web_name(web_by_origin_.at(variables[index]->identity));
                }
                out << " = ";
                for (size_t index = 0; index < iterator_names.size(); ++index) {
                    if (index) out << ", ";
                    out << iterator_names[index];
                }
                out << "\n";
            }
            emit_region(inside, condition.source, &loop.body, indent + 1,
                        emitted_blocks, out);
            out << padding << "end\n";
        } else if (kind->second == NodeKind::While) {
            std::string branch_test = predicate(*test->second);
            const std::string exit_test = true_inside
                ? "not (" + branch_test + ")" : branch_test;
            if (condition.source.value != loop.id.value) {
                fail("RENDER_WHILE_CONDITION_NOT_HEADER");
                active_loops_.erase(loop.id.value); return;
            }
            out << padding << "while true do\n";
            emit_block_events(condition.source, indent + 1, emitted_blocks, out);
            out << padding << "    if " << exit_test << " then break end\n";
            emit_region(inside, condition.source, &loop.body, indent + 1,
                        emitted_blocks, out);
            out << padding << "end\n";
        } else if (kind->second == NodeKind::Repeat) {
            std::string branch_test = predicate(*test->second);
            const std::string exit_test = true_inside
                ? "not (" + branch_test + ")" : branch_test;
            out << padding << "repeat\n";
            emit_region(BlockId(loop.id.value), condition.source, &loop.body, indent + 1,
                        emitted_blocks, out);
            emit_block_events(condition.source, indent + 1, emitted_blocks, out);
            out << padding << "until " << exit_test << '\n';
        } else {
            fail("RENDER_LOOP_KIND_INVALID");
        }
        active_loops_.erase(loop.id.value);
        const auto skip_variable = cyclic_loop_skip_variables_.find(loop.id.value);
        const std::string skip = skip_variable == cyclic_loop_skip_variables_.end()
            ? std::string() : skip_variable->second;
        cyclic_loop_skip_variables_.erase(loop.id.value);
        for (BlockId block : loop.body)
            if (!emitted_blocks.count(block)) fail("RENDER_LOOP_BLOCK_COVERAGE");
        if (!failures_.empty()) return;
        if (has_cyclic_header_exit) {
            if (!cyclic_header_exit.normal_bridge_blocks.empty()) {
                if (skip.empty()) {
                    fail("RENDER_CYCLIC_HEADER_SKIP_VARIABLE_MISSING"); return;
                }
                out << padding << "if not " << skip << " then\n";
                emit_region(cyclic_header_exit.normal_outside,
                            cyclic_header_exit.outside,
                            &cyclic_header_exit.normal_bridge_blocks,
                            indent + 1, emitted_blocks, out);
                out << padding << "end\n";
                if (!failures_.empty()) return;
            }
            emit_region(cyclic_header_exit.outside, stop, outer_domain, indent,
                        emitted_blocks, out);
        } else {
            emit_region(outside, stop, outer_domain, indent, emitted_blocks, out);
        }
    }

    void emit_region(BlockId start, BlockId stop, const std::set<BlockId>* domain,
                     int indent, std::set<BlockId>& emitted_blocks,
                     std::ostringstream& out) {
        if (!start.valid() || start == stop) return;
        if (!model_.reachable_blocks.count(start)) {
            fail("RENDER_REGION_TARGET_UNREACHABLE"); return;
        }
        if (domain && !domain->count(start)) {
            fail("RENDER_REGION_ESCAPES_DOMAIN"); return;
        }
        region_stack_.push_back(std::make_pair(start, stop));
        struct RegionFrame {
            std::vector<std::pair<BlockId, BlockId>>& stack;
            ~RegionFrame() { stack.pop_back(); }
        } region_frame{region_stack_};
        auto loop = loops_by_header_.find(start.value);
        if (loop != loops_by_header_.end() && !active_loops_.count(start.value)) {
            emit_loop(*loop->second, stop, domain, indent, emitted_blocks, out);
            return;
        }
        emit_block_events(start, indent, emitted_blocks, out);
        if (block_returns(start.value)) return;

        auto branch = branches_by_block_.find(start.value);
        if (branch != branches_by_block_.end()) {
            const BranchContract& contract = *branch->second;
            auto numeric_prep_loop = numeric_loops_by_prep_.find(start.value);
            auto numeric_prep_test = predicates_by_block_.find(start.value);
            if (numeric_prep_loop != numeric_loops_by_prep_.end()
                && numeric_prep_test != predicates_by_block_.end()
                && numeric_prep_test->second->kind
                    == PredicateTestKind::NumericForExhausted) {
                emit_loop(*numeric_prep_loop->second, stop, domain, indent,
                          emitted_blocks, out);
                return;
            }
            if (contract.role == BranchRole::LoopCondition
                && active_loops_.count(contract.loop.value)) return;
            if (contract.role == BranchRole::LoopCondition) {
                auto loop_item = model_.authoritative_loops.find(contract.loop);
                auto kind = loop_kind_by_header_.find(contract.loop.value);
                if (loop_item != model_.authoritative_loops.end()
                    && kind != loop_kind_by_header_.end()
                    && kind->second == NodeKind::NumericFor
                    && start == loop_item->second.prep) {
                    emit_loop(loop_item->second, stop, domain, indent,
                              emitted_blocks, out);
                    return;
                }
            }
            if (contract.role == BranchRole::ConditionalBreak
                || contract.role == BranchRole::ConditionalContinue
                || contract.role == BranchRole::ConditionalBreakContinue) {
                auto loop_item = model_.authoritative_loops.find(contract.loop);
                auto test = predicates_by_block_.find(start.value);
                if (loop_item == model_.authoritative_loops.end()
                    || !active_loops_.count(contract.loop.value)) {
                    fail("RENDER_LOOP_ACTION_OUTSIDE_ACTIVE_LOOP"); return;
                }
                if (test == predicates_by_block_.end()) {
                    fail("RENDER_BRANCH_TEST_MISSING"); return;
                }
                const AuthoritativeLoop& loop = loop_item->second;
                auto is_continue = [&](BlockId target) {
                    return target.value == loop.id.value
                        || target == loop.canonical_latch;
                };
                auto consume_structural_continue_target = [&](BlockId target) {
                    if (target.value == loop.id.value || emitted_blocks.count(target))
                        return true;
                    if (target != loop.canonical_latch || block_has_source_events(target))
                        return false;
                    emit_block_events(target, indent, emitted_blocks, out);
                    return failures_.empty();
                };
                const bool true_inside = loop.body.count(contract.true_target) != 0;
                const bool false_inside = loop.body.count(contract.false_target) != 0;
                const bool true_continue = is_continue(contract.true_target);
                const bool false_continue = is_continue(contract.false_target);
                const std::string padding((size_t)indent * 4, ' ');
                const std::string branch_test = predicate(*test->second);

                if (contract.role == BranchRole::ConditionalBreak) {
                    if (true_inside == false_inside) {
                        fail("RENDER_CONDITIONAL_BREAK_DIRECTION"); return;
                    }
                    const bool true_breaks = !true_inside;
                    const std::set<BlockId>& exit_blocks = true_breaks
                        ? contract.true_blocks : contract.false_blocks;
                    const BlockId exit_target = true_breaks
                        ? contract.true_target : contract.false_target;
                    const bool exit_terminal = true_breaks
                        ? contract.true_has_terminal : contract.false_has_terminal;
                    out << padding << "if "
                        << (true_breaks ? branch_test : "not (" + branch_test + ")")
                        << " then\n";
                    if (exit_blocks.empty())
                        out << padding << "    break\n";
                    else if (exit_terminal)
                        emit_region(exit_target, BlockId(), &exit_blocks, indent + 1,
                                    emitted_blocks, out);
                    else {
                        fail("RENDER_BREAK_EXIT_ARM_NONTERMINAL"); return;
                    }
                    out << padding << "end\n";
                    emit_region(true_inside ? contract.true_target : contract.false_target,
                                stop, domain, indent, emitted_blocks, out);
                    return;
                }
                if (contract.role == BranchRole::ConditionalContinue) {
                    if (true_continue == false_continue) {
                        fail("RENDER_CONDITIONAL_CONTINUE_DIRECTION"); return;
                    }
                    const BlockId continue_target = true_continue
                        ? contract.true_target : contract.false_target;
                    if (!consume_structural_continue_target(continue_target)) {
                        fail("RENDER_CONTINUE_TARGET_HAS_SOURCE_EVENTS"); return;
                    }
                    out << padding << "if "
                        << (true_continue ? branch_test : "not (" + branch_test + ")")
                        << " then continue end\n";
                    const BlockId next = true_continue
                        ? contract.false_target : contract.true_target;
                    if (!loop.body.count(next)) {
                        fail("RENDER_CONTINUE_FALLTHROUGH_OUTSIDE_LOOP"); return;
                    }
                    emit_region(next, stop, domain, indent, emitted_blocks, out);
                    return;
                }
                if (!(true_continue && !false_inside)
                    && !(false_continue && !true_inside)) {
                    fail("RENDER_BREAK_CONTINUE_DIRECTION"); return;
                }
                const BlockId continue_target = true_continue
                    ? contract.true_target : contract.false_target;
                if (!consume_structural_continue_target(continue_target)) {
                    fail("RENDER_CONTINUE_TARGET_HAS_SOURCE_EVENTS"); return;
                }
                const std::set<BlockId>& exit_blocks = true_continue
                    ? contract.false_blocks : contract.true_blocks;
                const BlockId exit_target = true_continue
                    ? contract.false_target : contract.true_target;
                const bool exit_terminal = true_continue
                    ? contract.false_has_terminal : contract.true_has_terminal;
                auto emit_exit_action = [&]() {
                    if (exit_blocks.empty()) out << padding << "    break\n";
                    else if (exit_terminal)
                        emit_region(exit_target, BlockId(), &exit_blocks, indent + 1,
                                    emitted_blocks, out);
                    else fail("RENDER_BREAK_EXIT_ARM_NONTERMINAL");
                };
                out << padding << "if " << branch_test << " then\n";
                if (true_continue) out << padding << "    continue\n";
                else emit_exit_action();
                out << padding << "else\n";
                if (true_continue) emit_exit_action();
                else out << padding << "    continue\n";
                out << padding << "end\n";
                return;
            }
            if (contract.role == BranchRole::PreservedCyclic) {
                CyclicNumericHeaderExit cyclic;
                CyclicNumericHeaderTerminal terminal;
                auto test = predicates_by_block_.find(start.value);
                const bool is_exit =
                    decompose_cyclic_numeric_header_exit(contract, cyclic);
                const bool is_terminal = !is_exit
                    && decompose_cyclic_numeric_header_terminal(contract, terminal);
                if (!is_exit && !is_terminal) {
                    fail("RENDER_PRESERVED_CYCLIC_PENDING"); return;
                }
                const AuthoritativeLoop* owner = is_exit ? cyclic.loop : terminal.loop;
                if (!owner || !active_loops_.count(owner->id.value)) {
                    fail("RENDER_CYCLIC_HEADER_OUTSIDE_ACTIVE_LOOP"); return;
                }
                if (test == predicates_by_block_.end()) {
                    fail("RENDER_BRANCH_TEST_MISSING"); return;
                }
                const std::string padding((size_t)indent * 4, ' ');
                const std::string branch_test = predicate(*test->second);
                if (is_terminal) {
                    out << padding << "if "
                        << (terminal.true_is_latch
                            ? "not (" + branch_test + ")" : branch_test)
                        << " then\n";
                    emit_region(terminal.terminal_start, BlockId(),
                                &terminal.terminal_blocks, indent + 1,
                                emitted_blocks, out);
                    if (!failures_.empty()) return;
                    out << padding << "end\n";
                    emit_region(terminal.latch_path_start,
                                terminal.loop->canonical_latch,
                                &terminal.latch_path_blocks, indent,
                                emitted_blocks, out);
                    return;
                }
                out << padding << "if "
                    << (cyclic.true_is_latch
                        ? "not (" + branch_test + ")" : branch_test)
                    << " then\n";
                emit_region(cyclic.exit_start, cyclic.outside,
                            &cyclic.exit_blocks, indent + 1,
                            emitted_blocks, out);
                if (!failures_.empty()) return;
                auto skip = cyclic_loop_skip_variables_.find(cyclic.loop->id.value);
                if (!cyclic.normal_bridge_blocks.empty()) {
                    if (skip == cyclic_loop_skip_variables_.end()) {
                        fail("RENDER_CYCLIC_HEADER_SKIP_VARIABLE_MISSING"); return;
                    }
                    out << padding << "    " << skip->second << " = true\n";
                }
                out << padding << "    break\n"
                    << padding << "end\n";
                emit_region(cyclic.latch_path_start,
                            cyclic.loop->canonical_latch,
                            &cyclic.latch_path_blocks, indent,
                            emitted_blocks, out);
                return;
            }
            if ((contract.role == BranchRole::ShortCircuitSharedTrue
                 || contract.role == BranchRole::ShortCircuitSharedFalse)
                && contract.chain_shared_target == stop
                && contract.true_target == stop
                && contract.false_target == contract.chain_next) {
                auto test = predicates_by_block_.find(start.value);
                if (test == predicates_by_block_.end()) {
                    fail("RENDER_BRANCH_TEST_MISSING"); return;
                }
                const std::string padding((size_t)indent * 4, ' ');
                out << padding << "if " << predicate(*test->second) << " then\n"
                    << padding << "else\n";
                emit_region(contract.chain_next, stop, domain, indent + 1,
                            emitted_blocks, out);
                out << padding << "end\n";
                return;
            }
            if (contract.role == BranchRole::Region && contract.join.valid()) {
                const bool true_direct_join = contract.true_target == contract.join
                    && contract.true_blocks.empty();
                const bool false_direct_join = contract.false_target == contract.join
                    && contract.false_blocks.empty();
                if (true_direct_join != false_direct_join) {
                    const BlockId nested_start = true_direct_join
                        ? contract.false_target : contract.true_target;
                    const std::set<BlockId>& nested_domain = true_direct_join
                        ? contract.false_blocks : contract.true_blocks;
                    auto nested_item = branches_by_block_.find(nested_start.value);
                    if (nested_item != branches_by_block_.end()) {
                        const BranchContract& nested = *nested_item->second;
                        const bool bounded_short_boundary =
                            (nested.role == BranchRole::ShortCircuitSharedTrue
                             || nested.role == BranchRole::ShortCircuitSharedFalse)
                            && nested_domain.count(nested.source)
                            && nested.chain_next == contract.join
                            && nested.false_target == contract.join
                            && nested.true_target == nested.chain_shared_target
                            && nested.chain_shared_target.valid();
                        std::set<BlockId> bridge_blocks;
                        const bool bridge_bounded = bounded_short_boundary
                            && recover_bounded_region(contract.join,
                                                      nested.chain_shared_target,
                                                      bridge_blocks);
                        std::vector<BlockId> overlap;
                        std::set_intersection(bridge_blocks.begin(), bridge_blocks.end(),
                                              nested_domain.begin(), nested_domain.end(),
                                              std::back_inserter(overlap));
                        if (bridge_bounded && !bridge_blocks.empty() && overlap.empty()) {
                            auto outer_test = predicates_by_block_.find(start.value);
                            auto nested_test = predicates_by_block_.find(
                                nested.source.value);
                            if (outer_test == predicates_by_block_.end()
                                || nested_test == predicates_by_block_.end()) {
                                fail("RENDER_BRANCH_TEST_MISSING"); return;
                            }
                            const std::string padding((size_t)indent * 4, ' ');
                            const std::string decision = "short_boundary_"
                                + std::to_string(model_.prototype.value) + "_"
                                + std::to_string(contract.source.value);
                            const std::string direct_condition = true_direct_join
                                ? predicate(*outer_test->second)
                                : "not (" + predicate(*outer_test->second) + ")";
                            out << padding << "local " << decision << "\n"
                                << padding << "if " << direct_condition << " then\n"
                                << padding << "    " << decision << " = true\n"
                                << padding << "else\n";
                            emit_block_events(nested.source, indent + 1,
                                              emitted_blocks, out);
                            if (!failures_.empty()) return;
                            out << padding << "    " << decision << " = not ("
                                << predicate(*nested_test->second) << ")\n"
                                << padding << "end\n"
                                << padding << "if " << decision << " then\n";
                            emit_region(contract.join, nested.chain_shared_target,
                                        &bridge_blocks, indent + 1,
                                        emitted_blocks, out);
                            out << padding << "end\n";
                            if (!failures_.empty()) return;
                            emit_region(nested.chain_shared_target, stop, domain,
                                        indent, emitted_blocks, out);
                            return;
                        }
                    }
                }
            }
            if (contract.role == BranchRole::PreservedShared) {
                SharedTailBranch shared;
                auto test = predicates_by_block_.find(start.value);
                if (!decompose_shared_tail(contract, shared)) {
                    fail("RENDER_PRESERVED_SHARED_PENDING"); return;
                }
                if (test == predicates_by_block_.end()) {
                    fail("RENDER_BRANCH_TEST_MISSING"); return;
                }
                if (shared.recurrence_loop
                    && !active_loops_.count(shared.recurrence_loop->id.value)) {
                    fail("RENDER_SHARED_RECURRENCE_OUTSIDE_ACTIVE_LOOP"); return;
                }
                const std::string padding((size_t)indent * 4, ' ');
                const std::string branch_test = predicate(*test->second);
                if (shared.false_gate) {
                    std::set<BlockId> seen;
                    CollapsedBranch gate_branch;
                    if (!analyze_short_terminal(*shared.false_gate, seen,
                                                gate_branch)) return;
                    const bool true_selects_shared =
                        gate_branch.true_target == shared.entry;
                    const bool false_selects_shared =
                        gate_branch.false_target == shared.entry;
                    const bool true_selects_escape =
                        gate_branch.true_target == shared.false_gate_escape;
                    const bool false_selects_escape =
                        gate_branch.false_target == shared.false_gate_escape;
                    if (true_selects_shared == false_selects_shared
                        || true_selects_escape == false_selects_escape
                        || true_selects_shared != false_selects_escape) {
                        fail("RENDER_SHARED_FALSE_GATE_DIRECTION"); return;
                    }
                    const std::string decision = "shared_gate_"
                        + std::to_string(model_.prototype.value) + "_"
                        + std::to_string(contract.source.value);
                    out << padding << "local " << decision << "\n"
                        << padding << "if " << branch_test << " then\n"
                        << padding << "    " << decision << " = true\n"
                        << padding << "else\n";
                    emit_short_decision(*shared.false_gate, decision,
                                        false_selects_shared, true, indent + 1,
                                        emitted_blocks, out);
                    out << padding << "end\n";
                    if (!failures_.empty()) return;
                    out << padding << "if " << decision << " then\n";
                    const BlockId shared_stop = shared.continuation.valid()
                        ? shared.continuation : contract.join;
                    emit_region(shared.entry, shared_stop,
                                &shared.shared_blocks, indent + 1,
                                emitted_blocks, out);
                    out << padding << "end\n";
                    if (!failures_.empty()) return;
                    emit_region(contract.join, stop, domain, indent,
                                emitted_blocks, out);
                    return;
                }
                if (!shared.true_prefix.empty()) {
                    out << padding << "if " << branch_test << " then\n";
                    emit_region(contract.true_target, shared.entry, &shared.true_prefix,
                                indent + 1, emitted_blocks, out);
                    if (!shared.false_prefix.empty()) {
                        out << padding << "else\n";
                        emit_region(contract.false_target, shared.entry,
                                    &shared.false_prefix, indent + 1,
                                    emitted_blocks, out);
                    }
                    out << padding << "end\n";
                } else if (!shared.false_prefix.empty()) {
                    out << padding << "if not (" << branch_test << ") then\n";
                    emit_region(contract.false_target, shared.entry,
                                &shared.false_prefix, indent + 1,
                                emitted_blocks, out);
                    out << padding << "end\n";
                } else {
                    fail("RENDER_PRESERVED_SHARED_EMPTY_PREFIXES"); return;
                }
                if (!failures_.empty()) return;
                const BlockId shared_stop = shared.continuation.valid()
                    ? shared.continuation : contract.join;
                emit_region(shared.entry, shared_stop, &shared.shared_blocks,
                            indent, emitted_blocks, out);
                if (!failures_.empty()) return;
                emit_region(contract.join, stop, domain, indent, emitted_blocks, out);
                return;
            }
            if (contract.role == BranchRole::Region && contract.join.valid()) {
                const bool true_direct_join = contract.true_target == contract.join
                    && contract.true_blocks.empty();
                const bool false_direct_join = contract.false_target == contract.join
                    && contract.false_blocks.empty();
                if (true_direct_join != false_direct_join) {
                    const BlockId nested_start = true_direct_join
                        ? contract.false_target : contract.true_target;
                    const std::set<BlockId>& nested_domain = true_direct_join
                        ? contract.false_blocks : contract.true_blocks;
                    auto nested_item = branches_by_block_.find(nested_start.value);
                    if (nested_item != branches_by_block_.end()
                        && nested_item->second->role == BranchRole::PreservedEscaping) {
                        const BranchContract& nested = *nested_item->second;
                        const bool nested_true_bridge = nested.true_escapes_region
                            && nested.true_target == contract.join
                            && nested.true_blocks.empty();
                        const bool nested_false_bridge = nested.false_escapes_region
                            && nested.false_target == contract.join
                            && nested.false_blocks.empty();
                        const bool nested_true_tail = nested.true_target == nested.join
                            && nested.true_blocks.empty();
                        const bool nested_false_tail = nested.false_target == nested.join
                            && nested.false_blocks.empty();
                        const bool bridge_tail_pair = nested.join.valid()
                            && nested_domain.count(nested.source)
                            && nested_domain.count(nested.join)
                            && ((nested_true_bridge && nested_false_tail)
                                || (nested_false_bridge && nested_true_tail));
                        std::set<BlockId> bridge_blocks;
                        const bool bridge_bounded = bridge_tail_pair
                            && recover_bounded_region(contract.join, nested.join,
                                                      bridge_blocks);
                        std::vector<BlockId> overlap;
                        std::set_intersection(bridge_blocks.begin(), bridge_blocks.end(),
                                              nested_domain.begin(), nested_domain.end(),
                                              std::back_inserter(overlap));
                        if (bridge_bounded && !bridge_blocks.empty() && overlap.empty()) {
                            auto outer_test = predicates_by_block_.find(start.value);
                            auto nested_test = predicates_by_block_.find(
                                nested.source.value);
                            if (outer_test == predicates_by_block_.end()
                                || nested_test == predicates_by_block_.end()) {
                                fail("RENDER_BRANCH_TEST_MISSING"); return;
                            }
                            const std::string padding((size_t)indent * 4, ' ');
                            const std::string decision = "bridge_"
                                + std::to_string(model_.prototype.value) + "_"
                                + std::to_string(contract.source.value);
                            const std::string outer_condition = true_direct_join
                                ? predicate(*outer_test->second)
                                : "not (" + predicate(*outer_test->second) + ")";
                            const std::string nested_condition = nested_true_bridge
                                ? predicate(*nested_test->second)
                                : "not (" + predicate(*nested_test->second) + ")";
                            out << padding << "local " << decision << "\n"
                                << padding << "if " << outer_condition << " then\n"
                                << padding << "    " << decision << " = true\n"
                                << padding << "else\n";
                            emit_block_events(nested.source, indent + 1,
                                              emitted_blocks, out);
                            if (!failures_.empty()) return;
                            out << padding << "    " << decision << " = "
                                << nested_condition << "\n"
                                << padding << "end\n"
                                << padding << "if " << decision << " then\n";
                            emit_region(contract.join, nested.join, &bridge_blocks,
                                        indent + 1, emitted_blocks, out);
                            out << padding << "end\n";
                            if (!failures_.empty()) return;
                            emit_region(nested.join, stop, &nested_domain, indent,
                                        emitted_blocks, out);
                            return;
                        }
                        const bool virtual_two_way_escape = nested.virtual_exit_join
                            && !nested.join.valid()
                            && nested.true_escapes_region
                            && nested.false_escapes_region
                            && nested.true_blocks.empty()
                            && nested.false_blocks.empty();
                        const bool true_selects_outer_join = virtual_two_way_escape
                            && nested.true_target == contract.join;
                        const bool false_selects_outer_join = virtual_two_way_escape
                            && nested.false_target == contract.join;
                        if (true_selects_outer_join != false_selects_outer_join) {
                            const BlockId alternate_tail = true_selects_outer_join
                                ? nested.false_target : nested.true_target;
                            std::set<BlockId> terminal_bridge;
                            bool reaches_tail = false, reaches_terminal = false;
                            const bool terminal_bridge_bounded =
                                nested_domain.count(nested.source)
                                && nested_domain.count(alternate_tail)
                                && recover_bounded_or_terminal_region(
                                    contract.join, alternate_tail, terminal_bridge,
                                    reaches_tail, reaches_terminal);
                            std::vector<BlockId> terminal_overlap;
                            std::set_intersection(terminal_bridge.begin(),
                                                  terminal_bridge.end(),
                                                  nested_domain.begin(),
                                                  nested_domain.end(),
                                                  std::back_inserter(terminal_overlap));
                            if (terminal_bridge_bounded && reaches_tail
                                && reaches_terminal && !terminal_bridge.empty()
                                && terminal_overlap.empty()) {
                                auto outer_test = predicates_by_block_.find(start.value);
                                auto nested_test = predicates_by_block_.find(
                                    nested.source.value);
                                if (outer_test == predicates_by_block_.end()
                                    || nested_test == predicates_by_block_.end()) {
                                    fail("RENDER_BRANCH_TEST_MISSING"); return;
                                }
                                const std::string padding((size_t)indent * 4, ' ');
                                const std::string decision = "terminal_bridge_"
                                    + std::to_string(model_.prototype.value) + "_"
                                    + std::to_string(contract.source.value);
                                const std::string outer_condition = true_direct_join
                                    ? predicate(*outer_test->second)
                                    : "not (" + predicate(*outer_test->second) + ")";
                                const std::string nested_condition =
                                    true_selects_outer_join
                                    ? predicate(*nested_test->second)
                                    : "not (" + predicate(*nested_test->second) + ")";
                                out << padding << "local " << decision << "\n"
                                    << padding << "if " << outer_condition << " then\n"
                                    << padding << "    " << decision << " = true\n"
                                    << padding << "else\n";
                                emit_block_events(nested.source, indent + 1,
                                                  emitted_blocks, out);
                                if (!failures_.empty()) return;
                                out << padding << "    " << decision << " = "
                                    << nested_condition << "\n"
                                    << padding << "end\n"
                                    << padding << "if " << decision << " then\n";
                                emit_region(contract.join, alternate_tail,
                                            &terminal_bridge, indent + 1,
                                            emitted_blocks, out);
                                out << padding << "end\n";
                                if (!failures_.empty()) return;
                                emit_region(alternate_tail, stop, &nested_domain,
                                            indent, emitted_blocks, out);
                                return;
                            }
                        }
                    }
                }
            }
            if (contract.role == BranchRole::PreservedEscaping) {
                const bool true_is_escape = contract.true_escapes_region
                    && contract.true_target == stop && contract.true_blocks.empty();
                const bool false_is_escape = contract.false_escapes_region
                    && contract.false_target == stop && contract.false_blocks.empty();
                const bool other_terminal = true_is_escape
                    ? contract.false_has_terminal : contract.true_has_terminal;
                if (contract.virtual_exit_join && !contract.join.valid()
                    && true_is_escape != false_is_escape && other_terminal) {
                    auto test = predicates_by_block_.find(start.value);
                    if (test == predicates_by_block_.end()) {
                        fail("RENDER_BRANCH_TEST_MISSING"); return;
                    }
                    const std::string padding((size_t)indent * 4, ' ');
                    out << padding << "if " << predicate(*test->second) << " then\n";
                    emit_region(contract.true_target, stop, &contract.true_blocks,
                                indent + 1, emitted_blocks, out);
                    if (!contract.false_blocks.empty()) {
                        out << padding << "else\n";
                        emit_region(contract.false_target, stop, &contract.false_blocks,
                                    indent + 1, emitted_blocks, out);
                    }
                    out << padding << "end\n";
                    return;
                }
                fail("RENDER_PRESERVED_ESCAPING_SHAPE_PENDING"); return;
            }
            CollapsedBranch rendered_branch;
            const BranchContract* chain_terminal = nullptr;
            if (contract.role == BranchRole::ShortCircuitSharedTrue
                || contract.role == BranchRole::ShortCircuitSharedFalse) {
                chain_terminal = short_terminal_contract(contract);
                std::set<BlockId> seen;
                if (!analyze_short_terminal(contract, seen, rendered_branch)) return;
                const std::string decision = "sc_"
                    + std::to_string(model_.prototype.value) + "_"
                    + std::to_string(contract.source.value);
                out << std::string((size_t)indent * 4, ' ')
                    << "local " << decision << "\n";
                emit_short_decision(contract, decision, false, false, indent,
                                    emitted_blocks, out);
                rendered_branch.test = decision;
            } else if (contract.role == BranchRole::Region) {
                auto test = predicates_by_block_.find(start.value);
                if (test == predicates_by_block_.end()) {
                    fail("RENDER_BRANCH_TEST_MISSING"); return;
                }
                auto chain = branches_by_block_.find(contract.false_target.value);
                std::set<BlockId> escape_seen;
                if (chain != branches_by_block_.end()
                    && (chain->second->role == BranchRole::ShortCircuitSharedTrue
                        || chain->second->role == BranchRole::ShortCircuitSharedFalse)
                    && contract.true_target == chain->second->chain_shared_target
                    && short_chain_has_joined_escape(*chain->second, escape_seen)) {
                    std::set<BlockId> seen;
                    if (!analyze_short_terminal(*chain->second, seen,
                                                rendered_branch)) return;
                    const std::string decision = "sc_"
                        + std::to_string(model_.prototype.value) + "_"
                        + std::to_string(contract.source.value);
                    const std::string decision_padding((size_t)indent * 4, ' ');
                    out << decision_padding << "local " << decision << "\n"
                        << decision_padding << "if " << predicate(*test->second)
                        << " then\n"
                        << decision_padding << "    " << decision << " = true\n"
                        << decision_padding << "else\n";
                    emit_short_decision(*chain->second, decision, false, true,
                                        indent + 1, emitted_blocks, out);
                    out << decision_padding << "end\n";
                    rendered_branch.test = decision;
                } else {
                    rendered_branch.test = predicate(*test->second);
                    rendered_branch.source_test = test->second;
                    rendered_branch.true_target = contract.true_target;
                    rendered_branch.false_target = contract.false_target;
                    rendered_branch.join = contract.join;
                    rendered_branch.virtual_exit_join = contract.virtual_exit_join;
                    rendered_branch.true_blocks = contract.true_blocks;
                    rendered_branch.false_blocks = contract.false_blocks;
                    rendered_branch.true_has_terminal = contract.true_has_terminal;
                    rendered_branch.false_has_terminal = contract.false_has_terminal;
                }
            } else {
                fail("RENDER_BRANCH_ROLE_PENDING"); return;
            }
            if (chain_terminal
                && (chain_terminal->role == BranchRole::ConditionalBreak
                    || chain_terminal->role == BranchRole::ConditionalContinue
                    || chain_terminal->role == BranchRole::ConditionalBreakContinue)) {
                auto loop_item = model_.authoritative_loops.find(chain_terminal->loop);
                if (loop_item == model_.authoritative_loops.end()
                    || !active_loops_.count(chain_terminal->loop.value)) {
                    fail("RENDER_LOOP_ACTION_OUTSIDE_ACTIVE_LOOP"); return;
                }
                const AuthoritativeLoop& loop = loop_item->second;
                auto is_continue = [&](BlockId target) {
                    return target.value == loop.id.value
                        || target == loop.canonical_latch;
                };
                const bool true_continue = is_continue(rendered_branch.true_target);
                const bool false_continue = is_continue(rendered_branch.false_target);
                const std::string padding((size_t)indent * 4, ' ');
                const bool true_inside = loop.body.count(rendered_branch.true_target) != 0;
                const bool false_inside = loop.body.count(rendered_branch.false_target) != 0;
                auto consume_continue = [&](BlockId target) {
                    if (target.value == loop.id.value || emitted_blocks.count(target))
                        return true;
                    if (target != loop.canonical_latch || block_has_source_events(target))
                        return false;
                    emit_block_events(target, indent, emitted_blocks, out);
                    return failures_.empty();
                };
                if (chain_terminal->role == BranchRole::ConditionalContinue) {
                    if (true_continue == false_continue) {
                        fail("RENDER_CONDITIONAL_CONTINUE_DIRECTION"); return;
                    }
                    const BlockId continue_target = true_continue
                        ? rendered_branch.true_target : rendered_branch.false_target;
                    if (!consume_continue(continue_target)) {
                        fail("RENDER_CONTINUE_TARGET_HAS_SOURCE_EVENTS"); return;
                    }
                    out << padding << "if "
                        << (true_continue ? rendered_branch.test
                                          : "not (" + rendered_branch.test + ")")
                        << " then continue end\n";
                    const BlockId next = true_continue
                        ? rendered_branch.false_target : rendered_branch.true_target;
                    if (!loop.body.count(next)) {
                        fail("RENDER_CONTINUE_FALLTHROUGH_OUTSIDE_LOOP"); return;
                    }
                    emit_region(next, stop, domain, indent, emitted_blocks, out);
                    return;
                }
                if (chain_terminal->role == BranchRole::ConditionalBreak) {
                    if (true_inside == false_inside) {
                        fail("RENDER_CONDITIONAL_BREAK_DIRECTION"); return;
                    }
                    const bool true_breaks = !true_inside;
                    const std::set<BlockId>& exit_blocks = true_breaks
                        ? rendered_branch.true_blocks : rendered_branch.false_blocks;
                    const BlockId exit_target = true_breaks
                        ? rendered_branch.true_target : rendered_branch.false_target;
                    const bool exit_terminal = true_breaks
                        ? rendered_branch.true_has_terminal
                        : rendered_branch.false_has_terminal;
                    out << padding << "if "
                        << (true_breaks ? rendered_branch.test
                                        : "not (" + rendered_branch.test + ")")
                        << " then\n";
                    if (exit_blocks.empty()) out << padding << "    break\n";
                    else if (exit_terminal)
                        emit_region(exit_target, BlockId(), &exit_blocks, indent + 1,
                                    emitted_blocks, out);
                    else {
                        fail("RENDER_BREAK_EXIT_ARM_NONTERMINAL"); return;
                    }
                    out << padding << "end\n";
                    emit_region(true_inside ? rendered_branch.true_target
                                            : rendered_branch.false_target,
                                stop, domain, indent, emitted_blocks, out);
                    return;
                }
                if (!(true_continue && !false_inside)
                    && !(false_continue && !true_inside)) {
                    fail("RENDER_BREAK_CONTINUE_DIRECTION"); return;
                }
                const BlockId continue_target = true_continue
                    ? rendered_branch.true_target : rendered_branch.false_target;
                if (!consume_continue(continue_target)) {
                    fail("RENDER_CONTINUE_TARGET_HAS_SOURCE_EVENTS"); return;
                }
                const std::set<BlockId>& exit_blocks = true_continue
                    ? rendered_branch.false_blocks : rendered_branch.true_blocks;
                const BlockId exit_target = true_continue
                    ? rendered_branch.false_target : rendered_branch.true_target;
                const bool exit_terminal = true_continue
                    ? rendered_branch.false_has_terminal
                    : rendered_branch.true_has_terminal;
                auto emit_exit_action = [&]() {
                    if (exit_blocks.empty()) out << padding << "    break\n";
                    else if (exit_terminal)
                        emit_region(exit_target, BlockId(), &exit_blocks, indent + 1,
                                    emitted_blocks, out);
                    else fail("RENDER_BREAK_EXIT_ARM_NONTERMINAL");
                };
                out << padding << "if " << rendered_branch.test << " then\n";
                if (true_continue) out << padding << "    continue\n";
                else emit_exit_action();
                out << padding << "else\n";
                if (true_continue) emit_exit_action();
                else out << padding << "    continue\n";
                out << padding << "end\n";
                return;
            }
            const std::string padding((size_t)indent * 4, ' ');
            // Do not render a direct-join true edge as an empty `then` followed
            // by a populated `else`.  Although that source is logically
            // equivalent, Luau lowers it to an inverted compare plus an extra
            // JUMP.  DE's original form is the single compare that skips a
            // guarded body.  Live Rhino `_T.rhinoRoar` initialization proved
            // the alternate shape can select the wrong arm in the game VM.
            // Invert only the structurally proved direct-join case; both arm
            // domains and the authoritative join remain unchanged.
            const bool invert_empty_true = rendered_branch.true_blocks.empty()
                && !rendered_branch.false_blocks.empty()
                && rendered_branch.true_target == rendered_branch.join;
            std::string final_test = rendered_branch.source_test
                ? predicate(*rendered_branch.source_test, invert_empty_true)
                : invert_empty_true ? "not (" + rendered_branch.test + ")"
                                    : rendered_branch.test;
            // Give a compound boolean its own join before entering the arm it
            // controls.  Without this boundary Luau can fuse the short-circuit
            // CFG into a following loop; the recompiled Saryn corpus fixture
            // then loses loop ownership even though the truth table is right.
            // This rule applies to every compound predicate, not one ability.
            if (rendered_branch.source_test
                && compound_predicate(*rendered_branch.source_test)) {
                const std::string decision = "predicate_value_"
                    + std::to_string(model_.prototype.value) + "_"
                    + std::to_string(rendered_branch.source_test->block.value);
                out << padding << "local " << decision << " = " << final_test << "\n";
                final_test = decision;
            }
            if (invert_empty_true) {
                out << padding << "if " << final_test << " then\n";
                emit_region(rendered_branch.false_target, rendered_branch.join,
                            &rendered_branch.false_blocks,
                            indent + 1, emitted_blocks, out);
            } else {
                out << padding << "if " << final_test << " then\n";
                emit_region(rendered_branch.true_target, rendered_branch.join,
                            &rendered_branch.true_blocks,
                            indent + 1, emitted_blocks, out);
                if (!rendered_branch.false_blocks.empty()) {
                    out << padding << "else\n";
                    emit_region(rendered_branch.false_target,
                                rendered_branch.join,
                                &rendered_branch.false_blocks,
                                indent + 1, emitted_blocks, out);
                } else if (rendered_branch.false_target
                           != rendered_branch.join) {
                    fail("RENDER_EMPTY_FALSE_ARM_TARGET_MISMATCH");
                }
            }
            out << padding << "end\n";
            if (rendered_branch.join.valid())
                emit_region(rendered_branch.join, stop, domain, indent,
                            emitted_blocks, out);
            else if (!rendered_branch.virtual_exit_join)
                fail("RENDER_BRANCH_JOIN_MISSING");
            return;
        }

        std::vector<Edge> successors;
        for (const Edge& edge : model_.cfg_edges)
            if (edge.source == start && edge.target.valid()) successors.push_back(edge);
        if (successors.empty()) return;
        if (successors.size() != 1) {
            fail("RENDER_CONTROL_SUCCESSOR_ARITY"); return;
        }
        emit_region(successors[0].target, stop, domain, indent, emitted_blocks, out);
    }

public:
    explicit Renderer(const Model& model,
                      const std::map<int, Model>* module_models = nullptr,
                      std::vector<std::string> upvalue_names = {})
        : model_(model), module_models_(module_models),
          upvalue_names_(std::move(upvalue_names)) {
        for (const ValueWebContract& web : model.authoritative_value_webs)
            for (const ValueOriginContract& origin : web.members) web_by_origin_[origin] = web.id;
        for (const LocalValueContract& local : model.authoritative_local_values)
            if (local.parameter) {
                auto web = web_by_origin_.find(local.identity);
                if (web != web_by_origin_.end()) {
                    parameter_webs_.insert(web->second);
                    parameter_reg_by_web_[web->second] = local.identity.reg;
                }
            }
        for (const auto& value : model.authoritative_expressions) {
            expression_by_origin_[value.identity] = &value;
            expressions_by_instruction_[value.identity.instruction].push_back(&value);
        }
        for (const auto& value : model.authoritative_definition_emissions)
            emission_by_origin_[value.identity] = &value;
        for (const auto& value : model.authoritative_calls) calls_[value.instruction] = &value;
        for (const auto& value : model.authoritative_returns) returns_[value.instruction] = &value;
        for (const auto& value : model.authoritative_store_operations) stores_[value.instruction] = &value;
        for (const auto& value : model.authoritative_table_operations) tables_[value.instruction] = &value;
        for (const auto& value : model.authoritative_closures)
            closures_[value.instruction] = &value;
        for (const auto& value : model.authoritative_branches)
            branches_by_block_[value.source.value] = &value;
        for (const auto& value : model.authoritative_predicate_tests)
            predicates_by_block_[value.block.value] = &value;
        for (const auto& value : model.authoritative_predicate_expressions)
            predicate_expressions_by_block_[value.block.value] = &value;
        for (const auto& value : model.authoritative_loops)
            loops_by_header_[value.first.value] = &value.second;
        for (const auto& value : model.nodes)
            if (value.second.loop.valid()
                && (value.second.kind == NodeKind::While
                    || value.second.kind == NodeKind::Repeat
                    || value.second.kind == NodeKind::NumericFor
                    || value.second.kind == NodeKind::GenericFor))
                loop_kind_by_header_[value.second.loop.value] = value.second.kind;
        for (const auto& value : model.authoritative_branches)
            if (value.role == BranchRole::LoopCondition && value.loop.valid())
                loop_condition_by_header_[value.loop.value] = &value;
        // A generic for whose source body always breaks has no natural backedge
        // through the body.  The region classifier can therefore label FORGLOOP
        // as an ordinary region branch even though the opcode still owns exact
        // generic-for semantics.  Recover only the opcode-proven header identity.
        for (const auto& loop : model.authoritative_loops) {
            auto kind = loop_kind_by_header_.find(loop.first.value);
            if (kind == loop_kind_by_header_.end()
                || kind->second != NodeKind::GenericFor
                || loop_condition_by_header_.count(loop.first.value)) continue;
            auto branch = branches_by_block_.find(loop.first.value);
            auto test = predicates_by_block_.find(loop.first.value);
            if (branch != branches_by_block_.end()
                && test != predicates_by_block_.end()
                && test->second->kind == PredicateTestKind::GenericForAdvance)
                loop_condition_by_header_[loop.first.value] = branch->second;
        }
        for (const auto& loop : model.authoritative_loops) {
            auto kind = loop_kind_by_header_.find(loop.first.value);
            if (kind == loop_kind_by_header_.end()
                || kind->second != NodeKind::NumericFor) continue;
            numeric_loops_by_prep_[loop.second.prep.value] = &loop.second;
            auto test = predicates_by_block_.find(loop.second.prep.value);
            if (test != predicates_by_block_.end()
                && test->second->kind == PredicateTestKind::NumericForExhausted)
                numeric_prep_test_by_loop_[loop.first.value] = test->second;
        }
        for (const auto& value : model.authoritative_calls)
            if (value.open_argument_origin_kind == (int)vf::TopKind::OpenCall) {
                open_result_producers_.insert(value.open_argument_origin_instruction);
                open_result_consumers_[value.open_argument_origin_instruction]
                    = value.instruction;
            }
        for (const auto& value : model.authoritative_returns)
            if (value.open_origin_kind == (int)vf::TopKind::OpenCall) {
                open_result_producers_.insert(value.open_origin_instruction);
                open_result_consumers_[value.open_origin_instruction] = value.instruction;
            }
        for (const auto& value : model.authoritative_table_operations)
            if (value.list_open_origin_kind == (int)vf::TopKind::OpenCall) {
                open_result_producers_.insert(value.list_open_origin_instruction);
                open_result_consumers_[value.list_open_origin_instruction]
                    = value.instruction;
            }

        // Preserve DE's specialised stock iterator preps.  This is deliberately
        // stricter than recognising a callee name: the three loop operands must
        // be the exact three fixed results of one call, the call must be in the
        // loop's prep block, no observable effect may sit between it and the
        // prep terminator, and those result definitions may be used only by the
        // paired prep/FORGLOOP instructions.  Those conditions make folding the
        // call into the source `for` header an order-preserving representation,
        // not a heuristic rewrite.
        const bool iterator_trace = std::getenv("RENOVICE_ITERATOR_TRACE") != nullptr;
        for (const auto& loop_item : model.authoritative_loops) {
            const AuthoritativeLoop& loop = loop_item.second;
            auto kind = loop_kind_by_header_.find(loop_item.first.value);
            auto test_item = predicates_by_block_.find(loop_item.first.value);
            if (iterator_trace)
                std::fprintf(stderr, "ITERTRACE proto=%d loop=%d prep=%d kind=%d test=%d\n",
                             model.prototype.value, loop_item.first.value, loop.prep.value,
                             kind == loop_kind_by_header_.end() ? -1 : (int)kind->second,
                             test_item == predicates_by_block_.end()
                                 ? -1 : (int)test_item->second->kind);
            if (kind == loop_kind_by_header_.end()
                || kind->second != NodeKind::GenericFor
                || test_item == predicates_by_block_.end()
                || test_item->second->kind != PredicateTestKind::GenericForAdvance
                || test_item->second->operands.size() != 3) continue;
            const PredicateTestContract& test = *test_item->second;

            int producer_instruction = -1;
            bool exact_triplet = true;
            if (test.operands[0].size() == 1) {
                const ValueOriginContract& first = *test.operands[0].begin();
                if (first.kind == 2) producer_instruction = first.instruction;
            }
            for (size_t slot = 0; slot < 3; ++slot) {
                const auto& origins = test.operands[slot];
                if (iterator_trace) {
                    std::fprintf(stderr, "ITERTRACE operand=%zu origins=%zu", slot,
                                 origins.size());
                    for (const ValueOriginContract& traced : origins)
                        std::fprintf(stderr, " k%d/i%d/r%d", traced.kind,
                                     traced.instruction, traced.reg);
                    std::fprintf(stderr, "\n");
                }
                bool saw_producer = false;
                int producer_reg = -1;
                for (const ValueOriginContract& origin : origins) {
                    if (origin.kind != 2) { exact_triplet = false; break; }
                    if (origin.instruction == producer_instruction) {
                        if (saw_producer) { exact_triplet = false; break; }
                        saw_producer = true; producer_reg = origin.reg;
                    } else if (slot != 2
                               || origin.instruction != test.instruction) {
                        exact_triplet = false; break;
                    }
                }
                if (!saw_producer) exact_triplet = false;
                if (slot == 2)
                    for (const ValueOriginContract& origin : origins)
                        if (origin.instruction == test.instruction
                            && origin.reg != producer_reg)
                            exact_triplet = false;
                if (!exact_triplet) break;
            }
            auto producer_item = calls_.find(producer_instruction);
            if (iterator_trace)
                std::fprintf(stderr, "ITERTRACE candidate exact=%d producer=%d found=%d\n",
                             exact_triplet ? 1 : 0, producer_instruction,
                             producer_item == calls_.end() ? 0 : 1);
            if (!exact_triplet || producer_item == calls_.end()) continue;
            const CallContract& producer = *producer_item->second;
            if (iterator_trace)
                std::fprintf(stderr,
                             "ITERTRACE call block=%d results=%d first=%d args=%zu open=%d method=%d callee=%zu\n",
                             producer.block.value, producer.result_count,
                             producer.result_first, producer.fixed_argument_origins.size(),
                             producer.open_argument_origin_kind,
                             producer.method_call ? 1 : 0,
                             producer.callee_origins.size());
            if (producer.method_call || producer.result_count != 3
                || producer.fixed_argument_origins.size() != 1
                || producer.open_argument_origin_kind >= 0
                || producer.block != loop.prep
                || producer.callee_origins.size() != 1) continue;
            for (size_t slot = 0; slot < 3; ++slot) {
                auto origin = std::find_if(
                    test.operands[slot].begin(), test.operands[slot].end(),
                    [&](const ValueOriginContract& value) {
                        return value.kind == 2
                            && value.instruction == producer_instruction;
                    });
                if (origin == test.operands[slot].end()
                    || origin->reg != producer.result_first + (int)slot) {
                    exact_triplet = false; break;
                }
            }
            if (!exact_triplet) continue;

            auto callee_expression = expression_by_origin_.find(
                *producer.callee_origins.begin());
            if (iterator_trace && callee_expression != expression_by_origin_.end())
                std::fprintf(stderr, "ITERTRACE callee kind=%d name=%s\n",
                             (int)callee_expression->second->kind,
                             callee_expression->second->name.c_str());
            if (callee_expression == expression_by_origin_.end()
                || (callee_expression->second->kind != ExpressionKind::ImportRead
                    && callee_expression->second->kind
                        != ExpressionKind::GlobalRead)
                || (callee_expression->second->name != "ipairs"
                    && callee_expression->second->name != "pairs")) continue;

            // The direct builtin spelling below replaces the callee read as well as
            // the call.  Suppress that read only when its value belongs exclusively
            // to this producer and is not captured.  Otherwise retaining the read is
            // required for access-count/evaluation-order fidelity, so fail closed and
            // leave the original materialised generic iterator untouched.
            const ValueOriginContract& callee_origin
                = *producer.callee_origins.begin();
            bool callee_exclusive = false;
            for (const LocalValueContract& local : model.authoritative_local_values) {
                if (!(local.identity == callee_origin)) continue;
                callee_exclusive = local.copied_by_captures.empty()
                    && local.shared_by_captures.empty();
                for (const LocalUseSite& use : local.uses)
                    if (use.instruction != producer.instruction) {
                        callee_exclusive = false; break;
                    }
                break;
            }
            if (!callee_exclusive) continue;

            auto prep_range = model.block_instruction_ranges.find(loop.prep.value);
            if (prep_range == model.block_instruction_ranges.end()
                || producer.instruction >= prep_range->second.second) continue;
            const int prep_instruction = prep_range->second.second;
            if (iterator_trace)
                std::fprintf(stderr, "ITERTRACE prep_instruction=%d producer=%d\n",
                             prep_instruction, producer.instruction);
            bool reordered_effect = false;
            for (EffectId effect : model.observable_effects)
                if (effect.value > producer.instruction
                    && effect.value < prep_instruction) {
                    reordered_effect = true; break;
                }
            if (reordered_effect) continue;

            for (size_t slot = 0; slot < 3 && exact_triplet; ++slot) {
                auto producer_origin = std::find_if(
                    test.operands[slot].begin(), test.operands[slot].end(),
                    [&](const ValueOriginContract& value) {
                        return value.kind == 2
                            && value.instruction == producer_instruction;
                    });
                if (producer_origin == test.operands[slot].end()) {
                    exact_triplet = false; break;
                }
                bool found_local = false;
                for (const LocalValueContract& local : model.authoritative_local_values) {
                    if (!(local.identity == *producer_origin)) continue;
                    found_local = true;
                    for (const LocalUseSite& use : local.uses)
                        if (use.instruction != prep_instruction
                            && use.instruction != test.instruction) {
                            exact_triplet = false; break;
                        }
                    break;
                }
                if (!found_local) exact_triplet = false;
            }
            if (!exact_triplet) continue;
            if (iterator_trace)
                std::fprintf(stderr, "ITERTRACE ACCEPT proto=%d loop=%d producer=%d\n",
                             model.prototype.value, loop_item.first.value,
                             producer.instruction);
            specialised_iterator_call_by_loop_[loop_item.first.value]
                = producer.instruction;
            specialised_iterator_call_producers_.insert(producer.instruction);
            specialised_iterator_scaffolding_instructions_.insert(
                callee_origin.instruction);
        }
    }

    void validate_contracts(bool dispatcher = false) {
        if (!model_.renderer_ready || !model_.ownership_conflicts.empty())
            fail("RENDER_MODEL_NOT_VERIFIED");
        if (!dispatcher) for (const BranchContract& branch : model_.authoritative_branches)
            switch (branch.role) {
                case BranchRole::Region:
                case BranchRole::LoopCondition:
                case BranchRole::ConditionalBreak:
                case BranchRole::ConditionalContinue:
                case BranchRole::ConditionalBreakContinue:
                case BranchRole::ShortCircuitSharedTrue:
                case BranchRole::ShortCircuitSharedFalse:
                case BranchRole::PreservedEscaping:
                    break;
                case BranchRole::Redundant:
                    fail("RENDER_REDUNDANT_PREDICATE_PENDING"); break;
                case BranchRole::PreservedCyclic: {
                    CyclicNumericHeaderExit cyclic;
                    CyclicNumericHeaderTerminal terminal;
                    CyclicWhileIteration while_iteration;
                    if (!decompose_cyclic_numeric_header_exit(branch, cyclic)
                        && !decompose_cyclic_numeric_header_terminal(
                            branch, terminal)
                        && !decompose_cyclic_while_iteration(
                            branch, while_iteration))
                        fail("RENDER_PRESERVED_CYCLIC_PENDING");
                    break;
                }
                case BranchRole::PreservedShared: {
                    SharedTailBranch shared;
                    if (!decompose_shared_tail(branch, shared))
                        fail("RENDER_PRESERVED_SHARED_PENDING");
                    break;
                }
                case BranchRole::Unresolved:
                    fail("RENDER_UNRESOLVED_BRANCH"); break;
            }
        if (!model_.authoritative_closures.empty() && !module_models_)
            fail("RENDER_CLOSURE_MODULE_CONTEXT_MISSING");
        if (model_.authoritative_upvalue_count != (int)upvalue_names_.size())
            fail("RENDER_UPVALUE_CONTEXT_MISSING");
        if (!model_.authoritative_scope_closes.empty() && !module_models_)
            fail("RENDER_SCOPE_CLOSE_MODULE_CONTEXT_MISSING");
        for (const auto& range : open_result_consumers_) {
            if (range.first < 0 || range.second <= range.first
                || !calls_.count(range.first)) {
                fail("RENDER_OPEN_RANGE_INVALID"); continue;
            }
            for (EffectId effect : model_.observable_effects)
                if (effect.value > range.first && effect.value < range.second)
                    fail("RENDER_OPEN_RANGE_EFFECT_INTERLEAVE");
        }
        if (!dispatcher)
            for (const Edge& edge : model_.cfg_edges)
                if (edge.kind == EdgeKind::Break || edge.kind == EdgeKind::Continue)
                    fail("RENDER_NONLINEAR_TRANSFER_PENDING");
        if (dispatcher) {
            for (const auto& test : predicates_by_block_)
                if (test.second->kind == PredicateTestKind::Preserved)
                    fail("RENDER_DISPATCHER_PREDICATE_PENDING");
        }
        std::set<EffectId> represented_effects;
        for (const auto& value : model_.authoritative_calls)
            represented_effects.insert(EffectId(value.instruction));
        for (const auto& value : model_.authoritative_returns)
            represented_effects.insert(EffectId(value.instruction));
        for (const auto& value : model_.authoritative_store_operations)
            represented_effects.insert(EffectId(value.instruction));
        for (const auto& value : model_.authoritative_table_operations)
            if (value.effect_order >= 0) represented_effects.insert(EffectId(value.instruction));
        for (const auto& value : model_.authoritative_closures)
            represented_effects.insert(EffectId(value.instruction));
        // CLOSEUPVALS is a lexical cell-lifetime boundary, not an independently observable
        // operation in the effect manifest. Module rendering preserves it through distinct
        // source locals/capture bindings; adding its instruction here would invent an effect.
        if (represented_effects != model_.observable_effects)
            fail("RENDER_OBSERVABLE_EFFECT_COVERAGE");
    }

    Result render_function_literal_structured(int indent = 0) {
        const Node& root = model_.nodes.at(model_.root);
        size_t non_parameter_webs = 0;
        for (const ValueWebContract& web : model_.authoritative_value_webs)
            if (!parameter_webs_.count(web.id)) ++non_parameter_webs;
        // The Luau compiler has a hard 200-local-register ceiling. Keep 40
        // registers of headroom for loop variables, capture snapshots, branch
        // decisions, and compiler temporaries; smaller functions retain normal
        // readable locals, while only provably high-pressure functions use a
        // private value frame.
        frame_storage_ = non_parameter_webs
            + (size_t)std::max(0, root.parameter_count) >= 160;
        if (frame_storage_) used_frame_storage_ = true;
        validate_contracts();
        if (!failures_.empty()) return {false, "", failures_};
        std::ostringstream out;
        out << "function(";
        for (int parameter = 0; parameter < root.parameter_count; ++parameter) {
            if (parameter) out << ", ";
            out << 'p' << model_.prototype.value << '_' << parameter;
        }
        if (root.accepts_varargs) {
            if (root.parameter_count) out << ", ";
            out << "...";
        }
        out << ")\n";
        const std::string body_padding((size_t)(indent + 1) * 4, ' ');
        if (frame_storage_)
            out << body_padding << "local frame_" << model_.prototype.value << " = {}\n";
        else
            for (const ValueWebContract& web : model_.authoritative_value_webs)
                if (!parameter_webs_.count(web.id))
                    out << body_padding << "local " << web_name(web.id) << "\n";

        std::set<BlockId> emitted_blocks;
        emit_region(BlockId(0), BlockId(), &model_.reachable_blocks, indent + 1,
                    emitted_blocks, out);
        if (emitted_blocks != model_.reachable_blocks)
            fail("RENDER_BLOCK_COVERAGE");
        out << std::string((size_t)indent * 4, ' ') << "end";
        Result result;
        result.ok = failures_.empty();
        result.used_dispatcher = used_dispatcher_;
        result.used_frame_storage = used_frame_storage_;
        result.source = result.ok ? out.str() : "";
        result.failures = failures_;
        result.first_duplicate_block = first_duplicate_block_;
        result.first_duplicate_prototype = first_duplicate_prototype_;
        result.duplicate_first_region_start = duplicate_first_region_start_;
        result.duplicate_first_region_stop = duplicate_first_region_stop_;
        result.duplicate_second_region_start = duplicate_second_region_start_;
        result.duplicate_second_region_stop = duplicate_second_region_stop_;
        std::set_difference(model_.reachable_blocks.begin(), model_.reachable_blocks.end(),
                            emitted_blocks.begin(), emitted_blocks.end(),
                            std::inserter(result.missing_blocks,
                                          result.missing_blocks.end()));
        return result;
    }

    Result render_function_literal_dispatcher(int indent = 0) {
        // A flat dispatcher keeps many SSA/value webs simultaneously addressable.
        // Declaring every web as a function-long Luau local exceeds the VM's 200
        // local-register ceiling even though the original prototype is valid.  One
        // private table preserves exact per-web storage while keeping only one local.
        frame_storage_ = true;
        validate_contracts(true);
        if (!failures_.empty()) return {false, "", failures_};
        const Node& root = model_.nodes.at(model_.root);
        std::ostringstream out;
        out << "function(";
        for (int parameter = 0; parameter < root.parameter_count; ++parameter) {
            if (parameter) out << ", ";
            out << 'p' << model_.prototype.value << '_' << parameter;
        }
        if (root.accepts_varargs) {
            if (root.parameter_count) out << ", ";
            out << "...";
        }
        out << ")\n";
        const int body_indent = indent + 1;
        const std::string body_padding((size_t)body_indent * 4, ' ');
        out << body_padding << "local frame_" << model_.prototype.value << " = {}\n";
        const std::string control = "cfg_" + std::to_string(model_.prototype.value);
        out << body_padding << "local " << control << " = 0\n";

        auto is_for = [&](const AuthoritativeLoop& loop) {
            auto kind = loop_kind_by_header_.find(loop.id.value);
            return kind != loop_kind_by_header_.end()
                && (kind->second == NodeKind::NumericFor
                    || kind->second == NodeKind::GenericFor);
        };
        std::map<int, const AuthoritativeLoop*> for_by_prep;
        std::map<int, std::set<BlockId>> for_bodies;
        std::map<int, std::set<BlockId>> direct_domains;
        std::set<BlockId> root_domain = model_.reachable_blocks;
        for (const auto& item : model_.authoritative_loops) {
            const AuthoritativeLoop& loop = item.second;
            if (!is_for(loop)) continue;
            if (!loop.prep.valid() || loop.body.count(loop.prep)) {
                fail("RENDER_DISPATCHER_FOR_PREP_INVALID"); continue;
            }
            if (!for_by_prep.emplace(loop.prep.value, &loop).second)
                fail("RENDER_DISPATCHER_FOR_PREP_AMBIGUOUS");
            std::set<BlockId> effective_body = loop.body;
            auto kind = loop_kind_by_header_.find(loop.id.value);
            auto condition = loop_condition_by_header_.find(loop.id.value);
            if (kind != loop_kind_by_header_.end()
                && kind->second == NodeKind::GenericFor
                && condition != loop_condition_by_header_.end()
                && !effective_body.count(condition->second->true_target)) {
                // FORGLOOP's taken edge is the iteration body.  In the exact
                // `for ... do break end` family that path never returns to the
                // header, so natural-loop membership omits it.  The verified
                // region contract still supplies the exact taken-arm blocks.
                if (effective_body.count(condition->second->false_target)
                    || condition->second->true_blocks.empty()
                    || !condition->second->true_blocks.count(
                        condition->second->true_target)) {
                    fail("RENDER_DISPATCHER_GENERIC_BREAK_BODY_MISSING");
                } else {
                    effective_body.insert(condition->second->true_blocks.begin(),
                                          condition->second->true_blocks.end());
                }
            }
            for_bodies[loop.id.value] = std::move(effective_body);
            for (BlockId block : for_bodies[loop.id.value]) root_domain.erase(block);
        }
        for (const auto& item : model_.authoritative_loops) {
            const AuthoritativeLoop& loop = item.second;
            if (!is_for(loop)) continue;
            std::set<BlockId> domain = for_bodies.at(loop.id.value);
            for (const auto& nested_item : model_.authoritative_loops) {
                const AuthoritativeLoop& nested = nested_item.second;
                if (!is_for(nested) || nested.id == loop.id) continue;
                const std::set<BlockId>& nested_body = for_bodies.at(nested.id.value);
                const std::set<BlockId>& loop_body = for_bodies.at(loop.id.value);
                if (std::includes(loop_body.begin(), loop_body.end(),
                                  nested_body.begin(), nested_body.end()))
                    for (BlockId block : nested_body) domain.erase(block);
            }
            direct_domains[loop.id.value] = std::move(domain);
        }
        if (!failures_.empty()) return {false, "", failures_};

        std::set<BlockId> emitted_blocks;

        std::function<void(const std::set<BlockId>&, const AuthoritativeLoop*, int)>
            emit_dispatch_domain;
        std::function<void(const AuthoritativeLoop&, int)> emit_dispatch_for;

        emit_dispatch_for = [&](const AuthoritativeLoop& loop, int line_indent) {
            auto kind = loop_kind_by_header_.find(loop.id.value);
            auto condition_item = loop_condition_by_header_.find(loop.id.value);
            auto domain_item = direct_domains.find(loop.id.value);
            if (kind == loop_kind_by_header_.end()
                || condition_item == loop_condition_by_header_.end()
                || domain_item == direct_domains.end()) {
                fail("RENDER_DISPATCHER_FOR_CONTRACT_MISSING"); return;
            }
            const BranchContract& condition = *condition_item->second;
            auto condition_test = predicates_by_block_.find(condition.source.value);
            if (condition_test == predicates_by_block_.end()) {
                fail("RENDER_DISPATCHER_FOR_TEST_MISSING"); return;
            }
            const std::set<BlockId>& effective_body = for_bodies.at(loop.id.value);
            const bool true_inside = effective_body.count(condition.true_target) != 0;
            const bool false_inside = effective_body.count(condition.false_target) != 0;
            if (true_inside == false_inside) {
                fail("RENDER_DISPATCHER_FOR_DIRECTION"); return;
            }
            const BlockId inside = true_inside
                ? condition.true_target : condition.false_target;
            const BlockId outside = true_inside
                ? condition.false_target : condition.true_target;
            if (!inside.valid() || !outside.valid()) {
                fail("RENDER_DISPATCHER_FOR_TARGET_INVALID"); return;
            }
            const std::string padding((size_t)line_indent * 4, ' ');
            const std::string leave = "leave_for_"
                + std::to_string(model_.prototype.value) + "_"
                + std::to_string(loop.id.value);
            out << padding << "local " << leave << " = false\n";

            if (kind->second == NodeKind::NumericFor) {
                auto prep_item = numeric_prep_test_by_loop_.find(loop.id.value);
                if (prep_item == numeric_prep_test_by_loop_.end()
                    || prep_item->second->operands.size() != 3
                    || condition_test->second->kind
                        != PredicateTestKind::NumericForAdvance) {
                    fail("RENDER_DISPATCHER_NUMERIC_FOR_CONTRACT"); return;
                }
                const PredicateTestContract& prep = *prep_item->second;
                const ExpressionDefinitionContract* variable = nullptr;
                for (const auto& expression : model_.authoritative_expressions) {
                    if (expression.kind != ExpressionKind::NumericLoopState
                        || expression.identity.instruction
                            != condition_test->second->instruction) continue;
                    if (expression.identity.reg == prep.raw_a + 2) {
                        if (variable) { fail("RENDER_DISPATCHER_NUMERIC_VARIABLE_AMBIGUOUS"); return; }
                        variable = &expression;
                    }
                }
                if (!variable) {
                    fail("RENDER_DISPATCHER_NUMERIC_VALUES_MISSING"); return;
                }
                const std::string variable_target =
                    web_name(web_by_origin_.at(variable->identity));
                const std::string iterator_name = "for_value_"
                    + std::to_string(model_.prototype.value) + "_"
                    + std::to_string(loop.id.value);
                out << padding << "for " << iterator_name << " = "
                    << origin_value(prep.operands[2]) << ", "
                    << origin_value(prep.operands[0]) << ", "
                    << origin_value(prep.operands[1]) << " do\n"
                    << padding << "    "
                    << variable_target << " = " << iterator_name << "\n";
            } else {
                const PredicateTestContract& test = *condition_test->second;
                if (test.kind != PredicateTestKind::GenericForAdvance
                    || test.operands.size() != 3) {
                    fail("RENDER_DISPATCHER_GENERIC_FOR_CONTRACT"); return;
                }
                std::vector<const ExpressionDefinitionContract*> variables;
                for (const auto& expression : model_.authoritative_expressions)
                    if (expression.kind == ExpressionKind::GenericLoopResult
                        && expression.identity.instruction == test.instruction
                        && expression.identity.reg >= test.raw_a + 3)
                        variables.push_back(&expression);
                std::sort(variables.begin(), variables.end(), [](const auto* left,
                                                                  const auto* right) {
                    return left->identity.reg < right->identity.reg;
                });
                const int expected = (int)(test.raw_aux & 0xffu);
                if (expected < 1 || (int)variables.size() != expected) {
                    fail("RENDER_DISPATCHER_GENERIC_VARIABLES_MISSING"); return;
                }
                out << padding << "for ";
                std::vector<std::string> iterator_names;
                for (size_t index = 0; index < variables.size(); ++index) {
                    if (index) out << ", ";
                    iterator_names.push_back("for_value_"
                        + std::to_string(model_.prototype.value) + "_"
                        + std::to_string(loop.id.value) + "_"
                        + std::to_string(index));
                    out << iterator_names.back();
                }
                auto specialised = specialised_iterator_call_by_loop_.find(
                    loop.id.value);
                if (specialised != specialised_iterator_call_by_loop_.end()) {
                    auto producer = calls_.find(specialised->second);
                    if (producer == calls_.end())
                        fail("RENDER_SPECIALISED_ITERATOR_PRODUCER_MISSING");
                    else out << " in "
                             << specialised_iterator_call(*producer->second)
                             << " do\n";
                } else {
                    out << " in " << origin_value(test.operands[0]) << ", "
                        << origin_value(test.operands[1]) << ", "
                        << origin_value(test.operands[2]) << " do\n";
                }
                out << padding << "    ";
                for (size_t index = 0; index < variables.size(); ++index) {
                    if (index) out << ", ";
                    out << web_name(web_by_origin_.at(variables[index]->identity));
                }
                out << " = ";
                for (size_t index = 0; index < iterator_names.size(); ++index) {
                    if (index) out << ", ";
                    out << iterator_names[index];
                }
                out << "\n";
            }
            out << padding << "    " << control << " = " << inside.value << "\n";
            emit_dispatch_domain(domain_item->second, &loop, line_indent + 1);
            out << padding << "    if " << leave << " then break end\n"
                << padding << "end\n"
                << padding << "if not " << leave << " then\n"
                << padding << "    " << control << " = " << outside.value << "\n"
                << padding << "end\n";
        };

        emit_dispatch_domain = [&](const std::set<BlockId>& domain,
                                   const AuthoritativeLoop* owner,
                                   int dispatcher_indent) {
            const std::string dispatcher_padding(
                (size_t)dispatcher_indent * 4, ' ');
            const std::string arm_padding(
                (size_t)(dispatcher_indent + 1) * 4, ' ');
            const std::string statement_padding(
                (size_t)(dispatcher_indent + 2) * 4, ' ');
            const std::string owner_leave = owner
                ? "leave_for_" + std::to_string(model_.prototype.value) + "_"
                    + std::to_string(owner->id.value)
                : std::string();
            const BranchContract* owner_condition = nullptr;
            if (owner) {
                auto found = loop_condition_by_header_.find(owner->id.value);
                if (found == loop_condition_by_header_.end()) {
                    fail("RENDER_DISPATCHER_FOR_CONTRACT_MISSING"); return;
                }
                owner_condition = found->second;
            }
            out << dispatcher_padding << "while true do\n";
            bool first = true;
            for (BlockId block : domain) {
                out << arm_padding << (first ? "if " : "elseif ") << control
                    << " == " << block.value << " then\n";
                first = false;
                emit_block_events(block, dispatcher_indent + 2, emitted_blocks, out);
                if (!failures_.empty()) return;

                // The source-level for header owns the VM's FORNLOOP/FORGLOOP
                // operation. Reaching that control block completes exactly one
                // source iteration; its non-control events (if any) were emitted above.
                if (owner_condition && block == owner_condition->source) {
                    out << statement_padding << "break\n";
                    continue;
                }
                if (block_returns(block.value)) continue;

                auto nested_for = for_by_prep.find(block.value);
                if (nested_for != for_by_prep.end()) {
                    emit_dispatch_for(*nested_for->second, dispatcher_indent + 2);
                    if (!failures_.empty()) return;
                    if (owner) {
                        out << statement_padding << "if ";
                        bool first_member = true;
                        for (BlockId member : domain) {
                            if (!first_member) out << " and ";
                            first_member = false;
                            out << control << " ~= " << member.value;
                        }
                        if (first_member) out << "true";
                        out << " then\n"
                            << statement_padding << "    " << owner_leave << " = true\n"
                            << statement_padding << "    break\n"
                            << statement_padding << "end\n";
                    }
                    continue;
                }

                auto transfer = [&](BlockId target, int transfer_indent) {
                    const std::string padding((size_t)transfer_indent * 4, ' ');
                    if (!target.valid()) {
                        fail("RENDER_DISPATCHER_TARGET_INVALID"); return;
                    }
                    if (owner && !for_bodies.at(owner->id.value).count(target)) {
                        out << padding << control << " = " << target.value << "\n"
                            << padding << owner_leave << " = true\n"
                            << padding << "break\n";
                    } else if (!domain.count(target)) {
                        fail("RENDER_DISPATCHER_FOR_CHILD_ENTRY");
                    } else {
                        out << padding << control << " = " << target.value << "\n";
                    }
                };

                auto branch = branches_by_block_.find(block.value);
                if (branch != branches_by_block_.end()) {
                    auto test = predicates_by_block_.find(block.value);
                    if (test == predicates_by_block_.end()) {
                        fail("RENDER_BRANCH_TEST_MISSING"); return;
                    }
                    out << statement_padding << "if " << predicate(*test->second)
                        << " then\n";
                    transfer(branch->second->true_target, dispatcher_indent + 3);
                    out << statement_padding << "else\n";
                    transfer(branch->second->false_target, dispatcher_indent + 3);
                    out << statement_padding << "end\n";
                    if (!failures_.empty()) return;
                    continue;
                }

                std::set<BlockId> successors;
                for (const Edge& edge : model_.cfg_edges)
                    if (edge.source == block && edge.target.valid())
                        successors.insert(edge.target);
                if (successors.empty()) {
                    if (owner) out << statement_padding << "return\n";
                    else out << statement_padding << "break\n";
                } else if (successors.size() == 1) {
                    transfer(*successors.begin(), dispatcher_indent + 2);
                    if (!failures_.empty()) return;
                } else {
                    fail("RENDER_DISPATCHER_SUCCESSOR_ARITY"); return;
                }
            }
            if (!first) {
                out << arm_padding << "else\n"
                    << arm_padding << "    error(\"invalid control state\")\n"
                    << arm_padding << "end\n";
            }
            out << dispatcher_padding << "end\n";
        };

        emit_dispatch_domain(root_domain, nullptr, body_indent);
        out << std::string((size_t)indent * 4, ' ') << "end";
        if (emitted_blocks != model_.reachable_blocks)
            fail("RENDER_BLOCK_COVERAGE");
        Result result;
        result.ok = failures_.empty();
        result.used_dispatcher = true;
        result.used_frame_storage = true;
        result.source = result.ok ? out.str() : "";
        result.failures = failures_;
        std::set_difference(model_.reachable_blocks.begin(), model_.reachable_blocks.end(),
                            emitted_blocks.begin(), emitted_blocks.end(),
                            std::inserter(result.missing_blocks,
                                          result.missing_blocks.end()));
        return result;
    }

    Result render_function_literal(int indent = 0) {
        Result structured = render_function_literal_structured(indent);
        if (structured.ok) return structured;
        if (std::getenv("RENOVICE_STRUCTURED_TRACE")) {
            std::fprintf(stderr, "STRUCTURED_FALLBACK proto=%d", model_.prototype.value);
            for (const std::string& failure : structured.failures)
                std::fprintf(stderr, " %s", failure.c_str());
            std::fprintf(stderr, "\n");
        }
        Renderer dispatcher(model_, module_models_, upvalue_names_);
        return dispatcher.render_function_literal_dispatcher(indent);
    }

    Result render_chunk() {
        validate_contracts();
        const Node& root = model_.nodes.at(model_.root);
        if (root.parameter_count != 0) fail("RENDER_MODULE_ROOT_PARAMETERS");
        if (!upvalue_names_.empty()) fail("RENDER_MODULE_ROOT_UPVALUES");
        if (!failures_.empty()) return {false, "", failures_};
        std::ostringstream out;
        for (const ValueWebContract& web : model_.authoritative_value_webs)
            if (!parameter_webs_.count(web.id)) out << "local " << web_name(web.id) << "\n";
        std::set<BlockId> emitted_blocks;
        emit_region(BlockId(0), BlockId(), &model_.reachable_blocks, 0,
                    emitted_blocks, out);
        if (emitted_blocks != model_.reachable_blocks) fail("RENDER_BLOCK_COVERAGE");
        Result result;
        result.ok = failures_.empty();
        result.used_dispatcher = used_dispatcher_;
        result.source = result.ok ? out.str() : "";
        result.failures = failures_;
        result.first_duplicate_block = first_duplicate_block_;
        result.first_duplicate_prototype = first_duplicate_prototype_;
        result.duplicate_first_region_start = duplicate_first_region_start_;
        result.duplicate_first_region_stop = duplicate_first_region_stop_;
        result.duplicate_second_region_start = duplicate_second_region_start_;
        result.duplicate_second_region_stop = duplicate_second_region_stop_;
        std::set_difference(model_.reachable_blocks.begin(), model_.reachable_blocks.end(),
                            emitted_blocks.begin(), emitted_blocks.end(),
                            std::inserter(result.missing_blocks,
                                          result.missing_blocks.end()));
        return result;
    }

    Result render() {
        Result function = render_function_literal(0);
        if (!function.ok) return function;
        function.source = "local proto_" + std::to_string(model_.prototype.value)
            + " = " + function.source + "\nreturn proto_"
            + std::to_string(model_.prototype.value) + "\n";
        return function;
    }
};

inline Result render_semantic(const Model& model) { return Renderer(model).render(); }

inline Result render_semantic_with_module_context(const Model& model,
                                                  const std::map<int, Model>& models) {
    std::map<int, int> target_sites;
    for (const auto& owner : models)
        for (const ClosureContract& closure : owner.second.authoritative_closures)
            ++target_sites[closure.target.value];
    for (const auto& target : target_sites)
        if (target.second != 1)
            return {false, "", {"RENDER_SHARED_CLOSURE_PROTOTYPE_PENDING"}};

    std::vector<std::string> upvalue_names;
    std::ostringstream declarations;
    for (int slot = 0; slot < model.authoritative_upvalue_count; ++slot) {
        const std::string name = "up_" + std::to_string(slot);
        upvalue_names.push_back(name);
        declarations << "local " << name << "\n";
    }
    Renderer renderer(model, &models, std::move(upvalue_names));
    Result result = renderer.render();
    if (result.ok) result.source = declarations.str() + result.source;
    return result;
}

inline Result render_module(const std::map<int, Model>& models, int root_prototype) {
    auto root = models.find(root_prototype);
    if (root == models.end())
        return {false, "", {"RENDER_MODULE_ROOT_MODEL_MISSING"}};
    std::map<int, int> target_sites;
    std::map<int, std::set<int>> children;
    for (const auto& model : models)
        for (const ClosureContract& closure : model.second.authoritative_closures) {
            ++target_sites[closure.target.value];
            children[model.first].insert(closure.target.value);
        }
    for (const auto& target : target_sites)
        if (target.second != 1)
            return {false, "", {"RENDER_SHARED_CLOSURE_PROTOTYPE_PENDING"}};
    std::set<int> reachable;
    std::vector<int> pending{root_prototype};
    while (!pending.empty()) {
        const int current = pending.back(); pending.pop_back();
        if (!reachable.insert(current).second) continue;
        auto found = children.find(current);
        if (found != children.end())
            pending.insert(pending.end(), found->second.begin(), found->second.end());
    }
    if (reachable.size() != models.size())
        return {false, "", {"RENDER_ORPHAN_PROTOTYPE_PENDING"}};
    Renderer renderer(root->second, &models, {});
    return renderer.render_chunk();
}

} // namespace sir::source
