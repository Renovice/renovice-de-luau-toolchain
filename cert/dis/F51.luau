function OnInit()
  local function t(fortytwo)
    local r = {}
    r.f = fortytwo
    local v = r.f
    if v == nil then error("F51_NIL_notfieldread") end
    if v > 41.5 then if v < 42.5 then error("F51_is42_FIELDREAD") end end
    error("F51_other")
  end
  t(42)
end
