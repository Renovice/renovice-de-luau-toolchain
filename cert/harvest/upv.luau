-- Isolate: does a closure's assignment to a captured local propagate, and does `~= nil` on it work?
function OnInit()
  local x                      -- starts nil, assigned INSIDE a closure
  local ok = pcall(function() x = 42 end)
  print("UPV:pcall=" .. tostring(ok) .. " x=" .. tostring(x) .. " type=" .. type(x))
  if x ~= nil then print("UPV:neq_nil=TRUE") else print("UPV:neq_nil=FALSE") end
  if x == nil then print("UPV:eq_nil=TRUE") else print("UPV:eq_nil=FALSE") end
  print("UPV:reached_after_ifs")
  local y
  local ok2 = pcall(function() y = nil end)
  if y ~= nil then print("UPV:y_neq_nil=TRUE") else print("UPV:y_neq_nil=FALSE") end
  print("UPV:end")
  error("UPV_DONE")
end
