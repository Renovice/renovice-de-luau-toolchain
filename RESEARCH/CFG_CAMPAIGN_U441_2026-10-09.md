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

## 3. Results

(in progress)
