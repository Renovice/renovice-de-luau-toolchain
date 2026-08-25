-- ground-truth case: func_multiarity
function f(a)
  local z0 = function() return 0 end
  local z1 = function(p) return p end
  local z2 = function(p, q) return p + q end
  local z3 = function(p, q, r) return p + q + r end
  if a == 0 then return z0() end
  if a == 1 then return z1(7) end
  if a == 2 then return z2(3, 4) end
  return z3(1, 2, 3)
end
