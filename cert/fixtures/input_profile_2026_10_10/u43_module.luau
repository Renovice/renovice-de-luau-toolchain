-- RENOVICE_HASH_FIELD: SeasonToStr
-- RENOVICE_HASH_FIELD: GetCurrentSeason
-- Stale U43-profile module shape (44.1.1 cache: EE_Scripts_ImGui*, Lotus_Scripts_Cmds_*): hashed
-- field reads on a library table, globals, branches, a numeric and a generic loop and a closure.
-- The original is built with the U43 `recompile`, so it is U43-profile bytecode with U43 hashes.
local Lib = {}
Lib.SeasonToStr = function(value)
    if value == 1 then
        return "spring"
    elseif value == 2 then
        return "summer"
    end
    return "season " .. tostring(value)
end
Lib.GetCurrentSeason = function()
    return 2
end
local names = {}
for index = 1, 3 do
    names[#names + 1] = Lib.SeasonToStr(index)
end
local total = 0
for _, name in ipairs(names) do
    total = total + string.len(name)
end
local current = Lib.GetCurrentSeason()
local function describe(prefix)
    return prefix .. ":" .. Lib.SeasonToStr(current) .. ":" .. total
end
print(table.concat(names, ","))
print(describe("now"))
while total > 10 do
    total = total - 7
end
print("left", total)
