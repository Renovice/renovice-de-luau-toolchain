#!/usr/bin/env python3
"""
gen_rt.py — generate the M6 GROUND-TRUTH corpus.

The old decompiled sources (all_source_v13/v14/v15) cannot validate the decompiler: they were
produced with the wrong opcode map, so "our output matches v13" would mean we are wrong in the
same way. Instead we generate source we KNOW by construction, and push it through the certified
front half of the pipeline:

    S --luau-compile--> LBC1 --transcode--> DE1 --decompile--> S' --luau-compile--> LBC2
                          |                                                          |
                          +------------------ compare -------------------------------+

If S' compiles to the same Luau bytecode as S did, S' is the same program — independent of
formatting, identifier names or register allocation.

Each case is SMALL and focused on one construct, so a failure localises immediately. That is the
same property that made the v10 matrix able to pinpoint JUMPIFEQ.
"""
import os, sys, itertools

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rt", "src")
cases = {}

def add(name, body):
    cases[name] = body if body.endswith("\n") else body + "\n"

def fn(name, params, body):
    """A module exposing one function, so every case is a complete compilable unit."""
    return "function %s(%s)\n%s\nend\n" % (name, params, body)

# ---------------------------------------------------------------- arithmetic
BIN = [("add", "+"), ("sub", "-"), ("mul", "*"), ("div", "/"),
       ("mod", "%"), ("pow", "^"), ("idiv", "//")]
for nm, op in BIN:
    add("arith_%s_rr" % nm, fn("f", "a, b", "  return a %s b" % op))
    add("arith_%s_rk" % nm, fn("f", "a",    "  return a %s 3" % op))   # K on the right
    add("arith_%s_kr" % nm, fn("f", "a",    "  return 7 %s a" % op))   # K on the left
add("arith_unm",    fn("f", "a", "  return -a"))
add("arith_len",    fn("f", "a", "  return #a"))
add("arith_not",    fn("f", "a", "  return not a"))
add("arith_chain",  fn("f", "a, b, c", "  return a + b * c - a / b"))
add("arith_paren",  fn("f", "a, b, c", "  return (a + b) * (c - a)"))
add("arith_negk",   fn("f", "a", "  return a - -4"))

# ---------------------------------------------------------------- comparisons
CMP = [("eq", "=="), ("ne", "~="), ("lt", "<"), ("le", "<="), ("gt", ">"), ("ge", ">=")]
for nm, op in CMP:
    # BRANCHING form and VALUE-PRODUCING form compile to different opcodes — cover both.
    add("cmp_%s_branch_rr" % nm, fn("f", "a, b", "  if a %s b then return 1 else return 2 end" % op))
    add("cmp_%s_value_rr"  % nm, fn("f", "a, b", "  return a %s b" % op))
    add("cmp_%s_branch_kn" % nm, fn("f", "a",    "  if a %s 5 then return 1 else return 2 end" % op))
    add("cmp_%s_value_kn"  % nm, fn("f", "a",    "  return a %s 5" % op))
# constant-type dispatch: DE picks the compare by CONSTANT KIND, so cover each kind
add("cmp_eq_kstr",  fn("f", "a", '  if a == "hi" then return 1 else return 2 end'))
add("cmp_ne_kstr",  fn("f", "a", '  return a ~= "hi"'))
add("cmp_eq_kbool", fn("f", "a", "  if a == true then return 1 else return 2 end"))
add("cmp_ne_kbool", fn("f", "a", "  return a ~= false"))
add("cmp_eq_knil",  fn("f", "a", "  if a == nil then return 1 else return 2 end"))
add("cmp_ne_knil",  fn("f", "a", "  return a ~= nil"))
add("cmp_boundary", fn("f", "a", "  return a <= a, a < a, a >= a, a > a"))   # what separates < from <=

# ---------------------------------------------------------------- and / or
add("logic_and_rr",   fn("f", "a, b", "  return a and b"))
add("logic_or_rr",    fn("f", "a, b", "  return a or b"))
add("logic_and_k",    fn("f", "a",    "  return a and true"))
add("logic_or_k",     fn("f", "a",    "  return a or 5"))
add("logic_or_kstr",  fn("f", "a",    '  return a or "default"'))
add("logic_chain",    fn("f", "a, b, c", "  return a and b or c"))
add("logic_notnot",   fn("f", "a",    "  return not not a"))
add("logic_guard",    fn("f", "t",    "  return t and t.x and t.x.y"))

