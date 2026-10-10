-- Regression fixture (2026-10-09, DEFECTS #77): a source while leaving by its header test, a
-- `break` and a bare RETURN shared by two tests (`if IsNull(a) or IsNull(b) then return end`), the
-- 44.1.1 InfestedPredatorFinisherSpores p3 / ExplosiveDissolve p6 class. The CFG renderer printed the
-- shared return (and statement-carrying break arms) as `break` and left those blocks unowned, so the
-- whole prototype fell back to the legacy region emitter, which here duplicated the following `for`
-- (the body ran 1 + 2 + ... times). Fixed: the while's private break/return arms join its render
-- domain and its header exit is a recognised `break` target. Opt-out: RENOVICE_NO_CFG_WHILE_LOOP_ARMS.
function IsNull(v) return v == nil end
function Run(a, b, n)
    local t = n
    while 0 < t do
        if IsNull(a) or IsNull(b) then
            return
        end
        if a.d < 2 then
            break
        end
        a.d = a.d - 1
        t = t - 1
    end
    if IsNull(a) or IsNull(b) then
        return
    end
    print("after", a.d, t)
    for i = 1, 2 do
        if IsNull(b[i]) then
            continue
        end
        print("b", i)
    end
end
Run({ d = 5 }, { 1, 2 }, 9)
Run({ d = 9 }, { 1 }, 3)
Run(nil, {}, 3)
