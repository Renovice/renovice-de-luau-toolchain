-- OPEN DEFECT witness (2026-10-09, dataflow-identity). NEWTABLE R3; MOVE R5 <- R3 for the
-- table.insert argument: the table allocation is retargeted to R5 (expr.h TABLEMOVECOALESCE) although
-- R3 is read after the loop, so Create(names) receives a stale number. CFG-ID PASS;
-- RENOVICE_NO_TABLEMOVECOALESCE=1 (or RENOVICE_NO_CALLCOALESCE=1) restores it. Class CALL VALUE +K -N:NEWTABLE.
local Skel = {}
Skel.__index = Skel
function Skel:GetFullName() return "skel:" .. self.id end
local pool = { { skel = setmetatable({ id = "a" }, Skel), mats = { 1, 2 } } }
local function Create(list) return { list = list } end
local function Spawn()
    local count = #pool
    local index = math.random(1, count)
    local names = {}
    table.insert(names, pool[index].skel:GetFullName())
    local overrides = {}
    for i = 1, #pool[index].mats do
        overrides[i] = pool[index].mats[i] * 10
    end
    local loader = Create(names)
    print("spawn", type(loader.list), loader.list[1], #overrides)
end
Spawn()
