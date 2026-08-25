// semantic_ir/verify.h -- fail-closed invariants before any source rendering.
#pragma once
#include "model.h"
#include "value_flow.h"
#include "local_lifetime.h"
#include "value_web.h"
#include "statement_selection.h"
#include <sstream>

namespace sir {

enum class Invariant {
    BlockCoverage = 1, EffectCoverage, LoopIdentity, LoopForest, EdgeCoverage,
    ExitCoverage, PrototypeCapture, ScopeLifetime, LocalLifetime, ValueWeb,
    ExpressionSemantics, StatementSelection, CallArity,
    ReturnSemantics, TableSemantics, StoreSemantics, PredicateSemantics,
    EvaluationOrder, RenderOwnership
};

struct Issue { Invariant invariant; std::string code; std::string detail; };
struct Verification {
    std::vector<Issue> issues;
    bool ok() const { return issues.empty(); }
    bool has(const std::string& code) const {
        for (const Issue& issue : issues) if (issue.code == code) return true;
        return false;
    }
};

inline void issue(Verification& out, Invariant invariant, const char* code,
                  const std::string& detail) {
    out.issues.push_back({invariant, code, detail});
}

inline Verification verify(const Model& model) {
    Verification out;

    // 1. Every reachable block is owned exactly once or explicitly consumed as scaffolding.
    std::map<BlockId, int> block_counts;
    for (const auto& pair : model.nodes)
        for (BlockId block : pair.second.blocks) ++block_counts[block];
    for (BlockId block : model.compiler_scaffolding) ++block_counts[block];
    bool blocks_ok = true;
    for (BlockId block : model.reachable_blocks)
        if (block_counts[block] != 1) blocks_ok = false;
    for (const auto& pair : block_counts)
        if (!model.reachable_blocks.count(pair.first) || pair.second != 1) blocks_ok = false;
    if (!blocks_ok) issue(out, Invariant::BlockCoverage, "SIR_BLOCK_COVERAGE",
                          "reachable blocks must have exactly one semantic/scaffolding owner");

    // 2. Every observable effect appears exactly once.
    std::map<EffectId, int> effect_counts;
    for (const auto& pair : model.nodes)
        for (EffectId effect : pair.second.effects) ++effect_counts[effect];
    bool effects_ok = true;
    for (EffectId effect : model.observable_effects)
        if (effect_counts[effect] != 1) effects_ok = false;
    for (const auto& pair : effect_counts)
        if (!model.observable_effects.count(pair.first) || pair.second != 1) effects_ok = false;
    if (!effects_ok) issue(out, Invariant::EffectCoverage, "SIR_EFFECT_COVERAGE",
                           "observable effects must have exactly one semantic owner");

    // 3. Each authoritative LoopId has one and only one semantic loop node.
    std::map<LoopId, int> loop_counts;
    for (const auto& pair : model.nodes) if (pair.second.loop.valid()) ++loop_counts[pair.second.loop];
    bool loops_ok = true;
    for (const auto& pair : model.authoritative_loops)
        if (loop_counts[pair.first] != 1) loops_ok = false;
    for (const auto& pair : loop_counts)
        if (!model.authoritative_loops.count(pair.first) || pair.second != 1) loops_ok = false;
    if (!loops_ok) issue(out, Invariant::LoopIdentity, "SIR_LOOP_IDENTITY",
                         "authoritative LoopIds must map one-to-one to semantic loop nodes");

    // 4. Loop parent, children, body, and latches must equal the authoritative forest.
    bool forest_ok = true;
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (!node.loop.valid()) continue;
        auto found = model.authoritative_loops.find(node.loop);
        if (found == model.authoritative_loops.end()) { forest_ok = false; continue; }
        const AuthoritativeLoop& loop = found->second;
        if (node.loop_parent != loop.parent || node.loop_children != loop.children
            || node.loop_body != loop.body || node.loop_latches != loop.latches)
            forest_ok = false;
        if (node.loop_canonical_latch != loop.canonical_latch)
            forest_ok = false;
    }
    if (!forest_ok) issue(out, Invariant::LoopForest, "SIR_LOOP_FOREST",
                          "semantic loop forest/body/latches differ from authoritative facts");

