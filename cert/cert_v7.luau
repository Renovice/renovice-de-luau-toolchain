-- Cert v7: confirms the audit crash-fixes. arith + all compares + concat/len/not + numeric-for + closure-call
-- + CAPTURE (mutable upvalue) + TABLE FIELD read/write (the cert_v5/v6 crash: SETTABLEKS 0x0c->0x15, key tag-3).
-- AVOIDS: method-definition (shared-const TODO) and bare-global read (GETGLOBAL unmapped, lowers to GETIMPORT TODO).
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
        if five <= five  then else error("LE")  end
        if five == five  then else error("EQ")  end
        if six == five   then error("NE")  end
        if sa .. sb .. sc == sabc then else error("CONCAT") end
        if #sabcd == four         then else error("LEN")    end
        if (not vfalse) == vtrue  then else error("NOT")    end
        local sum = 0
        for i = 1, ten do sum = sum + i end
        if sum == fiftyfive then else error("FORN") end
        -- TABLE FIELD read + write (previously crashed): fresh table, write field, read it back
        local r = {}
        r.a = eleven
        r.b = r.a + one
        if r.b == twelve then else error("FIELD") end
        -- CAPTURE: closure capturing a mutable upvalue
        local acc = 0
        local function bump() acc = acc + one return acc end
        bump()
        if bump() == two then else error("CAPTURE") end
        -- closure call
        local function add1(n) return n + 1 end
        if add1(fortyone) == fortytwo then else error("CALL") end
    end
    body(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
         "a", "b", "c", "abc", "abcd", false, true)
    error("CERT_V7_PASS")
end
