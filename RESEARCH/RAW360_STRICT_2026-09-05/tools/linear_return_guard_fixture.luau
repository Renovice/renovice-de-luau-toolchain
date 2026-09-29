local function probe(enabled, first, second, log)
    if enabled then
        repeat
            table.insert(log, "first")
            if first then break end
            table.insert(log, "second")
            if second then break end
            return "hit", false
        until true
    end
    table.insert(log, "tail")
    return "tail", nil
end
local cases = {
    {false, false, false, "tail", "tail"},
    {false, false, true, "tail", "tail"},
    {false, true, false, "tail", "tail"},
    {false, true, true, "tail", "tail"},
    {true, false, false, "hit", "first;second", false},
    {true, false, true, "tail", "first;second;tail"},
    {true, true, false, "tail", "first;tail"},
    {true, true, true, "tail", "first;tail"},
}
for _, case in ipairs(cases) do
    local log = {}
    local result = table.pack(probe(case[1], case[2], case[3], log))
    assert(result.n == 2)
    assert(result[1] == case[4])
    assert(result[2] == case[6])
    assert(table.concat(log, ";") == case[5])
end
print("linear return guard fixture: 32 assertions passed")
