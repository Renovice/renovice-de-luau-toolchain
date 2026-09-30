# CFG-identity failure classes: four decompiler defects and one gate normalization gap — 2026-09-30

Build under test: Warframe 44.0.2 (content 2026.09.28.13.06, exe 2026.09.24.13.29, name-hash seed
`768e5ed0`). Stock input: the read-only extraction `work/u44-rawhash-2026-09-29/stock`
(5,473 modules; `manifest.json` SHA-256 `ad6491ef1def1f281e249ad66015a01979333d9481aea48e4a3342695aefb508`).
Repo work only. Nothing was written to the game install or OpenWF, nothing was deployed.
Branch `fix/natural-loop-header-cfg-gate`, parent commit `029ba1f`.

| role | SHA-256 |
|---|---|
| before (HEAD `029ba1f`, pipeline AND gate) | `b4221c48a26600c1c0e2e67c04ceb09e77927745adaf492b5d4c39a85aa055eb` |
| after (this change, `build.bat`, 0 warnings / 0 errors, pipeline AND gate) | `a788f0612a4327d27a45234202ec6474775e01ae72f6dd17060bb110eec18dc7` |
| `bin/luau-compile.exe` | `6156a05d9caf9fa84e58baeca79a244f47d86b8982f5425f2ca3e23b976ed2a4` |
| `bin/luau.exe` (fixture execution) | `a0f4edd1e80ef7d7afd223c061e1f3b753398152cb732abf57328a93b375053e` |

## 1. Choosing the class (hypothesis)

Baseline (fresh `before` run, identical to the 2026-09-29 `after`): CFG-ID 3,577 PASS / 1,882 FAIL.
First-mismatch classes by module: LOAD -> GETIMPORT 193, LOAD -> LOAD 178, LOAD -> CALL 145,
IF TRUTHY -> GETIMPORT 111, GETIMPORT -> GETIMPORT 94, PROTO_COUNT 71, IF TRUTHY -> NAMECALL 71.
By prototype, GETFIELD -> GETTABLEN 963 is concentrated in a handful of huge modules
(WF99PvPvEMission etc.), so fixing it moves few modules.

**Chosen: the LOAD -> {GETIMPORT, CALL, LOAD} family (516 modules, 3 of the top 3).** Leverage: one
mechanism was suspected behind all three (a constant load placed in a different position relative to
calls/imports), and each first mismatch is a LOAD, which is either a gate normalization gap
(unobservable placement) or a real emitter ordering defect.

