// semantic_plan_cmd.h -- build and verify the first immutable ownership manifest.
// Included after m6e_cmd.h so it can measure the CURRENT emitter PLAN pass as a control.
#pragma once
#include "semantic_plan.h"
#include <sstream>

namespace semcmd {

static void collect_region_blocks(const sa::Analyzer& analyzer, int region,
                                  std::map<int, int>& counts) {
    if (region < 0 || region >= (int)analyzer.regions.size()) return;
    const sa::Region& value = analyzer.regions[region];
    if (value.kind == sa::RK::Basic) {
        ++counts[value.block];
        return;
    }
    for (int child : value.parts) collect_region_blocks(analyzer, child, counts);
}

static std::set<int> region_block_set(const sa::Analyzer& analyzer, int region) {
    std::map<int, int> counts;
    collect_region_blocks(analyzer, region, counts);
    std::set<int> result;
    for (const auto& item : counts) result.insert(item.first);
    return result;
}

static bool is_obvious_effect(uint8_t opcode) {
    switch (opcode) {
        case 0x54: // CALL
        case 0x02: // SETGLOBAL
        case 0x53: // SETUPVAL
        case 0x15: // SETFIELD
        case 0x2a: // SETTABLE
        case 0x2e: // SETTABLEN
        case 0x3f: // SETLIST
        case 0x29: // RETURN
        case 0x16: // NEWCLOSURE
        case 0x42: // DUPCLOSURE
            return true;
        default:
            return false;
    }
}

static void configure_emitter(em::Emitter& emitter, const ir::IProto& ip,
                              const st::Graph& graph, const sa::Analyzer& analyzer,
                              const std::vector<st::Loop>& loops, int prototype) {
    emitter.ip = &ip;
    emitter.g = &graph;
    emitter.A = &analyzer;
    emitter.pidx = prototype;
    for (const st::Loop& loop : loops) {
        if (loop.header >= 0) emitter.authoritative_loop_bodies[loop.header] = loop.body;
        if (loop.latch >= 0) emitter.latch_of_loop.insert(loop.latch);
        if (loop.header >= 0) {
            emitter.header_of_loop.insert(loop.header);
            emitter.block2loop[loop.header] = loop.header;
            if (loop.latch >= 0) emitter.block2loop[loop.latch] = loop.header;
            if (loop.prep >= 0) emitter.block2loop[loop.prep] = loop.header;
        }
        if (loop.prep >= 0 && loop.latch >= 0) emitter.prep2latch[loop.prep] = loop.latch;
    }
    emitter.assign_loop_owners(loops);
    emitter.assign_emit_owners(loops);
    emitter.enable_exact_six_shell_outer =
        loop_identity_repair_enabled() && has_exact_six_shell_nested_numeric(loops);
    emitter.enable_proper_generic_two_exit = proper_generic_two_exit_enabled();
    emitter.enable_multi_latch_generic_body_scope = multi_latch_generic_body_scope_enabled();
    emitter.enable_gyre_second_generic_nested = gyre_second_generic_nested_enabled();
    emitter.enable_gyre_energized_outer = gyre_energized_outer_enabled();
    emitter.enable_pulse_four_latch_generic_dedup = pulse_four_latch_generic_dedup_enabled();
    emitter.enable_two_block_two_exit_reversed_generic = pulse_two_exit_match_fold_enabled();
    emitter.enable_authoritative_region_nested_outer = authoritative_region_nested_outer_enabled();
    emitter.enable_split_for_whole_part = split_for_whole_part_enabled();
    emitter.enable_parent_first_child_coalesce = parent_first_child_coalesce_enabled();
    emitter.enable_parent_first_reversed_generic = parent_first_reversed_generic_enabled();
    emitter.enable_repaired_generic_child_coalesce =
        repaired_generic_child_coalesce_enabled();
    emitter.enable_seq_generic_for_coalesce = seq_generic_for_coalesce_enabled();
}

// Run the same loop-claim arbitration used immediately before rendering.  Keeping this adapter here
// makes the initial manifest observational: it reports what production currently plans, without
// changing source output.  The next architectural step is to make this manifest the input to a dumb
// renderer and delete the duplicate arbitration from m6e_cmd.h.
static em::Emitter planned_emitter(const ir::IProto& ip, const st::Graph& graph,
                                   const sa::Analyzer& analyzer,
                                   const std::vector<st::Loop>& loops, int prototype) {
    em::Emitter emitter;
    configure_emitter(emitter, ip, graph, analyzer, loops, prototype);
    em::Emitter first = emitter;
    first.planning = true;
    first.emit_function("");
    if (parent_first_exact_outer_enabled()) {
        emitter.parent_first_outer_headers =
            emitter.derive_parent_first_outer_headers(loops, first);
        if (!emitter.parent_first_outer_headers.empty()) {
            em::Emitter scoped = emitter;
            scoped.planning = true;
            scoped.emit_function("");
            first = scoped;
        }
    }
    bool single_loop_structure_surplus =
        loop_identity_repair_enabled()
        && first.header_of_loop.size() == 1
        && emitted_loop_region_count(analyzer) == first.header_of_loop.size()
        && first.plan_claim.size() > first.header_of_loop.size();
    bool replan_surplus_generic =
        single_loop_structure_surplus
        || (!std::getenv("RENOVICE_NO_REVERSED_GENERIC_CONTINUE")
            && first.has_reversed_generic_natural
            && first.plan_claim.size() > first.header_of_loop.size());
    if (replan_surplus_generic || !first.terminal_arm_loop_latches.empty()) {
        emitter.terminal_arm_loop_latches = first.terminal_arm_loop_latches;
        emitter.enable_surplus_generic_collision = replan_surplus_generic;
        em::Emitter second = emitter;
        second.planning = true;
        second.emit_function("");
        bool collision_exact = !replan_surplus_generic
            || second.plan_claim.size() == second.header_of_loop.size();
        if (collision_exact) {
            emitter.accept_planning_result(second);
        } else {
            emitter.enable_surplus_generic_collision = false;
            if (!first.terminal_arm_loop_latches.empty()) {
                em::Emitter third = emitter;
                third.planning = true;
                third.emit_function("");
                emitter.accept_planning_result(third);
            } else {
                emitter.accept_planning_result(first);
            }
        }
    } else {
        emitter.accept_planning_result(first);
    }
    return emitter;
}

static int loop_parent(const st::Loop& child, const std::vector<st::Loop>& loops) {
    int parent = -1;
    size_t parent_size = (size_t)-1;
    for (const st::Loop& candidate : loops) {
        if (candidate.header == child.header || candidate.body.size() <= child.body.size()) continue;
        bool contains = true;
        for (int block : child.body)
            if (!candidate.body.count(block)) { contains = false; break; }
        if (contains && candidate.body.size() < parent_size) {
            parent = candidate.header;
            parent_size = candidate.body.size();
        }
    }
    return parent;
}

// Post-dominance over a CFG with multiple RETURN blocks needs one synthetic exit. Without it,
// two terminal arms have an empty real-block intersection and look unstructured even though both
// provably converge at function exit. Keep the synthetic node analysis-only: it never owns a
// block, instruction, effect, or CFG edge.
static void compute_postdom_with_virtual_exit(const st::Graph& graph,
                                               std::vector<std::set<int>>& postdominators) {
    const int count = (int)graph.n.size();
    const int virtual_exit = count;
    postdominators.assign(count + 1, {});
    std::set<int> universe{virtual_exit};
    for (int block = 0; block < count; ++block)
        if (graph.n[block].reach) universe.insert(block);
    for (int block = 0; block < count; ++block)
        if (graph.n[block].reach) postdominators[block] = universe;
    postdominators[virtual_exit] = {virtual_exit};
    bool changed = true;
    int guard = 0;
    while (changed && guard++ < 1000) {
        changed = false;
        for (int block = count - 1; block >= 0; --block) {
            if (!graph.n[block].reach) continue;
            std::vector<int> successors;
            for (int target : {graph.n[block].succ_true, graph.n[block].succ_false})
                if (target >= 0 && target < count && graph.n[target].reach
                    && std::find(successors.begin(), successors.end(), target) == successors.end())
                    successors.push_back(target);
            if (successors.empty()) successors.push_back(virtual_exit);
            std::set<int> intersection = postdominators[successors.front()];
            for (size_t index = 1; index < successors.size(); ++index) {
                std::set<int> next;
                std::set_intersection(intersection.begin(), intersection.end(),
                                      postdominators[successors[index]].begin(),
                                      postdominators[successors[index]].end(),
                                      std::inserter(next, next.begin()));
                intersection = std::move(next);
            }
            intersection.insert(block);
            if (intersection != postdominators[block]) {
                postdominators[block] = std::move(intersection);
                changed = true;
            }
        }
    }
}

static sem::Manifest build_manifest(const ir::IProto& ip, int prototype) {
    sem::Manifest manifest;
    manifest.prototype = prototype;
    st::Graph graph;
    if (!build_graph(ip, graph)) {
        manifest.failures.push_back({"CFG_BUILD_FAILED", "build_graph returned false"});
        return manifest;
    }
    if (graph.n.empty()) {
        manifest.failures.push_back({"EMPTY_CFG", "prototype has no CFG blocks"});
        return manifest;
    }
    st::compute_dom(graph);
    std::vector<std::set<int>> postdominators;
    compute_postdom_with_virtual_exit(graph, postdominators);
    const int virtual_exit = (int)graph.n.size();
    manifest.reducible = st::is_reducible(graph);
    for (size_t block = 0; block < graph.n.size(); ++block) {
        if (!graph.n[block].reach) continue;
        for (int predecessor : graph.n[block].preds)
            if (predecessor >= 0 && predecessor < (int)graph.n.size()
                && graph.n[predecessor].reach)
                manifest.block_predecessors[(int)block].insert(predecessor);
        manifest.block_dominators[(int)block] = graph.dom[block];
        manifest.immediate_dominator[(int)block] = graph.idom[block];
        const int immediate = st::ipostdom(postdominators, (int)block);
        manifest.immediate_postdominator[(int)block] =
            immediate == virtual_exit ? -1 : immediate;
    }
    sa::Analyzer analyzer;
    analyzer.build(graph);
    int steps = 0;
    if (!analyzer.reduce(steps) || analyzer.live.size() != 1) {
        manifest.failures.push_back({"REGION_REDUCTION_FAILED", "region tree did not reduce to one root"});
        return manifest;
    }
    const int root = *analyzer.live.begin();
    std::vector<int> region_parent(analyzer.regions.size(), -1);
    std::vector<int> region_position(analyzer.regions.size(), -1);
    for (size_t parent = 0; parent < analyzer.regions.size(); ++parent)
        for (size_t position = 0; position < analyzer.regions[parent].parts.size(); ++position) {
            int child = analyzer.regions[parent].parts[position];
            if (child >= 0 && child < (int)analyzer.regions.size()) {
                region_parent[child] = (int)parent;
                region_position[child] = (int)position;
            }
        }
    collect_region_blocks(analyzer, root, manifest.block_emit_count);
    for (size_t block = 0; block < graph.n.size(); ++block) {
        if (!graph.n[block].reach) continue;
        ++manifest.reachable_blocks;
        manifest.reachable_block_ids.insert((int)block);
        manifest.block_instruction_ranges[(int)block] = {graph.n[block].first, graph.n[block].last};
        int count = manifest.block_emit_count[(int)block];
        if (count == 0)
            manifest.failures.push_back({"BLOCK_UNOWNED", "block=" + std::to_string(block)});
        else if (count != 1)
            manifest.failures.push_back({"BLOCK_MULTI_OWNED", "block=" + std::to_string(block)
                                         + " count=" + std::to_string(count)});
    }
    for (const auto& item : manifest.block_emit_count)
        if ((item.first < 0 || item.first >= (int)graph.n.size() || !graph.n[item.first].reach)
            && item.second > 0)
            manifest.failures.push_back({"UNREACHABLE_BLOCK_OWNED", "block="
                                         + std::to_string(item.first)});

    const std::vector<st::Loop> loops = st::find_loops(graph);
    const em::Emitter planned = planned_emitter(ip, graph, analyzer, loops, prototype);
    if (std::getenv("RENOVICE_PLANTREE")) planned.dump_region_tree(root, 0);

    for (size_t source = 0; source < graph.n.size(); ++source) {
        const st::Node& node = graph.n[source];
        if (!node.reach) continue;
        auto add_edge = [&](int target, int arm) {
            if (target < 0 || target >= (int)graph.n.size() || !graph.n[target].reach) return;
            sem::EdgePlan edge;
            edge.source = (int)source;
            edge.target = target;
            edge.arm = arm;
            edge.kind = node.is_uncond ? sem::EdgeKind::Unconditional
                : (node.is_branch
                   ? (arm ? sem::EdgeKind::ConditionalTrue : sem::EdgeKind::ConditionalFalse)
                   : sem::EdgeKind::Fallthrough);
            for (const st::Loop& loop : loops) {
                if (loop.body.count((int)source) && loop.body.count(target)
                    && target == loop.header) {
                    edge.kind = sem::EdgeKind::Backedge;
                    edge.loop_header = loop.header;
                    break;
                }
                if (loop.body.count((int)source) && !loop.body.count(target)) {
                    edge.kind = sem::EdgeKind::LoopExit;
                    edge.loop_header = loop.header;
                }
            }
            manifest.edges.push_back(edge);
        };
        add_edge(node.succ_true, 1);
        if (node.succ_false != node.succ_true) add_edge(node.succ_false, 0);
        if (node.last >= 0 && node.last < (int)ip.code.size()
            && ip.code[node.last].op == 0x29) {
            sem::EdgePlan edge;
            edge.source = (int)source;
            edge.target = -1;
            edge.kind = sem::EdgeKind::Return;
            manifest.edges.push_back(edge);
        }
        if (node.is_branch) {
            sem::PredicatePlan predicate;
            predicate.block = (int)source;
            predicate.instruction = node.last;
            predicate.true_target = node.succ_true;
            predicate.false_target = node.succ_false;
            const int immediate = st::ipostdom(postdominators, (int)source);
            predicate.virtual_exit_join = immediate == virtual_exit;
            predicate.join = predicate.virtual_exit_join ? -1 : immediate;
            auto collect_arm = [&](int start, int stop, std::set<int>& blocks,
                                   bool& has_terminal, bool& escapes) {
                std::vector<int> pending;
                if (start >= 0 && start != stop) pending.push_back(start);
                while (!pending.empty()) {
                    int block = pending.back(); pending.pop_back();
                    if (block == stop || blocks.count(block)) continue;
                    if (block < 0 || block >= (int)graph.n.size() || !graph.n[block].reach) {
                        escapes = true; continue;
                    }
                    if (!graph.dom[block].count((int)source)) { escapes = true; continue; }
                    blocks.insert(block);
                    bool successor = false;
                    for (int target : {graph.n[block].succ_true, graph.n[block].succ_false}) {
                        if (target < 0) continue;
                        successor = true;
                        if (target == stop) continue;
                        if (!graph.dom[target].count((int)source)) { escapes = true; continue; }
                        pending.push_back(target);
                    }
                    if (!successor) has_terminal = true;
                }
            };
            collect_arm(predicate.true_target, predicate.join, predicate.true_blocks,
                        predicate.true_has_terminal, predicate.true_escapes_region);
            collect_arm(predicate.false_target, predicate.join, predicate.false_blocks,
                        predicate.false_has_terminal, predicate.false_escapes_region);
            std::set_intersection(predicate.true_blocks.begin(), predicate.true_blocks.end(),
                                  predicate.false_blocks.begin(), predicate.false_blocks.end(),
                                  std::inserter(predicate.overlap_blocks,
                                                predicate.overlap_blocks.begin()));
            const st::Loop* condition_loop = nullptr;
            for (const st::Loop& loop : loops) {
                if (!loop.body.count((int)source)) continue;
                const bool true_inside = loop.body.count(predicate.true_target) != 0;
                const bool false_inside = loop.body.count(predicate.false_target) != 0;
                if (true_inside == false_inside) continue;
                if ((int)source != loop.header && (int)source != loop.latch) continue;
                if (!condition_loop || loop.body.size() < condition_loop->body.size())
                    condition_loop = &loop;
            }
            if (predicate.true_target == predicate.false_target) {
                predicate.role = "redundant_predicate";
                predicate.proven = true;
            } else if (condition_loop) {
                predicate.role = "loop_condition";
                predicate.loop_header = condition_loop->header;
                predicate.proven = true;
            } else {
                const bool true_target_shared = predicate.overlap_blocks.count(
                    predicate.true_target) != 0;
                const bool false_target_shared = predicate.overlap_blocks.count(
                    predicate.false_target) != 0;
                if (true_target_shared != false_target_shared) {
                    const int local_join = true_target_shared ? predicate.true_target
                                                              : predicate.false_target;
                    std::set<int> bounded_true, bounded_false;
                    bool bounded_true_terminal = false, bounded_false_terminal = false;
                    bool bounded_true_escape = false, bounded_false_escape = false;
                    collect_arm(predicate.true_target, local_join, bounded_true,
                                bounded_true_terminal, bounded_true_escape);
                    collect_arm(predicate.false_target, local_join, bounded_false,
                                bounded_false_terminal, bounded_false_escape);
                    std::set<int> bounded_overlap;
                    std::set_intersection(bounded_true.begin(), bounded_true.end(),
                                          bounded_false.begin(), bounded_false.end(),
                                          std::inserter(bounded_overlap,
                                                        bounded_overlap.begin()));
                    if (bounded_overlap.empty() && !bounded_true_escape
                        && !bounded_false_escape && !bounded_true.count((int)source)
                        && !bounded_false.count((int)source)) {
                        predicate.join = local_join;
                        predicate.virtual_exit_join = false;
                        predicate.shared_entry_join = true;
                        predicate.true_blocks = std::move(bounded_true);
                        predicate.false_blocks = std::move(bounded_false);
                        predicate.overlap_blocks.clear();
                        predicate.true_has_terminal = bounded_true_terminal;
                        predicate.false_has_terminal = bounded_false_terminal;
                        predicate.true_escapes_region = false;
                        predicate.false_escapes_region = false;
                    }
                }
                predicate.role = "branch_region";
                predicate.proven = (predicate.join >= 0 || (predicate.virtual_exit_join
                                            && predicate.true_has_terminal
                                            && predicate.false_has_terminal))
                    && predicate.overlap_blocks.empty()
                    && !predicate.true_escapes_region && !predicate.false_escapes_region
                    && !predicate.true_blocks.count((int)source)
                    && !predicate.false_blocks.count((int)source);
                if (!predicate.proven && predicate.false_target >= 0
                    && predicate.false_target < (int)graph.n.size()
                    && graph.n[predicate.false_target].reach
                    && graph.n[predicate.false_target].is_branch
                    && predicate.false_target != (int)source) {
                    const st::Node& child = graph.n[predicate.false_target];
                    if (predicate.true_target == child.succ_true) {
                        predicate.role = "short_circuit_shared_true";
                        predicate.chain_mode = "shared_true";
                        predicate.chain_next = predicate.false_target;
                        predicate.chain_shared_target = predicate.true_target;
                        predicate.proven = true;
                    } else if (predicate.true_target == child.succ_false) {
                        predicate.role = "short_circuit_shared_false";
                        predicate.chain_mode = "shared_false";
                        predicate.chain_next = predicate.false_target;
                        predicate.chain_shared_target = predicate.true_target;
                        predicate.proven = true;
                    }
                }
                if (!predicate.proven) {
                    const st::Loop* owner = nullptr;
                    for (const st::Loop& candidate : loops) {
                        if (!candidate.body.count((int)source)) continue;
                        if (!owner || candidate.body.size() < owner->body.size())
                            owner = &candidate;
                    }
                    if (owner && (int)source != owner->header
                        && !owner->body.empty() && (int)source != owner->latch) {
                        const bool true_inside = owner->body.count(
                            predicate.true_target) != 0;
                        const bool false_inside = owner->body.count(
                            predicate.false_target) != 0;
                        const bool true_continue = predicate.true_target == owner->header
                            || predicate.true_target == owner->latch;
                        const bool false_continue = predicate.false_target == owner->header
                            || predicate.false_target == owner->latch;
                        if ((true_continue && !false_inside)
                            || (false_continue && !true_inside)) {
                            predicate.role = "conditional_break_continue";
                            predicate.loop_action = "break_continue";
                            predicate.loop_header = owner->header;
                            predicate.proven = true;
                        } else if (true_inside != false_inside) {
                            predicate.role = "conditional_break";
                            predicate.loop_action = "break";
                            predicate.loop_header = owner->header;
                            predicate.proven = true;
                        } else if ((true_continue && false_inside
                                   && !false_continue)
                                  || (false_continue && true_inside
                                      && !true_continue)) {
                            predicate.role = "conditional_continue";
                            predicate.loop_action = "continue";
                            predicate.loop_header = owner->header;
                            predicate.proven = true;
                        }
                    }
                }
                if (!predicate.proven) {
                    if (predicate.true_blocks.count((int)source)
                        || predicate.false_blocks.count((int)source))
                        predicate.role = "preserved_cyclic";
                    else if (!predicate.overlap_blocks.empty())
                        predicate.role = "preserved_shared";
                    else if (predicate.true_escapes_region
                             || predicate.false_escapes_region)
                        predicate.role = "preserved_escaping";
                    else
                        predicate.role = "unresolved_branch";
                    predicate.explicitly_preserved = predicate.role != "unresolved_branch";
                }
            }
            manifest.predicates.push_back(predicate);
            if (node.succ_true < 0 || node.succ_false < 0)
                manifest.failures.push_back({"PREDICATE_EDGE_MISSING", "block="
                                             + std::to_string(source)});
        }
        for (int instruction = node.first;
             instruction <= node.last && instruction < (int)ip.code.size(); ++instruction) {
            if (!is_obvious_effect(ip.code[instruction].op)) continue;
            manifest.effects.push_back({instruction, (int)source, ip.code[instruction].name});
        }
    }

    std::map<int, const st::Loop*> loop_by_header;
    std::map<int, int> parent_by_header;
    std::map<int, int> planned_region_by_header;
    for (const st::Loop& known_loop : loops) {
        loop_by_header[known_loop.header] = &known_loop;
        parent_by_header[known_loop.header] = loop_parent(known_loop, loops);
        if (known_loop.kind == st::Loop::ForNum || known_loop.kind == st::Loop::ForGen) {
            auto winner = planned.semantic_plan_winner.find(known_loop.header);
            if (winner != planned.semantic_plan_winner.end())
                planned_region_by_header[known_loop.header] = winner->second;
        } else {
            auto owner = planned.loop_owner.find(known_loop.header);
            if (owner != planned.loop_owner.end())
                planned_region_by_header[known_loop.header] = owner->second;
        }
    }
    auto loop_form = [](const st::Loop& known_loop) {
        return known_loop.kind == st::Loop::ForNum ? "for_numeric"
            : known_loop.kind == st::Loop::ForGen ? "for_generic"
            : known_loop.kind == st::Loop::Repeat ? "repeat" : "while";
    };
    std::set<int> consumed_winner_keys;
    for (const st::Loop& loop : loops) {
        sem::LoopPlan value;
        value.header = loop.header;
        value.prep = loop.prep;
        value.canonical_latch = loop.latch;
        value.source_form = loop.kind == st::Loop::ForNum ? "for_numeric"
            : loop.kind == st::Loop::ForGen ? "for_generic"
            : loop.kind == st::Loop::Repeat ? "repeat" : "while";
        value.body = loop.body;
        value.parent_header = loop_parent(loop, loops);
        for (int source : loop.body) {
            if (source < 0 || source >= (int)graph.n.size()) continue;
            for (int target : {graph.n[source].succ_true, graph.n[source].succ_false}) {
                if (target < 0) continue;
                if (target == loop.header) {
                    value.latches.insert(source);
                    value.backedges.insert({source, target});
                } else if (!loop.body.count(target)) {
                    value.exits.insert({source, target});
                }
            }
        }
        // The historical emitter PLAN pass records only source-for claim collisions.  Its key may be
        // the authoritative header, prep, latch, or first body block.  Resolve all four explicitly;
        // never compare the raw key to a loop header and call the mismatch semantic evidence.
        if (loop.kind == st::Loop::ForNum || loop.kind == st::Loop::ForGen) {
            auto candidates = planned.semantic_plan_candidates.find(loop.header);
            if (candidates != planned.semantic_plan_candidates.end())
                for (const auto& region : candidates->second) {
                    value.candidate_regions.insert(region.first);
                    value.candidate_plan_keys.insert(region.second.begin(), region.second.end());
                }
            for (const auto& provenance : planned.plan_key_loops) {
                if (!provenance.second.count(loop.header)) continue;
                consumed_winner_keys.insert(provenance.first);
            }
            std::vector<std::pair<size_t, int>> header_candidates;
            std::vector<std::pair<size_t, int>> body_candidates;
            for (int region : value.candidate_regions) {
                if (planned.semantic_header_candidates.count({loop.header, region}))
                    header_candidates.push_back({region_block_set(analyzer, region).size(), region});
                if (planned.semantic_body_candidates.count({loop.header, region}))
                    body_candidates.push_back({region_block_set(analyzer, region).size(), region});
            }
            // Semantic roles come from the CFG/region tree, not solely from claimants that the
            // current renderer happened to discover. Prefer proven claimants; only when a role has
            // none, consult all reduced regions. Equal-size reduced representations are structural
            // aliases, so their stable region id is a provenance tie-break rather than a semantic
            // ambiguity.
            {
                for (size_t region = 0; region < analyzer.regions.size(); ++region) {
                    const std::set<int> blocks = region_block_set(analyzer, (int)region);
                    const int head = planned.head_block((int)region);
                    if (header_candidates.empty() && (head == loop.prep || head == loop.header))
                        header_candidates.push_back({blocks.size(), (int)region});
                    bool complete = true;
                    for (int block : loop.body)
                        if (!blocks.count(block)) { complete = false; break; }
                    if (complete) body_candidates.push_back({blocks.size(), (int)region});
                }
            }
            auto unique_candidates = [](std::vector<std::pair<size_t, int>>& values) {
                std::sort(values.begin(), values.end());
                values.erase(std::unique(values.begin(), values.end()), values.end());
            };
            unique_candidates(header_candidates);
            unique_candidates(body_candidates);
            if (!header_candidates.empty()) {
                value.header_region = header_candidates[0].second;
            } else {
                manifest.failures.push_back({"FOR_HEADER_OWNER_UNRESOLVED", "header="
                                             + std::to_string(loop.header)});
            }
            if (body_candidates.empty()) {
                int reachable_missing = 0, unreachable_missing = 0;
                std::string missing_blocks;
                for (int block : loop.body) {
                    if (manifest.block_emit_count.count(block)) continue;
                    if (!missing_blocks.empty()) missing_blocks += ',';
                    missing_blocks += std::to_string(block);
                    if (block >= 0 && block < (int)graph.n.size() && graph.n[block].reach)
                        ++reachable_missing;
                    else
                        ++unreachable_missing;
                }
                manifest.failures.push_back({"FOR_BODY_OWNER_UNRESOLVED", "header="
                                             + std::to_string(loop.header) + " reachable_missing="
                                             + std::to_string(reachable_missing)
                                             + " unreachable_missing="
                                             + std::to_string(unreachable_missing) + " blocks="
                                             + missing_blocks});
            } else {
                value.body_region = body_candidates[0].second;
                value.planned_region = value.body_region;
            }
            for (int region : value.candidate_regions)
                if (region != value.header_region && region != value.body_region)
                    value.shell_regions.insert(region);
            if (value.candidate_regions.empty()) {
                value.legacy_claim_missing = true;
                // The old emitter's claimant table is historical renderer provenance, not a
                // semantic ownership oracle.  The new manifest independently proves the two
                // source roles needed for a `for`: (1) a unique reduced region headed by the
                // authoritative prep/header, and (2) the smallest reduced region containing the
                // complete authoritative loop body.  Register that split ownership explicitly.
                // Absence of an old claimant is then diagnostic only; failing a verified loop for
                // it produced hundreds of false FOR_LOOP_UNOWNED reports, including stock Mallet.
                const bool header_role_proven = value.header_region >= 0
                    && (planned.head_block(value.header_region) == loop.prep
                        || planned.head_block(value.header_region) == loop.header);
                bool body_role_proven = value.body_region >= 0;
                if (body_role_proven) {
                    const std::set<int> body_blocks =
                        region_block_set(analyzer, value.body_region);
                    for (int body_block : loop.body)
                        if (!body_blocks.count(body_block)) {
                            body_role_proven = false;
                            break;
                        }
                }
                value.split_role_owned = header_role_proven && body_role_proven;
                if (!value.split_role_owned) {
                // Keep the detailed old diagnostic for a genuine split-role proof failure.  It is
                // no longer reached merely because historical emitter provenance is absent.
                int header_kind = value.header_region >= 0
                    ? (int)analyzer.regions[value.header_region].kind : -1;
                int body_kind = value.body_region >= 0
                    ? (int)analyzer.regions[value.body_region].kind : -1;
                auto nearest_proper = [&](int region) {
                    std::set<int> seen;
                    while (region >= 0 && seen.insert(region).second) {
                        if (analyzer.regions[region].kind == sa::RK::Proper) return region;
                        region = region_parent[region];
                    }
                    return -1;
                };
                int header_proper = nearest_proper(value.header_region);
                int body_proper = nearest_proper(value.body_region);
                std::map<int, int> header_ancestors;
                int cursor = value.header_region, distance = 0;
                while (cursor >= 0 && !header_ancestors.count(cursor)) {
                    header_ancestors[cursor] = distance++;
                    cursor = region_parent[cursor];
                }
                int lca = -1, body_distance = 0;
                cursor = value.body_region;
                std::set<int> body_seen;
                while (cursor >= 0 && body_seen.insert(cursor).second) {
                    if (header_ancestors.count(cursor)) { lca = cursor; break; }
                    cursor = region_parent[cursor];
                    ++body_distance;
                }
                int ancestor_depth = 0;
                int nearest_parent = value.parent_header;
                int nearest_parent_region = planned_region_by_header.count(nearest_parent)
                    ? planned_region_by_header[nearest_parent] : -1;
                std::string nearest_parent_form = "none";
                if (loop_by_header.count(nearest_parent))
                    nearest_parent_form = loop_form(*loop_by_header[nearest_parent]);
                int shared_wrapper_edges = 0;
                int first_shared_inner = -1, first_shared_outer = -1,
                    first_shared_region = -1;
                int inner_ancestor = nearest_parent;
                std::set<int> ancestor_seen;
                while (inner_ancestor >= 0 && ancestor_seen.insert(inner_ancestor).second) {
                    ++ancestor_depth;
                    int outer_ancestor = parent_by_header.count(inner_ancestor)
                        ? parent_by_header[inner_ancestor] : -1;
                    int inner_region = planned_region_by_header.count(inner_ancestor)
                        ? planned_region_by_header[inner_ancestor] : -1;
                    int outer_region = planned_region_by_header.count(outer_ancestor)
                        ? planned_region_by_header[outer_ancestor] : -1;
                    if (inner_region >= 0 && inner_region == outer_region) {
                        ++shared_wrapper_edges;
                        if (first_shared_inner < 0) {
                            first_shared_inner = inner_ancestor;
                            first_shared_outer = outer_ancestor;
                            first_shared_region = inner_region;
                        }
                    }
                    inner_ancestor = outer_ancestor;
                }
                std::string first_shared_inner_form = "none";
                std::string first_shared_outer_form = "none";
                if (loop_by_header.count(first_shared_inner))
                    first_shared_inner_form = loop_form(*loop_by_header[first_shared_inner]);
                if (loop_by_header.count(first_shared_outer))
                    first_shared_outer_form = loop_form(*loop_by_header[first_shared_outer]);
                int first_shared_outer_body = -1, first_shared_inner_body = -1,
                    first_shared_outer_exits = -1, first_shared_region_blocks = -1,
                    first_shared_region_exact_outer = 0;
                if (loop_by_header.count(first_shared_outer)) {
                    const st::Loop& outer_loop = *loop_by_header[first_shared_outer];
                    first_shared_outer_body = (int)outer_loop.body.size();
                    std::set<int> outer_exit_targets;
                    for (int block : outer_loop.body)
                        for (int target : {graph.n[block].succ_true, graph.n[block].succ_false})
                            if (target >= 0 && !outer_loop.body.count(target))
                                outer_exit_targets.insert(target);
                    first_shared_outer_exits = (int)outer_exit_targets.size();
                    if (first_shared_region >= 0) {
                        const std::set<int> shared_blocks =
                            region_block_set(analyzer, first_shared_region);
                        first_shared_region_blocks = (int)shared_blocks.size();
                        first_shared_region_exact_outer = shared_blocks == outer_loop.body ? 1 : 0;
                    }
                }
                if (loop_by_header.count(first_shared_inner))
                    first_shared_inner_body =
                        (int)loop_by_header[first_shared_inner]->body.size();
                manifest.failures.push_back({"FOR_LOOP_UNOWNED", "header="
                                             + std::to_string(loop.header) + " form="
                                             + value.source_form + " prep="
                                             + std::to_string(loop.prep) + " body_size="
                                             + std::to_string(loop.body.size()) + " header_region="
                                             + std::to_string(value.header_region) + " body_region="
                                             + std::to_string(value.body_region) + " header_kind="
                                             + std::to_string(header_kind) + " body_kind="
                                             + std::to_string(body_kind) + " same_region="
                                             + (value.header_region == value.body_region ? "1" : "0")
                                             + " header_parent="
                                             + std::to_string(value.header_region >= 0
                                                   ? region_parent[value.header_region] : -1)
                                             + " body_parent="
                                             + std::to_string(value.body_region >= 0
                                                   ? region_parent[value.body_region] : -1)
                                             + " header_pos="
                                             + std::to_string(value.header_region >= 0
                                                   ? region_position[value.header_region] : -1)
                                             + " body_pos="
                                             + std::to_string(value.body_region >= 0
                                                   ? region_position[value.body_region] : -1)
                                             + " shared_parent_kind="
                                             + std::to_string(value.header_region >= 0
                                                   && value.body_region >= 0
                                                   && region_parent[value.header_region]
                                                      == region_parent[value.body_region]
                                                   && region_parent[value.header_region] >= 0
                                                   ? (int)analyzer.regions[
                                                         region_parent[value.header_region]].kind
                                                   : -1)
                                             + " root_kind="
                                             + std::to_string((int)analyzer.regions[root].kind)
                                             + " header_proper=" + std::to_string(header_proper)
                                             + " body_proper=" + std::to_string(body_proper)
                                             + " common_proper="
                                             + (header_proper >= 0 && header_proper == body_proper
                                                    ? "1" : "0")
                                             + " lca=" + std::to_string(lca) + " lca_kind="
                                             + std::to_string(lca >= 0
                                                   ? (int)analyzer.regions[lca].kind : -1)
                                             + " header_distance="
                                             + std::to_string(lca >= 0
                                                   ? header_ancestors[lca] : -1)
                                             + " body_distance="
                                             + std::to_string(lca >= 0 ? body_distance : -1)
                                             + " parent_header=" + std::to_string(nearest_parent)
                                             + " parent_form=" + nearest_parent_form
                                             + " parent_region="
                                             + std::to_string(nearest_parent_region)
                                             + " ancestor_depth="
                                             + std::to_string(ancestor_depth)
                                             + " shared_wrapper_edges="
                                             + std::to_string(shared_wrapper_edges)
                                             + " first_shared_inner="
                                             + std::to_string(first_shared_inner)
                                             + " first_shared_outer="
                                             + std::to_string(first_shared_outer)
                                             + " first_shared_region="
                                             + std::to_string(first_shared_region)
                                             + " first_shared_inner_form="
                                             + first_shared_inner_form
                                             + " first_shared_outer_form="
                                             + first_shared_outer_form
                                             + " first_shared_outer_body="
                                             + std::to_string(first_shared_outer_body)
                                             + " first_shared_inner_body="
                                             + std::to_string(first_shared_inner_body)
                                             + " first_shared_outer_exits="
                                             + std::to_string(first_shared_outer_exits)
                                             + " first_shared_region_blocks="
                                             + std::to_string(first_shared_region_blocks)
                                             + " first_shared_region_exact_outer="
                                             + std::to_string(first_shared_region_exact_outer)
                                             + " prototype_loops="
                                             + std::to_string(loops.size())});
                }
            }
            // The historical render key can be the authoritative for-header itself.  In the exact
            // nested shape where that header is also the enclosing non-for loop's prep block, the
            // legacy block2loop alias is necessarily ambiguous and plan_key_loops can attribute the
            // key to the parent.  Do not discard the stronger direct identity: when split-role CFG
            // ownership is already proven and the winner region is the proven complete body owner,
            // a winner keyed by this loop's own header belongs to this loop.  A generic-for has one
            // additional exact legacy identity: the FORGLOOP header's taken successor is its
            // canonical first body block (the renderer derives the same bstart at emit.h:1705).
            // Jade Chaos is the one corpus specimen keyed that way.
            if (value.split_role_owned) {
                std::set<int> exact_legacy_keys{loop.header};
                if (loop.kind == st::Loop::ForGen && loop.header >= 0
                    && loop.header < (int)graph.n.size()
                    && graph.n[loop.header].succ_true >= 0)
                    exact_legacy_keys.insert(graph.n[loop.header].succ_true);
                for (int key : exact_legacy_keys) {
                    auto direct_winner = planned.plan_winner.find(key);
                    if (direct_winner == planned.plan_winner.end()
                        || direct_winner->second != value.body_region)
                        continue;
                    value.candidate_plan_keys.insert(key);
                    consumed_winner_keys.insert(key);
                }
            }
            if (!value.candidate_plan_keys.empty())
                value.plan_key = *value.candidate_plan_keys.begin();
        } else {
            // Non-for loops are not represented by plan_winner at all.  Preserve the structurer's
            // best ownership fact, but mark it region-only: this is precisely the missing semantic
            // boundary that currently lets a region be hijacked by an interior for-loop at render.
            auto owner = planned.loop_owner.find(loop.header);
            if (owner == planned.loop_owner.end()) {
                manifest.failures.push_back({"NONFOR_LOOP_UNOWNED", "header="
                                             + std::to_string(loop.header)});
            } else {
                value.planned_region = owner->second;
                value.region_only = true;
            }
        }
        if (value.planned_region >= 0) {
            value.planned_region_blocks = region_block_set(analyzer, value.planned_region);
            bool contains = true;
            for (int block : loop.body)
                if (!value.planned_region_blocks.count(block)) { contains = false; break; }
            if (!contains)
                manifest.failures.push_back({"LOOP_OWNER_INCOMPLETE", "header="
                                             + std::to_string(loop.header) + " region="
                                             + std::to_string(value.planned_region)});
        }
        manifest.loops[loop.header] = std::move(value);
    }
    auto terminal_numeric_for = [&](int key, int region, sem::TerminalForPlan& value) {
        auto reject = [&](const char* reason) {
            if (std::getenv("RENOVICE_SEMANTIC_PLAN_TERMINAL_TRACE"))
                std::fprintf(stderr,
                    "TERMINAL_FOR_REJECT proto=%d key=%d region=%d reason=%s\n",
                    prototype, key, region, reason);
            return false;
        };
        if (!manifest.reducible || key < 0 || key >= (int)graph.n.size()
            || region < 0 || region >= (int)analyzer.regions.size())
            return reject("INVALID_INPUT_OR_IRREDUCIBLE");
        const std::set<int> blocks = region_block_set(analyzer, region);
        if (!blocks.count(key)) return reject("KEY_OUTSIDE_REGION");

        int prep = -1;
        for (int block : blocks) {
            if (block < 0 || block >= (int)graph.n.size())
                return reject("REGION_BLOCK_OUT_OF_RANGE");
            const int last = graph.n[block].last;
            if (last < 0 || last >= (int)ip.code.size() || ip.code[last].op != 0x47)
                continue;
            // Numeric FORNPREP falls through to the body and takes its branch when the range is
            // empty. A terminal fragment has exactly one such prep, headed by the winning region.
            if (graph.n[block].succ_false != key || prep >= 0)
                return reject("FORNPREP_IDENTITY_AMBIGUOUS");
            prep = block;
        }
        if (prep < 0) return reject("FORNPREP_MISSING");
        if (planned.head_block(region) != prep) return reject("FORNPREP_NOT_REGION_HEAD");
        const int exit = graph.n[prep].succ_true;
        if (exit < 0 || blocks.count(exit)) return reject("RANGE_EXIT_NOT_EXTERNAL");

        // A real natural loop must use LoopPlan. Test exact loop identity here: an unrelated
        // enclosing dispatcher loop legitimately contains the terminal for's prep/body blocks.
        // Body-set membership alone therefore cannot prove ownership. A discovered loop owns this
        // source for only when it has the same prep or header. The closed-region test below still
        // forbids any hidden edge back to the terminal prep/body entry.
        for (const st::Loop& loop : loops)
            if (loop.prep == prep || loop.header == key)
                return reject("PREP_OR_BODY_OWNED_BY_NATURAL_LOOP");
        for (int block : blocks) {
            if (block == prep) continue;
            for (int target : {graph.n[block].succ_true, graph.n[block].succ_false}) {
                if (target == prep || target == key)
                    return reject("HIDDEN_TERMINAL_FOR_RECURRENCE");
                if (target >= 0 && !blocks.count(target) && target != exit)
                    return reject("NON_RANGE_EXTERNAL_ESCAPE");
            }
        }

        value.key = key;
        value.prep = prep;
        value.body = key;
        value.exit = exit;
        value.region = region;
        value.region_blocks = blocks;
        return true;
    };
    for (const auto& winner : planned.plan_winner) {
        if (consumed_winner_keys.count(winner.first)) continue;
        sem::TerminalForPlan terminal;
        if (terminal_numeric_for(winner.first, winner.second, terminal)) {
            manifest.terminal_fors[winner.first] = std::move(terminal);
            continue;
        }
        manifest.extra_loop_winners[winner.first] = winner.second;
        auto provenance = planned.plan_key_loops.find(winner.first);
        const std::string code = provenance == planned.plan_key_loops.end()
            || provenance->second.empty() ? "FOR_OWNER_NO_LOOP_ID" : "FOR_OWNER_ORPHANED";
        manifest.failures.push_back({code, "key=" + std::to_string(winner.first)
                                     + " region=" + std::to_string(winner.second)
                                     + " loop_ids="
                                     + std::to_string(provenance == planned.plan_key_loops.end()
                                                          ? 0 : provenance->second.size())});
    }
    for (auto& item : manifest.loops) {
        const int parent_header = item.second.parent_header;
        auto parent = manifest.loops.find(parent_header);
        if (parent != manifest.loops.end()) parent->second.child_headers.insert(item.first);
    }
    // A region that structurally owns a non-for loop but is simultaneously the winning source-for
    // claimant has two incompatible responsibilities in the current implicit plan.  Some production
    // render-time repairs recover the nesting, others do not; until that decision is represented as
    // explicit nested plan nodes, it is not verifiable and must be surfaced rather than guessed.
    for (const auto& outer_item : manifest.loops) {
        const sem::LoopPlan& outer = outer_item.second;
        if (!outer.region_only || outer.planned_region < 0) continue;
        for (const auto& inner_item : manifest.loops) {
            const sem::LoopPlan& inner = inner_item.second;
            if (inner.plan_key < 0 || inner.planned_region != outer.planned_region) continue;
            bool authoritative_ancestor = false;
            int cursor = inner.parent_header;
            std::set<int> seen_parents;
            while (cursor >= 0 && seen_parents.insert(cursor).second) {
                if (cursor == outer.header) { authoritative_ancestor = true; break; }
                auto parent = manifest.loops.find(cursor);
                if (parent == manifest.loops.end()) break;
                cursor = parent->second.parent_header;
            }
            bool contains_inner = true;
            bool inner_contains_outer = true;
            bool inner_only_terminal = true;
            int overlap = 0;
            std::string overlap_blocks, inner_only_blocks, inner_only_edges;
            for (int block : inner.body)
                if (outer.body.count(block)) {
                    ++overlap;
                    if (!overlap_blocks.empty()) overlap_blocks += ',';
                    overlap_blocks += std::to_string(block);
                } else {
                    contains_inner = false;
                    if (graph.n[block].succ_true >= 0 || graph.n[block].succ_false >= 0)
                        inner_only_terminal = false;
                    if (!inner_only_blocks.empty()) inner_only_blocks += ',';
                    inner_only_blocks += std::to_string(block);
                    if (!inner_only_edges.empty()) inner_only_edges += ';';
                    inner_only_edges += std::to_string(block) + "->"
                        + std::to_string(graph.n[block].succ_true) + ","
                        + std::to_string(graph.n[block].succ_false);
                }
            for (int block : outer.body)
                if (!inner.body.count(block)) { inner_contains_outer = false; break; }
            if (authoritative_ancestor && contains_inner) {
                manifest.loops[outer.header].shared_region_descendants.insert(inner.header);
                continue;
            }
            // Natural-loop cores are predecessor closures of a latch and therefore exclude an
            // in-loop arm that returns before reaching that latch. Pattern-for lexical bodies retain
            // the terminal arm. If dominance proves the outer loop controls the inner header and
            // every apparent containment difference is terminal, this is still valid nesting—not a
            // partially overlapping cycle.
            if (overlap > 0 && inner_only_terminal
                && st::dominates(graph, outer.header, inner.header)) {
                manifest.loops[outer.header].shared_region_descendants.insert(inner.header);
                continue;
            }
            bool reverse_ancestor = false;
            cursor = outer.parent_header;
            seen_parents.clear();
            while (cursor >= 0 && seen_parents.insert(cursor).second) {
                if (cursor == inner.header) { reverse_ancestor = true; break; }
                auto parent = manifest.loops.find(cursor);
                if (parent == manifest.loops.end()) break;
                cursor = parent->second.parent_header;
            }
            if (reverse_ancestor && inner_contains_outer) {
                manifest.loops[inner.header].shared_region_descendants.insert(outer.header);
                continue;
            }
            // A source `for` can lexically contain a dispatcher-style `while true`
            // whose natural-loop parent chain does not cross the FORGLOOP header:
            // the for iteration enters the while, while the while's backedge closes
            // only over its own header.  Full natural-body containment plus header
            // dominance is the direct CFG proof of that relationship.  Requiring
            // both keeps partially overlapping cycles fail-closed.
            if (inner_contains_outer
                && st::dominates(graph, inner.header, outer.header)) {
                manifest.loops[inner.header].shared_region_descendants.insert(outer.header);
                continue;
            }
            if (overlap == 0) {
                manifest.loops[outer.header].shared_region_peers.insert(inner.header);
                manifest.loops[inner.header].shared_region_peers.insert(outer.header);
                continue;
            }
            manifest.failures.push_back({"LOOP_REGION_ROLE_ALIAS", "outer="
                                         + std::to_string(outer.header) + " inner="
                                         + std::to_string(inner.header) + " region="
                                         + std::to_string(outer.planned_region)
                                         + " contains_inner=" + (contains_inner ? "1" : "0")
                                         + " overlap=" + std::to_string(overlap)
                                         + " outer_form=" + outer.source_form
                                         + " inner_form=" + inner.source_form
                                         + " outer_size=" + std::to_string(outer.body.size())
                                         + " inner_size=" + std::to_string(inner.body.size())
                                         + " overlap_blocks=" + overlap_blocks
                                         + " inner_only_blocks=" + inner_only_blocks
                                         + " inner_only_edges=" + inner_only_edges
                                         + " inner_header_region="
                                         + std::to_string(inner.header_region)
                                         + " inner_body_region="
                                         + std::to_string(inner.body_region)});
        }
    }
    for (const auto& item : manifest.loops) {
        const sem::LoopPlan& child = item.second;
        if (child.parent_header < 0 || child.planned_region < 0) continue;
        auto parent = manifest.loops.find(child.parent_header);
        if (parent == manifest.loops.end() || parent->second.planned_region < 0) continue;
        // Equal owner regions are not automatically wrong: one verified plan node may wrap an inner
        // loop while emitting the outer shell.  Record only a missing containment relationship here.
        if (!parent->second.planned_region_blocks.count(child.header))
            manifest.failures.push_back({"LOOP_PARENT_UNPROVEN", "child="
                                         + std::to_string(child.header) + " parent="
                                         + std::to_string(child.parent_header)});
    }
    return manifest;
}

static void print_manifest(const sem::Manifest& manifest) {
    std::printf("SEMANTIC_PLAN proto=%d status=%s reachable_blocks=%d edges=%zu predicates=%zu "
                "effects=%zu loops=%zu failures=%zu\n",
                manifest.prototype, manifest.ok() ? "MANIFEST_OK" : "MANIFEST_FAILED",
                manifest.reachable_blocks, manifest.edges.size(), manifest.predicates.size(),
                manifest.effects.size(), manifest.loops.size(), manifest.failures.size());
    for (const auto& loop : manifest.loops) {
        const sem::LoopPlan& value = loop.second;
        std::printf("LOOP header=%d parent=%d prep=%d body=%zu latches=%zu exits=%zu "
                    "plan_key=%d planned_region=%d header_region=%d body_region=%d region_only=%d "
                    "split_role_owned=%d legacy_claim_missing=%d candidates=%zu aliases=%zu "
                    "shells=%zu children=%zu shared_descendants=%zu "
                    "shared_peers=%zu planned_blocks=%zu\n",
                    value.header, value.parent_header, value.prep, value.body.size(),
                    value.latches.size(), value.exits.size(), value.plan_key, value.planned_region,
                    value.header_region, value.body_region, value.region_only ? 1 : 0,
                    value.split_role_owned ? 1 : 0, value.legacy_claim_missing ? 1 : 0,
                    value.candidate_regions.size(), value.candidate_plan_keys.size(),
                    value.shell_regions.size(), value.child_headers.size(),
                    value.shared_region_descendants.size(),
                    value.shared_region_peers.size(),
                    value.planned_region_blocks.size());
    }
    for (const auto& item : manifest.terminal_fors) {
        const sem::TerminalForPlan& value = item.second;
        std::printf("TERMINAL_FOR key=%d prep=%d body=%d exit=%d region=%d blocks=%zu\n",
                    value.key, value.prep, value.body, value.exit, value.region,
                    value.region_blocks.size());
    }
    for (const sem::Failure& failure : manifest.failures)
        std::printf("FAIL %s %s\n", failure.code.c_str(), failure.detail.c_str());
}

static std::string json_escape(const std::string& input) {
    std::string output;
    for (unsigned char character : input) {
        if (character == '\\' || character == '"') { output += '\\'; output += (char)character; }
        else if (character == '\n') output += "\\n";
        else if (character == '\r') output += "\\r";
        else if (character == '\t') output += "\\t";
        else if (character < 0x20) output += '?';
        else output += (char)character;
    }
    return output;
}

} // namespace semcmd

