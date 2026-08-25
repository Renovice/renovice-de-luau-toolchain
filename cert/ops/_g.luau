function OnInit() local function t(a,b,lo,hi) local r=a-b
 if r>lo then else error("SUB_0x07_lo") end
 if r<hi then else error("SUB_0x07_hi") end
 error("SUB_0x07_OK") end t(10,3,6,8) end
