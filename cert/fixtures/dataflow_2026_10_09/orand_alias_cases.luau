-- DEFECTS #65 companion (2026-10-09): every register aliasing case of the recompiler's OR/AND lowering,
-- `A = B op C` with A==B, A==C, B==C, A==B==C and distinct registers (luau-compile emits OR R2 R2 R3,
-- OR R2 R3 R2, OR R2 R3 R3, OR R2 R2 R2, OR R4 R2 R3 and the same for AND). Only A==C (B != A) was
-- wrong under the old lowering (RENOVICE_LEGACY_ORAND_LOWERING=1: 4 of 40 printed values differ).
local function Run(p, q)
    local a, b = p, q
    a = a or b;  print("or A==B", a)
    a, b = p, q
    a = b or a;  print("or A==C", a)
    a, b = p, q
    a = b or b;  print("or B==C", a)
    a = p
    a = a or a;  print("or A==B==C", a)
    a, b = p, q
    local c = a or b; print("or none", c)
    a, b = p, q
    a = a and b; print("and A==B", a)
    a, b = p, q
    a = b and a; print("and A==C", a)
    a, b = p, q
    a = b and b; print("and B==C", a)
    a = p
    a = a and a; print("and A==B==C", a)
    a, b = p, q
    local d = a and b; print("and none", d)
end
Run(nil, "q")
Run("p", nil)
Run("p", "q")
Run(false, nil)
