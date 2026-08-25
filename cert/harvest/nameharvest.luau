-- Harvest REAL identifier names from the live VM: every string key of every reachable table.
-- Uses print() (logs to EE.log as Script [Info]) so it can emit many lines without aborting.
function OnInit()
  local seen = {}
  local out = {}
  local n = 0
  local function add(s)
    if type(s) == "string" and #s > 0 and #s < 64 then n = n + 1 out[n] = s end
  end
  local function walk(t, depth)
    if depth > 3 then return end
    if type(t) ~= "table" then return end
    if seen[t] then return end
    seen[t] = true
    local ok = pcall(function()
      for k, v in pairs(t) do
        add(k)
        if type(v) == "table" then walk(v, depth + 1) end
      end
    end)
    if not ok then print("NHFAIL:depth" .. depth) end
    local mt = getmetatable(t)
    if type(mt) == "table" then
      walk(mt, depth + 1)
      if type(mt.__index) == "table" then walk(mt.__index, depth + 1) end
    end
  end
  -- roots to try; report which ones were enumerable
  local roots = { _G, Engine, Game, string, table, math, os, coroutine, debug }
  local rootnames = { "_G", "Engine", "Game", "string", "table", "math", "os", "coroutine", "debug" }
  for i = 1, 9 do
    local before = n
    walk(roots[i], 0)
    print("NHROOT:" .. rootnames[i] .. "=" .. (n - before))
  end
  -- emit in chunks
  local buf = {}
  local bn = 0
  for i = 1, n do
    bn = bn + 1
    buf[bn] = out[i]
    if bn >= 40 then print("NH:" .. table.concat(buf, " ")) buf = {} bn = 0 end
  end
  if bn > 0 then print("NH:" .. table.concat(buf, " ")) end
  print("NHCOUNT:" .. n)
end
