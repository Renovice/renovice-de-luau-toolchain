local units = { { n = "a", friendly = true }, { n = "b", killed = true }, { n = "c" }, { n = "d" } }
local owner = nil
local function IsNull(v) return v == nil end
local function Setup(mode)
    owner = nil
    for _, u in ipairs(units) do
        if IsNull(u) then
            continue
        end
        if u.friendly then
            continue
        end
        if u.killed then
            continue
        end
        owner = u
        if mode == 0 then
            print("intro", u.n)
        end
        break
    end
    if IsNull(owner) then
        print("lost")
    else
        print("owner", owner.n)
    end
end
Setup(0)
Setup(1)
