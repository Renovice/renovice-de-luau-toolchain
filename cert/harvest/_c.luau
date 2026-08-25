function OnInit()
 local c
 local ok = pcall(function() c = nil end)
 if c ~= nil then print("W") else print("ok") end
end
