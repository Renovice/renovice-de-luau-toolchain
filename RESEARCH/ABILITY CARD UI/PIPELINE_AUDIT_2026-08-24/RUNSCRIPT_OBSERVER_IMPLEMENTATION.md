# Observation-only `RunScript` adapter

Date: 2026-08-24

Status: source and offline gates pass; built but not staged or deployed

## Purpose

This is gate 1 of the corrected addon-card architecture. It does not append,
remove, or change a row. It answers the remaining runtime questions before any
mutation is allowed:

1. Does the current SWIG `RunScript` binding resolve to one unambiguous native
   implementation?
2. Does the Arsenal card call arrive with the corpus-proven four arguments and
   synchronous flag?
3. Is `_T.AbilityLevelQueryParms` visible in the same Luau global state at the
   wrapper boundary?
4. Does `_T.AbilityUpgradeLevelInfo` exist immediately after the original
   `RunScript` returns?
5. Do Mallet's base and modded calls share the same ability identity while
   carrying different `Modded` values?

## Recovered binding contract

The bootstrapper's current SWIG registry defines every method entry as:

```cpp
struct SwigMethod
{
    std::uint32_t hash;
    int (*func)(luau_State*);
};
```

The current ability corpus resolves:

```text
RunScript hash=0xf4950b15 modules=3 sites=7 arguments=4 results=0
```

This proves the Luau/SWIG wrapper ABI used by the adapter. It does not prove an
internal engine `ScriptMgr` ABI, and the implementation does not detour a raw
executable address.

At runtime the installer enumerates the already-discovered `swig_types` table,
collects every method entry with the `RunScript` hash, and accepts them only if
all aliases point to exactly one original function. Zero bindings or multiple
distinct implementations fail closed and leave every entry untouched.

## Observation filter

The wrapper calls the original unchanged unless all conditions are true:

```text
target-addon observation enabled
AND not recursively inside the observer
AND RunScript argument count == 4
AND argument 4 is boolean true
AND current global _T exists
AND _T.AbilityLevelQueryParms is a table
AND query.Ability is non-nil
```

The query table is the semantic discriminator. Unrelated synchronous
`RunScript` calls without an active ability-level query remain transparent.

The observer currently records, but does not interpret or mutate:

- sequence number;
- Luau global-state pointer;
- owner thread;
- all four argument tags and raw identities;
- query-table tag and identity;
- ability tag and identity;
- `Modded` boolean;
- ability level;
- original C result count;
- result-table tag and identity;
- whether the global-state pointer remained the same;
- final observation classification.

Expected log pair:

```text
RENOVICE card query OBSERVE phase=before seq=... vm=... modded=0 ...
RENOVICE card query OBSERVE phase=after  seq=... vm=... same_vm=1 original_results=0 ... status=complete
```

Opening one Mallet card should yield two complete pairs: one `modded=0` and one
`modded=1` for the same ability identity. Additional pairs are not silently
ignored; their caller/query evidence must be explained before a row adapter is
implemented.

## Stack and behavior preservation

- The wrapper snapshots the four argument tags/identities only after stack
  capacity checks are complete.
- Query/result reads restore `state->outtop` to its exact incoming value.
- The original SWIG function is called exactly once.
- The original integer result count is returned unchanged.
- Any values produced by a nonzero original result count remain below the
  temporary observation stack and are preserved.
- A thread-local re-entry guard passes nested calls directly to the original.
- No Lua callback, addon callback, card provider, timer, filesystem read, or
  per-frame scan is performed.
- The rejected cached-export decorator remains in source for negative evidence
  but is runtime-disabled during this observation pass.

## Offline hypotheses

| Hypothesis | Evidence | Result |
|---|---|---|
| The repository already knows the SWIG wrapper ABI. | `SwigMethod::func` is `luau_CFunction`, defined as `int(*)(luau_State*)`. | **TRUE** |
| A fixed raw RVA is required to observe `RunScript`. | The method registry resolves one unique live wrapper address, which can be detoured without a build-specific hard-coded RVA. | **FALSE** |
| Mutating a `SwigMethod` descriptor after registration intercepts existing Lua closures. | The first live build patched one unique descriptor but recorded zero adapter entries across a second complete Arsenal/card opening. Existing closures retained the wrapper address copied during registration. | **FALSE LIVE** |
| A registry-validated native detour reaches existing `RunScript` closures. | The corrected live build recorded 26 entries in one VM/thread, including 24 synchronous four-argument calls, through `mode=native-detour`. | **TRUE LIVE** |
| Current DE globals can be read with the legacy string `getfield(-10002, name)` path. | All 24 synchronous calls had the expected tags but returned `query_table=0`; OpenWF's current `ivkr_push_global` instead uses a BOOL-tagged native-name hash plus `gettable(-10002)`. | **FALSE LIVE** |
| Any method entry with the same name may be patched independently. | Multiple distinct originals are ambiguous and fail the binding gate. | **FALSE** |
| All four-argument `RunScript` calls are card queries. | The wrapper additionally requires the current `_T.AbilityLevelQueryParms` table and non-nil `Ability`. | **FALSE** |
| The observer changes the card. | It does not write query/result tables or call addon hooks. | **FALSE** |
| Re-entry can recurse through the adapter. | Thread-local active state passes nested calls directly to the original. | **FALSE by gate** |
| The current cached-export decorator should run alongside the observer. | It was live-refuted and would contaminate the boundary test. | **FALSE** |
| Offline compilation proves the UI transaction. | Only a live base/modded log pair can prove it. | **FALSE** |

