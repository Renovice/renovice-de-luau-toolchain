# Ability-card pipeline audit: reproducibility and provenance

Date: 2026-08-24

## Installed build

| Artifact | SHA-256 |
|---|---|
| `Warframe/Warframe.x64.exe` | `87D3C0F946D6FFF8B95567B2FCE396D407721BC86CAFABDAFC44EE8F60FB92B0` |
| live `Warframe/wtsapi32.dll` observed during the failed addon run | `FFDD5ACF5959B413B2CBC976DDC7BE6569A64D46CA4E79C012950D7B17BC2791` |
| `TOOLS/find_rel32_xrefs.exe` | `0E79A240FFA828AE2EAE8D6709D32A3BCE5C3DD1AEE539EED1FD9D09627D3E35` |

Generated-source hashes:

| File | SHA-256 |
|---|---|
| `GENERATED/StatCompare.decompile.luau` | `C17E9B2903E962BBDC1A16E2ECCD809E0F0667860557C38AE858A5E19709BDD7` |
| `GENERATED/AbilityList.semantic.luau` | `81ED2F69B31A50A200B7040F830D125253C1E3A9F78AB2580FF0B49D974831B6` |
| `GENERATED/ItemInfoPopup.decompile.luau` | `5D1DAB921A3A52DD0EFAE88128DB44488A37287EE6DAE1ADCA7457C939BA3C15` |
| `GENERATED/ThemedAbilityProgression.semantic.luau` | `89E3573D3A4B6F242EE2B09CEE4961DE6D195696B680CE44A9B3CEA6145CC5E1` |

Semantic rendering of current `ItemInfoPopup` and `StatCompare` stopped with
`RENDER_NAME_METADATA_MIXED_NAME`. Direct current decompilations were retained
instead of hiding that warning or claiming a semantic-render success.

## Key generated-source locations

The exact line numbers below refer to the generated files in this audit:

- `ThemedAbilityProgression.semantic.luau:150` requires `AbilityList`;
- `ThemedAbilityProgression.semantic.luau:1372` calls `Populate`;
- `ThemedAbilityProgression.semantic.luau:2859-2863` clears the popup/query/result globals;
- `AbilityList.semantic.luau:213` creates the ability element shape;
- `AbilityList.semantic.luau:1373-1403` positions the popup and publishes `_T.InfoPopup_Data`;
- `ItemInfoPopup.decompile.luau:969-1033` resolves the description/script, runs `GetAbilityDescriptionInfo`, reads its params, and clears the temporary result;
- `ItemInfoPopup.decompile.luau:10722` calls `GetStatsTextForAbility`;
- `StatCompare.decompile.luau:9290-9307` creates and runs the first ability-level query;
- `StatCompare.decompile.luau:9317-9559` consumes special energy fields;
- `StatCompare.decompile.luau:9635-9639` creates and runs the second query;
- `StatCompare.decompile.luau:9694-10000` compares and formats row fields;
- `StatCompare.decompile.luau:10024-10027` clears query/result state.

The decompiler output contains a duplicated root-form rendering of the same
`StatCompare` prototype around lines 18793-19530. The audit uses the first
proto body above and treats the second as renderer output duplication, not a
second runtime transaction.

## Corpus evidence

Source corpus:

`RESEARCH/DE LUAU TRANSLATOR/NATIVE API AND LIVE CANDIDATE CENSUS/TOOLS/stage/src`

Recorded counts:

- staged ability modules: 286;
- modules with `GetAbilityUpgradeLevelInfo`: 284;
- modules using `AbilityLevelQueryParms`: 284;
- augment-aware producers: 190;
- producers with title rows: 191.

Observed producer fields:

```text
Label             1887
Value             3136
ValueUnit         1115
ValueIcon          373
Modded              279
Title               258
SmallerIsBetter      71
ValueMax              64
EnergyCost           175
BaseEnergyCost        11
EnergyIconOverride     6
EnergyCostMax           1
EnergyFormatting        1
```

These are exact field-assignment counts (`Field\s*=`), not unrestricted word
counts. For example, unrestricted `Modded` references include query reads and
would misleadingly report 1,003 rather than the 279 producer assignments.
`EnergyLabel` has zero producer assignments even though `StatCompare` contains
a consumer path for it.

Native-call census facts:

```text
RunScript       hash=0xf4950b15 modules=3   sites=7   args=4  results=0
SetSourceObject hash=0x835d7fe5 modules=192 sites=357 args=-1|2 results=0
```

