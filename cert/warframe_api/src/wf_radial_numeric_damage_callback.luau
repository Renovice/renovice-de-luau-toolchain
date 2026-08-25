function ActivateAbility(ability, avatar)
    local packet = Engine.RadialDamageData()
    packet:SetDamageCallback(function(_, damageAmount)
        if type(damageAmount) ~= "number" then
            return
        end
        local dealt = math.max(0, damageAmount)
        if dealt <= 0 then
            return
        end
        local control = avatar:DamageControl()
        local current = control:GetOverguardAmount()
        local updated = math.min(15000, current + dealt * 0.1)
        if current < updated then
            control:SetOverguardAmount(updated)
            avatar:NotifyOverguardGain(avatar:GetPlayer(), updated - current)
        end
    end)
    return avatar
end
