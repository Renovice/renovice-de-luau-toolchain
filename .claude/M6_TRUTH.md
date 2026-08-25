# M6 DECOMPILER — WHAT IS TRUE, WHAT IS NOT

Everything below was **measured**, not reasoned. Where a belief was later disproven it is recorded as
disproven rather than deleted, because several of these wrong beliefs cost multiple days each and
would otherwise be re-derived.

Companion to `FINDINGS.md` (chronological log) and **`.claude/PITFALLS.md`** (every way this project
has fooled itself — read that before trusting any measurement). This file is the distilled state.

**Run all four gates with one command:** `python cert/gates.py 300 150` — runs concurrently,
~1m45s instead of ~15 min serial, and refuses to ship on any failure.
Set `RENOVICE_CORPUS` if working from a copied workspace, or the oracles measure nothing.
Last updated: 2026-07-28.

---

## 1. CURRENT STATE

| metric | value | meaning |
|---|---|---|
| **ALIGNED** | **112 / 300** | fully 1:1 vs the original bytecode |
| ALIGNED-minus-orphans | 12 | 1:1 once provably-dead protos are excluded |
| LOOP-DIFF | 123 | wrong loop structure |
| ORDER-DIFF | 45 | same accesses, different effect order |
| PROTO-DUP | 8 | a function emitted twice |
| **NAME-DIFF** | **0** | no file drops a named access |
| back-edge MATCH | 155 | loop-count bijection vs original |
| EXTRA / LOST loop headers | 20 / 99 files | invented / missing loops |
| realtrip (fidelity mode) | **149/150 — 1 REAL FAILURE** | `BindingsUtil`, see below |
| corpus recompile | 5386/5386 | everything compiles |

**OPEN DEFECT — `Lotus_Interface_BindingsUtil` (fidelity mode only).** Diagnosed WRONG twice before
the real cause was found; all three are recorded in FINDINGS #96 because the wrong ones were plausible:
1. "hidden by a 20s trace timeout" — raising the cap did change the verdict, but that was not it.
2. "false failure from gates.py concurrency" — isolating realtrip did NOT fix it.
3. **THE TRUTH: an ENVIRONMENT difference.** `align.py` has ALWAYS run in fidelity mode
   (`RENOVICE_NATIVE=JUMPXEQKN,...`); `realtrip.py` NEVER did. The file is **SAME without
   `RENOVICE_NATIVE` and DIFFERENT with it.** The two headline oracles were measuring DIFFERENT
   CONFIGURATIONS of the compiler for the entire project.

`realtrip.py` is now pinned to the same env as `align.py`. Honest fidelity-mode baseline: **149/150.**

