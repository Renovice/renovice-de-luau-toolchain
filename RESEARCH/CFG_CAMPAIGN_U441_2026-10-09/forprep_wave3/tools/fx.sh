#!/usr/bin/env bash
# fx.sh FIXTURE.luau [EXE] : compile (recompile), luau.exe trace, decompile-mod, recompile, trace, cfg-identity
F="$1"; EXE="${2:-../../forprep/bin/derecomp.exe}"; B=${F%.luau}
L=../../forprep/bin/luau.exe
"$EXE" recompile $F $B.orig.lua_B >/dev/null || exit 1
"$EXE" decompile-mod $B.orig.lua_B $B.dec.luau >/dev/null 2>&1 || { echo DECOMPILE FAIL; exit 1; }
"$EXE" recompile $B.dec.luau $B.dec.lua_B >/dev/null || { echo RECOMPILE FAIL; exit 1; }
$L $F > $B.t0 2>&1; $L $B.dec.luau > $B.t1 2>&1
if cmp -s $B.t0 $B.t1; then echo BEHAVIOR SAME; else echo BEHAVIOR DIFFERS; diff $B.t0 $B.t1 | head -8; fi
"$EXE" cfg-identity $B.orig.lua_B $B.dec.lua_B | grep -E '^proto|CFG_IDENTITY'
