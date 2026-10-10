# Decompiler correctness campaign on client 44.1.1 — 2026-10-09

End goal (user, 2026-10-09; `CLAUDE.md` header, workspace `AGENTS.md`): the decompiler 99-100% accurate across the
CURRENT build's corpus, failure class by failure class, through general rules only (no per-script cases, no
per-script labelling layer). Then the modding API.

## 1. Baseline (measured)

Build under test: Warframe 44.1.1 (content 2026.10.08.13.05). Stock input: read-only extraction
`work/stock-2026.10.08.13.05` (5,478 modules; B.Font.toc SHA-256 `726365cc81044d28…`, the same TOC in the Steam folder
and the played Documents copy), made with `RESEARCH/U44_RAW_HASH_RECOMPILE_2026-09-29/tools/extract_u44_stock.py`.

| role | value |
|---|---|
| source | branch `fix/natural-loop-header-cfg-gate` HEAD `44e358b` (campaign branch `campaign/cfg-u441-2026-10-09`) |
| binary | `build.bat`, 0 warnings / 0 errors, `bin/derecomp.exe` = `bin/derecomp.701a2adf.exe`, SHA-256 `701a2adfe2e34b9d4e600191862b9234f7b2fb00977590314a74626290ab6d53` (reproducible: an agent worktree build of the same commit gives the same hash) |
| command | `python cert/u44_rawhash_roundtrip.py work/stock-2026.10.08.13.05 work/u441-baseline-701a2adf --jobs 20 --exe bin/derecomp.701a2adf.exe` (1,232 s) |

| measurement | 44.1.1 | 44.0.2 (2026-09-30, `work/forloops-2026-09-30/after`) |
|---|---|---|
| modules | 5,478 | 5,473 |
| decompile / recompile / deterministic | 5,464 / 5,464 / 5,464 | 5,459 |
| CONST-ID first pass | 5,343 | 5,330 of 5,459 |
| **CFG-ID first pass** | **4,174 (76.2%)** | 4,171 |
| CONST-ID and CFG-ID | 4,167 | 4,164 |
| CFG-ID FAIL | 1,304 (72 PROTO_COUNT) | 1,302 (71) |
| compiler-closed within 5 passes | 5,424 | |
| hash/string class swaps | 0 | 0 |
| prototypes compared / equal (count-aligned modules) | 74,393 / 71,234 | |

Not decompiled (14): 5 use opcodes 86/87/90 that the U44 profile does not admit (debug/ImGui/Cmd scripts,
HighwayVehicle), 8 `emit problem: cfg build failed`, 1 `Jade_Abilities_Chaos` `map::at` (known since U43).

Failure distribution: `tools/classes.py` (per first-mismatch class, smallest examples) and `tools/families.py` (work
queues by the first operation of the label: A load order 382, B access order 361, C conditions 508, D tables/loops/
returns 274, E proto count 72, stage failures 14, CONST-only 7; overlapping by design). Outputs:
`work/u441-baseline-701a2adf/{classes.json,families/}`.

## 2. Method

PITFALLS F: six diagnosis agents in isolated git worktrees (`tools/agent_worktree.sh`, `work/agents/<name>`), one per
family plus a dataflow-gate track for CFG-ID's documented blind spots (#41, #47, #52). Agents diagnose, reduce to
fixtures and race prototype patches; the integrator applies fixes one at a time in the main tree, each generic with an
`RENOVICE_NO_*` opt-out, and re-measures on the full corpus. A fix ships only when the full-corpus CFG-ID and CONST-ID
counts do not lose any module (PASS -> FAIL) and the existing gates (`cert/gates.py`, `cert/cfg_class_fixtures.py`)
pass.

## 3. Results (full 44.1.1 corpus, 5,478 modules, each batch measured against the previous one)

| batch | commit | binary | CFG-ID | CONST-ID | CFG-ID + dataflow | equal protos | PASS -> FAIL | gates |
|---|---|---|---|---|---|---|---|---|
| baseline | 44e358b | 701a2adf | 4,174 | 5,343 | 4,077 (agent run) | 71,234 | — | — |
| 1 (#53-#56) | 7db8538 | 49e0683e | 4,187 | 5,382 | — | 76,762 | 0 | PASS after G13 unmasking control |
| 2 (#57-#62) | 249b3fc | b5200665 | 4,289 | 5,383 | 4,187 | 77,006 | 0 | ALL PASS |
| 3 (#63-#67) | 6be6bec | 928298db | 4,465 | 5,389 | 4,351 | 77,326 | 0 | ALL PASS |
| 4 (#68-#71) | 9dd6e06 | fd0d4c81 | 4,481 | 5,389 | 4,367 | 77,348 | 0 | ALL PASS |
| 5 (#72-#75) | 4f6cb65 | 5713df5f | 4,515 | 5,389 | 4,501 | 77,410 | 0 | ALL PASS |
| 6 (#76-#77) | c8b6042 | 5ce9c9f8 | 4,533 | 5,389 | 4,519 | 77,432 | 0 | ALL PASS (G14 91 -> 98) |
| 7 (#78-#79) | 303c799 | 909755e9 | 4,544 | 5,434 | 4,533 | 79,024 of 83,518 | 0 | ALL PASS (G13 unmasking recorded) |
| 8 (#80-#81) | 91e2659 | 8ea2bc37 | 4,672 | 5,437 | 4,667 | 79,266 of 83,518 | 0 | ALL PASS (G14 98 -> 113) |
| 9 (#82-#89) | (this) | c62f1665 | 4,830 | 5,437 | 4,817 | 79,485 of 83,518 | 0 | ALL PASS (G14 113 -> 125) |

CFG-ID 76.2% -> 88.2% of 5,478; CFG-ID + dataflow 74.4% -> 87.9%; CONST-ID 97.5% -> 99.3%; PROTO_COUNT 72 -> 1. Run folders: `work/u441-r1-49e0683e`,
`work/u441-r2b-b5200665`, `work/u441-r3b-928298db`, `work/u441-r4b-fd0d4c81` (each with `transitions.json` and
`gates.txt`). Rejected or opt-in on integration (full-corpus regressions found by the integrator, not by the agents'
samples): split-exit condition guard (Gate 14 closure), cut-body entry #67 and innermost-loop-first #68 (PASS -> FAIL
modules and closure losses). Lesson: the stride-20 samples of the agents did not contain the regressing modules;
every batch needs the full corpus.

Wave 2 (in progress): two-exit loops / inlined returns, Proper dispatcher residue, loop selection rework (#67/#68),
coalescing liveness + OR/AND lowering (dataflow defects).
