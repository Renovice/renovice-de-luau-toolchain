function OnInit()
  local function t(a, c, b)
    local v = (a == c)   -- 3==3 -> TRUE : needs the reg-reg equality jump to FIRE
    local w = (a == b)   -- 3==5 -> FALSE
    if v then
      if w then error("K41=both_true") else error("K41=ok") end
    else
      if w then error("K41=inverted") else error("K41=never_jumps") end
    end
  end
  t(3, 3, 5)
end
