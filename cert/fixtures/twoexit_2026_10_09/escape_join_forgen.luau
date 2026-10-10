-- Regression fixture (2026-10-09, DEFECTS #76): 44.1.1 ApproachAnim p1 shape, compiled at -O2.
-- The local helper's `return true` inside a generic for is inlined as `r = true; JUMP join` inside
-- the body while the loop's exhaustion code `r = false` follows the FORGLOOP: a loop with two exit
-- destinations. The legacy region rendering printed the arm outside the loop (IsA(nil), no loop
-- test) and claimed the `for` twice; the CFG renderer rejected it (START_OUTSIDE_DOMAIN).
-- Fixed rendering: the arm runs inside the loop, records the escape in a generated selector and
-- breaks; `r = false` runs only when no escape was taken. Opt-out: RENOVICE_NO_CFG_LOOP_ESCAPE_JOIN.
local Things = { "A", "B" }
local function IsSpecial(obj)
    for _, t in pairs(Things) do
        if obj:IsA(t) then
            return true
        end
    end
    return false
end
function OnActivate(self)
    local anim = self:GetOverrideAnim()
    if anim == nil or IsSpecial(anim) then
        return
    end
    print("play", anim.n)
end
function IsAImpl(s, t)
    print("IsA", s.n, t)
    return t == s.hit
end
function Get1() return { n = 1, hit = "B", IsA = IsAImpl } end
function Get2() return { n = 2, hit = "Z", IsA = IsAImpl } end
function Get3() return nil end
OnActivate({ GetOverrideAnim = Get1 })
OnActivate({ GetOverrideAnim = Get2 })
print(pcall(OnActivate, { GetOverrideAnim = Get3 }))
