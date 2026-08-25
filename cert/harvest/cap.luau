-- HYPOTHESIS: after CAPTURE(0x35), reading the captured local DIRECTLY in the enclosing
-- function returns garbage (DE may box the value and repurpose the register).
function OnInit()
  local a = 7                       -- read directly, NEVER captured  -> control
  print("CAP:uncaptured=" .. tostring(a))

  local b = 11
  local f = function() return b end -- b IS captured (by value: never mutated)
  print("CAP:captured_direct=" .. tostring(b) .. " (expect 11)")
  print("CAP:captured_via_fn=" .. tostring(f()) .. " (expect 11)")

  local c = 3
  local g = function() c = c + 1 return c end   -- captured AND mutated -> REF capture
  print("CAP:refcap_direct_before=" .. tostring(c) .. " (expect 3)")
  local r = g()
  print("CAP:refcap_via_fn=" .. tostring(r) .. " (expect 4)")
  print("CAP:refcap_direct_after=" .. tostring(c) .. " (expect 4)")

  local d                            -- nil, captured
  local h = function() d = d end
  print("CAP:nilcap_direct=" .. tostring(d) .. " (expect nil)")
  error("CAP_DONE")
end
