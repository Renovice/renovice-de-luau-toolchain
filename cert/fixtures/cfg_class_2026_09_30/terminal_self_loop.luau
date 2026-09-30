-- Regression fixture (2026-09-30): a function whose whole reachable body is one exitless loop
-- (`while true do Sleep(0) end`; the compiler's final RETURN is unreachable). The region analyzer
-- stopped when one live node remained and never reduced that node's self edge, so the loop was
-- emitted as straight-line code that ran once and returned (44.0.2: SpawnCleanDrone WaitRepair,
-- Sentinel ability pumps). Mock natives; the mock Sleep raises after three calls to end the trace.
local count = 0
local function Sleep(seconds)
    count = count + 1
    print("sleep", seconds, count)
    if count >= 3 then error("stop", 0) end
end

local function WaitRepair(owner)
    while true do
        Sleep(0)
    end
end

print("result", pcall(WaitRepair, "owner"))
print("after", count)
