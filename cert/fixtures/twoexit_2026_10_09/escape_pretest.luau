-- Regression fixture (2026-10-09, DEFECTS #76, pre-test construct head), compiled at -O2. 44.1.1
-- Eidolon_Bomber p4 shape: the inlined helper `if t ~= nil then for ... return list[i] end end
-- return nil` jumps from its guard straight to the `return nil` block, which is also the loop's
-- normal-exit code, while the found arm skips it. The construct therefore starts at the guard:
--     local sel = 0; if t ~= nil then for ... sel = 1; break ... end end; if sel ~= 1 then r = nil end
-- The legacy rendering passes CFG-ID but reads the numeric for's index after the loop (the start
-- value: `pick b 1` instead of `pick b 2`); dataflow-identity catches it.
-- Opt-out: RENOVICE_NO_CFG_LOOP_ESCAPE_PRETEST.
local function FindOfType(t, list)
    if t ~= nil then
        for i = 1, #list do
            if list[i].kind == t then
                return list[i]
            end
        end
    end
    return nil
end
local spawns = { { kind = "a", pos = 1 }, { kind = "b", pos = 2 } }
function Pick(kind)
    local found = FindOfType(kind, spawns)
    local where = -1
    if found ~= nil then
        where = found.pos
    end
    print("pick", kind, where)
    return where
end
Pick("b")
Pick("z")
Pick(nil)
