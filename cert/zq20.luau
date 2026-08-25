function OnInit()
    local function t(a, b) if a ~= b then error("Q20_then") else error("Q20_else") end end
    t(5, 5)
end
