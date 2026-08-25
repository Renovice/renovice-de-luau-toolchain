-- Clean confirmation cert: arith (confirmed) + all compares + concat/len/not + numeric-for + closure-call
-- + global set/get. NO table-field WRITES (SETTABLEKS crashes until the key-encoding fix). CERT_V6_PASS sentinel.
function OnInit()
    local function body(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                        twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                        sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        if three + four    == seven    then else error("ADD")   end
        if ten - three     == seven    then else error("SUB")   end
        if six * seven     == fortytwo then else error("MUL")   end
        if twenty / four   == five     then else error("DIV")   end
        if seventeen % five == two     then else error("MOD")   end
        if two ^ 10        == k1024    then else error("POW")   end
        if -eight          == negeight then else error("MINUS") end
        if three < five  then else error("LT")  end
        if five < three  then error("LTf") end
        if five <= five  then else error("LE")  end
        if six <= five   then error("LEf") end
        if five == five  then else error("EQ")  end
        if six == five   then error("NE")  end
        if sa .. sb .. sc == sabc then else error("CONCAT") end
        if #sabcd == four         then else error("LEN")    end
        if (not vfalse) == vtrue  then else error("NOT")    end
        local sum = 0
        for i = 1, ten do sum = sum + i end
        if sum == fiftyfive then else error("FORN") end
        local function add1(n) return n + 1 end
        if add1(fortyone) == fortytwo then else error("CALL") end
        GCERT6 = k123
        if GCERT6 == k123 then else error("GLOBAL") end
    end
    body(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
         "a", "b", "c", "abc", "abcd", false, true)
    error("CERT_V6_PASS")
end
