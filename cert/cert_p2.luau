function OnInit()
    local function t(a, b)   -- 5,5 equal
        if a == b then error("P2_EQ_TRUE") else error("P2_EQ_FALSE") end
    end
    t(5, 5)
end
