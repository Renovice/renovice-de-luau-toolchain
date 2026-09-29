# Semantic IR mission-module renderer findings — 2026-08-28

Scope: exact stock corpus snapshot `de-luau-stock-2026-08-25`, with focused
reproduction on `Lotus_Scripts_Modes_SurvivalMission.lua_B`.

## H1 — a prototype referenced by multiple closure sites is unsupported

**Result: FALSE.** The prior rejection
`RENDER_SHARED_CLOSURE_PROTOTYPE_PENDING` was a renderer policy guard, not a
missing semantic operation. A Luau prototype may be instantiated by more than
one `NEWCLOSURE`/`DUPCLOSURE` site. The existing closure emitter already emits
the target function at each closure instruction and constructs the child
renderer with that site's ordered capture vector. Rejecting a repeated target
therefore excluded valid stock modules without protecting a missing invariant.

The guard was removed from both contextual and whole-module rendering. Capture
mode, source origins, ordering, and child upvalue arity remain verified by the
existing Semantic IR contracts.

## H2 — root chunks and nested functions use the same local-pressure gate

**Result: FALSE before this change; TRUE after it.** Function literals switched
to indexed frame storage at high local pressure, but module root chunks always
declared every value web as a local. Value-capture snapshots were also omitted
from the pressure calculation. Survival therefore produced more than Luau's
200-local limit even though its verified IR was renderable.

The renderer now:

- counts value-capture snapshots in the local-pressure budget;
- applies the same 160-local safety threshold to module roots;
- stores root value webs and high-pressure capture snapshots in the private
  `frame_<prototype>` table;
- preserves ordinary locals for lower-pressure functions.

This is a storage lowering only. It does not change the authoritative CFG,
effect order, value origins, capture modes, or closure sites.

## Focused results

- `semantic-ir-selftest`: 140/140 assertions PASS.
- `semantic-ir-lowering-selftest`: 22/22 assertions PASS; runtime exit 0.
- `semantic-ir-readable-selftest`: 9/9 assertions PASS.
- Survival fidelity/readable module rendering: PASS, 77 prototypes.
- Survival readable source compilation: PASS.
- Mobile Defense fidelity/readable rendering and compilation: PASS.
- Survival Pickups fidelity/readable rendering and compilation: PASS.
- Bard Music fidelity/readable rendering and compilation: PASS.

## H3 — the all-module gate's `STATUS_STACK_OVERFLOW` is a larger-stack problem

**Result: FALSE.** Repeated full-corpus runs terminated with Windows exception
`0xC00000FD`. Raising the PE stack reserve from 2 MiB to 16 MiB did not change
the exception class. Suspected modules also rendered successfully in isolated
one-module runs, falsifying a malformed-input explanation.

A Windows CDB attach captured thousands of repeating
`sir::source::Renderer::emit_region` frames. `emit_block_events` had already
reported `RENDER_BLOCK_EMITTED_TWICE`, but `emit_region` continued into the
duplicate block's branch and join. That converted an intended structural
rejection into unbounded recursion. The renderer now returns immediately when
block emission records a failure. The temporary larger-stack linker setting
was removed; the fix is fail-closed control flow, not hidden extra capacity.
The raw debugger transcript is preserved at
`RESEARCH/evidence/2026-08-28-semantic-ir-stack-overflow-cdb.log`.

## Full-corpus result after the recursion fix

The exact corpus contains 5,376 modules. The render-only gate now reaches its
normal summary and JSON output without a process exception:

- 5,279 modules accepted;
- 97 modules cleanly rejected;
- 81,897 prototype-level contextual renders attempted;
- 81,869 contextual renders accepted and 28 rejected;
- six modules report `RENDER_BLOCK_EMITTED_TWICE` instead of crashing;
- readable views attempted and rendered for all 5,279 accepted modules, with
  zero readable-render failures and 1,321,471 evidence-backed aliases;
- remaining module rejections are explicitly categorized as block coverage,
  loop-predicate ownership, Semantic IR adaptation, mixed-name metadata, or
  orphan-prototype work.

The report is stored outside the repository at
`work/research/ability-studio-data-driven-2026-08-28/full-corpus-render-only-final.json`.
The coordinated readable report is
`work/research/ability-studio-data-driven-2026-08-28/full-corpus-readable-final.json`.
This is not represented as 100 percent whole-corpus source parity: the 97
named rejections remain real work. It does prove that unsupported structures
now fail closed and cannot abort the gate before its audit report is written.
