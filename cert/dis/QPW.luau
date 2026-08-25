function OnInit()
  local function t(a, b)
    local v = a ^ b
    error("QPW=" .. tostring(v))
  end
  t(2, 10)
end
