-- NATIVE AND 0x2f / OR 0x2b. Lua and/or return an OPERAND, not a boolean — so falsey inputs
-- discriminate: `false and x` -> false (LEFT), `nil or y` -> y (RIGHT).
function OnInit()
  local function t(tru, fls, nl, five, six)
    local r = ""
    r = r .. "t_and=" .. tostring(tru and five)    -- true  and 5   -> 5
    r = r .. " f_and=" .. tostring(fls and five)   -- false and 5   -> false (LEFT)
    r = r .. " n_and=" .. tostring(nl and five)    -- nil   and 5   -> nil   (LEFT)
    r = r .. " t_or=" .. tostring(tru or six)      -- true  or 6    -> true  (LEFT)
    r = r .. " f_or=" .. tostring(fls or six)      -- false or 6    -> 6     (RIGHT)
    r = r .. " n_or=" .. tostring(nl or six)       -- nil   or 6    -> 6     (RIGHT)
    error("V12_ANDOR " .. r)
  end
  t(true, false, nil, 5, 6)
end
