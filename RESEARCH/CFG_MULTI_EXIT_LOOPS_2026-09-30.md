# Multi-exit loop bodies, loop-carried nil and gate S3/S4 — 2026-09-30

Build under test: Warframe 44.0.2 (content 2026.09.28.13.06, exe 2026.09.24.13.29, name-hash seed
`768e5ed0`). Stock input: the read-only extraction `work/u44-rawhash-2026-09-29/stock` (5,473
modules; `manifest.json` SHA-256 `ad6491ef1def1f281e249ad66015a01979333d9481aea48e4a3342695aefb508`).
Repo work only: nothing written to the game install or OpenWF, nothing deployed, nothing pushed.
Branch `fix/natural-loop-header-cfg-gate`, parent commit `b51d08a`.

| role | SHA-256 |
|---|---|
| before (HEAD `b51d08a`, pipeline AND gate) | `a788f0612a4327d27a45234202ec6474775e01ae72f6dd17060bb110eec18dc7` |
| after (this change, `build.bat`, 0 warnings / 0 errors, pipeline AND gate) | `d51d877e042353d852916c67a572a74a40201f5e57aeb412cfd86bcd68716d69` |
| `bin/luau-compile.exe` | `6156a05d9caf9fa84e58baeca79a244f47d86b8982f5425f2ca3e23b976ed2a4` |
| `bin/luau.exe` (fixture execution) | `a0f4edd1e80ef7d7afd223c061e1f3b753398152cb732abf57328a93b375053e` |

The `build.bat` output is byte-identical to the scratch build of the same source (`--no-insert-timestamp`).

## 1. Target and hypothesis

Target: first-mismatch classes IF TRUTHY -> GETIMPORT (120 modules) and IF TRUTHY -> NAMECALL (85),
already diagnosed as containing a real dropped branch (`CFG_CLASS_FIXES_2026-09-30/repro/`).

H1: a loop whose continuation test is a short-circuit chain with a statement operand is collapsed
by NaturalLoop with its interior unreduced, and the emitter drops the branch between the unreduced
parts. **Result: TRUE** (§2.1). The class also contained a second real defect (§2.2) and two gate
normalization gaps (§2.3, §2.4).

## 2. Root causes and fixes (each generic, each with an A/B opt-out)

### 2.1 Loop-body DAG (`src/structan.h`, DEFECTS #40)

Minimal shape (`while IsNull(g) or not g:GameStarted() do Sleep(1) end` followed by another loop):

    H: IsNull(g)            -> {L (truthy), C}
    C: g:GameStarted()      -> {exit (truthy), L}
    L: Sleep(1)             -> H

`is_loop_header(n)` is true for EVERY node of a cycle (a predecessor is reachable from it), so the
generalised if-then never fires inside a loop; the two-successor rules need a private arm that joins
or terminates; C's arms are the latch and the exit. Nothing matches, NaturalLoop collapses {H, C, L}
unreduced, and the emitter (fall-through between parts, `if c then break end` for a single leaving
arm) drops H's branch. luau.exe on the rebuilt fixture: `attempt to index nil with 'GameStarted'`.
When a plain statement follows the loop the exit arm is private and the loop happens to reduce,
which is why only some modules showed it.

Fix: before a NaturalLoop collapse, reduce its body as the acyclic graph it is once the back edges
and the exit edges are cut; the NaturalLoop then holds one structured child. The exit edges stay in
the CFG, so the emitter's loop-exit check still prints each as `if c then break end`. Admitted only
where that rendering is exact; otherwise the established collapse is unchanged:

- at most one exit target; exactly one latch part, whose only successor is the header;
- some body part has two in-body successors (the branch the old emission drops);
- every loop-leaving block edge is one arm of a conditional two-way branch, not a FOR prep/latch;
- the cut body reduces to one region; no loop-leaving edge sits inside a nested loop or Proper
  region of it (a `break` there leaves only the inner construct);