The corpus records observed Luau call shapes. It does not by itself certify a
C++ detour ABI or receiver type.

## BardMusic locations

In the staged stock BardMusic source:

- lines 145-153 contain the stock Damage/Radius/Duration modification paths;
- lines 184-234 inspect active augment state and create title/radius rows;
- lines 247-332 read the query, create the standard rows, and set `Modded`;
- line 334 publishes `_T.AbilityUpgradeLevelInfo`;
- line 337 publishes `GetAbilityUpgradeLevelInfo`.

The Mallet damage path's `SetSourceObject` call is recorded by the census at
prototype 16, instruction 565.

## Live negative evidence

Persistent log:

`Warframe/OpenWF/CustomScripts/renovice_source.log`

The relevant sequence contains:

```text
RENOVICE target module identity PASS key=8faf07b504d058f
RENOVICE Inject PASS ... exact_env=1
RENOVICE TARGET ADDON PASS key=8faf07b504d058f addons=1
RENOVICE native hook adapter PASS ...
RENOVICE card export attach FAIL reason=export-not-function
```

There is no corresponding card dispatch, `afterAbilityCard`, Mallet callback
installation, `afterDamage`, or Overguard dispatch. The user's live result was
also negative for both behavior and card rows.

`EE.log` confirms the real UI was loaded and the BardMusic asset was spot-
loaded. It also contains three `BardMusic.lua failed to start` messages while
opening the card. Those messages are recorded but not assigned to RENOVICE
without a stock differential.

## Existing native script-instance evidence

The source bootstrapper retains a disabled `ScriptMgr_startInstanceInternal`
hook in `main.cpp:2213-2258`, with its install block at `main.cpp:4303-4323`.
It identifies a script instance through:

- `ScriptInstance::script_type` at `+0x08`;
- `ScriptInstance::func_name_handle` at `+0x20`;
- resolved script path, name, and named function.

The current game executable contains exactly one match for the old two-argument
`startInstanceInternal` signature:

```text
48 89 5C 24 20 55 56 57 48 83 EC 30 48 8B E9 48 8B FA 48 8D 0D
```

Observed file offset: `0x95A240`.

Using the PE `.text` mapping (raw `0x400`, RVA `0x1000`) gives virtual address
`0x14095AE40`. Disassembly remains consistent with the historical two-argument,
boolean-return routine shape.

This makes the old hook a useful observation candidate for named script starts.
It does not prove that it surrounds the UI's complete synchronous result
transaction, and it does not solve yielded gameplay callbacks by itself. The
source marks the hook disabled and “problematic for 40.0.0”; it must not be
blindly re-enabled.

## Xref helper

`TOOLS/find_rel32_xrefs.cpp` scans PE sections for relative CALL references to a
target virtual address. It was built with:

```text
C:\msys64\ucrt64\bin\g++.exe -std=c++20 -O2 -Wall -Wextra -Werror
```

The initial compile exposed a C++ vexing-parse error; the vector construction
was corrected to brace initialization and the final build passed with warnings
treated as errors. The current target routine has 479 relative-call xrefs, so
the count is not sufficient to identify the ability-card caller without
additional semantic tracing.

## Reproduction commands

From PowerShell:

```powershell
$audit = 'C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE\DeNativeDecompiler (use this instead of native)\RESEARCH\ABILITY CARD UI\PIPELINE_AUDIT_2026-08-24'
$census = 'C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE\RESEARCH\DE LUAU TRANSLATOR\NATIVE API AND LIVE CANDIDATE CENSUS'

rg -n 'AbilityLevelQueryParms|AbilityUpgradeLevelInfo|GetAbilityUpgradeLevelInfo|RunScript' "$audit\GENERATED\StatCompare.decompile.luau"
rg -n 'GetAbilityDescriptionInfo|GetStatsTextForAbility|RunScript' "$audit\GENERATED\ItemInfoPopup.decompile.luau"
rg -n 'GetAbilityUpgradeLevelInfo|AbilityLevelQueryParms|ModifyValue|AbilityUpgradeLevelInfo|Title' "$census\TOOLS\stage\src\Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B.luau"
rg -n 'RunScript|SetSourceObject' "$census\native_methods.tsv"
Get-FileHash -Algorithm SHA256 'C:\Users\Bartek\OneDrive\Dokumenter\Warframe\Warframe.x64.exe'
```

All paths point to preserved artifacts. No game asset, live DLL, or server file
was changed during this audit.
