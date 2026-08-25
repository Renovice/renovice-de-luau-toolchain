function OnInit()
    local function t(a,b,c) if a / b == c then error("div1a_OK") else error("div1a_BAD") end end
    t(20,4,5)
end
