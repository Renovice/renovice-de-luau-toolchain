F = function(a, b, q, c)
  local x = a and b.u and (IsNull(q) or c.Has(q)) or false
  return x
end
