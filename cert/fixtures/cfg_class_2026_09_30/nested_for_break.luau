-- Regression fixture (2026-09-30, DEFECTS #44/#46/#47): `local idx = nil; for ... idx = i; break end`
-- as the first statements of a function-level `while true`. Three independent defects:
--   #44 the loop header block ends in the for's FORNPREP; the outer NaturalLoop lost its loop claim
--       and was flattened, deleting the `while` (the body ran once);
--   #46 the break arm `idx = i; break` cannot reach the latch, so it is outside the for's natural
--       body; its jump to the loop exit was dropped and the search kept going;
--   #47 instruction 0 is the loop header, so its LOADNIL was suppressed as a prologue `local` and
--       idx carried the previous iteration's value (cfg-identity cannot see a LOADNIL).
-- (A call inside the break condition, `s == Target()`, splits the for body into a multi-exit DAG that
-- is still mis-rendered; recorded in the research note, not covered here.)
-- Own code, mock natives; Sleep stops the loop after three rounds.
local rounds = 0
local function IsNull(value) return value == nil end
local function Sleep(seconds)
    rounds = rounds + 1
    print("sleep", seconds, rounds)
    if rounds >= 3 then error("stop", 0) end
end
local function Touch(item) print("touch", item) end
local wanted = { "b", "zz", "zz" }
local function Target() return wanted[rounds + 1] end
local function Track(t)
    while true do
        local idx = nil
        local want = Target()
        for i = 1, #t do
            local s = t[i]
            Touch(s)
            if not IsNull(s) and s == want then
                idx = i
                break
            end
        end
        if IsNull(idx) then
            table.insert(t, "new")
            print("insert", #t)
        end
        Sleep(0)
    end
end
print("result", pcall(Track, { "a", "b", "c" }))
