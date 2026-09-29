local function nested(a, b, c, d, e, log)
    repeat
        table.insert(log, "a")
        if a then
            table.insert(log, "b")
            if b then
                table.insert(log, "c")
                if c then
                    table.insert(log, "d")
                    if not d then break end
                    table.insert(log, "e")
                    if e then break end
                end
            end
        end
        return
    until true
    table.insert(log, "tail")
    return
end
local function leading(a, b, c, log)
    repeat
        table.insert(log, "a")
        if a then break end
        table.insert(log, "b")
        if b then break end
        table.insert(log, "c")
        if c then
            table.insert(log, "exit")
            break
        end
        return false, "guard"
    until true
    table.insert(log, "tail")
    return true, "tail"
end
local function arm(a, b, c, log)
    repeat
        if a then
            table.insert(log, "a")
            if b then
                table.insert(log, "b")
                break
            end
            table.insert(log, "fallback")
            break
        end
        return false
    until true
    table.insert(log, "tail")
    if c then return false end
    return true
end
local checks = 0
for mask = 0, 31 do
    local a = bit32.band(mask, 1) ~= 0
    local b = bit32.band(mask, 2) ~= 0
    local c = bit32.band(mask, 4) ~= 0
    local d = bit32.band(mask, 8) ~= 0
    local e = bit32.band(mask, 16) ~= 0
    local log = {}
    local result = table.pack(nested(a, b, c, d, e, log))
    local expected = "a"
    if a then expected ..= ";b" end
    if a and b then expected ..= ";c" end
    if a and b and c then expected ..= ";d" end
    if a and b and c and d then expected ..= ";e" end
    if a and b and c and (not d or e) then expected ..= ";tail" end
    assert(result.n == 0)
    assert(table.concat(log, ";") == expected)
    checks += 2
end
local cases = {
    {false,false,false,false,"a;b;c","a;fallback;tail",true},
    {false,false,true,true,"a;b;c;exit;tail","a;fallback;tail",false},
    {false,true,false,true,"a;b;tail","a;b;tail",true},
    {false,true,true,true,"a;b;tail","a;b;tail",false},
    {true,false,false,true,"a;tail","",false},
    {true,false,true,true,"a;tail","",false},
    {true,true,false,true,"a;tail","",false},
    {true,true,true,true,"a;tail","",false},
}
for _, case in ipairs(cases) do
    local log = {}
    local result = table.pack(leading(case[1], case[2], case[3], log))
    assert(result.n == 2)
    assert(result[1] == case[4])
    assert(result[2] == (case[4] and "tail" or "guard"))
    assert(table.concat(log, ";") == case[5])
    log = {}
    result = table.pack(arm(not case[1], case[2], case[3], log))
    assert(result.n == 1)
    assert(result[1] == case[7])
    assert(table.concat(log, ";") == case[6])
    checks += 7
end
assert(checks == 120)
print("nested repeat guard fixture: 121 assertions passed")
