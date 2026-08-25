-- ground-truth case: ctrl_fornum_st
function f(n)
  local s = 0
  for i = 1, n, 2 do s = s + i end
  return s
end
