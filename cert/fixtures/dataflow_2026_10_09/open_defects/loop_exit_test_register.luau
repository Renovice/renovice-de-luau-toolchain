-- OPEN DEFECT witness (2026-10-09, dataflow-identity). `if not IsNull(player)` inside a
-- `while true` loop: the rebuild tests the GetPlayer() result instead of the IsNull() result, so the
-- loop keeps polling. CFG-ID PASS. Class IF TRUTHY VALUE +D:CALL -D:CALL.
local sleeps = 0
local function Sleep(t)
    sleeps = sleeps + 1
    print("sleep", sleeps)
    if sleeps > 8 then error("stop", 0) end
end
local function IsNull(v) return v == nil or v == 0 end
local Region = {}
function Region:IsMaster() return true end
local Ent = {}
Ent.__index = Ent
function Ent:IsHidden() return false end
function Ent:GetPlayer() self.calls = self.calls + 1; if self.calls == 1 or self.calls > 3 then return 0 end return "player" end
function Ent:Suicide() print("suicide") end
local function Watch(ent)
    if not Region:IsMaster() then return end
    while true do
        if IsNull(ent) then return end
        while ent:IsHidden() do Sleep(0) end
        local player = ent:GetPlayer()
        if not IsNull(player) then
            while not IsNull(ent) and not IsNull(ent:GetPlayer()) do Sleep(0) end
            Sleep(0)
            if not IsNull(ent) then ent:Suicide() end
            return
        end
        Sleep(0)
    end
end
print("result", pcall(Watch, setmetatable({ calls = 0 }, Ent)))
