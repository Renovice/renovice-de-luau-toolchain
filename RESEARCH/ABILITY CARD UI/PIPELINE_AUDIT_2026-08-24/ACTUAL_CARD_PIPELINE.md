# Warframe ability-card Lua pipeline: authoritative audit

Date: 2026-08-24

Status: architecture audit complete; implementation deliberately not started

Implementation update: the first corrected gate now exists as a built but
undeployed observation-only SWIG `RunScript` adapter. It performs no row or
gameplay mutation. See `RUNSCRIPT_OBSERVER_IMPLEMENTATION.md`.

## Executive conclusion

The failed target-addon prototypes hooked the wrong object.

An ability card is not produced when the bootstrapper loads or undumps an
ability module, and it is not produced by locating a function in RENOVICE's
cached copy of that module's environment. The Arsenal UI owns a synchronous
query transaction. It asks the selected avatar to run the ability script's
named `GetAbilityUpgradeLevelInfo` entry, then immediately reads the result
from `_T.AbilityUpgradeLevelInfo` in the same UI Luau state.

The central card builder performs that transaction twice:

1. once with `Modded = false`, producing the base rows;
2. once with `Modded = not element.BaseOnly`, producing the current/modded
   rows.

It then compares the two arrays by numeric index and renders the result using
Warframe's existing native row clips. A correct addon card hook therefore has
to join this real UI transaction after the original `RunScript` call returns
and before the caller reads `_T.AbilityUpgradeLevelInfo`. It must not depend on
module-load timing, a cached export, an arbitrary `_T`, a timer, or scanning
spawned Mallet instances.

Gameplay behavior and card presentation are two projections of one addon
definition, but they are two different runtime hook boundaries. The card hook
belongs to the UI `RunScript` transaction. Mallet's damage hook belongs to a
real damage-packet boundary such as `RadialDamageData:SetSourceObject`, where
the source object identifies the Mallet damage definition/entity and the
packet already carries the caster.

## Scope and evidence boundary

This document answers four questions:

1. Which Lua files construct an ability card?
2. What is the exact request/result contract between the UI and an ability
   script?
3. Why did the separate-addon prototypes produce neither card rows nor
   Overguard?
4. Where can a real separate-addon framework attach without replacing the
   stock BardMusic bytecode?

The following are proved by current game bytecode, corpus data, live logs, or a
combination of them. The proposed native adapters are not yet implemented and
are not labelled live-proven.

## End-to-end card flow

```text
/Lotus/Interface/ThemedAbilityProgression.swf
    |
    | loads Lotus.Interface.Components.AbilityList
    | AbilityList.Create(...)
    | AbilityList:Populate(...)
    v
AbilityList.lua
    |
    | builds an ability element:
    | Resource, AbilityIndex, Level, Name, LocalizedDesc,
    | ModdedStats, BaseOnly, Icon, Suit, ForceOverride...
    |
    | on focus:
    | _T.InfoPopup_Data = selected element
    v
ItemInfoPopup.lua
    |
    | resolves Resource:GetScript()
    | produces the upper description separately
    | calls StatCompare.GetStatsTextForAbility(element)
    v
Lotus.Interface.Components.StatCompare
    |
    | query 1: _T.AbilityLevelQueryParms.Modded = false
    | avatar:RunScript(script, "GetAbilityUpgradeLevelInfo", true)
    | baseRows = _T.AbilityUpgradeLevelInfo
    |
    | query 2: _T.AbilityLevelQueryParms.Modded = !BaseOnly
    | avatar:RunScript(script, "GetAbilityUpgradeLevelInfo", true)
    | moddedRows = _T.AbilityUpgradeLevelInfo
    |
    | compares baseRows[i] with moddedRows[i]
    | emits Labels, Values, BaseValues, StatChanges
    v
ItemInfoPopup native row renderer
    |
    | creates ordinary row clips
    | formats label, value, unit, icon and comparison colour/arrow
    v
visible ability card
```

This pipeline has no addon-discovery step. A stock ability script knows
nothing about a RENOVICE addon unless RENOVICE composes the addon at a real
execution or result boundary.

## Stage 1: `ThemedAbilityProgression`

`ThemedAbilityProgression` is the outer Arsenal ability screen. The current
bytecode:

