local players = { { name = "a" }, { name = "b" }, { name = "c" } }
local function IsNull(v) return v == nil end
local Target = "b"
local function Find(found)
    if IsNull(found) then
        for _, p in ipairs(players) do
            print("visit", p.name)
            if p.name == Target then
                found = p
                break
            end
        end
    end
    print("found", found and found.name)
    return found
end
Find(nil)
Find(players[3])
