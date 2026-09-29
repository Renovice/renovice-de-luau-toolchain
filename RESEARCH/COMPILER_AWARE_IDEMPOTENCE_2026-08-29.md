# Compiler-aware idempotence pass — 2026-08-29 to 2026-08-30

## Objective

Make decompiled Luau converge to the spelling and register layout that the stock Luau compiler
actually produces, without special-casing Warframe script names and without weakening any semantic
release gate. Fidelity output remains the source of truth; the normalizers only choose a deterministic
source-equivalent spelling when their proof conditions hold.

## Certified result

The original deterministic target is complete. The normal binary, with no caller-supplied feature
flags, now installs the A/B-tested profile and passes both certification tiers:

| measurement | initial | certified default |
|---|---:|---:|
| strict source + bytecode + structure fixed points | 10 / 90 | **90 / 90** |
| aggregate cycle-1 → cycle-2 byte delta | +27,318 | **0** |
| aggregate max-stack delta | not certified | **0** |
| aggregate prototype delta | not certified | **0** |
| execution errors | 0 | **0** |
| default large specimens stable through cycle 10 | 0 / 5 | **5 / 5** |

Certified binary:

- `bin/derecomp.exe`
- SHA-256: `68D769D6C041829A5A839F4AB3C227BC26C66E2873EAC82455B1A2C07C620DB0`
- Machine-readable certificate:
  `cert/baselines/fixed-point-release-final-90-2026-08-30.json`

The same binary also measured a deterministic 360-file expansion:

- strict fixed points: **327 / 360**;
- drift: **33 / 360**;
- source-only drift: **0 / 33**;
- bytecode drift: **33 / 33**;
- structural drift: **33 / 33**;
- setup or execution errors: **0**;
- certificate: `cert/baselines/expanded-audit-release-final-2026-08-30.json`.

This is an increase of 18 strict fixed points over the prior 309/360 boundary, with zero regressions
among the 309 files that previously passed. The focused opcode/control-flow regression set is also
**12/12**, with its five large specimens **5/5** through cycle 10; see
`cert/baselines/focused-opcode-regressions-release-final.json`.

The semantic release gate for this same binary is also green: reachable access loss **0**, dropped
paths **0**, dead tails **0**, native NAMECALL exact, Warframe API traces **11/11**, Semantic IR
behavior **150/150**, and full behavioral round-trip **150/150**. See
`cert/baselines/release-gates-final-2026-08-30.json`.

The expansion is a measured boundary, not a pass and not a claim that all 5,386 corpus files are
fixed points. It was intentionally run in measurement mode so all residual families were captured.

Strict command used for the completed 90-file target:

```powershell
python cert\idempotence.py 90 --json-out cert\baselines\fixed-point-release-final-90-2026-08-30.json
```

## Accepted hypotheses

### H1 — sparse flat local names cause alpha-only source drift: TRUE

Evidence: source such as `local v1, v3, v4` is allocated densely by Luau and comes back as different
physical suffixes on cycle two. The guarded declaration-order canonicalizer now predicts that dense
allocation. It fails closed if the target name collides with a lexical binding.

### H2 — compiler-generated loop variables need lexical, allocation-independent names: TRUE

Numeric and generic `for` variables are now named `__renovice_for_<loop>_<index>`. Header right-hand
sides remain in the outer scope; body uses select the innermost matching binding. This removes slot
renaming drift without changing loop evaluation order.

### H3 — synthesized selector names must survive a compile cycle: TRUE, with a restricted proof

Emitter-created selectors use deterministic `__renovice_state_N` names. On a recompiled input the
name can be recovered only when all of the following are true:

1. the register has a definition followed by at least two integer-state tests;
2. its uses do not escape the proven lexical scope;
3. a nested selector is initialized by an integer literal, matching the generated Proper/SCC or
   escape-selector form.

This stabilizes the themed background family and four additional state-machine specimens while
leaving ordinary nested values untouched.

### H4 — the one-pass composite selector has a stock-compiler canonical form: TRUE for the guarded shape

When the generated head contains exactly one propagation guard and one terminal generated escape,
the emitter writes the compiler's straight-line `if selector == -1` form and a nested `else`/`if` arm
chain. A stock compiler probe showed that `repeat ... until true` otherwise leaves two disposable
JUMPs. The opt-out `RENOVICE_NO_DIRECT_SELECTOR=1` remains available for differential diagnosis.

### H5 — explicit tail return and predicate negation-normal form remove spelling drift: TRUE

The emitter spells the stock compiler's implicit zero-result tail return explicitly and renders
compound predicate trees with NOT pushed to opcode-aware leaves. This gives equivalent short-circuit
trees one deterministic source spelling. `RENOVICE_NO_PREDICATE_NNF=1` provides a diagnostic A/B path.

