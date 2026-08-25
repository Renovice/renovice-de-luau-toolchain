-- ground-truth case: func_recurse
local function fact(n) if n <= 1 then return 1 end return n * fact(n - 1) end
function f(n) return fact(n) end
