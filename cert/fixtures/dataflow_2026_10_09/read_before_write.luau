-- Dataflow-identity control (2026-10-09): the SetVortexWindPerZone class, a register read before its
-- assignment. The mutant (cert/dataflow_identity_fixtures.py) keeps every operation and its order but
-- passes the unassigned local instead of the call result: CFG-ID cannot see the difference (register
-- operands are not compared), dataflow-identity must. Own code, mock natives.
local function Compute(zone)
    return { zone = zone, strength = zone * 2 }
end
local function Normalize(value)
    if value == nil then return "nil" end
    return value.zone .. ":" .. value.strength
end
local function SetWind(zones)
    for zone = 1, zones do
        local wind = Compute(zone)
        print("wind", Normalize(wind))
    end
end
SetWind(3)
