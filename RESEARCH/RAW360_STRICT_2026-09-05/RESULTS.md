# Raw 350 to 360: strict default-profile certificate

## Result and acceptance boundary

The actual default `bin/derecomp.exe` passes **360/360 raw `decompile-mod`
fixed points**, with **11 distinct witnesses unchanged through cycle 10**.
The canonical **300/150 release gates pass**, and all 19 added executable
regression fixtures pass under both ordinary and native-opcode fidelity
compiler settings. The raw 350-to-360 foundation task is complete for this
selected sample.

The measured contract is:

```text
stock bytecode -> raw source S1 -> rebuilt bytecode B1
               -> raw source S2 -> rebuilt bytecode B2
require: S1 == S2 byte for byte AND B1 == B2 byte for byte
long witnesses: require the same S1/B1 through cycle 10
```

The denominator is the same deterministic 360-file sample used at the original
350/360 checkpoint. It is a regression sample, not the number of scripts the
toolchain can process. The current local stock corpus contains 5,386 `.lua_B`
files. The older 17,374 count refers to function prototypes in the selected
360 files, not to 17,374 script files.

This certificate does not require B1 to equal the original stock container.
None of the 360 first rebuilt containers is byte-identical to its stock input;
that auxiliary result is recorded explicitly in the JSON. Source/bytecode
stability also cannot, on its own, establish semantic equivalence. Separate
behavior and access checks below address specific failure classes.

## Pinned implementation

| Component | SHA-256 |
|---|---|
| Default decompiler/recompiler | `40BC733B43E366A7E65CFB40BDFD13D3F71B268C65F3841155B593D3F3DBA5D3` |
| Luau compiler frontend | `6156A05D9CAF9FA84E58BAECA79A244F47D86B8982F5425F2CA3E23B976ED2A4` |
| Luau test runtime | `A0F4EDD1E80EF7D7AFD223C061E1F3B753398152CB732ABF57328A93B375053E` |

The verified rules are installed by `install_certified_decompiler_defaults`
in `src/main.cpp`. The acceptance runs cleared inherited `RENOVICE*`
variables: no external candidate profile is required. The certification
harness still applies the repository's standard native-opcode/global compiler
settings, recorded in the JSON. `RENOVICE_NO_CERTIFIED_DEFAULT_PROFILE` is a
research opt-out, not part of the acceptance configuration.

The unsafe complete-ownership no-op is no longer enabled by default;
`RENOVICE_CFG_REJECT_OWNERSHIP_NOOP` is enabled. The redundant experimental
extra terminal retry remains disabled.

Promotion was independently checked: candidate v34 and default v35 use the
same 360 stock inputs and produce identical first-cycle source and bytecode
hashes for every file. See [default-promotion-comparison-v35.json](default-promotion-comparison-v35.json).

## Completed checks

| Check | Result | Evidence |
|---|---|---|
| Raw two-cycle source and rebuilt-bytecode equality | 360/360; zero process errors, integrity errors, or diagnostics | [default-full360-v35.json](default-full360-v35.json) |
| Default long witnesses | 5/5 through cycle 10 | Same full-sample JSON |
| Additional difficult long witnesses | 6/6 through cycle 10; all distinct from the default five | [default-difficult-cycle10-v35.json](default-difficult-cycle10-v35.json) |
| Known-source/stock-derived executable regression fixtures, ordinary settings | 19/19; 3,213 case assertions across source and two recovered cycles | [suite.json](artifacts/default-runtime-suite-v35/suite.json) |
| Same regression fixtures, corpus fidelity settings | 19/19; 3,213 case assertions again | [fidelity suite.json](artifacts/default-runtime-fidelity-suite-v35/suite.json), [environment](default-runtime-fidelity-v35-environment.json) |
| Independent named-access comparison against stock | 0 files with access loss across 360 | [default-allcats360-v35.log](default-allcats360-v35.log), [binary integrity](default-allcats360-v35-integrity.json) |
| Candidate-to-default promotion | 360/360 identical first-cycle source/bytecode pairs | [default-promotion-comparison-v35.json](default-promotion-comparison-v35.json) |
| Warnings-as-errors build and built-in selftests | PASS; globals, closure-index 7, Semantic IR 140, lowering 22, readable 10, closure-map smoke | [build-default-v35.log](build-default-v35.log) |
| Canonical release gates, 300 structural / 150 behavior | PASS; no baseline thresholds changed | [default-release-gates-v35.json](default-release-gates-v35.json) |
| Final compiler, frontend, runtime, emitter/main and audit-harness integrity | All retained hashes unchanged from the default build | [final-integrity-v35.json](final-integrity-v35.json) |

