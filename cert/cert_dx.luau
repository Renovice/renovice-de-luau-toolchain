-- Fresh-named isolation (Renovice.cert_dx), base fix already confirmed. Pinpoints the cert_v3 "ADD" failure:
-- polarity of JUMPIFEQ vs ADD vs param-passing. Only 5 args, so a pass here rules out a many-arg CALL issue.
function OnInit()
    local function t(a5, b5, three, four, seven)     -- a5=b5=5 ; three=3,four=4,seven=7
        if a5 ~= b5 then error("VX_EQ_BAD") end       -- a5==b5 -> ~= false -> must NOT error (isolates JUMPIFEQ polarity)
        local s = three + four
        if s ~= seven then error("VX_ADD_BAD") end     -- 3+4==7 -> must NOT error (ADD + compare)
        error("VX_ALL_OK")                             -- reached => JUMPIFEQ polarity + ADD both correct
    end
    t(5, 5, 3, 4, 7)
end
