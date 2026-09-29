-- Body: stock InventoryTest flat prototype 154, recovered with candidate v27.
-- Oracle: original CFG blocks 0..8; no game execution is claimed.
local u0, u1, u2, u3, u4, u5
local log = {}
IsNull = function(value) table.insert(log, "null"); return value == nil end
Lotus_Game = {SellOperation=function() table.insert(log, "create"); return {} end}
u4 = {SHIP_PARTS=1, PRIMEPARTS=2, TREASURE=3, SHIP_SCRAP=4, SHIP_RAW=5}
u5 = function() table.insert(log, "ship") end
function proto_154()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16
  local __renovice_local_0 = u0
  if __renovice_local_0 then
    do return end
  end
  __renovice_local_0 = u1
  if not __renovice_local_0 then
    v0 = gGameData
    __renovice_local_0 = IsNull
    __renovice_local_0 = __renovice_local_0(v0)
    if not __renovice_local_0 then
      __renovice_local_0 = Lotus_Game.SellOperation
      __renovice_local_0 = __renovice_local_0()
      u2 = __renovice_local_0
      __renovice_local_0 = u3
      v0 = u4
      v0 = v0.SHIP_PARTS
      if __renovice_local_0 == v0 then
        __renovice_local_0 = u5
        __renovice_local_0()
        do return end
      end
      __renovice_local_0 = u3
      v0 = u4
      v0 = v0.PRIMEPARTS
      if __renovice_local_0 == v0 then
        __renovice_local_0 = u2
        v0 = 1
        __renovice_local_0.mSellCurrency = v0
      else
        local __renovice_state_0 = 9
        __renovice_local_0 = u3
        v0 = u4
        v0 = v0.TREASURE
        if __renovice_local_0 == v0 then
          __renovice_state_0 = 12
        else
          __renovice_state_0 = 10
        end
        if __renovice_state_0 == 10 then
          __renovice_local_0 = u3
          v0 = u4
          v0 = v0.SHIP_SCRAP
          if __renovice_local_0 == v0 then
            __renovice_state_0 = 12
          else
            __renovice_state_0 = 11
          end
        end
        if __renovice_state_0 == 11 then
          __renovice_local_0 = u3
          v0 = u4
          v0 = v0.SHIP_RAW
          if __renovice_local_0 ~= v0 then
            __renovice_state_0 = 13
          else
            __renovice_state_0 = 12
          end
        end
        if __renovice_state_0 == 12 then
          __renovice_local_0 = u2
          v0 = 2
          __renovice_local_0.mSellCurrency = v0
        end
        if __renovice_state_0 == 13 then
          __renovice_local_0 = u3
          v0 = u4
          v0 = v0.ARCANE
          if __renovice_local_0 ~= v0 then
          else
            __renovice_state_0 = 14
          end
        end
        if __renovice_state_0 == 14 then
          __renovice_local_0 = u2
          v0 = 4
          __renovice_local_0.mSellCurrency = v0
        end
      end
      __renovice_local_0 = {}
      v0 = {}
      v1 = {}
      v2 = 0
      u6 = v2
      v2 = 0
      v5 = 1
      v6 = u7
      v6 = v6.mElements
      v3 = #v6
      v4 = 1
      for __renovice_for_0_0 = v5, v3, v4 do
        v6 = ResetLineCount
        v7 = 0
        v6(v7)
        v7 = u7
        v7 = v7.mElements
        v6 = v7[__renovice_for_0_0]
        v7 = v6.SellingPrice
        v11 = v6.UID
        v11 = 4
        v11 = v6.SellingPrice
        v8 = nil
        v10 = v11 * v8
        v12 = v0[v7]
        v12 = v12.CanHaveExpirables
        v12 = 24
        v13 = u6
        v12 = v13 + v10
        u6 = v12
        v2 = v2 + v8
        v9 = 0
        v10 = v6.SellingPrice
        v11 = u3
        v12 = u4
        v12 = v12.ARCANE
        if v11 == v12 then
          v11 = mMovie
          v13 = "/Lotus/Language/SystemMessages/ConfirmDistillRankWarning"
          v14 = true
          v15 = { ITEM = nil, RANK = nil }
          v16 = v6.Name
          v15.ITEM = v16
          v16 = v6.ArcaneRank
          v15.RANK = v16
          v11 = v11:GetLocalized(v13, v14, v15)
          v12 = table.insert
          v12(v1, v11)
        end
        v12 = v6.RawItem
        v12 = v12:IsTimeLimited()
        if v12 then
          v12 = u8
          v12 = v12.ShowMessage
          v13 = "/Lotus/Language/Menu/ItemInventory_CantSellTimeLimited"
          v12(v13)
          do return end
        end
        v7 = v6.Category
        v8 = 18
        if v7 == v8 then
          v8 = gGameData
          v10 = v6.UID
          v8 = v8:IsResourceDroneDeployed(v10)
          if v8 then
            v8 = u8
            v8 = v8.ShowMessage
            v9 = "/Lotus/Language/Menu/ItemInventory_CantSellResourceDrone"
            v8(v9)
            do return end
          end
        end
        v8 = u8
        v8 = v8.Ternary
        v10 = v6.Count
        if v10 == nil then
          v9 = false
        else
          v9 = true
        end
        v10 = v6.Count
        v11 = 1
        v8 = v8(v9, v10, v11)
        v9 = v8
        v10 = 0
        v11 = v6.UID
        v11 = u8
        v11 = v11.Ternary
        v13 = v6.UID
        if v13 == nil then
          v12 = false
        else
          v12 = true
        end
        v13 = v6.UID
        v14 = v6.Type
        v11 = v11(v12, v13, v14:GetFullName())
        v12 = 34
        if v7 == v12 then
          v12 = v6.RawItem
          v11 = v12:Name__c9974427()
        end
        v12 = u2
        v12:SellItem(v7, v11, v9)
        v12 = __renovice_local_0[v7]
        if v12 == nil then
          v12 = 1
          __renovice_local_0[v7] = v12
          v12 = u9
          v12 = v12(v7)
          v0[v7] = v12
        else
          v13 = __renovice_local_0[v7]
          v12 = v13 + 1
          __renovice_local_0[v7] = v12
        end
        v12 = 1
        if v7 == v12 then
          v12 = v6.RawItem
          v12 = v12:IsBayonet()
          if v12 then
            v13 = 5
            v12 = __renovice_local_0[v13]
            if v12 == nil then
              v12 = 5
              v13 = 1
              __renovice_local_0[v12] = v13
              v12 = 5
              v13 = u9
              v14 = 5
              v13 = v13(v14)
              v0[v12] = v13
            else
              v12 = 5
              v15 = 5
              v14 = __renovice_local_0[v15]
              v13 = v14 + 1
              __renovice_local_0[v12] = v13
            end
          end
        end
        v12 = v0[v7]
      end
      v3 = u2
      v4 = u6
      v3.mSellPrice = v4
      v4 = 5
      v3 = v0[v4]
      if v3 then
        v4 = 5
        v3 = __renovice_local_0[v4]
        if v3 then
          v6 = 5
          v5 = v0[v6]
          v5 = v5.Count
          v7 = 5
          v6 = __renovice_local_0[v7]
          v4 = v5 - v6
          if v4 ~= 1 then
            v3 = false
          else
            v3 = true
          end
          u10 = v3
        end
      end
      v4 = 1
      v3 = v0[v4]
      if v3 then
        v4 = 1
        v3 = __renovice_local_0[v4]
        if v3 then
          v6 = 1
          v5 = v0[v6]
          v5 = v5.Count
          v7 = 1
          v6 = __renovice_local_0[v7]
          v4 = v5 - v6
          if v4 ~= 1 then
            v3 = false
          else
            v3 = true
          end
          u11 = v3
        end
      end
      v3 = pairs
      v3, v4, v5 = v3(__renovice_local_0)
      for __renovice_for_1_0, __renovice_for_1_1 in v3, v4, v5 do
        v8 = v0[__renovice_for_1_0]
        if v8 == nil then
          continue
        end
        v8 = v0[__renovice_for_1_0]
        v8 = v8.Count
        v9 = 0
        if not (v9 <= v8) then
          continue
        end
        v8 = v0[__renovice_for_1_0]
        v8 = v8.Count
        if not (v8 <= __renovice_for_1_1) then
          continue
        end
        v8 = 15
        if __renovice_for_1_0 == v8 then
          v8 = u8
          v8 = v8.ShowMessage
          v9 = "/Lotus/Language/Menu/ItemInventory_CantSellLastSentinel"
          v8(v9)
          do return end
        end
        v8 = u8
        v8 = v8.ShowMessage
        v9 = "/Lotus/Language/Menu/ItemInventory_CantSellLastWeapon"
        v8(v9)
        do return end
      end
      v3 = u2
      v3 = v3.mSellPrice
      if v3 == 0 then
        v3 = u8
        v3 = v3.ShowMessage
        v4 = "/Lotus/Language/Menu/ItemInventory_NothingCanBeSold"
        v3(v4)
        do return end
      end
      v3 = true
      u0 = v3
      v3 = true
      u1 = v3
      v3 = "/Lotus/Language/Menu/ConfirmSellFormattedPrice"
      v5 = "/Lotus/Language/Menu/"
      v6 = u8
      v6 = v6.Ternary
      v8 = 1
      if not (v8 < v2) then
        v7 = false
      else
        v7 = true
      end
      v8 = "ItemInventory_MiscItemPlural"
      v9 = "ItemInventory_MiscItemSingular"
      v6 = v6(v7, v8, v9)
      v4 = v5 .. v6
      v5 = u8
      v5 = v5.FormatNumber
      v6 = u6
      v5 = v5(v6)
      v6 = u3
      v7 = u4
      v7 = v7.PRIMEPARTS
      for __renovice_for_2_0, __renovice_for_2_1 in v3, v4, v5 do
        __renovice_for_2_0 = "<PRIME_BUCKS>"
        v5 = __renovice_for_2_0 .. v5
        local __renovice_state_1 = 76
        __renovice_for_2_0 = u3
        __renovice_for_2_1 = u4
        __renovice_for_2_1 = __renovice_for_2_1.TREASURE
        if __renovice_for_2_0 == __renovice_for_2_1 then
          __renovice_state_1 = 79
        else
          __renovice_state_1 = 77
        end
        if __renovice_state_1 == 77 then
          __renovice_for_2_0 = u3
          __renovice_for_2_1 = u4
          __renovice_for_2_1 = __renovice_for_2_1.SHIP_SCRAP
          if __renovice_for_2_0 == __renovice_for_2_1 then
            __renovice_state_1 = 79
          else
            __renovice_state_1 = 78
          end
        end
        if __renovice_state_1 == 78 then
          __renovice_for_2_0 = u3
          __renovice_for_2_1 = u4
          __renovice_for_2_1 = __renovice_for_2_1.SHIP_RAW
          if __renovice_for_2_0 ~= __renovice_for_2_1 then
            __renovice_state_1 = 82
          else
            __renovice_state_1 = 79
          end
        end
        if __renovice_state_1 == 79 then
          __renovice_for_2_0 = "<FUSION_POINTS>"
          v5 = __renovice_for_2_0 .. v5
          __renovice_for_2_0 = u3
          __renovice_for_2_1 = u4
          __renovice_for_2_1 = __renovice_for_2_1.SHIP_SCRAP
          if __renovice_for_2_0 == __renovice_for_2_1 then
            __renovice_state_1 = 81
          else
            __renovice_state_1 = 80
          end
        end
        if __renovice_state_1 == 80 then
          __renovice_for_2_0 = u3
          __renovice_for_2_1 = u4
          __renovice_for_2_1 = __renovice_for_2_1.SHIP_RAW
          if __renovice_for_2_0 ~= __renovice_for_2_1 then
          else
            __renovice_state_1 = 81
          end
        end
        if __renovice_state_1 == 81 then
          v3 = "/Lotus/Language/Railjack/ConfirmScrap"
        end
        if __renovice_state_1 == 82 then
          __renovice_for_2_0 = u3
          __renovice_for_2_1 = u4
          __renovice_for_2_1 = __renovice_for_2_1.ARCANE
          if __renovice_for_2_0 ~= __renovice_for_2_1 then
            __renovice_state_1 = 87
          else
            __renovice_state_1 = 83
          end
        end
        if __renovice_state_1 == 83 then
          __renovice_for_2_0 = "/Lotus/Language/SystemMessages/"
          __renovice_for_2_1 = u8
          __renovice_for_2_1 = __renovice_for_2_1.Ternary
          v9 = 1
          if v9 < v2 then
            __renovice_state_1 = 85
          else
            __renovice_state_1 = 84
          end
        end
        if __renovice_state_1 == 84 then
          v8 = false
          __renovice_state_1 = 86
        end
        if __renovice_state_1 == 85 then
          v8 = true
          __renovice_state_1 = 86
        end
        if __renovice_state_1 == 86 then
          v9 = "ItemInventory_CosmeticEnhancerPlural"
          v10 = "ItemInventory_CosmeticEnhancerSingular"
          __renovice_for_2_1 = __renovice_for_2_1(v8, v9, v10)
          v4 = __renovice_for_2_0 .. __renovice_for_2_1
          v3 = "/Lotus/Language/SystemMessages/ConfirmDistill"
          __renovice_for_2_0 = "<DISTILL_POINTS>"
          v5 = __renovice_for_2_0 .. v5
        end
        if __renovice_state_1 ~= 87 then
          continue
        end
        __renovice_for_2_0 = "<"
        v10 = u12
        v10 = v10:GetLongDesc()
        __renovice_for_2_1 = v10:c_str()
        v8 = ">"
        v5 = __renovice_for_2_0 .. __renovice_for_2_1 .. v8 .. v5
      end
      v6 = mMovie
      v9 = false
      v10 = { NUMBER = nil }
      v11 = u8
      v11 = v11.FormatNumber
      v11 = v11(v2)
      v10.NUMBER = v11
      v4 = v6:GetLocalized(v4, v9, v10)
      v6 = mMovie
      v9 = true
      v10 = { ITEMS = nil, FORMATTED_PRICE = nil }
      v10.ITEMS = v4
      v10.FORMATTED_PRICE = v5
      v6 = v6:GetLocalized(v3, v9, v10)
      v7 = u3
      v8 = u4
      v8 = v8.ARCANE
      if v7 == v8 then
        v7 = #v1
        v8 = 0
        v7 = table.sort
        v9 = function(c1v0, c1v1)
          local c1v2
          if not (c1v0 < c1v1) then
            c1v2 = false
            do return c1v2 end
          end
          c1v2 = true
          do return c1v2 end
        end
        v7(v1, v9)
        v7 = ""
        v8 = ipairs
        v8, v9, v10 = v8(v1)
        for __renovice_for_3_0, __renovice_for_3_1 in v8, v9, v10 do
          v13 = 1
          if v13 < __renovice_for_3_0 then
            v14 = "\r\n"
            v7 = v7 .. v14
          end
          v7 = v7 .. __renovice_for_3_1
        end
        v9 = "\r\n\r\n"
        v6 = v7 .. v9 .. v6
        for __renovice_for_4_0, __renovice_for_4_1 in v8, v9, v10 do
        end
      end
      v7 = u8
      v7 = v7.ShowYesOrNoMessage
      v9 = "OnSellConfirmed"
      v7(v6, v9)
      do return end
    end
  end
  do return end
end


local function check(expected)
    local result = table.pack(proto_154())
    assert(result.n == 0)
    assert(table.concat(log, ";") == expected)
    log = {}
end
u0 = true
check("")
u0 = false
u1 = true
check("")
u1 = false
gGameData = nil
check("null")
gGameData = {}
u3 = 1
check("null;create;ship")
print("stock inventory guard fixture: 8 assertions passed")
