function OnInit()
  local c
  local r = "?"
  if c ~= nil then r = "WRONG" else r = "ok" end
  error("SCn=" .. r)
end
