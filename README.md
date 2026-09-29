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
| **M6** C++ decompiler (DE → Luau) | **Raw default `decompile-mod`: 360/360 strict source-and-bytecode fixed points.** Eleven distinct witnesses remain exact through **10 cycles**, the independent 360-file audit finds **0 lost named accesses**, and the canonical 300/150 release suite passes. The 19 added executable regression fixtures pass 3,213 case assertions across source and two recovered cycles. This is a selected-sample certificate; see [the raw closeout](RESEARCH/RAW360_STRICT_2026-09-05/RESULTS.md) for hashes, evidence, and limits. |
| **M7** Retire Python | blocked on M6 |

**Decode map is complete for all 77 opcodes** that occur in the corpus, which is M6's prerequisite.

## Working on the decompiler? Read these first

> **Closure-index rule:** `NEWCLOSURE.Bx` indexes the current prototype's child
> list; `DUPCLOSURE.Bx` indexes a tag-6 closure constant. The `ir` command now
> prints both the operand namespace and resolved flat/global prototype, for
> example `child[132] -> proto[349]`. Run `closure-index-selftest` before using
> IR output for runtime-hook ownership. See
> `RESEARCH/TOPMENU_CLOSURE_INDEX_NAMESPACE_FIX_2026-08-27.md`.

For large UI modules, generate a machine-readable closure/capture ownership map:

```powershell
.\bin\derecomp.exe closure-map input.lua_B closure-map.tsv
```

The TSV keeps the parent prototype, instruction index, child/constant operand
namespace, operand index, resolved global target, target shape, and every
`VAL:Rn`, `REF:Rn`, or `UPVAL:Un` capture in separate fields. A bad target,
capture mode, source range, or capture count fails the command instead of
producing a best-effort ownership map. This is the preferred evidence for
mapping runtime paths such as `Initialize.U14`; never infer a runtime upvalue
from a flat prototype number alone.

| file | what it gives you |
|---|---|
| **`.claude/M6_TRUTH.md`** | the distilled state — verified facts, and the beliefs that were measured and **disproven** (several cost days each) |
| **`.claude/PITFALLS.md`** | every way this project has fooled itself: tooling, metric, comparison, reasoning and process traps, plus the parallel-workspace rules |
| **`python cert/gates.py 300 150`** | consolidated release gates, one verdict, refuses to ship on any failure |
| `python cert/idempotence.py 360 --json-out RESEARCH/raw360-rerun.json` | raw source, bytecode, frame, prototype, max-stack, and opcode fixed-point certificate; current default result is **360/360**, plus **5/5** default witnesses through cycle 10; six additional difficult ten-cycle witnesses also pass |
| `python cert/dropped.py 300` | GATE 5 — code paths emitted but **unreachable**. Nothing else detects this class |
| `python cert/allcats.py 300` | GATE 6 — **honest** access loss. `NAME-DIFF` only sees files with no loop difference, so it read 0 while 46 files were losing accesses (one of them 293) |

> **Before calling any metric change a regression, reproduce it with the pre-change binary.**
> Three hypotheses in a row were wrong on 2026-07-28; each was settled in minutes by running the
> snapshot binary against the same oracle. A baseline may only move with that measurement recorded
> beside it — `gates.py` carries the proof inline.

The goal is **complete 1:1 translation**: any of the 5386 scripts may be decompiled, edited and
recompiled, and a single wrong instruction makes that script unusable in game — so partial fidelity is
worthless.

### Historical Proper-region defect record (FINDINGS #97)

The measurements below are retained as the evidence that found the defect. The
current 2026-08-30 release gate reports `DROPPED 0`, `DEADTAIL 0`, and
`ACCESS-LOSS-TOTAL 0`; do not reuse the historical 741-path figure as current
status.

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

**Historical divergence evidence:** the original emitter inflated some scripts by about 20% per
decompile→recompile cycle (`BindingsUtil` 32,474 → 37,997 → 44,947 bytes; 2,285 → 3,739 → 5,367
code lines). The certified raw default now makes the deterministic expansion **360/360**
source-and-bytecode fixed points and keeps eleven distinct specimens exact through ten cycles. Its
independent 360-file access audit reports zero missing accesses. The earlier raw 345/360 and 350/360
checkpoints are superseded by [the pinned raw certificate](RESEARCH/RAW360_STRICT_2026-09-05/RESULTS.md).
The stable wrapper is not needed to obtain this result. Full-corpus closure and exhaustive in-game
behavioral coverage have not been claimed.

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

### Fidelity and human-readable source side by side

The verified Semantic IR renderer now has two views over the same model. The
fidelity view keeps the canonical `p<proto>_<register>` / `v<proto>_<web>`
identifiers. The readable view changes identifiers only, using exact exported
function roles, confirmed API contracts, the corpus-derived API catalog, and
conservative structural hints. It never rewrites rendered text. Every applied
alias is recorded with its prototype, value web, confidence, and evidence.

```powershell
.\bin\derecomp.exe semantic-ir-render-module-readable `
  input.lua_B fidelity.luau readable.luau readable.names.tsv `
  --semantic-sdk ..\..\..\shared\semantic-sdk\symbols.tsv `
  --call-map readable.calls.tsv
