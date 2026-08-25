-- Ground-truth truth-table fixture for pure-test short-circuit predicate reconstruction.
-- Keep all operands as function parameters so the compiler cannot constant-fold the topology.
local function same_target(p, q)
    if p or q then return 1 end
    return 0
end

local function mirror(p, q)
    if (not p) and q then return 1 end
    return 0
end

local function nested_mirror(p, q, r)
    if not (p or q) and r then return 1 end
    return 0
end

local function mixed(p, q, r)
    if p or ((not q) and r) then return 1 end
    return 0
end

local function row(pi, qi, ri, p, q, r)
    print(pi, qi, ri,
          same_target(p, q), mirror(p, q), nested_mirror(p, q, r), mixed(p, q, r))
end

-- Deliberately explicit: this gate targets predicate reconstruction, not the still-open loop layer.
row(0, 0, 0, false, false, false)
row(0, 0, 1, false, false, true)
row(0, 1, 0, false, true, false)
row(0, 1, 1, false, true, true)
row(1, 0, 0, true, false, false)
row(1, 0, 1, true, false, true)
row(1, 1, 0, true, true, false)
row(1, 1, 1, true, true, true)
