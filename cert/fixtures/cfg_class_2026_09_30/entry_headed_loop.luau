-- Regression fixture (2026-09-30): a function body that starts with its loop,
-- `while true do if <test> then ... end Sleep(0) end`. The natural-loop rule tried the latch
-- (the Sleep block) first in region order and headed the loop there, so the emitter printed
-- `Sleep(0)` before the first test (44.0.2: CrewShipManager proto 5).
local sleeps = 0
local function Sleep(seconds)
    sleeps = sleeps + 1
    print("sleep", seconds, sleeps)
    if sleeps >= 3 then error("stop", 0) end
end
local polls = 0
local answers = { false, true, false }
local function Poll()
    polls = polls + 1
    print("poll", polls)
    return answers[polls]
end

local function Monitor()
    while true do
        if Poll() then
            print("ready", polls)
        end
        Sleep(0)
    end
end

print("result", pcall(Monitor))
