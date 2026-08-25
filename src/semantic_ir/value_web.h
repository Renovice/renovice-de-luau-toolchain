// semantic_ir/value_web.h -- value webs and CFG-evidenced multi-origin merges.
#pragma once
#include "local_lifetime.h"
#include <map>
#include <set>
#include <vector>

namespace sir::webs {

struct Analysis {
    bool known = true;
    std::string failure;
    std::set<ValueWebContract> webs;
    std::set<ValueMergeContract> merges;
};

inline ValueOriginContract root_of(
    std::map<ValueOriginContract, ValueOriginContract>& parent,
    const ValueOriginContract& value) {
    auto found = parent.find(value);
    if (found == parent.end()) return value;
    if (found->second == value) return value;
    found->second = root_of(parent, found->second);
    return found->second;
}

inline void unite(std::map<ValueOriginContract, ValueOriginContract>& parent,
                  const ValueOriginContract& left,
                  const ValueOriginContract& right) {
    const ValueOriginContract left_root = root_of(parent, left);
    const ValueOriginContract right_root = root_of(parent, right);
    if (left_root == right_root) return;
    if (right_root < left_root) parent[left_root] = right_root;
    else parent[right_root] = left_root;
}

inline LoopId loop_evidence(const sem::Manifest& manifest,
                            const vf::Analysis& flow, const LocalUseSite& use,
                            int reg,
                            const std::set<ValueOriginContract>& origins) {
    int best = -1;
    size_t best_size = (size_t)-1;
    for (const auto& item : manifest.loops) {
        const sem::LoopPlan& loop = item.second;
        if (!loop.body.count(use.block.value)) continue;
        bool crosses_latch = false;
        for (int latch : loop.latches) {
            bool authoritative_backedge = false;
            for (const auto& edge : loop.backedges)
                if (edge.first == latch && loop.body.count(edge.second)) {
                    authoritative_backedge = true; break;
                }
            if (!authoritative_backedge) continue;
            auto state = flow.block_out.find(latch);
            if (state == flow.block_out.end()) continue;
            for (const ValueOriginContract& origin : origins) {
                const vf::Origin converted{(vf::OriginKind)origin.kind,
                                           origin.instruction, origin.reg};
                if (locals::contains_origin(state->second, reg, converted)) {
                    crosses_latch = true; break;
                }
            }
            if (crosses_latch) break;
        }
        if (crosses_latch && loop.body.size() < best_size) {
            best = item.first; best_size = loop.body.size();
        }
    }
    return LoopId(best);
}

inline BlockId conditional_evidence(
    const sem::Manifest& manifest, const LocalUseSite& use,
    const std::set<ValueOriginContract>& origins,
    const std::map<ValueOriginContract, BlockId>& definition_blocks) {
    int best = -1;
    size_t best_depth = 0;
    for (const sem::PredicatePlan& predicate : manifest.predicates) {
        if (!predicate.proven || predicate.role != "branch_region" || predicate.join < 0)
            continue;
        auto use_dominators = manifest.block_dominators.find(use.block.value);
        if (use_dominators == manifest.block_dominators.end()
            || !use_dominators->second.count(predicate.join)) continue;
        bool in_true = false, in_false = false, incoming = false, invalid = false;
        auto predicate_dominators = manifest.block_dominators.find(predicate.block);
        for (const ValueOriginContract& origin : origins) {
            auto definition = definition_blocks.find(origin);
            if (definition == definition_blocks.end()) { invalid = true; break; }
            const int block = definition->second.value;
            if (predicate.true_blocks.count(block)) in_true = true;
            else if (predicate.false_blocks.count(block)) in_false = true;
            else if (predicate_dominators != manifest.block_dominators.end()
                     && predicate_dominators->second.count(block)) incoming = true;
            else { invalid = true; break; }
        }
        const int paths = (in_true ? 1 : 0) + (in_false ? 1 : 0) + (incoming ? 1 : 0);
        if (invalid || paths < 2 || (!in_true && !in_false)) continue;
        const size_t depth = predicate_dominators == manifest.block_dominators.end()
            ? 0 : predicate_dominators->second.size();
        if (best < 0 || depth > best_depth
            || (depth == best_depth && predicate.block < best)) {
            best = predicate.block; best_depth = depth;
        }
    }
    return BlockId(best);
}

inline Analysis analyze(const sem::Manifest& manifest, const vf::Analysis& flow,
                        PrototypeId owner,
                        const std::set<LocalValueContract>& local_values) {
    Analysis out;
    std::map<ValueOriginContract, ValueOriginContract> parent;
    std::map<ValueOriginContract, const LocalValueContract*> local_by_origin;
    std::map<ValueOriginContract, BlockId> definition_blocks;
    for (const LocalValueContract& value : local_values) {
        parent[value.identity] = value.identity;
        local_by_origin[value.identity] = &value;
        definition_blocks[value.identity] = value.definition_block;
    }

    struct RawMerge {
        LocalUseSite use;
        int reg = -1;
        std::set<ValueOriginContract> origins;
    };
    std::vector<RawMerge> raw_merges;
    for (const vf::Use& use : flow.uses) {
        std::set<ValueOriginContract> origins;
        for (const vf::Origin& origin : use.reaching) {
            if (origin.kind == vf::OriginKind::EntryRegister) continue;
            const ValueOriginContract converted{(int)origin.kind,
                                                origin.instruction, origin.reg};
            if (!parent.count(converted)) {
                out.known = false; out.failure = "merge origin has no local identity";
                return out;
            }
            origins.insert(converted);
        }
        if (origins.size() < 2) continue;
        auto block = std::find_if(manifest.block_instruction_ranges.begin(),
                                  manifest.block_instruction_ranges.end(),
            [&](const auto& item) {
                return item.second.first <= use.instruction
                    && use.instruction <= item.second.second;
            });
        if (block == manifest.block_instruction_ranges.end()) {
            out.known = false; out.failure = "merge use block unavailable"; return out;
        }
        auto first = origins.begin();
        for (auto other = std::next(first); other != origins.end(); ++other)
            unite(parent, *first, *other);
        raw_merges.push_back({LocalUseSite{BlockId(block->first), use.instruction},
                              use.reg, std::move(origins)});
    }

    std::map<ValueOriginContract, std::set<ValueOriginContract>> groups;
    for (const auto& item : parent) groups[root_of(parent, item.first)].insert(item.first);
    std::map<ValueOriginContract, int> group_ids;
    std::map<ValueOriginContract, int> origin_web;
    int next_id = 0;
    for (const auto& item : groups) {
        group_ids[item.first] = next_id;
        for (const ValueOriginContract& origin : item.second)
            origin_web[origin] = next_id;
        ++next_id;
    }

    std::map<int, ValueWebContract> by_id;
    for (const auto& item : groups) {
        ValueWebContract web;
        web.owner = owner; web.id = group_ids[item.first];
        web.reg = item.second.begin()->reg; web.members = item.second;
        std::set<int> declaration_inputs;
        for (const ValueOriginContract& origin : web.members) {
            const LocalValueContract& local = *local_by_origin.at(origin);
            if (origin.reg != web.reg) {
                out.known = false; out.failure = "web crosses physical registers"; return out;
            }
            declaration_inputs.insert(local.definition_block.value);
            web.uses.insert(local.uses.begin(), local.uses.end());
            for (const LocalUseSite& use : local.uses)
                declaration_inputs.insert(use.block.value);
        }
        web.declaration_block = locals::nearest_common_dominator(
            manifest, declaration_inputs);
        if (!web.declaration_block.valid()) {
            out.known = false; out.failure = "web declaration owner unavailable"; return out;
        }
        by_id[web.id] = web;
    }

    for (const RawMerge& raw : raw_merges) {
        ValueMergeContract merge;
        merge.owner = owner; merge.use = raw.use; merge.reg = raw.reg;
        merge.origins = raw.origins; merge.web_id = origin_web.at(*raw.origins.begin());
        merge.loop = loop_evidence(manifest, flow, raw.use, raw.reg, raw.origins);
        merge.conditional_source = conditional_evidence(
            manifest, raw.use, raw.origins, definition_blocks);
        if (merge.loop.valid() && merge.conditional_source.valid())
            merge.kind = ValueMergeKind::ConditionalLoop;
        else if (merge.loop.valid()) merge.kind = ValueMergeKind::LoopCarried;
        else if (merge.conditional_source.valid()) merge.kind = ValueMergeKind::Conditional;
        else merge.kind = ValueMergeKind::Preserved;
        by_id[merge.web_id].merge_uses.insert(merge.use);
        out.merges.insert(std::move(merge));
    }
    for (const auto& item : by_id) out.webs.insert(item.second);
    return out;
}

} // namespace sir::webs
