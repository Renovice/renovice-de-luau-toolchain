-- Synthetic Luau value/arity checks, including truthy zero, empty string, and table identity.
local function choose(value)
    local scratch = value
    if not scratch then scratch = 0.06 end
    local result = scratch
    return result
end
local function captured(value)
    local scratch = value
    local read = function() return scratch end
    if not scratch then scratch = 0.06 end
    local result = scratch
    scratch = 99
    return result, read()
end
local token = {}
local cases = {
    {expected = 0.06}, {value = false, expected = 0.06},
    {value = true, expected = true}, {value = 0, expected = 0},
    {value = -1, expected = -1}, {value = "", expected = ""},
    {value = token, expected = token}, {value = 0.5, expected = 0.5},
}
local assertions = 0
for _, case in ipairs(cases) do
    assert(choose(case.value) == case.expected)
    local result, after = captured(case.value)
    assert(result == case.expected)
    assert(after == 99)
    assertions += 3
end
local function literalTail(category, wanted)
    local value = 3
    if category == 9 then
        for index = 1, value do
            if index == wanted then return true, false end
        end
    else
        return true, true
    end
    value = false
    return value
end
for _, case in ipairs({{9, 2, 2, true, false}, {9, 4, 1, false}, {10, 2, 2, true, true}}) do
    local result = table.pack(literalTail(case[1], case[2]))
    assert(result.n == case[3])
    assert(result[1] == case[4])
    assert(result[2] == case[5])
    assertions += 3
end
assert(assertions == 33)
print("value temporary fixture: 33 assertions passed")
