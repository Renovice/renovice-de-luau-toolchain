# Components Evolution guard-dispatch experiment (2026-08-31)

## Baseline

- Authoritative production baseline: **345/360** byte-exact two-cycle fixed points.
- Evidence: `cert/baselines/fixedpoint-full360-terminal-pair.json`.
- Remaining target studied here: `Lotus_Interface_Components_EvolutionList.lua_B`.
- The original mismatch was isolated to prototype 2: cycle 1 to 2 changed two instructions,
  eight code bytes, and maximum stack 48 to 49.

## Hypothesis 1: exact two-boundary acyclic dispatch

An acyclic guard subgraph immediately before a shared effect had two exact outcomes: execute the
effect or exit a one-pass repeat. Nested `if` rendering revisited a shared block. A selector over the
proven subgraph should preserve single ownership.

### Result: partially true

- The first selector experiment removed all instruction, opcode, stack, and byte-count deltas.
- Strict byte identity still failed because cycle 2 removed the redundant one-pass repeat, shifting
  debug line information even though structural bytecode was identical.
- Evidence: `cert/baselines/probe-components-guard-dispatch-v1.json`.

## Hypothesis 2: consume the shared effect under the selector outcome

Emit `if state ~= exit_state then EFFECT end` directly instead of emitting
`if state == exit_state then break end; EFFECT` inside another one-pass repeat.

### Result: true for the target

- `Components_EvolutionList` passed byte-for-byte at cycle 2 and remained stable through cycle 4.
- Evidence: `cert/baselines/probe-components-guard-flat-dispatch-v2.json`.
- The candidate also passed the deterministic strict gate at **90/90**, with all five large default
  specimens stable through cycle 10.
- Evidence: `cert/baselines/candidate-guard-flat-dispatch-strict90-long10.json`.

## Expanded-corpus falsification

### Hypothesis: the exact two-boundary proof is sufficient for a production default

### Result: false

The 360-file gate found new failures outside the 90-file sample:

- `Components_HealthAndShieldDisplay`: new drift.
- `Components_ThemedCustomizationList`: new drift.
- `Libs_DojoMgrHelper`: emitted `continue` outside a loop and failed recompilation.
- The candidate fixed `Components_EvolutionList`, but the full result fell to 344 passes with one
  execution error, so it is not an acceptable production trade.
- Evidence: `cert/baselines/fixedpoint-full360-guard-flat-dispatch.json`.

A second proof rejected generated lexical scratch conditions and effects containing raw
`break`/`continue`. That removed the health-display drift and Dojo syntax error, while preserving the
target fix, but `Components_ThemedCustomizationList` still drifted.

- Evidence: `cert/baselines/probe-guard-flat-narrowed-regressions-4.json`.

## Decision

- `RENOVICE_CFG_GUARD_ACYCLIC_DISPATCH` remains an **opt-in research flag**.
- It is deliberately absent from `install_certified_decompiler_defaults()`.
- The earlier production behavior for boundary triangles was restored; the unsuccessful indirect
  boundary-partition experiment was removed.
- No filename or prototype-specific exception was added.

## Next global problem to solve

The remaining proof must predict whether compiling the generated selector will fold a lexical
scratch condition and create a different crossing-tail CFG on the next cycle. The correct next step
is a compiler-closure invariant for selector conditions and effect ownership, not thresholds based
on one specimen's block count or instruction count.
