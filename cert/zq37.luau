function OnInit()
    local function t(a, b) if a ~= b then error("Q37_then") else error("Q37_else") end end
    t(5, 5)
end
