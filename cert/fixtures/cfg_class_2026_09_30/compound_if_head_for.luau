-- 2026-11-07 (DoppelgangerStomp p3): `for ... end; if c then <loop with break> end`. The IfThen's head is
-- compound (the complete for, then the test of c); the region's first block is that for's FORGPREP and
-- the emitter opened a second `for` from it, dropping the test of c (the loop ran when c was false).
local function run(list, c, limit)
  local seen, n = 0, 0
  for _, v in ipairs(list) do
    seen = seen + v
  end
  if c then
    while n < limit do
      n = n + 1
      if n * seen > 20 then
        print("hit", n)
        break
      end
    end
  end
  print("done", seen, n)
end
run({ 1, 2, 3 }, true, 10)
run({ 4, 5 }, false, 10)
run({}, true, 3)
