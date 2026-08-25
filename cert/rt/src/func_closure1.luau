-- ground-truth case: func_closure1
function f(a)
  local function g() return a end
  return g()
end
