-- RENOVICE_NAME_HASH_SEED: 768e5ed0
-- RENOVICE_HASH_FIELD: ApplyHighLow
-- RENOVICE_HASH_FIELD: GetStarChart
  local v0, v1, v2, v3, v4, v5, v6, v7
  v0 = require
  v1 = "Lotus.Scripts.Effects.EffectsColorUtilities"
  v0 = v0(v1)
  v1 = require
  v2 = "Lotus.Interface.LotusUtilities"
  v1 = v1(v2)
  v2 = 0
  v3 = function()
    local c1v0
    c1v0 = _T.maximumSyndicateScarfIntensity
    if c1v0 then
      c1v0 = 1
      do return c1v0 end
    end
    c1v0 = v2
    do return c1v0 end
  end
  v4 = function(c2v0)
    local c2v1, c2v2
    c2v1 = c2v0:GetPlayer()
    c2v2 = IsNull
    c2v2 = c2v2(c2v1)
    if c2v2 then
      do return c2v0:GetInstance() end
    end
    do return c2v1:GetPlayerName() end
  end
  v5 = function()
    local c3v0, c3v1, c3v2
    c3v0 = gGameRules
    c3v1 = IsNull
    c3v1 = c3v1(c3v0)
    if c3v1 then
      c3v1 = false
      do return c3v1 end
    end
    c3v2 = gLotusHubGameRulesType
    c3v1 = c3v0:IsA(c3v2)
    if not c3v1 then
      c3v2 = gLotusAttractModeGameRulesType
      c3v1 = c3v0:IsA(c3v2)
    end
    do return c3v1 end
  end
  v6 = function(c4v0)
    local c4v1, c4v2, c4v3, c4v4, c4v5, c4v6, c4v7, c4v8, c4v9
    c4v1 = IsNull
    c4v1 = c4v1(c4v0)
    if c4v1 then
      do return end
    end
    c4v1 = c4v0:GetRootOwner()
    c4v2 = IsNull
    c4v2 = c4v2(c4v1)
    if not c4v2 then
      c4v4 = gBaseAvatarType
      c4v2 = c4v1:IsA(c4v4)
      if c4v2 then
        c4v2 = c4v1:InventoryControl()
        c4v2 = c4v2:GetActivePowerSuit()
        c4v3 = IsNull
        c4v3 = c4v3(c4v2)
        if not c4v3 then
          c4v3 = 8
          c4v4 = nil
          while true do
            c4v5 = IsNull
            c4v5 = c4v5(c4v4)
            if not c4v5 then break end
            c4v5 = 0
            if not (c4v5 < c4v3) then break end
            c4v4 = c4v2:GetCustomization()
            c4v3 = c4v3 - 1
            c4v5 = Sleep
            c4v6 = 0.1
            c4v5(c4v6)
          end
          c4v7 = 1
          c4v5 = c4v4:GetColors(c4v7)
          c4v8 = 6
          c4v6 = c4v5:Initialized(c4v8)
          if c4v6 then
            c4v6 = v0
            c4v6 = c4v6.ApplyHighLow
            c4v8 = Color
            c4v9 = c4v5.mEnergyColor
            c4v6(c4v0, c4v8(c4v9))
          else
            c4v8 = Lotus_Game.LOW_COLOR
            c4v0:RemoveMaterialParam(c4v8)
            c4v8 = Lotus_Game.HIGH_COLOR
            c4v0:RemoveMaterialParam(c4v8)
          end
        end
        c4v3 = gGameRules
        c4v4 = IsNull
        c4v4 = c4v4(c4v3)
        if c4v4 then
          do return end
        end
        c4v6 = gLotusAttractModeGameRulesType
        c4v4 = c4v3:IsA(c4v6)
        if c4v4 then
          c4v5 = gPlayerProfileMgr
          c4v7 = 0
          c4v5 = c4v5:GetPlayerProfile(c4v7)
          c4v5 = c4v5:GetGameSpecificData()
          c4v5 = c4v5:GetLoadOut()
          c4v5 = c4v5.mScarfSyndicateValue
          c4v4 = c4v5 / 255
          v2 = c4v4
          do return end
        end
        c4v4 = c4v1:GetPlayer()
        c4v5 = 8
        while true do
          c4v6 = IsNull
          c4v6 = c4v6(c4v4)
          if not c4v6 then
            c4v6 = c4v4:Name__33b57067()
            if c4v6 then break end
          end
          c4v6 = 0
          if not (c4v6 < c4v5) then break end
          c4v4 = c4v1:GetPlayer()
          c4v5 = c4v5 - 1
          c4v6 = Sleep
          c4v7 = 0.1
          c4v6(c4v7)
        end
        c4v6 = IsNull
        c4v6 = c4v6(c4v4)
        if not c4v6 then
          c4v7 = c4v4:GetLoadOut()
          c4v7 = c4v7.mScarfSyndicateValue
          c4v6 = c4v7 / 255
          v2 = c4v6
          do return end
        end
        c4v6 = 1
        v2 = c4v6
        do return end
      end
    end
    do return end
  end
  v7 = function()
    local c5v0
    c5v0 = 50
    do return c5v0 end
  end
  CephalonHubEval = v7
  v7 = function(c6v0)
    local c6v1, c6v2, c6v3, c6v4, c6v5, c6v6, c6v7, c6v8, c6v9, c6v10, c6v11
    c6v1 = v6
    c6v1(c6v0)
    c6v1 = Sleep
    c6v2 = 0
    c6v1(c6v2)
    c6v2 = gGameRules
    c6v3 = IsNull
    c6v3 = c6v3(c6v2)
    if c6v3 then
      c6v1 = false
    else
      c6v5 = gLotusHubGameRulesType
      c6v1 = c6v2:IsA(c6v5)
      if not c6v1 then
        c6v5 = gLotusAttractModeGameRulesType
        c6v1 = c6v2:IsA(c6v5)
      end
    end
    c6v2 = c6v0:GetRootOwner()
    c6v3 = IsNull
    c6v3 = c6v3(c6v2)
    if not c6v3 then
      c6v5 = gBaseAvatarType
      c6v3 = c6v2:IsA(c6v5)
      if not c6v3 then
        do return end
      end
      c6v4 = c6v2:GetPlayer()
      c6v5 = IsNull
      c6v5 = c6v5(c6v4)
      if c6v5 then
        c6v3 = c6v2:GetInstance()
      else
        c6v3 = c6v4:GetPlayerName()
      end
      while true do
        c6v4 = IsNull
        c6v4 = c6v4(c6v0)
        if c6v4 then break end
        c6v6 = _T.maximumSyndicateScarfIntensity
        if c6v6 then
          c6v5 = 1
        else
          c6v5 = v2
        end
        c6v4 = c6v5 * 2
        c6v5 = _T.CephSudaEffects
        if c6v5 ~= nil then
          c6v6 = _T.CephSudaEffects
          c6v5 = c6v6[c6v3]
          if c6v5 ~= nil then
            c6v5 = Clamp
            c6v7 = _T.CephSudaEffects
            c6v6 = c6v7[c6v3]
            c6v6 = c6v6.Flash
            c6v7 = 0
            c6v8 = 1
            c6v5 = c6v5(c6v6, c6v7, c6v8)
            c6v6 = c6v5 * 2
            c6v4 = c6v4 + c6v6
            c6v7 = _T.CephSudaEffects
            c6v6 = c6v7[c6v3]
            c6v8 = 0
            c6v11 = _T.CephSudaEffects
            c6v10 = c6v11[c6v3]
            c6v10 = c6v10.Flash
            c6v11 = DeltaTime
            c6v11 = c6v11()
            c6v9 = c6v10 - c6v11
            c6v7 = math.max
            c6v7 = c6v7(c6v8, c6v9)
            c6v6.Flash = c6v7
          end
        end
        c6v7 = Lotus_Game.UNLIT_ATTEN
        c6v0:SetMaterialParam(c6v7, c6v4)
        c6v7 = Lotus_Game.EMISSIVE_MAP_ATTEN
        c6v8 = c6v4 * 2
        c6v0:SetMaterialParam(c6v7, c6v8)
        if c6v1 then
          do return end
        end
        c6v5 = Sleep
        c6v6 = 0
        c6v5(c6v6)
      end
      do return end
    end
    do return end
  end
  CephalonScarfUpdate = v7
  v7 = function()
    local c7v0
    c7v0 = 50
    do return c7v0 end
  end
  RedVeilHubEval = v7
  v7 = function(c8v0)
    local c8v1, c8v2, c8v3, c8v4, c8v5, c8v6, c8v7, c8v8, c8v9, c8v10, c8v11, c8v12
    c8v1 = v6
    c8v1(c8v0)
    c8v1 = c8v0:GetRootOwner()
    c8v2 = IsNull
    c8v2 = c8v2(c8v1)
    if not c8v2 then
      c8v4 = gBaseAvatarType
      c8v2 = c8v1:IsA(c8v4)
      if c8v2 then
        c8v3 = c8v1:GetPlayer()
        c8v4 = IsNull
        c8v4 = c8v4(c8v3)
        if c8v4 then
          c8v2 = c8v1:GetInstance()
        else
          c8v2 = c8v3:GetPlayerName()
        end
        c8v3 = Sleep
        c8v4 = 0
        c8v3(c8v4)
        c8v3 = SmoothFloat
        c8v4 = 0
        c8v5 = 0.15
        c8v3 = c8v3(c8v4, c8v5)
        c8v6 = gLensFlareType
        c8v4 = c8v0:GetAttachment(c8v6)
        while true do
          c8v5 = IsNull
          c8v5 = c8v5(c8v0)
          if c8v5 then break end
          c8v7 = _T.maximumSyndicateScarfIntensity
          if c8v7 then
            c8v6 = 1
          else
            c8v6 = v2
          end
          c8v5 = c8v6 * 2
          c8v6 = _T.VeilEffects
          if c8v6 ~= nil then
            c8v7 = _T.VeilEffects
            c8v6 = c8v7[c8v2]
            if c8v6 ~= nil then
              c8v6 = Clamp
              c8v8 = _T.VeilEffects
              c8v7 = c8v8[c8v2]
              c8v7 = c8v7.Flash
              c8v8 = 0
              c8v9 = 1
              c8v6 = c8v6(c8v7, c8v8, c8v9)
              c8v7 = c8v6 * 4
              c8v5 = c8v5 + c8v7
              c8v8 = _T.VeilEffects
              c8v7 = c8v8[c8v2]
              c8v9 = 0
              c8v12 = _T.VeilEffects
              c8v11 = c8v12[c8v2]
              c8v11 = c8v11.Flash
              c8v12 = DeltaTime
              c8v12 = c8v12()
              c8v10 = c8v11 - c8v12
              c8v8 = math.max
              c8v8 = c8v8(c8v9, c8v10)
              c8v7.Flash = c8v8
            end
          end
          c8v6 = c8v1:GetPosture()
          c8v7 = 4
          if c8v6 == c8v7 then
            c8v10 = 0.1
            c8v8 = math.min
            c8v8 = c8v8(c8v5, c8v10)
            c8v3:SetTargetVal(c8v8)
          else
            c8v3:SetTargetVal(c8v5)
          end
          c8v8 = DeltaTime
          c8v3:Update(c8v8())
          c8v6 = c8v3:GetVal()
          c8v7 = IsNull
          c8v7 = c8v7(c8v4)
          if not c8v7 then
            c8v9 = Clamp
            c8v11 = 0.25
            c8v12 = 1
            c8v4:SetOpacity(c8v9(c8v6, c8v11, c8v12))
          end
          c8v9 = Lotus_Game.UNLIT_ATTEN
          c8v0:SetMaterialParam(c8v9, c8v6)
          c8v7 = Sleep
          c8v8 = 0
          c8v7(c8v8)
        end
        do return end
      end
    end
    do return end
  end
  RedVeilScarfUpdate = v7
  v7 = function()
    local c9v0, c9v1, c9v2, c9v3, c9v4, c9v5, c9v6, c9v7, c9v8
    c9v0 = v1
    c9v0 = c9v0.GetStarChart
    c9v0 = c9v0()
    c9v1 = c9v0:GetAllNodes()
    c9v2 = 0
    c9v3 = 0
    c9v4 = ipairs
    c9v4, c9v5, c9v6 = c9v4(c9v1)
    for __renovice_for_0_0, __renovice_for_0_1 in c9v4, c9v5, c9v6 do
      c9v2 = c9v2 + 1
      c9v8 = __renovice_for_0_1.unlocked
      if not c9v8 then
        continue
      end
      c9v3 = c9v3 + 1
    end
    c9v4 = Lerp
    c9v5 = 0
    c9v6 = 255
    c9v7 = c9v3 / c9v2
    c9v4 = c9v4(c9v5, c9v6, c9v7)
    do return c9v4 end
  end
  SteelMeridianHubEval = v7
  v7 = function(c10v0)
    local c10v1, c10v2, c10v3, c10v4, c10v5, c10v6, c10v7, c10v8, c10v9, c10v10, c10v11, c10v12, c10v13, c10v14, c10v15
    c10v1 = v6
    c10v1(c10v0)
    c10v1 = Sleep
    c10v2 = 0
    c10v1(c10v2)
    c10v1 = c10v0:GetRootOwner()
    c10v3 = gGameRules
    c10v2 = IsNull
    c10v2 = c10v2(c10v3)
    if not c10v2 then
      c10v2 = IsNull
      c10v2 = c10v2(c10v1)
      if not c10v2 then
        c10v4 = gBaseAvatarType
        c10v2 = c10v1:IsA(c10v4)
        if not c10v2 then
          do return end
        end
        c10v3 = c10v1:GetPlayer()
        c10v4 = IsNull
        c10v4 = c10v4(c10v3)
        if c10v4 then
          c10v2 = c10v1:GetInstance()
        else
          c10v2 = c10v3:GetPlayerName()
        end
        c10v4 = gGameRules
        c10v5 = IsNull
        c10v5 = c10v5(c10v4)
        if c10v5 then
          c10v3 = false
        else
          c10v7 = gLotusHubGameRulesType
          c10v3 = c10v4:IsA(c10v7)
          if not c10v3 then
            c10v7 = gLotusAttractModeGameRulesType
            c10v3 = c10v4:IsA(c10v7)
          end
        end
        c10v6 = attachedDecoType
        c10v4 = c10v1:GetAttachment(c10v6)
        c10v7 = extraAttachedDecoType
        c10v5 = c10v1:GetAllAttachments(c10v7)
        c10v6 = false
        while true do
          c10v7 = IsNull
          c10v7 = c10v7(c10v0)
          if c10v7 then break end
          c10v8 = _T.maximumSyndicateScarfIntensity
          if c10v8 then
            c10v7 = 1
          else
            c10v7 = v2
          end
          c10v8 = DeltaTime
          c10v8 = c10v8()
          c10v9 = _T.MeridianEffects
          if c10v9 ~= nil then
            c10v10 = _T.MeridianEffects
            c10v9 = c10v10[c10v2]
            if c10v9 ~= nil then
              c10v10 = _T.MeridianEffects
              c10v9 = c10v10[c10v2]
              c10v9 = c10v9.Shields
              c10v11 = _T.MeridianEffects
              c10v10 = c10v11[c10v2]
              c10v10 = c10v10.Health
              c10v12 = _T.MeridianEffects
              c10v11 = c10v12[c10v2]
              c10v12 = Lerp
              c10v14 = 0
              c10v15 = c10v8 * 2
              c10v12 = c10v12(c10v9, c10v14, c10v15)
              c10v11.Shields = c10v12
              c10v12 = _T.MeridianEffects
              c10v11 = c10v12[c10v2]
              c10v12 = Lerp
              c10v14 = 0
              c10v15 = c10v8 / 2
              c10v12 = c10v12(c10v10, c10v14, c10v15)
              c10v11.Health = c10v12
              c10v11 = c10v9 / 25
              c10v7 = c10v7 + c10v11
              c10v11 = c10v10 / 25
              c10v7 = c10v7 + c10v11
            end
          end
          c10v11 = Lotus_Game.UNLIT_ATTEN
          c10v0:SetMaterialParam(c10v11, c10v7)
          c10v9 = Lerp
          c10v10 = 3
          c10v12 = 1
          c10v14 = Name__975a761b
          c10v15 = Time
          c10v14 = c10v14(c10v15())
          c10v13 = c10v14 * 6
          c10v11 = c10v12 + c10v13
          c10v12 = Clamp
          c10v14 = 0
          c10v15 = 1
          c10v9 = c10v9(c10v10, c10v11, c10v12(c10v7, c10v14, c10v15))
          c10v12 = Lotus_Game.EMISSIVE_MAP_ATTEN
          c10v0:SetMaterialParam(c10v12, c10v9)
          c10v10 = IsNull
          c10v10 = c10v10(c10v4)
          if not c10v10 then
            c10v12 = Lotus_Game.UNLIT_ATTEN
            c10v4:SetMaterialParam(c10v12, c10v7)
          end
          c10v10 = IsNull
          c10v10 = c10v10(c10v5)
          if not c10v10 then
            c10v10 = 1
            if (c10v10 < c10v7 and not c10v6) then
              c10v10 = ipairs
              c10v10, c10v11, c10v12 = c10v10(c10v5)
              for __renovice_for_0_0, __renovice_for_0_1 in c10v10, c10v11, c10v12 do
                __renovice_for_0_1:Enable()
              end
              c10v6 = true
            else
              c10v10 = 1
              if (c10v7 < c10v10 and c10v6) then
                c10v10 = ipairs
                c10v10, c10v11, c10v12 = c10v10(c10v5)
                for __renovice_for_1_0, __renovice_for_1_1 in c10v10, c10v11, c10v12 do
                  __renovice_for_1_1:Disable()
                end
                c10v6 = false
              end
            end
          end
          if c10v3 then
            do return end
          end
          c10v10 = Sleep
          c10v11 = 0
          c10v10(c10v11)
        end
        do return end
      end
      do return end
    end
    do return end
  end
  SteelMeridianScarfUpdate = v7
  v7 = function()
    local c11v0, c11v1, c11v2, c11v3, c11v4, c11v5, c11v6, c11v7, c11v8, c11v9, c11v10, c11v11
    c11v0 = gPlayerProfileMgr
    c11v2 = 0
    c11v0 = c11v0:GetPlayerProfile(c11v2)
    c11v1 = IsNull
    c11v1 = c11v1(c11v0)
    if not c11v1 then
      c11v1 = c11v0:GetGameSpecificData()
      c11v2 = IsNull
      c11v2 = c11v2(c11v1)
      if not c11v2 then
        c11v2 = c11v1:GetRegularCredits()
        c11v3 = c11v1:GetPremiumCredits()
        c11v4 = Lerp
        c11v5 = 0
        c11v6 = 128
        c11v7 = Clamp
        c11v8 = c11v2 / 1000000
        c11v9 = 0
        c11v10 = 1
        c11v4 = c11v4(c11v5, c11v6, c11v7(c11v8, c11v9, c11v10))
        c11v5 = Lerp
        c11v6 = 0
        c11v7 = 128
        c11v8 = Clamp
        c11v9 = c11v3 / 100
        c11v10 = 0
        c11v11 = 1
        c11v5 = c11v5(c11v6, c11v7, c11v8(c11v9, c11v10, c11v11))
        c11v4 = c11v4 + c11v5
        c11v5 = Clamp
        c11v6 = math.floor
        c11v6 = c11v6(c11v4)
        c11v7 = 0
        c11v8 = 255
        c11v5 = c11v5(c11v6, c11v7, c11v8)
        do return c11v5 end
      end
    end
    c11v1 = 50
    do return c11v1 end
  end
  PerrinSequenceHubEval = v7
  v7 = function(c12v0)
    local c12v1, c12v2, c12v3, c12v4, c12v5, c12v6, c12v7, c12v8, c12v9, c12v10, c12v11, c12v12, c12v13, c12v14, c12v15, c12v16
    c12v1 = v6
    c12v1(c12v0)
    c12v1 = Sleep
    c12v2 = 0
    c12v1(c12v2)
    c12v2 = gGameRules
    c12v3 = IsNull
    c12v3 = c12v3(c12v2)
    if c12v3 then
      c12v1 = false
    else
      c12v5 = gLotusHubGameRulesType
      c12v1 = c12v2:IsA(c12v5)
      if not c12v1 then
        c12v5 = gLotusAttractModeGameRulesType
        c12v1 = c12v2:IsA(c12v5)
      end
    end
    c12v2 = c12v0:GetRootOwner()
    c12v3 = IsNull
    c12v3 = c12v3(c12v2)
    if not c12v3 then
      c12v5 = gBaseAvatarType
      c12v3 = c12v2:IsA(c12v5)
      if not c12v3 then
        do return end
      end
      c12v4 = c12v2:GetPlayer()
      c12v5 = IsNull
      c12v5 = c12v5(c12v4)
      if c12v5 then
        c12v3 = c12v2:GetInstance()
      else
        c12v3 = c12v4:GetPlayerName()
      end
      c12v4 = Symbol
      c12v5 = "Scalar2"
      c12v4 = c12v4(c12v5)
      c12v5 = Symbol
      c12v6 = "ClipThreshold"
      c12v5 = c12v5(c12v6)
      c12v8 = Symbol
      c12v9 = "LowColor"
      c12v8 = c12v8(c12v9)
      c12v9 = 0
      c12v10 = 0
      c12v11 = 0
      c12v12 = 1
      c12v0:SetMaterialParam(c12v8, c12v9, c12v10, c12v11, c12v12)
      while true do
        c12v6 = IsNull
        c12v6 = c12v6(c12v0)
        if c12v6 then break end
        c12v8 = _T.maximumSyndicateScarfIntensity
        if c12v8 then
          c12v7 = 1
        else
          c12v7 = v2
        end
        c12v6 = c12v7 * 1
        c12v7 = _T.PerrinEffects
        if c12v7 ~= nil then
          c12v8 = _T.PerrinEffects
          c12v7 = c12v8[c12v3]
          if c12v7 ~= nil then
            c12v7 = Clamp
            c12v8 = Sqrt
            c12v10 = _T.PerrinEffects
            c12v9 = c12v10[c12v3]
            c12v9 = c12v9.Flash
            c12v8 = c12v8(c12v9)
            c12v9 = 0
            c12v10 = 2
            c12v7 = c12v7(c12v8, c12v9, c12v10)
            c12v8 = c12v7 * 2
            c12v6 = c12v6 + c12v8
            c12v9 = _T.PerrinEffects
            c12v8 = c12v9[c12v3]
            c12v9 = Lerp
            c12v11 = _T.PerrinEffects
            c12v10 = c12v11[c12v3]
            c12v10 = c12v10.Flash
            c12v11 = 0
            c12v12 = DeltaTime
            c12v9 = c12v9(c12v10, c12v11, c12v12())
            c12v8.Flash = c12v9
          end
        end
        c12v9 = Lotus_Game.UNLIT_ATTEN
        c12v11 = 2
        c12v10 = math.min
        c12v10 = c12v10(c12v11, c12v6)
        c12v0:SetMaterialParam(c12v9, c12v10)
        c12v10 = Lerp
        c12v11 = 0.6
        c12v12 = 0
        c12v13 = Clamp
        c12v14 = c12v6 * 0.5
        c12v15 = 0
        c12v16 = 2
        c12v0:SetMaterialParam(c12v5, c12v10(c12v11, c12v12, c12v13(c12v14, c12v15, c12v16)))
        c12v11 = 2
        c12v12 = c12v6 * 2.5
        c12v10 = math.max
        c12v10 = c12v10(c12v11, c12v12)
        c12v0:SetMaterialParam(c12v4, c12v10)
        if c12v1 then
          do return end
        end
        c12v7 = Sleep
        c12v8 = 0
        c12v7(c12v8)
      end
      do return end
    end
    do return end
  end
  PerrinSequenceScarfUpdate = v7
  v7 = function()
    local c13v0
    c13v0 = 50
    do return c13v0 end
  end
  NewLokaHubEval = v7
  v7 = function(c14v0)
    local c14v1, c14v2, c14v3, c14v4, c14v5, c14v6, c14v7, c14v8, c14v9, c14v10, c14v11, c14v12, c14v13, c14v14, c14v15, c14v16, c14v17
    local __renovice_state_0 = 0
    c14v1 = v6
    c14v1(c14v0)
    c14v1 = 0.1
    c14v2 = Sleep
    c14v3 = 0
    c14v2(c14v3)
    c14v3 = gGameRules
    c14v4 = IsNull
    c14v4 = c14v4(c14v3)
    if not c14v4 then
      __renovice_state_0 = 2
    else
      __renovice_state_0 = 1
    end
    if __renovice_state_0 == 1 then
      c14v2 = false
      __renovice_state_0 = 4
    end
    if __renovice_state_0 == 2 then
      c14v6 = gLotusHubGameRulesType
      c14v2 = c14v3:IsA(c14v6)
      if c14v2 then
        __renovice_state_0 = 4
      else
        __renovice_state_0 = 3
      end
    end
    if __renovice_state_0 == 3 then
      c14v6 = gLotusAttractModeGameRulesType
      c14v2 = c14v3:IsA(c14v6)
      __renovice_state_0 = 4
    end
    if __renovice_state_0 == 4 then
      c14v3 = c14v0:GetRootOwner()
      c14v4 = IsNull
      c14v4 = c14v4(c14v3)
      if c14v4 then
        __renovice_state_0 = 6
      else
        __renovice_state_0 = 5
      end
    end
    if __renovice_state_0 == 5 then
      c14v6 = gBaseAvatarType
      c14v4 = c14v3:IsA(c14v6)
      if c14v4 then
        __renovice_state_0 = 7
      else
        __renovice_state_0 = 6
      end
    end
    if __renovice_state_0 == 6 then
      do return end
    end
    if __renovice_state_0 == 7 then
      c14v5 = c14v3:GetPlayer()
      c14v6 = IsNull
      c14v6 = c14v6(c14v5)
      if not c14v6 then
        __renovice_state_0 = 9
      else
        __renovice_state_0 = 8
      end
    end
    if __renovice_state_0 == 8 then
      c14v4 = c14v3:GetInstance()
      __renovice_state_0 = 10
    end
    if __renovice_state_0 == 9 then
      c14v4 = c14v5:GetPlayerName()
      __renovice_state_0 = 10
    end
    if __renovice_state_0 == 10 then
      c14v7 = gLensFlareType
      c14v5 = c14v0:GetAttachment(c14v7)
      c14v8 = attachedDecoType
      c14v6 = c14v0:GetAttachment(c14v8)
    end
    while true do
      local __renovice_state_1 = 11
      c14v7 = IsNull
      c14v7 = c14v7(c14v0)
      if c14v7 then
        __renovice_state_1 = 41
      else
        __renovice_state_1 = 12
      end
      if __renovice_state_1 == 12 then
        if not c14v2 then
          __renovice_state_1 = 19
        else
          __renovice_state_1 = 13
        end
      end
      if __renovice_state_1 == 13 then
        c14v9 = _T.maximumSyndicateScarfIntensity
        if not c14v9 then
          __renovice_state_1 = 15
        else
          __renovice_state_1 = 14
        end
      end
      if __renovice_state_1 == 14 then
        c14v8 = 1
        __renovice_state_1 = 16
      end
      if __renovice_state_1 == 15 then
        c14v8 = v2
        __renovice_state_1 = 16
      end
      if __renovice_state_1 == 16 then
        c14v7 = c14v8 / 255
        c14v1 = c14v7 * 2
        c14v9 = Lotus_Game.UNLIT_ATTEN
        c14v0:SetMaterialParam(c14v9, c14v1)
        c14v7 = IsNull
        c14v7 = c14v7(c14v5)
        if c14v7 then
          __renovice_state_1 = 18
        else
          __renovice_state_1 = 17
        end
      end
      if __renovice_state_1 == 17 then
        c14v10 = 1
        c14v9 = math.min
        c14v9 = c14v9(c14v10, c14v1)
        c14v5:SetOpacity(c14v9)
        __renovice_state_1 = 18
      end
      if __renovice_state_1 == 18 then
        do return end
      end
      if __renovice_state_1 == 19 then
        c14v7 = _T.NewLokaEffects
        if c14v7 ~= nil then
          __renovice_state_1 = 21
        else
          __renovice_state_1 = 20
        end
      end
      if __renovice_state_1 == 20 then
        c14v7 = _T
        c14v8 = {}
        c14v7.NewLokaEffects = c14v8
        __renovice_state_1 = 21
      end
      if __renovice_state_1 == 21 then
        c14v8 = _T.NewLokaEffects
        c14v7 = c14v8[c14v4]
        if c14v7 ~= nil then
          __renovice_state_1 = 23
        else
          __renovice_state_1 = 22
        end
      end
      if __renovice_state_1 == 22 then
        c14v7 = _T.NewLokaEffects
        c14v8 = { Flash = 0, Total = 0, Parts = nil }
        c14v9 = {}
        c14v8.Parts = c14v9
        c14v7[c14v4] = c14v8
        __renovice_state_1 = 23
      end
      if __renovice_state_1 == 23 then
        c14v7 = _T.NewLokaEffects
        if c14v7 == nil then
          __renovice_state_1 = 39
        else
          __renovice_state_1 = 24
        end
      end
      if __renovice_state_1 == 24 then
        c14v8 = _T.NewLokaEffects
        c14v7 = c14v8[c14v4]
        if c14v7 == nil then
          __renovice_state_1 = 39
        else
          __renovice_state_1 = 25
        end
      end
      if __renovice_state_1 == 25 then
        c14v9 = 1
        c14v7 = 4
        c14v8 = 1
        for __renovice_for_0_0 = c14v9, c14v7, c14v8 do
          c14v12 = _T.NewLokaEffects
          c14v11 = c14v12[c14v4]
          c14v11 = c14v11.Parts
          c14v10 = c14v11[__renovice_for_0_0]
          if c14v10 == nil then
            c14v10 = { Total = 0, Flash = 0 }
          end
          c14v11 = Clamp
          c14v13 = c14v10.Total
          c14v12 = c14v13 / 10
          c14v13 = 0
          c14v14 = 1
          c14v11 = c14v11(c14v12, c14v13, c14v14)
          c14v12 = Clamp
          c14v13 = c14v10.Flash
          c14v14 = 0
          c14v15 = 1
          c14v12 = c14v12(c14v13, c14v14, c14v15)
          c14v14 = 0.1
          c14v16 = c14v12 * 2
          c14v17 = c14v11 * 2
          c14v15 = c14v16 + c14v17
          c14v13 = math.max
          c14v1 = c14v13(c14v14, c14v15)
          c14v14 = 0
          c14v16 = c14v10.Flash
          c14v17 = DeltaTime
          c14v17 = c14v17()
          c14v15 = c14v16 - c14v17
          c14v13 = math.max
          c14v13 = c14v13(c14v14, c14v15)
          c14v10.Flash = c14v13
          if __renovice_for_0_0 == 1 then
            c14v15 = Lotus_Game.EMISSIVE_MAP_ATTEN
            c14v0:SetMaterialParam(c14v15, c14v1)
            continue
          end
          if __renovice_for_0_0 == 2 then
            c14v15 = Lotus_Game.UNLIT_ATTEN
            c14v16 = c14v1 * 0.5
            c14v0:SetMaterialParam(c14v15, c14v16)
            continue
          end
          if __renovice_for_0_0 == 3 then
            c14v13 = IsNull
            c14v13 = c14v13(c14v6)
            if not c14v13 then
              c14v15 = Lotus_Game.UNLIT_ATTEN
              c14v6:SetMaterialParam(c14v15, c14v1)
            end
            continue
          end
          c14v13 = IsNull
          c14v13 = c14v13(c14v5)
          if c14v13 then
            continue
          end
          c14v16 = 1
          c14v15 = math.min
          c14v15 = c14v15(c14v16, c14v1)
          c14v5:SetOpacity(c14v15)
        end
      end
      if __renovice_state_1 == 39 then
        c14v9 = Lotus_Game.UNLIT_ATTEN
        c14v10 = c14v1 * 0.5
        c14v0:SetMaterialParam(c14v9, c14v10)
      end
      if __renovice_state_1 == 41 then
        do return end
      end
      c14v7 = Sleep
      c14v8 = 0
      c14v7(c14v8)
    end
    do return end
  end
  NewLokaScarfUpdate = v7
  v7 = function()
    local c15v0
    c15v0 = 50
    do return c15v0 end
  end
  ArbitersOfHexisHubEval = v7
  v7 = function(c16v0)
    local c16v1, c16v2, c16v3, c16v4, c16v5, c16v6, c16v7, c16v8, c16v9, c16v10, c16v11, c16v12, c16v13, c16v14, c16v15, c16v16, c16v17
    c16v1 = v6
    c16v1(c16v0)
    c16v1 = Sleep
    c16v2 = 0
    c16v1(c16v2)
    c16v2 = gGameRules
    c16v3 = IsNull
    c16v3 = c16v3(c16v2)
    if c16v3 then
      c16v1 = false
    else
      c16v5 = gLotusHubGameRulesType
      c16v1 = c16v2:IsA(c16v5)
      if not c16v1 then
        c16v5 = gLotusAttractModeGameRulesType
        c16v1 = c16v2:IsA(c16v5)
      end
    end
    c16v4 = attachedDecoType
    c16v2 = c16v0:GetAttachment(c16v4)
    c16v5 = extraAttachedDecoType
    c16v3 = c16v0:GetAttachment(c16v5)
    c16v4 = Symbol
    c16v5 = "BlueClipThreshold"
    c16v4 = c16v4(c16v5)
    c16v5 = c16v0:GetRootOwner()
    c16v6 = IsNull
    c16v6 = c16v6(c16v5)
    if not c16v6 then
      c16v8 = gBaseAvatarType
      c16v6 = c16v5:IsA(c16v8)
      if not c16v6 then
        do return end
      end
      c16v7 = c16v5:GetPlayer()
      c16v8 = IsNull
      c16v8 = c16v8(c16v7)
      if c16v8 then
        c16v6 = c16v5:GetInstance()
      else
        c16v6 = c16v7:GetPlayerName()
      end
      while true do
        c16v7 = IsNull
        c16v7 = c16v7(c16v0)
        if c16v7 then break end
        c16v9 = _T.maximumSyndicateScarfIntensity
        if c16v9 then
          c16v8 = 1
        else
          c16v8 = v2
        end
        c16v7 = c16v8 * 2
        c16v8 = 1
        c16v9 = _T.HexisEffects
        if c16v9 ~= nil then
          c16v10 = _T.HexisEffects
          c16v9 = c16v10[c16v6]
          if c16v9 ~= nil then
            c16v9 = Clamp
            c16v11 = _T.HexisEffects
            c16v10 = c16v11[c16v6]
            c16v10 = c16v10.Flash
            c16v11 = 0
            c16v12 = 1
            c16v9 = c16v9(c16v10, c16v11, c16v12)
            c16v10 = c16v9 * 6
            c16v7 = c16v7 + c16v10
            c16v10 = Clamp
            c16v13 = _T.HexisEffects
            c16v12 = c16v13[c16v6]
            c16v12 = c16v12.BloodTotal
            c16v11 = c16v12 / 50
            c16v12 = 0
            c16v13 = 1
            c16v10 = c16v10(c16v11, c16v12, c16v13)
            c16v11 = Clamp
            c16v13 = _T.HexisEffects
            c16v12 = c16v13[c16v6]
            c16v12 = c16v12.BloodFlash
            c16v13 = 0
            c16v14 = 1
            c16v11 = c16v11(c16v12, c16v13, c16v14)
            c16v12 = Clamp
            c16v14 = c16v11 * 0.2
            c16v15 = c16v10 * 1
            c16v13 = c16v14 + c16v15
            c16v14 = 0
            c16v15 = 1
            c16v12 = c16v12(c16v13, c16v14, c16v15)
            c16v8 = c16v8 - c16v12
            c16v13 = _T.HexisEffects
            c16v12 = c16v13[c16v6]
            c16v14 = 0
            c16v17 = _T.HexisEffects
            c16v16 = c16v17[c16v6]
            c16v16 = c16v16.Flash
            c16v17 = DeltaTime
            c16v17 = c16v17()
            c16v15 = c16v16 - c16v17
            c16v13 = math.max
            c16v13 = c16v13(c16v14, c16v15)
            c16v12.Flash = c16v13
            c16v13 = _T.HexisEffects
            c16v12 = c16v13[c16v6]
            c16v14 = 0
            c16v17 = _T.HexisEffects
            c16v16 = c16v17[c16v6]
            c16v16 = c16v16.Flash
            c16v17 = DeltaTime
            c16v17 = c16v17()
            c16v15 = c16v16 - c16v17
            c16v13 = math.max
            c16v13 = c16v13(c16v14, c16v15)
            c16v12.BloodFlash = c16v13
          end
        end
        c16v9 = IsNull
        c16v9 = c16v9(c16v2)
        if not c16v9 then
          c16v11 = Lotus_Game.UNLIT_ATTEN
          c16v2:SetMaterialParam(c16v11, c16v7)
        end
        c16v9 = IsNull
        c16v9 = c16v9(c16v3)
        if not c16v9 then
          c16v3:SetMaterialParam(c16v4, c16v8)
        end
        if c16v1 then
          do return end
        end
        c16v9 = Sleep
        c16v10 = 0
        c16v9(c16v10)
      end
      do return end
    end
    do return end
  end
  ArbitersOfHexisScarfUpdate = v7
  do return end
