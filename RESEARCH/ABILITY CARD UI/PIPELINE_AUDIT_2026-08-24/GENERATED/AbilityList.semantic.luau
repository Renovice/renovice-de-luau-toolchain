-- RENOVICE_HASH_FIELD: CardFromArtifact
-- RENOVICE_HASH_FIELD: CreateList
-- RENOVICE_HASH_FIELD: DrawSeparator
-- RENOVICE_HASH_FIELD: GetAlignmentText
-- RENOVICE_HASH_FIELD: GetColor
-- RENOVICE_HASH_FIELD: GetLocForAction
-- RENOVICE_HASH_FIELD: GetVisibilityCenter
-- RENOVICE_HASH_FIELD: GetVisibilitySize
-- RENOVICE_HASH_FIELD: Round
-- RENOVICE_HASH_FIELD: SetItemInfoPopupRect
-- RENOVICE_HASH_FIELD: Ternary
local v23_0
local v23_1
local v23_2
local v23_3
local v23_4
local v23_5
local v23_6
local v23_7
local v23_8
local v23_9
local v23_10
local v23_11
local v23_12
local v23_13
local v23_14
local v23_15
local v23_16
local v23_17
local v23_18
local v23_19
local v23_20
local v23_21
local v23_22
local v23_23
local v23_24
local v23_25
local v23_26
local v23_27
local v23_28
local v23_29
local v23_30
local v23_31
local v23_32
local v23_33
local v23_34
local v23_35
local v23_36
local v23_37
local v23_38
local v23_39
local v23_40
local v23_41
local v23_42
local v23_43
local v23_44
local v23_45
local v23_46
local v23_47
local v23_48
local v23_49
local v23_50
local v23_51
v23_0 = module
v23_1 = (select(1, ...))
v23_2 = package.seeall
v23_0(v23_1, v23_2)
v23_3 = require
v23_5 = v23_3("Lotus.Interface.UIStyleUtilities")
v23_6 = require
v23_8 = v23_6("Lotus.Interface.UIUtilities")
v23_9 = require
v23_11 = v23_9("EE.Interface.Utilities")
v23_12 = require
v23_14 = v23_12("Lotus.Interface.CardUtilitiesRedux")
v23_15 = require
v23_17 = v23_15("Lotus.Interface.SyndicateUtilities")
v23_18 = require
v23_20 = v23_18("Lotus.Interface.BindingsUtil")
v23_21 = Resource
v23_23 = v23_21("/Lotus/Interface/Graphics/Arcanes/ArcaneGlow.png")
glowTexture = v23_23
v23_24 = Resource
v23_26 = v23_24("/Lotus/Interface/Materials/ThemedAbilitySpots")
sparklesMaterial = v23_26
v23_27 = Resource
v23_29 = v23_27("/Lotus/Interface/Materials/WarframeSelectVisibleRange")
visRangeMaterial = v23_29
v23_30 = Resource
v23_32 = v23_30("/Lotus/Interface/Materials/AbilitiesIconShadow")
shadowMaterial = v23_32
v23_33 = Resource
v23_35 = v23_33("/Lotus/Interface/Icons/Abilities/PassiveAbilityIcon.png")
passiveIcon = v23_35
v23_36 = {}
v23_37 = WeakResource
do
    local setlist_values_23_47 = table.pack(v23_37("/Lotus/Powersuits/Dragon/Abilities/DragonLuckAbility"))
    for setlist_index_23_47 = 1, setlist_values_23_47.n do
        v23_36[1 + setlist_index_23_47 - 1] = setlist_values_23_47[setlist_index_23_47]
    end
