-- Negated ordered comparisons are not their complementary relation for NaN,
-- and __lt/__le are separately observable operations. Expectations are literal.
local function less(a, b)
    if not (a < b) then return "no" end
    return "yes"
end
local function lessEqual(a, b)
    if not (a <= b) then return "no" end
    return "yes"
end
local cases = {
    {1, 2, "yes", "yes"}, {2, 1, "no", "no"},
    {1, 1, "no", "yes"}, {0/0, 1, "no", "no"},
    {1, 0/0, "no", "no"}, {0/0, 0/0, "no", "no"},
}
for _, case in ipairs(cases) do
    assert(less(case[1], case[2]) == case[3])
    assert(lessEqual(case[1], case[2]) == case[4])
end
local trace = ""
local mt = {
    __lt = function(a, b) trace ..= "lt:" .. a.id .. b.id .. ";"; return false end,
    __le = function(a, b) trace ..= "le:" .. a.id .. b.id .. ";"; return false end,
}
local a = setmetatable({id = "a"}, mt)
local b = setmetatable({id = "b"}, mt)
assert(less(a, b) == "no")
assert(trace == "lt:ab;")
trace = ""
assert(lessEqual(a, b) == "no")
assert(trace == "le:ab;")
print("ordered comparison fixture: 16 assertions passed")
