function OnInit() local function t(a,b,lo,hi) local r=a/b
 if r>lo then else error("DIV_lo") end
 if r<hi then else error("DIV_hi") end
 error("DIV_OK") end t(20,4,4,6) end
