# M6 PLAN — what is left, in order, with the measurements that constrain each step

Written 2026-07-25 at the end of a long session. Everything here is grounded in numbers already
measured; the dead ends are recorded so they are not rediscovered.

## Where we are

| stage | state | metric |
|---|---|---|
| M6a annotated IR | **done** | 5,529,086 / 5,529,086 operands resolved (100.0000%) |
| M6b CFG | **done** | 82,042 / 82,042 protos, dead code classified and cleared |
| M6c expression reconstruction | **done** | 5,529,086 / 5,529,086 instructions consumed, 0 unhandled |
| M6d control-flow structuring | **DONE** | **82,042/82,042 = 100.0000%**, zero duplication, 0 missing/dup blocks |
| M6e emission | **in progress — the active front** | **ALIGNED 112/300 vs the ORIGINAL bytecode** |
| M6f idempotence oracle | superseded as primary, see below | `lbc-cmp` self-tested |

### M6e is where all remaining work lives (2026-07-28)
Emission is now two-phase **PLAN / RENDER** (see `.claude/M6_TRUTH.md` §8): PLAN walks the whole
region tree with output discarded, recording every loop claim; RENDER lets only the winner wrap, so a
loser never opens a wrapper and nothing is ever unwrapped after placement.

| metric | value |
|---|---|
| ALIGNED (fully 1:1) | **112 / 300** |
| NAME-DIFF (dropped accesses) | **0** |
| back-edge MATCH | 155 |
| LOOP-DIFF / ORDER-DIFF / PROTO-DUP | 123 / 45 / 8 |
| realtrip | 149/150 — **1 real failure** (`BindingsUtil`) |
| corpus recompile | 5386 / 5386 |

The remaining 183 failures cluster into **10 shapes / ~3 mechanisms**, not a long tail:
numeric-for LOST (~106 files), generic-for DUPLICATED (~66), effect ORDER (45).

**Verify everything with one command:** `python cert/gates.py 300 150` — runs all four release gates
concurrently (~2 min instead of ~15 serial) and refuses to ship on any failure.

### M6f is superseded as the PRIMARY oracle
Idempotence (decompile → recompile → decompile) is SELF-CONSISTENCY and is structurally blind to a
consistent misreading: defects #56 and #58 each survived 5386/5386 round-trips and 150/150 behavioural
traces. What actually finds those is **comparison against the ORIGINAL bytecode** (`cert/align.py`,
`cert/backedge.py`) plus the **access-count gate**. Idempotence is retained as a secondary signal.

M6d closed via STRUCTURAL ANALYSIS (bottom-up graph reduction), not by patching the recursive
descent — see below. The descent is superseded and its numbers are kept only as a record of what
does not work.

---

## ⚠ EVERYTHING BELOW IS STRUCTURALLY COMPLETE, NOT SEMANTICALLY CONFIRMED

M6a/b/c/d all report 100%. Those are COMPLETENESS metrics — operands resolved, blocks placed,
instructions dispatched. **None of them proves the output means what the bytecode means.** Three bugs
hid behind exactly these metrics on 2026-07-25 (phantom FORGPREP edge, duplicate loops, SETLIST +
multret), each producing identical 100% scores with materially different output.

Nothing here may be called "verified" until `decompile -> emit -> luau-compile -> lbc-cmp` passes.
Until then: do not publish the regenerated corpus, and do not retire v13/v14/v15.

---

## ✅ M6d IS DONE — 100.0000%, zero duplication, no fallback

```
82,042 / 82,042 protos reduced to ONE region      (100.0000%)
adversarial coverage: 0 missing blocks, 0 duplicated blocks
ground truth 294/294 on all three generated sets, deterministic
```
Achieved by REPLACING the recursive descent with STRUCTURAL ANALYSIS (`src/structan.h`) — bottom-up
graph reduction (Muchnick ch.7.7). STEPS 0-2 below are obsolete: they described patching the descent,
which plateaued at 92.32% honest / 99.9976% only with ~15,700 block copies plus a dispatch-loop
fallback. Kept for the record because the measurements still document what does NOT work.

