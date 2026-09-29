# Raw 350 to 360 investigation, 2026-09-05

**Completed:** actual default binary `40BC733B...` passes raw 360/360, eleven
distinct ten-cycle witnesses, 19 regression fixtures under each of two compiler
configurations, and the canonical 300/150 release gates. The investigation
entries below are chronological; earlier pending/rejected candidates are not
the final status. See [RESULTS.md](RESULTS.md) for the pinned closeout.

## Acceptance boundary

User clarification after the first audit: the requested exactness is repeated
decompile/recompile bytecode identity. Original-container identity is an auxiliary
diagnostic, not the acceptance gate. Register allocation, constant order, and
container metadata can differ without proving semantic failure.

The requested foundation is the raw `decompile-mod` lane. Do not silently use
`decompile-mod-stable`, change the 360-file denominator, or substitute rebuilt
inputs. Exact source and bytecode equality between cycles is distinct from
equality with the original stock container. Neither a fixed point nor a
named-access census alone proves preserved program semantics.

Prior task read: `Map Warframe RE tooling`, task ID
`01a06d8e-16dc-7510-b0ea-ef5bef138a75`, through its final 2026-09-05 answer.
It records raw 350/360 and semantic presentation 318/360: 32 presentation rejects
among the 350 raw-eligible files plus ten raw-ineligible files, totaling 42
unverified presentation files. This is a separate remaining layer.

## Preserved starting state

- Binary SHA-256: `D734114550B1815C898C47C70A0692693C959234D79EC852F89F29450FD8A078`.
- The repository already contains substantial tracked and untracked work.
  `baseline/preexisting-diff-stat.txt` records the tracked change inventory.
- `baseline/` preserves the starting binary and the relevant emitter sources.
- Original corpus, game installations, server, and old backups remain untouched.

## Hypotheses and evidence

1. **The ten saved raw failures reproduce on the current binary: TRUE.**
   `baseline/residual10.json` reports 0/10 passes, all ten expected drifts,
   zero process errors. The five default witnesses pass at the explicitly
   shortened two-cycle depth used in this focused diagnostic run.
   `artifacts/baseline/` retains both source and rebuilt bytecode cycles.

2. **All remaining differences are harmless compiler spelling: NOT PROVEN.**
   DialogWithCards' changed function moves a state-dispatch tail before its
   initialization and materializes nil definitions. LoadOutSelect also contains
   suspicious nil-before-field reads. These require original-control-flow
   evidence, not a cosmetic normalization or acceptance based on equal size.

3. **Ordering a losing NaturalLoop container by original instruction address
   resolves DialogWithCards: FALSE.** The existing diagnostic
   `RENOVICE_ORDER_LOSING_NATURAL` flag removes the entry reordering and stack
   inflation, but the function still changes a loop into a conditional tail.
   `order-losing-natural.json` records equal byte lengths with differing
   bytecode, proving that equal lengths would be an invalid success criterion.

4. **The CFG renderer rejects an interior-exit natural loop as though it must
   be header-tested: TRUE.** `artifacts/dialog-debug.txt` reports stock prototype
   10, header 21, latch 24: both header edges stay inside, one backedge returns
   to the header, and the exit is block 25. Setup rejects it as
   `UNSUPPORTED_WHILE_SHAPE` and falls back to legacy regions.
   A diagnostic-gated candidate extends the verified while transaction to a
   single-backedge, single-exit interior-test shape. Acceptance is pending.

## Tooling observations

- `de-proto-diff` exits with a boolean change result; nonzero plus a valid
  `protos=` report represents a detected difference, not a subprocess failure.
- Git reports pre-existing CRLF normalization warnings under the repository's
  `* text=auto eol=lf` policy. No broad line-ending rewrite was performed.
- The original `cert/idempotence.py` recorded rebuild cycles and only the initial
  binary hash. This investigation added stronger corpus/frontend/binary identity
  checks; see the candidate results below.

No 360/360 raw completion or stock-byte-identity claim has been made.

## Candidate results

- Interior-exit loop candidate: `full360-interior-while-v1.json` proves 351/360
  raw fixed points, all prior 350 retained, 5/5 default witnesses through cycle 10,
  zero errors or emitted stderr diagnostics, stable compiler/frontend/input hashes.
  The newly passing file is DialogWithCards. Its independent access audit is
  913 -> 913, missing 0, extra 0. The direct original-byte diagnostic is 0/360;
  this is not the user's clarified acceptance contract.
- Transparent-loop-exit candidate: a pure one-instruction forward jump after the
  for latch leads to the same outside destination as a body break. Recognition
  reduces LotusUtilities' cycle drift from +718 bytes to +8 (two RETURNs), with
  zero remaining stack drift. It is not yet a whole-file pass.
  `full360-transparent-exit-v1.json` measures 351/360, all old 350 retained,
  5/5 witnesses through cycle 10, errors 0. The expanded access census reports
  zero missing accesses over all 360 (`allcats-transparent-exit-v1.log`).
