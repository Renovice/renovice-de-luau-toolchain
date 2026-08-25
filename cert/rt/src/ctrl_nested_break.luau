-- ground-truth case: ctrl_nested_break
function f(n)
  local s = 0
  for i = 1, n do
    for j = 1, n do
      if j > 2 then break end
      s = s + j
    end
    if i > 3 then break end
    s = s + i
  end
  return s
end
