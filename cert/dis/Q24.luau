function OnInit()
  local function t(three, ten)
    local v = ten + 3
    error("Q24=" .. tostring(v))
  end
  t(3, 10)
end