**The lesson worth keeping:** five rounds of heuristics asymptoted near 3 protos without closing,
because a pattern pile has infinite residue by construction. The residuals were only solved once I
started DUMPING THE RESIDUAL GRAPH and reading what it was, instead of tuning budgets.

---

## STEP 3 — M6e emission  ← NEXT

Now unblocked and the highest-value work, because it is the first thing that can check MEANING rather
than structure.

- Walk the region tree from `sa::Analyzer` (kinds: Seq, IfThen, IfThenElse, SelfLoop, While,
  NaturalLoop, Proper) and emit Luau.
- `local` declarations for values crossing blocks (declare every register, params first).
- Render short-circuit conditions from `st::Node::chain` / `chain_and`. **Without this
  `if a and b then` emits as `if b then`** — correct control flow, wrong program.
- Fold trailing field assignments into table constructors.
- Inline single-use temporaries.
- **DELETE the state-machine fallback** — it is now provably dead code.

## STEP 4 — THE CHECKS (cost order)
1. **Compilability** — feed emitted source to `luau-compile.exe`. X/5,386.
2. **Round-trip correctness** — `lbc-cmp LBC1 LBC2`. 142 ground-truth cases ready.
3. **Idempotence** — decompile -> recompile -> decompile, source1 == source2.
4. **IN-GAME** — decompile a real shipped script, recompile, deploy, F9. Start with a small leaf.

**Never validate against `all_source_v13/v14/v15`** — wrong opcode map baked in; agreeing with them
means being wrong the same way.

---

## STEP 0 — the 3,324 `unplaced preds=1` blocks  ← START HERE, biggest and easiest

Current failure histogram (after the loop dom-child sweep):
```
unplaced preds=1 term=0x54 (CALL)       1,164
unplaced preds=1 term=0x40 (JUMP)       1,007
unplaced preds=1 term=0x18 (JUMPIFNOT)    705
unplaced preds=1 term=0x4b (JUMPIF)       448      = 3,324 blocks
shared tail duplicated                  5,109      (working as intended)
revisit outside-loop                    1,578
revisit inside-loop                     1,226
revisit non-terminal                    1,132
```

**A block with exactly ONE predecessor is ALWAYS dominated by that predecessor**, so it is always
placeable — under its pred, in its pred's region, with no duplication and no irreducibility involved.
All 3,324 are therefore pure bugs in the traversal, and they are the single largest remaining bucket.

**The suspected cause:** the dominator-child sweep only runs at three sites (after an `if`, after
straight-line flow, after a loop). When a region ends any OTHER way — hitting a `stop`, emitting a
`Break`, emitting a `Continue`, or returning from a nested call — the sweep never runs for that
block's dominator, so a child it owns is silently abandoned.

**The fix to try first:** hoist the sweep into a single helper and run it at EVERY exit from
`structure_seq`, not at three of them. Concretely, before each `break` in the main loop, ask "does
`cur`'s dominator still own an unplaced child?" and continue there if so.

**Verify with:** `derecomp struct-validate <cache>` — `unplaced preds=1` must fall to 0. It is a clean
signal because the theory says it MUST be zero; any residue is still a bug.

---

## STEP 1 — the remaining REDUCIBLE protos (bugs, not limits)

**Why this is definitely achievable:** a reducible CFG is *always* expressible with if/while/for and
NO duplication. That is a theorem, not an aspiration. `st::is_reducible` already tags these, so the
target set is known exactly.

**What to do:** finish migrating `structure_seq` to dominator-tree terms — *including loops*, in one
piece.

```
loop body  = blocks dominated by the header that can reach the latch
loop exit  = blocks dominated by the header but NOT in the body
if-arms    = successors dominated by the branch block
join       = the dominator-tree child of the branch block that is not an arm
```

**Measurements that constrain the design — do not repeat these:**

