// emit.h — M6e: LUAU EMISSION from the region tree.
//
// Walks the sa::Analyzer region tree (Seq / IfThen / IfThenElse / SelfLoop / While / NaturalLoop /
// Proper) and writes Luau source. This is the first stage whose output can be checked for MEANING
// rather than completeness: feed it to luau-compile.exe and compare bytecode against the original.
// Everything before this point is structurally complete but semantically unconfirmed.
//
// Scoping is handled the blunt, correct way: declare EVERY register as a local at the top of the
// function, parameters first. That sidesteps block-scoping entirely — uglier than real scoping, but
// it cannot be wrong, and correctness has to land before readability.
#pragma once
#include "liveness.h"
#include <functional>
#include <string>
#include <vector>
#include <set>
#include "expr.h"
#include "structan.h"

namespace em {

// One Emitter is constructed per proto, so a construction counter identifies the proto even on the
// anonymous path (which carries no index). Needed because block ids are PER-PROTO and collide.

struct Emitter {
    const ir::IProto* ip = nullptr;
    const st::Graph*  g  = nullptr;
    const sa::Analyzer* A = nullptr;
    std::string out;
    int maxreg = 0;
    bool bad = false;                 // something could not be emitted faithfully
    std::string why;
    std::set<int> loop_blocks;        // blocks of the innermost loop being emitted
    // Back-edge destinations of the innermost emitted source loop. A conditional CFG edge to one
    // of these blocks is `continue`, not ordinary fallthrough and not `break`.
    std::set<int> loop_continue_targets;
    // Authoritative CFG body used only to recognize control edges. Keep this separate from
    // `loop_blocks`: the legacy body-placement partition intentionally has different behavior for
    // generic loops, and changing both at once moved their body outside the emitted wrapper.
    std::set<int> loop_control_blocks;
    bool loop_continue_enabled = false;
    bool has_reversed_generic_natural = false;
    bool enable_surplus_generic_collision = false;
    // Production family: the authoritative forest contains one numeric loop nested in a non-for
    // loop with exactly six shell blocks.  This couples duplicate generic ownership to the missing
    // outer-wrapper repair; enabling either half alone is known to trade one defect for the other on
    // RhinoDamageRoar p10. Production enables this only for primary ability-module paths;
    // RENOVICE_LOOP_IDENTITY_REPAIR opts other paths in and RENOVICE_NO_LOOP_IDENTITY_REPAIR
    // restores the prior behavior everywhere.
    bool enable_exact_six_shell_outer = false;
    // Primary-ability family: a Proper child containing the prototype's only authoritative
    // generic loop plus two explicit exits (one terminal) must remain a whole state. Flattening it
    // deletes every loop back edge (GyrePulse p22 and BlessingAbility p13).
    bool enable_proper_generic_two_exit = false;
    // Gyre Overcharged/Sphere family: a latch-headed seven-latch generic was taking the following
    // eleven-block non-for loop as its body scope. Use the canonical authoritative body only for
    // the measured disjoint five-loop topology.
    bool enable_multi_latch_generic_body_scope = false;
    // Gyre Overcharged/Sphere follow-up family: the second generic loop's stolen scope and
    // duplicated identity numerically cancel an unclaimed nested two-exit while.  Repair all three
    // facts atomically; enabling only the dedupe would turn a hidden identity defect into a lost loop.
    bool enable_gyre_second_generic_nested = false;
    // Diagnostic family for GyreEnergized p7: a twenty-block non-for loop contains two generic
    // loops, but reducer order places the second body before its prep and lets the first loop claim
    // twice.  The three repairs (dedupe first, select/reorder second, wrap outer) are inseparable.
    bool enable_gyre_energized_outer = false;
    // GyrePulse p11 diagnostic: a five-block/four-latch generic is already exact, but its
    // latch-headed While claimant uses a different key and emits one empty generic copy.
    bool enable_pulse_four_latch_generic_dedup = false;
    // GyrePulse p20 diagnostic: its two-block/two-exit generic is reduced as
    // [body, latch, PREP-containing pre-sequence].  The general reversed-generic rule starts at
    // three body blocks because smaller terminal-search loops have ownership hazards, so test this
    // exact three-part/two-exit topology independently.
    bool enable_two_block_two_exit_reversed_generic = false;
    // Ability-scoped family: a NaturalLoop region exactly equals an authoritative single-exit
    // non-for body containing one genuinely nested numeric loop.  The local reducer's body
    // approximation is not trusted for nesting; exact dominator-derived loop bodies decide it.
    bool enable_authoritative_region_nested_outer = false;
    // Ability-scoped family: a Proper dispatcher child contains one complete source-for split
    // between its unique PREP entry and a nested cyclic body. Keeping the child whole preserves the
    // back edge; the refined predicate rejects interacting generic forests with four or more loops.
    bool enable_split_for_whole_part = false;
    // Compose the first proven descendant family only after parent-first selection: a single-exit
    // numeric child whose immediate source-for parent is numeric and shares the selected exact
    // outer wrapper. Ability-scoped by the driver; false for all other callers by default.
    bool enable_parent_first_child_coalesce = false;
    // Use the existing lossless reversed-generic partition after parent-first outer selection, but
    // only for the corpus-proven one-child/single-exit parent family. Driver-scoped like the other
    // ability repairs; false for direct emitter callers.
    bool enable_parent_first_reversed_generic = false;
    // Compose a numeric child after the refined generic-parent partition has actually activated.
    // The first certified batch is limited to four-loop trees to exclude known surplus-identity
    // collision forests. Driver-scoped and false for direct emitter callers.
    bool enable_repaired_generic_child_coalesce = false;
    bool enable_seq_generic_for_coalesce = false;
    // Experimental corpus family: a rejected cyclic Proper child contains one descendant Seq
    // split exactly between a generic PREP block and its authoritative While body. The Proper
    // approval and Seq coalescing are one atomic ownership decision; the Seq rule cannot activate
    // for ordinary already-owned generic loops.
    std::set<int> approved_seq_generic_split_headers;
    // Exact non-for ancestors selected after a production planning pass proves that an unclaimed
    // source-for descendant and its parent collide on this same region. Populated between PLAN and
    // RENDER; empty by default so broad exact-region wrapping cannot activate accidentally.
    std::set<int> parent_first_outer_headers;
    // Loops currently open, keyed by their BODY-START block. A generic-for has TWO blocks that
    // `for_header` will turn into a header (the FORGPREP prep and the FORGLOOP latch), and they can
    // sit in DIFFERENT regions — an outer region opens one from the latch, an inner region opens
    // another from the prep, and the same loop gets wrapped twice. Measured on
    // EE_Types_ScriptCommands_JSON: 8 original loops emitted as 16 `for` statements, with literally
    // identical headers three lines apart. A per-region check cannot see this; the guard must be
    // per-proto. Body-start is the canonical loop identity: both paths resolve to it.
    std::set<int> for_open;
    // Pure MOVE triplets that Luau inserts to place for-loop controls in a contiguous frame. They
    // are collected while recognizing a header, but activated only for the winning wrapper; a
    // speculative/losing region must not suppress setup that no emitted header consumes.
    std::map<int, std::vector<int>> for_move_candidates; // header block -> instruction indices
    // Planning proves which candidate really has a source-level loop wrapper. Carry its frame into
    // render setup so a containing Seq cannot emit the MOVEs before the winning loop is reached.
    std::map<int, std::vector<int>> planned_for_moves;    // planning loopkey -> instruction indices
    std::set<int> suppress_insns;
    // The AUTHORITATIVE loop map for the proto being emitted (structur.h find_loops, which already
    // handles the FORNPREP/FORGPREP asymmetry). Keyed by PREP block -> LATCH block. A `for` may only
    // be opened for a prep the STRUCTURER agrees is a real loop; otherwise the emitter is a second,
    // independent loop detector that disagrees with it — which is how a parent region came to emit a
    // loop belonging to a nested region, and the child then emitted it again.
    std::map<int, int> prep2latch;      // prep block -> latch block
    std::set<int> latch_of_loop;        // every real latch block (FORNLOOP / FORGLOOP)
    std::set<int> header_of_loop;       // every real loop HEADER, from both finder branches
    // Exact dominator-derived loop bodies from structur.h.  `natural_loop_body()` is a useful local
    // reconstruction for legacy emission, but it can omit secondary-latch/side blocks and therefore
    // must not decide authoritative parent-child loop identity.
    std::map<int, std::set<int>> authoritative_loop_bodies; // loop header -> exact CFG body
    // CANONICAL loop identity: prep / header / latch of the SAME loop all map to its HEADER. Keying on
    // whichever block we happened to arrive at gave ONE loop TWO identities (arrive via the latch and
    // via the header and the dedupe misses), which is why suppression kept failing.
    std::map<int, int> block2loop;
    // LOOP OWNERSHIP, resolved BEFORE emission: loop header -> the ONE region allowed to wrap it.
    // Resolving ownership opportunistically during the walk is wrong in both orderings - claiming late
    // duplicates the loop (+588 headers), claiming early hands it to the OUTERMOST region which then
    // flattens the inner one and DROPS ITS CODE (NAME-DIFF 3 -> 15). Deciding up front, and picking the
    // INNERMOST region that contains the whole loop, is what every reference decompiler does.
    std::map<int, int> loop_owner;

    // OWNERSHIP EMISSION (RENOVICE_OWNEMIT=1). Decide UP FRONT which single region may emit each
    // loop's wrapper, then let every other region take its NORMAL path untouched. The two earlier
    // ownership attempts failed for a reason now understood: #74 picked the smallest region CONTAINING
    // the body, which is often too deep to emit a header at all; #76 picked the loop-KIND region, but
    // for a numeric for the header text lives on the FORNPREP prep block, which heads the enclosing
    // IfThen, not the loop-kind region. So an owner is only valid if it can ACTUALLY EMIT THE HEADER:
    // its head block must be the loop's prep block (numeric) or the loop's header block (generic).
    std::map<int, int> own_emit;        // loop header block -> the one region id allowed to wrap it
    // EndOfMatch p95 family: a conditional whose terminal arm owns a nested generic loop. During the
    // planning pass, record that loop's original latch so every claimant uses one prep/latch identity
    // during the render pass. This prevents both condition loss and an empty duplicate loop.
    std::set<int> terminal_arm_loop_latches;

    // ---- PLAN / RENDER -------------------------------------------------------------------------
    // Ten attempts failed because the emitter decides "am I a loop?" locally, during the walk, from
    // information that cannot tell it whether ANOTHER region will also wrap this body. Claim eagerly
    // and the loop duplicates (body iterates N^2); claim conservatively and a body is left unwrapped,
    // which makes an in-body `return` unconditional and kills everything after it (#89b).
    // Fix the phase, not the rule: run the ENTIRE walk once in PLANNING mode (identical control flow,
    // no text produced) recording every loop claim and how deeply nested it was, resolve duplicates
    // once with the whole picture visible, then RENDER. Nothing is ever unwrapped after placement,
    // because the losing claimant never wraps in the first place.
    bool planning = false;
    int  plan_nest = 0;                 // recursion depth during planning, to find the INNERMOST claim
    std::map<int, std::pair<int,int>> plan_claim;   // loopkey -> (best nest depth, winning region id)
    std::map<int, int> plan_winner;                 // loopkey -> region id allowed to wrap (render)
    // Authoritative ownership is keyed by the dominator-derived loop HEADER, never by the
    // historical rendering key.  The legacy maps remain temporarily because several diagnostic
    // repairs still consult their aliases, but source-loop arbitration and render suppression use
    // these maps.  This guarantees one winning region per semantic loop even when PREP, latch, and
    // body-start claimants arrive under different legacy keys.
    std::map<int, std::pair<int,int>> semantic_plan_claim; // LoopId -> (score, winning region)
    std::map<int, int> semantic_plan_winner;               // LoopId -> winning region
    std::map<int, std::map<int, std::set<int>>> semantic_plan_candidates;
    std::set<std::pair<int, int>> semantic_header_candidates; // (LoopId, region)
    std::set<std::pair<int, int>> semantic_body_candidates;   // complete body coverage
    std::map<int, std::vector<int>> semantic_planned_for_moves; // LoopId -> frame MOVEs
    // Stable cross-layer provenance for the semantic ownership manifest. Historical loopkey is a
    // rendering deduplication key and may be a prep, latch, body-start, or even exhaustion block; it
    // is NOT a semantic LoopId. Record which authoritative header each key claimed while all local
    // facts are still available. A set is intentional: key collisions between distinct loops are
    // exactly the ambiguity the verifier must expose rather than resolve by guessing afterward.
    std::map<int, std::set<int>> plan_key_loops;     // loopkey -> authoritative loop header(s)

    void accept_planning_result(const Emitter& planned) {
        plan_winner.clear();
        for (const auto& claim : planned.plan_claim)
            plan_winner[claim.first] = claim.second.second;
        semantic_plan_winner.clear();
        for (const auto& claim : planned.semantic_plan_claim)
            semantic_plan_winner[claim.first] = claim.second.second;
        plan_key_loops = planned.plan_key_loops;
        semantic_plan_candidates = planned.semantic_plan_candidates;
        semantic_header_candidates = planned.semantic_header_candidates;
        semantic_body_candidates = planned.semantic_body_candidates;
        semantic_planned_for_moves = planned.semantic_planned_for_moves;
    }

    std::set<int> derive_parent_first_outer_headers(const std::vector<st::Loop>& loops,
                                                     const Emitter& planned) {
        std::set<int> result;
        if (loops.size() > 9) return result;
        std::map<int, const st::Loop*> by_header;
        std::map<int, int> parent;
        for (const st::Loop& loop : loops) by_header[loop.header] = &loop;
        for (const st::Loop& child : loops) {
            int best = -1; size_t best_size = (size_t)-1;
            for (const st::Loop& candidate : loops) {
                if (candidate.header == child.header
                    || candidate.body.size() <= child.body.size()) continue;
                bool contains = true;
                for (int block : child.body)
                    if (!candidate.body.count(block)) { contains = false; break; }
                if (contains && candidate.body.size() < best_size) {
                    best = candidate.header; best_size = candidate.body.size();
                }
            }
            parent[child.header] = best;
        }
        auto planned_region = [&](int header) {
            if (!by_header.count(header)) return -1;
            const st::Loop& loop = *by_header.at(header);
            if (loop.kind == st::Loop::ForNum || loop.kind == st::Loop::ForGen) {
                auto winner = planned.semantic_plan_claim.find(header);
                return winner == planned.semantic_plan_claim.end()
                    ? -1 : winner->second.second;
            }
            auto owner = loop_owner.find(header);
            return owner == loop_owner.end() ? -1 : owner->second;
        };
        for (const st::Loop& child : loops) {
            if (child.kind != st::Loop::ForNum && child.kind != st::Loop::ForGen) continue;
            auto claims = planned.semantic_plan_candidates.find(child.header);
            if (claims != planned.semantic_plan_candidates.end() && !claims->second.empty())
                continue;
            int inner = parent[child.header];
            std::set<int> seen;
            while (inner >= 0 && seen.insert(inner).second) {
                int outer = parent.count(inner) ? parent[inner] : -1;
                if (outer < 0 || !by_header.count(outer)) { inner = outer; continue; }
                int inner_region = planned_region(inner), outer_region = planned_region(outer);
                const st::Loop& outer_loop = *by_header.at(outer);
                if (inner_region >= 0 && inner_region == outer_region
                    && outer_loop.kind != st::Loop::ForNum
                    && outer_loop.kind != st::Loop::ForGen)
                {
                    std::vector<int> region_vector;
                    collect_blocks(outer_region, region_vector);
                    std::set<int> region_blocks(region_vector.begin(), region_vector.end());
                    std::set<int> exits;
                    for (int block : outer_loop.body)
                        for (int target : {g->n[block].succ_true, g->n[block].succ_false})
                            if (target >= 0 && !outer_loop.body.count(target)) exits.insert(target);
                    if (region_blocks == outer_loop.body && exits.size() == 1)
                        result.insert(outer);
                }
                inner = outer;
            }
        }
        return result;
    }
    // Environment-gated provenance for FINDINGS #102. The previous probes named only the outer
    // Seq/IfThen that CONTAINED a dead tail, which left five plausible-but-wrong root causes. Keep
    // the complete recursive emitter call stack so RENOVICE_RETURNTRACE can identify the exact
    // nested region and block that writes a return. Empty by default and source-neutral.
    std::vector<int> region_trace_stack;

    // Luau has no labelled break. A cyclic region with several outgoing destinations therefore
    // records the exact target before breaking, then propagates that pending escape after each
    // nested loop closes. The outer Proper dispatcher resumes at the selected target.
    struct EscapeContext {
        std::set<int> domain;
        std::string selector;
    };
    std::vector<EscapeContext> escape_stack;

    bool escape_target_is_external(int target) const {
        return !escape_stack.empty() && target >= 0
            && !escape_stack.back().domain.count(target);
    }

    void emit_escape_assign(int target, int depth) {
        if (!escape_target_is_external(target)) return;
        out += ind(depth) + escape_stack.back().selector + " = " + std::to_string(target) + "\n";
    }

    void emit_escape_propagate(int depth, int normal_target = -1) {
        if (escape_stack.empty()) return;
        const EscapeContext& ec = escape_stack.back();
        if (normal_target >= 0 && !ec.domain.count(normal_target))
            out += ind(depth) + "if " + ec.selector + " == -1 then " + ec.selector + " = "
                 + std::to_string(normal_target) + " end\n";
        out += ind(depth) + "if " + ec.selector + " ~= -1 then break end\n";
    }

    void assign_emit_owners(const std::vector<st::Loop>& loops) {
        if (!A) return;
        for (const st::Loop& L : loops) {
            if (L.header < 0) continue;
            int best = -1; size_t bestsz = (size_t)-1;
            for (size_t rid = 0; rid < A->regions.size(); ++rid) {
                int hb = head_block((int)rid);
                if (hb < 0) continue;
                // Can this region emit the header at all?
                if (hb != L.prep && hb != L.header) continue;
                // And does it span the whole loop, so the body lands inside the wrapper?
                std::vector<int> pb; collect_blocks((int)rid, pb);
                std::set<int> bs(pb.begin(), pb.end());
                bool all = true;
                for (int b : L.body) if (!bs.count(b)) { all = false; break; }
                if (!all) continue;
                if (bs.size() < bestsz) { bestsz = bs.size(); best = (int)rid; }
            }
            if (best >= 0) own_emit[L.header] = best;
        }
    }

    void assign_loop_owners(const std::vector<st::Loop>& loops) {
        if (!A) return;
        // GROUNDED RULE (fork #75, 98.1% of protos): the structurer classifies exactly one loop-KIND
        // region (SelfLoop / While / NaturalLoop) per real loop header, so the owner of a loop with
        // header H is the loop-kind region whose head block IS H. Region KIND is the right key; the
        // earlier CONTAINMENT rule (below, kept as fallback) failed because many regions contain a
        // loop's blocks and it could not tell which one is the wrapper (MATCH 81/87 < 112).
        std::map<int, int> kind_owner;                    // header block -> loop-kind region
        for (size_t rid = 0; rid < A->regions.size(); ++rid) {
            sa::RK k = A->regions[rid].kind;
            if (k != sa::RK::SelfLoop && k != sa::RK::While && k != sa::RK::NaturalLoop) continue;
            int hb = head_block((int)rid);
            if (hb >= 0 && !kind_owner.count(hb)) kind_owner[hb] = (int)rid;
        }
        // Containment fallback for the 1.8% where the structurer under-classifies (a loop absorbed
        // into a Proper region has no loop-kind region of its own).
        std::vector<std::set<int>> rb(A->regions.size());
        auto region_blocks = [&](int rid) -> const std::set<int>& {
            if (rb[rid].empty()) { std::vector<int> b; collect_blocks(rid, b); rb[rid].insert(b.begin(), b.end()); }
            return rb[rid];
        };
        auto contains_complete_body = [&](int rid, const st::Loop& loop) {
            if (rid < 0 || rid >= (int)A->regions.size()) return false;
            const std::set<int>& blocks = region_blocks(rid);
            for (int block : loop.body)
                if (!blocks.count(block)) return false;
            return true;
        };
        for (const st::Loop& L : loops) {
            if (L.header < 0) continue;
            auto it = kind_owner.find(L.header);
            // A matching loop-kind head is strong ownership evidence, but it is not sufficient by
            // itself.  A reduced nested region can retain the authoritative head while omitting
            // blocks from the dominator-derived loop body (PacifistFist proto 29 was the corpus
            // witness).  Such a region cannot own emission for the complete loop; fall through to
            // the same smallest-complete-region rule used for under-classified Proper regions.
            if (it != kind_owner.end() && contains_complete_body(it->second, L)) {
                loop_owner[L.header] = it->second;
                continue;
            }
            int best = -1; size_t bestsz = (size_t)-1;
            for (size_t rid = 0; rid < A->regions.size(); ++rid) {
                const std::set<int>& bs = region_blocks((int)rid);
                bool all = true;
                for (int bb : L.body) if (!bs.count(bb)) { all = false; break; }
                if (all && bs.size() < bestsz) { bestsz = bs.size(); best = (int)rid; }
            }
            if (best >= 0) loop_owner[L.header] = best;
        }
    }
    int pidx = -1;                 // actual module prototype index; block indices are per-proto
    // How many loop wrappers we are LEXICALLY inside. `break` is only legal within one, and having
    // the block SET is not the same as having emitted a `for`/`while` around it — the for-body path
    // arms the scope without emitting a wrapper, which produced
    // "break statement must be inside a loop" on real scripts.
    int loop_depth = 0;

    static std::string ind(int n) { return std::string(n * 2, ' '); }

    static std::string R(int r) { char b[24]; std::snprintf(b, sizeof b, "v%d", r); return b; }

    std::string cond_reg(const st::Node* node, int test_insn, int reg) const {
        if (node) {
            auto test = node->chain_loadn_literals.find(test_insn);
            if (test != node->chain_loadn_literals.end()) {
                auto literal = test->second.find(reg);
                if (literal != test->second.end()) return std::to_string(literal->second);
            }
        }
        return R(reg);
    }

    // A single branch test, in the sense "the branch is TAKEN when this is true".
    std::string one_cond(const ir::IInsn& in, const st::Node* node = nullptr,
                         int test_insn = -1) {
        auto CR = [&](int reg) { return cond_reg(node, test_insn, reg); };
        switch (in.op) {
            case 0x4b: return CR(in.A);                                   // JUMPIF
            case 0x18: return "not " + CR(in.A);                          // JUMPIFNOT
            case 0x37: return CR(in.A) + " == " + CR((int)in.aux);        // JUMPIFEQ
            case 0x27: return CR(in.A) + " ~= " + CR((int)in.aux);        // JUMPIFNOTEQ
            // Lua's VM has only LT and LE: `a > b` IS `b < a`. Rendering `>`/`>=` keeps the same
            // truth value but reverses the operand order the VM actually uses, which diverges in
            // error text and under NaN. Emit only `<` / `<=`, in the VM's own order.
            case 0x21: return CR(in.A) + " < "  + CR((int)in.aux);
            case 0x1c: return CR((int)in.aux) + " <= " + CR(in.A);
            case 0x23: return CR(in.A) + " <= " + CR((int)in.aux);
            case 0x33: return CR((int)in.aux) + " < "  + CR(in.A);
            // JUMPXEQKNIL aux bit31 is the NOT flag: SET means "branch when NOT equal to nil".
            case 0x3a: return R(in.A) + ((in.aux & 0x80000000u) ? " ~= nil" : " == nil");
            // All four JUMPXEQK forms use bit31 as the NOT flag. This is covered by native-emission
            // ground truth for both polarities and by the real BindingsUtil 0x41 specimen: bit clear
            // branches on equality; bit set branches on inequality.
            case 0x34: return R(in.A) + ((in.aux & 0x80000000u) ? " ~= " : " == ")
                              + ((in.aux & 1) ? "true" : "false");
            case 0x20: case 0x41: {                                       // compare against a const
                int k = (int)(in.aux & 0x7fffffffu);
                std::string kv = (k >= 0 && k < (int)ip->consts.size())
                                 ? ir::value_text(ip->consts[k]) : "nil";
                return R(in.A) + ((in.aux & 0x80000000u) ? " ~= " : " == ") + kv;
            }
            // FORNPREP reaches here when its block is NOT the head of a region (e.g. inside a Proper
            // linearisation), where `for_header` never gets a chance. It IS expressible: the branch is
            // taken when the range is already exhausted, i.e. the loop body will not run at all.
            // Layout A+0=limit, A+1=step, A+2=index (see for_header).
            case 0x47: {
                std::string lim = R(in.A), st = R(in.A + 1), ix = R(in.A + 2);
                return "(" + st + " > 0 and " + ix + " > " + lim + ") or ("
                     + st + " < 0 and " + ix + " < " + lim + ")";
            }
            default: {
                bad = true;
                char b[64]; std::snprintf(b, sizeof b, "unrenderable condition op 0x%02x", in.op);
                why = b; return "true";
            }
        }
    }

    // The logical negation of one branch test, by inverting the comparison rather than wrapping it.
    std::string invert_cond(const ir::IInsn& in, const st::Node* node = nullptr,
                            int test_insn = -1) {
        auto CR = [&](int reg) { return cond_reg(node, test_insn, reg); };
        switch (in.op) {
            case 0x4b: return "not " + CR(in.A);                           // JUMPIF
            case 0x18: return CR(in.A);                                    // JUMPIFNOT
            case 0x37: return CR(in.A) + " ~= " + CR((int)in.aux);
            case 0x27: return CR(in.A) + " == " + CR((int)in.aux);
            case 0x21: return CR((int)in.aux) + " <= " + CR(in.A);
            case 0x1c: return CR(in.A) + " < "  + CR((int)in.aux);
            case 0x23: return CR((int)in.aux) + " < "  + CR(in.A);
            case 0x33: return CR(in.A) + " <= " + CR((int)in.aux);
            case 0x3a: return R(in.A) + ((in.aux & 0x80000000u) ? " == nil" : " ~= nil");
            case 0x34: return R(in.A) + ((in.aux & 0x80000000u) ? " == " : " ~= ")
                              + ((in.aux & 1) ? "true" : "false");
            case 0x20: case 0x41: {
                int k = (int)(in.aux & 0x7fffffffu);
                std::string kv = (k >= 0 && k < (int)ip->consts.size())
                                 ? ir::value_text(ip->consts[k]) : "nil";
                return R(in.A) + ((in.aux & 0x80000000u) ? " == " : " ~= ") + kv;
            }
            default: return "not (" + one_cond(in, node, test_insn) + ")";
        }
    }

    // The condition a block branches on. Short-circuit chains collapsed by build_graph live in
    // Node::chain — WITHOUT rendering those, `if a and b then` emits as `if b then`: correct control
    // flow, wrong program.
    std::string cond_of(int blk, bool negate) {
        if (blk < 0 || blk >= (int)g->n.size()) return "true";
        const st::Node& n = g->n[blk];
        if (n.branch_predicate) {
            std::function<std::string(const st::PredicatePtr&)> render_predicate =
                [&](const st::PredicatePtr& predicate) -> std::string {
                    if (!predicate) return "true";
                    if (predicate->kind == st::Predicate::Test) {
                        int test = predicate->test_insn;
                        if (test < 0 || test >= (int)ip->code.size()) return "true";
                        return one_cond(ip->code[test], &n, test);
                    }
                    if (predicate->kind == st::Predicate::Not)
                        return "not (" + render_predicate(predicate->left) + ")";
                    const char* connector = predicate->kind == st::Predicate::And ? " and " : " or ";
                    return "(" + render_predicate(predicate->left) + connector
                         + render_predicate(predicate->right) + ")";
                };
            std::string exact = render_predicate(n.branch_predicate);
            return negate ? ("not (" + exact + ")") : exact;
        }
        std::vector<int> tests = n.chain.empty() ? std::vector<int>{n.last} : n.chain;
        // A single test can be negated by INVERTING it, which reads far better than `not (not a)`.
        // A short-circuit chain cannot: negating `a and b` needs De Morgan on the connectives too, so
        // that case keeps the explicit wrapper rather than silently dropping the transformation.
        if (negate && tests.size() == 1 && tests[0] >= 0 && tests[0] < (int)ip->code.size())
            return invert_cond(ip->code[tests[0]], &n, tests[0]);
        std::string s;
        for (size_t i = 0; i < tests.size(); ++i) {
            int ii = tests[i];
            if (ii < 0 || ii >= (int)ip->code.size()) continue;
            if (i) {
                bool andj = (i - 1 < n.chain_and.size()) ? n.chain_and[i - 1] : true;
                s += andj ? " and " : " or ";
            }
            s += one_cond(ip->code[ii], &n, ii);
        }
        if (s.empty()) s = "true";
        return negate ? ("not (" + s + ")") : s;
    }

    // How many tests the block's condition is made of. Polarity may only be reasoned about from a
    // single terminator; a merged short-circuit chain needs De Morgan and is left alone.
    size_t n_chain_len(int blk) const {
        if (blk < 0 || blk >= (int)g->n.size()) return 0;
        return g->n[blk].chain.empty() ? 1 : g->n[blk].chain.size();
    }

    int head_block(int id) const {
        if (id < 0 || id >= (int)A->regions.size()) return -1;
        const sa::Region& r = A->regions[id];
        if (r.kind == sa::RK::Basic) return r.block;
        // Structural-analysis regions explicitly record their semantic head. NaturalLoop and Proper
        // build `parts` from a set, so parts[0] is merely the smallest region id and may be an
        // unrelated LOADNIL/return block. Test the authoritative head across every oracle before
        // promoting it; this helper also feeds loop ownership and polarity.
        if (std::getenv("RENOVICE_REGION_HEAD") && r.head >= 0 && r.head != id)
            return head_block(r.head);
        return r.parts.empty() ? -1 : head_block(r.parts[0]);
    }