Hypothesis H1: most LOAD -> CALL / LOAD -> GETIMPORT first mismatches are a gate normalization gap,
not a program difference. **Result: TRUE for LOAD -> CALL and most of LOAD -> GETIMPORT; FALSE for
LOAD -> LOAD** (a mix of real defects; one of them, #37 below, fixed here).

Method: the 400 smallest failing modules were rebuilt and gated in scratch (`tools/sample.py`,
`tools/regate.py`); each class was reduced to a minimal Luau fixture compiled with the real
toolchain, and every candidate cause was confirmed with an A/B opt-out on that fixture.

## 2. Root causes and fixes (each generic, each with an A/B opt-out)

### 2.1 Gate normalization gap S2 (`src/cfg_identity_cmd.h`) — LOAD -> CALL, LOAD -> GETIMPORT

Evidence (PostFade proto 0, `local t = 0; local info = obj:GetRegionMgr():GetLevelInfo(); while ...`):
stock and rebuild execute the same operations in the same order. Stock's block ends with the last
CALL; the rebuild's block ends with the MOVE that copies the CALL result. S1 put an unread pure load
"before the fixed terminator", i.e. before the CALL in stock and after it in the rebuild.

Fix S2: an unread pure node goes to the block end unless the terminator transfers control (branch,
loop op, return). A second defect surfaced on the Gate 12 fixture: a sunk node pruned the dispatch
environment with the liveness of its ORIGINAL index, so a pure node moved after a state definition
forgot that state (`IF EQK` then undecidable). Repositioned ("floating") nodes no longer prune; a
retained entry never changes a decision because a web's tests read only its own definitions.
`RENOVICE_CFGID_LEGACY_TAIL=1` restores the pre-S2 gate exactly (verified: it reproduces the old
gate's 1,882 FAIL / 3 PASS on all 1,896 kept `before` rebuilds).

Not loosened: the operand-slot ordering, label comparison and every branch are unchanged; the S2
fixture keeps two mutation controls (changed constant, swapped effects) that must FAIL and an
equivalent same-block reorder that must PASS.

### 2.2 Exitless terminal loop (`src/structan.h`, #35) — GETIMPORT -> RETURN

`WaitRepair(x) while true do Sleep(0) end end`: after reduction a single live node kept its self
edge; `reduce()` stopped at one live node, so the loop was emitted as `Sleep(0); return`. Fix: keep
reducing while the last node has a self edge (SelfLoop). `RENOVICE_NO_TERMINAL_SELF_LOOP`.

### 2.3 Loop headed by the function entry (`src/structan.h`, #36) — GETIMPORT -> GETIMPORT at depth 0

`while true do if not IsNull(gRegion) then ... end Sleep(0) end` as a whole function body. The
#31 repair skipped entry-containing candidates only when a clean candidate with a NON-entry head
existed; here the true head IS the entry, so the latch (Sleep) region headed the loop and the output
slept before the first test. Fix: the entry region may be the clean head when it holds the
original-CFG header of that cycle. `RENOVICE_NO_ENTRY_HEADED_LOOP`.

### 2.4 Latch sequenced before the entry (`src/structan.h`, #37) — LOAD -> LOAD at depth 0

FlickerOnOff: `while true do local t = 0 while t < 1 do ... end if loop == false then return end end`.
The entry's only graph predecessor is the outer latch, so every acyclic rule saw it as a private
successor and formed `Seq[latch, entry]`; the loop was rotated, the exit test ran first and the
inner counter read `nil` (`c1v3 = nil` after the implicit-nil canonicalizer). Fix: `npred(entry)`
counts the implicit call edge, so the entry is never absorbed as an arm or sequence tail.
`RENOVICE_NO_ENTRY_CALLER_EDGE`.

### 2.5 Import-chain snapshot (`src/emit.h`, #38) — GETIMPORT -> GETIMPORT (`_T` vs `_T."Name"`)

Weapon-attachment scripts use `local NAME = "TnChiselKanabo"; if _T[NAME] == nil then _T[NAME] = {} end`.
Stock bytecode: GETIMPORT `_T` + GETFIELD "TnChiselKanabo". Two text folds
(`canonicalize_paired_index_base_lifetimes` / `_temporaries`) printed `_T.TnChiselKanabo`, which Luau
compiles to ONE two-part GETIMPORT — a load-time snapshot in a safe environment. luau.exe proves the
difference: with `_T.RenoviceImportFixture = "stale"` predefined, stock and the fixed output print
`fresh`; the legacy output prints `stale`. Fix: when the folded base is a global root not assigned in
the body and the use is a read, the first field is spelled `["Name"]` (Luau never imports through an
index expression; the DE key class is decided by name in `transcode.h`, so constants are unchanged;
CONST-ID confirms). `RENOVICE_NO_IMPORT_CHAIN_GUARD`.

## 3. Regression fixtures (`cert/cfg_class_fixtures.py`, Gate 14 in `cert/gates.py`): 26/26

`cert/fixtures/cfg_class_2026_09_30/`: `terminal_self_loop`, `entry_headed_loop`,
`entry_outer_loop`, `import_chain` (each: runs, default behavior identical, default CFG-ID PASS,
opt-out CFG-ID FAIL, opt-out behavior differs) and `tail_load_order` (default PASS, legacy gate
FAILs the identical round trip, equivalent reorder PASS, 2 mutations FAIL). Gate 12 (natural loop)
stays 8/8.

## 4. Full 44.0.2 corpus, standard mode (`cert/u44_rawhash_roundtrip.py`, 11 jobs, full passes)

Exactly two full runs: `before` (b4221c48 as pipeline and gate) and `after` (a788f061 as pipeline and
gate). An earlier `after` attempt with an intermediate binary was stopped before completion when the
#37 defect was found; its partial output was discarded and it is not counted.

Denominators: 5,473 stock modules; 5,460 U44-format (13 stale U43-format modules fail loudly);
5,459 decompile (`Jade_Abilities_Chaos` still `map::at`). **Gate denominator 5,459**; 5,388
modules have matching prototype counts, 74,339 prototypes compared.

| measurement | before (`b4221c48`) | after (`a788f061`) |
|---|---|---|
| decompile / recompile / deterministic | 5,459 / 5,459 / 5,459 | 5,459 / 5,459 / 5,459 |
| **CFG-ID first pass PASS / FAIL** | **3,577 / 1,882** | **3,873 / 1,586** |
| CONST-ID first pass PASS / FAIL | 5,336 / 123 | 5,338 / 121 |
| CONST-ID and CFG-ID both PASS | 3,574 | 3,869 |
| CFG-ID prototypes equal (aligned modules) | 70,020 / 74,339 | 70,603 / 74,339 |
| hash/string class swaps | 0 | 0 |
| compiler-closed within 5 passes | 5,389 | 5,389 |
| CFG-ID on compiler-closed bytecode | 3,533 | 3,818 |
| CONST-ID on compiler-closed bytecode | 5,259 | 5,263 |
| one-pass source / bytecode fixed point | 2,040 / 2,052 | 2,040 / 2,052 |
| wall time | 1,192 s | 1,440 s |

Transitions (`evidence/u44-full-transitions.json`):

- CFG-ID FAIL→PASS **296**, PASS→FAIL **0**.
- CONST-ID FAIL→PASS 2 (SabotageOrokinEffects, 1999_LasriaStreets), PASS→FAIL 0.
- Prototype level: 475 modules gain equal prototypes, **0 modules lose one**.
- Compiler-closed CFG-ID PASS→FAIL 0; source fixed point unchanged in both directions (0 / 0).

Attribution without a third corpus run (`tools/regate_failures.py`, `evidence/before-failures-regated.json`):
the 1,896 kept `before` rebuilds (old pipeline) were re-gated with the new gate. 252 pass; with
`RENOVICE_CFGID_LEGACY_TAIL=1` the same binary reproduces the old gate exactly (1,882 FAIL, 3 PASS).
Of the 296 FAIL→PASS modules, **249 are gate-normalization gains** (the old rebuild was already
equivalent) and **47 need the new pipeline** (real decompiler corrections). The fixtures attribute
each pipeline fix individually; the corpus split between #35–#38 was not measured separately.

Named modules (before → after, equal prototypes / total): SpawnCleanDrone 7 → 8 / 9 (WaitRepair
fixed), CrewShipManager 6 → 7 / 7 PASS, FlickerOnOff 9 → 10 / 10 PASS, TnChiselKanabo 2 → 6 / 7,
GrnTwinBurstPistols 1 → 5 / 5 PASS, BoneSplitter 6 → 7 / 7 PASS, PostFade / CaptureShipDoor /
ObjectSway / TauDroneEffects PASS (gate S2). SyndicateScarves stays 17 / 17.

### Remaining CFG-ID failure classes (after; first mismatch)

By module (1,586 FAIL): LOAD -> LOAD 163, IF TRUTHY -> GETIMPORT 120, IF TRUTHY -> NAMECALL 85,
LOAD -> GETIMPORT 72, PROTO_COUNT 71, GETIMPORT -> GETIMPORT 60, GETIMPORT -> LOAD 45,
IF TRUTHY -> GETUPVAL 37, IF TRUTHY -> LOAD 36, IF EQ -> RETURN 36.

By prototype: GETFIELD -> GETTABLEN 963, GETIMPORT -> GETUPVAL 471, GETUPVAL -> GETIMPORT 425,
GETIMPORT -> GETIMPORT 407, LOAD -> LOAD 401, CALL -> GETTABLEN 345.

Diagnosed but not fixed (next class): **IF TRUTHY -> GETIMPORT / -> NAMECALL** contains real
dropped branches. `repro/compound_exit_multi_exit_loop.luau` (RailjackHudTrackers proto 2 shape):
`while IsNull(gGameRules) or not gGameRules:GameStarted() do Sleep(1) end` followed by another loop.
The loop body keeps two exits, no acyclic rule reduces it (the generalised if-then refuses the arm
because its break target is not a successor of the header, and the header is a loop header),
NaturalLoop collapses it unreduced, and the emitter drops the `IsNull -> Sleep` branch: the rebuild
calls `GameStarted()` on a null `gGameRules`. With a plain statement after the loop the same loop
reduces and passes. A fix needs a break-aware if-then reduction inside loops plus emitter support;
it was not attempted here.

## 5. Release gates (`python cert/gates.py 300 150`, final binary): ALL GATES PASS

`evidence/gates-final.{txt,json}`. Unchanged: ALIGNED 214, ORDER-DIFF 43, LOOP-DIFF 23, PROTO-DUP 8,
ACCESS-LOSS-TOTAL 0, DROPPED 0, DEADTAIL 0, realtrip 150/150, Semantic IR 22/22, 150/150, 11/11,
NAMECALL 11/11, CMPK 8/8. Improved: back-edge MATCH 266 → 267, LOST-LOOPS 22 → 21, LOST-HEADERS
107 → 106 (EXTRA-LOOPS 5, LATCH-DIFF 7, EXTRA-HEADERS 10 unchanged). Gate 12 8/8, Gate 14 26/26
(new). Gate 13: U43 first 300 CONST-ID 18 → 18, CFG-ID 12 → 14, protos 7,639 → 7,653 of 10,925,
swaps 6,590 → 6,590; U44 1-in-50 CONST-ID 107 → 107, CFG-ID 72 → 76, protos 1,483 → 1,491 of
1,701, swaps 0. Baselines ratcheted in `cert/gates.py`.

## 6. Limitations

- The gate still does not compare register dataflow or reg-reg comparison operand order.
- Most of the module-level gain (249 of 296) is a measurement correction, not a decompiler change.
- Re-decompiling the emitter's own dispatch-state output can still mis-structure (SyndicateScarves
  proto 13 on the compiler-closed pass: CFG-ID 16/17; the pass-1 build is 17/17). Not addressed.
- The import-chain guard spells `root["Name"]`, slightly less readable than `root.Name`; it is used
  only where the dotted form would compile to a different operation.
- No in-game test; everything here is offline stock identity plus luau.exe fixture behavior.

## 7. Files

- `src/cfg_identity_cmd.h` (S2 + floating nodes), `src/structan.h` (#35, #36, #37),
  `src/emit.h` (#38 helper used by both base folds).
- `cert/cfg_class_fixtures.py`, `cert/fixtures/cfg_class_2026_09_30/*.luau`, `cert/gates.py`
  (Gate 14, ratcheted Gate 13 baselines), `DEFECTS.md` #35–#39.
- `RESEARCH/CFG_CLASS_FIXES_2026-09-30/{evidence,tools,repro}`.

## Next step

Fix the IF TRUTHY -> GETIMPORT/NAMECALL family starting from `repro/compound_exit_multi_exit_loop.luau`
(break-aware if-then inside multi-exit loop bodies), then the remaining LOAD -> LOAD residue.
