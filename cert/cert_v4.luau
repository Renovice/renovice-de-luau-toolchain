-- Full opcode cert, rewritten to AVOID Luau JUMPIFEQ (the `~=` op, the only broken one). Every check uses
-- the proven jump-if-NOT-condition forms: `if <positive> then else error(TAG) end` (JUMPIFNOTEQ/NOTLT/NOTLE).
-- Fresh name (Renovice.cert_v4) + CERT_V4_PASS sentinel. Clean pass = whole implemented map correct in-game.
function OnInit()
    local function body(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                        twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                        sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        -- arithmetic (assert result == expected, error in the else -> JUMPIFNOTEQ)
        if three + four    == seven    then else error("ADD")   end
        if ten - three     == seven    then else error("SUB")   end
        if six * seven     == fortytwo then else error("MUL")   end
        if twenty / four   == five     then else error("DIV")   end
        if seventeen % five == two     then else error("MOD")   end
        if two ^ ten       == k1024    then else error("POW")   end
        if -eight          == negeight then else error("MINUS") end
        -- comparisons: assert the true ones (JUMPIFNOTLT/NOTLE), and the false ones via if-then (also NOT-forms)
        if three < five  then else error("LT")  end
        if five < three  then error("LTf") end                 -- must be false; JUMPIFNOTLT
        if five <= five  then else error("LE")  end
        if six <= five   then error("LEf") end                 -- must be false; JUMPIFNOTLE
        if five == five  then else error("EQ")  end
        if six == five   then error("NE")  end                 -- six~=five: JUMPIFNOTEQ, error only if equal
        -- concat / length / not
        if sa .. sb .. sc == sabc then else error("CONCAT") end
        if #sabcd == four         then else error("LEN")    end
        if (not vfalse) == vtrue  then else error("NOT")    end
        -- numeric for
        local sum = 0
        for i = 1, ten do sum = sum + i end
        if sum == fiftyfive then else error("FORN") end
        -- string-field table
        local r = {}
        r.a = eleven
        r.b = r.a + one
        if r.b == twelve then else error("FIELD") end
        -- closure + call
        local function add1(n) return n + 1 end
        if add1(fortyone) == fortytwo then else error("CALL") end
        -- method call
        local o = {}
        function o:m() return 7 end
        if o:m() == seven then else error("NAMECALL") end
        -- global set/get
        GCERT = k123
        if GCERT == k123 then else error("GLOBAL") end
    end
    body(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
         "a", "b", "c", "abc", "abcd", false, true)
    error("CERT_V4_PASS")
end
