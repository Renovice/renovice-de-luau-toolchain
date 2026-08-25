function ActivateAbility(ability, avatar, rank, target)
    avatar:GetPosition()
    local ok, message = pcall(function()
        target:GetPosition()
        error("mock native failure")
    end)
    avatar:GetRotation()
    return ok, message ~= nil, rank
end

function DeactivateAbility(ability, avatar, effect)
    local ok = pcall(function()
        effect:GetType()
        error("mock native failure")
    end)
    effect:Destroy()
    return ok
end
