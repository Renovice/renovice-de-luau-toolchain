-- Exercise an interior exit after a header diamond, including zero iterations.
local function interiorExit(limit)
    local index = 1
    local total = 0
    while true do
        local label = "item"
        if index > 1 then
            label = label .. index
        end
        if index > limit then break end
        total = total + #label
        index = index + 1
    end
    return total
end

-- The for-loop exhaustion and an early break share a continuation reached
-- through a jump-only block at the end of an enclosing one-shot repeat.
local function squadHostValue(entries, inSquad, fallback)
    local value = false
    repeat
        if inSquad then
            for index = 1, #entries do
                if not entries[index].host then continue end
                value = entries[index].value
                break
            end
            break
        end
        value = fallback
    until true
    return value
end

assert(interiorExit(0) == 0)
assert(interiorExit(1) == 4)
assert(interiorExit(3) == 14)
assert(squadHostValue({}, true, 99) == false)
assert(squadHostValue({{host = false, value = 7}}, true, 99) == false)
assert(squadHostValue({{host = true, value = 7}}, true, 99) == 7)
assert(squadHostValue({{host = false, value = 7}, {host = true, value = 8}}, true, 99) == 8)
assert(squadHostValue({{host = true, value = false}}, true, 99) == false)
assert(squadHostValue({}, false, 99) == 99)
print("loop exit fixture: 9 assertions passed")
