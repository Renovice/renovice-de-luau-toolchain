-- v11: NATIVE ANDK (0x31). Built with RENOVICE_NATIVE_ANDK=1 so the transcoder emits the real
-- DE opcode instead of our proven MOVE+JUMPIFNOT lowering. This is the ONLY way to certify 0x31,
-- whose meaning was inferred from just 22 corpus instances.
-- Semantics under test: R[A] = R[B] and K[C]  -- Lua `and` returns the LEFT operand when falsey,
-- otherwise the RIGHT one. Values are reported, so a wrong answer identifies what 0x31 really is.
function OnInit()
  local function t(tru, fls, nl, num)
    local r = ""
    r = r .. "t_and_t=" .. tostring(tru and true)    -- true  and true  -> true
    r = r .. " t_and_f=" .. tostring(tru and false)  -- true  and false -> false
    r = r .. " f_and_t=" .. tostring(fls and true)   -- false and true  -> false  (LEFT operand)
    r = r .. " n_and_t=" .. tostring(nl and true)    -- nil   and true  -> nil    (LEFT operand)
    r = r .. " num_and_t=" .. tostring(num and true) -- 5     and true  -> true
    error("V11_ANDK " .. r)
  end
  t(true, false, nil, 5)
end
