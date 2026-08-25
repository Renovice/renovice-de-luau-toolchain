function OnInit()
  local c
  local ok = pcall(function() c = nil end)
  local r1 = "?" if c ~= nil then r1 = "WRONG" else r1 = "ok" end
  local d = 5
  local ok2 = pcall(function() d = 7 end)
  local r2 = "?" if d ~= nil then r2 = "ok" else r2 = "WRONG" end
  local r3 = "?" if d == 7 then r3 = "ok" else r3 = "WRONG" end
  local e
  local r4 = "?" if e ~= nil then r4 = "WRONG" else r4 = "ok" end
  error("FIX cap_nil=" .. r1 .. " cap_num_neqnil=" .. r2 .. " cap_num_eq7=" .. r3 .. " nocap=" .. r4)
end
