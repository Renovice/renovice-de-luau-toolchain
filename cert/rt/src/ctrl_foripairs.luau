-- ground-truth case: ctrl_foripairs
function f(t)
  local s = 0
  for i, v in ipairs(t) do s = s + v end
  return s
end