### H6 — private return-only loop arms can be reconstructed without absorbing sibling flow: TRUE

The CFG renderer now accepts the proven private-arm shape and retries only when the first ownership
attempt fails for the specific collision it knows how to resolve. This stabilized loop-heavy
specimens without widening the general ownership rules.

### H7 — complete semantic ownership can be accepted as a no-op: TRUE

When every reachable block already has one exact owner, forcing an additional structural promotion
only creates new spelling drift. The guarded complete-ownership path now keeps the verified region.

### H8 — generic-for loop intervals must begin at the taken body successor: TRUE

For a generic loop, the body normally precedes the `FORGLOOP` latch in bytecode layout. Treating the
latch as both ends of the interval discarded the body and made nested branches appear ownerless.
Using the taken successor as the body boundary fixed the general loop model rather than a named file.

### H9 — an acyclic dispatcher is safe only for the proven ownership-collision retry: TRUE

The dispatcher fallback is now scoped to a failed collision retry and uses topological rank for its
state values. Raw block numbers are layout artifacts; topological states are deterministic across a
compile cycle.

### H10 — a closed terminal dispatcher needs an explicit terminal return: TRUE

When all dispatcher arms are closed, spelling the final no-result return prevents the compiler from
creating a different terminal CFG on the next cycle.

### H11 — exact-return arm trees have a compiler-stable structured form: TRUE

The guarded renderer replaces one-shot `repeat ... until true` wrappers with nested `if`/`else` only
when every arm has an exact terminal return. This removed the remaining Background prototype drift.

### H12 — shared-continue rewriting must be a final normalization: TRUE

Distributing a shared `continue` before later loop/guard rewrites caused it to be duplicated or placed
after a direct `break`/`return`. Deferring the rewrite and deleting unreachable terminal-command plus
`continue` pairs made the emitted source valid and deterministic.

### H13 — prototype-level diagnostics materially shorten fixed-point debugging: TRUE

`de-proto-diff` reports header, code, constant, max-stack, prototype, and opcode deltas for each
closure. `decompile` and `decompile-mod` can write directly to an output path, so diagnostics no
longer depend on shell redirection changing encodings or hiding partial output.

### H14 — terminal boolean diamonds were under-recognized after lexical recovery: TRUE

The existing guard-return normalizer required a raw `vN` assignment target and assumed the final
return contained only that boolean. Captured names, `__renovice_local_N`, empty returns, and
multi-value returns therefore drifted despite having the same compiled program. Proving one plain
assignment identifier plus one exact terminal return fixed ten files without changing bytecode.

### H15 — compiler source spelling needs a final exact-control cleanup: TRUE

The remaining small families were exact source equivalents: multiline versus inline break arms,
shared versus distributed breaks, adjacent break guards, adjacent terminal state tests, unreachable
empty loops after a return, and capture substitution producing `local = local`. Syntax-tight final
normalizers fixed those forms without inspecting script names.

### H16 — terminal loop tails need ownership-independent canonical rotation: TRUE

Native and compiler-generated CFGs represented the same loop tail as guard-`continue`, wrapped
single-arm bodies, nested else chains, or break-owned tails. Requiring the innermost loop boundary,
exact terminal transfer, and complete lexical tail allowed those shapes to converge. The focused
22-file set became 22/22, while the full expansion gained exactly 22 files with zero regressions.

### H17 — generic-for source arity belongs to the paired FORGLOOP: TRUE

A `FORGPREP` does not carry the number of source loop variables. Defaulting every prep to two variables
made native one-variable loops recompile with a different frame. Reading the low-byte arity from the
unique paired `FORGLOOP` fixed the family without inspecting filenames or register numbers.

### H18 — compiler-stable terminal guards require exact lexical ownership: TRUE

Terminal boolean diamonds, comparison-driven while guards, shared returns, and loop-tail breaks can be
rotated only when the complete path between the decision and terminal transfer contains no executable
statement. Exact indentation and innermost-loop boundaries proved that ownership. Wider variants were
rejected by the release gates; the restricted forms stabilized the focused opcode family.

### H19 — partial state recovery is safe only for a proven tail-owned interval: TRUE

Generated selector recovery now requires its integer definitions/tests to form the complete tail of the
candidate scope. Lexical declaration order supplies deterministic generated-state names, and duplicate
empty pure-truthiness guards are removed only when the immediately following real guard evaluates the
same side-effect-free expression. This fixed slot reuse without global live-range rewriting.

### H20 — an explicit nil first definition can be ordinary slot reuse, not a selector: TRUE

