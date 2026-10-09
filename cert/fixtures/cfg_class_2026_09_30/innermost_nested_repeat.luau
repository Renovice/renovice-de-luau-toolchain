-- VentKidsBand p1 shape (loops campaign 2026-10-09): `while true do for i = 1, n do ...; repeat
-- if lost() then stop(); return end; Sleep() until not playing() end; if not again() then break end
-- end`. Outer-first loop selection headed one cycle at the inner repeat and lost the outer loop.
local log = {}
local plays, touches, rounds = 0, 0, 0
local function playing() plays = plays + 1; return plays % 3 ~= 0 end
local function IsNull(v) return v == nil end
local function touching(p) touches = touches + 1; return touches <= 11 end
local function again() rounds = rounds + 1; return rounds < 3 end
local function f(n, p)
  while true do
    for i = 1, n do
      log[#log + 1] = "start" .. i
      repeat
        if IsNull(p) or not touching(p) then
          log[#log + 1] = "stop"
          return
        end
        log[#log + 1] = "sleep"
      until not playing()
    end
    if not again() then break end
  end
  log[#log + 1] = "done"
end
f(2, {})
print(table.concat(log, " "))
plays, touches, rounds = 0, 0, 0
log = {}
f(1, nil)
print(table.concat(log, " "))
