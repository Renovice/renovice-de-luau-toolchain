# CFG-ID failure clusters on client 2026.10.22.13.12 — 2026-11-02 (read-only measurement)

Details, tools and evidence: `work/failure-clusters-2026-11-02/` (`CLUSTERS.md`, `clusters.json`, `shapes.json`,
`tools/shape_classify.py`, `tools/aggregate.py`, `repro/`). No change to `src/`, the gates or the commits.

## Inputs
- Build: 2026.10.22.13.12. Evidence: the EE.log `Build Label` and the Steam/Documents `B.Font.toc` (`fee49300…`, which is not the
  campaign's `726365cc…`). The corpus was extracted read-only to `work/failure-clusters-2026-11-02/stock-2026.10.22.13.12`
  (5,481 modules: 3 new, 93 with changed bytes vs 2026.10.08.13.05).
- Binary: `bin/derecomp.14c22656.exe` = `bin/derecomp.exe` (SHA-256 `14c2265618c42e1b…`). Source is HEAD `dca27be`, with a clean tree.
- Command: `cert/u44_rawhash_roundtrip.py ... --jobs 20 --dataflow --keep` (1,263 s).

## Baseline (first pass)
Decompile/recompile/deterministic 5,481/5,481/5,481. CONST-ID 5,460. **CFG-ID 4,921 (89.8%)**. CFG-ID + dataflow 4,907.
Dataflow FAIL among CFG-ID PASS 14. PROTO_COUNT 0, class swaps 0, gate errors 0. Equal prototypes 82,916 / 83,665.
Compared with r12 (4,877 on 5,478): +3 new modules that PASS, +42 FAIL -> PASS (37 of them on unchanged stock, so they come from the
ctor commits built after batch 12), and 1 PASS -> FAIL (SandmanPassive, whose stock changed; new shape LOOP_LOST).

## Hypothesis
H: the remaining CFG-ID failures are dominated by one structuring mechanism, not a long tail.
Result: **TRUE.** There are 560 FAIL modules and 749 failing prototypes. 477 modules carry one class. Prototypes whose stock loop has two or more
exit targets, together with the dispatcher fallbacks (DISPATCHER_* + LOOP_LOST + LOOP_EXTRA), touch 394 modules, and **346 fail only
there**. The largest single class is DISPATCHER_MULTI_EXIT_FOR: 261 modules, 207 only-class. A short-circuit chain whose leaves
are several escapes (break / return / continue) inside a for, mostly nested, falls back to a `__renovice_state_N`
dispatcher. The smallest repros show behavior differences (TauDropshipAvatar p9 prints a `break` before the state logic;
HardModeDaily p4 drops a `continue`), so these are real defects and not only CFG shape differences.

Ranked by only-class modules: DISPATCHER_MULTI_EXIT_FOR 207 (L), LOOP_LOST 49 (L), STRAIGHT_ORDER_LOAD 38 (S-M, probable
gate gap, unconfirmed), DISPATCHER_MULTI_EXIT_WHILE 22 (L), DISPATCHER_ACYCLIC 20 (M), LOOP_BODY_ORDER 17, OP_SET_DIFF_LOAD 17,
LOOP_EXTRA 16, COND_EMPTY_IF 14 (S).

## Caveats
- A COPY of derecomp.exe outside `bin/` cannot find `luau-compile.exe`, so every recompile fails (PITFALLS A1 family). That run was
  quarantined (`INVALID-*`).
- No module was excluded. COND_EMPTY_IF/TRUTHY_ONLY (6) and STRAIGHT_ORDER_LOAD (44) are probable gate normalization gaps.
  Both are UNCONFIRMED until a luau.exe behavior check is done.
- The gain counts are upper bounds: a fix can uncover a later divergence in the same prototype.

## Next step
Put the multi-exit escape renderer in front of the integrator for `src/emit.h`/`src/structan.h`: short-circuit chains with escape leaves
inside a loop, starting with the 3 smallest repros in `repro/DISPATCHER_MULTI_EXIT_FOR/` and `repro/LOOP_LOST/`. Add a CFG-class
fixture for each before fixing.
