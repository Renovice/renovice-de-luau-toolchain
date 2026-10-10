-- Interior dead code under a constant-false condition (KuvaPath / RailJackEnemyEffects shape): the THEN
-- value of an if-expression whose condition is `x and false` is compiled (JUMPIFNOT x -> else; JUMP
-- else; THEN...) but no path reaches it. Its constants ("debug cap", math.min, GetCount) exist only there.
local debugMode = false
local function SetDebug(value)
    debugMode = value
end
local counter = { n = 4 }
function counter:GetCount()
    return self.n
end
local function MaxPlayers()
    return if debugMode and false then math.min(counter:GetCount(), 6) else 6
end
local function Label()
    return if debugMode and false then tostring("debug cap " .. counter:GetCount()) else "cap"
end
local function Limit(players)
    if players < MaxPlayers() then
        return Label() .. " ok"
    end
    return Label() .. " full"
end
SetDebug(true)
print(MaxPlayers(), Limit(3), Limit(9))
SetDebug(false)
print(MaxPlayers(), Limit(6))
