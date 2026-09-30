-- Regression fixture (2026-09-30, DEFECTS #51): `{ name = ..., flag = ..., Make() }` compiles to
-- NEWTABLE, SETFIELDs, then SETLIST into the SAME table. The decompiler rebuilt the SETLIST as a fresh
-- `vA = {value}`, replacing the table and losing every field (44.0.2 EE_Interface_Components_List
-- CreateList p86). The element is parenthesized so the SETLIST has a fixed count (a multret tail
-- is not covered; it does not occur on 44.0.2). Own code.
local made = 0
local function Make(tag)
    made = made + 1
    return tag .. made
end
local function CreateList(name)
    local list = {
        mName = name,
        mCount = 3,
        mEnabled = true,
        (Make(name)),
    }
    return list
end
local list = CreateList("menu")
print(list.mName, list.mCount, list.mEnabled, list[1], #list)
print("made", made)
