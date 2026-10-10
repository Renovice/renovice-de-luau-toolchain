local values = { 10, 20, 30, 40 }
local polls = 0
local function Sleep()
    polls = polls + 1
    print("sleep", polls)
    if polls >= 3 then error("stop", 0) end
end
local function Pick(v)
    if v < 0 then
        while true do
            Sleep()
        end
    end
    local n = #values
    for i = n, 1, -1 do
        if values[i] <= v then
            print("pick", i, values[i])
            return
        end
    end
    print("none")
end
Pick(25)
Pick(5)
Pick(100)
print(pcall(Pick, -1))
