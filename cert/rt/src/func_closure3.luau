-- ground-truth case: func_closure3
function f(a, b, c)
  local function g() return a + b + c end
  return g()
end
