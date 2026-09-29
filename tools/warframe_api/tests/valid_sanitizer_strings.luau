-- String contents must not be scanned as calls, while a string literal used as
-- an actual argument must still count as one argument for every Luau string
-- delimiter family.

local doubleQuotedDocumentation = "fake:AddGravityMultiplier(Symbol('x'), 0)"
local singleQuotedDocumentation = 'fake:RemoveGravityMultiplier()'
local longDocumentation = [[fake:GetLocalPlayerAvatar("unexpected")]]

return function()
    return IsNull("double"), IsNull('single'), IsNull([[long]]),
        doubleQuotedDocumentation, singleQuotedDocumentation, longDocumentation
end
