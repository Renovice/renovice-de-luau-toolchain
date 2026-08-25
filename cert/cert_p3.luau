function OnInit()
    local function t(a, b)   -- 1,2 : 1<2 true
        if a < b then error("P3_LT_THEN") end
        error("P3_LT_SKIP")
    end
    t(1, 2)
end
