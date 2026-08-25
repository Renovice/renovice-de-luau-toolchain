function OnInit()
    local function t(a,c) if -a == c then error("minus_OK") else error("minus_BAD") end end
    t(8,-8)
end
