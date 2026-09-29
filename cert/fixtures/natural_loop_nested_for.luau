-- Regression fixture (2026-09-29): the control-flow shape of SyndicateScarves NewLokaScarfUpdate
-- (Warframe 44.0.2, /Lotus/Scripts/Effects/SyndicateScarves.lua proto 13), re-expressed with mock
-- natives so it runs under plain luau.exe.
--
-- Shape: a guarded prologue with early returns, then `while not IsNull(obj)` whose body holds a
-- terminal (returning) hub branch, two lazy-initialisation guards, a short-circuit `a ~= nil and
-- b[k] ~= nil` whose second operand needs statements (so it cannot become a predicate chain), a
-- nested numeric `for` with an if/elseif chain and a fallback `else`, and a trailing Sleep. The old
-- structurer headed the natural loop at the `b[k] ~= nil` test (region-id order, no dominance
-- check), which pulled the prologue into the loop; the emitter then printed the loop body first,
-- the prologue last, and no `while` at all. CONST-ID passed that output.
local trace = {}
local function note(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring((select(i, ...))) end
    trace[#trace + 1] = table.concat(parts, " ")
end

local ticks = 0
local function IsNull(object)
    return object == nil or object.dead == true
end
local function Sleep(seconds)
    ticks = ticks + 1
    note("sleep", seconds, ticks)
end
local function DeltaTime()
    return 0.25
end
local function Clamp(value, low, high)
    if value < low then return low end
    if value > high then return high end
    return value
end

SharedT = {}
local level = 128

local function prepare(object)
    note("prepare", object.name)
end

local function makePart(name, lifetime)
    local part = { name = name, dead = false, lifetime = lifetime }
    function part:SetMaterialParam(key, value)
        note(self.name, "param", key, string.format("%.3f", value))
        self.lifetime = self.lifetime - 1
        if self.lifetime <= 0 then self.dead = true end
    end
    function part:SetOpacity(value)
        note(self.name, "opacity", string.format("%.3f", value))
    end
    return part
end

local function makeScarf(options)
    local scarf = makePart("scarf", options.lifetime)
    scarf.rules = options.rules
    function scarf:GetRootOwner()
        return options.owner
    end
    function scarf:GetAttachment(kind)
        return options.attachments[kind]
    end
    return scarf
end

local function update(scarf)
    prepare(scarf)
    local value = 0.1
    Sleep(0)
    local rules = scarf.rules
    local isHub
    if IsNull(rules) then
        isHub = false
    else
        isHub = rules:IsA("hub") or rules:IsA("attract")
    end
    local owner = scarf:GetRootOwner()
    if IsNull(owner) or not owner:IsA("avatar") then
        return
    end
    local player = owner:GetPlayer()
    local name
    if IsNull(player) then
        name = owner:GetInstance()
    else
        name = player:GetPlayerName()
    end
    local flare = scarf:GetAttachment("flare")
    local deco = scarf:GetAttachment("deco")
    while not IsNull(scarf) do
        if isHub then
            local base = SharedT.maximumIntensity and 1 or level
            value = base / 255 * 2
            scarf:SetMaterialParam("unlit", value)
            if not IsNull(flare) then
                flare:SetOpacity(math.min(1, value))
            end
            return
        end
        if SharedT.effects == nil then
            SharedT.effects = {}
        end
        if SharedT.effects[name] == nil then
            SharedT.effects[name] = { Flash = 0, Total = 0, Parts = {} }
        end
        if SharedT.effects ~= nil and SharedT.effects[name] ~= nil then
            for i = 1, 4 do
                local part = SharedT.effects[name].Parts[i]
                if part == nil then
                    part = { Total = 0, Flash = 0 }
                end
                local total = Clamp(part.Total / 10, 0, 1)
                local flash = Clamp(part.Flash, 0, 1)
                value = math.max(0.1, flash * 2 + total * 2)
                part.Flash = math.max(0, part.Flash - DeltaTime())
                if i == 1 then
                    scarf:SetMaterialParam("emissive", value)
                elseif i == 2 then
                    scarf:SetMaterialParam("unlit", value * 0.5)
                elseif i == 3 then
                    if not IsNull(deco) then
                        deco:SetMaterialParam("unlit", value)
                    end
                else
                    if not IsNull(flare) then
                        flare:SetOpacity(math.min(1, value))
                    end
                end
            end
        else
            scarf:SetMaterialParam("unlit", value * 0.5)
        end
        Sleep(0)
    end
end

local function makeRules(kind)
    return { IsA = function(_, wanted) return wanted == kind end }
end

local function makeOwner(hasPlayer, avatar)
    local owner = {}
    function owner:IsA(kind) return avatar and kind == "avatar" end
    function owner:GetPlayer()
        if not hasPlayer then return nil end
        return { GetPlayerName = function() return "player" end }
    end
    function owner:GetInstance() return "instance" end
    return owner
end

local scenarios = {
    { label = "hub", rules = makeRules("hub"), owner = makeOwner(true, true), lifetime = 9, flare = true },
    { label = "attract", rules = makeRules("attract"), owner = makeOwner(false, true), lifetime = 9, flare = false },
    { label = "mission-player", rules = makeRules("mission"), owner = makeOwner(true, true), lifetime = 7, flare = true },
    { label = "mission-instance", rules = nil, owner = makeOwner(false, true), lifetime = 5, flare = false },
    { label = "not-avatar", rules = nil, owner = makeOwner(true, false), lifetime = 5, flare = true },
    { label = "no-owner", rules = nil, owner = nil, lifetime = 5, flare = true },
}

for _, scenario in ipairs(scenarios) do
    SharedT = {}
    if scenario.label == "attract" then SharedT.maximumIntensity = true end
    if scenario.label == "mission-instance" then
        SharedT.effects = { instance = { Flash = 0, Total = 0, Parts = { { Total = 5, Flash = 1 } } } }
    end
    ticks = 0
    local attachments = { deco = makePart("deco", 100) }
    if scenario.flare then attachments.flare = makePart("flare", 100) end
    note("scenario", scenario.label)
    update(makeScarf({ rules = scenario.rules, owner = scenario.owner, lifetime = scenario.lifetime,
                       attachments = attachments }))
end

for _, line in ipairs(trace) do print(line) end
