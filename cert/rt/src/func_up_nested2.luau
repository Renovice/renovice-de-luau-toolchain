-- ground-truth case: func_up_nested2
function f(a, b)
  local mid = function(c)
    local inner = function() return a + b + c end
    return inner()
  end
  return mid(10)
end
