-- 2026-11-07 (CheckLevelTag p1): a generic for whose break arm leaves to a following endless loop, the
-- for reduced from its FORGLOOP latch (the PREP outside the region). The emitter treated the region's
-- first part (the body test) as setup and printed it above an empty `for`: the test ran once, on nil.
-- The endless tail runs inside a coroutine; Sleep yields.
local Sleep = coroutine.yield
local function run(t, key)
  local found = false
  for k, v in pairs(t) do
    if v == key then
      print("hit", k)
      found = true
      break
    end
  end
  while true do
    Sleep(found)
  end
end
for _, case in ipairs({ { { a = 1, b = 2 }, 2 }, { { a = 1 }, 5 } }) do
  local co = coroutine.create(run)
  print(coroutine.resume(co, case[1], case[2]))
  print(coroutine.resume(co))
end