## Offline results

Deterministic injection-core verifier:

```text
RunScript observer accepts only the synchronous ability-card query shape PASS
RunScript observer is transparent while disabled or re-entered PASS
RunScript observer rejects wrong arity asynchronous and non-boolean calls PASS
RunScript observer rejects missing query tables and missing ability identity PASS
RunScript observer distinguishes complete missing-result and ABI-drift outcomes PASS
INJECTION CORE PASS
```

Private x64 build:

```text
PRIVATE BUILD PASS
warnings=0
errors=0
x64=yes
companion_import=no
bytes=4152320
sha256=b3aa9d4a8ae7aba2a472f3ad4a916748009f53561536ace75ab384f00e13ca02
```

This is the corrected repository build artifact and has not yet been deployed.
The earlier descriptor-only observer was deployed with SHA-256
`8613a47fc0ffea50a65a941c5fb59035320dc60fc82b74109b8b4ea2687acf0a`.
It found exactly one `RunScript` descriptor/original but recorded zero adapter
entries during both the first and a complete second Arsenal/card opening. That
is a live negative control for post-registration descriptor mutation, not a
successful card-boundary observation.

The corrected observer uses the registry only to resolve and validate the
unique wrapper address. A native function detour then covers already-created
Lua closures as well as future calls. The original is invoked through the
detour trampoline, so descriptor mutation is no longer the interception
mechanism.

The corrected build also carries bounded diagnostic telemetry: the first 64
`RunScript` entries are recorded regardless of shape, and at most the first 256
four-argument synchronous candidates are retained after that. This makes a
second zero-observation result distinguishable as either no native detour entry,
an unexpected argument layout, or a missing query table, without creating an
unbounded runtime logger.

The first native-detour live run resolved the first two branches: entry and
argument interception are correct. It recorded 26 entries with tags
`9,9,9,1`; 24 were synchronous. All 24 failed only at `_T` discovery. The
current source now implements the same global-key encoding used by
`OpenWF/runtime.pluto`: `wf_hash(name)` stored in a `LUAU_BOOL` TValue followed
by `luau_gettable(state, -10002)`. Nested `_T` fields continue through the
normal field accessor.

## Hashed-global live acceptance result

The corrected hashed-global build was deployed with SHA-256
`b3aa9d4a8ae7aba2a472f3ad4a916748009f53561536ace75ab384f00e13ca02`.
The client was launched and the Octavia ability screen was exercised. The
session begins at line 796 of `OpenWF/CustomScripts/renovice_source.log` and
produced:

```text
RunScript entries                         82
valid synchronous ability-card queries   38
before observations                      38
after observations                       38
complete transactions                    38
base queries (Modded=false)               19
modded queries (Modded=true)              19
distinct ability identities               4
same_vm                                   38/38
original_results=0                        38/38
result_tag=table                          38/38
```

The four distinct ability identities were
`00000217A03017F0`, `00000217A0301930`, `00000217A0301B90`, and
`00000217A0301DB0`. Every complete transaction ran in VM
`00000216B9B40EE0` on owner thread `6412`. This proves that the native detour,
current DE hashed-global lookup, query classification, original-call
transparency, and post-call result lookup are correct in the live game.

| Hypothesis | Evidence | Result |
|---|---|---|
| BOOL-tagged `wf_hash("_T")` plus `gettable(-10002)` reaches the current DE global table. | 38/38 classified queries found both `AbilityLevelQueryParms` and `Ability`. | **TRUE LIVE** |
| `RunScript` is the synchronous ability-card provider boundary. | 38/38 observations produced `AbilityUpgradeLevelInfo` tables after the original call. | **TRUE LIVE** |
| The adapter changes the original result ABI. | All 38 original calls returned zero results and the adapter returned that value unchanged. | **FALSE LIVE** |
| One Octavia card opening queries only Mallet. | Four different ability identities were observed. | **FALSE LIVE** |
| A generic addon may append rows to every classified card query. | It would affect all queried abilities, not only the target module. | **FALSE by live discrimination evidence** |

