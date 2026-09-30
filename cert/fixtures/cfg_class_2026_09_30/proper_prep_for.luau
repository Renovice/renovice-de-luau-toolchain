-- Regression fixture (2026-09-30, DEFECTS #48): 44.0.2 MatchTagAndSourceType p2 shape. Compiled at
-- -O2, so both helper loops are INLINED into Match: each inlined `return true` becomes `r = true`
-- plus a jump past the loop's normal-exhaustion `r = false`, i.e. a two-exit loop whose FORNPREP /
-- FORGPREP is a separate child of the Proper region. The dispatcher dissolved the loops into raw
-- states: the numeric FORNPREP became `<` comparisons, the FORNLOOP/FORGLOOP back edges fell
-- through, and each body ran at most once. Own code, mock natives.
local acceptedTags = { "a", "b", "c" }
local acceptedTypes = { "T1", "T2" }
local function IsTagAccepted(tag)
    for i = 1, #acceptedTags do
        if tag == tostring(acceptedTags[i]) then
            return true
        end
    end
    return false
end
local function IsTypeAccepted(obj)
    for _, t in pairs(acceptedTypes) do
        if obj:IsA(t) then
            return true
        end
    end
    return false
end
local function Match(src, tag, obj)
    if IsNull(obj) or IsNull(src) then
        return false
    end
    if IsTagAccepted(tag) and IsTypeAccepted(obj) then
        return true
    end
    return false
end
function IsNull(v) return v == nil end
local obj = { IsA = function(self, t) print("IsA", t) return t == "T2" end }
print(Match(1, "b", obj), Match(1, "z", obj), Match(nil, "b", obj), Match(1, "c", { IsA = function() return false end }))
