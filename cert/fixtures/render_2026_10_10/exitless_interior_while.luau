-- Regression fixture (render campaign 2026-10-10, EXITLESS INTERIOR WHILE), compiled at -O2. A
-- `while true do if c then A else B end ... end` that never leaves (its only way out is an error):
-- the header test has both successors inside the loop and the loop has no exit edge at all
-- (44.1.1 Vault p2, SpawnSpectres p1, Intel p20 class: 22 refused prototypes). The CFG renderer
-- refused it at setup (INTERIOR_WHILE_EXIT_COUNT) and the legacy region emitter, which cannot spell
-- the inlined two-exit search loop of the same function (#80), rendered the prototype.
-- Opt-out: RENOVICE_NO_CFG_EXITLESS_WHILE.
local Kinds = { "A", "B" }
local function IsSpecial(obj)
    for _, k in pairs(Kinds) do
        if obj:IsA(k) then
            return true
        end
    end
    return false
end
function Pump(obj, limit)
    if obj ~= nil and IsSpecial(obj) then
        print("special", obj.n)
    end
    local n = 0
    while true do
        if n % 3 == 0 then
            print("tick", n)
        else
            print("tock", n)
        end
        n = n + 1
        if n > limit then
            error("stop " .. n, 0)
        end
    end
end
function IsAImpl(s, k)
    print("IsA", s.n, k)
    return k == s.hit
end
print(pcall(Pump, { n = 1, hit = "B", IsA = IsAImpl }, 4))
print(pcall(Pump, { n = 2, hit = "Z", IsA = IsAImpl }, 1))