The next gate is therefore not more card-pipeline discovery. It is exact target
ownership: while the original `RunScript` call is active, bind argument 2's
script-resource identity to the target module body key observed by the loader.
Only an exact `(VM, script resource) -> target key` match may dispatch the
target addon's `afterAbilityCard` hook.

## Live acceptance before row mutation

1. Close the client before any separately authorized deployment.
2. Preserve and hash the current live DLL.
3. Deploy only the observation build and verify byte identity.
4. Launch and open Mallet's card once.
5. Require `RunScript observer PASS` with one original implementation.
6. Require one complete `modded=0` and one complete `modded=1` pair.
7. Require the same `vm`, thread, and ability identity across the pair.
8. Require `same_vm=1`, `original_results=0`, and a table result for both.
9. Confirm the visible card remains stock and Mallet gameplay remains stock.
10. Open two unrelated ability cards and prove their ability identities differ
    without any behavior change.
11. If any gate fails, restore the previous DLL and update the hypothesis
    ledger. Do not append a test row.

This acceptance has now passed. Row mutation remains disabled until the exact
target-key/script-resource ownership binding passes its own live gate.

## Exact target-binding observer prepared

The next observation build installs the `RunScript` native detour as soon as a
target addon chunk is configured, before the target module needs to load. It no
longer waits for an already-active addon generation. During a classified card
transaction it publishes a thread-local boundary containing the exact VM,
owner thread, script-resource argument, and ability identity. If the natural
loader sees a configured target body key within that boundary, it records an
exact `(VM, script resource) -> target key` association. Card observations now
report `target_match` and `target_key`, but still perform no mutation.

Offline hypothesis ledger:

| Hypothesis | Evidence | Result |
|---|---|---|
| Waiting until target addon activation is sufficient to observe its first natural load. | Activation itself occurs only after that load, so installing there is causally late. | **FALSE** |
| A configured target chunk is enough reason to install the bounded observer early. | The observer is transparent for unrelated calls and already passed its live ABI gate. | **TRUE by design and prior live evidence** |
| A loader event outside an active card transaction may establish ownership. | It lacks the calling script resource and could belong to preload or unrelated execution. | **FALSE by gate** |
| Matching only a target key or only an ability identity is sufficient. | The live screen queried four abilities in one VM; ownership requires the exact script resource as well. | **FALSE** |
| Exact key, VM, script resource, and owner-thread gates are deterministic offline. | New verifier cases accept the exact tuple and reject inactive, cross-VM, cross-thread, zero-resource, wrong-key, and wrong-resource cases. | **TRUE OFFLINE** |

Prepared artifact:

```text
RENOVICE_DEPLOYMENTS/RUNSCRIPT_TARGET_BINDING_OBSERVER_2026-08-24/staging/wtsapi32.dll
bytes=4155904
sha256=b8bb6608ce4e6b84ffd110f38edd68207b3d7f72aa121e76bf6e1be5e9ca2add
warnings=0
errors=0
```

The live DLL was not overwritten during preparation. Its observed hash remained
`b3aa9d4a8ae7aba2a472f3ad4a916748009f53561536ace75ab384f00e13ca02`.

## First target-binding live result: rejected

The prepared target-binding observer was deployed and Octavia's four cards were
exercised. It observed 12 complete card transactions, but recorded zero target
bindings; all 12 reported `target_match=0`. The relevant startup order was:

```text
target module identity PASS key=8faf07b504d058f
Inject PASS 08faf07b504d058f.MalletOverguardAndCard.target.addon.lua_B
TARGET ADDON PASS key=8faf07b504d058f
RunScript observer PASS ... mode=native-detour
```

There were no RENOVICE failures, fatals, rollbacks, card changes, or gameplay
mutations. This is a clean negative result.

| Hypothesis | Evidence | Result |
|---|---|---|
| Installing the observer from the first ordinary script-thread drain occurs before the target's natural load. | The target module identity and addon activation preceded observer installation in the same startup session. | **FALSE LIVE** |
| Every target load necessarily occurs inside an already-classified card query with `_T.AbilityLevelQueryParms` populated. | Several synchronous `RunScript` calls precede each classified card pair with `query_table=0`; target loading may occur in that precursor call. | **FALSE / unsupported** |
| The failed binding indicates a delay or race. | The ordering is deterministic and the observer never had an eligible active boundary. | **FALSE** |

Correction prepared in source:

1. `notify_swig_types_ready()` installs the observer immediately after the
   bootstrapper finishes populating its SWIG type registry, before ordinary
   gameplay/UI script loads.
2. Exact four-argument synchronous `RunScript` calls now establish a scoped
   target-binding boundary even when the card query global is not populated.
3. Strict card result observation remains separately gated by the query table
   and ability identity.
