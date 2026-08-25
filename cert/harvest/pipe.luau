-- END-TO-END NAMING PIPELINE TEST
-- Each method name below came from our resolved namebase. Writing `obj:Name()` makes our recompiler
-- hash the name (FNV) and emit NAMECALL 0x2d with that hash. If the name is correct, the VM dispatches
-- to a REAL native and returns a sensible value. "attempt to call nil" would mean the mapping is wrong.
function OnInit()
  local function shot(label, fn)
    local ok, v = pcall(fn)
    if ok then
      print("PIPE:" .. label .. " OK type=" .. type(v) .. " val=" .. tostring(v))
    else
      print("PIPE:" .. label .. " FAIL " .. tostring(v))
    end
  end
  local av
  shot("gRegion:GetLocalPlayerAvatar", function() av = gRegion:GetLocalPlayerAvatar() return av end)
  if av == nil then print("PIPE:no-avatar (run in a mission)") error("PIPE_DONE") end
  shot("avatar:GetFullName",       function() return av:GetFullName() end)
  shot("avatar:GetName",           function() return av:GetName() end)
  shot("avatar:GetType",           function() return av:GetType() end)
  shot("avatar:GetPlayerProfile",  function() return av:GetPlayerProfile() end)
  local inv
  shot("avatar:InventoryControl",  function() inv = av:InventoryControl() return inv end)
  if inv ~= nil then
    shot("inv:GetActivePowerSuit", function() return inv:GetActivePowerSuit() end)
  end
  shot("gRegion:GetAvatars",       function() return gRegion:GetAvatars() end)
  -- negative control: a name that is NOT in our table -> should fail to dispatch
  shot("avatar:ZzNotARealMethodQq", function() return av:ZzNotARealMethodQq() end)
  error("PIPE_DONE")
end
