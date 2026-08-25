function OnInit()
  local function t(one, three, ten)
    local s = 0
    for i = 1, ten do s = s + i end            -- FORNPREP / FORNLOOP
    if s == 55 then else error("L_FORN") end
    local d = 0
    for i = ten, one, -1 do d = d + 1 end      -- FORN with step
    if d == 10 then else error("L_FORN_STEP") end
    local arr = { 10, 20, 30 }
    local isum, icnt = 0, 0
    for i, v in ipairs(arr) do isum = isum + v icnt = icnt + 1 end   -- FORGPREP_INEXT
    if isum == 60 then else error("L_IPAIRS_SUM") end
    if icnt == 3 then else error("L_IPAIRS_CNT") end
    local psum = 0
    for kk, vv in pairs(arr) do psum = psum + vv end                 -- FORGPREP_NEXT
    if psum == 60 then else error("L_PAIRS") end
    local w = 0
    while w < three do w = w + 1 end            -- JUMPBACK
    if w == 3 then else error("L_WHILE") end
    local r = 0
    repeat r = r + 1 until r >= three
    if r == 3 then else error("L_REPEAT") end
    error("V9_LOOP_OK")
  end
  t(1, 3, 10)
end
