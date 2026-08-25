function OnInit()
  local function t(a, c, b)
    local v = (a == c)   -- 3==3 -> TRUE : needs the reg-reg equality jump to FIRE
    local w = (a == b)   -- 3==5 -> FALSE
    if v then
      if w then error("K26=both_true") else error("K26=ok") end
    else
      if w then error("K26=inverted") else error("K26=never_jumps") end
    end
  end
  t(3, 3, 5)
end
