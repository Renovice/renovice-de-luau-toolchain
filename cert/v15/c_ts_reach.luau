function OnInit()
  local function probe(src)
    local dst = 111
    local mark = 0
    dst = src
    mark = 77
    return dst, mark
  end
  error("V15_REACH loaded")   -- fires before probe() is ever entered
end
