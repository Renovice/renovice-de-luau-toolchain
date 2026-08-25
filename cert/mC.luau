-- Verify the MUL operands + fortytwo actually hold their values in the 26-param frame, via proven ADD.
function OnInit()
    local function b(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                     twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                     sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        if six      == five + one     then else error("six_NOT_6")      end   -- 5+1=6
        if seven    == five + two     then else error("seven_NOT_7")    end   -- 5+2=7
        if fortytwo == fortyone + one then else error("fortytwo_NOT_42") end  -- 41+1=42
        error("mC_operands_OK")
    end
    b(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
      "a", "b", "c", "abc", "abcd", false, true)
end
