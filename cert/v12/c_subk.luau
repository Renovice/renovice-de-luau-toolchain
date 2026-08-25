-- NATIVE SUBK 0x3e: R[A] = R[B] - K[C]. Operand ORDER is the thing under test.
function OnInit()
  local function t(a)
    -- 10 - 3 = 7 ; if operands were reversed we would see -7 ; if it were ADDK, 13 ; MULK, 30
    error("V12_SUBK subk=" .. tostring(a - 3) .. " subk2=" .. tostring(a - 25))
  end
  t(10)   -- second case goes negative: 10-25 = -15  (reversed would be +15)
end
