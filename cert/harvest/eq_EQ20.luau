function OnInit()
  local y
  local n = 5
  -- each of these emits the jump-if-EQUAL form via our JUMPXEQK lowering
  if y ~= nil then print("EQ20:nil_neq=WRONG") else print("EQ20:nil_neq=ok") end
  if n ~= 5   then print("EQ20:num_neq=WRONG") else print("EQ20:num_neq=ok") end
  if n ~= 9   then print("EQ20:num_neq9=ok") else print("EQ20:num_neq9=WRONG") end
  error("EQ20_DONE")
end
