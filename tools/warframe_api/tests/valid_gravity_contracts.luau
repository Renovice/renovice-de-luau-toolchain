-- Exact source-visible call shapes established by stock corpus evidence and
-- the 2026-08-27 controlled local Octavia float test.

local FLOAT_KEY = Symbol("WF_API_GRAVITY_CONTRACT_TEST")

return function()
    local avatar = gRegion:GetLocalPlayerAvatar()
    if IsNull(avatar) then
        return
    end

    avatar:AddGravityMultiplier(FLOAT_KEY, 0, -1)
    avatar:RemoveGravityMultiplier(FLOAT_KEY)
end