- requires `Lotus.Interface.Components.AbilityList`;
- constructs `AbilityList.Create(mMovie, "Abilities.AbilityList")`;
- calls `Populate`;
- uses `AbilityList.GetAugmentsForAbility` for the augment-preview path;
- clears `_T.InfoPopup_Data`, `_T.AbilityLevelQueryParms`,
  `_T.AbilityUpgradeLevelInfo`, and `_T.ModPreviewAvatar` during shutdown.

This proves that the temporary `_T` objects are UI transaction state, not a
permanent module-owned addon registry.

## Stage 2: `AbilityList`

For an ability, `AbilityList.GetElementForAbility` builds the selected-entry
object. Relevant fields include:

- `IsAbility` and `CustomEntry`;
- `Resource`;
- `AbilityIndex` and `Level`;
- `Name` and `LocalizedDesc`;
- `Suit`;
- `ModdedStats` and `BaseOnly`;
- `ForceOverrideDesc`;
- `Icon`, `IconColor`, and theme/locking fields.

The name and default description originate from the ability resource's
localization tags. When the row is focused, `AbilityList` calls the popup
positioning method and assigns the element to `_T.InfoPopup_Data`.

`AbilityList.GetAugmentsForAbility` is a separate preview/listing operation. It
does not globally merge arbitrary scripts into every future card query.

## Stage 3: `ItemInfoPopup`

`ItemInfoPopup` consumes `_T.InfoPopup_Data`. For an ability resource it
resolves, among other things:

- `Resource:GetScript()`;
- the localized name and description tag;
- ability level/index and energy fields;
- whether base or modded presentation is requested.

### Upper paragraph

The descriptive paragraph and the bottom statistics are separate systems.
For a dynamic ability description, the popup asks an avatar to run:

```lua
avatar:RunScript(script, Symbol("GetAbilityDescriptionInfo"), true)
```

It then reads `_T.AbilityDescriptionInfo.Params`, clears the temporary result,
and localizes the paragraph. This is why changing a description can work while
custom statistic rows do not: success in the description path says nothing
about the `GetAbilityUpgradeLevelInfo` transaction.

### Bottom rows

For numeric/stat rows, `ItemInfoPopup` calls:

```lua
StatCompare.GetStatsTextForAbility(element)
```

That central function returns four parallel arrays used by the ordinary
Warframe renderer:

- `Labels`;
- `Values`;
- `BaseValues`;
- `StatChanges`.

The popup then creates the native row clips. RENOVICE does not need a custom
SWF or a custom row widget. It only needs to append valid producer rows before
`StatCompare` transforms them.

## Stage 4: exact `StatCompare` transaction

### Context selection

The central builder selects an avatar from the current UI context. The normal
local avatar may be overridden by `_T.MenuSuitAvatar` or
`_T.ModPreviewAvatar`, with additional paths for special suits, mechs, and
railjack contexts. It validates that it has an ability element, movie, avatar,
inventory control, and active powersuit.

When `AbilityIndex` is present it also calls the current hashed inventory/suit
method used to select the appropriate ability context. Its friendly semantic
name is not yet proved and must not be invented.

### First call: base rows

The effective request is:

```lua
_T.AbilityLevelQueryParms = {
    ForceOverride = element.ForceOverride,
    Level = (element.Level or 0) + 1,
    Ability = element.Resource,
    Avatar = avatar,
    Modded = false,
}

avatar:RunScript(
    element.Script,
    Symbol("GetAbilityUpgradeLevelInfo"),
    true
)

local baseRows = _T.AbilityUpgradeLevelInfo
```

The third argument `true` and the immediate result read establish a
synchronous request/result contract for this caller. A delayed timer callback
cannot satisfy it.

The builder also reads special non-array members from this first result:

- `EnergyCost`;
- `EnergyCostMax`;
- `BaseEnergyCost`;
- `EnergyLabel`;
- `EnergyFormatting`;
- `EnergyIconOverride`.

It inserts the Drain/Energy presentation centrally and can add a cooldown row
from native ability data.

### Second call: current/modded rows

The builder replaces the query with:

```lua
_T.AbilityLevelQueryParms = {
    ForceOverride = element.ForceOverride,
    Level = (element.Level or 0) + 1,
    Ability = element.Resource,
    Avatar = avatar,
    Modded = not element.BaseOnly,
}

avatar:RunScript(
    element.Script,
    Symbol("GetAbilityUpgradeLevelInfo"),
    true
)

local moddedRows = _T.AbilityUpgradeLevelInfo
```

