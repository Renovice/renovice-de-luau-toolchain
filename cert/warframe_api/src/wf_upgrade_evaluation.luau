local function readStats(ability, avatar, baseRange)
    local suit = avatar:InventoryControl():GetActivePowerSuit()
    local augmentLevel = suit:GetAbilityAugmentLevel(ability:GetAbilityIndex())
    local augmentType = suit:GetAbilityAugmentType(ability:GetType())
    local modifiedRange = suit:GetUpgradeModifiedValue(ability:GetType(), augmentType, baseRange)
    return modifiedRange, augmentLevel, augmentType
end

function EvaluateAbility(ability, avatar, target)
    local range, augmentLevel, augmentType = readStats(ability, avatar, 20)
    local distance = target:DistanceToEntity(avatar)
    if target:IsKilled() then
        return false, range, augmentLevel
    elseif distance <= range and augmentLevel > 0 then
        return true, range - distance, augmentType
    end
    return false, distance, augmentType
end

function ActivateAbility(ability, avatar, rank, target)
    local range, augmentLevel = readStats(ability, avatar, rank * 10)
    return range + augmentLevel, target:GetHealth(), target:GetMaxHealth()
end
