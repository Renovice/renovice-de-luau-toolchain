function OnInit() local function t(n,lo,hi) local sum=0
 for i=1,n do sum=sum+i end
 if sum>lo then else error("FORN_lo") end
 if sum<hi then else error("FORN_hi") end
 error("FORN_OK") end t(10,54,56) end
