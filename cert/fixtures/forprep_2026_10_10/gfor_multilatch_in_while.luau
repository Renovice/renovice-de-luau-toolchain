local children = { { mesh = nil, n = "x" }, { mesh = "Head", n = "h" }, { mesh = "Body", n = "b" }, { mesh = "Body", n = "c" } }
local function IsNull(v) return v == nil end
local rounds = 0
local function Sleep()
    rounds = rounds + 1
    if rounds >= 3 then error("stop", 0) end
end
local function Watch()
    local found = nil
    local r = nil
    while true do
        if IsNull(found) then
            for _, c in ipairs(children) do
                print("visit", c.n)
                if c.mesh then
                    r = string.find(c.mesh, "Body")
                    if not IsNull(r) then
                        found = c
                        break
                    end
                end
            end
        end
        print("found", found and found.n, r)
        Sleep()
    end
end
print(pcall(Watch))
