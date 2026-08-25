-- AUTO-GENERATED behavioural matrix: ARITHX
function OnInit()
  local function t(zero, negone, two, three, four, ten, negten)
    if (ten + three) == 13 then else error("A_add") end
    if (ten - three) == 7 then else error("A_sub") end
    if (ten * three) == 30 then else error("A_mul") end
    if (ten / four) == 2.5 then else error("A_div") end
    if (ten % three) == 1 then else error("A_mod") end
    if (two ^ three) == 8 then else error("A_pow") end
    if (-ten) == negten then else error("A_unm") end
    if (ten + 4) == 14 then else error("A_addk") end
    if (ten - 4) == 6 then else error("A_subk") end
    if (ten * 4) == 40 then else error("A_mulk") end
    if (ten / 4) == 2.5 then else error("A_divk") end
    if (ten % 4) == 2 then else error("A_modk") end
    if (two ^ 3) == 8 then else error("A_powk") end
    if (ten // 4) == 2 then else error("A_idivk") end
    if (ten // 3) == 3 then else error("A_idivk2") end
    if (20 - ten) == 10 then else error("A_subrk") end
    if (20 / ten) == 2 then else error("A_divrk") end
    if (negten + ten) == 0 then else error("A_negadd") end
    if (negten * negone) == ten then else error("A_negmul") end
    if (three / two) == 1.5 then else error("A_frac") end
    if (negten / four) == -2.5 then else error("A_negfrac") end
    if (zero * ten) == 0 then else error("A_zero") end
    if (ten + zero) == ten then else error("A_addzero") end
    if (negten % three) == 2 then else error("A_negmod") end
    if ((ten + three) * two - four) == 22 then else error("A_precedence") end
    error("V10_ARITHX_OK")
  end
  t(0, -1, 2, 3, 4, 10, -10)
end
