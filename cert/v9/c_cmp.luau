function OnInit()
  local function t(three, five, vtrue, vfalse, sx)
    if three < five then else error("C_LT") end
    if five < three then error("C_LTf") end
    if five <= five then else error("C_LE") end
    if five + 1 <= five then error("C_LEf") end
    if five == five then else error("C_EQ") end
    if five == three then error("C_NE") end
    if vtrue then else error("C_JUMPIF") end
    if not vfalse then else error("C_JUMPIFNOT") end
    if three == 3 then else error("C_KEQN") end
    if three ~= 4 then else error("C_KNEN") end
    if sx == "hi" then else error("C_KEQS") end
    local z = nil
    if z == nil then else error("C_KEQNIL") end
    if vtrue == true then else error("C_KEQB") end
    error("V9_CMP_OK")
  end
  t(3, 5, true, false, "hi")
end
