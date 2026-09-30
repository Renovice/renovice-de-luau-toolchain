-- FIXED 2026-09-30 (DEFECTS #40, d51d877e); was the UNFIXED repro of RESEARCH/CFG_CLASS_FIXES_2026-09-30/repro. RailjackHudTrackers p2 shape.
-- The first loop body {IsNull test, GameStarted test, Sleep} keeps two exits when its exit target is
-- another loop header (with a plain statement after the loop it reduces and PASSes); NaturalLoop then
-- collapses it unreduced and the emitter drops the
-- `IsNull(gGameRules) -> Sleep` branch: GameStarted is called even when gGameRules is null.
function Track()
    while IsNull(gGameRules) or not gGameRules:GameStarted() do
        Sleep(1)
    end
    while true do
        if not IsNull(gA) and gB ~= nil then
            print("ready")
            while true do
                Tick()
                Sleep(0)
            end
        end
        Sleep(1)
    end
end
