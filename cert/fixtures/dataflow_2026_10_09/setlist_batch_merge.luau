-- FIXED (DEFECTS #66, 2026-10-09). A list constructor with more than 16 items is flushed in SETLIST
-- batches (aux 1, 17, 33). The decompiler printed later batches as index stores `t[17] = v` (SETTABLEN):
-- not the stock program (CFG-ID LABEL LOAD/SETLIST -> SETTABLEN), and a multret tail in a later batch was
-- truncated to one value (`select(2, 0, 36, 37)` lost 37: `#mixed` 37 -> 36). Later batches are now merged
-- into the constructor. RENOVICE_NO_SETLIST_BATCH_MERGE=1 reproduces the index-store form.
-- Covers call items, constant items, an upvalue read, a third batch and a multret tail.
function V(x) return x * 2 end
local names = {}
local function Build(extra)
    local list = { "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11", "a12", "a13", "a14",
                   "a15", "a16", "a17", "a18", extra, #names, "a21" }
    print(#list, list[1], list[17], list[19], list[20], list[21])
    local mixed = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
                    27, 28, 29, 30, 31, 32, 33, 34, string.format("%d", 35), select(2, 0, 36, 37) }
    print(#mixed, mixed[16], mixed[17], mixed[33], mixed[35], mixed[36], mixed[37])
    return list
end
Build("x")
local function Calls()
    local t = { V(1), V(2), V(3), V(4), V(5), V(6), V(7), V(8), V(9), V(10), V(11), V(12), V(13), V(14),
                V(15), V(16), V(17), V(18), V(19), V(20) }
    print(#t, t[1], t[17], t[20])
end
Calls()
