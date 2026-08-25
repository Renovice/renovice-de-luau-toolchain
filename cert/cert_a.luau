function OnInit()
    local function t(a, b)          -- a=b=5
        if a ~= b then error("A_NE") end   -- a==b -> ~= false -> must skip -> reach A_EQ
        error("A_EQ")               -- A_EQ => 0x20 jumps on equal (polarity correct)
    end
    t(5, 5)
end
