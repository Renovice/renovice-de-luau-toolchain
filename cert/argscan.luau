-- Reproduces cert_v4's EXACT 26-param body() frame, but checks each numeric param in order.
-- First error("Axx") = the first param that arrived wrong => pinpoints where CALL arg-passing breaks.
-- ARGSCAN_OK => arg passing is fine and the cert_v4 MUL failure is a genuine MUL-opcode problem.
-- Uses only the proven JUMPIFNOTEQ (==) branch form. Fresh name via injector generation suffix.
function OnInit()
    local function b(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                     twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                     sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        if one       == 1    then else error("A01_one")       end
        if two       == 2    then else error("A02_two")       end
        if three     == 3    then else error("A03_three")     end
        if four      == 4    then else error("A04_four")      end
        if five      == 5    then else error("A05_five")      end
        if six       == 6    then else error("A06_six")       end
        if seven     == 7    then else error("A07_seven")     end
        if eight     == 8    then else error("A08_eight")     end
        if ten       == 10   then else error("A09_ten")       end
        if eleven    == 11   then else error("A10_eleven")    end
        if twelve    == 12   then else error("A11_twelve")    end
        if seventeen == 17   then else error("A12_seventeen") end
        if twenty    == 20   then else error("A13_twenty")    end
        if fortyone  == 41   then else error("A14_fortyone")  end
        if fortytwo  == 42   then else error("A15_fortytwo")  end
        if fiftyfive == 55   then else error("A16_fiftyfive") end
        if k1024     == 1024 then else error("A17_k1024")     end
        if negeight  == -8   then else error("A18_negeight")  end
        if k123      == 123  then else error("A19_k123")      end
        error("ARGSCAN_OK")
    end
    b(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
      "a", "b", "c", "abc", "abcd", false, true)
end
