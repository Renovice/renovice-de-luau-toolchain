function OnInit()
  local function t(a, b)
    local n
    if a == 5    then else error("XEQ_num") end   -- KN ==, notbit=1 -> 0x27
    if a ~= 6    then else error("XNE_num") end   -- KN ~=, notbit=0 -> 0x20
    if b == "hi" then else error("XEQ_str") end   -- KS ==
    if n == nil  then else error("XEQ_nil") end   -- KNIL ==
    error("XEQK_OK")
  end
  t(5, "hi")
end
