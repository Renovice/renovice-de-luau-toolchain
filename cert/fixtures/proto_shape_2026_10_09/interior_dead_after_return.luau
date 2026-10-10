-- Interior dead code after an early return (EndlessSpawnLib / InfBoomerangPods shape): DE's compiler
-- keeps statements after a mid-function return. `repeat return X until true` is the same single RETURN
-- but not a terminator to the upstream compiler, so the statements after it are compiled and unreachable,
-- and live code follows them (the join after the `if`).
local function Classify(value)
    if value > 10 then
        repeat return "big" until true
        print("dead after return", value)
        local scaled = value * 3
        warn("never", scaled)
    end
    local t = 0.1
    while t < 2 do
        repeat return "loop exit " .. value until true
        t = t + Sleep(0) * 4
        print("dead loop body", t)
    end
    return "small"
end
print(Classify(20), Classify(3))
