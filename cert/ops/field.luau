function OnInit() local function t(v,lo,hi) local r={}
 r.a=v
 local x=r.a
 if x>lo then else error("FIELD_lo") end
 if x<hi then else error("FIELD_hi") end
 error("FIELD_OK") end t(11,10,12) end
