local changedNumericValue = 150

return function(stateObject, entity, force)
    stateObject:Enable(true)
    entity:ApplyForce(force)
    return changedNumericValue
end