    // A for-loop is NOT expressible as a boolean condition — that is precisely why FORNPREP/FORGLOOP
    // are distinct opcodes, and why rendering one as `while <cond>` would mean inventing a test.
    // Recover the real header instead. Both layouts are read off ground-truth bytecode, not assumed:
    //
    //   numeric  FORNPREP A : A+0=limit A+1=step A+2=index, and the loop VARIABLE IS the index at
    //                         A+2 (ctrl_fornum has maxstack=5, so no A+3 exists at all).
    //   generic  FORGLOOP A : A+0=generator A+1=state A+2=control, loop vars at A+3.., aux=#vars.
    //
    // The two are asymmetric — the same trap as the FORGPREP/FORNPREP conditionality asymmetry.
    bool for_header(int blk, std::string& hdr) {
        if (blk < 0 || blk >= (int)g->n.size()) return false;
        int li = g->n[blk].last;
        if (li < 0 || li >= (int)ip->code.size()) return false;
        const ir::IInsn& in = ip->code[li];
        int a = in.A;
        int source[3] = {a, a + 1, a + 2};
        std::vector<int> move_insns;
        // A winning generic wrapper is often discovered from its FORGLOOP latch block, while the
        // compiler's three frame MOVEs sit immediately before the paired FORGPREP in another block.
        // Looking only before the latch misses that frame and makes it permanent source locals on
        // every cycle. Resolve the unique authoritative PREP->LATCH pair and inspect the PREP block;
        // its A must agree with the latch, otherwise fail closed and keep the explicit copies.
        int move_blk = blk, move_li = li;
        if (in.op == 0x1e || in.op == 0x0a) {
            int paired_prep = -1;
            for (const auto& pair : prep2latch) if (pair.second == blk) {
                if (paired_prep >= 0) { paired_prep = -2; break; }
                paired_prep = pair.first;
            }
            if (paired_prep >= 0 && paired_prep < (int)g->n.size()) {
                int pi = g->n[paired_prep].last;
                if (pi >= 0 && pi < (int)ip->code.size()
                    && ip->code[pi].A == a
                    && (ip->code[pi].op == 0x47 || ip->code[pi].op == 0x0b
                        || ip->code[pi].op == 0x30 || ip->code[pi].op == 0x1b)) {
                    move_blk = paired_prep;
                    move_li = pi;
                }
            }
        }
        int cursor = move_li - 1;
        bool move_triplet = !std::getenv("RENOVICE_NO_FORCOALESCE");
        for (int slot = 2; slot >= 0 && move_triplet; --slot) {
            if (cursor < g->n[move_blk].first || ip->code[cursor].op != 0x14
                || ip->code[cursor].A != a + slot) {
                move_triplet = false;
                break;
            }
            source[slot] = ip->code[cursor].B;
            move_insns.push_back(cursor--);
        }
        // Numeric-for frames have a different, measured compiler order:
        // index(A+2), limit(A), step(A+1), FORNPREP. The generic descending scan above cannot
        // recognize it, so each round trip otherwise promotes all three frame slots to locals.
        // Accept only the exact adjacent layout in the authoritative PREP block.
        const uint8_t move_term = ip->code[move_li].op;
        if (!move_triplet && !std::getenv("RENOVICE_NO_FORCOALESCE")
            && !std::getenv("RENOVICE_NO_NUMERIC_FORCOALESCE")
            && move_term == 0x47 && move_li - 3 >= g->n[move_blk].first) {
            const int order[3] = {a + 2, a, a + 1};
            bool numeric_triplet = true;
            for (int q = 0; q < 3; ++q) {
                const ir::IInsn& mv = ip->code[move_li - 3 + q];
                if (mv.op != 0x14 || mv.A != order[q]) {
                    numeric_triplet = false;
                    break;
                }
            }
            if (numeric_triplet) {
                source[2] = ip->code[move_li - 3].B;
                source[0] = ip->code[move_li - 2].B;
                source[1] = ip->code[move_li - 1].B;
                move_insns = {move_li - 3, move_li - 2, move_li - 1};
                move_triplet = true;
            }
        }
        if (move_triplet) for_move_candidates[blk] = move_insns;
        if (in.op == 0x47 || in.op == 0x0a) {                  // FORNPREP or FORNLOOP (same layout)
            hdr = "for " + R(a + 2) + " = " + R(source[2]) + ", "
                + R(source[0]) + ", " + R(source[1]) + " do";
            return true;
        }
        if (in.op == 0x1e || in.op == 0x30 || in.op == 0x1b || in.op == 0x0b) {  // FORGLOOP / preps
            int nv = (in.op == 0x1e) ? (int)(in.aux & 0xff) : 2;
            if (nv < 1) nv = 1;
            std::string vars;
            for (int q = 0; q < nv; ++q) { if (q) vars += ", "; vars += R(a + 3 + q); }
            hdr = "for " + vars + " in " + R(source[0]) + ", "
                + R(source[1]) + ", " + R(source[2]) + " do";
            return true;
        }
        return false;
    }

    // FORNLOOP (0x0a) is the LATCH of a numeric for: the iteration is already expressed by the `for`
    // header recovered from FORNPREP, so this block must NOT get a loop wrapper of its own. It has no
    // renderable boolean condition, so wrapping it yields `while true do ... if not (true) then break
    // end end` -- an INFINITE loop. (FORGLOOP 0x1e is handled by for_header, which emits the generic
    // `for ... in` directly, so it is deliberately not listed here.)
    bool is_for_latch(int blk) const {
        if (blk < 0 || blk >= (int)g->n.size()) return false;
        int li = g->n[blk].last;
        if (li < 0 || li >= (int)ip->code.size()) return false;
        uint8_t o = ip->code[li].op;
        return o == 0x0a || o == 0x1e;      // FORNLOOP and FORGLOOP are both latches
    }

    // Can this block supply a boolean at all? Only a real conditional branch can. A for-LATCH has no
    // test, and an unconditional terminator (JUMP 0x40 / JUMPBACK 0x25) or a plain CALL 0x54 ending a
    // block has none either — asking cond_of for one yields "unrenderable condition op". Every caller
    // must check this FIRST rather than assuming the region shape implies a test.
    bool renderable_cond(int blk) const {
        if (blk < 0 || blk >= (int)g->n.size()) return false;
        return g->n[blk].is_branch && !is_for_latch(blk);
    }

    // The NATURAL LOOP body of a back edge into `start` — the standard algorithm: every block that
    // reaches a latch without passing back through the header.
    //
    // This must NOT be approximated by the enclosing REGION's blocks. A region routinely contains code
    // that follows the loop, so with nested `for`s the inner loop's region also held the OUTER loop's
    // body; a `break` target then looked "inside the loop" and no break was emitted at all.
    std::set<int> natural_loop_body(int start) const {
        std::set<int> body;
        if (start < 0 || start >= (int)g->n.size()) return body;
        std::vector<int> stk;
        for (int p : g->n[start].preds)
            if (st::dominates(*g, start, p)) stk.push_back(p);   // p -> start is a back edge
        if (stk.empty()) return body;
        body.insert(start);
        while (!stk.empty()) {
            int x = stk.back(); stk.pop_back();
            if (x < 0 || x >= (int)g->n.size()) continue;
            if (!body.insert(x).second) continue;
            for (int q : g->n[x].preds) stk.push_back(q);
        }
        return body;
    }

    bool exact_generic_scope_theft(int hb, int displaced_start, int required_latches,
                                   size_t canonical_min, size_t canonical_max,
                                   size_t displaced_size) const {
        if (hb < 0 || hb >= (int)g->n.size() || header_of_loop.size() != 5) return false;
        int last = g->n[hb].last;
        if (last < 0 || last >= (int)ip->code.size() || ip->code[last].op != 0x1e) return false;
        int dominance_latches = 0;
        for (size_t block = 0; block < g->n.size(); ++block) {
            if (!g->n[block].reach || !st::dominates(*g, hb, (int)block)) continue;
            if (g->n[block].succ_true == hb || g->n[block].succ_false == hb)
                ++dominance_latches;
        }
        if (dominance_latches != required_latches) return false;
        auto canonical_identity = block2loop.find(hb);
        auto displaced_identity = block2loop.find(displaced_start);
        if (canonical_identity == block2loop.end() || displaced_identity == block2loop.end()
            || canonical_identity->second == displaced_identity->second) return false;
        for (const auto& prep_latch : prep2latch) {
            auto prep_identity = block2loop.find(prep_latch.first);
            if (prep_identity != block2loop.end()
                && prep_identity->second == displaced_identity->second) return false;
        }
        std::set<int> canonical_body = natural_loop_body(canonical_identity->second);
        std::set<int> displaced_body = natural_loop_body(displaced_identity->second);
        if (canonical_body.size() < canonical_min || canonical_body.size() > canonical_max
            || displaced_body.size() != displaced_size) return false;
        for (int block : canonical_body)
            if (displaced_body.count(block)) return false;
        return true;
    }

    bool exact_two_generic_twenty_block_outer(int& outer_header,
                                              int& first_prep,
                                              int& second_prep) const {
        outer_header = first_prep = second_prep = -1;
        if (!enable_gyre_energized_outer || header_of_loop.size() != 4) return false;
        auto op_of = [&](int block) -> int {
            if (block < 0 || block >= (int)g->n.size()) return -1;
            int last = g->n[block].last;
            return last >= 0 && last < (int)ip->code.size() ? (int)ip->code[last].op : -1;
        };
        for (int candidate_outer : header_of_loop) {
            std::set<int> outer_body = natural_loop_body(candidate_outer);
            if (outer_body.size() != 20) continue;
            bool outer_is_for = false;
            for (const auto& pair : prep2latch) {
                auto mapped = block2loop.find(pair.first);
                if (mapped != block2loop.end() && mapped->second == candidate_outer)
                    outer_is_for = true;
            }
            if (outer_is_for) continue;
            std::vector<std::pair<int, std::pair<size_t, int>>> nested;
            for (const auto& pair : prep2latch) {
                int prep = pair.first;
                int op = op_of(prep);
                if (op != 0x0b && op != 0x30 && op != 0x1b) continue;
                auto mapped = block2loop.find(prep);
                if (mapped == block2loop.end() || mapped->second == candidate_outer) continue;
                std::set<int> body = natural_loop_body(mapped->second);
                bool subset = !body.empty();
                for (int block : body) if (!outer_body.count(block)) subset = false;
                if (!subset) continue;
                int latches = 0;
                for (int block : body)
                    if (g->n[block].succ_true == mapped->second
                        || g->n[block].succ_false == mapped->second)
                        ++latches;
                nested.push_back({prep, {body.size(), latches}});
            }
            if (nested.size() != 2) continue;
            std::sort(nested.begin(), nested.end());
            if (nested[0].second != std::make_pair((size_t)2, 1)
                || nested[1].second != std::make_pair((size_t)4, 2)) continue;
            int outer_latches = 0;
            for (int block : outer_body)
                if (g->n[block].succ_true == candidate_outer
                    || g->n[block].succ_false == candidate_outer)
                    ++outer_latches;
            if (outer_latches != 1) continue;
            outer_header = candidate_outer;
            first_prep = nested[0].first;
            second_prep = nested[1].first;
            return true;
        }
        return false;
    }

    bool exact_four_latch_generic_with_four_block_peer(int hb) const {
        if (!enable_pulse_four_latch_generic_dedup || header_of_loop.size() != 2
            || hb < 0 || hb >= (int)g->n.size()) return false;
        auto canonical = block2loop.find(hb);
        if (canonical == block2loop.end()) return false;
        std::set<int> generic_body = natural_loop_body(canonical->second);
        if (generic_body.size() != 5) return false;
        int generic_latches = 0;
        for (int block : generic_body)
            if (g->n[block].succ_true == canonical->second
                || g->n[block].succ_false == canonical->second)
                ++generic_latches;
        if (generic_latches != 4) return false;
        bool canonical_is_for = false;
        for (const auto& pair : prep2latch) {
            auto mapped = block2loop.find(pair.first);
            if (mapped != block2loop.end() && mapped->second == canonical->second)
                canonical_is_for = true;
        }
        if (!canonical_is_for) return false;
        int peers = 0;
        for (int candidate : header_of_loop) {
            if (candidate == canonical->second) continue;
            std::set<int> peer_body = natural_loop_body(candidate);
            if (peer_body.size() != 4) continue;
            bool disjoint = true;
            for (int block : peer_body) if (generic_body.count(block)) disjoint = false;
            bool peer_is_for = false;
            for (const auto& pair : prep2latch) {
                auto mapped = block2loop.find(pair.first);
                if (mapped != block2loop.end() && mapped->second == candidate)
                    peer_is_for = true;
            }
            int peer_latches = 0;
            for (int block : peer_body)
                if (g->n[block].succ_true == candidate || g->n[block].succ_false == candidate)
                    ++peer_latches;
            if (disjoint && !peer_is_for && peer_latches == 1) ++peers;
        }
        return peers == 1;
    }

    bool exact_two_exit_match_loop_forest() const {
        if (!enable_two_block_two_exit_reversed_generic || header_of_loop.size() != 3)
            return false;
        int search_generic = 0, peer_generic = 0, outer_while = 0;
        for (int candidate : header_of_loop) {
            std::set<int> body = natural_loop_body(candidate);
            int latches = 0;
            std::set<int> exits;
            for (int block : body) {
                if (g->n[block].succ_true == candidate || g->n[block].succ_false == candidate)
                    ++latches;
                for (int successor : {g->n[block].succ_true, g->n[block].succ_false})
                    if (successor >= 0 && !body.count(successor)) exits.insert(successor);
            }
            bool is_for = false;
            for (const auto& prep_latch : prep2latch) {
                auto identity = block2loop.find(prep_latch.first);
                if (identity != block2loop.end() && identity->second == candidate)
                    is_for = true;
            }
            if (is_for && body.size() == 2 && latches == 1 && exits.size() == 2)
                ++search_generic;
            else if (is_for && body.size() == 4 && latches == 3 && exits.size() == 1)
                ++peer_generic;
            else if (!is_for && body.size() == 35 && latches == 1 && exits.size() == 1)
                ++outer_while;
        }
        return search_generic == 1 && peer_generic == 1 && outer_while == 1;
    }

    // Emit a region into a separate buffer instead of appending to `out`, so a loop header's
    // statements can be placed relative to its exit test.
    std::string capture(int id, int depth) {
        std::string save; save.swap(out);
        emit_region(id, depth);
        std::string got; got.swap(out); out.swap(save);
        return got;
    }

    void collect_blocks(int id, std::vector<int>& outb) const {
        if (id < 0 || id >= (int)A->regions.size()) return;
        const sa::Region& r = A->regions[id];
        if (r.kind == sa::RK::Basic) { outb.push_back(r.block); return; }
        for (int p : r.parts) collect_blocks(p, outb);
    }

    void dump_region_tree(int id, int tree_depth) const {
        if (id < 0 || id >= (int)A->regions.size()) return;
        const sa::Region& r = A->regions[id];
        std::fprintf(stderr, "DEADTAIL_TREE pidx=%d depth=%d id=%d kind=%s head=%d "
                             "block=%d parts=",
                     pidx, tree_depth, id, rk_name(r.kind), r.head, r.block);
        for (size_t i = 0; i < r.parts.size(); ++i)
            std::fprintf(stderr, "%s%d", i ? "," : "", r.parts[i]);
        std::fprintf(stderr, "\n");
        for (int child : r.parts) dump_region_tree(child, tree_depth + 1);
    }

    // FINDINGS #102: which flat-emission path drops an IfThen wrapper? Mark each and correlate
    // by region id against the DEADTAIL line, instead of reasoning about it (four hypotheses in
    // this defect family have already been wrong).
    void flatmark(int site, int id, sa::RK k, int isfor) const {
        if (std::getenv("RENOVICE_SEQDBG"))
            fprintf(stderr, "FLAT pidx=%d site=%d rgn=%d kind=%s isfor=%d\n",
                    pidx, site, id, rk_name(k), isfor);
    }
    static const char* rk_name(sa::RK k) {
        switch (k) {
            case sa::RK::Basic: return "Basic";           case sa::RK::Seq: return "Seq";
            case sa::RK::IfThen: return "IfThen";         case sa::RK::IfThenElse: return "IfThenElse";
            case sa::RK::SelfLoop: return "SelfLoop";     case sa::RK::While: return "While";
            case sa::RK::NaturalLoop: return "NaturalLoop"; default: return "Proper";
        }
    }
    bool region_has_terminal(int id) const {
        std::vector<int> b; collect_blocks(id, b);
        for (int x : b)
            if (x >= 0 && x < (int)g->n.size() && g->n[x].succ_true < 0 && g->n[x].succ_false < 0)
                return true;
        return false;
    }
    // DEAD-TAIL ATTRIBUTION (RENOVICE_SEQDBG=1) for FINDINGS #100 / task M6e-4.
    // A dead tail is an emitted `do return end` followed by more code at the same level: the Luau
    // compiler discards the rest, and the discarded block IS reachable in the original bytecode
    // (DecoPreview proto[3]: JUMPIF insn[82] -> insn[207]). A prior diagnosis attributed 179/181
    // sites to `Seq` using a TEXTUAL heuristic; this reports the region kind the emitter is ACTUALLY
    // in, so the attribution rests on the emitter rather than on inference from its output.
    // True when the text emitted so far ends with a `do return ... end` at exactly this depth, i.e.
    // an UNCONDITIONAL return at the current block level. Anything emitted after it is dead.
    bool ends_with_return_at(int depth) const {
        size_t e = out.find_last_not_of("\n");
        if (e == std::string::npos) return false;
        size_t s = out.rfind('\n', e);
        s = (s == std::string::npos) ? 0 : s + 1;
        std::string want = ind(depth) + "do return";
        return out.compare(s, want.size(), want) == 0;
    }
    void deadtail_dbg(int id) const {
        if (!std::getenv("RENOVICE_SEQDBG")) return;
        if (id < 0 || id >= (int)A->regions.size()) return;
        const sa::Region& r = A->regions[id];
        for (size_t q = 0; q + 1 < r.parts.size(); ++q) {
            if (!region_has_terminal(r.parts[q])) continue;
            // A Seq[A,B] is only formed when A has exactly ONE successor (B) and B has exactly one
            // predecessor (A) -- so A cannot ALWAYS return; some block of A must flow to B. The
            // defect is therefore emission ORDER INSIDE A. Report A's kind, its block count, and
            // whether the block A emits LAST is the returning one, which is the actual invariant
            // violation: a region with a successor must not end its emission with a bare `return`.
            int a = r.parts[q];
            std::vector<int> ab; collect_blocks(a, ab);
            int last_blk = -1;
            for (int x : ab) if (x > last_blk) last_blk = x;
            bool last_returns = (last_blk >= 0 && last_blk < (int)g->n.size()
                                 && g->n[last_blk].succ_true < 0 && g->n[last_blk].succ_false < 0);
            fprintf(stderr, "SEQTAIL kind=%s nparts=%d partidx=%d akind=%s ablocks=%d alastret=%d\n",
                    rk_name(r.kind), (int)r.parts.size(), (int)q,
                    rk_name(A->regions[a].kind), (int)ab.size(), last_returns ? 1 : 0);
        }
    }

    void emit_block(int blk, int depth) {
        if (blk < 0 || blk >= (int)g->n.size()) return;
        const st::Node& n = g->n[blk];
        if (std::getenv("RENOVICE_BLOCKTRACE"))
            std::fprintf(stderr,
                         "EMIT_BLOCK pidx=%d planning=%d block=%d first=%d last=%d "
                         "succ_true=%d succ_false=%d depth=%d loop_depth=%d "
                         "loop_member=%d control_member=%d\n",
                         pidx, planning ? 1 : 0, blk, n.first, n.last,
                         n.succ_true, n.succ_false, depth, loop_depth,
                         loop_blocks.count(blk) ? 1 : 0,
                         loop_control_blocks.count(blk) ? 1 : 0);
        for (int i = n.first; i <= n.last && i < (int)ip->code.size(); ++i)
            if (ip->code[i].A > maxreg) maxreg = ip->code[i].A;
        ex::ProtoOut po; ex::BlockOut bo; bo.first = n.first; bo.last = n.last;
        ex::reconstruct_block(*ip, n.first, n.last, po, bo);
        for (const ex::Stmt& s : bo.stmts) {
            if (suppress_insns.count(s.insn) || n.chain_setup_insns.count(s.insn)) continue;
            switch (s.k) {
                case ex::SK::Assign:
                    out += ind(depth) + ex::render(s.lhs) + " = " + ex::render(s.rhs) + "\n";
                    break;
                case ex::SK::ExprStmt:
                    out += ind(depth) + ex::render(s.rhs) + "\n";
                    break;
                case ex::SK::Return: {
                    std::string v;
                    for (size_t q = 0; q < s.list.size(); ++q) {
                        if (q) v += ", ";
                        v += ex::render(s.list[q]);
                    }
                    if (std::getenv("RENOVICE_RETURNTRACE")) {
                        int source_line = 1;
                        for (char ch : out) if (ch == '\n') ++source_line;
                        std::fprintf(stderr,
                                     "RETURN proto=%d planning=%d block=%d insn=%d depth=%d "
                                     "source_line=%d stack=",
                                     pidx, planning ? 1 : 0, blk, s.insn, depth, source_line);
                        for (size_t q = 0; q < region_trace_stack.size(); ++q) {
                            int rid = region_trace_stack[q];
                            if (q) std::fputc('/', stderr);
                            std::fprintf(stderr, "%d:%s", rid,
                                         (rid >= 0 && rid < (int)A->regions.size())
                                             ? rk_name(A->regions[rid].kind) : "invalid");
                        }
                        std::fputc('\n', stderr);
                        for (int rid : region_trace_stack) {
                            if (rid < 0 || rid >= (int)A->regions.size()) continue;
                            const sa::Region& tr = A->regions[rid];
                            int th = head_block(rid);
                            std::fprintf(stderr,
                                         "RETURN_REGION id=%d kind=%s head_region=%d head_block=%d "
                                         "basic_block=%d parts=",
                                         rid, rk_name(tr.kind), tr.head, th, tr.block);
                            for (size_t q = 0; q < tr.parts.size(); ++q) {
                                if (q) std::fputc(',', stderr);
                                std::fprintf(stderr, "%d", tr.parts[q]);
                            }
                            std::fputc('\n', stderr);
                            if (th >= 0 && th < (int)g->n.size()) {
                                const st::Node& tn = g->n[th];
                                std::fprintf(stderr,
                                             "RETURN_CFG region=%d block=%d first=%d last=%d "
                                             "succ_true=%d succ_false=%d term=0x%02x\n",
                                             rid, th, tn.first, tn.last, tn.succ_true, tn.succ_false,
                                             (unsigned)tn.term);
                            }
                        }
                    }
                    // `return` MUST be the last statement in a Lua block. A Seq region can emit a
                    // returning block followed by a subsequent (unreachable) one at the same level,
                    // which is a hard syntax error — "Expected 'end' ..., got '='". `do return end` is
                    // the idiomatic form that stays valid with code after it, and is semantically
                    // identical everywhere else.
                    out += ind(depth) + "do return" + (v.empty() ? "" : " " + v) + " end\n";
                    break;
                }
                case ex::SK::Branch: break;                 // the structure owns control flow (but
                                                            // see the loop-exit check below)
                case ex::SK::Local: case ex::SK::LoopCtl: case ex::SK::Comment: break;
                default: break;
            }
        }
        // A branch leaving a multi-exit cyclic region must remember WHICH destination it selected.
        // `break` alone loses that information, and a nested `break` reaches only the innermost loop;
        // loop-close propagation below carries the selector through the remaining scopes.
        bool emitted_region_escape = false;
        if (!escape_stack.empty()) {
            bool t_out = escape_target_is_external(n.succ_true);
            bool f_out = escape_target_is_external(n.succ_false);
            if (renderable_cond(blk) && (t_out || f_out)) {
                if (t_out && f_out && n.succ_true != n.succ_false) {
                    out += ind(depth) + "if " + cond_of(blk, false) + " then\n";
                    emit_escape_assign(n.succ_true, depth + 1);
                    out += ind(depth) + "else\n";
                    emit_escape_assign(n.succ_false, depth + 1);
                    out += ind(depth) + "end\n";
                    out += ind(depth) + "do break end\n";
                    emitted_region_escape = true;
                } else if (t_out != f_out) {
                    int target = t_out ? n.succ_true : n.succ_false;
                    out += ind(depth) + "if " + cond_of(blk, f_out) + " then\n";
                    emit_escape_assign(target, depth + 1);
                    out += ind(depth + 1) + "break\n";
                    out += ind(depth) + "end\n";
                    emitted_region_escape = true;
                }
            } else {
                // An ordinary block ending in CALL/SETUPVAL/etc. reaches its sole successor by
                // fallthrough. In the CFG that is just as unconditional as an explicit JUMP. When
                // the successor leaves this selector domain it must be recorded too; otherwise a
                // composite condition ending in normal code loses the arm it selected.
                bool t_valid = n.succ_true >= 0, f_valid = n.succ_false >= 0;
                int target = t_out ? n.succ_true : (f_out ? n.succ_false : -1);
                bool sole_external = target >= 0 && (t_valid != f_valid);
                if (target >= 0 && (n.is_uncond || sole_external)) {
                    emit_escape_assign(target, depth);
                    out += ind(depth) + "do break end\n";
                    emitted_region_escape = true;
                }
            }
        }
        // A conditional edge to the current loop's VM latch is a source `continue`. Region templates
        // do not own this edge: dropping it makes every guard fall through into work that the original
        // iteration skipped. Production enables this only for the proven reversed-generic family;
        // RENOVICE_NO_REVERSED_GENERIC_CONTINUE restores the prior behavior for controlled A/B.
        bool emitted_loop_continue = false;
        bool emit_loop_continue = std::getenv("RENOVICE_EMIT_LOOP_CONTINUE") != nullptr
            || loop_continue_enabled;
        if (!emitted_region_escape && emit_loop_continue
            && loop_depth > 0 && loop_control_blocks.count(blk) && renderable_cond(blk))
        {
            bool t_continue = loop_continue_targets.count(n.succ_true) != 0;
            bool f_continue = loop_continue_targets.count(n.succ_false) != 0;
            if (std::getenv("RENOVICE_CONTINUETRACE")) {
                std::fprintf(stderr, "CONTINUE_EDGE pidx=%d block=%d true=%d false=%d targets=",
                             pidx, blk, n.succ_true, n.succ_false);
                for (int target : loop_continue_targets) std::fprintf(stderr, "%d,", target);
                std::fprintf(stderr, " match=%d/%d\n", t_continue ? 1 : 0, f_continue ? 1 : 0);
            }
            if (t_continue != f_continue) {
                out += ind(depth) + "if " + cond_of(blk, f_continue) + " then continue end\n";
                emitted_loop_continue = true;
            }
        }
        // A conditional branch whose target LEAVES the enclosing loop is a `break`. Nothing else in
        // the emitter can express it: SK::Branch is dropped on the assumption that a region template
        // owns the control flow, which is false for a block sitting directly inside a loop body.
        // Without this, `for i=1,n do if i>3 then break end ... end` emits an INFINITE loop.
        if (!emitted_region_escape && !emitted_loop_continue
            && loop_depth > 0 && loop_blocks.count(blk) && renderable_cond(blk)) {
            bool t_out = n.succ_true  >= 0 && !loop_blocks.count(n.succ_true);
            bool f_out = n.succ_false >= 0 && !loop_blocks.count(n.succ_false);
            if (t_out != f_out)                       // exactly one arm leaves the loop
                out += ind(depth) + "if " + cond_of(blk, f_out) + " then break end\n";
        }
    }

