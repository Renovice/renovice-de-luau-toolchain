-- Dead tail after an endless loop: the statements after `while true do ... end` are compiled but
-- unreachable (PatrolScript shape). The tail uses many registers the live code does not (register
-- declaration order, CoHUpgrades shape) and creates a closure (BoonSelection shape: a prototype that
-- exists only in dead code).
local function Patrol(limit)
    local count = 0
    while true do
        count = count + 1
        print("patrol", count)
        if count >= limit then
            error("stop", 0)
        end
    end
    print("exit", count)
    local a, b, c, d, e, f, g, h, i, j, k, l = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
    print("tail values", a, b, c, d, e, f, g, h, i, j, k, l)
    local callback = function(value)
        return "tail closure " .. value
    end
    return callback
end
print(pcall(Patrol, 3))
