-- Regression fixture (2026-09-30, DEFECTS #45): a numeric-for body holding an inner loop followed by
-- a statement (the saved repro RESEARCH/CFG_MULTI_EXIT_LOOPS_2026-09-30/repro/numeric_for_body_order).
-- The for-body NaturalLoop was emitted without its own wrapper, in region-id order, and the inner
-- While had been collapsed after the latch block that holds print(i): print(i) ran BEFORE the inner
-- loop on every iteration. The harness predefines IsNull, Sleep and gGameRules as globals (the stock
-- GETIMPORT shape); Sleep makes gGameRules appear on every second poll and drops it after a print.
local function Track()
    for i = 1, 3 do
        while IsNull(gGameRules) do Sleep(1) end
        print(i)
        gGameRules = nil
    end
end

print("result", pcall(Track))
