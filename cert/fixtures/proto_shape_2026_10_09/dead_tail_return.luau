-- Dead tail after a RETURN: `repeat return ... until true` is a single RETURN that the compiler does
-- not treat as a terminator, so the statements after it are compiled but unreachable.
local function Check(flag)
    if flag then
        print("flag set")
        return 1
    end
    repeat
        return 2
    until true
    print("unreachable", flag)
    local late = function()
        return "late closure"
    end
    return late
end
print(Check(true), Check(false))
