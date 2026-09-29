# U44 build profile

Supports the verified 2026.09.24.13.29 client. Universal addon APIs are unchanged.

- `derecomp recompile-u44 source.luau output.lua_B profiles/u44/name-map.tsv`: compile portable named Lua and translate proven U43 opaque aliases. Unknown opaque aliases reject.

## Editing current U44 stock modules (raw-hash path)

Use this path for any module decompiled from U44 bytecode. Do not feed U44-decompiled source through the U43 alias map, and never decompile U44 bytecode with the U43 decompile modes.

- `derecomp decompile-mod-u44 stock.lua_B source.luau`: lowers U44 opcodes to canonical U43 opcodes in memory (native-name hashes untouched), resolves names through the namebase rehashed with seed `768e5ed0` (ambiguous U44 hashes stay raw), and writes `-- RENOVICE_NAME_HASH_SEED: 768e5ed0` plus `RENOVICE_HASH_GLOBAL`, `RENOVICE_HASH_FIELD` and `RENOVICE_IMPORT_CLASS` metadata. Unknown names render as `Name__<u44 hash>`; a name used both hashed and string-keyed renders its hashed uses as `name__<hash>`.
- `derecomp recompile-u44 source.luau output.lua_B` (no alias map): a source declaring the U44 seed is a raw-hash source. Every `X__<hex>` suffix is the exact stock hash, never rehashed or alias-mapped; plain names hash with the U44 seed; suffix-spelled global/field reads keep the hash class even without a directive; `Name__9828c6d9` is recognized as `_T`. Combining a raw-hash source with an alias map is rejected, as is compiling it with the U43 `recompile` mode.
- `derecomp recompile-u44-raw source.luau output.lua_B`: the same contract for an older U44 source that has no seed declaration.
- `derecomp semantic-ir-render-module-u44 stock.lua_B source.luau`: readable Semantic IR rendering of U44 input with the same namespace metadata. Its output is not a byte-fidelity round trip (it adds renderer capture accesses, as on U43).
- `derecomp const-identity stock.lua_B candidate.lua_B --u44`: per-prototype gate comparing native-name hash multisets, string multisets and name-key use classes with stock. A source fixed point cannot detect a stable hash-to-string class loss; this gate can. Run `python cert/u44_rawhash_roundtrip.py <stock dir> <out dir>` for the corpus form. Evidence: `RESEARCH/U44_RAW_HASH_RECOMPILE_2026-09-29.md`.
- `derecomp profile-to-u44 old.lua_B new.lua_B profiles/u44/name-map.tsv`: structured opcode/native-name lowering, retaining operands, AUX data, closures and debug metadata. This does **not** retarget module IDs, prototype IDs, upvalues or instruction-addressed hooks.
- `derecomp profile-from-u44 new.lua_B old.lua_B profiles/u44/name-map.tsv`: inverse lowering for supported aliases and verification.
- Existing `recompile` and decompiler modes retain their U43 contract. Do not feed raw U44 instructions into U43 semantic analysis.

Native opcode/profile evidence and installed-addon binding audit are recorded in `work/research/U44-2026-09-27/lua-port`. New builds require a verified profile and a stock-module binding audit. An unchanged authoring API does not mean arbitrary future native layouts are compatible.

Native aliases here are an evidence-backed subset, not a complete recovered API. Unresolved/ambiguous aliases are not guessed. The runtime's matching profile header must remain byte-identical to `src/de_opcode_profile.h`.