The defect itself: the round trip TAKES A DIFFERENT BRANCH —
`S' : CALL Engine.IsPlayingWithController()` vs `S'': CALL Engine.IsMobile()` (+2 extra calls).
Opcode census, ORIGINAL vs our RECOMPILE: **`0x20` 6 -> 78** (13x over-emitted), `0x41` 6 -> 5,
`0x34` and `0x3a` correct. These are exactly the const-compare opcodes `emit.h` documents as
**never having had a ground-truth test** ("ZERO ground-truth cases exercise 0x20/0x41/0x34, so the
change was UNVERIFIABLE"). BindingsUtil in fidelity mode IS that test, and it fails.

Also known-wrong but gate-invisible: `SetVortexWindPerZone` emits reads of `c1v9` and its loop bounds
BEFORE they are assigned (`Normalize(nil)`). Loop count is right (2=2) and all 30 accesses are
preserved, so every gate passes — proof that a green gate is not proof of correctness.

Category totals reconcile exactly: 112 + 45 + 123 + 8 + 12 = 300. ORDER-DIFF rising is not a
regression — LOOP-DIFF fell 25, of which 7 became ALIGNED and 18 became ORDER-DIFF, which is a
strictly less severe class.

**GOAL:** complete 1:1 translation. Any of the 5386 scripts may be decompiled, edited and recompiled;
ONE wrong instruction makes that script unusable in game. Partial fidelity is worthless.

---

## 2. THE REMAINING WORK IS 10 SHAPES, NOT 183 PROBLEMS

183 failing files cluster into **10 distinct failure shapes**; the top three are 65% of them.

| files | shape |
|---|---|
| 53 | LOST FORNPREP/FORNLOOP — numeric-for lost |
| 36 | EXTRA FORGPREP/FORGLOOP — generic-for duplicated |
| 30 | both together |
| 27 | ORDER-DIFF — effect order |
| 12 / 9 / 6 / 1 / 1 | mixed loss variants |
| 8 | PROTO-DUP |

They reduce to **~3 mechanisms**: numeric-for LOST (~106 files), generic-for DUPLICATED (~66 files),
effect ORDER (27). Because the pipeline is deterministic, a shape once fixed stays fixed for every
file that has it. **Attack shapes by frequency, never individual files.**

---

## 3. WHAT IS TRUE — bytecode facts (all verified against real DE bytecode)

- **DE bytecode is Luau v9, renumbered.** Header `09 03`. Our `luau-compile.exe` emits `0c 03` (v12)
  by default and `09 03` with `--fflags=false`. Upstream `LBC_VERSION_TARGET` is 9; v12 is gated by
  `FFlag::LuauBytecodeCostModel` (11 = `LuauEmitCallFeedback`, 10 = `DebugLuauUserDefinedClasses`).
- **The v9 switch is BLOCKED** — `luau_bc.h::read()` unconditionally reads a per-proto `dsize` varint
  (the v12 cost-model prefix) that v9 does not have. Feeding it v9 gives `parse error: rd_u8: past
  end`. It must be made version-aware first.
- **For plain Lua the v9→v12 opcode delta is ZERO.** v10/v11 add Roblox-internal ops
  (`NEWCLASSMEMBER`, `CALLFB`, `CMPPROTO`) never emitted for our input; v12 adds no opcodes at all.
- **"Luau v9" ≠ "DE v9 container".** DE renumbers opcodes (`CALL` = 0x54 vs stock 0x15), so the
  transcoder is mandatory at ANY Luau version.
- **Opcode crash-safety is CLEAN.** 5386 files / 82,059 protos yield **77 attested opcode bytes**;
  static analysis of every transcoder path yields **77 emittable**. The sets are identical — we can
  emit nothing the shipping game does not already execute. (Residual risk is wrong OPERANDS on a
  correct opcode; `transcode.h` has open TODOs on NEWCLOSURE width and SETLIST/SETTABLEN.)

### Loop register layouts — measured, not from documentation
- **Numeric for:** `A+0 = limit`, `A+1 = step`, `A+2 = index` **and the user-visible variable**.
  Bytecode.h's comment implies the variable is at A+3; **that is not what Luau materialises.**
  Verified in real DE bytecode (`ImGuiSeasonOverride`): `FORNPREP A=5`, body reads **R7 = A+2**, never
  R8. Fiu's interpreter likewise updates only `stack[A+2]`.
- **Generic for:** `A+0 = generator`, `A+1 = state`, `A+2 = control index` (not user-visible),
  user variables at **A+3 .. A+2+nvars**, where `nvars = aux & 0xFF` and **bit31 = ipairs fast path**.

### Loop CFG shapes — the two preps are ASYMMETRIC
- **FORNPREP is CONDITIONAL** (it can prove zero iterations from limit/step/index alone):
  preheader = the FORNPREP block · header = its **fallthrough** · latch = FORNLOOP ·
  exits from **both** FORNPREP and FORNLOOP.
- **FORGPREP is UNCONDITIONAL** (the iterator has not been called yet; that call *is* FORGLOOP):
  preheader = the FORGPREP block · **header = the FORGLOOP block** (it dominates the whole body) ·
  latch = last body block · exit from FORGLOOP only.
- **A preheader is never part of its loop** (LLVM: "the preheader dominates the loop without itself
  being part of the loop"). Correct region shape is `Seq[preheader, LoopNode]`.
- **while vs repeat** is purely structural: conditional test at the HEADER = `while`; at the LATCH =
  `repeat/until`.
- **A back edge is `u→v` where `v` DOMINATES `u`.** Loop count = number of **distinct back-edge
  headers** — two back edges into one header are ONE loop with two latches, not two loops.

### Where the bug is
- **The structurer is 98.1% correct**: exactly one loop-kind region per back-edge header in
  **18,273 / 18,621** protos (`derecomp loopfork`). **The loop bug is in the EMITTER**, which ran a
  second, independent opcode-scanning loop detector that disagreed with it.

---

## 4. WHAT IS NOT TRUE — beliefs that were measured and disproven

Each of these was believed, acted on, and cost real time.

- **NOT benign.** Duplicate loop wrappers were called "CLASS-A harmless" because NAME-DIFF stayed 0.
  **They NEST** — the same iterator triple emitted at depth 2 and again at depth 3, so the body runs
  **N² times instead of N**. A real, severe correctness bug.
- ~~**The emitter does NOT drop source code.**~~ **RETRACTED 2026-07-28 (#97).** True for the
  unwrapping failures — there the SOURCE was complete (`mMovie` 49 = 49) and the RECOMPILE lost
  accesses at COMPILE time. **But the `Proper` state-machine emitter DOES drop code at EMISSION
  time**: a backward `p<id> = N` targets a guard already passed in the flat ascending `if` chain, so
  that path is unreachable in the source itself. 46 such transitions in the first 300 files. Both
  mechanisms are real; do not assume "the source is always complete".
- **Unwrapping does NOT change `return` scope.** In Lua a `return` exits the FUNCTION regardless of
  loop nesting. The real mechanism is **REACHABILITY**: inside a loop body `do return end` runs only
  if that iteration executes, so code after the loop stays reachable; unwrapped, it becomes
  unconditional and everything after it is dead, so the compiler discards the tail.
- ~~**Proper-region flattening is NOT the dominant lost-loop cause.**~~ **RETRACTED 2026-07-28
  (#97): the measurement asked the wrong question.** "11 of 1204 Proper regions directly contain a
  loop-kind part" counted regions holding a sub-region **already classified as a loop**. The defect
  is regions holding a cycle that was **never classified as a loop at all** — exactly the population
  that count excludes. Re-measured (`cert/dropped.py 300`): **168/300 files (56 %)** emit a Proper
  state machine, 1,011 machines, 23,643 states, and **46 backward + 1 self transition = 47 silently
  dropped paths across 15 files**. Proper
  flattening is the **largest known defect in M6e**. *(The rule "verify a diagnosis's SCALE before
  implementing" survives — what failed was choosing what to count.)*
- **FIRST-CLAIMANT is NOT correct.** Tested directly (Rule C): NAME-DIFF 12, accesses lost
  (JSON 176→170). **INNERMOST / CANONICAL wins** — the outer claimant's extent is larger than the
  loop, so wrapping there pulls post-loop code inside the `for`.
- **Containment-based ownership does NOT work.** Smallest region containing header+latch → MATCH 81;
  containing the whole body → 87; both far below the 112 baseline at the time.
- **Module-level hoisting does NOT fix PROTO-DUP.** The shared closures carry CAPTURES, and a
  capture-bearing closure cannot be hoisted to module level — its captures reference enclosing-scope
  locals. Would need nearest-common-scope hoisting plus capture rebinding.
- **Rule-reordering in the structurer does NOT implement "loops before conditionals".** Moving
  NaturalLoop ahead of Proper made things worse (MATCH 113→111). The literature's ordering assumes a
  loop forest computed UP FRONT (Ghidra's `orderLoopBodies`), not reshuffling greedy rules — the
  NaturalLoop rule's own comment says it needs its interior reduced first.

---

## 5. THE STANDING RULES

1. **NO SUPPRESSION.** Never remove a loop wrapper from around already-placed code — not
   conditionally, not as a trade. The second wrapper must never be **created**. Ten attempts violated
   this and every one lost code (`FINDINGS` #60d, #67, #72, #74, #76, #83, #84, #86, #87, #90).
2. **Only comparison against the ORIGINAL finds a consistent misreading.** `recompile` writes back
   whatever `decompile` misread, so round-trip and self-trace oracles are blind by construction.
   Defects #56 and #58 each survived 5386/5386 round-trips and 150/150 traces.
3. **Verify a diagnosis's SCALE before implementing it.** The Proper-flattening fix would have been a
   1204-region rewrite for 11 cases. A 2-minute count prevented it.
4. **Look at the DISTRIBUTION before optimising.** Clustering the failures took 2 minutes and reframed
   twenty turns of work.
5. **Oracle agreement is not proof.** Two oracles called the N² nesting bug clean because both were
   insensitive to it by construction.

---

## 6. MEASUREMENT TRAPS — each of these has produced a false conclusion here

- **Build only with `build.bat`** (msys2 ucrt64, `-static`). A plain `g++` build exits `3221225785`
  (0xC0000139, entrypoint not found) under Python, every diff comes back EMPTY, and that reads as
  "perfect agreement". **An oracle that cannot run reports success.**
- **Empty output is a FAILURE signal, never a clean result.** Always check exit codes.
- **Block IDs are PER-PROTO and collide across protos.** Never aggregate them; group by proto.
- **Proto INDEXES shift between emitter variants** (emitting one fewer `for` reorders them), so
  `proto[i]` on two sides is often a different function. **Match by CONTENT.**
- **`realtrip` wraps bodies in `pcall`** and can MASK a dropped access. Never use it alone to prove
  fidelity. It gave a false pass on a path that lost 8 accesses.
- **A realtrip TIMEOUT is not a DIFFERENCE.** One file needs >20s; at 90s it returns SAME.
- **`cert/*.py` resolve the corpus RELATIVELY** (`ROOT/../Transpiler/protos2/cache`). Copying the
  project to a temp dir BREAKS this — sub-agents doing so measured a different corpus and reported a
  wrong baseline that nearly discarded the project's biggest win.
- **NAME-DIFF counts named ACCESSES, not structure.** It is blind to an empty duplicate wrapper.
- **Always state whether a number came from the ORIGINAL, our SOURCE, or our RECOMPILE.** Conflating
  these produced several false conclusions.

---

## 7. THE ORACLES AND WHAT EACH IS FOR

| oracle | measures | blind to |
|---|---|---|
| `cert/align.py N` | ALIGNED / NAME-DIFF / LOOP-DIFF / ORDER-DIFF / PROTO-DUP vs ORIGINAL | — the primary gate |
| `cert/backedge.py N` | loop-count bijection vs ORIGINAL | the right instrument for loops |
| `cert/realtrip.py N` | behavioural equivalence S′ vs S″ | pcall-masked drops; self-consistent only |
| `derecomp loopfork` | structurer loop-kind regions vs back-edge headers | decides emitter-vs-structurer |
| `derecomp backedges` | back edges / headers / mapped loops | — |
| **access count vs ORIGINAL** | **GETIMPORT+NAMECALL+GETFIELD in `skeleton --live`** | **the mandatory gate** |

### The four gates — a change ships only if ALL pass
1. **ZERO ACCESS LOSS** — per file, recompile count == original count. Known values:
   JSON 176 · BeaconInProgress 525 · LotusBackground 190 · InfestationCyst 127 ·
   AllianceView 987 · Grid 672 · Utilities 784.
2. **NAME-DIFF must stay 0.**
3. **realtrip must not regress** (150/150; one file needs a raised budget).
4. **ALIGNED must improve.**

### Required environment for every oracle
```
RENOVICE_NATIVE_GLOBALS=1
RENOVICE_NATIVE=JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP
```
Without these the transcoder applies injection-oriented LOWERINGS (globals via `_G`, JUMPXEQK lowered)
and the oracle measures configuration rather than fidelity. `realtrip.py` used to inherit the caller's
shell and silently measured the wrong thing — its env is now pinned in the script.

---

## 8. THE ARCHITECTURE THAT WORKS — PLAN / RENDER

Loop identification belongs to the STRUCTURER; the emitter must not re-derive it. Every reference
decompiler orders it that way (Ghidra `orderLoopBodies` before `collapseInternal`; angr/Phoenix
structures cyclic before acyclic; Cifuentes identifies loops before conditionals; unluac instantiates
typed `ForBlock` during structuring and only `print()`s at emission).

Emission is **two phases**:
- **PLAN** — run the entire walk with `planning = true`; identical control flow, output discarded;
  record every loop claim as `plan_claim[loopkey] = (score, region_id)`.
- **RENDER** — re-run with `plan_winner`; a region that is not the winner emits its parts and returns
  **without ever opening a wrapper**. Nothing is unwrapped after placement, by construction.

**The winning tie-break (shipped, #93):**
```
score = (canonical ? 2000 : 0) + plan_nest
canonical  ==  this region's head block IS the loop's prep block or its header block
               (i.e. it genuinely owns the `for` header TEXT)
ties break on nesting depth; loopkey prefers latch_blk when present
```
This took ALIGNED 91 → 105, EXTRA-LOOPS 127 → 18 files, MATCH 113 → 134, with NAME-DIFF still 0 and
every access count exact.

---

## 9. NEXT TARGET

**Shape 1 — numeric-for LOST.** 53 files standalone, ~106 files in total; the single largest
mechanism. It GREW (53 → 131 lost headers) as the accepted cost of #93, so the mechanism is fresh and
traceable to a known change rather than historical.

Then: generic-for duplicated (~66 files), then ORDER-DIFF (27), then PROTO-DUP (8, needs
nearest-common-scope hoisting).

**Restore point:** `/tmp/*_SHIPPED_91.*` holds the pre-#93 tree if a regression needs isolating.
