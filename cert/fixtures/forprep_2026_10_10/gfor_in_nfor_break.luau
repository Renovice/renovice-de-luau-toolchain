local zones = { { list = { "a", "b" } }, { list = nil }, { list = { "c", "p" } }, { list = { "p" } } }
local rounds = 0
local function IsNull(v) return v == nil end
local function Sleep()
    rounds = rounds + 1
    if rounds >= 3 then error("stop", 0) end
end
local function Watch(p)
    while true do
        local found = nil
        for i = 1, #zones do
            if not IsNull(zones[i].list) then
                for _, v in ipairs(zones[i].list) do
                    print("visit", i, v)
                    if v == p then
                        found = i
                        break
                    end
                end
                if not IsNull(found) then
                    break
                end
            end
        end
        print("found", found)
        Sleep()
    end
end
print(pcall(Watch, "p"))
