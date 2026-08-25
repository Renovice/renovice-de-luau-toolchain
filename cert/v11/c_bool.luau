-- v11: BOOLEAN CONSTANTS. Until today the transcoder THREW on these, so no cert ever
-- covered a `{ flag = true }` table — one of the most common shapes in real game scripts.
function OnInit()
  local function t()
    local cfg = { on = true, off = false, n = 3 }
    local r = "on=" .. tostring(cfg.on) .. " off=" .. tostring(cfg.off) .. " n=" .. tostring(cfg.n)
    -- booleans surviving a round trip through a table must still compare correctly
    if cfg.on ~= true  then r = r .. " BAD_ON"  end
    if cfg.off ~= false then r = r .. " BAD_OFF" end
    if cfg.off then r = r .. " BAD_TRUTHY" end
    if not cfg.on then r = r .. " BAD_FALSY" end
    error("V11_BOOL " .. r)
  end
  t()
end
