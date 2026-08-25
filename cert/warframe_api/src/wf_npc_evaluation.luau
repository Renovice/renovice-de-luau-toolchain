function NpcEvaluateAbility(ability, agent, target)
    local avatar = agent:GetAvatar()
    if IsNull(avatar) or target:IsKilled() then
        return 0
    end

    local distance = avatar:DistanceToEntity(target)
    local energy = avatar:InventoryControl():GetActivePowerSuit():GetEnergy()
    local cost = ability:GetActivationEnergyCost()
    if distance < 8 and energy >= cost then
        return 1, target
    end
    return 0, distance
end

function ActivateAbility(ability, avatar, rank, target)
    local manager = gRegion:GetNpcMgr()
    local director = gRegion:GetAiDirector()
    manager:Attach(avatar, target, rank)
    director:CreateEntity(ability:GetType(), avatar)
    return manager, director
end
