-- Shared prototype through -O2 inlining (DUPCLOSURE): InitList is inlined into Initialize; the
-- callback literal captures nothing, so both sites use DUPCLOSURE of one prototype.
local list = {}
local function InitList()
    list.draw = function(entry)
        return "draw " .. tostring(entry)
    end
    list.size = 60
end
function Initialize()
    print("init")
    InitList()
    print(list.draw(7), list.size)
end
InitList()
print(list.draw(1))
Initialize()
