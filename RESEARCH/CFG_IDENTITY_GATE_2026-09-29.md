# Natural-loop structuring defect and the stock CFG-identity gate — 2026-09-29

Build under test: Warframe 44.0.2 (content 2026.09.28.13.06, exe 2026.09.24.13.29, name-hash seed
`768e5ed0`). Stock input: the read-only extraction `work/u44-rawhash-2026-09-29/stock` (5,473
modules; `manifest.json` SHA-256 `ad6491ef…b508`; `B.Font.toc` SHA-256 `10cced56…9dfd`). Repo work
only. Nothing was written to the game install and nothing was deployed.

Binaries:

| role | SHA-256 |
|---|---|
| baseline decompiler (HEAD `0299da9`) | `c1672d8d70e44bf7001a68f873f229714f5afdefb0b93c8558b6abb49e187c58` |
| final decompiler (this change, `build.bat`, 0 warnings / 0 errors) | `b4221c48a26600c1c0e2e67c04ceb09e77927745adaf492b5d4c39a85aa055eb` |
| gate binary used for BOTH corpus runs (same `cfg_identity_cmd.h`) | `e1821e124ab0589763e8974650e829e120207278a94c3e73f9400914e65045ef` |
| `bin/luau-compile.exe` | `6156a05d9caf9fa84e58baeca79a244f47d86b8982f5425f2ca3e23b976ed2a4` |
| `bin/luau.exe` (fixture execution) | `a0f4edd1e80ef7d7afd223c061e1f3b753398152cb732abf57328a93b375053e` |

## 1. The defect

`/Lotus/Scripts/Effects/SyndicateScarves.lua` (stock SHA-256 `0963cfb5…e9c8`), proto 13
`NewLokaScarfUpdate`. `decompile-mod-u44` printed the per-part `for` loop first, then the hub branch,
then the function prologue ending in `return`. The `while not IsNull(scarf)` loop was gone. CONST-ID
passed 17/17 because it compares constants, not order or control flow. The same output appears on
the U43 path (`decompile-mod`), so this is not a U44 issue.

### Hypothesis

The structurer chooses the wrong natural-loop header. Once the header is right, the emitter still
cannot render a `while` whose body is a non-series-parallel DAG containing a nested `for`.

**Result: TRUE.** There are four causes, each needed. The fixture attribution is in §3.

### Root cause (structan.h / emit.h)

1. **Wrong loop header (structan.h, NaturalLoop rule).** Any edge `p -> n` that closes a cycle
   (`reaches(n, p)`) was taken as a back edge. `n` was tried in region-id order. The real header
   (block 11, `IsNull(scarf)`) had already been collapsed into region 65, a newer and higher id.
   Block 24 (`NewLokaEffects[name] ~= nil`) was still a Basic region with a lower id, so it was
   chosen as the header. The natural-loop body is the backwards closure from `p = 65`. That closure
   ran through the real header into the prologue region 66, which is the function entry. The
   single-entry test cannot see this because the entry has no predecessors.
   Output: `NaturalLoop(head = 24)` containing the whole function.
2. **Loop body never reduced (structan.h, Proper rule).** The loop body is not series-parallel:
   `if t ~= nil and t[k] ~= nil then for … else … end`. The second operand needs statements, so it
   cannot be merged into a predicate chain. The Proper rule rejects any node that `reaches(c, n)`.
   Inside a loop every body node reaches the header through the latch, so the body stayed
   unreduced. The emitter then drops the branches between unreduced parts.
3. **Outer `while` taken for its nested `for` (emit.h).** The greedy interior-PREP scan found the
   nested FORNPREP, which was deep inside an IfThen part, and turned the outer region into that
   `for`. `is_for_body` (any FOR latch anywhere in the region) also suppressed the `while` wrapper.
   Parts came out in set (region-id) order, so the latch came before the body.
4. **Nested `for` flattened inside the loop-body dispatcher (emit.h, Proper).** The certified
   profile sets `RENOVICE_NO_PROPER_WHOLE_PROMOTION`. The raw dispatcher cannot spell a
   FORNLOOP/FORGLOOP back edge: the latch "falls through" to its exit state. So a cyclic child
   closed by a FOR latch lost its loop.

### Fix (generic; no module, ability or filename branch; each part has an A/B opt-out)