- the latch stays outside every Proper region of the cut body (the Proper dispatcher follows real
  CFG edges and would treat the cut back edge as an internal cycle; the same rule as #32).

With one latch that every body node reaches, the latch is the cut DAG's only sink, so no terminal-arm
rule can mistake the latch (a `continue`) for a `return`. `RENOVICE_NO_LOOP_BODY_DAG=1` restores the
old collapse. RailjackHudTrackers (the diagnosed module): 3/4 -> 4/4 PASS.

### 2.2 Loop-carried nil (`src/emit.h`, `canonicalize_implicit_nil_reads`, DEFECTS #41)

Found while writing the behavior fixture for 2.1. `local owner = nil; while true do if IsNull(owner)
then owner = Find() end ... end`: the flat function-local declaration drops the entry LOADNIL, and
the canonicalizer placed `owner = nil` before the first TEXTUAL read, i.e. inside the loop. A later
printed definition runs before that read on every iteration after the first, so the variable was
reset each iteration. cfg-identity cannot see it (LOADNIL is epsilon): the legacy output PASSES the
gate while luau.exe prints an extra `bind`. Corpus witness: AddAscarisNegator `OnPlayerSpawned`
(`lastSuit` reset every 0.1 s, so the skin re-applies forever) passed CFG-ID before this change.

Fix: a first read inside a loop gets its nil before the OUTERMOST enclosing loop — the stock
`local x = nil` position. That is exact whether or not the loop assigns the register (nothing
earlier mentions it, so it is nil on loop entry either way). **Rejected on measurement:** hoisting
only loop-assigned registers regressed AddAscarisNegator p0 (`IF EQ -> IF EQK`): the sibling nil
left at the read let the compiler fold `lastAvatar` into a constant compare. `RENOVICE_NO_LOOP_NIL_HOIST=1`
restores the old placement.

### 2.3 Gate S3: truthiness no-op (`src/cfg_identity_cmd.h`, DEFECTS #42)

Stock keeps the final test of an empty-bodied `if Engine.X() and IsNull(u) then end` (JUMPIF with both
successors the same block); the decompiler prints the operand calls without the dead test
(TradingPostScreenLauncher). A truthiness test runs no metamethod, so a test whose two successors
resolve to the same node in the same dispatch state is bypassed. Comparisons (EQ/LT/LE) are not
folded: they can invoke `__eq/__lt/__le`. `RENOVICE_CFGID_LEGACY_TRUTHY_NOOP=1` disables S3.

### 2.4 Gate S4: loop-operand slot (`src/cfg_identity_cmd.h`, DEFECTS #43)

S1 orders sunk pure loads by the operand slot they feed. FOR*PREP/FOR*LOOP read the range A..A+2,
but A+1/A+2 were matched against the B/C fields (B is a jump offset), so identical `for i = 400, 415`
bound loads got allocation-dependent slots (StreamShipQuestLayers p3, LOAD -> LOAD). S4 slots by the
offset from A. `RENOVICE_CFGID_LEGACY_LOOP_SLOT=1` restores the old rule. With both legacy switches
the final binary reproduces the old gate exactly on all 1,586 kept before-failures (0 PASS,
`evidence/before-failures-regated-legacy-switches.json`).

## 3. Semantics (luau.exe; stock vs old output vs fixed output)

`cert/fixtures/cfg_class_2026_09_30/` (own code, mock natives):

| fixture | stock trace | old output (opt-out) | fixed output |
|---|---|---|---|
| `compound_exit_loop` (globals, GETIMPORT shape) | 8 sleeps, `started`, `ready` | `attempt to index nil with 'GameStarted'`, CFG FAIL | identical, CFG PASS |
| `compound_exit_namecall` (upvalues, NAMECALL shape) | master after 2nd IsMaster | nil-index error, CFG FAIL | identical, CFG PASS |
| `loop_carried_nil` | `bind a` once | extra `bind b`, CFG **PASS** (blind spot) | identical, CFG PASS |
| `truthy_noop` (S3) | — | legacy gate FAILs the identical round trip | PASS; body / early-return mutations FAIL |
| `loop_prep_slots` (S4) | — | legacy gate FAILs the identical round trip | PASS; changed bound FAILs |

Negative control: the before binary (a788f061) fails exactly the six new default checks of Gate 14.

## 4. Regression gate (`cert/cfg_class_fixtures.py`, Gate 14 in `cert/gates.py`): 50/50

`python cert/gates.py 300 150` with d51d877e: **ALL GATES PASS** (`evidence/gates-final.{txt,json}`).
Unchanged: ALIGNED 214, PROTO-DUP 8, ACCESS-LOSS-TOTAL 0, DROPPED 0, DEADTAIL 0, realtrip 150/150,
Semantic IR 22/22, 150/150, 11/11, NAMECALL 11/11, Gate 12 8/8. Moved: back-edge MATCH 267 -> 268,
LOST-LOOPS 21 -> 20, LOST-HEADERS 106 -> 105; align LOOP-DIFF 23 -> 22, ORDER-DIFF 43 -> 44 (one
module moved between the two); Gate 6 LOOP-DIFF 28 -> 27. Gate 13: U43 first 300 CONST-ID 18 -> 18,
CFG-ID 14 -> 14, protos 7,653 -> 7,667 of 10,925, swaps 6,590 -> 6,590; U44 1-in-50 CONST-ID
107 -> 107, CFG-ID 76 -> 79, protos 1,491 -> 1,494 of 1,701, swaps 0. Baselines ratcheted.

## 5. Full 44.0.2 corpus, standard mode (`cert/u44_rawhash_roundtrip.py`, 11 jobs)

Exactly two full runs: `before` (a788f061 as pipeline and gate; reproduces the 2026-09-30 `after`
exactly) and `after` (d51d877e as pipeline and gate). Scratch sampling between them used rebuilds of
the before-failures and the before-passes (`tools/sample.py`, `tools/regate.py`), not full runs.

Denominators: 5,473 stock modules; 5,460 U44-format (13 stale U43-format modules fail loudly);
5,459 decompile (`Jade_Abilities_Chaos` still `map::at`). **Gate denominator 5,459**; 5,388 modules
with matching prototype counts, 74,339 prototypes compared.

| measurement | before (`a788f061`) | after (`d51d877e`) |
|---|---|---|
| decompile / recompile / deterministic | 5,459 / 5,459 / 5,459 | 5,459 / 5,459 / 5,459 |
| **CFG-ID first pass PASS / FAIL** | **3,873 / 1,586** | **4,017 / 1,442** |
| CONST-ID first pass PASS / FAIL | 5,338 / 121 | 5,339 / 120 |
| CONST-ID and CFG-ID both PASS | 3,869 | 4,010 |
| CFG-ID prototypes equal (aligned modules) | 70,603 / 74,339 | 70,873 / 74,339 |
| hash/string class swaps | 0 | 0 |
| compiler-closed within 5 passes | 5,389 | 5,375 |
| CFG-ID on compiler-closed bytecode | 3,818 | 3,966 |
| CONST-ID on compiler-closed bytecode | 5,263 | 5,252 |
| one-pass source / bytecode fixed point | 2,040 / 2,052 | 2,036 / 2,048 |
| wall time | 1,365 s | 1,478 s |

Transitions (`evidence/u44-full-transitions.json`):

- CFG-ID FAIL→PASS **144**, PASS→FAIL **0**. CONST-ID FAIL→PASS 1, PASS→FAIL 0.
- Prototype level: 241 modules gain equal prototypes, **0 modules lose one**.
- Compiler-closed CFG-ID FAIL→PASS 110, PASS→FAIL 0.
- **Regression recorded, not hidden:** 15 modules no longer close within 5 passes (1 newly closes),
  so 16 closed CONST-ID PASS results become "not measured" (closed CONST-ID 5,263 -> 5,252; no
  closed CONST-ID PASS→FAIL). In all 15 the first-pass CFG-ID equal count is unchanged or higher
  (Platform 3 -> 4/4 PASS). `tools/closure.sh` attributes it to #40 (`RENOVICE_NO_LOOP_BODY_DAG=1`
  closes AlchemistVial at pass 3): the old run-together emission of these loops happened to be a
  fixed point; the structured body now contains a nested multi-exit loop whose escape selector grows
  by one variable per re-decompile (AlchemistVial p7 `c7v37 -> c7v39`). Excluding Proper regions or
  FOR preps from the cut body does not restore closure (measured, rejected).
