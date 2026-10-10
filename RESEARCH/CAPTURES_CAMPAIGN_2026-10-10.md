# Captured locals and upvalues — agent captures, wave 3 of the 44.1.1 campaign (2026-10-10)

Build: Warframe 44.1.1 (content 2026.10.08.13.05), stock `work/stock-2026.10.08.13.05` (read only).
Baseline: campaign HEAD c01796c, `bin/derecomp.c62f1665.exe` (SHA-256 `c62f16656ea43a81…`, reproduced bit-exact by
the agent worktree build), full run `work/u441-r9-c62f1665`.
Result: agent branch `agent/captures` commit 667770c (+ docs), binary `derecomp.46694dd9.exe`
(SHA-256 `46694dd9b4b91df864a1b0483dc667b846dc584cb8cad58585bdd87d54cc67d4`, rebuilt from the committed source
bit-exact).

## 1. Hypotheses and results

| # | hypothesis | result |
|---|---|---|
| H1 | `CLOSEUPVALS -> *` = a block-scoped local captured by reference flattened to function scope; behavior can change | TRUE. luau.exe: `for ... do local x ...; fs[#fs+1] = function() return x end end` prints `1 2` from stock, `2 2` from the flat form; on real output later register reuse also overwrites the captured variable (closures returned functions). |
| H2 | `UPVALUE GETUPVAL -> GETUPVAL` (16 modules) is one mechanism | FALSE: three. 3 modules = one register captured in two by-value slots (Luau's `local b = a` alias); 12 modules = the >195-local spill frame `vT`; 1 module (InterceptionChallenge) = upvalue numbering order of `u = f(u')`. |
| H3 | StatsLib PROTO_COUNT = a top-level #52 snapshot makes Luau share the closure | TRUE. Luau's shouldShareClosure shares closures whose upvalues are immutable top-level chunk locals outside loops; `repeat ... until true` emits no instruction and lifts that. |
| H4 | the 13 CFG-PASS / dataflow-FAIL modules share a capture mechanism | FALSE. 12 = loop variable read after a break exit (`VALUE -D:FORNLOOP/FORGLOOP`, loop structure); 1 (FishInfo) = emit.h `canonicalize_paired_index_base_lifetimes` text-order liveness across dispatcher states. |

## 2. Fixes (each generic, each with an opt-out)

- `src/scoped_captures.h` (new) + expr.h marker + emit.h call: block-scoped REF-captured locals
  (`RENOVICE_NO_SCOPED_CAPTURE_LOCALS`; control `RENOVICE_SCOPED_CAPTURE_MARKERS_ONLY`; trace
  `RENOVICE_SCOPED_CAPTURE_TRACE`). Exactness argument and refusal rules in the header comment.
- expr.h: duplicate by-value capture slots (`RENOVICE_NO_DUPLICATE_CAPTURE_SNAPSHOT`).
- `src/scoped_captures.h` `unshare_snapshot_closures` + m6e main-chunk index: StatsLib
  (`RENOVICE_NO_UNSHARED_SNAPSHOT_CLOSURE`).

## 3. Measurements (all with `cert/u44_rawhash_roundtrip.py ... --jobs 3 --dataflow`)

Control (decompile only, stride 20 = 274 modules, `work/agents/captures-runs/ctl1`): the output with
`RENOVICE_NO_SCOPED_CAPTURE_LOCALS=1 RENOVICE_NO_DUPLICATE_CAPTURE_SNAPSHOT=1` and the output with
`RENOVICE_SCOPED_CAPTURE_MARKERS_ONLY=1 RENOVICE_NO_DUPLICATE_CAPTURE_SNAPSHOT=1` are byte-identical to c62f1665 on all
274 modules (markers alone change no emission decision).

Queue = the 74 r9 modules with a CLOSEUPVALS/UPVALUE class + the 13 CFG-PASS/dataflow-FAIL modules + StatsLib (88,
`work/agents/captures-runs/queue.txt`). Before = c62f1665 (`m1-queue-before`, identical to r9 on these modules),
after = 46694dd9 (`m2-queue-after`):

| measure | before | after |
|---|---|---|
| CFG-ID PASS | 13 | 39 |
| CONST-ID PASS | 78 | 79 (StatsLib) |
| dataflow PASS | 0 | 27 |
| CFG-ID + dataflow PASS | 0 | 25 |
| compiler-closed | 86 | 86 |
| equal prototypes | 7,158 / 10,235 | 7,224 / 10,235 |
| PROTO_COUNT modules | 1 | 0 |
| PASS -> FAIL (any gate), closure lost, equal-prototype loss | | none |

Stride 20 (274 modules, `m1-stride-before` / `m2-stride-after`): CFG-ID 247 -> 248, dataflow 247 -> 248, CONST-ID 272
-> 272, closed 271 -> 271, equal prototypes 4,156 -> 4,158; no PASS -> FAIL, no closure or prototype loss.

Full corpus (5,478 modules): first-pass decompile of c62f1665 vs 46694dd9 (`work/agents/captures-runs/full`,
`changed.txt`): 60 modules change, the recompiler is unchanged, so no other module can change in any round. 59 are in
the queue; the 60th (LasrianTankJumpAbility) was run before/after (`m2-extra-*`): all verdicts unchanged. Derived
full-corpus totals (r9 + measured deltas; the c62f1665 reruns of queue and stride equal r9 module for module):
CFG-ID 4,830 -> 4,856, CONST-ID 5,437 -> 5,438, CFG-ID + dataflow 4,817 -> 4,842, equal prototypes 79,485 -> 79,551
of 83,518, PROTO_COUNT 1 -> 0, compiler-closed unchanged, no PASS -> FAIL, no closure or prototype loss. Not a
direct full-corpus runner run (the integrator re-measures).

Fixture gates (binary 46694dd9): `cert/cfg_class_fixtures.py` 135/135 (was 125; +10 checks), 
`cert/dataflow_identity_fixtures.py` 157/157 (+6), `cert/proto_shape_fixtures.py` 52/52 (+12),
`cert/natural_loop_nested_for.py` 8/8. Legacy controls reproduce: scoped_capture_loop legacy behavior differs /
CFG FAIL / dataflow FAIL; duplicate legacy CFG FAIL, behavior same; markers-only legacy CFG FAIL, behavior differs;
shared_main_snapshot legacy prototype count differs.

## 4. Remaining (measured after 46694dd9 on the queue)

- CLOSEUPVALS classes left in 14 modules; every traced refusal is a dispatcher shape (the definition and the closure
  or the CLOSEUPVALS in different `__renovice_state_N` blocks: DuelistPistolsPassive p4, ChamberDoorKeyEncounter p30,
  Conversation p29, ThemedSyndicates p176 ...). Witness: `cert/fixtures/captures_2026_10_10/open/` (behavior still
  differs). Needs the loop/dispatcher owner.
- UPVALUE: 12 spill-frame modules + InterceptionChallenge (see DEFECTS).
</content>
</invoke>
