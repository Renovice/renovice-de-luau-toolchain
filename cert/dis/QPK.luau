function OnInit()
  local function t(a) local v = a ^ 10 error("QPK=" .. tostring(v)) end
  t(2)
end
