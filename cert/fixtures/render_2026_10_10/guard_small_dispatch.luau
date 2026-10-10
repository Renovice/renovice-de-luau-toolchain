-- Regression fixture (render campaign 2026-10-10, RENDER TRANSACTIONS + SMALL GUARD DISPATCH),
-- compiled at -O2. `if flag and o:IsActive() or not o:IsDeactivating() then EFFECT end` inside a
-- loop: the operands are calls, so the test is three blocks where the IsActive block reaches the
-- effect directly and the IsDeactivating block is shared (44.1.1 SonicEarthQuake p12, EpisodeStatus
-- p7 class). The guard renderer claimed blocks before its proof failed and the whole prototype was
-- refused (GUARD_CHAIN_NO_BOUNDARY_EDGE); the legacy region emitter then rendered it and cannot
-- spell the inlined two-exit search loop (#80). Fixed: the failed guard candidate is rolled back and
-- the three-block guard is spelled by the exact selector dispatcher.
-- Opt-outs: RENOVICE_NO_CFG_GUARD_TRANSACTION, RENOVICE_NO_CFG_SMALL_GUARD_DISPATCH.
local Kinds = { "A", "B" }
local function IsSpecial(obj)
    for _, k in pairs(Kinds) do
        if obj:IsA(k) then
            return true
        end
    end
    return false
end
local o = { active = false, deact = false }
function o:IsActive() print("IsActive") return self.active end
function o:IsDeactivating() print("IsDeactivating") return self.deact end
function F(obj, flag, list)
    if obj ~= nil and IsSpecial(obj) then
        print("special", obj.n)
    end
    local r = 0
    local i = 0
    while i < #list do
        i = i + 1
        if list[i] > 0 then
            if flag and o:IsActive() or not o:IsDeactivating() then
                r = r + list[i]
                print("effect", r)
            end
            o.active = not o.active
        end
        print("step", i, r)
    end
    return r
end
function IsAImpl(s, k)
    print("IsA", s.n, k)
    return k == s.hit
end
print(F({ n = 1, hit = "B", IsA = IsAImpl }, true, { 1, 2 }))
print(F({ n = 2, hit = "Z", IsA = IsAImpl }, false, { 3, -1, 4, 5 }))
o.deact = true
print(F(nil, true, { 5 }))
