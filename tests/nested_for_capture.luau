-- Regression fixture (2026-10-08): an outer numeric loop schedules closures that run their own pairs loop
-- and read the captured OUTER index. Shape of /Lotus/Interface/OmegaRerollSelection.lua proto 10 (Riven
-- cycle animation: Angle = (i - 1) * -67.5). A decompiler that gives both loops one name makes the
-- closure read the inner index after recompilation.
local scheduled = {}
local effects = {}
local function schedule(delay, fn)
  scheduled[#scheduled + 1] = { delay = delay, fn = fn }
end
for i = 1, 16 do
  schedule(i * 0.045, function()
    for k, v in pairs({ "a", "b" }) do
      effects[#effects + 1] = { Name = v, First = k == 1, Angle = (i - 1) * -67.5 }
    end
  end)
end
for _, entry in ipairs(scheduled) do
  entry.fn()
end
return effects