| # | file | change | opt-out |
|---|---|---|---|
| 1 | `src/structan.h` | A NaturalLoop candidate whose body holds the entry (with `n != entry`) is skipped, but only when a clean candidate of the same cycle exists: head holds an original-CFG loop header (`st::find_loops`) whose body covers `p2`, head is not the entry, and the body excludes the entry and contains both `n` and `p`. Otherwise the established candidate is kept. | `RENOVICE_LEGACY_ENTRY_IN_LOOP` |
| 2 | `src/structan.h` | Proper growth at a dominance loop header uses the exact acyclicity test "no member except `n` has a direct edge to `n`". Latches stay outside and become the single exit. | `RENOVICE_NO_LOOP_BODY_PROPER` |
| 3 | `src/emit.h` | `proven_non_for_natural_loop`. The semantic head is an authoritative While/Repeat header (no prep; no FOR latch targets it). It dominates the region, the region holds the whole loop body, and extra blocks are exit arms. Such a loop's parts are emitted in header-first topological order. The PREP overrides (no interior-PREP `for`, no `is_for_body`) apply only when the prep is nested inside a composite part and the loop has at most one outside continuation. | `RENOVICE_NO_PROVEN_WHILE_NATURAL` |
| 4 | `src/emit.h` | A single-exit, terminal-free Proper child whose cycle is closed by a FOR latch stays a whole state, even under the certified profile. | `RENOVICE_NO_FOR_CYCLE_WHOLE_PART` |

Result on the stock module (`evidence/SyndicateScarves.gates.txt`):

- HEAD output: CFG-ID 16/17 (proto 13 FAIL at depth 0), CONST-ID PASS.
- Fixed output: **CFG-ID 17/17 PASS**, CONST-ID 17/17 PASS, 2 dispatch webs resolved.
- The research hand-repaired control fails CFG-ID proto 13. Its `if t ~= nil then t = t[k] end;
  if t ~= nil then` is an equivalent but different CFG, and the gate reports that correctly.
- Fixed rebuild SHA-256: `145bc5cc…18cc`.
- Proto 13 is now `while true do <flag-dispatched body with the for kept whole> Sleep(0) end`. It
  is correct but not pretty: it is a state machine, not the original `and`.

Rejected on measurement (kept here so it is not retried):

- **Strict dominance for every back edge** (`RENOVICE_DOMINANCE_BACKEDGE`, now diagnostic-only).
  In Lotus_Interface_Hub p117 an earlier collapse had already merged loop 11's latch and prep with
  the entry. The dominance-correct choice exposed a downstream emitter defect: release Gate 6
  ACCESS-LOSS rose to 1 file / 11 accesses.
- **"Prefer any clean loop first"** reordered unrelated reductions and gave the same Hub loss.
- **Substituting the clean loop immediately** collapsed SyndicateScarves before its inner `for`,
  leaving the interior unreduced.
- **Broad PREP overrides for every proven loop** (intermediate binary `e1821e12`, full corpus run
  kept as evidence): +125 CFG-ID but 6 CONST-ID PASS→FAIL (EncounterLib, MoodController, VoidSink,
  NullStar, PlayerDoppelgangerAbility, CasesObjective). Multi-exit loops and direct-prep loops lost
  code.
- **Disabling header ordering outside the PREP family** (intermediate `3ed2b012`, full corpus run
  kept): CFG-ID 3,452 → 3,434 with 57 modules PASS→FAIL. Loop-body Proper regions need header-first
  order.

## 2. The CFG-identity gate (`derecomp cfg-identity <stock> <candidate> [--u44]`)

`src/cfg_identity_cmd.h`. For each prototype index it builds an instruction graph:

- **Labels are register-free.** Each label is the opcode class plus every non-register operand:
  constant or key identity with its hash/string class, upvalue slot, child proto, call and return
  arity, loop variable count.
- **Successors are ordered.** Conditionals are canonicalized to `[predicate true, predicate
  false]`, so JUMPIF/JUMPIFNOT and EQ/NOTEQ polarity do not matter.
- **Equality is bisimulation.** Two prototypes are equal if their entries are bisimilar: labels
  match, and successors are pairwise bisimilar, explored from the entry. This makes block
  splitting, jump threading, shared versus duplicated RETURN blocks and unreachable code
  irrelevant. Any reordered, dropped or added operation, a changed branch target, or a lost or
  invented loop is a mismatch.

