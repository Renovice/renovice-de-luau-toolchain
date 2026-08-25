-- FRESH-NAMED diagnostic (Renovice.cert2) to bypass the require cache, with version-tagged messages so we
-- KNOW the new bytecode ran. Tests the current transcoder fix (JUMPIFEQ=0x20, jump base op+4).
function OnInit()
    local function t(a5, b5, three, four, seven)   -- a5=b5=5 (equal); three=3,four=4,seven=7
        if a5 ~= b5 then error("V3_JEQ_BAD") end    -- a5==b5 so ~= is false -> must NOT error
        local s = three + four
        if s ~= seven then error("V3_ADD_BAD") end   -- 3+4==7 -> must NOT error
        error("V3_ALL_OK")                           -- reached => compare + ADD both correct
    end
    t(5, 5, 3, 4, 7)
end
