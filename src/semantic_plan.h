// semantic_plan.h -- read-only semantic ownership manifest and verifier results.
//
// This is deliberately NOT a source AST and does not render Luau.  It freezes the facts that must
// survive the boundary between CFG/region analysis and text rendering.  The first version records
// blocks, CFG edges, predicates, effects, authoritative loops, and the existing emitter PLAN pass's
// chosen loop owners.  Later value/capture/result ownership can extend this data model without
// putting more analysis back into emit.h.
#pragma once
#include <map>
#include <set>
#include <string>
#include <utility>
#include <vector>

namespace sem {

enum class EdgeKind {
    Fallthrough,
    ConditionalTrue,
    ConditionalFalse,
    Unconditional,
    Backedge,
    LoopExit,
    Return
};

struct EdgePlan {
    int source = -1;
    int target = -1;
    int arm = 0;                       // 1 = branch-taken, 0 = fallthrough/only edge
    EdgeKind kind = EdgeKind::Fallthrough;
    int loop_header = -1;              // loop whose backedge/exit this edge represents
};

struct PredicatePlan {
    int block = -1;
    int instruction = -1;
    int true_target = -1;
    int false_target = -1;
    int join = -1;
    bool virtual_exit_join = false;
    bool shared_entry_join = false;
    int chain_next = -1;
    int chain_shared_target = -1;
    std::string chain_mode;
    std::string loop_action;
    int loop_header = -1;
    std::string role;
    std::set<int> true_blocks;
    std::set<int> false_blocks;
    std::set<int> overlap_blocks;
    bool true_has_terminal = false;
    bool false_has_terminal = false;
    bool true_escapes_region = false;
    bool false_escapes_region = false;
    bool explicitly_preserved = false;
    bool proven = false;
};

struct EffectPlan {
    int instruction = -1;
    int block = -1;
    std::string opcode;
};

struct LoopPlan {
    int header = -1;
    int prep = -1;
    std::string source_form;
    std::set<int> body;
    std::set<int> latches;
    int canonical_latch = -1;
    std::set<std::pair<int, int>> backedges;
    std::set<std::pair<int, int>> exits;
    int parent_header = -1;

    int plan_key = -1;                 // existing emitter key, which is not always the loop header
    int planned_region = -1;           // winner from the existing pre-render PLAN pass
    bool region_only = false;           // non-for loop known only to structural ownership
    std::set<int> candidate_regions;    // all regions that attempted to claim this LoopId
    std::set<int> candidate_plan_keys;  // historical aliases observed across those claims
    int header_region = -1;             // region responsible only for source `for ... do` text
    int body_region = -1;               // smallest complete authoritative-body container
    bool split_role_owned = false;      // header/body roles independently proven by CFG regions
    bool legacy_claim_missing = false;  // old emitter supplied no claimant; diagnostic only
    std::set<int> shell_regions;         // enclosing control-flow roles; never duplicate wrappers
    std::set<int> child_headers;         // authoritative direct child LoopIds
    std::set<int> shared_region_descendants; // nested LoopIds whose role shares this owner region
    std::set<int> shared_region_peers;   // disjoint sibling LoopIds in one reduced container
    std::set<int> planned_region_blocks;
};

struct Failure {
    std::string code;
    std::string detail;
};

struct Manifest {
    int prototype = -1;
    int reachable_blocks = 0;
    std::set<int> reachable_block_ids;
    std::map<int, std::pair<int, int>> block_instruction_ranges;
    std::map<int, std::set<int>> block_predecessors;
    std::map<int, std::set<int>> block_dominators;
    std::map<int, int> immediate_dominator;
    std::map<int, int> immediate_postdominator;
    bool reducible = false;
    std::map<int, int> block_emit_count; // root region-tree leaf coverage
    std::vector<EdgePlan> edges;
    std::vector<PredicatePlan> predicates;
    std::vector<EffectPlan> effects;
    std::map<int, LoopPlan> loops;       // authoritative loop header -> plan
    std::map<int, int> extra_loop_winners;
    std::vector<Failure> failures;

    bool ok() const { return failures.empty(); }
};

inline const char* edge_kind_name(EdgeKind kind) {
    switch (kind) {
        case EdgeKind::Fallthrough: return "fallthrough";
        case EdgeKind::ConditionalTrue: return "conditional_true";
        case EdgeKind::ConditionalFalse: return "conditional_false";
        case EdgeKind::Unconditional: return "unconditional";
        case EdgeKind::Backedge: return "backedge";
        case EdgeKind::LoopExit: return "loop_exit";
        case EdgeKind::Return: return "return";
    }
    return "unknown";
}

} // namespace sem
