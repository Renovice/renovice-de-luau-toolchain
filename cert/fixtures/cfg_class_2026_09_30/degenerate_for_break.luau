-- 2026-11-07: `for ... do break end`. Luau sends the latch's back edge to the loop exit and leaves the
-- `break` as a dead body; the prototype did not reduce (generic) or printed a raw zero-trip test
-- (numeric), and inside a `while` the enclosing loop was lost. The custom iterator proves the call
-- still happens exactly once per loop.
local calls = 0
local function iter(state, ctl)
  calls = calls + 1
  if ctl < state then return ctl + 1 end
  return nil
end
local function run(n, rounds)
  local seen = 0
  for _, v in iter, 3, 0 do
    break
  end
  for i = 1, n do
    break
  end
  while seen < rounds do
    seen = seen + 1
    for k in iter, 5, 0 do
      break
    end
  end
  print("run", n, rounds, seen, calls)
end
run(2, 3)
run(0, 1)
