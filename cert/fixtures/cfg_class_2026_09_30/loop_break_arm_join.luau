-- Loop with a break arm whose body joins the code after the loop, nested in an outer loop
-- (Platform p2 shape). The arm must run only when the loop left through it.
local rounds = 0
local log = {}
local function f(maxLoops, notifyAt)
  local ready = false
  while true do
    while ready == false do ready = true end
    rounds = rounds + 1
    if rounds > 3 then return end
    local loops, t = 0, 0
    while true do
      while t < 3 do t = t + 1 end
      if loops == notifyAt[rounds] then
        log[#log + 1] = "reset" .. rounds
        break
      end
      t = 0
      loops = loops + 1
      if maxLoops < loops then break end
    end
    log[#log + 1] = "end" .. rounds .. ":" .. loops
    ready = false
  end
end
f(2, {9, 1, 9})
print(table.concat(log, " "))
print(rounds, #log)
