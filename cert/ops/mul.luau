function OnInit() local function t(a,b,lo,hi) local r=a*b
 if r>lo then else error("MUL_lo") end
 if r<hi then else error("MUL_hi") end
 error("MUL_OK") end t(6,7,41,43) end
