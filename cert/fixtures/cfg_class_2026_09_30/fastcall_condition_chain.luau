-- 2026-11-07 (NpcSwitchTeleportAbility p5): a while condition whose tests call a fast-called builtin
-- with one register argument (FASTCALL1 hint first in each test's setup, like `IsNull(x)`), as the
-- first statement of a numeric for body. The refused fold left the tests as statements; the loop
-- structured as `while true` with two tests dropped and the after-loop code inside the loop.
local selfDead, camDead = nil, nil
local cam = { shakes = 0 }
local t, ticks = 0, 0
local function step()
  ticks = ticks + 1
  if ticks == 3 then camDead = 1 end
  return 0.2
end
for i = 1, 2 do
  while not tonumber(selfDead) and not tonumber(camDead) and t < 0.5 do
    print("tick", i, t)
    if not tonumber(camDead) then
      t = t + step()
      cam.shakes = cam.shakes + 1
    end
  end
  print("after", i, t, cam.shakes)
  t = 0
  camDead = nil
end
print("done", ticks, cam.shakes)
