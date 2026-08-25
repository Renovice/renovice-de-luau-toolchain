function OnInit()
  GTESTX = 42
  local x = GTESTX
  if x > 41 then else error("GG_nil_or_low") end
  if x < 43 then else error("GG_hi") end
  error("GG_OK")
end
