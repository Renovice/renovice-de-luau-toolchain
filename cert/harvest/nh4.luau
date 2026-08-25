-- Harvester v4: OBJECT-TARGETED. Uses the real API (learned from the OpenWF pluto scripts) to obtain
-- LIVE gameplay objects, then walks each object's metatable/__index chain to dump every method name.
-- The unresolved hashes are 82% NAMECALL (obj:Method) names, which only exist on live object classes.
-- RUN THIS INSIDE A MISSION so the avatar/suit/weapons actually exist.
function OnInit()
  local total = 0
  local line, cnt = "", 0
  local function flush() if cnt > 0 then print("MH:" .. line) line = "" cnt = 0 end end
  local function emit(s)
    total = total + 1
    line = line .. s .. " "
    cnt = cnt + 1
    if cnt >= 25 then flush() end
  end
  local seen = {}
  local function dumpobj(o, label)
    if o == nil then print("MHOBJ:" .. label .. "=nil") return end
    local n0 = total
    -- instance fields
    pcall(function() for k, v in pairs(o) do if type(k) == "string" then emit(k) end end end)
    -- class methods live on the metatable chain
    local mt = nil
    pcall(function() mt = getmetatable(o) end)
    local depth = 0
    while mt ~= nil and depth < 8 do
      if seen[mt] then break end
      seen[mt] = true
      pcall(function() for k, v in pairs(mt) do if type(k) == "string" then emit(k) end end end)
      local ix = nil
      pcall(function() ix = rawget(mt, "__index") end)
      if type(ix) == "table" then
        if seen[ix] then break end
        seen[ix] = true
        pcall(function() for k, v in pairs(ix) do if type(k) == "string" then emit(k) end end end)
        local nxt = nil
        pcall(function() nxt = getmetatable(ix) end)
        mt = nxt
      else
        local nxt = nil
        pcall(function() nxt = getmetatable(mt) end)
        mt = nxt
      end
      depth = depth + 1
    end
    print("MHOBJ:" .. label .. "=" .. (total - n0))
  end
  local function try(fn, label)
    local ok, v = pcall(fn)
    if ok then dumpobj(v, label) else print("MHOBJ:" .. label .. "=CALLFAIL") end
  end
  dumpobj(gRegion, "gRegion")
  try(function() return gRegion:GetLocalPlayerAvatar() end, "avatar")
  try(function() return gRegion:GetAvatars() end, "avatars")
  local av = nil
  pcall(function() av = gRegion:GetLocalPlayerAvatar() end)
  if av ~= nil then
    try(function() return av:InventoryControl() end, "inv")
    local inv = nil
    pcall(function() inv = av:InventoryControl() end)
    if inv ~= nil then
      try(function() return inv:GetActivePowerSuit() end, "suit")
    end
  end
  flush()
  print("MHTOTAL:" .. total)
  error("MH_DONE=" .. total)
end
