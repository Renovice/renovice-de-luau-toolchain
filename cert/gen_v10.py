# Generates the v10 BEHAVIOURAL matrix: every construct exercised in BOTH polarities, at boundaries,
# and with discriminating values (nil / false / 0 / "" / negatives / captured). Hand-written certs missed
# four real bugs; a generated matrix is systematic instead of ad-hoc.
# Sandbox limits: no table./string. libraries. math.* works via GETIMPORT. Use operators + print/error/
# tostring/type/pcall/pairs/ipairs/select only.
from pathlib import Path
OUT = Path(__file__).parent / "v10"
OUT.mkdir(exist_ok=True)

def mod(name, body, params, args):
    return ("-- AUTO-GENERATED behavioural matrix: %s\n"
            "function OnInit()\n  local function t(%s)\n%s"
            "    error(\"V10_%s_OK\")\n  end\n  t(%s)\nend\n") % (name, params, body, name, args)

def chk(cond, tag):   return "    if %s then else error(\"%s\") end\n" % (cond, tag)
def chkf(cond, tag):  return "    if %s then error(\"%s\") end\n" % (cond, tag)

# ---------- 1. COMPARE MATRIX ----------
b = ""
for x, y, rel in (("a", "b", "lt"), ("b", "a", "gt"), ("a", "c", "eq")):
    lt, gt, eq = rel == "lt", rel == "gt", rel == "eq"
    L = lambda v: "true" if v else "false"
    b += chk("(%s < %s) == %s"  % (x, y, L(lt)),        "C_lt_" + rel)
    b += chk("(%s <= %s) == %s" % (x, y, L(lt or eq)),  "C_le_" + rel)
    b += chk("(%s > %s) == %s"  % (x, y, L(gt)),        "C_gt_" + rel)
    b += chk("(%s >= %s) == %s" % (x, y, L(gt or eq)),  "C_ge_" + rel)
    b += chk("(%s == %s) == %s" % (x, y, L(eq)),        "C_eq_" + rel)
    b += chk("(%s ~= %s) == %s" % (x, y, L(not eq)),    "C_ne_" + rel)
b += chk("a < b", "C_if_lt");            b += chkf("b < a", "C_if_ltf")
b += chk("a <= c", "C_if_le_bound");     b += chkf("b <= a", "C_if_lef")
b += chk("a >= c", "C_if_ge_bound");     b += chkf("a >= b", "C_if_gef")
b += chk("a == 3", "C_k_eq");            b += chkf("a == 4", "C_k_eqf")
b += chk("a ~= 4", "C_k_ne");            b += chkf("a ~= 3", "C_k_nef")
b += chk("a < 4", "C_k_lt");             b += chk("a <= 3", "C_k_le_bound")
b += chk("a > 2", "C_k_gt");             b += chk("a >= 3", "C_k_ge_bound")
b += chk("(a < a) == false", "C_lt_self"); b += chk("(a <= a) == true", "C_le_self")
(OUT / "c_cmpx.luau").write_text(mod("CMPX", b, "a, b, c", "3, 5, 3"), encoding="utf-8")

# ---------- 2. NIL / FALSE / TRUTHINESS ----------
b = "    local n = nil\n    local f = false\n    local z = 0\n    local s = \"\"\n"
b += chk("n == nil", "N_nil_eq");          b += chkf("n ~= nil", "N_nil_ne")
b += chk("f ~= nil", "N_false_ne_nil");    b += chkf("f == nil", "N_false_eq_nil")
b += chk("z ~= nil", "N_zero_ne_nil");     b += chk("s ~= nil", "N_str_ne_nil")
b += chkf("n", "N_nil_truthy");            b += chkf("f", "N_false_truthy")
b += chk("z", "N_zero_should_be_truthy");  b += chk("s", "N_emptystr_truthy")
b += chk("f == false", "N_false_eqfalse"); b += chk("f ~= true", "N_false_netrue")
b += "    local p\n    local cp = function() p = nil end cp()\n"
b += chk("p == nil", "N_cap_setnil_eq");   b += chkf("p ~= nil", "N_cap_setnil_ne")
b += "    local q = 1\n    local cq = function() q = nil end cq()\n"
b += chk("q == nil", "N_cap_1tonil")
b += "    local r\n    local cr = function() r = 9 end cr()\n"
b += chk("r == 9", "N_cap_niltonum");      b += chk("r ~= nil", "N_cap_niltonum_ne")
b += "    local u\n    local cu = function() return u end\n"
b += chk("u == nil", "N_cap_readonly")
b += "    local v = false\n    local cv = function() v = false end cv()\n"
b += chk("v == false", "N_cap_false");     b += chk("v ~= nil", "N_cap_false_ne_nil")
(OUT / "c_nilx.luau").write_text(mod("NILX", b, "unused", "0"), encoding="utf-8")

