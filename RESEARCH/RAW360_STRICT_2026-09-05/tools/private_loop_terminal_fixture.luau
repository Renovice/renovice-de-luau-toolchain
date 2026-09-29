local function scan(items, log)
    for i = 1, #items do
        local item = items[i]
        table.insert(log, "item" .. i)
        if item.skip then continue end
        if item.drone then
            if item.deployed then
                table.insert(log, "drone")
                return "denied", i
            end
        end
        table.insert(log, "work")
        if item.raw ~= nil then
            if item.raw.expirable or item.category == 24 then
                if item.raw.limited then
                    table.insert(log, "limited")
                    return "denied", i
                end
            end
        end
        table.insert(log, "tail")
    end
    table.insert(log, "complete")
    return "complete", false
end
local checks = 0
for mask = 0, 127 do
    local item = {
        skip = bit32.band(mask, 1) ~= 0,
        drone = bit32.band(mask, 2) ~= 0,
        deployed = bit32.band(mask, 4) ~= 0,
        raw = bit32.band(mask, 8) ~= 0 and {
            expirable = bit32.band(mask, 16) ~= 0,
            limited = bit32.band(mask, 32) ~= 0,
        } or nil,
        category = bit32.band(mask, 64) ~= 0 and 24 or 0,
    }
    local droneDenied = not item.skip and item.drone and item.deployed
    local limitedDenied = not item.skip and not droneDenied and item.raw ~= nil
        and (item.raw.expirable or item.category == 24) and item.raw.limited
    local expected = "item1"
    if droneDenied then expected ..= ";drone"
    elseif limitedDenied then expected ..= ";work;limited"
    elseif item.skip then expected ..= ";complete"
    else expected ..= ";work;tail;complete" end
    local log = {}
    local result = table.pack(scan({item}, log))
    assert(result.n == 2)
    assert(result[1] == ((droneDenied or limitedDenied) and "denied" or "complete"))
    assert(result[2] == ((droneDenied or limitedDenied) and 1 or false))
    assert(table.concat(log, ";") == expected)
    checks += 4
end
local log = {}
local result = table.pack(scan({}, log))
assert(result.n == 2 and result[1] == "complete" and result[2] == false)
assert(table.concat(log, ";") == "complete")
log = {}
result = table.pack(scan({{}, {raw={expirable=true, limited=true}}, {}}, log))
assert(result.n == 2 and result[1] == "denied" and result[2] == 2)
assert(table.concat(log, ";") == "item1;work;tail;item2;work;limited")
assert(checks == 512)
print("private loop terminal fixture: 517 assertions passed")
