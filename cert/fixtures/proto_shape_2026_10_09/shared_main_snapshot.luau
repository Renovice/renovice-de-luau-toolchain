-- Shared prototype inlined into the MAIN CHUNK with by-value captures (StatsLib 44.1.1): MakeKey is
-- inlined at -O2 into the chunk, so its callback literal is created in the chunk from the inlined
-- parameters, captured by value. Stock keeps NEWCLOSURE there (the captured locals belong to the
-- inlined function); the decompiled snapshots are top-level chunk locals, which Luau would share
-- (DUPCLOSURE) and the shared-prototype merge then refused (src/scoped_captures.h).
local function MakeKey(prefix, sep)
    return function(a, b) return prefix .. b .. sep .. a .. "!" end
end
local handlers = {}
handlers.start = MakeKey(tostring(1), tostring("_"))
handlers.vault = MakeKey(tostring(1) .. "v", tostring("_"))
handlers.stage = MakeKey("STAGE" .. tostring(1), tostring("_"))
print(handlers.start(1, "x"), handlers.vault(2, "y"))
print(handlers.stage(3, "z"), MakeKey ~= nil)
