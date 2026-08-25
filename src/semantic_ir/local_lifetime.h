// semantic_ir/local_lifetime.h -- source-neutral local value lifetime contracts.
#pragma once
#include "model.h"
#include "value_flow.h"
#include <algorithm>
#include <map>
#include <set>

namespace sir::locals {

struct Analysis {
    bool known = true;
    std::string failure;
    std::set<LocalValueContract> values;
};

inline bool contains_origin(const vf::State& state, int reg,
                            const vf::Origin& origin) {
    return reg >= 0 && reg < (int)state.size()
        && state[(size_t)reg].count(origin) != 0;
}

inline BlockId nearest_common_dominator(
    const std::map<int, std::set<int>>& block_dominators,
    const std::set<int>& blocks) {
    if (blocks.empty()) return BlockId();
    std::set<int> common;
    bool first = true;
    for (int block : blocks) {
        auto found = block_dominators.find(block);
        if (found == block_dominators.end()) return BlockId();
        if (first) {
            common = found->second;
            first = false;
        } else {
            std::set<int> intersection;
            std::set_intersection(common.begin(), common.end(), found->second.begin(),
                                  found->second.end(),
                                  std::inserter(intersection, intersection.begin()));
            common.swap(intersection);
        }
    }
    int best = -1;
    size_t best_depth = 0;
    for (int candidate : common) {
        auto found = block_dominators.find(candidate);
        const size_t depth = found == block_dominators.end()
            ? 0 : found->second.size();
        if (best < 0 || depth > best_depth
            || (depth == best_depth && candidate < best)) {
            best = candidate;
            best_depth = depth;
        }
    }
    return BlockId(best);
}

inline BlockId nearest_common_dominator(const sem::Manifest& manifest,
                                        const std::set<int>& blocks) {
    return nearest_common_dominator(manifest.block_dominators, blocks);
}

inline Analysis analyze(const ir::IProto& proto, const sem::Manifest& manifest,
                        const vf::Analysis& flow, PrototypeId owner) {
    Analysis out;
    if (!flow.known || !flow.converged) {
        out.known = false; out.failure = "value flow unavailable"; return out;
    }
    std::map<int, int> instruction_block;
    int entry_block = -1;
    int entry_instruction = 0x7fffffff;
    for (int block : manifest.reachable_block_ids) {
        auto range = manifest.block_instruction_ranges.find(block);
        if (range == manifest.block_instruction_ranges.end()) {
            out.known = false; out.failure = "reachable block has no range"; return out;
        }
        if (range->second.first < entry_instruction) {
            entry_instruction = range->second.first; entry_block = block;
        }
        for (int instruction = range->second.first;
             instruction <= range->second.second
                 && instruction < (int)proto.code.size(); ++instruction)
            if (instruction >= 0) instruction_block[instruction] = block;
    }
    if (entry_block < 0) {
        out.known = false; out.failure = "entry block unavailable"; return out;
    }

    std::map<int, std::set<int>> block_successors;
    for (const auto& item : manifest.block_predecessors)
        for (int predecessor : item.second)
            block_successors[predecessor].insert(item.first);
    std::map<vf::Origin, LocalValueContract> contracts;
    for (int reg = 0; reg < proto.nparams; ++reg) {
        const vf::Origin origin{vf::OriginKind::Parameter, -1, reg};
        LocalValueContract value;
        value.owner = owner;
        value.identity = ValueOriginContract{(int)origin.kind, origin.instruction, origin.reg};
        value.definition_block = BlockId(entry_block);
        value.parameter = true;
        contracts[origin] = value;
    }
    for (const vf::Definition& definition : flow.definitions) {
        auto block = instruction_block.find(definition.origin.instruction);
        if (block == instruction_block.end()) {
            out.known = false; out.failure = "definition block unavailable"; return out;
        }
        LocalValueContract value;
        value.owner = owner;
        value.identity = ValueOriginContract{(int)definition.origin.kind,
                                             definition.origin.instruction,
                                             definition.origin.reg};
        value.definition_block = BlockId(block->second);
        contracts[definition.origin] = value;
    }

    std::map<vf::Origin, std::map<int, std::set<int>>> events;
    for (const auto& item : contracts)
        if (!item.second.parameter)
            events[item.first][item.second.definition_block.value].insert(
                item.first.instruction);
    for (const vf::Use& use : flow.uses) {
        auto block = instruction_block.find(use.instruction);
        if (block == instruction_block.end()) {
            out.known = false; out.failure = "use block unavailable"; return out;
        }
        for (const vf::Origin& origin : use.reaching) {
            auto value = contracts.find(origin);
            if (value == contracts.end()) {
                if (origin.kind == vf::OriginKind::EntryRegister) continue;
                out.known = false; out.failure = "use origin has no value identity"; return out;
            }
            value->second.uses.insert(LocalUseSite{BlockId(block->second), use.instruction});
            events[origin][block->second].insert(use.instruction);
        }
    }

    for (auto& item : contracts) {
        const vf::Origin& origin = item.first;
        LocalValueContract& value = item.second;
        std::set<int> declaration_inputs = {value.definition_block.value};
        for (const LocalUseSite& use : value.uses) declaration_inputs.insert(use.block.value);
        value.declaration_block = nearest_common_dominator(manifest, declaration_inputs);
        if (!value.declaration_block.valid()) {
            out.known = false; out.failure = "common dominator unavailable"; return out;
        }
        std::set<int> live_blocks;
        std::vector<int> pending;
        for (const LocalUseSite& use : value.uses)
            if (live_blocks.insert(use.block.value).second)
                pending.push_back(use.block.value);
        for (size_t cursor = 0; cursor < pending.size(); ++cursor) {
            const int block = pending[cursor];
            auto incoming = flow.block_in.find(block);
            if (incoming == flow.block_in.end()
                || !contains_origin(incoming->second, origin.reg, origin))
                continue; // the value is defined inside this block
            auto predecessors = manifest.block_predecessors.find(block);
            if (predecessors == manifest.block_predecessors.end()) continue;
            for (int predecessor : predecessors->second) {
                auto outgoing = flow.block_out.find(predecessor);
                if (outgoing != flow.block_out.end()
                    && contains_origin(outgoing->second, origin.reg, origin)
                    && live_blocks.insert(predecessor).second)
                    pending.push_back(predecessor);
            }
        }
        live_blocks.insert(value.definition_block.value);
        for (int block : live_blocks) {
            auto range = manifest.block_instruction_ranges.find(block);
            const auto incoming = flow.block_in.find(block);
            const auto outgoing = flow.block_out.find(block);
            const bool live_in = incoming != flow.block_in.end()
                && contains_origin(incoming->second, origin.reg, origin);
            bool live_out = false;
            if (outgoing != flow.block_out.end()
                && contains_origin(outgoing->second, origin.reg, origin)) {
                for (int successor : block_successors[block]) {
                    auto successor_in = flow.block_in.find(successor);
                    if (live_blocks.count(successor)
                        && successor_in != flow.block_in.end()
                        && contains_origin(successor_in->second, origin.reg, origin)) {
                        live_out = true; break;
                    }
                }
            }
            auto block_events = events[origin].find(block);
            const bool has_events = block_events != events[origin].end();
            int first_instruction = live_in ? range->second.first
                : (has_events ? *block_events->second.begin() : range->second.first);
            int last_instruction = live_out ? range->second.second
                : (has_events ? *block_events->second.rbegin() : first_instruction);
            value.lifetimes.insert(LocalBlockLifetime{BlockId(block), first_instruction,
                                                      last_instruction, live_in, live_out});
        }
        if (value.lifetimes.empty()) {
            out.known = false; out.failure = "value has no lifetime interval"; return out;
        }
    }
    for (const auto& item : contracts) out.values.insert(item.second);
    return out;
}

} // namespace sir::locals
