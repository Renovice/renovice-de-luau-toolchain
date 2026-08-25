-- Cert v8: the M4-completion ops. reg-key table read/write (0x01/0x2a), generic-for pairs(0x30)/ipairs(0x1b)
-- + FORGLOOP(0x1e), and FASTCALL-dropped math builtins. Defensive: fresh local tables, bracketed checks.
function OnInit()
    local function body(one, two, three, ten)
        -- reg-key write + read  (t[k]=v ; t[k])
        local t = {}
        local k = three
        t[k] = ten
        local rv = t[k]
        if rv > 9  then else error("REGKEY_lo") end
        if rv < 11 then else error("REGKEY_hi") end
        -- reg-key write with a computed key, read back
        t[k + one] = two
        local rv2 = t[k + one]
        if rv2 > 1 then else error("REGKEY2_lo") end
        if rv2 < 3 then else error("REGKEY2_hi") end
        -- ipairs generic-for (FORGPREP_INEXT 0x1b + FORGLOOP 0x1e aux bit31)
        local arr = { 10, 20, 30 }
        local sum = 0
        local cnt = 0
        for i, v in ipairs(arr) do sum = sum + v cnt = cnt + one end
        if sum > 59 then else error("IPAIRS_sum_lo") end
        if sum < 61 then else error("IPAIRS_sum_hi") end
        if cnt > 2  then else error("IPAIRS_cnt_lo") end
        if cnt < 4  then else error("IPAIRS_cnt_hi") end
        -- pairs generic-for (FORGPREP_NEXT 0x30)
        local psum = 0
        for kk, vv in pairs(arr) do psum = psum + vv end
        if psum > 59 then else error("PAIRS_lo") end
        if psum < 61 then else error("PAIRS_hi") end
        -- FASTCALL-dropped builtins (must still work via the normal call path)
        local fl = math.floor(three + 0.7)
        if fl > 2 then else error("FLOOR_lo") end
        if fl < 4 then else error("FLOOR_hi") end
        local mx = math.max(one, ten)
        if mx > 9  then else error("MAX_lo") end
        if mx < 11 then else error("MAX_hi") end
    end
    body(1, 2, 3, 10)
    error("CERT_V8_PASS")
end