Normalizations. Each is semantics-preserving and documented in the header.

- **Epsilon instructions.** MOVE, LOADNIL, CAPTURE, FASTCALL*, JUMP/JUMPBACK and PREPVARARGS
  (dropped by the transcoder) are bypassed.
- **Transcoder lowerings folded back:**
  - F1: LOAD scratch [+ MOVE] + JUMPIFEQ2/NOTEQ becomes `IF EQK k`.
  - F2: LOAD + reg-reg arithmetic becomes `<OP>K` or `SUBRK`/`DIVRK`.
  - F3: MOVE; JUMPIF(NOT); MOVE/LOAD becomes `OR`/`AND[K]`.
- **Compiler variants.**
  - FORGPREP, FORGPREP_INEXT and 0x0b are all `FORGPREP`; the FORGLOOP ipairs bit is dropped.
  - NEWCLOSURE and DUPCLOSURE are both `CLOSURE <flat proto>`.
  - LOADN and LOADK of a number are the same.
  - A keys-only DUPTABLE template equals the all-nil keyed template.
- **Dead constant loads** (instruction liveness) are dropped.
- **Redundant forms.**
  - `NOT r2 <- r1; JUMPIF r2` (r2 dead) becomes a test of r1 with the opposite polarity.
  - CLOSEUPVALS immediately before RETURN is dropped.
- **Pure-materialization sinking within a block.** Constant loads, NEWTABLE, DUPTABLE and
  GETIMPORT are sunk to just before their first real reader, following MOVE copies. Nodes at the
  same anchor are ordered by the operand slot they feed, so swapped arguments still mismatch. Then
  they are ordered by label. GETIMPORT counts as pure because Luau resolves imports at load time in
  a safe environment.
- **Upvalue slots** are compared up to one consistent bijection per prototype.
- **Emitter dispatch states (N4).** A register whose reaching definitions (a union-find web) are
  all constant loads, and whose every use is an equality-with-constant test (native EQK, or
  F1-folded with its MOVE copy), is a dispatch state. Its tests are decided statically during a
  product bisimulation over (node, state environment). The environment is pruned by liveness.
  This checks a flag-guarded rendering by the paths it actually executes, instead of
  rejecting every Proper state machine. It is capped at 400,000 product states; exceeding the cap
  is MODEL_ERROR, fail-closed.

Output lines: `proto i CFG_DIFF kind= depth= stock[i]="…" candidate[j]="…" class="…"`, then
`CFG_CLASSES {…}`, then `CFG_IDENTITY protos_stock= protos_candidate= cfg_equal= model_errors=
candidate_dispatch_webs= verdict=`. `--dump=N` prints both models for one prototype.

What it does **not** prove:

- Register dataflow is not compared, so reading the wrong register (the SetVortexWindPerZone
  `Normalize(nil)` class) is invisible.
- Operand order of reg-reg comparisons is not compared.
- MOVE/LOADNIL-only effects are invisible.
- Prototypes are paired by index, and a module whose prototype count differs is reported as
  PROTO_COUNT. Aggregate prototype totals count only modules whose prototype counts agree.
- It is a stock-identity gate, not a behavioral proof, and not in-game evidence.

Sensitivity and negative controls, `cert/natural_loop_nested_for.py` (8/8 PASS):

- The fixture `cert/fixtures/natural_loop_nested_for.luau` (the NewLokaScarfUpdate shape with mock
  natives, own code) round-trips with an identical 53-line execution trace and CFG-ID PASS.
- With the four opt-outs set, the gate FAILs and the behavior differs (a nil-index runtime error).
- Each of three source mutations FAILs: branch bodies swapped, loop bound 4→3, `Sleep` moved to
  the loop head.

## 3. Attribution (fixture, final binary)

Setting each opt-out alone makes the fixture fail both CFG-ID and behavior:
`RENOVICE_LEGACY_ENTRY_IN_LOOP`, `RENOVICE_NO_LOOP_BODY_PROPER`, `RENOVICE_NO_PROVEN_WHILE_NATURAL`,
`RENOVICE_NO_FOR_CYCLE_WHOLE_PART`. All four are needed.

## 4. Full 44.0.2 corpus, standard mode (`cert/u44_rawhash_roundtrip.py`, 11 jobs, full passes)

Denominators:

