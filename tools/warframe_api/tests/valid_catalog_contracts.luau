return function(avatar, powerSuit, actor)
    if avatar:IsKilled() then
        actor:SetCanRun(true)
        actor:ShakeView(1, 2, 3, 4)
        actor:StopWeapons()
        return powerSuit:GetAbilities()
    end
    return nil
end
