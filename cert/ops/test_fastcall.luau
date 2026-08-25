
local function test(x, y, z)
    local a = math.abs(x)
    local b = tonumber(y)
    local c = tostring(z)
    local d = math.floor(x)
    local e = math.ceil(x)
    local f = math.sqrt(x)
    local g = math.max(x, y)
    local h = math.min(x, y)
    local i = type(x)
    return a, b, c, d, e, f, g, h, i
end
