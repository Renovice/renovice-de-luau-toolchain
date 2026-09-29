-- Synthetic first-iteration loops and observable nested table-index evaluation.
local function firstPair(left, right)
    local a, b
    local calls = 0
    for index = 1, #left do
        calls += 1
        a = left[index]
        break
    end
    for index = 1, #right do
        calls += 1
        b = right[index]
        break
    end
    return a, b, calls
end
local cases = {
    {left = {}, right = {}, count = 0},
    {left = {7, 8}, right = {}, a = 7, count = 1},
    {left = {}, right = {9, 10}, b = 9, count = 1},
    {left = {3, 4}, right = {5, 6}, a = 3, b = 5, count = 2},
    {left = {false, true}, right = {0, 1}, a = false, b = 0, count = 2},
    {left = {"", "next"}, right = {false}, a = "", b = false, count = 2},
}
local assertions = 0
for _, case in ipairs(cases) do
    local result = table.pack(firstPair(case.left, case.right))
    assert(result.n == 3)
    assert(result[1] == case.a)
    assert(result[2] == case.b)
    assert(result[3] == case.count)
    assertions += 4
end
local trace = ""
local inner = setmetatable({}, {__index = function(_, key)
    trace ..= "inner:" .. key .. ";"
    return 42
end})
local outer = setmetatable({}, {__index = function(_, key)
    trace ..= "outer:" .. key .. ";"
    return inner
end})
local function nested()
    local base = outer[1]
    local result = base[2]
    return result
end
local function observed()
    local base = outer[1]
    local result = base[2]
    return result, base
end
trace = ""
assert(nested() == 42)
assert(trace == "outer:1;inner:2;")
trace = ""
local result, base = observed()
assert(result == 42)
assert(base == inner)
assert(trace == "outer:1;inner:2;")
assert(assertions == 24)
print("index and first loop fixture: 29 assertions passed")
