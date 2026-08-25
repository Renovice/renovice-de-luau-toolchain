-- AUTO-GENERATED behavioural matrix: CMPX
function OnInit()
  local function t(a, b, c)
    if (a < b) == true then else error("C_lt_lt") end
    if (a <= b) == true then else error("C_le_lt") end
    if (a > b) == false then else error("C_gt_lt") end
    if (a >= b) == false then else error("C_ge_lt") end
    if (a == b) == false then else error("C_eq_lt") end
    if (a ~= b) == true then else error("C_ne_lt") end
    if (b < a) == false then else error("C_lt_gt") end
    if (b <= a) == false then else error("C_le_gt") end
    if (b > a) == true then else error("C_gt_gt") end
    if (b >= a) == true then else error("C_ge_gt") end
    if (b == a) == false then else error("C_eq_gt") end
    if (b ~= a) == true then else error("C_ne_gt") end
    if (a < c) == false then else error("C_lt_eq") end
    if (a <= c) == true then else error("C_le_eq") end
    if (a > c) == false then else error("C_gt_eq") end
    if (a >= c) == true then else error("C_ge_eq") end
    if (a == c) == true then else error("C_eq_eq") end
    if (a ~= c) == false then else error("C_ne_eq") end
    if a < b then else error("C_if_lt") end
    if b < a then error("C_if_ltf") end
    if a <= c then else error("C_if_le_bound") end
    if b <= a then error("C_if_lef") end
    if a >= c then else error("C_if_ge_bound") end
    if a >= b then error("C_if_gef") end
    if a == 3 then else error("C_k_eq") end
    if a == 4 then error("C_k_eqf") end
    if a ~= 4 then else error("C_k_ne") end
    if a ~= 3 then error("C_k_nef") end
    if a < 4 then else error("C_k_lt") end
    if a <= 3 then else error("C_k_le_bound") end
    if a > 2 then else error("C_k_gt") end
    if a >= 3 then else error("C_k_ge_bound") end
    if (a < a) == false then else error("C_lt_self") end
    if (a <= a) == true then else error("C_le_self") end
    error("V10_CMPX_OK")
  end
  t(3, 5, 3)
end
