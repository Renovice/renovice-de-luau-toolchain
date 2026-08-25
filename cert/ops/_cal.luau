function OnInit()
 local function t(three,five)
  local a=(three<three) local b=(three<five) local c=(five<three)
  if a==false then else error("LTb") end
  if b==true then else error("LTt") end
  if c==false then else error("LTf") end
  error("LT23_OK")
 end
 t(3,5)
end
