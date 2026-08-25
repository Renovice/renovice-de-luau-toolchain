-- ground-truth case: ctrl_fornum_mut
function f(n)
  local s = 0
  for i = 1, n do
    i = i + 100
    s = s + i
  end
  return s
end
