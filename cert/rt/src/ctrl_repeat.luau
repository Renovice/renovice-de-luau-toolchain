-- ground-truth case: ctrl_repeat
function f(n)
  local i = 0
  repeat i = i + 1 until i >= n
  return i
end