`AvatarDiorama` reused one physical register for an early `nil` object slot and later integer state
tests. Counting the later tests across the whole function falsely localized the `nil` definition as a
dispatcher. Rejecting a top-level candidate whose first value is explicitly `nil` removed the extra
`LOADNIL`/call-frame drift. The focused file now passes source, bytecode, stack, prototype, and opcode
checks at cycle two.

### H21 — one-shot Proper wrappers need both control and local-lifetime canonicalization: TRUE

`ControllerLayout` contained nested `repeat ... until true` shells used only to provide generated
selector break targets. Flattening the two proven wrapper shapes and rotating direct selector-break
tails removed the control-flow drift. One instruction still remained because Luau physicalized the
flattened comparison selector on cycle two. Binding that uniquely declared selector to the next frame
slot on cycle one reproduced the same function-wide nil lifetime. The result is exact source and exact
bytecode, not merely equal byte counts.

### H22 — parser-only source forms should converge before recompilation: TRUE

Luau removes parentheses from `not (vN)` and collapses an outer fully parenthesized condition whose
entire body is one inner condition into a short-circuit `and`. Normalizing only those grammar-proven
forms fixed `ConclaveModeSelection`, `DiegeticArtifactCards`, and the final source-only expansion case,
`ThemedCustomizationList`, without changing bytecode.

### H23 — rotating a generated state break-tail must retain the break: TRUE

The generated selector assignment records the state observed after a loop; it is not a control
transfer. The first break-tail canonicalizer moved the remaining loop body into an `else` arm but
dropped the source `break`. In ChatRedux prototype 188, three early exits became `continue` inside an
unbounded `while true`, making the following numeric loop and callback block unreachable. Preserving
the exact break recovered all **39 / 39** missing accesses from that prototype.

### H24 — a split branch into an early return and an effectful latch must fail closed: TRUE

ChatRedux prototype 152 has a numeric-loop branch whose paths reach either a return arm or a latch
that executes `Parts`/`table.insert` before `FORNLOOP`. A simple triangle cannot emit the later return
unconditionally, and it cannot use `continue` because that skips the latch payload. The CFG renderer
now rejects only this measured mixed-ownership shape and transactionally falls back to the legacy
renderer. That recovered the remaining **2 / 2** accesses. The complete module now round-trips
**15,040 / 15,040** reachable accesses with zero missing and zero extra.

## Rejected hypotheses and negative evidence

### R1 — all indentation-contained nested state candidates are safe to localize: FALSE

The first implementation accepted any nested definition with repeated state tests and no textual use
outside its indentation scope. The 300-file release gate found:

- `Lotus_Interface_DiegeticFoundry.lua_B`
- 155 reachable named accesses lost after recompilation
- aggregate access loss rose from 0 to 155
- lost headers rose from 359 to 361

Differential tests proved that direct selector lowering and predicate normalization were not the
cause. Disabling entry-state localization removed the access loss. The offending nested value was
initialized from `v10[16]`, not from a generated integer state. Restricting nested localization to an
integer initializer preserved all focused fixed points and restored access loss to zero.

### R2 — physical-register live-range intervals can safely split every disjoint state machine: FALSE

The interval experiment worsened `Utilities` from one extra `LOADNIL` to fourteen extra `LOADNIL`
plus four `MOVE`s, and worsened `Anchor` by twenty-two `LOADNIL`s. The experiment was fully reverted.

### R3 — the new direct-selector lowering caused the Foundry loss: FALSE

`RENOVICE_NO_DIRECT_SELECTOR=1` retained the exact same 155-access loss. It was not rolled back.

### R4 — predicate negation-normal form caused the Foundry loss: FALSE

The legacy predicate renderer retained the exact same 155-access loss. The canonical renderer was
kept.

### R5 — duplicate a crossing branch to avoid dispatcher lowering: FALSE

The experiment caused exponential source growth across cycles. It was removed completely.

### R6 — enable the acyclic loop dispatcher globally: FALSE

The broad switch fixed a focused family but regressed `DragScroll`, `ImGui`, and prototype 75 in the
deterministic set. Only the proof-scoped collision retry remains enabled.

### R7 — localize every top-level first definition: FALSE

The wider localization changed allocation and control spelling in both Background and Anchor. The
experiment was removed; the narrow selector proof remains.

### R8 — raw block-number state canonicalization alone fixes Background prototype 9: FALSE

Changing only the state numbering did not fix the source cycle. Topological state IDs were retained as
a general determinism improvement, but the actual p9 fix was the exact-return structured arm renderer.

### R9 — invert the equality inside any compound terminal-loop predicate: FALSE

