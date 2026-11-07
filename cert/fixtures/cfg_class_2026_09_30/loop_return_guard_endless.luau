-- 2026-11-07 (GenericSpawnSentinel p3): `while true do for i = 1, n do if a(i) then if b(i) then return end
-- if c(i) then use(i) end end end Sleep() end`. Through the endless outer loop the `return` block
-- post-dominates the `b` test, so the for renderer took it as the join: `if not b then ... end; return`
-- returned on the first iteration. The endless loop runs in a coroutine; Sleep yields.
local Sleep = coroutine.yield
local round = 0
local function a(i) return i % 2 == 1 end
local function b(i) return round == 3 and i == 3 end
local function c(i) return i > 1 end
local function use(i) print("use", round, i) end
local function f(n)
  while true do
    for i = 1, n do
      if a(i) then
        if b(i) then
          return
        end
        if c(i) then
          use(i)
        end
      end
    end
    round = round + 1
    Sleep(round)
  end
end
local co = coroutine.create(f)
for _ = 1, 5 do print(coroutine.resume(co, 5)) end