The release run used raw `decompile-mod` and the same pinned binary. Results:
realtrip 150/150, zero differences and zero timeouts; Semantic IR source-grounded
behavior 150/150 and Warframe API traces 11/11, both with zero vacuous cases;
constant comparison 8/8; lowering 22/22; access normalization 5/5; exact native
NAMECALL spelling/order 11/11 for HarnessEffects. Structural results: ALIGNED
211, NAME-DIFF 0, loop MATCH 266, EXTRA-LOOPS 2, LOST-LOOPS 23, LATCH-DIFF 9,
LOST-HEADERS 106, EXTRA-HEADERS 2. Detected dropped paths, dead tails, and
independent lost named accesses are all zero. These satisfy the existing
ratchets without redefining their thresholds. `realtrip` compares recovered
executions to each other; the independent known-source fixtures are necessary
because a shared wrong behavior could otherwise pass.

The independent stock comparison also reports CLEAN 256, ORDER-DIFF 88,
LOOP-DIFF 35, ACCESS-GAIN 10, and PROTO-COUNT-DIFF 9. These are independently
counted categories, so they overlap. They are retained rather than described
as complete stock-structure parity. Zero lost named accesses does not prove
correct branch selection, execution count, or effect order.

The 11 long witnesses are EE Interface Utilities, ScriptCommands JSON, Lotus
Docs Loadouts, BindingsUtil, DiegeticUpgradeCards, HudRedux, InventoryTest,
LoadOutSelect, LotusUtilities, MapRedux, and SporePrimer. Exact filenames are
recorded in the promotion comparison.

## Hypotheses settled by evidence

1. **The original ten failures are reproducible: true.** The saved original
   D734 binary fails all ten focused cases. Equal byte length was explicitly
   rejected as an acceptance criterion; some probes had equal sizes but
   different bytecode. See `baseline/residual10.json` and retained artifacts.
2. **Every residual is harmless formatting: false as a general explanation.**
   Executable fixtures exposed lost unconditional loop breaks, unsafe index
   lifetimes, and continuations emitted on the wrong branch. Passing a fixed
   point never overruled a failing source-grounded behavior test.
3. **Reversing an ordered comparison implements its logical complement: false.**
   NOTLT/NOTLE must preserve the original comparison and negate its result.
   The old rewrite fails for NaN and can select a different comparison
   metamethod. The ordered-comparison oracle fails on the old binary and
   passes 48 assertions across the source and two corrected cycles.
4. **Claiming every reachable CFG block guarantees correct control flow: false.**
   A sensitive shared-terminal fixture lost its completion effect on the
   false branch despite complete block coverage. Strict duplicate-ownership
   rejection and bounded shared-tail recovery pass all 45 assertions.
5. **Reachability through the proposed effect is proof of a bypass: false.**
   A pending-join experiment reintroduced an effectful-loop defect. The
   corrected proof excludes the effect when checking for a bypass. The
   combined suite caught the regression; the negative evidence is retained.
6. **The last Inventory drift came from a source-loop proof failure: true.**
   A guard-dispatch request was also classified as a source-loop dispatch
   merely because it had a terminal and domain. Its domain was the whole
   prototype, so the loop matcher rejected it and changed the emitted form.
   Distinguishing these two requests closes the last raw fixed point while
   retaining ownership checks and passing the behavior suite.

