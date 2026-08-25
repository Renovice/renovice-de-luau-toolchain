-- ground-truth case: logic_guard
function f(t)
  return t and t.x and t.x.y
end
