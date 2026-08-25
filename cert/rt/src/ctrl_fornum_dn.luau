-- ground-truth case: ctrl_fornum_dn
function f(n)
  local s = 0
  for i = n, 1, -1 do s = s + i end
  return s
end
