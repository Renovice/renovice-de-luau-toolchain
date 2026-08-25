function ActivateAbility(ability, avatar, rank, target)
    local damage = Engine.DamageData()
    damage:SetBaseAmount(rank * 25)
    local hit = 0

    for _, candidate in ipairs(gRegion:FindAll(gLotusAvatarType)) do
        if candidate:IsKilled() then
            continue
        end
        if avatar:IsAvatarFriendly(candidate) then
            continue
        end
        candidate:DamageDD(damage)
        hit += 1
    end

    return hit, target:DistanceToEntity(avatar)
end
