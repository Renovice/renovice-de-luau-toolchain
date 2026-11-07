-- 2026-11-07 (TennoHubHangar p2): `for i, x in ipairs(a) do t[i] = x end` before an endless loop reduces
-- as While(FORGLOOP latch, body). The latch's exit was taken as the body start: the body printed after
-- an empty `for` and wrote t[nil]. The endless loop runs in a coroutine; Sleep yields.
local Sleep = coroutine.yield
local function run(arr, t)
  for i, x in ipairs(arr) do
    t[i] = x * 2
  end
  while true do
    Sleep(#t)
  end
end
local t = {}
local co = coroutine.create(run)
print(coroutine.resume(co, { 4, 5, 6 }, t))
print(t[1], t[2], t[3], coroutine.resume(co))
