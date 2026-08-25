// semantic_ir/value_flow.h -- source-neutral reaching definitions for DE register bytecode.
#pragma once
#include "../liveness.h"
#include "../semantic_plan.h"
#include <map>
#include <set>
#include <vector>

namespace sir::vf {

enum class OriginKind { Parameter = 0, EntryRegister = 1, Instruction = 2 };

struct Origin {
    OriginKind kind = OriginKind::EntryRegister;
    int instruction = -1;
    int reg = -1;
    bool operator<(const Origin& other) const {
        if (kind != other.kind) return (int)kind < (int)other.kind;
        if (instruction != other.instruction) return instruction < other.instruction;
        return reg < other.reg;
    }
    bool operator==(const Origin& other) const {
        return kind == other.kind && instruction == other.instruction && reg == other.reg;
    }
};

struct Definition {
    Origin origin;
    bool open_range = false;
    bool operator<(const Definition& other) const {
        if (origin < other.origin) return true;
        if (other.origin < origin) return false;
        return open_range < other.open_range;
    }
};

struct Use {
    int instruction = -1;
    int reg = -1;
    bool open_range = false;
    std::set<Origin> reaching;
};

using State = std::vector<std::set<Origin>>;

struct Analysis {
    bool known = true;
    bool converged = true;
    int iterations = 0;
    std::set<Definition> definitions;
    std::vector<Use> uses;
    std::map<int, State> block_in;
    std::map<int, State> block_out;
};

enum class TopKind { Fixed = 0, OpenCall = 1, OpenVararg = 2 };

struct TopOrigin {
    TopKind kind = TopKind::Fixed;
    int instruction = -1;
    int base = 0;
    int fixed_top = -1;
    bool operator<(const TopOrigin& other) const {
        if (kind != other.kind) return (int)kind < (int)other.kind;
        if (instruction != other.instruction) return instruction < other.instruction;
        if (base != other.base) return base < other.base;
        return fixed_top < other.fixed_top;
    }
    bool operator==(const TopOrigin& other) const {
        return kind == other.kind && instruction == other.instruction
            && base == other.base && fixed_top == other.fixed_top;
    }
};

struct TopUse {
    int instruction = -1;
    int first_register = -1;
    uint8_t opcode = 0;
    std::set<TopOrigin> reaching;
};

struct TopAnalysis {
    bool known = true;
    bool converged = true;
    int iterations = 0;
    std::vector<TopUse> uses;
    std::map<int, std::set<TopOrigin>> block_in;
    std::map<int, std::set<TopOrigin>> block_out;
};

inline bool is_open_use(const ir::IInsn& instruction, int reg) {
    if (instruction.op == 0x54 && instruction.B == 0)
        return reg >= instruction.A;
    if (instruction.op == 0x29 && instruction.B == 0)
        return reg >= instruction.A;
    if (instruction.op == 0x3f && instruction.C == 0)
        return reg >= instruction.B;
    return false;
}

inline bool is_open_definition(const ir::IInsn& instruction, int reg) {
    if (instruction.op == 0x54 && instruction.C == 0)
        return reg >= instruction.A;
    if (instruction.op == 0x4c && instruction.B == 0)
        return reg >= instruction.A;
    return false;
}

inline State entry_state(const ir::IProto& proto) {
    State state((size_t)std::max(0, proto.maxstack));
    for (int reg = 0; reg < proto.maxstack; ++reg) {
        Origin origin;
        origin.kind = reg < proto.nparams ? OriginKind::Parameter
                                          : OriginKind::EntryRegister;
        origin.reg = reg;
        state[(size_t)reg].insert(origin);
    }
    return state;
}

inline void union_state(State& destination, const State& source) {
    if (destination.size() < source.size()) destination.resize(source.size());
    for (size_t reg = 0; reg < source.size(); ++reg)
        destination[reg].insert(source[reg].begin(), source[reg].end());
}

inline bool transfer_block(const ir::IProto& proto, const sem::Manifest& manifest,
                           int block, const State& input, State& output,
                           std::set<Definition>* definitions = nullptr,
                           std::vector<Use>* uses = nullptr) {
    auto range = manifest.block_instruction_ranges.find(block);
    if (range == manifest.block_instruction_ranges.end()) return false;
    State current = input;
    for (int index = range->second.first;
         index <= range->second.second && index < (int)proto.code.size(); ++index) {
        if (index < 0) continue;
        const ir::IInsn& instruction = proto.code[(size_t)index];
        std::set<int> instruction_uses, instruction_defs;
        if (!lv::register_effects(proto, instruction, instruction_uses, instruction_defs))
            return false;
        if (uses)
            for (int reg : instruction_uses) {
                Use use;
                use.instruction = index; use.reg = reg;
                use.open_range = is_open_use(instruction, reg);
                if (reg >= 0 && reg < (int)current.size()) use.reaching = current[(size_t)reg];
                uses->push_back(std::move(use));
            }
        for (int reg : instruction_defs) {
            if (reg < 0 || reg >= (int)current.size()) continue;
            Origin origin{OriginKind::Instruction, index, reg};
            current[(size_t)reg].clear();
            current[(size_t)reg].insert(origin);
            if (definitions)
                definitions->insert(Definition{origin, is_open_definition(instruction, reg)});
        }
    }
    output = std::move(current);
    return true;
}

inline Analysis analyze(const ir::IProto& proto, const sem::Manifest& manifest) {
    Analysis analysis;
    if (manifest.reachable_block_ids.empty()) return analysis;
    int entry_block = -1, entry_instruction = 0x7fffffff;
    for (int block : manifest.reachable_block_ids) {
        auto range = manifest.block_instruction_ranges.find(block);
        if (range != manifest.block_instruction_ranges.end()
            && range->second.first < entry_instruction) {
            entry_instruction = range->second.first;
            entry_block = block;
        }
        analysis.block_in[block] = State((size_t)std::max(0, proto.maxstack));
        analysis.block_out[block] = State((size_t)std::max(0, proto.maxstack));
    }
    const State initial = entry_state(proto);
    bool changed = true;
    while (changed && analysis.iterations++ < 10000) {
        changed = false;
        for (int block : manifest.reachable_block_ids) {
            State next_in((size_t)std::max(0, proto.maxstack));
            if (block == entry_block) union_state(next_in, initial);
            auto predecessors = manifest.block_predecessors.find(block);
            if (predecessors != manifest.block_predecessors.end())
                for (int predecessor : predecessors->second) {
                    auto predecessor_out = analysis.block_out.find(predecessor);
                    if (predecessor_out != analysis.block_out.end())
                        union_state(next_in, predecessor_out->second);
                }
            State next_out;
            if (!transfer_block(proto, manifest, block, next_in, next_out)) {
                analysis.known = false;
                return analysis;
            }
            if (next_in != analysis.block_in[block]
                || next_out != analysis.block_out[block]) {
                analysis.block_in[block] = std::move(next_in);
                analysis.block_out[block] = std::move(next_out);
                changed = true;
            }
        }
    }
    analysis.converged = !changed;
    if (!analysis.converged) return analysis;
    for (int block : manifest.reachable_block_ids) {
        State ignored;
        if (!transfer_block(proto, manifest, block, analysis.block_in[block], ignored,
                            &analysis.definitions, &analysis.uses)) {
            analysis.known = false;
            break;
        }
    }
    return analysis;
}

inline bool is_open_top_consumer(const ir::IInsn& instruction) {
    return (instruction.op == 0x54 && instruction.B == 0)
        || (instruction.op == 0x29 && instruction.B == 0)
        || (instruction.op == 0x3f && instruction.C == 0);
}

inline int open_top_first_register(const ir::IInsn& instruction) {
    return instruction.op == 0x3f ? instruction.B : instruction.A;
}

inline bool transfer_top_block(const ir::IProto& proto, const sem::Manifest& manifest,
                               int block, const std::set<TopOrigin>& input,
                               std::set<TopOrigin>& output,
                               std::vector<TopUse>* uses = nullptr) {
    auto range = manifest.block_instruction_ranges.find(block);
    if (range == manifest.block_instruction_ranges.end()) return false;
    std::set<TopOrigin> current = input;
    for (int index = range->second.first;
         index <= range->second.second && index < (int)proto.code.size(); ++index) {
        if (index < 0) continue;
        const ir::IInsn& instruction = proto.code[(size_t)index];
        if (uses && is_open_top_consumer(instruction))
            uses->push_back(TopUse{index, open_top_first_register(instruction),
                                   instruction.op, current});
        if (instruction.op == 0x54) {
            const int results = (int)instruction.C - 1;
            current.clear();
            if (results < 0)
                current.insert(TopOrigin{TopKind::OpenCall, index, instruction.A, -1});
            else
                current.insert(TopOrigin{TopKind::Fixed, index, 0,
                                         (int)instruction.A + results - 1});
            continue;
        }
        if (instruction.op == 0x4c) {
            const int results = (int)instruction.B - 1;
            current.clear();
            if (instruction.B == 0)
                current.insert(TopOrigin{TopKind::OpenVararg, index, instruction.A, -1});
            else
                current.insert(TopOrigin{TopKind::Fixed, index, 0,
                                         (int)instruction.A + results - 1});
            continue;
        }
        std::set<int> instruction_uses, instruction_defs;
        if (!lv::register_effects(proto, instruction, instruction_uses, instruction_defs))
            return false;
        if (!instruction_defs.empty()) {
            const int highest = *instruction_defs.rbegin();
            std::set<TopOrigin> updated;
            for (TopOrigin origin : current) {
                if (origin.kind == TopKind::Fixed)
                    origin.fixed_top = std::max(origin.fixed_top, highest);
                updated.insert(origin);
            }
            current.swap(updated);
        }
    }
    output = std::move(current);
    return true;
}

inline TopAnalysis analyze_top(const ir::IProto& proto, const sem::Manifest& manifest) {
    TopAnalysis analysis;
    if (manifest.reachable_block_ids.empty()) return analysis;
    int entry_block = -1, entry_instruction = 0x7fffffff;
    for (int block : manifest.reachable_block_ids) {
        auto range = manifest.block_instruction_ranges.find(block);
        if (range != manifest.block_instruction_ranges.end()
            && range->second.first < entry_instruction) {
            entry_instruction = range->second.first;
            entry_block = block;
        }
        analysis.block_in[block] = {};
        analysis.block_out[block] = {};
    }
    const TopOrigin initial{TopKind::Fixed, -1, 0, proto.nparams - 1};
    bool changed = true;
    while (changed && analysis.iterations++ < 10000) {
        changed = false;
        for (int block : manifest.reachable_block_ids) {
            std::set<TopOrigin> next_in;
            if (block == entry_block) next_in.insert(initial);
            auto predecessors = manifest.block_predecessors.find(block);
            if (predecessors != manifest.block_predecessors.end())
                for (int predecessor : predecessors->second) {
                    auto predecessor_out = analysis.block_out.find(predecessor);
                    if (predecessor_out != analysis.block_out.end())
                        next_in.insert(predecessor_out->second.begin(),
                                       predecessor_out->second.end());
                }
            std::set<TopOrigin> next_out;
            if (!transfer_top_block(proto, manifest, block, next_in, next_out)) {
                analysis.known = false;
                return analysis;
            }
            if (next_in != analysis.block_in[block]
                || next_out != analysis.block_out[block]) {
                analysis.block_in[block] = std::move(next_in);
                analysis.block_out[block] = std::move(next_out);
                changed = true;
            }
        }
    }
    analysis.converged = !changed;
    if (!analysis.converged) return analysis;
    for (int block : manifest.reachable_block_ids) {
        std::set<TopOrigin> ignored;
        if (!transfer_top_block(proto, manifest, block, analysis.block_in[block], ignored,
                                &analysis.uses)) {
            analysis.known = false;
            break;
        }
    }
    return analysis;
}

inline bool top_contracts_closed(const ir::IProto& proto, const sem::Manifest& manifest,
                                 const TopAnalysis& analysis) {
    if (!analysis.known || !analysis.converged) return false;
    std::map<int, int> instruction_block;
    std::set<int> producers;
    for (const auto& range_item : manifest.block_instruction_ranges)
        for (int instruction = range_item.second.first;
             instruction <= range_item.second.second && instruction < (int)proto.code.size();
             ++instruction) {
            if (instruction < 0) continue;
            instruction_block[instruction] = range_item.first;
            const ir::IInsn& candidate = proto.code[(size_t)instruction];
            if ((candidate.op == 0x54 && candidate.C == 0)
                || (candidate.op == 0x4c && candidate.B == 0))
                producers.insert(instruction);
        }
    std::map<int, int> consumption;
    for (const TopUse& use : analysis.uses) {
        if (use.reaching.size() != 1) return false;
        const TopOrigin& origin = *use.reaching.begin();
        if (origin.kind != TopKind::OpenCall && origin.kind != TopKind::OpenVararg)
            return false;
        if (!producers.count(origin.instruction)
            || instruction_block[origin.instruction] != instruction_block[use.instruction])
            return false;
        ++consumption[origin.instruction];
    }
    for (int producer : producers)
        if (consumption[producer] != 1) return false;
    return true;
}

} // namespace sir::vf
