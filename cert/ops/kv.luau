function OnInit()
  local function t(x, five, ninety, two, twenty)
    if x - 5   == five   then else error("SUBK")  end
    if 100 - x == ninety then else error("SUBRK") end
    if x / 5   == two    then else error("DIVK")  end
    if x * 2   == twenty then else error("MULK")  end
    error("KV_OK")
  end
  t(10, 5, 90, 2, 20)
end
