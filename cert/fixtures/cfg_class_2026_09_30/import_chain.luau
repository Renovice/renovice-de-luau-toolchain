-- Regression fixture (2026-09-30): a string-indexed read of a global table, `_T[NAME]` with a
-- constant local NAME, compiles to GETIMPORT _T + GETFIELD "NAME". The base-temporary folds
-- printed it as `_T.NAME`, which Luau compiles to ONE two-part GETIMPORT: a load-time snapshot
-- in a safe environment, not a live read. The harness predefines `_T.RenoviceImportFixture` as
-- "stale" before loading this chunk; the stock program prints "fresh".
local NAME = "RenoviceImportFixture"

local function Init()
    _T[NAME] = "fresh"
    print("value", _T[NAME])
    local other = _T.RenoviceOther
    print("other", other)
end

Init()
