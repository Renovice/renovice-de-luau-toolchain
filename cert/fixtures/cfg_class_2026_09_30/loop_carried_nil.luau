-- Regression fixture (2026-09-30, DEFECTS #41): `local owner = nil` before a polling loop whose
-- body assigns owner later in the text. The flat function-local declaration dropped the entry
-- LOADNIL and the implicit-nil canonicalizer placed `owner = nil` at the first textual read, INSIDE
-- the loop, resetting the variable every iteration (an extra "bind" is printed). cfg-identity
-- cannot see it (LOADNIL is epsilon); luau.exe behavior can.
local sleeps = 0
local function Sleep(seconds)
    sleeps = sleeps + 1
    print("sleep", seconds, sleeps)
    if sleeps >= 6 then error("stop", 0) end
end
local function IsNull(value)
    return value == nil
end
local owners = { false, "a", "a", "b" }
local function GetManager()
    local owner = owners[sleeps + 1]
    if owner == false then return nil end
    return { owner = owner }
end

local function Watch(state)
    local owner = nil
    while true do
        if IsNull(owner) then
            local manager = GetManager()
            if IsNull(manager) then
                owner = nil
            else
                owner = manager.owner
            end
        end
        if not IsNull(owner) then
            if IsNull(state[1]) or state[1] ~= owner then
                state[1] = owner
                print("bind", owner)
            end
        end
        Sleep(0)
    end
end

print("result", pcall(Watch, {}))
