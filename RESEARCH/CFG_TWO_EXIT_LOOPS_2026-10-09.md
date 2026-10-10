# Two-exit loops: loop escape joins and while break/return arms (#76, #77) — 2026-10-09

Campaign wave 2, agent `twoexit`. Branch `agent/twoexit` (base `6be6bec`, commits `943b3d4`, `c7fb3f1`);
the same change rebased onto batch 5 is `agent/twoexit-rebased` (`0387660`, `dc71895`, on `340d54c`).
Repo work only: nothing deployed, nothing pushed. Stock input: `work/stock-2026.10.08.13.05` (44.1.1).

| role | SHA-256 |
|---|---|
| before (`6be6bec`, pipeline and gate for every run below) | `928298dbe617030fb5bd3b0a086f32ba8090780f71610d0b7ffddf95b1d3ee75` |
| after (`c7fb3f1`, `build.bat`, 0 warnings / 0 errors) | `d1504afa4a7972f1fea71c0376ec5f890227bdcd60f5dbc8d3e10bb267e49daf` |
| rebased (`dc71895` on `340d54c`) | `c03ef3dc3c798d0f8c4ff28aa475bede544b6919352508e22acaf0f84564ba4d` |
| intermediate `943b3d4` (measured, superseded: SongFragmentPickup regression) | `2cb3a6aaf0cef25b4e5aa26c4f23a452fc905471576b247859e0b4e8c2418eab` |

## 1. Hypothesis and result

H: the wave-1 reports (tables "split-exit loop", conditions M7 "inlined search two exit", accessorder
"break + return", dataflow open defect `for_index_after_exit_o2`) are one mechanism: a loop whose body
leaves for more than one destination. The whole-prototype CFG renderer could not spell it (no `goto`) and
rejected the prototype (`START_OUTSIDE_DOMAIN`, or blocks left unowned), and the legacy region emitter
then mis-rendered it. **TRUE** for the -O2 inlined-return loops (for) and for while loops with
statement-carrying break arms / shared returns; the legacy-path symptoms (arm printed after the loop,
loop variable out of scope, `for` claimed twice, return printed as `break`) all disappear once the CFG
renderer owns the prototype.

## 2. Census (method)

`derecomp loop-exit-scan --u44` (new, read-only, `src/loop_exit_scan_cmd.h`) over all 5,478 stock
modules (5,465 U44): per authoritative loop, the natural body, the canonical exit C (FOR latch fallthrough
/ while header-test exit) and every other exit arm classified RET / BRK / JOIN by its private arm.
JOIN = an arm ending at one block J with J != C: 272 prototypes in 186 modules (forgen 208 loops, fornum
129, while 143). Queue = modules whose failing prototype (CFG-ID or dataflow `firstDiffs` of the
928298db full run) carries a JOIN loop or a loop with both a return arm and a break arm: **166 modules**
(147 JOIN, 23 RET+BRK). Files: `work/agents/twoexit-runs/{loopexit_stock.txt,queue.py,queue.txt}`.

## 3. Mechanism (emit.h `emit_cfg_for_function`)

#76 LOOP ESCAPE JOINS. Per source for (and plain while), every non-canonical, non-return exit arm that
is private to the loop and ends at the same single join J is rendered INSIDE the loop (its loop variables
in scope), sets a generated dispatch selector and breaks; the canonical-exit code C .. J runs only when
no escape was taken:

    local __renovice_state_N = 0
    for ... do ... if c then r = v; __renovice_state_N = 1; break end ... end
    if __renovice_state_N ~= 1 then r = d end
    <J>

The construct is one lexical unit opened at its head (the prep, the while header, or the nearest
dominator H of the loop entry and of C's outside entries — an inlined helper's guard that jumps straight
to `return d`; H .. entry must be acyclic and private). Proof helpers, guard chains and atomic dispatch
children treat the construct as exiting at J (`loop_outside`, `registered_while_outside`). CFG-ID resolves
the selector as a dispatch web; dataflow-identity passes it. No placed wrapper is ever removed: a loop
with a registered escape is rendered only inside its construct (`LOOP_ESCAPE_OUTSIDE_CONSTRUCT` otherwise).
An arm ending at a shared bare RETURN stays a return arm (c7fb3f1, SongFragmentPickup p2).

#77 WHILE LOOP ARMS. A plain header-tested while's private break/return arms join its render domain and
its header-test exit is a recognised `break` target, so a shared bare RETURN (`if IsNull(a) or IsNull(b)
then return end`) or a break arm with statements no longer leaves the prototype incomplete.

Opt-outs: `RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN` (all of it), `RENOVICE_NO_CFG_LOOP_ESCAPE_PRETEST` (pre-test
heads), `RENOVICE_NO_CFG_WHILE_LOOP_ARMS` (#77), `RENOVICE_CFG_LOOP_ESCAPE_TO_RETURN=1` (re-admit
bare-return joins, A/B of c7fb3f1). Diagnostics: `RENOVICE_CFG_FOR_DEBUG` prints `CFG_FOR_LOOP_ESCAPE`,
`CFG_FOR_LOOP_ESCAPE_REJECT reason=...`, `CFG_FOR_LOOP_ARMS`, `CFG_FOR_LOOP_ESCAPE_RETURN_ARM`.

