local zones = { { tag = "A" }, { tag = "B" }, { tag = "Exit" }, { tag = "C" } }
local rounds = 0
local function IsNull(v) return v == nil end
local function Sleep()
    rounds = rounds + 1
    if rounds >= 3 then error("stop", 0) end
end
local function Watch()
    local found = nil
    while true do
        if IsNull(found) then
            for _, z in ipairs(zones) do
                print("visit", z.tag)
                if z.tag == "Exit" or #zones == 1 then
                    found = z
                    break
                end
            end
        end
        print("found", found and found.tag)
        Sleep()
    end
end
print(pcall(Watch))
