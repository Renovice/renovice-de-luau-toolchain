# Warframe Ability/API Trace Oracle

This directory tests shared Warframe-shaped callback semantics without loading
or modifying the game.

## Files

- `src/*.luau`: known-source property fixtures.
- `de/*.lua_B`: DE-format fixtures generated from `src`.
- `mock_prelude.luau`: deterministic typed native-object boundary.
- `probe.luau`: callback lifecycle runner and canonical trace writer.

## Rebuild and run

From the DeNativeDecompiler root:

```powershell
.\bin\derecomp.exe rt-build cert\warframe_api\src
python cert\behave.py --semantic-ir --warframe-api --verbose
python cert\gates.py 300 150
```

Expected dedicated result: **11 SAME, 0 DIFFERENT, 0 VACUOUS**.

This directory is a compiler/decompiler trace oracle, not the authoritative
real-engine API definition. Real native contracts, evidence confidence,
lifetimes, authority limits, and disproven assumptions live in
`api/warframe/`.

## Fixture rules

1. Add fixtures by semantic property, never to special-case one ability or
   prototype.
2. Prefer recovered real callback/API names. Invented names become DE
   hash-only `Name__<hash>` aliases and test name recovery instead of the
   intended semantic property.
3. Use a literal for synthetic resource/type values unless the global name is
   itself the property being tested.
4. Add typed mock returns only when supported by recovered source/API evidence.
   Unknown methods remain traceable and return `nil`.
5. A matching error is not sufficient. Every fixture must produce at least one
   successful callback observation, and the suite must keep zero vacuous cases.
6. This oracle never authorizes game injection. Live VM, loader, native
   userdata, timing, replication, and rollback require the separate controlled
   no-edit reinjection gate.
