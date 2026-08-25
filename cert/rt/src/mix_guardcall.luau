-- ground-truth case: mix_guardcall
function f(o)
  if o and o.fn then return o:fn(1, 2) end
  return nil
end
