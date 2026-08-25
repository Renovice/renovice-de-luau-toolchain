function OnInit()
  local c
  local f = function() c = nil end
  f()
  -- What does the VM actually think c is, at the point of comparison?
  print("DG:type=" .. type(c) .. " str=" .. tostring(c))
  -- (a) direct compare in the enclosing function  <- known broken
  if c ~= nil then print("DG:a_direct_neqnil=WRONG") else print("DG:a_direct_neqnil=ok") end
  -- (b) compare INSIDE a closure (reads via GETUPVAL, not the raw register)
  local g = function() if c ~= nil then return "WRONG" else return "ok" end end
  print("DG:b_via_closure=" .. g())
  -- (c) compare against another plain nil local (not our LOADNIL scratch)
  local z
  if c ~= z then print("DG:c_vs_nil_local=WRONG") else print("DG:c_vs_nil_local=ok") end
  -- (d) truthiness test instead of equality
  if c then print("DG:d_truthy=WRONG") else print("DG:d_truthy=ok") end
  -- (e) a captured local never assigned by the closure at all
  local h
  local k = function() return h end
  if h ~= nil then print("DG:e_capread_only=WRONG") else print("DG:e_capread_only=ok") end
  error("DG_DONE")
end
