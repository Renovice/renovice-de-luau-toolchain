-- RENOVICE full opcode certification -- SELF-CHECKING, in the proven OnInit module form.
-- Every operand is a runtime PARAMETER (no constant folding) and every result is compared against another
-- PARAMETER (reg-vs-reg fused branches, not const-compares). Each check runs error(TAG) only if that opcode
-- is wrong. So a CLEAN finish (INST+0x30 low=2, no EE.log error) == the whole implemented opcode map is
-- correct; an error (low=3) puts the failing TAG in EE.log. Asymmetric values also verify operand order.
function OnInit()
    local function body(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                        twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                        sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        -- ARITHMETIC (asymmetric => operand order verified)
        if three + four    ~= seven    then error("ADD")   end
        if ten - three     ~= seven    then error("SUB")   end
        if six * seven     ~= fortytwo then error("MUL")   end
        if twenty / four   ~= five     then error("DIV")   end
        if seventeen % five ~= two     then error("MOD")   end
        if two ^ ten       ~= k1024    then error("POW")   end
        if -eight          ~= negeight then error("MINUS") end
        -- COMPARISONS (both directions)
        if not (three < five)  then error("LT")  end
        if five < three        then error("LTf") end
        if not (five <= five)  then error("LE")  end
        if six <= five         then error("LEf") end
        if not (five == five)  then error("EQ")  end
        if not (six ~= five)   then error("NE")  end
        -- CONCAT + LENGTH
        if sa .. sb .. sc ~= sabc then error("CONCAT") end
        if #sabcd ~= four         then error("LEN")    end
        -- NOT
        if (not vfalse) ~= vtrue then error("NOT") end
        -- NUMERIC FOR
        local sum = 0
        for i = 1, ten do sum = sum + i end
        if sum ~= fiftyfive then error("FORN") end
        -- STRING-FIELD table
        local r = {}
        r.a = eleven
        r.b = r.a + one
        if r.b ~= twelve then error("FIELD") end
        -- CLOSURE (nups=0) + CALL
        local function add1(n) return n + 1 end
        if add1(fortyone) ~= fortytwo then error("CALL") end
        -- METHOD call (NAMECALL)
        local o = {}
        function o:m() return 7 end
        if o:m() ~= seven then error("NAMECALL") end
        -- GLOBAL set/get
        GCERT = k123
        if GCERT ~= k123 then error("GLOBAL") end
    end
    body(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
         "a", "b", "c", "abc", "abcd", false, true)
    -- All checks passed -> announce it (turns success into an observable EE.log line; no U1 ambiguity).
    -- If instead a check failed, error(TAG) above already fired with the failing opcode's name.
    error("CERT_ALL_PASS")
end
-- NO chunk return: require asserts the chunk returns NOTHING (0 values); matches the proven gc_loop.
