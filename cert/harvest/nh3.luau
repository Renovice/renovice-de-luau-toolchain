-- Harvester v3: deeper traversal, hunts METHOD tables (the unresolved hashes are 82% NAMECALL names).
-- Walks values as well as keys, follows metatables/__index chains, and reports what kind of table each was.
function OnInit()
  local seen = {}
  local total, funcs = 0, 0
  local line, cnt = "", 0
  local function flush() if cnt > 0 then print("NH:" .. line) line = "" cnt = 0 end end
  local function emit(s)
    total = total + 1
    line = line .. s .. " "
    cnt = cnt + 1
    if cnt >= 30 then flush() end
  end
  local function walk(t, depth)
    if depth > 6 then return end
    if type(t) ~= "table" or seen[t] then return end
    seen[t] = true
    pcall(function()
      for k, v in pairs(t) do
        if type(k) == "string" then
          emit(k)
          if type(v) == "function" then funcs = funcs + 1 end
        end
        if type(v) == "table" then walk(v, depth + 1) end
        -- follow metatables of VALUES too: engine objects carry their methods there
        pcall(function()
          local vm = getmetatable(v)
          if type(vm) == "table" then
            walk(vm, depth + 1)
            local ix = rawget(vm, "__index")
            if type(ix) == "table" then walk(ix, depth + 1) end
          end
        end)
      end
    end)
    pcall(function()
      local mt = getmetatable(t)
      if type(mt) == "table" then
        walk(mt, depth + 1)
        local ix = rawget(mt, "__index")
        if type(ix) == "table" then walk(ix, depth + 1) end
      end
    end)
  end
  local function root(t, nm)
    local b = total
    pcall(function() walk(t, 0) end)
    print("NHR:" .. nm .. "=" .. (total - b))
  end
  root(_G, "_G")
  root(Engine, "Engine")
  flush()
  print("NHTOTAL:" .. total .. " funcs:" .. funcs)
  error("NH3_DONE=" .. total)
end