static int cmd_plan_verify(int argc, char** argv) {
    ir_load_namebase();
    const std::string path = argv[2];
    g_primary_ability_loop_scope = is_primary_ability_module_path(path);
    std::string bytes = read_file(path);
    de::Module module;
    try { module = de::walk(bytes); }
    catch (const std::exception& error) {
        std::fprintf(stderr, "plan-verify: walk error: %s\n", error.what());
        return 2;
    }
    std::vector<std::string> pool = ir::parse_pool(bytes);
    const int only = argc >= 4 ? std::atoi(argv[3]) : -1;
    int failures = 0;
    for (size_t index = 0; index < module.protos.size(); ++index) {
        if (only >= 0 && only != (int)index) continue;
        ir::IProto proto = ir_annotate(module.protos[index], (int)index, pool, g_nb);
        if (!proto.ok) {
            ++failures;
            std::printf("SEMANTIC_PLAN proto=%zu status=FAILED failures=1\n"
                        "FAIL ANNOTATE_FAILED %s\n", index, proto.why.c_str());
            continue;
        }
        sem::Manifest manifest = semcmd::build_manifest(proto, (int)index);
        semcmd::print_manifest(manifest);
        if (!manifest.ok()) ++failures;
    }
    return failures == 0 ? 0 : 1;
}

