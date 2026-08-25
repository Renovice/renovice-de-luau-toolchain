function OnInit()
  local y
  local n = 5
  -- each of these emits the jump-if-EQUAL form via our JUMPXEQK lowering
  if y ~= nil then print("EQ3a:nil_neq=WRONG") else print("EQ3a:nil_neq=ok") end
  if n ~= 5   then print("EQ3a:num_neq=WRONG") else print("EQ3a:num_neq=ok") end
  if n ~= 9   then print("EQ3a:num_neq9=ok") else print("EQ3a:num_neq9=WRONG") end
  error("EQ3a_DONE")
end