# ---------- 3. ARITHMETIC ----------
b = ""
b += chk("(ten + three) == 13", "A_add");   b += chk("(ten - three) == 7", "A_sub")
b += chk("(ten * three) == 30", "A_mul");   b += chk("(ten / four) == 2.5", "A_div")
b += chk("(ten % three) == 1", "A_mod");    b += chk("(two ^ three) == 8", "A_pow")
b += chk("(-ten) == negten", "A_unm")
b += chk("(ten + 4) == 14", "A_addk");      b += chk("(ten - 4) == 6", "A_subk")
b += chk("(ten * 4) == 40", "A_mulk");      b += chk("(ten / 4) == 2.5", "A_divk")
b += chk("(ten % 4) == 2", "A_modk");       b += chk("(two ^ 3) == 8", "A_powk")
b += chk("(ten // 4) == 2", "A_idivk");     b += chk("(ten // 3) == 3", "A_idivk2")
b += chk("(20 - ten) == 10", "A_subrk");    b += chk("(20 / ten) == 2", "A_divrk")
b += chk("(negten + ten) == 0", "A_negadd")
b += chk("(negten * negone) == ten", "A_negmul")
b += chk("(three / two) == 1.5", "A_frac")
b += chk("(negten / four) == -2.5", "A_negfrac")
b += chk("(zero * ten) == 0", "A_zero");    b += chk("(ten + zero) == ten", "A_addzero")
b += chk("(negten % three) == 2", "A_negmod")
b += chk("((ten + three) * two - four) == 22", "A_precedence")
(OUT / "c_arithx.luau").write_text(
    mod("ARITHX", b, "zero, negone, two, three, four, ten, negten", "0, -1, 2, 3, 4, 10, -10"), encoding="utf-8")

# ---------- 4. CONTROL FLOW ----------
b = ""
b += "    local s = 0\n    for i = 1, ten do s = s + i end\n" + chk("s == 55", "F_forn_up")
b += "    local d = 0\n    for i = ten, 1, -1 do d = d + 1 end\n" + chk("d == 10", "F_forn_down")
b += "    local st = 0\n    for i = 1, ten, 2 do st = st + 1 end\n" + chk("st == 5", "F_forn_step")
b += "    local w = 0\n    while w < three do w = w + 1 end\n" + chk("w == 3", "F_while")
b += "    local rp = 0\n    repeat rp = rp + 1 until rp >= three\n" + chk("rp == 3", "F_repeat")
b += "    local rn = 0\n    repeat rn = rn + 1 until rn ~= 0\n" + chk("rn == 1", "F_repeat_ne")
b += "    local br = 0\n    for i = 1, ten do if i > three then break end br = br + 1 end\n" + chk("br == 3", "F_break")
b += "    local nst = 0\n    for i = 1, three do for j = 1, three do nst = nst + 1 end end\n" + chk("nst == 9", "F_nested")
b += "    local ch = 0\n    if three > ten then ch = 1 elseif three == 3 then ch = 2 else ch = 3 end\n" + chk("ch == 2", "F_elseif")
b += "    local arr = { 10, 20, 30 }\n    local isum = 0\n    for i, v in ipairs(arr) do isum = isum + v end\n" + chk("isum == 60", "F_ipairs")
b += "    local psum = 0\n    for k, v in pairs(arr) do psum = psum + v end\n" + chk("psum == 60", "F_pairs")
b += "    local ecnt = 0\n    for i = 1, 0 do ecnt = ecnt + 1 end\n" + chk("ecnt == 0", "F_empty_for")
b += "    local icnt = 0\n    for i, v in ipairs({}) do icnt = icnt + 1 end\n" + chk("icnt == 0", "F_empty_ipairs")
(OUT / "c_ctrlx.luau").write_text(mod("CTRLX", b, "three, ten", "3, 10"), encoding="utf-8")

