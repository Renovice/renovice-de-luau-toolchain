-- Regression fixture (2026-09-30, DEFECTS #49): compiler-closure of a two-exit loop. `while #t > 0 do
-- ... if not Resists(t) then Fire(p, t) break end ... end` inside an `if` is rendered with a generated
-- escape selector; flattening its repeat-once shell kept an empty `sel == -1` guard, which compiled to
-- a real compare. Every re-decompile printed that compare with its constant in a fresh register and
-- the re-derived selector shell left a new residue, so the source never repeated (44.0.2
-- AlchemistVial p7 and 6 more modules stopped converging after #40). Own code, mock natives.
local shots = 0
local function IsNull(value) return value == nil end
local function Resists(target) return target.resist end
local function Fire(projectile, target) shots = shots + 1; print("fire", projectile, target.name) end
local function Launch(projectile, targets)
    if not IsNull(projectile) then
        print("launch", projectile)
        while #targets > 0 do
            local index = #targets
            local target = targets[index]
            if not Resists(target) then
                Fire(projectile, target)
                break
            end
            table.remove(targets, index)
        end
        print("left", #targets)
    end
end
Launch("p1", { { name = "a", resist = false }, { name = "b", resist = true } })
Launch("p2", { { name = "c", resist = true } })
Launch(nil, {})
print("shots", shots)
