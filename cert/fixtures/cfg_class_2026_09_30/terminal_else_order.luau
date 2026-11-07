-- 2026-11-07 (HarrowHeatInBubbles ApplyUpgrade): `if c then <long arm, closure, falls to the end> else
-- <closure> end` with both arms ending the function. The structurer took the JUMP-reached else arm as a
-- guard (`if not c then <else> return end <then>`): the same behavior, but source order swapped and Luau
-- numbers child functions in source order, so the two closures exchanged prototype ids (CFG-only).
local state = {}
local function apply(master, id)
  if master then
    state.players = state.players or {}
    state.players[id] = true
    state.override = function(a, b)
      return state.players[a] and b or false
    end
    print("master", id, state.override(id, 7))
  else
    state.override = function()
      return true
    end
  end
end
apply(true, 3)
apply(false, 4)
print(state.override(3, 1))