# ---------- 5. FUNCTIONS / UPVALUES / VARARGS ----------
b = "    local acc = 0\n    local bump = function(n) acc = acc + n return acc end\n"
b += chk("bump(1) == 1", "U_cap1"); b += chk("bump(2) == 3", "U_cap2"); b += chk("acc == 3", "U_cap_direct")
b += "    local function add(x, y) return x + y end\n" + chk("add(2,3) == 5", "U_call")
b += "    local function multi() return 1, 2, 3 end\n    local m1, m2, m3 = multi()\n"
b += chk("m1 == 1", "U_multi1"); b += chk("m2 == 2", "U_multi2"); b += chk("m3 == 3", "U_multi3")
b += "    local function va(...) local x, y = ... return (x or 0) + (y or 0) end\n"
b += chk("va(3,4) == 7", "U_vararg"); b += chk("va(3) == 3", "U_vararg_short")
b += chk("select(\"#\", 1, 2, 3) == 3", "U_select")
b += "    local function fact(n) if n <= 1 then return 1 end return n * fact(n-1) end\n"
b += chk("fact(5) == 120", "U_recurse")
b += "    local o = {}\n    function o:m(x) return x * 2 end\n" + chk("o:m(4) == 8", "U_method")
b += "    local fs = {}\n    for i = 1, 3 do fs[i] = function() return i end end\n"
b += chk("fs[1]() == 1", "U_closeup1"); b += chk("fs[3]() == 3", "U_closeup3")
b += "    local outer = 5\n    local function mid() local function inner() return outer end return inner() end\n"
b += chk("mid() == 5", "U_nested_upval")
b += "    local ok, err = pcall(function() error(\"boom\") end)\n"
b += chkf("ok", "U_pcall_shouldfail")
(OUT / "c_funcx.luau").write_text(mod("FUNCX", b, "unused", "0"), encoding="utf-8")

# ---------- 6. TABLES / STRINGS / LOGICAL ----------
b = "    local t = {}\n    t.a = 1\n    t.b = 2\n" + chk("t.a + t.b == 3", "T_field")
b += "    t.a = t.a + 10\n" + chk("t.a == 11", "T_field_rmw")
b += "    local k = \"dyn\"\n    t[k] = 7\n" + chk("t[k] == 7", "T_regkey")
b += "    local i = 2\n    local arr = { 10, 20, 30 }\n"
b += chk("arr[1] == 10", "T_intkey"); b += chk("arr[i] == 20", "T_regidx")
b += "    arr[i] = 99\n" + chk("arr[2] == 99", "T_setregidx")
b += "    arr[1] = 5\n" + chk("arr[1] == 5", "T_setintkey")
b += "    local rec = { x = 1, y = 2 }\n" + chk("rec.x + rec.y == 3", "T_duptable")
b += "    local nst = {}\n    nst.inner = {}\n    nst.inner.v = 42\n" + chk("nst.inner.v == 42", "T_nested")
b += "    t.gone = 1\n    t.gone = nil\n" + chk("t.gone == nil", "T_setnil")
b += chk("(\"a\" .. \"b\") == \"ab\"", "S_concat2")
b += chk("(\"a\" .. \"b\" .. \"c\") == \"abc\"", "S_concat3")
b += chk("(sa .. sb) == \"xy\"", "S_concat_reg")
b += chk("#\"abcd\" == 4", "S_len"); b += chk("#sa == 1", "S_len_reg")
b += chk("(not false) == true", "S_not"); b += chk("(not nil) == true", "S_notnil")
b += chk("(not 0) == false", "S_notzero")
b += chk("(true and 5) == 5", "L_and"); b += chk("(false and 5) == false", "L_and_short")
b += chk("(nil and 5) == nil", "L_and_nil")
b += chk("(false or 5) == 5", "L_or"); b += chk("(3 or 5) == 3", "L_or_short")
b += chk("(nil or 7) == 7", "L_or_nil")
(OUT / "c_tabx.luau").write_text(mod("TABX", b, "sa, sb", "\"x\", \"y\""), encoding="utf-8")

for p in sorted(OUT.glob("*.luau")):
    txt = p.read_text(encoding="utf-8")
    print("  %-16s %3d assertions" % (p.name, txt.count("error(\"") - 1))