    void emit_region(int id, int depth) {
        if (id < 0 || id >= (int)A->regions.size()) return;
        region_trace_stack.push_back(id);
        struct RegionTracePop {
            std::vector<int>& stack;
            ~RegionTracePop() { stack.pop_back(); }
        } region_trace_pop{region_trace_stack};
        const sa::Region& r = A->regions[id];
        switch (r.kind) {
            case sa::RK::Basic:
                emit_block(r.block, depth);
                break;
            case sa::RK::Seq:
                // DEAD-TAIL DETECTION, EXACT (RENOVICE_SEQDBG=1).
                // An earlier probe counted "Seq[A,B] where A contains a return" and got 14,776 hits
                // against only 181 real dead tails -- a 1.2% hit rate, because `if c then return end`
                // is overwhelmingly common and entirely benign. The defect is TEXTUAL and specific:
                // a part's emission ENDS with a top-level `do return end` while further parts follow,
                // so everything after it is dead and the Luau compiler discards it. Check the emitted
                // text, which is exact, rather than the region shape, which is not.
                for (size_t q = 0; q < r.parts.size(); ++q) {
                    // A Proper reduction may end with a FORNPREP while the dominance-qualified
                    // NaturalLoop it enters is the next Seq child. Neither child alone can emit the
                    // source numeric-for: the left owns setup, the right owns body+latch. Coalesce
                    // this exact canonical boundary, keyed by prep2latch, rather than scanning for an
                    // arbitrary opcode or inventing a loop.
                    if (!std::getenv("RENOVICE_NO_NESTED_FOR_COALESCE") && q + 1 < r.parts.size()) {
                        std::vector<int> left, right;
                        collect_blocks(r.parts[q], left); collect_blocks(r.parts[q + 1], right);
                        std::set<int> right_set(right.begin(), right.end());
                        int prep = -1, latch = -1, body_start = -1;
                        std::string hdr;
                        for (int candidate : left) {
                            auto known = prep2latch.find(candidate);
                            if (known == prep2latch.end() || !right_set.count(known->second)) continue;
                            if (!A->nested_for_preps.count(candidate)) continue;
                            if (candidate < 0 || candidate >= (int)g->n.size()) continue;
                            int li = g->n[candidate].last;
                            if (li < 0 || li >= (int)ip->code.size()
                                || ip->code[li].op != 0x47) continue;
                            int bs = g->n[candidate].succ_false;
                            if (!right_set.count(bs) || !for_header(candidate, hdr)) continue;
                            prep = candidate; latch = known->second; body_start = bs; break;
                        }
                        if (prep >= 0) {
                            auto moves = for_move_candidates.find(prep);
                            if (moves != for_move_candidates.end())
                                suppress_insns.insert(moves->second.begin(), moves->second.end());
                            emit_region(r.parts[q], depth);
                            out += ind(depth) + hdr + "\n";
                            std::set<int> saved_blocks = loop_blocks;
                            loop_blocks = natural_loop_body(body_start);
                            ++loop_depth;
                            emit_region(r.parts[q + 1], depth + 1);
                            --loop_depth;
                            loop_blocks = saved_blocks;
                            out += ind(depth) + "end\n";
                            int normal_exit = (latch >= 0 && latch < (int)g->n.size())
                                ? g->n[latch].succ_false : -1;
                            emit_escape_propagate(depth, normal_exit);
                            int loopkey = block2loop.count(prep) ? block2loop[prep] : body_start;
                            if (loopkey >= 0) for_open.insert(loopkey);
                            if (std::getenv("RENOVICE_LOOPTRACE"))
                                std::fprintf(stderr,
                                             "COALESCE_SEQ_FOR pidx=%d seq=%d prep=%d body=%d "
                                             "latch=%d left=%d right=%d\n",
                                             pidx, id, prep, body_start, latch,
                                             r.parts[q], r.parts[q + 1]);
                            ++q;
                            continue;
                        }
                    }
                    // Corpus-wide root generic split family. The semantic census identifies a
                    // direct Seq boundary where a one-block Basic child owns FORGPREP and the next
                    // While child owns exactly the authoritative body plus latch. Neither child can
                    // emit the source loop alone. Compose only that complete adjacent partition;
                    // mixed bodies, nested LoopIds, ambiguous preps, and non-adjacent regions fail
                    // closed. Experimental until both 6,035-prototype oracles certify it.
                    if (enable_seq_generic_for_coalesce
                        && q + 1 < r.parts.size()
                        && A->regions[r.parts[q]].kind == sa::RK::Basic) {
                        std::vector<int> left_blocks, right_blocks_vector;
                        collect_blocks(r.parts[q], left_blocks);
                        collect_blocks(r.parts[q + 1], right_blocks_vector);
                        std::set<int> right_blocks(right_blocks_vector.begin(),
                                                   right_blocks_vector.end());
                        int selected_prep = -1, selected_latch = -1;
                        int selected_header = -1, selected_body_start = -1;
                        std::string selected_header_text;
                        int candidates = 0;
                        if (left_blocks.size() == 1) {
                            const int prep = left_blocks.front();
                            const int op = (prep >= 0 && prep < (int)g->n.size())
                                ? g->n[prep].term : -1;
                            auto paired = prep2latch.find(prep);
                            auto identity = block2loop.find(prep);
                            if ((op == 0x0b || op == 0x30 || op == 0x1b)
                                && paired != prep2latch.end()
                                && identity != block2loop.end()
                                && right_blocks.count(paired->second)) {
                                const int loop_header = identity->second;
                                auto body = authoritative_loop_bodies.find(loop_header);
                                bool root_loop = body != authoritative_loop_bodies.end();
                                if (root_loop)
                                    for (const auto& possible_parent : authoritative_loop_bodies) {
                                        if (possible_parent.first == loop_header
                                            || possible_parent.second.size() <= body->second.size())
                                            continue;
                                        bool contains = true;
                                        for (int block : body->second)
                                            if (!possible_parent.second.count(block)) {
                                                contains = false; break;
                                            }
                                        if (contains) { root_loop = false; break; }
                                    }
                                int body_start = -1;
                                const int next_instruction = g->n[prep].last + 1;
                                for (size_t block = 0; block < g->n.size(); ++block)
                                    if (g->n[block].first == next_instruction) {
                                        body_start = (int)block; break;
                                    }
                                std::string header_text;
                                if (root_loop && right_blocks == body->second
                                    && right_blocks.count(body_start)
                                    && approved_seq_generic_split_headers.count(loop_header)
                                    && for_header(prep, header_text)) {
                                    ++candidates;
                                    selected_prep = prep;
                                    selected_latch = paired->second;
                                    selected_header = loop_header;
                                    selected_body_start = body_start;
                                    selected_header_text = header_text;
                                }
                            }
                        }
                        if (candidates == 1) {
                            if (planning) {
                                const int score = 1000000 + 2000 + plan_nest + 1;
                                semantic_plan_candidates[selected_header][id]
                                    .insert(selected_header);
                                semantic_header_candidates.insert({selected_header, id});
                                semantic_body_candidates.insert({selected_header, id});
                                semantic_plan_claim[selected_header] =
                                    std::make_pair(score, id);
                                plan_key_loops[selected_header].insert(selected_header);
                                auto moves = for_move_candidates.find(selected_prep);
                                if (moves != for_move_candidates.end())
                                    semantic_planned_for_moves[selected_header] = moves->second;
                            }
                            auto moves = for_move_candidates.find(selected_prep);
                            if (moves != for_move_candidates.end())
                                suppress_insns.insert(moves->second.begin(), moves->second.end());
                            emit_region(r.parts[q], depth);
                            out += ind(depth) + selected_header_text + "\n";
                            std::set<int> saved_blocks = loop_blocks;
                            std::set<int> saved_continue_targets = loop_continue_targets;
                            std::set<int> saved_control_blocks = loop_control_blocks;
                            bool saved_continue_enabled = loop_continue_enabled;
                            loop_blocks = authoritative_loop_bodies[selected_header];
                            loop_control_blocks = loop_blocks;
                            loop_continue_targets.clear();
                            loop_continue_targets.insert(selected_latch);
                            loop_continue_enabled = true;
                            // Loop-kind regions key this generic by its body-entry block, while the
                            // semantic manifest keys it by the canonical header. Mark both aliases
                            // before descending so the child emits flat inside this one wrapper.
                            for_open.insert(selected_header);
                            for_open.insert(selected_body_start);
                            ++loop_depth;
                            emit_region(r.parts[q + 1], depth + 1);
                            --loop_depth;
                            loop_blocks = saved_blocks;
                            loop_continue_targets = saved_continue_targets;
                            loop_control_blocks = saved_control_blocks;
                            loop_continue_enabled = saved_continue_enabled;
                            out += ind(depth) + "end\n";
                            int normal_exit = selected_latch >= 0
                                && selected_latch < (int)g->n.size()
                                ? g->n[selected_latch].succ_false : -1;
                            emit_escape_propagate(depth, normal_exit);
                            if (std::getenv("RENOVICE_LOOPTRACE"))
                                std::fprintf(stderr,
                                             "COALESCE_SEQ_GENERIC pidx=%d seq=%d prep=%d "
                                             "header=%d body=%d latch=%d left=%d right=%d\n",
                                             pidx, id, selected_prep, selected_header,
                                             selected_body_start, selected_latch,
                                             r.parts[q], r.parts[q + 1]);
                            ++q;
                            continue;
                        }
                    }
                    emit_region(r.parts[q], depth);
                    if (q + 1 < r.parts.size() && ends_with_return_at(depth)
                        && std::getenv("RENOVICE_SEQDBG"))
                    {
                        // An IfThen emits `if <cond> then ... end`, which CANNOT leave a bare
                        // `do return end` at the outer depth -- unless it emitted WITHOUT its
                        // wrapper. Report whether the head block has a renderable condition, and
                        // the head's terminator opcode, to find out which.
                        int ah = head_block(r.parts[q]);
                        fprintf(stderr, "DEADTAIL pidx=%d planning=%d argn=%d akind=%s bkind=%s "
                                        "nparts=%d rcond=%d aterm=%02x aparts=%d\n",
                                pidx,
                                planning ? 1 : 0,
                                r.parts[q],
                                rk_name(A->regions[r.parts[q]].kind),
                                rk_name(A->regions[r.parts[q + 1]].kind), (int)r.parts.size(),
                                (ah >= 0 && renderable_cond(ah)) ? 1 : 0,
                                (ah >= 0 && ah < (int)g->n.size()) ? g->n[ah].term : 0,
                                (int)A->regions[r.parts[q]].parts.size());
                        if (std::getenv("RENOVICE_RETURNTRACE")) {
                            const size_t tail_start = out.size() > 1200 ? out.size() - 1200 : 0;
                            std::fprintf(stderr, "DEADTAIL_TEXT_BEGIN pidx=%d region=%d\n%s"
                                                 "DEADTAIL_TEXT_END pidx=%d region=%d\n",
                                         pidx, r.parts[q], out.substr(tail_start).c_str(),
                                         pidx, r.parts[q]);
                            dump_region_tree(r.parts[q], 0);
                            dump_region_tree(r.parts[q + 1], 0);
                        }
                        if (std::getenv("RENOVICE_RETURNTRACE")) {
                            for (int side = 0; side < 2; ++side) {
                                int child = r.parts[q + (size_t)side];
                                std::vector<int> child_blocks;
                                collect_blocks(child, child_blocks);
                                for (int cb : child_blocks) {
                                    if (cb < 0 || cb >= (int)g->n.size()) continue;
                                    const st::Node& cn = g->n[cb];
                                    std::fprintf(stderr,
                                                 "DEADTAIL_CFG side=%c region=%d block=%d first=%d "
                                                 "last=%d succ_true=%d succ_false=%d term=0x%02x\n",
                                                 side == 0 ? 'A' : 'B', child, cb, cn.first, cn.last,
                                                 cn.succ_true, cn.succ_false, (unsigned)cn.term);
                                }
                            }
                        }
                        if (std::getenv("RENOVICE_SEQTEXT")) {
                            // Reasoning about how an IfThen leaves a bare return at the OUTER depth
                            // went in circles. Print what was actually emitted instead.
                            size_t cut = out.size(); int lines = 0;
                            while (cut > 0 && lines < 7) { if (out[--cut] == '\n') ++lines; }
                            fprintf(stderr, "---- tail of A (kind=%s) ----\n%s----\n",
                                    rk_name(A->regions[r.parts[q]].kind), out.substr(cut).c_str());
                        }
                    }
                }
                break;
            // A for-loop reaches emission as an IfThen (FORNPREP is conditional) or as a loop
            // region latched by FORGLOOP. Either way the head block's terminator names the loop kind,
            // so check it FIRST -- otherwise cond_of is asked for a boolean that does not exist.
            case sa::RK::IfThen:
            case sa::RK::IfThenElse:
            case sa::RK::SelfLoop:
            case sa::RK::While:
            case sa::RK::NaturalLoop: {
                int head = r.parts.empty() ? -1 : r.parts[0];
                int hb   = head_block(head);
                // Keep the region's own condition separate from the mutable loop-header candidate.
                // The interior PREP scan below deliberately rewrites `hb`; if a conditional region
                // then loses a duplicate loop claim and falls through to normal IfThen emission,
                // using that rewritten PREP as its condition reports "unrenderable" and flattens the
                // if anyway (FINDINGS #106, BindingsUtil proto 18).
                const int region_condition_block = hb;
                int header_source_blk = hb;
                std::string hdr;
                bool isfor = for_header(hb, hdr);
                // A for-latch region carries no condition of its own — emit its statements flat and
                // let the enclosing `for` drive the iteration.
                if (!isfor && is_for_latch(hb) && r.kind != sa::RK::IfThen
                    && r.kind != sa::RK::IfThenElse) {
                    for (int p : r.parts) emit_region(p, depth);
                    break;
                }
                // A loop may carry the for-op on its LATCH — but only a GENERIC for does. FORGLOOP
                // (0x1e) genuinely terminates the loop, so finding it deeper inside the region still
                // means "this region IS that loop". Every PREP (FORNPREP 0x47, FORGPREP 0x0b/0x30/
                // 0x1b) sits in the PREHEADER, BEFORE the loop, so finding one on a non-head block
                // means the region is really `setup...; for ... end`. Opening a region-level `for`
                // there emits the header BEFORE its own setup and swallows it into the body — measured
                // on ImGuiSeasonOverride, where ONE original loop became TWO `for`s whose bounds
                // (c1v5/c1v6/c1v7) were assigned INSIDE the body they were supposed to control.
                // Rejecting preps lets the region recurse until the prep block IS a head, which is the
                // path that emits the setup first and only then opens the header.
                auto term_op = [&](int b) -> int {
                    int li = (b >= 0 && b < (int)g->n.size()) ? g->n[b].last : -1;
                    return (li < 0 || li >= (int)ip->code.size()) ? -1 : (int)ip->code[li].op;
                };
                int latch_blk = -1;                 // set when the header came from a FORGLOOP latch
                // A region whose OWN head is FORGLOOP reached `isfor=true` before the interior-latch
                // scan below, so `latch_blk` stayed -1.  Body-start resolution then treated the
                // FORGLOOP like a prep and used its exit edge, giving the same loop a second identity
                // (Dialog p62: prep claim key 5, latch-head claim key 17).  The production identity
                // repair is limited to the analyzer-approved three-latch/single-loop topology.
                bool approved_canonical_latch = A->multi_latch_for_headers.count(hb) != 0
                    || terminal_arm_loop_latches.count(hb);
                if ((std::getenv("RENOVICE_DIRECT_FORGLOOP_IDENTITY")
                     || (approved_canonical_latch
                         && !std::getenv("RENOVICE_NO_THREE_LATCH_SINGLE_LOOP")))
                    && isfor && term_op(hb) == 0x1e)
                {
                    latch_blk = hb;
                    header_source_blk = hb;
                }
                // ...but a generic-for has TWO blocks that `for_header` will happily turn into a
                // header: the FORGPREP prep AND the FORGLOOP latch. If this region opens one from the
                // latch while an inner region opens another from the prep, the SAME loop is emitted
                // with TWO headers. Measured on EE_Types_ScriptCommands_JSON: 8 original generic-fors
                // became EXACTLY 16. So only take the latch when the region does NOT also contain a
                // prep — if a prep is present, the prep path below owns this loop and produces the one
                // correct header.
                if (!isfor) {
                    std::vector<int> blks; collect_blocks(id, blks);
                    bool has_prep = false;
                    for (int b : blks) {
                        int o = term_op(b);
                        if (o == 0x47 || o == 0x0b || o == 0x30 || o == 0x1b) { has_prep = true; break; }
                    }
                    if (!has_prep)
                        for (int b : blks) {
                            if (term_op(b) != 0x1e) continue;       // FORGLOOP only: the real latch
                            if (for_header(b, hdr)) {
                                isfor = true; latch_blk = b; header_source_blk = b; break;
                            }
                        }
                }
                // An interior PREP means the region is `setup...; for ... end`, so it must be SPLIT:
                // everything up to and including the part that CONTAINS the prep is setup and belongs
                // BEFORE the header; only the parts after it are the body. Emitting the header at the
                // region level instead put it before its own setup (one loop became two, with bounds
                // assigned inside the body), and simply refusing the prep lost the loop altogether.
                int prep_part = -1;
                // RENOVICE_NOPREPSPLIT=1 restores the pre-fix behaviour, so a regression can be
                // ATTRIBUTED rather than guessed at: rerun an oracle with and without it.
                if (!isfor && !std::getenv("RENOVICE_NOPREPSPLIT")) {
                    // Look ONLY at each part's HEAD block, never its whole subtree. `collect_blocks`
                    // recurses, so a parent region would find a prep belonging to a NESTED region and
                    // open a header for it — and then the child would open the very same loop again.
                    // Proven with RENOVICE_LOOPTRACE on EE_Types_ScriptCommands_JSON: two identical
                    // headers, `rgn=70 hb=34 bs=35` and `rgn=71 hb=34 bs=35` — same head block, same
                    // body start, two different regions. They emit sequentially rather than nested, so
                    // the for_open guard cannot catch them; the scan itself has to stop being greedy.
                    // A prep deeper in the subtree is not lost: recursion reaches the region where
                    // that prep IS the head.
                    // REVERTED (#60d): scanning only each part's HEAD block did stop a parent region
                    // stealing a nested region's loop (JSON 16 -> 14, LOOP-DIFF 172 -> 170), but it
                    // SKIPPED CODE - NAME-DIFF went 3 -> 6, meaning three more files touched a
                    // different set of named entities. Losing an entity access is a SEMANTIC change;
                    // a duplicated loop header is redundant structure. Never trade the first for the
                    // second. The greedy scan is restored until the overlap can be fixed without
                    // dropping anything.
                    for (size_t q = 0; q < r.parts.size() && !isfor; ++q) {
                        std::vector<int> pb; collect_blocks(r.parts[q], pb);
                        for (int b : pb) {
                            int o = term_op(b);
                            if (o != 0x47 && o != 0x0b && o != 0x30 && o != 0x1b) continue;
                            if (for_header(b, hdr)) {
                                isfor = true; prep_part = (int)q;
                                hb = b;                  // the body starts at THIS block's fallthrough
                                header_source_blk = b;
                                break;
                            }
                        }
                    }
                }
                int energized_outer_header = -1, energized_first_prep = -1,
                    energized_second_prep = -1;
                bool exact_energized_proto =
                    exact_two_generic_twenty_block_outer(energized_outer_header,
                                                         energized_first_prep,
                                                         energized_second_prep);
                bool exact_pulse_two_exit_proto = exact_two_exit_match_loop_forest();
                bool exact_energized_outer = exact_energized_proto
                    && r.kind == sa::RK::NaturalLoop && r.parts.size() == 10
                    && energized_outer_header == region_condition_block;
                if (exact_energized_outer) {
                    for (size_t q = 0; q < r.parts.size(); ++q) {
                        std::vector<int> blocks;
                        collect_blocks(r.parts[q], blocks);
                        if (std::find(blocks.begin(), blocks.end(), energized_second_prep)
                            == blocks.end()) continue;
                        std::string second_header;
                        if (!for_header(energized_second_prep, second_header)) break;
                        isfor = true;
                        prep_part = (int)q;
                        hb = energized_second_prep;
                        header_source_blk = energized_second_prep;
                        hdr = second_header;
                        break;
                    }
                }
                // BindingsUtil proto 16: an IfThen whose own condition is block 0
                // currently scans into its arm, finds the arm's FORGPREP at block 2, and wins loop
                // ownership.  It then emits itself as that `for`, deleting the block-0 guard and
                // making mutually exclusive terminal alternatives sequential.  A conditional can
                // represent the loop's zero-iteration gate only when its OWN condition block is the
                // prep/latch.  A prep found deeper in an arm belongs to a child region.  Keep this
                // The production rule below is deliberately narrower than "conditional owns only
                // its head": both exits of the nested two-block search must terminate the function.
                // Broader versions recovered accesses but regressed hundreds of loop headers.
                bool nested_loop_exits_to_terminal = false;
                bool nested_loop_is_two_block_search = false;
                bool nested_loop_arm_is_terminal = false;
                int nested_terminal_arm_loop_count = 0;
                if (isfor && header_source_blk != region_condition_block) {
                    auto nested_latch = prep2latch.find(header_source_blk);
                    if (nested_latch != prep2latch.end()
                        && nested_latch->second >= 0
                        && nested_latch->second < (int)g->n.size())
                    {
                        int normal_exit = g->n[nested_latch->second].succ_false;
                        nested_loop_exits_to_terminal = normal_exit >= 0
                            && normal_exit < (int)g->n.size()
                            && g->n[normal_exit].succ_true < 0
                            && g->n[normal_exit].succ_false < 0;
                        int body_start = g->n[nested_latch->second].succ_true;
                        if (body_start >= 0 && body_start < (int)g->n.size()) {
                            const st::Node& search = g->n[body_start];
                            int match_exit = search.succ_true == nested_latch->second
                                ? search.succ_false
                                : (search.succ_false == nested_latch->second
                                    ? search.succ_true : -1);
                            nested_loop_is_two_block_search = match_exit >= 0
                                && match_exit < (int)g->n.size()
                                && g->n[match_exit].succ_true < 0
                                && g->n[match_exit].succ_false < 0;
                        }
                    }
                    // EndOfMatch p95: an IfThen's arm contains an entire generic loop and ends in
                    // RETURN.  Letting the parent claim that nested loop replaces the condition with
                    // a `for`, emits the terminal arm unconditionally, and makes the sibling branch
                    // dead (43 reachable accesses disappear on recompilation).  Determine terminality
                    // from the exact CFG boundary of the child arm, not from a filename or opcode
                    // pattern. The normal-exhaustion check below supplies the second required fact.
                    for (int child : r.parts) {
                        if (child < 0 || child >= (int)A->regions.size()) continue;
                        std::vector<int> child_blocks;
                        collect_blocks(child, child_blocks);
                        std::set<int> child_set(child_blocks.begin(), child_blocks.end());
                        if (!child_set.count(header_source_blk)) continue;
                        bool has_outgoing_edge = false;
                        for (int child_block : child_blocks) {
                            if (child_block < 0 || child_block >= (int)g->n.size()) continue;
                            for (int target : {g->n[child_block].succ_true,
                                               g->n[child_block].succ_false})
                                if (target >= 0 && !child_set.count(target))
                                    has_outgoing_edge = true;
                        }
                        nested_loop_arm_is_terminal = !has_outgoing_edge;
                        std::set<int> arm_loop_headers;
                        for (int child_block : child_blocks)
                            if (header_of_loop.count(child_block))
                                arm_loop_headers.insert(child_block);
                        nested_terminal_arm_loop_count = (int)arm_loop_headers.size();
                        break;
                    }
                }
                if (std::getenv("RENOVICE_LOOPTRACE") && isfor
                    && (r.kind == sa::RK::IfThen || r.kind == sa::RK::IfThenElse)
                    && header_source_blk != region_condition_block)
                    std::fprintf(stderr,
                                 "COND_LOOP_OWNER pidx=%d region=%d cond=%d source=%d terminal=%d "
                                 "two_block_search=%d terminal_arm=%d arm_loops=%d\n",
                                 pidx, id, region_condition_block, header_source_blk,
                                 nested_loop_exits_to_terminal ? 1 : 0,
                                 nested_loop_is_two_block_search ? 1 : 0,
                                 nested_loop_arm_is_terminal ? 1 : 0,
                                 nested_terminal_arm_loop_count);
                bool reject_terminal_search =
                    !std::getenv("RENOVICE_ALLOW_CONDITIONAL_STEAL_TERMINAL_SEARCH")
                    && nested_loop_exits_to_terminal && nested_loop_is_two_block_search;
                // Both facts are required. A terminal child region alone is insufficient: Duviri
                // BuildConfig p20 has that broad shape, but the nested loop's own normal exhaustion
                // continues into non-terminal control flow; rejecting its parent claim flattened a
                // real outer numeric loop into a one-shot repeat. EndOfMatch p95 has a terminal arm
                // AND a terminal normal loop exit, which is the causal dead-tail shape.
                bool reject_terminal_arm =
                    !std::getenv("RENOVICE_ALLOW_CONDITIONAL_STEAL_TERMINAL_ARM")
                    && nested_loop_arm_is_terminal && nested_loop_exits_to_terminal;
                // ChatRedux p181 has terminal command arms that each contain exactly one complete
                // generic loop. Their parent switch condition greedily claims the nested prep,
                // replacing the switch with `for`; the preceding command arm's return then makes
                // the next callback closures dead. The old broad terminal-arm experiment also
                // matched DuviriBuildConfig p20, whose arm contains four nested loops including a
                // real outer numeric loop, and damaged it. Requiring exactly one dominance-backed
                // loop distinguishes those shapes. Hub p41 confirms the same rule independently:
                // it removes an invented duplicate loop and restores the original 1-header/2-latch
                // topology. Keep an opt-out only for controlled A/B reproduction.
                bool reject_single_loop_terminal_arm =
                    !std::getenv("RENOVICE_ALLOW_SINGLE_LOOP_TERMINAL_ARM_STEAL")
                    && nested_loop_arm_is_terminal && nested_terminal_arm_loop_count == 1;
                if (reject_terminal_arm || reject_single_loop_terminal_arm) {
                    auto canonical_latch = prep2latch.find(header_source_blk);
                    if (canonical_latch != prep2latch.end())
                        terminal_arm_loop_latches.insert(canonical_latch->second);
                    else if (term_op(header_source_blk) == 0x1e)
                        terminal_arm_loop_latches.insert(header_source_blk);
                }
                if ((reject_terminal_search || reject_terminal_arm
                     || reject_single_loop_terminal_arm) && isfor
                    && (r.kind == sa::RK::IfThen || r.kind == sa::RK::IfThenElse)
                    && header_source_blk != region_condition_block
                    )
                {
                    isfor = false;
                    prep_part = -1;
                    latch_blk = -1;
                    hb = region_condition_block;
                    header_source_blk = region_condition_block;
                }
                // AUTHORITATIVE GATE. A `for` may only be opened if the loop this prep belongs to is
                // a REAL loop header in the dominator-derived map. Previously any prep found anywhere
                // in a region's subtree opened a header, so a PARENT region emitted a loop belonging
                // to a NESTED region and the child then emitted it again — +588 invented loop headers
                // across 300 files. Consulting the map instead of the opcode makes the structurer the
                // single source of truth, which is how Ghidra/angr/Cifuentes all order it.
                // OWNERSHIP GATE: only the designated region may wrap this loop. Everyone else
                // falls through to its normal handling, so no code is orphaned.
                static const bool use_own = std::getenv("RENOVICE_OWNEMIT") != nullptr;
                if (use_own && isfor && !own_emit.empty()) {
                    int lh = -1;
                    if (hb >= 0 && hb < (int)g->n.size()) {
                        int li = g->n[hb].last;
                        int o  = (li >= 0 && li < (int)ip->code.size()) ? (int)ip->code[li].op : -1;
                        if (o == 0x47)                                   lh = g->n[hb].succ_false;
                        else if (o == 0x0b || o == 0x30 || o == 0x1b)    lh = g->n[hb].succ_true;
                        else                                             lh = hb;
                    }
                    auto oit = own_emit.find(lh);
                    if (oit != own_emit.end() && oit->second != id) isfor = false;
                }
                int loop_id = -1;                    // canonical identity of the loop = its LATCH block
                if (!std::getenv("RENOVICE_NO_THREE_LATCH_SINGLE_LOOP") && isfor) {
                    if (latch_blk >= 0 && A->multi_latch_for_headers.count(latch_blk))
                        loop_id = latch_blk;
                    else {
                        auto canonical_latch = prep2latch.find(hb);
                        if (canonical_latch != prep2latch.end()
                            && A->multi_latch_for_headers.count(canonical_latch->second))
                            loop_id = canonical_latch->second;
                    }
                }
                if (isfor && !terminal_arm_loop_latches.empty()) {
                    if (latch_blk >= 0 && terminal_arm_loop_latches.count(latch_blk))
                        loop_id = latch_blk;
                    else if (term_op(hb) == 0x1e && terminal_arm_loop_latches.count(hb))
                        loop_id = hb;
                    else {
                        auto terminal_latch = prep2latch.find(hb);
                        if (terminal_latch != prep2latch.end()
                            && terminal_arm_loop_latches.count(terminal_latch->second))
                            loop_id = terminal_latch->second;
                    }
                }
                // GATED OFF BY DEFAULT (RENOVICE_LOOPMAP=1 to enable). Consulting the structurer's
                // loop map instead of scanning opcodes is the architecturally correct fix (#64) and it
                // WORKS on duplication -- invented loop headers fell 588 -> 205. But it also rejects
                // loops the map does not carry, and lost headers rose 175 -> 678, so MATCH went
                // 112 -> 107: net WORSE. The map is not yet complete enough to be authoritative, and a
                // half-applied refactor that loses more loops than it fixes is worse than none.
                // Kept, flagged, and measured rather than deleted or silently shipped.
                static const bool use_map = std::getenv("RENOVICE_LOOPMAP") != nullptr;
                // Gate on the CANONICAL map, not on prep2latch: keying the guard to the PATTERN branch meant
                // any proto whose loops were found only by DOMINANCE had prep2latch empty and so ran
                // entirely UNGATED - the permissive path that kept the duplication alive.
                // NO EMPTINESS ESCAPE HATCH. `!block2loop.empty()` skipped the gate entirely for any proto
                // whose map was empty, and those protos then emitted the SAME loop up to 4 times
                // (measured: proto 5 of AvatarDiorama, emitted=4 distinct=1 map=0). If the structurer
                // found NO loops in a proto, a `for` emitted there is unjustified by definition, so an
                // empty map must REJECT rather than wave everything through.
                if (use_map && isfor) {
                    if (latch_blk >= 0) {
                        if (latch_of_loop.count(latch_blk)) loop_id = latch_blk;
                    } else {
                        auto it = prep2latch.find(hb);
                        if (it != prep2latch.end()) loop_id = it->second;
                        else {
                            // find_loops has TWO branches (pattern-based for FOR* preps, and plain
                            // dominance). Keying only on the pattern branch's prep rejected every loop
                            // the dominance branch found -- lost loops jumped 175 -> 678. Accept the
                            // derived HEADER too: numeric-for falls through into its body, generic-for
                            // jumps to its FORGLOOP.
                            int li = (hb >= 0 && hb < (int)g->n.size()) ? g->n[hb].last : -1;
                            uint8_t o = (li >= 0 && li < (int)ip->code.size()) ? ip->code[li].op : 0;
                            int hdr = -1;
                            if (o == 0x47) hdr = g->n[hb].succ_false;
                            else if (o == 0x0b || o == 0x30 || o == 0x1b) hdr = g->n[hb].succ_true;
                            if (hdr >= 0 && header_of_loop.count(hdr)) loop_id = hdr;
                        }
                    }
                    // THE REGION'S OWN HEAD BLOCK MAY ITSELF BE THE LOOP. A generic-for's head block
                    // terminates in FORGLOOP, which (per #68) IS that loop's header — and a numeric
                    // loop's head can be the FORNLOOP latch. Every observed rejection was exactly this
                    // shape (op=0x1e, latch_blk=-1, no prep entry), because the gate only ever asked
                    // about a PREP block or the fallback latch, never about `hb` itself.
                    if (loop_id < 0 && hb >= 0) {
                        auto it2 = block2loop.find(hb);
                        if (it2 != block2loop.end()) loop_id = it2->second;
                    }
                    if (loop_id >= 0) {                 // canonicalise: always key on the HEADER
                        auto it3 = block2loop.find(loop_id);
                        if (it3 != block2loop.end()) loop_id = it3->second;
                    }
                    // Only the OWNING region may wrap this loop. Any other region that meets it emits
                    // its parts flat, so the loop is neither duplicated nor lost.
                    // OFF unless RENOVICE_LOOPOWNER=1. Ownership-by-smallest-containing-region is
                    // NOT the right rule: requiring header+latch picked regions too deep (MATCH 81),
                    // requiring the whole body still only reached 87 - both far below the 125 that
                    // mark-before-recurse alone achieves. Containment does not identify the region that
                    // will actually WRAP the loop. Kept, flagged and measured rather than deleted.
                    static const bool use_owner = std::getenv("RENOVICE_LOOPOWNER") != nullptr;
                    if (use_owner && loop_id >= 0) {
                        auto ito = loop_owner.find(loop_id);
                        if (ito != loop_owner.end() && ito->second != id) { isfor = false; loop_id = -1; }
                    }
                    if (loop_id < 0 && isfor) {
                        // Instrumented, not guessed: report WHICH lookup missed. Guessing this
                        // rejection cause has failed three times; the double-header question only
                        // yielded to provenance tracing.
                        if (std::getenv("RENOVICE_LOOPTRACE")) {
                            int li = (hb >= 0 && hb < (int)g->n.size()) ? g->n[hb].last : -1;
                            int o  = (li >= 0 && li < (int)ip->code.size()) ? (int)ip->code[li].op : -1;
                            int hN = (hb >= 0 && o == 0x47) ? g->n[hb].succ_false : -1;
                            int hG = (hb >= 0 && (o == 0x0b || o == 0x30 || o == 0x1b))
                                     ? g->n[hb].succ_true : -1;
                            std::fprintf(stderr,
                                "REJECT rgn=%d hb=%d op=0x%02x latch_blk=%d inPrep2Latch=%d "
                                "inLatchSet=%d hdrN=%d(%d) hdrG=%d(%d) mapsz=%zu\n",
                                id, hb, o, latch_blk, (int)prep2latch.count(hb),
                                (latch_blk >= 0 ? (int)latch_of_loop.count(latch_blk) : -1),
                                hN, (hN >= 0 ? (int)header_of_loop.count(hN) : -1),
                                hG, (hG >= 0 ? (int)header_of_loop.count(hG) : -1),
                                prep2latch.size());
                        }
                        isfor = false;               // the structurer does not call this a loop
                    }
                }
                if (isfor) {
                    // Resolve the loop's identity BEFORE emitting anything, so an already-open loop
                    // is not wrapped a second time. FORNPREP is CONDITIONAL and falls through into
                    // the body; FORGPREP is UNCONDITIONAL and jumps to the FORGLOOP latch, so its
                    // body is the block immediately after it (the latch's back-edge target).
                    int bstart = -1;
                    if (latch_blk >= 0 && latch_blk < (int)g->n.size()) {
                        // Header came from the FORGLOOP LATCH. Its back edge jumps to the body start,
                        // which is the SAME block the prep path resolves to — so both paths now agree
                        // on the loop's identity and the guard can actually match.
                        bstart = g->n[latch_blk].succ_true;
                    } else if (hb >= 0 && hb < (int)g->n.size()) {
                        int ho = term_op(hb);
                        if (ho == 0x0b || ho == 0x30 || ho == 0x1b) {      // FORGPREP + specialisations
                            int nxt = g->n[hb].last + 1;
                            for (size_t q = 0; q < g->n.size(); ++q)
                                if (g->n[q].first == nxt) { bstart = (int)q; break; }
                        } else if (ho == 0x0a) {
                            bstart = g->n[hb].succ_true;   // FORNLOOP latch: back edge -> body start
                        } else {
                            bstart = g->n[hb].succ_false;                  // FORNPREP: fallthrough
                        }
                    }
                    int loopkey = (loop_id >= 0) ? loop_id : (latch_blk >= 0 ? latch_blk : bstart);
                    bool exact_second_generic_scope =
                        enable_gyre_second_generic_nested
                        && r.kind == sa::RK::While
                        && exact_generic_scope_theft(hb, bstart, 1, 2, 2, 8);
                    // Narrow diagnostic for an observed generic-for duplicate.  When the structurer's
                    // loop child is headed by FORGLOOP, the fallback above keys it by the *post-loop*
                    // successor.  Its conditional parent is keyed by the first body block instead,
                    // so planning sees two loops.  Derive that same body block from the authoritative
                    // PREP only for this exact While/FORGLOOP claim; unlike broad canonicalisation,
                    // this does not merge nested NaturalLoop claims.
                    bool generic_header_body_loopkey =
                        std::getenv("RENOVICE_GENERIC_HEADER_BODY_LOOPKEY") != nullptr
                        || std::getenv("RENOVICE_GENERIC_BODYKEY_LARGE_OUTER") != nullptr
                        || enable_exact_six_shell_outer
                        || enable_surplus_generic_collision
                        || exact_energized_proto
                        || exact_four_latch_generic_with_four_block_peer(hb)
                        || exact_pulse_two_exit_proto
                        || exact_second_generic_scope;
                    if (generic_header_body_loopkey && isfor
                        && r.kind == sa::RK::While && hb >= 0 && term_op(hb) == 0x1e)
                    {
                        auto header_identity = block2loop.find(hb);
                        if (header_identity != block2loop.end()) {
                            for (const auto& prep_latch : prep2latch) {
                                auto prep_identity = block2loop.find(prep_latch.first);
                                if (prep_identity == block2loop.end()
                                    || prep_identity->second != header_identity->second)
                                    continue;
                                int next_instruction = g->n[prep_latch.first].last + 1;
                                for (size_t block = 0; block < g->n.size(); ++block)
                                    if (g->n[block].first == next_instruction) {
                                        int parent_body_key = (int)block;
                                        // Collision evidence is mandatory.  Without a parent claim
                                        // on this exact key, the FORGLOOP-headed region is a real,
                                        // standalone owner and remapping it can suppress the loop.
                                        bool claimed_by_parent = planning
                                            ? plan_claim.count(parent_body_key) != 0
                                            : plan_winner.count(parent_body_key) != 0;
                                        if (claimed_by_parent) loopkey = parent_body_key;
                                        break;
                                    }
                                break;
                            }
                        }
                    }
                    // Diagnostic fork: planning cannot deduplicate one loop if a parent claimant is
                    // keyed by its body start while the loop-kind child is keyed by its post-loop
                    // successor.  The authoritative map already gives PREP and HEADER the same
                    // identity; test that identity independently of RENOVICE_LOOPMAP's unsafe
                    // emission gate before considering it for production.
                    bool canonical_plan_loopkey =
                        std::getenv("RENOVICE_CANONICAL_PLAN_LOOPKEY") != nullptr
                        || std::getenv("RENOVICE_COMBINED_CANONICAL_OUTER_LOOP") != nullptr;
                    if (canonical_plan_loopkey && isfor) {
                        for (int candidate : {hb, header_source_blk, latch_blk, bstart}) {
                            auto canonical = block2loop.find(candidate);
                            if (canonical != block2loop.end()) {
                                loopkey = canonical->second;
                                break;
                            }
                        }
                    }
                    int authoritative_header = -1;
                    for (int candidate : {loop_id, hb, header_source_blk, latch_blk, bstart}) {
                        auto identity = block2loop.find(candidate);
                        if (identity != block2loop.end()) {
                            authoritative_header = identity->second;
                            break;
                        }
                    }
                    if (planning) {
                        if (loopkey >= 0 && authoritative_header >= 0)
                            plan_key_loops[loopkey].insert(authoritative_header);
                        // CANONICAL-FIRST, then innermost. A claimant whose head block IS the loop's
                        // prep or header genuinely owns the header text; prefer it over any region
                        // that merely happens to contain the loop. Ties break on nesting depth.
                        bool canonical = (hb >= 0) && (prep2latch.count(hb) || header_of_loop.count(hb));
                        // Experimental fork for the final #106 loop-wrapper specimens. The default
                        // innermost claimant excludes their guarded return; measure outermost across
                        // every oracle before changing production ownership.
                        int nest_score = std::getenv("RENOVICE_PLAN_OUTERMOST") ? -plan_nest : plan_nest;
                        int score = (canonical ? 2000 : 0) + nest_score;
                        // Semantic ownership must cover the loop before locality or opcode position
                        // can break ties.  The legacy per-key contests never compared aliases, so an
                        // incomplete deep region could beat a complete claimant once aliases were
                        // merged by LoopId.  Give complete authoritative-body coverage absolute
                        // priority; the existing canonical/innermost score remains the tie-breaker.
                        std::vector<int> semantic_claim_blocks;
                        collect_blocks(id, semantic_claim_blocks);
                        bool complete_semantic_owner = authoritative_header >= 0;
                        auto authoritative_body = authoritative_loop_bodies.find(authoritative_header);
                        if (authoritative_body == authoritative_loop_bodies.end()) {
                            complete_semantic_owner = false;
                        } else {
                            std::set<int> claim_set(semantic_claim_blocks.begin(),
                                                    semantic_claim_blocks.end());
                            for (int block : authoritative_body->second)
                                if (!claim_set.count(block)) {
                                    complete_semantic_owner = false;
                                    break;
                                }
                        }
                        int semantic_score = (complete_semantic_owner ? 1000000 : 0) + score;
                        if (std::getenv("RENOVICE_PLANDBG")) {
                            std::vector<int> claim_blocks;
                            collect_blocks(id, claim_blocks);
                            std::fprintf(stderr,
                                         "PLAN_CLAIM pidx=%d loopkey=%d rgn=%d kind=%s hb=%d "
                                         "canonical=%d nest=%d score=%d blocks=%d\n",
                                         pidx, loopkey, id, rk_name(r.kind), hb, canonical ? 1 : 0,
                                         plan_nest, score, (int)claim_blocks.size());
                        }
                        auto pit = plan_claim.find(loopkey);
                        if (loopkey >= 0 && (pit == plan_claim.end() || score > pit->second.first))
                            plan_claim[loopkey] = std::make_pair(score, id);
                        if (authoritative_header >= 0) {
                            semantic_plan_candidates[authoritative_header][id].insert(loopkey);
                            if (canonical)
                                semantic_header_candidates.insert({authoritative_header, id});
                            if (complete_semantic_owner)
                                semantic_body_candidates.insert({authoritative_header, id});
                            auto semantic = semantic_plan_claim.find(authoritative_header);
                            if (semantic == semantic_plan_claim.end()
                                || semantic_score > semantic->second.first
                                || (semantic_score == semantic->second.first
                                    && id < semantic->second.second))
                                semantic_plan_claim[authoritative_header] =
                                    std::make_pair(semantic_score, id);
                        }
                        auto planned_moves = for_move_candidates.find(header_source_blk);
                        if (loopkey >= 0 && planned_moves != for_move_candidates.end())
                            planned_for_moves[loopkey] = planned_moves->second;
                        if (authoritative_header >= 0 && planned_moves != for_move_candidates.end())
                            semantic_planned_for_moves[authoritative_header] = planned_moves->second;
                    } else if (loopkey >= 0 && !plan_winner.empty()) {
                        int winning_region = -1;
                        auto legacy = plan_winner.find(loopkey);
                        if (legacy != plan_winner.end()) winning_region = legacy->second;
                        if (winning_region >= 0 && winning_region != id) {
                            // FINDINGS #106: a losing LOOP claimant may still be an IfThen region.
                            // Flattening that region suppresses its unrelated conditional wrapper;
                            // a guarded return becomes unconditional and kills the reachable tail.
                            // Return-site provenance plus the exact 300-file lost-condition gate
                            // measured 165 -> 59 sites when conditional losers use their normal
                            // emitter. Keep an opt-out only for controlled A/B attribution.
                            if (!std::getenv("RENOVICE_FLATTEN_PLAN_CONDITIONALS")
                                && (r.kind == sa::RK::IfThen || r.kind == sa::RK::IfThenElse)) {
                                if (std::getenv("RENOVICE_SEQDBG"))
                                    std::fprintf(stderr,
                                                 "KEEP_PLAN_CONDITIONAL rgn=%d winner=%d loopkey=%d\n",
                                                 id, winning_region, loopkey);
                                goto emit_conditional_region;
                            }
                            // Non-conditional losers really are duplicate loop wrappers and remain
                            // flat. The older broad kind-guard experiment was correctly recorded as
                            // false for that code revision; subsequent emitter changes required this
                            // return-site remeasurement rather than assuming the old result persisted.
                            flatmark(1, id, r.kind, isfor?1:0); for (int p : r.parts) emit_region(p, depth);
                            break;
                        }
                    }
                    if (isfor && planning) ++plan_nest;
                    if (std::getenv("RENOVICE_LOOPTRACE"))
                        std::fprintf(stderr, "EMIT p=%d loopkey=%d already=%d open=%zu\n",
                                     pidx, loopkey, (loopkey >= 0 ? (int)for_open.count(loopkey) : -1),
                                     for_open.size());
                    if (loopkey >= 0 && for_open.count(loopkey)) {
                        // An enclosing region already opened THIS loop. Emit the parts flat rather
                        // than wrapping the same body in a second, identical `for`.
                        // (A loop-kind guard was tried here too and REVERTED — see the note on the
                        // plan_winner branch above and FINDINGS #102.)
                        flatmark(2, id, r.kind, isfor?1:0); for (int p : r.parts) emit_region(p, depth);
                        break;
                    }
                    // SIMPLE NESTED OUTER-LOOP REPAIR. A NaturalLoop can be the authoritative wrapper for
                    // an OUTER while/repeat while its region also contains the PREP of a nested
                    // numeric for. The generic interior-PREP scan above then turns the whole region
                    // into that inner `for`; the for-body partition correctly keeps the tail outside
                    // the inner loop, but nothing re-opens the outer loop, so the tail executes once.
                    //
                    // StalkerAbsorb proto 7 is the minimal measured witness:
                    //   outer  header=16 latch=24 body={16..24} (While/Repeat)
                    //   inner  header=19 latch=23 prep=18       (ForNum)
                    //   region 64 is NaturalLoop(head=16) but claims the inner loop via prep 18.
                    //
                    // Preserve the existing, already-measured inner-for partition and wrap its whole
                    // emitted segment in an outer `while true`. While emitting that segment, arm the
                    // OUTER natural-loop block set, so blocks 16/17 spell their exact exit branches as
                    // `if ... then break end` in original evaluation order. The inner for temporarily
                    // replaces loop_blocks and restores this outer set on close.
                    //
                    // The production boundary is intentionally narrow: the region must itself be a
                    // NaturalLoop, its original condition/head must map to a DIFFERENT authoritative
                    // loop from the claimed for, that outer loop must not itself have a FOR prep, the
                    // dominator-derived body must be non-empty, and the nested PREP must be a DIRECT
                    // Basic sibling of the NaturalLoop. The last requirement is essential:
                    // FocusActivation p8 stores its FORGPREP deep inside a Seq child; the broad rule
                    // emitted that entire child (including the already-complete generic for) as
                    // "setup", then appended an empty duplicate for and wrapped both. A direct PREP
                    // sibling is the measured topology where this partition has an exact boundary.
                    // RENOVICE_NO_SIMPLE_NESTED_OUTER_LOOP=1 restores the prior behavior for A/B.
                    bool wrap_outer_natural = false;
                    bool exact_authoritative_region_outer = false;
                    int selected_parent_first_outer = -1;
                    std::set<int> saved_outer_loop_blocks;
                    size_t outer_segment_start = out.size();
                    if (!std::getenv("RENOVICE_NO_SIMPLE_NESTED_OUTER_LOOP")
                        && r.kind == sa::RK::NaturalLoop && region_condition_block >= 0
                        && prep_part >= 0 && prep_part < (int)r.parts.size()
                        && ((A->regions[r.parts[(size_t)prep_part]].kind == sa::RK::Basic
                             && head_block(r.parts[(size_t)prep_part]) == header_source_blk)
                            || exact_energized_outer
                            // The exact-region diagnostic below must inspect deep-PREP reducer
                            // shapes too.  Merely entering this analysis does not wrap anything;
                            // its complete-region equality remains the fail-closed decision.
                            || enable_authoritative_region_nested_outer))
                    {
                        auto outer_it = block2loop.find(region_condition_block);
                        int outer_key = outer_it == block2loop.end() ? -1 : outer_it->second;
                        bool outer_is_for = false;
                        if (outer_key >= 0)
                            for (const auto& pair : prep2latch) {
                                auto prep_loop = block2loop.find(pair.first);
                                if (prep_loop != block2loop.end() && prep_loop->second == outer_key) {
                                    outer_is_for = true;
                                    break;
                                }
                            }
                        std::set<int> outer_body = natural_loop_body(outer_key);
                        std::set<int> inner_body = natural_loop_body(bstart);
                        if (exact_energized_outer) {
                            auto canonical_inner = block2loop.find(header_source_blk);
                            if (canonical_inner != block2loop.end())
                                inner_body = natural_loop_body(canonical_inner->second);
                        }
                        std::set<int> contained_loops;
                        size_t contained_preps = 0;
                        for (int block : outer_body) {
                            auto mapped = block2loop.find(block);
                            if (mapped != block2loop.end()) contained_loops.insert(mapped->second);
                            if (prep2latch.count(block)) ++contained_preps;
                        }
                        bool inner_is_nested = !inner_body.empty();
                        for (int block : inner_body)
                            if (!outer_body.count(block)) { inner_is_nested = false; break; }
                        std::set<int> shell;
                        for (int block : outer_body)
                            if (!inner_body.count(block)) shell.insert(block);
                        // First production-quality family: one nested numeric for surrounded by a
                        // SIMPLE shell of at most three ordered exit predicates plus the PREP and
                        // outer latch/tail. Every shell block must have one of those proven roles.
                        // The next observed shell has four predicates (RhinoDamageRoar p10); its local
                        // loop is recovered, but doing so exposes an unrelated module-level duplicate
                        // and fails the no-tradeoff gate. Keep that larger family for the next repair.
                        bool shell_roles_exact = !shell.empty();
                        for (int block : shell) {
                            bool is_prep = block == header_source_blk;
                            bool is_exit_test = renderable_cond(block);
                            bool is_outer_latch = block >= 0 && block < (int)g->n.size()
                                && (g->n[block].succ_true == outer_key
                                    || g->n[block].succ_false == outer_key);
                            if (!is_prep && !is_exit_test && !is_outer_latch) {
                                shell_roles_exact = false;
                                break;
                            }
                        }
                        // Diagnostic-only expansion used to isolate the next measured family.  Do
                        // not enable this in production: larger shells have not yet passed the
                        // module-level duplicate-ownership gate.
                        bool allow_large_simple_shell =
                            std::getenv("RENOVICE_ALLOW_LARGE_SIMPLE_NESTED_OUTER_LOOP") != nullptr
                            || std::getenv("RENOVICE_COMBINED_CANONICAL_OUTER_LOOP") != nullptr
                            || std::getenv("RENOVICE_GENERIC_BODYKEY_LARGE_OUTER") != nullptr
                            || (enable_exact_six_shell_outer && shell.size() == 6);
                        bool exact_energized_wrap = exact_energized_outer
                            && outer_key == energized_outer_header
                            && header_source_blk == energized_second_prep
                            && outer_body.size() == 20 && inner_body.size() == 4
                            && contained_loops.size() == 3 && contained_preps == 2;
                        // Diagnostic candidate for the next Gyre family.  Unlike the original
                        // small-shell repair, this does not classify every block outside the nested
                        // numeric loop as an exit/prep/latch.  Instead it requires a stronger whole-
                        // region invariant: the emitting NaturalLoop's complete block set must equal
                        // the authoritative outer-loop body exactly.  That permits ordinary work in
                        // the shell without accidentally pulling a preheader, preceding peer loop,
                        // or post-loop continuation into the wrapper.  GyreOvercharged p9 is the
                        // first witness; GyrePulse p14 deliberately fails this equality because its
                        // reducer region also contains blocks outside the authoritative outer loop.
                        if (enable_authoritative_region_nested_outer) {
                            std::vector<int> emitting_region_vector;
                            collect_blocks(id, emitting_region_vector);
                            std::set<int> emitting_region_blocks(emitting_region_vector.begin(),
                                                                 emitting_region_vector.end());
                            std::set<int> authoritative_inner_body;
                            auto authoritative_inner = authoritative_loop_bodies.find(loopkey);
                            if (authoritative_inner != authoritative_loop_bodies.end())
                                authoritative_inner_body = authoritative_inner->second;
                            bool authoritative_inner_is_nested =
                                !authoritative_inner_body.empty();
                            for (int block : authoritative_inner_body)
                                if (!outer_body.count(block)) {
                                    authoritative_inner_is_nested = false;
                                    break;
                                }
                            std::set<int> authoritative_outer_exits;
                            for (int block : outer_body)
                                for (int target : {g->n[block].succ_true,
                                                   g->n[block].succ_false})
                                    if (target >= 0 && !outer_body.count(target))
                                        authoritative_outer_exits.insert(target);
                            exact_authoritative_region_outer =
                                outer_key >= 0 && outer_key != loopkey && !outer_is_for
                                && authoritative_inner_is_nested
                                && term_op(header_source_blk) == 0x47
                                && contained_loops.size() == 2 && contained_preps == 1
                                && emitting_region_blocks == outer_body
                                // First certification boundary: larger/multi-exit prototypes can
                                // contain an independent false loop that the recovered outer loop
                                // exposes by cancellation.  Keep those for an atomic ownership
                                // repair; this bounded family has no negative ability witnesses.
                                && authoritative_outer_exits.size() == 1
                                && header_of_loop.size() <= 4;
                            // Parent-first diagnostic: when this region equals a single-exit
                            // authoritative non-for body exactly, preserve that outer wrapper before
                            // repairing any nested child loop. Use the canonical inner LoopId rather
                            // than the historical rendering key, and do not require the outer body to
                            // contain only one child; that requirement is precisely what excluded the
                            // measured shared-wrapper family.
                            if (parent_first_outer_headers.count(outer_key)) {
                                std::set<int> canonical_inner_body;
                                auto canonical_inner =
                                    authoritative_loop_bodies.find(authoritative_header);
                                if (canonical_inner != authoritative_loop_bodies.end())
                                    canonical_inner_body = canonical_inner->second;
                                bool canonical_inner_nested = !canonical_inner_body.empty();
                                for (int block : canonical_inner_body)
                                    if (!outer_body.count(block)) {
                                        canonical_inner_nested = false;
                                        break;
                                    }
                                exact_authoritative_region_outer = outer_key >= 0
                                    && authoritative_header >= 0
                                    && outer_key != authoritative_header && !outer_is_for
                                    && canonical_inner_nested
                                    && emitting_region_blocks == outer_body
                                    && authoritative_outer_exits.size() == 1;
                                if (exact_authoritative_region_outer)
                                    selected_parent_first_outer = outer_key;
                                if (std::getenv("RENOVICE_LOOPTRACE"))
                                    std::fprintf(stderr,
                                                 "PARENT_FIRST_EXACT_OUTER pidx=%d rgn=%d "
                                                 "outer=%d inner=%d outer_body=%d inner_body=%d "
                                                 "exits=%d exact=%d\n",
                                                 pidx, id, outer_key, authoritative_header,
                                                 (int)outer_body.size(),
                                                 (int)canonical_inner_body.size(),
                                                 (int)authoritative_outer_exits.size(),
                                                 exact_authoritative_region_outer ? 1 : 0);
                            }
                            if (std::getenv("RENOVICE_LOOPTRACE"))
                                std::fprintf(stderr,
                                             "AUTHORITATIVE_REGION_OUTER pidx=%d rgn=%d outer=%d "
                                             "inner=%d region=%zu outer_body=%zu inner_body=%zu "
                                             "nested=%d exits=%zu headers=%zu exact=%d\n",
                                             pidx, id, outer_key, loopkey,
                                             emitting_region_blocks.size(), outer_body.size(),
                                             authoritative_inner_body.size(),
                                             authoritative_inner_is_nested ? 1 : 0,
                                             authoritative_outer_exits.size(),
                                             header_of_loop.size(),
                                             exact_authoritative_region_outer ? 1 : 0);
                        }
                        if (enable_gyre_energized_outer && std::getenv("RENOVICE_LOOPTRACE"))
                            std::fprintf(stderr,
                                         "ENERGIZED_OUTER pidx=%d rgn=%d exact=%d outer=%d/%d "
                                         "source=%d/%d bodies=%zu/%zu loops=%zu preps=%zu wrap=%d\n",
                                         pidx, id, exact_energized_outer ? 1 : 0,
                                         outer_key, energized_outer_header,
                                         header_source_blk, energized_second_prep,
                                         outer_body.size(), inner_body.size(), contained_loops.size(),
                                         contained_preps, exact_energized_wrap ? 1 : 0);
                        if ((outer_key >= 0 && outer_key != loopkey && !outer_is_for
                             && inner_is_nested && term_op(header_source_blk) == 0x47
                             && contained_loops.size() == 2 && contained_preps == 1
                             && (shell.size() <= 5 || allow_large_simple_shell)
                             && shell_roles_exact) || exact_energized_wrap
                            || exact_authoritative_region_outer)
                        {
                            wrap_outer_natural = true;
                            saved_outer_loop_blocks = loop_blocks;
                            loop_blocks.swap(outer_body);
                            ++loop_depth;
                            if (std::getenv("RENOVICE_LOOPTRACE")) {
                                std::set<int> outer_exits;
                                for (int block : loop_blocks)
                                {
                                    for (int succ : {g->n[block].succ_true, g->n[block].succ_false})
                                        if (succ >= 0 && !loop_blocks.count(succ))
                                            outer_exits.insert(succ);
                                }
                                std::fprintf(stderr,
                                             "ABILITY_OUTER_WRAP pidx=%d rgn=%d outer=%d inner=%d "
                                             "outer_blocks=%zu inner_blocks=%zu exits=%zu parts=%zu "
                                             "prep_part=%d prep_op=0x%02x loops=%zu preps=%zu\n",
                                             pidx, id, outer_key, loopkey, loop_blocks.size(),
                                             inner_body.size(), outer_exits.size(), r.parts.size(),
                                             prep_part, term_op(header_source_blk),
                                             contained_loops.size(), contained_preps);
                            }
                        }
                    }
                    // MARK BEFORE RECURSING. The setup emission below re-enters emit_region, and that
                    // recursion can reach the SAME loop again — at which point for_open had not yet
                    // been updated, so the guard saw nothing and the loop was emitted a second time.
                    // Measured: `EMIT p=63 loopkey=43 already=0 open=0` three times over, one loop
                    // emitted three times with the guard never firing once (0 suppressions in 128
                    // emissions). Claiming the loop first makes the guard effective on re-entry.
                    // Gated: mark-before-recurse eliminates duplication (EXTRA 550 -> 0) but lets the
                    // OUTERMOST region claim the loop, and on the default path that DROPS CODE -
                    // NAME-DIFF 3 -> 15, i.e. 12 more files touching a different set of named
                    // entities. Losing an entity access is a semantic change and is never an
                    // acceptable price for tidier loop structure. Confined to the experimental path
                    // until loop OWNERSHIP is resolved before emission.
                    if (use_map && loopkey >= 0) for_open.insert(loopkey);
                    // This region survived ownership/deduplication and will really emit the header;
                    // only now is it safe to consume the compiler's setup MOVE triplet.
                    auto fmc = for_move_candidates.find(header_source_blk);
                    if (std::getenv("RENOVICE_LOOPTRACE"))
                        std::fprintf(stderr,
                                     "FOR_MOVE pidx=%d source=%d found=%d count=%d candidates=%d\n",
                                     pidx, header_source_blk,
                                     fmc != for_move_candidates.end() ? 1 : 0,
                                     fmc != for_move_candidates.end() ? (int)fmc->second.size() : 0,
                                     (int)for_move_candidates.size());
                    if (fmc != for_move_candidates.end())
                        suppress_insns.insert(fmc->second.begin(), fmc->second.end());
                    // A LATCH-HEADED loop has NO setup to emit first: parts[0] IS the latch, i.e. the
                    // END of the body. Emitting it as "setup" before the header inverts the body and
                    // produces reads of registers that have not been assigned yet — the source of
                    // `Normalize(nil)` (a register read before its initialiser). For those, open the
                    // header immediately and let every part be emitted as body.
                    bool latch_headed = (hb >= 0 && term_op(hb) == 0x0a)
                        || (!std::getenv("RENOVICE_NO_THREE_LATCH_SINGLE_LOOP") && latch_blk >= 0
                            && A->multi_latch_for_headers.count(latch_blk));
                    // A reduced latch-headed numeric loop may have three sibling pieces in reverse
                    // structural order: [latch+normal-exit, body, preheader/entry].  Dojo p9 is the
                    // proof specimen. Locate the unique FORNPREP paired with this latch and emit its
                    // containing part before the source header. This partition also prevents the
                    // inner latch+exit artifact from becoming a competing loop claimant. The prep
                    // part retains the zero-iteration decision; the `for` handles only the path that
                    // actually enters the loop. The environment opt-out exists only for controlled
                    // production-vs-prior-behaviour attribution.
                    int latched_numeric_pre_part = -1;
                    if (!std::getenv("RENOVICE_ALLOW_UNPARTITIONED_LATCHED_NUMERIC_REGION")
                        && latch_headed && hb >= 0 && term_op(hb) == 0x0a)
                    {
                        int paired_prep = -1;
                        for (const auto& pair : prep2latch)
                            if (pair.second == hb) {
                                if (paired_prep >= 0) { paired_prep = -2; break; }
                                paired_prep = pair.first;
                            }
                        if (paired_prep >= 0)
                            for (size_t q = 0; q < r.parts.size(); ++q) {
                                std::vector<int> blocks;
                                collect_blocks(r.parts[q], blocks);
                                if (std::find(blocks.begin(), blocks.end(), paired_prep) != blocks.end()) {
                                    latched_numeric_pre_part = (int)q;
                                    break;
                                }
                            }
                    }
                    if (latched_numeric_pre_part >= 0)
                        emit_region(r.parts[(size_t)latched_numeric_pre_part], depth);
                    // Some NaturalLoop reductions retain generic-for pieces in reverse CFG order:
                    // [body..., PREP-containing preheader, earlier preheader].  Emitting every part
                    // through PREP as setup produces an empty `for` and moves the real body outside.
                    // Production accepts only a fully separable partition proven by the
                    // authoritative loop body; any mixed part fails closed to the legacy path.
                    bool reorder_reversed_generic_natural = false;
                    bool parent_first_reversed_generic_active = false;
                    std::vector<size_t> reordered_pre, reordered_body, reordered_after;
                    bool allow_reversed_generic =
                        !std::getenv("RENOVICE_NO_REVERSED_GENERIC_CONTINUE");
                    int header_op = term_op(header_source_blk);
                    if (allow_reversed_generic && r.kind == sa::RK::NaturalLoop && prep_part > 0
                        && (header_op == 0x0b || header_op == 0x30 || header_op == 0x1b))
                    {
                        int canonical_header = -1;
                        auto mapped_header = block2loop.find(header_source_blk);
                        if (mapped_header != block2loop.end()) canonical_header = mapped_header->second;
                        std::set<int> authoritative_body = natural_loop_body(canonical_header);
                        int body_min = authoritative_body.empty() ? -1 : *authoritative_body.begin();
                        int body_max = authoritative_body.empty() ? -1 : *authoritative_body.rbegin();
                        // Two-block bodies are the minimal terminal-search family and have separate
                        // ownership hazards (ChatRedux p384).  Keep the general family at three
                        // blocks, but permit the independently gated three-part/two-exit topology.
                        std::set<int> authoritative_exits;
                        for (int block : authoritative_body)
                            for (int successor : {g->n[block].succ_true, g->n[block].succ_false})
                                if (successor >= 0 && !authoritative_body.count(successor))
                                    authoritative_exits.insert(successor);
                        bool exact_two_block_two_exit =
                            exact_pulse_two_exit_proto
                            && authoritative_body.size() == 2
                            && authoritative_exits.size() == 2
                            && r.parts.size() == 3 && prep_part == 2
                            && A->regions[r.parts[0]].kind == sa::RK::Basic
                            && A->regions[r.parts[1]].kind == sa::RK::Basic;
                        bool exact_partition = authoritative_body.size() >= 3
                            || exact_two_block_two_exit;
                        bool safe_parent_first_reversed_generic = false;
                        if (selected_parent_first_outer >= 0 && canonical_header >= 0
                            && !authoritative_body.empty()) {
                            std::set<int> parent_exits;
                            for (int block : authoritative_body)
                                for (int target : {g->n[block].succ_true,
                                                   g->n[block].succ_false})
                                    if (target >= 0 && !authoritative_body.count(target))
                                        parent_exits.insert(target);
                            int immediate_children = 0;
                            bool child_shape_safe = false;
                            for (const auto& child_entry : authoritative_loop_bodies) {
                                if (child_entry.first == canonical_header
                                    || child_entry.second.size() >= authoritative_body.size())
                                    continue;
                                bool contained = true;
                                for (int block : child_entry.second)
                                    if (!authoritative_body.count(block)) {
                                        contained = false; break;
                                    }
                                if (!contained) continue;
                                int immediate_parent = -1;
                                size_t immediate_size = (size_t)-1;
                                for (const auto& possible : authoritative_loop_bodies) {
                                    if (possible.first == child_entry.first
                                        || possible.second.size() <= child_entry.second.size())
                                        continue;
                                    bool possible_contains = true;
                                    for (int block : child_entry.second)
                                        if (!possible.second.count(block)) {
                                            possible_contains = false; break;
                                        }
                                    if (possible_contains
                                        && possible.second.size() < immediate_size) {
                                        immediate_parent = possible.first;
                                        immediate_size = possible.second.size();
                                    }
                                }
                                if (immediate_parent != canonical_header) continue;
                                ++immediate_children;
                                int child_prep_op = -1;
                                for (const auto& pair : prep2latch) {
                                    auto identity = block2loop.find(pair.first);
                                    if (identity != block2loop.end()
                                        && identity->second == child_entry.first) {
                                        child_prep_op = term_op(pair.first);
                                        break;
                                    }
                                }
                                const bool child_numeric = child_prep_op == 0x47;
                                const bool tiny_child_generic =
                                    (child_prep_op == 0x0b || child_prep_op == 0x30
                                     || child_prep_op == 0x1b)
                                    && child_entry.second.size() <= 2;
                                child_shape_safe = child_numeric || tiny_child_generic;
                            }
                            safe_parent_first_reversed_generic = parent_exits.size() == 1
                                && immediate_children == 1 && child_shape_safe;
                        }
                        std::vector<int> part_min(r.parts.size(), INT_MAX);
                        for (size_t q = 0; exact_partition && q < r.parts.size(); ++q) {
                            std::vector<int> blocks;
                            collect_blocks(r.parts[q], blocks);
                            bool any_inside = false, any_outside = false;
                            for (int block : blocks) {
                                part_min[q] = std::min(part_min[q], block);
                                if (authoritative_body.count(block)) any_inside = true;
                                else any_outside = true;
                            }
                            if (blocks.empty() || (any_inside && any_outside)) {
                                exact_partition = false;
                            } else if (any_inside) {
                                reordered_body.push_back(q);
                            } else {
                                int maximum = *std::max_element(blocks.begin(), blocks.end());
                                int minimum = *std::min_element(blocks.begin(), blocks.end());
                                if (maximum < body_min) reordered_pre.push_back(q);
                                else if (minimum > body_max) reordered_after.push_back(q);
                                else exact_partition = false;
                            }
                        }
                        auto by_block = [&](size_t left, size_t right) {
                            return part_min[left] < part_min[right];
                        };
                        std::sort(reordered_pre.begin(), reordered_pre.end(), by_block);
                        std::sort(reordered_body.begin(), reordered_body.end(), by_block);
                        std::sort(reordered_after.begin(), reordered_after.end(), by_block);
                        bool prep_is_pre = std::find(reordered_pre.begin(), reordered_pre.end(),
                                                     (size_t)prep_part) != reordered_pre.end();
                        bool begins_with_body = !reordered_body.empty() && reordered_body.front() == 0;
                        reorder_reversed_generic_natural = exact_partition && prep_is_pre
                            && (begins_with_body || exact_energized_outer
                                || (enable_parent_first_reversed_generic
                                    && safe_parent_first_reversed_generic))
                            && !reordered_pre.empty();
                        parent_first_reversed_generic_active =
                            reorder_reversed_generic_natural
                            && enable_parent_first_reversed_generic
                            && safe_parent_first_reversed_generic;
                        if (reorder_reversed_generic_natural)
                            has_reversed_generic_natural = true;
                        if (std::getenv("RENOVICE_CONTINUETRACE"))
                            std::fprintf(stderr,
                                         "REVERSED_GENERIC pidx=%d rgn=%d exact=%d enabled=%d "
                                         "pre=%zu body=%zu after=%zu canonical=%d\n",
                                         pidx, id, exact_partition ? 1 : 0,
                                         reorder_reversed_generic_natural ? 1 : 0,
                                         reordered_pre.size(), reordered_body.size(),
                                         reordered_after.size(), canonical_header);
                    }
                    if (reorder_reversed_generic_natural) {
                        for (size_t q : reordered_pre) emit_region(r.parts[q], depth);
                    } else if (latch_headed) {
                        /* no setup: the header is the first thing emitted */
                    } else if (prep_part >= 0)      // split: everything through the prep is setup
                        for (int q = 0; q <= prep_part; ++q) emit_region(r.parts[q], depth);
                    else
                        emit_region(head, depth);   // loop setup lives in the head block
                    out += ind(depth) + hdr;
                    // RENOVICE_LOOPTRACE=1 annotates every emitted `for` with its provenance. Three
                    // successive guesses at why one loop gets two headers all failed to move the
                    // count, so stop guessing: record which REGION, head block, body-start and latch
                    // produced each header and read the answer off the output.
                    if (std::getenv("RENOVICE_LOOPTRACE"))
                        out += "  --[[rgn=" + std::to_string(id) + " hb=" + std::to_string(hb)
                             + " bs=" + std::to_string(bstart) + " latch=" + std::to_string(latch_blk)
                             + " prep=" + std::to_string(prep_part)
                             + " lid=" + std::to_string(loop_id)
                             + " map=" + std::to_string((int)block2loop.size()) + " p=" + std::to_string(pidx) + "]]";
                    out += "\n";
                    if (!use_map && loopkey >= 0) for_open.insert(loopkey);
                    // A `for` is a LOOP, so a branch inside it that leaves it is a `break`. Only the
                    // NaturalLoop path used to arm `loop_blocks`, so no block inside a for-loop could
                    // ever emit one — `for i=1,n do if i>3 then break end ... end` silently dropped
                    // the break and ran every iteration.
                    // The body of a `for` starts at the PREP block's fallthrough; its natural loop is
                    // the exact break scope. Using the region's blocks instead made a nested for's
                    // scope swallow the outer loop's body.
                    //
                    // BUT THE TWO PREPS ARE ASYMMETRIC — the same trap as the M6d phantom edge.
                    // FORNPREP is CONDITIONAL: it falls through into the body, so `succ_false` IS the
                    // body. FORGPREP is UNCONDITIONAL: it JUMPS FORWARD to the FORGLOOP latch, so it
                    // has no meaningful false-edge and `succ_false` is not the body at all. Reading it
                    // as one yields an empty/garbage natural loop, the break scope collapses, and the
                    // generic-for is emitted wrong or lost. The generic-for body begins at the
                    // instruction immediately AFTER the prep — which is exactly the block FORGLOOP
                    // back-edges to.
                    int body_start = bstart;        // resolved above, before the header was emitted
                    int loop_scope_header = body_start;
                    int dominance_latches_to_head = 0;
                    if (hb >= 0 && hb < (int)g->n.size())
                        for (size_t block = 0; block < g->n.size(); ++block) {
                            if (!g->n[block].reach || !st::dominates(*g, hb, (int)block)) continue;
                            if (g->n[block].succ_true == hb || g->n[block].succ_false == hb)
                                ++dominance_latches_to_head;
                        }
                    int canonical_head = -1, displaced_head = -1;
                    auto canonical_identity = block2loop.find(hb);
                    if (canonical_identity != block2loop.end())
                        canonical_head = canonical_identity->second;
                    auto displaced_identity = block2loop.find(body_start);
                    if (displaced_identity != block2loop.end())
                        displaced_head = displaced_identity->second;
                    std::set<int> candidate_canonical_body = natural_loop_body(canonical_head);
                    std::set<int> candidate_displaced_body = natural_loop_body(displaced_head);
                    bool displaced_is_for = false;
                    for (const auto& prep_latch : prep2latch) {
                        auto prep_identity = block2loop.find(prep_latch.first);
                        if (prep_identity != block2loop.end()
                            && prep_identity->second == displaced_head) {
                            displaced_is_for = true;
                            break;
                        }
                    }
                    bool candidate_bodies_disjoint = true;
                    for (int block : candidate_canonical_body)
                        if (candidate_displaced_body.count(block)) {
                            candidate_bodies_disjoint = false;
                            break;
                        }
                    bool canonical_multi_latch_generic_body =
                        enable_multi_latch_generic_body_scope
                        && r.kind == sa::RK::While
                        && hb >= 0 && term_op(hb) == 0x1e
                        && header_of_loop.size() == 5
                        && dominance_latches_to_head == 7
                        && canonical_head >= 0 && displaced_head >= 0
                        && canonical_head != displaced_head && !displaced_is_for
                        && candidate_canonical_body.size() >= 9
                        && candidate_displaced_body.size() == 11
                        && candidate_bodies_disjoint;
                    bool canonical_second_generic_body =
                        enable_gyre_second_generic_nested
                        && r.kind == sa::RK::While
                        && exact_generic_scope_theft(hb, body_start, 1, 2, 2, 8);
                    if (std::getenv("RENOVICE_MULTI_LATCH_GENERIC_BODY_SCOPE")
                        && std::getenv("RENOVICE_CONTINUETRACE")
                        && hb >= 0 && term_op(hb) == 0x1e)
                        std::fprintf(stderr,
                                     "MULTI_LATCH_GENERIC_SCOPE pidx=%d rgn=%d hb=%d bstart=%d "
                                     "classified=%d mapped=%d\n",
                                     pidx, id, hb, body_start,
                                     dominance_latches_to_head,
                                     block2loop.count(hb) ? block2loop.at(hb) : -1);
                    bool canonical_for_scope =
                        std::getenv("RENOVICE_CANONICAL_FOR_LOOP_SCOPE") != nullptr
                        || canonical_multi_latch_generic_body
                        || canonical_second_generic_body
                        || exact_energized_outer
                        || exact_authoritative_region_outer
                        || (reorder_reversed_generic_natural
                            && !std::getenv("RENOVICE_NO_REVERSED_GENERIC_CONTINUE"));
                    if (canonical_for_scope) {
                        for (int candidate : {header_source_blk, hb, latch_blk, body_start}) {
                            auto mapped = block2loop.find(candidate);
                            if (mapped != block2loop.end()) {
                                loop_scope_header = mapped->second;
                                break;
                            }
                        }
                    }
                    std::set<int> nb = natural_loop_body(body_start);
                    if (canonical_multi_latch_generic_body || canonical_second_generic_body
                        || exact_energized_outer || exact_authoritative_region_outer) {
                        std::set<int> authoritative_body;
                        auto exact_body = authoritative_loop_bodies.find(loop_scope_header);
                        if (exact_authoritative_region_outer
                            && exact_body != authoritative_loop_bodies.end())
                            authoritative_body = exact_body->second;
                        else
                            authoritative_body = natural_loop_body(loop_scope_header);
                        if (!authoritative_body.empty()) nb.swap(authoritative_body);
                    }
                    std::set<int> control_nb = canonical_for_scope
                        ? natural_loop_body(loop_scope_header) : nb;
                    std::set<int> save = loop_blocks;
                    std::set<int> save_continue_targets = loop_continue_targets;
                    std::set<int> save_control_blocks = loop_control_blocks;
                    bool save_continue_enabled = loop_continue_enabled;
                    if (!nb.empty()) loop_blocks = nb;
                    loop_control_blocks = control_nb;
                    loop_continue_enabled = std::getenv("RENOVICE_EMIT_LOOP_CONTINUE") != nullptr
                        || (reorder_reversed_generic_natural
                            && !std::getenv("RENOVICE_NO_REVERSED_GENERIC_CONTINUE"));
                    loop_continue_targets.clear();
                    auto add_paired_latch = [&](int prep) {
                        auto paired = prep2latch.find(prep);
                        if (paired != prep2latch.end() && paired->second >= 0)
                            loop_continue_targets.insert(paired->second);
                    };
                    add_paired_latch(header_source_blk);
                    add_paired_latch(hb);
                    if (latch_blk >= 0) loop_continue_targets.insert(latch_blk);
                    if (hb >= 0 && (term_op(hb) == 0x0a || term_op(hb) == 0x1e))
                        loop_continue_targets.insert(hb);
                    if (std::getenv("RENOVICE_CONTINUETRACE")) {
                        std::fprintf(stderr,
                                     "CONTINUE_SCOPE pidx=%d rgn=%d hb=%d source=%d body=%d targets=",
                                     pidx, id, hb, header_source_blk, body_start);
                        for (int target : loop_continue_targets) std::fprintf(stderr, "%d,", target);
                        std::fprintf(stderr, " blocks=%zu control=%zu\n",
                                     loop_blocks.size(), loop_control_blocks.size());
                    }
                    // Only the parts INSIDE the natural loop belong in the body. A region routinely
                    // also holds the code that FOLLOWS the loop, and emitting that inside made a
                    // nested `for` swallow the outer loop's body — the outer statements then ran once
                    // per inner iteration.
                    std::vector<int> after;
                    if (reorder_reversed_generic_natural)
                        for (size_t q : reordered_after) after.push_back(r.parts[q]);
                    ++loop_depth;                       // we are now lexically inside `for ... do`
                    std::vector<size_t> emission_parts;
                    if (reorder_reversed_generic_natural) {
                        emission_parts = reordered_body;
                    } else {
                        size_t first_part = latch_headed ? 0
                            : (prep_part >= 0 ? (size_t)prep_part + 1 : 1);
                        for (size_t q = first_part; q < r.parts.size(); ++q)
                            emission_parts.push_back(q);
                    }
                    // NaturalLoop parts are assembled from a set, so even after the source `for`
                    // header and preheader have been recovered, the BODY can remain cyclically
                    // rotated. Alliance p29 is the minimal proof: the authoritative numeric-for body
                    // is blocks 1..13, but the two clean body parts arrive as [9..13, 1..8].  That
                    // executes the latter half of the iteration first and creates a five-state
                    // normalization rotation.
                    //
                    // Reorder only a lossless, fully proven partition: every emission part must be
                    // wholly inside `nb`, their union must equal `nb`, exactly one part must contain
                    // the authoritative body entry, and that entry-containing part must also be first
                    // in source instruction order. Mixed, missing, duplicated, or ambiguous parts
                    // fail closed. This is a CFG/source-order invariant, not an Alliance filename or
                    // prototype exception.
                    bool reordered_for_body_from_header = false;
                    if (!std::getenv("RENOVICE_NO_FOR_BODY_HEADER_ORDER")
                        && r.kind == sa::RK::NaturalLoop
                        && !reorder_reversed_generic_natural
                        && emission_parts.size() >= 2 && body_start >= 0 && !nb.empty())
                    {
                        bool exact_body_partition = true;
                        int header_part_count = 0;
                        std::set<int> partition_union;
                        std::map<size_t, int> part_first_instruction;
                        for (size_t q : emission_parts) {
                            std::vector<int> blocks;
                            collect_blocks(r.parts[q], blocks);
                            if (blocks.empty()) { exact_body_partition = false; break; }
                            int first_instruction = INT_MAX;
                            bool contains_header = false;
                            for (int block : blocks) {
                                if (!nb.count(block) || partition_union.count(block)) {
                                    exact_body_partition = false;
                                    break;
                                }
                                partition_union.insert(block);
                                contains_header = contains_header || block == body_start;
                                if (block >= 0 && block < (int)g->n.size())
                                    first_instruction = std::min(first_instruction, g->n[block].first);
                            }
                            if (!exact_body_partition || first_instruction == INT_MAX) {
                                exact_body_partition = false;
                                break;
                            }
                            part_first_instruction[q] = first_instruction;
                            if (contains_header) ++header_part_count;
                        }
                        exact_body_partition = exact_body_partition
                            && partition_union == nb && header_part_count == 1;
                        if (exact_body_partition) {
                            std::vector<size_t> ordered = emission_parts;
                            std::stable_sort(ordered.begin(), ordered.end(),
                                             [&](size_t left, size_t right) {
                                                 return part_first_instruction[left]
                                                     < part_first_instruction[right];
                                             });
                            std::vector<int> first_blocks;
                            collect_blocks(r.parts[ordered.front()], first_blocks);
                            bool ordered_from_header = std::find(first_blocks.begin(),
                                                                 first_blocks.end(), body_start)
                                != first_blocks.end();
                            if (ordered_from_header && ordered != emission_parts) {
                                emission_parts.swap(ordered);
                                reordered_for_body_from_header = true;
                            }
                        }
                        if (std::getenv("RENOVICE_LOOPTRACE"))
                            std::fprintf(stderr,
                                         "FOR_BODY_HEADER_ORDER pidx=%d rgn=%d body=%d parts=%zu "
                                         "exact=%d reordered=%d\n",
                                         pidx, id, body_start, emission_parts.size(),
                                         exact_body_partition ? 1 : 0,
                                         reordered_for_body_from_header ? 1 : 0);
                    }
                    // Parent-first descendant experiment.  The earlier direct child coalescer was
                    // structurally tempting but wrong: it inserted a nested numeric loop before the
                    // shared outer wrapper had been restored, so twelve portable loop identities
                    // regressed.  Retry only inside a region selected by the accepted parent-first
                    // repair, and only when one immediate numeric child is a lossless partition of
                    // the current source-for's direct emission parts.  This remains opt-in until the
                    // full ability oracles prove that ancestor-first composition is sufficient.
                    int parent_first_child_header = -1;
                    int parent_first_child_prep = -1;
                    int parent_first_child_latch = -1;
                    size_t parent_first_child_prep_part = (size_t)-1;
                    std::vector<size_t> parent_first_child_body_parts;
                    std::set<size_t> parent_first_child_consumed_parts;
                    std::string parent_first_child_hdr;
                    if (enable_parent_first_child_coalesce
                        && exact_authoritative_region_outer
                        && selected_parent_first_outer >= 0
                        && authoritative_header >= 0 && !nb.empty())
                    {
                        bool authoritative_parent_is_numeric = false;
                        for (const auto& pair : prep2latch) {
                            auto identity = block2loop.find(pair.first);
                            if (identity != block2loop.end()
                                && identity->second == authoritative_header
                                && term_op(pair.first) == 0x47) {
                                authoritative_parent_is_numeric = true;
                                break;
                            }
                        }
                        const bool repaired_generic_parent =
                            enable_repaired_generic_child_coalesce
                            && parent_first_reversed_generic_active
                            // First certified batch: exclude larger collision forests where an
                            // unrelated duplicate loop can mask the missing child in aggregate
                            // counts (AlchemistDistill has seven authoritative loops). Sonar's
                            // four-loop tree has no such surplus identity; deeper forests need
                            // their independent duplicate repaired before child composition.
                            && header_of_loop.size() == 4;
                        std::vector<int> candidates;
                        for (const auto& entry : authoritative_loop_bodies) {
                            const int child_header = entry.first;
                            const std::set<int>& child_body = entry.second;
                            if (child_header == authoritative_header || child_body.empty()
                                || child_body.size() >= nb.size()) continue;
                            bool contained = true;
                            for (int block : child_body)
                                if (!nb.count(block)) { contained = false; break; }
                            if (!contained) continue;

                            // The current loop must be the child's immediate authoritative parent;
                            // a deeper containing body means that ancestor still has to be repaired
                            // first and this child is not eligible in this pass.
                            int immediate_parent = -1;
                            size_t immediate_size = (size_t)-1;
                            for (const auto& possible : authoritative_loop_bodies) {
                                if (possible.first == child_header
                                    || possible.second.size() <= child_body.size()) continue;
                                bool possible_contains = true;
                                for (int block : child_body)
                                    if (!possible.second.count(block)) {
                                        possible_contains = false; break;
                                    }
                                if (possible_contains && possible.second.size() < immediate_size) {
                                    immediate_parent = possible.first;
                                    immediate_size = possible.second.size();
                                }
                            }
                            if (immediate_parent != authoritative_header) continue;
                            // The first broad ancestor-first pass was still unsafe for generic
                            // parents whose latch identity remains non-exact, and for two-exit
                            // numeric children that need escape composition rather than a plain
                            // lexical `for`.  The only portable-exact witness is a numeric parent
                            // with a single-exit numeric child; make both facts explicit.
                            std::set<int> child_exits;
                            for (int block : child_body)
                                for (int target : {g->n[block].succ_true,
                                                   g->n[block].succ_false})
                                    if (target >= 0 && !child_body.count(target))
                                        child_exits.insert(target);
                            if ((!authoritative_parent_is_numeric && !repaired_generic_parent)
                                || child_exits.size() != 1)
                                continue;

                            int prep = -1, latch = -1;
                            for (const auto& pair : prep2latch) {
                                auto identity = block2loop.find(pair.first);
                                if (identity == block2loop.end()
                                    || identity->second != child_header
                                    || term_op(pair.first) != 0x47) continue;
                                if (prep >= 0) { prep = -2; break; }
                                prep = pair.first; latch = pair.second;
                            }
                            if (prep < 0) continue;

                            size_t prep_part_index = (size_t)-1;
                            size_t prep_position = (size_t)-1;
                            std::vector<size_t> body_parts;
                            std::set<int> body_union;
                            bool exact_partition = true;
                            for (size_t position = 0; position < emission_parts.size(); ++position) {
                                size_t part_index = emission_parts[position];
                                std::vector<int> blocks;
                                collect_blocks(r.parts[part_index], blocks);
                                std::set<int> part_blocks(blocks.begin(), blocks.end());
                                if (part_blocks.count(prep)) {
                                    if (prep_part_index != (size_t)-1
                                        || part_blocks.size() != 1
                                        || A->regions[r.parts[part_index]].kind != sa::RK::Basic) {
                                        exact_partition = false; break;
                                    }
                                    prep_part_index = part_index;
                                    prep_position = position;
                                }
                                bool any_child = false, any_non_child = false;
                                for (int block : part_blocks) {
                                    if (child_body.count(block)) any_child = true;
                                    else any_non_child = true;
                                }
                                if (any_child && any_non_child) {
                                    exact_partition = false; break;
                                }
                                if (any_child) {
                                    if (prep_position != (size_t)-1 && position < prep_position) {
                                        exact_partition = false; break;
                                    }
                                    body_parts.push_back(part_index);
                                    for (int block : part_blocks)
                                        if (!body_union.insert(block).second) {
                                            exact_partition = false; break;
                                        }
                                }
                                if (!exact_partition) break;
                            }
                            exact_partition = exact_partition
                                && prep_part_index != (size_t)-1
                                && !body_parts.empty() && body_union == child_body;
                            std::string child_header_text;
                            if (!exact_partition || !for_header(prep, child_header_text)) continue;
                            candidates.push_back(child_header);
                            if (candidates.size() == 1) {
                                parent_first_child_header = child_header;
                                parent_first_child_prep = prep;
                                parent_first_child_latch = latch;
                                parent_first_child_prep_part = prep_part_index;
                                parent_first_child_body_parts = body_parts;
                                parent_first_child_hdr = child_header_text;
                            }
                        }
                        if (candidates.size() != 1) {
                            parent_first_child_header = -1;
                            parent_first_child_body_parts.clear();
                        } else {
                            std::stable_sort(parent_first_child_body_parts.begin(),
                                             parent_first_child_body_parts.end(),
                                             [&](size_t left, size_t right) {
                                                 return g->n[head_block(r.parts[left])].first
                                                     < g->n[head_block(r.parts[right])].first;
                                             });
                            parent_first_child_consumed_parts.insert(
                                parent_first_child_body_parts.begin(),
                                parent_first_child_body_parts.end());
                            if (planning) {
                                const int score = 1000000 + 2000 + plan_nest + 1;
                                semantic_plan_candidates[parent_first_child_header][id]
                                    .insert(parent_first_child_header);
                                semantic_header_candidates.insert(
                                    {parent_first_child_header, id});
                                semantic_body_candidates.insert(
                                    {parent_first_child_header, id});
                                semantic_plan_claim[parent_first_child_header] =
                                    std::make_pair(score, id);
                                plan_key_loops[parent_first_child_header]
                                    .insert(parent_first_child_header);
                                auto moves = for_move_candidates.find(parent_first_child_prep);
                                if (moves != for_move_candidates.end())
                                    semantic_planned_for_moves[parent_first_child_header] =
                                        moves->second;
                            }
                            if (std::getenv("RENOVICE_LOOPTRACE"))
                                std::fprintf(stderr,
                                             "PARENT_FIRST_CHILD_CANDIDATE pidx=%d rgn=%d "
                                             "outer=%d parent=%d child=%d prep=%d latch=%d parts=%zu\n",
                                             pidx, id, selected_parent_first_outer,
                                             authoritative_header,
                                             parent_first_child_header, parent_first_child_prep,
                                             parent_first_child_latch,
                                             parent_first_child_body_parts.size());
                        }
                    }
                    for (size_t q : emission_parts) {
                        if ((int)q == latched_numeric_pre_part) continue;
                        if (parent_first_child_header >= 0
                            && q == parent_first_child_prep_part) {
                            auto moves = for_move_candidates.find(parent_first_child_prep);
                            if (moves != for_move_candidates.end())
                                suppress_insns.insert(moves->second.begin(), moves->second.end());
                            emit_region(r.parts[q], depth + 1);
                            out += ind(depth + 1) + parent_first_child_hdr + "\n";
                            std::set<int> saved_child_blocks = loop_blocks;
                            std::set<int> saved_child_continue_targets = loop_continue_targets;
                            std::set<int> saved_child_control_blocks = loop_control_blocks;
                            bool saved_child_continue_enabled = loop_continue_enabled;
                            loop_blocks = authoritative_loop_bodies[parent_first_child_header];
                            loop_control_blocks = loop_blocks;
                            loop_continue_targets.clear();
                            if (parent_first_child_latch >= 0)
                                loop_continue_targets.insert(parent_first_child_latch);
                            loop_continue_enabled = true;
                            ++loop_depth;
                            for (size_t child_part : parent_first_child_body_parts)
                                emit_region(r.parts[child_part], depth + 2);
                            --loop_depth;
                            loop_blocks = saved_child_blocks;
                            loop_continue_targets = saved_child_continue_targets;
                            loop_control_blocks = saved_child_control_blocks;
                            loop_continue_enabled = saved_child_continue_enabled;
                            out += ind(depth + 1) + "end\n";
                            int normal_exit = parent_first_child_latch >= 0
                                && parent_first_child_latch < (int)g->n.size()
                                ? g->n[parent_first_child_latch].succ_false : -1;
                            emit_escape_propagate(depth + 1, normal_exit);
                            for_open.insert(parent_first_child_header);
                            continue;
                        }
                        if (parent_first_child_consumed_parts.count(q)) continue;
                        std::vector<int> pb; collect_blocks(r.parts[q], pb);
                        bool any_inside = nb.empty(), any_outside = false;
                        for (int b : pb) {
                            if (nb.count(b)) any_inside = true;
                            else any_outside = true;
                        }
                        // The latch/exit IfThen is a reducer artifact, not a source conditional: its
                        // head is the FORNLOOP already represented by the header, and its other child
                        // is the normal exit.  Emitting the whole mixed region inside places `return`
                        // before the real body; emitting it all outside loses the latch. Partition its
                        // direct children by the authoritative natural-loop set.
                        const sa::Region& part_region = A->regions[r.parts[q]];
                        bool partitioned = false;
                        if (latched_numeric_pre_part >= 0 && any_inside && any_outside
                            && (part_region.kind == sa::RK::IfThen
                                || part_region.kind == sa::RK::IfThenElse)
                            && head_block(r.parts[q]) == hb)
                        {
                            partitioned = true;
                            for (int child : part_region.parts) {
                                std::vector<int> cb; collect_blocks(child, cb);
                                bool child_inside = !cb.empty();
                                for (int block : cb)
                                    if (!nb.count(block)) { child_inside = false; break; }
                                if (child_inside) emit_region(child, depth + 1);
                                else after.push_back(child);
                            }
                        }
                        if (!partitioned) {
                            if (any_inside) emit_region(r.parts[q], depth + 1);
                            else            after.push_back(r.parts[q]);
                        }
                    }
                    --loop_depth;                       // and out of it again
                    if (planning) --plan_nest;
                    loop_blocks = save;
                    loop_continue_targets = save_continue_targets;
                    loop_control_blocks = save_control_blocks;
                    loop_continue_enabled = save_continue_enabled;
                    out += ind(depth) + "end\n";
                    int normal_exit = -1;
                    if (latch_blk >= 0 && latch_blk < (int)g->n.size())
                        normal_exit = g->n[latch_blk].succ_false;
                    emit_escape_propagate(depth, normal_exit);
                    // DO NOT erase: `for_open` means "already emitted in this proto", not "currently
                    // open". Erasing on close only caught NESTED duplicates, and the measured
                    // duplicates are SEQUENTIAL — two sibling regions (rgn=70, rgn=71) emitting the
                    // same loop one after the other, by which time the first had already been erased.
                    // Every block is emitted exactly once (the M6d invariant), so a loop belongs in
                    // the output exactly once too.
                    if (!after.empty()) flatmark(3, id, r.kind, isfor?1:0);
                    for (int p : after) emit_region(p, depth);
                    if (wrap_outer_natural) {
                        --loop_depth;
                        loop_blocks = saved_outer_loop_blocks;
                        std::string body = out.substr(outer_segment_start);
                        out.resize(outer_segment_start);
                        std::string nested;
                        nested.reserve(body.size() + body.size() / 16 + 16);
                        bool line_start = true;
                        for (char ch : body) {
                            if (line_start) nested += "  ";
                            nested += ch;
                            line_start = ch == '\n';
                        }
                        out += ind(depth) + "while true do\n" + nested + ind(depth) + "end\n";
                    }
                    break;
                }
emit_conditional_region:
                if (r.kind == sa::RK::IfThen || r.kind == sa::RK::IfThenElse) {
                    if (!std::getenv("RENOVICE_MUTATED_CONDITION_HB"))
                        hb = region_condition_block;
                    std::vector<int> arms(r.parts.begin() + (r.parts.empty() ? 0 : 1), r.parts.end());
                    // Atomic two-block/two-exit generic reconstruction.  In this reducer topology
                    // the conditional's head is the complete reversed NaturalLoop, while its sole
                    // Basic arm is the match action reached by the loop body's non-normal exit.  The
                    // child can correctly recover `if not match then continue`, but ordinary
                    // conditional emission places the match action AFTER `end`, changing the search
                    // into a no-op loop followed by one stale action.  Fold that exact side-exit arm
                    // before the recovered loop's closing `end` and terminate the iteration with the
                    // source-level break represented by the second authoritative exit.
                    bool fold_two_exit_match_arm = false;
                    if (!planning && exact_pulse_two_exit_proto
                        && r.kind == sa::RK::IfThen && r.parts.size() == 2
                        && A->regions[head].kind == sa::RK::NaturalLoop
                        && A->regions[arms[0]].kind == sa::RK::Basic
                        && header_of_loop.size() == 3)
                    {
                        int arm_block = head_block(arms[0]);
                        std::vector<int> head_blocks_vector;
                        collect_blocks(head, head_blocks_vector);
                        std::set<int> head_blocks(head_blocks_vector.begin(), head_blocks_vector.end());
                        int matching_loops = 0;
                        for (int candidate : header_of_loop) {
                            std::set<int> body = natural_loop_body(candidate);
                            if (body.size() != 2) continue;
                            std::set<int> exits;
                            for (int block : body)
                                for (int successor : {g->n[block].succ_true, g->n[block].succ_false})
                                    if (successor >= 0 && !body.count(successor)) exits.insert(successor);
                            bool complete_inside_head = true;
                            for (int block : body)
                                if (!head_blocks.count(block)) complete_inside_head = false;
                            bool has_generic_prep = false;
                            for (const auto& prep_latch : prep2latch) {
                                auto identity = block2loop.find(prep_latch.first);
                                if (identity != block2loop.end() && identity->second == candidate
                                    && prep_latch.second >= 0
                                    && term_op(prep_latch.second) == 0x1e)
                                    has_generic_prep = true;
                            }
                            if (complete_inside_head && exits.size() == 2 && exits.count(arm_block)
                                && has_generic_prep)
                                ++matching_loops;
                        }
                        fold_two_exit_match_arm = matching_loops == 1;
                    }
                    if (fold_two_exit_match_arm) {
                        std::string child = capture(head, depth);
                        const std::string closing = ind(depth) + "end\n";
                        size_t close = child.rfind(closing);
                        if (close != std::string::npos) {
                            std::string match_action = capture(arms[0], depth + 1);
                            child.insert(close, match_action + ind(depth + 1) + "break\n");
                            out += child;
                            break;
                        }
                    }
                    // A composite conditional head has no single opcode that `cond_of` can render.
                    // Flattening its arms is not a harmless fallback: it executes mutually exclusive
                    // paths sequentially, and an arm containing `return` makes every following part
                    // dead. Preserve the CFG decision instead. Every edge leaving the composite head
                    // records its exact target; after the head finishes, only the arm containing that
                    // target is entered. An exit that belongs to no arm is the normal "skip" path.
                    // Experiment for BindingsUtil proto 16: a compound head can BEGIN with a
                    // renderable test while still containing whole terminal alternatives.  Treating
                    // that compound region as a simple condition emits those alternatives before the
                    // eventual `if`; its first return then kills every later arm.  Force the already
                    // existing exact-exit selector for this counterfactual without changing the
                    // production path until the corpus gates establish the rule.
                    bool force_compound_selector =
                        std::getenv("RENOVICE_FORCE_COMPOSITE_SELECTOR") != nullptr;
                    if (!std::getenv("RENOVICE_NO_COMPOSITE_SELECTOR")
                        && A->regions[head].kind != sa::RK::Basic
                        && (!renderable_cond(hb) || force_compound_selector)) {
                        std::vector<int> hbl; collect_blocks(head, hbl);
                        std::set<int> hset(hbl.begin(), hbl.end()), exits;
                        bool exits_recordable = true;
                        for (int b : hbl) {
                            const st::Node& bn = g->n[b];
                            bool external = false;
                            for (int s : {bn.succ_true, bn.succ_false})
                                if (s >= 0 && !hset.count(s)) { exits.insert(s); external = true; }
                            bool t_valid = bn.succ_true >= 0, f_valid = bn.succ_false >= 0;
                            bool sole_external = external && (t_valid != f_valid);
                            if (external && !renderable_cond(b) && !bn.is_uncond
                                && !sole_external && !is_for_latch(b))
                            {
                                exits_recordable = false;
                                if (std::getenv("RENOVICE_SEQDBG"))
                                    std::fprintf(stderr,
                                                 "FLATCOND_UNREC pidx=%d region=%d block=%d term=%02x "
                                                 "true=%d false=%d\n",
                                                 pidx, id, b, (unsigned)bn.term,
                                                 bn.succ_true, bn.succ_false);
                            }
                        }
                        std::vector<std::set<int>> arm_targets(arms.size());
                        for (size_t q = 0; q < arms.size(); ++q) {
                            std::vector<int> abl; collect_blocks(arms[q], abl);
                            std::set<int> aset(abl.begin(), abl.end());
                            for (int x : exits) if (aset.count(x)) arm_targets[q].insert(x);
                        }
                        // A composite head can still end in one authoritative ordinary decision.
                        // Components_List p53 is the proof specimen: a ten-block Seq performs setup
                        // and a source-for, then block 10 alone chooses the sole arm versus the skip
                        // path. Asking the ENTRY block for a condition invents a selector around the
                        // whole Seq; that selector compiles into another composite head and gains one
                        // wrapper per normalization cycle. When every external edge originates at one
                        // renderable tail block and exactly one of its successors enters the sole arm,
                        // emit the structured head once and guard the arm with that real tail test.
                        // Multiple decision sources, mixed ownership, or an ambiguous arm fail closed.
                        bool emitted_composite_tail_decision = false;
                        if (!std::getenv("RENOVICE_NO_COMPOSITE_TAIL_DECISION")
                            && arms.size() == 1 && exits.size() == 2)
                        {
                            std::set<int> external_sources;
                            for (int block : hbl)
                                for (int target : {g->n[block].succ_true,
                                                   g->n[block].succ_false})
                                    if (target >= 0 && !hset.count(target))
                                        external_sources.insert(block);
                            std::vector<int> arm_blocks_vector;
                            collect_blocks(arms[0], arm_blocks_vector);
                            std::set<int> arm_blocks(arm_blocks_vector.begin(),
                                                     arm_blocks_vector.end());
                            // First certified family: keep the repair at the outer lexical level and
                            // require the sole arm to be no larger than half of the already-structured
                            // head. Larger or nested families are semantically plausible but expose
                            // separate unresolved selector ownership in Background; they remain on the
                            // legacy path until independently certified.
                            bool certified_outer_tail_family = depth == 1
                                && A->regions[head].kind == sa::RK::Seq
                                && arm_blocks.size() * 2 <= hset.size();
                            if (certified_outer_tail_family && external_sources.size() == 1) {
                                int tail = *external_sources.begin();
                                const st::Node& tn = g->n[tail];
                                bool true_enters = arm_blocks.count(tn.succ_true) != 0;
                                bool false_enters = arm_blocks.count(tn.succ_false) != 0;
                                if (renderable_cond(tail) && true_enters != false_enters) {
                                    emit_region(head, depth);
                                    out += ind(depth) + "if "
                                         + cond_of(tail, false_enters && !true_enters)
                                         + " then\n";
                                    emit_region(arms[0], depth + 1);
                                    out += ind(depth) + "end\n";
                                    emitted_composite_tail_decision = true;
                                    if (std::getenv("RENOVICE_ESCDBG"))
                                        std::fprintf(stderr,
                                                     "COMPOSITE_TAIL_DECISION pidx=%d region=%d "
                                                     "head=%d head_kind=%s head_blocks=%zu "
                                                     "arm_blocks=%zu tail=%d true_arm=%d "
                                                     "false_arm=%d depth=%d\n",
                                                     pidx, id, head,
                                                     rk_name(A->regions[head].kind), hset.size(),
                                                     arm_blocks.size(), tail,
                                                     true_enters ? 1 : 0,
                                                     false_enters ? 1 : 0, depth);
                                }
                            }
                        }
                        if (emitted_composite_tail_decision) break;
                        bool every_arm_has_entry = !arms.empty();
                        for (const std::set<int>& t : arm_targets)
                            if (t.empty()) every_arm_has_entry = false;
                        if (exits_recordable && every_arm_has_entry) {
                            if (std::getenv("RENOVICE_ESCDBG"))
                            {
                                std::fprintf(stderr,
                                             "COMPOSITE_SELECTOR pidx=%d region=%d head=%d "
                                             "head_kind=%s blocks=%zu exits=%zu arms=%zu depth=%d\n",
                                             pidx, id, head, rk_name(A->regions[head].kind),
                                             hset.size(), exits.size(), arms.size(), depth);
                                for (int block : hbl)
                                    for (int target : {g->n[block].succ_true,
                                                       g->n[block].succ_false})
                                        if (target >= 0 && !hset.count(target))
                                            std::fprintf(stderr,
                                                         "COMPOSITE_EXIT pidx=%d region=%d "
                                                         "source=%d target=%d renderable=%d "
                                                         "uncond=%d\n",
                                                         pidx, id, block, target,
                                                         renderable_cond(block) ? 1 : 0,
                                                         g->n[block].is_uncond ? 1 : 0);
                            }
                            EscapeContext ec;
                            ec.domain = hset;
                            ec.selector = "c" + std::to_string(id);
                            out += ind(depth) + "local " + ec.selector + " = -1\n";
                            out += ind(depth) + "repeat\n";
                            escape_stack.push_back(ec);
                            emit_region(head, depth + 1);
                            escape_stack.pop_back();
                            out += ind(depth + 1) + "break\n";
                            out += ind(depth) + "until true\n";
                            for (size_t q = 0; q < arms.size(); ++q) {
                                out += ind(depth) + std::string(q == 0 ? "if " : "elseif ");
                                bool first_target = true;
                                for (int t : arm_targets[q]) {
                                    if (!first_target) out += " or ";
                                    out += ec.selector + " == " + std::to_string(t);
                                    first_target = false;
                                }
                                out += " then\n";
                                emit_region(arms[q], depth + 1);
                            }
                            out += ind(depth) + "end\n";
                            break;
                        }
                    }
                    emit_region(head, depth);
                    // POLARITY. cond_of renders "the branch is TAKEN", but Luau compiles
                    // `if a then BODY end` as `JUMPIFNOT a -> past the body`, so the body is the
                    // FALLTHROUGH and its guard is the NEGATION of the taken-condition. Emitting the
                    // taken-condition directly inverts every if in the program -- and it still
                    // compiles, so 100% compilability said nothing. Ask the graph which successor the
                    // then-region actually is; never assume.
                    // With TWO arms we can choose between SWAPPING them and NEGATING the condition,
                    // and the two differ observably: inverting a comparison is not equivalent under
                    // NaN (`a < b` and `a >= b` are BOTH false) and reverses the operand order Lua
                    // evaluates. Pick whichever form matches the OPCODE'S OWN POLARITY, which is the
                    // comparison the source actually wrote:
                    //   positive test (JUMPIF / JUMPIFEQ / JUMPIFLT / JUMPIFLE)  -> then-arm = TARGET
                    //   NOT test (JUMPIFNOT / JUMPIFNOTEQ / JUMPIFNOTLT / NOTLE) -> then-arm = FALLTHROUGH
                    // Getting this backwards is still semantically correct but rewrites `a <= a` as
                    // `a < a`, which only shows up as a different error being raised first.
                    bool negate = false;
                    if (hb >= 0 && hb < (int)g->n.size()) {
                        const st::Node& hn = g->n[hb];
                        bool notflavour = false;
                        if (hn.last >= 0 && hn.last < (int)ip->code.size() && n_chain_len(hb) == 1) {
                            const ir::IInsn& t = ip->code[hn.last];
                            switch (t.op) {
                                case 0x18: case 0x1c: case 0x27: case 0x33: notflavour = true; break;
                                case 0x20: case 0x41: case 0x34: case 0x3a:
                                    notflavour = (t.aux & 0x80000000u) != 0; break;
                                default: break;
                            }
                        }
                        int want = notflavour ? hn.succ_false : hn.succ_true;
                        int other = notflavour ? hn.succ_true : hn.succ_false;
                        if (arms.size() == 2) {
                            // PRESERVE THE ORIGINAL ARM ORDER. This used to reorder the arms so the
                            // `then` branch was whichever one a POSITIVE test selects (nicer to read),
                            // but that emits the two arms in the opposite order to the original
                            // bytecode, so the recompile's block layout is reversed — the dominant
                            // cause of ORDER-DIFF. Only one arm ever executes, so the swap was
                            // behaviour-preserving but structurally unfaithful, and 1:1 fidelity is
                            // the requirement. Emit in block order and let `negate` carry the polarity.
                            int h0 = head_block(arms[0]), h1 = head_block(arms[1]);
                            if (h0 >= 0 && h1 >= 0 && h0 > h1) {
                                std::swap(arms[0], arms[1]); std::swap(h0, h1);
                            }
                            // cond_of(hb,false) is true exactly when the branch is TAKEN (-> succ_true),
                            // so selecting succ_false needs the inverted test. Same rule the
                            // single-arm case below already uses.
                            negate = (h0 == hn.succ_false && h0 != hn.succ_true);
                            (void)want; (void)other;
                        } else if (!arms.empty()) {
                            int tb = head_block(arms[0]);      // single arm: nothing to swap with
                            negate = (tb == hn.succ_false && tb != hn.succ_true);
                        }
                    }
                    // The head may carry no test at all — a for-LATCH whose back edge the loop region
                    // already consumed, or an unconditional terminator. Within this region it is then
                    // effectively straight-line, so emit the arms in sequence rather than inventing an
                    // `if`. This was the last source of "unrenderable condition op 0x0a".
                    // If this FORNPREP's loop header was already emitted by its designated child,
                    // the enclosing IfThen is only the VM's zero-iteration gate. Rendering that gate
                    // as a source `if` before a source `for` evaluates the bounds twice and changes
                    // Luau's observable type-error ordering. The source `for` already owns exactly
                    // this check, so emit the child flat instead of spelling the bytecode precheck.
                    const bool consumed_fornprep = hb >= 0 && hb < (int)g->n.size()
                        && g->n[hb].last >= 0 && g->n[hb].last < (int)ip->code.size()
                        && ip->code[g->n[hb].last].op == 0x47;
                    bool arms_have_terminal = false;
                    for (int a : arms) if (region_has_terminal(a)) arms_have_terminal = true;
                    if (!renderable_cond(hb) || (consumed_fornprep && !arms_have_terminal)) {
                        if (std::getenv("RENOVICE_SEQDBG")) {
                            std::vector<int> hbl; collect_blocks(head, hbl);
                            std::set<int> hset(hbl.begin(), hbl.end()), hex;
                            for (int b : hbl)
                                for (int s : {g->n[b].succ_true, g->n[b].succ_false})
                                    if (s >= 0 && !hset.count(s)) hex.insert(s);
                            std::fprintf(stderr,
                                         "FLATCOND pidx=%d region=%d kind=%s head=%d hkind=%s "
                                         "hblocks=%d exits=",
                                         pidx, id, rk_name(r.kind), head,
                                         rk_name(A->regions[head].kind), (int)hbl.size());
                            for (int x : hex) std::fprintf(stderr, "%d,", x);
                            std::fprintf(stderr, " arms=");
                            for (int a : arms) std::fprintf(stderr, "%d:%d,", a, head_block(a));
                            std::fprintf(stderr, "\n");
                        }
                        flatmark(4, id, r.kind, isfor?1:0);
                        for (size_t q = 0; q < arms.size(); ++q) emit_region(arms[q], depth);
                        break;
                    }
                    out += ind(depth) + "if " + cond_of(hb, negate) + " then\n";
                    if (!arms.empty()) emit_region(arms[0], depth + 1);
                    // With THREE OR MORE arms (a generalised n-way region) this used to emit `else`
                    // once per arm — two `else` clauses for one `if` is a hard syntax error
                    // ("Expected 'end' (to close 'else'), got 'else'"). There is exactly ONE else
                    // branch; the remaining arms are alternatives inside it, so nest them.
                    if (arms.size() > 1) {
                        out += ind(depth) + "else\n";
                        for (size_t q = 1; q < arms.size(); ++q) emit_region(arms[q], depth + 1);
                    }
                    out += ind(depth) + "end\n";
                    break;
                }
                // REAL LOOP EXITS. The old shape was `while true do <parts> break end`, whose trailing
                // unconditional break caps EVERY loop at one iteration - structurally a loop,
                // behaviourally a straight line. Emit the actual exit test instead.
                if (r.kind == sa::RK::While && r.parts.size() >= 2) {
                    // Header statements re-run every iteration, BEFORE the test, so they must stay
                    // inside the loop. Only when the header is pure test can this collapse to the
                    // idiomatic `while <cond> do`.
                    ++loop_depth;
                    std::string hdr_stmts = capture(head, depth + 1);
                    std::string body      = capture(r.parts[1], depth + 1);
                    --loop_depth;
                    int bodyblk = head_block(r.parts[1]);
                    bool neg = (hb >= 0 && hb < (int)g->n.size())
                               && bodyblk == g->n[hb].succ_false && bodyblk != g->n[hb].succ_true;
                    bool have = renderable_cond(hb);
                    std::string cond = have ? cond_of(hb, neg) : std::string();
                    if (!have) {   // no test to extract: body carries its own exits
                        out += ind(depth) + "while true do" + std::string(1,10) + hdr_stmts
                             + body + ind(depth) + "end" + std::string(1,10);
                    } else if (hdr_stmts.empty()) {
                        out += ind(depth) + "while " + cond + " do\n" + body + ind(depth) + "end\n";
                    } else {
                        // Emit the EXIT test DIRECTLY rather than negating the enter-body test.
                        // `not (i < n)` and `n <= i` agree on truth but evaluate a DIFFERENT
                        // comparison, which diverges in error text and under NaN.
                        out += ind(depth) + "while true do\n" + hdr_stmts;
                        out += ind(depth + 1) + "if "
                             + cond_of(hb, bodyblk == g->n[hb].succ_true) + " then break end\n";
                        out += body + ind(depth) + "end\n";
                    }
                    int while_exit = -1;
                    if (hb >= 0 && hb < (int)g->n.size()) {
                        const st::Node& wn = g->n[hb];
                        while_exit = (wn.succ_true == bodyblk) ? wn.succ_false : wn.succ_true;
                    }
                    emit_escape_propagate(depth, while_exit);
                    break;
                }
                if (r.kind == sa::RK::SelfLoop && !r.parts.empty()) {
                    int blk = head_block(id);
                    ++loop_depth;
                    std::string stmts = capture(r.parts[0], depth + 1);
                    --loop_depth;
                    // The EXIT is whichever successor is not the block itself; ask for THAT condition
                    // directly, because negating the loop-back test reverses the comparison.
                    if (!renderable_cond(blk)) {
                        out += ind(depth) + "while true do" + std::string(1,10) + stmts
                             + ind(depth) + "end" + std::string(1,10);
                        break;
                    }
                    bool exit_is_fallthrough = (blk >= 0 && blk < (int)g->n.size())
                                               && g->n[blk].succ_true == blk;
                    out += ind(depth) + "while true do\n" + stmts;
                    out += ind(depth + 1) + "if " + cond_of(blk, exit_is_fallthrough)
                         + " then break end\n";
                    out += ind(depth) + "end\n";
                    int self_exit = -1;
                    if (blk >= 0 && blk < (int)g->n.size()) {
                        const st::Node& sn = g->n[blk];
                        self_exit = (sn.succ_true == blk) ? sn.succ_false : sn.succ_true;
                    }
                    emit_escape_propagate(depth, self_exit);
                    break;
                }
                if (r.kind == sa::RK::NaturalLoop) {
                    // A branch inside the loop whose target leaves the loop IS a `break`. Emitting
                    // the parts sequentially drops it -- `for i=1,n do if i>3 then break end ... end`
                    // became an infinite `while true do ... end`, which the oracle caught as a
                    // TIMEOUT rather than a wrong value.
                    std::vector<int> bl; collect_blocks(id, bl);
                    std::set<int> save = loop_blocks;
                    loop_blocks.clear();
                    for (int b : bl) loop_blocks.insert(b);
                    // A NaturalLoop's `parts` are assembled from a set and are not a control-flow
                    // order. Luau also lays some loop preheaders before a rotated body/latch layout.
                    // JSON p11 is the minimal witness: region blocks {0..45}, but the authoritative
                    // cycle is {1..45}; block 0 enters header 1 and no body edge returns to block 0.
                    // Emitting set order [0,latch,body] inside `while true` rotates side effects on
                    // every round trip. Partition only when one unique largest authoritative loop
                    // body cleanly owns complete region parts and every outside part is proven to be
                    // a one-way preheader. Mixed parts or body-to-outside edges fail closed.
                    bool partition_natural_preheader = false;
                    int partition_header = -1;
                    std::set<int> partition_body;
                    std::set<int> partition_emitted_body;
                    std::vector<int> partition_pre_parts, partition_body_parts;
                    if (!std::getenv("RENOVICE_NO_NATURAL_PREHEADER_PARTITION")) {
                        size_t best_size = 0; int best_count = 0;
                        std::set<int> region_blocks(bl.begin(), bl.end());
                        for (int candidate : header_of_loop) {
                            std::set<int> body = natural_loop_body(candidate);
                            if (std::getenv("RENOVICE_LOOPTRACE"))
                                std::fprintf(stderr,
                                             "NATURAL_CANDIDATE pidx=%d region=%d candidate=%d "
                                             "body=%d region_blocks=%d\n",
                                             pidx, id, candidate, (int)body.size(),
                                             (int)region_blocks.size());
                            if (body.size() < 2 || body.size() >= region_blocks.size()) continue;
                            bool subset = true;
                            for (int block : body) if (!region_blocks.count(block)) subset = false;
                            if (!subset) continue;
                            if (body.size() > best_size) {
                                best_size = body.size(); best_count = 1;
                                partition_header = candidate; partition_body.swap(body);
                            } else if (body.size() == best_size) {
                                ++best_count;
                            }
                        }
                        bool exact_parts = best_count == 1 && partition_header >= 0;
                        for (int part : r.parts) {
                            std::vector<int> blocks; collect_blocks(part, blocks);
                            bool any_in = false;
                            for (int block : blocks) {
                                if (partition_body.count(block)) any_in = true;
                            }
                            if (blocks.empty()) { exact_parts = false; break; }
                            // A structured conditional part may mix cyclic-core blocks with terminal
                            // arms. It still belongs lexically inside the loop. Only a part with no
                            // core block at all is a preheader candidate.
                            if (any_in) {
                                partition_body_parts.push_back(part);
                                partition_emitted_body.insert(blocks.begin(), blocks.end());
                            }
                            else partition_pre_parts.push_back(part);
                        }
                        bool pre_enters_body = false, body_returns_to_pre = false;
                        std::set<int> pre_blocks;
                        for (int part : partition_pre_parts) {
                            std::vector<int> blocks; collect_blocks(part, blocks);
                            pre_blocks.insert(blocks.begin(), blocks.end());
                        }
                        for (int block : pre_blocks)
                            for (int successor : {g->n[block].succ_true, g->n[block].succ_false})
                                if (partition_body.count(successor)) pre_enters_body = true;
                        for (int block : partition_emitted_body)
                            for (int successor : {g->n[block].succ_true, g->n[block].succ_false})
                                if (pre_blocks.count(successor)) body_returns_to_pre = true;
                        int header_parts = 0;
                        for (int part : partition_body_parts) {
                            std::vector<int> blocks; collect_blocks(part, blocks);
                            if (std::find(blocks.begin(), blocks.end(), partition_header) != blocks.end())
                                ++header_parts;
                        }
                        partition_natural_preheader = exact_parts && !partition_pre_parts.empty()
                            && !partition_body_parts.empty() && pre_enters_body
                            && !body_returns_to_pre && header_parts == 1;
                        if (!partition_natural_preheader && std::getenv("RENOVICE_LOOPTRACE"))
                            std::fprintf(stderr,
                                         "NATURAL_PREHEADER_REJECT pidx=%d region=%d header=%d "
                                         "best=%d ties=%d exact=%d pre=%d bodyparts=%d enters=%d "
                                         "returns=%d headerparts=%d\n",
                                         pidx, id, partition_header, (int)best_size, best_count,
                                         exact_parts ? 1 : 0, (int)partition_pre_parts.size(),
                                         (int)partition_body_parts.size(), pre_enters_body ? 1 : 0,
                                         body_returns_to_pre ? 1 : 0, header_parts);
                        if (partition_natural_preheader) {
                            auto first_insn = [&](int part) {
                                std::vector<int> blocks; collect_blocks(part, blocks);
                                int first = INT_MAX;
                                for (int block : blocks) first = std::min(first, g->n[block].first);
                                return first;
                            };
                            std::stable_sort(partition_pre_parts.begin(), partition_pre_parts.end(),
                                             [&](int a, int b) { return first_insn(a) < first_insn(b); });
                            std::stable_sort(partition_body_parts.begin(), partition_body_parts.end(),
                                             [&](int a, int b) { return first_insn(a) < first_insn(b); });
                            std::vector<int> first_blocks;
                            collect_blocks(partition_body_parts.front(), first_blocks);
                            if (std::find(first_blocks.begin(), first_blocks.end(), partition_header)
                                == first_blocks.end())
                                partition_natural_preheader = false;
                        }
                        if (partition_natural_preheader && std::getenv("RENOVICE_LOOPTRACE"))
                            std::fprintf(stderr,
                                         "NATURAL_PREHEADER pidx=%d region=%d header=%d body=%d "
                                         "pre_parts=%d body_parts=%d\n",
                                         pidx, id, partition_header, (int)partition_body.size(),
                                         (int)partition_pre_parts.size(),
                                         (int)partition_body_parts.size());
                    }
                    // GyreOvercharged p15 / GyreSphere p16 expose a reducer blind spot: the
                    // authoritative forest contains a three-block, two-exit loop nested directly in
                    // an eight-block NaturalLoop, but the region tree flattens all eight blocks into
                    // Basic siblings.  Emitting those siblings in one outer wrapper deletes the inner
                    // back edge.  The second generic-for repair removes a false loop that happened to
                    // cancel this loss numerically, so both repairs must be evaluated atomically.
                    //
                    // Recover only the measured structural identity: five authoritative headers in
                    // the prototype; eight direct Basic blocks exactly equal to the outer natural-loop
                    // body; one proper nested three-block loop with one latch and two exits, both still
                    // inside the outer body; and one of those exits is the outer latch.  A selector is
                    // necessary because Luau has no labelled break: one inner exit resumes at the tail,
                    // while the other continues the enclosing loop.
                    bool emit_exact_nested_two_exit = false;
                    int nested_header = -1, nested_outer_latch_exit = -1;
                    std::set<int> nested_body, nested_exits;
                    if (enable_gyre_second_generic_nested
                        && header_of_loop.size() == 5 && bl.size() == 8
                        && r.parts.size() == 8)
                    {
                        bool direct_basic_partition = true;
                        std::set<int> direct_blocks;
                        for (int part : r.parts) {
                            if (part < 0 || part >= (int)A->regions.size()
                                || A->regions[part].kind != sa::RK::Basic) {
                                direct_basic_partition = false;
                                break;
                            }
                            direct_blocks.insert(A->regions[part].block);
                        }
                        std::set<int> outer_body = natural_loop_body(region_condition_block);
                        std::set<int> outer_latches;
                        for (int block : outer_body)
                            if (g->n[block].succ_true == region_condition_block
                                || g->n[block].succ_false == region_condition_block)
                                outer_latches.insert(block);
                        int matching_nested = 0;
                        if (direct_basic_partition && direct_blocks == outer_body
                            && outer_body.size() == 8 && outer_latches.size() == 1)
                        {
                            for (int candidate : header_of_loop) {
                                if (candidate == region_condition_block
                                    || !outer_body.count(candidate)) continue;
                                std::set<int> candidate_body = natural_loop_body(candidate);
                                if (candidate_body.size() != 3) continue;
                                bool contained = true;
                                for (int block : candidate_body)
                                    if (!outer_body.count(block)) contained = false;
                                if (!contained) continue;
                                int latch_count = 0;
                                for (int block : candidate_body)
                                    if (g->n[block].succ_true == candidate
                                        || g->n[block].succ_false == candidate)
                                        ++latch_count;
                                std::set<int> exits;
                                for (int block : candidate_body)
                                    for (int target : {g->n[block].succ_true, g->n[block].succ_false})
                                        if (target >= 0 && !candidate_body.count(target))
                                            exits.insert(target);
                                if (latch_count != 1 || exits.size() != 2) continue;
                                bool exits_stay_outer = true;
                                for (int target : exits)
                                    if (!outer_body.count(target)) exits_stay_outer = false;
                                int latch_exit = *outer_latches.begin();
                                if (!exits_stay_outer || !exits.count(latch_exit)) continue;
                                ++matching_nested;
                                nested_header = candidate;
                                nested_body.swap(candidate_body);
                                nested_exits.swap(exits);
                                nested_outer_latch_exit = latch_exit;
                            }
                        }
                        emit_exact_nested_two_exit = matching_nested == 1;
                    }
                    // A NaturalLoop that CONTAINS a for-latch IS the for-loop's iteration, already
                    // expressed by the enclosing `for` header. Wrapping it in a second `while true`
                    // would iterate twice over. Keep loop_blocks set either way, so a branch leaving
                    // the loop still becomes a `break` — which now breaks the `for`, as intended.
                    bool is_for_body = false;
                    for (int b : bl) if (is_for_latch(b)) { is_for_body = true; break; }
                    // Moving a preheader outside an already-open source `for` requires cooperation
                    // from that enclosing wrapper; do not perform the non-for partition here.
                    if (partition_natural_preheader && is_for_body)
                        partition_natural_preheader = false;
                    if (partition_natural_preheader) {
                        for (int part : partition_pre_parts) emit_region(part, depth);
                        loop_blocks = partition_emitted_body;
                    }
                    if (is_for_body) {
                        for (int p : r.parts) emit_region(p, depth);
                    } else if (emit_exact_nested_two_exit) {
                        out += ind(depth) + "while true do\n";
                        ++loop_depth;
                        bool nested_emitted = false;
                        for (int part : r.parts) {
                            int block = A->regions[part].block;
                            if (nested_body.count(block)) {
                                if (nested_emitted) continue;
                                nested_emitted = true;
                                EscapeContext ec;
                                ec.domain = nested_body;
                                ec.selector = "g" + std::to_string(id) + "_" +
                                              std::to_string(nested_header);
                                out += ind(depth + 1) + "local " + ec.selector + " = -1\n";
                                out += ind(depth + 1) + "while true do\n";
                                std::set<int> outer_scope = loop_blocks;
                                loop_blocks = nested_body;
                                ++loop_depth;
                                escape_stack.push_back(ec);
                                for (int nested_part : r.parts) {
                                    int nested_block = A->regions[nested_part].block;
                                    if (nested_body.count(nested_block))
                                        emit_region(nested_part, depth + 2);
                                }
                                escape_stack.pop_back();
                                --loop_depth;
                                loop_blocks = outer_scope;
                                out += ind(depth + 1) + "end\n";
                                out += ind(depth + 1) + "if " + ec.selector + " == "
                                     + std::to_string(nested_outer_latch_exit)
                                     + " then continue end\n";
                                continue;
                            }
                            emit_region(part, depth + 1);
                        }
                        --loop_depth;
                        out += ind(depth) + "end\n";
                    } else {
                        // `loop_depth` MUST be tracked across this wrapper. emit_block only emits a
                        // `break` when `loop_depth > 0`, so emitting `while true do` without raising it
                        // means every loop-exiting branch inside is SILENTLY DROPPED — the loop then
                        // spins forever. The While and SelfLoop arms already do this; NaturalLoop was
                        // the one wrapper that did not.
                        out += ind(depth) + "while true do\n";
                        ++loop_depth;
                        const std::vector<int>& loop_parts = partition_natural_preheader
                            ? partition_body_parts : r.parts;
                        for (int p : loop_parts) emit_region(p, depth + 1);
                        --loop_depth;
                        out += ind(depth) + "end\n";
                    }
                    loop_blocks = save;
                    std::set<int> natural_exits;
                    const std::set<int> exit_blocks = partition_natural_preheader
                        ? partition_emitted_body : std::set<int>(bl.begin(), bl.end());
                    for (int b : exit_blocks)
                        for (int s : {g->n[b].succ_true, g->n[b].succ_false})
                            if (s >= 0 && !exit_blocks.count(s)) natural_exits.insert(s);
                    emit_escape_propagate(depth,
                                          natural_exits.size() == 1 ? *natural_exits.begin() : -1);
                    break;
                }
                // NaturalLoop: exits live inside the body (as `return`, or a branch leaving the
                // region). No forced break — that would be the one-iteration bug again. If an exit was
                // not recovered this spins, which the oracle's timeout reports rather than hides.
                // loop_depth must be raised here for the same reason as the arm above: without it
                // emit_block suppresses every `break`, so a recoverable exit is thrown away and the
                // "spins forever" case is caused by US rather than by a genuinely unrecovered exit.
                out += ind(depth) + "while true do\n";
                ++loop_depth;
                for (int p : r.parts) emit_region(p, depth + 1);
                --loop_depth;
                out += ind(depth) + "end\n";
                emit_escape_propagate(depth);
                break;
            }
            case sa::RK::Proper: {
                // A Proper region is a single-entry ACYCLIC subgraph that matches no template (a DAG
                // with cross edges, e.g. `a and b or c` where two conditions share a join block).
                // Emitting its parts sequentially DROPS every branch — `a and b or c` decompiled to
                // `v3 = v1  v3 = v2  return v3`, straight-line code with the logic deleted.
                //
                // Emit a flag-guarded topological linearisation instead: each block sets the entry
                // flag of its successors, and every non-entry block runs under its own flag. This is
                // exact and needs NO block duplication. Because the region is acyclic and blocks are
                // numbered in code order, ascending index IS a topological order.
                std::vector<int> bl; collect_blocks(id, bl);
                std::sort(bl.begin(), bl.end());
                std::set<int> inreg(bl.begin(), bl.end());
                if (bl.size() < 2) { for (int p : r.parts) emit_region(p, depth); break; }
                // DIAGNOSTIC for FINDINGS #97/#98. `collect_blocks` above recurses through EVERY
                // child region kind, so a NaturalLoop/While/SelfLoop part is DISSOLVED into raw
                // blocks and its back edge becomes a backward `p<id> = N` in the flat ascending
                // chain -- which targets a guard already evaluated, silently dropping that path.
                // Dump the part structure so the replacement can be designed from data.
                if (std::getenv("RENOVICE_PROPERDBG")) {
                    auto kn = [](sa::RK k) {
                        switch (k) {
                            case sa::RK::Basic: return "Basic"; case sa::RK::Seq: return "Seq";
                            case sa::RK::IfThen: return "IfThen"; case sa::RK::IfThenElse: return "IfThenElse";
                            case sa::RK::SelfLoop: return "SelfLoop"; case sa::RK::While: return "While";
                            case sa::RK::NaturalLoop: return "NaturalLoop"; default: return "Proper";
                        }
                    };
                    fprintf(stderr, "PROPER region=%d parts=%d blocks=%d\n",
                            id, (int)r.parts.size(), (int)bl.size());
                    for (int p : r.parts) {
                        std::vector<int> pb; collect_blocks(p, pb);
                        std::set<int> ps(pb.begin(), pb.end());
                        // exits: one-step successors of this part that leave it
                        std::set<int> ex; bool cyc = false;
                        for (int b2 : pb) {
                            for (int s2 : {g->n[b2].succ_true, g->n[b2].succ_false}) {
                                if (s2 < 0) continue;
                                if (ps.count(s2)) { if (s2 <= b2) cyc = true; }
                                else ex.insert(s2);
                            }
                        }
                        fprintf(stderr, "   part=%-5d kind=%-12s head=%-5d nblocks=%-4d exits=%d%s targets=",
                                p, kn(A->regions[p].kind), head_block(p), (int)pb.size(),
                                (int)ex.size(), cyc ? "  <== CONTAINS A CYCLE" : "");
                        for (int x : ex) std::fprintf(stderr, "%d,", x);
                        std::fprintf(stderr, "\n");
                    }
                }
                // ONE state variable, not one boolean per block. Control follows exactly ONE path
                // through a DAG, so "which block are we in" is a single value — a flag per block blew
                // Luau's 200-LOCAL limit ("Out of local registers ... pN_N") on large regions.
                //
                // FINDINGS #97/#98 — WHOLE-PART STATES.
                // `collect_blocks` above flattens EVERY child region kind down to raw blocks. For an
                // ACYCLIC part that is harmless: ascending block index really is a topological order.
                // For a part containing a CYCLE it is fatal — the interior back edge resurfaces as a
                // backward `pv = N` targeting a guard already evaluated in this flat ascending chain,
                // so that path NEVER RUNS. 1,075 paths across 514 corpus files were lost this way.
                //
                // The structurer is not at fault: it proved the REGION-level graph acyclic
                // (`structan.h` rejects a candidate when `reaches(c, n)`), so at PART granularity a
                // backward transition cannot occur by construction. Emit such a part as ONE state via
                // `emit_region`, which preserves its `for`/`while` wrapper.
                //
                // Only parts that are provably safe to keep whole are promoted; everything else keeps
                // the previous per-block behaviour exactly. This can only remove dropped paths, never
                // introduce one.
                std::set<int> whole;                       // part ids emitted as a single state
                std::map<int, std::set<int>> part_exit;    // part id -> its out-of-part successors
                std::map<int, int> part_entry;             // part id -> its DERIVED entry block
                std::map<int, int> part_default_exit;      // normal completion when exits are plural
                const int region_entry = head_block(r.head >= 0 ? r.head : id);
                for (int p : r.parts) {
                    if (A->regions[p].kind == sa::RK::Basic) continue;
                    std::vector<int> pb; collect_blocks(p, pb);
                    if (pb.size() < 2) continue;
                    std::set<int> ps(pb.begin(), pb.end());
                    bool cyc = false; std::set<int> ex;
                    for (int b2 : pb)
                        for (int s2 : {g->n[b2].succ_true, g->n[b2].succ_false}) {
                            if (s2 < 0) continue;
                            if (ps.count(s2)) { if (s2 <= b2) cyc = true; }
                            else ex.insert(s2);
                        }
                    if (!cyc) continue;                    // acyclic: flattening is already correct
                    // Identify the normal fallthrough of a multi-exit loop. Conditional non-local
                    // exits are recorded at their source block; FOR latches are not boolean branches,
                    // so their false edge is the explicit normal-completion destination.
                    int default_exit = ex.size() == 1 ? *ex.begin() : -1;
                    std::set<int> normal_candidates;
                    bool all_exits_explicit = true;
                    for (int b2 : pb) {
                        const st::Node& bn = g->n[b2];
                        bool has_external = false;
                        for (int s2 : {bn.succ_true, bn.succ_false})
                            if (s2 >= 0 && !ps.count(s2)) has_external = true;
                        if (has_external && !renderable_cond(b2) && !bn.is_uncond
                            && !is_for_latch(b2))
                            all_exits_explicit = false;
                        if (is_for_latch(b2) && bn.succ_false >= 0 && !ps.count(bn.succ_false))
                            normal_candidates.insert(bn.succ_false);
                        if (bn.is_uncond) {
                            for (int s2 : {bn.succ_true, bn.succ_false})
                                if (s2 >= 0 && !ps.count(s2)) normal_candidates.insert(s2);
                        }
                    }
                    if (default_exit < 0 && normal_candidates.size() == 1)
                        default_exit = *normal_candidates.begin();
                    if (ex.size() > 1 && default_exit < 0 && !all_exits_explicit) {
                        if (std::getenv("RENOVICE_LOOPTRACE"))
                            std::fprintf(stderr,
                                         "WHOLE_REJECT pidx=%d proper=%d part=%d reason=ambiguous_exit "
                                         "blocks=%d exits=%d default=%d explicit=%d\n",
                                         pidx, id, p, (int)pb.size(), (int)ex.size(), default_exit,
                                         all_exits_explicit ? 1 : 0);
                        continue; // visible ambiguity: do not guess
                    }
                    // The earlier whole-part promotion proved that a terminal cyclic part with only
                    // zero/one exit can expose an internally misordered return. Keep that established
                    // safety boundary. Multi-exit terminal parts are the new case handled by the
                    // selector: every non-returning destination is recorded before control leaves.
                    int terminals = 0;
                    for (int b2 : pb)
                        if (g->n[b2].succ_true < 0 && g->n[b2].succ_false < 0) ++terminals;
                    if (terminals > 0 && ex.size() <= 1) {
                        if (std::getenv("RENOVICE_LOOPTRACE"))
                            std::fprintf(stderr,
                                         "WHOLE_REJECT pidx=%d proper=%d part=%d reason=terminal_single_exit "
                                         "blocks=%d exits=%d terminals=%d\n",
                                         pidx, id, p, (int)pb.size(), (int)ex.size(), terminals);
                        continue;
                    }
                    // Diagnostic hypothesis: a non-terminal cyclic shell can still be emitted whole
                    // when the selector records its conditional side exit and the for-latch gives one
                    // unambiguous normal-completion exit. FocusUtilities p6 is exactly this shape.
                    // Keep the production boundary until the focused and corpus A/B gates prove it.
                    bool approved_nested_shell = false;
                    if (!std::getenv("RENOVICE_NO_NESTED_FOR_PROMOTION")) {
                        for (int prep : A->nested_for_preps) {
                            if (!inreg.count(prep) || prep < 0 || prep >= (int)g->n.size()) continue;
                            auto known = prep2latch.find(prep);
                            if (known != prep2latch.end() && ps.count(known->second)
                                && ps.count(g->n[prep].succ_false)) {
                                approved_nested_shell = true; break;
                            }
                        }
                    }
                    // GyrePulse p22 diagnostic family: the Proper child contains one complete
                    // generic-for and a post-loop conditional with two explicit destinations, one
                    // of which is a terminal return. Flattening that child turns the FORGLOOP back
                    // edges into already-passed dispatcher states and removes the loop entirely.
                    // Keep this flag-only until focused identity and complete-corpus Pareto gates
                    // prove that promoting the whole child is safe.
                    bool approved_generic_two_exit = false;
                    if (enable_proper_generic_two_exit
                        && header_of_loop.size() == 1
                        && terminals == 0 && ex.size() == 2 && all_exits_explicit) {
                        int authoritative_headers = 0;
                        for (int header : header_of_loop)
                            if (ps.count(header)) ++authoritative_headers;
                        int complete_generic_pairs = 0;
                        for (const auto& prep_latch : prep2latch) {
                            int prep = prep_latch.first, latch = prep_latch.second;
                            if (!ps.count(prep) || !ps.count(latch)
                                || latch < 0 || latch >= (int)g->n.size())
                                continue;
                            int latch_insn = g->n[latch].last;
                            if (latch_insn < 0 || latch_insn >= (int)ip->code.size()
                                || ip->code[latch_insn].op != 0x1e) continue;
                            auto identity = block2loop.find(latch);
                            if (identity != block2loop.end() && ps.count(identity->second))
                                ++complete_generic_pairs;
                        }
                        int terminal_destinations = 0;
                        for (int target : ex)
                            if (target >= 0 && target < (int)g->n.size()
                                && g->n[target].succ_true < 0
                                && g->n[target].succ_false < 0)
                                ++terminal_destinations;
                        approved_generic_two_exit = authoritative_headers == 1
                            && complete_generic_pairs == 1 && terminal_destinations == 1;
                        if (approved_generic_two_exit && std::getenv("RENOVICE_ESCDBG"))
                            std::fprintf(stderr,
                                         "ESC_PROMOTE_GENERIC_TWO_EXIT pidx=%d proper=%d part=%d "
                                         "blocks=%d exits=%d\n",
                                         pidx, id, p, (int)pb.size(), (int)ex.size());
                    }
                    // Diagnostic family for a source-for split INSIDE one cyclic Proper child:
                    // the PREP is the child's unique external entry while the authoritative body
                    // and latch are nested below it. Flattening this child makes the latch jump to
                    // an already-visited dispatcher state, so the loop disappears. Promote only a
                    // single complete LoopId whose PREP is the proven entry; multi-loop shells and
                    // partial bodies remain rejected.
                    bool approved_split_for_shell = false;
                    int split_for_prep = -1;
                    if (enable_split_for_whole_part) {
                        std::set<int> external_entries;
                        for (int outside : bl) {
                            if (ps.count(outside)) continue;
                            for (int target : {g->n[outside].succ_true, g->n[outside].succ_false})
                                if (target >= 0 && ps.count(target)) external_entries.insert(target);
                        }
                        if (ps.count(region_entry)) external_entries.insert(region_entry);
                        int complete_pairs = 0;
                        for (const auto& prep_latch : prep2latch) {
                            const int prep = prep_latch.first;
                            const int latch = prep_latch.second;
                            if (!ps.count(prep) || !ps.count(latch)) continue;
                            auto identity = block2loop.find(prep);
                            if (identity == block2loop.end()) continue;
                            auto body = authoritative_loop_bodies.find(identity->second);
                            if (body == authoritative_loop_bodies.end()) continue;
                            bool complete_body = true;
                            for (int block : body->second)
                                if (!ps.count(block)) { complete_body = false; break; }
                            if (!complete_body) continue;
                            if (external_entries.size() == 1
                                && *external_entries.begin() == prep) {
                                ++complete_pairs;
                                split_for_prep = prep;
                            }
                        }
                        const bool split_for_numeric = split_for_prep >= 0
                            && ip->code[g->n[split_for_prep].last].op == 0x47;
                        // The broad complete-pair predicate exposed interactions in prototypes with
                        // four or more authoritative loops. Keep the numeric form (whose PREP/latch
                        // ownership is unambiguous) and small generic forests only; certify this
                        // refinement independently before making it the default.
                        approved_split_for_shell = complete_pairs == 1
                            && (split_for_numeric || header_of_loop.size() <= 3);
                        if (approved_split_for_shell && std::getenv("RENOVICE_LOOPTRACE"))
                            std::fprintf(stderr,
                                         "WHOLE_APPROVE_SPLIT_FOR pidx=%d proper=%d part=%d "
                                         "blocks=%d exits=%d loops=%d prep=%d prep_op=0x%02x kind=%s\n",
                                         pidx, id, p, (int)pb.size(), (int)ex.size(),
                                         (int)header_of_loop.size(), split_for_prep,
                                         split_for_prep >= 0
                                             ? (int)ip->code[g->n[split_for_prep].last].op : -1,
                                         rk_name(A->regions[p].kind));
                    }
                    // Corpus-wide generic counterpart to the numeric split-shell repair. Search
                    // this cyclic child recursively for one exact Seq partition:
                    //   Basic(FORGPREP) ; While(authoritative body + latch)
                    // The enclosing child must be safe for the existing escape selector. Record the
                    // LoopId here so the nested Seq emitter cannot activate independently elsewhere.
                    bool approved_seq_generic_split = false;
                    if (enable_seq_generic_for_coalesce) {
                        std::set<int> split_headers;
                        std::function<void(int)> find_split = [&](int region) {
                            if (region < 0 || region >= (int)A->regions.size()) return;
                            const sa::Region& candidate = A->regions[region];
                            if (candidate.kind == sa::RK::Seq) {
                                for (size_t part_index = 0;
                                     part_index + 1 < candidate.parts.size(); ++part_index) {
                                    const int left = candidate.parts[part_index];
                                    const int right = candidate.parts[part_index + 1];
                                    if (A->regions[left].kind != sa::RK::Basic
                                        || A->regions[right].kind != sa::RK::While)
                                        continue;
                                    std::vector<int> left_vector, right_vector;
                                    collect_blocks(left, left_vector);
                                    collect_blocks(right, right_vector);
                                    if (left_vector.size() != 1) continue;
                                    const int prep = left_vector.front();
                                    if (prep < 0 || prep >= (int)g->n.size()) continue;
                                    const int instruction = g->n[prep].last;
                                    if (instruction < 0 || instruction >= (int)ip->code.size())
                                        continue;
                                    const int opcode = ip->code[instruction].op;
                                    if (opcode != 0x0b && opcode != 0x30 && opcode != 0x1b)
                                        continue;
                                    auto identity = block2loop.find(prep);
                                    auto paired = prep2latch.find(prep);
                                    if (identity == block2loop.end() || paired == prep2latch.end())
                                        continue;
                                    auto body = authoritative_loop_bodies.find(identity->second);
                                    if (body == authoritative_loop_bodies.end()) continue;
                                    const std::set<int> right_blocks(right_vector.begin(),
                                                                     right_vector.end());
                                    if (right_blocks != body->second
                                        || !right_blocks.count(paired->second))
                                        continue;
                                    bool root_loop = true;
                                    for (const auto& possible_parent : authoritative_loop_bodies) {
                                        if (possible_parent.first == identity->second
                                            || possible_parent.second.size() <= body->second.size())
                                            continue;
                                        bool contains = true;
                                        for (int block : body->second)
                                            if (!possible_parent.second.count(block)) {
                                                contains = false; break;
                                            }
                                        if (contains) { root_loop = false; break; }
                                    }
                                    if (root_loop) split_headers.insert(identity->second);
                                }
                            }
                            for (int child : candidate.parts) find_split(child);
                        };
                        find_split(p);
                        // The exact missing-owner witnesses are two-exit dispatchers. A one-exit
                        // child can already be emitted by the normal ownership path; opting it into
                        // this repair duplicated an otherwise exact InkBalloon loop.
                        const bool selector_safe = terminals == 0 && ex.size() == 2
                            && all_exits_explicit;
                        // In a loop forest, promoting the containing dispatcher also changes the
                        // ownership and nesting of sibling loops. The broad corpus probe produced
                        // 22 identity regressions that way. Keep this first certified family to a
                        // prototype whose one authoritative LoopId is exactly the split candidate.
                        if (header_of_loop.size() == 1 && split_headers.size() == 1
                            && selector_safe) {
                            approved_seq_generic_split_headers.insert(*split_headers.begin());
                            approved_seq_generic_split = true;
                            if (std::getenv("RENOVICE_LOOPTRACE"))
                                std::fprintf(stderr,
                                             "WHOLE_APPROVE_SEQ_GENERIC pidx=%d proper=%d "
                                             "part=%d header=%d blocks=%d exits=%d emit_owner=%d\n",
                                             pidx, id, p, *split_headers.begin(),
                                             (int)pb.size(), (int)ex.size(),
                                             own_emit.count(*split_headers.begin())
                                                 ? own_emit.at(*split_headers.begin()) : -1);
                        }
                    }
                    if (terminals == 0 && ex.size() > 1
                        && !approved_nested_shell && !approved_generic_two_exit
                        && !approved_split_for_shell && !approved_seq_generic_split) {
                        if (std::getenv("RENOVICE_LOOPTRACE"))
                            std::fprintf(stderr,
                                         "WHOLE_REJECT pidx=%d proper=%d part=%d reason=unapproved_multi_exit "
                                         "blocks=%d exits=%d nested_shell=%d generic_two_exit=%d "
                                         "split_for=%d\n",
                                         pidx, id, p, (int)pb.size(), (int)ex.size(),
                                         approved_nested_shell ? 1 : 0,
                                         approved_generic_two_exit ? 1 : 0,
                                         approved_split_for_shell ? 1 : 0);
                        continue;
                    }
                    // ENTRY BLOCK, DERIVED — NOT `head_block(p)`.
                    // `head_block` returns `parts[0]`, but NaturalLoop/Proper build `parts` from a
                    // std::set, so parts[0] is the lowest REGION ID, not the entry. Keying a state on
                    // that block sends the transition to a guard that never matches and the path is
                    // lost — measured: it cost 2 accesses in Lotus_Interface_Components_DecoPreview.
                    // Derive it instead: the entry is the unique block of the part reachable from
                    // outside it. If that is not unique, one state cannot represent the part; skip.
                    std::set<int> entries;
                    for (int b2 : bl) {
                        if (ps.count(b2)) continue;        // edges from inside the part are fine
                        for (int s2 : {g->n[b2].succ_true, g->n[b2].succ_false})
                            if (s2 >= 0 && ps.count(s2)) entries.insert(s2);
                    }
                    if (ps.count(region_entry)) entries.insert(region_entry);
                    if (entries.size() != 1) {
                        if (std::getenv("RENOVICE_LOOPTRACE"))
                            std::fprintf(stderr,
                                         "WHOLE_REJECT pidx=%d proper=%d part=%d reason=entry_count "
                                         "blocks=%d entries=%d\n",
                                         pidx, id, p, (int)pb.size(), (int)entries.size());
                        continue;
                    }
                    whole.insert(p);
                    part_entry[p] = *entries.begin();
                    part_exit[p] = ex;
                    part_default_exit[p] = default_exit;
                    if (std::getenv("RENOVICE_ESCDBG") && ex.size() > 1)
                        std::fprintf(stderr,
                                     "ESC_PROMOTE pidx=%d proper=%d part=%d blocks=%d exits=%d "
                                     "terminals=%d default=%d explicit=%d\n",
                                     pidx, id, p, (int)pb.size(), (int)ex.size(), terminals,
                                     default_exit, all_exits_explicit ? 1 : 0);
                }
                // State list: one entry per whole part (keyed by its head block) plus every block not
                // covered by one. Sorted ascending, so the ordering argument is unchanged.
                std::set<int> covered;
                for (int p : whole) { std::vector<int> pb; collect_blocks(p, pb); covered.insert(pb.begin(), pb.end()); }
                std::map<int, int> state_part;             // state key (block id) -> part id, if whole
                std::map<int, int> state_prep;             // coalesced numeric prep -> cyclic shell
                std::map<int, int> part_state_key;
                for (int p : whole) part_state_key[p] = part_entry[p];
                if (!std::getenv("RENOVICE_NO_NESTED_FOR_COALESCE")) {
                    for (int p : whole) {
                        std::vector<int> pb; collect_blocks(p, pb);
                        std::set<int> ps(pb.begin(), pb.end());
                        for (int candidate : bl) {
                            if (covered.count(candidate) || candidate < 0
                                || candidate >= (int)g->n.size()) continue;
                            int li = g->n[candidate].last;
                            if (li < 0 || li >= (int)ip->code.size()
                                || ip->code[li].op != 0x47) continue;
                            if (!A->nested_for_preps.count(candidate)) continue;
                            if (g->n[candidate].succ_false != part_entry[p]) continue;
                            auto loop = prep2latch.find(candidate);
                            if (loop == prep2latch.end() || !ps.count(loop->second)) continue;
                            part_state_key[p] = candidate;
                            state_prep[candidate] = candidate;
                            if (std::getenv("RENOVICE_LOOPTRACE"))
                                std::fprintf(stderr,
                                             "COALESCE_FOR pidx=%d proper=%d prep=%d part=%d "
                                             "entry=%d latch=%d\n",
                                             pidx, id, candidate, p, part_entry[p], loop->second);
                            break;
                        }
                    }
                }
                std::vector<int> states;
                for (int p : whole) {
                    int key = part_state_key[p]; states.push_back(key); state_part[key] = p;
                }
                for (int b2 : bl)
                    if (!covered.count(b2) && !state_prep.count(b2)) states.push_back(b2);
                std::sort(states.begin(), states.end());
                auto st_of = [&](int s2) {
                    if (s2 < 0) return s2;
                    for (int p : whole) {
                        std::vector<int> pb; collect_blocks(p, pb);
                        if (std::find(pb.begin(), pb.end(), s2) != pb.end()) return part_state_key[p];
                    }
                    return s2;
                };
                // A Proper region is usually a DAG, but after whole-child promotion its remaining
                // state graph can still contain a cycle spanning several parts. The old ascending
                // chain executes each guard once, so `state 2 -> state 1` assigns a guard that has
                // already run and silently drops the path. Partition the EXACT graph this emitter
                // will write into SCCs. Only a genuinely cyclic SCC gets repeated dispatch; acyclic
                // states retain the established one-pass layout.
                std::set<int> state_set(states.begin(), states.end());
                std::map<int, std::set<int>> state_succ;
                for (int b2 : states) {
                    if (state_part.count(b2)) {
                        for (int t : part_exit[state_part[b2]]) {
                            int st = st_of(t);
                            if (state_set.count(st)) state_succ[b2].insert(st);
                        }
                        continue;
                    }
                    const st::Node& bn = g->n[b2];
                    int ts = st_of(bn.succ_true), fs = st_of(bn.succ_false);
                    bool ti = state_set.count(ts), fi = state_set.count(fs);
                    if (renderable_cond(b2)) {
                        if (ti) state_succ[b2].insert(ts);
                        if (fi) state_succ[b2].insert(fs);
                    } else if (fi) {
                        state_succ[b2].insert(fs);           // mirrors the emitter's fallthrough rule
                    } else if (ti) {
                        state_succ[b2].insert(ts);
                    }
                }
                auto state_reaches = [&](int from, int target) {
                    std::set<int> seen; std::vector<int> todo{from};
                    while (!todo.empty()) {
                        int x = todo.back(); todo.pop_back();
                        if (!seen.insert(x).second) continue;
                        for (int s : state_succ[x]) {
                            if (s == target) return true;
                            if (!seen.count(s)) todo.push_back(s);
                        }
                    }
                    return from == target;
                };
                std::map<int, std::set<int>> cyclic_scc;     // state -> its cyclic component
                std::set<int> classified;
                for (int seed : states) {
                    if (classified.count(seed)) continue;
                    std::set<int> comp;
                    for (int candidate : states)
                        if (state_reaches(seed, candidate) && state_reaches(candidate, seed))
                            comp.insert(candidate);
                    classified.insert(comp.begin(), comp.end());
                    bool cyclic = comp.size() > 1 || state_succ[seed].count(seed);
                    if (cyclic) {
                        for (int member : comp) cyclic_scc[member] = comp;
                        if (std::getenv("RENOVICE_SCCDBG")) {
                            std::fprintf(stderr, "SCC_PROMOTE pidx=%d proper=%d states=", pidx, id);
                            for (int member : comp) std::fprintf(stderr, "%d,", member);
                            std::fprintf(stderr, "\n");
                        }
                    }
                }
                // Emit the SCC condensation DAG in topological order. Block numbers are source
                // layout, not a topological guarantee: Background p164 has an acyclic 23 -> 12 edge,
                // so ascending guards still drop it even though no repeated dispatch is required.
                // Condensation gives one node per cyclic component and one per acyclic state.
                std::vector<std::set<int>> groups;
                std::map<int, int> group_of;
                for (int state : states) {
                    if (group_of.count(state)) continue;
                    std::set<int> group = cyclic_scc.count(state)
                        ? cyclic_scc[state] : std::set<int>{state};
                    int gi = (int)groups.size();
                    groups.push_back(group);
                    for (int member : group) group_of[member] = gi;
                }
                std::vector<std::set<int>> group_succ(groups.size());
                std::vector<int> indegree(groups.size(), 0);
                for (int state : states) {
                    int from = group_of[state];
                    for (int target : state_succ[state]) {
                        int to = group_of[target];
                        if (from != to && group_succ[from].insert(to).second) ++indegree[to];
                    }
                }
                std::set<std::pair<int, int>> ready;       // stable: lowest member, then group id
                for (int gi = 0; gi < (int)groups.size(); ++gi)
                    if (indegree[gi] == 0) ready.insert({*groups[gi].begin(), gi});
                std::vector<int> group_order;
                while (!ready.empty()) {
                    int gi = ready.begin()->second;
                    ready.erase(ready.begin());
                    group_order.push_back(gi);
                    for (int to : group_succ[gi])
                        if (--indegree[to] == 0) ready.insert({*groups[to].begin(), to});
                }
                if (group_order.size() != groups.size())
                    throw std::runtime_error("Proper SCC condensation unexpectedly remained cyclic");
                // Diagnostic A/B control: restore the accepted pre-SCC numeric one-pass dispatcher.
                // This remains environment-gated and is used only to attribute corpus metric changes.
                const bool disable_scc_dispatch = std::getenv("RENOVICE_NO_SCCDISPATCH") != nullptr;
                if (disable_scc_dispatch) {
                    groups.clear(); group_of.clear(); group_order.clear();
                    for (int state : states) {
                        group_of[state] = (int)groups.size();
                        groups.push_back({state});
                        group_order.push_back((int)group_order.size());
                    }
                }
                std::string pv = "p" + std::to_string(id);
                int initial_state = st_of(region_entry);
                if (disable_scc_dispatch || !state_set.count(initial_state))
                    initial_state = states.empty() ? bl[0] : states[0];
                out += ind(depth) + "local " + pv + " = " + std::to_string(initial_state) + "\n";
                auto emit_state = [&](int b2, int guard_depth) {
                    int d2 = guard_depth + 1;
                    out += ind(guard_depth) + "if " + pv + " == " + std::to_string(b2) + " then\n";
                    // WHOLE-PART state: emit the child region intact, then take its single exit.
                    if (state_part.count(b2)) {
                        int p = state_part[b2];
                        std::vector<int> pb; collect_blocks(p, pb);
                        EscapeContext ec;
                        ec.domain.insert(pb.begin(), pb.end());
                        ec.selector = "e" + std::to_string(id) + "_" + std::to_string(p);
                        int default_exit = part_default_exit[p];
                        const std::set<int>& ex = part_exit[p];
                        if (state_prep.count(b2)) {
                            std::string hdr;
                            if (!for_header(state_prep[b2], hdr))
                                throw std::runtime_error("coalesced FORNPREP lost its header");
                            out += ind(d2) + "local " + ec.selector + " = -1\n";
                            emit_block(state_prep[b2], d2);
                            out += ind(d2) + hdr + "\n";
                            std::set<int> saved_blocks = loop_blocks;
                            loop_blocks.clear(); loop_blocks.insert(pb.begin(), pb.end());
                            ++loop_depth; escape_stack.push_back(ec);
                            emit_region(p, d2 + 1);
                            escape_stack.pop_back(); --loop_depth; loop_blocks = saved_blocks;
                            out += ind(d2) + "end\n";
                            if (default_exit >= 0)
                                out += ind(d2) + "if " + ec.selector + " == -1 then " + ec.selector
                                     + " = " + std::to_string(default_exit) + " end\n";
                            bool first_exit = true;
                            for (int t : ex) {
                                out += ind(d2) + std::string(first_exit ? "if " : "elseif ")
                                     + ec.selector + " == " + std::to_string(t) + " then\n";
                                int state_target = st_of(t);
                                if (inreg.count(t))
                                    out += ind(d2 + 1) + pv + " = " + std::to_string(state_target) + "\n";
                                first_exit = false;
                            }
                            if (!first_exit) out += ind(d2) + "end\n";
                        } else if (ex.size() <= 1) {
                            emit_region(p, d2);
                            if (!ex.empty()) {
                                int t = *ex.begin();
                                int state_target = st_of(t);
                                if (inreg.count(t))
                                    out += ind(d2) + pv + " = " + std::to_string(state_target) + "\n";
                            }
                        } else {
                            out += ind(d2) + "local " + ec.selector + " = -1\n";
                            out += ind(d2) + "repeat\n";
                            escape_stack.push_back(ec);
                            emit_region(p, d2 + 1);
                            escape_stack.pop_back();
                            if (default_exit >= 0)
                                out += ind(d2 + 1) + "if " + ec.selector + " == -1 then " + ec.selector
                                     + " = " + std::to_string(default_exit) + " end\n";
                            out += ind(d2 + 1) + "break\n";
                            out += ind(d2) + "until true\n";
                            bool first_exit = true;
                            for (int t : ex) {
                                out += ind(d2) + std::string(first_exit ? "if " : "elseif ")
                                     + ec.selector + " == " + std::to_string(t) + " then\n";
                                int state_target = st_of(t);
                                if (inreg.count(t))
                                    out += ind(d2 + 1) + pv + " = " + std::to_string(state_target) + "\n";
                                first_exit = false;
                            }
                            if (!first_exit) out += ind(d2) + "end\n";
                        }
                        out += ind(guard_depth) + "end\n";
                        return;
                    }
                    emit_block(b2, d2);
                    const st::Node& bn = g->n[b2];
                    int s_true = st_of(bn.succ_true), s_false = st_of(bn.succ_false);
                    bool t_in = s_true  >= 0 && inreg.count(s_true);
                    bool f_in = s_false >= 0 && inreg.count(s_false);
                    // A for-LATCH (FORNLOOP 0x0a / FORGLOOP 0x1e) has NO boolean condition: its back
                    // edge was already consumed by the enclosing loop region, so inside this ACYCLIC
                    // region it merely falls through.
                    bool cond_ok = renderable_cond(b2);
                    if (cond_ok && (t_in || f_in)) {
                        out += ind(d2) + "if " + cond_of(b2, false) + " then\n";
                        if (t_in) out += ind(d2 + 1) + pv + " = " + std::to_string(s_true) + "\n";
                        out += ind(d2) + "else\n";
                        if (f_in) out += ind(d2 + 1) + pv + " = " + std::to_string(s_false) + "\n";
                        out += ind(d2) + "end\n";
                    } else {
                        if (f_in)      out += ind(d2) + pv + " = " + std::to_string(s_false) + "\n";
                        else if (t_in) out += ind(d2) + pv + " = " + std::to_string(s_true) + "\n";
                    }
                    out += ind(guard_depth) + "end\n";
                };
                for (int gi : group_order) {
                    const std::set<int>& comp = groups[gi];
                    bool cyclic = comp.size() > 1
                        || (comp.size() == 1 && state_succ[*comp.begin()].count(*comp.begin()));
                    if (!cyclic) {
                        emit_state(*comp.begin(), depth);
                        continue;
                    }
                    out += ind(depth) + "while ";
                    bool first = true;
                    for (int member : comp) {
                        if (!first) out += " or ";
                        out += pv + " == " + std::to_string(member);
                        first = false;
                    }
                    out += " do\n";
                    for (int member : comp) emit_state(member, depth + 1);
                    out += ind(depth) + "end\n";
                }
                break;
            }
            default:
                deadtail_dbg(id);
                for (int p : r.parts) emit_region(p, depth);
                break;
        }
    }

