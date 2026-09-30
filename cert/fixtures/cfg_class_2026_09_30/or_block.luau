-- Gate normalization fixture (2026-09-30, S5, DEFECTS #50): stock DE bytecode has a native ORK for
-- `x or 0`; our rebuild lowers it to MOVE + JUMPIF + LOAD, which split the straight-line block, so a
-- pure GETIMPORT before it could not sink past it (44.0.2 DialogTree: `_T.X = _T.X or 0` compared as
-- GETIMPORT _T -> GETIMPORT _T.X). The harness compiles the original with RENOVICE_NATIVE=ORK (the
-- stock form) and predefines _T before loading the chunk (import resolution).
local function Tick(dt)
    _T.Timer = _T.Timer or 0
    _T.Timer = _T.Timer + dt
    if _T.Timer >= 1 then
        _T.Timer = nil
        return true
    end
    return false
end
print(Tick(0.5), Tick(0.6), Tick(0.2))
