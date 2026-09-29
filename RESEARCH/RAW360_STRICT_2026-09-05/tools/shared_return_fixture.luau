-- Reduced control-flow witness derived from the LoadOutSelect shared tail.
-- This is a synthetic fixture, not a claim to recovered original variable names.
local function sharedReturn(first, second, entries, effects)
    local temporary, total
    repeat
        if first ~= nil then
            temporary = first:IsZero()
            if not temporary then break end
        end
        if second then break end
        temporary = nil
        return temporary
    until true
    total = 0
    for index = 1, #entries do
        temporary = entries[index]
        if temporary < 0 then continue end
        total = total + temporary
    end
    effects:Record(total)
    return total
end

local assertions = 0
local function check(firstKind, second, expected)
    local zeroCalls = 0
    local first = nil
    if firstKind ~= "absent" then
        first = {IsZero = function()
            zeroCalls = zeroCalls + 1
            return firstKind == "zero"
        end}
    end
    local recorded = {}
    local effects = {Record = function(self, value)
        table.insert(recorded, value)
    end}
    local result = sharedReturn(first, second, {3, -5, 7}, effects)
    assert(result == expected, firstKind .. "/" .. tostring(second) .. ": result")
    assert(#recorded == (expected == nil and 0 or 1), firstKind .. ": shared tail count")
    assert(recorded[1] == expected, firstKind .. ": shared tail value")
    assert(zeroCalls == (firstKind == "absent" and 0 or 1), firstKind .. ": method count")
    assertions = assertions + 4
end

check("absent", false, nil)
check("absent", true, 10)
check("zero", false, nil)
check("zero", true, 10)
check("nonzero", false, 10)
check("nonzero", true, 10)
print("shared return fixture: " .. assertions .. " assertions passed")
