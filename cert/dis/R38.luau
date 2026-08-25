function OnInit()
  local function t(three, ten)
    local v = ten + 4
    error("R38=" .. tostring(v))
  end
  t(3, 10)
end
