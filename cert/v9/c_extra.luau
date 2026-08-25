function OnInit()
  local function t(two, three, five, ten)
    local a, b, c = three                     -- b,c = nil  -> LOADNIL
    if a == 3 then else error("X_MULTI") end
    if b == nil then else error("X_LOADNIL") end
    if c == nil then else error("X_LOADNIL2") end
    if five >= three then else error("X_GE") end   -- JUMPIFLT polarity
    if three >= five then error("X_GEf") end
    if five > three then else error("X_GT") end
    if three > five then error("X_GTf") end
    if 20 / five == 4 then else error("X_DIVRK") end -- const / reg
    if 20 % three == 2 then else error("X_MODRK") end
    local orv = b or ten                      -- ORK/OR with nil lhs
    if orv == 10 then else error("X_OR_NIL") end
    local andv = a and ten
    if andv == 10 then else error("X_AND") end
    local andn = b and ten
    if andn == nil then else error("X_AND_NIL") end
    local lt = three < five                   -- JUMPIFLT (value-producing compare)
    if lt == true then else error("X_LT_VAL") end
    local ge = five < three
    if ge == false then else error("X_LT_VAL2") end
    local r = 0
    repeat r = r + 1 until r < 0 or r >= three  -- repeat-until with < (JUMPIFLT)
    if r == 3 then else error("X_REPEAT_LT") end
    error("V9_EXTRA_OK")
  end
  t(2, 3, 5, 10)
end
