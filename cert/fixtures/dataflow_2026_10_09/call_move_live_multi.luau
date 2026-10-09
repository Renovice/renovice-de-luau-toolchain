-- FIXED (DEFECTS #64, multi-result form, 2026-10-09). `local b, c = G(); a, d = b, c`: expr.h retargeted both
-- CALL results into a, d (`a, d = G()`) although b and c are read later, leaving them unassigned (nil).
-- CFG-ID PASS either way. RENOVICE_NO_CALLMOVE_LIVE_SOURCE_GUARD=1 reproduces the old output.
local function G() return 1, 2 end
local function T()
    local a, d = 0, 0
    local b, c = G()
    a, d = b, c
    print("t", a, d, b, c)
end
T()
