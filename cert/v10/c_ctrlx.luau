-- AUTO-GENERATED behavioural matrix: CTRLX
function OnInit()
  local function t(three, ten)
    local s = 0
    for i = 1, ten do s = s + i end
    if s == 55 then else error("F_forn_up") end
    local d = 0
    for i = ten, 1, -1 do d = d + 1 end
    if d == 10 then else error("F_forn_down") end
    local st = 0
    for i = 1, ten, 2 do st = st + 1 end
    if st == 5 then else error("F_forn_step") end
    local w = 0
    while w < three do w = w + 1 end
    if w == 3 then else error("F_while") end
    local rp = 0
    repeat rp = rp + 1 until rp >= three
    if rp == 3 then else error("F_repeat") end
    local rn = 0
    repeat rn = rn + 1 until rn ~= 0
    if rn == 1 then else error("F_repeat_ne") end
    local br = 0
    for i = 1, ten do if i > three then break end br = br + 1 end
    if br == 3 then else error("F_break") end
    local nst = 0
    for i = 1, three do for j = 1, three do nst = nst + 1 end end
    if nst == 9 then else error("F_nested") end
    local ch = 0
    if three > ten then ch = 1 elseif three == 3 then ch = 2 else ch = 3 end
    if ch == 2 then else error("F_elseif") end
    local arr = { 10, 20, 30 }
    local isum = 0
    for i, v in ipairs(arr) do isum = isum + v end
    if isum == 60 then else error("F_ipairs") end
    local psum = 0
    for k, v in pairs(arr) do psum = psum + v end
    if psum == 60 then else error("F_pairs") end
    local ecnt = 0
    for i = 1, 0 do ecnt = ecnt + 1 end
    if ecnt == 0 then else error("F_empty_for") end
    local icnt = 0
    for i, v in ipairs({}) do icnt = icnt + 1 end
    if icnt == 0 then else error("F_empty_ipairs") end
    error("V10_CTRLX_OK")
  end
  t(3, 10)
end
