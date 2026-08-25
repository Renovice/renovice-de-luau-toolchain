-- ground-truth case: ctrl_while
function f(n)
  local s = 0
  local i = 0
  while i < n do i = i + 1; s = s + i end
  return s
end
