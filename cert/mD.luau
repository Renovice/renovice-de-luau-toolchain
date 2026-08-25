-- KEY probe: value-check six*seven using ORDERED compares (proven value-comparing), NOT equality.
-- If prod brackets to exactly 42, MUL is correct and any cert MUL failure is an EQUALITY-op problem.
function OnInit()
    local function b(one, two, three, four, five, six, seven, eight, ten, eleven, twelve, seventeen,
                     twenty, fortyone, fortytwo, fiftyfive, k1024, negeight, k123,
                     sa, sb, sc, sabc, sabcd, vfalse, vtrue)
        local prod = six * seven
        if fortyone < prod       then else error("prod_le_41") end   -- 41 < prod => prod >= 42
        if prod < fortytwo + one then else error("prod_ge_43") end   -- prod < 43 => prod <= 42
        error("mD_prod_IS_42")                                       -- reached => prod == 42 exactly
    end
    b(1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 17, 20, 41, 42, 55, 1024, -8, 123,
      "a", "b", "c", "abc", "abcd", false, true)
end
