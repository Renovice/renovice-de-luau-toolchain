function OnInit()
  local o = {}
  function o:m() return 7 end
  local a = o:m()
  GX = 5
  local b = GX
  if a == b then else error("x") end
end
