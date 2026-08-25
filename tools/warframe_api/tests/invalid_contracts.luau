-- These API-looking strings/comments must not be scanned:
-- fake:SetOverguardAmount(1, 2)
local documentation = "fake:SetDamageCallback(function(one) end)"

function ActivateAbility(ability, avatar)
    local packet = Engine.RadialDamageData()
    packet:SetDamageCallback(function(damageOnly)
        return damageOnly
    end)
    avatar:DamageControl():SetOverguardAmount(100, 200)
    return documentation
end
