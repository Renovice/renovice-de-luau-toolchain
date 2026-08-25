function OnInit()
  local ok = pcall(function() print("PRINTPROBE_LINE") end)
  error("PRINTOK=" .. tostring(ok))
end
