-- ground-truth case: func_callargs
function f(g, a, b)
  return g(), g(a), g(a, b)
end
