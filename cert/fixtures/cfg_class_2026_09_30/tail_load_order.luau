-- Regression fixture (2026-09-30) for the cfg-identity gate's pure-materialization sinking (S2).
-- `local t = 0` has no reader in its block; stock ends that block with the last CALL, while the
-- rebuild ends it with the MOVE copy of the CALL result. The old sinking rule placed the load
-- before the last CALL in one case and after it in the other, which reported LOAD -> CALL for two
-- identical programs (44.0.2: PostFade, CaptureShipDoor, ObjectSway, TauDroneEffects ...).
local function Fade(obj, from, to, duration)
    local t = 0
    local info = obj:GetRegionMgr():GetLevelInfo()
    while t < duration do
        t = t + 0.5
        info:SetFade(from + t)
    end
    info:SetFade(to)
end

local region = {}
function region:GetLevelInfo()
    return { SetFade = function(_, value) print("fade", value) end }
end
local owner = {}
function owner:GetRegionMgr()
    return region
end
Fade(owner, 1, 9, 2)
