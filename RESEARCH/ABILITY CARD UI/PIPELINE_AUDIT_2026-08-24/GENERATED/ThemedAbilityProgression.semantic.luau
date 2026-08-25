-- RENOVICE_HASH_FIELD: ConvertColorNumberToHex
-- RENOVICE_HASH_FIELD: Create
-- RENOVICE_HASH_FIELD: CreateAvatarDiorama
-- RENOVICE_HASH_FIELD: CreateList
-- RENOVICE_HASH_FIELD: CreateSideButton
-- RENOVICE_HASH_FIELD: DrawSeparator
-- RENOVICE_HASH_FIELD: FadeBackground
-- RENOVICE_HASH_FIELD: FormatNumber
-- RENOVICE_HASH_FIELD: GetAugmentsForAbility
-- RENOVICE_HASH_FIELD: GetColor
-- RENOVICE_HASH_FIELD: GetOperatorAbilities
-- RENOVICE_HASH_FIELD: GetOrionAvatar
-- RENOVICE_HASH_FIELD: GetPassiveDescription
-- RENOVICE_HASH_FIELD: GetScreenDimensions
-- RENOVICE_HASH_FIELD: GetSiriusAvatar
-- RENOVICE_HASH_FIELD: GetSuitTips
-- RENOVICE_HASH_FIELD: GetUIMode
-- RENOVICE_HASH_FIELD: IsPvpEnabled
-- RENOVICE_HASH_FIELD: PlaySound
-- RENOVICE_HASH_FIELD: Round
-- RENOVICE_HASH_FIELD: SetItemInfoPopupRect
-- RENOVICE_HASH_FIELD: ShowAugmentsForAbility
-- RENOVICE_HASH_FIELD: Ternary
-- RENOVICE_HASH_FIELD: TransformPixelToViewportCoordinates
-- RENOVICE_HASH_FIELD: UsingBrightBackground
local v44_0
local v44_1
local v44_2
local v44_3
local v44_4
local v44_5
local v44_6
local v44_7
local v44_8
local v44_9
local v44_10
local v44_11
local v44_12
local v44_13
local v44_14
local v44_15
local v44_16
local v44_17
local v44_18
local v44_19
local v44_20
local v44_21
local v44_22
local v44_23
local v44_24
local v44_25
local v44_26
local v44_27
local v44_28
local v44_29
local v44_30
local v44_31
local v44_32
local v44_33
local v44_34
local v44_35
local v44_36
local v44_37
local v44_38
local v44_39
local v44_40
local v44_41
local v44_42
local v44_43
local v44_44
local v44_45
local v44_46
local v44_47
local v44_48
local v44_49
local v44_50
local v44_51
local v44_52
local v44_53
local v44_54
local v44_55
local v44_56
local v44_57
local v44_58
local v44_59
local v44_60
local v44_61
local v44_62
local v44_63
local v44_64
local v44_65
local v44_66
local v44_67
local v44_68
local v44_69
local v44_70
local v44_71
local v44_72
local v44_73
local v44_74
local v44_75
local v44_76
local v44_77
local v44_78
local v44_79
local v44_80
local v44_81
local v44_82
local v44_83
local v44_84
local v44_85
local v44_86
local v44_87
local v44_88
local v44_89
local v44_90
local v44_91
local v44_92
local v44_93
local v44_94
local v44_95
local v44_96
local v44_97
local v44_98
local v44_99
local v44_100
local v44_101
local v44_102
local v44_103
local v44_104
local v44_105
local v44_106
local v44_107
local v44_108
v44_0 = require
v44_2 = v44_0("Lotus.Powersuits.PowersuitAbilities.PVPLib")
v44_3 = require
v44_5 = v44_3("EE.Interface.Utilities")
v44_6 = require
v44_8 = v44_6("Lotus.Interface.UIStyleUtilities")
v44_9 = require
v44_11 = v44_9("Lotus.Interface.UIUtilities")
v44_12 = require
v44_14 = v44_12("EE.Interface.AnchorMgr")
v44_15 = require
v44_17 = v44_15("Lotus.Interface.LoadoutUtilities")
v44_18 = require
v44_20 = v44_18("Lotus.Interface.CardUtilitiesRedux")
v44_21 = require
v44_23 = v44_21("Lotus.Interface.Components.AbilityList")
v44_24 = require
v44_26 = v44_24("Lotus.Interface.LotusUtilities")
v44_27 = require
v44_29 = v44_27("Lotus.Interface.FocusUtilities")
v44_30 = require
v44_32 = v44_30("Lotus.Scripts.Libs.SiriusOrionUtilsLib")
v44_33 = require
v44_35 = v44_33("Lotus.Interface.Components.AvatarDiorama")
v44_36 = { SIRIUS = nil, ORION = nil }
v44_37 = WeakResource
v44_39 = v44_37("/Lotus/Powersuits/SiriusOrion/SiriusBaseSuit")
v44_36.SIRIUS = v44_39
v44_40 = WeakResource
v44_42 = v44_40("/Lotus/Powersuits/SiriusOrion/OrionBaseSuit")
v44_36.ORION = v44_42
v44_43 = {}
v44_44 = nil
v44_45 = nil
v44_46 = false
v44_47 = false
v44_48 = true
v44_49 = nil
v44_50 = nil
v44_51 = nil
v44_52 = {}
v44_53 = nil
v44_54 = false
v44_55 = true
v44_56 = nil
v44_57 = nil
v44_58 = nil
v44_59 = nil
v44_60 = nil
v44_61 = false
v44_62 = { InitX = 0 }
v44_63 = nil
v44_64 = true
v44_65 = true
v44_66 = Symbol
v44_68 = v44_66("TempleMetronomeSweetSpotMxGp")
v44_69 = Symbol
v44_71 = v44_69("OraxiaSpiderMxGp")
local cap_44_75_2 = v44_36
local cap_44_75_3 = v44_5
local cap_44_75_4 = v44_32
v44_72 = function()
    local frame_0 = {}
    local cfg_0 = 0
    while true do
        if cfg_0 == 0 then
            frame_0[0] = gRegion
            frame_0[1] = IsNull
            frame_0[2] = frame_0[1](frame_0[0])
            if frame_0[2] then
                cfg_0 = 29
            else
                cfg_0 = 1
            end
        elseif cfg_0 == 1 then
            frame_0[3] = _T.ArsenalOpen
            if frame_0[3] then
                cfg_0 = 4
            else
                cfg_0 = 2
            end
        elseif cfg_0 == 2 then
            frame_0[3] = _T.ArsenalUpgradeOpen
            if frame_0[3] then
                cfg_0 = 4
            else
                cfg_0 = 3
            end
        elseif cfg_0 == 3 then
            frame_0[3] = _T.ModScreenOpen
            cfg_0 = 4
        elseif cfg_0 == 4 then
            if not (frame_0[3]) then
                cfg_0 = 15
            else
                cfg_0 = 5
            end
        elseif cfg_0 == 5 then
            frame_0[4] = _T.mMechaSuitMode
            if not (frame_0[4]) then
                cfg_0 = 8
            else
                cfg_0 = 6
            end
        elseif cfg_0 == 6 then
            frame_0[5] = _T.MechAvatar
            frame_0[6] = IsNull
            frame_0[7] = frame_0[6](frame_0[5])
            if frame_0[7] then
                cfg_0 = 8
            else
                cfg_0 = 7
            end
        elseif cfg_0 == 7 then
            frame_0[8] = _T.MechAvatar
            v44_45 = frame_0[8]
            cfg_0 = 28
        elseif cfg_0 == 8 then
            frame_0[9] = _T.mSpecialSuitMode
            if not (frame_0[9]) then
                cfg_0 = 10
            else
                cfg_0 = 9
            end
        elseif cfg_0 == 9 then
            frame_0[10] = v44_61
            if not (frame_0[10]) then
                cfg_0 = 12
            else
                cfg_0 = 10
            end
        elseif cfg_0 == 10 then
            frame_0[11] = _T.mSpecialSuitMode
            if frame_0[11] then
                cfg_0 = 14
            else
                cfg_0 = 11
            end
        elseif cfg_0 == 11 then
            frame_0[12] = v44_61
            if not (frame_0[12]) then
                cfg_0 = 14
            else
                cfg_0 = 12
            end
        elseif cfg_0 == 12 then
            frame_0[13] = _T.SpecialSuitAvatar
            frame_0[14] = IsNull
            frame_0[15] = frame_0[14](frame_0[13])
            if frame_0[15] then
                cfg_0 = 14
            else
                cfg_0 = 13
            end
        elseif cfg_0 == 13 then
            frame_0[16] = _T.SpecialSuitAvatar
            v44_45 = frame_0[16]
            cfg_0 = 28
        elseif cfg_0 == 14 then
            frame_0[17] = gRegion
            frame_0[18] = Symbol
            frame_0[27] = (frame_0[17]):FindFirstTagged(frame_0[18]("ArsenalAvatar"))
            v44_45 = frame_0[27]
            cfg_0 = 28
        elseif cfg_0 == 15 then
            frame_0[28] = gRegion
            frame_0[31] = (frame_0[28]):GetLocalPlayers()
            frame_0[32] = frame_0[31][1]
            frame_0[33] = frame_0[32]
            frame_0[34] = IsNull
            frame_0[35] = frame_0[34](frame_0[33])
            if frame_0[35] then
                cfg_0 = 28
            else
                cfg_0 = 16
            end
        elseif cfg_0 == 16 then
            frame_0[38] = (frame_0[32]):GetAvatar()
            v44_45 = frame_0[38]
            frame_0[39] = v44_45
            frame_0[40] = IsNull
            frame_0[41] = frame_0[40](frame_0[39])
            if frame_0[41] then
                cfg_0 = 19
            else
                cfg_0 = 17
            end
        elseif cfg_0 == 17 then
            frame_0[42] = v44_45
            frame_0[43] = gTennoAvatarType
            frame_0[46] = (frame_0[42]):IsA(frame_0[43])
            if not (frame_0[46]) then
                cfg_0 = 19
            else
                cfg_0 = 18
            end
        elseif cfg_0 == 18 then
            frame_0[47] = v44_45
            frame_0[48] = gLotusOperatorAvatarType
            frame_0[51] = (frame_0[47]):IsA(frame_0[48])
            if not (frame_0[51]) then
                cfg_0 = 20
            else
                cfg_0 = 19
            end
        elseif cfg_0 == 19 then
            frame_0[54] = (frame_0[32]):GetOwnedPowerSuitAvatar()
            v44_45 = frame_0[54]
            cfg_0 = 20
        elseif cfg_0 == 20 then
            frame_0[55] = v44_45
            frame_0[56] = IsNull
            frame_0[57] = frame_0[56](frame_0[55])
            if not (frame_0[57]) then
                cfg_0 = 22
            else
                cfg_0 = 21
            end
        elseif cfg_0 == 21 then
            frame_0[60] = (frame_0[32]):GetAvatar()
            v44_45 = frame_0[60]
            cfg_0 = 22
        elseif cfg_0 == 22 then
            frame_0[61] = v44_61
            if not (frame_0[61]) then
                cfg_0 = 28
            else
                cfg_0 = 23
            end
        elseif cfg_0 == 23 then
            frame_0[62] = v44_45
            frame_0[63] = IsNull
            frame_0[64] = frame_0[63](frame_0[62])
            if frame_0[64] then
                cfg_0 = 28
            else
                cfg_0 = 24
            end
        elseif cfg_0 == 24 then
            frame_0[65] = v44_45
            frame_0[68] = (frame_0[65]):InventoryControl()
            frame_0[71] = (frame_0[68]):GetActivePowerSuit()
            frame_0[72] = frame_0[71]
            frame_0[73] = IsNull
            frame_0[74] = frame_0[73](frame_0[72])
            if frame_0[74] then
                cfg_0 = 28
            else
                cfg_0 = 25
            end
        elseif cfg_0 == 25 then
            frame_0[75] = cap_44_75_2
            frame_0[76] = (frame_0[75]).SIRIUS
            frame_0[79] = (frame_0[71]):IsA(frame_0[76])
            if frame_0[79] then
                cfg_0 = 27
            else
                cfg_0 = 26
            end
        elseif cfg_0 == 26 then
            frame_0[80] = cap_44_75_2
            frame_0[81] = (frame_0[80]).ORION
            frame_0[84] = (frame_0[71]):IsA(frame_0[81])
            if not (frame_0[84]) then
                cfg_0 = 28
            else
                cfg_0 = 27
            end
        elseif cfg_0 == 27 then
            frame_0[85] = cap_44_75_3
            frame_0[86] = (frame_0[85]).Ternary
            frame_0[87] = cap_44_75_2
            frame_0[88] = (frame_0[87]).SIRIUS
            frame_0[91] = (frame_0[71]):IsA(frame_0[88])
            frame_0[92] = cap_44_75_4
            frame_0[93] = (frame_0[92]).GetOrionAvatar
            frame_0[94] = v44_45
            frame_0[95] = frame_0[93](frame_0[94])
            frame_0[96] = cap_44_75_4
            frame_0[97] = (frame_0[96]).GetSiriusAvatar
            frame_0[98] = v44_45
            frame_0[101] = frame_0[86](frame_0[91], frame_0[95], frame_0[97](frame_0[98]))
            v44_45 = frame_0[101]
            cfg_0 = 28
        elseif cfg_0 == 28 then
            frame_0[102] = _T
            frame_0[103] = v44_45
            frame_0[102].ModPreviewAvatar = frame_0[103]
            cfg_0 = 29
        elseif cfg_0 == 29 then
            return
        else
            error("invalid control state")
        end
    end