It then compares `moddedRows[i]` against `baseRows[i]` by array index.
Consequently, an addon row provider must return the same stable row identities,
count, order, units, and meaning in both calls. Only the values are expected to
change. Conditionally inserting a row in only one pass shifts every later
comparison and is invalid.

At the end, the builder clears `_T.AbilityLevelQueryParms` and
`_T.AbilityUpgradeLevelInfo`.

## Producer row contract

The current 286-module ability corpus contains 284 modules that expose
`GetAbilityUpgradeLevelInfo` and use `_T.AbilityLevelQueryParms`. The observed
row fields and site counts are:

| Field | Observed sites | Meaning |
|---|---:|---|
| `Label` | 1,887 | Localized path or literal left-hand label. |
| `Value` | 3,136 | Main numeric/string value. |
| `ValueUnit` | 1,115 | Native localized unit template. |
| `ValueIcon` | 373 | Native inline icon/token. |
| `Modded` | 279 | Result-array comparison mode. |
| `Title` | 258 | Section/title row rather than an ordinary value row. |
| `SmallerIsBetter` | 71 | Reverses improvement interpretation. |
| `ValueMax` | 64 | Upper end of a displayed value range. |

Special result members observed across the producers:

| Member | Producers/sites observed |
|---|---:|
| `EnergyCost` | 175 |
| `BaseEnergyCost` | 11 |
| `EnergyIconOverride` | 6 |
| `EnergyCostMax` | 1 |
| `EnergyFormatting` | 1 |

`StatCompare` also knows how to read `EnergyLabel`, but the current 286-module
ability corpus contains zero producer assignments to that member. It is a
consumer-supported field, not a corpus-proven producer convention.

No `TextOnly` producer row was observed in this ability corpus. The generic
comparison component knows other shapes for other item-stat paths, but an
editor must not advertise them as ability-row fields without an ability-side
example or a live proof.

### Renderer behavior

For ordinary rows, the current builder:

- localizes the label and applies the UI's title casing;
- formats numeric values to the game's normal precision;
- maps the float infinity sentinel to the localized infinity text;
- formats `ValueMax` as a value range;
- localizes `ValueUnit` with the formatted value as `COUNT`;
- incorporates `ValueIcon` in the rendered value;
- compares current and base values;
- records positive, negative, or unchanged state in `StatChanges`;
- applies `SmallerIsBetter` when deciding whether a change is beneficial;
- renders `Title = true` as a section title rather than a numeric row.

Therefore custom values should remain numeric and use the stock unit fields.
Pre-formatting `"1%"` into a string discards useful native comparison and
localization behavior.

## BardMusic/Mallet as the concrete stock example

The stock current BardMusic producer reads:

- `_T.AbilityLevelQueryParms.Level`;
- `.Modded`;
- `.Avatar`;
- `.Ability`.

It establishes the level-dependent base values, then, for the modded pass:

- modifies Damage Multiplier through `Engine.UpgradedValue` plus
  `InventoryControl:ModifyValue(..., 10, suit:GetType(), suit)`;
- modifies Radius through the stock upgrade selector used by BardMusic;
- modifies Duration through the stock duration selector.

It publishes ordinary rows for Damage Multiplier, Radius, and Duration, sets
the result array's `Modded` member from the query, and assigns the array to
`_T.AbilityUpgradeLevelInfo`.

### How DE adds augment rows

Stock BardMusic also asks the active suit for the installed augment level and
type. When its augment applies, the **base BardMusic producer itself** appends:

- a `Title = true` row containing the augment name;
- an additional native Radius-percent row.

Across the corpus, 190 of the 284 producers inspect augment state and 191
contain title rows. This is the reusable pattern DE chose: the selected
ability's producer participates in the same base/modded query and contributes
extra rows. It does not establish a generic engine feature where an unrelated
Lua file is automatically discovered and merged into a card.

## Why every separate-addon prototype failed

### 1. A loaded cached module is not a running card producer

RENOVICE successfully identified the target body key and loaded the addon into
an exact borrowed environment, but the live log reported:

```text
target module identity PASS
Inject PASS ... exact_env=1
TARGET ADDON PASS
native hook adapter PASS
card export attach FAIL reason=export-not-function
```

No card dispatch or damage dispatch followed. Loader success proved that
bytecode had been undumped and cached. It did not prove the root had executed,
that a named script instance was running, or that the environment contained
the function used by the UI transaction.

