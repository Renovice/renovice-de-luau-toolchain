-- TESTSET 0x51 identification. Carrier is a MOVE (0x14, same A<-B layout), patched to 0x51.
-- Our decode claim: copy R[B] to R[A] if R[B] is truthy, ELSE SKIP the next instruction.
-- So the instruction AFTER it must be observable, or the skip is invisible and a plain MOVE
-- would look identical. `mark` is that observable.
--   if 0x51 is TESTSET : truthy src -> dst=src, mark=77 ; falsey src -> dst stays 111, mark stays 0
--   if 0x51 is a MOVE  : dst=src and mark=77 in BOTH cases
function OnInit()
  local function probe(src)
    local dst = 111
    local mark = 0
    dst = src        -- MOVE  (this is the patched instruction)
    mark = 77        -- LOADN (skipped iff the patched op skips)
    return dst, mark
  end
  local d1, m1 = probe(7)       -- truthy
  local d2, m2 = probe(false)   -- falsey
  error("V14_TESTSET t_dst=" .. tostring(d1) .. " t_mark=" .. tostring(m1) ..
        " f_dst=" .. tostring(d2) .. " f_mark=" .. tostring(m2))
end
