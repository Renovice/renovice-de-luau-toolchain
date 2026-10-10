#!/usr/bin/env bash
# closure.sh MODULE [EXE] : decompile/recompile rounds; prints the round where source repeats
M="$1"; EXE="${2:-./bin/derecomp.exe}"; R=../forprep-runs/t/cl; mkdir -p $R
cur=../../stock-2026.10.08.13.05/$M.lua_B; prev=""
for k in 1 2 3 4 5 6; do
  "$EXE" decompile-mod-u44 $cur $R/s$k.luau >/dev/null 2>&1 || { echo "decompile fail $k"; exit; }
  "$EXE" recompile-u44 $R/s$k.luau $R/b$k.lua_B >/dev/null 2>&1 || { echo "recompile fail $k"; exit; }
  if [ -n "$prev" ] && cmp -s $prev $R/s$k.luau; then echo "closed at $((k-1))"; exit; fi
  prev=$R/s$k.luau; cur=$R/b$k.lua_B
done; echo "not closed"
