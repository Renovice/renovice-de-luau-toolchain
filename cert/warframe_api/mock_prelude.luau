-- Deterministic Warframe-shaped native boundary used symmetrically by known
-- source and Semantic IR-rendered source. Unknown methods are traced and return
-- nil; important API families receive typed deterministic values below.
local _G = setmetatable({}, {__index = _G})

local __wf_trace = {}
local __wf_objects = {}

local function __wf_value(value, depth)
    depth = depth or 0
    local kind = type(value)
    if kind == "table" then
        local name = rawget(value, "__mock_name")
        if name then return "@" .. name end
        if depth >= 3 then return "<deep>" end
        local keys = {}
        for key in pairs(value) do
            if key ~= "__mock_name" and key ~= "__mock_props" then
                keys[#keys + 1] = key
            end
        end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        local parts = {}
        for _, key in ipairs(keys) do
            parts[#parts + 1] = tostring(key) .. "="
                .. __wf_value(value[key], depth + 1)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    elseif kind == "function" then return "<fn>"
    elseif kind == "string" then return string.format("%q", value)
    elseif kind == "number" then return string.format("%.10g", value)
    else return tostring(value) end
end

local function __wf_log(...)
    local values = table.pack(...)
    local parts = {}
    for index = 1, values.n do parts[index] = __wf_value(values[index]) end
    __wf_trace[#__wf_trace + 1] = table.concat(parts, "|")
end

local __wf_return
local function __wf_object(name, properties)
    local object = {__mock_name = name, __mock_props = properties or {}}
    __wf_objects[name] = object
    return setmetatable(object, {
        __index = function(self, key)
            local property = rawget(self, "__mock_props")[key]
            if property ~= nil then
                __wf_log("get", name, key, property)
                return property
            end
            return function(receiver, ...)
                __wf_log("call", name, key, receiver == self, ...)
                if key == "FailNative" then error("mock native failure:" .. name) end
                return __wf_return(name, key, ...)
            end
        end,
        __newindex = function(self, key, value)
            __wf_log("set", name, key, value)
            rawget(self, "__mock_props")[key] = value
        end,
        __tostring = function() return "@" .. name end,
    })
end

local __wf = {}
for _, name in ipairs({
    "ability", "avatar", "enemy", "friend", "killed", "agent", "suit",
    "inventory", "damage", "damageControl", "spawn", "attachment",
    "motion", "npcMgr", "aiDirector", "ragdoll", "secondaryArgs"
}) do
    __wf[name] = __wf_object(name)
end
__wf.NULL = __wf_object("NULL")

__wf_return = function(name, method, ...)
    if method == "InventoryControl" then return __wf.inventory end
    if method == "GetActivePowerSuit" or method == "GetSuit" then return __wf.suit end
    if method == "DamageControl" then return __wf.damageControl end
    if method == "MotionControl" then return __wf.motion end
    if method == "GetNpcMgr" then return __wf.npcMgr end
    if method == "GetAiDirector" then return __wf.aiDirector end
    if method == "GetAvatarOwner" or method == "GetAbilityOwnerAvatar__c2c53207" then
        return __wf.avatar
    end
    if method == "GetAvatar" then return __wf.avatar end
    if method == "GetAgent" then return __wf.agent end
    if method == "GetRagdoll" then return __wf.ragdoll end
    if method == "GetAttachment" or method == "Attach" then return __wf.attachment end
    if method == "CreateEntity" or method == "FindFirstTagged" then return __wf.spawn end
    if method == "FindAll" or method == "GetAvatarsTouching" then
        return {__wf.enemy, __wf.friend, __wf.killed}
    end
    if method == "GetAbilities" then return {__wf.ability} end
    if method == "GetAbilityByIndex" then return __wf.ability end
    if method == "GetPosition" or method == "GetSimPosition" then
        return {__mock_name = "position:" .. name}
    end
    if method == "GetRotation" or method == "GetSimRotation" then
        return {__mock_name = "rotation:" .. name}
    end
    if method == "GetType" or method == "GetResType" then return "type:" .. name end
    if method == "GetInstance" then return "instance:" .. name end
    if method == "IsMaster" or method == "IsActive" then return true end
    if method == "IsKilled" or method == "IsPreDeath" then return name == "killed" end
    if method == "IsAvatarFriendly" then
        local other = select(1, ...)
        return other == __wf.friend
    end
    if method == "IsA" then return true end
    if method == "GetHealth" then return name == "killed" and 0 or 75 end
    if method == "GetMaxHealth" then return 100 end
    if method == "GetShield" then return 40 end
    if method == "GetMaxShield" then return 100 end
    if method == "GetEnergy" then return 100 end
    if method == "GetActivationEnergyCost" then return 25 end
    if method == "GetAbilityIndex" then return 2 end
    if method == "GetNumAbilities" then return 1 end
    if method == "GetAbilityAugmentLevel" then return 2 end
    if method == "GetAbilityAugmentType" then return 1 end
    if method == "GetUpgradeModifiedValue" or method == "GetModifiedValue" then
        local base = select(3, ...)
        if type(base) ~= "number" then base = select(2, ...) end
        return type(base) == "number" and base * 1.5 or 1.5
    end
    if method == "SetDamageCallback" then
        local callback = select(1, ...)
        if type(callback) == "function" then
            callback(__wf.enemy, 120)
            callback(__wf.friend, 80)
            callback(__wf.killed, -5)
        end
        return nil
    end
    if method == "GetOverguardAmount" then
        return rawget(__wf.damageControl, "__mock_props").overguard or 100
    end
    if method == "SetOverguardAmount" then
        rawget(__wf.damageControl, "__mock_props").overguard = select(1, ...)
        return nil
    end
    if method == "GetPlayer" then return __wf.avatar end
    if method == "DistanceToEntity" then return 4 end
    if method == "GetTableElementCount__ad7b05b3" then return 1 end
    return nil
end

gRegion = __wf_object("gRegion")
mOwner = __wf_object("mOwner")
Engine = {
    DamageData = function(...)
        __wf_log("global", "Engine.DamageData", ...)
        return __wf.damage
    end,
    RadialDamageData = function(...)
        __wf_log("global", "Engine.RadialDamageData", ...)
        return __wf.damage
    end,
}
Lotus_Game = {
    SecondaryScriptArgs = function(...)
        __wf_log("global", "Lotus_Game.SecondaryScriptArgs", ...)
        return __wf.secondaryArgs
    end,
}

function IsNull(value)
    __wf_log("global", "IsNull", value)
    return value == nil or value == __wf.NULL
end
function Symbol(value) __wf_log("global", "Symbol", value); return "sym:" .. value end
function Sleep(value) __wf_log("global", "Sleep", value) end
function DeltaTime() __wf_log("global", "DeltaTime"); return 0.25 end
function Vector(x, y, z)
    __wf_log("global", "Vector", x, y, z)
    return {__mock_name = "vector:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(z)}
end
function Ternary(condition, yes, no)
    __wf_log("global", "Ternary", condition, yes, no)
    if condition then return yes else return no end
end

ZERO_VECTOR = {__mock_name = "ZERO_VECTOR"}
ZERO_ROTATION = {__mock_name = "ZERO_ROTATION"}
gLotusAvatarType = "type:LotusAvatar"
gPowerSuitType = "type:PowerSuit"
FX_TYPE = "type:AbilityFx"
ATTACH_TYPE = "type:Attachment"
CAST_ANIM = "anim:Cast"

local function __wf_take_trace()
    local result = table.concat(__wf_trace, ";")
    table.clear(__wf_trace)
    return result
end