- Source fixed point: 6 True→False, 2 False→True.

Attribution without a third run (`evidence/before-failures-regated-*.json`): the 1,586 before-failures
rebuilt with the before pipeline and gated with d51d877e: 114 PASS (S3 alone: 97). All 114 are among
the corpus FAIL→PASS set, so **114 of the 144 are gate normalization gains and 30 need the new
pipeline** (#40/#41). The first-mismatch class of the 144 before the change: IF TRUTHY -> GETIMPORT 51,
IF TRUTHY -> NAMECALL 22, LOAD -> LOAD 17 (S4), IF TRUTHY -> RETURN 15, IF TRUTHY -> GETUPVAL 13.

SyndicateScarves (`/Lotus/Scripts/Effects/SyndicateScarves.lua`, stock `0963cfb5…e9c8`): the
decompiled source is **byte-identical** before and after (`a5fba35e…d187`), rebuild `145bc5cc…18cc`
(same as the 2026-09-29 fixed rebuild), CFG-ID 17/17, CONST-ID 17/17
(`evidence/SyndicateScarves.d51d877e.luau`). The Syandanas v2 candidate built from it is unaffected.

### Remaining CFG-ID failure classes (after; first mismatch, by module; 1,442 FAIL)

LOAD -> LOAD 143, PROTO_COUNT 71, LOAD -> GETIMPORT 69, GETIMPORT -> GETIMPORT 58,
GETIMPORT -> LOAD 50, IF TRUTHY -> NAMECALL 46, IF TRUTHY -> GETIMPORT 45, IF EQ -> RETURN 39,
GETIMPORT -> IF TRUTHY 36, ORK -> GETIMPORT 31, SETLIST -> NEWTABLE 31, IF TRUTHY -> LOAD 29.

By prototype: GETFIELD -> GETTABLEN 964, GETIMPORT -> GETUPVAL 470, GETUPVAL -> GETIMPORT 427,
GETIMPORT -> GETIMPORT 393, LOAD -> LOAD 370, CALL -> GETTABLEN 345.

## 6. LOAD -> LOAD (next class) — partial

Taken only as far as the S4 normalization (17 modules of the class). Diagnosed, not fixed:

- MatchTagAndSourceType p2 and similar: a numeric `for` inside a Proper region is flattened into the
  dispatcher's raw FORNPREP predicates (`IF LT` chains) — the stock FORNPREP/FORNLOOP are gone.
- `for i = 1, 3 do while c do ... end; print(i) end` (numeric-for body with a nested loop followed
  by a statement): the for-body parts are emitted in region-id order, so `print(i)` runs BEFORE the
  inner loop (scratch fixture `f1`; the generic `for` shape passes).
- A `for` with `idx = i; break` inside a `while true` NaturalLoop loses its `break` (scratch `b4`;
  also wrong before this change; at top level the whole-prototype CFG renderer handles it).

## 7. Limitations

- No in-game test; offline stock identity plus luau.exe fixture behavior only.
- 114 of the 144 module gains are measurement corrections (S3/S4), not decompiler changes.
- The compiler-closure loss in §5 is open.
- cfg-identity still does not compare register dataflow; #41 shows a real class it cannot see.
  A LOADNIL-aware or dataflow check would be the gate-side follow-up.

## 8. Files

- `src/structan.h` (#40), `src/emit.h` (#41), `src/cfg_identity_cmd.h` (S3, S4).
- `cert/cfg_class_fixtures.py` (Gate 14, 50 checks), `cert/fixtures/cfg_class_2026_09_30/`
  (`compound_exit_loop`, `compound_exit_namecall`, `loop_carried_nil`, `truthy_noop`,
  `loop_prep_slots`), `cert/gates.py` (count, ratchets), `DEFECTS.md` #40–#43.
- `RESEARCH/CFG_MULTI_EXIT_LOOPS_2026-09-30/{evidence,tools,repro}`.

## Next step

Fix the numeric-for defects of §6 (for-body part order, lost `break` in a nested for, FOR loops
flattened inside Proper dispatchers), then look at the escape-selector growth behind the closure loss.
