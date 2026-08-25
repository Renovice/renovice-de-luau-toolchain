function OnInit()
 local y
 local ok2 = pcall(function() y = nil end)
 if y ~= nil then print("T") else print("F") end
end
