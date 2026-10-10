-- Regression fixture (render campaign 2026-10-10, DISJOINT GUARD ARMS), compiled at -O2. A local
-- search helper inlined into an if/elseif chain: `if Contains(a) then r = true elseif not
-- Contains(b) then return true else r = false end; print(r)`. The inlined `return true` jumps past
-- the shared `print` (the guard effect), so both arms of the first test lead to the effect or the
-- exit through their own chains and no real join exists (the EventVendorPlatformDisplay p3 shape;
-- reported open by the wave-2 conditions agent, work/agents/conditions-runs/fixtures/
-- inlined_search_two_exit.luau). The CFG renderer refused the main chunk
-- (GUARD_CHAIN_NO_BOUNDARY_EDGE) and the legacy region emitter printed the `for` twice and lost the
-- compare. Opt-out: RENOVICE_NO_CFG_GUARD_DISJOINT_ARMS.
local function Contains(t, x)
    for _, v in ipairs(t) do
        if v == x then
            return true
        end
    end
    return false
end
local active = { "a", "b" }
local inactive = { "c" }
local function IsActive(tag)
    local result = false
    if Contains(active, tag) then
        result = true
    elseif not Contains(inactive, tag) then
        return true
    else
        result = false
    end
    print("tag", tag, result)
    return result
end
print(IsActive("a"), IsActive("c"), IsActive("z"))
