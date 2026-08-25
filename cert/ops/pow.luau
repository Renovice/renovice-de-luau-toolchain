function OnInit() local function t(a,b,lo,hi) local r=a^b
 if r>lo then else error("POW_lo") end
 if r<hi then else error("POW_hi") end
 error("POW_OK") end t(2,10,1023,1025) end
