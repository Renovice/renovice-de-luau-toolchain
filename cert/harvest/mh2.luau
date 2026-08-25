-- Every step pcall'd + reported. Determines whether a live userdata object's methods are enumerable.
function OnInit()
  local av
  local ok1 = pcall(function() av = gRegion:GetLocalPlayerAvatar() end)
  print("MH2:avatar ok=" .. tostring(ok1) .. " type=" .. type(av))
  local mt
  local ok2 = pcall(function() mt = getmetatable(av) end)
  print("MH2:getmetatable ok=" .. tostring(ok2) .. " type=" .. type(mt))
  local ix
  local ok3 = pcall(function() ix = rawget(mt, "__index") end)
  print("MH2:rawget__index ok=" .. tostring(ok3) .. " type=" .. type(ix))
  local n = 0
  local ok4 = pcall(function() for k, v in pairs(ix) do n = n + 1 end end)
  print("MH2:pairs(__index) ok=" .. tostring(ok4) .. " count=" .. n)
  local n2 = 0
  local ok5 = pcall(function() for k, v in pairs(mt) do n2 = n2 + 1 end end)
  print("MH2:pairs(mt) ok=" .. tostring(ok5) .. " count=" .. n2)
  -- membership oracle: can we probe a KNOWN method by name on the live object?
  local f
  local ok6 = pcall(function() f = av.GetHealth end)
  print("MH2:av.GetHealth ok=" .. tostring(ok6) .. " type=" .. type(f))
  local g
  local ok7 = pcall(function() g = av.InventoryControl end)
  print("MH2:av.InventoryControl ok=" .. tostring(ok7) .. " type=" .. type(g))
  error("MH2_DONE")
end
