function OnInit()
  local function t(two, three, ten)
    if two ^ ten == 1024 then else error("P_POW_RR") end   -- reg-reg POW  (0x45)
    if two ^ 10 == 1024 then else error("P_POWK")  end     -- POWK control (0x08)
    if ten // 3 == 3 then else error("P_IDIVK")  end       -- floor-div by CONST (0x24)
    if ten // 4 == 2 then else error("P_IDIVK2") end
    error("V9_POW_OK")
  end
  t(2, 3, 10)
end
