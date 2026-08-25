function OnInit()
  local function t(three, fls)
    local v = fls * three
    error("Q51=" .. tostring(v))
  end
  t(3, false)
end
