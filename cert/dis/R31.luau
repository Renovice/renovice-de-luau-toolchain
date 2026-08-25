function OnInit()
  local function t(three, ten)
    local v = ten + 4
    error("R31=" .. tostring(v))
  end
  t(3, 10)
end
