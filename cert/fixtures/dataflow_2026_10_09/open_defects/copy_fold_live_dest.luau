-- OPEN DEFECT witness (2026-10-09, dataflow-identity). expr.h fold_pure_setup_move erases
-- `target = entity` (MOVE R1 <- R0) and substitutes R0 into the call although R1 is live out of the
-- block (the conditional reassignment and the later read): `target:GetOwner()` then reads nil.
-- CFG-ID PASS; RENOVICE_NO_CALLCOALESCE=1 restores the behavior. Corpus class NAMECALL VALUE +NIL -PARAM.
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
