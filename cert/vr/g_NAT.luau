function OnInit()
  GXNAT = 42
  local x = GXNAT
  if x > 41 then else error("NAT_nil_low") end
  if x < 43 then else error("NAT_hi") end
  GXNAT = GXNAT + 1
  if GXNAT == 43 then else error("NAT_rmw") end
  error("NAT_OK")
end
