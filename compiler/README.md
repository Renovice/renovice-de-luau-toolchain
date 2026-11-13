# luau-compile-renovice

`bin/luau-compile-renovice.exe` is upstream Luau's `luau-compile` with a few fast flags added. The
round-trip gates recompile decompiled source with it (`src/main.cpp` `compile_luau`). The flags are off
by default, so without them its output is byte-identical to upstream.

Base: luau-lang/luau `5bc7f4b23756f69f4669b419fa9034f117ccd6fe` ("Clip this assert. (#2568)").
Changed files, copied here verbatim:

- `Compiler.cpp` -> `Compiler/src/Compiler.cpp`
- `Flags.cpp` -> `CLI/src/Flags.cpp` (integer fast flags on the command line)

| flag | default | effect |
|---|---|---|
| `RenoviceInlineMissingArgsConstant` | 1 | cost-model treatment of missing call arguments as constants (inliner A/B) |
| `RenoviceGroupNotTemplated` | 0 | a parenthesised table value stays out of the constructor template (DE keeps some constant fields out) |
| `RenoviceNoConstantSwap` | 0 | `-O2` does not swap `k*r` / `k+r` operands (DE does not) |
| `RenoviceInlineGroupedOnly` | 0 | only a call written `(f)(x)` is inlined, and the cost threshold is waived for it: the decompiler writes that form exactly for the calls DE inlined |

`compile_luau` passes `RenoviceGroupNotTemplated=1,RenoviceNoConstantSwap=1,RenoviceInlineGroupedOnly=1`
(`RENOVICE_LUAU_INLINE_ANY` drops the last one; `RENOVICE_LUAU_UPSTREAM` uses the plain compiler).

Build (msys2 ucrt64):

```bash
git clone https://github.com/luau-lang/luau src && git -C src checkout 5bc7f4b23756f69f4669b419fa9034f117ccd6fe
cp compiler/Compiler.cpp src/Compiler/src/Compiler.cpp && cp compiler/Flags.cpp src/CLI/src/Flags.cpp
cmake -S src -B out -G Ninja -DCMAKE_BUILD_TYPE=Release && ninja -C out luau-compile.exe
cp out/luau-compile.exe bin/luau-compile-renovice.exe
```
