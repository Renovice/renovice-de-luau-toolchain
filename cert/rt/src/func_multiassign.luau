-- ground-truth case: func_multiassign
function f(a)
  local x, y, z = a, a + 1, a + 2
  return x + y + z
end
