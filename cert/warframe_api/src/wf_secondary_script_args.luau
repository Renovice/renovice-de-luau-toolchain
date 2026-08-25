function ActivateAbility(ability, avatar, rank, target)
    local args = Lotus_Game.SecondaryScriptArgs(true)
    args:PushFloatArg(rank * 0.5)
    args:PushObjectArg(target)
    args:PushVector3Arg(avatar:GetPosition())
    avatar:ActivateSecondaryScript(ability:GetType(), args)
    return args, rank
end

function DeactivateAbility(ability, avatar, effect)
    local args = Lotus_Game.SecondaryScriptArgs(false)
    args:PushObjectArg(effect)
    avatar:ActivateSecondaryScript(ability:GetType(), args)
    return IsNull(effect)
end
