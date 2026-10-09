-- OPEN DEFECT witness (2026-10-09, dataflow-identity). Compiled -O2: FindCount inlines and its
-- `return list[i].count` leaves the numeric for with the index register still read; the rebuild
-- iterates a fresh __renovice_for variable and reads the start value. CFG-ID PASS.
-- Class GETTABLE VALUE -D:FORNLOOP.
local function FindCount(list, kind)
    for i = 1, #list do
        if list[i].kind == kind then
            return list[i].count
        end
    end
    return 0
end
local function Build(list, kind)
    local entry = {}
    entry.Count = FindCount(list, kind)
    print("count", kind, entry.Count)
    return entry
end
local items = { { kind = "a", count = 10 }, { kind = "b", count = 20 }, { kind = "c", count = 30 } }
Build(items, "c")
Build(items, "z")
