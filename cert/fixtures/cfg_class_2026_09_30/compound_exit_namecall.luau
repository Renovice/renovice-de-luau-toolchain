-- Regression fixture (2026-09-30, DEFECTS #40), IF TRUTHY -> NAMECALL class with upvalue mocks:
-- `while IsNull(region) or not region:IsMaster() do Sleep(1) end` followed by a second loop. The
-- rebuilt loop evaluated IsNull, discarded the result and called region:IsMaster() on nil.
local n = 0
local region = nil
local function Sleep(seconds)
    n = n + 1
    print("sleep", seconds, n)
    if n == 2 then
        region = { ticks = 0 }
        function region:IsMaster()
            self.ticks = self.ticks + 1
            return self.ticks >= 2
        end
    end
    if n >= 6 then error("stop", 0) end
end
local function IsNull(value)
    return value == nil
end

local function WaitMaster()
    while IsNull(region) or not region:IsMaster() do
        Sleep(1)
    end
    print("master", n)
    while true do
        if not IsNull(region) then
            print("tick", region.ticks)
        end
        Sleep(0)
    end
end

print("result", pcall(WaitMaster))