### 2. VM `SETGLOBAL` is not the public C API setter

BardMusic bytecode publishes functions with VM `SETGLOBAL` instructions. The
interpreter executes those opcodes internally. Detouring the public C API
`lua_setglobal`-style helper cannot observe them. Improving frame arithmetic or
loader timing cannot rescue a hook attached to a function the VM never calls.

### 3. `_T` is context-owned, not a safe cross-VM message bus

The earlier `_T.RENOVICE_AUGMENT_ABILITY_CARD` experiment installed a handler
in a different or prematurely captured context. F9 and module refresh could
pass while the actual UI query saw none of it. RENOVICE's multi-VM live work
already proves that HUD/UI/gameplay states can have different global states.
Cross-state execution is prohibited; a handler in one state cannot be treated
as though it exists in all states.

### 4. The card result is consumed immediately

`StatCompare` reads `_T.AbilityUpgradeLevelInfo` immediately after the
synchronous `RunScript` returns. Retrying later, polling instances, or waiting
for a module export cannot change the result already consumed by that call.

### 5. Gameplay ownership was inferred from an active cached Lua frame

The attempted `SetSource` adapter tried to decide whether the native call
belonged to BardMusic by finding a cached target closure in the active Lua
call-info chain. BardMusic's long-lived `BoxLoop` yields and resumes, while the
cached module environment is not the engine's durable identity for the damage
packet. The adapter therefore loaded but never attached Mallet's callback.

### Live verdict

The final tested target-addon build produced neither Overguard nor custom card
rows. This is a live **FALSE** for the cached-environment/root-decorator
architecture, not a timing issue and not a claim that addons are impossible.

## What a real addon hook means

A separate addon can leave the stock `.lua_B` file byte-for-byte untouched,
but it cannot affect execution without changing dispatch somewhere. A modding
hook framework normally owns one of these boundaries:

1. a function-call dispatcher;
2. an event dispatcher;
3. a result/return adapter;
4. a generated wrapper or bytecode weave;
5. a native engine callback.

“Separate” means the authoring source and stock asset remain separate and the
framework composes them deterministically. It does not mean the addon runs by
magic without entering a stock execution path.

## Proposed card architecture

### Primary design: same-state `RunScript` post-call adapter

The evidence-backed boundary is the native/SWIG `RunScript` method called by
`StatCompare`. The corpus resolves its hash as `0xf4950b15` and shows the
four-argument, zero-result call shape at seven sites in three modules. The
friendly signature beyond those observed facts still requires native binding
verification before detouring it.

The adapter would run in this order:

```text
UI Luau state enters avatar:RunScript(...)
    |
    | pre-call: inspect current _T.AbilityLevelQueryParms
    |           verify function == GetAbilityUpgradeLevelInfo
    |           resolve target ability from query.Ability
    v
call original native RunScript
    |
    | stock ability producer publishes _T.AbilityUpgradeLevelInfo
    v
post-call, still in the same UI state
    |
    | read the just-produced row array
    | append registered addon rows for query.Ability
    | validate row schema and stable base/modded row identities
    v
return to StatCompare
    |
    | StatCompare immediately reads the augmented result
    v
native stock rows appear on the card
```

This design has the necessary properties:

- same Luau state as the UI-owned `_T` transaction;
- exact synchronous ordering;
- target identity from the ability resource/definition, not a transient
  spawned instance;
- no modification to stock BardMusic bytecode;
- no cached-export assumption;
- no per-frame work;
- no timer, retry, or instance scan;
- one call for base and one call for modded, exactly matching DE's pipeline.

### Card-provider contract

The editor/addon registry should store stable definitions, not arbitrary arrays
whose shapes can drift between the two passes:

```lua
target = "/Lotus/Powersuits/Bard/Abilities/BardMusicAbility"

cardRows = {
    {
        id = "overguard_cap",
        order = 100,
        label = "Overguard Cap",
        unit = nil,
        base = function(query) return 15000 end,
        modded = function(query) return 15000 end,
    },
    {
        id = "damage_to_overguard",
        order = 110,
        label = "Overguard From Damage",
        unit = "/Lotus/Language/Game/UNIT_PERCENT",
        base = function(query) return 1 end,
        modded = function(query)
            -- same Strength formula used by gameplay, clamped to 5
        end,
    },
}
```

