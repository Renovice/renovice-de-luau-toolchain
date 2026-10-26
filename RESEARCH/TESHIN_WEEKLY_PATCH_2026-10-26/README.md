# Teshin weekly-rotation patch — 2026-10-26

## What this is

Teshin's Hard Mode Honors vendor shows 9 items flagged `RotatedWeekly` in its native data
(weapon riven mods, Forma, Umbra Forma, Kuva, a fusion bundle, the veiled riven). The server
(`OpenWF Server 23.09.2026/SpaceNinjaServer`, `fullyStockedVendors`) already sends every one of
them with a far-future, non-expiring date — proven by querying the live server's
`getVendorInfo.php` directly and diffing the response.

The client script `Lotus_Scripts_Events_EventVendor.lua_B`, proto 20 (as numbered by `ir-u44`
/ `cfg-identity --u44`; the raw on-disk file uses a different opcode numbering, see below),
decides independently which ONE of the 9 weekly items is "this week's pick" via a round-robin:

```
R22 = week_counter % eligible_weekly_count
if R22 == R21 then  -- R21 = this item's position among the weekly pool
    unlocked = true
else
    unlocked = false  -- item is skipped (continue), not merely shown "locked"
```

That JUMPIFEQ (opcode 0x37 in canonical/U43 numbering) is the only thing standing in the way;
the server side was never the problem.

## Why this isn't a decompile+recompile replacement

`cfg-identity --u44` on an unmodified decompile→recompile round-trip of this module shows
`cfg_equal=41/42` with a real dataflow mismatch in a different, unrelated prototype (a known
`FORGPREP -> GETFIELD` decompiler defect near a `reward` field, unrelated to Teshin). Shipping a
full recompiled replacement would have silently carried that unrelated bug into every other system
this shared script touches (Railjack crew hiring, Road to Tau / Shadowgrapher / Jade Shadows /
Duviri Murmur event rewards). So this is a **raw single-byte patch** of the original stock file,
not a decompile/recompile.

## The numbering gotcha

`ir-u44` / `cfg-identity --u44` / `decompile-mod-u44` all operate on bytecode after
`de::change_build_profile(bytes, false)` (raw-U44 -> canonical/U43 opcode numbers). The existing
`de-patchop` CLI command reads the raw on-disk file directly with no such conversion, so a proto
index and opcode byte read off the canonical form (e.g. "proto 20, opcode 0x37") do not describe
the same bytes in the raw file. The project's own `profile-to-u44`/`profile-from-u44` CLI commands
do the right conversion, but require a complete native-name map for the module, and this module's
calls weren't fully covered by `profiles/u44/name-map.tsv` (fails closed: "unresolved native name").

`patch_teshin_weekly.cpp` sidesteps that by calling `de::change_build_profile` with `names=nullptr`
(the same no-map, opcode-only call `cfg_identity_cmd.h` already uses internally) — valid because
opcode renumbering and native-name translation are independent passes in that function, and this
patch never needs to touch a name.

## Verification

- Byte diff of the patched file against stock: **exactly 1 byte differs**, at the intended operand
  (`A: 22 -> 21`), out of 52,781 total.
- `decompile-mod-u44` on the patched file: 0 new errors; the line now reads `if R21 == R21 then`
  (always true), confirming the intended semantic change and nothing else.
- `cfg-identity --u44` stock vs. patched: `cfg_equal=42/42`, 0 classes — confirms the control-flow
  graph is byte-identical; only the one comparison's operand changed.

## Files here

- `patch_teshin_weekly.cpp` — the standalone tool (build: `g++ -O2 -std=c++17 -static -o patch_teshin_weekly.exe patch_teshin_weekly.cpp` from this folder, paths adjusted, or from `work/agents/` as originally run).
- `e7836a15a3d9cffe (Teshin all weekly items).lua_B` — the patched output, installed at
  `OpenWF/LuaScripts/Replacements/` in the Documents game copy. Filename is the FNV-1a-64 content
  key of the original stock module (loader convention, `HOW_TO_ADD_SCRIPTS.md`).

## Status

Installed and live-tested 2026-10-26: all 9 weekly items now show simultaneously with permanent
timers. No regression noticed in the other systems this script shares, on a casual pass.
