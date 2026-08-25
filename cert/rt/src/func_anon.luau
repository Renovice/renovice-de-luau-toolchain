-- ground-truth case: func_anon
function f(a)
  local g = function(x) return x * 2 end
  return g(a)
end
