local active = nil
local elapsed = 0

local function setActive(value)
    active = value
    return function(delta)
        elapsed += delta
        if active ~= nil then
            active:SetHealth(elapsed)
        end
        return elapsed, active
    end
end

function ActivateAbility(ability, avatar, rank, target)
    local effect = gRegion:CreateEntity("type:AbilityFx", avatar:GetPosition(), ZERO_ROTATION, avatar)
    local updater = setActive(effect)
    local first, current = updater(rank / 10)
    return first, current
end

function Update(ability, avatar, deltaTime, target)
    if active == nil then
        return false, elapsed
    end
    elapsed += deltaTime
    active:DamageDD(target)
    return true, elapsed, active
end

function DeactivateAbility(ability, avatar, effect)
    local previous = active
    active = nil
    elapsed = 0
    if not IsNull(previous) then
        previous:Destroy()
    end
    return previous
end