- `tools/loop_exit_fixture.luau`: nine runtime assertions pass on original source
  and two rebuilt/decompiled cycles, with both candidate features enabled. They
  also pass with both features disabled. This is general behavior coverage, not
  a sensitive reproduction of the stock failure; no claim to the contrary is made.
- `cert/idempotence.py` now records input and frontend hashes, before/after
  integrity, actual RENOVICE environment, stderr diagnostics, and original-byte
  identity separately; it rejects duplicate rows and hidden raw canonicalization.
  `harness-negative-inputs.json` confirms four invalid configurations fail with
  exit 2: duplicate input, zero sample, zero workers, hidden canonicalization.

## Shared-return branch investigation

- **Hypothesis: complete block coverage proves every path is preserved: FALSE.**
  LoadOutSelect rebuilt prototype 47 has a guard diamond reaching private return
  15 or shared continuation 16. The old early-return join chooses 14, consumes
  the continuation from one branch, then accepts a revisit as a no-op because
  every block was emitted. This drops the other route into the continuation.
  `artifacts/exact-loadout-debug.txt` records the original rebuilt graph and trace.
- **Hypothesis: the existing exact two-boundary guard can preserve this path:
  TRUE for the focused prototype.** The first experimental extension rejected
  the root triangle because its helper was available only during a retry; a
  second extension handles that triangle and makes prototype 47 exact.
  It changes unrelated shared-bare-return spelling in prototype 59, so the whole
  file still fails by one JUMP. Neither broad experiment is accepted as a release.
  `exact-return-v1.json`, `exact-return-v2.json`, and `exact-return-strict-v2.json`
  retain negative results; no failures have been relabeled as passes.
- **Sensitive runtime reproduction: confirmed.**
  `tools/shared_return_fixture.luau` is explicitly synthetic, derived from that
  guard shape. The original source passes 24 assertions. With new features
  disabled, its first decompiled cycle fails the `absent/true` result assertion.
  With the v2 guard candidate and strict ownership enabled, all 24 assertions
  pass on source and both decompiled cycles (72 total). It checks all six
  nil/zero/nonzero and false/true combinations, method count, and shared-tail
  count/value. This is a bounded runtime witness, not a stock game execution.
- The next candidate restricts the first-pass proof to a private return that
  cannot be reached from its continuation, with no pending outer stop. Boundary
  triangle support is scoped to that transaction. This prevents swallowing a
  shared return/outer boundary just to obtain a convenient spelling.

## User scope clarification

The existing compiler/game-loading route and readable editor are real prior work;
350/360 is not a count of all scripts capable of compiling or running in game.
The current work fixes remaining raw fixed-point/control-flow defects beneath the
readable layer. The saved readable-layer acceptance remains 318/360 on its pinned
D734 compiler; these experimental builds have not been promoted into that audit.
The project records a 10/10 in-game compiler certification suite. That historical
suite does not prove all original stock modules behave identically after recovery.

## Resumed stability work

The user confirmed the broad decompile/recompile/injector pipeline already works
and asked to continue the selected 360-file stability work. Do not describe 360
as the full Lua corpus or a limit on script loading. No game deployment is part
of these compiler experiments.

- Private-return v4: LoadOutSelect becomes an exact raw fixed point, but the
  full candidate is **347/360**, not an accepted improvement. Five former passes
  regress: CardUtilitiesRedux, AbilityList, AvatarDiorama,
  ThemedCustomizationButton, and PreviewLinkUtilities. All five have zero byte
  length/instruction/stack delta; some still have different byte contents. None
  is accepted on length alone. Disabling the old complete-ownership no-op
  produces 344/360 and remains a separate diagnostic, not a release change.
- Interior guard v5: prove the loop header prefix reaches exactly its common
  body or unique outside exit before emitting the body. This removes both extra
  RETURNs in LotusUtilities; the full file still has branch/source drift.
- A first-pass return extension also matched ordinary direct-boundary guards,
  introducing repeat wrappers only on cycle two. The next version excludes
  those and targets only interior shared-branch guards. It leaves the existing
  private-return retry path intact.
- Guard-source v6 adds separately gated normalization of inline nested break
  guards, associative boolean grouping, nil-test loops, and returned elseif
  arms. These are source-shape candidates, not source-name or filename rules.
- The first v6 build failed because the nil-loop insertion matched the wrong
  similarly shaped normalizer. The compiler caught missing local identifiers;
  the insertion was moved to the exact while normalizer before rebuilding.
  `build-guard-source-v6.log` preserves the failure.
