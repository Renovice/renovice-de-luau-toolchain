# DeNativeRecompiler

> **Workspace migration notice (2026-08-25):** this is the authoritative DE
> Luau toolchain at `repos/toolchains/de-luau-toolchain`. Corpus tools now
> resolve `shared/corpus/de-luau-stock` through the root `WORKSPACE.json` (or
> `RENOVICE_CORPUS`). The milestone numbers later in this README are a dated
> development snapshot and must not be treated as the current project-wide
> status without rerunning the applicable gates.

One self-contained C++ toolchain for Warframe's DE `09 03` "Luau" bytecode:
**recompile** Luau source → bytecode the game runs, **decompile** bytecode → readable Luau, and manage the
script corpus — all from this folder, against one local knowledge base.

## Status

| Milestone | State |
|---|---|
| **M1** Luau frontend (drives `luau-compile.exe`) | done |
| **M2** Luau bytecode parser | done |
| **M3** DE container reader/writer | done — **5382/5382 byte-exact** round-trip |
| **M4** Transcoder (Luau → DE) | **done, in-game certified** — 10/10 cert modules, 0 unmapped ops over a 250-file sample |
| **M5** Corpus parity sweep | **done — 100.0000%** (see `M5_PARITY.md`) |
| **M6** C++ decompiler (DE → Luau) | **in progress — the active front.** M6a–M6d done; **M6e emission holds all remaining work: ALIGNED 112/300 vs the ORIGINAL bytecode, NAME-DIFF 0, 5386/5386 recompile** |
| **M7** Retire Python | blocked on M6 |

**Decode map is complete for all 77 opcodes** that occur in the corpus, which is M6's prerequisite.

## Working on the decompiler? Read these first

| file | what it gives you |
|---|---|
| **`.claude/M6_TRUTH.md`** | the distilled state — verified facts, and the beliefs that were measured and **disproven** (several cost days each) |
| **`.claude/PITFALLS.md`** | every way this project has fooled itself: tooling, metric, comparison, reasoning and process traps, plus the parallel-workspace rules |
| **`python cert/gates.py 300 150`** | all **six** release gates concurrently, one verdict, refuses to ship on any failure |
| `python cert/dropped.py 300` | GATE 5 — code paths emitted but **unreachable**. Nothing else detects this class |
| `python cert/allcats.py 300` | GATE 6 — **honest** access loss. `NAME-DIFF` only sees files with no loop difference, so it read 0 while 46 files were losing accesses (one of them 293) |

> **Before calling any metric change a regression, reproduce it with the pre-change binary.**
> Three hypotheses in a row were wrong on 2026-07-28; each was settled in minutes by running the
> snapshot binary against the same oracle. A baseline may only move with that measurement recorded
> beside it — `gates.py` carries the proof inline.

The goal is **complete 1:1 translation**: any of the 5386 scripts may be decompiled, edited and
recompiled, and a single wrong instruction makes that script unusable in game — so partial fidelity is
worthless.

### The largest known defect: the Proper-region state machine (FINDINGS #97)

`src/emit.h` emits `Proper` regions as a synthesized state machine (`local p29 = 0` / `if p29 == N
then ... p29 = M end`), relying on an **unchecked** comment-stated precondition that the region is
acyclic and that ascending block index is a topological order. Measured over the **full 5,386-file
corpus**:

| | found | after the fix |
|---|---|---|
| files emitting a state machine | 2,283 / 5,386 = 42.4 % | unchanged (by design) |
| **dropped code paths** | **1,075** | **741** (−31 %) |
| **affected files** | 514 (9.5 %) | **385 (7.1 %)** |
| synthesized states | 139,594 | 133,266 |

Root cause is **not** the structurer — its region tree is correct. `collect_blocks`
([src/emit.h:345](src/emit.h)) recurses through *every* child region kind including `NaturalLoop`,
so the `Proper` emitter **dissolves loops the structurer got right** and their back edges become
backward `p = N` transitions. Worst-hit files are core gameplay, including
`Lotus_Powersuits_PowersuitAbilities_OperatorTransference` — the exact file class this toolchain
exists to edit.

**Related and equally serious: the decompiler is DIVERGENT.** Each decompile→recompile cycle inflates
a script ~20 % at bytecode level with no fixed point (`BindingsUtil` 32,474 → 37,997 → 44,947 bytes;
2,285 → 3,739 → 5,367 code lines). A second edit operates on a materially different file.

