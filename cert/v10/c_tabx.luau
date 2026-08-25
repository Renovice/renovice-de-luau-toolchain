-- AUTO-GENERATED behavioural matrix: TABX
function OnInit()
  local function t(sa, sb)
    local t = {}
    t.a = 1
    t.b = 2
    if t.a + t.b == 3 then else error("T_field") end
    t.a = t.a + 10
    if t.a == 11 then else error("T_field_rmw") end
    local k = "dyn"
    t[k] = 7
    if t[k] == 7 then else error("T_regkey") end
    local i = 2
    local arr = { 10, 20, 30 }
    if arr[1] == 10 then else error("T_intkey") end
    if arr[i] == 20 then else error("T_regidx") end
    arr[i] = 99
    if arr[2] == 99 then else error("T_setregidx") end
    arr[1] = 5
    if arr[1] == 5 then else error("T_setintkey") end
    local rec = { x = 1, y = 2 }
    if rec.x + rec.y == 3 then else error("T_duptable") end
    local nst = {}
    nst.inner = {}
    nst.inner.v = 42
    if nst.inner.v == 42 then else error("T_nested") end
    t.gone = 1
    t.gone = nil
    if t.gone == nil then else error("T_setnil") end
    if ("a" .. "b") == "ab" then else error("S_concat2") end
    if ("a" .. "b" .. "c") == "abc" then else error("S_concat3") end
    if (sa .. sb) == "xy" then else error("S_concat_reg") end
    if #"abcd" == 4 then else error("S_len") end
    if #sa == 1 then else error("S_len_reg") end
    if (not false) == true then else error("S_not") end
    if (not nil) == true then else error("S_notnil") end
    if (not 0) == false then else error("S_notzero") end
    if (true and 5) == 5 then else error("L_and") end
    if (false and 5) == false then else error("L_and_short") end
    if (nil and 5) == nil then else error("L_and_nil") end
    if (false or 5) == 5 then else error("L_or") end
    if (3 or 5) == 3 then else error("L_or_short") end
    if (nil or 7) == 7 then else error("L_or_nil") end
    error("V10_TABX_OK")
  end
  t("x", "y")
end
