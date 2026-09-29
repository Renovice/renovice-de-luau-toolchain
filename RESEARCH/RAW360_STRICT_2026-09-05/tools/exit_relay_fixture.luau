-- Synthetic runtime witness for many-to-one loop exit relays and distinguishing reads.
-- Expected results come from the stated route behavior, independently of recovered text.
local function route(mode, limit)
    local destination = -1
    local source = -1
    local count = 0
    while true do
        if count >= limit then source = 5 break end
        count += 1
        if mode == 1 then source = 7 break end
        if mode == 2 then source = 9 break end
    end
    if source == 5 then destination = 13
    elseif source == 7 then destination = 8
    elseif source == 9 then destination = 8 end
    return destination, count
end

local function observedRoute(mode, limit)
    local destination = -1
    local source = -1
    local count = 0
    while true do
        if count >= limit then source = 5 break end
        count += 1
        if mode == 1 then source = 7 break end
        if mode == 2 then source = 9 break end
    end
    local observed = source
    if source == 5 then destination = 13
    elseif source == 7 then destination = 8
    elseif source == 9 then destination = 8 end
    return destination, count, observed
end

local function capturedRoute(mode, limit)
    local destination = -1
    local source = -1
    local observe = function() return source end
    local count = 0
    while true do
        if count >= limit then source = 5 break end
        count += 1
        if mode == 1 then source = 7 break end
        if mode == 2 then source = 9 break end
    end
    if source == 5 then destination = 13
    elseif source == 7 then destination = 8
    elseif source == 9 then destination = 8 end
    return destination, count, observe()
end

local cases = {
    {0, 0, 13, 0, 5}, {1, 0, 13, 0, 5}, {2, 0, 13, 0, 5},
    {0, 3, 13, 3, 5}, {1, 3, 8, 1, 7}, {2, 3, 8, 1, 9},
}
local assertions = 0
for _, case in ipairs(cases) do
    local value, count = route(case[1], case[2])
    assert(value == case[3]); assert(count == case[4])
    local observed
    value, count, observed = observedRoute(case[1], case[2])
    assert(value == case[3]); assert(count == case[4]); assert(observed == case[5])
    value, count, observed = capturedRoute(case[1], case[2])
    assert(value == case[3]); assert(count == case[4]); assert(observed == case[5])
    assertions += 8
end

local calls = 0
local function predicate(value) calls += 1 return value end
local function emptyElse(flag, value)
    if predicate(flag) then
        if value then return 7 end
    else
        do return end
    end
    do return end
end
for _, case in ipairs({{false, false}, {false, true}, {true, false}, {true, true}}) do
    local before = calls
    local value = emptyElse(case[1], case[2])
    if case[1] and case[2] then assert(value == 7) else assert(value == nil) end
    assert(calls == before + 1)
    assertions += 2
end
assert(assertions == 56)
print("exit relay fixture: 56 assertions passed")