- `tools/stock_binary_search_fixture.luau` retains the recovered LotusUtilities
  BinarySearch body and its three dependencies, with extraction/source hashes
  in `stock-binary-search-fixture-provenance.json`. Twelve independent expected
  cases cover empty/singleton inputs, absent values, repeated values, both array
  ends, and ascending/descending order: all 36 assertions pass on the source.
  Source and both recovered cycles pass all 36 assertions each (108 total),
  retained in `artifacts/stock-binary-search-v6/result.json`.

## Verified v6 result and later counterfactuals

- `full360-guard-source-v6.json`: **353/360 raw fixed points**, zero errors or
  integrity failures, and all five selected ten-cycle witnesses pass. Set
  comparison retains every original 350 pass. New passes: DialogWithCards,
  LoadOutSelect, LotusUtilities. Binary SHA-256:
  `5D8421F08E9D32B38F9ABEB88C061DCDE37E537388833ED17D5090C4AA18893D`.
  `baseline/derecomp-v6-raw353.exe` retains the binary; the v6 profile is explicit
  in `tools/Set-CandidateProfileV6.ps1`. Defaults have not been promoted.
- `allcats-guard-source-v6.log`: named access loss total is zero. This is a
  static coverage metric, not proof of every runtime path. The sensitive shared
  return fixture also passes 72 assertions across source and two cycles.
- Seven raw failures remain: ChatRedux, DiegeticFoundry, HudRedux, InventoryTest,
  LoadOutRedux, LotusNetworkUtilities, MapRedux. `residual7-v6.json` and retained
  per-cycle artifacts contain their exact drift, not length-only comparisons.
- v7 exit-only guard-tail plus uncaptured prefix-state recovery: no additional
  passes among seven. MapRedux drift falls from +1535 to +96 bytes, but HudRedux,
  InventoryTest, and LoadOutRedux grow more. This combined result is unaccepted.
- `prefix-only-v7.json` isolates prefix recovery: MapRedux +1527, LoadOutRedux
  +294, HudRedux +357, InventoryTest +530 bytes; AvatarDiorama remains a pass;
  five ten-cycle witnesses pass. This isolates the large MapRedux improvement
  to guard-tail handling. The first attempt used an incorrect AvatarDiorama
  relative filename and failed input validation before running; the corrected
  path is `Lotus_Interface_Components_AvatarDiorama.lua_B`.
- Network guard-tail hypothesis remains **false as a complete fix**. Rendering
  the exit-only tail avoids its first rejection, then meets shared block 87 a
  second time from the effect arm. Ownership rejection remains intact; no
  duplicate/no-op workaround is accepted.
- v8 hypotheses under test: collapse a mapped integer exit relay only when its
  source has no distinguishing reads/captures or later uses; rotate a sole empty
  else return when the immediate continuation returns the same empty result.
  Both are separately gated generic source proofs, not filename rules.
- `mapped-relay-v8.json`: ChatRedux bytecode is now exactly equal, but emitted
  source differs by one unused observation serial; strict combined pass remains
  false. v9 serial normalization reveals a separate one-byte source difference
  in a returned else arm of c126. `full360-relay-v9.json` remains 353/360, zero
  errors/integrity failures and five ten-cycle passes; it retains all prior
  passed files. Do not relabel ChatRedux as a combined pass.
- `exit_relay_fixture.luau` is a synthetic witness with ordinary, distinguishing
  read, and captured-state routes, plus empty-return condition evaluation counts.
  All 56 assertions pass on source and two decompiled cycles (168 total), saved
  in `artifacts/exit-relay-v9/result.json`. It is bounded runtime coverage, not
  stock game execution or a demonstrated sensitive failure on the old compiler.
- Shared-guard partition v9 **fixes LotusNetworkUtilities** in isolation:
  `partition-only-v9.json` passes source/bytecode fixed points through ten cycles.
  Before emitting a guard, prove its prefix and effect do not share blocks; try
  a downstream shared boundary when an immediate successor cannot own it. This
  prevents the observed second claim of block 87 without suppressing ownership
  errors or duplicating effects.
- `full360-partition-v9.json`, which also enables the separate exit-only-tail and
  prefix-reuse experiments, is **350/360**, not accepted. New regressions versus
  v6: Background, ThemedCustomizationList, ConsumablesOverlay,
  ConversationUtilities. Five ten-cycle witnesses still pass, with zero errors.
  The isolated Network fix needs a full audit without those combined features.
- v10 hypotheses: prefer a proven private-return triangle over a plain state
  dispatcher when its exclusive prefix and shared continuation are disjoint;
  rotate a terminal else across closing single-arm if scopes only when the
  existing continuation returns no values and crosses no loop or effect.
