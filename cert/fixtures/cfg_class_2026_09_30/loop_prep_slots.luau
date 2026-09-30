-- Gate fixture (2026-09-30, cfg-identity S4): a numeric `for` with constant bounds. The original
-- loads limit, step and index straight into the loop registers A..A+2; the decompiled source loads
-- them into locals and copies them in. FORNPREP reads the range A..A+2, and the old slot rule matched
-- A+1/A+2 against the instruction's B/C fields (a jump offset), so the unobservable load order
-- depended on register allocation (44.0.2 StreamShipQuestLayers: `for i = 400, 415` reported
-- LOAD -> LOAD). This exact body/prologue makes the decompiled prep hit that coincidence.
local layers = { [403] = "ship", [410] = "dock" }
local total = 0
local function FindLayer(name)
    local p0 = total * 2
    for i = 400, 415 do
        total = total + 2
        if layers[i] == name then
            return i
        end
    end
    return nil
end
print("result", FindLayer("dock"), FindLayer("ship"), FindLayer("none"), total)
