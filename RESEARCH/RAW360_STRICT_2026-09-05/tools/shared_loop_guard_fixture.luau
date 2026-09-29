local function scan(first, second, items, log)
    local count = 0
    for _, marker in ipairs({1}) do
        local function a() table.insert(log, "a"); return first end
        local function b() table.insert(log, "b"); return second end
        if a() or b() then
            for _, value in ipairs(items) do
                table.insert(log, "item" .. value)
                count += value
            end
        else
            table.insert(log, "other")
        end
        table.insert(log, "tail")
        count += marker
    end
    return count
end
local cases = {
    {true, false, {}, 1, "a;tail"},
    {true, true, {2,3}, 6, "a;item2;item3;tail"},
    {false, true, {}, 1, "a;b;tail"},
    {false, true, {2,3}, 6, "a;b;item2;item3;tail"},
    {false, false, {}, 1, "a;b;other;tail"},
    {false, false, {2,3}, 1, "a;b;other;tail"},
}
for _, case in ipairs(cases) do
    local log = {}
    assert(scan(case[1], case[2], case[3], log) == case[4])
    assert(table.concat(log, ";") == case[5])
end
print("shared loop guard fixture: 12 assertions passed")
