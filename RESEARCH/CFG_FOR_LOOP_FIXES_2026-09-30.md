# Numeric-for structuring, selector residue, gate S5, SETLIST and by-value captures — 2026-09-30

Build under test: Warframe 44.0.2 (content 2026.09.28.13.06, exe 2026.09.24.13.29, name-hash seed
`768e5ed0`). Stock input: the read-only extraction `work/u44-rawhash-2026-09-29/stock` (5,473
modules; `manifest.json` SHA-256 `ad6491ef1def1f281e249ad66015a01979333d9481aea48e4a3342695aefb508`).
Repo work only: nothing written to the game install or OpenWF, nothing deployed, nothing pushed.
Branch `fix/natural-loop-header-cfg-gate`, parent commit `16ecb4f`.

| role | SHA-256 |
|---|---|
| before (HEAD `16ecb4f`, pipeline AND gate) | `d51d877e042353d852916c67a572a74a40201f5e57aeb412cfd86bcd68716d69` |
| after (this change, `build.bat`, 0 warnings / 0 errors, pipeline AND gate) | `65c4657239eebc194f8aa9c62cb919153449ec05a163e88086decf5c990ecf1c` |
| `bin/luau-compile.exe` | `6156a05d9caf9fa84e58baeca79a244f47d86b8982f5425f2ca3e23b976ed2a4` |
| `bin/luau.exe` (fixture execution) | `a0f4edd1e80ef7d7afd223c061e1f3b753398152cb732abf57328a93b375053e` |

The `build.bat` output is byte-identical to the scratch build of the same source (`--no-insert-timestamp`).

## 1. Targets and hypotheses

1. The three numeric-`for` defects diagnosed in `CFG_MULTI_EXIT_LOOPS_2026-09-30.md` §6 (class
   `LOAD -> LOAD`, 143 modules). H1: each is a distinct emitter/structurer ownership gap, not one
   mechanism. **TRUE** — (a) is #45, (b) is three defects #44/#46/#47, (c) is #48.