- `full360-triangle-v10.json`: 355/360 bytecode fixed points, but **351/360 combined
  source/bytecode fixed points**. Source-only regressions: GearSpiral,
  OmegaCompatibilityPanel, LotusUtilities, RetroMinigame. ChatRedux and Network
  now pass combined checks. This full profile is not accepted as a replacement
  for the no-regression v6 result. `allcats-triangle-v10.log`: clean 250, order
  differences 94, loop differences 41, access gain/diff 10, proto-count diff 9,
  **zero access losses**. All five ten-cycle witnesses pass.
- `combined-triangle-v10.json` additionally enables exit-only-tail and prefix
  recovery. It retains the four earlier v9 regressions; MapRedux has only one
  extra LOADNIL and DiegeticFoundry only one fewer JUMP. Native per-proto reports
  establish these are actual changes, not rounded percentages.
- `return_continuation_fixture.luau`: verifies result arity and effect order for
  returned else branches, intervening effects, and loop boundaries. All 24
  assertions pass on source and both cycles (72 total), saved under
  `artifacts/return-continuation-v10`.
- v11 corrects an over-conservative literal-return shadow check: reading a raw
  register as a for-loop bound is not declaring that register as the iterator.
  A new gated OR-value rule covers only complete uncaptured scratch lifetimes
  with exact copy/test/literal-fallback/copy groups. The source-only regressions
  remain to be inspected; none is waived just because bytecode is equal.
- v11 focused results: MapRedux is a combined exact fixed point; Foundry bytecode
  is exact but contains an unreachable source return. Four source regressions
  were also duplicate empty returns appended after an already returning first
  arm. v12 fixes the producer to avoid appending an unreachable continuation.
- `value_temporary_fixture.luau`: 33 assertions cover truthy zero/empty-string,
  table identity, captured scratch mutation, literal return tails, and result
  arity. Source plus two cycles pass 99 assertions on both v11 and v12.
- `full360-return-tail-v12.json`: **356/360 combined, 357/360 bytecode**, five
  ten-cycle witnesses pass, zero execution/integrity errors. Remaining byte
  failures are HudRedux, InventoryTest, LoadOutRedux. LotusUtilities has a
  source-only regression, so this is not yet a no-regression release. Set
  comparison confirms LotusUtilities is the only lost v6 pass. Binary retained
  as `baseline/derecomp-v12-raw356.exe`, SHA-256
  `77DF2FE5A85724A7F247F1B4C502827BCD01E978934B1BBFE7E245673DF7BECB`.
  Profile remains `tools/Set-CandidateProfileV11.ps1` (no exit-only-tail flag).
- v13 diagnostic switches under development separate plain single-exit DAG
  dispatch from guard-boundary dispatch. InventoryTest c140 gains a plain
  dispatcher at cycle-two block 25; LoadOutRedux c484 gains a guard-boundary
  dispatcher at block 96. No dispatch switch is accepted merely because it
  reduces the length of a currently failing file.
- `full360-empty-cleanup-v13.json`: **357/360 combined exact fixed points**, all
  original 350 and v6 353 passes retained, five ten-cycle witnesses pass, zero
  errors/integrity failures. The last source-only Utilities duplicate empty
  return is removed after retaining its preceding valued return. Binary saved
  as `baseline/derecomp-v13-raw357.exe`, SHA-256
  `4A92DC2BBF6AF158B2D5AB39664F2814FB08290DFA725FDA63046AC0A87B8B05`.
  Use the explicit v11 profile; none of these candidates changes default flags.
- Broad plain-single-exit deferral v13 reduces residual drift to Hud -61 bytes,
  Inventory +36, LoadOut +4. Full audit is **356/360**, however: Network regresses.
  `allcats-defer-plain-v13.log` retains zero access losses; clean 248, order diff
  95, loop diff 43. This broad flag is diagnostic, not accepted. Guard-dispatch
  deferral also regresses Utilities in the focused run and remains unaccepted.
- The closure comparison helper failed to create an empty diff for identical
  closures, leading to a missing-file read while checking c227. It now always
  writes the diff, including zero bytes, and the c227 result was regenerated and
  checked at length zero. Native diff already showed only LoadOut p218 changed.
- v14 narrows plain dispatch deferral to an immediate effect with proven
  disjoint prefix/suffix ownership. It also tests late use of existing captured
  index lifetime normalizers, and recognizes another complete raw-FORNPREP zero
  lifetime when proving scratch-only outside uses. All remain separately gated.
- v14 focused: LoadOut bytecode becomes exact but source still differs; the
  private-effect deferral still regresses Network. Late index lifetime passes
  do not remove Hud's remaining nested-capture temporary. No v14 promotion.
