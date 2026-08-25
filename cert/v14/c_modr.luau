-- MODR 0x00 identification. Carrier is a single MUL (0x22, same R[A]=R[B] op R[C] layout),
-- whose opcode byte is then rewritten to 0x00. Operands 17 and 5 make EVERY candidate distinct:
--   MUL 85 | MOD 2 | MOD-swapped 5 | DIV 3.4 | DIV-swapped 0.294... | ADD 22 | SUB 12 | SUB-swap -12 | IDIV 3
function OnInit()
  local function t(a, b)
    error("V14_MODR r=" .. tostring(a * b))
  end
  t(17, 5)
end
