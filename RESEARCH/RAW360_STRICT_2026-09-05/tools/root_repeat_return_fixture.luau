local function probe(a, b, c, extra, log)
    repeat
        table.insert(log, "a")
        if a then
            table.insert(log, "b")
            if b then
                table.insert(log, "prefix")
                if extra then table.insert(log, "extra") end
                break
            end
        end
        return nil, nil, nil
    until true
    table.insert(log, "tail")
    if c then return "private", nil end
    return true, false
end
local function scoped(flag)
    local value = "outer"
    repeat
        local value = "inner"
        if flag then break end
        return value
    until true
    return value
end
for mask = 0, 15 do
    local a = bit32.band(mask, 1) ~= 0
    local b = bit32.band(mask, 2) ~= 0
    local c = bit32.band(mask, 4) ~= 0
    local extra = bit32.band(mask, 8) ~= 0
    local log = {}
    local result = table.pack(probe(a, b, c, extra, log))
    local expected = "a"
    if a then expected ..= ";b" end
    if a and b then
        expected ..= ";prefix"
        if extra then expected ..= ";extra" end
        expected ..= ";tail"
    end
    assert(table.concat(log, ";") == expected)
    if a and b then
        assert(result.n == 2)
        assert(result[1] == (c and "private" or true))
        assert(result[2] == (if c then nil else false))
    else
        assert(result.n == 3)
        assert(result[1] == nil and result[2] == nil)
        assert(result[3] == nil)
    end
end
assert(scoped(true) == "outer")
assert(scoped(false) == "inner")
print("root repeat return fixture: 66 assertions passed")
