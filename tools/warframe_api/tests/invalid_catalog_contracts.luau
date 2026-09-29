return function(avatar, powerSuit, actor)
    avatar:IsKilled(true)
    actor:SetCanRun()
    actor:ShakeView(1, 2, 3)
    actor:StopWeapons(true)
    return powerSuit:GetAbilities(1)
end