At commit time the framework validates:

- unique `id` per target ability;
- deterministic ordering;
- same row IDs and schema for base and modded passes;
- finite numeric values unless explicitly allowed;
- supported native row fields only;
- valid existing unit/localization keys or a clean literal label;
- no mutation of `_T.AbilityLevelQueryParms`;
- no cross-state function reference.

The adapter then materializes normal row tables inside the current UI state and
appends them to the stock result. Warframe continues to own formatting and
layout.

### F9 behavior

F9 needs only to rebuild and atomically replace the addon registry generation.
There is no watcher and no idle polling. The next card query calls the current
generation. If the existing popup has already consumed its rows, the user must
move focus away and back so the UI asks again; the framework must not mutate a
completed visual clip behind the UI's back.

Removal is symmetrical: the next transaction has no provider, so only stock
rows remain. A failed provider is contained, logged, and the stock result is
preserved.

## Proposed gameplay architecture for the Mallet proof

The gameplay hook is separate from the card hook.

Stock BardMusic's `BoxLoop` constructs a radial damage packet and calls, in
order:

```text
RadialDamageData:SetSource(caster)
RadialDamageData:SetOrigin(...)
RadialDamageData:SetBaseAmount(...)
RadialDamageData:SetDamagePct(...)
RadialDamageData:SetSourceObject(malletObject)
gRegion:RadialDamage(damageData)
```

`SetSourceObject` is a stronger semantic boundary than “some `SetSource` call
made while a cached BardMusic closure appears in a frame.” Its corpus hash is
`0x835d7fe5`; all 357 observed sites are void calls across 192 modules. For
Mallet, the source object gives the adapter a real object/type/resource identity
that can be checked against the registered addon target, while the packet's
source already identifies the caster.

At this boundary the Mallet adapter can install the already-proven native
damage callback on that packet. The callback receives actual applied damage,
then grants the caster the configured fraction as Overguard up to the cap.

This is proposed, not yet proved. Before deployment it must establish:

- the exact native binding and receiver type for `SetSourceObject`;
- the reliable type/resource identity exposed by the source object;
- that the callback survives through `RadialDamage` and reports actual applied
  per-target damage;
- that the adapter rejects unrelated radial-damage packets;
- that one packet is decorated once;
- that stock behavior is unchanged when no addon is registered.

Not every future addon should abuse `SetSourceObject`. The framework needs a
small catalogue of evidence-backed events. When no stable native event exists,
a generated minimal IR/bytecode weave around a named function is preferable to
copying and maintaining a whole decompiled module.

## General editor architecture

```text
RENOVICE addon project
    |
    | one stable target ability/resource ID
    | one source-of-truth stat/formula model
    | behavior declarations or explicit Lua
    | card-row declarations
    | localization/description declarations
    v
deterministic builder
    |
    +--> gameplay projection
    |      native event adapter OR minimal generated weave
    |
    +--> card projection
    |      same-state RunScript result adapter
    |
    +--> description/localization projection
    |
    +--> compiled addon generation + manifest + rollback
    v
F9 transaction
    |
    | validate complete generation
    | atomically commit or preserve previous generation
    v
next real gameplay/card query uses the new generation
```

Full replacement remains valid when the original control flow itself must be
changed. Addons are preferred when an evidence-backed event/result boundary can
express the change.

## Does the decompiler need upgrading for this?

| Hypothesis | Evidence | Result |
|---|---|---|
| The decompiler cannot express native ability rows. | Direct BardMusic replacement rows appeared and hot-reloaded live. | **FALSE** |
| A custom UI renderer is required. | Stock row tables already create native rows. | **FALSE** |
| The central UI modules are perfectly renderable today. | Semantic rendering of current `StatCompare` and `ItemInfoPopup` stops at `RENDER_NAME_METADATA_MIXED_NAME`; direct decompilation was required for the audit. | **FALSE** |
| That renderer defect blocks the correct addon hook. | The proposed adapter observes the existing native call/result and does not rebuild either central UI module. | **FALSE**, subject to native-hook proof |
| The current failure is fundamentally a Lua normalization failure. | Stock replacement produced working card rows and gameplay; addon logs fail before dispatch. | **FALSE** |

The renderer defect should remain in decompiler R&D because readable central UI
modules are valuable, but it is not a reason to keep guessing at addon
attachment.