- **Sensitive runtime failure found:** `index_and_first_loop_fixture.luau`
  uses two ordinary numeric loops that each break after their first item, then
  checks nested-index evaluation order. The recovered first loop loses its
  unconditional break and iterates to the final item. Source passes; first
  recovery fails. This reproduces on the original D734 binary as well as v13,
  v14, and v15. Retained controls: `artifacts/index-first-loop-original-control`
  and `artifacts/index-first-loop-v13-control-fixed`.
- The first saved-v13 control could not compile because a relocated derecomp
  expects `luau-compile.exe` adjacent to itself. The same unchanged compiler
  frontend was copied into `baseline`, and the corrected control then reproduced
  the runtime failure. The helper now accepts an explicit compiler path and
  records future failures in result.json plus compiler/decompiler diagnostics.
- Native fixture p0 has FORNPREP, body, an unconditional JUMP to normal exit,
  and an unreachable FORNLOOP. The fallback renderer emitted only conditional
  loop exits. v15 added exact unconditional-exit handling but still failed
  because its latch-pair map omits that unreachable numeric latch. v16 pairs
  the latch using opcode, base register, adjacent normal-exit instruction,
  backedge destination, and outside target; it remains gated pending runtime
  and corpus tests. This is a real pre-existing semantic defect, not a hash
  drift relabeled as a runtime failure.
- v16 full audit: 357/360 combined, all v13 passes retained, five ten-cycle
  witnesses pass, zero execution/integrity errors. Static category audit has
  zero access losses. The sensitive first-item loop fixture now passes all 87
  source/two-cycle assertions. Binary SHA-256:
  90B2D16FFEB3D3B5F570B4727BDAB658D6E19DC75D235C80EC2914CE114B0531.
- v17 structured preference is a whole-prototype transaction. First try ordinary
  plain guards, accept only a complete successful renderer walk; otherwise
  restore the entire emitter and run the existing DAG-capable renderer/retry.
  Focused Network passes, avoiding the regression of broad/narrow deferral.
  LoadOut bytecode is exact with the repeated FORNPREP zero lifetime proof,
  but two source differences remain. Hud -61 bytes; Inventory +36 bytes.
- v18 tests exact plain-identifier truthiness in the existing empty-OR decision
  canonicalizer and adjacent compound numeric-index temporary lifetimes. The
  new compound case excludes captured scratch registers and only accepts a
  plain-register RHS consumer; lookup order remains unchanged.
- Research lookup corrections: modular.h was an incorrect guessed filename;
  file inventory identified m6e_cmd.h. Network's exact corpus filename is
  Lotus_Interface_LotusNetworkUtilities.lua_B; the missing-file audit rejected
  the abbreviated filename before executing any specimens (exit 2). Hud c90
  scoped diff was absent in the v13 folder; inspected native p89 directly.
- A review of inherited ordered-comparison normalizers found a hypothesis to
  test: replacing not(a < b) with b <= a can change NaN/metamethod behavior.
  Added a bounded runtime fixture; result pending. This is not waived by hashes.
- v18 full audit preserves all 357 combined passes and all five ten-cycle
  witnesses, with zero execution/integrity errors. Nested-index p89 drift is
  removed. LoadOut now has one source-only localized index-store lifetime.
- Ordered-comparison fixture: original source passes 16 assertions; first
  recovery fails for both original D734 and v18. one_cond/invert_cond currently
  confuse JUMPIFNOTLT/JUMPIFNOTLE with reversed positive relations, and several
  inherited canonicalizers repeat that assumption. v19 has a separately gated
  correction preserving negation and operand order through those normalizers.
- Hud loop-dispatch diagnostic proves a complete CFG rendering for p173 (313
  reachable blocks owned) but does NOT establish stability: a global enable
  yields +1556 bytes of drift. Keep it diagnostic. v19 tests a pristine final
  retry only after existing ownership retries failed.
- Inventory p154 rejects EFFECTFUL_LATCH_SPLIT_TRIANGLE: an early branch can
  reach either the shared continuation or an effectful loop latch. v19 tests
  a one-shot repeat for that bypass, leaving latch statements to the loop owner.
  It must pass path-sensitive tests, not merely remove the renderer rejection.
- v19 focused without the ordered-predicate switch: Network and LoadOut pass
  source and bytecode equality; Inventory remains +36, Hud's late DAG retry
  remains unstable. No promotion. Index-store runtime fixture passes 12 checks.
- v19 exact ordered predicates: 346/360 combined, five ten-cycle witnesses
  pass, execution/integrity errors zero. Eleven prior v18 passes are lost
  and LoadOut's source-only failure becomes a bytecode failure; residual list
  retained in full360-exact-predicates-v19.json. Correctness cannot be traded
  back for those hashes. Most new deltas are LOADNIL scratch lifetimes.
- Exact-predicate runtime correction passes 48 checks, including unchanged
  __lt/__le operation identity and operand order. Source is itself identical
  between its first and second recovered cycles.
