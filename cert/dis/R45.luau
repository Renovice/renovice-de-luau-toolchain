function OnInit()
  local function t(three, ten)
    local v = ten % three
    error("R45=" .. tostring(v))
  end
  t(3, 10)
end
