-- ground-truth case: ctrl_break
function f(n)
  local s = 0
  for i = 1, n do if i > 3 then break end s = s + i end
  return s
end