The first loop-tail implementation treated `(A ~= B or C < D)` as though flipping only `~=` negated
the whole expression. Background immediately regressed from exact to an opcode-polarity drift. The
90-file gate caught it before certification. The rule now rejects `and`, `or`, and parenthesized
conditions; compound negation remains owned by the opcode-aware predicate pass. Background returned
to exact, and all 22 focused source-only files still passed.

### R10 — broad shared-return and generalized terminal-guard rotation are safe: FALSE

The broad forms absorbed sibling work or changed which loop owned the transfer. Only exact terminal
paths with no intervening executable line survived focused and 90-file A/B gates.

### R11 — global live ranges, disabled disjoint-state intervals, or uncovered-prefix intervals solve
the remaining allocator drift: FALSE

Global live-range rewriting multiplied `LOADNIL`/`MOVE` drift. Disabling disjoint selector intervals
regressed already stable files, and accepting an uncovered prefix allowed unrelated slot reuse into a
generated binding. All three experiments were removed; only tail-owned interval proofs remain.

### R12 — ControllerLayout needs the broad acyclic loop dispatcher: FALSE

`RENOVICE_CFG_LOOP_ACYCLIC_DISPATCH=1` moved the ownership collision from one block to another and
failed with an already-emitted start block. The successful fix was the source-equivalent one-shot
wrapper plus physical-selector lifetime normalization, not a wider dispatcher fallback.

### R13 — direct exit-join rendering or boundary-triangle ownership without retry is sufficient: FALSE

Direct exit-join rendering revisited an already owned block. Enabling the boundary triangle outside
the proven retry path produced the same ownership conflict. Both broad experiments were removed; the
guarded collision retry remains the only accepted boundary-triangle path.

### R14 — any effectful latch-shaped block can be emitted as `continue`: FALSE

Some secondary latch/side blocks execute real work before the authoritative loop latch. Treating those
blocks as `continue` skipped their effects and changed branch layout. Continue classification now uses
the exact authoritative loop contract rather than a back-edge-shaped heuristic.

## Remaining work

The original 90-file checklist, focused 12-file opcode set, and five large long-cycle specimens are
finished. The deterministic expansion is now 327/360, up from 309/360 with zero regressions. Every
remaining file has both bytecode and structural drift; there are no source-only residuals and no
execution errors. The 33 residual files must be handled by structural families, not filename checks
or one-off source substitutions.

Largest measured byte deltas are `ContextAction` (+21,202), `LoadOutRedux` (+6,013), `ChatRedux`
(+4,887), `MapRedux` (+3,328), `EndOfMatch` (+1,755), `HudRedux` (+1,359), `LotusUtilities` (+601),
`InventoryTest` (+524), `DiegeticFoundry` (+356), `Codex` (-158), and `Hub` (-152). They require
prototype-level CFG/frame evidence rather than additional source spelling cleanup.

After the 360-file set is strict, expand the deterministic certificate again and eventually run all
5,386 files. Until then, full-corpus fixed-point parity remains unproven.

## Evidence locations

Diagnostics are organized under:

`work/diagnostics/de-luau-idempotence/2026-08-29/`

and:

`work/diagnostics/de-luau-idempotence/2026-08-30/`

Important result sets:

- `families.json` — initial failure clustering
- `loop-probes/` — stock compiler loop-form probes
- `direct-selector-90/results.json` — 58/90 candidate result before the full-gate audit
- `state-interval-focused/` — rejected live-range interval experiment
- `foundry-safe-artifact/` — focused Foundry cycles used during the semantic-loss bisect
- `final-guarded-90/results.json` — guarded intermediate measurement
- `cert/baselines/probe-background-final-source-v9.json` — Background exact through four cycles
- `cert/baselines/probe-background-and-expanded-syntax-v4.json` — syntax-clean focused expansion
- `cert/baselines/probe-expanded-source-only-4-v6.json` — final focused loop-tail proof, 4/4
- `cert/baselines/probe-source-canonical-guarded-5-v8.json` — Background regression guard plus 4/4
- `cert/baselines/focused-opcode-regressions-release-final.json` — focused 12/12 plus long 5/5
- `cert/baselines/fixed-point-release-final-90-2026-08-30.json` — current strict 90/90 certificate
- `cert/baselines/expanded-audit-release-final-2026-08-30.json` — current 327/360 boundary
- `cert/baselines/release-gates-final-2026-08-30.json` — zero-loss semantic release verdict

The four final certificates above are the authoritative current measurements for binary SHA-256
`68D769D6C041829A5A839F4AB3C227BC26C66E2873EAC82455B1A2C07C620DB0`.
