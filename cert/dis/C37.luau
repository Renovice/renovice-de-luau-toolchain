function OnInit()
  local function t(three, five)
    local r = 0
    if five == five then r = 1 else r = 2 end
    local s = 0
    if five == three then s = 1 else s = 2 end
    local v = r * 10 + s
    if v > 11.5 then if v < 12.5 then error("C37_v12_CORRECT") end end
    if v > 20.5 then if v < 21.5 then error("C37_v21_INVERTED") end end
    if v > 10.5 then if v < 11.5 then error("C37_v11_ALWAYSTHEN") end end
    if v > 21.5 then if v < 22.5 then error("C37_v22_ALWAYSELSE") end end
    error("C37_other")
  end
  t(3, 5)
end
