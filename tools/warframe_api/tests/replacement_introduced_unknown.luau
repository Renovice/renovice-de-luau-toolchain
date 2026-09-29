return function(stateObject, entity, force)
    stateObject:Enable(true)
    entity:ApplyForce(force)
    entity:InventedReplacementCall(force)
end
