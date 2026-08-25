-- ground-truth case: ctrl_continue
function f(n)
  local s = 0
  for i = 1, n do if i == 2 then continue end s = s + i end
  return s
end
