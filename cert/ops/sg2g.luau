function OnInit()
  GGY = 7          -- SETGLOBAL 0x02
  local g = _G
  local x = g.GGY  -- read via _G table
  if x > 6 then else error("SG_nil_low") end
  if x < 8 then else error("SG_hi") end
  error("SG2G_OK")
end
