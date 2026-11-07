-- 2026-11-07 (DoppelgangerStomp p3 shape): `if c then while t() do for ... end; if X then Y break end end end`.
-- The while region contains the nested for's FORGLOOP latch; the emitter took any latch in the region
-- as "this loop is a for body already opened" and printed the while without its wrapper (one pass, the
-- loop test and the break arm misplaced).
local function run(c, rounds, list)
  local n, total = 0, 0
  if c then
    while n < rounds do
      n = n + 1
      for _, v in ipairs(list) do
        total = total + v
      end
      if total > 10 then
        print("over", n, total)
        break
      end
    end
  end
  print("done", n, total)
end
run(true, 5, { 1, 2 })
run(true, 2, { 1 })
run(false, 5, { 9 })
