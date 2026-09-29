local function scan(items, log)
    for _, item in ipairs(items) do
        if item.a then
            if item.b then return "early" end
        else
            if item.c then return "early" end
        end
        table.insert(log, item.id)
    end
    return "complete"
end
local cases = {
    {false, false, false, "complete", 1},
    {false, false, true, "early", 0},
    {false, true, false, "complete", 1},
    {false, true, true, "early", 0},
    {true, false, false, "complete", 1},
    {true, false, true, "complete", 1},
    {true, true, false, "early", 0},
    {true, true, true, "early", 0},
}
for _, case in ipairs(cases) do
    local log = {}
    local item = {a=case[1], b=case[2], c=case[3], id="item"}
    assert(scan({item}, log) == case[4])
    assert(#log == case[5])
    assert(log[1] == (case[5] == 1 and "item" or nil))
end
local log = {}
assert(scan({}, log) == "complete")
assert(#log == 0)
assert(scan({{id="first"}, {id="second", a=true, b=true}}, log) == "early")
assert(#log == 1)
assert(log[1] == "first")
print("effectful latch fixture: 29 assertions passed")
