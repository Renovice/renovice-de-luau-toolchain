-- Narrow the UPV anomaly: SETUPVAL with a nil value, and pcall-vs-direct invocation.
function OnInit()
  -- A: closure assigns NIL to captured var, called DIRECTLY (no pcall)
  local a = 1
  local fa = function() a = nil end
  fa()
  print("SUP:A_direct_setnil=" .. tostring(a) .. " (expect nil)")

  -- B: same but invoked through pcall  <-- the exact upv.luau shape
  local b = 1
  local okb = pcall(function() b = nil end)
  print("SUP:B_pcall_setnil=" .. tostring(b) .. " pcall=" .. tostring(okb) .. " (expect nil/true)")

  -- C: var starts nil, closure assigns nil, via pcall  <-- literally upv.luau
  local c
  local okc = pcall(function() c = nil end)
  print("SUP:C_nil_pcall_nil=" .. tostring(c) .. " (expect nil)")
  if c ~= nil then print("SUP:C_neq_nil=WRONG") else print("SUP:C_neq_nil=ok") end

  -- D: closure assigns a NUMBER via pcall (known-good shape) as control
  local d
  local okd = pcall(function() d = 9 end)
  print("SUP:D_pcall_setnum=" .. tostring(d) .. " (expect 9)")

  -- E: no closure at all, plain nil compare (control)
  local e
  if e ~= nil then print("SUP:E_neq_nil=WRONG") else print("SUP:E_neq_nil=ok") end
  error("SUP_DONE")
end
