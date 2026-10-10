-- OPEN (captures campaign 2026-10-10, not in a gate): a while loop with a break renders as a Proper
-- dispatcher (`__renovice_state_N` blocks); the scoped local's definition and its closure land in
-- different state blocks, so scoped_captures.h fails closed and the flat local stays shared.
-- luau.exe: stock prints `while 12 13 22 done`; the decompiled source fails at runtime
-- (the flat y is overwritten by later code). Same shape as DuelistPistolsPassive p4.
local hs = {}
local i = 0
while i < 3 do
    i = i + 1
    local y = i * 10
    y = y + 1
    hs[i] = function() y = y + 1; return y end
    if i == 2 then break end
end
local after = { 1, 2, 3 }
print("while", hs[1](), hs[1](), hs[2]())
print("done", #after)
