local children = { { mesh = nil, n = "x" }, { mesh = "Head", n = "h" }, { mesh = "Body", n = "b" }, { mesh = "Body", n = "c" } }
local function IsNull(v) return v == nil end
local function Pick(enabled)
    local found = nil
    local r = nil
    if enabled then
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
    return found
end
Pick(true)
Pick(false)
