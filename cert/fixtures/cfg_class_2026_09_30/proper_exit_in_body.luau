-- Regression fixture (proper campaign 2026-10-09, 44.1.1 Lotus_Scripts_DeathSquadFlak p0, reduced
-- with renamed methods): a loop body that starts with break tests and holds a short-circuit test
-- with a statement operand,
--   while not IsNull(victim) and not victim:IsKilled() do
--     ... if victim:IsActive(2) or victim:InventoryControl():IsFiring() then ... else ... end ...
-- The `or` reduces to a Proper region that grows over the break tests. The loop-body DAG refused
-- every loop-leaving edge inside a Proper (fail_kind 100), the NaturalLoop kept its interior
-- unreduced and the emitter dropped the `or` test (RENOVICE_NO_PROPER_EXIT_IN_BODY_DAG: IsFiring()
-- ran on every iteration). With the cut body admitted, the dispatcher re-tested each break
-- condition after printing `if c then break end`, a second IF TRUTHY stock never had
-- (RENOVICE_NO_PROPER_EXIT_ARM_ONCE: CFG-only, the behavior is the same).
-- The harness predefines the engine globals and Setup() (PROPER_EXIT_PRELUDE).
local Shake = Symbol("LeechShake")
function OnAttached(self)
  if gRegion:IsMaster() then
    local victim = self:GetAttachParent()
    if not IsNull(victim) and victim:IsA(gBaseAvatarType) then
      self:Destroy()
      local sentinel = victim:IsA(gLotusSentinelAvatarType)
      local npc = victim:IsA(gLotusNpcAvatarType)
      local acc = 0
      local timer = 0
      local limit = Random(0.25, 0.75)
      while not IsNull(victim) and not victim:IsKilled() do
        if npc then self:Destroy() end
        local dt = DeltaTime()
        if victim:IsActive(2) or victim:InventoryControl():IsFiring() then
          self:Destroy()
        else
          acc = acc + dt * damagePerSecond
          if 1 < acc then
            local rest = math.fmod(acc, 1)
            victim:DamageEx(acc, 16, 6, 0, self:GetInstigator(), self)
            acc = rest
          end
        end
        if sentinel then
          if victim:IsReady(Shake) then
            Sleep(0.2)
            self:Destroy()
            return
          end
          timer = timer + dt
          if limit <= timer then
            local a = victim:PlayAnim(Shake, false, 3, 1, true)
            if not IsNull(a) then victim:SuspendScriptUntilAnimEvent("ShakeOff", 2.5) else Sleep(0.5) end
            self:Destroy()
            return
          end
        end
        Sleep(0)
      end
    end
  end
end

print("result", pcall(OnAttached, Setup(false, false)))
print("result", pcall(OnAttached, Setup(true, true)))
