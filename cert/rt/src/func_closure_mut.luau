-- ground-truth case: func_closure_mut
function f(a)
  local n = a
  local function g() n = n + 1; return n end
  g(); return g()
end