4. Nested boundaries preserve and restore their parent association, so no
   outer script resource can leak into a nested target load.

This remains causal ownership discovery: no timer, polling, delay, instance
scan, or global "most recent ability" state was introduced.

## Early-binding live result: causal loader association rejected

The corrected observer was installed before the target module loaded. The live
session then produced one target-module identity, one successful target-addon
activation, and 30 complete ability-card transactions. It produced zero script
bindings and all 30 card transactions reported `target_match=0`. No RENOVICE
failure, fatal, or rollback occurred.

| Hypothesis | Evidence | Result |
|---|---|---|
| Installing the observer before the target load fixes the missing binding. | Installation preceded the natural target load, yet bindings remained zero. | **FALSE LIVE** |
| The target module's natural loader event is nested inside one of the observed synchronous `RunScript` calls. | A target load occurred while the observer was active, but no scoped call ever captured it. | **FALSE LIVE** |
| The remaining failure is a timer or race. | Thirty deterministic complete queries repeated the same result without errors. | **FALSE LIVE** |

The loader/`RunScript` stack-correlation model is therefore retired. The card
pipeline itself remains proven. The replacement ownership model is an explicit
addon contract:

```text
card query Ability resource
    -> each loaded addon's matchesAbility(Ability)
    -> one unambiguous target body key
    -> afterAbilityCard(stock rows, real query)
```

For the Mallet proof, `matchesAbility` compares the queried resource's native
localization tag with `/Lotus/Language/Suits/BardMusicAbilityName`. This is a
stable resource-owned property already used by DE UI code; it is not an
instance scan. Matching runs only at a real ability-card query. Multiple addons
for the same target key are allowed, while different target keys claiming the
same ability fail closed as ambiguous.

The editor-facing form should ultimately store the canonical ability resource
path (`/Lotus/Powersuits/Bard/Abilities/BardMusicAbility`) and generate the
corresponding matcher. The localization-tag predicate is the first live proof
because both its value and native accessor are already evidenced in the
current corpus.

## Exact ability match passed; downstream contracts failed live

The ability-identity build produced the required exact discrimination. On
Mallet's base and modded queries it logged `target_match=1` with target key
`08faf07b504d058f`; other Octavia abilities remained `target_match=0`.
`afterAbilityCard` completed its protected call. Nevertheless, no custom rows
appeared and gameplay granted no Overguard. There was no
`SetSource.installDamageCallback` or `afterDamage` event.

| Hypothesis | Evidence | Result |
|---|---|---|
| `matchesAbility` can associate the separate addon with the base Mallet ability. | Both real Mallet card passes selected exactly one target key; unrelated ability queries did not. | **TRUE LIVE** |
| A successful zero-result callback proves its in-place row mutation became UI output. | The callback PASS logged, but no row appeared and the host neither consumed a result nor read back publication. | **FALSE LIVE** |
| A second addon-local `active` upvalue is a useful lifecycle gate. | Registry commit already controls reachability; the flag creates an unobservable silent no-op path. | **FALSE BY DESIGN** |
| Walking active Lua frames at `SetSource` reliably identifies BardMusic ownership. | No callback-attachment event occurred during real Mallet damage. | **FALSE LIVE** |
| This negative result implicates the decompiler. | The addon loaded, both match callbacks executed, and exact native transactions were observed without bytecode/runtime errors. Failure occurs in host routing/publication after compilation. | **FALSE** |

## Semantic publication and damage-packet successor

The successor build makes the card callback a provider:

```text
stock rows -> afterAbilityCard(rows, query) -> returned table
          -> host writes _T.AbilityUpgradeLevelInfo
          -> exact table-identity readback
          -> RunScript returns to the UI
```

The addon copies the stock array before appending rows, so a failed later
provider cannot partially mutate the stock result. Nil/non-table results,
exceptions, or failed readback fail explicitly. The private `active` flag was
removed; registry membership is the single activation authority.

Gameplay now follows the corpus-proven stock `BoxLoop` sequence:

```text
SetSource(caster)
SetSourceObject(mallet creator ability)
RadialDamage(packet)
```

The exact `RadialDamageData` SWIG type is found through its unique
`SetDamageCallback` binding. `SetSource` creates only a bounded short-lived
packet/caster handoff. `SetSourceObject` consumes it and invokes the addon's
protected `matchesDamageSource(sourceObject)` predicate. A successful,
unambiguous Mallet match installs the applied-damage callback on that packet.
This replaces call-stack inference with an actual data-flow boundary and does
not scan ability instances.

Deployment and rollback hashes, offline gates, and required live events are in
`Boostrapper Source Edited/RENOVICE_DEPLOYMENTS/SEMANTIC_CARD_AND_DAMAGE_BUS_2026-08-24/MANIFEST.md`.
