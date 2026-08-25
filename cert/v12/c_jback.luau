-- NATIVE JUMPBACK 0x25. We normally emit 0x40 JUMP for backward jumps too. The CFG/dead-code
-- audit treats 0x25 as an unconditional BACK jump, so a loop must terminate and sum correctly.
function OnInit()
  local function t(n)
    local sum, i = 0, 0
    while i < n do i = i + 1; sum = sum + i end   -- 1+2+..+5 = 15
    local guard = 0
    repeat guard = guard + 1 until guard >= 3     -- must stop at exactly 3
    error("V12_JBACK sum=" .. tostring(sum) .. " guard=" .. tostring(guard))
  end
  t(5)
end
