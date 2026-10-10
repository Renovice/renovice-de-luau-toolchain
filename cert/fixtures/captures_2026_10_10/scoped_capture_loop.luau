-- Block-scoped locals captured by reference (captures campaign 2026-10-10, scoped_captures.h).
-- Each loop iteration and the do-block own a fresh variable that their closures keep after the
-- block ends; the slot is reused afterwards. A flat function-scope local made every closure share
-- one variable that later code overwrote.
local fs = {}
for _, n in ipairs({"a", "b", "c"}) do
    local x = 0
    if n == "a" then x = 1 elseif n == "b" then x = 2 else x = 3 end
    fs[#fs + 1] = function() return n .. x end
end
local hs = {}
local i = 0
while i < 2 do
    i = i + 1
    local y = i * 10
    y = y + 1
    hs[i] = function() y = y + 1; return y end
end
do
    local z = 5
    z = z + 1
    fs.h = function() return z end
end
-- `local alias = base` with neither written: Luau binds both names to one register, and the
-- closure captures that register in two upvalue slots (TouchInterface Window).
local base = { tag = "base" }
local alias = base
local function both() return base.tag .. "/" .. alias.tag end
local reuse = { "r1", "r2" }
print("loop", fs[1](), fs[2](), fs[3]())
print("while", hs[1](), hs[1](), hs[2]())
print("do", fs.h())
print("alias", both(), reuse[2])