- Effectful-latch fixture fails on v19: the CFG renderer claims a shared tail
  in both branches, and legacy fallback moves the loop body outside the loop.
  This is distinct from the proposed effectful-latch bypass, which rejects
  a private RETURN in Inventory before reaching a completed rendering.
- v20 adds loop-bounded early-return joins (stop at the current latch, preserve
  private-return ownership) and allows real RETURN nodes only inside the new
  effectful-latch repeat transaction. The fixture and the full fixed-point
  profile must be rechecked before accepting either change.
- v20 sensitive loop fixture passes 87 assertions. Focused Inventory p154 is
  now stable; Inventory p149 remains +4 bytes. Hud's large DAG growth drops to
  -12 bytes (three JUMPs), but both still fail combined source/bytecode checks.
- v21 restores exact raw-FORNPREP normalization using NOTLT operands and
  De Morgan, preserving short-circuit order and NaN behavior. It bounds shared
  return searches by pending outer joins. Focused CardUtilities, ColorPicker,
  PreviewLinkUtilities, and LoadOut pass; 10 of the 14 v19 failures remain.
- v22 normalizes discarded comparison expressions in their actual LT/LE
  operand order, removes paired NOTs only around proven boolean comparisons,
  handles a negated ordered left term in empty-OR arms, and resolves adjacent
  index chains before lexical localization. Full audit: 346/360 combined;
  five ten-cycle witnesses pass; zero execution/integrity errors. It fixes
  nine v19 failures but exposes nine others; exact lists retained in JSON.
- v23 moves the expanded loop/outer-boundary vocabulary into pristine retries
  after existing renderers fail. A guard's intermediate diamond must not cross
  its pending effect boundary. Hud's shared terminal block contains print,
  CLOSEUPVALS, RETURN; it cannot be duplicated. The new narrowly scoped terminal
  effect path owns it once and respects the pending outer join.
- Inventory's original p149 fallback puts a nil index in its entry prelude.
  This is not evidence of faithful stock behavior. Its CFG trace claims numeric
  loop prep 33 twice while traversing a guard whose real pending effect differs
  from the intermediate post-dominator. Current research fixes ownership before
  accepting source output. Do not label these broken fallbacks runtime-certified.
- v23 full audit: 354/360 combined, five ten-cycle witnesses pass, errors and
  integrity errors zero. Residuals: AvatarDiorama -4 bytes, EidolonJobBoard
  +12, Hud source-only, Inventory +4, Utilities +8, Map source-only. This run
  still allowed the inherited complete-ownership no-op and is not a release.
- **Sensitive complete-ownership failure:** shared_terminal_effect_fixture
  returns nil and omits the completion log on enabled=false. The existing CFG
  renderer reports all eight reachable blocks emitted, but emitted the common
  continuation inside enabled=true only. This demonstrates why block coverage
  alone is not a path proof. Enabling RENOVICE_CFG_REJECT_OWNERSHIP_NOOP with
  v23 fixes all 45 source/two-cycle runtime assertions. Keep this rejection in
  the strict candidate; do not recover a count by restoring that shortcut.
- v23 effectful-latch runtime fixture still passes 87 assertions. Original Hud
  p173 now renders all 284 blocks with the expanded terminal-effect retry.
- v24 tests atomic delegation of an entire guard diamond before its root is
  claimed, so a shared source-loop preheader can be rendered once. It also
  drops NOT polarity only for a comparison value already proved discarded;
  the actual comparison/metamethod and operand order remain present. This
  avoids compiler-generated boolean/NOT scratches in EidolonJobBoard.
