-- Minimal 3-arg MUL (the presumed earlier "mul09 OK" form) to reconcile: does 6*7==42 pass with tiny registers?
function OnInit()
    local function t(a, b, c)
        if a * b == c then else error("MULMIN_BAD") end
        error("MULMIN_OK")
    end
    t(6, 7, 42)
end
