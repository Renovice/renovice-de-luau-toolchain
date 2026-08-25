-- ground-truth case: func_nested2
function f(a)
  local function g()
    local function h() return a end
    return h()
  end
  return g()
end