    // 5. Every CFG edge is owned exactly once by a semantic control node. Derive the represented
    // set from nodes; never compare the authoritative set with an adapter-level copy of itself.
    std::map<Edge, int> edge_counts;
    std::set<BranchContract> semantic_branches;
    bool edges_ok = true;
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (node.control_edges.empty()) continue;
        const bool control_kind = node.kind == NodeKind::If || node.kind == NodeKind::IfElse
            || node.kind == NodeKind::Break || node.kind == NodeKind::Continue
            || node.kind == NodeKind::Return || node.kind == NodeKind::Fallthrough
            || node.kind == NodeKind::LoopEntry
            || node.kind == NodeKind::BooleanSkipTransfer
            || node.kind == NodeKind::LinearTransfer || node.kind == NodeKind::JoinTransfer
            || node.kind == NodeKind::LoopCondition || node.kind == NodeKind::LoopLatch
            || node.kind == NodeKind::LoopExitTransfer || node.kind == NodeKind::RedundantPredicate
            || node.kind == NodeKind::BooleanShortCircuit
            || node.kind == NodeKind::ConditionalBreak
            || node.kind == NodeKind::ConditionalContinue
            || node.kind == NodeKind::ConditionalBreakContinue
            || node.kind == NodeKind::PreservedCyclicBranch
            || node.kind == NodeKind::PreservedSharedBranch
            || node.kind == NodeKind::PreservedEscapingBranch
            || node.kind == NodeKind::UnresolvedBranch
            || node.kind == NodeKind::UnresolvedControl;
        if (!control_kind) edges_ok = false;
        if (!node.control_source.valid() || node.control_instruction < 0
            || node.control_opcode.empty()) edges_ok = false;
        bool source_owned = node.blocks.count(node.control_source) != 0;
        auto parent = model.nodes.find(node.parent);
        if (parent != model.nodes.end() && parent->second.blocks.count(node.control_source))
            source_owned = true;
        if (!source_owned) edges_ok = false;
        for (const Edge& edge : node.control_edges) {
            ++edge_counts[edge];
            if (edge.source != node.control_source) edges_ok = false;
            if (node.kind == NodeKind::Return
                && (edge.kind != EdgeKind::Return || edge.target.valid())) edges_ok = false;
        }
        if (node.kind == NodeKind::IfElse && node.control_edges.size() != 2) edges_ok = false;
        if (node.kind == NodeKind::Return && node.control_edges.size() != 1) edges_ok = false;
        if (node.kind == NodeKind::Fallthrough
            && (node.control_edges.size() != 1
                || node.control_edges.begin()->kind != EdgeKind::Sequence))
            edges_ok = false;
        if (node.kind == NodeKind::LoopEntry) {
            auto loop = model.authoritative_loops.find(node.control_loop);
            if (node.control_edges.size() != 1 || loop == model.authoritative_loops.end()
                || loop->second.prep != node.control_source
                || !loop->second.body.count(node.control_edges.begin()->target))
                edges_ok = false;
        }
        if (node.kind == NodeKind::BooleanSkipTransfer
            && (node.control_edges.size() != 1 || node.control_opcode != "LOADB"
                || node.control_edges.begin()->kind != EdgeKind::Unconditional))
            edges_ok = false;
        if (node.kind == NodeKind::LinearTransfer
            && (node.control_edges.size() != 1 || node.control_target_predecessor_count != 1
                || !node.control_source_dominates_target))
            edges_ok = false;
        if (node.kind == NodeKind::JoinTransfer
            && (node.control_edges.size() != 1 || node.control_target_predecessor_count <= 1))
            edges_ok = false;
        if (node.kind == NodeKind::LoopLatch) {
            auto loop = model.authoritative_loops.find(node.control_loop);
            if (node.control_edges.size() != 1 || loop == model.authoritative_loops.end()
                || !loop->second.latches.count(node.control_source)
                || node.control_edges.begin()->kind != EdgeKind::LoopBack
                || node.control_edges.begin()->target.value != node.control_loop.value)
                edges_ok = false;
        }
        if (node.kind == NodeKind::LoopExitTransfer) {
            auto loop = model.authoritative_loops.find(node.control_loop);
            if (node.control_edges.size() != 1 || loop == model.authoritative_loops.end()
                || !loop->second.body.count(node.control_source)
                || loop->second.body.count(node.control_edges.begin()->target)
                || node.control_edges.begin()->kind != EdgeKind::LoopExit)
                edges_ok = false;
        }
        if (node.kind == NodeKind::If || node.kind == NodeKind::IfElse
            || node.kind == NodeKind::LoopCondition
            || node.kind == NodeKind::RedundantPredicate
            || node.kind == NodeKind::BooleanShortCircuit
            || node.kind == NodeKind::ConditionalBreak
            || node.kind == NodeKind::ConditionalContinue
            || node.kind == NodeKind::ConditionalBreakContinue
            || node.kind == NodeKind::PreservedCyclicBranch
            || node.kind == NodeKind::PreservedSharedBranch
            || node.kind == NodeKind::PreservedEscapingBranch
            || node.kind == NodeKind::UnresolvedBranch) {
            BranchContract branch;
            branch.source = node.control_source;
            branch.true_target = node.branch_true_target;
            branch.false_target = node.branch_false_target;
            branch.join = node.branch_join;
            branch.virtual_exit_join = node.branch_virtual_exit_join;
            branch.chain_next = node.branch_chain_next;
            branch.chain_shared_target = node.branch_chain_shared_target;
            branch.true_escapes_region = node.branch_true_escapes_region;
            branch.false_escapes_region = node.branch_false_escapes_region;
            branch.true_has_terminal = node.branch_true_has_terminal;
            branch.false_has_terminal = node.branch_false_has_terminal;
            branch.role = node.branch_role;
            branch.loop = node.control_loop;
            branch.true_blocks = node.branch_true_blocks;
            branch.false_blocks = node.branch_false_blocks;
            semantic_branches.insert(branch);
            if (branch.role == BranchRole::Redundant) {
                if (node.control_edges.size() != 1
                    || branch.true_target != branch.false_target
                    || branch.join != branch.true_target) edges_ok = false;
            } else if (node.control_edges.size() != 2) edges_ok = false;
            std::set<BlockId> overlap;
            std::set_intersection(branch.true_blocks.begin(), branch.true_blocks.end(),
                                  branch.false_blocks.begin(), branch.false_blocks.end(),
                                  std::inserter(overlap, overlap.begin()));
            if (branch.role == BranchRole::Region) {
                if ((branch.join.valid() == branch.virtual_exit_join) || !overlap.empty()
                    || branch.true_blocks.count(branch.source)
                    || branch.false_blocks.count(branch.source)
                    || branch.true_blocks.count(branch.join)
                    || branch.false_blocks.count(branch.join)) edges_ok = false;
                auto arm_is_closed = [&](const std::set<BlockId>& blocks, BlockId target,
                                         BlockId allowed_join, bool require_return) {
                    if (target == allowed_join) {
                        if (!blocks.empty()) return false;
                    } else if (!blocks.count(target)) {
                        return false;
                    }
                    bool saw_return = false;
                    for (BlockId block : blocks) {
                        for (const Edge& edge : model.cfg_edges) {
                            if (edge.source != block) continue;
                            if (edge.kind == EdgeKind::Return && !edge.target.valid()) {
                                saw_return = true;
                            } else if (!edge.target.valid()
                                       || (!blocks.count(edge.target)
                                           && edge.target != allowed_join)) {
                                return false;
                            }
                        }
                    }
                    return !require_return || saw_return;
                };
                if (branch.virtual_exit_join) {
                    if (!arm_is_closed(branch.true_blocks, branch.true_target, BlockId(), true)
                        || !arm_is_closed(branch.false_blocks, branch.false_target,
                                          BlockId(), true))
                        edges_ok = false;
                } else if (!arm_is_closed(branch.true_blocks, branch.true_target,
                                          branch.join, false)
                           || !arm_is_closed(branch.false_blocks, branch.false_target,
                                             branch.join, false)) {
                        edges_ok = false;
                }
            } else if (branch.role == BranchRole::LoopCondition) {
                auto loop = model.authoritative_loops.find(branch.loop);
                if (loop == model.authoritative_loops.end()) edges_ok = false;
                else {
                    const bool true_inside = loop->second.body.count(branch.true_target) != 0;
                    const bool false_inside = loop->second.body.count(branch.false_target) != 0;
                    if (true_inside == false_inside) edges_ok = false;
                }
            } else if (branch.role == BranchRole::Redundant) {
                if (!branch.true_blocks.empty() || !branch.false_blocks.empty())
                    edges_ok = false;
            } else if (branch.role == BranchRole::ShortCircuitSharedTrue
                       || branch.role == BranchRole::ShortCircuitSharedFalse) {
                if (node.kind != NodeKind::BooleanShortCircuit
                    || branch.chain_next != branch.false_target
                    || branch.chain_shared_target != branch.true_target
                    || branch.chain_next == branch.source)
                    edges_ok = false;
            } else if (branch.role == BranchRole::ConditionalBreak
                       || branch.role == BranchRole::ConditionalContinue
                       || branch.role == BranchRole::ConditionalBreakContinue) {
                auto loop = model.authoritative_loops.find(branch.loop);
                if (loop == model.authoritative_loops.end()
                    || !loop->second.body.count(branch.source)
                    || branch.source.value == branch.loop.value
                    || branch.source == loop->second.canonical_latch) {
                    edges_ok = false;
                } else {
                    const bool true_inside = loop->second.body.count(
                        branch.true_target) != 0;
                    const bool false_inside = loop->second.body.count(
                        branch.false_target) != 0;
                    const bool true_continue = branch.true_target.value == branch.loop.value
                        || branch.true_target == loop->second.canonical_latch;
                    const bool false_continue = branch.false_target.value == branch.loop.value
                        || branch.false_target == loop->second.canonical_latch;
                    const bool conditional_break = true_inside != false_inside
                        && !((true_continue && !false_inside)
                             || (false_continue && !true_inside));
                    const bool conditional_continue =
                        (true_continue && false_inside && !false_continue)
                        || (false_continue && true_inside && !true_continue);
                    const bool break_continue = (true_continue && !false_inside)
                        || (false_continue && !true_inside);
                    if ((branch.role == BranchRole::ConditionalBreak
                         && !conditional_break)
                        || (branch.role == BranchRole::ConditionalContinue
                            && !conditional_continue)
                        || (branch.role == BranchRole::ConditionalBreakContinue
                            && !break_continue))
                        edges_ok = false;
                }
            } else if (branch.role == BranchRole::PreservedCyclic) {
                if (node.kind != NodeKind::PreservedCyclicBranch
                    || (!branch.true_blocks.count(branch.source)
                        && !branch.false_blocks.count(branch.source)))
                    edges_ok = false;
            } else if (branch.role == BranchRole::PreservedShared) {
                if (node.kind != NodeKind::PreservedSharedBranch
                    || branch.true_blocks.count(branch.source)
                    || branch.false_blocks.count(branch.source)
                    || overlap.empty())
                    edges_ok = false;
            } else if (branch.role == BranchRole::PreservedEscaping) {
                if (node.kind != NodeKind::PreservedEscapingBranch
                    || branch.true_blocks.count(branch.source)
                    || branch.false_blocks.count(branch.source)
                    || !overlap.empty()
                    || (!branch.true_escapes_region && !branch.false_escapes_region))
                    edges_ok = false;
            }
        }
    }
    std::set<Edge> semantic_edges;
    for (const auto& pair : edge_counts) {
        semantic_edges.insert(pair.first);
        if (pair.second != 1) edges_ok = false;
    }
    std::map<BlockId, BranchContract> semantic_branch_by_source;
    for (const BranchContract& branch : semantic_branches)
        if (!semantic_branch_by_source.emplace(branch.source, branch).second)
            edges_ok = false;
    for (const BranchContract& branch : semantic_branches) {
        if (branch.role != BranchRole::ShortCircuitSharedTrue
            && branch.role != BranchRole::ShortCircuitSharedFalse) continue;
        auto child = semantic_branch_by_source.find(branch.chain_next);
        if (child == semantic_branch_by_source.end()) {
            edges_ok = false;
        } else if (branch.role == BranchRole::ShortCircuitSharedTrue) {
            if (child->second.true_target != branch.chain_shared_target)
                edges_ok = false;
        } else if (child->second.false_target != branch.chain_shared_target) {
            edges_ok = false;
        }
    }
    if (model.authoritative_branches != semantic_branches) edges_ok = false;
    if (!edges_ok || model.cfg_edges != semantic_edges)
        issue(out, Invariant::EdgeCoverage, "SIR_EDGE_COVERAGE",
              "semantic control nodes must own every authoritative CFG edge exactly once");

    // 6. Loop exits must be unambiguous and exactly match authoritative exits.
    bool exits_ok = true;
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (!node.loop.valid()) continue;
        auto found = model.authoritative_loops.find(node.loop);
        if (found == model.authoritative_loops.end()
            || node.loop_exits != found->second.exits) exits_ok = false;
        std::set<std::pair<BlockId, BlockId>> exit_edges;
        for (const Exit& exit_plan : node.loop_exits)
            if (!exit_edges.insert({exit_plan.source, exit_plan.target}).second)
                exits_ok = false;
    }
    if (!exits_ok) issue(out, Invariant::ExitCoverage, "SIR_EXIT_COVERAGE",
                         "loop exits must be exact and have one meaning per CFG edge");

    // 7. The function definition and every closure site/capture binding have stable identities.
    std::map<PrototypeId, int> prototype_counts;
    std::set<ClosureContract> semantic_closures;
    std::set<CaptureContract> semantic_captures;
    bool prototypes_ok = true;
    auto root = model.nodes.find(model.root);
    const int root_registers = root == model.nodes.end() ? -1
        : root->second.maximum_register_count;
    const int root_upvalues = root == model.nodes.end() ? -1 : root->second.upvalue_count;
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (node.kind == NodeKind::Function && node.prototype.valid())
            ++prototype_counts[node.prototype];
        if (node.kind != NodeKind::Closure) continue;
        ClosureContract closure;
        closure.owner = model.prototype;
        closure.target = node.closure_prototype;
        closure.instruction = node.closure_instruction;
        closure.destination_register = node.closure_destination_register;
        closure.expected_capture_count = node.target_upvalue_count;
        closure.captures = node.captures;
        semantic_closures.insert(closure);
        if ((int)node.captures.size() != node.target_upvalue_count) prototypes_ok = false;
        std::set<int> slots;
        for (const CaptureContract& capture : node.captures) {
            semantic_captures.insert(capture);
            if (capture.owner != model.prototype || capture.target != node.closure_prototype
                || capture.closure_instruction != node.closure_instruction
                || capture.slot < 0 || capture.slot >= node.target_upvalue_count
                || !slots.insert(capture.slot).second || capture.source < 0
                || (int)capture.mode < (int)CaptureMode::Value
                || (int)capture.mode > (int)CaptureMode::Upvalue)
                prototypes_ok = false;
            if ((capture.mode == CaptureMode::Value || capture.mode == CaptureMode::Reference)
                && (capture.source >= root_registers || capture.source_origins.empty()
                    || capture.parent_upvalue_slot != -1))
                prototypes_ok = false;
            if (capture.mode == CaptureMode::Upvalue
                && (capture.source >= root_upvalues || !capture.source_origins.empty()
                    || capture.parent_upvalue_slot != capture.source
                    || capture.reference_cell_register != -1))
                prototypes_ok = false;
            if (capture.mode == CaptureMode::Value
                && capture.reference_cell_register != -1) prototypes_ok = false;
            if (capture.mode == CaptureMode::Reference
                && capture.reference_cell_register != capture.source) prototypes_ok = false;
        }
    }
    if (root == model.nodes.end() || root->second.kind != NodeKind::Function
        || root->second.upvalue_count != model.authoritative_upvalue_count)
        prototypes_ok = false;
    if (model.authoritative_closures != semantic_closures
        || model.authoritative_captures != semantic_captures)
        prototypes_ok = false;
    for (PrototypeId prototype : model.authoritative_prototypes)
        if (prototype_counts[prototype] != 1) prototypes_ok = false;
    for (const auto& pair : prototype_counts)
        if (!model.authoritative_prototypes.count(pair.first) || pair.second != 1)
            prototypes_ok = false;
    if (!prototypes_ok) issue(out, Invariant::PrototypeCapture, "SIR_PROTOTYPE_CAPTURE",
                              "prototype or capture identity/count differs");

    // 8. CLOSEUPVALS boundaries explicitly end the captured-local register range.
    bool scopes_ok = true;
    std::set<ScopeCloseContract> semantic_scope_closes;
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (!node.has_scope_close) continue;
        const ScopeCloseContract& close = node.scope_close;
        if (node.kind != NodeKind::ScopeClose || !node.effects.empty()
            || close.owner != model.prototype || !close.block.valid()
            || close.instruction < 0 || close.first_register < 0
            || close.first_register >= root_registers
            || !semantic_scope_closes.insert(close).second)
            scopes_ok = false;
    }
    if (semantic_scope_closes != model.authoritative_scope_closes) scopes_ok = false;
    if (!scopes_ok) issue(out, Invariant::ScopeLifetime, "SIR_SCOPE_LIFETIME",
                          "capture cell identity or CLOSEUPVALS boundary differs");

    // 9. Every parameter/definition has one conservative lifetime and declaration owner.
    bool locals_ok = root != model.nodes.end();
    const std::set<LocalValueContract> semantic_locals = locals_ok
        ? root->second.local_values : std::set<LocalValueContract>{};
    if (semantic_locals != model.authoritative_local_values) locals_ok = false;
    std::map<ValueOriginContract, std::set<CaptureId>> expected_copies;
    std::map<ValueOriginContract, std::set<CaptureId>> expected_shares;
    for (const CaptureContract& capture : model.authoritative_captures)
        for (const ValueOriginContract& origin : capture.source_origins) {
            if (capture.mode == CaptureMode::Value)
                expected_copies[origin].insert(capture.capture);
            else if (capture.mode == CaptureMode::Reference)
                expected_shares[origin].insert(capture.capture);
        }
    std::set<ValueOriginContract> local_identities;
    for (const LocalValueContract& value : semantic_locals) {
        if (!local_identities.insert(value.identity).second || value.owner != model.prototype
            || !value.definition_block.valid() || !value.declaration_block.valid()
            || !model.reachable_blocks.count(value.definition_block)
            || !model.reachable_blocks.count(value.declaration_block)
            || value.identity.reg < 0 || value.identity.reg >= root_registers
            || value.lifetimes.empty()) locals_ok = false;
        if (value.parameter) {
            if (value.identity.kind != (int)vf::OriginKind::Parameter
                || value.identity.instruction != -1
                || value.identity.reg >= root->second.parameter_count) locals_ok = false;
        } else if (value.identity.kind != (int)vf::OriginKind::Instruction
                   || value.identity.instruction < 0) locals_ok = false;
        std::set<int> required_blocks = {value.definition_block.value};
        for (const LocalUseSite& use : value.uses) {
            required_blocks.insert(use.block.value);
            if (!model.reachable_blocks.count(use.block)) locals_ok = false;
            bool covered = false;
            for (const LocalBlockLifetime& lifetime : value.lifetimes)
                if (lifetime.block == use.block
                    && lifetime.first_instruction <= use.instruction
                    && use.instruction <= lifetime.last_instruction) covered = true;
            if (!covered) locals_ok = false;
        }
        for (int block : required_blocks) {
            auto dominators = model.block_dominators.find(block);
            if (dominators == model.block_dominators.end()
                || !dominators->second.count(value.declaration_block.value))
                locals_ok = false;
        }
        if (value.declaration_block != locals::nearest_common_dominator(
                model.block_dominators, required_blocks))
            locals_ok = false;
        for (const LocalBlockLifetime& lifetime : value.lifetimes) {
            auto range = model.block_instruction_ranges.find(lifetime.block.value);
            if (!model.reachable_blocks.count(lifetime.block)
                || range == model.block_instruction_ranges.end()
                || lifetime.first_instruction < range->second.first
                || lifetime.last_instruction > range->second.second
                || lifetime.first_instruction > lifetime.last_instruction)
                locals_ok = false;
        }
        if (value.copied_by_captures != expected_copies[value.identity]
            || value.shared_by_captures != expected_shares[value.identity])
            locals_ok = false;
    }
    for (const auto& item : expected_copies)
        if (!local_identities.count(item.first)) locals_ok = false;
    for (const auto& item : expected_shares)
        if (!local_identities.count(item.first)) locals_ok = false;
    if (!locals_ok) issue(out, Invariant::LocalLifetime, "SIR_LOCAL_LIFETIME",
                          "value identity, lifetime, declaration, or capture link differs");

    // 10. Value webs cover every identity and every multi-origin use exactly once.
    bool webs_ok = root != model.nodes.end();
    const std::set<ValueWebContract> semantic_webs = webs_ok
        ? root->second.value_webs : std::set<ValueWebContract>{};
    const std::set<ValueMergeContract> semantic_merges = webs_ok
        ? root->second.value_merges : std::set<ValueMergeContract>{};
    if (semantic_webs != model.authoritative_value_webs
        || semantic_merges != model.authoritative_value_merges) webs_ok = false;
    std::map<ValueOriginContract, const LocalValueContract*> local_by_identity;
    std::map<std::pair<LocalUseSite, int>, std::set<ValueOriginContract>> use_origins;
    for (const LocalValueContract& value : semantic_locals) {
        local_by_identity[value.identity] = &value;
        for (const LocalUseSite& use : value.uses)
            use_origins[{use, value.identity.reg}].insert(value.identity);
    }
    std::map<int, const ValueWebContract*> web_by_id;
    std::map<ValueOriginContract, int> identity_web;
    for (const ValueWebContract& web : semantic_webs) {
        if (web.owner != model.prototype || web.id < 0 || web.reg < 0
            || web.reg >= root_registers || !web.declaration_block.valid()
            || web.members.empty() || !web_by_id.emplace(web.id, &web).second)
            webs_ok = false;
        std::set<int> declaration_inputs;
        std::set<LocalUseSite> expected_uses;
        for (const ValueOriginContract& member : web.members) {
            auto local = local_by_identity.find(member);
            if (local == local_by_identity.end() || member.reg != web.reg
                || !identity_web.emplace(member, web.id).second) {
                webs_ok = false; continue;
            }
            declaration_inputs.insert(local->second->definition_block.value);
            expected_uses.insert(local->second->uses.begin(), local->second->uses.end());
            for (const LocalUseSite& use : local->second->uses)
                declaration_inputs.insert(use.block.value);
        }
        if (web.uses != expected_uses
            || web.declaration_block != locals::nearest_common_dominator(
                model.block_dominators, declaration_inputs)) webs_ok = false;
    }
    if (identity_web.size() != semantic_locals.size()) webs_ok = false;
    std::set<std::pair<LocalUseSite, int>> represented_merges;
    for (const ValueMergeContract& merge : semantic_merges) {
        auto web = web_by_id.find(merge.web_id);
        const auto expected = use_origins.find({merge.use, merge.reg});
        if (merge.owner != model.prototype || web == web_by_id.end()
            || expected == use_origins.end() || expected->second.size() < 2
            || merge.origins != expected->second
            || !web->second->merge_uses.count(merge.use)
            || !represented_merges.insert({merge.use, merge.reg}).second)
            webs_ok = false;
        for (const ValueOriginContract& origin : merge.origins)
            if (!web->second->members.count(origin)) webs_ok = false;
        const bool conditional = merge.kind == ValueMergeKind::Conditional
            || merge.kind == ValueMergeKind::ConditionalLoop;
        const bool loop = merge.kind == ValueMergeKind::LoopCarried
            || merge.kind == ValueMergeKind::ConditionalLoop;
        if (conditional) {
            bool found = false;
            for (const BranchContract& branch : model.authoritative_branches)
                if (branch.source == merge.conditional_source
                    && branch.role == BranchRole::Region && branch.join.valid()) {
                    auto dominators = model.block_dominators.find(merge.use.block.value);
                    if (dominators != model.block_dominators.end()
                        && dominators->second.count(branch.join.value)) found = true;
                }
            if (!found) webs_ok = false;
        } else if (merge.conditional_source.valid()) webs_ok = false;
        if (loop) {
            auto found = model.authoritative_loops.find(merge.loop);
            if (found == model.authoritative_loops.end()
                || !found->second.body.count(merge.use.block)) webs_ok = false;
        } else if (merge.loop.valid()) webs_ok = false;
        if (merge.kind == ValueMergeKind::Preserved
            && (merge.conditional_source.valid() || merge.loop.valid())) webs_ok = false;
    }
    for (const auto& use : use_origins)
        if (use.second.size() > 1 && !represented_merges.count(use.first)) webs_ok = false;
    for (const ValueWebContract& web : semantic_webs) {
        std::set<LocalUseSite> expected;
        for (const ValueMergeContract& merge : semantic_merges)
            if (merge.web_id == web.id) expected.insert(merge.use);
        if (web.merge_uses != expected) webs_ok = false;
    }
    if (!webs_ok) issue(out, Invariant::ValueWeb, "SIR_VALUE_WEB",
                         "web membership, declaration, merge, or CFG evidence differs");

    // Every instruction-produced value has one exact producer contract.  Operand
    // order is significant; each slot retains the complete reaching-origin set.
    bool expressions_ok = root != model.nodes.end();
    const std::set<ExpressionDefinitionContract> semantic_expressions = expressions_ok
        ? root->second.expressions : std::set<ExpressionDefinitionContract>{};
    if (semantic_expressions != model.authoritative_expressions)
        expressions_ok = false;
    std::set<ValueOriginContract> expected_expression_identities;
    for (const LocalValueContract& local : semantic_locals)
        if (local.identity.kind == (int)vf::OriginKind::Instruction)
            expected_expression_identities.insert(local.identity);
    std::set<ValueOriginContract> expression_identities;
    for (const ExpressionDefinitionContract& expression : semantic_expressions) {
        if (expression.owner != model.prototype || !expression.block.valid()
            || expression.identity.kind != (int)vf::OriginKind::Instruction
            || expression.identity.instruction < 0 || expression.identity.reg < 0
            || expression.result_slot < 0
            || expression.identity.reg != expression.raw_a + expression.result_slot
            || !expression_identities.insert(expression.identity).second
            || expression.kind == ExpressionKind::Preserved)
            expressions_ok = false;
        auto range = model.block_instruction_ranges.find(expression.block.value);
        if (range == model.block_instruction_ranges.end()
            || expression.identity.instruction < range->second.first
            || expression.identity.instruction > range->second.second)
            expressions_ok = false;
        for (const std::set<ValueOriginContract>& operand : expression.operands) {
            if (operand.empty()) expressions_ok = false;
            for (const ValueOriginContract& origin : operand)
                if (!local_by_identity.count(origin)) expressions_ok = false;
        }
        if ((expression.constant_index < 0) != (expression.constant_kind < 0))
            expressions_ok = false;
        if (expression.open_result
            && expression.kind != ExpressionKind::CallResult
            && expression.kind != ExpressionKind::VarargResult)
            expressions_ok = false;
        if (expression.open_operands
            && expression.kind != ExpressionKind::CallResult)
            expressions_ok = false;
        const size_t operand_count = expression.operands.size();
        switch (expression.kind) {
            case ExpressionKind::Number: case ExpressionKind::Constant:
            case ExpressionKind::Nil: case ExpressionKind::Boolean:
            case ExpressionKind::UpvalueRead: case ExpressionKind::GlobalRead:
            case ExpressionKind::ImportRead: case ExpressionKind::NewTable:
            case ExpressionKind::DuplicateTable: case ExpressionKind::ClosureValue:
            case ExpressionKind::VarargResult:
                if (operand_count != 0) expressions_ok = false;
                break;
            case ExpressionKind::Move: case ExpressionKind::FieldRead:
            case ExpressionKind::NumberIndexRead: case ExpressionKind::Unary:
            case ExpressionKind::MethodFunction: case ExpressionKind::MethodReceiver:
                if (operand_count != 1) expressions_ok = false;
                break;
            case ExpressionKind::IndexRead:
                if (operand_count != 2) expressions_ok = false;
                break;
            case ExpressionKind::Concatenate:
                if (operand_count == 0) expressions_ok = false;
                break;
            case ExpressionKind::Binary:
                if (operand_count != (expression.constant_index < 0 ? 2u : 1u)
                    || expression.operator_text.empty()) expressions_ok = false;
                break;
            case ExpressionKind::CallResult:
                if (operand_count == 0) expressions_ok = false;
                break;
            case ExpressionKind::NumericLoopState:
            case ExpressionKind::GenericLoopResult:
                if (operand_count != 3 || !expression.compiler_scaffolding)
                    expressions_ok = false;
                break;
            case ExpressionKind::Preserved:
                expressions_ok = false;
                break;
        }
        if ((expression.kind == ExpressionKind::MethodFunction
             || expression.kind == ExpressionKind::MethodReceiver)
            && !expression.compiler_scaffolding) expressions_ok = false;
        if (expression.kind == ExpressionKind::CallResult) {
            bool found = false;
            for (const CallContract& call : model.authoritative_calls)
                if (call.instruction == expression.identity.instruction) found = true;
            if (!found) expressions_ok = false;
        }
        if (expression.kind == ExpressionKind::ClosureValue) {
            bool found = false;
            for (const ClosureContract& closure : model.authoritative_closures)
                if (closure.instruction == expression.identity.instruction
                    && closure.target.value == expression.closure_target) found = true;
            if (!found) expressions_ok = false;
        }
        if (expression.kind == ExpressionKind::NewTable
            || expression.kind == ExpressionKind::DuplicateTable) {
            bool found = false;
            for (const TableOperationContract& table : model.authoritative_table_operations)
                if (table.instruction == expression.identity.instruction
                    && table.table_register == expression.identity.reg
                    && (table.kind == TableOperationKind::NewTable
                        || table.kind == TableOperationKind::DuplicateTemplate)) found = true;
            if (!found) expressions_ok = false;
        }
    }
    if (expression_identities != expected_expression_identities)
        expressions_ok = false;
    if (!expressions_ok)
        issue(out, Invariant::ExpressionSemantics, "SIR_EXPRESSION_SEMANTICS",
              "producer coverage, ordered operands, result shape, or semantic link differs");

    // Each producer is selected exactly once: one grouped statement owner,
    // a literal substitution with complete proof, or verified VM scaffolding.
    bool selection_ok = root != model.nodes.end();
    const std::set<DefinitionEmissionContract> semantic_emissions = selection_ok
        ? root->second.definition_emissions
        : std::set<DefinitionEmissionContract>{};
    if (semantic_emissions != model.authoritative_definition_emissions)
        selection_ok = false;
    std::map<ValueOriginContract, const ExpressionDefinitionContract*> expression_by_id;
    std::map<int, std::set<ValueOriginContract>> expression_groups;
    for (const ExpressionDefinitionContract& expression : semantic_expressions) {
        expression_by_id[expression.identity] = &expression;
        expression_groups[expression.identity.instruction].insert(expression.identity);
    }
    std::map<ValueOriginContract, int> expected_web;
    std::map<int, size_t> selection_web_sizes;
    for (const ValueWebContract& web : semantic_webs) {
        selection_web_sizes[web.id] = web.members.size();
        for (const ValueOriginContract& member : web.members)
            expected_web[member] = web.id;
    }
    std::set<ValueOriginContract> selected_identities;
    std::map<int, int> statement_owners;
    std::map<int, EmissionDisposition> group_dispositions;
    for (const DefinitionEmissionContract& emission : semantic_emissions) {
        auto expression = expression_by_id.find(emission.identity);
        auto local = local_by_identity.find(emission.identity);
        auto web = expected_web.find(emission.identity);
        if (emission.owner != model.prototype || expression == expression_by_id.end()
            || local == local_by_identity.end() || web == expected_web.end()
            || emission.web_id != web->second
            || !selected_identities.insert(emission.identity).second)
            selection_ok = false;
        if (expression == expression_by_id.end()) continue;
        const int instruction = emission.identity.instruction;
        const ValueOriginContract leader = *expression_groups[instruction].begin();
        if (!(emission.group_leader == leader)) selection_ok = false;
        auto group_kind = group_dispositions.find(instruction);
        if (group_kind == group_dispositions.end())
            group_dispositions[instruction] = emission.disposition;
        else if (group_kind->second != emission.disposition)
            selection_ok = false;
        if (emission.emits_statement) ++statement_owners[instruction];

        if (emission.disposition == EmissionDisposition::ExplicitStatement) {
            if (emission.emits_statement != (emission.identity == leader))
                selection_ok = false;
        } else if (emission.disposition == EmissionDisposition::StructuralScaffolding) {
            if (emission.emits_statement || !expression->second->compiler_scaffolding)
                selection_ok = false;
        } else if (emission.disposition == EmissionDisposition::InlineLiteral) {
            if (emission.emits_statement || !selection::literal_kind(expression->second->kind)
                || !emission.single_use || !emission.single_origin_at_use
                || !emission.dominance_proven || !emission.capture_free
                || selection_web_sizes[emission.web_id] != 1
                || local->second->uses.size() != 1
                || !(emission.inline_use == *local->second->uses.begin()))
                selection_ok = false;
            auto origins = use_origins.find({emission.inline_use, emission.identity.reg});
            if (origins == use_origins.end()
                || origins->second != std::set<ValueOriginContract>{emission.identity})
                selection_ok = false;
            auto dominators = model.block_dominators.find(emission.inline_use.block.value);
            if (dominators == model.block_dominators.end()
                || !dominators->second.count(expression->second->block.value)
                || (expression->second->block == emission.inline_use.block
                    && expression->second->identity.instruction
                       >= emission.inline_use.instruction))
                selection_ok = false;
        }
    }
    if (selected_identities != expected_expression_identities)
        selection_ok = false;
    for (const auto& group : expression_groups) {
        const EmissionDisposition disposition = group_dispositions[group.first];
        const int expected_owners = disposition == EmissionDisposition::ExplicitStatement ? 1 : 0;
        if (statement_owners[group.first] != expected_owners) selection_ok = false;
    }
    const selection::Analysis independently_selected = selection::analyze(model);
    if (!independently_selected.known
        || independently_selected.definitions != semantic_emissions)
        selection_ok = false;
    if (!selection_ok)
        issue(out, Invariant::StatementSelection, "SIR_STATEMENT_SELECTION",
              "definition partition, statement ownership, inline proof, or scaffolding differs");

    // 11. Every authoritative CALL has one semantic owner with the exact VM operand ranges.
    bool calls_ok = true;
    std::set<CallContract> semantic_calls;
    std::set<int> call_instructions;
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (node.kind != NodeKind::Call) continue;
        CallContract call;
        call.owner = model.prototype; call.block = node.call_block;
        call.instruction = node.call_instruction; call.effect_order = node.call_effect_order;
        call.base_register = node.call_base_register; call.method_call = node.call_is_method;
        call.namecall_instruction = node.call_namecall_instruction;
        call.receiver_register = node.call_receiver_register;
        call.argument_first = node.call_argument_first;
        call.argument_count = node.call_argument_count;
        call.explicit_argument_first = node.call_explicit_argument_first;
        call.explicit_argument_count = node.call_explicit_argument_count;
        call.result_first = node.call_result_first;
        call.result_count = node.call_result_count;
        call.callee_origins = node.call_callee_origins;
        call.receiver_origins = node.call_receiver_origins;
        call.fixed_argument_origins = node.call_fixed_argument_origins;
        call.open_argument_origin_kind = node.call_open_argument_origin_kind;
        call.open_argument_origin_instruction =
            node.call_open_argument_origin_instruction;
        call.open_argument_origin_base = node.call_open_argument_origin_base;
        if (!semantic_calls.insert(call).second
            || !call_instructions.insert(call.instruction).second)
            calls_ok = false;
        if (call.owner != model.prototype || !call.block.valid() || call.instruction < 0
            || call.effect_order < 0 || call.base_register < 0
            || call.base_register >= root_registers
            || call.argument_first != call.base_register + 1
            || call.result_first != call.base_register
            || call.argument_count < -1 || call.explicit_argument_count < -1
            || call.result_count < -1 || node.effects.size() != 1
            || node.effects[0] != EffectId(call.instruction)
            || call.callee_origins.empty())
            calls_ok = false;
        auto origins_known = [&](const std::set<ValueOriginContract>& origins) {
            if (origins.empty()) return false;
            for (const ValueOriginContract& origin : origins)
                if (!local_by_identity.count(origin)) return false;
            return true;
        };
        if (!origins_known(call.callee_origins)) calls_ok = false;
        for (const auto& origins : call.fixed_argument_origins)
            if (!origins_known(origins)) calls_ok = false;
        if (call.method_call) {
            if (call.namecall_instruction != call.instruction - 1
                || call.receiver_register != call.base_register + 1
                || call.explicit_argument_first != call.base_register + 2
                || (call.argument_count >= 0
                    && call.explicit_argument_count
                        != std::max(0, call.argument_count - 1)))
                calls_ok = false;
            if (!origins_known(call.receiver_origins)) calls_ok = false;
        } else if (call.namecall_instruction != -1 || call.receiver_register != -1
                   || call.explicit_argument_first != call.base_register + 1
                   || call.explicit_argument_count != call.argument_count
                   || !call.receiver_origins.empty()) {
            calls_ok = false;
        }
        if (call.explicit_argument_count >= 0) {
            if ((int)call.fixed_argument_origins.size()
                    != call.explicit_argument_count
                || call.open_argument_origin_kind != -1
                || call.open_argument_origin_instruction != -1
                || call.open_argument_origin_base != -1)
                calls_ok = false;
        } else if ((call.open_argument_origin_kind != (int)vf::TopKind::OpenCall
                    && call.open_argument_origin_kind != (int)vf::TopKind::OpenVararg)
                   || call.open_argument_origin_instruction < 0
                   || call.open_argument_origin_base < call.explicit_argument_first
                   || (int)call.fixed_argument_origins.size()
                        != call.open_argument_origin_base
                           - call.explicit_argument_first) {
            calls_ok = false;
        }
    }
    if (semantic_calls != model.authoritative_calls) calls_ok = false;
    if (!calls_ok) issue(out, Invariant::CallArity, "SIR_CALL_ARITY",
                         "call identity, value operands, argument/result range, or order differs");

    // 9. Every RETURN owns exact fixed values or one symbolic open producer.
    bool returns_ok = true;
    std::set<ReturnContract> semantic_returns;
    if (!model.authoritative_returns.empty()) for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (node.kind != NodeKind::Return) continue;
        ReturnContract value;
        value.owner = model.prototype; value.block = node.return_block;
        value.instruction = node.return_instruction;
        value.effect_order = node.return_effect_order;
        value.first_register = node.return_first_register;
        value.value_count = node.return_value_count;
        value.fixed_values = node.return_fixed_values;
        value.open_origin_kind = node.return_open_origin_kind;
        value.open_origin_instruction = node.return_open_origin_instruction;
        value.open_origin_base = node.return_open_origin_base;
        if (!semantic_returns.insert(value).second || !value.block.valid()
            || value.owner != model.prototype || value.instruction < 0
            || value.effect_order < 0 || value.first_register < 0
            || (value.value_count != 0 && value.first_register >= root_registers)
            || value.value_count < -1
            || node.effects.size() != 1
            || node.effects[0] != EffectId(value.instruction))
            returns_ok = false;
        if (value.value_count >= 0) {
            if ((int)value.fixed_values.size() != value.value_count
                || value.open_origin_kind != -1 || value.open_origin_instruction != -1
                || value.open_origin_base != -1)
                returns_ok = false;
            for (const auto& origins : value.fixed_values)
                if (origins.empty()) returns_ok = false;
        } else {
            if ((value.open_origin_kind != (int)vf::TopKind::OpenCall
                    && value.open_origin_kind != (int)vf::TopKind::OpenVararg)
                || value.open_origin_instruction < 0
                || value.open_origin_base < value.first_register
                || (int)value.fixed_values.size()
                    != value.open_origin_base - value.first_register)
                returns_ok = false;
            for (const auto& origins : value.fixed_values)
                if (origins.empty()) returns_ok = false;
        }
    }
    if (!model.authoritative_returns.empty()
        && semantic_returns != model.authoritative_returns) returns_ok = false;
    if (!returns_ok) issue(out, Invariant::ReturnSemantics, "SIR_RETURN_CONTRACT",
                           "return identity, fixed values, open producer, or order differs");

    // 10. Table allocations and writes preserve identity, operands, batches, and order.
    bool tables_ok = true;
    std::set<TableOperationContract> semantic_tables;
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (!node.has_table_operation) continue;
        const TableOperationContract& value = node.table_operation;
        if (!semantic_tables.insert(value).second || value.owner != model.prototype
            || !value.block.valid() || value.instruction < 0 || value.table_register < 0
            || value.table_origins.empty()) tables_ok = false;
        const bool allocation = value.kind == TableOperationKind::NewTable
            || value.kind == TableOperationKind::DuplicateTemplate;
        if (allocation) {
            const std::set<ValueOriginContract> expected = {
                ValueOriginContract{2, value.instruction, value.table_register}};
            if (node.kind != NodeKind::TableConstructor || value.effect_order != -1
                || value.table_origins != expected || !node.effects.empty())
                tables_ok = false;
        } else if (node.kind != NodeKind::Assignment || value.effect_order < 0
                   || node.effects.size() != 1
                   || node.effects[0] != EffectId(value.instruction)) {
            tables_ok = false;
        }
        if (value.kind == TableOperationKind::SetField
            || value.kind == TableOperationKind::SetIndex
            || value.kind == TableOperationKind::SetNumber) {
            if (value.value_register < 0 || value.value_origins.empty()) tables_ok = false;
        }
        if (value.kind == TableOperationKind::SetIndex
            && (value.key_register < 0 || value.key_origins.empty())) tables_ok = false;
        if (value.kind == TableOperationKind::SetList) {
            if (value.list_first_register < 0 || value.list_value_count < -1)
                tables_ok = false;
            if (value.list_value_count >= 0) {
                if ((int)value.list_fixed_values.size() != value.list_value_count
                    || value.list_open_origin_kind != -1
                    || value.list_open_origin_instruction != -1
                    || value.list_open_origin_base != -1)
                    tables_ok = false;
                for (const auto& origins : value.list_fixed_values)
                    if (origins.empty()) tables_ok = false;
            } else if ((value.list_open_origin_kind != (int)vf::TopKind::OpenCall
                           && value.list_open_origin_kind != (int)vf::TopKind::OpenVararg)
                       || value.list_open_origin_instruction < 0
                       || value.list_open_origin_base < value.list_first_register
                       || (int)value.list_fixed_values.size()
                            != value.list_open_origin_base - value.list_first_register) {
                tables_ok = false;
            }
            for (const auto& origins : value.list_fixed_values)
                if (origins.empty()) tables_ok = false;
        }
    }
    if (semantic_tables != model.authoritative_table_operations) tables_ok = false;
    if (!tables_ok) issue(out, Invariant::TableSemantics, "SIR_TABLE_CONTRACT",
                          "table identity, operands, list tail, or update order differs");

    // Global/upvalue writes own their target, reaching value, and effect slot.
    bool stores_ok = true;
    std::set<StoreOperationContract> semantic_stores;
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (!node.has_store_operation) continue;
        const StoreOperationContract& store = node.store_operation;
        if (!semantic_stores.insert(store).second || store.owner != model.prototype
            || !store.block.valid() || store.instruction < 0 || store.effect_order < 0
            || store.value_origins.empty() || node.kind != NodeKind::Assignment
            || node.effects.size() != 1
            || node.effects[0] != EffectId(store.instruction))
            stores_ok = false;
        for (const ValueOriginContract& origin : store.value_origins)
            if (!local_by_identity.count(origin)) stores_ok = false;
        if (store.kind == StoreOperationKind::Global) {
            if (store.name.empty() || store.upvalue_slot != -1) stores_ok = false;
        } else if (store.name.size() != 0 || store.upvalue_slot < 0
                   || store.upvalue_slot >= root_upvalues) stores_ok = false;
    }
    if (semantic_stores != model.authoritative_store_operations) stores_ok = false;
    if (!stores_ok) issue(out, Invariant::StoreSemantics, "SIR_STORE_CONTRACT",
                          "store target, reaching value, or effect order differs");

    // Every predicate/control test owns exact branch-taken operands and constants.
    bool predicate_tests_ok = true;
    std::set<PredicateTestContract> semantic_predicate_tests;
    std::set<PredicateExpressionContract> semantic_predicate_expressions;
    auto validate_test = [&](const PredicateTestContract& test) {
        if (test.owner != model.prototype || !test.block.valid()
            || test.instruction < 0 || test.kind == PredicateTestKind::Preserved)
            predicate_tests_ok = false;
        for (const auto& operand : test.operands) {
            if (operand.empty()) predicate_tests_ok = false;
            for (const ValueOriginContract& origin : operand)
                if (!local_by_identity.count(origin)) predicate_tests_ok = false;
        }
        const size_t count = test.operands.size();
        if ((test.kind == PredicateTestKind::Truthy
             || test.kind == PredicateTestKind::Falsey)
            && count != 1) predicate_tests_ok = false;
        if ((test.kind == PredicateTestKind::Equal
             || test.kind == PredicateTestKind::NotEqual)
            && count != (test.constant_text.empty() ? 2u : 1u))
            predicate_tests_ok = false;
        if ((test.kind == PredicateTestKind::Less
             || test.kind == PredicateTestKind::LessEqual)
            && count != 2) predicate_tests_ok = false;
        if ((test.kind == PredicateTestKind::NumericForExhausted
             || test.kind == PredicateTestKind::NumericForAdvance
             || test.kind == PredicateTestKind::GenericForAdvance)
            && count != 3) predicate_tests_ok = false;
        if ((test.constant_index < 0) != (test.constant_kind < 0))
            predicate_tests_ok = false;
    };
    for (const auto& pair : model.nodes) {
        const Node& node = pair.second;
        if (node.has_predicate_test
            && (node.predicate_test.block != node.control_source
                || node.predicate_test.instruction != node.control_instruction))
            predicate_tests_ok = false;
        if (!node.has_predicate_expression) {
            if (node.has_predicate_test) {
                validate_test(node.predicate_test);
                semantic_predicate_tests.insert(node.predicate_test);
            }
            continue;
        }
        const PredicateExpressionContract& expression = node.predicate_expression;
        if (!semantic_predicate_expressions.insert(expression).second
            || expression.owner != model.prototype
            || expression.block != node.control_source
            || expression.root < 0 || expression.root >= (int)expression.nodes.size())
            predicate_tests_ok = false;
        for (size_t index = 0; index < expression.nodes.size(); ++index) {
            const PredicateExpressionNodeContract& item = expression.nodes[index];
            auto earlier = [&](int child) {
                return child >= 0 && child < (int)index;
            };
            if (item.kind == PredicateExpressionKind::Test) {
                if (item.left != -1 || item.right != -1
                    || item.test.block != expression.block)
                    predicate_tests_ok = false;
                validate_test(item.test);
                if (!semantic_predicate_tests.insert(item.test).second)
                    predicate_tests_ok = false;
            } else if (item.kind == PredicateExpressionKind::Not) {
                if (!earlier(item.left) || item.right != -1)
                    predicate_tests_ok = false;
            } else if (!earlier(item.left) || !earlier(item.right)) {
                predicate_tests_ok = false;
            }
        }
    }
    if (semantic_predicate_tests != model.authoritative_predicate_tests
        || semantic_predicate_expressions != model.authoritative_predicate_expressions)
        predicate_tests_ok = false;
    if (!predicate_tests_ok)
        issue(out, Invariant::PredicateSemantics, "SIR_PREDICATE_TEST",
              "predicate expression, instruction, operands, constant, or control owner differs");

    // 11. Observable effects retain their authoritative evaluation order.
    if (model.authoritative_effect_order != model.semantic_effect_order)
        issue(out, Invariant::EvaluationOrder, "SIR_EVALUATION_ORDER",
              "semantic effect order differs from authoritative order");

    // 12. Parent ownership is complete and rendering needs no arbitration.
    bool ownership_ok = model.renderer_ready && model.ownership_conflicts.empty()
        && model.root.valid() && model.nodes.count(model.root) != 0;
    std::map<NodeId, int> child_counts;
    for (const auto& pair : model.nodes)
        for (NodeId child : pair.second.children) {
            ++child_counts[child];
            auto found = model.nodes.find(child);
            if (found == model.nodes.end() || found->second.parent != pair.first)
                ownership_ok = false;
        }
    for (const auto& pair : model.nodes) {
        if (pair.first == model.root) {
            if (pair.second.parent.valid()) ownership_ok = false;
        } else if (child_counts[pair.first] != 1 || !pair.second.parent.valid()) {
            ownership_ok = false;
        }
        if (pair.second.kind == NodeKind::UnknownPreservedOperation
            && pair.second.preserved_opcode.empty()) ownership_ok = false;
    }
    if (!ownership_ok) issue(out, Invariant::RenderOwnership, "SIR_RENDER_OWNERSHIP",
                             "node ownership is incomplete or still requires renderer arbitration");

    return out;
}

} // namespace sir
