local function forward(owner, ...)
    owner:DamageDD(...)
    return select("#", ...), ...
end

local function choose(condition, ...)
    if condition then
        return ...
    end
    return nil, select("#", ...)
end

function ActivateAbility(ability, avatar, rank, target)
    local count, first, second, third = forward(mOwner, ability:GetType(), rank, target)
    return count, first, second, third
end

function EvaluateAbility(ability, avatar, target)
    return choose(not target:IsKilled(), avatar:GetPosition(), target, ability:GetType())
end