end
v44_73 = function(p1_0)
    local v1_1
    local v1_2
    local v1_3
    local v1_4
    local v1_5
    local v1_6
    local v1_7
    local v1_8
    local v1_9
    local v1_10
    local v1_11
    local v1_12
    local v1_13
    local v1_14
    local v1_15
    local v1_16
    local v1_17
    local v1_18
    local v1_19
    local v1_20
    local v1_21
    local v1_22
    local v1_23
    local v1_24
    local v1_25
    local v1_26
    local v1_27
    local v1_28
    local v1_29
    local v1_30
    local v1_31
    local v1_32
    local v1_33
    local v1_34
    local v1_35
    local v1_36
    local v1_37
    local v1_38
    local v1_39
    local v1_40
    local v1_41
    local v1_42
    local v1_43
    local v1_44
    local v1_45
    local v1_46
    local v1_47
    local v1_48
    local v1_49
    v1_1 = p1_0
    v1_2 = IsNull
    v1_3 = v1_2(v1_1)
    if not (v1_3) then
        v1_4 = nil
        v1_7 = p1_0:IsPrime()
        if v1_7 then
            v1_8 = false
            v1_9 = 1
            v1_10 = Name__9c4a63df
            v1_11 = (#v1_10)
            v1_12 = 1
            for v1_9 = v1_9, v1_11, v1_12 do
                v1_13 = Name__9c4a63df
                v1_14 = v1_13[v1_9]
                v1_17 = p1_0:IsA(v1_14)
                if not (not (v1_17)) then
                    v1_8 = true
                    break
                end
            end
            if not (v1_8) then
                v1_18 = Resource
                v1_21 = p1_0:GetType()
                v1_30 = v1_18(v1_21:GetParent())
                v1_33 = v1_30:GetDiorama()
                v1_4 = v1_33
            end
        end
        v1_34 = v1_4
        v1_35 = IsNull
        v1_36 = v1_35(v1_34)
        if v1_36 then
            v1_39 = p1_0:GetDiorama()
            v1_4 = v1_39
        end
        v1_40 = v1_4
        v1_41 = IsNull
        v1_42 = v1_41(v1_40)
        if not (v1_42) then
            v1_43 = v44_63
            v1_47 = v1_4
            v1_43:ShowAvatarDiorama(nil, nil, nil, v1_47)
        end
        return
    else
        return
    end
end
local cap_44_83_0 = v44_5
local cap_44_83_2 = v44_11
v44_74 = function(p3_0, p3_1)
    local v3_2
    local v3_3
    local v3_4
    local v3_5
    local v3_6
    local v3_7
    local v3_8
    local v3_9
    local v3_10
    local v3_11
    local v3_12
    local v3_13
    local v3_14
    local v3_15
    local v3_16
    local v3_17
    local v3_18
    local v3_19
    local v3_20
    local v3_21
    local v3_22
    local v3_23
    local v3_24
    local v3_25
    local v3_26
    local v3_27
    local v3_28
    local v3_29
    local v3_30
    local v3_31
    local v3_32
    local v3_33
    local v3_34
    local v3_35
    local v3_36
    local v3_37
    local v3_38
    local v3_39
    local v3_40
    local v3_41
    local v3_42
    local v3_43
    local v3_44
    local v3_45
    local v3_46
    local v3_47
    local v3_48
    local v3_49
    local v3_50
    local v3_51
    local v3_52
    local v3_53
    local v3_54
    local v3_55
    local v3_56
    local v3_57
    local v3_58
    local v3_59
    local v3_60
    local v3_61
    local v3_62
    local v3_63
    local v3_64
    local v3_65
    local v3_66
    local v3_67
    local v3_68
    local v3_69
    local v3_70
    local v3_71
    local v3_72
    local v3_73
    local v3_74
    local v3_75
    local v3_76
    local v3_77
    local v3_78
    local v3_79
    local v3_80
    local v3_81
    local v3_82
    local v3_83
    local v3_84
    local v3_85
    local v3_86
    local v3_87
    local v3_88
    local v3_89
    local v3_90
    local v3_91
    local v3_92
    local v3_93
    local v3_94
    local v3_95
    local v3_96
    local v3_97
    local v3_98
    local v3_99
    local v3_100
    local v3_101
    local v3_102
    local v3_103
    local v3_104
    local v3_105
    local v3_106
    local v3_107
    local v3_108
    local v3_109
    local v3_110
    local v3_111
    local v3_112
    local v3_113
    local v3_114
    local v3_115
    local v3_116
    local v3_117
    local v3_118
    local v3_119
    local v3_120
    local v3_121
    local v3_122
    local v3_123
    local v3_124
    local v3_125
    local v3_126
    local v3_127
    local v3_128
    local v3_129
    local v3_130
    local v3_131
    v3_2 = cap_44_83_0
    v3_3 = (v3_2).GetScreenDimensions
    v3_4 = mMovie
    v3_5 = v3_3(v3_4)
    v3_6 = v44_50
    v3_7 = IsNull
    v3_8 = v3_7(v3_6)
    if not (v3_8) then
        v3_9 = v44_50
        v3_10 = p3_0
        v3_11 = p3_1
        v3_9:Update(v3_10, v3_11)
    end
    v3_14 = mMovie
    v3_17 = (-v3_5)
    v3_18 = (v3_17 / 2)
    v3_14:SetNumberVariable("Abilities.Underline", 0, v3_18)
    v3_21 = cap_44_83_2
    v3_22 = (v3_21).DrawSeparator
    v3_23 = mMovie
    v3_25 = v3_5
    v3_22(v3_23, "Abilities.Underline", v3_25)
    v3_26 = v44_57
    v3_27 = IsNull
    v3_28 = v3_27(v3_26)
    if not (v3_28) then
        v3_29 = v44_57
        v3_30 = function(p2_0)
            local v2_1
            local v2_2
            local v2_3
            local v2_4
            local v2_5
            local v2_6
            local v2_7
            local v2_8
            local v2_9
            local v2_10
            local v2_11
            local v2_12
            local v2_13
            local v2_14
            local v2_15
            local v2_16
            local v2_17
            local v2_18
            local v2_19
            local v2_20
            local v2_21
            local v2_22
            local v2_23
            local v2_24
            local v2_25
            v2_1 = cap_44_83_0
            v2_2 = (v2_1).TransformPixelToViewportCoordinates
            v2_3 = mMovie
            v2_4 = { x = nil, y = nil }
            v2_5 = mMovie
            v2_6 = (p2_0).mClipName
            v2_8 = (v2_6 .. ".Btn")
            v2_12 = v2_5:GetNumberVariable(v2_8, 2)
            v2_4.x = v2_12
            v2_13 = mMovie
            v2_14 = (p2_0).mClipName
            v2_16 = (v2_14 .. ".Btn")
            v2_20 = v2_13:GetNumberVariable(v2_16, 3)
            v2_4.y = v2_20
            v2_21 = v2_2(v2_3, v2_4)
            v2_22 = (p2_0).Rect
            v2_23 = (v2_21).x
            v2_22.X = v2_23
            v2_24 = (p2_0).Rect
            v2_25 = (v2_21).y
            v2_24.Y = v2_25
            return
        end
        v3_29:RunForAllElements(v3_30)
        v3_33 = v44_57
        v3_33:UpdateVisRanges()
    end
    v3_36 = v44_58
    v3_37 = IsNull
    v3_38 = v3_37(v3_36)
    if not (v3_38) then
        v3_39 = cap_44_83_0
        v3_40 = (v3_39).TransformPixelToViewportCoordinates
        v3_41 = mMovie
        v3_42 = { x = nil, y = nil }
        v3_43 = mMovie
        v3_44 = v44_58
        v3_45 = (v3_44).ClipName
        v3_47 = (v3_45 .. ".Icon")
        v3_51 = v3_43:GetNumberVariable(v3_47, 2)
        v3_42.x = v3_51
        v3_52 = mMovie
        v3_53 = v44_58
        v3_54 = (v3_53).ClipName
        v3_56 = (v3_54 .. ".Icon")
        v3_60 = v3_52:GetNumberVariable(v3_56, 3)
        v3_42.y = v3_60
        v3_61 = v3_40(v3_41, v3_42)
        v3_62 = v44_58
        v3_63 = (v3_62).Rect
        v3_64 = (v3_61).x
        v3_63.X = v3_64
        v3_65 = v44_58
        v3_66 = (v3_65).Rect
        v3_67 = (v3_61).y
        v3_66.Y = v3_67
    end
    v3_68 = v44_59
    v3_69 = IsNull
    v3_70 = v3_69(v3_68)
    if not (v3_70) then
        v3_71 = cap_44_83_0
        v3_72 = (v3_71).TransformPixelToViewportCoordinates
        v3_73 = mMovie
        v3_74 = { x = nil, y = nil }
        v3_75 = mMovie
        v3_76 = v44_59
        v3_77 = (v3_76).ClipName
        v3_79 = (v3_77 .. ".Icon")
        v3_83 = v3_75:GetNumberVariable(v3_79, 2)
        v3_74.x = v3_83
        v3_84 = mMovie
        v3_85 = v44_59
        v3_86 = (v3_85).ClipName
        v3_88 = (v3_86 .. ".Icon")
        v3_92 = v3_84:GetNumberVariable(v3_88, 3)
        v3_74.y = v3_92
        v3_93 = v3_72(v3_73, v3_74)
        v3_94 = v44_59
        v3_95 = (v3_94).Rect
        v3_96 = (v3_93).x
        v3_95.X = v3_96
        v3_97 = v44_59
        v3_98 = (v3_97).Rect
        v3_99 = (v3_93).y
        v3_98.Y = v3_99
    end
    v3_100 = v44_60
    v3_101 = IsNull
    v3_102 = v3_101(v3_100)
    if not (v3_102) then
        v3_103 = cap_44_83_0
        v3_104 = (v3_103).TransformPixelToViewportCoordinates
        v3_105 = mMovie
        v3_106 = { x = nil, y = nil }
        v3_107 = mMovie
        v3_108 = v44_60
        v3_109 = (v3_108).ClipName
        v3_111 = (v3_109 .. ".Icon")
        v3_115 = v3_107:GetNumberVariable(v3_111, 2)
        v3_106.x = v3_115
        v3_116 = mMovie
        v3_117 = v44_60
        v3_118 = (v3_117).ClipName
        v3_120 = (v3_118 .. ".Icon")
        v3_124 = v3_116:GetNumberVariable(v3_120, 3)
        v3_106.y = v3_124
        v3_125 = v3_104(v3_105, v3_106)
        v3_126 = v44_60
        v3_127 = (v3_126).Rect
        v3_128 = (v3_125).x
        v3_127.X = v3_128
        v3_129 = v44_60
        v3_130 = (v3_129).Rect
        v3_131 = (v3_125).y
        v3_130.Y = v3_131
    end
    return
end
local cap_44_91_0 = v44_74
v44_75 = function(p4_0, p4_1)
    local v4_2
    local v4_3
    local v4_4
    v4_2 = cap_44_91_0
    v4_3 = p4_0
    v4_4 = p4_1
    v4_2(v4_3, v4_4)
    return
end
onViewportSizeChanged = v44_75
local cap_44_94_1 = v44_8
local cap_44_94_2 = v44_5
v44_76 = function(p5_0)
    local v5_1
    local v5_2
    local v5_3
    local v5_4
    local v5_5
    local v5_6
    local v5_7
    local v5_8
    local v5_9
    local v5_10
    local v5_11
    local v5_12
    local v5_13
    local v5_14
    local v5_15
    local v5_16
    local v5_17
    local v5_18
    local v5_19
    local v5_20
    local v5_21
    local v5_22
    local v5_23
    local v5_24
    local v5_25
    local v5_26
    local v5_27
    local v5_28
    local v5_29
    local v5_30
    local v5_31
    local v5_32
    local v5_33
    local v5_34
    local v5_35
    local v5_36
    local v5_37
    local v5_38
    local v5_39
    local v5_40
    local v5_41
    local v5_42
    local v5_43
    local v5_44
    local v5_45
    local v5_46
    local v5_47
    local v5_48
    local v5_49
    local v5_50
    local v5_51
    local v5_52
    local v5_53
    local v5_54
    local v5_55
    local v5_56
    local v5_57
    local v5_58
    local v5_59
    local v5_60
    local v5_61
    local v5_62
    local v5_63
    local v5_64
    local v5_65
    local v5_66
    local v5_67
    local v5_68
    local v5_69
    local v5_70
    local v5_71
    local v5_72
    local v5_73
    local v5_74
    local v5_75
    local v5_76
    local v5_77
    local v5_78
    local v5_79
    local v5_80
    local v5_81
    local v5_82
    local v5_83
    local v5_84
    local v5_85
    local v5_86
    local v5_87
    local v5_88
    local v5_89
    local v5_90
    local v5_91
    local v5_92
    local v5_93
    local v5_94
    local v5_95
    local v5_96
    local v5_97
    local v5_98
    local v5_99
    local v5_100
    local v5_101
    local v5_102
    local v5_103
    local v5_104
    local v5_105
    local v5_106
    local v5_107
    local v5_108
    local v5_109
    local v5_110
    local v5_111
    local v5_112
    local v5_113
    local v5_114
    if p5_0 then
        v5_1 = { Content = nil, Background1 = nil, FloatingContent = nil, FloatingContentHighlight = nil }
        v5_2 = cap_44_94_1
        v5_3 = (v5_2).GetColor
        v5_6 = v5_3(6, true)
        v5_1.Content = v5_6
        v5_7 = cap_44_94_1
        v5_8 = (v5_7).GetColor
        v5_11 = v5_8(2, true)
        v5_1.Background1 = v5_11
        v5_12 = cap_44_94_1
        v5_13 = (v5_12).GetColor
        v5_16 = v5_13(9, true)
        v5_1.FloatingContent = v5_16
        v5_17 = cap_44_94_1
        v5_18 = (v5_17).GetColor
        v5_21 = v5_18(10, true)
        v5_1.FloatingContentHighlight = v5_21
        v44_43 = v5_1
        v5_22 = v44_43
        v5_23 = cap_44_94_2
        v5_24 = (v5_23).ConvertColorNumberToHex
        v5_25 = v44_43
        v5_26 = (v5_25).Content
        v5_27 = v5_24(v5_26)
        v5_22.ContentHex = v5_27
        v5_28 = v44_43
        v5_29 = cap_44_94_2
        v5_30 = (v5_29).ConvertColorNumberToHex
        v5_31 = v44_43
        v5_32 = (v5_31).FloatingContentHighlight
        v5_33 = v5_30(v5_32)
        v5_28.FloatingContentHighlightHex = v5_33
    end
    v5_34 = mMovie
    v5_37 = v44_43
    v5_38 = (v5_37).FloatingContent
    v5_34:SetNumberVariable("OperatorAbilities.Arrow", 11, v5_38)
    v5_41 = mMovie
    v5_44 = v44_43
    v5_45 = (v5_44).Background1
    v5_41:SetNumberVariable("OperatorAbilities.Backer", 11, v5_45)
    v5_48 = mMovie
    v5_51 = v44_43
    v5_52 = (v5_51).FloatingContent
    v5_48:SetNumberVariable("OperatorAbilities.Icon", 11, v5_52)
    v5_55 = cap_44_94_1
    v5_56 = (v5_55).UsingBrightBackground
    v5_57 = v5_56()
    v5_58 = v44_43
    v5_59 = (v5_58).FloatingContent
    v5_60 = mMovie
    v5_63 = v5_59
    v5_60:SetNumberVariable("Abilities.Underline", 11, v5_63)
    v5_66 = mMovie
    v5_69 = v44_43
    v5_70 = (v5_69).Background1
    v5_66:SetNumberVariable("Abilities.Backer", 11, v5_70)
    v5_73 = mMovie
    v5_76 = cap_44_94_2
    v5_77 = (v5_76).Ternary
    v5_78 = v5_57
    v5_73:SetNumberVariable("Abilities.Backer", 12, v5_77(v5_78, 70, 100))
    v5_87 = mMovie
    v5_90 = cap_44_94_2
    v5_91 = (v5_90).Ternary
    v5_92 = v5_57
    v5_87:SetNumberVariable("Abilities.Backer", 6, v5_91(v5_92, 180, 280))
    v5_101 = mMovie
    v5_104 = cap_44_94_2
    v5_105 = (v5_104).Ternary
    v5_106 = v5_57
    v5_101:SetNumberVariable("Abilities.Blurer", 6, v5_105(v5_106, 180, 280))
    return
end
local cap_44_98_1 = v44_72
local cap_44_98_5 = v44_36
v44_77 = function()
    local frame_6 = {}
    local cfg_6 = 0
    while true do
        if cfg_6 == 0 then
            frame_6[0] = v44_45
            frame_6[1] = IsNull
            frame_6[2] = frame_6[1](frame_6[0])
            if not (frame_6[2]) then
                cfg_6 = 3
            else
                cfg_6 = 1
            end
        elseif cfg_6 == 1 then
            frame_6[3] = cap_44_98_1
            frame_6[3]()
            frame_6[4] = v44_45
            frame_6[5] = IsNull
            frame_6[6] = frame_6[5](frame_6[4])
            if not (frame_6[6]) then
                cfg_6 = 3
            else
                cfg_6 = 2
            end
        elseif cfg_6 == 2 then
            return false
        elseif cfg_6 == 3 then
            frame_6[8] = gGameData
            frame_6[9] = IsNull
            frame_6[10] = frame_6[9](frame_6[8])
            if not (frame_6[10]) then
                cfg_6 = 5
            else
                cfg_6 = 4
            end
        elseif cfg_6 == 4 then
            return false
        elseif cfg_6 == 5 then
            frame_6[12] = v44_44
            frame_6[13] = IsNull
            frame_6[14] = frame_6[13](frame_6[12])
            if not (frame_6[14]) then
                cfg_6 = 24
            else
                cfg_6 = 6
            end
        elseif cfg_6 == 6 then
            frame_6[15] = gGameData
            frame_6[18] = (frame_6[15]):GetLoadOut()
            frame_6[19] = nil
            frame_6[20] = v44_46
            if not (frame_6[20]) then
                cfg_6 = 8
            else
                cfg_6 = 7
            end
        elseif cfg_6 == 7 then
            frame_6[25] = (frame_6[18]):GetWeaponInfo(2, 0)
            frame_6[26] = frame_6[25]
            frame_6[27] = v44_45
            frame_6[30] = (frame_6[27]):InventoryControl()
            frame_6[33] = (frame_6[30]):Name__d22c79ce()
            v44_44 = frame_6[33]
            cfg_6 = 15
        elseif cfg_6 == 8 then
            frame_6[34] = nil
            frame_6[35] = gRegion
            frame_6[38] = (frame_6[35]):GetLocalPlayerAvatar()
            frame_6[39] = frame_6[38]
            frame_6[40] = IsNull
            frame_6[41] = frame_6[40](frame_6[39])
            if frame_6[41] then
                cfg_6 = 11
            else
                cfg_6 = 9
            end
        elseif cfg_6 == 9 then
            frame_6[42] = Name__e47a507c
            frame_6[45] = (frame_6[38]):IsA(frame_6[42])
            if not (frame_6[45]) then
                cfg_6 = 11
            else
                cfg_6 = 10
            end
        elseif cfg_6 == 10 then
            frame_6[34] = frame_6[38]
            v44_55 = false
            cfg_6 = 11
        elseif cfg_6 == 11 then
            frame_6[47] = frame_6[34]
            frame_6[48] = IsNull
            frame_6[49] = frame_6[48](frame_6[47])
            if frame_6[49] then
                cfg_6 = 13
            else
                cfg_6 = 12
            end
        elseif cfg_6 == 12 then
            frame_6[52] = (frame_6[34]):InventoryControl()
            frame_6[55] = (frame_6[52]):GetActivePowerSuit()
            v44_44 = frame_6[55]
            cfg_6 = 14
        elseif cfg_6 == 13 then
            frame_6[56] = v44_45
            frame_6[59] = (frame_6[56]):InventoryControl()
            frame_6[62] = (frame_6[59]):GetActivePowerSuit()
            v44_44 = frame_6[62]
            cfg_6 = 14
        elseif cfg_6 == 14 then
            frame_6[67] = (frame_6[18]):GetWeaponInfo(0, 0)
            frame_6[26] = frame_6[67]
            cfg_6 = 15
        elseif cfg_6 == 15 then
            frame_6[68] = frame_6[26]
            frame_6[69] = IsNull
            frame_6[70] = frame_6[69](frame_6[68])
            if frame_6[70] then
                cfg_6 = 17
            else
                cfg_6 = 16
            end
        elseif cfg_6 == 16 then
            frame_6[71] = v44_44
            frame_6[72] = IsNull
            frame_6[73] = frame_6[72](frame_6[71])
            if not (frame_6[73]) then
                cfg_6 = 18
            else
                cfg_6 = 17
            end
        elseif cfg_6 == 17 then
            v44_44 = nil
            return false
        elseif cfg_6 == 18 then
            frame_6[76] = _T.SetSquadOverlayTitle
            frame_6[77] = IsNull
            frame_6[78] = frame_6[77](frame_6[76])
            if frame_6[78] then
                cfg_6 = 24
            else
                cfg_6 = 19
            end
        elseif cfg_6 == 19 then
            frame_6[79] = mMovie
            frame_6[80] = v44_44
            frame_6[83] = (frame_6[80]):GetLocalizeTag()
            frame_6[86] = (frame_6[83]):c_str()
            frame_6[90] = (frame_6[79]):GetLocalized(frame_6[86], false)
            frame_6[91] = v44_44
            frame_6[92] = cap_44_98_5
            frame_6[93] = (frame_6[92]).SIRIUS
            frame_6[96] = (frame_6[91]):IsA(frame_6[93])
            if not (frame_6[96]) then
                cfg_6 = 21
            else
                cfg_6 = 20
            end
        elseif cfg_6 == 20 then
            frame_6[97] = mMovie
            frame_6[102] = (frame_6[97]):GetLocalized("/Lotus/Language/Suits/SiriusSuitName", false)
            frame_6[90] = frame_6[102]
            cfg_6 = 23
        elseif cfg_6 == 21 then
            frame_6[103] = v44_44
            frame_6[104] = cap_44_98_5
            frame_6[105] = (frame_6[104]).ORION
            frame_6[108] = (frame_6[103]):IsA(frame_6[105])
            if not (frame_6[108]) then
                cfg_6 = 23
            else
                cfg_6 = 22
            end
        elseif cfg_6 == 22 then
            frame_6[109] = mMovie
            frame_6[114] = (frame_6[109]):GetLocalized("/Lotus/Language/Suits/OrionSuitName", false)
            frame_6[90] = frame_6[114]
            cfg_6 = 23
        elseif cfg_6 == 23 then
            frame_6[115] = _T.SetSquadOverlayTitle
            frame_6[116] = mMovie
            frame_6[121] = (frame_6[116]):GetLocalized("/Lotus/Language/Menu/MenuAbilities", false)
            frame_6[122] = frame_6[90]
            frame_6[123] = v44_54
            frame_6[115](frame_6[121], frame_6[122], frame_6[123])
            v44_54 = true
            cfg_6 = 24
        elseif cfg_6 == 24 then
            return true
        else
            error("invalid control state")
        end
    end
end
local cap_44_106_1 = v44_17
v44_78 = function()
    local v7_0
    local v7_1
    local v7_2
    local v7_3
    local v7_4
    local v7_5
    local v7_6
    local v7_7
    local v7_8
    local v7_9
    local v7_10
    local v7_11
    local v7_12
    local v7_13
    local v7_14
    local v7_15
    local v7_16
    local v7_17
    local v7_18
    local v7_19
    local v7_20
    local v7_21
    local v7_22
    local v7_23
    local v7_24
    local v7_25
    local v7_26
    v7_0 = v44_44
    v7_1 = IsNull
    v7_2 = v7_1(v7_0)
    if not (v7_2) then
        v7_3 = cap_44_106_1
        v7_4 = (v7_3).GetSuitTips
        v7_5 = mMovie
        v7_6 = v44_44
        v7_7 = v7_4(v7_5, v7_6)
        v7_8 = (#v7_7)
        if not (0 < v7_8) then
            v7_21 = mMovie
            v7_21:Name__d9713943("Tips", 13, false)
            return
        else
            v7_10 = cap_44_106_1
            v7_11 = (v7_10).CreateSideButton
            v7_12 = mMovie
            v7_15 = tipsIcon
            v7_17 = { Hints = nil }
            v7_17.Hints = v7_7
            v7_19 = v44_43
            v7_20 = v7_11(v7_12, "Tips", "/Lotus/Language/Menu/Ability_Tips", v7_15, 40, v7_17, 2, v7_19)
            v44_60 = v7_20
            return
        end
    else
        return
    end
end
local cap_44_111_0 = v44_77
local cap_44_111_2 = v44_2
local cap_44_111_6 = v44_23
local cap_44_111_7 = v44_5
local cap_44_111_9 = v44_17
local cap_44_111_13 = v44_36
local cap_44_111_16 = v44_29
local cap_44_111_18 = v44_62
local cap_44_111_19 = v44_73
v44_79 = function(p9_0)
    local frame_9 = {}
    local cfg_9 = 0
    while true do
        if cfg_9 == 0 then
            frame_9[1] = cap_44_111_0
            frame_9[2] = frame_9[1]()
            if frame_9[2] then
                cfg_9 = 2
            else
                cfg_9 = 1
            end
        elseif cfg_9 == 1 then
            return
        elseif cfg_9 == 2 then
            frame_9[3] = false
            frame_9[4] = v44_44
            frame_9[5] = IsNull
            frame_9[6] = frame_9[5](frame_9[4])
            if frame_9[6] then
                cfg_9 = 22
            else
                cfg_9 = 3
            end
        elseif cfg_9 == 3 then
            frame_9[7] = gGameData
            frame_9[10] = (frame_9[7]):GetInventory()
            frame_9[13] = (frame_9[10]):GetActiveQuest()
            frame_9[14] = v44_44
            frame_9[15] = WeakResource
            frame_9[34] = (frame_9[14]):IsA(frame_9[15]("/Lotus/Powersuits/Stalker/Stalker"))
            if not (frame_9[34]) then
                cfg_9 = 8
            else
                cfg_9 = 4
            end
        elseif cfg_9 == 4 then
            frame_9[35] = frame_9[13]
            frame_9[36] = IsNull
            frame_9[37] = frame_9[36](frame_9[35])
            frame_9[34] = (not frame_9[37])
            if not (frame_9[34]) then
                cfg_9 = 8
            else
                cfg_9 = 5
            end
        elseif cfg_9 == 5 then
            frame_9[38] = WeakResource
            frame_9[40] = frame_9[38]("/Lotus/Types/Keys/JadeShadows/JadeShadowQuestKeyChain")
            if frame_9[13] == frame_9[40] then
                cfg_9 = 7
            else
                cfg_9 = 6
            end
        elseif cfg_9 == 6 then
            frame_9[34] = false
            cfg_9 = 8
        elseif cfg_9 == 7 then
            frame_9[34] = true
            cfg_9 = 8
        elseif cfg_9 == 8 then
            frame_9[3] = frame_9[34]
            frame_9[41] = cap_44_111_2
            frame_9[42] = (frame_9[41]).IsPvpEnabled
            frame_9[43] = frame_9[42]()
            frame_9[44] = 0
            frame_9[45] = v44_57
            frame_9[46] = v44_44
            frame_9[47] = frame_9[43]
            frame_9[49] = v44_47
            do (frame_9[45]):Populate(frame_9[46], frame_9[47], true, frame_9[49]) end
            frame_9[52] = v44_57
            frame_9[53] = function(p8_0)
                local v8_1
                local v8_2
                local v8_3
                local v8_4
                local v8_5
                local v8_6
                local v8_7
                local v8_8
                local v8_9
                local v8_10
                local v8_11
                local v8_12
                local v8_13
                local v8_14
                v8_1 = {}
                v8_2 = v44_53
                if not (v8_2 == nil) then
                    v8_3 = cap_44_111_6
                    v8_4 = (v8_3).GetAugmentsForAbility
                    v8_5 = v44_53
                    v8_6 = (p8_0).Resource
                    v8_7 = v8_4(v8_5, v8_6)
                    v8_1 = v8_7
                end
                v8_8 = (#v8_1)
                if 0 < v8_8 then
                    v8_10 = true
                else
                    v8_10 = false
                end
                p8_0.CanPreviewOverride = v8_10
                p8_0.PreviewTagOverride = "/Lotus/Language/Alchemy/AbilityAugmentPreview"
                v8_12 = (p8_0).mTextHeight
                v8_13 = frame_9[44]
                if v8_13 < v8_12 then
                    v8_14 = (p8_0).mTextHeight
                    frame_9[44] = v8_14
                end
                return
            end
            do (frame_9[52]):RunForAllElements(frame_9[53]) end
            frame_9[56] = (frame_9[44] + 95)
            frame_9[57] = v44_57
            frame_9[58] = (frame_9[57]).mForcedHorizontalSeparation
            frame_9[59] = v44_57
            frame_9[62] = (frame_9[59]):GetHowManyElements()
            frame_9[63] = (frame_9[58] * frame_9[62])
            frame_9[64] = (frame_9[63] / 2)
            frame_9[65] = (-frame_9[64])
            frame_9[66] = v44_57
            frame_9[67] = (frame_9[66]).mForcedHorizontalSeparation
            frame_9[68] = (frame_9[67] / 2)
            frame_9[69] = (frame_9[65] + frame_9[68])
            frame_9[70] = mMovie
            frame_9[71] = v44_57
            frame_9[72] = (frame_9[71]).mParentClipName
            frame_9[74] = cap_44_111_7
            frame_9[75] = (frame_9[74]).Round
            frame_9[76] = frame_9[69]
            do (frame_9[70]):SetNumberVariable(frame_9[72], 0, frame_9[75](frame_9[76])) end
            frame_9[89] = mMovie
            do (frame_9[89]):Name__d9713943("Abilities", 13, true) end
            frame_9[96] = (900 - frame_9[56])
            frame_9[97] = math.min
            frame_9[98] = frame_9[97](745, frame_9[96])
            if (not (frame_9[98] < 745) or not (p9_0)) then
                cfg_9 = 13
            else
                cfg_9 = 10
            end
        elseif cfg_9 == 10 then
            frame_9[100] = v44_50
            frame_9[103] = frame_9[98]
            do (frame_9[100]):ChangeOriginalCoords("Abilities", nil, frame_9[103]) end
            frame_9[106] = (745 - frame_9[98])
            frame_9[107] = {}
            frame_9[107][1] = "Passive"
            frame_9[107][2] = "Switch"
            frame_9[107][3] = "Tips"
            frame_9[107][4] = "OperatorAbilities"
            frame_9[112] = frame_9[107]
            frame_9[113] = nil
            frame_9[114] = nil
            local leave_for_9_12 = false
            for for_value_9_12_0, for_value_9_12_1 in frame_9[112], frame_9[113], frame_9[114] do
                frame_9[127], frame_9[128] = for_value_9_12_0, for_value_9_12_1
                cfg_9 = 11
                while true do
                    if cfg_9 == 11 then
                        frame_9[115] = v44_50
                        frame_9[116] = frame_9[128]
                        frame_9[119] = (frame_9[115]):GetOriginalCoords(frame_9[116])
                        frame_9[120] = v44_50
                        frame_9[121] = frame_9[128]
                        frame_9[123] = (frame_9[119]).y
                        frame_9[124] = (frame_9[123] - frame_9[106])
                        do (frame_9[120]):ChangeOriginalCoords(frame_9[121], nil, frame_9[124]) end
                        cfg_9 = 12
                    elseif cfg_9 == 12 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_9_12 then break end
            end
            if not leave_for_9_12 then
                cfg_9 = 13
            end
        elseif cfg_9 == 13 then
            if frame_9[43] then
                cfg_9 = 21
            else
                cfg_9 = 14
            end
        elseif cfg_9 == 14 then
            frame_9[129] = cap_44_111_9
            frame_9[130] = (frame_9[129]).GetPassiveDescription
            frame_9[131] = mMovie
            frame_9[132] = v44_45
            frame_9[133] = v44_44
            frame_9[134] = frame_9[130](frame_9[131], frame_9[132], frame_9[133])
            if frame_9[134] == "" then
                cfg_9 = 16
            else
                cfg_9 = 15
            end
        elseif cfg_9 == 15 then
            frame_9[135] = cap_44_111_9
            frame_9[136] = (frame_9[135]).CreateSideButton
            frame_9[137] = mMovie
            frame_9[140] = passiveIcon
            frame_9[142] = { LocalizedDesc = nil, PreviewImage = nil }
            frame_9[142].LocalizedDesc = frame_9[134]
            frame_9[143] = v44_44
            frame_9[146] = (frame_9[143]):Name__33c3c4f7()
            frame_9[142].PreviewImage = frame_9[146]
            frame_9[148] = v44_43
            frame_9[149] = frame_9[136](frame_9[137], "Passive", "/Lotus/Language/Menu/Ability_Passive", frame_9[140], 56, frame_9[142], 1, frame_9[148])
            v44_58 = frame_9[149]
            cfg_9 = 16
        elseif cfg_9 == 16 then
            frame_9[150] = v44_44
            frame_9[151] = cap_44_111_13
            frame_9[152] = (frame_9[151]).SIRIUS
            frame_9[155] = (frame_9[150]):IsA(frame_9[152])
            if frame_9[155] then
                cfg_9 = 18
            else
                cfg_9 = 17
            end
        elseif cfg_9 == 17 then
            frame_9[156] = v44_44
            frame_9[157] = cap_44_111_13
            frame_9[158] = (frame_9[157]).ORION
            frame_9[161] = (frame_9[156]):IsA(frame_9[158])
            if not (frame_9[161]) then
                cfg_9 = 21
            else
                cfg_9 = 18
            end
        elseif cfg_9 == 18 then
            frame_9[162] = v44_44
            frame_9[163] = cap_44_111_13
            frame_9[164] = (frame_9[163]).SIRIUS
            frame_9[167] = (frame_9[162]):IsA(frame_9[164])
            frame_9[169] = cap_44_111_7
            frame_9[170] = (frame_9[169]).Ternary
            frame_9[171] = frame_9[167]
            frame_9[174] = frame_9[170](frame_9[171], "OrionSuitName", "SiriusSuitName")
            frame_9[175] = ("/Lotus/Language/Suits/" .. frame_9[174])
            frame_9[176] = mMovie
            frame_9[179] = { SUITS = nil }
            frame_9[180] = mMovie
            frame_9[181] = frame_9[175]
            frame_9[185] = (frame_9[180]):GetLocalized(frame_9[181], false)
            frame_9[179].SUITS = frame_9[185]
            frame_9[188] = (frame_9[176]):GetLocalized("/Lotus/Language/Suits/Ability_SwapSuit", false, frame_9[179])
            frame_9[189] = cap_44_111_9
            frame_9[190] = (frame_9[189]).CreateSideButton
            frame_9[191] = mMovie
            frame_9[193] = frame_9[175]
            frame_9[194] = switchIcon
            frame_9[196] = { LocalizedDesc = nil }
            frame_9[196].LocalizedDesc = frame_9[188]
            frame_9[198] = v44_43
            frame_9[199] = frame_9[190](frame_9[191], "Switch", frame_9[193], frame_9[194], 48, frame_9[196], 3, frame_9[198])
            v44_59 = frame_9[199]
            frame_9[200] = v44_58
            frame_9[201] = IsNull
            frame_9[202] = frame_9[201](frame_9[200])
            if (frame_9[202] or not (p9_0)) then
                cfg_9 = 21
            else
                cfg_9 = 20
            end
        elseif cfg_9 == 20 then
            frame_9[203] = v44_50
            frame_9[207] = (frame_9[203]):GetOriginalCoords("Passive")
            frame_9[208] = v44_50
            frame_9[211] = (frame_9[207]).y
            frame_9[212] = (frame_9[211] - 75)
            do (frame_9[208]):ChangeOriginalCoords("Passive", nil, frame_9[212]) end
            cfg_9 = 21
        elseif cfg_9 == 21 then
            cfg_9 = 22
        elseif cfg_9 == 22 then
            frame_9[215] = v44_56
            do (frame_9[215]):RemoveElements(true, true) end
            if frame_9[3] then
                cfg_9 = 25
            else
                cfg_9 = 23
            end
        elseif cfg_9 == 23 then
            frame_9[220] = cap_44_111_16
            frame_9[221] = (frame_9[220]).GetOperatorAbilities
            frame_9[222] = mMovie
            frame_9[223] = frame_9[221](frame_9[222])
            frame_9[224] = 1
            frame_9[225] = (#frame_9[223])
            frame_9[226] = 1
            local leave_for_9_24 = false
            for for_value_9_24 = frame_9[224], frame_9[225], frame_9[226] do
                frame_9[224] = for_value_9_24
                cfg_9 = 24
                while true do
                    if cfg_9 == 24 then
                        frame_9[227] = v44_56
                        frame_9[228] = frame_9[223][frame_9[224]]
                        do (frame_9[227]):AddElement(frame_9[228], true) end
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_9_24 then break end
            end
            if not leave_for_9_24 then
                cfg_9 = 25
            end
        elseif cfg_9 == 25 then
            frame_9[232] = v44_56
            do (frame_9[232]):Redraw(nil, true, true) end
            frame_9[238] = v44_56
            frame_9[241] = (frame_9[238]):GetHowManyElements()
            frame_9[242] = mMovie
            frame_9[245] = v44_55
            if not (frame_9[245]) then
                cfg_9 = 29
            else
                cfg_9 = 26
            end
        elseif cfg_9 == 26 then
            if 0 < frame_9[241] then
                cfg_9 = 28
            else
                cfg_9 = 27
            end
        elseif cfg_9 == 27 then
            frame_9[245] = false
            cfg_9 = 29
        elseif cfg_9 == 28 then
            frame_9[245] = true
            cfg_9 = 29
        elseif cfg_9 == 29 then
            do (frame_9[242]):Name__d9713943("OperatorAbilities", 13, frame_9[245]) end
            if not (2 < frame_9[241]) then
                cfg_9 = 31
            else
                cfg_9 = 30
            end
        elseif cfg_9 == 30 then
            frame_9[250] = v44_56
            frame_9[251] = (frame_9[250]).mForcedHorizontalSeparation
            frame_9[252] = v44_50
            frame_9[254] = cap_44_111_18
            frame_9[255] = (frame_9[254]).InitX
            frame_9[256] = (frame_9[255] - frame_9[251])
            do (frame_9[252]):ChangeOriginalCoords("OperatorAbilities", frame_9[256], nil) end
            frame_9[260] = mMovie
            frame_9[263] = cap_44_111_18
            frame_9[264] = (frame_9[263]).InitArrowWidth
            frame_9[265] = (frame_9[264] + frame_9[251])
            frame_9[266] = (frame_9[265] + 1)
            do (frame_9[260]):SetNumberVariable("OperatorAbilities.Arrow.Middle", 14, frame_9[266]) end
            frame_9[269] = mMovie
            frame_9[272] = cap_44_111_18
            frame_9[273] = (frame_9[272]).InitArrowX
            frame_9[274] = (frame_9[273] - frame_9[251])
            do (frame_9[269]):SetNumberVariable("OperatorAbilities.Arrow.Middle", 0, frame_9[274]) end
            frame_9[277] = mMovie
            frame_9[280] = cap_44_111_18
            frame_9[281] = (frame_9[280]).InitArrowFadeX
            frame_9[282] = (frame_9[281] - frame_9[251])
            do (frame_9[277]):SetNumberVariable("OperatorAbilities.Arrow.Fade", 0, frame_9[282]) end
            frame_9[285] = mMovie
            frame_9[288] = cap_44_111_18
            frame_9[289] = (frame_9[288]).InitBackerWidth
            frame_9[290] = (frame_9[289] + frame_9[251])
            frame_9[291] = (frame_9[290] + 1)
            do (frame_9[285]):SetNumberVariable("OperatorAbilities.Backer", 14, frame_9[291]) end
            frame_9[294] = mMovie
            frame_9[297] = cap_44_111_18
            frame_9[298] = (frame_9[297]).InitBackerX
            frame_9[299] = (frame_9[298] + frame_9[251])
            do (frame_9[294]):SetNumberVariable("OperatorAbilities.Backer", 0, frame_9[299]) end
            frame_9[302] = mMovie
            frame_9[305] = cap_44_111_18
            frame_9[306] = (frame_9[305]).InitBlurerWidth
            frame_9[307] = (frame_9[306] + frame_9[251])
            frame_9[308] = (frame_9[307] + 1)
            do (frame_9[302]):SetNumberVariable("OperatorAbilities.Blurer", 14, frame_9[308]) end
            frame_9[311] = mMovie
            frame_9[314] = cap_44_111_18
            frame_9[315] = (frame_9[314]).InitBlurerX
            frame_9[316] = (frame_9[315] + frame_9[251])
            do (frame_9[311]):SetNumberVariable("OperatorAbilities.Blurer", 0, frame_9[316]) end
            cfg_9 = 31
        elseif cfg_9 == 31 then
            if p9_0 then
                cfg_9 = 33
            else
                cfg_9 = 32
            end
        elseif cfg_9 == 32 then
            frame_9[319] = cap_44_111_7
            frame_9[320] = (frame_9[319]).FadeBackground
            frame_9[321] = mMovie
            frame_9[320](frame_9[321], 100, 0)
            frame_9[324] = gFlashMgr
            do (frame_9[324]):DestroyBackgroundRegion() end
            cfg_9 = 33
        elseif cfg_9 == 33 then
            frame_9[327] = cap_44_111_19
            frame_9[328] = v44_44
            frame_9[327](frame_9[328])
            return
        else
            error("invalid control state")
        end
    end
end
v44_80 = function()
    local v10_0
    local v10_1
    local v10_2
    local v10_3
    local v10_4
    local v10_5
    local v10_6
    local v10_7
    local v10_8
    local v10_9
    local v10_10
    local v10_11
    local v10_12
    local v10_13
    local v10_14
    local v10_15
    local v10_16
    local v10_17
    local v10_18
    v10_0 = mMovie
    v10_3 = v10_0:GetParent()
    v10_4 = v10_3
    v10_5 = IsNull
    v10_6 = v10_5(v10_4)
    if not (v10_6) then
        v10_7 = _T.TopMenuOpen
        if v10_7 then
        else
            v10_8 = mMovie
            v10_11 = v10_8:GetParent()
            v10_11:Execute("CloseAbilityProgression", "")
            return
        end
    end
    v10_16 = mMovie
    v10_16:Close()
    return
end
local cap_44_133_2 = v44_5
v44_81 = function()
    local v12_0
    local v12_1
    local v12_2
    local v12_3
    local v12_4
    local v12_5
    local v12_6
    local v12_7
    local v12_8
    local v12_9
    local v12_10
    local v12_11
    local v12_12
    local v12_13
    local v12_14
    local v12_15
    v12_0 = print
    v12_0("ToggleModdedStats()")
    v12_2 = v44_47
    v12_3 = (not v12_2)
    v44_47 = v12_3
    v12_4 = UpdateButtons
    v12_4()
    v12_5 = v44_57
    v12_6 = function(p11_0)
        local v11_1
        local v11_2
        local v11_3
        local v11_4
        local v11_5
        local v11_6
        local v11_7
        local v11_8
        local v11_9
        local v11_10
        local v11_11
        local v11_12
        local v11_13
        local v11_14
        local v11_15
        local v11_16
        local v11_17
        local v11_18
        local v11_19
        local v11_20
        local v11_21
        local v11_22
        local v11_23
        local v11_24
        local v11_25
        local v11_26
        local v11_27
        v11_1 = v44_47
        p11_0.ModdedStats = v11_1
        v11_2 = cap_44_133_2
        v11_3 = (v11_2).FormatNumber
        v11_4 = (p11_0).Resource
        v11_9 = v11_4:GetActivationEnergyCost(true, false)
        v11_14 = v11_3(v11_9, 2, false, nil, true)
        p11_0.Energy = v11_14
        v11_15 = cap_44_133_2
        v11_16 = (v11_15).FormatNumber
        v11_17 = (p11_0).Resource
        v11_22 = v11_17:GetActivationEnergyCost(false, false)
        v11_27 = v11_16(v11_22, 2, false, nil, true)
        p11_0.BaseEnergy = v11_27
        return
    end
    v12_5:RunForAllElements(v12_6)
    v12_9 = v44_49
    v12_10 = v44_47
    v12_9:Name__9458f868(v12_10)
    v12_13 = _T.InfoPopup_Data
    if not (v12_13 == nil) then
        v12_14 = _T.InfoPopup_Data
        v12_14.Refresh = true
    end
    return
end
local cap_44_138_2 = v44_68
v44_82 = function()
    local v13_0
    local v13_1
    local v13_2
    local v13_3
    local v13_4
    local v13_5
    local v13_6
    local v13_7
    local v13_8
    local v13_9
    local v13_10
    local v13_11
    local v13_12
    v13_0 = v44_64
    v13_1 = (not v13_0)
    v44_64 = v13_1
    v13_2 = v44_49
    v13_3 = IsNull
    v13_4 = v13_3(v13_2)
    if not (v13_4) then
        v13_5 = v44_49
        v13_6 = cap_44_138_2
        v13_7 = v44_64
        if not (v13_7) then
            v13_8 = 0
        else
            v13_8 = 1
        end
        v13_5:ShowStormTest(v13_6, v13_8, true)
    end
    v13_12 = UpdateButtons
    v13_12()
    return
end
local cap_44_142_2 = v44_71
v44_83 = function()
    local v14_0
    local v14_1
    local v14_2
    local v14_3
    local v14_4
    local v14_5
    local v14_6
    local v14_7
    local v14_8
    local v14_9
    local v14_10
    local v14_11
    local v14_12
    v14_0 = v44_65
    v14_1 = (not v14_0)
    v44_65 = v14_1
    v14_2 = v44_49
    v14_3 = IsNull
    v14_4 = v14_3(v14_2)
    if not (v14_4) then
        v14_5 = v44_49
        v14_6 = cap_44_142_2
        v14_7 = v44_65
        if not (v14_7) then
            v14_8 = 0
        else
            v14_8 = 1
        end
        v14_5:ShowStormTest(v14_6, v14_8, true)
    end
    v14_12 = UpdateButtons
    v14_12()
    return
end
local cap_44_146_2 = v44_82
local cap_44_146_4 = v44_81
local cap_44_146_5 = v44_80
v44_84 = function()
    local v15_0
    local v15_1
    local v15_2
    local v15_3
    local v15_4
    local v15_5
    local v15_6
    local v15_7
    local v15_8
    local v15_9
    local v15_10
    local v15_11
    local v15_12
    local v15_13
    local v15_14
    local v15_15
    local v15_16
    local v15_17
    local v15_18
    local v15_19
    local v15_20
    local v15_21
    local v15_22
    local v15_23
    local v15_24
    local v15_25
    local v15_26
    local v15_27
    local v15_28
    local v15_29
    local v15_30
    local v15_31
    local v15_32
    local v15_33
    local v15_34
    local v15_35
    local v15_36
    local v15_37
    local v15_38
    local v15_39
    local v15_40
    local v15_41
    local v15_42
    local v15_43
    local v15_44
    local v15_45
    local v15_46
    local v15_47
    local v15_48
    local v15_49
    local v15_50
    local v15_51
    local v15_52
    local v15_53
    local v15_54
    local v15_55
    local v15_56
    local v15_57
    local v15_58
    local v15_59
    local v15_60
    local v15_61
    local v15_62
    local v15_63
    local v15_64
    local v15_65
    local v15_66
    local v15_67
    local v15_68
    local v15_69
    local v15_70
    local v15_71
    local v15_72
    local v15_73
    local v15_74
    local v15_75
    local v15_76
    local v15_77
    local v15_78
    local v15_79
    local v15_80
    local v15_81
    local v15_82
    local v15_83
    local v15_84
    local v15_85
    v15_0 = {}
    v15_1 = nil
    v15_2 = v44_44
    v15_3 = IsNull
    v15_4 = v15_3(v15_2)
    if not (v15_4) then
        v15_5 = v44_44
        v15_6 = WeakResource
        v15_14 = v15_5:IsA(v15_6("/Lotus/Powersuits/Temple/TempleBaseSuit"))
        if v15_14 then
            v15_15 = mMovie
            v15_20 = v15_15:GetLocalized("/Lotus/Language/Suits/TempleMetronomeAudioToggle", false)
            v15_21 = v15_20
            v15_22 = v44_64
            if v15_22 then
                v15_32 = mMovie
                v15_37 = v15_32:GetLocalized("<CHECKMARK> ", true)
                v15_38 = v15_37
                v15_39 = v15_21
                v15_31 = (v15_38 .. v15_39)
            else
                v15_23 = mMovie
                v15_28 = v15_23:GetLocalized("<CHECKMARK_OUTLINE> ", true)
                v15_29 = v15_28
                v15_30 = v15_21
                v15_31 = (v15_29 .. v15_30)
            end
            v15_40 = { Label = nil, CallBack = nil, CallOut = "MENU_GENERIC2" }
            v15_40.Label = v15_31
            v15_41 = cap_44_146_2
            v15_40.CallBack = v15_41
            v15_42 = v15_0
            v15_43 = table.insert
            v15_43(v15_42, v15_40)
        end
    end
    v15_44 = mMovie
    v15_49 = v15_44:GetLocalized("/Lotus/Language/Menu/ShowBaseStats", false)
    v15_50 = v15_49
    v15_51 = v44_47
    if not (v15_51) then
        v15_61 = mMovie
        v15_66 = v15_61:GetLocalized("<CHECKMARK> ", true)
        v15_67 = v15_66
        v15_68 = v15_50
        v15_60 = (v15_67 .. v15_68)
    else
        v15_52 = mMovie
        v15_57 = v15_52:GetLocalized("<CHECKMARK_OUTLINE> ", true)
        v15_58 = v15_57
        v15_59 = v15_50
        v15_60 = (v15_58 .. v15_59)
    end
    v15_69 = { Label = nil, CallBack = nil, CallOut = "MENU_GENERIC1" }
    v15_69.Label = v15_60
    v15_70 = cap_44_146_4
    v15_69.CallBack = v15_70
    v15_71 = v15_0
    v15_72 = table.insert
    v15_72(v15_71, v15_69)
    v15_73 = { Label = "/Lotus/Language/Menu/Exit", CallBack = nil, CallOut = "MENU_CANCEL" }
    v15_74 = cap_44_146_5
    v15_73.CallBack = v15_74
    v15_75 = v15_0
    v15_76 = table.insert
    v15_76(v15_75, v15_73)
    v15_77 = _T.SetButtons
    if v15_77 then
        v15_78 = _T.SetButtons
        v15_79 = mMovie
        v15_80 = v15_0
        v15_81 = getfenv
        v15_78(v15_79, v15_80, v15_81(1))
    end
    return
end
UpdateButtons = v44_84
v44_85 = function()
    local v16_0
    v44_48 = false
    return
end
local cap_44_156_1 = v44_23
local cap_44_156_5 = v44_26
v44_86 = function()
    local v18_0
    local v18_1
    local v18_2
    local v18_3
    local v18_4
    local v18_5
    local v18_6
    local v18_7
    local v18_8
    local v18_9
    local v18_10
    local v18_11
    local v18_12
    local v18_13
    local v18_14
    local v18_15
    local v18_16
    local v18_17
    local v18_18
    local v18_19
    local v18_20
    local v18_21
    local v18_22
    local v18_23
    local v18_24
    local v18_25
    local v18_26
    local v18_27
    local v18_28
    local v18_29
    local v18_30
    local v18_31
    local v18_32
    local v18_33
    local v18_34
    local v18_35
    local v18_36
    local v18_37
    local v18_38
    v18_0 = cap_44_156_1
    v18_1 = (v18_0).Create
    v18_2 = mMovie
    v18_4 = v18_1(v18_2, "Abilities.AbilityList")
    v44_57 = v18_4
    v18_5 = v44_57
    v18_5.CanPreviewElements = true
    v18_7 = v44_57
    v18_8 = function(p17_0)
        local v17_1
        local v17_2
        local v17_3
        local v17_4
        local v17_5
        local v17_6
        local v17_7
        local v17_8
        local v17_9
        local v17_10
        local v17_11
        local v17_12
        local v17_13
        v17_1 = v44_53
        if v17_1 ~= nil then
            v17_2 = cap_44_156_1
            v17_3 = (v17_2).ShowAugmentsForAbility
            v17_4 = mMovie
            v17_5 = p17_0
            v17_6 = v44_53
            v17_7 = graphicManifestMovie
            v17_8 = v44_43
            v17_9 = Resource
            v17_10 = (p17_0).RepSynd
            v17_13 = v17_3(v17_4, v17_5, v17_6, v17_7, v17_8, v17_9(v17_10))
            v44_51 = v17_13
            return
        else
            return
        end
    end
    v18_7.PreviewCallback = v18_8
    v18_9 = v44_57
    v18_9:UpdateVisRanges()
    v18_12 = gGameData
    v18_15 = v18_12:GetSupportedSyndicate()
    v18_16 = cap_44_156_5
    v18_17 = (v18_16).GetUIMode
    v18_18 = v18_17()
    v18_19 = cap_44_156_5
    v18_20 = (v18_19).UI_MODE_IN_SPACE_SHIP
    if not (v18_18 ~= v18_20) then
        v18_21 = EMPTY_SYMBOL
        if v18_15 == v18_21 then
        else
            v18_22 = 1
            v18_23 = syndicates
            v18_24 = (#v18_23)
            v18_25 = 1
            for v18_22 = v18_22, v18_24, v18_25 do
                v18_26 = Resource
                v18_27 = syndicates
                v18_28 = v18_27[v18_22]
                v18_29 = v18_26(v18_28)
                v18_30 = v18_29
                v18_31 = IsNull
                v18_32 = v18_31(v18_30)
                if v18_32 then
                else
                    v18_35 = v18_29:GetAffiliationTag()
                    if v18_35 ~= v18_15 then continue end
                    v18_36 = v44_57
                    v18_37 = syndicates
                    v18_38 = v18_37[v18_22]
                    v18_36.RepSynd = v18_38
                    return
                end
            end
        end
    end
    return
end
local cap_44_163_1 = v44_5
local cap_44_163_3 = v44_11
v44_87 = function()
    local v22_0
    local v22_1
    local v22_2
    local v22_3
    local v22_4
    local v22_5
    local v22_6
    local v22_7
    local v22_8
    local v22_9
    local v22_10
    local v22_11
    local v22_12
    local v22_13
    local v22_14
    local v22_15
    local v22_16
    local v22_17
    local v22_18
    local v22_19
    local v22_20
    local v22_21
    local v22_22
    local v22_23
    local v22_24
    local v22_25
    local v22_26
    local v22_27
    local v22_28
    v22_0 = require
    v22_2 = v22_0("EE.Interface.Components.List")
    v22_3 = (v22_2).CreateList
    v22_4 = mMovie
    v22_7 = v22_3(v22_4, "OperatorAbilities.Ability", 3)
    v44_56 = v22_7
    v22_8 = v44_56
    v22_8:SetCallbacks(nil, "OpAbilityFocused", "OpAbilityUnfocused")
    v22_14 = v44_56
    v22_14.mForcedHorizontalSeparation = 65
    v22_16 = v44_56
    v22_16.mForcedVerticalSeparation = 0
    v22_18 = v44_56
    v22_19 = function(p19_0)
        local v19_1
        local v19_2
        local v19_3
        local v19_4
        local v19_5
        local v19_6
        local v19_7
        local v19_8
        local v19_9
        local v19_10
        local v19_11
        local v19_12
        local v19_13
        local v19_14
        local v19_15
        local v19_16
        local v19_17
        local v19_18
        local v19_19
        local v19_20
        local v19_21
        local v19_22
        local v19_23
        local v19_24
        local v19_25
        local v19_26
        local v19_27
        local v19_28
        local v19_29
        local v19_30
        local v19_31
        local v19_32
        local v19_33
        local v19_34
        local v19_35
        local v19_36
        local v19_37
        local v19_38
        local v19_39
        local v19_40
        local v19_41
        local v19_42
        local v19_43
        local v19_44
        local v19_45
        local v19_46
        local v19_47
        local v19_48
        local v19_49
        local v19_50
        local v19_51
        local v19_52
        local v19_53
        local v19_54
        local v19_55
        v19_1 = cap_44_163_1
        v19_2 = (v19_1).Ternary
        v19_3 = (p19_0).mIsUltimate
        v19_6 = v19_2(v19_3, 3, 1)
        v19_7 = mMovie
        v19_8 = (p19_0).mClipName
        v19_10 = (v19_8 .. ".IconBacker")
        v19_11 = Name__40379146
        v19_12 = v19_11[v19_6]
        v19_7:OverrideTexture(v19_10, v19_12)
        v19_15 = mMovie
        v19_16 = (p19_0).mClipName
        v19_18 = (v19_16 .. ".IconBackerFill")
        v19_19 = Name__40379146
        v19_20 = (v19_6 + 1)
        v19_21 = v19_19[v19_20]
        v19_15:OverrideTexture(v19_18, v19_21)
        v19_24 = mMovie
        v19_25 = (p19_0).mClipName
        v19_27 = (v19_25 .. ".Icon")
        v19_28 = (p19_0).mCard
        v19_29 = (v19_28).mIcon
        v19_24:OverrideTexture(v19_27, v19_29)
        v19_32 = mMovie
        v19_33 = (p19_0).mClipName
        v19_36 = v44_43
        v19_37 = (v19_36).FloatingContent
        v19_32:Name__52c1b74e(v19_33, "Icon", 11, v19_37)
        v19_40 = mMovie
        v19_41 = (p19_0).mClipName
        v19_44 = v44_43
        v19_45 = (v19_44).FloatingContent
        v19_40:Name__52c1b74e(v19_41, "IconBacker", 11, v19_45)
        v19_48 = mMovie
        v19_49 = (p19_0).mClipName
        v19_52 = v44_43
        v19_53 = (v19_52).Background1
        v19_48:Name__52c1b74e(v19_49, "IconBackerFill", 11, v19_53)
        return
    end
    v22_18.mElementDrawCallback = v22_19
    v22_20 = v44_56
    v22_21 = function(p20_0)
        local v20_1
        local v20_2
        local v20_3
        local v20_4
        local v20_5
        local v20_6
        local v20_7
        local v20_8
        local v20_9
        local v20_10
        local v20_11
        local v20_12
        local v20_13
        local v20_14
        local v20_15
        local v20_16
        local v20_17
        local v20_18
        local v20_19
        local v20_20
        local v20_21
        local v20_22
        local v20_23
        local v20_24
        local v20_25
        local v20_26
        local v20_27
        local v20_28
        local v20_29
        local v20_30
        local v20_31
        local v20_32
        local v20_33
        local v20_34
        local v20_35
        local v20_36
        local v20_37
        local v20_38
        local v20_39
        local v20_40
        local v20_41
        local v20_42
        local v20_43
        local v20_44
        local v20_45
        local v20_46
        local v20_47
        local v20_48
        local v20_49
        local v20_50
        local v20_51
        local v20_52
        local v20_53
        local v20_54
        local v20_55
        local v20_56
        local v20_57
        local v20_58
        local v20_59
        local v20_60
        local v20_61
        local v20_62
        local v20_63
        local v20_64
        local v20_65
        local v20_66
        local v20_67
        local v20_68
        local v20_69
        local v20_70
        local v20_71
        local v20_72
        local v20_73
        local v20_74
        local v20_75
        v20_1 = cap_44_163_1
        v20_2 = (v20_1).PlaySound
        v20_3 = _G
        v20_4 = (v20_3).UISound_Focus
        v20_2(v20_4)
        v20_5 = mMovie
        v20_6 = (p20_0).mClipName
        v20_9 = v44_43
        v20_10 = (v20_9).FloatingContentHighlight
        v20_5:Name__52c1b74e(v20_6, "Icon", 11, v20_10)
        v20_13 = mMovie
        v20_14 = (p20_0).mClipName
        v20_17 = v44_43
        v20_18 = (v20_17).FloatingContentHighlight
        v20_13:Name__52c1b74e(v20_14, "IconBacker", 11, v20_18)
        v20_21 = (p20_0).mCard
        v20_22 = (v20_21).mDesc
        v20_23 = (p20_0).mModifierCard
        v20_24 = IsNull
        v20_25 = v20_24(v20_23)
        if not (v20_25) then
            v20_26 = mMovie
            v20_28 = cap_44_163_1
            v20_29 = (v20_28).Ternary
            v20_30 = (p20_0).mIsUltimate
            v20_33 = v20_29(v20_30, "OperatorAbilitiesUltimateModifierAppend", "OperatorAbilitiesModifierAppend")
            v20_34 = ("/Lotus/Language/Focus/" .. v20_33)
            v20_38 = v20_26:GetLocalized(v20_34, false)
            v20_39 = v20_22
            v20_41 = v44_43
            v20_42 = (v20_41).FloatingContentHighlightHex
            v20_44 = v20_38
            v20_46 = string.upper
            v20_47 = (p20_0).mModifierCard
            v20_48 = (v20_47).mName
            v20_49 = v20_46(v20_48)
            v20_50 = v20_49
            v20_52 = (p20_0).mModifierCard
            v20_53 = (v20_52).mDesc
            v20_22 = (v20_39 .. "<br><br><font color=\"" .. v20_42 .. "\">" .. v20_44 .. "<br><b>" .. v20_50 .. "</b></font><br>" .. v20_53)
        end
        v20_54 = { CustomEntry = true, Name = nil, Description = nil }
        v20_55 = (p20_0).mCard
        v20_56 = (v20_55).mName
        v20_54.Name = v20_56
        v20_54.Description = v20_22
        v20_57 = cap_44_163_3
        v20_58 = (v20_57).SetItemInfoPopupRect
        v20_59 = mMovie
        v20_60 = v20_54
        v20_61 = mMovie
        v20_62 = (p20_0).mClipName
        v20_66 = v20_61:GetNumberVariable(v20_62, 2)
        v20_67 = mMovie
        v20_68 = (p20_0).mClipName
        v20_72 = v20_67:GetNumberVariable(v20_68, 3)
        v20_58(v20_59, v20_60, v20_66, v20_72, 60, 60)
        v20_75 = _T
        v20_75.InfoPopup_Data = v20_54
        return
    end
    v22_20.mOnFocusedCallback = v22_21
    v22_22 = v44_56
    v22_23 = function(p21_0)
        local v21_1
        local v21_2
        local v21_3
        local v21_4
        local v21_5
        local v21_6
        local v21_7
        local v21_8
        local v21_9
        local v21_10
        local v21_11
        local v21_12
        local v21_13
        local v21_14
        local v21_15
        local v21_16
        local v21_17
        local v21_18
        v21_1 = mMovie
        v21_2 = (p21_0).mClipName
        v21_5 = v44_43
        v21_6 = (v21_5).FloatingContent
        v21_1:Name__52c1b74e(v21_2, "Icon", 11, v21_6)
        v21_9 = mMovie
        v21_10 = (p21_0).mClipName
        v21_13 = v44_43
        v21_14 = (v21_13).FloatingContent
        v21_9:Name__52c1b74e(v21_10, "IconBacker", 11, v21_14)
        v21_17 = _T
        v21_17.InfoPopup_Data = nil
        return
    end
    v22_22.mOnUnfocusedCallback = v22_23
    v22_24 = mMovie
    v22_26 = operatorIcon
    v22_24:OverrideTexture("OperatorAbilities.Icon", v22_26)
    return
end
local cap_44_168_0 = v44_5
local cap_44_168_2 = v44_8
local cap_44_168_4 = v44_14
local cap_44_168_5 = v44_62
local cap_44_168_8 = v44_35
local cap_44_168_11 = v44_68
local cap_44_168_13 = v44_71
local cap_44_168_14 = v44_72
local cap_44_168_17 = v44_52
local cap_44_168_18 = v44_26
v44_88 = function()
    local frame_23 = {}
    local cfg_23 = 0
    while true do
        if cfg_23 == 0 then
            frame_23[0] = cap_44_168_0
            frame_23[1] = (frame_23[0]).PlaySound
            frame_23[2] = _G
            frame_23[3] = (frame_23[2]).UISound_GridOpen
            frame_23[1](frame_23[3])
            frame_23[4] = cap_44_168_0
            frame_23[5] = (frame_23[4]).PlaySound
            frame_23[6] = _G
            frame_23[7] = (frame_23[6]).UISound_ButtonSelect
            frame_23[5](frame_23[7])
            frame_23[8] = mMovie
            frame_23[9] = _T.RadialSolarMapOpen
            if frame_23[9] == true then
                cfg_23 = 2
            else
                cfg_23 = 1
            end
        elseif cfg_23 == 1 then
            frame_23[10] = false
            cfg_23 = 3
        elseif cfg_23 == 2 then
            frame_23[10] = true
            cfg_23 = 3
        elseif cfg_23 == 3 then
            do (frame_23[8]):SetPreDrawUpdate(frame_23[10]) end
            frame_23[13] = mMovie
            do (frame_23[13]):SetBackgroundColor(0) end
            frame_23[17] = mMovie
            do (frame_23[17]):SetBackgroundAlpha(1) end
            frame_23[21] = { Background1 = nil, FloatingContent = nil, FloatingContentHighlight = nil }
            frame_23[22] = cap_44_168_2
            frame_23[23] = (frame_23[22]).GetColor
            frame_23[26] = frame_23[23](2, true)
            frame_23[21].Background1 = frame_23[26]
            frame_23[27] = cap_44_168_2
            frame_23[28] = (frame_23[27]).GetColor
            frame_23[31] = frame_23[28](9, true)
            frame_23[21].FloatingContent = frame_23[31]
            frame_23[32] = cap_44_168_2
            frame_23[33] = (frame_23[32]).GetColor
            frame_23[36] = frame_23[33](10, true)
            frame_23[21].FloatingContentHighlight = frame_23[36]
            v44_43 = frame_23[21]
            frame_23[37] = cap_44_168_4
            frame_23[38] = (frame_23[37]).Create
            frame_23[39] = mMovie
            frame_23[40] = frame_23[38](frame_23[39])
            v44_50 = frame_23[40]
            frame_23[41] = v44_50
            frame_23[42] = mMovie
            frame_23[44] = {}
            frame_23[45] = v44_50
            frame_23[46] = (frame_23[45]).ANCHOR_H_LEFT
            frame_23[47] = v44_50
            frame_23[48] = (frame_23[47]).ANCHOR_V_BOTTOM
            frame_23[44][1] = frame_23[46]
            frame_23[44][2] = frame_23[48]
            do (frame_23[41]):Register(frame_23[42], "Passive", frame_23[44]) end
            frame_23[51] = v44_50
            frame_23[52] = mMovie
            frame_23[54] = {}
            frame_23[55] = v44_50
            frame_23[56] = (frame_23[55]).ANCHOR_H_LEFT
            frame_23[57] = v44_50
            frame_23[58] = (frame_23[57]).ANCHOR_V_BOTTOM
            frame_23[54][1] = frame_23[56]
            frame_23[54][2] = frame_23[58]
            do (frame_23[51]):Register(frame_23[52], "Switch", frame_23[54]) end
            frame_23[61] = v44_50
            frame_23[62] = mMovie
            frame_23[64] = {}
            frame_23[65] = v44_50
            frame_23[66] = (frame_23[65]).ANCHOR_H_CENTRE
            frame_23[67] = v44_50
            frame_23[68] = (frame_23[67]).ANCHOR_V_BOTTOM
            frame_23[64][1] = frame_23[66]
            frame_23[64][2] = frame_23[68]
            do (frame_23[61]):Register(frame_23[62], "Abilities", frame_23[64]) end
            frame_23[71] = v44_50
            frame_23[72] = mMovie
            frame_23[74] = {}
            frame_23[75] = v44_50
            frame_23[76] = (frame_23[75]).ANCHOR_H_RIGHT
            frame_23[77] = v44_50
            frame_23[78] = (frame_23[77]).ANCHOR_V_BOTTOM
            frame_23[74][1] = frame_23[76]
            frame_23[74][2] = frame_23[78]
            do (frame_23[71]):Register(frame_23[72], "Tips", frame_23[74]) end
            frame_23[81] = v44_50
            frame_23[82] = mMovie
            frame_23[84] = {}
            frame_23[85] = v44_50
            frame_23[86] = (frame_23[85]).ANCHOR_H_RIGHT
            frame_23[87] = v44_50
            frame_23[88] = (frame_23[87]).ANCHOR_V_BOTTOM
            frame_23[84][1] = frame_23[86]
            frame_23[84][2] = frame_23[88]
            do (frame_23[81]):Register(frame_23[82], "OperatorAbilities", frame_23[84]) end
            frame_23[91] = v44_50
            frame_23[95] = (frame_23[91]):GetOriginalCoords("OperatorAbilities")
            frame_23[96] = cap_44_168_5
            frame_23[97] = (frame_23[95]).x
            frame_23[96].InitX = frame_23[97]
            frame_23[98] = cap_44_168_5
            frame_23[99] = mMovie
            frame_23[104] = (frame_23[99]):GetNumberVariable("OperatorAbilities.Arrow.Middle", 14)
            frame_23[98].InitArrowWidth = frame_23[104]
            frame_23[105] = cap_44_168_5
            frame_23[106] = mMovie
            frame_23[111] = (frame_23[106]):GetNumberVariable("OperatorAbilities.Arrow.Middle", 0)
            frame_23[105].InitArrowX = frame_23[111]
            frame_23[112] = cap_44_168_5
            frame_23[113] = mMovie
            frame_23[118] = (frame_23[113]):GetNumberVariable("OperatorAbilities.Arrow.Fade", 0)
            frame_23[112].InitArrowFadeX = frame_23[118]
            frame_23[119] = cap_44_168_5
            frame_23[120] = mMovie
            frame_23[125] = (frame_23[120]):GetNumberVariable("OperatorAbilities.Backer", 14)
            frame_23[119].InitBackerWidth = frame_23[125]
            frame_23[126] = cap_44_168_5
            frame_23[127] = mMovie
            frame_23[132] = (frame_23[127]):GetNumberVariable("OperatorAbilities.Backer", 0)
            frame_23[126].InitBackerX = frame_23[132]
            frame_23[133] = cap_44_168_5
            frame_23[134] = mMovie
            frame_23[139] = (frame_23[134]):GetNumberVariable("OperatorAbilities.Blurer", 14)
            frame_23[133].InitBlurerWidth = frame_23[139]
            frame_23[140] = cap_44_168_5
            frame_23[141] = mMovie
            frame_23[146] = (frame_23[141]):GetNumberVariable("OperatorAbilities.Blurer", 0)
            frame_23[140].InitBlurerX = frame_23[146]
            frame_23[147] = gPlayerProfileMgr
            frame_23[151] = (frame_23[147]):GetPlayerProfile(0)
            frame_23[154] = (frame_23[151]):Settings()
            v44_49 = frame_23[154]
            frame_23[155] = cap_44_168_8
            frame_23[156] = (frame_23[155]).CreateAvatarDiorama
            frame_23[157] = mMovie
            frame_23[158] = frame_23[156](frame_23[157])
            v44_63 = frame_23[158]
            frame_23[159] = v44_49
            frame_23[162] = (frame_23[159]):Name__e560dee0()
            v44_47 = frame_23[162]
            frame_23[163] = v44_49
            frame_23[164] = cap_44_168_11
            frame_23[167] = (frame_23[163]):Name__b66a4856(frame_23[164])
            if frame_23[167] == 1 then
                cfg_23 = 5
            else
                cfg_23 = 4
            end
        elseif cfg_23 == 4 then
            frame_23[168] = false
            cfg_23 = 6
        elseif cfg_23 == 5 then
            frame_23[168] = true
            cfg_23 = 6
        elseif cfg_23 == 6 then
            v44_64 = frame_23[168]
            frame_23[169] = v44_49
            frame_23[170] = cap_44_168_13
            frame_23[173] = (frame_23[169]):Name__b66a4856(frame_23[170])
            if frame_23[173] == 1 then
                cfg_23 = 8
            else
                cfg_23 = 7
            end
        elseif cfg_23 == 7 then
            frame_23[174] = false
            cfg_23 = 9
        elseif cfg_23 == 8 then
            frame_23[174] = true
            cfg_23 = 9
        elseif cfg_23 == 9 then
            v44_65 = frame_23[174]
            frame_23[175] = mMovie
            do (frame_23[175]):Name__d9713943("Passive", 13, false) end
            frame_23[181] = mMovie
            do (frame_23[181]):Name__d9713943("Switch", 13, false) end
            frame_23[187] = mMovie
            do (frame_23[187]):Name__d9713943("Tips", 13, false) end
            frame_23[193] = mMovie
            do (frame_23[193]):Name__d9713943("Abilities", 13, false) end
            frame_23[199] = mMovie
            do (frame_23[199]):Name__d9713943("OperatorAbilities", 13, false) end
            frame_23[205] = mMovie
            do (frame_23[205]):SetCallbacks("OperatorAbilities.Icon", "OperatorIconFocused", "OperatorIconUnfocused", nil, nil) end
            frame_23[213] = cap_44_168_14
            frame_23[213]()
            frame_23[214] = v44_45
            frame_23[215] = IsNull
            frame_23[216] = frame_23[215](frame_23[214])
            if frame_23[216] then
                cfg_23 = 11
            else
                cfg_23 = 10
            end
        elseif cfg_23 == 10 then
            frame_23[217] = v44_45
            frame_23[220] = (frame_23[217]):InventoryControl()
            frame_23[223] = (frame_23[220]):IsSpaceMode()
            v44_46 = frame_23[223]
            cfg_23 = 11
        elseif cfg_23 == 11 then
            frame_23[224] = cap_44_168_17
            frame_23[224].Initialized = false
            frame_23[226] = cap_44_168_18
            frame_23[227] = (frame_23[226]).GetUIMode
            frame_23[228] = frame_23[227]()
            frame_23[229] = cap_44_168_18
            frame_23[230] = (frame_23[229]).UI_MODE_IN_SPACE_SHIP
            if frame_23[228] == frame_23[230] then
                cfg_23 = 16
            else
                cfg_23 = 12
            end
        elseif cfg_23 == 12 then
            frame_23[231] = _T.InSimulacrum
            if frame_23[231] then
                cfg_23 = 16
            else
                cfg_23 = 13
            end
        elseif cfg_23 == 13 then
            frame_23[232] = _T.InDojo
            if frame_23[232] then
                cfg_23 = 16
            else
                cfg_23 = 14
            end
        elseif cfg_23 == 14 then
            frame_23[233] = gGameRules
            frame_23[234] = IsNull
            frame_23[235] = frame_23[234](frame_23[233])
            if frame_23[235] then
                cfg_23 = 17
            else
                cfg_23 = 15
            end
        elseif cfg_23 == 15 then
            frame_23[236] = gGameRules
            frame_23[237] = gLotusHubGameRulesType
            frame_23[240] = (frame_23[236]):IsA(frame_23[237])
            if not (frame_23[240]) then
                cfg_23 = 17
            else
                cfg_23 = 16
            end
        elseif cfg_23 == 16 then
            frame_23[241] = cap_44_168_17
            frame_23[242] = UISys.ScriptResLoader_Create
            frame_23[243] = {}
            frame_23[244] = Name__e2170410
            do
                local setlist_values_23_273 = table.pack((frame_23[244]):GetFullName())
                for setlist_index_23_273 = 1, setlist_values_23_273.n do
                    frame_23[243][1 + setlist_index_23_273 - 1] = setlist_values_23_273[setlist_index_23_273]
                end
            end
            frame_23[251] = frame_23[242](frame_23[243])
            frame_23[241].Loader = frame_23[251]
            frame_23[252] = _T.BackgroundMovie
            do (frame_23[252]):Execute("ShowBlockingMessage", "1") end
            cfg_23 = 17
        elseif cfg_23 == 17 then
            return
        else
            error("invalid control state")
        end
    end
end
Initialize = v44_88
local cap_44_189_0 = v44_80
v44_89 = function()
    local v24_0
    v24_0 = cap_44_189_0
    v24_0()
    return
end
TransitionOut = v44_89
local cap_44_192_0 = v44_5
v44_90 = function()
    local v25_0
    local v25_1
    local v25_2
    local v25_3
    local v25_4
    local v25_5
    local v25_6
    local v25_7
    local v25_8
    local v25_9
    local v25_10
    local v25_11
    local v25_12
    local v25_13
    local v25_14
    local v25_15
    local v25_16
    local v25_17
    local v25_18
    local v25_19
    local v25_20
    local v25_21
    local v25_22
    local v25_23
    local v25_24
    local v25_25
    local v25_26
    local v25_27
    local v25_28
    local v25_29
    local v25_30
    local v25_31
    local v25_32
    local v25_33
    local v25_34
    v25_0 = _T
    v25_0.InfoPopup_Data = nil
    v25_2 = _T
    v25_2.AbilityLevelQueryParms = nil
    v25_4 = _T
    v25_4.AbilityUpgradeLevelInfo = nil
    v25_6 = _T
    v25_6.ModPreviewAvatar = nil
    v25_8 = cap_44_192_0
    v25_9 = (v25_8).PlaySound
    v25_10 = _G
    v25_11 = (v25_10).UISound_GridOpenTwo
    v25_9(v25_11)
    v25_12 = gGameStatsMgr
    v25_13 = IsNull
    v25_14 = v25_13(v25_12)
    if not (v25_14) then
        v25_15 = gGameStatsMgr
        v25_16 = Symbol
        v25_18 = v25_16("IN_SHIP_VIEW_TIME")
        v25_15:StopTimer(v25_18, "EQUIPMENT_ABILITIES")
    end
    v25_22 = _T.SetSquadOverlayTitle
    v25_23 = IsNull
    v25_24 = v25_23(v25_22)
    if not (v25_24) then
        v25_25 = _T.SetSquadOverlayTitle
        v25_25()
    end
    v25_26 = v44_51
    v25_27 = IsNull
    v25_28 = v25_27(v25_26)
    if not (v25_28) then
        v25_29 = v44_51
        v25_29:Close()
    end
    v25_32 = gFlashMgr
    v25_32:DestroyBackgroundRegion()
    return
end
Shutdown = v44_90
local cap_44_196_0 = v44_52
local cap_44_196_2 = v44_86
local cap_44_196_3 = v44_87
local cap_44_196_4 = v44_79
local cap_44_196_5 = v44_78
local cap_44_196_6 = v44_85
local cap_44_196_7 = v44_76
local cap_44_196_8 = v44_74
local cap_44_196_11 = v44_5
v44_91 = function()
    local v26_0
    local v26_1
    local v26_2
    local v26_3
    local v26_4
    local v26_5
    local v26_6
    local v26_7
    local v26_8
    local v26_9
    local v26_10
    local v26_11
    local v26_12
    local v26_13
    local v26_14
    local v26_15
    local v26_16
    local v26_17
    local v26_18
    local v26_19
    local v26_20
    local v26_21
    local v26_22
    local v26_23
    local v26_24
    local v26_25
    local v26_26
    local v26_27
    local v26_28
    local v26_29
    local v26_30
    local v26_31
    local v26_32
    local v26_33
    local v26_34
    local v26_35
    local v26_36
    local v26_37
    local v26_38
    local v26_39
    local v26_40
    local v26_41
    local v26_42
    local v26_43
    local v26_44
    local v26_45
    local v26_46
    local v26_47
    local v26_48
    local v26_49
    local v26_50
    local v26_51
    local v26_52
    local v26_53
    local v26_54
    local v26_55
    local v26_56
    local v26_57
    local v26_58
    local v26_59
    local v26_60
    local v26_61
    local v26_62
    local v26_63
    local v26_64
    local v26_65
    local v26_66
    local v26_67
    local v26_68
    local v26_69
    local v26_70
    local v26_71
    local v26_72
    local v26_73
    local v26_74
    local v26_75
    local v26_76
    local v26_77
    local v26_78
    local v26_79
    local v26_80
    local v26_81
    local v26_82
    local v26_83
    local v26_84
    local v26_85
    local v26_86
    local v26_87
    local v26_88
    local v26_89
    local v26_90
    local v26_91
    local v26_92
    local v26_93
    local v26_94
    local v26_95
    local v26_96
    local v26_97
    local v26_98
    local v26_99
    local v26_100
    local v26_101
    local v26_102
    local v26_103
    local v26_104
    local v26_105
    local v26_106
    local v26_107
    local v26_108
    local v26_109
    local v26_110
    local v26_111
    local v26_112
    local v26_113
    local v26_114
    local v26_115
    local v26_116
    local v26_117
    local v26_118
    v26_0 = mMovie
    v26_1 = RealDeltaTime
    v26_0:Name__b7f5bbc5(v26_1())
    v26_7 = cap_44_196_0
    v26_8 = (v26_7).Initialized
    if not (v26_8) then
        v26_9 = cap_44_196_0
        v26_10 = (v26_9).Loader
        local sc_26_1
        if v26_10 == nil then
            sc_26_1 = true
        else
            v26_11 = cap_44_196_0
            v26_12 = (v26_11).Loader
            v26_15 = v26_12:IsDone()
            sc_26_1 = v26_15
        end
        if sc_26_1 then
            v26_16 = cap_44_196_0
            v26_16.Initialized = true
            v26_18 = cap_44_196_0
            v26_19 = (v26_18).Loader
            if not (v26_19 == nil) then
                v26_20 = Resource
                v26_21 = Name__e2170410
                v26_22 = v26_20(v26_21)
                v44_53 = v26_22
            end
            v26_23 = cap_44_196_2
            v26_23()
            v26_24 = cap_44_196_3
            v26_24()
            v26_25 = cap_44_196_4
            v26_25(true)
            v26_27 = cap_44_196_5
            v26_27()
            v26_28 = cap_44_196_6
            v26_28()
            v26_29 = cap_44_196_7
            v26_29(true)
            v26_31 = UpdateButtons
            v26_31()
            v26_32 = cap_44_196_8
            v26_33 = mMovie
            v26_36 = v26_33:GetViewportWidth()
            v26_37 = mMovie
            v26_32(v26_36, v26_37:GetViewportHeight())
            v26_43 = gGameStatsMgr
            v26_44 = IsNull
            v26_45 = v26_44(v26_43)
            if not (v26_45) then
                v26_46 = gGameStatsMgr
                v26_47 = Symbol
                v26_49 = v26_47("IN_SHIP_VIEW_TIME")
                v26_46:StartTimer(v26_49, "EQUIPMENT_ABILITIES")
            end
            v26_53 = _T.BackgroundMovie
            v26_53:Execute("ShowBlockingMessage", "0")
        end
    end
    v26_58 = v44_57
    v26_59 = IsNull
    v26_60 = v26_59(v26_58)
    if not (v26_60) then
        v26_61 = v44_57
        v26_61:Update()
    end
    v26_64 = v44_63
    v26_65 = IsNull
    v26_66 = v26_65(v26_64)
    if not (v26_66) then
        v26_67 = v44_63
        v26_67:Update()
        v26_70 = v44_63
        v26_71 = (v26_70).mDioramaLoader
        v26_74 = v26_71:IsLoading()
        if v26_74 then
            v26_75 = v44_63
            v26_76 = (v26_75).mDioramaLoader
            v26_79 = v26_76:LoadingComplete()
            if v26_79 then
                v26_80 = v44_63
                v26_81 = (v26_80).mDioramaLoader
                v26_81.mSyncAvatars = true
                v26_83 = v44_63
                v26_84 = (v26_83).mDioramaLoader
                v26_84.mUseArsenalAvatarForLocal = true
                v26_86 = v44_63
                v26_87 = (v26_86).mDioramaLoader
                v26_87:FinishLoad()
                v26_90 = v44_63
                v26_91 = (v26_90).mDioramaLoader
                v26_92 = Symbol
                v26_94 = v26_92("Venari")
                v26_95 = _T.SpecialSuitAvatar
                v26_91:UpdateAvatar(v26_94, v26_95, true)
                v26_99 = v44_63
                v26_99:FinishLoadingAvatarDiorama()
                v26_102 = cap_44_196_11
                v26_103 = (v26_102).FadeBackground
                v26_104 = mMovie
                v26_103(v26_104, 0, 0.35)
                v26_107 = cap_44_196_7
                v26_107()
                v26_108 = cap_44_196_8
                v26_109 = mMovie
                v26_112 = v26_109:GetViewportWidth()
                v26_113 = mMovie
                v26_108(v26_112, v26_113:GetViewportHeight())
            end
        end
    end
    return
end
Update = v44_91
v44_92 = function(p27_0)
    local v27_1
    local v27_2
    local v27_3
    if p27_0 ~= 1 then
        if p27_0 ~= 2 then
            v27_3 = v44_59
            return v27_3
        else
            v27_2 = v44_60
            return v27_2
        end
    else
        v27_1 = v44_58
        return v27_1
    end
end
local cap_44_214_0 = v44_92
v44_93 = function(p28_0)
    local v28_1
    local v28_2
    local v28_3
    local v28_4
    local v28_5
    v28_1 = cap_44_214_0
    v28_2 = p28_0
    v28_3 = v28_1(v28_2)
    v28_3:OnFocused()
    return
end
SideButtonFocused = v44_93
local cap_44_217_0 = v44_92
v44_94 = function(p29_0)
    local v29_1
    local v29_2
    local v29_3
    local v29_4
    local v29_5
    local v29_6
    local v29_7
    v29_1 = Engine.IsMobile
    v29_2 = v29_1()
    local predicate_value_29_0 = (not (v29_2) or not (p29_0 ~= 1))
    if predicate_value_29_0 then
        v29_3 = cap_44_217_0
        v29_4 = p29_0
        v29_5 = v29_3(v29_4)
        v29_5:OnUnfocused()
    end
    return
end
SideButtonUnfocused = v44_94
v44_95 = function()
    local v30_0
    local v30_1
    local v30_2
    local v30_3
    local v30_4
    local v30_5
    local v30_6
    v30_0 = _T
    v30_1 = mMovie
    v30_6 = v30_1:GetLocalized("/Lotus/Language/Focus/OperatorAbilitiesTooltip", false)
    v30_0.gToolTip = v30_6
    return
end
OperatorIconFocused = v44_95
v44_96 = function()
    local v31_0
    local v31_1
    v31_0 = _T
    v31_0.gToolTip = nil
    return
end
OperatorIconUnfocused = v44_96
v44_97 = function(p32_0)
    return
end
SideButtonPressed = v44_97
local cap_44_226_3 = v44_79
local cap_44_226_4 = v44_78
v44_98 = function(p33_0)
    local v33_1
    local v33_2
    local v33_3
    local v33_4
    local v33_5
    local v33_6
    local v33_7
    local v33_8
    if not (p33_0 ~= 3) then
        v33_1 = v44_61
        v33_2 = (not v33_1)
        v44_61 = v33_2
        v44_45 = nil
        v44_44 = nil
        v33_5 = cap_44_226_3
        v33_5(false)
        v33_7 = cap_44_226_4
        v33_7()
        v33_8 = UpdateButtons
        v33_8()
    end
    return
end
SideButtonReleased = v44_98
v44_99 = function(p34_0)
    local v34_1
    local v34_2
    local v34_3
    local v34_4
    local v34_5
    local v34_6
    local v34_7
    local v34_8
    local v34_9
    local v34_10
    local v34_11
    v34_1 = v44_48
    if not (v34_1) then
        v34_2 = v44_57
        v34_3 = IsNull
        v34_4 = v34_3(v34_2)
        if not (v34_4) then
            v34_5 = v44_57
            v34_6 = p34_0
            v34_7 = tonumber
            v34_8 = v34_7(v34_6)
            v34_5:SelectElementById(v34_8, true)
        end
    end
    return
end
AbilityPressed = v44_99
local cap_44_237_1 = v44_5
v44_100 = function(p35_0)
    local v35_1
    local v35_2
    local v35_3
    local v35_4
    local v35_5
    local v35_6
    local v35_7
    local v35_8
    local v35_9
    local v35_10
    local v35_11
    local v35_12
    local v35_13
    local v35_14
    v35_1 = v44_57
    v35_2 = IsNull
    v35_3 = v35_2(v35_1)
    if not (v35_3) then
        v35_4 = v44_57
        v35_5 = p35_0
        v35_6 = tonumber
        v35_7 = v35_6(v35_5)
        v35_4:FocusElementById(v35_7, true)
        v35_11 = cap_44_237_1
        v35_12 = (v35_11).PlaySound
        v35_13 = _G
        v35_14 = (v35_13).UISound_Focus
        v35_12(v35_14)
    end
    return
end
AbilityFocused = v44_100
v44_101 = function(p36_0)
    local v36_1
    local v36_2
    local v36_3
    local v36_4
    local v36_5
    local v36_6
    local v36_7
    local v36_8
    local v36_9
    local v36_10
    v36_1 = v44_57
    v36_2 = IsNull
    v36_3 = v36_2(v36_1)
    if not (v36_3) then
        v36_4 = v44_57
        v36_5 = p36_0
        v36_6 = tonumber
        v36_7 = v36_6(v36_5)
        v36_4:UnfocusElementById(v36_7, true)
    end
    return
end
AbilityUnfocused = v44_101
local cap_44_244_1 = v44_5
v44_102 = function(p37_0)
    local v37_1
    local v37_2
    local v37_3
    local v37_4
    local v37_5
    local v37_6
    local v37_7
    local v37_8
    local v37_9
    local v37_10
    local v37_11
    local v37_12
    local v37_13
    local v37_14
    v37_1 = v44_56
    v37_2 = IsNull
    v37_3 = v37_2(v37_1)
    if not (v37_3) then
        v37_4 = v44_56
        v37_5 = p37_0
        v37_6 = tonumber
        v37_7 = v37_6(v37_5)
        v37_4:FocusElementById(v37_7, true)
        v37_11 = cap_44_244_1
        v37_12 = (v37_11).PlaySound
        v37_13 = _G
        v37_14 = (v37_13).UISound_Focus
        v37_12(v37_14)
    end
    return
end
OpAbilityFocused = v44_102
v44_103 = function(p38_0)
    local v38_1
    local v38_2
    local v38_3
    local v38_4
    local v38_5
    local v38_6
    local v38_7
    local v38_8
    local v38_9
    local v38_10
    v38_1 = v44_56
    v38_2 = IsNull
    v38_3 = v38_2(v38_1)
    if not (v38_3) then
        v38_4 = v44_56
        v38_5 = p38_0
        v38_6 = tonumber
        v38_7 = v38_6(v38_5)
        v38_4:UnfocusElementById(v38_7, true)
    end
    return
end
OpAbilityUnfocused = v44_103
v44_104 = function()
    local v39_0
    v39_0 = v44_48
    return v39_0
end
IsInputBlocked = v44_104
v44_105 = function()
    local v40_0
    return true
end
SupportsThemes = v44_105
local cap_44_256_0 = v44_76
v44_106 = function()
    local v41_0
    local v41_1
    v41_0 = cap_44_256_0
    v41_0(true)
    return
end
OnStyleChangedCallback = v44_106
v44_107 = function(p42_0)
    local v42_1
    local v42_2
    local v42_3
    local v42_4
    local v42_5
    local v42_6
    local v42_7
    local v42_8
    local v42_9
    local v42_10
    local v42_11
    local v42_12
    local v42_13
    local v42_14
    local v42_15
    local v42_16
    local v42_17
    local v42_18
    local v42_19
    local v42_20
    if p42_0 ~= "true" then
        v42_11 = FlashInterpolate
        v42_12 = mMovie
        v42_15 = {}
        v42_15[1] = 12
        v42_17 = {}
        v42_17[1] = 100
        v42_11(v42_12, "_root", 2, v42_15, v42_17, 0.15, 0)
        return
    else
        v42_1 = FlashInterpolate
        v42_2 = mMovie
        v42_5 = {}
        v42_5[1] = 12
        v42_7 = {}
        v42_7[1] = 0
        v42_1(v42_2, "_root", 0, v42_5, v42_7, 0.15, 0)
        return
    end
end
HideScreenForPlatPurchase = v44_107
v44_108 = function(p43_0)
    local v43_1
    local v43_2
    local v43_3
    local v43_4
    local v43_5
    local v43_6
    v43_1 = v44_57
    v43_2 = IsNull
    v43_3 = v43_2(v43_1)
    if not (v43_3) then
        v43_4 = v44_57
        v43_4:OnGamepadTransition()
    end
    return
end
OnGamepadTransition = v44_108
return
