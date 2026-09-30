-- UNFIXED repro (2026-09-30): the general shape of DEFECTS #46. A call inside the break condition
-- (`s == Target()`) splits the numeric-for body into a multi-exit DAG {test1, test2, latch} with two
-- loop exits (the break arm and normal exhaustion). The #40 loop-body DAG admits at most one exit
-- target and no FOR-latch exit, so the body stays unreduced; nested in `while true` (region path) the
-- IsNull test is lost and the break fires on the wrong edge. At top level the CFG renderer handles it.
local rounds = 0
local function IsNull(value) return value == nil end
local function Touch(item) print("touch", item) end
local wanted = { "b", "zz", "zz" }
local function Target() return wanted[rounds + 1] end
local function Sleep(seconds)
    rounds = rounds + 1
    if rounds >= 3 then error("stop", 0) end
end
local function Track(t)
    while true do
        local idx = nil
        for i = 1, #t do
            local s = t[i]
            Touch(s)
            if not IsNull(s) and s == Target() then
                idx = i
                break
            end
        end
        if IsNull(idx) then table.insert(t, "new") end
        Sleep(0)
    end
end
print(pcall(Track, { "a", "b", "c" }))
