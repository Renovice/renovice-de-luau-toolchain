-- 0x51 identification, take 2. The first attempt patched a MOVE and set C=0 as a "flag" —
-- but de-fieldaudit shows C is a CONST INDEX (38.5% exceed maxstack, 0% exceed nconsts), and the
-- probe's proto had NO constants, so C=0 indexed an empty table and the chunk died silently.
-- Carrier is now ADDK (R[A]=R[B]+K[C]), which already carries a VALID const index, then patched to 0x51.
-- de-ktags says 0x51's constants are mixed (70% number, 20% string, some nil/bool) = a DEFAULT VALUE,
-- which is the signature of ORK: R[A] = R[B] or K[C].
--   ORK  : truthy->left (7),  false->right (5), nil->right (5)
--   ANDK : truthy->right (5), false->left (false), nil->left (nil)
--   ADDK : 12, and would ERROR on false/nil
function OnInit()
  local function probe(src)
    return src + 5
  end
  error("V15_ORK t=" .. tostring(probe(7)) .. " f=" .. tostring(probe(false)) .. " n=" .. tostring(probe(nil)))
end