    struct RegToken { size_t first = 0, last = 0; int reg = -1; };

    // Find generated register identifiers without touching recovered string contents or comments.
    // The old declaration scan was textual and could mistake a literal such as "v123" for a local;
    // register allocation must never rewrite user data.
    static std::vector<RegToken> reg_tokens(const std::string& text) {
        std::vector<RegToken> tokens;
        size_t i = 0;
        while (i < text.size()) {
            if (text[i] == '\'' || text[i] == '"') {
                char quote = text[i++];
                while (i < text.size()) {
                    if (text[i] == '\\' && i + 1 < text.size()) { i += 2; continue; }
                    if (text[i++] == quote) break;
                }
                continue;
            }
            if (i + 1 < text.size() && text[i] == '-' && text[i + 1] == '-') {
                if (i + 3 < text.size() && text[i + 2] == '[' && text[i + 3] == '[') {
                    size_t end = text.find("]]", i + 4);
                    i = end == std::string::npos ? text.size() : end + 2;
                } else {
                    size_t end = text.find('\n', i + 2);
                    i = end == std::string::npos ? text.size() : end + 1;
                }
                continue;
            }
            if (i + 1 < text.size() && text[i] == '[' && text[i + 1] == '[') {
                size_t end = text.find("]]", i + 2);
                i = end == std::string::npos ? text.size() : end + 2;
                continue;
            }
            if (text[i] == 'v' && i + 1 < text.size()
                && std::isdigit((unsigned char)text[i + 1])
                && !(i && (std::isalnum((unsigned char)text[i - 1]) || text[i - 1] == '_'))) {
                size_t j = i + 1; int reg = 0;
                while (j < text.size() && std::isdigit((unsigned char)text[j])) {
                    reg = reg * 10 + (text[j] - '0'); ++j;
                }
                if (!(j < text.size() && (std::isalnum((unsigned char)text[j]) || text[j] == '_'))) {
                    tokens.push_back({i, j, reg}); i = j; continue;
                }
            }
            ++i;
        }
        return tokens;
    }

