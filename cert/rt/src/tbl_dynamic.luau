-- ground-truth case: tbl_dynamic
function f(a, b)
  return {a, b, [a] = b}
end
