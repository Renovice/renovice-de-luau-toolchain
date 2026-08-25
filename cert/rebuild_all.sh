#!/bin/bash
# Rebuild EVERY cert module from source with the CURRENT binary and CURRENT opcode map, then deploy.
# Point: the v9/v10 suites were built before today's map changes (FORGPREP->0x0b default, IDIV 0x00
# added, ORK's C declared a const index). Re-running them is a genuine regression test.
set -u
D="$(cd "$(dirname "$0")/.." && pwd)"; cd "$D"
X=./bin/derecomp.exe
INJ="/c/Users/Bartek/OneDrive/Dokumenter/Warframe/OpenWF/CustomScripts/Inject"
rm -f "$INJ"/v9_*.spawn.lua_B "$INJ"/v1[0-9]_*.spawn.lua_B
ok=0; fail=0
plain() { # dir file tag
  if $X recompile "cert/$1/$2.luau" "cert/$1/$2.spawn.lua_B" >/dev/null 2>&1; then
    cp "cert/$1/$2.spawn.lua_B" "$INJ/$3_$2.spawn.lua_B"; ok=$((ok+1))
  else echo "  BUILD FAIL $1/$2"; fail=$((fail+1)); fi
}
knob() { # dir file tag NATIVE
  if RENOVICE_NATIVE="$4" $X recompile "cert/$1/$2.luau" "cert/$1/$2.spawn.lua_B" >/dev/null 2>&1; then
    cp "cert/$1/$2.spawn.lua_B" "$INJ/$3_$2.spawn.lua_B"; ok=$((ok+1))
  else echo "  BUILD FAIL $1/$2 (knob $4)"; fail=$((fail+1)); fi
}
for f in c_data c_arith c_cmp c_table c_loop c_func c_extra c_ord c_va c_pow c_nil; do plain v9 $f v9; done
for f in c_cmpx c_nilx c_arithx c_ctrlx c_funcx c_tabx;                              do plain v10 $f v10; done
plain v11 c_thin v11
plain v11 c_bool v11
knob  v11 c_andk v11 "ANDK"
knob  v12 c_andor v12 "AND,OR"
knob  v12 c_subk  v12 "SUBK"
knob  v12 c_cmpk  v12 "JUMPXEQKN,JUMPXEQKS,JUMPXEQKB"
knob  v12 c_jback v12 "JUMPBACK"
plain v13 c_forgprep v13          # 0x0b is now the DEFAULT, so no knob needed
# patched modules: carrier -> single opcode byte rewritten
$X recompile cert/v14/c_modr.luau _wf/rb_modr.lua_B >/dev/null 2>&1 \
  && $X de-patchop _wf/rb_modr.lua_B cert/v14/c_modr.spawn.lua_B 0 0x22 0 0x00 >/dev/null 2>&1 \
  && cp cert/v14/c_modr.spawn.lua_B "$INJ/v14_c_modr.spawn.lua_B" && ok=$((ok+1)) || { echo "  FAIL v14/c_modr"; fail=$((fail+1)); }
$X recompile cert/v15/c_ork.luau _wf/rb_ork.lua_B >/dev/null 2>&1 \
  && $X de-patchop _wf/rb_ork.lua_B cert/v15/c_ork.spawn.lua_B 0 0x38 0 0x51 >/dev/null 2>&1 \
  && cp cert/v15/c_ork.spawn.lua_B "$INJ/v15_c_ork.spawn.lua_B" && ok=$((ok+1)) || { echo "  FAIL v15/c_ork"; fail=$((fail+1)); }
knob  v16 c_fastcall v16 "FASTCALL"   # emission is default now, but keep the knob explicit
echo "built+deployed: $ok   failures: $fail"
