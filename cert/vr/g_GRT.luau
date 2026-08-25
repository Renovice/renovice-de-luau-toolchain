function OnInit()
  GXGRT = 42
  local x = GXGRT
  if x > 41 then else error("GRT_nil_low") end
  if x < 43 then else error("GRT_hi") end
  GXGRT = GXGRT + 1
  if GXGRT == 43 then else error("GRT_rmw") end
  error("GRT_OK")
end
