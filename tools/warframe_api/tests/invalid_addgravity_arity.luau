-- AddGravityMultiplier requires key, multiplier, and duration.
return function(avatar)
    avatar:AddGravityMultiplier(Symbol("BAD_GRAVITY_ARITY"), 0)
end
