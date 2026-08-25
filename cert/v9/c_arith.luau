function OnInit()
  local function t(x, two, three, five, ten)
    if ten - three == 7 then else error("A_SUB") end
    if three * five == 15 then else error("A_MUL") end
    if ten / five == 2 then else error("A_DIV") end
    if ten % three == 1 then else error("A_MOD") end
    if two ^ 3 == 8 then else error("A_POWK") end
    if -five == -5 then else error("A_MINUS") end
    if three + 4 == 7 then else error("A_ADDK") end
    if three * 4 == 12 then else error("A_MULK") end
    if ten / 4 == 2.5 then else error("A_DIVK") end
    if ten % 4 == 2 then else error("A_MODK") end
    if three - 1 == 2 then else error("A_SUBK") end
    if 20 - three == 17 then else error("A_SUBRK") end
    error("V9_ARITH_OK")
  end
  t(0, 2, 3, 5, 10)
end
