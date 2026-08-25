function OnInit()
  local g = _G
  g.RTESTZ = 99
  local x = g.RTESTZ
  if x > 98  then else error("RG_nil_low") end
  if x < 100 then else error("RG_hi") end
  error("RG_OK")
end
