-- Covers the two blind spots that let a real bug hide behind a green suite:
--  (1) nil comparisons on values written through SETUPVAL by a closure  (was broken: LOADNIL+reg-compare)
--  (2) jump-if-TRUE polarity (`x ~= k`), which `if c then else error() end` never emits
function OnInit()
  local a                                   -- captured + assigned nil via closure
  local f = function() a = nil end
  f()
  if a ~= nil then error("N_cap_nil") end
  if a == nil then else error("N_cap_nil2") end
  local b = 1                               -- captured, assigned nil (1 -> nil)
  local g = function() b = nil end
  g()
  if b ~= nil then error("N_cap_setnil") end
  local c = 0                               -- captured, assigned non-nil
  local h = function() c = 7 end
  h()
  if c ~= nil then else error("N_cap_num") end
  if c == 7 then else error("N_cap_num7") end
  local d                                   -- captured but never assigned
  local k = function() return d end
  if d ~= nil then error("N_capread") end
  local e                                   -- never captured
  if e ~= nil then error("N_plain") end
  -- jump-if-TRUE polarities (the forms certs never emitted)
  local n = 5
  if n ~= 5 then error("N_neq_same") end
  if n ~= 9 then else error("N_neq_diff") end
  if n ~= nil then else error("N_num_neqnil") end
  error("V9_NIL_OK")
end
