# Compiler-closed fixed point 360 closeout — 2026-09-05

> **Superseded raw checkpoint:** the subsequent default binary `40BC733B...`
> passes **360/360 raw `decompile-mod` fixed points**, eleven distinct witnesses
> through ten cycles, and the canonical release gates. See
> [the raw 350-to-360 closeout](RAW360_STRICT_2026-09-05/RESULTS.md).
> The D734 measurements and rejected experiments below are historical evidence,
> not the current raw pass count. The later work also found and corrected real
> semantic defects; the old assumption that every raw residual was merely
> compiler spelling must not be treated as established fact.

## Outcome

The certified `decompile-mod-stable` view now reaches **360/360** exact two-cycle fixed points on the
deterministic sorted sample. All five default large witnesses remain exact through cycle 10. The
independent named-access audit reports **0 files and 0 accesses lost** across all 360.

This is a compiler-closed deterministic-sample certificate. It is not byte identity with the original
DE files, exhaustive certification of all 5,386 corpus files, or an in-game runtime proof. The raw
`decompile-mod` diagnostic view now reaches **350/360**, with 10 first-pass compiler-spelling
drifts visible for future work.

Certified binary SHA-256:

`D734114550B1815C898C47C70A0692693C959234D79EC852F89F29450FD8A078`

## Raw diagnostic checkpoint

Hypothesis: the generalized source and CFG canonicalizations promoted after the original 345/360
closeout improve first-pass closure without weakening the already-certified stable view.

Result: **true for the deterministic 360-file sample**. On the same warnings-as-errors binary, the
raw view passes 350/360 and the stable view passes 360/360. Both modes keep all five default large
witnesses fixed through cycle 10. The ten remaining raw-only drifts are:

- `Lotus_Interface_ChatRedux.lua_B`
- `Lotus_Interface_DialogWithCards.lua_B`
- `Lotus_Interface_DiegeticFoundry.lua_B`
- `Lotus_Interface_HudRedux.lua_B`
- `Lotus_Interface_InventoryTest.lua_B`
- `Lotus_Interface_LoadOutRedux.lua_B`
- `Lotus_Interface_LoadOutSelect.lua_B`
- `Lotus_Interface_LotusNetworkUtilities.lua_B`
- `Lotus_Interface_LotusUtilities.lua_B`
- `Lotus_Interface_MapRedux.lua_B`

The unfinished DiegeticFoundry probes were removed before this checkpoint. In particular, no
plain-dispatch-return exclusion, guard-boundary size limit, or incomplete shared-return loop matcher
is present in the certified binary.

## Last semantic blocker

`Lotus_Interface_LotusUtilities.lua_B` previously stabilized only after losing seven reachable named
operations from its Duviri cave-offer tail:

- `GETIMPORT gGameData`
- `GETIMPORT Lotus_Game`
- `GETFIELD DuviriCaveOffers`
- `SETFIELD mSeed`
- `SETFIELD mWarframes`
- `SETFIELD mWeapons`
- `NAMECALL SetDuviriCaveOffers`

The old region renderer greedily claimed a nested generic-loop prep and later emitted a fake loop
around the outer exhaustion tail. On the next cycle, an unreachable selector allowed the compiler to
delete that tail.

The repair is general and proof-driven:

1. A guard chain that reaches a verified source while-loop delegates that loop atomically to the
   authoritative CFG renderer and resumes only at its unique outside edge.
2. A nested source loop may spell a transfer as local `break` only when the target is the proven latch
   of a strictly enclosing authoritative loop.
3. The whole-prototype renderer remains transactional: incomplete, duplicate, out-of-domain, or
   ambiguous ownership rejects the candidate before source is published.
4. The certified default profile enables mixed source-for/source-while composition. No filename,
   prototype number, register number, instruction count, or Warframe-specific exception participates.

After the repair, `LotusUtilities` is exactly `10,130 -> 10,130` reachable named accesses with nothing
missing or extra, and its focused cycle-10 certificate passes.

## A/B evidence

Enabling the generalized composition changed 13 of the first 360 emitted stable modules. Relative to
the prior default:

| metric | prior | candidate | delta |
|---|---:|---:|---:|
| ALIGNED | 236 | 239 | +3 |
| LOOP-DIFF | 56 | 53 | -3 |
| back-edge MATCH | 290 | 292 | +2 |
| LOST-LOOPS | 58 | 56 | -2 |
| LOST-HEADERS | 322 | 300 | -22 |
| access-loss files | 1 | 0 | -1 |
| missing accesses | 7 | 0 | -7 |
| dropped paths | 0 | 0 | unchanged |

The full 360 `gates.py` invocation also reports one `NAME-DIFF`: an extra `GetLocalized` NAMECALL in
`Lotus_Interface_Libs_SortieGenerator.lua_B`. Focused A/B proved that exact `944 -> 945` gain exists
with the candidate both disabled and enabled; it is a pre-existing file beyond the canonical 300-file
ratchet, not a change introduced by this repair. The independent all-category oracle is therefore the
decisive expanded access-loss gate and reports zero loss.

## Final verification

Build and self-tests:

- native global transcoder: PASS
- closure-index namespace: 7/7 PASS
- Semantic IR fixtures: 140/140 PASS
- Semantic IR lowering execution: 22/22 PASS
- readable layer: 10/10 PASS
- closure-map smoke: PASS
- warnings-as-errors build: PASS

Compiler-closed idempotence:

```text
CYCLE2 files=360 passed=360 failed=0 errors=0
CYCLE10 files=5 passed=5 failed=0 errors=0
```

Expanded named-access audit:

```text
files=360
ACCESS-LOSS-TOTAL 0
ACCESS-LOSS is the number that must never rise: 0 file(s)
```

Canonical release gates (`300` structure/access files, `150` behavior files):

```text
ALL GATES PASS
ALIGNED 207
NAME-DIFF 0
realtrip 150/150
DROPPED 0
DEADTAIL 0
ACCESS-LOSS-TOTAL 0
```

Semantic ownership and IR over the exact same sorted 360-file sample:

```text
files=360 prototypes=17374 manifest_ok=17374 failed=0
files_touched=360 prototypes=17374 verified=17374 failed=0
unresolved_control_nodes=0
value_flow known=17374 unknown=0 nonconverged=0 missing_origin=0
```

Machine-readable evidence:

- `cert/baselines/fixedpoint-full360-compiler-stable-semantic-final-2026-09-05.json`
- `cert/baselines/release-gates-compiler-stable-semantic-final-2026-09-05.json`
- `cert/baselines/semantic-plan-cert-sample360-semantic-final-2026-09-05.json`
- `cert/baselines/semantic-ir-cert-sample360-semantic-final-2026-09-05.json`
- `work/fixedpoint-full360-raw-post-semantic-fix-2026-09-05.json`
- `work/diagnostics/fixedpoint-full360-clean350-checkpoint-20260905.json`
- `work/diagnostics/fixedpoint-full360-stable-checkpoint-20260905.json`

## Next boundary

The 360 compiler-closed sample is complete. Further decompiler work should either:

1. expand the same fixed-point, access, ownership, and IR certificate beyond 360 toward the full
   corpus; or
2. reduce the 10 raw diagnostic drifts without regressing the already-certified stable view.
