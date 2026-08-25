-- AUTO-GENERATED behavioural matrix: NILX
function OnInit()
  local function t(unused)
    local n = nil
    local f = false
    local z = 0
    local s = ""
    if n == nil then else error("N_nil_eq") end
    if n ~= nil then error("N_nil_ne") end
    if f ~= nil then else error("N_false_ne_nil") end
    if f == nil then error("N_false_eq_nil") end
    if z ~= nil then else error("N_zero_ne_nil") end
    if s ~= nil then else error("N_str_ne_nil") end
    if n then error("N_nil_truthy") end
    if f then error("N_false_truthy") end
    if z then else error("N_zero_should_be_truthy") end
    if s then else error("N_emptystr_truthy") end
    if f == false then else error("N_false_eqfalse") end
    if f ~= true then else error("N_false_netrue") end
    local p
    local cp = function() p = nil end cp()
    if p == nil then else error("N_cap_setnil_eq") end
    if p ~= nil then error("N_cap_setnil_ne") end
    local q = 1
    local cq = function() q = nil end cq()
    if q == nil then else error("N_cap_1tonil") end
    local r
    local cr = function() r = 9 end cr()
    if r == 9 then else error("N_cap_niltonum") end
    if r ~= nil then else error("N_cap_niltonum_ne") end
    local u
    local cu = function() return u end
    if u == nil then else error("N_cap_readonly") end
    local v = false
    local cv = function() v = false end cv()
    if v == false then else error("N_cap_false") end
    if v ~= nil then else error("N_cap_false_ne_nil") end
    error("V10_NILX_OK")
  end
  t(0)
end
