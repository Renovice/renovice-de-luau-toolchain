# Semantic IR human-readable layer — 2026-08-28

## Outcome

The production C++ decompiler now emits a human-readable source view beside,
not instead of, its fidelity view. Both are rendered from the same verified
Semantic IR. The readable path supplies identifiers at the renderer's single
`web_name` boundary; it does not run legacy text substitutions and cannot edit
control flow, expressions, calls, closure captures, or statement ordering.

One invocation produces three coordinated files:

1. canonical fidelity Luau;
2. human-readable Luau;
3. TSV mapping `prototype + web + canonical + readable + confidence + evidence`.

## Hypotheses and results

| Hypothesis | Evidence | Result |
|---|---|---|
| A second view can preserve the existing fidelity output exactly. | RunnerRush was rendered once with `semantic-ir-render-module` and once as the fidelity twin of `semantic-ir-render-module-readable`. Both SHA-256 values were `16842054E85EDCA4A8C3894593D317EC053D8007AB931E93C833CA3FF4D1EF26`. | **TRUE** |
| Readability can be implemented without a text-rewrite pipeline. | `source_renderer::Naming` is consulted only by `web_name`. Child and dispatcher renderers receive the same immutable naming table. | **TRUE** |
| The existing API work from the earlier AI is useful to this layer. | `api/warframe/selected_catalog.tsv` supplies corpus-derived owner/result hints; `contracts.tsv` supplies stronger parameter, return, and evidence contracts. Gauss/RunnerRush gained names including `rotation`, `entity`, `inventoryControl`, and `weapon`. | **TRUE** |
| API/catalog evidence can recover every original local name. | The ability corpus produced 1,709 ambiguity diagnostics. DE bytecode does not preserve arbitrary author-local names, and several webs have equally strong conflicting roles. Those webs remained canonical. | **FALSE** |
| Readable aliases can safely replace frame-backed dispatcher storage. | 1,818 of 6,035 contextual prototypes used frame storage. Replacing `frame_N[web]` with an identifier would change the lowering shape, so aliases are kept in the sidecar for those cases. | **FALSE** |
| The readable view remains valid, reparsable Luau across the complete primary ability corpus. | `semantic-ir-render-module-corpus --abilities --compile-rendered --readable` rendered 286/286 readable modules, compiled and reparsed 286/286, preserved all 6,035 prototype trees/root identities, and reported zero readable failures. | **TRUE** |

## Gauss/RunnerRush vertical slice

The user-provided fidelity fragment was located in
`Lotus_Powersuits_Runner_Abilities_RunnerRush.lua_B`.

Representative changes in the readable view:

```luau
impactBurstFunction = function(sourceAbility, p12_1, p12_2, p12_3, p12_4, p12_5)
    avatarOwner = sourceAbility:GetAvatarOwner()
    rotation = avatarOwner:GetSimRotation()
    region = gRegion
    entity = region:CreateEntity(...)
end
ImpactBurst = impactBurstFunction
```

Names without sufficient evidence, including some remaining parameters, stay
`p12_N`/`v12_N`. Unresolved native hashes such as `Name__a50e34c3` remain exact.

## Gates run

```text
build.bat
  TRANSCODE_GLOBAL_SELFTEST PASS
  CLOSURE INDEX SELFTEST PASS checks=7 failures=0
  SEMANTIC_IR_READABLE_SELFTEST assertions=9 passed=9 failed=0
  CLOSURE_MAP PASS

semantic-ir-selftest
  assertions=140 passed=140 failed=0

semantic-ir-lowering-selftest
  assertions=22 passed=22 failed=0 runtime_exit=0

semantic-ir-render-module-corpus --abilities --compile-rendered --readable
  modules=286 accepted=286 rejected=0 semantic_failed=0
  prototypes=6035 accepted=6035
  context_renderer_compile=passed:6035 failed:0
  module_compile=passed:286 failed:0
  readable=attempted:286 rendered:286 failed:0 aliases:150494 diagnostics:1709
  readable_compile=passed:286 failed:0

Ability Editor C++ build
  warnings-as-errors build PASS
  ctest 1/1 PASS
  render-source transaction smoke PASS on RunnerRush
```

Machine-readable corpus report:
`stage/readable-corpus-2026-08-28.json`.

## Fail-closed boundaries

- An unknown or conflicting alias is omitted, never guessed.
- `Name__<hash>` and `G_<hash>` identities are not renamed.
- Readable rendering must use the same dispatcher/frame strategy as fidelity.
- Readable Luau must compile before the coordinated outputs are published.
- Corpus gates compile, parse, and check prototype count/root identity for both
  views.
- Ability Studio preserves and restores prior files if activation of any member
  of the readable/fidelity/map transaction fails.

## Remaining work, deliberately not misrepresented as complete

- Original developer-chosen local names cannot be recovered when bytecode never
  stored them.
- API hints can be expanded as contracts become confirmed; the TSV evidence
  makes such upgrades auditable.
- Frame-backed dispatcher functions remain mechanically indexed in source.
- This layer improves identifiers. It does not yet perform higher-level source
  transforms such as folding a closure assignment plus later global store into
  a single function declaration, because that requires separate capture/use
  equivalence proof.
