-- ground-truth case: ctrl_whiletrue
function f(n)
  local i = 0
  while true do i = i + 1; if i >= n then return i end end
end
