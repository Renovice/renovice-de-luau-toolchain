-- Regression fixture (2026-09-30): the whole function body is an outer loop whose header is the
-- function entry (`while true do local t = 0 while t < 1 do ... end if stop then return end end`).
-- The entry's only graph predecessor is the outer latch, so the sequence rule treated it as a
-- private successor and formed Seq[latch, entry]; the loop was rotated and the exit test printed
-- before `t = 0` (44.0.2: FlickerOnOff, where the inner counter then read nil).
local frames = 0
local function DeltaTime()
    return 0.5
end
local function Sleep(seconds)
    frames = frames + 1
    print("sleep", seconds, frames)
    if frames >= 8 then error("stop", 0) end
end
local passes = 0
local function Flicker(obj, loop)
    while true do
        local t = 0
        while t < 1 do
            obj.brightness = t
            print("brightness", t)
            t = t + DeltaTime()
            Sleep(0)
        end
        passes = passes + 1
        if loop == false or passes >= 2 then
            return passes
        end
    end
end

print("result", pcall(Flicker, {}, true))
print("result", pcall(Flicker, {}, false))
