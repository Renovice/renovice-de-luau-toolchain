polls = 0
function IsNull(value) return value == nil end
function DeltaTime() return 0.75 end
function Random(a, b) return a + b end
function Symbol(name) return name end
damagePerSecond = 2
gBaseAvatarType, gLotusSentinelAvatarType, gLotusNpcAvatarType = "base", "sentinel", "npc"
function Sleep(seconds)
    polls = polls + 1
    print("sleep", seconds, polls)
    if polls >= 40 then error("stop", 0) end
end
gRegion = { IsMaster = function() return true end }
function Setup(sentinel, npc)
    polls = 0
    local victim = { hp = 3 }
    function victim:IsA(kind) print("isa", kind); return kind == "base" or (kind == "sentinel" and sentinel) or (kind == "npc" and npc) end
    function victim:IsKilled() return self.hp <= 0 end
    function victim:IsActive(kind) print("active", kind, polls); return polls % 3 == 1 end
    function victim:InventoryControl() return { IsFiring = function() print("firing", polls); return polls % 4 == 2 end } end
    function victim:DamageEx(amount, a, b, c, who, src) self.hp = self.hp - 1; print("damage", amount, a, b, c, who, self.hp) end
    function victim:IsReady(name) print("ready", name, polls); return polls == 7 end
    function victim:PlayAnim(name, a, b, c, d) print("anim", name, a, b, c, d); return nil end
    function victim:SuspendScriptUntilAnimEvent(e, t) print("suspend", e, t) end
    local leech = { destroyed = 0 }
    function leech:GetAttachParent() return victim end
    function leech:GetInstigator() return "inst" end
    function leech:Destroy() self.destroyed = self.destroyed + 1; print("destroy", self.destroyed) end
    return leech
end
