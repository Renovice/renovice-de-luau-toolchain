return function(avatar, powerSuit)
    if avatar:IsKilled() then
        return powerSuit:GetAbilities()
    end
    return nil
end
