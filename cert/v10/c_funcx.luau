-- AUTO-GENERATED behavioural matrix: FUNCX
function OnInit()
  local function t(unused)
    local acc = 0
    local bump = function(n) acc = acc + n return acc end
    if bump(1) == 1 then else error("U_cap1") end
    if bump(2) == 3 then else error("U_cap2") end
    if acc == 3 then else error("U_cap_direct") end
    local function add(x, y) return x + y end
    if add(2,3) == 5 then else error("U_call") end
    local function multi() return 1, 2, 3 end
    local m1, m2, m3 = multi()
    if m1 == 1 then else error("U_multi1") end
    if m2 == 2 then else error("U_multi2") end
    if m3 == 3 then else error("U_multi3") end
    local function va(...) local x, y = ... return (x or 0) + (y or 0) end
    if va(3,4) == 7 then else error("U_vararg") end
    if va(3) == 3 then else error("U_vararg_short") end
    if select("#", 1, 2, 3) == 3 then else error("U_select") end
    local function fact(n) if n <= 1 then return 1 end return n * fact(n-1) end
    if fact(5) == 120 then else error("U_recurse") end
    local o = {}
    function o:m(x) return x * 2 end
    if o:m(4) == 8 then else error("U_method") end
    local fs = {}
    for i = 1, 3 do fs[i] = function() return i end end
    if fs[1]() == 1 then else error("U_closeup1") end
    if fs[3]() == 3 then else error("U_closeup3") end
    local outer = 5
    local function mid() local function inner() return outer end return inner() end
    if mid() == 5 then else error("U_nested_upval") end
    local ok, err = pcall(function() error("boom") end)
    if ok then error("U_pcall_shouldfail") end
    error("V10_FUNCX_OK")
  end
  t(0)
end
