function OnInit()
  local function t(one, two, sa, sb, sabc, vtrue, vfalse)
    local n = nil
    local b = true
    local s = sa .. sb .. "c"
    if s == sabc then else error("D_CONCAT") end
    if #sabc == 3 then else error("D_LEN") end
    if (not vfalse) == vtrue then else error("D_NOT") end
    if n == nil then else error("D_NIL") end
    if b == vtrue then else error("D_BOOL") end
    local m = one
    if m == one then else error("D_MOVE") end
    if 12345 == 12345 then else error("D_LOADK") end
    error("V9_DATA_OK")
  end
  t(1, 2, "a", "b", "abc", true, false)
end
