-- Constructor expressions (ctor agent 2026-10-10, DEFECTS #90). Own code; prints values only.
-- Each constructor's items contain control flow (44.1.1: AddIngredientsScreen p4 `{ if a then 100
-- else 0 }`, DailyTribute p41 `{ Ternary(u ~= nil, 100, 0) }`, ArenaGambling p12 `{ Ternary(a.Active
-- or a.QuestStageIndex ~= nil, 100, 50), self:CalculateY(a) }`, ThemedSquadPanel p30 `(x and not y)
-- or z`, NewPlayerTutorialFoundry p2 `{ { text = ..., check = 3 < n }, ... }`), a record item before
-- the last list item (DEFECTS #51), or more than one SETLIST batch with record items between them.
local Box = {}
Box.__index = Box
function Box.new(n) return setmetatable({ n = n, Active = n > 2, Quest = (n % 2 == 0) and n or nil }, Box) end
function Box:CalculateY(o) return self.n * 10, o.n end
local function Ternary(c, a, b) if c then return a end return b end
local function Pair(a, b) return a, b end
local function show(t)
  local parts = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      local inner = {}
      for k2, v2 in pairs(v) do inner[#inner + 1] = tostring(k2) .. "=" .. tostring(v2) end
      table.sort(inner)
      v = "{" .. table.concat(inner, ",") .. "}"
    end
    parts[#parts + 1] = tostring(k) .. ":" .. tostring(v)
  end
  table.sort(parts)
  return "#" .. #t .. " " .. table.concat(parts, " ")
end

local function Build(flag, n, box, other, name)
  local a = { if flag then 100 else 0 }
  local b = { Ternary(name ~= nil, 100, 0) }
  local c = { Ternary(box.Active or box.Quest ~= nil, 100, 50), box:CalculateY(other) }
  local d = { flag and box.n or n, n < 3, 5 > n, n <= box.n }
  local e = { Ternary((box.Active and not flag) or other.Active, 70, 0) }
  local f = { { text = "one", check = 3 < n }, { text = "two", check = 4 < n } }
  local g = { mode = name, flag and 1 or 2, Pair(n, if flag then "y" else "z") }
  local h = { name or "anon", function() return n + 1 end, (Pair(n, 9)) }
  return a, b, c, d, e, f, g, h
end

local function Many(flag, n)
  local t = {
    { level = n }, { level = n + 1 }, { level = n + 2 }, { level = n + 3 }, { level = n + 4 },
    { level = n + 5 }, { level = n + 6 }, { level = n + 7 }, { level = n + 8 }, { level = n + 9 },
    { level = n + 10 }, { level = n + 11 }, { level = n + 12 }, { level = n + 13 }, { level = n + 14 },
    { level = n + 15 }, { level = n + 16 }, { level = if flag then n else -n }, { level = n + 18 },
  }
  return t
end

for _, args in ipairs({ { true, 2, "x" }, { false, 5, nil }, { true, 4, "y" } }) do
  local flag, n, name = args[1], args[2], args[3]
  local results = { Build(flag, n, Box.new(n), Box.new(n + 1), name) }
  for i = 1, #results do
    local r = results[i]
    if i == 8 then print(i, r[1], r[2](), r[3], #r) else print(i, show(r)) end
  end
  local m = Many(flag, n)
  print("many", #m, m[1].level, m[17].level, m[18].level, m[19].level)
end
