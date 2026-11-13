F1 = function(a, b, q, c)
  local x = a and b.u and (IsNull(q) or c.Has(q)) or false
  return x
end
F2 = function(a, q)
  return IsNull(a) and (q:IsHub() or q:IsBoot()) and not q:IsA(a) and q:N() == 2 and q:IsA(b)
end
F3 = function(a, b)
  local y = a == 1 or b:Get() or 7
  return y
end
F4 = function(a, b, c)
  local z = (a < b and c:F()) or (b > 3 and c:G())
  print(z)
end
F5 = function(t, q)
  local w = t:S() ~= 0 or t:Name(q.region) or false
  return w
end
