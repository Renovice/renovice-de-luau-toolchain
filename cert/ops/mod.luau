function OnInit() local function t(a,b,lo,hi) local r=a%b
 if r>lo then else error("MOD_lo") end
 if r<hi then else error("MOD_hi") end
 error("MOD_OK") end t(17,5,1,3) end
