-- stubenv.lua — a MOCK Warframe/DE engine environment.
--
-- Real shipped scripts reference engine globals (Engine.*, gRegion, IsNull, _T, Symbol, Rotation, ...)
-- that do not exist outside the game, so they cannot be run to compare behaviour. This supplies a
-- universal proxy for every unknown global: indexing, calling and arithmetic all succeed and return
-- another proxy, and every operation is APPENDED TO A TRACE.
--
-- The trace is the observable. We have no original source for a real script, so S-vs-S' is impossible;
-- what IS possible is S' vs S'' (the round-tripped module). If the two produce identical traces, the
-- decompile->recompile loop preserved the program's behaviour on real code.
--
-- Everything must be DETERMINISTIC: proxies carry a stable path name, never an address, and every
-- metamethod returns a fixed value rather than anything derived from identity.

local TRACE = {}
local function emit(s) TRACE[#TRACE + 1] = s end

local Proxy = {}
local mkproxy

local function nameof(v)
  local t = type(v)
  if t == "table" then
    local mt = getmetatable(v)
    if mt == Proxy then return rawget(v, "__path") end
    return "<tbl>"
  elseif t == "function" then return "<fn>"
  elseif t == "number" then
    if v ~= v then return "nan" end
    return string.format("%.10g", v)
  elseif t == "string" then return string.format("%q", v)
  end
  return tostring(v)
end

local function arglist(...)
  local n = select("#", ...)
  local parts = {}
  for i = 1, n do parts[#parts + 1] = nameof((select(i, ...))) end
  return table.concat(parts, ",")
end

Proxy.__index = function(self, k)
  local path = rawget(self, "__path") .. "." .. tostring(k)
  emit("IDX " .. path)
  return mkproxy(path)
end
Proxy.__newindex = function(self, k, v)
  emit("SET " .. rawget(self, "__path") .. "." .. tostring(k) .. " = " .. nameof(v))
end
Proxy.__call = function(self, ...)
  emit("CALL " .. rawget(self, "__path") .. "(" .. arglist(...) .. ")")
  return mkproxy(rawget(self, "__path") .. "()")
end
Proxy.__tostring = function(self) return rawget(self, "__path") end
Proxy.__len       = function(self) emit("LEN " .. rawget(self, "__path")); return 0 end
Proxy.__concat    = function(a, b) return nameof(a) .. nameof(b) end
-- Comparisons must be TOTAL and deterministic, or a script that compares an engine value against a
-- number would raise and cut the trace short at a point that depends on nothing meaningful.
Proxy.__eq = function(a, b) return rawget(a, "__path") == rawget(b, "__path") end
Proxy.__lt = function(a, b) emit("LT"); return false end
Proxy.__le = function(a, b) emit("LE"); return false end
for _, op in ipairs({"__add","__sub","__mul","__div","__mod","__pow","__unm","__idiv"}) do
  Proxy[op] = function(a, b) emit("ARITH " .. op); return mkproxy("arith") end
end

mkproxy = function(path)
  return setmetatable({ __path = path }, Proxy)
end

-- The script's environment: every unknown global resolves to a named proxy. Reads are recorded so a
-- control-flow change that reads a different global shows up in the trace.
local ENV = {}
setmetatable(ENV, {
  __index = function(_, k)
    local keep = rawget(_G, k)
    if keep ~= nil then return keep end          -- real stdlib (string, table, math, ...)
    emit("GLOBAL " .. tostring(k))
    return mkproxy(tostring(k))
  end,
  __newindex = function(t, k, v)
    emit("SETGLOBAL " .. tostring(k) .. " = " .. nameof(v))
    rawset(t, k, v)
  end,
})

return { ENV = ENV, TRACE = TRACE, mkproxy = mkproxy, nameof = nameof, emit = emit }
