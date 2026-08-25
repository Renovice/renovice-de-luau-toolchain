function OnInit()
  local function t(one, two, seven)
    local acc = 0                               -- captured, mutable
    local function bump(n) acc = acc + n return acc end   -- NEWCLOSURE + CAPTURE + GETUPVAL/SETUPVAL
    bump(one)
    if bump(two) == 3 then else error("F_CAPTURE") end
    local function plain(a, b) return a + b end  -- DUPCLOSURE (no upvalues)
    if plain(one, two) == 3 then else error("F_CALL") end
    local obj = {}
    function obj:m(x) return x + one end         -- method def (SETTABLEKS) + NAMECALL
    if obj:m(two) == 3 then else error("F_NAMECALL") end
    local function va(...)                       -- GETVARARGS
      local a, b = ...
      return (a or 0) + (b or 0)
    end
    if va(one, two) == 3 then else error("F_VARARG") end
    local fs = {}
    for i = 1, 3 do fs[i] = function() return i end end   -- CLOSEUPVALS (per-iteration capture)
    if fs[2]() == 2 then else error("F_CLOSEUPVALS") end
    V9GLOB = seven                               -- SETGLOBAL + _G mirror
    if V9GLOB == 7 then else error("F_GLOBAL") end
    if math.floor(2.7) == 2 then else error("F_BUILTIN") end   -- GETIMPORT + FASTCALL-dropped
    error("V9_FUNC_OK")
  end
  t(1, 2, 7)
end
