-- Minimal: is gRegion reachable, and does the object chain work? No tables, no closures over tables.
function OnInit()
  print("MH1:start")
  local r = gRegion
  print("MH1:gRegion=" .. tostring(r ~= nil) .. " type=" .. type(r))
  local okA, av = pcall(function() return gRegion:GetLocalPlayerAvatar() end)
  print("MH1:avatarCall=" .. tostring(okA) .. " got=" .. tostring(av ~= nil))
  if av ~= nil then
    local mt = getmetatable(av)
    print("MH1:avatarMT=" .. type(mt))
    if type(mt) == "table" then
      local ix = rawget(mt, "__index")
      print("MH1:__index=" .. type(ix))
      local n = 0
      pcall(function() for k, v in pairs(ix) do n = n + 1 end end)
      print("MH1:indexKeys=" .. n)
      local n2 = 0
      pcall(function() for k, v in pairs(mt) do n2 = n2 + 1 end end)
      print("MH1:mtKeys=" .. n2)
    end
    local n3 = 0
    pcall(function() for k, v in pairs(av) do n3 = n3 + 1 end end)
    print("MH1:avatarKeys=" .. n3)
  end
  error("MH1_DONE")
end