| variant | natural | verdict |
|---|---:|---|
| edge-following only | 94.51% | baseline |
| gate if-ARMS on dominance | 89.55% | **worse** — removes more than it fixes |
| + place dominator-tree children | 91.33% | still worse than baseline |
| arms by edge + dom-child sweep | 95.03% | **the sweep is the valuable half** |
| + same sweep after loops | **95.33%** | current |

The lesson: **half-migrating to the dominator algorithm is worse than either endpoint.** Loops are
still handled by ad-hoc pattern matching, and gating arms by dominance refuses descents that the
ad-hoc machinery was handling correctly. Either finish the migration or leave it alone.

---

## STEP 2 — the 1,688 IRREDUCIBLE protos (node splitting)

**Why achievable:** any irreducible CFG becomes reducible under node splitting, after which Step 1's
algorithm applies. Also a theorem.

**What to do — a GRAPH PRE-PASS, before any traversal:**
1. Find nodes with more than one structural parent (reachable from two regions neither of which
   dominates the other).
2. Materialise a duplicate node with its own index; redirect one predecessor's edge to the copy.
3. Repeat until `is_reducible(g)` returns true.
4. Structure the enlarged graph normally.

**Do NOT split during traversal.** Measured: erasing a block from `emitted` mid-descent so it can be
re-emitted gave **+0.29pp for 113,088 splits**, with the budget exhausting before convergence — the
same block re-splits indefinitely. The code is still present, disabled, with this reason attached.

**Bound it:** splitting is worst-case exponential. Cap total duplication per proto (3-4x original
block count is ample for compiler output) and count protos that hit the cap. They keep the
state-machine fallback, and the count must stay visible.

---

## STEP 3 — M6e emission

Only start once Step 1 and 2 land; emission on a wrong structure produces plausible wrong source,
which is the failure mode this project keeps getting bitten by.

Needed:
- `local` declarations for values crossing blocks (simplest correct approach: declare every register
  used, with parameters first — sidesteps scoping entirely).
- Render short-circuit conditions from `Node::chain` / `chain_and`. **Without this `if a and b then`
  emits as `if b then`** — correct control flow, wrong program. The chain is already recorded.
- Fold trailing field assignments into table constructors (`{1, 2, x = 3}`).
- Inline single-use temporaries.

---

## STEP 4 — THE CHECKS (in this order, cheapest first)

1. **Compilability** — feed emitted source to `luau-compile.exe`. Automatic, corpus-wide, X/5,386.
   If it does not compile it is not Luau, full stop.
2. **Round-trip correctness** — `S --luau-compile--> LBC1 --transcode--> DE1 --decompile--> S'
   --luau-compile--> LBC2`, then `lbc-cmp LBC1 LBC2`. If S' compiles to the same Luau bytecode, it is
   the same program regardless of formatting or register allocation. 142 ground-truth cases are ready.
3. **Idempotence** — decompile -> recompile -> decompile, require source1 == source2.
4. **IN-GAME (the only true end-to-end proof)** — take a REAL shipped script, decompile it, recompile
   it with our transcoder, deploy to `Inject/`, F9, confirm it runs and behaves. Start with a small
   leaf script, not Mallet.

**Never validate against `all_source_v13/v14/v15`.** They were decompiled with the old wrong opcode
map; agreeing with them means being wrong in the same way. Bytecode only.

---

## Standing rules earned the hard way (see DEFECTS.md)

- A completeness metric at 100% says nothing about correctness. `expr-validate` read 0 unhandled while
  SETLIST silently dropped every array element.
- A fallback that always succeeds absorbs bugs. The state machine reported "0 unrepresentable" while
  3,123 perfectly reducible protos were being mangled. Any catch-all needs a check asking whether it
  should have been needed.
- Verify the code path is exercised: `histops` must show the opcode present, and absent with the knob
  off.
- Report VALUES, not pass/fail — a wrong number names the opcode.
- Never append a trailing `//` comment to a line that continues (done twice, both silent).
