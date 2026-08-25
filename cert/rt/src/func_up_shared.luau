-- ground-truth case: func_up_shared
function f(a, b)
  local g1 = function() return a + b end
  local g2 = function() return a - b end
  local g3 = function() return a * b end
  return g1() + g2() + g3()
end