    // Compatibility wrapper for the shared analysis. Unknown shapes continue to fail closed.
    bool reg_effects(const ir::IInsn& in, std::set<int>& uses, std::set<int>& defs) const {
        return lv::register_effects(*ip, in, uses, defs);
    }

    std::map<int, int> allocate_registers(const std::string& body,
                                          const std::set<int>& used) const {
        const int mx = ip->maxstack;
        std::vector<std::set<int>> adj((size_t)std::max(0, mx));
        lv::Analysis liveness = lv::analyze(*ip, *g);
        if (!liveness.known || !liveness.converged) return {};

        auto interfere = [&](int a, int b) {
            if (a == b || a < ip->nparams || b < ip->nparams || a >= mx || b >= mx) return;
            adj[a].insert(b); adj[b].insert(a);
        };
        for (size_t b = 0; b < g->n.size(); ++b) {
            if (!g->n[b].reach) continue;
            std::set<int> live = liveness.live_out[b];
            for (int i = g->n[b].last; i >= g->n[b].first && i >= 0; --i) {
                std::set<int> uses, defs;
                reg_effects(ip->code[i], uses, defs);
                for (int def : defs) for (int other : live) interfere(def, other);
                for (int def : defs) live.erase(def);
                live.insert(uses.begin(), uses.end());
            }
        }

        // Also require non-overlapping appearances in the emitted source. This makes allocation
        // conservative when region emission reorders blocks relative to bytecode instruction order.
        std::map<int, std::pair<size_t, size_t>> span;
        for (const RegToken& token : reg_tokens(body)) {
            auto it = span.find(token.reg);
            if (it == span.end()) span[token.reg] = {token.first, token.last};
            else it->second.second = token.last;
        }
        std::vector<int> locals;
        for (int reg : used) if (reg >= ip->nparams && reg < mx) locals.push_back(reg);
        for (size_t i = 0; i < locals.size(); ++i) for (size_t j = i + 1; j < locals.size(); ++j) {
            auto a = span.find(locals[i]), b = span.find(locals[j]);
            if (a == span.end() || b == span.end()) continue;
            bool overlap = !(a->second.second < b->second.first || b->second.second < a->second.first);
            if (overlap) interfere(locals[i], locals[j]);
        }

        // Luau source captures a local by reference even when DE's CAPTURE mode copied by value.
        // Until the emitter can spell by-value captures explicitly, every captured register must
        // retain a unique function-lifetime name.
        std::set<int> captured;
        for (const ir::IInsn& in : ip->code)
            if (in.op == 0x35 && in.A != 2 && in.B >= ip->nparams) captured.insert(in.B);
        for (int cap : captured) for (int reg : locals) interfere(cap, reg);

        // Deterministic DSATUR coloring: saturation, then degree, then smallest original register.
        std::map<int, int> color;
        while (color.size() < locals.size()) {
            int pick = -1, pick_sat = -1, pick_degree = -1;
            for (int reg : locals) {
                if (color.count(reg)) continue;
                std::set<int> neighbor_colors;
                for (int n : adj[reg]) { auto it = color.find(n); if (it != color.end()) neighbor_colors.insert(it->second); }
                int sat = (int)neighbor_colors.size(), degree = (int)adj[reg].size();
                if (sat > pick_sat || (sat == pick_sat && degree > pick_degree)
                    || (sat == pick_sat && degree == pick_degree && (pick < 0 || reg < pick))) {
                    pick = reg; pick_sat = sat; pick_degree = degree;
                }
            }
            std::set<int> forbidden;
            for (int n : adj[pick]) { auto it = color.find(n); if (it != color.end()) forbidden.insert(it->second); }
            int chosen = 0; while (forbidden.count(chosen)) ++chosen;
            color[pick] = chosen;
        }

        std::map<int, int> names;
        int max_color = -1;
        for (const auto& pair : color) {
            names[pair.first] = ip->nparams + pair.second;
            max_color = std::max(max_color, pair.second);
        }
        if (std::getenv("RENOVICE_LIVERANGEDBG"))
            std::fprintf(stderr, "LIVERANGE used=%d colors=%d captured=%d maxstack=%d\n",
                         (int)locals.size(), max_color + 1, (int)captured.size(), mx);
        return names;
    }