Because the emitted form is a flat ascending `if` chain, a backward `p = N` targets a guard already
passed. `Lotus_Interface_Hub` turns a `Sleep(0)` polling loop into a one-shot. **No pre-existing gate
detected this class** — `realtrip` compares our output to itself, `NAME-DIFF` counts accesses,
`backedge` checks the CFG (which is correct; the loss happens later, at emission). Run
**`python cert/dropped.py 300`** to reproduce; it exits 1 while any dropped path remains.

Other defects kept deliberately visible: `BindingsUtil` (a real behavioural difference — a symptom of
the above, *not* the const-compare opcode bug it first appeared to be; it was invisible because
`realtrip.py` did not set `RENOVICE_NATIVE` while `align.py` always did, so the two headline gates
measured different compiler configurations) and `SetVortexWindPerZone` (emits register reads before
their assignment while passing every gate).

**A green gate is the absence of a detected failure, not proof of correctness.**

## Build

```bash
g++ -O2 -std=c++17 -static -static-libgcc -static-libstdc++ -o bin/derecomp.exe src/main.cpp
```
Static by design — no external DLLs. Don't rebuild while probe scripts are running (the exe stays open and
the link fails); build to a temp name and swap.

## Layout

```
src/
  main.cpp          CLI
  luau_bc.h         Luau bytecode parser (M2)
  de_container.h    DE 09 03 reader/writer (M3) — byte-exact
  de_namehash.h     FNV name hash (self-test: GetConfigBool == 0x4aec2dac)
  transcode.h       Luau -> DE opcode/const/lowering logic (M4)   <- the interesting file
cert/v9/            10-module in-game cert suite (100% opcode coverage)
data/               legacy opcode notes (see the warning below)
OPCODE_MAP.md       authoritative opcode reference (emit + decode)
METHODOLOGY.md      how to establish an opcode's meaning — read before touching the map
FINDINGS.md         dated log of every investigation and correction
```

## Quick start

```bash
# recompile a script
./bin/derecomp.exe recompile my.luau my.spawn.lua_B

# inspect what we produced
./bin/derecomp.exe de-disasm my.spawn.lua_B 0

# regression: container round-trip over the whole corpus
./bin/derecomp.exe de-roundtrip-batch ../../../shared/corpus/de-luau-stock
```

Deploy by copying the `.lua_B` into `OpenWF/CustomScripts/Inject/`, then press **F9** in-game. Results
appear in `%LOCALAPPDATA%\Warframe\EE.log` as `Script Error: <TAG>` lines (the cert scripts signal via
`error()` on purpose).

## Three coverage numbers — don't conflate them

| Metric | Value | Meaning |
|---|---|---|
| Cert-suite opcode coverage | **59/59 = 100%** | every **DE byte** we can emit is exercised by a self-checking in-game test (59 bytes ← 69 Luau op names, 7 of them dropped, 3 pairs sharing a byte; see `OPCODE_MAP.md` §0) |
| Corpus **decode** coverage | **77/77 = 100%** | every opcode appearing in real scripts is understood |
| Corpus **emit** coverage | **~95%** freq-weighted | the rest is FASTCALL hints (dropped by design) and ops we express differently |
| ~~Recompile `all_source_v13`~~ | **retracted** | v13/v14/v15 were decompiled with the OLD WRONG opcode map — a contaminated oracle. See `M5_PARITY.md`. M6 regenerates the corpus. |

## Before you change the opcode map

Read `METHODOLOGY.md`. Short version:

* A wrong table/name opcode causes an **access violation that can crash the game** — establish those
  offline from the corpus, never by crash-probing.
* `NAMECALL` is always a **tag-1 FNV hash** and field writes are always **tag-3 strings**. Global
  accesses and field reads use both forms in shipped code; preserve the renderer's
  `RENOVICE_HASH_GLOBAL` / `RENOVICE_HASH_FIELD` metadata instead of guessing.
* Test comparisons at **boundaries** (`a <= a`) and in **both polarities** — this is what hid the
  `JUMPIFLT`/`JUMPIFLE` swap for most of the project.
* **A cert result is only valid for the exact binary it ran against.** Change `transcode.h` → rebuild →
  round-trip regression → redeploy the full suite → F9 → all green → *then* claim it works.
* `data/wf_opcode_map.tsv` handler labels are **wrong** in several places (`0x07` "VEC_SUB", `0x22`
  "VEC_MUL", `0x2d` "GETGLOBAL"). The corpus overrules them.
