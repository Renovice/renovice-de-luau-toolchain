-- BOUNDARY test of the jump-if-TRUE ordered compares (0x21 JUMPIFLE / 0x23 JUMPIFLT).
-- Value-producing compares force those forms. The a<=a / a<a boundary distinguishes < from <=.
function OnInit()
  local function t(three, five)
    local le_bound = (three <= three)   -- MUST be true  ; false => 0x21 behaves as '<'
    local lt_bound = (three < three)    -- MUST be false ; true  => 0x23 behaves as '<='
    local le_t = (three <= five)
    local le_f = (five <= three)
    local lt_t = (three < five)
    local lt_f = (five < three)
    if le_bound == true  then else error("P_LE_BOUND") end
    if lt_bound == false then else error("P_LT_BOUND") end
    if le_t == true  then else error("P_LE_T") end
    if le_f == false then else error("P_LE_F") end
    if lt_t == true  then else error("P_LT_T") end
    if lt_f == false then else error("P_LT_F") end
    error("V9_ORD_OK")
  end
  t(3, 5)
end
