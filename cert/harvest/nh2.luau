-- Name harvester v2: no table.* (unavailable in the sandbox). Builds lines with .. and prints them.
-- pairs/next/getmetatable/pcall/print/rawget all confirmed available.
function OnInit()
  local seen = {}
  local total = 0
  local line = ""
  local cnt = 0
  local function flush()
    if cnt > 0 then print("NH:" .. line) line = "" cnt = 0 end
  end
  local function emit(s)
    total = total + 1
    line = line .. s .. " "
    cnt = cnt + 1
    if cnt >= 30 then flush() end
  end
  local function walk(t, depth)
    if depth > 3 then return end
    if seen[t] then return end
    seen[t] = true
    pcall(function()
      for k, v in pairs(t) do
        if type(k) == "string" then emit(k) end
        if type(v) == "table" and depth < 3 then walk(v, depth + 1) end
      end
    end)
    pcall(function()
      local mt = getmetatable(t)
      if mt then
        walk(mt, depth + 1)
        local ix = rawget(mt, "__index")
        if type(ix) == "table" then walk(ix, depth + 1) end
      end
    end)
  end
  local function tryroot(t, nm)
    local before = total
    pcall(function() walk(t, 0) end)
    print("NHROOT:" .. nm .. "=" .. (total - before))
  end
  tryroot(_G, "_G")
  tryroot(Engine, "Engine")
  tryroot(OnInit, "OnInit")
  flush()
  print("NHCOUNT:" .. total)
  error("NH_DONE=" .. total)
end