2. The compiler-closure loss of #40 (15 modules). H2: re-decompiling the structured two-exit output
   re-creates the escape selector and leaves one extra compare per round. **TRUE for 7 of 15** (#49);
   the other 8 are different re-decompile misstructurings (§6).
3. Next class, time allowing: `GETIMPORT -> GETIMPORT`. H3 (DialogTree): a gate normalization gap
   around the lowered OR. **TRUE** (#50, gate S5).
4. Coordinator report (mid-task, another investigation, `EE_Interface_Components_List`): SETLIST into
   an existing table rebuilt as a fresh one (#51), by-value captures bound to shared flat locals (#52).
   Both **TRUE** on the stock module (sha256 `2f5237c6…345c`).

## 2. Root causes and fixes (each generic, each with an opt-out)

| # | file | root cause | fix | opt-out |
|---|---|---|---|---|
| 44 | `emit.h` `proven_non_for_natural_loop` | a while whose header block ends in the FORNPREP of a nested `for` (`while true do local idx = nil; for ...`) was rejected as "for-headed"; the NaturalLoop lost the loop claim and was flattened (the `while` disappeared) | admit a prep-headed While/Repeat when the for's latch is inside the loop body and does not branch to the header | `RENOVICE_NO_PREP_HEADED_WHILE` |
| 45 | `emit.h` `unwrapped_loop_parts` | a NaturalLoop emitted without its own wrapper (for iteration, lost claim) printed its parts in region-id order: `print(i)` ran before the inner `while` | header-first topological order from the region head, latch last; refused for FORGLOOP-headed regions and non-DAG part graphs | `RENOVICE_NO_FOR_BODY_PART_ORDER` |
| 46 | `emit.h` `emit_block` | the break arm `idx = i; JUMP exit` is outside the for's natural body, so the unconditional-break check skipped it; the search continued | a block whose predecessors are all in the body and whose jump is the for's canonical exit prints `do break end`, only when no body block branches to two body blocks | `RENOVICE_NO_FOR_BREAK_ARM` |
| 47 | `expr.h` LOADNIL | a LOADNIL at instruction 0 was always treated as the prologue of a flat `local`; when instruction 0 is a loop header, the per-iteration reset `local idx = nil` was dropped (invisible to cfg-identity) | keep `x = nil` when any branch targets instruction 0 | `RENOVICE_NO_LOOP_ENTRY_NIL` |
| 48 | `emit.h` Proper dispatcher | a cyclic child that is not kept whole is dissolved, and the FORNPREP/FORGPREP of a two-exit (inlined `return true`) or return-arm loop is a separate raw state: the prep printed as `<` comparisons, the back edge fell through, the body ran at most once | a child holding a for's latch and whole natural body whose prep is a raw state is emitted as the coalesced `for` state with the escape selector (numeric and generic, single/multi exit, return arms); rejected Seq/IfThen/IfThenElse/Proper children offer their loop descendants; a one-block FOR SelfLoop qualifies; the prep is keyed by the latch's loop | `RENOVICE_NO_PROPER_PREP_FOR`, `RENOVICE_NO_PROPER_NESTED_LOOP_PARTS` |
| 49 | `emit.h` `canonicalize_single_pass_state_wrappers` | flattening a repeat-once selector shell kept an empty `if sel == -1 then end` ("metamethods"), although `sel` is a generated integer; it compiled to a real compare, each re-decompile printed it with a fresh constant register and the re-derived shell left another one | drop the guard for `__renovice_state_N ==/~= <integer>` | `RENOVICE_KEEP_SELECTOR_GUARD_RESIDUE` |
| 50 | `cfg_identity_cmd.h` S5 | GATE: the lowered F3 (MOVE + JUMPIF + LOAD) split the straight-line block, stock's native ORK does not; a pure GETIMPORT before `x or 0` could not sink past it (`_T.X = _T.X or 0`: `GETIMPORT _T -> GETIMPORT _T.X`) | a folded F3 does not end the S1/S2 block; its MOVE copies are the OR's operand slots 1/2 | `RENOVICE_CFGID_LEGACY_OR_BLOCK` |
| 51 | `expr.h` SETLIST | `{ k = v, ..., (f()) }` = NEWTABLE, SETFIELDs, SETLIST into the same table; the SETLIST was always rendered `vA = {values}`, replacing the table (List CreateList p86: every list field lost) | when anything reads the table between its NEWTABLE/DUPTABLE and the SETLIST (instruction-order scan, fail safe), store `vA[k] = value`; a multret tail keeps the rebuild (0 corpus sites) | `RENOVICE_NO_SETLIST_EXISTING_TABLE` |
| 52 | `expr.h` NEW/DUPCLOSURE | a `CAPTURE 0 R` (by value) was bound to the flat per-register local `vR`; a later write to R (next iteration, register reuse) changed what the closure read (List Redraw p54: per-element callbacks all saw the last element; invisible to cfg-identity) | when a write to R is reachable from the closure, snapshot `local __renovice_capture_<proto>_<ordinal> = vR` and capture it; a copy only CAPTUREs read (our own snapshot, re-decompiled) becomes the snapshot | `RENOVICE_NO_CAPTURE_SNAPSHOT` |

Rejected or narrowed on measurement (not to be retried as they were):

- #46 unrestricted (any block whose predecessors are all in the loop body): no first-pass change on
  unreduced multi-exit bodies (their condition is already wrong) but 18 modules stopped converging
  (NonCombatSpeed p2). Narrowed to bodies where no block branches to two body blocks.
- #48 promoting any rejected composite descendant: an `IfThenElse(Seq(prep, loop), arm, arm)`
  promoted whole printed two `for` headers (MatchTag p2). Only loop kinds are promoted; composites are
  only searched. Keying the prep by `block2loop[prep]` missed preps that also head an outer loop
  (MawBugsBunny p5); keyed by the latch.
- S5 without operand slots: BindingsUtil p14 (`x or t` with a sunk NEWTABLE) lost an equal prototype
  (`NEWTABLE -> OR`). Fixed by treating the F3 MOVE copies as the OR's operands.
- #52 without copy reuse: our own snapshot `local s = vX` compiles to MOVE + CAPTURE of a register the
  loop rewrites, so every round added `vR = vX` plus a new snapshot: 118 modules stopped converging.
  With the pc in the name it also never repeated; the name is now prototype + CAPTURE ordinal.

## 3. Semantics (luau.exe; stock vs old output vs fixed output)

Fixtures in `cert/fixtures/cfg_class_2026_09_30/` (own code, mock natives):

| fixture | defect | old output (opt-out) | fixed output |
|---|---|---|---|
| `for_body_order` | #45 | prints `1` before the inner loop's sleeps; CFG FAIL | identical trace, CFG PASS |
| `nested_for_break` | #44 | outer `while` deleted, one round; CFG FAIL | identical, CFG PASS |
|  | #46 | search keeps touching after the match; CFG FAIL | identical |
|  | #47 | round 2 does not insert (idx carried); CFG **PASS** (blind spot) | identical |
| `proper_prep_for` (-O2, inlined) | #48 | `false false false false`, no `IsA` call; CFG FAIL | `true false false false`, CFG PASS |
| `selector_residue` | #49 | source never repeats in 5 rounds; first pass CFG FAIL | repeats at round 2; CFG PASS |
| `or_block` (native ORK original) | #50 | legacy gate FAILs the identical round trip | PASS; `or 1` and `and 0` mutations FAIL |
| `setlist_existing` | #51 | `nil nil nil menu1 1` | `menu 3 true menu1 1` (CFG still differs: SETTABLEN vs SETLIST) |
| `capture_snapshot` | #52 | `c c#3` three times; CFG **PASS** (blind spot) | `a a#1 / b b#2 / c c#3`; re-decompiles to itself |

Gate 14 (`cert/cfg_class_fixtures.py`): **91/91** with 65c46572. Negative control: d51d877e fails
every new default check; 6be95eb4 (#52 without copy reuse) fails `CAPTURE_SNAPSHOT_DEFAULT_CLOSES`.

## 4. Release gates (`python cert/gates.py 300 150`, 65c46572): ALL GATES PASS

`evidence/gates-final.{txt,json}`. Unchanged: PROTO-DUP 8, ACCESS-LOSS-TOTAL 0, DROPPED 0, DEADTAIL 0,
realtrip 150/150, Gate 12 8/8. Improved: ALIGNED 214 -> 219, align LOOP-DIFF 22 -> 14, back-edge
MATCH 268 -> 275, LOST-LOOPS 20 -> 7, LOST-HEADERS 105 -> 35, Gate 6 LOOP-DIFF 27 -> 18. Worse but
within limits: align ORDER-DIFF 44 -> 47, EXTRA-LOOPS 5 -> 9, LATCH-DIFF 7 -> 9, EXTRA-HEADERS 10 -> 21.
Gate 13: U43 first 300 CONST-ID 18 -> 18, CFG-ID 14 -> 16, protos 7,667 -> 7,687 of 10,925, swaps
6,590 -> 6,590; U44 1-in-50 CONST-ID 107 -> 107, CFG-ID 79 -> 82, protos 1,494 -> 1,498 of 1,701,
swaps 0. Baselines ratcheted in `cert/gates.py`; Gate 14 count 50 -> 91.

## 5. Full 44.0.2 corpus, standard mode (`cert/u44_rawhash_roundtrip.py`, 11 jobs)

`before` = d51d877e (reproduces the 2026-09-30 `after` of the previous note exactly). The `after`
run was repeated: 54cab5a8 (measured BindingsUtil proto loss and 18 closure losses -> #46 narrowed,
S5 slots), 2c0124f5 (aborted when the coordinator added #51/#52), 6be95eb4 (measured 118 closure
losses from #52 -> copy reuse), final 65c46572. Intermediate summaries are kept in `evidence/`; only
before/final are compared below.

Denominators: 5,473 stock modules; 5,460 U44-format (13 stale U43-format modules fail loudly);
5,459 decompile (`Jade_Abilities_Chaos` still `map::at`). **Gate denominator 5,459**; 5,388 modules
with matching prototype counts, 74,339 prototypes compared.

| measurement | before (`d51d877e`) | after (`65c46572`) |
|---|---|---|
| decompile / recompile / deterministic | 5,459 / 5,459 / 5,459 | 5,459 / 5,459 / 5,459 |
| **CFG-ID first pass PASS / FAIL** | **4,017 / 1,442** | **4,171 / 1,288** |
| CONST-ID first pass PASS / FAIL | 5,339 / 120 | 5,339 / 120 |
| CONST-ID and CFG-ID both PASS | 4,010 | 4,164 |
| CFG-ID prototypes equal (aligned modules) | 70,873 / 74,339 | 71,189 / 74,339 |
| hash/string class swaps | 0 | 0 |
| compiler-closed within 5 passes | 5,375 | 5,418 |
| CFG-ID on compiler-closed bytecode | 3,966 | 4,082 |
| CONST-ID on compiler-closed bytecode | 5,252 | 5,297 |
| one-pass source / bytecode fixed point | 2,036 / 2,048 | 2,038 / 2,050 |
| wall time | 1,288 s | 1,556 s |

Transitions (`evidence/u44-full-transitions.json`):

- CFG-ID FAIL→PASS **154**, PASS→FAIL **0**. CONST-ID first pass: no change either way.
- Prototype level: 283 modules gain equal prototypes. **0 aligned modules lose one.** One module
  with mismatched prototype counts (WorldStateWindow, 184 stock vs 190 candidate, excluded from the
  aligned totals like ResourceConversion before) moves 118 -> 117: a structured `for` replaces a
  flattened state, so duplicated closures are defined in a different textual order.
- Compiler closure: 55 modules newly close, 12 no longer close (net +43). Of the 15 #40 losses, 7
  close again (AlchemistVial, DragonLuck, RhinoCharge, RhinoChargeReplicant, RevenantMark, EidolonMP,
  ColonistDoorDefenseMission). Of the 12 new non-closures, the opt-outs attribute Snake, TitaniaQuest
  and HelminthTransmissions to #44 (in HelminthTransmissions the old output had deleted the outer
  loop and its `IsPlaying` break; the restored loop's generic-for break arm is re-hoisted under a new
  selector each round) and TransitionalEvents to #46 (an unreduced compound condition); the rest
  (DuviriMissions, EidolonMissions, HexConquestReviveMechanic, WeaveMutalistBossMission,
  NecramechControl, VolatileAtmosphere, BursaSpawnScript, MoaStasisField) were not attributed
  individually (`tools/closure.sh` with each opt-out does it).
- **Compiler-closed CONST-ID PASS→FAIL 1: WaveDefend.** First pass is PASS/PASS; from round 2 a
  promoted loop part (#48 nested parts, `RENOVICE_NO_PROPER_NESTED_LOOP_PARTS=1` restores PASS) is
  dispatched after its sibling states, so a `table.sort` comparator closure moves behind three others
  and the prototype indices shift. Recorded, not fixed.

Attribution without another run (`evidence/regate_before_failures_*.json`): the 1,442 before
CFG failures rebuilt by the before pipeline and gated with 65c46572: 52 PASS; with
`RENOVICE_CFGID_LEGACY_OR_BLOCK=1` 0 PASS. All 52 are in the FAIL→PASS set, so **52 of the 154 are
the S5 gate normalization and 102 need the new pipeline**.

Named modules (before → after equal prototypes): MatchTagAndSourceType 3 -> 4/4 PASS,
SabotageOrokinEffects 4 -> 6/6 PASS, CorpusBow 3 -> 4/4 PASS, MawBugsBunny 7 -> 8/8 PASS, DialogTree
2 -> 3/3 PASS (S5), EE_Interface_Components_List 85 -> 86/88, AlchemistVial 15 -> 16/17 (closes at 2).

SyndicateScarves (`/Lotus/Scripts/Effects/SyndicateScarves.lua`, stock `0963cfb5…e9c8`): the
decompiled source is **byte-identical** to d51d877e (`a5fba35e…d187`,
`evidence/SyndicateScarves.65c46572.luau`).

### Remaining CFG-ID failure classes (after; first mismatch, by module; 1,288 FAIL)

LOAD -> LOAD 103, LOAD -> GETIMPORT 79, IF TRUTHY -> NAMECALL 55, IF TRUTHY -> GETIMPORT 49,
IF EQ -> RETURN 44, GETIMPORT -> LOAD 42, GETIMPORT -> GETIMPORT 41, GETIMPORT -> IF TRUTHY 38,
IF TRUTHY -> LOAD 33, SETLIST -> NEWTABLE 33, GETIMPORT -> NAMECALL 30, LOAD -> GETUPVAL 21.
PROTO_COUNT modules: 71 (unchanged).

Diagnosed residue of LOAD -> LOAD (t9 sample): the redundant numeric-for zero-trip guard
`if not ((step > 0 and i > lim) or ...) then for ... end end` (an IfThen with the prep as condition
plus a `for` opened from the FORNLOOP latch; behavior-neutral, CFG-only; InfestedLichPreDeath), and
live-range differences of dead constant loads in dispatcher states (RamSledSpawnAbility p3).

## 6. Limitations

- No in-game test; offline stock identity plus luau.exe fixture behavior only.
- 52 of the 154 module gains are a measurement correction (S5), not a decompiler change.
- Still open: a call inside a `for` break condition (`if not IsNull(s) and s == Target() then ... break
  end`) leaves the body an unreduced two-exit DAG; nested in `while true` the IsNull test is lost
  (`repro/for_break_call_condition_in_while.luau`). #46 is deliberately not applied there.
- #51 gives the exact behavior but not stock identity (`t[1] = v` is SETTABLEN, stock is SETLIST);
  folding the field stores into the constructor would be. A multret SETLIST tail into an observed
  table keeps the old rebuild (0 sites on 44.0.2).
- #47 and #52 are invisible to cfg-identity (LOADNIL/MOVE/CAPTURE dataflow); the fixtures record the
  blind spot. A dataflow-aware gate remains the follow-up.
- 8 of the 15 #40 closure losses and 12 new ones remain; one compiler-closed CONST-ID regression
  (WaveDefend) is recorded above.

## 7. Files

- `src/structan.h` unchanged; `src/emit.h` (#44, #45, #46, #48, #49), `src/expr.h` (#47, #51, #52),
  `src/cfg_identity_cmd.h` (S5).
- `cert/cfg_class_fixtures.py` (Gate 14, 91 checks), `cert/fixtures/cfg_class_2026_09_30/`
  (`for_body_order`, `nested_for_break`, `proper_prep_for`, `selector_residue`, `or_block`,
  `setlist_existing`, `capture_snapshot`), `cert/gates.py` (count, ratchets), `DEFECTS.md` #44–#52.
- `RESEARCH/CFG_FOR_LOOP_FIXES_2026-09-30/{evidence,tools,repro}`; the saved repros of the previous
  note are marked FIXED.

## Next step

The remaining LOAD -> LOAD residue is mostly the redundant zero-trip guard around a latch-opened
`for` (one IfThen claiming the prep while the loop opens from its latch). After that, the
compound-break-condition `for` body (the open repro) and the IF TRUTHY -> NAMECALL/GETIMPORT residue.
