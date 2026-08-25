-- 26 params as 13 equal pairs; each check `q == q_dup` is reg==reg (JUMPIFNOTEQ, proven; aux = q_dup's reg).
-- The compare aux register climbs with pair index: P01 aux=R1 ... P13 aux=R25. The FIRST error("Pnn") reveals
-- the register threshold where high-register operands (arg-passing OR fused-compare aux) break.
-- ARGSCAN2_OK => all 26 registers deliver + compare correctly, so cert_v4's MUL failure lies elsewhere.
function OnInit()
    local function b(q1,q1b, q2,q2b, q3,q3b, q4,q4b, q5,q5b, q6,q6b, q7,q7b,
                     q8,q8b, q9,q9b, q10,q10b, q11,q11b, q12,q12b, q13,q13b)
        if q1  == q1b  then else error("P01_r1")  end
        if q2  == q2b  then else error("P02_r3")  end
        if q3  == q3b  then else error("P03_r5")  end
        if q4  == q4b  then else error("P04_r7")  end
        if q5  == q5b  then else error("P05_r9")  end
        if q6  == q6b  then else error("P06_r11") end
        if q7  == q7b  then else error("P07_r13") end
        if q8  == q8b  then else error("P08_r15") end
        if q9  == q9b  then else error("P09_r17") end
        if q10 == q10b then else error("P10_r19") end
        if q11 == q11b then else error("P11_r21") end
        if q12 == q12b then else error("P12_r23") end
        if q13 == q13b then else error("P13_r25") end
        error("ARGSCAN2_OK")
    end
    b(11,11, 22,22, 33,33, 44,44, 55,55, 66,66, 77,77,
      88,88, 99,99, 110,110, 121,121, 132,132, 143,143)
end
