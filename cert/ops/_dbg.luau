function OnInit() local function t(a,b,lo,hi) local r=a-b
 if r>lo then else error("SUB_lo") end
 if r<hi then else error("SUB_hi") end
 error("SUB_OK") end t(10,3,6,8) end
