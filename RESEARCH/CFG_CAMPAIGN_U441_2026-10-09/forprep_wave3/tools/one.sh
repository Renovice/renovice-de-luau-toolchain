#!/usr/bin/env bash
# one.sh MODULE PROTO [exe] : decompile+recompile+cfg-identity, print proto's function source and stock IR
M="$1"; P="$2"; EXE="${3:-./bin/derecomp.exe}"
S=../../stock-2026.10.08.13.05/$M.lua_B; R=../forprep-runs/t
"$EXE" decompile-mod-u44 $S $R/$M.luau >/dev/null 2>&1
"$EXE" recompile-u44 $R/$M.luau $R/$M.lua_B >/dev/null 2>&1
"$EXE" cfg-identity $S $R/$M.lua_B --u44 | grep -E "^proto $P |CFG_IDENTITY"
