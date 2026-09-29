local trace = ""
local target = setmetatable({}, {__newindex = function(_, key, value)
    trace ..= "set:" .. key .. ":" .. value .. ";"
end})
local captures = setmetatable({}, {__index = function(_, index)
    trace ..= "get:" .. index .. ";"
    if index == 1 then return target end
    return function() trace ..= "call;" end
end})
local function update(value)
    local base = captures[1]
    base.Current = value
    base = captures[2]
    base()
end
update(7)
assert(trace == "get:1;set:Current:7;get:2;call;")
trace = ""
update(0)
assert(trace == "get:1;set:Current:0;get:2;call;")
local function retained(value)
    local base = captures[1]
    base.Current = value
    return base
end
trace = ""
assert(retained(5) == target)
assert(trace == "get:1;set:Current:5;")
print("index store fixture: 4 assertions passed")