- 5,473 stock modules.
- 5,460 are U44-format. The 13 stale U43-format modules fail loudly as before.
- 5,459 decompile. `Jade_Abilities_Chaos` still fails `map::at`.
- **The gate denominator is 5,459**, of which 5,388 modules have matching prototype counts, with
  74,339 prototypes compared.

Same stock directory, same gate binary; only the pipeline binary differs.

| measurement | before (`c1672d8d`) | after (`b4221c48`) |
|---|---|---|
| decompile / recompile / deterministic | 5,459 / 5,459 / 5,459 | 5,459 / 5,459 / 5,459 |
| **CFG-ID first pass PASS / FAIL** | **3,452 / 2,007** | **3,577 / 1,882** |
| CONST-ID first pass PASS / FAIL | 5,330 / 129 | 5,336 / 123 |
| CONST-ID and CFG-ID both PASS | 3,449 | 3,574 |
| CFG-ID prototypes equal (aligned modules) | 69,683 / 74,339 | 70,020 / 74,339 |
| hash/string class swaps | 0 | 0 |
| compiler-closed within 5 passes | 5,372 | 5,389 |
| CFG-ID on compiler-closed bytecode | 3,420 | 3,533 |
| CONST-ID on compiler-closed bytecode | 5,241 | 5,259 |
| one-pass source / bytecode fixed point | 2,120 / 2,130 | 2,040 / 2,052 |
| wall time | 1,453 s | 1,225 s |

Module transitions:

- CFG-ID FAIL→PASS 125, PASS→FAIL 0.
- CONST-ID FAIL→PASS 6 (EidolonJobBoard, MapRedux, MapLegend, MissionRequirementUtilities,
  PostCameraUpdateHud, WaveDefend), PASS→FAIL 0.
- Prototype-level: 280 modules gain equal prototypes, 2 lose one:
  - ResourceConversion: its prototype counts differ, so same-index pairing is meaningless and it
    is excluded from the totals.
  - DoppelgangerTendrils p5: the emitter adds a redundant numeric-for zero-trip guard. It is CFG
    only; CONST-ID still passes.
- The one-pass source fixed point drops by 80 while the compiler-closed count rises by 17. The new
  loop-body regions converge in a second pass rather than the first. This is recorded, not hidden.

Two intermediate full runs are kept as evidence, and their rejected designs are listed in §1:
`evidence/u44-intermediate-e1821e12-compare.json` and `evidence/u44-intermediate-3ed2b012-compare.json`.
That makes three full runs in total instead of the two requested; each rerun followed a measured
regression.

### Remaining CFG-ID failure classes (after; first mismatch)

By module (1,882 FAIL):

| class | modules |
|---|---|
| LABEL LOAD -> GETIMPORT | 193 |
| LABEL LOAD -> LOAD | 178 |
| LABEL LOAD -> CALL | 145 |
| LABEL IF TRUTHY -> GETIMPORT | 111 |
| LABEL GETIMPORT -> GETIMPORT | 94 |
| PROTO_COUNT (prototype lost or duplicated) | 71 |
| LABEL IF TRUTHY -> NAMECALL | 71 |
| LABEL GETIMPORT -> LOAD | 41 |
| LABEL IF TRUTHY -> LOAD / -> GETUPVAL / IF EQ -> RETURN | 35 each |

By prototype, the top classes are:

| class | prototypes |
|---|---|
| GETFIELD -> GETTABLEN | 963 (concentrated in a few modules, e.g. WF99PvPvEMission, where the rebuild indexes numerically where stock reads a field) |
| GETIMPORT -> GETIMPORT | 486 |
| GETIMPORT -> GETUPVAL | 472 |
| LOAD -> LOAD | 436 |
| GETUPVAL -> GETIMPORT | 426 |
| LOAD -> GETIMPORT | 365 |
| CALL -> GETTABLEN | 345 |

These are not diagnosed here. The LOAD/GETIMPORT/GETUPVAL/CALL classes are operation-order
differences across block boundaries, where values are materialized in a different block or order
than stock. They are also where the remaining Proper state-machine renderings (raw FORNPREP
predicates, the dropped FORNLOOP back edges of other shapes) show up. Each class needs its own
hypothesis.

## 5. Release gates (`python cert/gates.py 300 150`, final binary)

ALL GATES PASS.

