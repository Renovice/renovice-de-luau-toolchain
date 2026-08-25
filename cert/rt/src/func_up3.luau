-- ground-truth case: func_up3
function f(a, b, c)
  local g = function() return a + b + c end
  return g()
end
