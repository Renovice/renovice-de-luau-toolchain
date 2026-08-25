local spawnedByOwner = {}

function EvaluateAbility(ability, avatar, target)
    local suit = avatar:InventoryControl():GetActivePowerSuit()
    local strength = suit:GetUpgradeModifiedValue(ability:GetType(), 9, 100)
    return strength, target:IsKilled()
end

function ActivateAbility(ability, avatar, rank, target)
    if not gRegion:IsMaster() then
        return false
    end

    local effect = gRegion:CreateEntity("type:AbilityFx", avatar:GetPosition(), ZERO_ROTATION, avatar)
    spawnedByOwner[avatar:GetInstance()] = effect
    effect:Attach("type:Attachment")
    avatar:PlayAnimation("anim:Cast")

    if not target:IsKilled() and not avatar:IsAvatarFriendly(target) then
        local damage = Engine.DamageData()
        damage:SetBaseAmount(rank * 100)
        target:DamageDD(damage)
    end
    return rank, effect
end

function DeactivateAbility(ability, avatar, effect)
    local saved = spawnedByOwner[avatar:GetInstance()] or effect
    if not IsNull(saved) then
        saved:Destroy()
    end
    spawnedByOwner[avatar:GetInstance()] = nil
    return saved
end
