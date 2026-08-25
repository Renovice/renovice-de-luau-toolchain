function OnInit()
  local function t(three, ten)
    local v = ten % three
    if v > 13.5 then if v < 14.5 then error("M00_is14_ADDK") end end
    if v >  5.5 then if v <  6.5 then error("M00_is6_SUBK")  end end
    if v > 29.5 then if v < 30.5 then error("M00_is30_MUL")  end end
    if v > 39.5 then if v < 40.5 then error("M00_is40_MULK") end end
    if v >  2.4 then if v <  2.6 then error("M00_is2p5_DIVK") end end
    if v >  0.5 then if v <  1.5 then error("M00_is1_MOD")   end end
    if v >  2.5 then if v <  3.5 then error("M00_is3_SWAPMOD") end end
    if v >  9.5 then if v < 10.5 then error("M00_is10_LHS")  end end
    error("M00_other")
  end
  t(3, 10)
end
