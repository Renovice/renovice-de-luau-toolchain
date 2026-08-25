-- ground-truth case: func_method
local T = {}
T.__index = T
function T:get() return self.v end
function f(o) return o:get() end
