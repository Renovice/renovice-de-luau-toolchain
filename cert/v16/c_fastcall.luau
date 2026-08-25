-- NATIVE FASTCALL emission (0x10/0x19/0x26/0x0c). Until now we DROPPED these, losing the builtin
-- fast path on every recompiled script.
-- The risk being tested is NOT "does it crash" — a fastcall whose builtin id is unrecognised simply
-- falls through to the slow path and returns the right answer. The risk is a WRONG BUILTIN ID, which
-- returns a plausible wrong NUMBER. So every value is reported, and the pairs are chosen so that
-- neighbouring builtin ids disagree:
--   math.max(id 18) vs math.min(id 19) are ADJACENT -> an off-by-one is immediately visible
--   floor(id 12) 3.7 -> 3 while ceil(id 7) 3.7 -> 4
function OnInit()
  local function t(a, b, neg)
    local r = ""
    r = r .. "floor=" .. tostring(math.floor(a))     -- 3.7 -> 3   (ceil would give 4)
    r = r .. " ceil=" .. tostring(math.ceil(a))      -- 3.7 -> 4
    r = r .. " max=" .. tostring(math.max(2, b))     -- (2,9) -> 9 (min would give 2)
    r = r .. " min=" .. tostring(math.min(2, b))     -- (2,9) -> 2 (max would give 9)
    r = r .. " abs=" .. tostring(math.abs(neg))      -- -5 -> 5
    r = r .. " sqrt=" .. tostring(math.sqrt(16))     -- 4
    r = r .. " maxk=" .. tostring(math.max(a, 10))   -- FASTCALL2K path -> 10
    r = r .. " type=" .. tostring(type(a))           -- "number"
    error("V16_FASTCALL " .. r)
  end
  t(3.7, 9, -5)
end