    static std::string rewrite_registers(const std::string& body,
                                         const std::map<int, int>& names) {
        std::vector<RegToken> tokens = reg_tokens(body);
        std::string rewritten; size_t cursor = 0;
        for (const RegToken& token : tokens) {
            rewritten += body.substr(cursor, token.first - cursor);
            auto it = names.find(token.reg);
            if (it == names.end()) rewritten += body.substr(token.first, token.last - token.first);
            else rewritten += "v" + std::to_string(it->second);
            cursor = token.last;
        }
        rewritten += body.substr(cursor);
        return rewritten;
    }

    // Turn a generated dispatch-state register's first, unconditional top-level assignment into
    // its declaration:
    //
    //     local v7              local v7 = rhs
    //     v7 = rhs      ->
    //
    // This is binding-equivalent but avoids the entry LOADNIL generated for the split spelling.
    // Fail closed unless the assignment is at function depth one, is the register's first textual
    // occurrence, and its RHS does not read the same register (whose initializer has different Lua
    // scope rules). Returns the registers removed from the flat declaration header.
    static std::set<int> localize_dispatch_state_definitions(std::string& body) {
        std::set<int> localized, seen;
        std::string rewritten;
        size_t pos = 0;
        while (pos < body.size()) {
            size_t end = body.find('\n', pos);
            if (end == std::string::npos) end = body.size();
            std::string line = body.substr(pos, end - pos);
            std::vector<RegToken> tokens = reg_tokens(line);
            size_t indent = 0;
            while (indent < line.size() && line[indent] == ' ') ++indent;
            bool candidate = indent == 2 && indent + 4 <= line.size()
                          && line[indent] == 'v'
                          && std::isdigit((unsigned char)line[indent + 1])
                          && !tokens.empty() && tokens.front().first == indent;
            int reg = candidate ? tokens.front().reg : -1;
            size_t after = candidate ? tokens.front().last : 0;
            candidate = candidate && after + 3 <= line.size()
                     && line.compare(after, 3, " = ") == 0 && !seen.count(reg);
            // Do not generalize this to ordinary entry definitions. That experiment reduced total
            // drift but destabilized previously fixed scripts by changing Luau's allocation of many
            // unrelated locals. A recompiled Proper/state fallback has this unmistakable repeated
            // `if vN == state` shape; require at least two state tests before touching the binding.
            if (candidate) {
                const std::string state_test = "if v" + std::to_string(reg) + " == ";
                int tests = 0;
                for (size_t q = 0; (q = body.find(state_test, q)) != std::string::npos;
                     q += state_test.size())
                    ++tests;
                candidate = tests >= 2;
            }
            for (size_t q = 1; candidate && q < tokens.size(); ++q)
                if (tokens[q].reg == reg) candidate = false;
            if (candidate) {
                line.insert(indent, "local ");
                localized.insert(reg);
            }
            for (const RegToken& token : tokens) seen.insert(token.reg);
            rewritten += line;
            if (end < body.size()) rewritten += '\n';
            pos = end + (end < body.size() ? 1 : 0);
        }
        body.swap(rewritten);
        return localized;
    }

