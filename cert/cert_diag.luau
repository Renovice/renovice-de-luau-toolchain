-- Diagnostic: localize the cert_all "ADD" failure. Is it (a) the fused compare ~= (JUMPIFEQ) polarity,
-- (b) ADD genuinely wrong, or (c) param passing? Few args here (5) vs cert_all's 26 -> if this passes but
-- cert_all fails, it's the arg count. Each outcome self-announces via error(); first error wins.
function OnInit()
    local function t(a5, b5, three, four, seven)   -- a5=5, b5=5 (equal, different regs -> not folded)
        -- (1) JUMPIFEQ polarity: a5 ~= b5 must be FALSE (they're both 5). If it errors, the compare is inverted.
        if a5 ~= b5 then error("JEQ_INVERTED") end
        -- (2) reached => JUMPIFEQ ok on equal operands. Now ADD: three+four must equal seven.
        local s = three + four
        if s ~= seven then error("ADD_VALUE_WRONG") end
        -- (3) both fine
        error("DIAG_ALL_OK")
    end
    t(5, 5, 3, 4, 7)
end