```

The Semantic SDK adds evidence-backed receiver, argument, return, and field
types to the sidecar without rewriting executable expressions. The sidecar
columns are `prototype`, `web`, `canonical`, `readable`, `confidence`,
`evidence`, `semantic_type`, `type_confidence`, and `type_evidence`. A missing,
invalid, or explicitly requested-but-unreadable SDK fails the command before
publishing outputs; ambiguous candidates remain canonical and are diagnosed.

API type names do not imply value ownership or snapshot semantics. The live
Ice Wave investigation proved that a correctly typed `UpgradedValue` returned
by `DamageData:GetBaseAmount()` can remain a live view of its owning packet:
after the packet changed, a retained wrapper read the new value. It also proved
that a repeated native address can belong to consecutive logical packets and
that Lua-entry and native-call hooks can observe different nested boundaries.
The readable layer must preserve the SDK's authority and lifetime fields; it
must never translate `UpgradedValue` into an immutable number, infer logical
identity from userdata equality, or present direct-call membership as a live
execution guarantee. See
`RESEARCH/ICE_WAVE_RUNTIME_SEMANTICS_2026-09-14.md`.

The optional call map is a separate instruction-addressed artifact. Every row
is keyed by `(prototype, instruction, source_occurrence)`: the first two fields
identify one bytecode call, while the contiguous occurrence records every
mutually exclusive expression produced by structured rendering. It records effect order, method/global/
dynamic call kind, callee and receiver value webs, ordered argument/result
webs, open-width flags, receiver type/confidence/evidence, an explicit
descriptor-join basis, exact readable and fidelity source spans, and at most
one Semantic SDK descriptor. `RECEIVER_TYPE` requires compatible receiver
evidence; `UNIQUE_METHOD_NAME` keeps a single name candidate without treating
same-call inference as independent type proof; `RECEIVER_TYPE_CONFLICT` exposes
incompatible receiver evidence. Call-map schema 2 and semantic-proof schema 3
make those fields hash-bound and fail closed in Ability Studio.

The compact SDK feed retains the catalog's exact `observed_args` set and its
separate `observed_open_args` flag. A catalog observation such as `2|4|5`
therefore does not silently become the continuous range `2..5`. A descriptor
proves only its recorded call form. Until the SDK carries an explicit
exhaustive-overload flag, a stock
call outside that form is `OBSERVED_MISMATCH`, not an invented confirmed
violation. `CONFIRMED_MISMATCH` remains a fail-closed consumer state for future
contracts that explicitly prove exhaustiveness.

Uncertain or conflicting names deliberately stay canonical. Unresolved native
hashes such as `Name__a50e34c3` are never renamed. The command fails before
publishing outputs if the readable source does not compile or if naming changes
the renderer's dispatcher/frame strategy.

Release gate for all primary ability modules:

```powershell
.\bin\derecomp.exe semantic-ir-render-module-corpus `
  ..\..\..\shared\corpus\de-luau-stock `
  --abilities --compile-rendered --readable `
  --semantic-sdk ..\..\..\shared\semantic-sdk\symbols.tsv `
  --json-out stage\readable-corpus.json
```

Long all-module research runs report progress every 100 modules by default.
Use `--progress-every 1` while isolating a hard native crash; per-module C++
exceptions are contained and named in the JSON report instead of aborting the
entire corpus.

The 2026-08-29 SDK gate rendered and compiled 286/286 fidelity modules and
286/286 readable modules (6,035 prototypes), with zero render or compile
failures. It emitted 150,521 aliases and 67,836 typed value webs. Ambiguity
diagnostics are intentional fail-closed decisions, not silently chosen names.
`RESEARCH/SEMANTIC_IR_READABLE_LAYER_2026-08-28.md` records the readable-layer
design; the Semantic SDK toolchain records the cross-tool evidence closeout.

The newer 2026-09-06 Ability Studio transaction audit covers the pinned
360-file compiler-closed sample and accepts 360/360 with zero rejects,
2,160/2,160 coordinated artifacts, and zero temporary residue. It adds
lossless mixed hash/plaintext disambiguation, explicit dead-orphan prototype
markers, verified terminal numeric-for regions, syntax-safe computed-index
bases, a dominance-plus-containment proof for compiler-generated nested loop
roles, and exact API-call expressions for 143,691 distinct bytecode calls. The
same final `derecomp.exe` independently passes raw 360/360, five default
ten-cycle witnesses, the canonical 300/150 release gates, and the two
3,213-assertion fixture configurations. See the Ability Editor's
`RESEARCH/API_CALLSITE_INTEGRATION_2026-09-06/STATUS.md` for the exact
artifact hashes and validation boundary. An exploratory unfiltered scan of all
5,386 local scripts still has 20 ownership-manifest and 8 Semantic IR failures;
the 360/360 result is not a whole-corpus claim.

`data/ability_stats_labeled.json` is older AI-authored discovery material and
is not part of the readable renderer or Ability Studio's trusted bindings. See
`data/ABILITY_STATS_LABELED_STATUS.md` before using it; exact body-key/value-flow
registries are authoritative.

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
