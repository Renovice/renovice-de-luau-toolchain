-- ground-truth case: ctrl_forgen_mut
function f(t)
  local s = 0
  for k, v in pairs(t) do
    v = v + 1
    s = s + v
  end
  return s
end
