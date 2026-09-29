-- Body: stock Dojo/Trade flat prototype 67, recovered by candidate v33.
-- Oracle: six-slot loop, Plat/Card skip guards, inner MOD/PLATINUM skip loop,
-- Filler callback and final completion. Native methods are deterministic mocks.
local u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12, u13
local log = {}
local entries = {}
local function record(value) table.insert(log, value) end
IsNull = function(value) record("null"); return value == nil end
gGameRules = {Name__b07f6191=function(self) record("rules"); return {} end}
u1 = {GetElementInIndex=function(self, index) record("get" .. index); return entries[index] end}
u2 = {MOD=1, PLATINUM=2}
u4 = function(value) assert(value == true); record("fill") end
u13 = function() record("done") end
local function slots(kind)
    local result = {}
    for i = 1, 6 do result[i] = if kind == "plat" then {Plat=true} else {Card=false} end
    return result
end
function proto_67(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15
  v1 = false
  u0 = v1
  v1 = IsNull
  v1 = v1(v0)
  if not v1 then
    v1 = gGameRules
    v1 = v1:Name__b07f6191()
    v2 = 1
    v5 = 1
    v3 = 6
    v4 = 1
    for __renovice_for_0_0 = v5, v3, v4 do
      v6 = v0[__renovice_for_0_0]
      v7 = v6.Plat
      if v7 then
        continue
      end
      v7 = v6.Card
      if v7 ~= nil then
        continue
      end
      v7 = u1
      v7 = v7:GetElementInIndex(v2)
      while true do
        v8 = v7.TradeType
        v9 = u2
        v9 = v9.MOD
        if v8 ~= v9 then
          v8 = v7.TradeType
          v9 = u2
          v9 = v9.PLATINUM
          if v8 ~= v9 then break end
        end
        v2 = v2 + 1
        v8 = u1
        v7 = v8:GetElementInIndex(v2)
      end
      u3 = v7
      v8 = v6.Filler
      if v8 then
        v8 = u4
        v9 = true
        v8(v9)
      else
        v8 = u3
        if v8 ~= nil then
          v8 = u5
          v8 = v8(v6)
          v9 = u6
          if not v9 then
            v9 = v6.StoreItem
            v9 = v9:GetRequiredLevel()
            v10 = u7
            if v10 < v9 then
              v9 = u8
              v9 = v9.Ternary
              v11 = u2
              v11 = v11.WEAPONS
              if v8 ~= v11 then
                v10 = false
              else
                v10 = true
              end
              v11 = "/Lotus/Language/Dojo/TRADE_OFFER_ERR_WEAPON_XP_LOCKED"
              v12 = "/Lotus/Language/Dojo/TRADE_OFFER_ERR_ITEM_XP_LOCKED"
              v9 = v9(v10, v11, v12)
              v10 = u8
              v10 = v10.ShowMessage
              v11 = mMovie
              v14 = false
              v15 = u9
              v10(v11:GetLocalized(v9, v14, v15))
              do return end
            end
          end
          v9 = u2
          v9 = v9.WEAPONS
          if v8 == v9 then
            v9 = v6.RawItem
            v9 = v9:CanTrade()
            if not v9 then
              v9 = u8
              v9 = v9.ShowMessage
              v10 = mMovie
              v12 = "/Lotus/Language/Dojo/TRADE_ERR_WEAPON_NOT_UNRANKED"
              v13 = false
              v9(v10:GetLocalized(v12, v13))
              do return end
            end
            v9 = v6.RawItem
            v9 = v9:IsTimeLimited()
            if v9 then
              v9 = u8
              v9 = v9.ShowMessage
              v10 = mMovie
              v12 = "/Lotus/Language/Dojo/TRADE_ERR_WEAPON_WILL_EXPIRE"
              v13 = false
              v9(v10:GetLocalized(v12, v13))
              do return end
            end
          end
          v9 = u2
          v9 = v9.WEAPON_SKINS
          if v8 == v9 then
            v9 = v6.RawItem
            v9 = v9:IsTimeLimited()
            if v9 then
              v9 = u8
              v9 = v9.ShowMessage
              v10 = mMovie
              v12 = "/Lotus/Language/Dojo/TRADE_ERR_WEAPON_SKIN_WILL_EXPIRE"
              v13 = false
              v9(v10:GetLocalized(v12, v13))
              do return end
            end
          end
          v9 = u10
          v10 = u1
          v11 = u3
          v9 = v9(v10, v11)
          u3 = v9
          v9 = u11
          v9 = v9.GetStoreItemInfo
          v10 = mMovie
          v11 = v6.StoreItem
          v12 = { GetVisibilityMaterial = false, AppendInfo = nil, ItemInfo = nil }
          v13 = u3
          v12.AppendInfo = v13
          v13 = v6.RawItem
          v12.ItemInfo = v13
          v14 = nil
          v15 = true
          v9 = v9(v10, v11, v12, v1, v14, v15)
          u3 = v9
          v9 = u3
          v10 = 1
          v9.Count = v10
          v9 = u3
          v10 = v6.Type
          v9.mItemType = v10
          v9 = u3
          v10 = v6.Type
          v9.Trading = v10
          u3.TradeType = v8
          v9 = u3
          v10 = v6.ArcaneRank
          v9.ArcaneRank = v10
          v9 = u3
          v10 = v6.ArcaneMaxRank
          v9.ArcaneMaxRank = v10
          v9 = u3
          v9 = v9.TradeType
          v10 = u2
          v10 = v10.FUSION_TREASURES
          if v9 == v10 then
            v9 = u3
            v10 = v6.RawItem
            v9.Trading = v10
          else
            v9 = u3
            v9 = v9.TradeType
            v10 = u2
            v10 = v10.KUBROW_PRINTS
            if v9 == v10 then
              v9 = u3
              v10 = v6.RawItem
              v9.Trading = v10
            else
              v9 = u3
              v9 = v9.TradeType
              v10 = u2
              v10 = v10.LICH
              if v9 == v10 then
                v9 = u3
                v10 = v6.RawItem
                v9.Trading = v10
              else
                v9 = u3
                v9 = v9.TradeType
                v10 = u2
                v10 = v10.EMOTE
                if v9 == v10 then
                  v9 = u3
                  v10 = v6.RawItem
                  v9.Trading = v10
                else
                  local __renovice_state_0 = -1
                  v9 = u3
                  v9 = v9.TradeType
                  v10 = u2
                  v10 = v10.WEAPONS
                  if v9 == v10 then
                    __renovice_state_0 = -1
                  else
                    __renovice_state_0 = 1
                  end
                  if __renovice_state_0 == 1 then
                    v9 = u3
                    v9 = v9.TradeType
                    v10 = u2
                    v10 = v10.WEAPON_SKINS
                    if v9 ~= v10 then
                      __renovice_state_0 = 2
                    else
                      __renovice_state_0 = -1
                    end
                  end
                  if __renovice_state_0 == 2 then
                    v9 = u3
                    v9 = v9.TradeType
                    v10 = u2
                    v10 = v10.ENHANCEMENTS
                    if v9 ~= v10 then
                      __renovice_state_0 = 4
                    else
                      __renovice_state_0 = 3
                    end
                  end
                  if __renovice_state_0 == 3 then
                    v9 = u3
                    v10 = v6.Name
                    v9.Name = v10
                    v9 = u3
                    v10 = v6.RawItem
                    v9.Trading = v10
                    __renovice_state_0 = 4
                  end
                  if __renovice_state_0 ~= 4 then
                    v9 = u3
                    v10 = v6.RawItem
                    v9.Trading = v10
                    v9 = u3
                    v10 = v6.StoreItem
                    v10 = v10:GetProductCategory()
                    v9.Category = v10
                  end
                end
              end
            end
          end
          v9 = u12
          v10 = true
          v9(v10)
        end
      end
      v2 = v2 + 1
    end
    v3 = u13
    v3()
  end
  do return end
end


local checks = 0
local function check(items, expected, final)
    log = {}
    u0 = true
    u3 = nil
    local result = table.pack(proto_67(items))
    assert(result.n == 0)
    assert(u0 == false)
    assert(table.concat(log, ";") == expected)
    assert((u3 and u3.id or nil) == final)
    checks += 4
end
check(nil, "null", nil)
check(slots("plat"), "null;rules;done", nil)
check(slots("card"), "null;rules;done", nil)
local items = slots("plat")
items[2] = {Filler=true}
items[5] = {Filler=true}
entries = {{TradeType=1}, {TradeType=2}, {TradeType=3,id="a"}, {TradeType=3,id="b"}}
check(items, "null;rules;get1;get2;get3;fill;get4;fill;done", "b")
print("stock dojo loop fixture: 16 assertions passed")
