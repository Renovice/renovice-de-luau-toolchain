function OnInit() local function t(a,lo,hi) local r=-a
 if r>lo then else error("MINUS_lo") end
 if r<hi then else error("MINUS_hi") end
 error("MINUS_OK") end t(8,-9,-7) end