# ---------------------------------------------------------------- control flow
add("ctrl_if",        fn("f", "a", "  if a then return 1 end\n  return 0"))
add("ctrl_ifelse",    fn("f", "a", "  if a then return 1 else return 2 end"))
add("ctrl_elseif",    fn("f", "a, b", "  if a then return 1 elseif b then return 2 else return 3 end"))
add("ctrl_while",     fn("f", "n", "  local s = 0\n  local i = 0\n  while i < n do i = i + 1; s = s + i end\n  return s"))
add("ctrl_repeat",    fn("f", "n", "  local i = 0\n  repeat i = i + 1 until i >= n\n  return i"))
add("ctrl_fornum",    fn("f", "n", "  local s = 0\n  for i = 1, n do s = s + i end\n  return s"))
add("ctrl_fornum_st", fn("f", "n", "  local s = 0\n  for i = 1, n, 2 do s = s + i end\n  return s"))
add("ctrl_fornum_dn", fn("f", "n", "  local s = 0\n  for i = n, 1, -1 do s = s + i end\n  return s"))
add("ctrl_forpairs",  fn("f", "t", "  local s = 0\n  for k, v in pairs(t) do s = s + v end\n  return s"))
add("ctrl_foripairs", fn("f", "t", "  local s = 0\n  for i, v in ipairs(t) do s = s + v end\n  return s"))
add("ctrl_forgeneric",
    "local function iter(s, i) i = i + 1; if i <= 3 then return i, i * 10 end end\n" +
    fn("f", "", "  local s = 0\n  for i, v in iter, nil, 0 do s = s + v end\n  return s"))
add("ctrl_break",     fn("f", "n", "  local s = 0\n  for i = 1, n do if i > 3 then break end s = s + i end\n  return s"))
add("ctrl_continue",  fn("f", "n", "  local s = 0\n  for i = 1, n do if i == 2 then continue end s = s + i end\n  return s"))
add("ctrl_nested",    fn("f", "n", "  local s = 0\n  for i = 1, n do for j = 1, n do s = s + i * j end end\n  return s"))
add("ctrl_whiletrue", fn("f", "n", "  local i = 0\n  while true do i = i + 1; if i >= n then return i end end"))
add("ctrl_deadtail",  fn("f", "a", "  if a then return 1 else return 2 end\n  return 3"))  # unreachable tail

# ---------------------------------------------------------------- functions
for n in range(0, 4):
    ps = ", ".join("p%d" % i for i in range(n))
    rs = " + ".join("p%d" % i for i in range(n)) or "0"
    add("func_params%d" % n, fn("f", ps, "  return %s" % rs))
add("func_multiret",  fn("f", "a", "  return a, a + 1, a + 2"))
add("func_multiassign", fn("f", "a", "  local x, y, z = a, a + 1, a + 2\n  return x + y + z"))
add("func_vararg",    "function f(...)\n  local a, b = ...\n  return a, b, select('#', ...)\nend\n")
add("func_vararg_fwd","local function g(...) return ... end\nfunction f(...) return g(...) end\n")
add("func_closure1",  fn("f", "a", "  local function g() return a end\n  return g()"))
add("func_closure3",  fn("f", "a, b, c", "  local function g() return a + b + c end\n  return g()"))
add("func_closure_mut", fn("f", "a", "  local n = a\n  local function g() n = n + 1; return n end\n  g(); return g()"))
add("func_nested2",   fn("f", "a", "  local function g()\n    local function h() return a end\n    return h()\n  end\n  return g()"))
add("func_recurse",   "local function fact(n) if n <= 1 then return 1 end return n * fact(n - 1) end\nfunction f(n) return fact(n) end\n")
add("func_method",    "local T = {}\nT.__index = T\nfunction T:get() return self.v end\nfunction f(o) return o:get() end\n")
add("func_callargs",  fn("f", "g, a, b", "  return g(), g(a), g(a, b)"))
add("func_anon",      fn("f", "a", "  local g = function(x) return x * 2 end\n  return g(a)"))

