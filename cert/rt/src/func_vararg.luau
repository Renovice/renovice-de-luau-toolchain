-- ground-truth case: func_vararg
function f(...)
  local a, b = ...
  return a, b, select('#', ...)
end