The implementation uses shared control-flow, lifetime, and source-shape rules.
It contains no new filename/prototype whitelist to force these ten scripts to
pass. Failed whole-prototype rendering attempts restore emitter state before
another attempt or legacy fallback. No original variable names or native API
semantics were invented to reach the result.

Full chronological positive and negative findings, rejected configurations,
and artifact locations are preserved in [STATUS.md](STATUS.md). Some broad
fixtures also passed before their related fix; those are retained as regression
coverage, not presented as sensitive reproductions of that defect.

## Reproduction

From the toolchain root, with the pinned binary and original corpus:

```powershell
Get-ChildItem Env:RENOVICE* | ForEach-Object {
    Remove-Item -LiteralPath ('Env:' + $_.Name)
}
python cert/idempotence.py 360 --workers 4 --json-out RESEARCH/raw360-rerun.json
python cert/allcats.py 360
& RESEARCH/RAW360_STRICT_2026-09-05/tools/Verify-CandidateFixtureSuite.ps1 `
    -OutputDirectory RESEARCH/raw360-runtime-rerun
$env:RENOVICE_NATIVE_GLOBALS = '1'
$env:RENOVICE_NATIVE = 'JUMPXEQKN,JUMPXEQKS,JUMPXEQKB,JUMPBACK,AND,OR,ANDK,ORK,SUBK,FORGPREP'
& RESEARCH/RAW360_STRICT_2026-09-05/tools/Verify-CandidateFixtureSuite.ps1 `
    -OutputDirectory RESEARCH/raw360-runtime-fidelity-rerun
# Run release gates without other concurrent test workloads.
python cert/gates.py 300 150 --json-out RESEARCH/raw360-release-rerun.json
```

Use fresh output directories for fixture/artifact reruns. Do not rebuild while
an audit runs. The idempotence harness pins the compiler, frontend, and stock
inputs before/after execution, rejects invalid/duplicate selections and raw
mode with inherited stable canonicalization, and retains per-cycle hashes.
Neither `--measure` nor `decompile-mod-stable` was used for default acceptance.

## Later semantic-layer closeout — 2026-09-06

The historical 318/360 semantic readability figure is now superseded for this
same selected sample. Ability Studio accepts 360/360 hash-bound semantic views,
publishes all 1,800 coordinated artifacts, and leaves zero rejects or
temporaries. The final shared toolchain binary is
`C4A1355F8893C02A8B6C431DA7A9DC328491512545B8592ACE6149B98E5B196E`.
Because semantic renderer/planner changes share that executable with the raw
lane, the raw checks in this report were repeated rather than assumed:

```text
raw fixed point                 360/360
ten-cycle witnesses             11/11
canonical release gates         ALL PASS (300/150)
independent access loss         0 across 360
ordinary runtime fixtures       19/19, 3,213 assertions
native-opcode runtime fixtures  19/19, 3,213 assertions
ownership/IR prototypes         17,374/17,374 in both sweeps
```

The new raw inventory and release evidence are
`cert/baselines/fixedpoint-full360-semantic-beautification-final-2026-09-06.json`
and
`cert/baselines/release-gates-semantic-beautification-final-2026-09-06.json`.
The exact presentation result, fixes, hashes, and limits are documented in
`repos/apps/ability-editor/RESEARCH/SEMANTIC_BEAUTIFICATION_360_2026-09-05/STATUS.md`.

This does not certify every local script. A separate unfiltered 5,386-file
experiment found 20 ownership-manifest failures and 8 Semantic IR failures
among 82,059 prototypes. It is preserved as the next broader-corpus boundary,
not hidden by the completed 360-file result.

The user's existing successful injector/bootstrapper and in-game script work
is compatible with these results. This run does not repeat an in-game test or
establish all native API behavior. All outputs are within the RE project;
game files, server files, and old backups were not modified.