## 4. Fixtures (luau.exe behavior, `cert/fixtures/twoexit_2026_10_09`)

| fixture | gate | default | opt-out |
|---|---|---|---|
| escape_join_forgen (-O2, ApproachAnim p1 shape) | Gate 14 | CFG PASS, behavior same | CFG FAIL, `IsA 1 nil`, play ran wrongly |
| escape_join_loop_value (-O2, FishingLib p1 shape) | Gate 14 | CFG PASS, same | CFG FAIL, every lookup `nil nil` |
| while_break_return_arms (InfestedPredatorFinisherSpores class) | Gate 14 | CFG PASS, same | CFG FAIL, legacy duplicated the next `for` |
| escape_pretest (-O2, Bomber p4 shape) | dataflow | CFG+DF PASS, same | CFG blind, DF FAIL, `pick b 1` |
| for_index_after_exit_o2 (was an open defect) | dataflow | CFG+DF PASS, same | CFG blind, DF FAIL, `count c 10` |

Gate 14 `cert/cfg_class_fixtures.py` 106/106 (was 91; proper_prep_for's legacy controls now also set
`RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN`), `cert/dataflow_identity_fixtures.py` 106/106 (the base script failed
2 checks on 928298db: `loop_exit_test_register` was still listed open although #64 fixed it; now in the
fixed set as batch 4 does). Negative control: 928298db fails exactly the 6 + 5 new default checks.
Compiler closure of the five fixtures: source repeats at round 2-3, closed bytecode CFG PASS.

## 5. Measured (u44 runner, `--jobs 3 --dataflow`, gate 928298db)

Full 44.1.1 corpus, `work/agents/twoexit-runs/full_v6` (5,031 s) vs `work/u441-r3b-928298db`:

| measurement | before | after |
|---|---|---|
| decompile / recompile / deterministic | 5,465 / 5,465 / 5,465 | same |
| CFG-ID first pass | 4,465 | **4,596** (+131, 0 PASS->FAIL) |
| CONST-ID first pass | 5,389 | 5,391 (0 PASS->FAIL) |
| dataflow-identity | 4,390 | 4,518 (0 PASS->FAIL) |
| CFG-ID + dataflow | 4,351 | 4,478 |
| compiler-closed within 5 passes | 5,446 | 5,449 (0 lost; Illusion, CRTShieldBurstAbility, MoaStasisField gained) |
| CFG-ID / CONST-ID on closed bytecode | 4,354 / 5,370 | 4,482 / 5,375 (0 PASS->FAIL) |
| equal prototypes (81,090 compared) | 77,326 | 77,573 (0 modules lose one) |
| source / bytecode fixed point | 2,045 / 2,057 | 2,073 / 2,084 |

Queue (166, subset of the full run): CFG-ID 8 -> 82, CONST-ID 158 -> 160, dataflow 0 -> 73, closure
163 -> 164, equal prototypes 4,607 -> 4,779, no PASS->FAIL, no loss. Stride-20 control (274): CFG-ID
230 -> 234, dataflow 226 -> 230, CONST-ID 270 = 270, closure 271 = 271, equal prototypes 4,087 -> 4,098,
no PASS->FAIL, no loss. Of the 131 corpus gains, 70 modules carry a JOIN loop, 5 RET+BRK, 56 only
return arms (#77 while arms). `dataflowFailAmongCfgPass` 114 -> 118 (9 in, 5 out): nine modules are
newly CFG-PASS with a remaining dataflow difference. Unmaskings, not regressions: in 8 the same dataflow
difference is already in the 928298db firstDiffs; in TeleportTo p11 the read of the unassigned
`c12v18:IsA(...)` receiver (a folded `local obj = target` copy) is present verbatim in the 928298db source.

Rebased build vs batch 5 (`5713df5f`, gate 5713df5f), queue ∪ stride (432): CFG-ID 241 -> 319,
dataflow 235 -> 318, CONST-ID 420 -> 422, closure 426 -> 427, equal prototypes 8,493 -> 8,667, no
PASS->FAIL, no loss (`work/agents/twoexit-runs/rb6`).

Rejected on measurement: `943b3d4` turned SongFragmentPickup PASS -> FAIL (a nested for's return to the
outer loop's exit RETURN registered as an escape join outside the outer loop's domain); fixed by
c7fb3f1, which changes only the 8 modules where the exclusion fires (all back to their 928298db result).

## 6. Not fixed (residue, measured on the queue)

JOIN-signature modules failing CFG or dataflow: 159 -> 90 of 186. Remaining reasons (first CFG renderer
rejection of the JOIN prototype): unrelated walker vocabulary (`START_ALREADY_EMITTED` triangles,
`GUARD_CHAIN_NO_BOUNDARY_EDGE`, e.g. the inlined `return` inside an if/elseif chain of
`inlined_search_two_exit`'s main chunk, which is not a loop exit), interior-exit / `while true` loops with
several exits (`INTERIOR_WHILE_EXIT_COUNT`, `UNSUPPORTED_WHILE_SHAPE`: not admitted by the renderer
setup), and escapes that would have to leave two loops at once (fail closed). The legacy region path
(split IfThenElse heads, `head_block` taking `parts[0]`) is unchanged; it is now reached less often.
No in-game test.