static int cmd_plan_verify_corpus(int argc, char** argv) {
    ir_load_namebase();
    const fs::path directory = argv[2];
    bool abilities_only = false;
    std::string json_path;
    for (int argument = 3; argument < argc; ++argument) {
        std::string value = argv[argument];
        if (value == "--abilities") abilities_only = true;
        else if (value == "--json-out" && argument + 1 < argc) json_path = argv[++argument];
    }
    if (!fs::is_directory(directory)) {
        std::fprintf(stderr, "plan-verify-corpus: input is not a directory: %s\n",
                     directory.string().c_str());
        return 2;
    }
    std::vector<fs::path> files;
    for (const auto& entry : fs::directory_iterator(directory)) {
        if (!entry.is_regular_file() || entry.path().extension() != ".lua_B") continue;
        if (abilities_only && !is_primary_ability_module_path(entry.path().string())) continue;
        files.push_back(entry.path());
    }
    std::sort(files.begin(), files.end());
    long long prototypes = 0, manifest_ok = 0, failed = 0, annotate_failed = 0;
    long long blocks = 0, edges = 0, predicates = 0, effects = 0, loops = 0;
    long long terminal_for_fragments = 0;
    std::map<std::string, long long> categories;
    std::map<std::string, long long> files_by_category;
    std::vector<std::string> examples;
    for (const fs::path& file : files) {
        const std::string path = file.string();
        g_primary_ability_loop_scope = is_primary_ability_module_path(path);
        std::string bytes = read_file(path);
        de::Module module;
        try { module = de::walk(bytes); }
        catch (...) { categories["WALK_FAILED"]++; continue; }
        std::vector<std::string> pool = ir::parse_pool(bytes);
        std::set<std::string> file_categories;
        for (size_t index = 0; index < module.protos.size(); ++index) {
            ++prototypes;
            ir::IProto proto = ir_annotate(module.protos[index], (int)index, pool, g_nb);
            if (!proto.ok) {
                ++failed; ++annotate_failed; ++categories["ANNOTATE_FAILED"];
                file_categories.insert("ANNOTATE_FAILED");
                continue;
            }
            sem::Manifest manifest = semcmd::build_manifest(proto, (int)index);
            blocks += manifest.reachable_blocks;
            edges += (long long)manifest.edges.size();
            predicates += (long long)manifest.predicates.size();
            effects += (long long)manifest.effects.size();
            loops += (long long)manifest.loops.size();
            terminal_for_fragments += (long long)manifest.terminal_fors.size();
            if (manifest.ok()) ++manifest_ok;
            else {
                ++failed;
                for (const sem::Failure& failure : manifest.failures) {
                    ++categories[failure.code];
                    file_categories.insert(failure.code);
                    if (examples.size() < 5000)
                        examples.push_back(file.filename().string() + "\tproto="
                                           + std::to_string(index) + "\t" + failure.code + "\t"
                                           + failure.detail);
                }
            }
        }
        for (const std::string& category : file_categories) ++files_by_category[category];
    }
    std::printf("== SEMANTIC OWNERSHIP MANIFEST BASELINE ==\n");
    std::printf("files=%zu prototypes=%lld manifest_ok=%lld failed=%lld annotate_failed=%lld\n",
                files.size(), prototypes, manifest_ok, failed, annotate_failed);
    std::printf("reachable_blocks=%lld edges=%lld predicates=%lld obvious_effects=%lld loops=%lld\n",
                blocks, edges, predicates, effects, loops);
    std::printf("terminal_for_fragments=%lld\n", terminal_for_fragments);
    for (const auto& category : categories)
        std::printf("FAILURE %-28s occurrences=%lld files=%lld\n", category.first.c_str(),
                    category.second, files_by_category[category.first]);
    for (const std::string& example : examples) std::printf("EXAMPLE\t%s\n", example.c_str());

    if (!json_path.empty()) {
        std::ostringstream json;
        json << "{\n  \"scope\": \"" << (abilities_only ? "abilities" : "all") << "\",\n"
             << "  \"directory\": \"" << semcmd::json_escape(fs::absolute(directory).string()) << "\",\n"
             << "  \"files\": " << files.size() << ",\n"
             << "  \"prototypes\": " << prototypes << ",\n"
             << "  \"manifest_ok\": " << manifest_ok << ",\n"
             << "  \"render_semantics_verified\": false,\n"
             << "  \"failed\": " << failed << ",\n"
             << "  \"reachable_blocks\": " << blocks << ",\n"
             << "  \"edges\": " << edges << ",\n"
             << "  \"predicates\": " << predicates << ",\n"
             << "  \"obvious_effects\": " << effects << ",\n"
             << "  \"loops\": " << loops << ",\n"
             << "  \"terminal_for_fragments\": " << terminal_for_fragments << ",\n"
             << "  \"failure_categories\": {";
        bool first = true;
        for (const auto& category : categories) {
            if (!first) json << ',';
            json << "\n    \"" << semcmd::json_escape(category.first) << "\": {\"occurrences\": "
                 << category.second << ", \"files\": " << files_by_category[category.first] << '}';
            first = false;
        }
        if (!categories.empty()) json << '\n';
        json << "  },\n  \"examples\": [";
        for (size_t index = 0; index < examples.size(); ++index) {
            if (index) json << ',';
            json << "\n    \"" << semcmd::json_escape(examples[index]) << '"';
        }
        if (!examples.empty()) json << '\n';
        json << "  ]\n}\n";
        fs::path json_destination = json_path;
        std::error_code directory_error;
        if (json_destination.has_parent_path())
            fs::create_directories(json_destination.parent_path(), directory_error);
        if (directory_error || !write_file(json_path, json.str())) {
            std::fprintf(stderr, "plan-verify-corpus: cannot write JSON: %s\n", json_path.c_str());
            return 2;
        }
        std::printf("json=%s\n", json_path.c_str());
    }
    // A baseline command reports discovered semantic-plan failures through its summary and JSON.
    // Operational errors use exit 2; known verification failures use exit 1 so automation cannot
    // accidentally treat an unsafe corpus as clean.
    return failed == 0 && categories.empty() ? 0 : 1;
}