end
v23_44 = true
local cap_23_49_0 = v23_11
local cap_23_49_1 = v23_36
v23_45 = function(p0_0, p0_1, p0_2, p0_3, p0_4, p0_5, p0_6, p0_7, p0_8, p0_9)
    local frame_0 = {}
    local cfg_0 = 0
    while true do
        if cfg_0 == 0 then
            frame_0[10] = nil
            frame_0[11] = (p0_1 - 1)
            frame_0[12] = p0_3
            frame_0[13] = IsWeak
            frame_0[14] = p0_3
            frame_0[15] = frame_0[13](frame_0[14])
            if not (frame_0[15]) then
                cfg_0 = 2
            else
                cfg_0 = 1
            end
        elseif cfg_0 == 1 then
            frame_0[16] = Resource
            frame_0[17] = p0_3
            frame_0[18] = frame_0[16](frame_0[17])
            frame_0[12] = frame_0[18]
            cfg_0 = 2
        elseif cfg_0 == 2 then
            if not (p0_2) then
                cfg_0 = 4
            else
                cfg_0 = 3
            end
        elseif cfg_0 == 3 then
            frame_0[19] = frame_0[11]
            frame_0[22] = (frame_0[12]):Name__01f5c208(frame_0[19])
            if not (frame_0[22]) then
                cfg_0 = 24
            else
                cfg_0 = 4
            end
        elseif cfg_0 == 4 then
            frame_0[23] = nil
            frame_0[24] = p0_7
            frame_0[25] = IsNull
            frame_0[26] = frame_0[25](frame_0[24])
            if frame_0[26] then
                cfg_0 = 6
            else
                cfg_0 = 5
            end
        elseif cfg_0 == 5 then
            frame_0[27] = p0_7
            cfg_0 = 9
        elseif cfg_0 == 6 then
            if not (p0_4) then
                cfg_0 = 8
            else
                cfg_0 = 7
            end
        elseif cfg_0 == 7 then
            frame_0[28] = frame_0[11]
            frame_0[31] = (frame_0[12]):GetAbilityByIndex(frame_0[28])
            frame_0[27] = frame_0[31]
            cfg_0 = 9
        elseif cfg_0 == 8 then
            frame_0[32] = frame_0[11]
            frame_0[35] = (frame_0[12]):Name__06c22bff(frame_0[32])
            frame_0[27] = frame_0[35]
            cfg_0 = 9
        elseif cfg_0 == 9 then
            frame_0[36] = frame_0[27]
            frame_0[37] = IsNull
            frame_0[38] = frame_0[37](frame_0[36])
            if not (frame_0[38]) then
                cfg_0 = 11
            else
                cfg_0 = 10
            end
        elseif cfg_0 == 10 then
            return frame_0[10]
        elseif cfg_0 == 11 then
            frame_0[41] = (frame_0[12]):GetLevel()
            frame_0[42] = frame_0[11]
            frame_0[45] = (frame_0[12]):Name__5682bdb4(frame_0[42])
            frame_0[46] = nil
            if not (p0_9) then
                cfg_0 = 14
            else
                cfg_0 = 12
            end
        elseif cfg_0 == 12 then
            frame_0[49] = (frame_0[27]):Name__b92141d1()
            frame_0[50] = EMPTY_SYMBOL
            if frame_0[49] == frame_0[50] then
                cfg_0 = 14
            else
                cfg_0 = 13
            end
        elseif cfg_0 == 13 then
            frame_0[53] = (frame_0[27]):Name__b92141d1()
            frame_0[56] = (frame_0[53]):c_str()
            frame_0[60] = p0_0:GetLocalized(frame_0[56], true)
            frame_0[61] = frame_0[60]
            cfg_0 = 15
        elseif cfg_0 == 14 then
            frame_0[64] = (frame_0[27]):GetLocalizeDescTag()
            frame_0[67] = (frame_0[64]):c_str()
            frame_0[71] = p0_0:GetLocalized(frame_0[67], true)
            frame_0[61] = frame_0[71]
            cfg_0 = 15
        elseif cfg_0 == 15 then
            frame_0[72] = { IsAbility = true, CustomEntry = true, ForceOverrideDesc = nil, Suit = nil, AbilityIndex = nil, Resource = nil, Name = nil, LocalizedDesc = nil, Level = nil, Locked = nil, Icon = nil, IconColor = nil, Themed = nil, ModdedStats = nil, BaseOnly = nil, HideRankUp = nil }
            frame_0[72].ForceOverrideDesc = p0_9
            frame_0[72].Suit = p0_3
            frame_0[72].AbilityIndex = frame_0[11]
            frame_0[72].Resource = frame_0[27]
            frame_0[73] = string.upper
            frame_0[76] = (frame_0[27]):GetLocalizeTag()
            frame_0[79] = (frame_0[76]):c_str()
            frame_0[89] = frame_0[73](p0_0:GetLocalized(frame_0[79], false))
            frame_0[72].Name = frame_0[89]
            frame_0[72].LocalizedDesc = frame_0[61]
            frame_0[90] = frame_0[11]
            frame_0[93] = (frame_0[12]):GetAbilityLevel(frame_0[90])
            frame_0[94] = (frame_0[93] - 1)
            frame_0[72].Level = frame_0[94]
            if frame_0[41] < frame_0[45] then
                cfg_0 = 17
            else
                cfg_0 = 16
            end
        elseif cfg_0 == 16 then
            frame_0[95] = false
            cfg_0 = 18
        elseif cfg_0 == 17 then
            frame_0[95] = true
            cfg_0 = 18
        elseif cfg_0 == 18 then
            frame_0[72].Locked = frame_0[95]
            frame_0[98] = (frame_0[27]):GetIconTexture()
            frame_0[72].Icon = frame_0[98]
            frame_0[99] = cap_23_49_0
            frame_0[100] = (frame_0[99]).Ternary
            frame_0[103] = (frame_0[27]):TintIconToTheme()
            frame_0[106] = frame_0[100](frame_0[103], 6, nil)
            frame_0[72].IconColor = frame_0[106]
            frame_0[109] = (frame_0[27]):Name__a6ca7840()
            frame_0[110] = (not frame_0[109])
            frame_0[72].Themed = frame_0[110]
            frame_0[72].ModdedStats = p0_5
            frame_0[72].BaseOnly = p0_6
            frame_0[72].HideRankUp = p0_8
            frame_0[10] = frame_0[72]
            frame_0[111] = StringSplit
            frame_0[113] = frame_0[61]
            frame_0[114] = frame_0[111]("<br>", frame_0[113])
            frame_0[115] = (#frame_0[114])
            frame_0[116] = 1
            frame_0[117] = cap_23_49_1
            frame_0[118] = (#frame_0[117])
            frame_0[119] = 1
            local leave_for_0_19 = false
            for for_value_0_19 = frame_0[116], frame_0[118], frame_0[119] do
                frame_0[116] = for_value_0_19
                cfg_0 = 19
                while true do
                    if cfg_0 == 19 then
                        frame_0[120] = (frame_0[10]).Resource
                        frame_0[121] = cap_23_49_1
                        frame_0[122] = frame_0[121][frame_0[116]]
                        frame_0[125] = (frame_0[120]):IsA(frame_0[122])
                        if not (frame_0[125]) then
                            cfg_0 = 21
                        else
                            cfg_0 = 20
                        end
                    elseif cfg_0 == 20 then
                        frame_0[115] = (frame_0[115] + 1)
                        cfg_0 = 22
                        leave_for_0_19 = true
                        break
                    elseif cfg_0 == 21 then
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_0_19 then break end
            end
            if not leave_for_0_19 then
                cfg_0 = 22
            end
        elseif cfg_0 == 22 then
            if not (1 < frame_0[115]) then
                cfg_0 = 24
            else
                cfg_0 = 23
            end
        elseif cfg_0 == 23 then
            frame_0[10].NumItemPopupPages = frame_0[115]
            frame_0[10].SplitPerStatHeader = true
            cfg_0 = 24
        elseif cfg_0 == 24 then
            return frame_0[10]
        else
            error("invalid control state")
        end
    end
end
local cap_23_52_0 = v23_45
v23_46 = function(p1_0, p1_1, p1_2, p1_3, p1_4, p1_5, p1_6, p1_7, p1_8, p1_9)
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
    v1_10 = cap_23_52_0
    v1_11 = p1_0
    v1_12 = p1_1
    v1_13 = p1_2
    v1_14 = p1_3
    v1_15 = p1_4
    v1_16 = p1_5
    v1_17 = p1_6
    v1_18 = p1_7
    v1_19 = p1_8
    v1_20 = p1_9
    v1_21 = v1_10(v1_11, v1_12, v1_13, v1_14, v1_15, v1_16, v1_17, v1_18, v1_19, v1_20)
    return v1_21
end
GetElementForAbility = v23_46
v23_47 = function(p2_0, p2_1)
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
    local v2_26
    local v2_27
    local v2_28
    local v2_29
    local v2_30
    local v2_31
    local v2_32
    local v2_33
    local v2_34
    local v2_35
    local v2_36
    local v2_37
    v2_2 = p2_0
    v2_3 = IsNull
    v2_4 = v2_3(v2_2)
    if not (v2_4) then
        v2_5 = p2_1
        v2_6 = IsNull
        v2_7 = v2_6(v2_5)
        if not (v2_7) then
            v2_9 = p2_1
            v2_12 = p2_0:GetAugmentsForAbility(v2_9)
            v2_13 = {}
            v2_14 = gGameRules
            v2_17 = v2_14:GetStoreManifest()
            v2_18 = 1
            v2_19 = (#v2_12)
            v2_20 = 1
            for v2_18 = v2_18, v2_19, v2_20 do
                v2_21 = v2_12[v2_18]
                v2_22 = v2_17
                v2_23 = IsNull
                v2_24 = v2_23(v2_22)
                if v2_24 then
                    v2_35 = v2_13
                    v2_36 = v2_21
                    v2_37 = table.insert
                    v2_37(v2_35, v2_36)
                else
                    v2_25 = v2_21
                    v2_28 = v2_17:Name__1dc35bd2(v2_25)
                    v2_29 = v2_28
                    v2_30 = IsNull
                    v2_31 = v2_30(v2_29)
                    if not (v2_31) then
                        v2_32 = v2_13
                        v2_33 = v2_21
                        v2_34 = table.insert
                        v2_34(v2_32, v2_33)
                    end
                end
            end
            return v2_13
        end
    end
    v2_8 = {}
    return v2_8
end
local cap_23_56_0 = v23_47
v23_48 = function(p3_0, p3_1)
    local v3_2
    local v3_3
    local v3_4
    local v3_5
    v3_2 = cap_23_56_0
    v3_3 = p3_0
    v3_4 = p3_1
    v3_5 = v3_2(v3_3, v3_4)
    return v3_5
end
GetAugmentsForAbility = v23_48
local cap_23_59_0 = v23_47
local cap_23_59_1 = v23_14
local cap_23_59_2 = v23_17
v23_49 = function(p4_0, p4_1, p4_2, p4_3, p4_4, p4_5)
    local frame_4 = {}
    local cfg_4 = 0
    while true do
        if cfg_4 == 0 then
            frame_4[6] = p4_0
            frame_4[7] = IsNull
            frame_4[8] = frame_4[7](frame_4[6])
            if not (frame_4[8]) then
                cfg_4 = 2
            else
                cfg_4 = 1
            end
        elseif cfg_4 == 1 then
            return
        elseif cfg_4 == 2 then
            frame_4[11] = p4_1:GetFocusedElement()
            frame_4[12] = frame_4[11]
            frame_4[13] = IsNull
            frame_4[14] = frame_4[13](frame_4[12])
            if not (frame_4[14]) then
                cfg_4 = 4
            else
                cfg_4 = 3
            end
        elseif cfg_4 == 3 then
            return
        elseif cfg_4 == 4 then
            frame_4[15] = cap_23_59_0
            frame_4[16] = p4_2
            frame_4[17] = (frame_4[11]).Resource
            frame_4[18] = frame_4[15](frame_4[16], frame_4[17])
            frame_4[19] = (#frame_4[18])
            if frame_4[19] ~= 0 then
                cfg_4 = 6
            else
                cfg_4 = 5
            end
        elseif cfg_4 == 5 then
            return
        elseif cfg_4 == 6 then
            frame_4[20] = {}
            frame_4[21] = p4_5
            frame_4[22] = IsNull
            frame_4[23] = frame_4[22](frame_4[21])
            if frame_4[23] then
                cfg_4 = 8
            else
                cfg_4 = 7
            end
        elseif cfg_4 == 7 then
            frame_4[26] = p4_5:GetAlignments()
            frame_4[20] = frame_4[26]
            cfg_4 = 8
        elseif cfg_4 == 8 then
            frame_4[27] = {}
            frame_4[28] = 1
            frame_4[29] = (#frame_4[18])
            frame_4[30] = 1
            local leave_for_4_9 = false
            for for_value_4_9 = frame_4[28], frame_4[29], frame_4[30] do
                frame_4[28] = for_value_4_9
                cfg_4 = 9
                while true do
                    if cfg_4 == 9 then
                        frame_4[31] = Lotus_Game.UpgradeInfo
                        frame_4[32] = frame_4[31]()
                        frame_4[33] = WeakResource
                        frame_4[34] = frame_4[18][frame_4[28]]
                        frame_4[59] = frame_4[33]((frame_4[34]):GetFullName())
                        frame_4[32].mItemType = frame_4[59]
                        frame_4[60] = (frame_4[32]).mInstance
                        frame_4[61] = IsNull
                        frame_4[62] = frame_4[61](frame_4[60])
                        if frame_4[62] then
                            cfg_4 = 11
                        else
                            cfg_4 = 10
                        end
                    elseif cfg_4 == 10 then
                        frame_4[63] = (frame_4[32]).mInstance
                        frame_4[67] = (frame_4[63]):GetFusionLimit("")
                        frame_4[68] = (frame_4[32]).mInstance
                        frame_4[69] = frame_4[67]
                        frame_4[72] = (frame_4[68]):Name__65a6ff3f(frame_4[69])
                        frame_4[32].mUpgradeFingerprint = frame_4[72]
                        cfg_4 = 11
                    elseif cfg_4 == 11 then
                        frame_4[73] = cap_23_59_1
                        frame_4[74] = (frame_4[73]).CardFromArtifact
                        frame_4[75] = frame_4[32]
                        frame_4[76] = frame_4[28]
                        frame_4[77] = frame_4[74](frame_4[75], frame_4[76])
                        frame_4[78] = { Name = nil, LocalizedDesc = "", mModDescOverride = nil, Card = nil, Count = 1, HideOwned = true, OverrideCardCount = true }
                        frame_4[79] = (frame_4[77]).mName
                        frame_4[78].Name = frame_4[79]
                        frame_4[84] = p4_0:GetLocalized("/Lotus/Language/Syndicates/AugmentVendorDesc", false)
                        frame_4[78].mModDescOverride = frame_4[84]
                        frame_4[78].Card = frame_4[77]
                        frame_4[85] = (frame_4[32]).mItemType
                        frame_4[88] = p4_2:Name__5c62bf85(frame_4[85])
                        frame_4[89] = (#frame_4[88])
                        if not (0 < frame_4[89]) then
                            cfg_4 = 18
                        else
                            cfg_4 = 12
                        end
                    elseif cfg_4 == 12 then
                        frame_4[91] = {}
                        frame_4[78].Affiliations = frame_4[91]
                        frame_4[92] = 1
                        frame_4[93] = (#frame_4[88])
                        frame_4[94] = 1
                        local leave_for_4_13 = false
                        for for_value_4_13 = frame_4[92], frame_4[93], frame_4[94] do
                            frame_4[92] = for_value_4_13
                            cfg_4 = 13
                            while true do
                                if cfg_4 == 13 then
                                    frame_4[95] = Resource
                                    frame_4[96] = frame_4[88][frame_4[92]]
                                    frame_4[97] = frame_4[95](frame_4[96])
                                    frame_4[98] = 0
                                    frame_4[99] = 1
                                    frame_4[100] = (#frame_4[20])
                                    frame_4[101] = 1
                                    local leave_for_4_14 = false
                                    for for_value_4_14 = frame_4[99], frame_4[100], frame_4[101] do
                                        frame_4[99] = for_value_4_14
                                        cfg_4 = 14
                                        while true do
                                            if cfg_4 == 14 then
                                                frame_4[102] = frame_4[88][frame_4[92]]
                                                frame_4[103] = frame_4[20][frame_4[99]]
                                                frame_4[104] = (frame_4[103]).other
                                                if frame_4[102] ~= frame_4[104] then
                                                    cfg_4 = 16
                                                else
                                                    cfg_4 = 15
                                                end
                                            elseif cfg_4 == 15 then
                                                frame_4[105] = frame_4[20][frame_4[99]]
                                                frame_4[98] = (frame_4[105]).multiplier
                                                cfg_4 = 17
                                                leave_for_4_14 = true
                                                break
                                            elseif cfg_4 == 16 then
                                                break
                                            else
                                                error("invalid control state")
                                            end
                                        end
                                        if leave_for_4_14 then break end
                                    end
                                    if not leave_for_4_14 then
                                        cfg_4 = 17
                                    end
                                    if cfg_4 ~= 13 and cfg_4 ~= 17 then
                                        leave_for_4_13 = true
                                        break
                                    end
                                elseif cfg_4 == 17 then
                                    frame_4[107] = (p4_4).FloatingContentHighlightHex
                                    frame_4[109] = cap_23_59_2
                                    frame_4[110] = (frame_4[109]).GetAlignmentText
                                    frame_4[111] = p4_0
                                    frame_4[112] = frame_4[98]
                                    frame_4[115] = frame_4[110](frame_4[111], frame_4[112], true, true)
                                    frame_4[116] = frame_4[115]
                                    frame_4[118] = (p4_4).ContentHex
                                    frame_4[122] = (frame_4[97]):GetUIName()
                                    frame_4[125] = (frame_4[122]):c_str()
                                    frame_4[129] = p4_0:GetLocalized(frame_4[125], false)
                                    frame_4[130] = frame_4[129]
                                    frame_4[132] = ("<p><font color=\"" .. frame_4[107] .. "\">" .. frame_4[116] .. "<br><font color=\"" .. frame_4[118] .. "\">" .. frame_4[130] .. "</font></font></p>")
                                    frame_4[133] = (frame_4[78]).Affiliations
                                    frame_4[134] = { Label = nil, Icon = nil, RawModifier = nil, Level = 0 }
                                    frame_4[134].Label = frame_4[132]
                                    frame_4[137] = (frame_4[97]):GetIconTexture()
                                    frame_4[134].Icon = frame_4[137]
                                    frame_4[134].RawModifier = frame_4[98]
                                    frame_4[138] = table.insert
                                    frame_4[138](frame_4[133], frame_4[134])
                                    break
                                else
                                    error("invalid control state")
                                end
                            end
                            if leave_for_4_13 then break end
                        end
                        if not leave_for_4_13 then
                            cfg_4 = 18
                        end
                        if cfg_4 ~= 9 and cfg_4 ~= 10 and cfg_4 ~= 11 and cfg_4 ~= 12 and cfg_4 ~= 18 then
                            leave_for_4_9 = true
                            break
                        end
                    elseif cfg_4 == 18 then
                        frame_4[139] = frame_4[27]
                        frame_4[140] = frame_4[78]
                        frame_4[141] = table.insert
                        frame_4[141](frame_4[139], frame_4[140])
                        break
                    else
                        error("invalid control state")
                    end
                end
                if leave_for_4_9 then break end
            end
            if not leave_for_4_9 then
                cfg_4 = 19
            end
        elseif cfg_4 == 19 then
            frame_4[142] = _T
            frame_4[143] = { TITLE = nil, TIP = "", CANCEL_LABEL = "/Lotus/Language/Menu/Store_Close", HIDE_CONFIRM_BUTTON = true, SKIP_FILLER = nil, mITEMS = nil }
            frame_4[148] = p4_0:GetLocalized("/Lotus/Language/Alchemy/AbilityAugmentsTitle", false)
            frame_4[143].TITLE = frame_4[148]
            frame_4[149] = (#frame_4[18])
            if frame_4[149] == 1 then
                cfg_4 = 21
            else
                cfg_4 = 20
            end
        elseif cfg_4 == 20 then
            frame_4[150] = false
            cfg_4 = 22
        elseif cfg_4 == 21 then
            frame_4[150] = true
            cfg_4 = 22
        elseif cfg_4 == 22 then
            frame_4[143].SKIP_FILLER = frame_4[150]
            frame_4[143].mITEMS = frame_4[27]
            frame_4[142].Manifest = frame_4[143]
            frame_4[151] = p4_3
            return p4_0:PushChildMovie(frame_4[151])
        else
            error("invalid control state")
        end
    end
end
ShowAugmentsForAbility = v23_49
local cap_23_64_0 = v23_20
v23_50 = function(p5_0, p5_1)
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
    v5_2 = (p5_1).IsPassive
    if not (v5_2) then
        v5_3 = cap_23_64_0
        v5_4 = (v5_3).GetLocForAction
        v5_6 = (p5_1).AbilityIndex
        v5_7 = ("ABILITY_" .. v5_6)
        v5_11 = v5_4(v5_7, nil, true, true)
        v5_12 = (p5_1).mClipName
        v5_15 = v5_11
        p5_0:Name__f4a9016a(v5_12, "Binding", 36, p5_0:GetLocalized(v5_15, true))
        v5_25 = Engine.IsPlayingWithTouchscreen
        v5_26 = v5_25()
        if v5_26 then
            v5_27 = (p5_1).mClipName
            p5_0:Makeposshield(v5_27, "Binding", 13, false)
        end
        return
    else
        return
    end
end
local cap_23_66_0 = v23_11
local cap_23_66_1 = v23_45
local cap_23_66_2 = v23_8
local cap_23_66_3 = v23_5
local cap_23_66_5 = v23_50
v23_51 = function(p22_0, p22_1)
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
    local v22_29
    local v22_30
    local v22_31
    local v22_32
    local v22_33
    local v22_34
    local v22_35
    local v22_36
    local v22_37
    local v22_38
    local v22_39
    local v22_40
    local v22_41
    local v22_42
    local v22_43
    local v22_44
    local v22_45
    local v22_46
    local v22_47
    local v22_48
    local v22_49
    local v22_50
    local v22_51
    local v22_52
    local v22_53
    local v22_54
    local v22_55
    local v22_56
    local v22_57
    v22_2 = require
    v22_4 = v22_2("EE.Interface.Components.List")
    v22_5 = (v22_4).CreateList
    v22_6 = p22_0
    v22_7 = p22_1
    v22_9 = (v22_7 .. ".Ability")
    v22_10 = v22_5(v22_6, v22_9)
    v22_10:SetCallbacks("AbilityPressed", "AbilityFocused", "AbilityUnfocused")
    v22_10.mParentClipName = p22_1
    v22_10.mVisibleElements = 4
    v22_10.mForcedVerticalSeparation = 0
    v22_10.mForcedHorizontalSeparation = 220
    v22_10.mInitIconYPos = -45
    v22_10.mIconFocusOffset = 15
    v22_10.mIconHeight = 200
    v22_10.mGlowWidth = 600
    v22_10.mVisFadeSize = 0
    v22_10.mIconDim = 110
    v22_10.mPassiveIconDim = nil
    v22_10.mUnderlineWidthOffset = 0
    v22_10.mShowTitle = true
    v22_10.mShowRank = true
    v22_10.mShowBinding = true
    v22_10.mSimplePopup = false
    v22_10.mShowRankUp = true
    v22_32 = p22_1
    v22_34 = (v22_32 .. ".Ability.Title")
    v22_38 = p22_0:GetNumberVariable(v22_34, 1)
    v22_10.mTitleYPos = v22_38
    v22_39 = sparklesMaterial
    v22_10.mSparkleMaterial = v22_39
    v22_40 = { Loader = nil, IsLoading = false, StuffToLoad = nil }
    v22_41 = {}
    v22_40.StuffToLoad = v22_41
    v22_10.mIconLoader = v22_40
    v22_42 = { Base = nil, HiddenPassive = nil }
    v22_10.mHorizontalSeparationVars = v22_42
    v22_43 = { Height = nil, YPos = nil }
    v22_10.mButtonParamOverride = v22_43
    v22_10.mTipSoundOverride = nil
    v22_10.mPageSoundOverride = nil
    local cap_22_68_0 = v22_10
    v22_46 = function(p6_0)
        local v6_1
        local v6_2
        local v6_3
        local v6_4
        local v6_5
        local v6_6
        local v6_7
        local v6_8
        local v6_9
        local v6_10
        local v6_11
        local v6_12
        local v6_13
        local v6_14
        local v6_15
        local v6_16
        local v6_17
        local v6_18
        local v6_19
        local v6_20
        local v6_21
        local v6_22
        local v6_23
        local v6_24
        local v6_25
        local v6_26
        local v6_27
        local v6_28
        local v6_29
        local v6_30
        local v6_31
        local v6_32
        local v6_33
        local v6_34
        local v6_35
        local v6_36
        local v6_37
        local v6_38
        local v6_39
        local v6_40
        local v6_41
        local v6_42
        local v6_43
        local v6_44
        v6_1 = {}
        v6_2 = visRangeMaterial
        v6_3 = shadowMaterial
        v6_4 = cap_22_68_0
        v6_5 = (v6_4).mSparkleMaterial
        v6_1[1] = v6_2
        v6_1[2] = v6_3
        v6_1[3] = v6_5
        v6_6 = (p6_0).mMovie
        v6_7 = (p6_0).mParentClipName
        v6_11 = v6_6:GetNumberVariable(v6_7, 3)
        v6_12 = cap_23_66_0
        v6_13 = (v6_12).GetVisibilityCenter
        v6_14 = (p6_0).mMovie
        v6_15 = (p6_0).mIconHeight
        v6_16 = (v6_15 / 2)
        v6_17 = (v6_11 - v6_16)
        v6_18 = v6_13(v6_14, v6_17)
        v6_19 = cap_23_66_0
        v6_20 = (v6_19).GetVisibilitySize
        v6_21 = (p6_0).mMovie
        v6_22 = (p6_0).mIconHeight
        v6_23 = v6_20(v6_21, v6_22)
        v6_25 = v6_1
        for v6_43, v6_44 in ipairs(v6_25) do
            v6_29 = Lotus_Game.VISIBILITY_CENTER
            v6_30 = v6_18
            v6_44:SetParam(v6_29, v6_30)
            v6_33 = Lotus_Game.VISIBILITY_SIZE
            v6_34 = (p6_0).mVisFadeSize
            v6_35 = (v6_34 * 2)
            v6_36 = (v6_23 - v6_35)
            v6_44:SetParam(v6_33, v6_36)
            v6_39 = Lotus_Game.VISIBILITY_FADE_SIZE
            v6_40 = (p6_0).mVisFadeSize
            v6_44:SetParam(v6_39, v6_40)
        end
        return
    end
    v22_10.UpdateVisRanges = v22_46
    local cap_22_72_2 = v22_10
    v22_47 = function(p7_0, p7_1, p7_2, p7_3, p7_4, p7_5, p7_6, p7_7, p7_8)
        local frame_7 = {}
        p7_0:RemoveElements(true, true)
        frame_7[13] = p7_1
        frame_7[14] = IsWeak
        frame_7[15] = p7_1
        frame_7[16] = frame_7[14](frame_7[15])
        if frame_7[16] then
            frame_7[17] = Resource
            frame_7[18] = p7_1
            frame_7[19] = frame_7[17](frame_7[18])
            frame_7[13] = frame_7[19]
        end
        frame_7[20] = (p7_0).mShowPassive
        if frame_7[20] then
            frame_7[21] = _T
            frame_7[21].PassiveInfo = nil
            frame_7[23] = gRegion
            frame_7[26] = (frame_7[23]):GetLocalPlayerAvatar()
            frame_7[27] = frame_7[26]
            frame_7[28] = IsNull
            frame_7[29] = frame_7[28](frame_7[27])
            if not (frame_7[29]) then
                frame_7[32] = (frame_7[13]):GetOwnerSetScript()
                frame_7[33] = Symbol
                frame_7[35] = frame_7[33]("GetPassiveInfo")
                do (frame_7[26]):RunScript(frame_7[32], frame_7[35], false) end
            end
            frame_7[39] = { IsPassive = true, CustomEntry = true, Name = nil, LocalizedDesc = nil, Icon = nil, PreviewImage = nil }
            frame_7[40] = string.upper
            frame_7[41] = (p7_0).mMovie
            frame_7[58] = frame_7[40]((frame_7[41]):GetLocalized("/Lotus/Language/Menu/Ability_Passive", false))
            frame_7[39].Name = frame_7[58]
            frame_7[59] = (p7_0).mMovie
            frame_7[62] = (frame_7[13]):Name__7346ca05()
            frame_7[65] = (frame_7[62]):c_str()
            frame_7[67] = _T.PassiveInfo
            frame_7[70] = (frame_7[59]):GetLocalized(frame_7[65], true, frame_7[67])
            frame_7[39].LocalizedDesc = frame_7[70]
            frame_7[71] = passiveIcon
            frame_7[39].Icon = frame_7[71]
            frame_7[74] = (frame_7[13]):Name__33c3c4f7()
            frame_7[39].PreviewImage = frame_7[74]
            frame_7[75] = (frame_7[39]).LocalizedDesc
            if not (frame_7[75] == "") then
                frame_7[76] = frame_7[39]
                p7_0:AddElement(frame_7[76], true)
            end
            frame_7[80] = (p7_0).mHorizontalSeparationVars
            frame_7[81] = (frame_7[80]).Base
            if not (frame_7[81] == nil) then
                frame_7[82] = (p7_0).mHorizontalSeparationVars
                frame_7[83] = (frame_7[82]).HiddenPassive
                if not (frame_7[83] == nil) then
                    frame_7[84] = cap_23_66_0
                    frame_7[85] = (frame_7[84]).Ternary
                    frame_7[86] = (frame_7[39]).LocalizedDesc
                    if frame_7[86] ~= "" then
                        frame_7[87] = true
                    else
                        frame_7[87] = false
                    end
                    frame_7[88] = (p7_0).mHorizontalSeparationVars
                    frame_7[89] = (frame_7[88]).Base
                    frame_7[90] = (p7_0).mHorizontalSeparationVars
                    frame_7[91] = (frame_7[90]).HiddenPassive
                    frame_7[92] = frame_7[85](frame_7[87], frame_7[89], frame_7[91])
                    p7_0.mForcedHorizontalSeparation = frame_7[92]
                end
            end
        end
        frame_7[93] = {}
        frame_7[94] = 1
        frame_7[95] = 4
        frame_7[96] = 1
        for for_value_7_14 = frame_7[94], frame_7[95], frame_7[96] do
            frame_7[94] = for_value_7_14
            frame_7[97] = cap_23_66_1
            frame_7[98] = (p7_0).mMovie
            frame_7[99] = frame_7[94]
            frame_7[100] = p7_2
            frame_7[101] = p7_1
            frame_7[102] = p7_3
            frame_7[103] = p7_4
            frame_7[104] = p7_5
            frame_7[106] = (p7_0).mShowRankUp
            frame_7[107] = (not frame_7[106])
            frame_7[108] = frame_7[97](frame_7[98], frame_7[99], frame_7[100], frame_7[101], frame_7[102], frame_7[103], frame_7[104], nil, frame_7[107])
            if not (frame_7[108] == nil) then
                frame_7[109] = (frame_7[108]).LocalizedDesc
                if not (frame_7[109] == nil) then
                    frame_7[110] = (frame_7[108]).LocalizedDesc
                    if not (frame_7[110] == "") then
                        frame_7[111] = (frame_7[108]).Icon
                        frame_7[112] = IsNull
                        frame_7[113] = frame_7[112](frame_7[111])
                        if not (frame_7[113]) then
                            frame_7[114] = frame_7[93]
                            frame_7[115] = (frame_7[108]).Icon
                            frame_7[126] = table.insert
                            frame_7[126](frame_7[114], (frame_7[115]):GetFullName())
                        end
                        frame_7[127] = (p7_0).mSimplePopup
                        if frame_7[127] then
                            frame_7[108].IsAbility = false
                        end
                        if p7_8 then
                            frame_7[108].AreStatsBuried = true
                        end
                        frame_7[130] = frame_7[108]
                        p7_0:AddElement(frame_7[130], true)
                    end
                end
            end
        end
        if not (p7_6 == nil) then
            frame_7[134] = 1
            frame_7[135] = (#p7_6)
            frame_7[136] = 1
            for for_value_7_27 = frame_7[134], frame_7[135], frame_7[136] do
                frame_7[134] = for_value_7_27
                frame_7[137] = cap_23_66_1
                frame_7[138] = (p7_0).mMovie
                frame_7[140] = p7_2
                frame_7[141] = p7_1
                frame_7[142] = p7_3
                frame_7[143] = p7_4
                frame_7[144] = p7_5
                frame_7[145] = Resource
                frame_7[146] = p7_6[frame_7[134]]
                frame_7[147] = frame_7[145](frame_7[146])
                frame_7[148] = (p7_0).mShowRankUp
                frame_7[149] = (not frame_7[148])
                frame_7[150] = frame_7[137](frame_7[138], 1, frame_7[140], frame_7[141], frame_7[142], frame_7[143], frame_7[144], frame_7[147], frame_7[149])
                if not (frame_7[150] == nil) then
                    frame_7[151] = (frame_7[150]).Icon
                    frame_7[152] = IsNull
                    frame_7[153] = frame_7[152](frame_7[151])
                    if not (frame_7[153]) then
                        frame_7[154] = frame_7[93]
                        frame_7[155] = (frame_7[150]).Icon
                        frame_7[166] = table.insert
                        frame_7[166](frame_7[154], (frame_7[155]):GetFullName())
                    end
                    frame_7[167] = (p7_0).mSimplePopup
                    if frame_7[167] then
                        frame_7[150].IsAbility = false
                    end
                    frame_7[169] = frame_7[150]
                    p7_0:AddElement(frame_7[169], true)
                end
            end
        end
        frame_7[173] = false
        frame_7[174] = (#frame_7[93])
        if 0 < frame_7[174] then
            frame_7[176] = (#frame_7[93])
            frame_7[177] = cap_22_72_2
            frame_7[178] = (frame_7[177]).mIconLoader
            frame_7[179] = (frame_7[178]).StuffToLoad
            frame_7[180] = (#frame_7[179])
            if not (frame_7[176] ~= frame_7[180]) then
                frame_7[173] = true
                frame_7[181] = 1
                frame_7[182] = (#frame_7[93])
                frame_7[183] = 1
                for for_value_7_37 = frame_7[181], frame_7[182], frame_7[183] do
                    frame_7[181] = for_value_7_37
                    frame_7[184] = frame_7[93][frame_7[181]]
                    frame_7[185] = cap_22_72_2
                    frame_7[186] = (frame_7[185]).mIconLoader
                    frame_7[187] = (frame_7[186]).StuffToLoad
                    frame_7[188] = frame_7[187][frame_7[181]]
                    if not (frame_7[184] == frame_7[188]) then
                        frame_7[173] = false
                        break
                    end
                end
            end
        end
        if not (frame_7[173]) then
            frame_7[189] = cap_22_72_2
            frame_7[190] = (frame_7[189]).mIconLoader
            frame_7[190].IsLoading = false
            frame_7[192] = cap_22_72_2
            frame_7[193] = (frame_7[192]).mIconLoader
            frame_7[193].StuffToLoad = frame_7[93]
            frame_7[194] = cap_22_72_2
            frame_7[195] = (frame_7[194]).mIconLoader
            frame_7[196] = (frame_7[195]).StuffToLoad
            frame_7[197] = (#frame_7[196])
            if 0 < frame_7[197] then
                frame_7[199] = cap_22_72_2
                frame_7[200] = (frame_7[199]).mIconLoader
                frame_7[201] = UISys.ScriptResLoader_Create
                frame_7[202] = cap_22_72_2
                frame_7[203] = (frame_7[202]).mIconLoader
                frame_7[204] = (frame_7[203]).StuffToLoad
                frame_7[205] = frame_7[201](frame_7[204])
                frame_7[200].Loader = frame_7[205]
                frame_7[206] = cap_22_72_2
                frame_7[207] = (frame_7[206]).mIconLoader
                frame_7[207].IsLoading = true
            end
        end
        frame_7[209] = (p7_0).mSkipAbilityColorGet
        local bridge_7_43
        if frame_7[209] == nil then
            bridge_7_43 = true
        else
            frame_7[210] = (p7_0).mSkipAbilityColorGet
            bridge_7_43 = not (frame_7[210])
        end
        if bridge_7_43 then
            frame_7[211] = Color
            frame_7[212] = frame_7[211]()
            p7_0.mAbilityColor1 = frame_7[212]
            frame_7[213] = Color
            frame_7[214] = frame_7[213]()
            p7_0.mAbilityColor2 = frame_7[214]
            frame_7[215] = (p7_0).mAbilityColor1
            do (frame_7[13]):GetEnergyColor(frame_7[215]) end
            frame_7[218] = (p7_0).mAbilityColor2
            do (frame_7[13]):GetEnergyColor(frame_7[218], true) end
        end
        frame_7[222] = cap_22_72_2
        frame_7[223] = (frame_7[222]).mSparkleMaterial
        frame_7[224] = Symbol
        frame_7[226] = frame_7[224]("TintColor")
        frame_7[227] = (p7_0).mAbilityColor1
        frame_7[228] = (frame_7[227]).red
        frame_7[229] = (frame_7[228] / 255)
        frame_7[230] = (p7_0).mAbilityColor1
        frame_7[231] = (frame_7[230]).green
        frame_7[232] = (frame_7[231] / 255)
        frame_7[233] = (p7_0).mAbilityColor1
        frame_7[234] = (frame_7[233]).blue
        frame_7[235] = (frame_7[234] / 255)
        do (frame_7[223]):SetParam(frame_7[226], frame_7[229], frame_7[232], frame_7[235], 1) end
        frame_7[239] = cap_22_72_2
        frame_7[240] = (frame_7[239]).mSparkleMaterial
        frame_7[241] = Symbol
        frame_7[243] = frame_7[241]("GlowColor")
        frame_7[244] = (p7_0).mAbilityColor2
        frame_7[245] = (frame_7[244]).red
        frame_7[246] = (frame_7[245] / 128)
        frame_7[247] = (p7_0).mAbilityColor2
        frame_7[248] = (frame_7[247]).green
        frame_7[249] = (frame_7[248] / 128)
        frame_7[250] = (p7_0).mAbilityColor2
        frame_7[251] = (frame_7[250]).blue
        frame_7[252] = (frame_7[251] / 128)
        do (frame_7[240]):SetParam(frame_7[243], frame_7[246], frame_7[249], frame_7[252], 1) end
        frame_7[258] = p7_7
        p7_0:Redraw(nil, nil, frame_7[258])
        frame_7[261] = (p7_0).mForcedHorizontalSeparation
        frame_7[264] = p7_0:GetHowManyElements()
        frame_7[265] = (frame_7[261] * frame_7[264])
        frame_7[266] = (p7_0).mUnderlineWidthOffset
        frame_7[267] = (frame_7[265] + frame_7[266])
        frame_7[268] = (p7_0).mShowPassive
        if frame_7[268] then
            frame_7[267] = (frame_7[267] - 30)
        end
        frame_7[269] = cap_23_66_2
        frame_7[270] = (frame_7[269]).DrawSeparator
        frame_7[271] = (p7_0).mMovie
        frame_7[272] = (p7_0).mParentClipName
        frame_7[274] = (frame_7[272] .. ".Underline")
        frame_7[275] = frame_7[267]
        frame_7[270](frame_7[271], frame_7[274], frame_7[275])
        frame_7[276] = (p7_0).mMovie
        frame_7[277] = (p7_0).mParentClipName
        frame_7[280] = cap_23_66_3
        frame_7[281] = (frame_7[280]).GetColor
        do (frame_7[276]):Name__52c1b74e(frame_7[277], "Underline", 11, frame_7[281](9, true)) end
        frame_7[293] = (p7_0).VisibleRangeInfo
        if not (frame_7[293] == nil) then
            frame_7[294] = {}
            frame_7[294][1] = "UnderLine.Fill"
            frame_7[294][2] = "Underline.CapLeft"
            frame_7[294][3] = "Underline.CapRight"
            frame_7[299] = frame_7[294]
            for for_value_7_51_0, for_value_7_51_1 in pairs(frame_7[299]) do
                frame_7[312], frame_7[313] = for_value_7_51_0, for_value_7_51_1
                frame_7[303] = (p7_0).mMovie
                frame_7[304] = (p7_0).mParentClipName
                frame_7[306] = frame_7[313]
                frame_7[307] = (frame_7[304] .. "." .. frame_7[306])
                frame_7[308] = (p7_0).VisibleRangeInfo
                frame_7[309] = (frame_7[308]).BaseMaterial
                do (frame_7[303]):OverrideMaterial(frame_7[307], frame_7[309]) end
            end
        end
        return
    end
    v22_10.Populate = v22_47
    v22_48 = (v22_10).CalculateX
    v22_10.List_CalculateX = v22_48
    v22_49 = function(p8_0, p8_1)
        local v8_2
        local v8_3
        local v8_4
        local v8_5
        local v8_6
        local v8_7
        v8_2 = p8_1
        return p8_0:List_CalculateX(v8_2)
    end
    v22_10.CalculateX = v22_49
    local cap_22_83_0 = v22_10
    v22_50 = function(p10_0)
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
        local v10_19
        local v10_20
        local v10_21
        local v10_22
        local v10_23
        local v10_24
        local v10_25
        local v10_26
        local v10_27
        local v10_28
        local v10_29
        local v10_30
        local v10_31
        local v10_32
        local v10_33
        local v10_34
        local v10_35
        local v10_36
        local v10_37
        local v10_38
        local v10_39
        local v10_40
        local v10_41
        local v10_42
        local v10_43
        local v10_44
        local v10_45
        local v10_46
        local v10_47
        local v10_48
        local v10_49
        local v10_50
        local v10_51
        local v10_52
        local v10_53
        local v10_54
        local v10_55
        local v10_56
        local v10_57
        local v10_58
        local v10_59
        local v10_60
        local v10_61
        local v10_62
        local v10_63
        local v10_64
        local v10_65
        local v10_66
        local v10_67
        local v10_68
        local v10_69
        local v10_70
        local v10_71
        local v10_72
        local v10_73
        v10_1 = (p10_0).mClipName
        if v10_1 ~= nil then
            v10_2 = FlashInterpolate
            v10_3 = cap_22_83_0
            v10_4 = (v10_3).mMovie
            v10_5 = (p10_0).mClipName
            v10_7 = (v10_5 .. ".Icon")
            v10_9 = {}
            v10_9[1] = 1
            v10_11 = {}
            v10_12 = cap_22_83_0
            v10_13 = (v10_12).mInitIconYPos
            v10_14 = cap_22_83_0
            v10_15 = (v10_14).mIconFocusOffset
            v10_16 = (v10_13 - v10_15)
            v10_11[1] = v10_16
            v10_2(v10_4, v10_7, 2, v10_9, v10_11, 0.15)
            v10_18 = FlashInterpolate
            v10_19 = cap_22_83_0
            v10_20 = (v10_19).mMovie
            v10_21 = (p10_0).mClipName
            v10_23 = (v10_21 .. ".Glow")
            v10_25 = {}
            v10_25[1] = 12
            v10_27 = {}
            v10_27[1] = 100
            v10_18(v10_20, v10_23, 2, v10_25, v10_27, 0.25)
            v10_30 = cap_22_83_0
            local cap_10_38_0 = p10_0
            v10_31 = function(p9_0)
                local v9_1
                local v9_2
                local v9_3
                local v9_4
                local v9_5
                local v9_6
                local v9_7
                local v9_8
                local v9_9
                local v9_10
                local v9_11
                local v9_12
                local v9_13
                local v9_14
                local v9_15
                v9_1 = cap_10_38_0
                v9_2 = (v9_1).Id
                v9_3 = (p9_0).Id
                if not (v9_2 == v9_3) then
                    v9_4 = FlashInterpolate
                    v9_5 = cap_22_83_0
                    v9_6 = (v9_5).mMovie
                    v9_7 = (p9_0).mClipName
                    v9_9 = (v9_7 .. ".Glow")
                    v9_11 = {}
                    v9_11[1] = 12
                    v9_13 = {}
                    v9_13[1] = 0
                    v9_4(v9_6, v9_9, 2, v9_11, v9_13, 0.25)
                end
                return
            end
            v10_30:RunForAllElements(v10_31)
            v10_34 = cap_23_66_2
            v10_35 = (v10_34).SetItemInfoPopupRect
            v10_36 = cap_22_83_0
            v10_37 = (v10_36).mMovie
            v10_38 = p10_0
            v10_39 = cap_22_83_0
            v10_40 = (v10_39).mMovie
            v10_41 = (p10_0).mClipName
            v10_43 = (v10_41 .. ".Btn")
            v10_47 = v10_40:GetNumberVariable(v10_43, 2)
            v10_48 = cap_22_83_0
            v10_49 = (v10_48).mMovie
            v10_50 = (p10_0).mClipName
            v10_52 = (v10_50 .. ".Btn")
            v10_56 = v10_49:GetNumberVariable(v10_52, 3)
            v10_57 = cap_22_83_0
            v10_58 = (v10_57).mForcedHorizontalSeparation
            v10_59 = (v10_58 - 15)
            v10_60 = cap_22_83_0
            v10_61 = (v10_60).mForcedHorizontalSeparation
            v10_35(v10_37, v10_38, v10_47, v10_56, v10_59, v10_61)
            v10_62 = cap_22_83_0
            v10_63 = (v10_62).mTipSoundOverride
            p10_0.mTipSoundOverride = v10_63
            v10_64 = cap_22_83_0
            v10_65 = (v10_64).mPageSoundOverride
            p10_0.mPageSoundOverride = v10_65
            v10_66 = _T
            v10_67 = cap_22_83_0
            v10_66.InfoPopup_Grid = v10_67
            v10_68 = _T
            v10_68.InfoPopup_Data = p10_0
            v10_69 = cap_22_83_0
            v10_70 = p10_0
            v10_69:UpdateColors(v10_70, true)
            return
        else
            return
        end
    end
    v22_10.mOnFocusedCallback = v22_50
    local cap_22_87_0 = v22_10
    v22_51 = function(p12_0)
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
        local v12_16
        local v12_17
        local v12_18
        local v12_19
        local v12_20
        local v12_21
        local v12_22
        local v12_23
        local v12_24
        local v12_25
        local v12_26
        v12_1 = _T
        v12_1.InfoPopup_Grid = nil
        v12_3 = _T
        v12_3.InfoPopup_Data = nil
        v12_5 = FlashInterpolate
        v12_6 = cap_22_87_0
        v12_7 = (v12_6).mMovie
        v12_8 = (p12_0).mClipName
        v12_10 = (v12_8 .. ".Icon")
        v12_12 = {}
        v12_12[1] = 1
        v12_14 = {}
        v12_15 = cap_22_87_0
        v12_16 = (v12_15).mInitIconYPos
        v12_14[1] = v12_16
        v12_5(v12_7, v12_10, 2, v12_12, v12_14, 0.15)
        v12_18 = cap_22_87_0
        v12_19 = function(p11_0)
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
            v11_1 = FlashInterpolate
            v11_2 = cap_22_87_0
            v11_3 = (v11_2).mMovie
            v11_4 = (p11_0).mClipName
            v11_6 = (v11_4 .. ".Glow")
            v11_8 = {}
            v11_8[1] = 12
            v11_10 = {}
            v11_10[1] = 65
            v11_1(v11_3, v11_6, 2, v11_8, v11_10, 0.25)
            return
        end
        v12_18:RunForAllElements(v12_19)
        v12_22 = cap_22_87_0
        v12_23 = p12_0
        v12_22:UpdateColors(v12_23, false)
        return
    end
    v22_10.mOnUnfocusedCallback = v22_51
    v22_52 = function(p13_0)
        local v13_1
        v23_44 = true
        return
    end
    v22_10.OnGamepadTransition = v22_52
    local cap_22_93_2 = v22_10
    v22_53 = function(p16_0)
        local v16_1
        local v16_2
        local v16_3
        local v16_4
        local v16_5
        local v16_6
        local v16_7
        local v16_8
        local v16_9
        local v16_10
        local v16_11
        local v16_12
        local v16_13
        local v16_14
        local v16_15
        local v16_16
        local v16_17
        v16_1 = (p16_0).mIconLoader
        v16_2 = (v16_1).IsLoading
        if v16_2 then
            v16_3 = (p16_0).mIconLoader
            v16_4 = (v16_3).Loader
            v16_7 = v16_4:IsDone()
            if v16_7 then
                v16_8 = (p16_0).mIconLoader
                v16_8.IsLoading = false
                local cap_16_11_0 = p16_0
                v16_10 = function(p14_0)
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
                    local v14_13
                    v14_1 = (p14_0).IsPassive
                    if not (v14_1) then
                        v14_2 = cap_16_11_0
                        v14_3 = (v14_2).mMovie
                        v14_4 = (p14_0).mClipName
                        v14_3:Makeposshield(v14_4, "Icon", 13, true)
                        v14_10 = cap_16_11_0
                        v14_11 = p14_0
                        v14_10:SetIconForElement(v14_11)
                    end
                    return
                end
                p16_0:RunForAllElements(v16_10)
            end
        end
        v16_13 = v23_44
        if v16_13 then
            v23_44 = false
            v16_15 = function(p15_0)
                local v15_1
                local v15_2
                local v15_3
                local v15_4
                v15_1 = cap_23_66_5
                v15_2 = cap_22_93_2
                v15_3 = (v15_2).mMovie
                v15_4 = p15_0
                v15_1(v15_3, v15_4)
                return
            end
            p16_0:RunForAllElements(v16_15)
        end
        return
    end
    v22_10.Update = v22_53
    v22_54 = function(p17_0, p17_1, p17_2)
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
        local v17_14
        local v17_15
        local v17_16
        local v17_17
        local v17_18
        local v17_19
        local v17_20
        local v17_21
        local v17_22
        local v17_23
        local v17_24
        local v17_25
        local v17_26
        local v17_27
        local v17_28
        local v17_29
        local v17_30
        local v17_31
        local v17_32
        local v17_33
        local v17_34
        local v17_35
        local v17_36
        local v17_37
        local v17_38
        local v17_39
        local v17_40
        local v17_41
        local v17_42
        local v17_43
        local v17_44
        local v17_45
        local v17_46
        local v17_47
        local v17_48
        local v17_49
        local v17_50
        local v17_51
        local v17_52
        local v17_53
        local v17_54
        local v17_55
        local v17_56
        local v17_57
        local v17_58
        local v17_59
        local v17_60
        local v17_61
        local v17_62
        local v17_63
        local v17_64
        local v17_65
        local v17_66
        local v17_67
        local v17_68
        local v17_69
        local v17_70
        local v17_71
        local v17_72
        local v17_73
        local v17_74
        local v17_75
        local v17_76
        local v17_77
        local v17_78
        local v17_79
        local v17_80
        local v17_81
        local v17_82
        local v17_83
        local v17_84
        local v17_85
        local v17_86
        local v17_87
        local v17_88
        local v17_89
        local v17_90
        local v17_91
        local v17_92
        local v17_93
        local v17_94
        local v17_95
        local v17_96
        local v17_97
        local v17_98
        local v17_99
        local v17_100
        local v17_101
        local v17_102
        local v17_103
        local v17_104
        local v17_105
        local v17_106
        local v17_107
        local v17_108
        local v17_109
        local v17_110
        local v17_111
        local v17_112
        local v17_113
        local v17_114
        local v17_115
        local v17_116
        local v17_117
        local v17_118
        local v17_119
        local v17_120
        local v17_121
        local v17_122
        local v17_123
        v17_3 = cap_23_66_3
        v17_4 = (v17_3).GetColor
        v17_7 = v17_4(6, true)
        v17_8 = cap_23_66_3
        v17_9 = (v17_8).GetColor
        v17_12 = v17_9(9, true)
        v17_13 = cap_23_66_3
        v17_14 = (v17_13).GetColor
        v17_17 = v17_14(10, true)
        v17_18 = (p17_0).mAbilityColor1
        v17_21 = v17_18:GetUInt()
        v17_22 = (p17_0).mAbilityColor2
        v17_25 = v17_22:GetUInt()
        v17_26 = {}
        v17_26[1] = 0
        v17_26[2] = 3342336
        v17_26[3] = 8912896
        v17_26[4] = 12255232
        local bridge_17_0
        if not (p17_2) then
            bridge_17_0 = true
        else
            v17_31 = v17_17
            bridge_17_0 = not (v17_31)
        end
        if bridge_17_0 then
            v17_31 = v17_12
        end
        v17_32 = (p17_0).mMovie
        v17_33 = (p17_1).mClipName
        v17_36 = v17_12
        v17_32:Name__52c1b74e(v17_33, "Icon.Icon", 11, v17_36)
        v17_39 = (p17_0).mMovie
        v17_40 = (p17_1).mClipName
        v17_43 = v17_17
        v17_39:Name__52c1b74e(v17_40, "Glow", 11, v17_43)
        v17_46 = (p17_0).mMovie
        v17_47 = (p17_1).mClipName
        v17_50 = v17_21
        v17_46:Name__52c1b74e(v17_47, "Icon.Shadow", 11, v17_50)
        v17_53 = (p17_0).mMovie
        v17_54 = (p17_1).mClipName
        v17_56 = (v17_54 .. ".Icon.Shadow")
        v17_58 = (p17_0).mAbilityColor1
        v17_59 = (v17_58).red
        v17_60 = (v17_59 / 255)
        v17_61 = (p17_0).mAbilityColor1
        v17_62 = (v17_61).green
        v17_63 = (v17_62 / 255)
        v17_64 = (p17_0).mAbilityColor1
        v17_65 = (v17_64).blue
        v17_66 = (v17_65 / 255)
        v17_53:Name__e243d995(v17_56, "CheapGlowColor", v17_60, v17_63, v17_66, 1)
        v17_70 = (p17_0).mMovie
        v17_71 = (p17_1).mClipName
        v17_74 = v17_31
        v17_70:Name__52c1b74e(v17_71, "Title", 11, v17_74)
        v17_77 = (p17_0).mMovie
        v17_78 = (p17_1).mClipName
        v17_81 = v17_7
        v17_77:Name__52c1b74e(v17_78, "Rank", 11, v17_81)
        v17_84 = (p17_0).mMovie
        v17_85 = (p17_1).mClipName
        v17_88 = v17_31
        v17_84:Name__52c1b74e(v17_85, "Binding", 11, v17_88)
        v17_91 = (p17_0).mMovie
        v17_92 = (p17_1).mClipName
        v17_91:Name__52c1b74e(v17_92, "Gradient", 12, 0)
        v17_98 = (p17_0).mMovie
        v17_99 = (p17_1).mClipName
        v17_102 = v17_25
        v17_98:Name__52c1b74e(v17_99, "Highlight.StarburstOne", 11, v17_102)
        v17_105 = (p17_0).mMovie
        v17_106 = (p17_1).mClipName
        v17_109 = v17_21
        v17_105:Name__52c1b74e(v17_106, "Highlight.StarburstTwo", 11, v17_109)
        v17_112 = (p17_0).mMovie
        v17_113 = (p17_1).mClipName
        v17_117 = (p17_1).mIndex
        v17_118 = (#v17_26)
        v17_119 = (v17_117 % v17_118)
        v17_120 = (1 + v17_119)
        v17_121 = v17_26[v17_120]
        v17_112:Name__52c1b74e(v17_113, "Sparkles", 11, v17_121)
        return
    end
    v22_10.UpdateColors = v22_54
    v22_55 = function(p18_0, p18_1)
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
        v18_2 = Resource
        v18_3 = (p18_1).Icon
        v18_4 = v18_2(v18_3)
        v18_5 = (p18_0).mMovie
        v18_6 = (p18_1).mClipName
        v18_8 = (v18_6 .. ".Icon.Icon")
        v18_9 = v18_4
        v18_10 = visRangeMaterial
        v18_5:Name__9c27ee88(v18_8, v18_9, v18_10)
        v18_13 = (p18_0).mMovie
        v18_14 = (p18_1).mClipName
        v18_16 = (v18_14 .. ".Icon.Shadow")
        v18_17 = v18_4
        v18_18 = shadowMaterial
        v18_13:Name__9c27ee88(v18_16, v18_17, v18_18)
        return
    end
    v22_10.SetIconForElement = v22_55
    local cap_22_103_0 = v22_10
    v22_56 = function(p19_0)
        local frame_19 = {}
        frame_19[1] = (p19_0).mClipName
        if frame_19[1] ~= nil then
            frame_19[2] = cap_22_103_0
            frame_19[5] = (frame_19[2]):GetFocusedElement()
            frame_19[6] = frame_19[5]
            frame_19[7] = IsNull
            frame_19[8] = frame_19[7](frame_19[6])
            frame_19[9] = (not frame_19[8])
            if frame_19[9] then
                frame_19[10] = (frame_19[5]).Id
                frame_19[11] = (p19_0).Id
                if frame_19[10] == frame_19[11] then
                    frame_19[9] = true
                else
                    frame_19[9] = false
                end
            end
            frame_19[12] = cap_23_66_2
            frame_19[13] = (frame_19[12]).SetItemInfoPopupRect
            frame_19[14] = cap_22_103_0
            frame_19[15] = (frame_19[14]).mMovie
            frame_19[16] = p19_0
            frame_19[17] = cap_22_103_0
            frame_19[18] = (frame_19[17]).mMovie
            frame_19[19] = (p19_0).mClipName
            frame_19[21] = (frame_19[19] .. ".Btn")
            frame_19[25] = (frame_19[18]):GetNumberVariable(frame_19[21], 2)
            frame_19[26] = cap_22_103_0
            frame_19[27] = (frame_19[26]).mMovie
            frame_19[28] = (p19_0).mClipName
            frame_19[30] = (frame_19[28] .. ".Btn")
            frame_19[34] = (frame_19[27]):GetNumberVariable(frame_19[30], 3)
            frame_19[35] = cap_22_103_0
            frame_19[36] = (frame_19[35]).mForcedHorizontalSeparation
            frame_19[37] = (frame_19[36] - 15)
            frame_19[38] = cap_22_103_0
            frame_19[39] = (frame_19[38]).mForcedHorizontalSeparation
            frame_19[13](frame_19[15], frame_19[16], frame_19[25], frame_19[34], frame_19[37], frame_19[39])
            frame_19[40] = cap_22_103_0
            frame_19[41] = (frame_19[40]).mMovie
            frame_19[42] = (p19_0).mClipName
            frame_19[45] = cap_22_103_0
            frame_19[46] = (frame_19[45]).mShowTitle
            do (frame_19[41]):Makeposshield(frame_19[42], "Title", 13, frame_19[46]) end
            frame_19[49] = cap_22_103_0
            frame_19[50] = (frame_19[49]).mForcedHorizontalSeparation
            frame_19[51] = (frame_19[50] - 10)
            frame_19[52] = cap_22_103_0
            frame_19[53] = (frame_19[52]).mMovie
            frame_19[54] = (p19_0).mClipName
            frame_19[57] = frame_19[51]
            do (frame_19[53]):Name__52c1b74e(frame_19[54], "Title", 14, frame_19[57]) end
            frame_19[60] = cap_22_103_0
            frame_19[61] = (frame_19[60]).mMovie
            frame_19[62] = (p19_0).mClipName
            frame_19[65] = cap_23_66_0
            frame_19[66] = (frame_19[65]).Round
            frame_19[67] = (frame_19[51] / 2)
            frame_19[68] = frame_19[66](frame_19[67])
            frame_19[69] = (frame_19[68] - 2)
            frame_19[70] = (-frame_19[69])
            do (frame_19[61]):Name__52c1b74e(frame_19[62], "Title", 0, frame_19[70]) end
            frame_19[73] = cap_22_103_0
            frame_19[74] = (frame_19[73]).mMovie
            frame_19[75] = (p19_0).mClipName
            frame_19[78] = string.upper
            frame_19[79] = cap_22_103_0
            frame_19[80] = (frame_19[79]).mMovie
            frame_19[81] = (p19_0).Name
            do (frame_19[74]):Name__f4a9016a(frame_19[75], "Title", 36, frame_19[78]((frame_19[80]):GetLocalized(frame_19[81], true))) end
            frame_19[106] = cap_22_103_0
            frame_19[107] = (frame_19[106]).mMovie
            frame_19[108] = (p19_0).mClipName
            frame_19[113] = (frame_19[107]):Name__46690123(frame_19[108], "Title", 41)
            frame_19[114] = cap_22_103_0
            frame_19[115] = (frame_19[114]).mMovie
            frame_19[116] = (p19_0).mClipName
            frame_19[119] = cap_22_103_0
            frame_19[120] = (frame_19[119]).mTitleYPos
            frame_19[121] = (frame_19[120] + frame_19[113])
            frame_19[122] = (frame_19[121] + 3)
            do (frame_19[115]):Name__52c1b74e(frame_19[116], "Rank", 1, frame_19[122]) end
            frame_19[125] = cap_22_103_0
            frame_19[126] = (frame_19[125]).mMovie
            frame_19[127] = (p19_0).mClipName
            frame_19[130] = cap_22_103_0
            frame_19[131] = (frame_19[130]).mShowRank
            do (frame_19[126]):Makeposshield(frame_19[127], "Rank", 13, frame_19[131]) end
            frame_19[134] = (p19_0).Locked
            if not (frame_19[134]) then
                frame_19[166] = (p19_0).Level
                if frame_19[166] ~= 3 then
                    frame_19[198] = cap_22_103_0
                    frame_19[199] = (frame_19[198]).mMovie
                    frame_19[200] = (p19_0).mClipName
                    frame_19[203] = TitleCase
                    frame_19[204] = cap_22_103_0
                    frame_19[205] = (frame_19[204]).mMovie
                    frame_19[208] = { RANK = nil }
                    frame_19[209] = (p19_0).Level
                    frame_19[208].RANK = frame_19[209]
                    do (frame_19[199]):Name__f4a9016a(frame_19[200], "Rank", 36, frame_19[203]((frame_19[205]):GetLocalized("/Lotus/Language/Menu/Global_FormattedRankCaps", true, frame_19[208]))) end
                else
                    frame_19[167] = cap_22_103_0
                    frame_19[168] = (frame_19[167]).mMovie
                    frame_19[169] = (p19_0).mClipName
                    frame_19[172] = TitleCase
                    frame_19[173] = cap_22_103_0
                    frame_19[174] = (frame_19[173]).mMovie
                    do (frame_19[168]):Name__f4a9016a(frame_19[169], "Rank", 36, frame_19[172]((frame_19[174]):GetLocalized("/Lotus/Language/Ranks/MaxRank", true))) end
                end
            else
                frame_19[135] = cap_22_103_0
                frame_19[136] = (frame_19[135]).mMovie
                frame_19[137] = (p19_0).mClipName
                frame_19[140] = TitleCase
                frame_19[141] = cap_22_103_0
                frame_19[142] = (frame_19[141]).mMovie
                do (frame_19[136]):Name__f4a9016a(frame_19[137], "Rank", 36, frame_19[140]((frame_19[142]):GetLocalized("/Lotus/Language/Menu/FocusLocked", true))) end
            end
            frame_19[231] = cap_22_103_0
            frame_19[232] = (frame_19[231]).mShowRank
            if frame_19[232] then
                frame_19[233] = cap_22_103_0
                frame_19[234] = (frame_19[233]).mMovie
                frame_19[235] = (p19_0).mClipName
                frame_19[240] = (frame_19[234]):Name__46690123(frame_19[235], "Rank", 41)
                frame_19[241] = (frame_19[240] + 3)
                frame_19[113] = (frame_19[113] + frame_19[241])
            end
            frame_19[242] = cap_22_103_0
            frame_19[243] = (frame_19[242]).mMovie
            frame_19[244] = (p19_0).mClipName
            frame_19[247] = cap_22_103_0
            frame_19[248] = (frame_19[247]).mTitleYPos
            frame_19[249] = (frame_19[248] + frame_19[113])
            frame_19[250] = (frame_19[249] + 5)
            do (frame_19[243]):Name__52c1b74e(frame_19[244], "Binding", 1, frame_19[250]) end
            frame_19[253] = cap_22_103_0
            frame_19[254] = (frame_19[253]).mMovie
            frame_19[255] = (p19_0).mClipName
            frame_19[258] = cap_22_103_0
            frame_19[259] = (frame_19[258]).mShowBinding
            do (frame_19[254]):Makeposshield(frame_19[255], "Binding", 13, frame_19[259]) end
            frame_19[262] = cap_22_103_0
            frame_19[263] = (frame_19[262]).mShowBinding
            if frame_19[263] then
                frame_19[264] = cap_22_103_0
                frame_19[265] = (frame_19[264]).mMovie
                frame_19[266] = (p19_0).mClipName
                frame_19[271] = (frame_19[265]):Name__46690123(frame_19[266], "Binding", 41)
                frame_19[272] = (frame_19[271] + 5)
                frame_19[113] = (frame_19[113] + frame_19[272])
            end
            frame_19[273] = (frame_19[113] + 10)
            p19_0.mTextHeight = frame_19[273]
            frame_19[274] = cap_23_66_5
            frame_19[275] = cap_22_103_0
            frame_19[276] = (frame_19[275]).mMovie
            frame_19[277] = p19_0
            frame_19[274](frame_19[276], frame_19[277])
            frame_19[278] = (p19_0).IsPassive
            if not (frame_19[278]) then
                frame_19[279] = cap_22_103_0
                frame_19[280] = (frame_19[279]).mIconLoader
                frame_19[281] = (frame_19[280]).Loader
                frame_19[282] = IsNull
                frame_19[283] = frame_19[282](frame_19[281])
                frame_19[278] = (not frame_19[283])
                if frame_19[278] then
                    frame_19[284] = cap_22_103_0
                    frame_19[285] = (frame_19[284]).mIconLoader
                    frame_19[286] = (frame_19[285]).IsLoading
                    frame_19[278] = (not frame_19[286])
                end
            end
            frame_19[287] = cap_22_103_0
            frame_19[288] = (frame_19[287]).mMovie
            frame_19[289] = (p19_0).mClipName
            frame_19[292] = frame_19[278]
            do (frame_19[288]):Makeposshield(frame_19[289], "Icon", 13, frame_19[292]) end
            if frame_19[278] then
                frame_19[295] = cap_22_103_0
                frame_19[296] = p19_0
                do (frame_19[295]):SetIconForElement(frame_19[296]) end
            end
            frame_19[299] = cap_22_103_0
            frame_19[300] = (frame_19[299]).mIconDim
            frame_19[301] = (p19_0).IsPassive
            if frame_19[301] then
                frame_19[302] = cap_22_103_0
                frame_19[303] = (frame_19[302]).mPassiveIconDim
                frame_19[304] = IsNull
                frame_19[305] = frame_19[304](frame_19[303])
                if not (frame_19[305]) then
                    frame_19[306] = cap_22_103_0
                    frame_19[300] = (frame_19[306]).mPassiveIconDim
                end
            end
            frame_19[307] = cap_22_103_0
            frame_19[308] = (frame_19[307]).mMovie
            frame_19[309] = (p19_0).mClipName
            frame_19[312] = frame_19[300]
            do (frame_19[308]):Name__52c1b74e(frame_19[309], "Icon", 14, frame_19[312]) end
            frame_19[315] = cap_22_103_0
            frame_19[316] = (frame_19[315]).mMovie
            frame_19[317] = (p19_0).mClipName
            frame_19[320] = frame_19[300]
            do (frame_19[316]):Name__52c1b74e(frame_19[317], "Icon", 15, frame_19[320]) end
            frame_19[323] = cap_22_103_0
            frame_19[324] = (frame_19[323]).mMovie
            frame_19[325] = (p19_0).mClipName
            frame_19[328] = cap_22_103_0
            frame_19[329] = (frame_19[328]).mInitIconYPos
            do (frame_19[324]):Name__52c1b74e(frame_19[325], "Icon", 1, frame_19[329]) end
            frame_19[332] = cap_22_103_0
            frame_19[333] = (frame_19[332]).mMovie
            frame_19[334] = (p19_0).mClipName
            do (frame_19[333]):Makeposshield(frame_19[334], "Icon.Shadow", 13, false) end
            frame_19[340] = cap_22_103_0
            frame_19[341] = (frame_19[340]).mMovie
            frame_19[342] = (p19_0).mClipName
            frame_19[344] = (frame_19[342] .. ".Glow")
            frame_19[345] = glowTexture
            do (frame_19[341]):OverrideTexture(frame_19[344], frame_19[345]) end
            frame_19[348] = cap_22_103_0
            frame_19[349] = (frame_19[348]).mMovie
            frame_19[350] = (p19_0).mClipName
            frame_19[352] = (frame_19[350] .. ".Sparkles")
            frame_19[353] = cap_22_103_0
            frame_19[354] = (frame_19[353]).mSparkleMaterial
            do (frame_19[349]):OverrideMaterial(frame_19[352], frame_19[354]) end
            frame_19[357] = cap_22_103_0
            frame_19[358] = (frame_19[357]).mMovie
            frame_19[359] = (p19_0).mClipName
            frame_19[362] = cap_22_103_0
            frame_19[363] = (frame_19[362]).mGlowWidth
            do (frame_19[358]):Name__52c1b74e(frame_19[359], "Glow", 14, frame_19[363]) end
            frame_19[366] = cap_22_103_0
            frame_19[367] = (frame_19[366]).mMovie
            frame_19[368] = (p19_0).mClipName
            do (frame_19[367]):Name__52c1b74e(frame_19[368], "Glow", 12, 65) end
            frame_19[374] = cap_22_103_0
            frame_19[375] = (frame_19[374]).mButtonParamOverride
            frame_19[376] = (frame_19[375]).Height
            if not (frame_19[376] == nil) then
                frame_19[377] = cap_22_103_0
                frame_19[378] = (frame_19[377]).mMovie
                frame_19[379] = (p19_0).mClipName
                frame_19[382] = cap_22_103_0
                frame_19[383] = (frame_19[382]).mButtonParamOverride
                frame_19[384] = (frame_19[383]).Height
                do (frame_19[378]):Name__52c1b74e(frame_19[379], "Btn", 15, frame_19[384]) end
            end
            frame_19[387] = cap_22_103_0
            frame_19[388] = (frame_19[387]).mButtonParamOverride
            frame_19[389] = (frame_19[388]).YPos
            if not (frame_19[389] == nil) then
                frame_19[390] = cap_22_103_0
                frame_19[391] = (frame_19[390]).mMovie
                frame_19[392] = (p19_0).mClipName
                frame_19[395] = cap_22_103_0
                frame_19[396] = (frame_19[395]).mButtonParamOverride
                frame_19[397] = (frame_19[396]).YPos
                do (frame_19[391]):Name__52c1b74e(frame_19[392], "Btn", 1, frame_19[397]) end
            end
            frame_19[400] = cap_22_103_0
            frame_19[401] = (frame_19[400]).VisibleRangeInfo
            if not (frame_19[401] == nil) then
                frame_19[402] = {}
                frame_19[402][1] = "Icon.Icon"
                frame_19[402][2] = "Glow"
                frame_19[402][3] = "Highlight.StarburstOne.StarburstOne"
                frame_19[402][4] = "Highlight.StarburstTwo.StarburstTwo"
                frame_19[408] = frame_19[402]
                for for_value_19_30_0, for_value_19_30_1 in pairs(frame_19[408]) do
                    frame_19[423], frame_19[424] = for_value_19_30_0, for_value_19_30_1
                    frame_19[412] = cap_22_103_0
                    frame_19[413] = (frame_19[412]).mMovie
                    frame_19[414] = (p19_0).mClipName
                    frame_19[416] = frame_19[424]
                    frame_19[417] = (frame_19[414] .. "." .. frame_19[416])
                    frame_19[418] = cap_22_103_0
                    frame_19[419] = (frame_19[418]).VisibleRangeInfo
                    frame_19[420] = (frame_19[419]).BaseMaterial
                    do (frame_19[413]):OverrideMaterial(frame_19[417], frame_19[420]) end
                end
            end
            frame_19[425] = cap_22_103_0
            frame_19[426] = p19_0
            frame_19[427] = frame_19[9]
            do (frame_19[425]):UpdateColors(frame_19[426], frame_19[427]) end
            return
        else
            return
        end
    end
    v22_10.mElementDrawCallback = v22_56
    v22_57 = function(p21_0, p21_1)
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
        local v21_19
        local v21_20
        local v21_21
        local v21_22
        local v21_23
        local v21_24
        local v21_25
        local v21_26
        local v21_27
        local v21_28
        local v21_29
        local v21_30
        local v21_31
        local v21_32
        local v21_33
        local v21_34
        local v21_35
        local v21_36
        local v21_37
        local v21_38
        local v21_39
        local v21_40
        local v21_41
        local v21_42
        local v21_43
        local v21_44
        local v21_45
        local v21_46
        local v21_47
        local v21_48
        local v21_49
        local v21_50
        local v21_51
        v21_2 = Color
        v21_3 = v21_2()
        p21_0.mAbilityColor1 = v21_3
        v21_4 = Color
        v21_5 = v21_4()
        p21_0.mAbilityColor2 = v21_5
        v21_6 = (p21_0).mAbilityColor1
        p21_1:GetEnergyColor(v21_6)
        v21_9 = (p21_0).mAbilityColor2
        p21_1:GetEnergyColor(v21_9, true)
        v21_13 = (p21_0).mSparkleMaterial
        v21_14 = Symbol
        v21_16 = v21_14("TintColor")
        v21_17 = (p21_0).mAbilityColor1
        v21_18 = (v21_17).red
        v21_19 = (v21_18 / 255)
        v21_20 = (p21_0).mAbilityColor1
        v21_21 = (v21_20).green
        v21_22 = (v21_21 / 255)
        v21_23 = (p21_0).mAbilityColor1
        v21_24 = (v21_23).blue
        v21_25 = (v21_24 / 255)
        v21_13:SetParam(v21_16, v21_19, v21_22, v21_25, 1)
        v21_29 = (p21_0).mSparkleMaterial
        v21_30 = Symbol
        v21_32 = v21_30("GlowColor")
        v21_33 = (p21_0).mAbilityColor2
        v21_34 = (v21_33).red
        v21_35 = (v21_34 / 128)
        v21_36 = (p21_0).mAbilityColor2
        v21_37 = (v21_36).green
        v21_38 = (v21_37 / 128)
        v21_39 = (p21_0).mAbilityColor2
        v21_40 = (v21_39).blue
        v21_41 = (v21_40 / 128)
        v21_29:SetParam(v21_32, v21_35, v21_38, v21_41, 1)
        local cap_21_45_0 = p21_0
        v21_45 = function(p20_0)
            local v20_1
            local v20_2
            local v20_3
            local v20_4
            local v20_5
            v20_1 = cap_21_45_0
            v20_2 = p20_0
            v20_1:UpdateColors(v20_2, false)
            return
        end
        p21_0:RunForAllElements(v21_45)
        p21_0:Redraw(nil, nil)
        return
    end
    v22_10.UpdateMaterialColorFromSuitRes = v22_57
    return v22_10
end
Create = v23_51
return