    // Registers introduced by a source `for` header are already lexical locals. Exclude one from
    // the flat function declaration only when its complete textual lifetime is owned by that loop:
    // no earlier occurrence, no self-read in the iterator/limit expressions, and no occurrence after
    // the matching indentation-level `end`. This deliberately rejects `for v7 = v7, ...` because
    // the RHS needs the outer binding even though the loop body gets a new local v7.
    static std::set<int> lexical_for_variables(const std::string& body) {
        std::set<int> result;
        size_t pos = 0;
        while (pos < body.size()) {
            size_t end = body.find('\n', pos);
            if (end == std::string::npos) end = body.size();
            std::string line = body.substr(pos, end - pos);
            size_t indent = 0;
            while (indent < line.size() && line[indent] == ' ') ++indent;
            if (indent >= 2 && line.compare(indent, 4, "for ") == 0) {
                size_t eq = line.find(" = ", indent + 4);
                size_t in = line.find(" in ", indent + 4);
                size_t delim = eq == std::string::npos ? in
                             : (in == std::string::npos ? eq : std::min(eq, in));
                size_t do_pos = line.rfind(" do");
                if (delim != std::string::npos && do_pos != std::string::npos && delim < do_pos) {
                    std::string vars = line.substr(indent + 4, delim - (indent + 4));
                    std::string rhs = line.substr(delim + 3, do_pos - (delim + 3));
                    std::vector<RegToken> var_tokens = reg_tokens(vars);
                    std::vector<RegToken> rhs_tokens = reg_tokens(rhs);
                    size_t scope_end = body.size();
                    size_t scan = end < body.size() ? end + 1 : end;
                    while (scan < body.size()) {
                        size_t scan_end = body.find('\n', scan);
                        if (scan_end == std::string::npos) scan_end = body.size();
                        size_t lead = scan;
                        while (lead < scan_end && body[lead] == ' ') ++lead;
                        if (lead < scan_end && lead - scan <= indent) {
                            scope_end = scan;
                            break;
                        }
                        scan = scan_end < body.size() ? scan_end + 1 : scan_end;
                    }
                    std::vector<RegToken> before = reg_tokens(body.substr(0, pos));
                    std::vector<RegToken> after = reg_tokens(body.substr(scope_end));
                    for (const RegToken& token : var_tokens) {
                        int reg = token.reg;
                        bool escaped = false;
                        for (const RegToken& other : before)
                            if (other.reg == reg) { escaped = true; break; }
                        for (const RegToken& other : rhs_tokens)
                            if (other.reg == reg) { escaped = true; break; }
                        for (const RegToken& other : after)
                            if (other.reg == reg) { escaped = true; break; }
                        if (!escaped) result.insert(reg);
                    }
                }
            }
            pos = end + (end < body.size() ? 1 : 0);
        }
        return result;
    }

