-- v11: the LOW-FREQUENCY ops whose corpus evidence is thin (IDIVK n=5, POWK n=132,
-- DIVRK n=590, SUBRK n=2489, POW reg-reg) + the newly-added boolean constant.
-- Operands are chosen so that every plausible RIVAL opcode gives a DIFFERENT answer,
-- and each result is REPORTED as a value rather than binned into pass/fail.
function OnInit()
  local function t(a, b, two, ten)
    local r = ""
    -- IDIVK: 7 // 2 = 3   (MODK->1, DIVK->3.5, MULK->14, ADDK->9, SUBK->5)
    r = r .. "idivk=" .. tostring(a // 2)
    -- POWK: 2 ^ 10 = 1024 (MULK->20, ADDK->12, DIVK->0.2, MODK->2)
    r = r .. " powk=" .. tostring(two ^ 10)
    -- SUBRK: 10 - b = 6   (reversed operands -> -6)
    r = r .. " subrk=" .. tostring(10 - b)
    -- DIVRK: 10 / b = 2.5 (reversed -> 0.4)
    r = r .. " divrk=" .. tostring(10 / b)
    -- POW reg-reg: 2 ^ 10 = 1024
    r = r .. " pow=" .. tostring(two ^ ten)
    error("V11_THIN " .. r)
  end
  t(7, 4, 2, 10)
end