# ---------------------------------------------------------------- tables
add("tbl_array",      fn("f", "", "  return {1, 2, 3}"))
add("tbl_hash",       fn("f", "", "  return {x = 1, y = 2}"))
add("tbl_mixed",      fn("f", "", "  return {1, 2, x = 3, y = 4}"))
add("tbl_bool",       fn("f", "", "  return {on = true, off = false, none = nil}"))
add("tbl_nested",     fn("f", "", "  return {a = {b = {c = 1}}}"))
add("tbl_empty",      fn("f", "", "  return {}"))
add("tbl_field_get",  fn("f", "t", "  return t.x"))
add("tbl_field_set",  fn("f", "t, v", "  t.x = v"))
add("tbl_field_chain",fn("f", "t", "  return t.a.b.c"))
add("tbl_index_get",  fn("f", "t, k", "  return t[k]"))
add("tbl_index_set",  fn("f", "t, k, v", "  t[k] = v"))
add("tbl_index_num",  fn("f", "t", "  return t[1], t[2]"))
add("tbl_len",        fn("f", "t", "  return #t"))
add("tbl_dynamic",    fn("f", "a, b", "  return {a, b, [a] = b}"))
add("tbl_bigarray",   fn("f", "", "  return {%s}" % ", ".join(str(i) for i in range(1, 21))))
# SETTABLEN: t[<small int literal>] = v. A GENERATOR GAP found by comparing ground-truth opcode
# coverage against the real corpus — we emit 0x2e but no case produced it.
add("tbl_setn",       fn("f", "t, v", "  t[1] = v\n  t[2] = v\n  t[3] = v"))
add("tbl_setn_mix",   fn("f", "t, v", "  t[1] = v\n  t.x = v\n  t[v] = v"))
add("tbl_getn_setn",  fn("f", "t", "  t[1] = t[2]\n  return t[1]"))

# ---------------------------------------------------------------- strings / concat
add("str_concat2",    fn("f", "a, b", "  return a .. b"))
add("str_concat4",    fn("f", "a, b, c, d", "  return a .. b .. c .. d"))
add("str_concat_k",   fn("f", "a", '  return "x=" .. a .. "!"'))
add("str_escape",     fn("f", "", '  return "tab\\there\\nnl \\"q\\" back\\\\slash"'))
add("str_method",     fn("f", "s", "  return s:upper()"))

# ---------------------------------------------------------------- globals / imports
add("glob_read",      fn("f", "", "  return SomeGlobal"))
add("glob_write",     fn("f", "v", "  SomeGlobal = v"))
add("glob_rw",        fn("f", "v", "  SomeGlobal = v\n  return SomeGlobal"))
add("imp_math1",      fn("f", "a", "  return math.floor(a)"))
add("imp_math2",      fn("f", "a, b", "  return math.max(a, b)"))
add("imp_math_k",     fn("f", "a", "  return math.max(a, 2)"))
add("imp_nested",     fn("f", "a", "  return math.floor(math.abs(a))"))
add("imp_type",       fn("f", "a", "  return type(a)"))
add("imp_tostring",   fn("f", "a", "  return tostring(a)"))
add("imp_pairs_call", fn("f", "t", "  return pairs(t)"))
# 3-ARGUMENT builtin calls -> FASTCALL3 (DE 0x4a), the last opcode with no generated case.
add("imp_sub3",       fn("f", "s, a, b", "  return string.sub(s, 1, -7), string.sub(s, a, b)"))
add("imp_clamp3",     fn("f", "a", "  return math.clamp(a, 0, 10)"))

# ---------------------------------------------------------------- constants
add("konst_nums",     fn("f", "", "  return 0, 1, -1, 255, 256, 65535, 3.5, -2.25, 1e10, 0.1"))
add("konst_bools",    fn("f", "", "  return true, false"))
add("konst_nil",      fn("f", "", "  return nil"))
add("konst_strs",     fn("f", "", '  return "", "a", "hello world"'))
add("konst_bigint",   fn("f", "", "  return 2147483647, -2147483648"))

# ---------------------------------------------------------------- combined shapes
add("mix_dispatch",   fn("f", "t, k",
    "  local h = t[k]\n  if h then return h(t) end\n  return nil"))
add("mix_accum",      fn("f", "t",
    "  local out = {}\n  for i, v in ipairs(t) do out[#out + 1] = v * 2 end\n  return out"))
add("mix_default",    fn("f", "opts",
    '  opts = opts or {}\n  local n = opts.n or 10\n  local name = opts.name or "anon"\n  return n, name'))
add("mix_guardcall",  fn("f", "o",
    "  if o and o.fn then return o:fn(1, 2) end\n  return nil"))

def main():
    os.makedirs(OUT, exist_ok=True)
    for f in os.listdir(OUT):
        if f.endswith(".luau"):
            os.remove(os.path.join(OUT, f))
    for name, body in sorted(cases.items()):
        with open(os.path.join(OUT, name + ".luau"), "w", encoding="utf-8", newline="\n") as fh:
            fh.write("-- ground-truth case: %s\n%s" % (name, body))
    print("wrote %d cases -> %s" % (len(cases), OUT))
    groups = {}
    for name in cases:
        groups[name.split("_")[0]] = groups.get(name.split("_")[0], 0) + 1
    for g, n in sorted(groups.items()):
        print("   %-8s %d" % (g, n))

if __name__ == "__main__":
    main()
