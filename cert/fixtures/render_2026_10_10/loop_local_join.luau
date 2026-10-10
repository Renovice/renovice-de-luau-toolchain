-- Regression fixture (render campaign 2026-10-10, LOOP-LOCAL JOIN), compiled at -O2. Inside a while
-- body the arm of `if t < 0.5 then ... end` holds a `break`, so that branch has no real immediate
-- post-dominator although both arms meet again before the latch (44.1.1 FairySoul p11, BardAmplify
-- p11 class). The CFG renderer printed the join inside the first arm and refused the whole prototype
-- (START_ALREADY_EMITTED); the legacy region emitter then rendered it, and it cannot spell the
-- inlined two-exit search loop of the same function (#80: the arm printed outside the loop).
-- Opt-out: RENOVICE_NO_CFG_LOOP_LOCAL_JOIN.
function IsNull(v) return v == nil end
function Sleep(s) end
function DeltaTime() return 0.25 end
local Kinds = { "A", "B" }
local function IsSpecial(obj)
    for _, k in pairs(Kinds) do
        if obj:IsA(k) then
            return true
        end
    end
    return false
end
local rules = { hits = 0 }
function rules:Check(p)
    self.hits = self.hits + 1
    print("check", p, self.hits)
    return self.hits >= 4
end
function Run(target, duration)
    if target ~= nil and IsSpecial(target) then
        print("special", target.n)
    end
    local t = 0
    local left = duration
    while 0 < left do
        if IsNull(target) then
            break
        end
        if t < 0.5 then
            if not IsNull(rules) and rules:Check(target.n) then
                break
            end
            t = 0.75
        end
        Sleep(0)
        t = t - DeltaTime()
        left = left - DeltaTime()
        print("tick", t, left)
    end
    print("end", t, left)
end
function IsAImpl(s, k)
    print("IsA", s.n, k)
    return k == s.hit
end
Run({ n = 1, hit = "B", IsA = IsAImpl }, 2)
Run({ n = 2, hit = "Z", IsA = IsAImpl }, 5)
Run(nil, 1)
