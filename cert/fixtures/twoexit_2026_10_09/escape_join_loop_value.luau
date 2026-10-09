-- Regression fixture (2026-10-09, DEFECTS #76): 44.1.1 FishingLib p1 shape, compiled at -O2. Three
-- inlined helpers in sequence, each `for _, v in pairs(t) do if obj:IsA(v) then return v end end
-- return nil`: the found arm READS THE LOOP VARIABLE and jumps past the exhaustion default. Printing
-- the arm after the loop (where `v` is out of scope) returned nil for every lookup; the escape-join
-- rendering keeps the arm inside the loop. Opt-out: RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN.
local A, B, C = { "a1", "a2" }, { "b1", "b2" }, { "c1", "c2" }
local function Find(obj, t)
    for _, v in pairs(t) do
        if obj:IsA(v) then
            return v
        end
    end
    return nil
end
function Rarity(obj)
    local r = Find(obj, A)
    if r ~= nil then
        return r, "common"
    end
    r = Find(obj, B)
    if r ~= nil then
        return r, "rare"
    end
    r = Find(obj, C)
    if r ~= nil then
        return r, "legendary"
    end
    return nil, nil
end
function IsAImpl(s, t) return t == s.hit end
print(Rarity({ hit = "a2", IsA = IsAImpl }))
print(Rarity({ hit = "b1", IsA = IsAImpl }))
print(Rarity({ hit = "c2", IsA = IsAImpl }))
print(Rarity({ hit = "zz", IsA = IsAImpl }))
