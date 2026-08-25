-- EXACT cert_v4 26-param frame. Splits the MUL check into independent sub-tests so the failing tag names
-- the real culprit. computed42 = fortyone+one (ADD only, proven). All compares are reg==reg (JUMPIFNOTEQ).
function OnInit()
    local function b(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                     twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                     sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        local prod       = six * seven        -- expect 42
        local computed42 = fortyone + one     -- 41 + 1 = 42, via ADD (proven)
        if prod == computed42     then else error("MUL_result_wrong") end   -- MUL correctness, no fortytwo param
        if fortytwo == computed42 then else error("param15_wrong")   end    -- fortytwo(R14) delivery
        if prod == fortytwo       then else error("cert_repro")      end    -- the exact cert MUL compare
        error("MULTEST_OK")
    end
    b(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
      "a", "b", "c", "abc", "abcd", false, true)
end
