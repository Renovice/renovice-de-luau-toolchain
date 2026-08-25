-- Isolated reproduction of multest check1 (six*seven == fortyone+one) in the 26-param frame.
function OnInit()
    local function b(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                     twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                     sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        if six * seven == fortyone + one then else error("mB_BAD") end
        error("mB_OK")
    end
    b(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
      "a", "b", "c", "abc", "abcd", false, true)
end