- v24 strict full audit: 354/360; five ten-cycle witnesses pass; zero errors/integrity errors.
- v25 linear return guards and adjacent index recovery: 356/360; five ten-cycle witnesses pass; zero errors/integrity errors. Hud and Map close. Runtime fixtures: index/first-loop 87 and linear-return guards 96 assertions pass.
- v26 pending guard joins and root empty-return tails: 358/360; five ten-cycle witnesses pass; zero execution/integrity errors. Background and DiegeticUpgradeCards close; Inventory c86 is solved but c155/p154 now drifts +32 bytes. Disabling only pending-join passes Inventory; disabling only root-return-tail does not. Keep investigating ownership, not hiding the defect with a filename exception. UpgradeCards original p49 renders all 133 reachable blocks.
- Two attempted v25 source.diff reads referenced nonexistent harness outputs. Corrected by comparing retained 01.luau/02.luau directly with git diff --no-index. No validation result depended on the missing files.
- v27 full audit remains 358/360 with the same two failures and five passing ten-cycle witnesses. Nested/leading/returning-arm syntax rules do not close Utilities yet. Runtime guard fixture: 363 assertions pass. Private-loop-terminal fixture: 1551 pass, but it also passes v27 so it is not a sensitive reproduction of Inventory.
- Sensitive stock-derived Inventory p154 guard fixture proves the v27 defect: source passes four original-CFG entry cases (8 assertions), recovered cycle 1 errors with attempt to index nil with nil before its first early return. Kept source, runtime failure JSON, and generated source under research. No in-game claim.
- v28 renders original Inventory p154 with all 97 reachable blocks, passes its source/bytecode fixed point, and passes the sensitive stock-entry fixture (24 total assertions). Stock-derived loop fixture covers empty items, no price, deployed drone, time-limited item, last sentinel, and a second-item early return: 72 case assertions pass, plus ResetLineCount argument assertions.
- v28 full audit: 356/360; five ten-cycle witnesses pass; zero execution/integrity/diagnostic errors. New representation drift in CharacterIntro, Friends, and Map; Utilities now includes p484 and p520. v29 moves new terminal/exit vocabulary into a final pristine whole-prototype retry to preserve earlier complete CFG renderings, and normalizes returning repeat tails before lexical recovery/after later producers.
- v29 full audit: 352/360, five ten-cycle witnesses pass, zero execution/integrity errors. At this point both broad root-repeat normalization and the additional terminal retry were suspects; later v31 A/B rejects the root-normalizer explanation for ImGui, StatCompare, and Inventory. Utilities p484 closes but p520 retains one JUMP; its returning-arm scanner incorrectly stopped at an if belonging to the tail, now corrected.
- The combined v29 fixture suite catches an older v26 regression: effectful-latch fixture fails at recovered cycle 1. Disabling the new root normalizer does not help; disabling pending-join does. CFG trace proves a false bypass: reachability to the pending follow was allowed through the candidate effect itself, so a prefix with no actual bypass was claimed before rejection. v30 requires reaching the pending continuation without passing through that effect. Keep the failed runtime artifact; hashes cannot replace this check.
- v30 passes all 18 runtime fixtures: 3165 case assertions across original source and two recovered cycles (plus some helper argument assertions). Focused stock audit is 5/10: CharacterIntro, Map, PreviewLink, Background, and UpgradeCards pass; ImGuiEntityViewer, StatCompare, Dojo Trade, Inventory, Utilities still drift. Utilities p520 closes; p484 remains +16 bytes.
- Source evidence for Utilities p484: its raw final return is inside an if/else, followed by the implicit empty root return. Requiring an identical nil-tuple setup at the physical root tail rejects the intended normal form unnecessarily. v31 retains the multi-nil failure-tuple restriction and the complete returning-tail proof, without that extra syntactic equality.
- v31 also A/B tests the v28 order of extended terminal proofs within the initial expanded retry, now with the corrected real-bypass preflight. This is a rendering-order hypothesis, not an acceptance of the earlier runtime defect.
- v31 runtime suite passes all 18 fixtures (3165 case assertions). Focused audit 5/11. Disabling the root normalizer leaves ImGui, StatCompare, and Inventory differences unchanged, falsifying that suspected cause.
- v32 disables the redundant unconditional extra terminal retry while retaining the terminal vocabulary in the initial expanded retry. Focused audit improves to 7/11; ImGui, StatCompare, and Inventory p96 recover. Remaining: Dojo Trade p67 -48, Friends p157 -4, Inventory p154 +92, Utilities p520 -4. This is a configuration A/B on the v31 binary, not a new build. Preserve no-extra-retry in the next candidate.
- v33 hypotheses: normalize an entire root repeat with a single returning escape before the older shared-break pass distributes its final break into both arms; find a bounded common continuation before the loop latch when private returns erase the real post-dominator. Inventory p154 needs the common suffix before its latch to remain singly owned; otherwise a broad loop dispatcher changes prefix spelling between cycles.
- v33 focused audit: 7/8 pass, only Inventory p154 remains +92 bytes. Friends, Utilities and Dojo Trade now close. Runtime suite 18/18, 3165 case assertions. Added a stock-derived Dojo p67 oracle for six slots, Plat/Card skips, nested MOD/PLATINUM skipping, Filler callback ordering and completion: 48 case assertions pass. This grows the retained suite to 19 fixtures / 3213 case assertions for future runs.
- v34 diagnosis: in ownership-retry mode, emit_acyclic_dispatch classifies guard boundaries as source-loop boundaries because terminal>=0 and domain!=null, although the domain is the whole prototype. It then cannot find an authoritative loop with that domain and returns early. Earlier attempts emit Inventory's five-block prelude as a guard dispatcher; the ownership retry emits it as a repeat instead, causing cycle drift. A guard-to-effect request must not also take the source-loop dispatcher route. v34 adds this explicit separation; whole-DAG and ownership checks remain unchanged.
- v33 full audit confirms 359/360 raw source+bytecode fixed points; five ten-cycle witnesses pass; zero execution/integrity errors. Only Inventory p154 +92 remains. Saved binary F449812A45B3044D2A27D51AAB5F82202EDF62D495AD842957716EB15CD2ECBA as baseline/derecomp-v33-strict359.exe. It also passes the 18-fixture suite and separate stock Dojo fixture. No defaults promoted.
- v34 focused Inventory source and bytecode fixed point passes. The 19-fixture runtime suite passes all 3213 case assertions. Binary BD90C62E07594D3F4BD0DD1BD950C8ED0FCA76DA89B1C2EB9CF15DFB3E923E52. Full 360 + five ten-cycle audit now running; no default promotion before it completes.
- Confirmed current stock corpus has 5386 .lua_B files. The prior 17374 figure in the 360-file certificate counts function prototypes, not script files.
- v34 full audit PASS: 360/360 raw source+bytecode fixed points, five ten-cycle witnesses, no execution/integrity errors. All 19 runtime fixtures pass (3213 case assertions). Saved candidate binary as baseline/derecomp-v34-strict360.exe.
- The complete tested feature set is now being installed in main.cpp defaults. Removed the inherited ACCEPT_COMPLETE_OWNERSHIP default; retained strict REJECT_OWNERSHIP_NOOP. The redundant extra terminal retry remains diagnostic and is not enabled. Next: build and certify the actual default binary, all-category access audit, difficult ten-cycle witnesses, and isolated release gates. Nothing has been deployed into game/server/ability-editor.
- Default v35 build passes warnings-as-errors and all built-in selftests. Binary SHA-256: 40BC733B43E366A7E65CFB40BDFD13D3F71B268C65F3841155B593D3F3DBA5D3. Raw full-sample certification passes 360/360 plus five ten-cycle witnesses; six additional distinct difficult witnesses pass through cycle 10. No process errors, integrity errors, or decompiler diagnostics. No external experimental profile was set.
- Promotion-equivalence hypothesis TRUE: candidate v34 and default v35 use identical stock inputs and produce identical cycle-one source and rebuilt-bytecode hashes for all 360 files. Evidence: default-promotion-comparison-v35.json. Independent allcats360: CLEAN 256, ORDER-DIFF 88, LOOP-DIFF 35, ACCESS-GAIN 10, PROTO-COUNT-DIFF 9, ACCESS-LOSS-TOTAL 0; binary unchanged.
- Isolated default release gates PASS at the existing thresholds: realtrip 150/150, zero differences/timeouts; ALIGNED 211; NAME-DIFF 0; loop MATCH 266; dropped paths/dead tails/access loss zero. Source-grounded Semantic IR 150/150 and Warframe API traces 11/11 with zero vacuous cases. Full metrics and tool hashes: default-release-gates-v35.json.
- Configuration cross-check TRUE: the 19-fixture suite passes 3213 case assertions with ordinary compiler settings and repeats all 3213 under the corpus audit's native-opcode/global settings. The fidelity environment is retained explicitly. This resolves the risk of comparing fixture and corpus results from different compiler settings; both result JSON files pin the same binary.
- Final integrity check passes for the default binary, Luau frontend/runtime, emitter, main source, and idempotence harness. Updated README, M6_TRUTH, and the superseded D734 closeout to point to RESULTS.md. Historical negative evidence remains intact. Raw 350-to-360 work is complete for the selected sample; separate presentation-layer promotion and whole-corpus/in-game certification are not implied.
- 2026-09-06 semantic-layer work changed only shared semantic renderer/planner paths, then rebuilt the common executable as `C4A1355F8893C02A8B6C431DA7A9DC328491512545B8592ACE6149B98E5B196E`. The raw lane was therefore recertified rather than assumed unchanged: 360/360 fixed points, five default plus six difficult ten-cycle witnesses, canonical 300/150 gates, allcats360 access loss 0, and both 19-fixture/3,213-assertion configurations pass.
- The selected 360-file semantic ownership and IR sweeps both pass 17,374/17,374 prototypes. Ability Studio's final hash-pinned transaction audit accepts 360/360 and publishes 1,800/1,800 coordinated artifacts with no residue. Exact semantic evidence is in the Ability Editor `RESEARCH/SEMANTIC_BEAUTIFICATION_360_2026-09-05/STATUS.md`.
- Negative broader-corpus boundary: an accidental but retained unfiltered sweep covered all 5,386 local scripts. Ownership passed 82,039/82,059 prototypes with 20 failures; Semantic IR passed 82,051/82,059 with 8 failures. These are not raw fixed-point results and do not alter the completed selected-360 claim. They remain the next semantic expansion backlog.
