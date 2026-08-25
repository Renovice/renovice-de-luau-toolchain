-- ground-truth case: tbl_setn_mix
function f(t, v)
  t[1] = v
  t.x = v
  t[v] = v
end
