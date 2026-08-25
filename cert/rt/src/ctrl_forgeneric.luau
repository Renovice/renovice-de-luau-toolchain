-- ground-truth case: ctrl_forgeneric
local function iter(s, i) i = i + 1; if i <= 3 then return i, i * 10 end end
function f()
  local s = 0
  for i, v in iter, nil, 0 do s = s + v end
  return s
end
