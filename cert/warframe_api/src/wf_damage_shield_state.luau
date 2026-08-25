local absorbed = 0

function OnDamaged(avatar, damage, source)
    local control = avatar:DamageControl()
    local shield = control:GetShield()
    local maximum = control:GetMaxShield()
    local restore = math.min(maximum - shield, source:GetHealth() / 5)
    if restore > 0 then
        control:SetShield(shield + restore)
        absorbed += restore
    end
    return absorbed, shield, restore
end

function OnKilled(avatar, source, ability)
    local control = avatar:DamageControl()
    if source:IsKilled() then
        control:SetShield(0)
        absorbed = 0
    end
    return absorbed, ability:GetType()
end
