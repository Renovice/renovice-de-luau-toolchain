local function check(enabled, absent, entries, log)
    for _, value in ipairs({"prefix"}) do table.insert(log, value) end
    if enabled then
        if absent or entries.key == nil then
            table.insert(log, "missing")
            return false
        end
    end
    table.insert(log, "complete")
    return true
end
local cases = {
    {false, false, false, true, "prefix;complete", 0},
    {false, true, false, true, "prefix;complete", 0},
    {true, true, false, false, "prefix;missing", 0},
    {true, false, false, false, "prefix;missing", 1},
    {true, false, true, true, "prefix;complete", 1},
}
for _, case in ipairs(cases) do
    local reads = 0
    local entries = setmetatable({}, {__index = function()
        reads += 1
        if case[3] then return 7 end
        return nil
    end})
    local log = {}
    assert(check(case[1], case[2], entries, log) == case[4])
    assert(table.concat(log, ";") == case[5])
    assert(reads == case[6])
end
print("shared terminal effect fixture: 15 assertions passed")