| gate | HEAD evidence (`U44_RAW_HASH…/evidence/gates-final.json`) | final |
|---|---|---|
| ALIGNED | 211 | 214 |
| first-match ORDER-DIFF | 49 | 43 |
| LOOP-DIFF | 20 | 23 |
| PROTO-DUP | 8 | 8 |
| back-edge MATCH | 266 | 266 |
| LOST-LOOPS / LATCH-DIFF / EXTRA-LOOPS | 23 / 9 / 2 | 22 / 7 / 5 |
| LOST-HEADERS / EXTRA-HEADERS | 106 / 2 | 107 / 10 |
| ACCESS-LOSS-TOTAL | 0 | 0 |
| DROPPED / DEADTAIL | 0 / 0 | 0 / 0 |
| realtrip | 150/150 | 150/150 |
| Semantic IR 22/22, 150/150, 11/11, NAMECALL 11/11 | pass | pass |

New gates:

- Gate 12 (natural-loop fixture): 8/8.
- Gate 13 U43, first 300: CONST-ID 18 → 18; CFG-ID 12 → 12; CFG prototypes 7,625 → 7,639 of
  10,925; class swaps 6,589 → 6,590 (AvatarDiorama unmasks one while its 100 other key differences
  go to 0). This is the known pending U43 hash-class defect, which CFG-ID labels include.
- Gate 13 U44, 1-in-50: CONST-ID 107 → 107; CFG-ID 69 → 72; CFG prototypes 1,474 → 1,483 of
  1,701; swaps 0.

The back-edge header counts moved within already-failing prototypes. Per file:

- Improved: ChatRedux −37 → −34, AvatarDiorama −5 → −2, ChallengePopUp and ChallengeUtilities
  now MATCH.
- Worse: DiegeticFoundry −6 → −12, EndOfMatch −8 → −11, ControllerLayout +1 → +6.

On the same 300-file sample, no module with matching prototype counts lost a CFG-ID-equal
prototype:

- ControllerLayout 40 → 43, DiegeticFoundry 128 → 130, ChatRedux 446 → 447,
  AvatarDiorama 71 → 72.
- EndOfMatch has mismatched prototype counts (286 vs 285), and its CFG-ID-equal count is unchanged
  at 43.

So the header-count moves are among prototypes that are wrong both before and after. They stay
under the existing ratchets and are recorded, not hidden.

## 6. Files

- `src/structan.h`: entry-in-loop candidate skip; loop-body Proper region; original loop bodies.
- `src/emit.h`: `semantic_head_block`, `proven_non_for_natural_loop`,
  `order_loop_parts_from_header`, and the FOR-latch whole-part exception.
- `src/cfg_identity_cmd.h` (new) and `src/main.cpp`: the `cfg-identity` command.
- `cert/u44_rawhash_roundtrip.py`: CFG-ID first-pass and closed results, class aggregation,
  `--first-pass-only`, and aligned-only prototype totals.
- `cert/gates.py`: Gates 12 and 13, with pre/post numbers pinned beside the new baselines.
- `cert/natural_loop_nested_for.py` and `cert/fixtures/natural_loop_nested_for.luau`.
- `DEFECTS.md` #31–#34.
- `RESEARCH/CFG_IDENTITY_GATE_2026-09-29/tools/compare_runs.py`.
- `RESEARCH/CFG_IDENTITY_GATE_2026-09-29/evidence/`: summaries, per-module TSVs, before/after
  comparison, intermediate comparisons, gates JSON/text, and the SyndicateScarves gate output.

## 7. Limitations and pending

- No in-game load or behavior test. The fixed SyndicateScarves source is statically CFG-identical
  to stock; that is not proof of gameplay.
- The research candidate `b79e3619e166d2a6 (Syndicate Syandanas Full Glow).lua_B` was built from
  the hand-repaired control and is unchanged. Rebuild it from the fixed `decompile-mod-u44` output
  before any deployment decision, then gate it with both CONST-ID and CFG-ID.
- The CFG-ID gate does not cover register dataflow; see §2.
- The U43 standard path still loses hash classes (pending, separately authorized repair).

## Next step

Take the largest remaining CFG-ID class (operation order across blocks: LOAD/GETIMPORT/CALL,
about 530 modules) and form one hypothesis about its mechanism. Check it with `--dump` on the
smallest failing prototype.
