function OnInit()
  local function probe(src)
    local dst = 111
    local mark = 0
    dst = src
    mark = 77
    return dst, mark
  end
  local d1, m1 = probe(7)
  local d2, m2 = probe(false)
  error("V15_CTRL t_dst=" .. tostring(d1) .. " t_mark=" .. tostring(m1) ..
        " f_dst=" .. tostring(d2) .. " f_mark=" .. tostring(m2))
end