## Hypothesis ledger

| Hypothesis | Evidence | Verdict |
|---|---|---|
| An ability module is queried once per card. | `StatCompare` builds and runs base and modded queries separately. | **FALSE** |
| Base and modded providers may emit different row layouts. | Results are paired by numeric index. | **FALSE** |
| The upper description and bottom rows use the same output. | They use `GetAbilityDescriptionInfo` and `GetAbilityUpgradeLevelInfo` respectively. | **FALSE** |
| A loaded cached environment is the card execution context. | Live `export-not-function`, no dispatch, and the UI's own `RunScript` transaction. | **FALSE** |
| A public C API global-set hook observes VM `SETGLOBAL`. | VM opcode is internal and was never observed by the detour. | **FALSE** |
| Timers/retries can repair the addon card path. | The result is read synchronously after `RunScript`. | **FALSE** |
| Editing/scanning every spawned ability instance is required. | Card identity is the selected ability resource and query, not a spawned Mallet. | **FALSE** |
| Stock augment cards prove a generic external-addon bus exists. | The base producer explicitly inspects augment state and appends its own rows. | **FALSE** |
| Separate addons are impossible. | A framework can compose at a real dispatch/result/event boundary while stock assets remain untouched. | **FALSE** |
| A same-state post-`RunScript` adapter matches the card transaction. | It encloses the exact producer call before the immediate result read. | **TRUE architecturally; unimplemented** |
| `SetSourceObject` is a better Mallet behavior target than cached-frame ownership. | It carries the damage packet's source object immediately before `RadialDamage`. | **TRUE as a candidate; native proof pending** |

## Implementation gates before another live DLL

No new addon DLL should be deployed until these gates pass:

1. Resolve and document the exact current `RunScript` native binding, ABI,
   receiver type, arguments, original return behavior, and all aliases.
2. Create a read-only observation detour first. Prove one base and one modded
   event per card rebuild, in the same Luau global state as the corresponding
   `_T` query/result.
3. Prove target identity from `_T.AbilityLevelQueryParms.Ability` for Mallet and
   at least two unrelated abilities; unrelated queries must be rejected.
4. Add a result-array validator and append one harmless literal test row after
   the original call. The stock four Mallet rows must remain byte/meaning
   equivalent.
5. Prove both base and modded passes contain the same addon row IDs and order.
6. Prove Show Base Stats and a Strength-modified build display the source-of-
   truth formula correctly.
7. Prove provider failure preserves the untouched stock result and logs an
   explicit failure.
8. Resolve and observe the exact `SetSourceObject`/damage boundary without
   changing behavior.
9. Prove the Mallet source-object predicate rejects unrelated damage packets.
10. Attach the actual-damage callback once, then prove correct Overguard,
    stock reflection, multiple enemies, zero damage, cap behavior, and cleanup.
11. Prove F9 add/change/remove in gameplay and UI without restart; the previous
    generation must survive any compile/validation failure.
12. Only after those passes promote the target-addon mechanism from
    experimental to editor-supported.

## Known unknowns

- The exact friendly name and semantics of the hashed pre-query ability-context
  method are not proved.
- The precise current C++ ABI behind SWIG `RunScript` must be recovered before
  any detour is safe.
- Whether all card callers use the identical `RunScript` binding must be
  confirmed at runtime; the corpus sees seven calls across three modules.
- `SetSourceObject` is the best current Mallet candidate, not yet a certified
  universal gameplay event.
- The EE log's `BardMusic.lua failed to start` lines require a stock/no-addon
  differential before attributing them to RENOVICE; older evidence indicates
  untouched preview scripts can emit similar messages.

These unknowns are deliberately explicit. None justifies returning to
cached-environment decoration or instance scanning.

## Evidence files

Generated current-game sources used in this audit are under `GENERATED/`:

- `ThemedAbilityProgression.semantic.luau`;
- `AbilityList.semantic.luau`;
- `ItemInfoPopup.decompile.luau`;
- `StatCompare.decompile.luau`.

The current stock BardMusic source is in the corpus staging directory:

`RESEARCH/DE LUAU TRANSLATOR/NATIVE API AND LIVE CANDIDATE CENSUS/TOOLS/stage/src/Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B.luau`

Commands, hashes, corpus counts, live-log facts, and the old disabled script-
instance hook are recorded in `EVIDENCE/REPRODUCIBILITY.md`.
