-- Regression fixture (2026-09-30, DEFECTS #40): a loop whose continuation test is a short-circuit
-- chain with a statement operand, followed by another loop (44.0.2 RailjackHudTrackers proto 2):
--   while IsNull(gGameRules) or not gGameRules:GameStarted() do Sleep(1) end
-- The loop body {IsNull test, GameStarted test, Sleep} kept two in-loop successors at its header;
-- no rule reduced it, NaturalLoop collapsed it unreduced, and the emitter dropped the
-- `IsNull -> Sleep` branch, so the rebuild called GameStarted() on a nil gGameRules.
-- The harness predefines IsNull, Sleep and gGameRules as globals (the stock GETIMPORT shape).
local function Track()
    while IsNull(gGameRules) or not gGameRules:GameStarted() do
        Sleep(1)
    end
    print("started")
    while true do
        if not IsNull(gGameRules) and gGameRules:GetCrewShipManager() ~= nil then
            print("ready")
            while true do
                Sleep(0)
            end
        end
        Sleep(1)
    end
end

print("result", pcall(Track))
