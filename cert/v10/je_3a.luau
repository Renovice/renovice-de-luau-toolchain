function OnInit()
  local function t(a, c, b, s1, s2)
    local v = (a == c)          -- 3==3 -> must be TRUE  (requires the jump to fire)
    local w = (a == b)          -- 3==5 -> must be FALSE
    local x = (s1 == s2)        -- "q"=="q" -> TRUE (string operands)
    local y = (a ~= b)          -- 3~=5 -> TRUE
    local r = "ok"
    if v ~= true  then r = "v_" .. tostring(v) end
    if w ~= false then r = "w_" .. tostring(w) end
    if x ~= true  then r = "x_" .. tostring(x) end
    if y ~= true  then r = "y_" .. tostring(y) end
    error("JE3a=" .. r)
  end
  t(3, 3, 5, "q", "q")
end
