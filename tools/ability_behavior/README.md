# Ability behavior catalog

This deterministic tool joins the existing 248-entry Ability Studio catalog
to exact DE bytecode evidence. It produces one module behavior record per
unique body key, a complete ability-entry index, and an API-usage ranking for
deep-contract work.

The tool proves only facts available from the pinned artifacts:

- exact stock bytecode and deployed FNV body key;
- verified Semantic IR render and callsite identity;
- exact exported global names;
- export-to-prototype identity when the synchronized renderer identifier and
  closure map agree;
- direct callsites in that prototype, with receiver and API-contract evidence
  preserved verbatim.

It does not claim that a direct call executes on every path or that helper
calls are transitively included. `lexical_signal_index` and
`cleanup_pair_candidates` are search aids. Their names are not promoted into
gameplay, authority, lifetime, mutation, or cleanup contracts.

Run from this directory:

```powershell
.\build.ps1 -Jobs 2
```

Use `-Reuse` only to reuse a module render whose input bytecode, decompiler,
Semantic SDK, artifact sizes, and artifact hashes all match its cache
manifest. The default output is
`work/ability-behavior/current/ability-behavior-catalog.json`.

## Current pinned result

The 2026-09-08 build verifies all 248 ability entries and all 246 unique body
modules. It records 88,869 exact callsites: 15,917 confirmed, 30,820
catalog-only, and 42,000 unregistered. The generated tree has 2,217 files; a
cached rebuild changed zero. Catalog SHA-256:
`40756DD95628D62E3670DBDFBC6CAB43BC72A95E027BA756240370BAC70F05DD`.

Eight catalog entries have an empty stock `ability_identifier`. The tool
preserves that empty value and still binds the entry through exact module,
export, renderer identity, and closure-map evidence. It never invents the
missing metadata name.
