function OnInit()
  GNAT1 = 42
  local x = GNAT1
  if x > 41 then else error("GN_nil_low") end
  if x < 43 then else error("GN_hi") end
  GNAT1 = GNAT1 + 1
  if GNAT1 == 43 then else error("GN_rmw") end
  error("GNAT_OK")
end
