local rounds = 0
local players = { { name = "a" }, { name = "b" }, { name = "c" } }
local function IsNull(v) return v == nil end
local function Sleep(t)
    rounds = rounds + 1
    print("sleep", rounds)
    if rounds >= 4 then error("stop", 0) end
end
local Target = "b"
local function Watch()
    local found = nil
    while true do
        if IsNull(found) then
            for _, p in ipairs(players) do
                print("visit", p.name)
                if p.name == Target then
                    found = p
                    break
                end
            end
        end
        if not IsNull(found) then
            print("found", found.name)
        end
        Sleep(0)
    end
end
print(pcall(Watch))
