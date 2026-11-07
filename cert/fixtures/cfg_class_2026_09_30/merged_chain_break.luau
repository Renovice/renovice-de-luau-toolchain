-- 2026-11-07 (SwiftDethAbility p7): a loop break under `(not A or (B and C)) and D`. The chain
-- `B and C` merged first; as a merged node it looked like a block with statements (its tests'
-- instructions, and the first test's own setup `t:Name()`), so `not A or (...)` never joined it.
-- The two halves rendered as one `if` inside `repeat ... until true`: the loop break became a skip.
local target = { n = 0, avatar = { frozen = false } }
function target:Name()
  self.n = self.n + 1
  return self.n % 3 ~= 0
end
function target.avatar:Frozen()
  return self.frozen
end
local count, steps = 0, 0
while steps < 12 do
  steps = steps + 1
  if steps == 4 then target.avatar.frozen = true end
  if steps == 6 then count = 1 end
  if (not target:Name() or (target:Name() and target.avatar:Frozen())) and 0 < count then
    break
  end
  print("step", steps, target.n)
end
print("done", steps, target.n, count)
