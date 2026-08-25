-- ground-truth case: func_vararg_fwd
local function g(...) return ... end
function f(...) return g(...) end
