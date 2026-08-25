-- ground-truth case: mix_accum
function f(t)
  local out = {}
  for i, v in ipairs(t) do out[#out + 1] = v * 2 end
  return out
end
