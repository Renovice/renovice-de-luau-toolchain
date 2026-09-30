#!/bin/bash
# usage: closure.sh <stock.lua_B> <tag>  (env passes through) -> prints pass at which source repeats
D="${CLEXE:-$(cd "$(dirname "$0")/../.." && pwd)/bin/derecomp.d51d877e.exe}"
d="$(dirname "$0")/cl/$2"; mkdir -p "$d"; cp "$1" "$d/b0.lua_B"
prev=""
for i in 1 2 3 4 5 6; do
  "$D" decompile-mod-u44 "$d/b$((i-1)).lua_B" "$d/s$i.luau" >/dev/null 2>&1
  "$D" recompile-u44 "$d/s$i.luau" "$d/b$i.lua_B" >/dev/null 2>&1
  h=$(sha256sum "$d/s$i.luau" | cut -c1-16)
  if [ "$h" = "$prev" ]; then echo "$2 closed_at=$i"; exit 0; fi
  prev=$h
done
echo "$2 NOT_CLOSED"
