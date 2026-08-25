-- Full opcode certification, FRESH NAME (Renovice.cert_v3) so it can't hit a stale require cache, with a
-- version-tagged PASS sentinel. Same self-checking body as cert_all. Clean load (after a game restart) =
-- CERT_V3_PASS means every implemented opcode is correct in-game; any opcode TAG = that one op to fix.
function OnInit()
    local function body(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                        twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                        sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        if three + four    ~= seven    then error("ADD")   end
        if ten - three     ~= seven    then error("SUB")   end
        if six * seven     ~= fortytwo then error("MUL")   end
        if twenty / four   ~= five     then error("DIV")   end
        if seventeen % five ~= two     then error("MOD")   end
        if two ^ ten       ~= k1024    then error("POW")   end
        if -eight          ~= negeight then error("MINUS") end
        if not (three < five)  then error("LT")  end
        if five < three        then error("LTf") end
        if not (five <= five)  then error("LE")  end
        if six <= five         then error("LEf") end
        if not (five == five)  then error("EQ")  end
        if not (six ~= five)   then error("NE")  end
        if sa .. sb .. sc ~= sabc then error("CONCAT") end
        if #sabcd ~= four         then error("LEN")    end
        if (not vfalse) ~= vtrue then error("NOT") end
        local sum = 0
        for i = 1, ten do sum = sum + i end
        if sum ~= fiftyfive then error("FORN") end
        local r = {}
        r.a = eleven
        r.b = r.a + one
        if r.b ~= twelve then error("FIELD") end
        local function add1(n) return n + 1 end
        if add1(fortyone) ~= fortytwo then error("CALL") end
        local o = {}
        function o:m() return 7 end
        if o:m() ~= seven then error("NAMECALL") end
        GCERT = k123
        if GCERT ~= k123 then error("GLOBAL") end
    end
    body(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
         "a", "b", "c", "abc", "abcd", false, true)
    error("CERT_V3_PASS")
end
