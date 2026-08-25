function OnInit()
  local c
  local ok = pcall(function() c = nil end)
  local r = "?"
  if c ~= nil then r = "WRONG" else r = "ok" end
  error("SC4=" .. r)
end
