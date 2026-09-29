# U44 build profile

Supports the verified 2026.09.24.13.29 client. Universal addon APIs are unchanged.

- `derecomp recompile-u44 source.luau output.lua_B profiles/u44/name-map.tsv`: compile portable named Lua and translate proven U43 opaque aliases. Unknown opaque aliases reject.
- `derecomp profile-to-u44 old.lua_B new.lua_B profiles/u44/name-map.tsv`: structured opcode/native-name lowering, retaining operands, AUX data, closures and debug metadata. This does **not** retarget module IDs, prototype IDs, upvalues or instruction-addressed hooks.
- `derecomp profile-from-u44 new.lua_B old.lua_B profiles/u44/name-map.tsv`: inverse lowering for supported aliases and verification.
- Existing `recompile` and decompiler modes retain their U43 contract. Do not feed raw U44 instructions into U43 semantic analysis.

Native opcode/profile evidence and installed-addon binding audit are recorded in `work/research/U44-2026-09-27/lua-port`. New builds require a verified profile and a stock-module binding audit. An unchanged authoring API does not mean arbitrary future native layouts are compatible.

Native aliases here are an evidence-backed subset, not a complete recovered API. Unresolved/ambiguous aliases are not guessed. The runtime's matching profile header must remain byte-identical to `src/de_opcode_profile.h`.
