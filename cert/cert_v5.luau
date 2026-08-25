-- Full opcode cert v5: arith now CONFIRMED (SUB=0x07 MUL=0x22 DIV=0x1a MOD=0x55 MINUS=0x0e), pow uses
-- pow-by-CONSTANT (two ^ 10 -> POWK=0x08, correct; reg-reg POW is a separate TBD). Fresh CERT_V5_PASS sentinel.
function OnInit()
    local function body(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                        twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                        sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        if three + four    == seven    then else error("ADD")   end
        if ten - three     == seven    then else error("SUB")   end
        if six * seven     == fortytwo then else error("MUL")   end
        if twenty / four   == five     then else error("DIV")   end
        if seventeen % five == two     then else error("MOD")   end
        if two ^ 10        == k1024    then else error("POW")   end   -- pow-by-const -> POWK
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
        local r = {}
        r.a = eleven
        r.b = r.a + one
        if r.b == twelve then else error("FIELD") end
        local function add1(n) return n + 1 end
        if add1(fortyone) == fortytwo then else error("CALL") end
        local o = {}
        function o:m() return 7 end
        if o:m() == seven then else error("NAMECALL") end
        GCERT5 = k123
        if GCERT5 == k123 then else error("GLOBAL") end
    end
    body(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
         "a", "b", "c", "abc", "abcd", false, true)
    error("CERT_V5_PASS")
end
