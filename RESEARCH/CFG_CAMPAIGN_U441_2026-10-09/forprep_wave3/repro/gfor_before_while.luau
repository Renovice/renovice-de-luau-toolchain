local items = { "a", "b", "c" }
local status = {}
local rounds = 0
local function Sleep()
    rounds = rounds + 1
    if rounds >= 3 then error("stop", 0) end
end
local function Run()
    local t = 0
    for i, v in ipairs(items) do
        status[i] = { name = v, state = "IDLE" }
        print("init", i, v)
    end
    while true do
        for _, s in ipairs(status) do
            if s.state == "IDLE" then
                s.state = "BUSY"
                print("start", s.name)
                continue
            end
            print("busy", s.name)
        end
        t = t + 1
        Sleep()
    end
end
print(pcall(Run))
