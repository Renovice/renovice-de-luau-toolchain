-- Regression fixture (render campaign 2026-10-10, INTERIOR WHILE ARMS), compiled at -O2. A `while
-- true` whose header test has both successors inside the loop and which leaves through a statement
-- `break` arm and a `return` arm (44.1.1 ToxinInoculation p8, ZarimanCorruptionMission p32 class).
-- Several exits made the CFG renderer refuse it at setup (INTERIOR_WHILE_EXIT_COUNT); the legacy
-- region emitter then rendered the prototype and cannot spell its inlined two-exit search loop (#80).
-- Opt-out: RENOVICE_NO_CFG_INTERIOR_WHILE_ARMS.
local Kinds = { "A", "B" }
local function IsSpecial(obj)
    for _, k in pairs(Kinds) do
        if obj:IsA(k) then
            return true
        end
    end
    return false
end
function Scan(obj, t, stop)
    if obj ~= nil and IsSpecial(obj) then
        print("special", obj.n)
    end
    local i = 0
    local found = nil
    while true do
        if t[i + 1] == nil then
            print("tail", i)
        else
            print("item", t[i + 1])
        end
        i = i + 1
        if t[i] == stop then
            found = i
            print("found", i)
            break
        end
        if i > #t then
            print("give up", i)
            return -1
        end
    end
    print("after", found)
    return found
end
function IsAImpl(s, k)
    print("IsA", s.n, k)
    return k == s.hit
end
print(Scan({ n = 1, hit = "B", IsA = IsAImpl }, { 4, 5, 6 }, 5))
print(Scan({ n = 2, hit = "Z", IsA = IsAImpl }, { 4, 5, 6 }, 9))
