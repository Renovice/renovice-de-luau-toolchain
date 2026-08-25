-- ground-truth case: ctrl_forpairs
function f(t)
  local s = 0
  for k, v in pairs(t) do s = s + v end
  return s
end
