-- ground-truth case: ctrl_nested
function f(n)
  local s = 0
  for i = 1, n do for j = 1, n do s = s + i * j end end
  return s
end
