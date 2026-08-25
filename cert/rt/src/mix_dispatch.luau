-- ground-truth case: mix_dispatch
function f(t, k)
  local h = t[k]
  if h then return h(t) end
  return nil
end
