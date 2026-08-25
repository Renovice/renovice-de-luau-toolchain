function OnInit()
  local function t(one, two, three, ten)
    local arr = { 10, 20, 30 }                 -- NEWTABLE + SETLIST
    local rec = { alpha = 1, beta = 2 }        -- DUPTABLE (const template)
    if arr[1] == 10 then else error("T_GETTABLEN") end
    arr[2] = 99
    if arr[2] == 99 then else error("T_SETTABLEN") end
    local k = three
    arr[k] = 77                                -- SETTABLE (reg key)
    if arr[k] == 77 then else error("T_REGKEY") end
    if rec.alpha == 1 then else error("T_GETFIELD") end
    rec.gamma = 5                              -- SETTABLEKS
    if rec.gamma == 5 then else error("T_SETFIELD") end
    rec.gamma = rec.gamma + rec.beta
    if rec.gamma == 7 then else error("T_FIELD_RMW") end
    local nested = {}
    nested.inner = {}
    nested.inner.v = ten
    if nested.inner.v == 10 then else error("T_NESTED") end
    error("V9_TABLE_OK")
  end
  t(1, 2, 3, 10)
end
