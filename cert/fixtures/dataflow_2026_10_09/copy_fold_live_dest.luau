-- FIXED (DEFECTS #63, 2026-10-09; found by dataflow-identity). expr.h fold_pure_setup_move erased
-- `target = entity` (MOVE R1 <- R0) and substituted R0 into the call although R1 is live out of the
-- block (the conditional reassignment and the later read): `target:GetOwner()` then read nil.
-- CFG-ID PASS either way. The fold now requires the copy's destination to be dead after the use
-- (prototype-wide liveness); RENOVICE_NO_COALESCE_LIVE_DEST_GUARD=1 reproduces the old output.
-- Corpus class NAMECALL VALUE +NIL -PARAM.
local Thing = {}
Thing.__index = Thing
function Thing.new(name, owner) return setmetatable({ name = name, owner = owner }, Thing) end
function Thing:IsA(kind) return self.name == kind end
function Thing:GetOwner() return self.owner end
function Thing:Name() return self.name end
local function Describe(entity)
    local target = entity
    if target:IsA("ragdoll") then
        target = target:GetOwner()
    end
    print("describe", target:Name())
end
Describe(Thing.new("ragdoll", Thing.new("owner")))
Describe(Thing.new("plain"))