    // A generic-for frame coalescer can suppress the newest compiler MOVE triplet adjacent to
    // FORGPREP, but copies emitted by an earlier decompile cycle have already become ordinary source
    // assignments. Recompiling those assignments reserves three more locals, moves the real loop
    // frame above them, and leaves another fossil on the next cycle:
    //
    //     v13 = v6; v14 = v7; v15 = v8
    //     v16 = v6; v17 = v7; v18 = v8
    //     for v41 in v6, v7, v8 do
    //
    // Remove only complete, contiguous triplets immediately before that exact generic-for header,
    // and only when every destination occurs exactly once in the whole emitted body (the assignment
    // itself). That last condition proves the copies are dead; a saved iterator value used after the
    // loop, by a closure, or anywhere in the body fails closed. Returns the number of removed lines.
    static int suppress_dead_generic_frame_copies(std::string& body) {
        if (std::getenv("RENOVICE_NO_DEAD_FOR_FRAME_COPIES")) return 0;
        struct Line { size_t first, last; std::string text; };
        std::vector<Line> lines;
        for (size_t pos = 0; pos < body.size();) {
            size_t end = body.find('\n', pos);
            if (end == std::string::npos) end = body.size();
            lines.push_back({pos, end, body.substr(pos, end - pos)});
            pos = end + (end < body.size() ? 1 : 0);
        }
        std::map<int, int> occurrences;
        for (const RegToken& token : reg_tokens(body)) ++occurrences[token.reg];
        std::set<size_t> remove;
        auto exact_assignment = [](const std::string& line, size_t indent,
                                   int& lhs, int& rhs) {
            std::vector<RegToken> tokens = reg_tokens(line);
            if (tokens.size() != 2 || tokens[0].first != indent) return false;
            std::string expected(indent, ' ');
            expected += "v" + std::to_string(tokens[0].reg) + " = v"
                      + std::to_string(tokens[1].reg);
            if (line != expected) return false;
            lhs = tokens[0].reg; rhs = tokens[1].reg;
            return true;
        };
        for (size_t i = 0; i < lines.size(); ++i) {
            const std::string& line = lines[i].text;
            size_t indent = 0;
            while (indent < line.size() && line[indent] == ' ') ++indent;
            if (line.compare(indent, 4, "for ") != 0) continue;
            size_t in = line.find(" in ", indent + 4), do_pos = line.rfind(" do");
            if (in == std::string::npos || do_pos == std::string::npos || in >= do_pos) continue;
            std::string iterator = line.substr(in + 4, do_pos - (in + 4));
            std::vector<RegToken> sources = reg_tokens(iterator);
            if (sources.size() != 3) continue;
            std::string exact = "v" + std::to_string(sources[0].reg) + ", v"
                              + std::to_string(sources[1].reg) + ", v"
                              + std::to_string(sources[2].reg);
            if (iterator != exact) continue;
            size_t cursor = i;
            while (cursor >= 3) {
                int lhs[3], rhs[3]; bool match = true;
                for (int q = 0; q < 3; ++q) {
                    const std::string& candidate = lines[cursor - 3 + q].text;
                    size_t lead = 0;
                    while (lead < candidate.size() && candidate[lead] == ' ') ++lead;
                    if (lead != indent || !exact_assignment(candidate, indent, lhs[q], rhs[q])
                        || rhs[q] != sources[q].reg || occurrences[lhs[q]] != 1
                        || lhs[q] == sources[0].reg || lhs[q] == sources[1].reg
                        || lhs[q] == sources[2].reg)
                        match = false;
                }
                if (!match || lhs[0] == lhs[1] || lhs[0] == lhs[2] || lhs[1] == lhs[2]) break;
                remove.insert(cursor - 3);
                remove.insert(cursor - 2);
                remove.insert(cursor - 1);
                cursor -= 3;
            }
        }
        if (remove.empty()) return 0;
        std::string rewritten;
        for (size_t i = 0; i < lines.size(); ++i) {
            if (remove.count(i)) continue;
            rewritten += lines[i].text;
            if (lines[i].last < body.size()) rewritten += '\n';
        }
        body.swap(rewritten);
        return (int)remove.size();
    }

    // Whole function: params, then every register as a local, then the body.
    std::string emit_function(const std::string& name) {
        out.clear(); maxreg = 0; bad = false;
        if (std::getenv("RENOVICE_REGIONTREE") && !A->live.empty())
            dump_region_tree(*A->live.begin(), 0);
        std::string body;
        {
            std::string save;
            emit_region(A->live.empty() ? -1 : *A->live.begin(), 1);
            body.swap(out);
        }
        std::string params;
        for (int i = 0; i < ip->nparams; ++i) { if (i) params += ", "; params += R(i); }
        if (ip->vararg) { if (!params.empty()) params += ", "; params += "..."; }
        std::string decls;
        // maxstack IS the frame size: the registers are exactly v0..maxstack-1, so it is authoritative
        // and the per-instruction scan of operand A is not. That scan was wrong in BOTH directions --
        // it MISSED registers that are only ever read (generic-for loop variables, which then became
        // nil global reads) and INVENTED ones from instructions whose A is not a register at all
        // (FASTCALL's A is a builtin id; IsNull = 133 declared 134 phantom locals in every proto that
        // called it, which is also within a hair of Luau's 200-local limit).
        if (ip->maxstack > 0) maxreg = ip->maxstack - 1;
        // Declare only the registers the body ACTUALLY MENTIONS. `maxstack` is the frame size, but a
        // proto rarely names every slot, and Luau has a HARD 200-local limit per function — a big
        // shipped script hit "Out of local registers ... exceeded limit 200" and could not be
        // recompiled at all. Scanning the emitted text is exact here because the emitter is the only
        // thing that writes these names.
        std::set<int> used;
        std::set<int> entry_locals;
        std::set<int> for_locals;
        int dead_for_frame_lines = suppress_dead_generic_frame_copies(body);
        if (dead_for_frame_lines && std::getenv("RENOVICE_FORLOCALDBG"))
            std::fprintf(stderr, "DEAD_FOR_FRAME pidx=%d lines=%d\n",
                         pidx, dead_for_frame_lines);
        if (!std::getenv("RENOVICE_NO_ENTRY_LOCAL_INIT"))
            entry_locals = localize_dispatch_state_definitions(body);
        if (!std::getenv("RENOVICE_NO_FOR_LEXICAL_LOCALS"))
            for_locals = lexical_for_variables(body);
        if (std::getenv("RENOVICE_FORLOCALDBG") && !for_locals.empty()) {
            std::fprintf(stderr, "FORLOCALS pidx=%d", pidx);
            for (int reg : for_locals) std::fprintf(stderr, " v%d", reg);
            std::fputc('\n', stderr);
        }
        for (const RegToken& token : reg_tokens(body)) used.insert(token.reg);
        if (std::getenv("RENOVICE_LIVERANGE")) {
            std::map<int, int> names = allocate_registers(body, used);
            if (!names.empty()) {
                body = rewrite_registers(body, names);
                used.clear();
                for (const RegToken& token : reg_tokens(body)) used.insert(token.reg);
            }
        }
        std::vector<int> decl;
        for (int i = ip->nparams; i <= maxreg; ++i)
            if (used.count(i) && !entry_locals.count(i) && !for_locals.count(i)) decl.push_back(i);
        // Luau's 200-local limit is HARD, and a few real protos genuinely name more registers than
        // that. Locals are not the only way to hold them: spill to a REGISTER TABLE, which has no such
        // limit. Parameters must stay real locals (they are the function's signature), so only
        // registers >= nparams are rewritten. Threshold leaves headroom for loop variables, Proper
        // state variables and inlined-closure names, which also consume locals.
        // SCOPE PROBE (RENOVICE_DECLDBG=1) for FINDINGS #103 / task M6e-3.
        // Every register the body mentions is declared here in ONE flat function-scope header. Luau
        // then places every call frame ABOVE all declared locals, so a self-reassigning call
        // `vX = vX(vY)` must spill (MOVE/MOVE/CALL/MOVE = 1 instruction becomes 4). Those spill
        // registers come back as new `vN` next cycle, get declared, and raise the ceiling again --
        // maxstack ratchets +20/cycle on Loadouts (63 -> 83 -> 103, measured).
        //
        // Locals in DISJOINT Lua scopes share registers, so declaring a register at the narrowest
        // region containing all its uses would let Luau reuse the slot and stop the ratchet. This
        // measures the prize: how many declared registers are confined to a SINGLE basic block.
        // Deliberately an UNDER-count -- B and C are treated as register operands for every opcode,
        // which is false for some (FASTCALL's A is a builtin id, not a register: that exact mistake
        // once declared 134 phantom locals), so a register is credited to MORE blocks than it really
        // touches and "single" can only be too low.
        if (std::getenv("RENOVICE_DECLDBG")) {
            std::map<int, std::set<int>> rblocks;
            for (size_t b = 0; b < g->n.size(); ++b) {
                const st::Node& nd = g->n[b];
                if (!nd.reach) continue;
                for (int i = nd.first; i <= nd.last && i >= 0 && i < (int)ip->code.size(); ++i) {
                    const ir::IInsn& in = ip->code[i];
                    rblocks[in.A].insert((int)b);
                    rblocks[in.B].insert((int)b);
                    rblocks[in.C].insert((int)b);
                }
            }
            int single = 0;
            for (int rr : decl) {
                auto it = rblocks.find(rr);
                if (it != rblocks.end() && it->second.size() <= 1) ++single;
            }
            // "Single basic block" is too strict a test for what can be narrowed. Lua reuses a
            // register once a local goes out of scope, so what matters is whether a register's live
            // range fits inside any PROPER SUB-REGION (a loop body, an if arm) -- those map to real
            // Lua scopes and can hold their own `local`. Find the SMALLEST region whose block set
            // contains all the register's blocks; if that is not the whole function, the declaration
            // can be pushed down and the slot reused.
            std::vector<std::pair<size_t, std::set<int>>> rsets;
            for (size_t rid = 0; rid < A->regions.size(); ++rid) {
                std::vector<int> rb; collect_blocks((int)rid, rb);
                if (rb.size() >= 1) rsets.push_back({rb.size(), std::set<int>(rb.begin(), rb.end())});
            }
            size_t rootsz = 0;
            for (auto& pr : rsets) rootsz = std::max(rootsz, pr.first);
            int narrowable = 0;
            for (int rr : decl) {
                auto it = rblocks.find(rr);
                if (it == rblocks.end()) continue;
                size_t best = rootsz + 1;
                for (auto& pr : rsets) {
                    if (pr.first >= best) continue;
                    bool all = true;
                    for (int b : it->second) if (!pr.second.count(b)) { all = false; break; }
                    if (all) best = pr.first;
                }
                if (best < rootsz) ++narrowable;
            }
            fprintf(stderr, "DECL ndecl=%d single_block=%d narrowable=%d maxstack=%d nblocks=%d\n",
                    (int)decl.size(), single, narrowable, ip->maxstack, (int)g->n.size());
        }
        const size_t LOCAL_BUDGET = 150;
        if (decl.size() > LOCAL_BUDGET) {
            std::string outb; size_t i = 0;
            while (i < body.size()) {
                if (body[i] == 'v' && i + 1 < body.size() && std::isdigit((unsigned char)body[i + 1])
                    && !(i && (std::isalnum((unsigned char)body[i - 1]) || body[i - 1] == '_'))) {
                    size_t j = i + 1; int n = 0;
                    while (j < body.size() && std::isdigit((unsigned char)body[j])) { n = n*10 + (body[j]-'0'); ++j; }
                    if (!(j < body.size() && (std::isalpha((unsigned char)body[j]) || body[j] == '_'))
                        && n >= ip->nparams) {
                        outb += "vT[" + std::to_string(n) + "]";
                        i = j; continue;
                    }
                }
                outb += body[i++];
            }
            body.swap(outb);
            decls = ind(1) + "local vT = {}\n";
        } else if (!decl.empty()) {
            decls = ind(1) + "local ";
            for (size_t q = 0; q < decl.size(); ++q) {
                if (q) decls += ", ";
                decls += R(decl[q]);
            }
            decls += "\n";
        }
        return "function " + name + "(" + params + ")\n" + decls + body + "end\n";
    }
};

} // namespace em
