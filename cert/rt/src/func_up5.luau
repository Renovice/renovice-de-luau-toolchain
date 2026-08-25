-- ground-truth case: func_up5
function f(a, b, c, d)
  local e = a * 2
  local g = function() return a + b + c + d + e end
  return g()
end
