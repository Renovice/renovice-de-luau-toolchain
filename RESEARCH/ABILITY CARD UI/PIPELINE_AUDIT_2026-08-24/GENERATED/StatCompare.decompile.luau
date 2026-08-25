function proto_0(v0)
  local v1
  v1 = true
  if v0 ~= nil then
    if v0 ~= "" then
      v1 = false
    else
      v1 = true
    end
  end
  do return v1 end
end
function proto_1(v0, v1)
  do return end
end

function proto_2(v0)
  local v1, v2, v3
  v1 = string.format
  v2 = "%x"
  v3 = u0
  v3 = v3.PreviousStatColor
  v1 = v1(v2, v3)
  do return v1 end
end

function proto_3(v0, v1, v2)
  local v3, v4, v5, v6, v8, v9, v10, v11
  v3 = u0
  v3 = v3.GetPreviousStatColor
  v3 = v3()
  v4 = true
  if v1 ~= nil then
    v4 = true
    if v2 ~= nil then
      v4 = v0.TextOnly
    end
  end
  if v1 == nil then
    if v1 <= v2 then
      v5 = false
    else
      v5 = true
    end
    v6 = v0.SmallerIsBetter
    if v6 then
      if v2 <= v1 then
        v5 = false
      else
        v5 = true
      end
    end
    v6 = u1
    v6 = v6.Ternary
    v8 = string.format
    v9 = "%x"
    v10 = u0
    v10 = v10.StatDecreasedColor
    v8 = v8(v9, v10)
    v9 = string.format
    v10 = "%x"
    v11 = u0
    v11 = v11.StatIncreasedColor
    v3 = v6(v5, v8, v9(v10, v11))
  end
  do return v3 end
end

function proto_4(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v26, v27, v28
  local p118 = 0
  if p118 == 0 then
    v1 = v0.Label
    if v1 == nil then
      p118 = 4
    else
      p118 = 1
    end
  end
  if p118 == 1 then
    v2 = u0
    v2 = v2.TitleCase
    if not v2 then
      p118 = 4
    else
      p118 = 2
    end
  end
  if p118 == 2 then
    v2 = v0.Title
    if v2 then
      p118 = 4
    else
      p118 = 3
    end
  end
  if p118 == 3 then
    v2 = TitleCase
    v1 = v2(v1)
    p118 = 4
  end
  if p118 == 4 then
    v2 = u0
    v2 = v2.mMovie
    v5 = v0.mClipName
    v6 = ".Label"
    v4 = v5 .. v6
    v5 = 36
    v2:SetStringVariable(v4, v5, v1)
    v2 = u0
    v2 = v2.mMovie
    v5 = v0.mClipName
    v6 = ".Label"
    v4 = v5 .. v6
    v5 = _G
    v5 = v5.UIMaterial_PlainText
    v2:OverrideMaterial(v4, v5)
    v2 = u0
    v2 = v2.mMovie
    v4 = v0.mClipName
    v5 = "Label"
    v6 = 44
    v7 = u0
    v7 = v7.LabelColor
    v2:Name__52c1b74e(v4, v5, v6, v7)
    v2 = u0
    v2 = v2.mMovie
    v5 = v0.mClipName
    v6 = ".NewValue"
    v4 = v5 .. v6
    v5 = _G
    v5 = v5.UIMaterial_PlainText
    v2:OverrideMaterial(v4, v5)
    v2 = u1
    v2 = v2.Ternary
    v4 = u0
    v4 = v4.LabelAlpha
    if v4 ~= nil then
      p118 = 6
    else
      p118 = 5
    end
  end
  if p118 == 5 then
    v3 = false
    p118 = 7
  end
  if p118 == 6 then
    v3 = true
    p118 = 7
  end
  if p118 == 7 then
    v4 = u0
    v4 = v4.LabelAlpha
    v5 = 100
    v2 = v2(v3, v4, v5)
    v3 = 100
    v4 = u0
    v4 = v4.StatAltAlphaOffset
    if v4 == nil then
      p118 = 10
    else
      p118 = 8
    end
  end
  if p118 == 8 then
    v5 = v0.mIndex
    v4 = v5 % 2
    if v4 ~= 0 then
      p118 = 10
    else
      p118 = 9
    end
  end
  if p118 == 9 then
    v4 = u0
    v4 = v4.StatAltAlphaOffset
    v2 = v2 + v4
    v4 = u0
    v4 = v4.StatAltAlphaOffset
    v3 = v3 + v4
    p118 = 10
  end
  if p118 == 10 then
    v4 = u0
    v4 = v4.mMovie
    v6 = v0.mClipName
    v7 = "Label"
    v8 = 12
    v4:Name__52c1b74e(v6, v7, v8, v2)
    v4 = u0
    v4 = v4.mMovie
    v6 = v0.mClipName
    v7 = "NewValue"
    v8 = 12
    v4:Name__52c1b74e(v6, v7, v8, v3)
    v5 = u0
    v5 = v5.StatBgColor
    if v5 ~= nil then
      p118 = 12
    else
      p118 = 11
    end
  end
  if p118 == 11 then
    v4 = false
    p118 = 13
  end
  if p118 == 12 then
    v4 = true
    p118 = 13
  end
  if p118 == 13 then
    v5 = u0
    v5 = v5.mMovie
    v7 = v0.mClipName
    v8 = "Bg"
    v9 = 13
    v5:Makeposshield(v7, v8, v9, v4)
    if not v4 then
      p118 = 18
    else
      p118 = 14
    end
  end
  if p118 == 14 then
    v5 = u0
    v5 = v5.mMovie
    v7 = v0.mClipName
    v8 = "Bg"
    v9 = 11
    v10 = u0
    v10 = v10.StatBgColor
    v5:Name__52c1b74e(v7, v8, v9, v10)
    v5 = u0
    v5 = v5.mMovie
    v7 = v0.mClipName
    v8 = "Bg"
    v9 = 12
    v10 = u1
    v10 = v10.Ternary
    v13 = v0.mIndex
    v12 = v13 % 2
    if v12 ~= 0 then
      p118 = 16
    else
      p118 = 15
    end
  end
  if p118 == 15 then
    v11 = false
    p118 = 17
  end
  if p118 == 16 then
    v11 = true
    p118 = 17
  end
  if p118 == 17 then
    v12 = u0
    v12 = v12.StatBgAlpha
    v13 = 0
    v5:Name__52c1b74e(v7, v8, v9, v10(v11, v12, v13))
    p118 = 18
  end
  if p118 == 18 then
    v5 = u0
    v5 = v5.mMovie
    v8 = v0.mClipName
    v9 = ".Label"
    v7 = v8 .. v9
    v8 = 52
    v5 = v5:Name__9d78ed52(v7, v8)
    if not v5 then
      p118 = 20
    else
      p118 = 19
    end
  end
  if p118 == 19 then
    v6 = u0
    v6 = v6.mMovie
    v9 = v0.mClipName
    v10 = ".Label"
    v8 = v9 .. v10
    v9 = 41
    v6 = v6:GetNumberVariable(v8, v9)
    v7 = u0
    v7 = v7.mMovie
    v9 = v0.mClipName
    v10 = "NewValue"
    v11 = 1
    v13 = v6 / 2
    v12 = v13 - 9
    v7:Name__52c1b74e(v9, v10, v11, v12)
    v7 = u0
    v7 = v7.mMovie
    v9 = v0.mClipName
    v10 = "Line"
    v11 = 1
    v12 = v6 + 7
    v7:Name__52c1b74e(v9, v10, v11, v12)
    p118 = 20
  end
  if p118 == 20 then
    v6 = u0
    v6 = v6.mMovie
    v8 = v0.mClipName
    v9 = "Line"
    v10 = 15
    v11 = 2.5
    v6:Name__52c1b74e(v8, v9, v10, v11)
    v6 = u0
    v6 = v6.mMovie
    v9 = v0.mClipName
    v10 = ".Line"
    v8 = v9 .. v10
    v9 = _G
    v9 = v9.UIMaterial_SmoothEdgeNoDepthTest
    v6:OverrideMaterial(v8, v9)
    v6 = u1
    v6 = v6.Ternary
    v8 = v0.ValueUnit
    v7 = IsNull
    v7 = v7(v8)
    v8 = ""
    v9 = v0.ValueUnit
    v6 = v6(v7, v8, v9)
    v7 = ""
    v8 = v0.Previous
    if v8 == nil then
      p118 = 23
    else
      p118 = 21
    end
  end
  if p118 == 21 then
    v8 = v0.Previous
    v8 = v8.StatValue
    if v8 ~= nil then
      p118 = 26
    else
      p118 = 22
    end
  end
  if p118 == 22 then
    v8 = v0.Previous
    v8 = v8.DisplayValue
    if v8 ~= nil then
      p118 = 26
    else
      p118 = 23
    end
  end
  if p118 == 23 then
    v8 = v0.TextOnly
    if not v8 then
      p118 = 25
    else
      p118 = 24
    end
  end
  if p118 == 24 then
    v8 = { StatValue = 0, DisplayValue = nil }
    v9 = u0
    v9 = v9.mMovie
    v11 = "/Lotus/Language/Menu/Arsenal_Zero"
    v12 = false
    v9 = v9:GetLocalized(v11, v12)
    v8.DisplayValue = v9
    v0.Previous = v8
    p118 = 28
  end
  if p118 == 25 then
    v8 = { StatValue = 0, DisplayValue = "0" }
    v0.Previous = v8
    p118 = 28
  end
  if p118 == 26 then
    v8 = v0.Previous
    v8 = v8.DisplayValue
    if v8 ~= nil then
      p118 = 28
    else
      p118 = 27
    end
  end
  if p118 == 27 then
    v8 = v0.Previous
    v9 = u1
    v9 = v9.FormatNumber
    v10 = v0.Previous
    v10 = v10.StatValue
    v11 = 0
    v12 = false
    v9 = v9(v10, v11, v12)
    v8.DisplayValue = v9
    p118 = 28
  end
  if p118 == 28 then
    v8 = v0.Current
    if v8 == nil then
      p118 = 31
    else
      p118 = 29
    end
  end
  if p118 == 29 then
    v8 = v0.Current
    v8 = v8.StatValue
    if v8 ~= nil then
      p118 = 34
    else
      p118 = 30
    end
  end
  if p118 == 30 then
    v8 = v0.Current
    v8 = v8.DisplayValue
    if v8 ~= nil then
      p118 = 34
    else
      p118 = 31
    end
  end
  if p118 == 31 then
    v8 = v0.TextOnly
    if not v8 then
      p118 = 33
    else
      p118 = 32
    end
  end
  if p118 == 32 then
    v8 = { StatValue = 0, DisplayValue = nil }
    v9 = u0
    v9 = v9.mMovie
    v11 = "/Lotus/Language/Menu/Arsenal_Zero"
    v12 = false
    v9 = v9:GetLocalized(v11, v12)
    v8.DisplayValue = v9
    v0.Current = v8
    p118 = 36
  end
  if p118 == 33 then
    v8 = { StatValue = 0, DisplayValue = "0" }
    v0.Current = v8
    p118 = 36
  end
  if p118 == 34 then
    v8 = v0.Current
    v8 = v8.DisplayValue
    if v8 ~= nil then
      p118 = 36
    else
      p118 = 35
    end
  end
  if p118 == 35 then
    v8 = v0.Current
    v9 = u1
    v9 = v9.FormatNumber
    v10 = v0.Current
    v10 = v10.StatValue
    v11 = 0
    v12 = false
    v9 = v9(v10, v11, v12)
    v8.DisplayValue = v9
    p118 = 36
  end
  if p118 == 36 then
    v8 = u0
    v8 = v8.GetPreviousStatColor
    v8 = v8(v0)
    v9 = ""
    if v6 == "" then
      p118 = 40
    else
      p118 = 37
    end
  end
  if p118 == 37 then
    v10 = u0
    v10 = v10.mMovie
    v13 = true
    v14 = { COUNT = nil }
    v15 = v0.Previous
    v15 = v15.DisplayValue
    v14.COUNT = v15
    v7 = v10:GetLocalized(v6, v13, v14)
    v10 = u0
    v10 = v10.TitleCase
    if not v10 then
      p118 = 39
    else
      p118 = 38
    end
  end
  if p118 == 38 then
    v10 = TitleCase
    v7 = v10(v7)
    p118 = 39
  end
  if p118 == 39 then
    v10 = "<p><font color=\"#"
    v12 = "\">"
    v14 = "</font>"
    v9 = v10 .. v8 .. v12 .. v7 .. v14
    p118 = 41
  end
  if p118 == 40 then
    v10 = "<p><font color=\"#"
    v12 = "\">"
    v15 = u1
    v15 = v15.Ternary
    v16 = u0
    v16 = v16.TitleCase
    v17 = TitleCase
    v18 = v0.Previous
    v18 = v18.DisplayValue
    v17 = v17(v18)
    v18 = v0.Previous
    v18 = v18.DisplayValue
    v13 = v15(v16, v17, v18)
    v14 = "</font>"
    v9 = v10 .. v8 .. v12 .. v13 .. v14
    p118 = 41
  end
  if p118 == 41 then
    v10 = u1
    v10 = v10.Ternary
    v11 = v0.TextOnly
    v12 = v0.Previous
    v12 = v12.DisplayValue
    v13 = v0.Previous
    v13 = v13.StatValue
    v10 = v10(v11, v12, v13)
    v11 = u1
    v11 = v11.Ternary
    v12 = v0.TextOnly
    v13 = v0.Current
    v13 = v13.DisplayValue
    v14 = v0.Current
    v14 = v14.StatValue
    v11 = v11(v12, v13, v14)
    if v10 == v11 then
      p118 = 47
    else
      p118 = 42
    end
  end
  if p118 == 42 then
    v12 = u0
    v12 = v12.mMovie
    v14 = "<MINI_ARROW>"
    v15 = true
    v12 = v12:GetLocalized(v14, v15)
    v13 = u0
    v13 = v13.GetCurrentStatColor
    v13 = v13(v0, v10, v11)
    if v6 == "" then
      p118 = 46
    else
      p118 = 43
    end
  end
  if p118 == 43 then
    v14 = u0
    v14 = v14.mMovie
    v17 = true
    v18 = { COUNT = nil }
    v19 = v0.Current
    v19 = v19.DisplayValue
    v18.COUNT = v19
    v7 = v14:GetLocalized(v6, v17, v18)
    v14 = u0
    v14 = v14.TitleCase
    if not v14 then
      p118 = 45
    else
      p118 = 44
    end
  end
  if p118 == 44 then
    v14 = TitleCase
    v7 = v14(v7)
    p118 = 45
  end
  if p118 == 45 then
    v15 = "<font color=\"#"
    v17 = "\">"
    v20 = "</font>"
    v9 = v9 .. v15 .. v13 .. v17 .. v12 .. v7 .. v20
    p118 = 47
  end
  if p118 == 46 then
    v15 = "<font color=\"#"
    v17 = "\">"
    v21 = u1
    v21 = v21.Ternary
    v22 = u0
    v22 = v22.TitleCase
    v23 = TitleCase
    v24 = v0.Current
    v24 = v24.DisplayValue
    v23 = v23(v24)
    v24 = v0.Current
    v24 = v24.DisplayValue
    v19 = v21(v22, v23, v24)
    v20 = "</font>"
    v9 = v9 .. v15 .. v13 .. v17 .. v12 .. v19 .. v20
    p118 = 47
  end
  if p118 == 47 then
    v13 = "</p>"
    v9 = v9 .. v13
    v12 = u0
    v12 = v12.mMovie
    v15 = v0.mClipName
    v16 = ".NewValue"
    v14 = v15 .. v16
    v15 = 36
    v12:SetStringVariable(v14, v15, v9)
    v12 = false
    v13 = v0.mIndex
    v14 = u0
    v14 = v14:GetHowManyElements()
    if v13 ~= v14 then
      p118 = 49
    else
      p118 = 48
    end
  end
  if p118 == 48 then
    v12 = true
    p118 = 52
  end
  if p118 == 49 then
    v13 = u0
    v16 = v0.mIndex
    v15 = v16 + 1
    v13 = v13:GetElementInIndex(v15)
    v14 = v0.Order
    v15 = v13.Order
    if v14 ~= v15 then
      p118 = 51
    else
      p118 = 50
    end
  end
  if p118 == 50 then
    v12 = false
    p118 = 52
  end
  if p118 == 51 then
    v12 = true
    p118 = 52
  end
  if p118 == 52 then
    v13 = u0
    v13 = v13.mMovie
    v15 = v0.mClipName
    v16 = 13
    v18 = v0.Filler
    v17 = not v18
    v13:Name__d9713943(v15, v16, v17)
    v13 = u0
    v13 = v13.mMovie
    v15 = v0.mClipName
    v16 = "Line"
    v17 = 13
    v18 = not v12
    if not v18 then
      p118 = 54
    else
      p118 = 53
    end
  end
  if p118 == 53 then
    v19 = v0.Filler
    v18 = not v19
    p118 = 54
  end
  if p118 == 54 then
    v13:Makeposshield(v15, v16, v17, v18)
    v13 = u0
    v13 = v13.mMovie
    v15 = v0.mClipName
    v16 = "DotLine"
    v17 = 13
    v19 = u0
    v19 = v19.DotLink
    if not v19 then
      p118 = 58
    else
      p118 = 55
    end
  end
  if p118 == 55 then
    v20 = v0.Filler
    if v20 then
      p118 = 57
    else
      p118 = 56
    end
  end
  if p118 == 56 then
    v20 = v0.Title
    p118 = 57
  end
  if p118 == 57 then
    v19 = not v20
    p118 = 58
  end
  if p118 == 58 then
    if v19 == true then
      p118 = 60
    else
      p118 = 59
    end
  end
  if p118 == 59 then
    v18 = false
    p118 = 61
  end
  if p118 == 60 then
    v18 = true
    p118 = 61
  end
  if p118 == 61 then
    v13:Makeposshield(v15, v16, v17, v18)
    v13 = v0.Filler
    if v13 then
      p118 = 63
    else
      p118 = 62
    end
  end
  if p118 == 62 then
    v13 = v0.Title
    if not v13 then
      p118 = 64
    else
      p118 = 63
    end
  end
  if p118 == 63 then
    v13 = u0
    v13 = v13.mMovie
    v16 = v0.mClipName
    v17 = ".NewValue"
    v15 = v16 .. v17
    v16 = 36
    v17 = ""
    v13:SetStringVariable(v15, v16, v17)
    do return end
  end
  if p118 == 64 then
    v13 = u0
    v13 = v13.DotLink
    if not v13 then
      p118 = 68
    else
      p118 = 65
    end
  end
  if p118 == 65 then
    v13 = u0
    v13 = v13.Width
    if v13 == nil then
      p118 = 68
    else
      p118 = 66
    end
  end
  if p118 == 66 then
    v13 = u0
    v13 = v13.mMovie
    v16 = v0.mClipName
    v17 = ".Label"
    v15 = v16 .. v17
    v16 = 40
    v13 = v13:GetNumberVariable(v15, v16)
    v14 = u0
    v14 = v14.mMovie
    v17 = v0.mClipName
    v18 = ".NewValue"
    v16 = v17 .. v18
    v17 = 40
    v14 = v14:GetNumberVariable(v16, v17)
    v15 = u1
    v15 = v15.Round
    v18 = u0
    v18 = v18.Width
    v20 = v13 + v14
    v19 = v20 + 10
    v17 = v18 - v19
    v16 = v17 / 5
    v15 = v15(v16)
    v16 = v15 * 5
    v17 = u0
    v17 = v17.mMovie
    v20 = v0.mClipName
    v21 = ".DotLine"
    v19 = v20 .. v21
    v20 = "TileRepeats"
    v22 = 1
    v23 = 1
    v24 = 1
    v17:Name__e243d995(v19, v20, v15, v22, v23, v24)
    v17 = u0
    v17 = v17.mMovie
    v19 = v0.mClipName
    v20 = "DotLine"
    v21 = 14
    v17:Name__52c1b74e(v19, v20, v21, v16)
    v17 = u0
    v17 = v17.mMovie
    v19 = v0.mClipName
    v20 = "DotLine"
    v21 = 15
    v22 = 5
    v17:Name__52c1b74e(v19, v20, v21, v22)
    v17 = u0
    v17 = v17.mMovie
    v19 = v0.mClipName
    v20 = "DotLine"
    v21 = 12
    v22 = 10
    v17:Name__52c1b74e(v19, v20, v21, v22)
    v17 = u0
    v17 = v17.mMovie
    v19 = v0.mClipName
    v20 = "DotLine"
    v21 = 0
    v24 = u0
    v24 = v24.mMovie
    v27 = v0.mClipName
    v28 = ".Label"
    v26 = v27 .. v28
    v27 = 0
    v24 = v24:GetNumberVariable(v26, v27)
    v23 = v24 + v13
    v22 = v23 + 5
    v17:Name__52c1b74e(v19, v20, v21, v22)
    v18 = u0
    v18 = v18.DotLinkMat
    v17 = IsNull
    v17 = v17(v18)
    if v17 then
      p118 = 68
    else
      p118 = 67
    end
  end
  if p118 == 67 then
    v17 = u0
    v17 = v17.mMovie
    v20 = v0.mClipName
    v21 = ".DotLine"
    v19 = v20 .. v21
    v20 = u0
    v20 = v20.DotLinkMat
    v17:OverrideMaterial(v19, v20)
    p118 = 68
  end
  if p118 == 68 then
    do return end
  end
end

function proto_5(v0, v1, v2, v3)
  v0:Populate()
  v0:_list_Redraw(v1, v2, v3)
  do return end
end

function proto_6(v0, v1)
  do return end
end

function proto_7(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12
  v1 = 0
  v4 = 1
  v5 = v0.mElements
  v2 = #v5
  v3 = 1
  for v4 = v4, v2, v3 do
    v6 = v0.mElements
    v5 = v6[v4]
    v6 = v5.Filler
    if v6 then
      v1 = v1 + 10
    else
      v6 = v0.mMovie
      v8 = v5.mClipName
      v9 = 15
      v6 = v6:GetNumberVariable(v8, v9)
      v8 = v0.mOriginalElementHeight
      v7 = v6 - v8
      v9 = v0.mForcedVerticalSeparation
      v8 = v1 + v9
      v9 = u0
      v9 = v9.Ternary
      v11 = 0
      if v7 <= v11 then
        v10 = false
      else
        v10 = true
      end
      v11 = v7 + 3
      v12 = 0
      v9 = v9(v10, v11, v12)
      v1 = v8 + v9
    end
  end
  do return v1 end
end

function proto_8(v0, v1)
  local v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13
  v2 = v0.mInitialY
  v5 = 1
  v6 = v1.Id
  v3 = v6 - 1
  v4 = 1
  for v5 = v5, v3, v4 do
    v7 = v0.mElements
    v6 = v7[v5]
    v6 = v6.Filler
    if v6 then
      v6 = u0
      v6 = v6.Ternary
      v7 = v0.mGrowsUpwards
      v8 = 10
      v9 = -10
      v6 = v6(v7, v8, v9)
      v2 = v2 + v6
    else
      v6 = v0.mMovie
      v9 = v0.mElements
      v8 = v9[v5]
      v8 = v8.mClipName
      v9 = 15
      v6 = v6:GetNumberVariable(v8, v9)
      v8 = v0.mOriginalElementHeight
      v7 = v6 - v8
      v9 = v0.mForcedVerticalSeparation
      v10 = u0
      v10 = v10.Ternary
      v12 = 0
      if v7 <= v12 then
        v11 = false
      else
        v11 = true
      end
      v12 = v7 + 3
      v13 = 0
      v10 = v10(v11, v12, v13)
      v8 = v9 + v10
      v9 = u0
      v9 = v9.Ternary
      v10 = v0.mGrowsUpwards
      v12 = -v8
      v8 = v9(v10, v8, v12)
      v2 = v2 + v8
    end
  end
  do return v2 end
end

function proto_9(v0, v1)
  local v2, v3, v4
  v2 = v0.Order
  v3 = v1.Order
  if v2 ~= v3 then
    v3 = v0.Order
    v4 = v1.Order
    if v4 <= v3 then
      v2 = false
    else
      v2 = true
    end
    do return v2 end
  end
  v3 = v0.Label
  v4 = v1.Label
  if v4 <= v3 then
    v2 = false
  else
    v2 = true
  end
  do return v2 end
end

function proto_10(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v22, v23, v24, v25, v26, v27, v28, v29, v30
  v3 = true
  v4 = true
  v0:RemoveElements(v3, v4)
  v1 = {}
  v2 = false
  v3 = false
  v4 = false
  v5 = u0
  v5 = v5.Ternary
  v6 = v0.mGrowsUpwards
  v7 = 1
  v8 = 0
  v5 = v5(v6, v7, v8)
  v6 = v5 + 1
  v7 = v6 + 1
  v8 = v7 + 1
  v9 = v8 + 1
  v10 = v9 + 1
  v11 = v10 + 1
  v12 = v11 + 1
  v13 = u0
  v13 = v13.Ternary
  v14 = v0.mGrowsUpwards
  v15 = 0
  v13 = v13(v14, v15, v12)
  v14 = u0
  v14 = v14.Ternary
  v15 = v0.mGrowsUpwards
  v17 = 0
  v14 = v14(v15, v12, v17)
  v15 = u0
  v15 = v15.Ternary
  v16 = v0.mGrowsUpwards
  v17 = 0
  v20 = v0.mStats
  v19 = #v20
  v20 = v12 + 1
  v18 = v19 * v20
  v15 = v15(v16, v17, v18)
  v16 = false
  v17 = ipairs
  v18 = v0.mStats
  v17, v18, v19 = v17(v18)
  for v20, v21 in v17, v18, v19 do
    v27 = v0.mSort
    v27 = v11 + v15
    v26.Order = v27
    v29 = { Label = "", Previous = nil, Filler = true, Order = nil }
    v30 = v11 + v15
    v29.Order = v30
    v27 = table.insert
    v27(v1, v29)
    v27 = v5 + v15
    v26.Order = v27
    v2 = true
    v27 = string.find
    v29 = "_RESIST$"
    v27 = v27(v25, v29)
    v27 = v7 + v15
    v26.Order = v27
    v3 = true
    v27 = string.find
    v29 = "EmbedDT_"
    v27 = v27(v25, v29)
    v27 = v10 + v15
    v26.Order = v27
    v27 = string.find
    v29 = "Embed"
    v27 = v27(v25, v29)
    v27 = v8 + v15
    v26.Order = v27
    v27 = string.find
    v29 = "DT_"
    v27 = v27(v25, v29)
    v27 = string.find
    v29 = "Power_"
    v27 = v27(v25, v29)
    v27 = v9 + v15
    v26.Order = v27
    v4 = true
    v27 = v6 + v15
    v26.Order = v27
    v27 = table.insert
    v27(v1, v26)
    v27 = v26.ForceOrder
    if v27 ~= nil then
      v28 = v26.ForceOrder
      v27 = v28 + v15
      v26.Order = v27
      v27 = v26.ForceOrder
      if v27 == v5 then
        v2 = true
      else
        v27 = v26.ForceOrder
        if v27 == v7 then
          v3 = true
        else
          v27 = v26.ForceOrder
          if v27 == v9 then
            v4 = true
          end
        end
      end
    end
    v22 = v0.mSort
    if v22 then
      if v2 then
        v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
        v25 = v6 + v15
        v24.Order = v25
        v22 = table.insert
        v22(v1, v24)
      end
      if v3 then
        v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
        v25 = v7 + v15
        v24.Order = v25
        v22 = table.insert
        v22(v1, v24)
      end
      if v4 then
        v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
        v25 = v9 + v15
        v24.Order = v25
        v22 = table.insert
        v22(v1, v24)
      end
    end
    v16 = true
    v22 = u0
    v22 = v22.Ternary
    v23 = v0.mGrowsUpwards
    v25 = v12 + 1
    v24 = v25 + v15
    v26 = v12 + 1
    v25 = v26 - v15
    v15 = v22(v23, v24, v25)
    for v20, v21 in v17, v18, v19 do
      v17 = v0.mSort
      if v17 then
        v17 = table.sort
        v19 = function(c1v0, c1v1)
          local c1v2, c1v3, c1v4
          c1v2 = c1v0.Order
          c1v3 = c1v1.Order
          if c1v2 ~= c1v3 then
            c1v3 = c1v0.Order
            c1v4 = c1v1.Order
            if c1v4 <= c1v3 then
              c1v2 = false
            else
              c1v2 = true
            end
            do return c1v2 end
          end
          c1v3 = c1v0.Label
          c1v4 = c1v1.Label
          if c1v4 <= c1v3 then
            c1v2 = false
          else
            c1v2 = true
          end
          do return c1v2 end
        end
        v17(v1, v19)
      end
      v17 = 0
      v18 = pairs
      v18, v19, v20 = v18(v1)
      for v21, v22 in v18, v19, v20 do
        v23 = ResetLineCount
        v24 = 0
        v23(v24)
        v17 = v17 + 1
        v22.Id = v17
        v26 = true
        v0:AddElement(v22, v26)
      end
      do return end
    end
    if v16 then
      v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
      v25 = u0
      v25 = v25.Ternary
      v26 = v0.mGrowsUpwards
      v28 = v14 - v15
      v25 = v25(v26, v15, v28)
      v24.Order = v25
      v22 = table.insert
      v22(v1, v24)
    end
    v22 = u1
    v23 = v21.mName
    v22 = v22(v23)
    if not v22 then
      v23 = v0.mStats
      v22 = #v23
      v23 = 1
      if v23 < v22 then
        v24 = { Label = nil, Previous = nil, Title = true, Order = nil }
        v26 = "<p><font color=\""
        v27 = v0.GroupTitleColor
        v28 = "\"><b>"
        v29 = v21.mName
        v30 = "</b></font></p>"
        v25 = v26 .. v27 .. v28 .. v29 .. v30
        v24.Label = v25
        v25 = v13 + v15
        v24.Order = v25
        v22 = table.insert
        v22(v1, v24)
      end
    end
    v22 = pairs
    v23 = v21.mStats
    v22, v23, v24 = v22(v23)
  end
end

function proto_11(v0, v1)
  local v2, v3, v4, v5, v6, v7, v8, v9
  v2 = require
  v3 = "EE.Interface.Components.List"
  v2 = v2(v3)
  v3 = v2.CreateList
  v3 = v3(v0, v1)
  v5 = "StatCompare("
  v7 = ")::"
  v4 = v5 .. v1 .. v7
  v3.mPrefix = v4
  v4 = {}
  v3.mStats = v4
  v4 = true
  v3.mSort = v4
  v4 = false
  v3.mWrapAroundNavigation = v4
  v4 = 0.15
  v3.mElementTransitionTime = v4
  v4 = "#4dd9e5"
  v3.GroupTitleColor = v4
  v4 = _G
  v4 = v4.UIColor_White
  v3.LabelColor = v4
  v4 = _G
  v4 = v4.UIColor_White
  v3.PreviousStatColor = v4
  v4 = _G
  v4 = v4.UIColor_Green
  v3.StatIncreasedColor = v4
  v4 = _G
  v4 = v4.UIColor_Red
  v3.StatDecreasedColor = v4
  v4 = true
  v3.mGrowsUpwards = v4
  v4 = 23
  v3.mForcedVerticalSeparation = v4
  v4 = v3.mMovie
  v7 = 15
  v4 = v4:GetNumberVariable(v1, v7)
  v3.mOriginalElementHeight = v4
  v6 = "StatSelected"
  v7 = "StatFocused"
  v8 = "StatUnfocused"
  v9 = "StatPressed"
  v3:SetCallbacks(v6, v7, v8, v9)
  v4 = function(c2v0, c2v1)
    do return end
  end
  v3.Print = v4
  v4 = function(c3v0)
    local c3v1, c3v2, c3v3
    c3v1 = string.format
    c3v2 = "%x"
    c3v3 = v3
    c3v3 = c3v3.PreviousStatColor
    c3v1 = c3v1(c3v2, c3v3)
    do return c3v1 end
  end
  v3.GetPreviousStatColor = v4
  v4 = function(c4v0, c4v1, c4v2)
    local c4v3, c4v4, c4v5, c4v6, c4v8, c4v9, c4v10, c4v11
    c4v3 = v3
    c4v3 = c4v3.GetPreviousStatColor
    c4v3 = c4v3()
    c4v4 = true
    if c4v1 ~= nil then
      c4v4 = true
      if c4v2 ~= nil then
        c4v4 = c4v0.TextOnly
      end
    end
    if c4v1 == nil then
      if c4v1 <= c4v2 then
        c4v5 = false
      else
        c4v5 = true
      end
      c4v6 = c4v0.SmallerIsBetter
      if c4v6 then
        if c4v2 <= c4v1 then
          c4v5 = false
        else
          c4v5 = true
        end
      end
      c4v6 = u0
      c4v6 = c4v6.Ternary
      c4v8 = string.format
      c4v9 = "%x"
      c4v10 = v3
      c4v10 = c4v10.StatDecreasedColor
      c4v8 = c4v8(c4v9, c4v10)
      c4v9 = string.format
      c4v10 = "%x"
      c4v11 = v3
      c4v11 = c4v11.StatIncreasedColor
      c4v3 = c4v6(c4v5, c4v8, c4v9(c4v10, c4v11))
    end
    do return c4v3 end
  end
  v3.GetCurrentStatColor = v4
  v4 = function(c5v0)
    local c5v1, c5v2, c5v3, c5v4, c5v5, c5v6, c5v7, c5v8, c5v9, c5v10, c5v11, c5v12, c5v13, c5v14, c5v15, c5v16, c5v17, c5v18, c5v19, c5v20, c5v21, c5v22, c5v23, c5v24, c5v26, c5v27, c5v28
    local p118 = 0
    if p118 == 0 then
      c5v1 = c5v0.Label
      if c5v1 == nil then
        p118 = 4
      else
        p118 = 1
      end
    end
    if p118 == 1 then
      c5v2 = v3
      c5v2 = c5v2.TitleCase
      if not c5v2 then
        p118 = 4
      else
        p118 = 2
      end
    end
    if p118 == 2 then
      c5v2 = c5v0.Title
      if c5v2 then
        p118 = 4
      else
        p118 = 3
      end
    end
    if p118 == 3 then
      c5v2 = TitleCase
      c5v1 = c5v2(c5v1)
      p118 = 4
    end
    if p118 == 4 then
      c5v2 = v3
      c5v2 = c5v2.mMovie
      c5v5 = c5v0.mClipName
      c5v6 = ".Label"
      c5v4 = c5v5 .. c5v6
      c5v5 = 36
      c5v2:SetStringVariable(c5v4, c5v5, c5v1)
      c5v2 = v3
      c5v2 = c5v2.mMovie
      c5v5 = c5v0.mClipName
      c5v6 = ".Label"
      c5v4 = c5v5 .. c5v6
      c5v5 = _G
      c5v5 = c5v5.UIMaterial_PlainText
      c5v2:OverrideMaterial(c5v4, c5v5)
      c5v2 = v3
      c5v2 = c5v2.mMovie
      c5v4 = c5v0.mClipName
      c5v5 = "Label"
      c5v6 = 44
      c5v7 = v3
      c5v7 = c5v7.LabelColor
      c5v2:Name__52c1b74e(c5v4, c5v5, c5v6, c5v7)
      c5v2 = v3
      c5v2 = c5v2.mMovie
      c5v5 = c5v0.mClipName
      c5v6 = ".NewValue"
      c5v4 = c5v5 .. c5v6
      c5v5 = _G
      c5v5 = c5v5.UIMaterial_PlainText
      c5v2:OverrideMaterial(c5v4, c5v5)
      c5v2 = u0
      c5v2 = c5v2.Ternary
      c5v4 = v3
      c5v4 = c5v4.LabelAlpha
      if c5v4 ~= nil then
        p118 = 6
      else
        p118 = 5
      end
    end
    if p118 == 5 then
      c5v3 = false
      p118 = 7
    end
    if p118 == 6 then
      c5v3 = true
      p118 = 7
    end
    if p118 == 7 then
      c5v4 = v3
      c5v4 = c5v4.LabelAlpha
      c5v5 = 100
      c5v2 = c5v2(c5v3, c5v4, c5v5)
      c5v3 = 100
      c5v4 = v3
      c5v4 = c5v4.StatAltAlphaOffset
      if c5v4 == nil then
        p118 = 10
      else
        p118 = 8
      end
    end
    if p118 == 8 then
      c5v5 = c5v0.mIndex
      c5v4 = c5v5 % 2
      if c5v4 ~= 0 then
        p118 = 10
      else
        p118 = 9
      end
    end
    if p118 == 9 then
      c5v4 = v3
      c5v4 = c5v4.StatAltAlphaOffset
      c5v2 = c5v2 + c5v4
      c5v4 = v3
      c5v4 = c5v4.StatAltAlphaOffset
      c5v3 = c5v3 + c5v4
      p118 = 10
    end
    if p118 == 10 then
      c5v4 = v3
      c5v4 = c5v4.mMovie
      c5v6 = c5v0.mClipName
      c5v7 = "Label"
      c5v8 = 12
      c5v4:Name__52c1b74e(c5v6, c5v7, c5v8, c5v2)
      c5v4 = v3
      c5v4 = c5v4.mMovie
      c5v6 = c5v0.mClipName
      c5v7 = "NewValue"
      c5v8 = 12
      c5v4:Name__52c1b74e(c5v6, c5v7, c5v8, c5v3)
      c5v5 = v3
      c5v5 = c5v5.StatBgColor
      if c5v5 ~= nil then
        p118 = 12
      else
        p118 = 11
      end
    end
    if p118 == 11 then
      c5v4 = false
      p118 = 13
    end
    if p118 == 12 then
      c5v4 = true
      p118 = 13
    end
    if p118 == 13 then
      c5v5 = v3
      c5v5 = c5v5.mMovie
      c5v7 = c5v0.mClipName
      c5v8 = "Bg"
      c5v9 = 13
      c5v5:Makeposshield(c5v7, c5v8, c5v9, c5v4)
      if not c5v4 then
        p118 = 18
      else
        p118 = 14
      end
    end
    if p118 == 14 then
      c5v5 = v3
      c5v5 = c5v5.mMovie
      c5v7 = c5v0.mClipName
      c5v8 = "Bg"
      c5v9 = 11
      c5v10 = v3
      c5v10 = c5v10.StatBgColor
      c5v5:Name__52c1b74e(c5v7, c5v8, c5v9, c5v10)
      c5v5 = v3
      c5v5 = c5v5.mMovie
      c5v7 = c5v0.mClipName
      c5v8 = "Bg"
      c5v9 = 12
      c5v10 = u0
      c5v10 = c5v10.Ternary
      c5v13 = c5v0.mIndex
      c5v12 = c5v13 % 2
      if c5v12 ~= 0 then
        p118 = 16
      else
        p118 = 15
      end
    end
    if p118 == 15 then
      c5v11 = false
      p118 = 17
    end
    if p118 == 16 then
      c5v11 = true
      p118 = 17
    end
    if p118 == 17 then
      c5v12 = v3
      c5v12 = c5v12.StatBgAlpha
      c5v13 = 0
      c5v5:Name__52c1b74e(c5v7, c5v8, c5v9, c5v10(c5v11, c5v12, c5v13))
      p118 = 18
    end
    if p118 == 18 then
      c5v5 = v3
      c5v5 = c5v5.mMovie
      c5v8 = c5v0.mClipName
      c5v9 = ".Label"
      c5v7 = c5v8 .. c5v9
      c5v8 = 52
      c5v5 = c5v5:Name__9d78ed52(c5v7, c5v8)
      if not c5v5 then
        p118 = 20
      else
        p118 = 19
      end
    end
    if p118 == 19 then
      c5v6 = v3
      c5v6 = c5v6.mMovie
      c5v9 = c5v0.mClipName
      c5v10 = ".Label"
      c5v8 = c5v9 .. c5v10
      c5v9 = 41
      c5v6 = c5v6:GetNumberVariable(c5v8, c5v9)
      c5v7 = v3
      c5v7 = c5v7.mMovie
      c5v9 = c5v0.mClipName
      c5v10 = "NewValue"
      c5v11 = 1
      c5v13 = c5v6 / 2
      c5v12 = c5v13 - 9
      c5v7:Name__52c1b74e(c5v9, c5v10, c5v11, c5v12)
      c5v7 = v3
      c5v7 = c5v7.mMovie
      c5v9 = c5v0.mClipName
      c5v10 = "Line"
      c5v11 = 1
      c5v12 = c5v6 + 7
      c5v7:Name__52c1b74e(c5v9, c5v10, c5v11, c5v12)
      p118 = 20
    end
    if p118 == 20 then
      c5v6 = v3
      c5v6 = c5v6.mMovie
      c5v8 = c5v0.mClipName
      c5v9 = "Line"
      c5v10 = 15
      c5v11 = 2.5
      c5v6:Name__52c1b74e(c5v8, c5v9, c5v10, c5v11)
      c5v6 = v3
      c5v6 = c5v6.mMovie
      c5v9 = c5v0.mClipName
      c5v10 = ".Line"
      c5v8 = c5v9 .. c5v10
      c5v9 = _G
      c5v9 = c5v9.UIMaterial_SmoothEdgeNoDepthTest
      c5v6:OverrideMaterial(c5v8, c5v9)
      c5v6 = u0
      c5v6 = c5v6.Ternary
      c5v8 = c5v0.ValueUnit
      c5v7 = IsNull
      c5v7 = c5v7(c5v8)
      c5v8 = ""
      c5v9 = c5v0.ValueUnit
      c5v6 = c5v6(c5v7, c5v8, c5v9)
      c5v7 = ""
      c5v8 = c5v0.Previous
      if c5v8 == nil then
        p118 = 23
      else
        p118 = 21
      end
    end
    if p118 == 21 then
      c5v8 = c5v0.Previous
      c5v8 = c5v8.StatValue
      if c5v8 ~= nil then
        p118 = 26
      else
        p118 = 22
      end
    end
    if p118 == 22 then
      c5v8 = c5v0.Previous
      c5v8 = c5v8.DisplayValue
      if c5v8 ~= nil then
        p118 = 26
      else
        p118 = 23
      end
    end
    if p118 == 23 then
      c5v8 = c5v0.TextOnly
      if not c5v8 then
        p118 = 25
      else
        p118 = 24
      end
    end
    if p118 == 24 then
      c5v8 = { StatValue = 0, DisplayValue = nil }
      c5v9 = v3
      c5v9 = c5v9.mMovie
      c5v11 = "/Lotus/Language/Menu/Arsenal_Zero"
      c5v12 = false
      c5v9 = c5v9:GetLocalized(c5v11, c5v12)
      c5v8.DisplayValue = c5v9
      c5v0.Previous = c5v8
      p118 = 28
    end
    if p118 == 25 then
      c5v8 = { StatValue = 0, DisplayValue = "0" }
      c5v0.Previous = c5v8
      p118 = 28
    end
    if p118 == 26 then
      c5v8 = c5v0.Previous
      c5v8 = c5v8.DisplayValue
      if c5v8 ~= nil then
        p118 = 28
      else
        p118 = 27
      end
    end
    if p118 == 27 then
      c5v8 = c5v0.Previous
      c5v9 = u0
      c5v9 = c5v9.FormatNumber
      c5v10 = c5v0.Previous
      c5v10 = c5v10.StatValue
      c5v11 = 0
      c5v12 = false
      c5v9 = c5v9(c5v10, c5v11, c5v12)
      c5v8.DisplayValue = c5v9
      p118 = 28
    end
    if p118 == 28 then
      c5v8 = c5v0.Current
      if c5v8 == nil then
        p118 = 31
      else
        p118 = 29
      end
    end
    if p118 == 29 then
      c5v8 = c5v0.Current
      c5v8 = c5v8.StatValue
      if c5v8 ~= nil then
        p118 = 34
      else
        p118 = 30
      end
    end
    if p118 == 30 then
      c5v8 = c5v0.Current
      c5v8 = c5v8.DisplayValue
      if c5v8 ~= nil then
        p118 = 34
      else
        p118 = 31
      end
    end
    if p118 == 31 then
      c5v8 = c5v0.TextOnly
      if not c5v8 then
        p118 = 33
      else
        p118 = 32
      end
    end
    if p118 == 32 then
      c5v8 = { StatValue = 0, DisplayValue = nil }
      c5v9 = v3
      c5v9 = c5v9.mMovie
      c5v11 = "/Lotus/Language/Menu/Arsenal_Zero"
      c5v12 = false
      c5v9 = c5v9:GetLocalized(c5v11, c5v12)
      c5v8.DisplayValue = c5v9
      c5v0.Current = c5v8
      p118 = 36
    end
    if p118 == 33 then
      c5v8 = { StatValue = 0, DisplayValue = "0" }
      c5v0.Current = c5v8
      p118 = 36
    end
    if p118 == 34 then
      c5v8 = c5v0.Current
      c5v8 = c5v8.DisplayValue
      if c5v8 ~= nil then
        p118 = 36
      else
        p118 = 35
      end
    end
    if p118 == 35 then
      c5v8 = c5v0.Current
      c5v9 = u0
      c5v9 = c5v9.FormatNumber
      c5v10 = c5v0.Current
      c5v10 = c5v10.StatValue
      c5v11 = 0
      c5v12 = false
      c5v9 = c5v9(c5v10, c5v11, c5v12)
      c5v8.DisplayValue = c5v9
      p118 = 36
    end
    if p118 == 36 then
      c5v8 = v3
      c5v8 = c5v8.GetPreviousStatColor
      c5v8 = c5v8(c5v0)
      c5v9 = ""
      if c5v6 == "" then
        p118 = 40
      else
        p118 = 37
      end
    end
    if p118 == 37 then
      c5v10 = v3
      c5v10 = c5v10.mMovie
      c5v13 = true
      c5v14 = { COUNT = nil }
      c5v15 = c5v0.Previous
      c5v15 = c5v15.DisplayValue
      c5v14.COUNT = c5v15
      c5v7 = c5v10:GetLocalized(c5v6, c5v13, c5v14)
      c5v10 = v3
      c5v10 = c5v10.TitleCase
      if not c5v10 then
        p118 = 39
      else
        p118 = 38
      end
    end
    if p118 == 38 then
      c5v10 = TitleCase
      c5v7 = c5v10(c5v7)
      p118 = 39
    end
    if p118 == 39 then
      c5v10 = "<p><font color=\"#"
      c5v12 = "\">"
      c5v14 = "</font>"
      c5v9 = c5v10 .. c5v8 .. c5v12 .. c5v7 .. c5v14
      p118 = 41
    end
    if p118 == 40 then
      c5v10 = "<p><font color=\"#"
      c5v12 = "\">"
      c5v15 = u0
      c5v15 = c5v15.Ternary
      c5v16 = v3
      c5v16 = c5v16.TitleCase
      c5v17 = TitleCase
      c5v18 = c5v0.Previous
      c5v18 = c5v18.DisplayValue
      c5v17 = c5v17(c5v18)
      c5v18 = c5v0.Previous
      c5v18 = c5v18.DisplayValue
      c5v13 = c5v15(c5v16, c5v17, c5v18)
      c5v14 = "</font>"
      c5v9 = c5v10 .. c5v8 .. c5v12 .. c5v13 .. c5v14
      p118 = 41
    end
    if p118 == 41 then
      c5v10 = u0
      c5v10 = c5v10.Ternary
      c5v11 = c5v0.TextOnly
      c5v12 = c5v0.Previous
      c5v12 = c5v12.DisplayValue
      c5v13 = c5v0.Previous
      c5v13 = c5v13.StatValue
      c5v10 = c5v10(c5v11, c5v12, c5v13)
      c5v11 = u0
      c5v11 = c5v11.Ternary
      c5v12 = c5v0.TextOnly
      c5v13 = c5v0.Current
      c5v13 = c5v13.DisplayValue
      c5v14 = c5v0.Current
      c5v14 = c5v14.StatValue
      c5v11 = c5v11(c5v12, c5v13, c5v14)
      if c5v10 == c5v11 then
        p118 = 47
      else
        p118 = 42
      end
    end
    if p118 == 42 then
      c5v12 = v3
      c5v12 = c5v12.mMovie
      c5v14 = "<MINI_ARROW>"
      c5v15 = true
      c5v12 = c5v12:GetLocalized(c5v14, c5v15)
      c5v13 = v3
      c5v13 = c5v13.GetCurrentStatColor
      c5v13 = c5v13(c5v0, c5v10, c5v11)
      if c5v6 == "" then
        p118 = 46
      else
        p118 = 43
      end
    end
    if p118 == 43 then
      c5v14 = v3
      c5v14 = c5v14.mMovie
      c5v17 = true
      c5v18 = { COUNT = nil }
      c5v19 = c5v0.Current
      c5v19 = c5v19.DisplayValue
      c5v18.COUNT = c5v19
      c5v7 = c5v14:GetLocalized(c5v6, c5v17, c5v18)
      c5v14 = v3
      c5v14 = c5v14.TitleCase
      if not c5v14 then
        p118 = 45
      else
        p118 = 44
      end
    end
    if p118 == 44 then
      c5v14 = TitleCase
      c5v7 = c5v14(c5v7)
      p118 = 45
    end
    if p118 == 45 then
      c5v15 = "<font color=\"#"
      c5v17 = "\">"
      c5v20 = "</font>"
      c5v9 = c5v9 .. c5v15 .. c5v13 .. c5v17 .. c5v12 .. c5v7 .. c5v20
      p118 = 47
    end
    if p118 == 46 then
      c5v15 = "<font color=\"#"
      c5v17 = "\">"
      c5v21 = u0
      c5v21 = c5v21.Ternary
      c5v22 = v3
      c5v22 = c5v22.TitleCase
      c5v23 = TitleCase
      c5v24 = c5v0.Current
      c5v24 = c5v24.DisplayValue
      c5v23 = c5v23(c5v24)
      c5v24 = c5v0.Current
      c5v24 = c5v24.DisplayValue
      c5v19 = c5v21(c5v22, c5v23, c5v24)
      c5v20 = "</font>"
      c5v9 = c5v9 .. c5v15 .. c5v13 .. c5v17 .. c5v12 .. c5v19 .. c5v20
      p118 = 47
    end
    if p118 == 47 then
      c5v13 = "</p>"
      c5v9 = c5v9 .. c5v13
      c5v12 = v3
      c5v12 = c5v12.mMovie
      c5v15 = c5v0.mClipName
      c5v16 = ".NewValue"
      c5v14 = c5v15 .. c5v16
      c5v15 = 36
      c5v12:SetStringVariable(c5v14, c5v15, c5v9)
      c5v12 = false
      c5v13 = c5v0.mIndex
      c5v14 = v3
      c5v14 = c5v14:GetHowManyElements()
      if c5v13 ~= c5v14 then
        p118 = 49
      else
        p118 = 48
      end
    end
    if p118 == 48 then
      c5v12 = true
      p118 = 52
    end
    if p118 == 49 then
      c5v13 = v3
      c5v16 = c5v0.mIndex
      c5v15 = c5v16 + 1
      c5v13 = c5v13:GetElementInIndex(c5v15)
      c5v14 = c5v0.Order
      c5v15 = c5v13.Order
      if c5v14 ~= c5v15 then
        p118 = 51
      else
        p118 = 50
      end
    end
    if p118 == 50 then
      c5v12 = false
      p118 = 52
    end
    if p118 == 51 then
      c5v12 = true
      p118 = 52
    end
    if p118 == 52 then
      c5v13 = v3
      c5v13 = c5v13.mMovie
      c5v15 = c5v0.mClipName
      c5v16 = 13
      c5v18 = c5v0.Filler
      c5v17 = not c5v18
      c5v13:Name__d9713943(c5v15, c5v16, c5v17)
      c5v13 = v3
      c5v13 = c5v13.mMovie
      c5v15 = c5v0.mClipName
      c5v16 = "Line"
      c5v17 = 13
      c5v18 = not c5v12
      if not c5v18 then
        p118 = 54
      else
        p118 = 53
      end
    end
    if p118 == 53 then
      c5v19 = c5v0.Filler
      c5v18 = not c5v19
      p118 = 54
    end
    if p118 == 54 then
      c5v13:Makeposshield(c5v15, c5v16, c5v17, c5v18)
      c5v13 = v3
      c5v13 = c5v13.mMovie
      c5v15 = c5v0.mClipName
      c5v16 = "DotLine"
      c5v17 = 13
      c5v19 = v3
      c5v19 = c5v19.DotLink
      if not c5v19 then
        p118 = 58
      else
        p118 = 55
      end
    end
    if p118 == 55 then
      c5v20 = c5v0.Filler
      if c5v20 then
        p118 = 57
      else
        p118 = 56
      end
    end
    if p118 == 56 then
      c5v20 = c5v0.Title
      p118 = 57
    end
    if p118 == 57 then
      c5v19 = not c5v20
      p118 = 58
    end
    if p118 == 58 then
      if c5v19 == true then
        p118 = 60
      else
        p118 = 59
      end
    end
    if p118 == 59 then
      c5v18 = false
      p118 = 61
    end
    if p118 == 60 then
      c5v18 = true
      p118 = 61
    end
    if p118 == 61 then
      c5v13:Makeposshield(c5v15, c5v16, c5v17, c5v18)
      c5v13 = c5v0.Filler
      if c5v13 then
        p118 = 63
      else
        p118 = 62
      end
    end
    if p118 == 62 then
      c5v13 = c5v0.Title
      if not c5v13 then
        p118 = 64
      else
        p118 = 63
      end
    end
    if p118 == 63 then
      c5v13 = v3
      c5v13 = c5v13.mMovie
      c5v16 = c5v0.mClipName
      c5v17 = ".NewValue"
      c5v15 = c5v16 .. c5v17
      c5v16 = 36
      c5v17 = ""
      c5v13:SetStringVariable(c5v15, c5v16, c5v17)
      do return end
    end
    if p118 == 64 then
      c5v13 = v3
      c5v13 = c5v13.DotLink
      if not c5v13 then
        p118 = 68
      else
        p118 = 65
      end
    end
    if p118 == 65 then
      c5v13 = v3
      c5v13 = c5v13.Width
      if c5v13 == nil then
        p118 = 68
      else
        p118 = 66
      end
    end
    if p118 == 66 then
      c5v13 = v3
      c5v13 = c5v13.mMovie
      c5v16 = c5v0.mClipName
      c5v17 = ".Label"
      c5v15 = c5v16 .. c5v17
      c5v16 = 40
      c5v13 = c5v13:GetNumberVariable(c5v15, c5v16)
      c5v14 = v3
      c5v14 = c5v14.mMovie
      c5v17 = c5v0.mClipName
      c5v18 = ".NewValue"
      c5v16 = c5v17 .. c5v18
      c5v17 = 40
      c5v14 = c5v14:GetNumberVariable(c5v16, c5v17)
      c5v15 = u0
      c5v15 = c5v15.Round
      c5v18 = v3
      c5v18 = c5v18.Width
      c5v20 = c5v13 + c5v14
      c5v19 = c5v20 + 10
      c5v17 = c5v18 - c5v19
      c5v16 = c5v17 / 5
      c5v15 = c5v15(c5v16)
      c5v16 = c5v15 * 5
      c5v17 = v3
      c5v17 = c5v17.mMovie
      c5v20 = c5v0.mClipName
      c5v21 = ".DotLine"
      c5v19 = c5v20 .. c5v21
      c5v20 = "TileRepeats"
      c5v22 = 1
      c5v23 = 1
      c5v24 = 1
      c5v17:Name__e243d995(c5v19, c5v20, c5v15, c5v22, c5v23, c5v24)
      c5v17 = v3
      c5v17 = c5v17.mMovie
      c5v19 = c5v0.mClipName
      c5v20 = "DotLine"
      c5v21 = 14
      c5v17:Name__52c1b74e(c5v19, c5v20, c5v21, c5v16)
      c5v17 = v3
      c5v17 = c5v17.mMovie
      c5v19 = c5v0.mClipName
      c5v20 = "DotLine"
      c5v21 = 15
      c5v22 = 5
      c5v17:Name__52c1b74e(c5v19, c5v20, c5v21, c5v22)
      c5v17 = v3
      c5v17 = c5v17.mMovie
      c5v19 = c5v0.mClipName
      c5v20 = "DotLine"
      c5v21 = 12
      c5v22 = 10
      c5v17:Name__52c1b74e(c5v19, c5v20, c5v21, c5v22)
      c5v17 = v3
      c5v17 = c5v17.mMovie
      c5v19 = c5v0.mClipName
      c5v20 = "DotLine"
      c5v21 = 0
      c5v24 = v3
      c5v24 = c5v24.mMovie
      c5v27 = c5v0.mClipName
      c5v28 = ".Label"
      c5v26 = c5v27 .. c5v28
      c5v27 = 0
      c5v24 = c5v24:GetNumberVariable(c5v26, c5v27)
      c5v23 = c5v24 + c5v13
      c5v22 = c5v23 + 5
      c5v17:Name__52c1b74e(c5v19, c5v20, c5v21, c5v22)
      c5v18 = v3
      c5v18 = c5v18.DotLinkMat
      c5v17 = IsNull
      c5v17 = c5v17(c5v18)
      if c5v17 then
        p118 = 68
      else
        p118 = 67
      end
    end
    if p118 == 67 then
      c5v17 = v3
      c5v17 = c5v17.mMovie
      c5v20 = c5v0.mClipName
      c5v21 = ".DotLine"
      c5v19 = c5v20 .. c5v21
      c5v20 = v3
      c5v20 = c5v20.DotLinkMat
      c5v17:OverrideMaterial(c5v19, c5v20)
      p118 = 68
    end
    if p118 == 68 then
      do return end
    end
  end
  v3.mElementDrawCallback = v4
  v4 = v3.Redraw
  v3._list_Redraw = v4
  v4 = function(c6v0, c6v1, c6v2, c6v3)
    c6v0:Populate()
    c6v0:_list_Redraw(c6v1, c6v2, c6v3)
    do return end
  end
  v3.Redraw = v4
  v4 = function(c7v0, c7v1)
    do return end
  end
  v3.SetupPreInterpolationValues = v4
  v4 = v3.DefaultAlphaInterpolation
  v3.GetInterpolationProperties = v4
  v4 = function(c8v0)
    local c8v1, c8v2, c8v3, c8v4, c8v5, c8v6, c8v7, c8v8, c8v9, c8v10, c8v11, c8v12
    c8v1 = 0
    c8v4 = 1
    c8v5 = c8v0.mElements
    c8v2 = #c8v5
    c8v3 = 1
    for c8v4 = c8v4, c8v2, c8v3 do
      c8v6 = c8v0.mElements
      c8v5 = c8v6[c8v4]
      c8v6 = c8v5.Filler
      if c8v6 then
        c8v1 = c8v1 + 10
      else
        c8v6 = c8v0.mMovie
        c8v8 = c8v5.mClipName
        c8v9 = 15
        c8v6 = c8v6:GetNumberVariable(c8v8, c8v9)
        c8v8 = c8v0.mOriginalElementHeight
        c8v7 = c8v6 - c8v8
        c8v9 = c8v0.mForcedVerticalSeparation
        c8v8 = c8v1 + c8v9
        c8v9 = u0
        c8v9 = c8v9.Ternary
        c8v11 = 0
        if c8v7 <= c8v11 then
          c8v10 = false
        else
          c8v10 = true
        end
        c8v11 = c8v7 + 3
        c8v12 = 0
        c8v9 = c8v9(c8v10, c8v11, c8v12)
        c8v1 = c8v8 + c8v9
      end
    end
    do return c8v1 end
  end
  v3.GetHeight = v4
  v4 = function(c9v0, c9v1)
    local c9v2, c9v3, c9v4, c9v5, c9v6, c9v7, c9v8, c9v9, c9v10, c9v11, c9v12, c9v13
    c9v2 = c9v0.mInitialY
    c9v5 = 1
    c9v6 = c9v1.Id
    c9v3 = c9v6 - 1
    c9v4 = 1
    for c9v5 = c9v5, c9v3, c9v4 do
      c9v7 = c9v0.mElements
      c9v6 = c9v7[c9v5]
      c9v6 = c9v6.Filler
      if c9v6 then
        c9v6 = u0
        c9v6 = c9v6.Ternary
        c9v7 = c9v0.mGrowsUpwards
        c9v8 = 10
        c9v9 = -10
        c9v6 = c9v6(c9v7, c9v8, c9v9)
        c9v2 = c9v2 + c9v6
      else
        c9v6 = c9v0.mMovie
        c9v9 = c9v0.mElements
        c9v8 = c9v9[c9v5]
        c9v8 = c9v8.mClipName
        c9v9 = 15
        c9v6 = c9v6:GetNumberVariable(c9v8, c9v9)
        c9v8 = c9v0.mOriginalElementHeight
        c9v7 = c9v6 - c9v8
        c9v9 = c9v0.mForcedVerticalSeparation
        c9v10 = u0
        c9v10 = c9v10.Ternary
        c9v12 = 0
        if c9v7 <= c9v12 then
          c9v11 = false
        else
          c9v11 = true
        end
        c9v12 = c9v7 + 3
        c9v13 = 0
        c9v10 = c9v10(c9v11, c9v12, c9v13)
        c9v8 = c9v9 + c9v10
        c9v9 = u0
        c9v9 = c9v9.Ternary
        c9v10 = c9v0.mGrowsUpwards
        c9v12 = -c9v8
        c9v8 = c9v9(c9v10, c9v8, c9v12)
        c9v2 = c9v2 + c9v8
      end
    end
    do return c9v2 end
  end
  v3.CalculateY = v4
  v4 = function(c11v0)
    local c11v1, c11v2, c11v3, c11v4, c11v5, c11v6, c11v7, c11v8, c11v9, c11v10, c11v11, c11v12, c11v13, c11v14, c11v15, c11v16, c11v17, c11v18, c11v19, c11v20, c11v22, c11v23, c11v24, c11v25, c11v26, c11v27, c11v28, c11v29, c11v30
    c11v3 = true
    c11v4 = true
    c11v0:RemoveElements(c11v3, c11v4)
    c11v1 = {}
    c11v2 = false
    c11v3 = false
    c11v4 = false
    c11v5 = u0
    c11v5 = c11v5.Ternary
    c11v6 = c11v0.mGrowsUpwards
    c11v7 = 1
    c11v8 = 0
    c11v5 = c11v5(c11v6, c11v7, c11v8)
    c11v6 = c11v5 + 1
    c11v7 = c11v6 + 1
    c11v8 = c11v7 + 1
    c11v9 = c11v8 + 1
    c11v10 = c11v9 + 1
    c11v11 = c11v10 + 1
    c11v12 = c11v11 + 1
    c11v13 = u0
    c11v13 = c11v13.Ternary
    c11v14 = c11v0.mGrowsUpwards
    c11v15 = 0
    c11v13 = c11v13(c11v14, c11v15, c11v12)
    c11v14 = u0
    c11v14 = c11v14.Ternary
    c11v15 = c11v0.mGrowsUpwards
    c11v17 = 0
    c11v14 = c11v14(c11v15, c11v12, c11v17)
    c11v15 = u0
    c11v15 = c11v15.Ternary
    c11v16 = c11v0.mGrowsUpwards
    c11v17 = 0
    c11v20 = c11v0.mStats
    c11v19 = #c11v20
    c11v20 = c11v12 + 1
    c11v18 = c11v19 * c11v20
    c11v15 = c11v15(c11v16, c11v17, c11v18)
    c11v16 = false
    c11v17 = ipairs
    c11v18 = c11v0.mStats
    c11v17, c11v18, c11v19 = c11v17(c11v18)
    for c11v20, c11v21 in c11v17, c11v18, c11v19 do
      c11v27 = c11v0.mSort
      c11v27 = c11v11 + c11v15
      c11v26.Order = c11v27
      c11v29 = { Label = "", Previous = nil, Filler = true, Order = nil }
      c11v30 = c11v11 + c11v15
      c11v29.Order = c11v30
      c11v27 = table.insert
      c11v27(c11v1, c11v29)
      c11v27 = c11v5 + c11v15
      c11v26.Order = c11v27
      c11v2 = true
      c11v27 = string.find
      c11v29 = "_RESIST$"
      c11v27 = c11v27(c11v25, c11v29)
      c11v27 = c11v7 + c11v15
      c11v26.Order = c11v27
      c11v3 = true
      c11v27 = string.find
      c11v29 = "EmbedDT_"
      c11v27 = c11v27(c11v25, c11v29)
      c11v27 = c11v10 + c11v15
      c11v26.Order = c11v27
      c11v27 = string.find
      c11v29 = "Embed"
      c11v27 = c11v27(c11v25, c11v29)
      c11v27 = c11v8 + c11v15
      c11v26.Order = c11v27
      c11v27 = string.find
      c11v29 = "DT_"
      c11v27 = c11v27(c11v25, c11v29)
      c11v27 = string.find
      c11v29 = "Power_"
      c11v27 = c11v27(c11v25, c11v29)
      c11v27 = c11v9 + c11v15
      c11v26.Order = c11v27
      c11v4 = true
      c11v27 = c11v6 + c11v15
      c11v26.Order = c11v27
      c11v27 = table.insert
      c11v27(c11v1, c11v26)
      c11v27 = c11v26.ForceOrder
      if c11v27 ~= nil then
        c11v28 = c11v26.ForceOrder
        c11v27 = c11v28 + c11v15
        c11v26.Order = c11v27
        c11v27 = c11v26.ForceOrder
        if c11v27 == c11v5 then
          c11v2 = true
        else
          c11v27 = c11v26.ForceOrder
          if c11v27 == c11v7 then
            c11v3 = true
          else
            c11v27 = c11v26.ForceOrder
            if c11v27 == c11v9 then
              c11v4 = true
            end
          end
        end
      end
      c11v22 = c11v0.mSort
      if c11v22 then
        if c11v2 then
          c11v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
          c11v25 = c11v6 + c11v15
          c11v24.Order = c11v25
          c11v22 = table.insert
          c11v22(c11v1, c11v24)
        end
        if c11v3 then
          c11v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
          c11v25 = c11v7 + c11v15
          c11v24.Order = c11v25
          c11v22 = table.insert
          c11v22(c11v1, c11v24)
        end
        if c11v4 then
          c11v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
          c11v25 = c11v9 + c11v15
          c11v24.Order = c11v25
          c11v22 = table.insert
          c11v22(c11v1, c11v24)
        end
      end
      c11v16 = true
      c11v22 = u0
      c11v22 = c11v22.Ternary
      c11v23 = c11v0.mGrowsUpwards
      c11v25 = c11v12 + 1
      c11v24 = c11v25 + c11v15
      c11v26 = c11v12 + 1
      c11v25 = c11v26 - c11v15
      c11v15 = c11v22(c11v23, c11v24, c11v25)
      for c11v20, c11v21 in c11v17, c11v18, c11v19 do
        c11v17 = c11v0.mSort
        if c11v17 then
          c11v17 = table.sort
          c11v19 = function(c10v0, c10v1)
            local c10v2, c10v3, c10v4
            c10v2 = c10v0.Order
            c10v3 = c10v1.Order
            if c10v2 ~= c10v3 then
              c10v3 = c10v0.Order
              c10v4 = c10v1.Order
              if c10v4 <= c10v3 then
                c10v2 = false
              else
                c10v2 = true
              end
              do return c10v2 end
            end
            c10v3 = c10v0.Label
            c10v4 = c10v1.Label
            if c10v4 <= c10v3 then
              c10v2 = false
            else
              c10v2 = true
            end
            do return c10v2 end
          end
          c11v17(c11v1, c11v19)
        end
        c11v17 = 0
        c11v18 = pairs
        c11v18, c11v19, c11v20 = c11v18(c11v1)
        for c11v21, c11v22 in c11v18, c11v19, c11v20 do
          c11v23 = ResetLineCount
          c11v24 = 0
          c11v23(c11v24)
          c11v17 = c11v17 + 1
          c11v22.Id = c11v17
          c11v26 = true
          c11v0:AddElement(c11v22, c11v26)
        end
        do return end
      end
      if c11v16 then
        c11v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
        c11v25 = u0
        c11v25 = c11v25.Ternary
        c11v26 = c11v0.mGrowsUpwards
        c11v28 = c11v14 - c11v15
        c11v25 = c11v25(c11v26, c11v15, c11v28)
        c11v24.Order = c11v25
        c11v22 = table.insert
        c11v22(c11v1, c11v24)
      end
      c11v22 = u1
      c11v23 = c11v21.mName
      c11v22 = c11v22(c11v23)
      if not c11v22 then
        c11v23 = c11v0.mStats
        c11v22 = #c11v23
        c11v23 = 1
        if c11v23 < c11v22 then
          c11v24 = { Label = nil, Previous = nil, Title = true, Order = nil }
          c11v26 = "<p><font color=\""
          c11v27 = c11v0.GroupTitleColor
          c11v28 = "\"><b>"
          c11v29 = c11v21.mName
          c11v30 = "</b></font></p>"
          c11v25 = c11v26 .. c11v27 .. c11v28 .. c11v29 .. c11v30
          c11v24.Label = c11v25
          c11v25 = c11v13 + c11v15
          c11v24.Order = c11v25
          c11v22 = table.insert
          c11v22(c11v1, c11v24)
        end
      end
      c11v22 = pairs
      c11v23 = c11v21.mStats
      c11v22, c11v23, c11v24 = c11v22(c11v23)
    end
  end
  v3.Populate = v4
  do return v3 end
end

function proto_12(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11)
  local v12, v14, v15
  if v5 ~= nil then
    v12 = u0
    v12 = v12.FormatNumber
    v14 = v7 or 1
    v15 = false
    v5 = v12(v5, v14, v15)
  end
  v12 = { DisplayValue = nil, StatValue = nil, TextOnly = nil, TextIfOneNil = nil, ToolTip = nil, ToolTipValue = nil, ToolTipLabel = nil, SecondaryToolTips = nil, HideStat = nil, HeaderOverride = nil, SmallerIsBetter = nil }
  v12.DisplayValue = v0
  v12.StatValue = v1
  v12.TextOnly = v2
  v12.TextIfOneNil = v3
  v12.ToolTip = v4
  v12.ToolTipValue = v5
  v12.ToolTipLabel = v6
  v12.SecondaryToolTips = v8
  v12.HideStat = v9
  v12.HeaderOverride = v10
  v12.SmallerIsBetter = v11
  do return v12 end
end

function proto_13(v0, v1)
  local v2, v3, v4, v5, v6, v8, v9, v10, v11, v13
  v2 = 9
  if v1 == 1 then
    v2 = 11
  else
    if v1 == -1 then
      v2 = 12
    end
  end
  v4 = "<font color=\"#"
  v9 = string.format
  v10 = "%X"
  v11 = u0
  v11 = v11.GetColor
  v13 = true
  v5 = v9(v10, v11(v2, v13))
  v6 = "\"><b>"
  v8 = "</b></font>"
  v3 = v4 .. v5 .. v6 .. v0 .. v8
  do return v3 end
end

function proto_14(v0, v1, v2)
  local v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28
  v24 = string.find
  v26 = "AMOUNT"
  v24 = v24(v22, v26)
  v18 = 0
  v24 = 0
  v24 = 0
  v3 = 3
  v15[v22] = v23
  v23 = u2
  v21 = v23(v5, v18)
  v25 = true
  v22 = v0:GetLocalized(v13, v25, v15)
  v4 = v4 .. v6 .. v21 .. v22
  v6 = "\r\n\r\n"
  v4 = ""
  v7 = "<MINI_DIAMOND> "
  v8 = true
  v5 = v0:GetLocalized(v7, v8)
  v6 = ""
  v7 = nil
  v8 = u0
  v8 = v8.CopyTableRecursive
  v7 = v8(v1)
  v8 = ipairs
  v8, v9, v10 = v8(v2)
  for v11, v12 in v8, v9, v10 do
    v13 = v12.VARS
    if v13 ~= nil then
      v14 = v12.VARS
      v13 = v14.AMOUNT
      if v13 ~= nil then
        v13 = v7[v11]
        if v13 == nil then
          v13 = u0
          v13 = v13.CopyTableRecursive
          v13 = v13(v12)
          v7[v11] = v13
          v13 = v7[v11]
          v13 = v13.VARS
          v14 = 0
          v13.AMOUNT = v14
        end
      end
    end
  end
  for v11, v12 in v8, v9, v10 do
  end
  v8 = ipairs
  v8, v9, v10 = v8(v7)
  v24 = v2[v11]
  if v24 == nil then
    v18 = 1
  else
    v25 = v2[v11]
    v25 = v25.VARS
    v24 = v25[v22]
    if not ((v24 == nil or v23 == nil)) then
      if v23 < v24 then
        v18 = -1
      else
        if v24 < v23 then
          v18 = 1
        end
      end
    end
  end
  v18 = v18 * v17
  v24 = v12.skipIndicatorComparison
  if v18 == 0 then
    v3 = 0
  else
    v24 = u0
    v24 = v24.Ternary
    v26 = 0
    if v18 <= v26 then
      v25 = false
    else
      v25 = true
    end
    v26 = 1
    v27 = 2
    v3 = v24(v25, v26, v27)
  end
  v24 = u0
  v24 = v24.Ternary
  v26 = 0
  if v18 <= v26 then
    v25 = false
  else
    v25 = true
  end
  v26 = 1
  v27 = 2
  v3 = v24(v25, v26, v27)
  v24 = ""
  v25 = v12.ShowAsPercent
  if v25 then
    v25 = u1
    v24 = v25(v23)
  else
    v25 = u0
    v25 = v25.FormatNumber
    v27 = 1
    v28 = false
    v24 = v25(v23, v27, v28)
  end
  v25 = u2
  v25 = v25(v24, v18)
  v15[v22] = v25
  for v11, v12 in v8, v9, v10 do
    do return v4, v3 end
  end
  v13 = v12.TEXT
  v14 = v12.VARS
  v15 = {}
  if v2 == nil then
    v16 = false
  else
    v16 = true
  end
  v17 = u0
  v17 = v17.Ternary
  v18 = v12.comparisonFlipped
  v19 = -1
  v20 = 1
  v17 = v17(v18, v19, v20)
  v18 = v12.skipFormatting
  if v18 then
    v5 = ""
    v6 = "\r\n"
  end
  v18 = 0
  v19 = pairs
  v19, v20, v21 = v19(v14)
end

function proto_15(v0)
  local v1, v2, v3, v4, v5, v6, v8
  v1 = WeakResource
  v2 = "/Lotus/Weapons/Tenno/LotusLongGun"
  v1 = v1(v2)
  v2 = WeakResource
  v3 = "/Lotus/Weapons/Sentients/OperatorAmplifiers/OperatorAmpWeapon"
  v2 = v2(v3)
  v3 = WeakResource
  v4 = "/Lotus/Weapons/Tenno/Archwing/Primary/ArchGun"
  v3 = v3(v4)
  v4 = WeakResource
  v5 = "/Lotus/Weapons/CrewShip/RailjackWeapon"
  v4 = v4(v5)
  v5 = WeakResource
  v6 = "/Lotus/Types/Friendly/Pets/BeastPetMeleeWeaponBase"
  v5 = v5(v6)
  v6 = v0:IsA(v1)
  if not v6 then
    v8 = gLotusPistolType
    v6 = v0:IsA(v8)
    if not v6 then
      v6 = v0:IsA(v3)
      if not v6 then
        v8 = gLotusMeleeWeaponType
        v6 = v0:IsA(v8)
        if not v6 then
          v6 = v0:IsA(v4)
          if not v6 then
            v6 = v0:IsA(v2)
            if not v6 then
              v6 = v0:IsA(v5)
            end
          end
        end
      end
    end
  end
  do return v6 end
end

function proto_16(v0)
  local v3
  v3 = gPowerSuitType
  do return v0:IsA(v3) end
end

function proto_17(v0, v1, v2)
  local v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32
  v3 = IsNull
  v3 = v3(v1)
  v3 = IsNull
  v3 = v3(v2)
  v3 = {}
  v4 = { mName = nil, mStats = nil, mIsMelee = false }
  v7 = "/Lotus/Language/Labels/RAILJACKUpper"
  v8 = false
  v5 = v0:GetLocalized(v7, v8)
  v4.mName = v5
  v5 = {}
  v4.mStats = v5
  v5 = v4.mStats
  v6 = v1:DamageControl()
  v7 = v1:InventoryControl()
  v8 = v1:MotionControl()
  v9 = v1:GetMaxHealth()
  v10 = u0
  v11 = nil
  v13 = nil
  v14 = true
  v10 = v10(v11, v9, v13, v14)
  v5.RailjackHealth = v10
  v10 = v6:GetMaxShield()
  v11 = v6:Name__e875637d()
  v12 = v11 / v10
  v11 = v12 * 100
  v12 = v6:GetShieldRechargeDelay()
  v13 = u0
  v14 = nil
  v16 = nil
  v17 = true
  v13 = v13(v14, v10, v16, v17)
  v5.Shield = v13
  v13 = u0
  v16 = "/Lotus/Language/Game/UNIT_PERCENT_PER_SECOND"
  v17 = false
  v18 = { COUNT = nil }
  v19 = u1
  v19 = v19.FormatNumber
  v21 = 1
  v22 = false
  v19 = v19(v11, v21, v22)
  v18.COUNT = v19
  v14 = v0:GetLocalized(v16, v17, v18)
  v15 = u1
  v15 = v15.Round
  v17 = 1
  v15 = v15(v11, v17)
  v16 = nil
  v17 = true
  v13 = v13(v14, v15, v16, v17)
  v5.ShieldRechargeRate = v13
  v13 = u0
  v16 = "/Lotus/Language/Menu/ProgressSeconds"
  v17 = false
  v18 = { CURRENT = nil }
  v19 = u1
  v19 = v19.FormatNumber
  v21 = 1
  v22 = false
  v19 = v19(v12, v21, v22)
  v18.CURRENT = v19
  v14 = v0:GetLocalized(v16, v17, v18)
  v15 = -v12
  v16 = nil
  v17 = true
  v13 = v13(v14, v15, v16, v17)
  v5.ShieldRechargeDelay = v13
  v13 = v6:GetArmourRating()
  v15 = 100
  v16 = v6:GetArmourResistance()
  v14 = v15 * v16
  v15 = u0
  v16 = nil
  v18 = nil
  v19 = true
  v20 = nil
  v15 = v15(v16, v13, v18, v19, v20, v14)
  v5.Armor = v15
  v18 = 0
  v16 = v8:GetMaxVelocity(v18)
  v17 = v1:GetZoneScale()
  v15 = v16 / v17
  v18 = v15.x
  v19 = v15.y
  v17 = v18 + v19
  v18 = v15.z
  v16 = v17 + v18
  v15 = v16 / 3
  v16 = u0
  v19 = "/Lotus/Language/Game/UNIT_METER_PER_SECOND"
  v20 = false
  v21 = { COUNT = nil }
  v22 = u1
  v22 = v22.FormatNumber
  v24 = 0
  v25 = false
  v22 = v22(v15, v24, v25)
  v21.COUNT = v22
  v17 = v0:GetLocalized(v19, v20, v21)
  v19 = nil
  v20 = true
  v16 = v16(v17, v15, v19, v20)
  v5.Engines = v16
  v18 = v8:Name__f0b747d5()
  v18 = v18.x
  v19 = 152
  v20 = v2:GetType()
  v16 = v7:GetUpgradeModifiedValue(v18, v19, v20, v2)
  v17 = u0
  v19 = "x"
  v20 = u1
  v20 = v20.FormatNumber
  v22 = 1
  v23 = false
  v20 = v20(v16, v22, v23)
  v18 = v19 .. v20
  v20 = nil
  v21 = true
  v17 = v17(v18, v16, v20, v21)
  v5.EngineBoost = v17
  v18 = 3
  v19 = 5
  v20 = 6
  v21 = 4
  v17 = {v18, v19, v20, v21}
  v20 = 1
  v18 = #v17
  v19 = 1
  for v20 = v20, v18, v19 do
    v21 = v17[v20]
    v24 = 100
    v25 = 42
    v26 = nil
    v27 = nil
    v22 = v7:GetUpgradeModifiedValue(v24, v25, v26, v27, v21)
    if v22 ~= 100 then
      v26 = u1
      v26 = v26.FormatNumber
      v27 = 100 - v22
      v28 = 1
      v29 = false
      v24 = v26(v27, v28, v29)
      v25 = "%"
      v23 = v24 .. v25
      v24 = u2
      v24 = v24.GetDamageTypeTag
      v24 = v24(v21)
      v25 = u0
      v28 = nil
      v29 = true
      v25 = v25(v23, v22, v28, v29)
      v5[v24] = v25
    end
  end
  if v3 then
    do return end
  end
  v20 = 0
  v21 = 144
  v22 = nil
  v23 = nil
  v24 = 23
  v18 = v7:GetUpgradeModifiedValue(v20, v21, v22, v23, v24)
  if v18 ~= 0 then
    v22 = u1
    v22 = v22.FormatNumber
    v23 = v18 * 100
    v24 = 1
    v25 = false
    v20 = v22(v23, v24, v25)
    v21 = "%"
    v19 = v20 .. v21
    v20 = u0
    v23 = nil
    v24 = true
    v20 = v20(v19, v18, v23, v24)
    v5.ElementRedirection = v20
  end
  v19 = v7:GetcheckCollision()
  v20 = u0
  v21 = nil
  v23 = nil
  v24 = true
  v20 = v20(v21, v19, v23, v24)
  v5.CargoCapacity = v20
  v20 = table.insert
  v20(v3, v4)
  v20 = { mName = nil, mStats = nil, mIsMelee = false }
  v23 = "/Lotus/Language/Labels/RAILJACK_BATTLE_MOD"
  v24 = false
  v21 = v0:GetLocalized(v23, v24)
  v20.mName = v21
  v21 = {}
  v20.mStats = v21
  v21 = v20.mStats
  v24 = 1
  v25 = 10
  v26 = v2:GetType()
  v22 = v7:GetUpgradeModifiedValue(v24, v25, v26, v2)
  v23 = u0
  v27 = u1
  v27 = v27.FormatNumber
  v28 = v22 * 100
  v29 = 0
  v30 = false
  v25 = v27(v28, v29, v30)
  v26 = "%"
  v24 = v25 .. v26
  v26 = nil
  v27 = true
  v23 = v23(v24, v22, v26, v27)
  v21.Railjack_Power_Strength = v23
  v25 = 1
  v26 = 9
  v27 = v2:GetType()
  v23 = v7:GetUpgradeModifiedValue(v25, v26, v27, v2)
  v24 = u0
  v28 = u1
  v28 = v28.FormatNumber
  v29 = v23 * 100
  v30 = 0
  v31 = false
  v26 = v28(v29, v30, v31)
  v27 = "%"
  v25 = v26 .. v27
  v27 = nil
  v28 = true
  v24 = v24(v25, v23, v27, v28)
  v21.Railjack_Power_Range = v24
  v26 = 1
  v27 = 3
  v28 = v2:GetType()
  v24 = v7:GetUpgradeModifiedValue(v26, v27, v28, v2)
  v25 = u0
  v29 = u1
  v29 = v29.FormatNumber
  v30 = v24 * 100
  v31 = 0
  v32 = false
  v27 = v29(v30, v31, v32)
  v28 = "%"
  v26 = v27 .. v28
  v28 = nil
  v29 = true
  v25 = v25(v26, v24, v28, v29)
  v21.Railjack_Power_Duration = v25
  v25 = table.insert
  v25(v3, v20)
  do return v3 end
end

function proto_18(v0, v1, v2, v3, v4)
  local v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45
  v25 = gSentinelPowerSuitType
  v23 = v2:IsA(v25)
  v28 = nil
  if v18 then
    v31 = v27 - 1
    v28 = v2:GetAbilityByIndex(v31)
  else
    v31 = v27 - 1
    v28 = v2:Name__06c22bff(v31)
  end
  v29 = IsNull
  v29 = v29(v28)
  if not v29 then
    v30 = "Ability"
    v29 = v30 .. v27
    v32 = v28:GetLocalizeTag()
    v32 = v32:c_str()
    v33 = false
    v30 = v0:GetLocalized(v32, v33)
    v21[v29] = v30
    v30 = "AbilityDescription"
    v29 = v30 .. v27
    v32 = v28:GetLocalizeDescTag()
    v32 = v32:c_str()
    v33 = true
    v30 = v0:GetLocalized(v32, v33)
    v21[v29] = v30
    v30 = "AbilityIcon"
    v29 = v30 .. v27
    v30 = v28:GetIconTexture()
    v21[v29] = v30
    v30 = "AbilityType"
    v29 = v30 .. v27
    v21[v29] = v28
  else
    v30 = "Ability"
    v29 = v30 .. v27
    v30 = nil
    v21[v29] = v30
    v30 = "AbilityIcon"
    v29 = v30 .. v27
    v30 = nil
    v21[v29] = v30
  end
  v23 = 0
  if v3 then
    v24 = v2:GetUnmodifiedMaxEnergy()
    v27 = 100
    v2:SetMaxEnergy(v27)
    v23 = v2:GetMaxEnergy()
    v2:SetMaxEnergy(v24)
  else
    v23 = v2:GetMaxEnergy()
  end
  v24 = v23
  v27 = WeakResource
  v28 = "/Lotus/Powersuits/Priest/PriestBaseSuit"
  v25 = v2:IsA(v27(v28))
  if not v25 then
    v26 = v2:GetInitialEnergy()
    v25 = math.min
    v24 = v25(v26, v24)
  end
  v25 = u2
  v26 = nil
  v28 = nil
  v29 = true
  v30 = nil
  v25 = v25(v26, v23, v28, v29, v30, v24)
  v21.Power = v25
  v25 = v21.Power
  v27 = { TEXT = "/Lotus/Language/Stats/TIP_PowerStartingEnergy", VARS = nil, skipIndicatorComparison = true }
  v28 = { AMOUNT = nil }
  v28.AMOUNT = v24
  v27.VARS = v28
  v26 = {v27}
  v25.SecondaryToolTips = v26
  v25 = IsNull
  v25 = v25(v17)
  if not v25 then
    v27 = v2:GetEnergyRegenSpeed()
    v28 = 106
    v25 = v17:GetUpgradeModifiedValue(v27, v28)
    v27 = v21.Power
    v27 = v27.SecondaryToolTips
    v28 = { TEXT = "/Lotus/Language/Stats/TIP_PowerRecovery", VARS = nil }
    v29 = { AMOUNT = nil }
    v29.AMOUNT = v25
    v28.VARS = v29
    v26 = table.insert
    v26(v27, v28)
  end
  if not v3 then
    v27 = "/Lotus/Language/Menu/MenuOperator"
    v28 = false
    v25 = v0:GetLocalized(v27, v28)
    v4.mName = v25
    v25 = {}
    v26 = nil
    v27 = nil
    v28 = IsNull
    v28 = v28(v17)
    if not v28 then
      v31 = 0
      v32 = 12
      v29 = v17:GetUpgradeModifiedValue(v31, v32)
      v28 = v29 / 50000
      v26 = v28 * 100
      v31 = v2:Name__dee00179()
      v32 = 11
      v29 = v17:GetUpgradeModifiedValue(v31, v32)
      v31 = v28 / v29
      v30 = 1 - v31
      v27 = v30 * 100
    end
    if v26 ~= nil then
      v28 = u2
      v29 = u4
      v29 = v29(v26)
      v28 = v28(v29, v26)
      v25.UltInitCharge = v28
      if v27 ~= nil then
        v28 = v25.UltInitCharge
        v29 = {}
        v28.SecondaryToolTips = v29
        v29 = v25.UltInitCharge
        v29 = v29.SecondaryToolTips
        v30 = { TEXT = "/Lotus/Language/Stats/TIP_UltChargeRate", VARS = nil, ShowAsPercent = true }
        v31 = { AMOUNT = nil }
        v31.AMOUNT = v27
        v30.VARS = v31
        v28 = table.insert
        v28(v29, v30)
      end
    end
    v28 = nil
    v29 = _T.UltimateUpgradeInfo
    if v29 ~= nil then
      v29 = _T.UltimateUpgradeInfo.Ability
      if v29 ~= nil then
        v29 = Resource
        v30 = _T.UltimateUpgradeInfo.Ability
        v29 = v29(v30)
        v28 = v29:GetScript()
      end
    end
    v29 = IsNull
    v29 = v29(v28)
    if not v29 then
      v32 = Symbol
      v33 = "GetDuration"
      v32 = v32(v33)
      v33 = true
      v1:RunScript(v28, v32, v33)
      v29 = _T.UltimateUpgradeInfo.Duration
      if v29 ~= nil then
        v29 = _T.UltimateUpgradeInfo.Duration
        v30 = u2
        v31 = u5
        v31 = v31(v29)
        v30 = v30(v31, v29)
        v25.UltDuration = v30
        v30 = _T.UltimateUpgradeInfo
        v31 = nil
        v30.Duration = v31
      end
    end
    v29 = { mName = nil, mIsMelee = false, mBehaviorIndex = 0, mStats = nil }
    v30 = string.upper
    v33 = "/Lotus/Language/OldPeace/Antique"
    v34 = false
    v30 = v30(v0:GetLocalized(v33, v34))
    v29.mName = v30
    v29.mStats = v25
    v20 = v29
  end
  v27 = 1
  v25 = 4
  v26 = 1
  for v27 = v27, v25, v26 do
  end
  v24 = 0
  v25 = 2
  v26 = 1
  v27 = 3
  v28 = 4
  v29 = 5
  v30 = 6
  v31 = 7
  v32 = 8
  v33 = 14
  v23 = {v24, v25, v26, v27, v28, v29, v30, v31, v32, v33}
  v24 = v21.Armor
  v25 = {}
  v24.SecondaryToolTips = v25
  v26 = 1
  v24 = #v23
  v25 = 1
  for v26 = v26, v24, v25 do
    v27 = v23[v26]
    v30 = 100
    v31 = 42
    v32 = v2:GetType()
    v28 = v17:GetUpgradeModifiedValue(v30, v31, v32, v2, v27)
    if v28 ~= 100 then
      v28 = 100 - v28
      v32 = u0
      v32 = v32.FormatNumber
      v34 = 1
      v35 = false
      v30 = v32(v28, v34, v35)
      v31 = "%"
      v29 = v30 .. v31
      v31 = v21.Armor
      v31 = v31.SecondaryToolTips
      v32 = { TEXT = nil, VARS = nil }
      v34 = "/Lotus/Language/Stats/TIP_"
      v37 = u3
      v37 = v37.GetDamageTypeTag
      v35 = v37(v27)
      v36 = "_RESIST"
      v33 = v34 .. v35 .. v36
      v32.TEXT = v33
      v33 = { AMOUNT = nil }
      v33.AMOUNT = v28
      v32.VARS = v33
      v30 = table.insert
      v30(v31, v32)
    end
  end
  v5 = IsNull
  v5 = v5(v2)
  if v5 then
    do return end
  end
  v5 = {}
  v6 = 0
  v7 = 0
  v8 = 0
  v11 = WeakResource
  v12 = "/Lotus/Powersuits/Operator/AdultOperatorSuit"
  v9 = v2:IsA(v11(v12))
  if not v9 then
    v11 = WeakResource
    v12 = "/Lotus/Powersuits/Operator/OperatorSuit"
    v9 = v2:IsA(v11(v12))
  end
  v12 = gFlightJetPackItemType
  v10 = v2:IsA(v12)
  if v10 then
    v10 = v2:IsModular()
  end
  v11 = false
  if v10 then
    v12 = IsNull
    v12 = v12(v1)
    if v12 then
      v1 = v2:GetOwner()
      v11 = true
    end
  end
  v12 = nil
  v13 = nil
  v14 = nil
  v15 = nil
  v16 = nil
  v17 = IsNull
  v17 = v17(v1)
  if not v5 then
    v18 = _T.MenuSuitAvatar
    v17 = IsNull
    v17 = v17(v18)
    if not v17 then
      v17 = _T.MenuSuitAvatar
      v12 = v17:DamageControl()
    end
    v17 = Resource
    v18 = "/Lotus/Types/Player/TennoMainMenuDamageController"
    v17 = v17(v18)
    v18 = v2:Name__1a6427eb()
    v19 = 0
    if v19 < v18 then
      v8 = v2:Name__1a6427eb()
    else
      v19 = _T.CachedTennoAvatar
      v18 = IsNull
      v18 = v18(v19)
      if not v18 then
        v18 = _T.CachedTennoAvatar
        v8 = v18:GetMaxHealth()
      end
    end
    v18 = u0
    v18 = v18.Ternary
    v20 = v2:Name__3bba4acd()
    v21 = 0
    if v20 < v21 then
      v19 = false
    else
      v19 = true
    end
    v20 = v2:Name__3bba4acd()
    v6 = v18(v19, v20, v17:GetMaxShield())
    v18 = u0
    v18 = v18.Ternary
    v20 = v2:Name__ff0a0d5c()
    v21 = 0
    if v20 <= v21 then
      v19 = false
    else
      v19 = true
    end
    v20 = v2:Name__ff0a0d5c()
    v7 = v18(v19, v20, v17:GetArmourRating())
    v20 = true
    v13 = v17:GetShieldGateTimer(v20)
    v18 = 100
    v19 = v17:GetArmourResistance()
    v14 = v18 * v19
    if v3 then
      v18 = u1
      v8 = v18:Name__952c73e1(v8)
      v18 = u1
      v6 = v18:Name__f1628429(v6)
      v18 = u1
      v7 = v18:ModifyArmor(v7)
    end
  else
    v12 = v1:DamageControl()
    if v3 then
      v2:RemoveLevelUpgrades(v1)
    end
    v18 = v1:GetMaxHealth()
    v17 = math.floor
    v8 = v17(v18)
    v18 = v12:GetMaxShield()
    v17 = math.floor
    v6 = v17(v18)
    v18 = v12:GetArmourRating()
    v17 = math.floor
    v7 = v17(v18)
    v17 = v12:GetShield()
    v12:SetShield(v6)
    v20 = true
    v13 = v12:GetShieldGateTimer(v20)
    v12:SetShield(v17)
    v18 = 100
    v19 = v12:GetArmourResistance()
    v14 = v18 * v19
    v15 = v12:GetShieldRechargeRate()
    v16 = v12:GetShieldRechargeDelay()
  end
  v17 = IsNull
  v17 = v17(v4)
  if v17 then
    v17 = { mName = "", mStats = nil, mIsMelee = false }
    v18 = {}
    v17.mStats = v18
    v4 = v17
  end
  v17 = nil
  v18 = false
  v19 = IsNull
  v19 = v19(v1)
  if not v19 then
    v17 = v1:InventoryControl()
    if not v3 then
      v19 = u0
      v19 = v19.Ternary
      v21 = v17:IsSpaceMode()
      v20 = v21 or v11
      v21 = v17:Name__d22c79ce()
      v2 = v19(v20, v21, v17:GetActivePowerSuit())
      v18 = true
    end
  end
  v19 = nil
  v20 = nil
  v21 = v4.mStats
  v22 = u2
  v23 = nil
  v25 = nil
  v26 = true
  v22 = v22(v23, v8, v25, v26)
  v21.Health = v22
  v22 = nil
  v23 = IsNull
  v23 = v23(v17)
  if not v23 then
    v25 = 1
    v26 = 140
    v27 = v2:GetType()
    v23 = v17:GetUpgradeModifiedValue(v25, v26, v27, v2)
    if v23 == 0 then
      v28 = "<LOCKED> "
      v29 = true
      v24 = v0:GetLocalized(v28, v29)
      v25 = "0"
      v22 = v24 .. v25
    end
  end
  v23 = u2
  v26 = nil
  v27 = true
  v23 = v23(v22, v6, v26, v27)
  v21.Shield = v23
  v23 = v21.Shield
  v25 = { TEXT = "/Lotus/Language/Stats/TIP_ShieldGate", VARS = nil }
  v26 = { AMOUNT = nil }
  v26.AMOUNT = v13
  v25.VARS = v26
  v24 = {v25}
  v23.SecondaryToolTips = v24
  if v16 then
    v24 = v21.Shield
    v24 = v24.SecondaryToolTips
    v25 = { TEXT = "/Lotus/Language/Stats/TIP_PowersuitShieldRechargeDelay", VARS = nil, comparisonFlipped = true }
    v26 = { AMOUNT = nil }
    v26.AMOUNT = v16
    v25.VARS = v26
    v23 = table.insert
    v23(v24, v25)
  end
  if v15 then
    v24 = v21.Shield
    v24 = v24.SecondaryToolTips
    v25 = { TEXT = "/Lotus/Language/Stats/TIP_PowersuitShieldRechargeRate", VARS = nil }
    v26 = { AMOUNT = nil }
    v26.AMOUNT = v15
    v25.VARS = v26
    v23 = table.insert
    v23(v24, v25)
  end
  v23 = u2
  v24 = nil
  v26 = nil
  v27 = true
  v28 = nil
  v23 = v23(v24, v7, v26, v27, v28, v14)
  v21.Armor = v23
  v23 = IsNull
  v23 = v23(v17)
  v23 = IsNull
  v23 = v23(v2)
  if v23 then
    v25 = v2:GetMovementSpeedMultiplier()
    v26 = IsNull
    v26 = v26(v17)
    if not v26 then
      if v3 then
        v28 = 1
        v29 = 167
        v26 = v17:GetUpgradeModifiedValue(v28, v29)
        v27 = u2
        v28 = u0
        v28 = v28.FormatNumber
        v30 = 2
        v31 = false
        v28 = v28(v26, v30, v31)
        v30 = nil
        v31 = true
        v27 = v27(v28, v26, v30, v31)
        v21.ParkourBoost = v27
      end
      v28 = 152
      v29 = 2
      v17:AddUpgrade(v28, v29, v25)
      v26 = 1
      v27 = v17:IsSpaceMode()
      if v27 then
        v29 = 1
        v30 = 152
        v31 = v2:GetType()
        v33 = 25
        v34 = Symbol
        v35 = "ARCHWING_SPRINT_SPEED"
        v26 = v17:GetUpgradeModifiedValue(v29, v30, v31, v2, v33, v34(v35))
      else
        v29 = 1
        v30 = 152
        v26 = v17:GetUpgradeModifiedValue(v29, v30)
      end
      v29 = 152
      v30 = 2
      v17:RemoveUpgrade(v29, v30, v25)
      v27 = u2
      v28 = u0
      v28 = v28.FormatNumber
      v30 = 2
      v31 = false
      v28 = v28(v26, v30, v31)
      v30 = nil
      v31 = true
      v27 = v27(v28, v26, v30, v31)
      v21.Mult_SprintSpeed = v27
      v27 = {}
      v30 = 1
      v31 = 10
      v32 = v2:GetType()
      v28 = v17:GetUpgradeModifiedValue(v30, v31, v32, v2)
      v29 = u2
      v33 = u0
      v33 = v33.FormatNumber
      v34 = v28 * 100
      v35 = 0
      v36 = false
      v31 = v33(v34, v35, v36)
      v32 = "%"
      v30 = v31 .. v32
      v32 = nil
      v33 = true
      v29 = v29(v30, v28, v32, v33)
      v27.Power_Strength = v29
      v31 = 1
      v32 = 3
      v33 = v2:GetType()
      v29 = v17:GetUpgradeModifiedValue(v31, v32, v33, v2)
      v30 = u2
      v34 = u0
      v34 = v34.FormatNumber
      v35 = v29 * 100
      v36 = 0
      v37 = false
      v32 = v34(v35, v36, v37)
      v33 = "%"
      v31 = v32 .. v33
      v33 = nil
      v34 = true
      v30 = v30(v31, v29, v33, v34)
      v27.Power_Duration = v30
      v30 = "/Lotus/Language/Labels/AVATAR_ABILITY"
      v33 = WeakResource
      v34 = "/Lotus/Powersuits/IronFrame/IronFrameBaseSuit"
      v31 = v2:IsA(v33(v34))
      if v31 then
        v30 = "/Lotus/Language/Labels/AVATAR_SHIELD"
      else
        v33 = WeakResource
        v34 = "/Lotus/Powersuits/Garuda/GarudaBaseSuit"
        v31 = v2:IsA(v33(v34))
        if v31 then
          v30 = "/Lotus/Language/Labels/AVATAR_HEALTH_MAX"
        end
      end
      v31 = {}
      v34 = u6
      v34 = v34.AI_EFFICIENCY_SYM
      v32 = v17:Name__158ab814(v34)
      if v32 then
        v34 = { Type = nil, Tag = nil, Value = nil }
        v35 = 4
        v34.Type = v35
        v35 = u6
        v35 = v35.AI_EFFICIENCY_SYM
        v34.Tag = v35
        v37 = u6
        v37 = v37.AI_EFFICIENCY_SYM
        v35 = v17:Name__e470b32b(v37)
        v34.Value = v35
        v32 = table.insert
        v32(v31, v34)
        v34 = u6
        v34 = v34.AI_EFFICIENCY_SYM
        v17:Name__6e278845(v34)
      end
      v34 = u6
      v34 = v34.AI_EFFICIENCY_MIN_SYM
      v32 = v17:Name__158ab814(v34)
      if v32 then
        v34 = { Type = nil, Tag = nil, Value = nil }
        v35 = 5
        v34.Type = v35
        v35 = u6
        v35 = v35.AI_EFFICIENCY_MIN_SYM
        v34.Tag = v35
        v37 = u6
        v37 = v37.AI_EFFICIENCY_MIN_SYM
        v35 = v17:Name__e470b32b(v37)
        v34.Value = v35
        v32 = table.insert
        v32(v31, v34)
        v34 = u6
        v34 = v34.AI_EFFICIENCY_MIN_SYM
        v17:Name__6e278845(v34)
      end
      v35 = 1
      v33 = v2:Name__9d3a8775(v35)
      v32 = v33 * 100
      v33 = 200 - v32
      v34 = u2
      v38 = u0
      v38 = v38.FormatNumber
      v40 = 0
      v41 = false
      v36 = v38(v33, v40, v41)
      v37 = "%"
      v35 = v36 .. v37
      v37 = nil
      v38 = true
      v39 = nil
      v40 = nil
      v41 = TitleCase
      v45 = false
      v34 = v34(v35, v33, v37, v38, v39, v40, v41(v0:GetLocalized(v30, v45)))
      v27.Power_Efficiency = v34
      v37 = 1
      v35 = v2:Name__95d14356(v37)
      v34 = v35 * 100
      v35 = v27.Power_Efficiency
      v37 = { TEXT = "/Lotus/Language/Stats/TIP_Power_Efficiency_Cost", VARS = nil, comparisonFlipped = true }
      v38 = { AMOUNT = nil }
      v38.AMOUNT = v32
      v37.VARS = v38
      v38 = { TEXT = "/Lotus/Language/Stats/TIP_Power_Efficiency_TotalCost", VARS = nil, comparisonFlipped = true }
      v39 = { AMOUNT = nil }
      v39.AMOUNT = v34
      v38.VARS = v39
      v36 = {v37, v38}
      v35.SecondaryToolTips = v36
      v35 = pairs
      v35, v36, v37 = v35(v31)
      for v38, v39 in v35, v36, v37 do
        v42 = v39.Tag
        v43 = v39.Type
        v44 = 4
        v45 = v39.Value
        v17:Name__90fde101(v42, v43, v44, v45)
      end
      v37 = 1
      v38 = 9
      v39 = v2:GetType()
      v35 = v17:GetUpgradeModifiedValue(v37, v38, v39, v2)
      v36 = u2
      v40 = u0
      v40 = v40.FormatNumber
      v41 = v35 * 100
      v42 = 0
      v43 = false
      v38 = v40(v41, v42, v43)
      v39 = "%"
      v37 = v38 .. v39
      v39 = nil
      v40 = true
      v36 = v36(v37, v35, v39, v40)
      v27.Power_Range = v36
      v36 = u2
      v40 = u0
      v40 = v40.FormatNumber
      v41 = v29 * 100
      v42 = 0
      v43 = false
      v38 = v40(v41, v42, v43)
      v39 = "%"
      v37 = v38 .. v39
      v39 = nil
      v40 = true
      v36 = v36(v37, v29, v39, v40)
      v27.Status_Duration_Lavos = v36
      v36 = u2
      v40 = u0
      v40 = v40.FormatNumber
      v42 = 0
      v43 = false
      v38 = v40(v33, v42, v43)
      v39 = "%"
      v37 = v38 .. v39
      v39 = nil
      v40 = true
      v36 = v36(v37, v33, v39, v40)
      v27.Power_Efficiency_Lavos = v36
      v36 = { mName = nil, mIsMelee = false, mBehaviorIndex = 0, mStats = nil }
      v37 = string.upper
      v40 = "/Lotus/Language/Actions/AbilityXP"
      v41 = false
      v37 = v37(v0:GetLocalized(v40, v41))
      v36.mName = v37
      v36.mStats = v27
      v19 = v36
      for v38, v39 in v35, v36, v37 do
      end
    else
      v26 = u2
      v27 = u0
      v27 = v27.FormatNumber
      v29 = 2
      v30 = false
      v27 = v27(v25, v29, v30)
      v29 = nil
      v30 = true
      v26 = v26(v27, v25, v29, v30)
      v21.Mult_SprintSpeed = v26
    end
  else
    v23 = IsNull
    v23 = v23(v2)
    if not v23 then
      v25 = gSentinelPowerSuitType
      v23 = v2:IsA(v25)
      if v23 then
        v23 = IsNull
        v23 = v23(v1)
        if not v23 then
          v23 = v1:GetSelfRespawnTime()
          v24 = u2
          v25 = nil
          v27 = nil
          v28 = true
          v29 = nil
          v30 = nil
          v31 = nil
          v32 = nil
          v33 = nil
          v34 = nil
          v35 = nil
          v36 = true
          v24 = v24(v25, v23, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36)
          v21.Self_Respawn_Time = v24
        end
      end
    end
  end
  v23 = table.insert
  v23(v5, v4)
  if v19 ~= nil then
    v23 = table.insert
    v23(v5, v19)
  end
  if v20 ~= nil then
    v25 = 1
    v23 = table.insert
    v23(v5, v25, v20)
  end
  do return v5 end
end

function proto_19(v0)
  local v1, v2, v3, v4, v6, v7
  v1 = Localize
  v2 = "/Lotus/Language/Game/PurifyPercent"
  v3 = { PERCENT = nil }
  v4 = u0
  v4 = v4.FormatNumber
  v6 = 1
  v7 = false
  v4 = v4(v0, v6, v7)
  v3.PERCENT = v4
  do return v1(v2, v3) end
end

function proto_20(v0, v1)
  local v2, v3, v4, v5, v8
  v2 = Localize
  v3 = "/Lotus/Language/Game/UNIT_SECOND"
  v4 = { COUNT = nil }
  v5 = u0
  v5 = v5.FormatNumber
  v8 = false
  v5 = v5(v0, v1, v8)
  v4.COUNT = v5
  do return v2(v3, v4) end
end

function proto_21(v0, v1)
  local v2, v3, v4, v5, v8
  v2 = Localize
  v3 = "/Lotus/Language/Game/UNIT_METER"
  v4 = { COUNT = nil }
  v5 = u0
  v5 = v5.FormatNumber
  v8 = false
  v5 = v5(v0, v1, v8)
  v4.COUNT = v5
  do return v2(v3, v4) end
end

function proto_22(v0)
  local v1, v2, v3, v4, v6, v7
  v1 = Localize
  v2 = "/Lotus/Language/Game/UNIT_DEGREE"
  v3 = { COUNT = nil }
  v4 = u0
  v4 = v4.FormatNumber
  v6 = 1
  v7 = false
  v4 = v4(v0, v6, v7)
  v3.COUNT = v4
  do return v1(v2, v3) end
end

function proto_23(v0)
  local v1, v2, v4, v5
  v1 = u0
  v2 = u1
  v2 = v2.FormatNumber
  v4 = 1
  v5 = false
  v2 = v2(v0, v4, v5)
  v4 = nil
  do return v1(v2, v0, v4) end
end

function proto_24(v0, v1, v2, v3, v4, v5)
  local v6, v7, v8, v9, v10, v11, v12, v13, v14
  v3 = v3 or 1
  v5 = v5 or ""
  v6 = u0
  v6 = v6.GetDamageTypeTag
  v7 = 0
  v8 = v1:GetBaseAmount()
  v8 = v8:GetModifiedValue()
  v11 = 0
  v9 = 19
  v10 = 1
  for v11 = v11, v9, v10 do
    v12 = v4[v11]
    v7 = v4[v11]
    v12 = v1:GetDamagePct(v11)
    v7 = v12 * v8
    v12 = 0
    if v12 < v7 then
      v14 = v6(v11)
      v12 = v5 .. v14
      v13 = u1
      v14 = v7 * v3
      v13 = v13(v14)
      v0[v12] = v13
    end
  end
  do return end
end

function proto_25(v0, v1, v2, v3, v4, v5, v6)
  local v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17
  v7 = 0
  v8 = false
  v9 = v4 or v0
  v10 = next
  v10 = v10(v9)
  v17 = v10(v14)
  v15 = v3 .. v17
  v16 = v9[v15]
  if v16 then
    v16 = v9[v15]
    v16 = v16.StatValue
    v7 = v7 + v16
    v11 = v11 + 1
  end
  v3 = v3 or ""
  v10 = #v3
  v11 = 0
  if v11 < v10 then
    v10 = u0
    v7 = v10(v9, v1, v2)
  end
  v10 = u1
  v10 = v10.GetDamageTypeTag
  v11 = 0
  v14 = 0
  v12 = 19
  v13 = 1
  for v14 = v14, v12, v13 do
  end
  if not v10 then
    v12 = IsNull
    v12 = v12(v6)
    if not v12 then
      v12 = IsNull
      v12 = v12(v5)
      if not v12 then
        v14 = 0
        v15 = 253
        v16 = v5:GetType()
        v12 = v6:GetUpgradeModifiedValue(v14, v15, v16, v5)
        v13 = 0
        if v13 < v12 then
          v7 = v7 + v12
          v8 = true
        end
      end
    end
    v12 = 0
    if v12 then
      v12 = u2
      v13 = v7 * v2
      v12 = v12(v13)
      v13 = false
      v14 = 1
      if v11 <= v14 then
        v13 = false
        if v2 == 1 then
          v13 = not v8
        end
      end
      v12.Hidden = v13
      v0.Total = v12
    end
  end
  do return v7 end
end

function proto_26(v0, v1, v2, v3, v4, v5, v6, v7)
  local v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18
  v3 = v3 or 1
  v4 = v4 or 1
  v6 = v6 or ""
  v8 = u0
  v8 = v8.GetDamageTypeTag
  v9 = 0
  v10 = 0
  v11 = 0
  v12 = v1:GetBaseAmount()
  v12 = v12:GetModifiedValue()
  v15 = 0
  v13 = 19
  v14 = 1
  for v15 = v15, v13, v14 do
    v16 = v1:GetDamagePct(v15)
    v17 = 0
    v9 = v1:GetDamagePct(v15)
    v16 = v5[v15]
    v9 = v5[v15]
    v16 = v1:GetDamagePct(v15)
    v9 = v16 * v12
    v16 = 0
    if v16 < v9 then
      v9 = v9 * v3
      v18 = v8(v15)
      v16 = v6 .. v18
      v17 = u1
      v17 = v17(v9)
      v0[v16] = v17
      v10 = v10 + v9
      v11 = v11 + 1
    end
  end
  v13 = 0
  if not ((v10 <= v13 or v7)) then
    v13 = u1
    v14 = v10 * v4
    v13 = v13(v14)
    v14 = false
    v15 = 1
    if v11 <= v15 then
      if v4 ~= 1 then
        v14 = false
      else
        v14 = true
      end
    end
    v13.Hidden = v14
    v0.Total = v13
  end
  do return end
end

function proto_27(v0, v1)
  local v2, v3, v4, v5, v6, v7, v8, v9
  v9 = v1.mStats
  v8 = v9[v5]
  v8 = v8.StatValue
  v7 = IsNull
  v7 = v7(v8)
  v8 = v1.mStats
  v7 = v8[v5]
  v7 = v7.StatValue
  v8 = v6.StatValue
  for v5, v6 in v2, v3, v4 do
    v2 = true
    do return v2 end
  end
  v9 = v1.mStats
  v8 = v9[v5]
  v7 = IsNull
  v7 = v7(v8)
  v2 = v0.mName
  v3 = v1.mName
  if v2 ~= v3 then
    v2 = false
    do return v2 end
  end
  v2 = v0.mBehaviorIndex
  v3 = v1.mBehaviorIndex
  if v2 ~= v3 then
    v2 = false
    do return v2 end
  end
  v2 = v0.mIsMelee
  v3 = v1.mIsMelee
  if v2 ~= v3 then
    v2 = false
    do return v2 end
  end
  v2 = v0.mExtra
  v3 = v1.mExtra
  if v2 ~= v3 then
    v2 = false
    do return v2 end
  end
  v3 = v0.mStats
  v2 = #v3
  v4 = v1.mStats
  v3 = #v4
  if v2 ~= v3 then
    v2 = false
    do return v2 end
  end
  v2 = pairs
  v3 = v0.mStats
  v2, v3, v4 = v2(v3)
  for v5, v6 in v2, v3, v4 do
  end
  v7 = false
  do return v7 end
end

function proto_28(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11)
  local v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34
  v12 = {}
  v13 = v1.projectileType
  v14 = v1.behaviorIndex
  v15 = v1.turboGlaive
  v16 = u0
  v16 = v16.GetProjectileAndDamageData
  v16, v17, v18 = v16(v0, v3, v13, v14, v15, v11)
  v21 = gWeaponProjectileFireBehaviorType
  v19 = v2:IsA(v21)
  if v19 then
    v19 = v2.advanceProjectileSequenceOnFire
    if v19 then
      v20 = v2:Name__c4f6d252()
      v19 = v20 - 1
      v20 = 0
      if v20 < v19 then
        v22 = 1
        v20 = v19
        v21 = 1
        for v22 = v22, v20, v21 do
          v2:SetProjectileIndex(v22)
          v23 = u0
          v23 = v23.GetProjectileAndDamageData
          v23, v24, v25 = v23(v0, v3, v13, v14, v15, v11)
          v28 = { DmgData = nil, RadialData = nil }
          v28.DmgData = v24
          v28.RadialData = v25
          v26 = table.insert
          v26(v12, v28)
        end
        v22 = 0
        v2:SetProjectileIndex(v22)
      end
    end
  end
  v19 = #v12
  v20 = {}
  if not v19 then
    local p39 = 7
    if p39 == 7 then
      v21 = u1
      v21(v20, v17, v4, v6, v7)
      v21 = v0:GetEmbedDamage(v16)
      v22 = v21:GetBaseAmount()
      v22 = v22:GetModifiedValue()
      v23 = next
      v23 = v23(v20)
      if v23 then
        p39 = 9
      else
        p39 = 8
      end
    end
    if p39 == 8 then
      v23 = 0
      if v22 <= v23 then
      else
        p39 = 9
      end
    end
    if p39 == 9 then
      v23 = v10
      v24 = 0
      if v19 <= v24 then
        p39 = 13
      else
        p39 = 10
      end
    end
    if p39 == 10 then
      if not v11 then
        p39 = 12
      else
        p39 = 11
      end
    end
    if p39 == 11 then
      v20 = {}
      p39 = 13
    end
    if p39 == 12 then
      v24 = Localize
      v25 = "/Lotus/Language/Stats/Attack1"
      v26 = {}
      v23 = v24(v25, v26)
      p39 = 13
    end
    if p39 == 13 then
      v24 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
      v25 = string.upper
      v25 = v25(v23)
      v24.mName = v25
      v25 = v1.behaviorIndex
      v24.mBehaviorIndex = v25
      v24.mStats = v20
      v25 = table.insert
      v25(v8, v24)
      v25 = 0
      if (v19 <= v25 or not v11) then
      else
        p39 = 15
      end
    end
    if p39 == 15 then
      v25 = {}
      v26 = u2
      v33 = nil
      v34 = true
      v26(v25, v17, v4, v6, v5, v7, v33, v34)
      v26 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
      v27 = string.upper
      v28 = Localize
      v29 = "/Lotus/Language/Stats/Attack1"
      v30 = {}
      v27 = v27(v28(v29, v30))
      v26.mName = v27
      v27 = v1.behaviorIndex
      v26.mBehaviorIndex = v27
      v26.mStats = v25
      v24 = v26
      v26 = table.insert
      v26(v8, v24)
      if not v18 then
      else
        p39 = 16
      end
    end
    if p39 == 16 then
      v26 = {}
      v27 = u1
      v33 = nil
      v27(v26, v18, v4, v6, v7, v33)
      v27 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
      v28 = string.upper
      v29 = Localize
      v30 = "/Lotus/Language/Labels/AVATAR_RADIAL_ATTACK"
      v31 = {}
      v28 = v28(v29(v30, v31))
      v27.mName = v28
      v28 = v1.behaviorIndex
      v27.mBehaviorIndex = v28
      v27.mStats = v26
      v28 = table.insert
      v28(v8, v27)
    end
  end
  v23 = 1
  v21 = v19
  v22 = 1
  for v23 = v23, v21, v22 do
    v24 = v12[v23]
    v24 = v24.DmgData
    v25 = v24:GetBaseAmount()
    v25 = v25:GetModifiedValue()
    v26 = 0
    if v26 < v25 then
      v25 = {}
      v26 = u2
      v33 = nil
      v26(v25, v24, v4, v6, v5, v7, v33, v11)
      v26 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
      v27 = string.upper
      v28 = Localize
      v30 = "/Lotus/Language/Stats/Attack"
      v31 = v23 + 1
      v29 = v30 .. v31
      v30 = {}
      v27 = v27(v28(v29, v30))
      v26.mName = v27
      v27 = v1.behaviorIndex
      v26.mBehaviorIndex = v27
      v26.mStats = v25
      v27 = table.insert
      v27(v8, v26)
      if v11 then
        v27 = v12[v23]
        v27 = v27.RadialData
        if v27 then
          v27 = {}
          v28 = u1
          v30 = v12[v23]
          v30 = v30.RadialData
          v34 = nil
          v28(v27, v30, v4, v6, v7, v34)
          v28 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
          v29 = string.upper
          v30 = Localize
          v31 = "/Lotus/Language/Labels/AVATAR_RADIAL_ATTACK"
          v32 = {}
          v29 = v29(v30(v31, v32))
          v28.mName = v29
          v29 = v1.behaviorIndex
          v28.mBehaviorIndex = v29
          v28.mStats = v27
          v29 = table.insert
          v29(v8, v28)
        end
      end
    end
  end
  do return v16, v17, v20 end
end

function proto_29(v0, v1)
  do return end
end

function proto_30(v0, v1)
  local v2, v3, v4, v9, v10
  v2 = ipairs
  v2, v3, v4 = v2(v1)
  for v5, v6 in v2, v3, v4 do
    v9 = v6:GetUpgradeType()
    v10 = v6:GetOperationType()
    v0:AddUpgrade(v9, v10, v6:GetValue())
  end
  do return end
end

function proto_31(v0, v1)
  local v2, v3, v4, v9, v10
  v2 = ipairs
  v2, v3, v4 = v2(v1)
  for v5, v6 in v2, v3, v4 do
    v9 = v6:GetUpgradeType()
    v10 = v6:GetOperationType()
    v0:RemoveUpgrade(v9, v10, v6:GetValue())
  end
  do return end
end

function proto_32(v0, v1, v2, v3)
  local v4, v5, v6, v9, v10, v11, v12, v13, v14, v15, v16
  v4 = ipairs
  v4, v5, v6 = v4(v1)
  for v7, v8 in v4, v5, v6 do
    v9 = v8:GetUpgradeType()
    v10 = 264
    if v9 == v10 then
      v10 = v8:GetDamageType()
      v11 = u0
      v11 = v11.GetDamageTypeTag
      v12 = v11(v10)
      v14 = 1
      v13 = v11(v14)
      v15 = 2
      v14 = v11(v15)
      v16 = 0
      v15 = v11(v16)
      v16 = v3[v13]
      if v16 then
        v16 = v3[v13]
        v3[v12] = v16
        v16 = nil
        v3[v13] = v16
      end
      v16 = v3[v14]
      if v16 then
        v16 = v3[v14]
        v3[v12] = v16
        v16 = nil
        v3[v14] = v16
      end
      v16 = v3[v15]
      if v16 then
        v16 = v3[v15]
        v3[v12] = v16
        v16 = nil
        v3[v15] = v16
      end
    end
  end
  do return end
end

function proto_33(v0, v1)
  local v2, v3, v4, v5, v6
  v4 = 1
  v2 = #v1
  v3 = 1
  for v4 = v4, v2, v3 do
    v5 = v1[v4]
    v6 = nil
    v0[v5] = v6
  end
  do return end
end

function proto_34(v0, v1)
  local v2, v3, v4, v5, v6, v7, v8
  v6 = 0
  v4 = 19
  v5 = 1
  for v6 = v6, v4, v5 do
    v7 = v0:GetDamagePct(v6)
    v8 = 0
    if v8 < v7 then
      v7 = v0:GetDamagePct(v6)
      v8 = v7 * v3
      v2 = v2 + v8
    end
  end
  v2 = 0
  v3 = v0:GetBaseAmount()
  v3 = v3:GetModifiedValue()
  if v1 then
    v4 = 0
    if v4 < v1 then
      v3 = v3 * v1
    end
  end
  v4 = 0
  do return v2 end
end

function proto_35(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13)
  local v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v26
  v14 = u0
  v14 = v14.GetCritStats
  v23 = v5.turboGlaive
  v14, v15 = v14(v2, v11, v4, v10, v8, v7, v3, v9, v23)
  v17 = _T.Stats_CritChanceOverride
  v16 = IsNull
  v16 = v16(v17)
  if not v16 then
    v18 = _T.Stats_CritChanceOverride
    v19 = v2:GetType()
    v19 = v19:GetFullName()
    v17 = v18[v19]
    v16 = IsNull
    v16 = v16(v17)
    if not v16 then
      v19 = _T.Stats_CritChanceOverride
      v20 = v2:GetType()
      v20 = v20:GetFullName()
      v18 = v19[v20]
      v19 = v5.behaviorIndex
      v17 = v18[v19]
      v16 = IsNull
      v16 = v16(v17)
      if not v16 then
        v18 = _T.Stats_CritChanceOverride
        v19 = v2:GetType()
        v19 = v19:GetFullName()
        v17 = v18[v19]
        v18 = v5.behaviorIndex
        v16 = v17[v18]
        v14 = v14 + v16
      end
    end
  end
  v17 = _T.Stats_CritMultOverride
  v16 = IsNull
  v16 = v16(v17)
  if not v16 then
    v18 = _T.Stats_CritMultOverride
    v19 = v2:GetType()
    v19 = v19:GetFullName()
    v17 = v18[v19]
    v16 = IsNull
    v16 = v16(v17)
    if not v16 then
      v19 = _T.Stats_CritMultOverride
      v20 = v2:GetType()
      v20 = v20:GetFullName()
      v18 = v19[v20]
      v19 = v5.behaviorIndex
      v17 = v18[v19]
      v16 = IsNull
      v16 = v16(v17)
      if not v16 then
        v18 = _T.Stats_CritMultOverride
        v19 = v2:GetType()
        v19 = v19:GetFullName()
        v17 = v18[v19]
        v18 = v5.behaviorIndex
        v16 = v17[v18]
        v15 = v15 + v16
      end
    end
  end
  v14 = v14 * 100
  v16 = u1
  v17 = u2
  v17 = v17(v14)
  v19 = nil
  v16 = v16(v17, v14, v19)
  v1.CriticalChance = v16
  v16 = Localize
  v17 = "/Lotus/Language/Menu/WeaponStats_MultipilerStat"
  v18 = { STAT = nil }
  v19 = u3
  v19 = v19.FormatNumber
  v21 = 1
  v22 = false
  v19 = v19(v15, v21, v22)
  v18.STAT = v19
  v16 = v16(v17, v18)
  v17 = u1
  v20 = nil
  v17 = v17(v16, v15, v20)
  v1.CriticalMultiplier = v17
  if v16 then
    v17 = u3
    v17 = v17.Ternary
    v19 = v7.fireIterations
    v20 = 1
    if v19 <= v20 then
      v18 = false
    else
      v18 = true
    end
    v19 = "ProcChancePerShot"
    v20 = "ProcChance"
    v17 = v17(v18, v19, v20)
    v20 = v4.baseProcChance
    v19 = v20 * 100
    v20 = 0
    v18 = math.max
    v18 = v18(v19, v20)
    v19 = v6:IsContinuousBehavior()
    if v19 then
      v21 = gWeaponBeamStateBehaviorType
      v19 = v6:IsA(v21)
      if not v19 then
        v19 = v2:GetFireRate()
        v18 = v18 * v19
      end
    end
    if v12 then
      v21 = 7
      v19 = v12:GetDamagePct(v21)
      v20 = 0
      if not ((v19 <= v20 or not v3)) then
        v19 = v3:Name__f313e652()
        v20 = 0
        if v20 < v19 then
          v19 = v3:Name__f313e652()
          v18 = v19 * 100
          v22 = 364
          v23 = v2:GetType()
          v18 = v11:GetUpgradeModifiedValue(v18, v22, v23, v2)
        end
      end
    end
    if not ((not v13 or not v3)) then
      v19 = v2:GetEmbedDamage(v3)
      if v19 then
        v20 = v19.baseProcChance
        v21 = 0
        if v21 < v20 then
          v20 = v19.baseProcChance
          v18 = v20 * 100
        end
      end
    end
    v19 = u1
    v20 = u2
    v20 = v20(v18)
    v22 = nil
    v19 = v19(v20, v18, v22)
    v1[v17] = v19
    v19 = u4
    v21 = false
    v22 = 1
    v19 = v19(v1, v21, v22)
    v20 = v1[v17]
    v21 = u5
    v26 = false
    v21 = v21(v0, v1, v18, v19, v26, v8)
    v20.SecondaryToolTips = v21
  end
  do return end
end

function proto_36(v0, v1, v2, v3, v4, v5, v6)
  local v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25
  v12 = IsNull
  v12 = v12(v6)
  v14 = 0
  v12 = 13
  v13 = 1
  for v14 = v14, v12, v13 do
    v15 = v6:Name__ece904ae(v10, v14)
    v15 = v6:Name__ece904ae(v11, v14)
    v15 = table.insert
    v15(v9, v14)
    v15 = IsNull
    v15 = v15(v5)
    if not v15 then
      v18 = false
      v15 = v5:GetForcedProc(v14, v18)
      if v15 then
        v15 = table.insert
        v15(v8, v14)
      end
    end
    v15 = IsNull
    v15 = v15(v6)
  end
  v7 = {}
  if not v4 then
    v9 = { TEXT = "/Lotus/Language/Stats/TIP_ProcChancePerDT", VARS = nil }
    v10 = {}
    v9.VARS = v10
    v7 = {v9}
  end
  v8 = pairs
  v8, v9, v10 = v8(v1)
  for v11, v12 in v8, v9, v10 do
    v13 = string.find
    v15 = "DT_"
    v13 = v13(v11, v15)
    if v13 ~= nil then
      v15 = 1
      v13 = math.max
      v13 = v13(v3, v15)
      v16 = v12.StatValue
      v15 = v16 / v13
      v14 = v15 * v2
      v15 = string.gsub
      v17 = "Embed"
      v18 = ""
      v15 = v15(v11, v17, v18)
      v19 = "/Lotus/Language/Game/"
      v18 = v19 .. v15
      v19 = true
      v16 = v0:GetLocalized(v18, v19)
      v17 = { DT_NAME = nil, AMOUNT = nil }
      v17.DT_NAME = v16
      v17.AMOUNT = v14
      v20 = { TEXT = "/Lotus/Language/Stats/TIP_DT_StatusChance", VARS = nil, skipFormatting = true }
      v20.VARS = v17
      v18 = table.insert
      v18(v7, v20)
    end
  end
  v8 = {}
  v9 = {}
  v10 = Symbol
  v11 = "MeleeSlam"
  v10 = v10(v11)
  v11 = Symbol
  v12 = "HeavySlam"
  v11 = v11(v12)
  v12 = IsNull
  v12 = v12(v5)
  local p44 = 17
  if p44 == 17 then
    v12 = #v8
    v13 = 0
    if v13 < v12 then
      p44 = 19
    else
      p44 = 18
    end
  end
  if p44 == 18 then
    v12 = #v9
    v13 = 0
    if v12 <= v13 then
      p44 = 25
    else
      p44 = 19
    end
  end
  if p44 == 19 then
    v14 = { TEXT = nil, VARS = nil }
    v19 = u0
    v22 = "<MINI_DIAMOND> "
    v23 = true
    v20 = v0:GetLocalized(v22, v23)
    v21 = 0
    v16 = v19(v20, v21)
    v17 = " "
    v20 = "/Lotus/Language/Stats/TIP_ForcedProcChancePerDT"
    v21 = false
    v18 = v0:GetLocalized(v20, v21)
    v15 = v16 .. v17 .. v18
    v14.TEXT = v15
    v15 = {}
    v14.VARS = v15
    v12 = table.insert
    v12(v7, v14)
    v12 = v8
    v13 = nil
    v14 = nil
    for v15, v16 in v12, v13, v14 do
      v17 = u1
      v17 = v17.GetDamageTypeTag
      v17 = v17(v16)
      v20 = { TEXT = nil, VARS = nil, skipFormatting = true }
      v24 = "/Lotus/Language/Game/"
      v23 = v24 .. v17
      v24 = true
      v21 = v0:GetLocalized(v23, v24)
      v20.TEXT = v21
      v21 = {}
      v20.VARS = v21
      v18 = table.insert
      v18(v7, v20)
    end
    v12 = v9
    v13 = nil
    v14 = nil
    for v15, v16 in v12, v13, v14 do
      v17 = u1
      v17 = v17.GetDamageTypeTag
      v17 = v17(v16)
      v20 = { TEXT = "/Lotus/Language/Stats/TIP_ForcedProcForSlamAttack", VARS = nil, skipFormatting = true }
      v21 = { DT_NAME = nil }
      v25 = "/Lotus/Language/Game/"
      v24 = v25 .. v17
      v25 = true
      v22 = v0:GetLocalized(v24, v25)
      v21.DT_NAME = v22
      v20.VARS = v21
      v18 = table.insert
      v18(v7, v20)
    end
    p44 = 25
  end
  if p44 == 25 then
    v12 = #v7
    v13 = 0
    if v12 <= v13 then
      p44 = 27
    else
      p44 = 26
    end
  end
  if p44 == 26 then
    do return v7 end
  end
  if p44 == 27 then
    v12 = nil
    do return v12 end
  end
end

function proto_37(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18)
  local v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49
  v31 = v1:GetEmbedDamage(v2)
  v32 = v31:GetBaseAmount()
  v32 = v32:GetModifiedValue()
  v33 = 0
  v33 = u5
  v33 = v33.GetDamageTypeTag
  v36 = 0
  v34 = 19
  v35 = 1
  for v36 = v36, v34, v35 do
    v37 = v31:GetDamagePct(v36)
    v38 = 0
    if v38 < v37 then
      v37 = v33(v36)
      v38 = v22[v36]
      if v38 == nil then
        v38 = u3
        v39 = nil
        v40 = 0
        v41 = nil
        v38 = v38(v39, v40, v41)
        v22[v37] = v38
      end
      v38 = u6
      v40 = v22[v37]
      v40 = v40.StatValue
      v42 = v31:GetDamagePct(v36)
      v41 = v42 * v32
      v39 = v40 + v41
      v38 = v38(v39)
      v22[v37] = v38
    end
  end
  local c85 = -1
  repeat
    v30 = WeakResource
    v31 = "/Lotus/Weapons/Corpus/Bow/Longbow/CrpBowArrow"
    v30 = v30(v31)
    v31 = WeakResource
    v32 = "/Lotus/Weapons/Corpus/Bow/Longbow/CrpBowArrowPvP"
    v29 = {v30, v31(v32)}
    v30 = false
    v31 = pairs
    v31, v32, v33 = v31(v29)
    for v34, v35 in v31, v32, v33 do
      v36 = v2:IsA(v35)
      if v36 then
        c85 = 22
        break
      end
      v21 = false
      v22 = {}
      if not ((not (not v8) and v9)) then
        v23 = v3:GetBaseAmount()
        v23 = v23:GetModifiedValue()
        v24 = 0
        if v24 < v23 then
          v23 = u0
          v27 = 1
          v23(v22, v3, v10, v27, v11)
          v23 = u1
          v36 = nil
          v23(v0, v22, v1, v2, v3, v4, v5, v6, v7, v8, v14, v15, v36, v18)
          v23 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
          v24 = string.upper
          v25 = Localize
          v27 = {}
          v24 = v24(v25(v16, v27))
          v23.mName = v24
          v24 = v4.behaviorIndex
          v23.mBehaviorIndex = v24
          v23.mStats = v22
          v19 = v23
        end
      end
      v23 = {}
      v24 = 0
      v25 = nil
      v26 = false
      v29 = WeakResource
      v30 = "/Lotus/Weapons/ClanTech/Energy/EnergyRifle"
      v27 = v1:IsA(v29(v30))
      v30 = gRadialOnMissImpactBehaviorType
      v28 = v7:IsA(v30)
      if v28 then
        v25 = v7:GetRadialDamageData(v14)
        v28 = v25:GetBaseAmount()
        v24 = v28:GetModifiedValue()
      end
      if not ((v24 ~= 0 or v27)) then
        v30 = gRadialOnMissTraceFireBehaviorType
        v28 = v6:IsA(v30)
        if v28 then
          v25 = v6:GetRadialDamageData(v14)
        else
          v26 = true
          v30 = false
          v25 = v1:GetExplosionDamage(v30, v2)
        end
        v28 = v25:GetBaseAmount()
        v24 = v28:GetModifiedValue()
      end
      v28 = 0
      if (not (not v8) and v9) then
        local p80 = 13
        if p80 == 13 then
          v21 = v26
          v28 = u2
          v28 = v28.Ternary
          v30 = v3.hitType
          v31 = 2
          if v30 ~= v31 then
            p80 = 15
          else
            p80 = 14
          end
        end
        if p80 == 14 then
          v29 = v6:Name__f81ac8ed()
          if v29 then
            p80 = 18
          else
            p80 = 15
          end
        end
        if p80 == 15 then
          v30 = v3.hitType
          v31 = 4
          if v30 == v31 then
            p80 = 17
          else
            p80 = 16
          end
        end
        if p80 == 16 then
          v29 = false
          p80 = 18
        end
        if p80 == 17 then
          v29 = true
          p80 = 18
        end
        if p80 == 18 then
          v32 = true
          v33 = true
          v30 = v7:GetPlayerDamageMultiplier(v32, v33)
          v31 = 1
          v28 = v28(v29, v30, v31)
          v30 = u2
          v30 = v30.Ternary
          v33 = 1
          v30 = v30(v14, v28, v33)
          v29 = v12 * v30
          v30 = u0
          v30(v23, v25, v10, v29)
          v32 = v25.fallOff
          v31 = v32 * 100
          v32 = 0
          v30 = math.max
          v30 = v30(v31, v32)
          v31 = u3
          v32 = u4
          v32 = v32(v30)
          v34 = nil
          v31 = v31(v32, v30, v34)
          v23.DamageFallOff = v31
        end
      end
      v28 = false
      v29 = v1:Name__7ffc2d2c(v2)
      if not v29 then
        c85 = 47
        break
      end
    end
    if c85 ~= -1 then break end
    break
  until true
  if c85 == 22 then
    v30 = true
  end
  if v32 <= v33 then
    local p83 = 31
    if p83 == 31 then
      v33 = false
      if v24 == 0 then
        p83 = 34
      else
        p83 = 32
      end
    end
    if p83 == 32 then
      v34 = 0
      if (not (v34 < v32) and not v30) then
        p83 = 45
      else
        p83 = 34
      end
    end
    if p83 == 34 then
      v36 = true
      v25 = v1:GetExplosionDamage(v36, v2)
      v33 = true
      v34 = v25:GetBaseAmount()
      v24 = v34:GetModifiedValue()
      v34 = 0
      if v24 <= v34 then
        p83 = 45
      else
        p83 = 35
      end
    end
    if p83 == 35 then
      v28 = true
      if v18 then
        p83 = 37
      else
        p83 = 36
      end
    end
    if p83 == 36 then
      v34 = u0
      v38 = 1
      v39 = nil
      v40 = "Embed"
      v34(v23, v25, v10, v38, v39, v40)
      p83 = 37
    end
    if p83 == 37 then
      v34 = v1:ProjectileEmbedTime(v2)
      v35 = nil
      v36 = v34.minValue
      v37 = v34.maxValue
      if v36 ~= v37 then
        p83 = 39
      else
        p83 = 38
      end
    end
    if p83 == 38 then
      v36 = u2
      v36 = v36.FormatNumber
      v37 = v34.minValue
      v38 = 1
      v39 = false
      v35 = v36(v37, v38, v39)
      p83 = 40
    end
    if p83 == 39 then
      v39 = u2
      v39 = v39.FormatNumber
      v40 = v34.minValue
      v41 = 1
      v42 = false
      v36 = v39(v40, v41, v42)
      v37 = " - "
      v38 = u2
      v38 = v38.FormatNumber
      v39 = v34.maxValue
      v40 = 1
      v41 = false
      v38 = v38(v39, v40, v41)
      v35 = v36 .. v37 .. v38
      p83 = 40
    end
    if p83 == 40 then
      if v35 == nil then
        p83 = 43
      else
        p83 = 41
      end
    end
    if p83 == 41 then
      v38 = 0.5
      v36 = v34:MapToRange(v38)
      v37 = 0
      if v36 <= v37 then
        p83 = 43
      else
        p83 = 42
      end
    end
    if p83 == 42 then
      v37 = u3
      v40 = nil
      v41 = nil
      v42 = nil
      v43 = nil
      v44 = nil
      v45 = nil
      v46 = nil
      v47 = nil
      v48 = nil
      v49 = true
      v37 = v37(v35, v36, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49)
      v23.EmbedDelay = v37
      p83 = 43
    end
    if p83 == 43 then
      v38 = v25.fallOff
      v37 = v38 * 100
      v38 = 0
      v36 = math.max
      v36 = v36(v37, v38)
      v37 = 0
      if v36 <= v37 then
        p83 = 45
      else
        p83 = 44
      end
    end
    if p83 == 44 then
      v37 = u3
      v38 = u4
      v38 = v38(v36)
      v40 = nil
      v37 = v37(v38, v36, v40)
      v23.EmbedFallOff = v37
      p83 = 45
    end
    if p83 == 45 then
      v34 = 0
      if v24 <= v34 then
      else
        p83 = 46
      end
    end
    if p83 == 46 then
      v21 = v33
    end
  end
  v29 = next
  v29 = v29(v23)
  if v29 then
    v29 = u3
    v30 = u7
    v31 = v25.radius
    v32 = 2
    v30 = v30(v31, v32)
    v31 = v25.radius
    v32 = nil
    v33 = nil
    v34 = u2
    v34 = v34.Ternary
    v36 = "MeleeRange"
    v37 = "AoERange"
    v29 = v29(v30, v31, v32, v33, v34(v8, v36, v37))
    v23.Range = v29
    v29 = u8
    v33 = u2
    v33 = v33.Ternary
    v35 = "Embed"
    v36 = nil
    v33 = v33(v28, v35, v36)
    v34 = nil
    v29(v23, v10, v13, v33, v34, v1, v15)
    v29 = u1
    v42 = nil
    v29(v0, v23, v1, v2, v25, v4, v5, v6, v7, v8, v14, v15, v42, v18)
    v29 = { mName = nil, mIsMelee = nil, mBehaviorIndex = nil, mStats = nil, mExtra = true }
    v30 = string.upper
    v31 = Localize
    v33 = {}
    v30 = v30(v31(v17, v33))
    v29.mName = v30
    v29.mIsMelee = v8
    v30 = v4.behaviorIndex
    v29.mBehaviorIndex = v30
    v29.mStats = v23
    v20 = v29
  end
  v29 = 1
  if not ((not (not v8) and v9)) then
    v29 = v13
  end
  v30 = u8
  v34 = nil
  v35 = nil
  v30(v22, v10, v29, v34, v35, v1, v15)
  do return v19, v20, v21 end
end

function proto_38(v0, v1, v2, v3, v4, v5, v6, v7, v8)
  local v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62, v63, v64, v65, v66, v67, v68, v69, v70, v71, v72, v73, v74, v76, v77, v78, v79, v80, v81, v82, v83, v84, v85, v86, v87, v88, v89, v90, v91, v92, v93, v94, v95, v96, v97, v98
  v28 = 1
  v26 = #v9
  v27 = 1
  for v28 = v28, v26, v27 do
    v29 = v9[1]
    v30 = v9[v28]
    v31 = pairs
    v32 = v30.mStats
    v31, v32, v33 = v31(v32)
    for v34 in v31, v32, v33 do
      v36 = IsNull
      v36 = v36(v34)
      if not v36 then
        v37 = v29.mStats
        v36 = v37[v34]
        v38 = v30.mStats
        v37 = v38[v34]
        v38 = IsNull
        v38 = v38(v36)
        if not v38 then
          v38 = IsNull
          v38 = v38(v37)
          if not v38 then
            v38 = v37.DisplayValue
            v39 = v36.DisplayValue
            if v38 == v39 then
              v38 = v30.mStats
              v39 = nil
              v38[v34] = v39
            end
          end
        end
      end
    end
    for v34, v35 in v31, v32, v33 do
    end
  end
  v31 = v30.behaviorIndex
  v31 = u3
  v33 = v30.upgrades
  v31(v18, v33)
  v33 = v30.behaviorIndex
  v31 = v1:GetStateBehavior(v33)
  v34 = Name__539c8440
  v32 = v31:IsA(v34)
  v34 = gWeaponBurstStateBehaviorType
  v32 = v31:IsA(v34)
  v56 = v32:Name__f81ac8ed()
  v62 = 0
  v60 = 19
  v61 = 1
  for v62 = v62, v60, v61 do
    v63 = v58:GetDamagePct(v62)
    v64 = 0
    if v64 < v63 then
      v63 = v10(v62)
      v64 = v54[v63]
      if v64 == nil then
        v64 = u2
        v65 = nil
        v66 = 0
        v67 = nil
        v64 = v64(v65, v66, v67)
        v54[v63] = v64
      end
      v64 = u8
      v66 = v54[v63]
      v66 = v66.StatValue
      v68 = v58:GetDamagePct(v62)
      v67 = v68 * v59
      v65 = v66 + v67
      v64 = v64(v65)
      v54[v63] = v64
    end
  end
  v70 = pairs
  v70, v71, v72 = v70(v69)
  local v75 = v52:IsA(v74)
  v68 = true
  v70 = v1:GetEmbedDamage(v52)
  v71 = v70:GetBaseAmount()
  v71 = v71:GetModifiedValue()
  v72 = 0
  v74 = 0
  v72 = 19
  v73 = 1
  v73 = 0
  v69 = 0
  v70 = next
  v70 = v70(v60)
  v70 = v1:Name__e76ee792(v52)
  v71 = 0
  v71 = u2
  v72 = u1
  v72 = v72.FormatNumber
  v74 = 2
  v75 = false
  v72 = v72(v70, v74, v75)
  v74 = nil
  v75 = nil
  v76 = u1
  v76 = v76.Ternary
  v78 = "MeleeRange"
  v79 = "AoERange"
  v71 = v71(v72, v70, v74, v75, v76(v36, v78, v79))
  v60.EmbedDamageRadius = v71
  v70 = v32:GetAmmoRequirement()
  v71 = v31:IsContinuousBehavior()
  v73 = gWeaponBeamStateBehaviorType
  v71 = v31:IsA(v73)
  v71 = 0
  v71 = v50 / v70
  v74 = 0
  v72 = 19
  v73 = 1
  v72 = u12
  v69 = v72(v60, v11, v39)
  v50 = v70
  v70 = 1
  v71 = 0
  v71 = u13
  v84 = nil
  v71(v0, v54, v1, v52, v53, v30, v31, v32, v33, v36, v5, v18, v84, v17)
  v75 = 1 / v72
  v74 = v75 * 100
  v75 = 10
  v71 = "/Lotus/Language/Stats/TIP_Accuracy_VeryLow"
  v75 = 10
  v75 = 15.9
  v71 = "/Lotus/Language/Stats/TIP_Accuracy_Low"
  v75 = 16
  v75 = 32.9
  v71 = "/Lotus/Language/Stats/TIP_Accuracy_Medium"
  v75 = u2
  v79 = false
  v76 = v0:GetLocalized(v71, v79)
  v78 = true
  v75 = v75(v76, v74, v78)
  v34.Accuracy = v75
  v75 = v34.Accuracy
  v77 = { TEXT = "/Lotus/Language/Stats/TIP_Accuracy_Spread", VARS = nil, comparisonFlipped = true }
  v78 = { AMOUNT = nil }
  v78.AMOUNT = v73
  v77.VARS = v78
  v76 = {v77}
  v75.SecondaryToolTips = v76
  v77 = true
  v78 = 1
  v75 = v32:GetSpread(v77, v78)
  v77 = v34.Accuracy
  v77 = v77.SecondaryToolTips
  v78 = { TEXT = "/Lotus/Language/Stats/TIP_Accuracy_MaxSpread", VARS = nil, comparisonFlipped = true }
  v79 = { AMOUNT = nil }
  v79.AMOUNT = v75
  v78.VARS = v79
  v76 = table.insert
  v76(v77, v78)
  v71 = v33:Name__a7b87d06()
  v72 = v71:GetBaseAmount()
  v72 = v72:GetModifiedValue()
  v73 = 0
  v75 = 0
  v73 = 19
  v74 = 1
  v73 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
  v74 = string.upper
  v77 = "/Lotus/Language/Labels/WEAPON_DAMAGE_AMOUNT"
  v78 = false
  v74 = v74(v0:GetLocalized(v77, v78))
  v73.mName = v74
  v74 = v30.behaviorIndex
  v73.mBehaviorIndex = v74
  v73.mStats = v54
  v74 = table.insert
  v74(v9, v73)
  v83 = {}
  v84 = v30.turboGlaive
  v76 = v1:Name__46beef39()
  v76 = v1:InfiniteClipsForPlayers()
  v74 = v1:Name__1d4c5bf4(v5)
  v76 = 0
  v76 = 1000000
  v79 = 220
  v74 = v18:GetUpgradeModifiedValue(v74, v79, v1:GetAmmoExType())
  v76 = v32:Name__eda17dce()
  v78 = WeakResource
  v79 = "/Lotus/Weapons/CrewShip/RailjackOrdnanceWeapon"
  v76 = v1:IsA(v78(v79))
  v80 = v32:Name__f81ac8ed()
  v82 = v32:GetProjectileType()
  v83 = false
  v79 = v1:Name__15392120(v82, v83)
  v79 = v33.damageFallOff
  v57 = v53.hitType
  v58 = 4
  if v57 ~= v58 then
    v56 = false
  else
    v56 = true
  end
  v71 = v62.radius
  v72 = 0
  if v72 < v71 then
    v71 = u2
    v72 = u11
    v73 = v62.radius
    v74 = 2
    v72 = v72(v73, v74)
    v73 = v62.radius
    v74 = nil
    v75 = nil
    v76 = u1
    v76 = v76.Ternary
    v78 = "MeleeRange"
    v79 = "AoERange"
    v71 = v71(v72, v73, v74, v75, v76(v36, v78, v79))
    v60.Range = v71
  end
  v76 = v10(v74)
  v75 = v54[v76]
  if v75 ~= nil then
    v75 = v10(v74)
    v76 = u8
    v79 = v10(v74)
    v78 = v54[v79]
    v78 = v78.StatValue
    v77 = v78 * v71
    v76 = v76(v77)
    v54[v75] = v76
  end
  v74 = v10(v73)
  v75 = v54[v74]
  if v75 ~= nil then
    v75 = u8
    v78 = v54[v74]
    v78 = v78.StatValue
    v77 = v78 * v3
    v78 = u1
    v78 = v78.Ternary
    v81 = 1
    v78 = v78(v5, v55, v81)
    v76 = v77 * v78
    v75 = v75(v76)
    v54[v74] = v75
  end
  v75 = 33
  if v75 <= v74 then
    v75 = 99.9
    if v74 < v75 then
      v71 = "/Lotus/Language/Stats/TIP_Accuracy_High"
    end
  end
  v76 = v71:GetDamagePct(v75)
  v77 = 0
  if v77 < v76 then
    v76 = v71:GetDamagePct(v75)
    v78 = v76 * v72
    v77 = v78 * v39
    v78 = v10(v75)
    v79 = u8
    v79 = v79(v77)
    v54[v78] = v79
  end
  if v37 ~= nil then
    v75 = v30.localizeTag
    if v75 == "/Lotus/Language/Menu/Loadout_FireModePrimary" then
      v75 = string.upper
      v78 = "/Lotus/Language/Menu/Loadout_FireModeMelee"
      v79 = false
      v75 = v75(v0:GetLocalized(v78, v79))
      v37.mName = v75
    end
  end
  v76 = IsNull
  v76 = v76(v71)
  if not v76 then
    v74 = v18:Name__3c47b5d8(v71)
  else
    v74 = 0
  end
  v76 = u2
  v77 = nil
  v78 = v2:Name__9e4171c1()
  v79 = nil
  v80 = nil
  v76 = v76(v77, v78, v79, v80)
  v34.EnergyPool = v76
  v76 = v32:Name__8bf9582a()
  v77 = v31:IsContinuousBehavior()
  if v77 then
    v77 = v76 * 100
    v78 = 3
    v76 = v77 * v78
    v77 = u2
    v81 = u1
    v81 = v81.FormatNumber
    v83 = 0
    v84 = false
    v79 = v81(v76, v83, v84)
    v80 = "/s"
    v78 = v79 .. v80
    v79 = -v76
    v80 = nil
    v77 = v77(v78, v79, v80)
    v34.EnergyPerSecond = v77
  else
    v77 = u2
    v78 = u1
    v78 = v78.FormatNumber
    v80 = 0
    v81 = false
    v78 = v78(v76, v80, v81)
    v79 = -v76
    v80 = nil
    v77 = v77(v78, v79, v80)
    v34.EnergyPerShot = v77
  end
  v70 = WeakResource
  v71 = "/Lotus/Weapons/Corpus/Bow/Longbow/CrpBowArrowBase"
  v69 = {v70(v71)}
  if v61 ~= 0 then
    v68 = false
  else
    v68 = true
  end
  v75 = v70:GetDamagePct(v74)
  v76 = 0
  if v76 < v75 then
    v75 = v10(v74)
    v76 = v54[v74]
    if v76 == nil then
      v76 = u2
      v77 = nil
      v78 = 0
      v79 = nil
      v76 = v76(v77, v78, v79)
      v54[v75] = v76
    end
    v76 = u8
    v78 = v54[v75]
    v78 = v78.StatValue
    v80 = v70:GetDamagePct(v74)
    v79 = v80 * v71
    v77 = v78 + v79
    v76 = v76(v77)
    v54[v75] = v76
  end
  v72 = v52
  if v72 then
    v74 = WeakResource
    v75 = "/Lotus/Weapons/Infested/Pistols/InfestedDartPistol/InfestedDartPistolBolt"
    v72 = v52:IsA(v74(v75))
  end
  v71 = u12
  v75 = u1
  v75 = v75.Ternary
  v77 = "Embed"
  v78 = nil
  v69 = v71(v60, v11, v39, v75(v67, v77, v78))
  v71 = "/Lotus/Language/Labels/AVATAR_RADIAL_ATTACK"
  v72 = v30.turboGlaive
  if v72 ~= nil then
    v71 = "/Lotus/Language/Labels/AVATAR_BOUNCE_ATTACK"
  else
    if v42 then
      v71 = "/Lotus/Language/Stats/ChargedRadialAttack"
    end
  end
  v72 = { mName = nil, mIsMelee = nil, mBehaviorIndex = nil, mStats = nil, mExtra = true }
  v73 = string.upper
  v77 = false
  v73 = v73(v0:GetLocalized(v71, v77))
  v72.mName = v73
  v72.mIsMelee = v36
  v73 = v30.behaviorIndex
  v72.mBehaviorIndex = v73
  v72.mStats = v60
  v73 = table.insert
  v73(v9, v72)
  v71 = 0
  if v71 < v61 then
    v71 = u13
    v71(v0, v60, v1, v52, v53, v30, v31, v32, v33, v36, v5, v18, v62, v17)
    if v15 then
      v71 = v60.Total
      v73 = v71.DisplayValue
      v76 = "/Lotus/Language/Labels/GENERIC_MULTIPLIER"
      v77 = false
      v78 = { VALUE = 3 }
      v74 = v0:GetLocalized(v76, v77, v78)
      v72 = v73 .. v74
      v71.DisplayValue = v72
      v60.Total = v71
    end
  end
  v71 = v53.baseAmount
  v71 = "/Lotus/Language/Stats/TIP_Accuracy_VeryHigh"
  v72 = u2
  v76 = false
  v73 = v0:GetLocalized(v71, v76)
  v74 = 100
  v75 = true
  v72 = v72(v73, v74, v75)
  v34.Accuracy = v72
  v74 = true
  v75 = 0
  v73 = v32:GetSpread(v74, v75)
  v76 = true
  v77 = 0
  v78 = false
  v74 = v32:GetSpread(v76, v77, v78)
  if v74 == 0 then
    v72 = v72 + 1
  end
  v74 = 0
  v74 = v32:Name__eda17dce()
  if v74 then
    v76 = v2:GetWeaponEnergyRegenSpeed()
    v77 = 106
    v74 = v18:GetUpgradeModifiedValue(v76, v77)
    v75 = u2
    v79 = u1
    v79 = v79.FormatNumber
    v81 = 0
    v82 = false
    v77 = v79(v74, v81, v82)
    v78 = "/s"
    v76 = v77 .. v78
    v78 = nil
    v75 = v75(v76, v74, v78)
    v34.RechargeRate = v75
    v75 = v2:Name__3bc90eb6()
    v78 = "/Lotus/Language/Menu/ProgressSeconds"
    v79 = false
    v80 = { CURRENT = nil }
    v81 = u1
    v81 = v81.FormatNumber
    v83 = 1
    v84 = false
    v81 = v81(v75, v83, v84)
    v80.CURRENT = v81
    v76 = v0:GetLocalized(v78, v79, v80)
    v77 = u2
    v79 = -v75
    v80 = nil
    v77 = v77(v76, v79, v80)
    v34.RechargeDelay = v77
  end
  v76 = gLotusWeaponProjectileFireBehaviorType
  v74 = v32:IsA(v76)
  if v74 then
    v74 = v32:Name__a27d16d0()
    if v74 ~= 0 then
      v75 = u13
      v88 = nil
      v75(v0, v34, v1, v52, v53, v30, v31, v32, v33, v36, v5, v18, v88, v17)
    end
  end
  if v21 then
    v71 = v30.turboGlaive
    if v71 ~= nil then
      v71 = {}
      v38 = true
      v74 = false
      v62 = v1:GetExplosionDamage(v74, v52)
      v74 = v52:Name__836612ff()
      v73 = v74 * 100
      v74 = 0
      v72 = math.max
      v72 = v72(v73, v74)
      v73 = u2
      v74 = u9
      v74 = v74(v72)
      v76 = nil
      v73 = v73(v74, v72, v76)
      v71.DamageFallOff = v73
      v73 = u2
      v74 = u11
      v75 = v62.radius
      v76 = 2
      v74 = v74(v75, v76)
      v75 = v62.radius
      v76 = nil
      v77 = nil
      v78 = u1
      v78 = v78.Ternary
      v80 = "MeleeRange"
      v81 = "AoERange"
      v73 = v73(v74, v75, v76, v77, v78(v36, v80, v81))
      v71.Range = v73
      v74 = u1
      v74 = v74.Ternary
      v77 = 1
      v74 = v74(v5, v55, v77)
      v73 = v3 * v74
      v74 = v52:Name__f53b9cc4()
      v48 = v73 * v74
      v73 = next
      v73 = v73(v54)
      if v73 then
        v73 = u16
        v78 = 1
        v73(v71, v62, v11, v48, v78)
      end
      v73 = { mName = nil, mBehaviorIndex = nil, mIsHeavyAttack = true, mStats = nil, mExtra = true }
      v74 = string.upper
      v77 = "/Lotus/Language/Labels/AVATAR_HEAVY_ATTACK"
      v78 = false
      v74 = v74(v0:GetLocalized(v77, v78))
      v73.mName = v74
      v74 = v30.behaviorIndex
      v73.mBehaviorIndex = v74
      v73.mStats = v71
      v74 = table.insert
      v74(v9, v73)
    end
  end
  if not ((v5 or not v11)) then
    v78 = WeakResource
    v79 = "/Lotus/Weapons/CrewShip/RailjackOrdnanceWeapon"
    v76 = v1:IsA(v78(v79))
    if v76 then
      v76 = v1:GetClipSize()
      v74 = v74 + v76
    end
  end
  v76 = math.floor
  v74 = v76(v74)
  v73 = u0
  v73 = v73.IsPseudoExalted
  v73 = v73(v1)
  v74 = v1:Name__ec99d38d()
  v74 = v74:GetWeaponRange()
  v75 = v18:IsSpaceMode()
  if v75 then
    v75 = v1:Name__ec99d38d()
    v77 = false
    v74 = v75:GetLockOnDistance(v77)
  end
  if v73 then
    v75 = _T.PseudoExaltedAdditionalStats
    if v75 then
      v75 = _T.PseudoExaltedAdditionalStats.mRange
      if v75 then
        v75 = _T.PseudoExaltedAdditionalStats.mRange
        v74 = v74 + v75
      end
    end
  end
  v75 = u2
  v76 = u11
  v78 = 2
  v76 = v76(v74, v78)
  v78 = nil
  v79 = nil
  v80 = u1
  v80 = v80.Ternary
  v82 = "MeleeRange"
  v83 = "AoERange"
  v75 = v75(v76, v74, v78, v79, v80(v36, v82, v83))
  v34.Range = v75
  v75 = v18:IsSpaceMode()
  v86 = 30
  v87 = true
  v2:SetPostureModifier(v86, v87)
  v86 = 4
  v84 = v33:Name__96ff68fb(v86)
  v87 = 4
  v85 = v33:GetMeleeAttack(v87)
  v86 = 1
  v87 = 1
  v88 = IsNull
  v88 = v88(v85)
  if not v88 then
    v86 = v85:Name__dab108e3()
    v88 = 1
    if v88 < v86 then
      v90 = 0
      v87 = v85:Name__1beb0183(v90)
      if v87 == 0.01 then
        v87 = 0
      end
    end
  end
  v88 = u14
  v88 = v88(v84, v87)
  v89 = u1
  v89 = v89.FormatNumber
  v90 = v88
  v91 = u1
  v91 = v91.Ternary
  v93 = 999.9
  if v93 <= v88 then
    v92 = false
  else
    v92 = true
  end
  v93 = 1
  v94 = 0
  v91 = v91(v92, v93, v94)
  v92 = false
  v89 = v89(v90, v91, v92)
  v90 = 1
  if v90 < v86 then
    v91 = " x"
    v92 = u1
    v92 = v92.FormatNumber
    v94 = 0
    v95 = false
    v92 = v92(v86, v94, v95)
    v89 = v89 .. v91 .. v92
  end
  v90 = u2
  v93 = nil
  v90 = v90(v89, v88, v93)
  v83.HeavyAttack = v90
  v92 = 30
  v93 = false
  v2:SetPostureModifier(v92, v93)
  v71 = v1:GetAmmoExType()
  v73 = v1:GetProductCategory()
  v74 = 16
  if v73 ~= v74 then
    v72 = false
  else
    v72 = true
  end
  v74 = v32:UsesAmmo()
  v73 = not v74
  if v73 then
    v73 = v32:ConsumesChargesForFire()
  end
  v74 = 0
  v75 = 0
  v59 = true
  v60 = true
  v57 = v33:GetPlayerDamageMultiplier(v59, v60)
  v58 = 1
  v55 = v55(v56, v57, v58)
  if not ((not v5 or v35)) then
    v56 = v1:Name__5a615971()
    v58 = 1
    v60 = 1
    v59 = v60 * v56
    v57 = v58 + v59
    v58 = Localize
    v59 = "/Lotus/Language/Menu/WeaponStats_MultipilerStat"
    v60 = { STAT = nil }
    v61 = u1
    v61 = v61.FormatNumber
    v63 = 1
    v64 = false
    v61 = v61(v57, v63, v64)
    v60.STAT = v61
    v58 = v58(v59, v60)
    v59 = u2
    v62 = nil
    v59 = v59(v58, v57, v62)
    v34.HeadShotMult = v59
  end
  if v16 then
    v56 = IsNull
    v56 = v56(v18)
    if not v56 then
      v58 = 1
      v59 = 275
      v60 = v1:GetType()
      v62 = 25
      v63 = EMPTY_SYMBOL
      v39 = v18:GetUpgradeModifiedValue(v58, v59, v60, v1, v62, v63)
    end
  end
  if v39 ~= 1 then
    v56 = false
  else
    v56 = true
  end
  v57 = u1
  v57 = v57.FormatNumber
  v59 = 1
  v60 = false
  v57 = v57(v39, v59, v60)
  v58 = v1:Name__62e4017e()
  if not ((not v58 or v16)) then
    v62 = "<LOCKED> "
    v63 = true
    v58 = v0:GetLocalized(v62, v63)
    v57 = v58 .. v57
    v56 = false
  end
  v58 = v32:IgnoreFireIterations()
  if not v58 then
    v58 = u2
    v61 = nil
    v62 = nil
    v63 = nil
    v64 = nil
    v65 = nil
    v66 = nil
    v67 = nil
    v58 = v58(v57, v39, v61, v62, v63, v64, v65, v66, v67, v56)
    v34.Multishot = v58
  else
    v39 = 1
  end
  v58 = v1:GetEmbedDamage(v52)
  v59 = v58:GetBaseAmount()
  v59 = v59:GetModifiedValue()
  v60 = 0
  if v68 then
    v68 = false
    v75 = true
    v62 = v1:GetExplosionDamage(v75, v52)
    v73 = v62:GetBaseAmount()
    v61 = v73:GetModifiedValue()
    v73 = 0
    if v73 < v61 then
      v38 = true
      v67 = true
      v68 = true
      v73 = u1
      v73 = v73.Ternary
      v76 = 1
      v73 = v73(v5, v55, v76)
      v48 = v47 * v73
      v73 = u10
      v78 = nil
      v79 = "Embed"
      v73(v60, v62, v11, v48, v78, v79)
    end
  end
  v73 = 0
  if not ((v59 <= v73 or v72)) then
    v38 = true
    v67 = true
  end
  if not v68 then
    v73 = v1:ProjectileEmbedTime(v52)
    v74 = nil
    v75 = v73.minValue
    v76 = v73.maxValue
    if v75 == v76 then
      v75 = u1
      v75 = v75.FormatNumber
      v76 = v73.minValue
      v77 = 1
      v78 = false
      v74 = v75(v76, v77, v78)
    else
      v78 = u1
      v78 = v78.FormatNumber
      v79 = v73.minValue
      v80 = 1
      v81 = false
      v75 = v78(v79, v80, v81)
      v76 = " - "
      v77 = u1
      v77 = v77.FormatNumber
      v78 = v73.maxValue
      v79 = 1
      v80 = false
      v77 = v77(v78, v79, v80)
      v74 = v75 .. v76 .. v77
    end
    if v74 ~= nil then
      v77 = 0.5
      v75 = v73:MapToRange(v77)
      v76 = 0
      if v76 < v75 then
        if v68 then
          v76 = u2
          v79 = nil
          v80 = nil
          v81 = nil
          v82 = nil
          v83 = nil
          v84 = nil
          v85 = nil
          v86 = nil
          v87 = nil
          v88 = true
          v76 = v76(v74, v75, v79, v80, v81, v82, v83, v84, v85, v86, v87, v88)
          v60.EmbedDelay = v76
        else
          v76 = u2
          v79 = nil
          v76 = v76(v74, v75, v79)
          v60.EmbedTime = v76
        end
      end
    end
    v77 = v62.fallOff
    v76 = v77 * 100
    v77 = 0
    v75 = math.max
    v75 = v75(v76, v77)
    v76 = 0
    if v76 < v75 then
      v76 = u2
      v77 = u9
      v77 = v77(v75)
      v79 = nil
      v76 = v76(v77, v75, v79)
      v60.EmbedFallOff = v76
    end
  end
  v71 = v30.turboGlaive
  if v71 == nil then
    v73 = Symbol
    v74 = "NO_ATTACK_SPEED"
    v71 = v1:Name__64182bfb(v73(v74))
    if not v71 then
      v71 = 2
      v72 = 1
      if v50 < v72 then
        v71 = 3
      end
      if v72 <= v50 then
        v72 = u2
        v73 = u1
        v73 = v73.FormatNumber
        v76 = false
        v73 = v73(v50, v71, v76)
        v75 = nil
        v72 = v72(v73, v50, v75)
        v34.FireRateMelee = v72
      else
        v74 = CanAllyPrime
        v72 = v31:IsA(v74)
        if v72 then
          v72 = v31:GetRefireWaitTime()
          v73 = 1 / v50
          if v73 < v72 then
            v50 = 1 / v72
          end
        end
        v72 = u1
        v72 = v72.FormatNumber
        v75 = false
        v72 = v72(v50, v71, v75)
        v73 = v1:Name__bf0191ef()
        v74 = 0
        if v74 < v73 then
          v77 = "<LOCKED> "
          v78 = true
          v73 = v0:GetLocalized(v77, v78)
          v72 = v73 .. v72
        end
        v73 = u2
        v76 = nil
        v73 = v73(v72, v50, v76)
        v34.FireRate = v73
      end
    end
  end
  v73 = 0
  v71 = 19
  v72 = 1
  v84 = IsNull
  v84 = v84(v75)
  if not v84 then
    v86 = Name__beda8ef9
    v84 = v31:IsA(v86)
    if v84 then
      v84 = v31:GetChargeTime()
      v88 = v75:Name__0683b84b()
      v89 = 327
      v90 = v1:GetType()
      v86 = v18:GetUpgradeModifiedValue(v88, v89, v90, v1)
      if v86 ~= 0 then
        v87 = v84 / v86
        v88 = u2
        v89 = u6
        v91 = 2
        v89 = v89(v87, v91)
        v90 = -v87
        v91 = nil
        v92 = nil
        v93 = nil
        v94 = nil
        v95 = nil
        v96 = 2
        v97 = nil
        if v85 ~= v86 then
          v98 = false
        else
          v98 = true
        end
        v88 = v88(v89, v90, v91, v92, v93, v94, v95, v96, v97, v98)
        v83.HeavyAttackWindUp = v88
      end
    end
  end
  v84 = Symbol
  v85 = "HeavySlam"
  v87 = v84(v85)
  v85 = v1:GetSlamRadius(v87)
  v86 = IsNull
  v86 = v86(v1:GetFiringAvatar())
  if not v86 then
    v86 = v1:GetFiringAvatar()
    v88 = 30
    v89 = true
    v86:SetPostureModifier(v88, v89)
    v86 = v1:Name__e22fb830(v84)
    v87 = v1:GetFiringAvatar()
    v89 = 30
    v90 = false
    v87:SetPostureModifier(v89, v90)
    v89 = v86.fallOffMax
    v88 = v89 * 100
    v89 = 0
    v87 = math.max
    v87 = v87(v88, v89)
    v88 = u8
    v89 = u14
    v88 = v88(v89(v86))
    v83.HeavySlamAttack = v88
    v88 = v83.HeavySlamAttack
    v90 = { TEXT = "/Lotus/Language/Stats/TIP_SlamAttackRadius", VARS = nil }
    v91 = { AMOUNT = nil }
    v91.AMOUNT = v85
    v90.VARS = v91
    v91 = { TEXT = "/Lotus/Language/Stats/TIP_SlamAttackFalloff", VARS = nil, comparisonFlipped = true }
    v92 = { AMOUNT = nil }
    v92.AMOUNT = v87
    v91.VARS = v92
    v89 = {v90, v91}
    v88.SecondaryToolTips = v89
  end
  v86 = v33:GetComboEfficiency()
  v86 = v86 * 100
  v87 = u2
  v88 = u9
  v88 = v88(v86)
  v89 = v86
  v90 = nil
  v91 = nil
  v92 = nil
  v93 = nil
  v94 = nil
  v95 = nil
  v96 = nil
  if v86 ~= 0 then
    v97 = false
  else
    v97 = true
  end
  v87 = v87(v88, v89, v90, v91, v92, v93, v94, v95, v96, v97)
  v83.ComboEfficiency = v87
  v87 = v1:Name__daee522c()
  if v87 then
    v87 = v1:GetEmpoweredMeleeChance()
    v88 = u2
    v89 = u9
    v90 = v87 * 100
    v89 = v89(v90)
    v90 = v87
    v91 = nil
    v92 = nil
    v93 = nil
    v94 = nil
    v95 = nil
    v96 = nil
    v97 = nil
    if v87 ~= 0 then
      v98 = false
    else
      v98 = true
    end
    v88 = v88(v89, v90, v91, v92, v93, v94, v95, v96, v97, v98)
    v83.Tennokai_Chance = v88
  end
  v87 = { mName = nil, mIsMelee = true, mIsHeavyAttack = true, mBehaviorIndex = nil, mStats = nil, mExtra = true }
  v88 = string.upper
  v91 = "/Lotus/Language/Labels/AVATAR_HEAVY_ATTACK"
  v92 = false
  v88 = v88(v0:GetLocalized(v91, v92))
  v87.mName = v88
  v88 = v30.behaviorIndex
  v87.mBehaviorIndex = v88
  v87.mStats = v83
  v88 = table.insert
  v88(v9, v87)
  if not v73 then
    v76 = u1
    v76 = v76.Round
    v76 = v76(v1:Name__bc09d984(v5))
    v77 = v1:InfiniteClipsForPlayers()
    v78 = nil
    if v77 then
      v76 = 4294967295
      v81 = "<INFINITE_SMALL>"
      v82 = true
      v78 = v0:GetLocalized(v81, v82)
    end
    v79 = 0
    if not v77 then
      if not ((v11 or v72)) then
        v79 = v1:Name__46beef39()
        if not ((v79 or v77)) then
          v79 = IsNull
          v79 = v79(v71)
          if not v79 then
            v79 = v1:IsHeavyWeapon()
            if not v79 then
              v75 = v1:GetAmmoPickupCount()
              if v75 == 0 then
                v79 = u17
                v79 = v79:GetAmmoExType()
                if v71 == v79 then
                  v79 = u17
                  v75 = v79:GetAmmoAmount()
                else
                  v79 = u18
                  v75 = v79:GetAmmoAmount()
                end
              end
              v82 = 222
              v75 = v18:GetUpgradeModifiedValue(v75, v82, v71)
            end
          end
        end
      end
      v79 = v1:GetReloadTime()
      v80 = v1:GetClipSize()
      if not ((v80 ~= 0 or v77)) then
        v76 = 1
        v78 = nil
      else
        v81 = v1:GetGripType()
        v82 = 17
        if v81 == v82 then
          v76 = 0
        else
          v81 = 0
          if v81 < v80 then
            v76 = v80
            v78 = nil
          end
        end
      end
      v81 = u2
      v81 = v81(v78, v76)
      v34.Mag = v81
      v81 = v34.Mag
      v82 = {}
      v81.SecondaryToolTips = v82
      if v76 ~= 4294967295 then
        v82 = v34.Mag
        v82 = v82.SecondaryToolTips
        v83 = { TEXT = "/Lotus/Language/Stats/TIP_MaxAmmo", VARS = nil }
        v84 = { AMOUNT = nil }
        v84.AMOUNT = v74
        v83.VARS = v84
        v81 = table.insert
        v81(v82, v83)
        v82 = v34.Mag
        v82 = v82.SecondaryToolTips
        v83 = { TEXT = "/Lotus/Language/Stats/TIP_AmmoPickupCount", VARS = nil }
        v84 = { AMOUNT = nil }
        v84.AMOUNT = v75
        v83.VARS = v84
        v81 = table.insert
        v81(v82, v83)
      end
      v81 = v1:GetReloadTime()
      v82 = u2
      v83 = u6
      v85 = 1
      v83 = v83(v81, v85)
      v84 = -v81
      v85 = nil
      v86 = nil
      v87 = nil
      v88 = nil
      v89 = nil
      v90 = nil
      v91 = nil
      v93 = 0.01
      if v93 < v81 then
        v92 = false
      else
        v92 = true
      end
      v82 = v82(v83, v84, v85, v86, v87, v88, v89, v90, v91, v92)
      v34.Reload = v82
      v82 = u2
      v83 = u1
      v83 = v83.FormatNumber
      v85 = 0
      v86 = false
      v83 = v83(v70, v85, v86)
      v84 = -v70
      v85 = nil
      v82 = v82(v83, v84, v85)
      v34.AmmoReq = v82
    end
  else
    v76 = u2
    v77 = nil
    v78 = v1:Name__e9a55c21()
    v79 = nil
    v76 = v76(v77, v78, v79)
    v34.MaxCharges = v76
  end
  v60 = {}
  v61 = 0
  v62 = nil
  v63 = false
  v66 = WeakResource
  v67 = "/Lotus/Powersuits/Choir/ChoirEruptWeaponBase"
  v64 = v1:IsA(v66(v67))
  v65 = false
  v66 = v30.turboGlaive
  if v66 == nil then
    v65 = not v64
  end
  v68 = WeakResource
  v69 = "/Lotus/Weapons/ClanTech/Energy/EnergyRifle"
  v66 = v1:IsA(v68(v69))
  if v66 ~= nil then
    v70 = v52:Name__bf644496()
    v71 = 386
    v72 = v1:GetType()
    v68 = v18:GetUpgradeModifiedValue(v70, v71, v72, v1)
    v67 = v68 * 100
    v68 = 0
    if v67 <= v68 then
      v65 = false
    else
      v65 = true
    end
    if v65 then
      v68 = 100
      if v67 < v68 then
        v68 = u2
        v69 = u9
        v69 = v69(v67)
        v71 = nil
        v68 = v68(v69, v67, v71)
        v60.BounceChance = v68
      end
    end
  end
  if v65 then
    v69 = gRadialOnMissImpactBehaviorType
    v67 = v33:IsA(v69)
    if v67 then
      v62 = v33:GetRadialDamageData(v5)
      v67 = v62:GetBaseAmount()
      v61 = v67:GetModifiedValue()
    end
    if not v67 then
      v69 = gRadialOnMissTraceFireBehaviorType
      v67 = v32:IsA(v69)
      if v67 then
        v62 = v32:GetRadialDamageData(v5)
      else
        v63 = true
        v69 = false
        v62 = v1:GetExplosionDamage(v69, v52)
      end
      v67 = v62:GetBaseAmount()
      v61 = v67:GetModifiedValue()
    end
  end
  v67 = 0
  if not (((v61 <= v67 or v66) or v16)) then
    v38 = true
    v67 = u1
    v67 = v67.Ternary
    v70 = 1
    v67 = v67(v5, v55, v70)
    v48 = v47 * v67
    v67 = u10
    v67(v60, v62, v11, v48)
    v69 = v62.fallOff
    v68 = v69 * 100
    v69 = 0
    v67 = math.max
    v67 = v67(v68, v69)
    v68 = u2
    v69 = u9
    v69 = v69(v67)
    v71 = nil
    v68 = v68(v69, v67, v71)
    v60.DamageFallOff = v68
  end
  v67 = false
  v68 = false
  v69 = v1:Name__7ffc2d2c(v52)
  v75 = v1:GetMeleeTree()
  if not v73 then
    v78 = 6
    v76 = v33:Name__96ff68fb(v78)
    v77 = u8
    v78 = u14
    v77 = v77(v78(v76))
    v34.SlideAttack = v77
    v77 = v1:GetSlamRadius()
    v78 = IsNull
    v78 = v78(v1:GetFiringAvatar())
    if not v78 then
      v78 = v1:Name__e22fb830()
      v81 = v78.fallOffMax
      v80 = v81 * 100
      v81 = 0
      v79 = math.max
      v79 = v79(v80, v81)
      v80 = u8
      v81 = u14
      v80 = v80(v81(v78))
      v34.SlamAttack = v80
      v80 = v34.SlamAttack
      v82 = { TEXT = "/Lotus/Language/Stats/TIP_SlamAttackRadius", VARS = nil }
      v83 = { AMOUNT = nil }
      v83.AMOUNT = v77
      v82.VARS = v83
      v83 = { TEXT = "/Lotus/Language/Stats/TIP_SlamAttackFalloff", VARS = nil, comparisonFlipped = true }
      v84 = { AMOUNT = nil }
      v84.AMOUNT = v79
      v83.VARS = v84
      v81 = {v82, v83}
      v80.SecondaryToolTips = v81
    end
    v78 = IsNull
    v78 = v78(v75)
    if v78 then
      v80 = v75:Name__19894fe1()
      v81 = 311
      v82 = v1:GetType()
      v78 = v18:GetUpgradeModifiedValue(v80, v81, v82, v1)
      v79 = u2
      v80 = u9
      v81 = v78 * 100
      v80 = v80(v81)
      v82 = nil
      v79 = v79(v80, v78, v82)
      v34.FollowThrough = v79
      v81 = Symbol
      v82 = "SWORDS_AND_SHIELD_STANCE"
      v80 = v75:Name__64182bfb(v81(v82))
      if not v80 then
        v80 = v1:Name__c9440100()
      end
      v81 = v1:GetParryAngle()
      v82 = u2
      v83 = u15
      v83 = v83(v81)
      v85 = nil
      v86 = nil
      v87 = nil
      v89 = nil
      v90 = nil
      v91 = nil
      v92 = not v80
      v82 = v82(v83, v81, v85, v86, v87, v81, v89, v90, v91, v92)
      v34.BlockingAngle = v82
    end
  end
  v76 = v33:GetInitialHitCounter()
  v77 = v33:Name__fffb815c()
  v80 = true
  v78 = v33:Name__70a26833(v80)
  v79 = u6
  v81 = 1
  v79 = v79(v78, v81)
  if not ((not v77 or v78 == 0)) then
    v78 = 1e9999
    v82 = "<INFINITE_SMALL>"
    v83 = true
    v79 = v0:GetLocalized(v82, v83)
  end
  v82 = 1
  v83 = 317
  v84 = v1:GetType()
  v80 = v18:GetUpgradeModifiedValue(v82, v83, v84, v1)
  if v80 == 1 then
    v81 = false
  else
    v81 = true
  end
  v82 = v33:InfosClaw()
  v83 = u2
  v86 = nil
  v83 = v83(v79, v78, v86)
  v34.ComboDuration = v83
  v83 = v34.ComboDuration
  v84 = {}
  v83.SecondaryToolTips = v84
  if v82 then
    v83 = 0
    if v83 < v76 then
      v84 = v34.ComboDuration
      v84 = v84.SecondaryToolTips
      v85 = { TEXT = "/Lotus/Language/Stats/TIP_ComboCount", VARS = nil }
      v86 = { AMOUNT = nil }
      v86.AMOUNT = v76
      v85.VARS = v86
      v83 = table.insert
      v83(v84, v85)
    end
  end
  if v81 then
    v83 = 1
    if v83 < v80 then
      v84 = v80 - 1
      v83 = v84 * 100
      v85 = v34.ComboDuration
      v85 = v85.SecondaryToolTips
      v86 = { TEXT = "/Lotus/Language/Stats/TIP_ComboCountChance", VARS = nil }
      v87 = { AMOUNT = nil }
      v87.AMOUNT = v83
      v86.VARS = v87
      v84 = table.insert
      v84(v85, v86)
    end
  end
  v34 = v30.behaviorIndex
  v32 = v1:GetFireBehavior(v34)
  v35 = v30.behaviorIndex
  v33 = v1:GetImpactBehavior(v35)
  v36 = v30.behaviorIndex
  v37 = false
  v1:SetBehavior(v36, v37)
  v34 = {}
  v35 = v1:IsMeleeWeapon()
  if v35 then
    v37 = gMeleeImpactBehaviorType
    v35 = v33:IsA(v37)
  end
  v38 = Name__7e8c54ab
  v36 = v31:IsA(v38)
  v37 = nil
  v38 = false
  v39 = v30.extraStateBehavior
  if v39 then
    v39 = v31:Name__0641d38c()
    if v39 then
      v39 = "/Lotus/Language/Menu/SecondaryFire"
      v30.localizedTag = v39
    end
  end
  v39 = v30.localizedTag
  if v39 then
    v39 = { mName = nil, mIsMelee = nil, mBehaviorIndex = nil, mStats = nil }
    v40 = string.upper
    v43 = v30.localizedTag
    v44 = false
    v40 = v40(v0:GetLocalized(v43, v44))
    v39.mName = v40
    v39.mIsMelee = v36
    v40 = v30.behaviorIndex
    v39.mBehaviorIndex = v40
    v39.mStats = v34
    v37 = v39
    v39 = table.insert
    v39(v9, v37)
  end
  local v41 = 1
  v32:SetDeltaModifier(v41)
  if not v35 then
    v39 = v31:GetLocTag()
    v42 = v39:c_str()
    v43 = false
    v40 = v0:GetLocalized(v42, v43)
    if v40 ~= "" then
      v41 = StringSplit
      v42 = "/"
      v39 = v41(v42, v39)
      v41 = string.gsub
      v43 = #v39
      v42 = v39[v43]
      v43 = "Loadout_"
      v44 = ""
      v39 = v41(v42, v43, v44)
      v43 = gWeaponBurstStateBehaviorType
      v41 = v31:IsA(v43)
      if v41 then
        v41 = v31:Name__76f26b92()
        if v41 ~= nil then
          v43 = " "
          v46 = "/Lotus/Language/Stats/BurstNumShotsUnit"
          v47 = false
          v48 = { COUNT = nil }
          v48.COUNT = v41
          v44 = v0:GetLocalized(v46, v47, v48)
          v40 = v40 .. v43 .. v44
        end
      end
      v41 = u2
      v43 = nil
      v44 = true
      v45 = nil
      v41 = v41(v40, v43, v44, v45, v39)
      v34.Trigger = v41
    end
    v43 = gLotusWeaponProjectileFireBehaviorType
    v41 = v32:IsA(v43)
    if v41 then
      v41 = v32:Name__22e9974f()
      v42 = v32:Name__a27d16d0()
      if not ((not (v41 ~= 0) and v42 == 0)) then
        v43 = u2
        v48 = u1
        v48 = v48.FormatNumber
        v50 = 0
        v51 = false
        v45 = v48(v41, v50, v51)
        v46 = " - "
        v47 = u1
        v47 = v47.FormatNumber
        v49 = 0
        v50 = false
        v47 = v47(v42, v49, v50)
        v44 = v45 .. v46 .. v47
        v46 = nil
        v43 = v43(v44, v41, v46)
        v34.DT_StackDamage = v43
      end
    end
    v43 = 1
    v44 = 342
    v45 = v1:GetType()
    v41 = v18:GetUpgradeModifiedValue(v43, v44, v45, v1)
    if v41 ~= 0 then
      v42 = false
    else
      v42 = true
    end
    v43 = v1:IsSilent()
    v44 = v32:GetProjectileType()
    v45 = false
    v46 = IsNull
    v46 = v46(v44)
    if not v46 then
      v46 = Resource
      v44 = v46(v44)
      v46 = IsNull
      v46 = v46(v44)
      if not v46 then
        v45 = v44:Name__71a0f7f1()
      end
    end
    v46 = "/Lotus/Language/Labels/WEAPON_NOISELOUD"
    v47 = v43
    if not v47 then
      v47 = v45
      if not v47 then
        v47 = v42
      end
    end
    if v47 then
      v46 = "/Lotus/Language/Labels/WEAPON_NOISEQUIET"
    else
      v48 = 1
      if v41 < v48 then
        v48 = 0
        if v48 < v41 then
          v46 = "/Lotus/Language/Labels/WEAPON_NOISESUPPRESSED"
        end
      end
    end
    v48 = u2
    v52 = false
    v49 = v0:GetLocalized(v46, v52)
    v50 = nil
    v51 = true
    v52 = nil
    v53 = nil
    v54 = nil
    v55 = nil
    v56 = nil
    v57 = nil
    v58 = false
    if v41 == 1 then
      v58 = not v47
    end
    v48 = v48(v49, v50, v51, v52, v53, v54, v55, v56, v57, v58)
    v34.Noise = v48
  end
  v1:SetFullyCharged()
  v39 = 1
  v40 = v30.ignoreMultishot
  if not v40 then
    v39 = v32:Name__ce5dfdb0()
  end
  v40 = nil
  v41 = nil
  v42 = false
  v43 = false
  v44 = nil
  v45 = nil
  v46 = false
  v47 = v3
  v48 = 0
  v49 = false
  v50 = v1:Name__fa54e90a()
  v53 = Name__539c8440
  v51 = v31:IsA(v53)
  if v40 then
    v1:SetAmmoInClip(v1:Name__bc09d984(v5))
    v53 = 0
    v31:GotoState(v53)
    v47 = v31:Name__6760a39b()
    v51 = v31:Name__4f5ee78b()
    v52 = v31:Name__4f5ee78b()
    if not ((not ((v52 ~= 1 or v14)) and not v13)) then
      v54 = 1
      v31:SetDamageMultiplier(v54)
      v52 = v30.projectileType
      v53 = v30.behaviorIndex
      v54 = v30.turboGlaive
      v55 = u4
      v55 = v55.GetProjectileAndDamageData
      v55, v56 = v55(v1, v5, v52, v53, v54)
      v57 = u5
      v74 = "/Lotus/Language/Stats/QuickShot"
      v75 = "/Lotus/Language/Stats/QuickShotRadialAttack"
      v40, v41, v49 = v57(v0, v1, v55, v56, v30, v31, v32, v33, v36, v35, v11, v4, v3, v39, v5, v18, v74, v75, v17)
      v57 = true
      if v40 == nil then
        if v41 == nil then
          v57 = false
        else
          v57 = true
        end
      end
      v42 = v57
      v59 = gLotusWeaponProjectileFireBehaviorType
      v57 = v32:IsA(v59)
      if v40 ~= nil then
        v55 = v32:Name__e1882fa1()
        v57 = IsNull
        v57 = v57(v55)
        if not v57 then
          v57 = Resource
          v55 = v57(v55)
          v57 = IsNull
          v57 = v57(v55)
          if not v57 then
            v60 = 0
            v61 = v30.behaviorIndex
            v56 = v1:Name__1f4d79ac(v55, v60, v61)
            v57 = u5
            v74 = "/Lotus/Language/Stats/PerfectShot"
            v75 = "/Lotus/Language/Stats/PerfectShotRadialAttack"
            v44, v45, v38 = v57(v0, v1, v55, v56, v30, v31, v32, v33, v36, v35, v11, v4, v3, v39, v5, v18, v74, v75, v17)
            v57 = true
            if v44 == nil then
              if v45 == nil then
                v57 = false
              else
                v57 = true
              end
            end
            v46 = v57
          end
        end
      end
    end
    v52 = v1:GetChargeTime()
    v53 = 0
    if v50 <= v53 then
      v53 = IsNull
      v53 = v53(v18)
      if not v53 then
        v55 = 1
        v56 = 276
        v57 = v1:GetType()
        v50 = v18:GetUpgradeModifiedValue(v55, v56, v57, v1)
      end
    end
    v53 = u2
    v54 = u6
    v56 = 2
    v54 = v54(v52, v56)
    v55 = -v52
    v56 = nil
    v53 = v53(v54, v55, v56)
    v34.ChargeRate = v53
    v43 = true
    v53 = v32.chargedProjectileType
    v30.projectileType = v53
  else
    v53 = gWeaponBurstStateBehaviorType
    v51 = v31:IsA(v53)
    if v51 then
      v1:SetAmmoInClip(v1:Name__bc09d984(v5))
    end
  end
  if v42 then
    v51 = table.insert
    v51(v9, v40)
  end
  if v41 ~= nil then
    v51 = table.insert
    v51(v9, v41)
  end
  v51 = "/Lotus/Language/Labels/WEAPON_DAMAGE_AMOUNT"
  if v43 then
    v51 = "/Lotus/Language/Stats/ChargedShot"
  else
    v52 = v32.fireIterations
    v53 = 1
    if v53 < v52 then
      v51 = "/Lotus/Language/Game/DamagePerProjectile"
    end
  end
  v52 = u7
  v62 = v36 and v35
  v63 = Localize
  v65 = {}
  v63 = v63(v51, v65)
  v52, v53, v54 = v52(v1, v30, v32, v5, v11, v39, v47, v4, v9, v62, v63, v16)
  v55 = Resource
  v52 = v55(v52)
  v55 = u1
  v55 = v55.Ternary
  v57 = v53.hitType
  v58 = 2
  v76 = 1
  v77 = v52
  if v77 then
    v79 = WeakResource
    v80 = "/Lotus/Weapons/Infested/InfestedLich/LongGuns/1999InfShotgun/1999InfFaceSucker"
    v77 = v52:IsA(v79(v80))
  end
  if not (((not (not v36) and v35) or v77)) then
    v76 = v39
  end
  v78 = u12
  v82 = nil
  v83 = nil
  v78 = v78(v54, v11, v76, v82, v83, v1, v18)
  v79 = u19
  v81 = v30.upgrades
  v79(v18, v81, v1, v54)
  if not v77 then
    v79 = u1
    v79 = v79.Ternary
    v81 = v32.fireIterations
    v82 = 1
    if v81 <= v82 then
      v80 = false
    else
      v80 = true
    end
    v81 = "ProcChancePerShot"
    v82 = "ProcChance"
    v79 = v79(v80, v81, v82)
    v80 = 0
    v81 = v54[v79]
    if v81 ~= nil then
      v81 = v54[v79]
      v80 = v81.StatValue
      v81 = v54[v79]
      v82 = u20
      v87 = false
      v89 = u1
      v89 = v89.Ternary
      v92 = nil
      v82 = v82(v0, v54, v80, v78, v87, v33, v89(v35, v1, v92))
      v81.SecondaryToolTips = v82
    end
    v81 = v60[v79]
    if v81 ~= nil then
      v81 = v60[v79]
      v80 = v81.StatValue
    end
    v81 = 0
    if v82 < v81 then
      v81 = 0
      if v81 < v69 then
        v81 = v60[v79]
        v81 = v60[v79]
        v82 = u20
        v87 = false
        v89 = u1
        v89 = v89.Ternary
        v92 = nil
        v82 = v82(v0, v60, v80, v69, v87, v33, v89(v35, v1, v92))
        v81.SecondaryToolTips = v82
        v81 = v54[v79]
        v81 = v81.SecondaryToolTips
        if v81 == nil then
          v81 = v54[v79]
          v82 = {}
          v81.SecondaryToolTips = v82
        end
        v81 = u20
        v86 = true
        v88 = u1
        v88 = v88.Ternary
        v91 = nil
        v81 = v81(v0, v60, v80, v69, v86, v33, v88(v35, v1, v91))
        v83 = v54[v79]
        v83 = v83.SecondaryToolTips
        v84 = { TEXT = "/Lotus/Language/Stats/TIP_ProcChancePerRadialDT", VARS = nil }
        v85 = {}
        v84.VARS = v85
        v82 = table.insert
        v82(v83, v84)
        v82 = ipairs
        v82, v83, v84 = v82(v81)
        for v85, v86 in v82, v83, v84 do
          v88 = v54[v79]
          v88 = v88.SecondaryToolTips
          v87 = table.insert
          v87(v88, v86)
        end
        for v85, v86 in v82, v83, v84 do
        end
      end
    end
  end
  if v42 then
    v79 = #v9
    v80 = 1
    if v80 < v79 then
      v79 = #v9
      v80 = u21
      v81 = v9[v79]
      v83 = v79 - 1
      v82 = v9[v83]
      v80 = v80(v81, v82)
      if v80 then
        v80 = nil
        v9[v79] = v80
      end
    end
  end
  if v46 then
    v79 = table.insert
    v79(v9, v44)
  end
  if v45 ~= nil then
    v79 = table.insert
    v79(v9, v45)
  end
  v81 = gLotusWeaponType
  v79 = v1:IsA(v81)
  if not v42 then
    v81 = "ShouldShowOmegaAttenStat"
    v82 = ""
    v79 = v0:Execute(v81, v82)
    if not ((not v79 or v29 ~= 1)) then
      v79 = v1:GetOmegaAttenuation()
      v80 = ""
      v81 = 0.7
      if v79 < v81 then
        v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenLowest"
        v84 = true
        v80 = v0:GetLocalized(v83, v84)
      else
        v81 = 0.9
        if v79 < v81 then
          v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenLow"
          v84 = true
          v80 = v0:GetLocalized(v83, v84)
        else
          v81 = 1.109
          if v79 <= v81 then
            v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenMedium"
            v84 = true
            v80 = v0:GetLocalized(v83, v84)
          else
            v81 = 1.309
            if v79 <= v81 then
              v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenHigh"
              v84 = true
              v80 = v0:GetLocalized(v83, v84)
            else
              v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenHighest"
              v84 = true
              v80 = v0:GetLocalized(v83, v84)
            end
          end
        end
      end
      v81 = u2
      v84 = nil
      v81 = v81(v80, v79, v84)
      v34.OmegaAtten = v81
    end
  end
  v81 = gWeaponTraceFireBehaviorType
  v79 = v32:IsA(v81)
  if v79 then
    v79 = v32:Name__a75a0be1()
    if not v79 then
      v80 = v32:GetTracePunctureDepth()
      v81 = u2
      v82 = u1
      v82 = v82.FormatNumber
      v84 = 1
      v85 = false
      v82 = v82(v80, v84, v85)
      v83 = v80
      v84 = nil
      v85 = nil
      v86 = nil
      v87 = nil
      v88 = nil
      v89 = nil
      v90 = nil
      if v80 ~= 0 then
        v91 = false
      else
        v91 = true
      end
      v81 = v81(v82, v83, v84, v85, v86, v87, v88, v89, v90, v91)
      v34.Punchthrough = v81
    else
      v80 = u2
      v83 = "<INFINITE_SMALL>"
      v84 = true
      v81 = v0:GetLocalized(v83, v84)
      v82 = 4294967295
      v83 = nil
      v80 = v80(v81, v82, v83)
      v34.Punchthrough = v80
    end
    v82 = 1
    v83 = 380
    v84 = v1:GetType()
    v80 = v18:GetUpgradeModifiedValue(v82, v83, v84, v1)
    if v80 ~= 0 then
      v38 = false
    else
      v38 = true
    end
    v83 = gWeaponBeamFireBehaviorType
    v81 = v32:IsA(v83)
    if v81 then
      v81 = v32:Name__f8393ca5()
      v82 = u2
      v83 = u1
      v83 = v83.FormatNumber
      v85 = 1
      v86 = false
      v83 = v83(v81, v85, v86)
      v82 = v82(v83, v81)
      v34.BeamRange = v82
    end
  else
    v81 = gWeaponProjectileFireBehaviorType
    v79 = v32:IsA(v81)
    if v79 then
      v79 = 0
      v80 = false
      v81 = v30.turboGlaive
      if v81 == true then
        v79 = v1:Name__81e9daf5(v32:GetTurboProjectileType(v5))
      else
        v81 = v32:GetProjectileType()
        v82 = IsNull
        v82 = v82(v81)
        if not v82 then
          v84 = gWaveProjectileType
          v82 = v81:IsA(v84)
          if v82 then
            v82 = Resource
            v82 = v82(v81)
            v83 = IsNull
            v83 = v83(v82)
            if not v83 then
              v83 = v82:AllowNormalContactBehavior()
              v80 = not v83
            end
          end
        end
        v79 = v1:Name__81e9daf5(v32:GetProjectileType())
      end
      if v80 then
        v81 = u2
        v84 = "<INFINITE_SMALL>"
        v85 = true
        v82 = v0:GetLocalized(v84, v85)
        v83 = 4294967295
        v84 = nil
        v81 = v81(v82, v83, v84)
        v34.Punchthrough = v81
      else
        v81 = u2
        v82 = u1
        v82 = v82.FormatNumber
        v84 = 1
        v85 = false
        v82 = v82(v79, v84, v85)
        v83 = v79
        v84 = nil
        v85 = nil
        v86 = nil
        v87 = nil
        v88 = nil
        v89 = nil
        v90 = nil
        if v79 ~= 0 then
          v91 = false
        else
          v91 = true
        end
        v81 = v81(v82, v83, v84, v85, v86, v87, v88, v89, v90, v91)
        v34.Punchthrough = v81
      end
    end
  end
  if v38 then
    if not ((not (not v42) and not v49)) then
      v79 = v34.Punchthrough
      if v79 ~= nil then
        v79 = u2
        v85 = "<LOCKED> "
        v86 = true
        v81 = v0:GetLocalized(v85, v86)
        v82 = "0"
        v80 = v81 .. v82
        v81 = 0
        v82 = nil
        v79 = v79(v80, v81, v82)
        v34.Punchthrough = v79
      end
    end
  end
  v79 = 0
  v82 = gWeaponProjectileFireBehaviorType
  v80 = v32:IsA(v82)
  v80 = v79.maxValue
  v81 = 0
  if v81 < v80 then
    v80 = { minValue = nil, maxValue = nil }
    v83 = v79.minValue
    v84 = 379
    v85 = v1:GetType()
    v81 = v18:GetUpgradeModifiedValue(v83, v84, v85, v1)
    v80.minValue = v81
    v83 = v79.maxValue
    v84 = 379
    v85 = v1:GetType()
    v81 = v18:GetUpgradeModifiedValue(v83, v84, v85, v1)
    v80.maxValue = v81
    v79 = v80
    v80 = v79.maxValue
    v81 = 0
    if v81 < v80 then
      v80 = u11
      v81 = v79.minValue
      v82 = u1
      v82 = v82.Ternary
      v84 = v79.minValue
      v85 = 999.9
      if v85 <= v84 then
        v83 = false
      else
        v83 = true
      end
      v84 = 1
      v85 = 0
      v80 = v80(v81, v82(v83, v84, v85))
      v81 = u11
      v82 = v79.maxValue
      v83 = u1
      v83 = v83.Ternary
      v85 = v79.maxValue
      v86 = 999.9
      if v86 <= v85 then
        v84 = false
      else
        v84 = true
      end
      v85 = 1
      v86 = 0
      v81 = v81(v82, v83(v84, v85, v86))
      v84 = " - "
      v82 = v80 .. v84 .. v81
      v83 = u2
      v85 = v79.minValue
      v86 = false
      v87 = true
      v83 = v83(v82, v85, v86, v87)
      v34.DamageFallOff = v83
    else
      v80 = u2
      v81 = "0"
      v82 = 0
      v83 = false
      v84 = true
      v80 = v80(v81, v82, v83, v84)
      v34.DamageFallOff = v80
    end
  end
  v80 = u0
  v80 = v80.IsPseudoExalted
  v80 = v80(v1)
  if v80 <= v81 then
    v80 = _T.PseudoExaltedAdditionalStats
    if v80 ~= nil then
      v80 = _T.PseudoExaltedAdditionalStats.GetDamageData
      if v80 ~= nil then
        v80 = _T.PseudoExaltedAdditionalStats.mName
        if v80 ~= nil then
          v82 = true
          v33:SetAlternateAttack(v82)
          v80 = _T.PseudoExaltedAdditionalStats.GetDamageData
          v83 = v80()
          v33:Name__54e4179e(v83)
          v83 = false
          v33:SetAlternateAttack(v83)
          v81 = _T.PseudoExaltedAdditionalStats.mCritChance
          if v81 then
            v83 = 244
            v84 = 0
            v85 = _T.PseudoExaltedAdditionalStats.mCritMult
            v86 = v1:GetType()
            v18:AddUpgrade(v83, v84, v85, v86, v1)
          end
          v81 = _T.PseudoExaltedAdditionalStats.mCritMult
          if v81 then
            v83 = 248
            v84 = 0
            v85 = _T.PseudoExaltedAdditionalStats.mCritMult
            v86 = v1:GetType()
            v18:AddUpgrade(v83, v84, v85, v86, v1)
          end
          v81 = {}
          v82 = u16
          v82(v81, v80)
          v82 = u13
          v86 = v32:GetProjectileType()
          v95 = nil
          v82(v0, v81, v1, v86, v80, v30, v31, v32, v33, v36, v5, v18, v95, v17)
          v82 = _T.PseudoExaltedAdditionalStats.mCritChance
          if v82 then
            v84 = 244
            v85 = 0
            v86 = _T.PseudoExaltedAdditionalStats.mCritMult
            v87 = v1:GetType()
            v18:RemoveUpgrade(v84, v85, v86, v87, v1)
          end
          v82 = _T.PseudoExaltedAdditionalStats.mCritMult
          if v82 then
            v84 = 248
            v85 = 0
            v86 = _T.PseudoExaltedAdditionalStats.mCritMult
            v87 = v1:GetType()
            v18:RemoveUpgrade(v84, v85, v86, v87, v1)
          end
          v82 = next
          v82 = v82(v81)
          if v82 then
            v82 = { mName = nil, mBehaviorIndex = nil, mStats = nil, mExtra = true }
            v83 = string.upper
            v86 = _T.PseudoExaltedAdditionalStats.mName
            v87 = false
            v83 = v83(v0:GetLocalized(v86, v87))
            v82.mName = v83
            v83 = v30.behaviorIndex
            v82.mBehaviorIndex = v83
            v82.mStats = v81
            v83 = table.insert
            v83(v9, v82)
          end
        end
      end
    end
  end
  v80 = u22
  v80(v1, v34)
  v80 = u23
  v82 = v30.upgrades
  v80(v18, v82)
  v80 = u24
  v82 = v30.unusedStats
  v80(v34, v82)
  v9 = IsNull
  v9 = v9(v2)
  v24 = #v19
  v26 = { localizedTag = "/Lotus/Language/Menu/Loadout_FireModePrimary", behaviorIndex = 0 }
  v24 = table.insert
  v24(v23, v26)
  v26 = v1:IsMeleeWeapon()
  v26 = v1:GetNumUpgrades()
  v28 = #v23
  v27 = v23[v28]
  v28 = {}
  v27.upgrades = v28
  v29 = 0
  v27 = v26 - 1
  v28 = 1
  for v29 = v29, v27, v28 do
    v30 = v1:GetUpgrade(v29)
    v31 = IsNull
    v31 = v31(v30)
    if not v31 then
      v33 = gLotusArtifactUpgradeType
      v31 = v30:IsA(v33)
      v31 = v30:Deckww()
      v32 = pairs
      v32, v33, v34 = v32(v31)
      for v35, v36 in v32, v33, v34 do
        v37 = IsNull
        v37 = v37(v30)
        if not v37 then
          v37 = IsNull
          v37 = v37(v36)
          if not v37 then
            v37 = Resource
            v37 = v37(v36)
            v40 = 1
            v38 = v37:GetNumUpgrades()
            v39 = 1
            for v40 = v40, v38, v39 do
              v43 = #v23
              v42 = v23[v43]
              v42 = v42.upgrades
              v45 = v40 - 1
              v41 = table.insert
              v41(v42, v37:GetUpgrade(v45))
            end
          end
        end
      end
      for v35, v36 in v32, v33, v34 do
      end
    end
  end
  v24 = ipairs
  v24, v25, v26 = v24(v19)
  for v27, v28 in v24, v25, v26 do
    if v27 <= v20 then
      v31 = { localizedTag = nil, behaviorIndex = nil }
      v32 = v28.localizedTag
      v31.localizedTag = v32
      v32 = v28.behaviorIndex
      v31.behaviorIndex = v32
      v29 = table.insert
      v29(v23, v31)
    end
  end
  v9 = IsNull
  v9 = v9(v2)
  if v9 then
    v9 = u0
    v9 = v9.GetMainMenuSuitAvatar
    v2 = v9()
  end
  v9 = IsNull
  v9 = v9(v1)
  v24 = v1:IsEvolvingWeapon()
  v25 = IsNull
  v25 = v25(v1:GetEvolutionReq())
  if not v25 then
    v27 = 9
    v25 = v1:HasFeature(v27)
    if not v25 then
      v26 = _T.ZarimanEvolution_Open
      if v26 ~= true then
        v25 = false
      else
        v25 = true
      end
    end
  end
  v9 = {}
  if v3 == nil then
    v3 = 1
  end
  v12 = gLotusHybridWeaponType
  v10 = v1:IsA(v12)
  if v3 ~= nil then
    v10 = v1:GetChildWeapon(v2)
    v11 = IsNull
    v11 = v11(v10)
    if not v11 then
      v11 = IsWeak
      v11 = v11(v10)
      if v11 then
        v11 = Resource
        v10 = v11(v10)
      end
      v1 = v10
    end
  end
  if v7 then
    v12 = true
    v1:Name__392c190e(v12)
    v10 = _T.mMechaSuitMode
    if v10 then
      v12 = true
      v1:Name__4de9e1f8(v12)
      v12 = 1
      v1:Name__19307ea9(v12)
    else
      v1:Name__19307ea9(v1:Name__974a9860())
    end
  end
  v10 = u0
  v10 = v10.GetDamageTypeTag
  v13 = WeakResource
  v14 = "/Lotus/Weapons/CrewShip/RailjackWeapon"
  v11 = v1:IsA(v13(v14))
  v14 = WeakResource
  v15 = "/Lotus/Weapons/Tenno/Pistols/PrimeBallistica/PrimeBallistica"
  v12 = v1:IsA(v14(v15))
  v15 = WeakResource
  v16 = "/Lotus/Weapons/Syndicates/RedVeil/Pistols/RVBallistica"
  v13 = v1:IsA(v15(v16))
  v14 = not v12
  if v14 then
    v14 = not v13
    if v14 then
      v16 = WeakResource
      v17 = "/Lotus/Weapons/Tenno/Pistols/AutomaticHandCrossbow/AutoCrossBow"
      v14 = v1:IsA(v16(v17))
    end
  end
  v17 = WeakResource
  v18 = "/Lotus/Weapons/Infested/InfestedLich/Pistols/CodaCatabolyst"
  v15 = v1:IsA(v17(v18))
  v18 = WeakResource
  v19 = "/Lotus/Weapons/Tenno/Archwing/Primary/NokkoArchGun/NokkoArchGun"
  v16 = v1:IsA(v18(v19))
  v19 = WeakResource
  v20 = "/Lotus/Weapons/Grineer/Pistols/GrineerCrossbow/GrineerGooGun"
  v17 = v1:IsA(v19(v20))
  v18 = v2:InventoryControl()
  v19 = v1:GetFireModes()
  v20 = v1:Name__ddcba1ac()
  v21 = false
  v22 = 1
  if v22 < v20 then
    v22 = v1:IsAlternateFireDisabled()
    if v22 then
      v20 = 1
    end
  end
  v22 = false
  v23 = #v19
  if v23 == 0 then
    v23 = 1
    if v20 <= v23 then
      v22 = false
    else
      v22 = true
    end
  end
  v23 = IsNull
  v23 = v23(v8)
  if not v23 then
    v25 = "/Lotus/Language/Stats/Loadout_UpgradeWeaponBonus"
    v26 = false
    v23 = v0:GetLocalized(v25, v26)
    v24 = {}
    v28 = u1
    v28 = v28.FormatNumber
    v30 = v8.DmgVal
    v29 = v30 * 100
    v30 = 1
    v31 = false
    v26 = v28(v29, v30, v31)
    v27 = "%"
    v25 = v26 .. v27
    v26 = u2
    v28 = v8.DmgVal
    v26 = v26(v25, v28)
    v24.UpgradeBonus = v26
    v26 = v24.UpgradeBonus
    v27 = "UpgradeBonus"
    v26.Key = v27
    v26 = u0
    v26 = v26.GetDamageTypeTag
    v27 = v8.DmgType
    v26 = v26(v27)
    v27 = v24.UpgradeBonus
    v28 = TitleCase
    v32 = "/Lotus/Language/Game/"
    v31 = v32 .. v26
    v32 = true
    v28 = v28(v0:GetLocalized(v31, v32))
    v27.Label = v28
    v28 = "/Lotus/Language/Game/"
    v30 = "_NoIcon"
    v27 = v28 .. v26 .. v30
    v31 = false
    v28 = v0:GetLocalized(v27, v31)
    if v28 == v27 then
      v31 = "/Lotus/Language/Game/"
      v30 = v31 .. v26
      v31 = true
      v27 = v0:GetLocalized(v30, v31)
    else
      v31 = false
      v27 = v0:GetLocalized(v27, v31)
    end
    v28 = v24.UpgradeBonus
    v28.SearchLabel = v27
    v28 = v24.UpgradeBonus
    v31 = "/Lotus/Language/Stats/Loadout_UpgradeWeaponBonus_TooltipLabel"
    v32 = false
    v29 = v0:GetLocalized(v31, v32)
    v28.HeaderOverride = v29
    v28 = v24.UpgradeBonus
    v31 = "/Lotus/Language/Stats/Loadout_UpgradeWeaponBonus_Desc"
    v32 = false
    v29 = v0:GetLocalized(v31, v32)
    v28.ToolTip = v29
    v28 = { mName = nil, mIsMelee = false, mBehaviorIndex = 0, mStats = nil }
    v29 = string.upper
    v29 = v29(v23)
    v28.mName = v29
    v28.mStats = v24
    v29 = table.insert
    v29(v9, v28)
  end
  v23 = {}
  v24 = IsNull
  v24 = v24(v19)
  if v9 then
    v9 = nil
    do return v9 end
  end
  if not v9 then
  end
  if not v9 then
    v26 = 2
    if v26 < v20 then
      v20 = v20 - 1
    end
  end
  if not v9 then
    v26 = { upgrades = nil, localizedTag = "/Lotus/Language/Mods/ZarimanRifleAltFireUnlockEvo", behaviorIndex = 0 }
    v27 = {}
    v26.upgrades = v27
    v27 = v1:GetEvolutionInfo()
    v28 = {}
    v29 = v1:Name__26aaad0c()
    v29 = Resource
    v33 = v27.mEvolutions
    v32 = v33[1]
    v32 = v32:Name__a013d615()
    v31 = v32[1]
    v31 = v31.mUpgrades
    v30 = v31[1]
    v29 = v29(v30)
    v28 = {}
    v30 = table.insert
    v30(v28, v29)
    v29 = v1:Name__da70379a()
    v30 = pairs
    v30, v31, v32 = v30(v29)
    for v33, v34 in v30, v31, v32 do
      v35 = IsNull
      v35 = v35(v34)
      if not v35 then
        v37 = Resource
        v35 = table.insert
        v35(v28, v37(v34))
      end
    end
    for v33, v34 in v30, v31, v32 do
    end
    v29 = pairs
    v29, v30, v31 = v29(v28)
    for v32, v33 in v29, v30, v31 do
      v34 = IsNull
      v34 = v34(v33)
      if not v34 then
        v36 = 1
        v34 = v33:GetNumUpgrades()
        v35 = 1
        for v36 = v36, v34, v35 do
          v38 = v26.upgrades
          v41 = v36 - 1
          v37 = table.insert
          v37(v38, v33:GetUpgrade(v41))
        end
        v36 = gLotusArtifactUpgradeType
        v34 = v33:IsA(v36)
        v34 = v33:Deckww()
        v35 = pairs
        v35, v36, v37 = v35(v34)
        for v38, v39 in v35, v36, v37 do
          v40 = IsNull
          v40 = v40(v39)
          if not v40 then
            v40 = Resource
            v40 = v40(v39)
            v43 = 1
            v41 = v40:GetNumUpgrades()
            v42 = 1
            for v43 = v43, v41, v42 do
              v45 = v26.upgrades
              v48 = v43 - 1
              v44 = table.insert
              v44(v45, v40:GetUpgrade(v48))
            end
          end
        end
        for v38, v39 in v35, v36, v37 do
        end
      end
    end
    v29 = table.insert
    v29(v23, v26)
  end
  v19 = v23
  v28 = gLotusSentinelAvatarType
  v26 = v2:IsA(v28)
  if not v9 then
    v26 = _T.ScriptedFireModes
    if v26 then
      v28 = _T.ScriptedFireModes.mWeaponType
      v26 = v1:IsA(v28)
      if v26 then
        v26 = ipairs
        v27 = _T.ScriptedFireModes.mStats
        v26, v27, v28 = v26(v27)
        for v29, v30 in v26, v27, v28 do
          v31 = v1:Name__4648fc4e()
          v32 = v30.weaponSlot
          if v31 == v32 then
            v31 = table.insert
            v31(v19, v30)
          end
        end
        v26 = v1:Name__6a099bbc()
        for v29, v30 in v26, v27, v28 do
          v26 = WeakResource
          v27 = "/Lotus/Types/Weapon/GlaiveProjectileFireBehavior"
          v26 = v26(v27)
          v29 = 0
          v27 = v20 - 1
          v28 = 1
          for v29 = v29, v27, v28 do
            v30 = v1:GetFireBehavior(v29)
            v30 = v30:IsA(v26)
            if v30 then break end
            if v30 then
              v21 = true
              v32 = 1
              v30 = #v19
              v31 = 1
              for v32 = v32, v30, v31 do
                v33 = v19[v32]
                v33 = v33.behaviorIndex
                if v33 == v29 then break end
                if v33 == v29 then
                  v33 = v19[v32]
                  v34 = false
                  v33.turboGlaive = v34
                  v33 = { localizedTag = "/Lotus/Language/Menu/Loadout_FireModeTurboThrow", behaviorIndex = nil, turboGlaive = true }
                  v33.behaviorIndex = v29
                  v34 = table.insert
                  v34(v19, v33)
                else
                end
              end
            end
          end
        end
      end
    end
  end
  if v22 then
    v28 = #v19
    v26 = v20 - 1
    v27 = 1
    for v28 = v28, v26, v27 do
      v31 = { behaviorIndex = nil, extraStateBehavior = true }
      v31.behaviorIndex = v28
      v29 = table.insert
      v29(v19, v31)
    end
  end
  v26 = ipairs
  v26, v27, v28 = v26(v19)
  if v20 <= v31 then
    v31 = print
    v33 = "Error: Invalid fire mode behavior index for weapon "
    v34 = v1:GetName()
    v35 = " fireMode index = "
    v36 = tostring
    v36 = v36(v29)
    v32 = v33 .. v34 .. v35 .. v36
    v31(v32)
  end
  v26 = IsNull
  v26 = v26(v1)
  if not v26 then
    v26 = v1:GetBehavior()
    if v26 ~= 0 then
      v28 = 0
      v29 = false
      v1:SetBehavior(v28, v29)
    end
  end
  v26 = _T.PseudoExaltedAdditionalStats
  local p968 = 561
  if p968 == 561 then
    v26 = _T.PseudoExaltedAdditionalStats.GetStats
    if v26 == nil then
    else
      p968 = 562
    end
  end
  if p968 == 562 then
    v26 = {}
    v27 = _T.PseudoExaltedAdditionalStats.GetStats
    v30 = _T.MenuSuitAvatar
    v29 = IsNull
    v29 = v29(v30)
    if v29 then
      p968 = 564
    else
      p968 = 563
    end
  end
  if p968 == 563 then
    v28 = _T.MenuSuitAvatar
    if v28 then
      p968 = 565
    else
      p968 = 564
    end
  end
  if p968 == 564 then
    v28 = gRegion
    v28 = v28:GetLocalPlayerAvatar()
    p968 = 565
  end
  if p968 == 565 then
    v28 = v27(v28)
    v29 = nil
    v30 = nil
    for v31, v32 in v28, v29, v30 do
      v33 = v32.StatTag
      v34 = u2
      v37 = v32.ValueUnit
      v38 = true
      v39 = { COUNT = nil }
      v40 = v32.Value
      v39.COUNT = v40
      v35 = v0:GetLocalized(v37, v38, v39)
      v36 = v32.Value
      v37 = false
      v38 = true
      v34 = v34(v35, v36, v37, v38)
      v26[v33] = v34
    end
    v28 = next
    v28 = v28(v26)
    if v28 then
      v28 = { mName = nil, mBehaviorIndex = 0, mStats = nil, mExtra = true }
      v29 = string.upper
      v32 = _T.PseudoExaltedAdditionalStats.mName
      v33 = false
      v29 = v29(v0:GetLocalized(v32, v33))
      v28.mName = v29
      v28.mStats = v26
      v29 = table.insert
      v29(v9, v28)
    end
  end
  for v31, v32 in v28, v29, v30 do
  end
  if v16 then
    v26 = u12
    v27 = v9[2]
    v27 = v27.mStats
    v29 = 6
    v30 = nil
    v31 = v9[3]
    v31 = v31.mStats
    v26(v27, v11, v29, v30, v31)
    v26 = u12
    v28 = #v9
    v27 = v9[v28]
    v27 = v27.mStats
    v29 = 6
    v30 = nil
    v31 = v9[4]
    v31 = v31.mStats
    v26(v27, v11, v29, v30, v31)
    v26 = table.remove
    v28 = #v9
    v26 = v26(v9, v28)
    v29 = 3
    v27 = table.insert
    v27(v9, v29, v26)
  end
  if v7 then
    v1:Name__77aaecad()
    v28 = false
    v1:Name__392c190e(v28)
  end
  do return v9 end
end

function proto_39()
  local v0, v1, v2
  v0 = 2
  v1 = getfenv
  v1 = v1(v0)
  while true do
    v2 = v1.mMovie
    if v2 then break end
    v0 = v0 + 1
    v2 = getfenv
    v1 = v2(v0)
  end
  do return v1 end
end

function proto_40(v0, v1, v2, v3)
  local v5, v6, v8, v9
  local v4 = u0
  if v4 == nil then
    do return end
  end
  v5 = u0
  v4 = v5[v0]
  if v4 == nil then
    do return end
  end
  if v2 == nil then
    v2 = 100
  end
  v5 = u1
  if not v5 then
    v5 = u2
    v8 = true
    v1 = v5:GetLocalized(v1, v8)
  end
  v5 = TitleCase
  v5 = v5(v1)
  v4.Label = v5
  v4.Key = v0
  v4.Order = v2
  if v3 ~= false then
    if not ((v3 == nil or v3 == "")) then
      v5 = TitleCase
      v6 = u2
      v9 = false
      v5 = v5(v6:GetLocalized(v3, v9))
      v4.SearchLabel = v5
      do return end
    end
    v5 = TitleCase
    v5 = v5(v1)
    v4.SearchLabel = v5
  end
  do return end
end

function proto_41(v0, v1, v2, v3, v4, v5, v6)
  local v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42
  v34 = v33.Label
  v34 = nil
  v10[v32] = v34
  v38 = 1
  v39 = 1
  v36 = string.sub
  v36 = v36(v22, v38, v39)
  v22 = ""
  v36 = v33.ToolTip
  if v36 ~= nil then
    v39 = "/Lotus/Language/Stats/TIP_"
    v40 = v33.ToolTip
    v38 = v39 .. v40
    v39 = true
    v40 = { OPEN_COLOR = nil, CLOSE_COLOR = "</font>", AMOUNT = nil, LABEL = nil }
    v40.OPEN_COLOR = v34
    v40.AMOUNT = v35
    v41 = v33.ToolTipLabel
    v40.LABEL = v41
    v23 = v8:GetLocalized(v38, v39, v40)
    v36 = #v23
    v37 = 0
    if v37 < v36 then
      v38 = 1
      v39 = 1
      v36 = string.sub
      v36 = v36(v23, v38, v39)
      if v36 ~= "/" then
        v36 = #v22
        v37 = 0
        if v37 < v36 then
          v37 = "\r"
          v22 = v22 .. v37 .. v23
        else
          v22 = v23
        end
      end
    end
  end
  v36 = #v22
  v37 = 0
  if v37 < v36 then
    v33.ToolTip = v22
  end
  for v27, v28 in v24, v25, v26 do
    do return v9 end
  end
  v29 = pairs
  v30 = v28.mStats
  v29, v30, v31 = v29(v30)
  for v32, v33 in v29, v30, v31 do
    v35 = "<font color=\"#"
    v38 = string.format
    v39 = "%X"
    v40 = u9
    v40 = v40.GetColor
    v41 = 10
    v42 = true
    v36 = v38(v39, v40(v41, v42))
    v37 = "\">"
    v34 = v35 .. v36 .. v37
    v35 = v33.ToolTipValue
    if v35 ~= nil then
      v37 = "<b>"
      v39 = "</b></font>"
      v35 = v34 .. v37 .. v35 .. v39
    end
    v36 = string.find
    v38 = "EmbedDT_"
    v36 = v36(v32, v38)
    if v36 ~= nil then
      v36 = string.gsub
      v38 = "Embed"
      v39 = ""
      v32 = v36(v32, v38, v39)
    end
    v39 = "/Lotus/Language/Stats/TIP_"
    v38 = v39 .. v32
    v39 = true
    v40 = { OPEN_COLOR = nil, CLOSE_COLOR = "</font>", AMOUNT = nil, LABEL = nil }
    v40.OPEN_COLOR = v34
    v40.AMOUNT = v35
    v41 = v33.ToolTipLabel
    v40.LABEL = v41
    v22 = v8:GetLocalized(v38, v39, v40)
    v36 = #v22
    v22 = u6
    v22 = v22(v0)
    v22 = IsNull
    v22 = v22(v1)
    v33 = WeakResource
    v34 = "/Lotus/Weapons/CrewShip/RailjackOrdnanceWeapon"
    v31 = v22:IsA(v33(v34))
    v32 = "Mag"
    v33 = "/Lotus/Language/Labels/WEAPON_HEAT_CLIP"
    v11(v32, v33)
    v32 = "AmmoReq"
    v33 = "/Lotus/Language/Labels/WEAPON_HEAT_GENERATION"
    v11(v32, v33)
    v32 = "Mag"
    v33 = "/Lotus/Language/Labels/WEAPON_CLIP"
    v34 = 3
    v11(v32, v33, v34)
    v23 = #v21
    v24 = 1
    if v24 < v23 then
      v23 = table.remove
      v25 = #v21
      v23(v21, v25)
    end
    if not ((v17 or v13)) then
      v9 = v21
    end
    v23 = #v21
    v24 = 1
    if v24 < v23 then
      v25 = WeakResource
      v26 = "/Lotus/Powersuits/Alchemist/AlchemistBaseSuit"
      v23 = v0:IsA(v25(v26))
      v24 = v21[2]
      v10 = v24.mStats
      v25 = "Power_Strength"
      v26 = "/Lotus/Language/Labels/AVATAR_ABILITY_STRENGTH"
      v11(v25, v26)
      if v23 then
        v25 = "Status_Duration_Lavos"
        v31 = "<WARNING> "
        v32 = true
        v27 = v8:GetLocalized(v31, v32)
        v30 = "/Lotus/Language/Labels/WEAPON_PROC_TIME"
        v31 = true
        v28 = v8:GetLocalized(v30, v31)
        v26 = v27 .. v28
        v27 = nil
        v28 = "/Lotus/Language/Labels/WEAPON_PROC_TIME"
        v11(v25, v26, v27, v28)
        v25 = "Power_Efficiency_Lavos"
        v31 = "<WARNING> "
        v32 = true
        v27 = v8:GetLocalized(v31, v32)
        v30 = "/Lotus/Language/Labels/AVATAR_ABILITY_EFFICIENCY"
        v31 = true
        v28 = v8:GetLocalized(v30, v31)
        v26 = v27 .. v28
        v27 = nil
        v28 = "/Lotus/Language/Labels/AVATAR_ABILITY_EFFICIENCY"
        v11(v25, v26, v27, v28)
      else
        v25 = "Power_Efficiency"
        v26 = "/Lotus/Language/Labels/AVATAR_ABILITY_EFFICIENCY"
        v11(v25, v26)
      end
      v25 = "Power_Range"
      v26 = "/Lotus/Language/Labels/AVATAR_ABILITY_RANGE"
      v11(v25, v26)
      v25 = "Power_Duration"
      v26 = "/Lotus/Language/Labels/AVATAR_ABILITY_DURATION"
      v11(v25, v26)
    end
    if v14 then
      v22 = v0:GetOwner()
      v22 = v22:MotionControl()
      v23 = IsNull
      v23 = v23(v22)
      if not v23 then
        v25 = gHoverboardMotionControllerType
        v23 = v22:IsA(v25)
        if v23 then
          v24 = { mName = "", mStats = nil, mIsMelee = false }
          v25 = {}
          v24.mStats = v25
          v9 = {v24}
          v23 = v9[1]
          v23 = v23.mStats
          v24 = v22:Name__667aeb05()
          v27 = true
          v25 = v22:Name__3904d0a3(v27)
          v28 = true
          v29 = true
          v26 = v22:Name__3df08c85(v28, v29)
          v27 = v22:GetDoubleJumpHeight()
          v28 = v22:GetJumpChargeTime()
          v29 = u5
          v30 = u3
          v30 = v30.FormatNumber
          v32 = 2
          v33 = false
          v30 = v30(v24, v32, v33)
          v32 = nil
          v33 = true
          v29 = v29(v30, v24, v32, v33)
          v23.JumpHeight = v29
          v29 = u5
          v30 = u3
          v30 = v30.FormatNumber
          v32 = 2
          v33 = false
          v30 = v30(v25, v32, v33)
          v32 = nil
          v33 = true
          v29 = v29(v30, v25, v32, v33)
          v23.VehicleSpeed = v29
          v29 = u5
          v30 = u3
          v30 = v30.FormatNumber
          v32 = 2
          v33 = false
          v30 = v30(v26, v32, v33)
          v32 = nil
          v33 = true
          v29 = v29(v30, v26, v32, v33)
          v23.BoostSpeed = v29
          v29 = u5
          v30 = u3
          v30 = v30.FormatNumber
          v32 = 2
          v33 = false
          v30 = v30(v27, v32, v33)
          v32 = nil
          v33 = true
          v29 = v29(v30, v27, v32, v33)
          v23.DoubleJumpHeight = v29
          v29 = u5
          v30 = u3
          v30 = v30.FormatNumber
          v32 = 2
          v33 = false
          v30 = v30(v28, v32, v33)
          v31 = -v28
          v32 = nil
          v33 = true
          v29 = v29(v30, v31, v32, v33)
          v23.JumpChargeTime = v29
          v29 = v9[1]
          v10 = v29.mStats
          v30 = "JumpHeight"
          v31 = "/Lotus/Language/Labels/VEHICLE_JUMP_HEIGHT"
          v11(v30, v31)
          v30 = "VehicleSpeed"
          v31 = "/Lotus/Language/Labels/VEHICLE_SPEED"
          v11(v30, v31)
          v30 = "BoostSpeed"
          v31 = "/Lotus/Language/Labels/VEHICLE_SPRINT_SPEED"
          v11(v30, v31)
          v30 = "JumpChargeTime"
          v31 = "/Lotus/Language/Labels/VEHICLE_JUMP_CHARGE_TIME"
          v11(v30, v31)
          v30 = "DoubleJumpHeight"
          v31 = "/Lotus/Language/Labels/VEHICLE_DOUBLE_JUMP_HEIGHT"
          v11(v30, v31)
        end
      end
    end
    v10 = v30.mStats
    v31 = true
    v30.mIsWeapon = v31
    v31 = IsNull
    v31 = v31(v22)
    if not v31 then
      v33 = gWeaponExType
      v31 = v22:IsA(v33)
      if v31 then
        v31 = v30.mBehaviorIndex
        v32 = v22:Name__ddcba1ac()
        if v31 < v32 then
          v33 = v30.mBehaviorIndex
          v23 = v22:GetStateBehavior(v33)
          v33 = gGlaiveAlternateGrenadeStateBehaviorType
          v24 = v23:IsA(v33)
        end
      end
    end
    v33 = 0
    v31 = 19
    v32 = 1
    for v33 = v33, v31, v32 do
      v39 = "Embed"
      v38 = v39 .. v34
      v37 = v10[v38]
      if v37 ~= nil then
        v39 = "Embed"
        v38 = v39 .. v34
        v40 = "/Lotus/Language/Game/"
        v39 = v40 .. v34
        v40 = nil
        v11(v38, v39, v40, v35)
      end
      v34 = u4
      v34 = v34.GetDamageTypeTag
      v36 = v15 or v16
      v34 = v34(v33, v36)
      v36 = "/Lotus/Language/Game/"
      v38 = "_NoIcon"
      v35 = v36 .. v34 .. v38
      v39 = "/Lotus/Language/Game/"
      v38 = v39 .. v34
      v39 = true
      v36 = v8:GetLocalized(v38, v39)
      v40 = false
      v37 = v8:GetLocalized(v35, v40)
      if v37 == v35 then
        v40 = false
        v35 = v8:GetLocalized(v36, v40)
      else
        v40 = false
        v35 = v8:GetLocalized(v35, v40)
      end
      v37 = v10[v34]
      if v37 ~= v35 then
        v37 = v10[v34]
        if v37 ~= nil then
          v37 = v10[v34]
          v37.ToolTipLabel = v36
        end
        v40 = nil
        v11(v34, v36, v40, v35)
      end
    end
    v32 = "MaxAmmo"
    v33 = "/Lotus/Language/Labels/WEAPON_AMMO_MAX"
    v11(v32, v33)
    v32 = "AmmoPickupCount"
    v33 = "/Lotus/Language/Labels/WEAPON_AMMO_RETRIEVED"
    v11(v32, v33)
    v32 = "MaxCharges"
    v33 = "/Lotus/Language/Labels/WEAPON_CHARGES_MAX"
    v34 = nil
    v35 = false
    v11(v32, v33, v34, v35)
    v31 = v30.mIsMelee
    if not v31 then
      v32 = "RechargeRate"
      v33 = "/Lotus/Language/Labels/RECHARGE_RATE"
      v11(v32, v33)
      v32 = "RechargeDelay"
      v33 = "/Lotus/Language/Labels/RECHARGE_DELAY"
      v11(v32, v33)
      v32 = "DT_StackDamage"
      v33 = "/Lotus/Language/Labels/WEAPON_STACKDAMAGE"
      v11(v32, v33)
      v32 = "Multishot"
      v33 = "/Lotus/Language/Labels/WEAPON_FIRE_ITERATIONS"
      v34 = 2
      v11(v32, v33, v34)
      v32 = "Noise"
      v33 = "/Lotus/Language/Labels/WEAPON_NOISE"
      v34 = 6
      v11(v32, v33, v34)
      if not v24 then
        v32 = "Reload"
        v33 = "/Lotus/Language/Labels/WEAPON_RELOAD"
        v34 = 3
        v11(v32, v33, v34)
        v32 = "Trigger"
        v33 = "/Lotus/Language/Labels/WEAPON_TRIGGER"
        v34 = 5
        v35 = false
        v11(v32, v33, v34, v35)
      end
    else
      v32 = "Stamina"
      v33 = "/Lotus/Language/Labels/AVATAR_STAMINA"
      v11(v32, v33)
    end
    v32 = "Punchthrough"
    v33 = "/Lotus/Language/Labels/WEAPON_PUNCTURE_DEPTH"
    v34 = 7
    v11(v32, v33, v34)
    v32 = "BeamRange"
    v33 = "/Lotus/Language/Stats/WeaponStats_BeamRange"
    v34 = 8
    v11(v32, v33, v34)
    v32 = "OmegaAtten"
    v33 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenuationTitle"
    v34 = 9
    v35 = "/Lotus/Language/Labels/OMEGA"
    v11(v32, v33, v34, v35)
    v32 = "DamageFallOff"
    v33 = "/Lotus/Language/Game/WEAPON_FALLOFF"
    v34 = nil
    v35 = false
    v11(v32, v33, v34, v35)
    v32 = "BounceChance"
    v33 = "/Lotus/Language/Labels/BOUNCE_CHANCE"
    v11(v32, v33)
    v22 = v0
    if v15 then
      v22 = v0:GetPilotWeapon()
    else
      if v17 then
        v23 = v1:InventoryControl()
        v25 = 5
        v22 = v23:GetWeaponInSlot(v25)
      else
        if v13 then
          v23 = v1:InventoryControl()
          v25 = 1
          v22 = v23:GetWeaponInSlot(v25)
        end
      end
    end
    v23 = u7
    v27 = 1
    v9 = v23(v8, v22, v1, v27, v19, v20, v3, v4, v5)
    if not v15 then
      if v15 then
        v23 = v9[1]
        v24 = string.upper
        v31 = "/Lotus/Language/Railjack/TacCallPilot"
        v32 = false
        v26 = v8:GetLocalized(v31, v32)
        v27 = " - "
        v30 = v22:GetLocalizeTag()
        v30 = v30:c_str()
        v31 = false
        v28 = v8:GetLocalized(v30, v31)
        v25 = v26 .. v27 .. v28
        v24 = v24(v25)
        v23.mName = v24
        v22 = v0:GetTurretWeapon()
        v23 = u7
        v27 = 1
        v23 = v23(v8, v22, v1, v27, v19, v20, v3, v4)
        if v23 ~= nil then
          v24 = v23[1]
          v25 = string.upper
          v32 = "/Lotus/Language/Railjack/RailjackGunnery"
          v33 = false
          v27 = v8:GetLocalized(v32, v33)
          v28 = " - "
          v31 = v22:GetLocalizeTag()
          v31 = v31:c_str()
          v32 = false
          v29 = v8:GetLocalized(v31, v32)
          v26 = v27 .. v28 .. v29
          v25 = v25(v26)
          v24.mName = v25
          v26 = 1
          v24 = #v23
          v25 = 1
          for v26 = v26, v24, v25 do
            v29 = v23[v26]
            v27 = table.insert
            v27(v9, v29)
          end
        end
      else
        if v17 then
          v23 = v9[1]
          v24 = string.upper
          v27 = "/Lotus/Language/Menu/Loadout_FireModeMelee"
          v28 = false
          v24 = v24(v8:GetLocalized(v27, v28))
          v23.mName = v24
        else
          if v13 then
            v23 = v9[1]
            v26 = "/Lotus/Language/Menu/TennoCustomization_Amp"
            v27 = false
            v24 = v8:GetLocalized(v26, v27)
            v23.mName = v24
          end
        end
      end
      if v6 then
        v23 = u7
        v27 = 1
        v23 = v23(v8, v6, v1, v27, v19, v20, v3, v4)
        if v23 ~= nil then
          v26 = 1
          v24 = #v23
          v25 = 1
          for v26 = v26, v24, v25 do
            v29 = v23[v26]
            v27 = table.insert
            v27(v9, v29)
          end
        end
      end
    else
      v9 = {}
    end
    v23 = nil
    v24 = nil
    if v4 then
      v27 = true
      v0:Name__392c190e(v27)
      v25 = _T.mMechaSuitMode
      if v25 then
        v27 = true
        v0:Name__4de9e1f8(v27)
        v27 = 1
        v0:Name__19307ea9(v27)
      else
        v0:Name__19307ea9(v0:Name__974a9860())
      end
    end
    v25 = false
    v26 = IsNull
    v26 = v26(v22)
    if not v26 then
      v26 = v22:GetHolsterCategory()
      v27 = 13
      if v26 ~= v27 then
        v25 = false
      else
        v25 = true
      end
    end
    v26 = ipairs
    v26, v27, v28 = v26(v9)
    v32 = "Total"
    v33 = "/Lotus/Language/Menu/Store_Total"
    v34 = nil
    v35 = false
    v11(v32, v33, v34, v35)
    v31 = v11
    v32 = "Range"
    v33 = u3
    v33 = v33.Ternary
    v34 = v18
    if v34 then
      v34 = v30.mIsHeavyAttack
    end
    v35 = "/Lotus/Language/Labels/AVATAR_RANGE_SEARCH"
    v36 = "/Lotus/Language/Labels/AVATAR_RANGE"
    v33 = v33(v34, v35, v36)
    v34 = u3
    v34 = v34.Ternary
    v35 = v30.mIsMelee
    v36 = 2
    v37 = 8
    v31(v32, v33, v34(v35, v36, v37))
    v32 = "EmbedDamageRadius"
    v33 = "/Lotus/Language/Stats/EmbedDamageRadius"
    v34 = nil
    v35 = false
    v11(v32, v33, v34, v35)
    v32 = "HeavyAttack"
    v33 = "/Lotus/Language/Labels/WEAPON_DAMAGE_AMOUNT"
    v34 = 1
    v11(v32, v33, v34)
    v31 = v30.mIsMelee
    if not v34 then
      v32 = "Accuracy"
      v33 = "/Lotus/Language/Labels/WEAPON_SPREAD"
      v34 = 4
      v11(v32, v33, v34)
      v32 = IsNull
      v32 = v32(v22)
      v31 = not v32
      if v31 then
        v33 = WeakResource
        v34 = "/Lotus/Weapons/Infested/LongGuns/InfSniperRifle/InfSniperRifle"
        v31 = v22:IsA(v33(v34))
      end
      v33 = "EmbedDelay"
      v34 = "/Lotus/Language/Labels/WEAPON_EMBED_DELAY"
      v35 = nil
      v36 = u3
      v36 = v36.Ternary
      v38 = false
      v39 = ""
      v11(v33, v34, v35, v36(v31, v38, v39))
      v33 = "EmbedTime"
      v34 = "/Lotus/Language/Stats/EmbedTime"
      v35 = nil
      v36 = false
      v11(v33, v34, v35, v36)
      v33 = "EmbedFallOff"
      v34 = "/Lotus/Language/Stats/EmbedFalloff"
      v35 = nil
      v36 = false
      v11(v33, v34, v35, v36)
    else
      v31 = IsNull
      v31 = v31(v1)
      if not v31 then
        v31 = v1:InventoryControl()
        v31 = v31:IsSpaceMode()
        if not v31 then
          v32 = "SlamAttack"
          v33 = "/Lotus/Language/Labels/AVATAR_SLAM_ATTACK"
          v34 = 3
          v11(v32, v33, v34)
          v32 = "SlideAttack"
          v33 = "/Lotus/Language/Labels/AVATAR_SLIDE_ATTACK"
          v34 = 4
          v11(v32, v33, v34)
          v32 = "ComboDuration"
          v33 = "/Lotus/Language/Labels/AVATAR_COMBO_DURATION"
          v34 = 5
          v35 = u3
          v35 = v35.Ternary
          v37 = false
          v38 = "/Lotus/Language/Menu/Combo"
          v11(v32, v33, v34, v35(v17, v37, v38))
          v32 = "FollowThrough"
          v33 = "/Lotus/Language/Labels/AVATAR_FOLLOW_THROUGH"
          v34 = 6
          v35 = false
          v11(v32, v33, v34, v35)
          v32 = "BlockingAngle"
          v33 = "/Lotus/Language/Labels/AVATAR_BLOCKING_ANGLE"
          v34 = 7
          v35 = "/Lotus/Language/Menu/Input_FIGHTER_PARRY"
          v11(v32, v33, v34, v35)
          v32 = "SlamAttackRadialDamage"
          v33 = "/Lotus/Language/Labels/AVATAR_SLAM_RADIAL_DAMAGE"
          v11(v32, v33)
          v32 = "SlamAttackRadius"
          v33 = "/Lotus/Language/Labels/AVATAR_SLAM_RADIUS"
          v11(v32, v33)
          v32 = "HeavySlamAttack"
          v33 = "/Lotus/Language/Labels/AVATAR_SLAM_ATTACK"
          v34 = 2
          v11(v32, v33, v34)
          v32 = "ComboEfficiency"
          v33 = "/Lotus/Language/Labels/AVATAR_ABILITY_EFFICIENCY"
          v34 = 3
          v11(v32, v33, v34)
          v32 = "Tennokai_Chance"
          v33 = "/Lotus/Language/Labels/TENNOKAI_CHANCE"
          v34 = 4
          v35 = "/Lotus/Language/ModTips/PerfectHeavyMelee"
          v11(v32, v33, v34, v35)
          v32 = "HeavyAttackWindUp"
          v33 = "/Lotus/Language/Labels/AVATAR_ATTACK_WIND_UP"
          v34 = 5
          v11(v32, v33, v34)
          v32 = "HeavySlamAttackRadialDamage"
          v33 = "/Lotus/Language/Labels/AVATAR_SLAM_RADIAL_DAMAGE"
          v11(v32, v33)
          v32 = "HeavySlamAttackRadius"
          v33 = "/Lotus/Language/Labels/AVATAR_SLAM_RADIUS"
          v11(v32, v33)
          v32 = "ComboCount"
          v33 = "/Lotus/Language/Labels/AVATAR_COMBO_COUNT"
          v11(v32, v33)
        end
      end
    end
    if not ((v25 or v24)) then
      v31 = v30.mIsMelee
      if v31 then
        v32 = "FireRateMelee"
        v33 = "/Lotus/Language/Labels/WEAPON_MELEE_FIRE_RATE"
        v34 = 1
        v11(v32, v33, v34)
      else
        v32 = "FireRate"
        v33 = "/Lotus/Language/Labels/WEAPON_FIRE_RATE"
        v34 = 1
        v11(v32, v33, v34)
      end
    end
    if v20 then
      v32 = "HeadShotMult"
      v33 = "/Lotus/Language/Labels/WEAPON_HEADSHOT_MULTIPLIER"
      v34 = 2
      v11(v32, v33, v34)
    else
      v32 = "CriticalChance"
      v33 = "/Lotus/Language/Labels/WEAPON_CRIT_CHANCE"
      v34 = 1
      v11(v32, v33, v34)
      v32 = "CriticalMultiplier"
      v33 = "/Lotus/Language/Labels/WEAPON_CRIT_MULTIPLIER"
      v34 = 2
      v35 = "/Lotus/Language/Labels/WEAPON_CRIT_DAMAGE"
      v11(v32, v33, v34, v35)
      v32 = "ExplosionRadius"
      v33 = "/Lotus/Language/Labels/WEAPON_EXPLOSION_RADIUS"
      v34 = nil
      v35 = false
      v11(v32, v33, v34, v35)
    end
    if v23 then
      v33 = Name__539c8440
      v31 = v23:IsA(v33)
      if v31 then
        v32 = "ChargeRate"
        v33 = "/Lotus/Language/Labels/WEAPON_CHARGE_RATE"
        v34 = 1
        v35 = "/Lotus/Language/Labels/WEAPON_FIRE_RATE"
        v11(v32, v33, v34, v35)
      end
    end
    v32 = "ProcChance"
    v33 = "/Lotus/Language/Labels/WEAPON_PROC"
    v34 = 3
    v11(v32, v33, v34)
    v32 = "ProcChancePerShot"
    v33 = "/Lotus/Language/Game/StatusPerProjectile"
    v34 = 3
    v35 = "/Lotus/Language/Labels/WEAPON_PROC_CHANCE"
    v11(v32, v33, v34, v35)
    v32 = "EnergyPool"
    v33 = "/Lotus/Language/Labels/ENERGY_POOL"
    v11(v32, v33)
    v32 = "EnergyPerSecond"
    v33 = "/Lotus/Language/Labels/ENERGY_PER_SECOND"
    v11(v32, v33)
    v32 = "EnergyPerShot"
    v33 = "/Lotus/Language/Labels/ENERGY_PER_SHOT"
    v11(v32, v33)
    v23 = gSentinelPowerSuitType
    v21 = v0:IsA(v23)
    v21 = nil
    v23 = v1:InventoryControl()
    v23 = v23:IsSpaceMode()
    v24 = "Mult_SprintSpeed"
    v25 = "/Lotus/Language/Labels/AVATAR_SPRINT_SPEED_SEARCH"
    v26 = 5
    v11(v24, v25, v26)
    v24 = "Mult_SprintSpeed"
    v25 = "/Lotus/Language/Labels/AVATAR_SPRINT_SPEED"
    v26 = 5
    v27 = u3
    v27 = v27.Ternary
    v29 = false
    v30 = ""
    v11(v24, v25, v26, v27(v17, v29, v30))
    v24 = "Shield"
    v25 = "/Lotus/Language/Labels/AVATAR_SHIELD"
    v26 = 2
    v11(v24, v25, v26)
    v21 = IsNull
    v21 = v21(v1)
    if v21 then
      v1 = v0:GetOwner()
    end
    v24 = "Stamina"
    v25 = "/Lotus/Language/Labels/AVATAR_STAMINA"
    v11(v24, v25)
    v24 = "Power"
    v25 = "/Lotus/Language/Labels/AVATAR_ABILITY"
    v26 = 4
    v11(v24, v25, v26)
    v24 = "ParkourBoost"
    v25 = "/Lotus/Language/Menu/WeaponStats_Bullet_Glide"
    v11(v24, v25)
    v25 = gSentinelPowerSuitType
    v23 = v0:IsA(v25)
    if v23 then
      v24 = "Self_Respawn_Time"
      v25 = "/Lotus/Language/Labels/AVATAR_RESPAWN_TIME"
      v26 = nil
      v27 = "/Lotus/Language/Labels/AVATAR_RESPAWN_TIME_SEARCH"
      v11(v24, v25, v26, v27)
    end
    v25 = 0
    v23 = 19
    v24 = 1
    for v25 = v25, v23, v24 do
      v29 = u4
      v29 = v29.GetDamageTypeTag
      v27 = v29(v25)
      v28 = "_RESIST"
      v26 = v27 .. v28
      v27 = v10[v26]
      if v27 ~= nil then
        v30 = "/Lotus/Language/Game/"
        v29 = v30 .. v26
        v30 = true
        v27 = v8:GetLocalized(v29, v30)
        v28 = v10[v26]
        if v28 ~= nil then
          v28 = v10[v26]
          v28.ToolTipLabel = v27
        end
        v29 = "/Lotus/Language/Game/"
        v31 = "_NoIcon"
        v28 = v29 .. v26 .. v31
        v32 = false
        v29 = v8:GetLocalized(v28, v32)
        if v29 == v28 then
          v32 = false
          v28 = v8:GetLocalized(v27, v32)
        else
          v32 = false
          v28 = v8:GetLocalized(v28, v32)
        end
        v32 = nil
        v11(v26, v27, v32, v28)
      end
    end
    v22 = u2
    v21 = v22(v8, v1, v0, v20)
    if v21 == nil then
      v22 = {}
      do return v22 end
    end
    v22 = 1
    if v13 then
      v23 = v21[v22]
      v10 = v23.mStats
      v24 = "UltInitCharge"
      v25 = "/Lotus/Language/Labels/AVATAR_ABILITY_OPERATOR_ULTIMATE_INITIAL_CHARGE"
      v26 = 1
      v11(v24, v25, v26)
      v24 = "UltDuration"
      v25 = "/Lotus/Language/Labels/AVATAR_ABILITY_DURATION"
      v26 = 2
      v11(v24, v25, v26)
      v22 = v22 + 1
    end
    v23 = v21[v22]
    v10 = v23.mStats
    v24 = "Health"
    v25 = "/Lotus/Language/Labels/AVATAR_HEALTH_MAX"
    v26 = 1
    v11(v24, v25, v26)
    v24 = "Armor"
    v25 = "/Lotus/Language/Labels/AVATAR_ARMOUR"
    v26 = 3
    v11(v24, v25, v26)
    v23 = IsNull
    v23 = v23(v1)
    v7 = u0
    v7 = v7()
    v8 = v7.mMovie
    v9 = {}
    v10 = nil
    v11 = IsNull
    v11 = v11(v0)
    if v11 then
      do return v9 end
    end
    v11 = function(c12v0, c12v1, c12v2, c12v3)
      local c12v5, c12v6, c12v8, c12v9
      local c12v4 = v10
      if c12v4 == nil then
        do return end
      end
      c12v5 = v10
      c12v4 = c12v5[c12v0]
      if c12v4 == nil then
        do return end
      end
      if c12v2 == nil then
        c12v2 = 100
      end
      c12v5 = v2
      if not c12v5 then
        c12v5 = v8
        c12v8 = true
        c12v1 = c12v5:GetLocalized(c12v1, c12v8)
      end
      c12v5 = TitleCase
      c12v5 = c12v5(c12v1)
      c12v4.Label = c12v5
      c12v4.Key = c12v0
      c12v4.Order = c12v2
      if c12v3 ~= false then
        if not ((c12v3 == nil or c12v3 == "")) then
          c12v5 = TitleCase
          c12v6 = v8
          c12v9 = false
          c12v5 = c12v5(c12v6:GetLocalized(c12v3, c12v9))
          c12v4.SearchLabel = c12v5
          do return end
        end
        c12v5 = TitleCase
        c12v5 = c12v5(c12v1)
        c12v4.SearchLabel = c12v5
      end
      do return end
    end
    v12 = u1
    v12 = v12(v0)
    v15 = WeakResource
    v16 = "/Lotus/Powersuits/Operator/AdultOperatorSuit"
    v13 = v0:IsA(v15(v16))
    if not v13 then
      v15 = WeakResource
      v16 = "/Lotus/Powersuits/Operator/OperatorSuit"
      v13 = v0:IsA(v15(v16))
    end
    v14 = false
    v17 = gCrewShipType
    v15 = v0:IsA(v17)
    v18 = WeakResource
    v19 = "/Lotus/Weapons/CrewShip/RailjackWeapon"
    v16 = v0:IsA(v18(v19))
    v19 = WeakResource
    v20 = "/Lotus/Powersuits/EntratiMech/BaseMechSuit"
    v17 = v0:IsA(v19(v20))
    v20 = WeakResource
    v21 = "/Lotus/Weapons/Tenno/Melee/LotusGlaiveWeaponBase"
    v18 = v0:IsA(v20(v21))
    v19 = {}
    v21 = _T.ArsenalState
    v22 = 2
    if v21 ~= v22 then
      v20 = false
    else
      v20 = true
    end
    v23 = WeakResource
    v24 = "/Lotus/Types/Vehicles/Hoverboard/HoverboardSuit"
    v21 = v0:IsA(v23(v24))
    if v21 then
      v14 = true
    end
    v23 = gPetPowerSuitType
    v21 = v0:IsA(v23)
    if v22 then
      if v4 then
        v0:Name__77aaecad()
        v28 = false
        v0:Name__392c190e(v28)
      end
    end
    v22 = ipairs
    v22, v23, v24 = v22(v21)
    for v25, v26 in v22, v23, v24 do
      v27 = table.insert
      v27(v9, v25, v26)
    end
    for v25, v26 in v22, v23, v24 do
    end
    if v15 then
      v22 = u8
      v9 = v22(v8, v1, v0)
      v22 = v9[1]
      v10 = v22.mStats
      v23 = "Shield"
      v24 = "/Lotus/Language/Labels/AVATAR_SHIELD"
      v25 = 3
      v11(v23, v24, v25)
      v23 = "Engines"
      v24 = "/Lotus/Language/Railjack/BonusEngine"
      v25 = 5
      v26 = "/Lotus/Language/Labels/AVATAR_MOVEMENT_SPEED"
      v11(v23, v24, v25, v26)
      v23 = "EngineBoost"
      v24 = "/Lotus/Language/Railjack/BonusEngineBoost"
      v25 = 6
      v11(v23, v24, v25)
      v23 = "RailjackHealth"
      v24 = "/Lotus/Language/Labels/RAILJACK_HEALTH_MAX"
      v25 = 1
      v11(v23, v24, v25)
      v23 = "Armor"
      v24 = "/Lotus/Language/Labels/AVATAR_ARMOUR"
      v25 = 2
      v11(v23, v24, v25)
      v23 = "ShieldRechargeRate"
      v24 = "/Lotus/Language/Labels/AVATAR_SHIELD_RECHARGE_RATE"
      v25 = nil
      v11(v23, v24, v25)
      v23 = "ShieldRechargeDelay"
      v24 = "/Lotus/Language/Labels/AVATAR_SHIELD_RECHARGE_DELAY"
      v11(v23, v24)
      v23 = "ElementRedirection"
      v24 = "/Lotus/Language/Labels/AVATAR_SHIELD_REDIRECTION"
      v11(v23, v24)
      v23 = "DT_FIRE"
      v24 = "/Lotus/Language/Labels/FIRE_RESIST"
      v11(v23, v24)
      v23 = "DT_ELECTRICITY"
      v24 = "/Lotus/Language/Labels/ELECTRICITY_RESIST"
      v11(v23, v24)
      v23 = "DT_POISON"
      v24 = "/Lotus/Language/Labels/POISON_RESIST"
      v11(v23, v24)
      v23 = "DT_FREEZE"
      v24 = "/Lotus/Language/Labels/FREEZE_RESIST"
      v11(v23, v24)
      v23 = "CargoCapacity"
      v24 = "/Lotus/Language/Labels/RAILJACK_CARGO_CAPACITY"
      v25 = 4
      v11(v23, v24, v25)
      v22 = v9[2]
      v10 = v22.mStats
      v23 = "Railjack_Power_Strength"
      v24 = "/Lotus/Language/Labels/AVATAR_ABILITY_STRENGTH"
      v25 = 1
      v26 = false
      v11(v23, v24, v25, v26)
      v23 = "Railjack_Power_Duration"
      v24 = "/Lotus/Language/Labels/AVATAR_ABILITY_DURATION"
      v25 = 2
      v26 = false
      v11(v23, v24, v25, v26)
      v23 = "Railjack_Power_Range"
      v24 = "/Lotus/Language/Labels/AVATAR_RANGE"
      v25 = 3
      v26 = false
      v11(v23, v24, v25, v26)
    end
    v24 = WeakResource
    v25 = "/Lotus/Types/Friendly/Pets/BeastPetMeleeWeaponBase"
    v22 = v0:IsA(v24(v25))
    if (not (v17) and not v13) then
      v22 = ipairs
      v22, v23, v24 = v22(v9)
      for v25, v26 in v22, v23, v24 do
        v10 = v26.mStats
        v27 = _T.MenuSuitAvatar
        v28 = IsNull
        v28 = v28(v27)
        if v28 then
          v28 = u4
          v28 = v28.GetMainMenuSuitAvatar
          v27 = v28()
        end
        v28 = IsNull
        v28 = v28(v27)
        if not v28 then
          v28 = IsNull
          v28 = v28(v1)
          if not v28 then
            v28 = v27:InventoryControl()
            v30 = 1
            v28 = v28:GetWeaponInSlot(v30)
            v29 = IsNull
            v29 = v29(v28)
            if not v29 then
              v29 = v28:GetDamageData()
              v30 = v1:InventoryControl()
              v32 = v29.criticalChance
              v33 = 127
              v34 = v0:GetType()
              v30 = v30:GetUpgradeModifiedValue(v32, v33, v34, v0)
              v32 = v10.CriticalChance
              v31 = IsNull
              v31 = v31(v32)
              if not v31 then
                v33 = v10.CriticalChance
                v33 = v33.StatValue
                v34 = 100
                v32 = v33 / v34
                v34 = v29.criticalChance
                v33 = v30 - v34
                v31 = v32 + v33
                v32 = v10.CriticalChance
                v36 = u3
                v36 = v36.FormatNumber
                v38 = 100
                v37 = v31 * v38
                v38 = 1
                v39 = false
                v34 = v36(v37, v38, v39)
                v35 = "%"
                v33 = v34 .. v35
                v32.DisplayValue = v33
                v32 = v10.CriticalChance
                v34 = 100
                v33 = v31 * v34
                v32.StatValue = v33
              end
              v32 = v10.ProcChance
              v31 = IsNull
              v31 = v31(v32)
              if not v31 then
                v32 = v0:GetDamageData()
                v32 = v32.baseProcChance
                v34 = v29.baseProcChance
                v35 = v1:InventoryControl()
                v37 = 0
                v38 = 136
                v35 = v35:GetUpgradeModifiedValue(v37, v38)
                v33 = v34 * v35
                v31 = v32 + v33
                v32 = v10.ProcChance
                v36 = u3
                v36 = v36.FormatNumber
                v38 = 100
                v37 = v31 * v38
                v38 = 1
                v39 = false
                v34 = v36(v37, v38, v39)
                v35 = "%"
                v33 = v34 .. v35
                v32.DisplayValue = v33
                v32 = v10.ProcChance
                v34 = 100
                v33 = v31 * v34
                v32.StatValue = v33
              end
            end
          end
        end
      end
    end
    v22 = IsNull
    v22 = v22(v5)
    if not v22 then
      v23 = "UpgradeBonus"
      v24 = "/Lotus/Language/Kingpins/NemesisView_StatWeaponBonus"
      v11(v23, v24)
    end
    v22 = nil
    v23 = nil
    v24 = ipairs
    v24, v25, v26 = v24(v9)
  end
end

function proto_42(v0, v1)
  local v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34
  v12 = "/Lotus/Language/Menu/NotAvailable"
  v13 = false
  v10 = v3:GetLocalized(v12, v13)
  v11 = u3
  v11 = v11.Ternary
  if v8 <= v7 then
    v12 = false
  else
    v12 = true
  end
  v11 = v11(v12, v1, v0)
  v14 = v6 + 1
  v12 = #v11
  v13 = 1
  for v14 = v14, v12, v13 do
    v18 = table.insert
    v18(v5, v16)
    v15 = v11[v14]
    v15 = v15.mName
    if not ((v1 == nil or v0 == nil)) then
      if v7 < v8 then
        v15 = v10 .. v4 .. v15
      else
        v15 = v15 .. v4 .. v10
      end
    end
    v16 = { mName = nil, mStats = nil }
    v16.mName = v15
    v17 = {}
    v16.mStats = v17
    v17 = v16.mStats
    v18 = pairs
    v19 = v11[v14]
    v19 = v19.mStats
    v18, v19, v20 = v18(v19)
    for v21, v22 in v18, v19, v20 do
      v23 = v22.Key
      if v23 ~= nil then
        v23 = v22.Key
        v24 = { Label = nil, TextOnly = nil, Order = nil }
        v25 = v22.Label
        v24.Label = v25
        v25 = v22.TextOnly
        v24.TextOnly = v25
        v25 = v22.Order
        v24.Order = v25
        v17[v23] = v24
        if v11 == v1 then
          v24 = v22.Key
          v23 = v17[v24]
          v24 = { StatValue = nil, DisplayValue = nil }
          v25 = v22.StatValue
          v24.StatValue = v25
          v25 = v22.DisplayValue
          v24.DisplayValue = v25
          v23.Current = v24
          if v0 == nil then
            v24 = v22.Key
            v23 = v17[v24]
            v25 = v22.Key
            v24 = v17[v25]
            v24 = v24.Current
            v23.Previous = v24
          end
        else
          v24 = v22.Key
          v23 = v17[v24]
          v24 = { StatValue = nil, DisplayValue = nil }
          v25 = v22.StatValue
          v24.StatValue = v25
          v25 = v22.DisplayValue
          v24.DisplayValue = v25
          v23.Previous = v24
          if v1 == nil then
            v24 = v22.Key
            v23 = v17[v24]
            v25 = v22.Key
            v24 = v17[v25]
            v24 = v24.Previous
            v23.Current = v24
          end
        end
      end
    end
  end
  v2 = u0
  v2 = v2()
  v3 = v2.mMovie
  v5 = " "
  v10 = "<MINI_ARROW>"
  v11 = true
  v6 = v3:GetLocalized(v10, v11)
  v7 = " "
  v4 = v5 .. v6 .. v7
  v5 = {}
  v7 = #v0
  v8 = #v1
  v6 = math.min
  v6 = v6(v7, v8)
  v9 = 1
  v7 = v6
  v8 = 1
  for v9 = v9, v7, v8 do
    v10 = v0[v9]
    v11 = v1[v9]
    v12 = ""
    v13 = u1
    v14 = v10.mName
    v13 = v13(v14)
    v13 = u1
    v14 = v11.mName
    v13 = v13(v14)
    v21 = v20.Key
    v22 = v20.Key
    v21 = v14[v22]
    v22 = v20.Key
    v21 = v14[v22]
    v21 = v21.Current
    v23 = v20.Key
    v22 = v14[v23]
    v22 = v22.Previous
    v23 = v21.StatValue
    v24 = v22.StatValue
    v23 = v21.DisplayValue
    v24 = v22.DisplayValue
    v15 = false
    v13 = v11.mName
    v14 = v10.mName
    if v13 ~= v14 then
      v13 = v10.mName
      v15 = v11.mName
      v12 = v13 .. v4 .. v15
    else
      v12 = v11.mName
    end
    v13 = u1
    v14 = v10.mName
    v13 = v13(v14)
    if v13 then
      v12 = v11.mName
    else
      v13 = u1
      v14 = v11.mName
      v13 = v13(v14)
      if v13 then
        v12 = v10.mName
      end
    end
    v24 = v20.Key
    v23 = v14[v24]
    v23 = v23.TextIfOneNil
    if v23 then
      v24 = v20.Key
      v23 = v14[v24]
      v24 = false
      v23.TextOnly = v24
    end
    v22 = v20.Key
    v21 = v14[v22]
    v21 = v21.Hidden
    if v21 then
      v21 = v20.Hidden
      if v21 then
        v21 = v20.Key
        v22 = nil
        v14[v21] = v22
      end
    end
    v21 = v20.Key
    v22 = { Label = nil, TextOnly = nil, TextIfOneNil = nil, SmallerIsBetter = nil, Current = nil, Previous = nil, Order = nil, SearchLabel = nil }
    v23 = v20.Label
    v22.Label = v23
    v23 = v20.TextOnly
    if not v23 then
      v23 = v20.TextIfOneNil
    end
    v22.TextOnly = v23
    v23 = v20.TextIfOneNil
    v22.TextIfOneNil = v23
    v23 = v20.SmallerIsBetter
    v22.SmallerIsBetter = v23
    v23 = u2
    v24 = v20.DisplayValue
    v25 = v20.StatValue
    v26 = nil
    v27 = nil
    v28 = v20.ToolTip
    v29 = nil
    v30 = nil
    v31 = nil
    v32 = v20.SecondaryToolTips
    v33 = v20.HideStat
    v34 = v20.HeaderOverride
    v23 = v23(v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34)
    v22.Current = v23
    v23 = {}
    v22.Previous = v23
    v23 = v20.Order
    v22.Order = v23
    v23 = v20.SearchLabel
    v22.SearchLabel = v23
    v14[v21] = v22
    v15 = false
    if v15 then
      v16 = v11.mName
      v13.mName = v16
    end
    v16 = table.insert
    v16(v5, v13)
    v13 = { mName = nil, mStats = nil }
    v13.mName = v12
    v14 = {}
    v13.mStats = v14
    v14 = v13.mStats
    v15 = true
    v16 = pairs
    v17 = v10.mStats
    v16, v17, v18 = v16(v17)
    for v19, v20 in v16, v17, v18 do
      if v20 ~= nil then
        v21 = v20.Key
        if v21 ~= nil then
          v21 = v20.Key
          v22 = { Label = nil, TextOnly = nil, TextIfOneNil = nil, SmallerIsBetter = nil, Previous = nil, Current = nil, Hidden = nil, Order = nil, SearchLabel = nil }
          v23 = v20.Label
          v22.Label = v23
          v23 = v20.TextOnly
          if not v23 then
            v23 = v20.TextIfOneNil
          end
          v22.TextOnly = v23
          v23 = v20.TextIfOneNil
          v22.TextIfOneNil = v23
          v23 = v20.SmallerIsBetter
          v22.SmallerIsBetter = v23
          v23 = u2
          v24 = v20.DisplayValue
          v25 = v20.StatValue
          v26 = nil
          v27 = nil
          v28 = v20.ToolTip
          v29 = nil
          v30 = nil
          v31 = nil
          v32 = v20.SecondaryToolTips
          v33 = v20.HideStat
          v34 = v20.HeaderOverride
          v23 = v23(v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34)
          v22.Previous = v23
          v23 = {}
          v22.Current = v23
          v23 = v20.Hidden
          v22.Hidden = v23
          v23 = v20.Order
          v22.Order = v23
          v23 = v20.SearchLabel
          v22.SearchLabel = v23
          v14[v21] = v22
        end
      end
    end
    v16 = pairs
    v17 = v11.mStats
    v16, v17, v18 = v16(v17)
    for v19, v20 in v16, v17, v18 do
      v22 = v20.Key
      v21 = v14[v22]
      v22 = u2
      v23 = v20.DisplayValue
      v24 = v20.StatValue
      v25 = nil
      v26 = nil
      v27 = v20.ToolTip
      v28 = nil
      v29 = nil
      v30 = nil
      v31 = v20.SecondaryToolTips
      v32 = v20.HideStat
      v33 = v20.HeaderOverride
      v22 = v22(v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33)
      v21.Current = v22
      v22 = v20.Key
      v21 = v14[v22]
      v23 = v20.Key
      v22 = v14[v23]
      v22 = v22.TextOnly
      if not v22 then
        v22 = v20.TextOnly
      end
      v21.TextOnly = v22
      v22 = v20.Key
      v21 = v14[v22]
      v23 = v20.Key
      v22 = v14[v23]
      v22 = v22.TextIfOneNil
      if not v22 then
        v22 = v20.TextIfOneNil
      end
      v21.TextIfOneNil = v22
      v22 = v20.Key
      v21 = v14[v22]
      v23 = v20.Key
      v22 = v14[v23]
      v22 = v22.Order
      if not v22 then
        v22 = v20.Order
      end
      v21.Order = v22
      v22 = v20.Key
      v21 = v14[v22]
      v21 = v21.Previous
    end
  end
  v7 = #v0
  v8 = #v1
  v10 = v7 - v8
  v9 = math.abs
  v9 = v9(v10)
  do return v5 end
end

function proto_43(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30
  local p193 = 0
  if p193 == 0 then
    v3 = _T.MenuSuitAvatar
    v2 = IsNull
    v2 = v2(v3)
    if v2 then
      p193 = 2
    else
      p193 = 1
    end
  end
  if p193 == 1 then
    v1 = _T.MenuSuitAvatar
    if v1 then
      p193 = 3
    else
      p193 = 2
    end
  end
  if p193 == 2 then
    v1 = gRegion
    v1 = v1:GetLocalPlayerAvatar()
    p193 = 3
  end
  if p193 == 3 then
    v3 = _T.ModPreviewAvatar
    v2 = IsNull
    v2 = v2(v3)
    if v2 then
      p193 = 5
    else
      p193 = 4
    end
  end
  if p193 == 4 then
    v1 = _T.ModPreviewAvatar
    p193 = 18
  end
  if p193 == 5 then
    v3 = _T.RailjackAvatar
    v2 = IsNull
    v2 = v2(v3)
    if v2 then
      p193 = 8
    else
      p193 = 6
    end
  end
  if p193 == 6 then
    v2 = v0.IsRailjackAbility
    if not v2 then
      p193 = 8
    else
      p193 = 7
    end
  end
  if p193 == 7 then
    v1 = _T.RailjackAvatar
    p193 = 18
  end
  if p193 == 8 then
    v2 = IsNull
    v2 = v2(v1)
    if v2 then
      p193 = 11
    else
      p193 = 9
    end
  end
  if p193 == 9 then
    v4 = gLotusVehicleAvatarType
    v2 = v1:IsA(v4)
    if not v2 then
      p193 = 11
    else
      p193 = 10
    end
  end
  if p193 == 10 then
    v1 = v1:GetRider()
    p193 = 18
  end
  if p193 == 11 then
    v2 = _T.mMechaSuitMode
    if not v2 then
      p193 = 14
    else
      p193 = 12
    end
  end
  if p193 == 12 then
    v3 = _T.MechAvatar
    v2 = IsNull
    v2 = v2(v3)
    if v2 then
      p193 = 14
    else
      p193 = 13
    end
  end
  if p193 == 13 then
    v1 = _T.MechAvatar
    p193 = 18
  end
  if p193 == 14 then
    v2 = _T.mSpecialSuitMode
    if v2 then
      p193 = 16
    else
      p193 = 15
    end
  end
  if p193 == 15 then
    v2 = _T.mCachedSpecialSuitMode
    if not v2 then
      p193 = 18
    else
      p193 = 16
    end
  end
  if p193 == 16 then
    v3 = _T.SpecialSuitAvatar
    v2 = IsNull
    v2 = v2(v3)
    if v2 then
      p193 = 18
    else
      p193 = 17
    end
  end
  if p193 == 17 then
    v1 = _T.SpecialSuitAvatar
    p193 = 18
  end
  if p193 == 18 then
    v2 = IsNull
    v2 = v2(v0)
    if v2 then
      p193 = 22
    else
      p193 = 19
    end
  end
  if p193 == 19 then
    v2 = v0.IsAbility
    if not v2 then
      p193 = 22
    else
      p193 = 20
    end
  end
  if p193 == 20 then
    v2 = IsNull
    v2 = v2(v1)
    if v2 then
      p193 = 22
    else
      p193 = 21
    end
  end
  if p193 == 21 then
    v3 = v0.Movie
    v2 = IsNull
    v2 = v2(v3)
    if not v2 then
      p193 = 23
    else
      p193 = 22
    end
  end
  if p193 == 22 then
    v2 = {}
    v3 = {}
    v4 = {}
    v5 = {}
    do return v2, v3, v4, v5 end
  end
  if p193 == 23 then
    v2 = {}
    v3 = {}
    v4 = {}
    v5 = {}
    v6 = nil
    v7 = nil
    v8 = v0.Movie
    v11 = "/Lotus/Language/Menu/Ability_DurationInfinite"
    v12 = true
    v13 = {}
    v9 = v8:GetLocalized(v11, v12, v13)
    v10 = v1:InventoryControl()
    v11 = IsNull
    v11 = v11(v10)
    if v11 then
      p193 = 27
    else
      p193 = 24
    end
  end
  if p193 == 24 then
    v11 = v10:GetActivePowerSuit()
    v12 = IsNull
    v12 = v12(v11)
    if v12 then
      p193 = 27
    else
      p193 = 25
    end
  end
  if p193 == 25 then
    v12 = v0.AbilityIndex
    if v12 == nil then
      p193 = 27
    else
      p193 = 26
    end
  end
  if p193 == 26 then
    v14 = v0.AbilityIndex
    v11:Name__a5cba175(v14)
    p193 = 27
  end
  if p193 == 27 then
    v11 = Symbol
    v12 = "GetAbilityUpgradeLevelInfo"
    v11 = v11(v12)
    v12 = _T
    v13 = { ForceOverride = nil, Level = nil, Ability = nil, Avatar = nil, Modded = false }
    v14 = v0.ForceOverride
    v13.ForceOverride = v14
    v16 = v0.Level
    v15 = v16 or 0
    v14 = v15 + 1
    v13.Level = v14
    v14 = v0.Resource
    v13.Ability = v14
    v13.Avatar = v1
    v12.AbilityLevelQueryParms = v13
    v14 = v0.Script
    v16 = true
    v1:RunScript(v14, v11, v16)
    v6 = _T.AbilityUpgradeLevelInfo
    v12 = IsNull
    v12 = v12(v6)
    if v12 then
      p193 = 40
    else
      p193 = 28
    end
  end
  if p193 == 28 then
    v12 = v6.EnergyCost
    if v12 == nil then
      p193 = 40
    else
      p193 = 29
    end
  end
  if p193 == 29 then
    v12 = v6.EnergyCost
    if v12 ~= false then
      p193 = 31
    else
      p193 = 30
    end
  end
  if p193 == 30 then
    v12 = nil
    v0.Energy = v12
    p193 = 40
  end
  if p193 == 31 then
    v12 = v6.EnergyCost
    v13 = v6.EnergyCostMax
    v15 = v0.Suit
    v14 = IsNull
    v14 = v14(v15)
    if v14 then
      p193 = 37
    else
      p193 = 32
    end
  end
  if p193 == 32 then
    v14 = v6.EnergyIconOverride
    if v14 ~= nil then
      p193 = 37
    else
      p193 = 33
    end
  end
  if p193 == 33 then
    v14 = v0.Suit
    v15 = IsWeak
    v15 = v15(v14)
    if not v15 then
      p193 = 35
    else
      p193 = 34
    end
  end
  if p193 == 34 then
    v15 = Resource
    v14 = v15(v14)
    p193 = 35
  end
  if p193 == 35 then
    v17 = v6.EnergyCost
    v12 = v14:Name__9d3a8775(v17)
    if not v13 then
      p193 = 37
    else
      p193 = 36
    end
  end
  if p193 == 36 then
    v17 = v6.EnergyCostMax
    v13 = v14:Name__9d3a8775(v17)
    p193 = 37
  end
  if p193 == 37 then
    v0.Energy = v12
    v14 = v6.BaseEnergyCost
    if v14 then
      p193 = 39
    else
      p193 = 38
    end
  end
  if p193 == 38 then
    v14 = v6.EnergyCost
    p193 = 39
  end
  if p193 == 39 then
    v0.BaseEnergy = v14
    v0.EnergyValueMax = v13
    v14 = v6.EnergyLabel
    v0.EnergyLabel = v14
    v14 = v6.EnergyFormatting
    v0.EnergyFormatting = v14
    v14 = v6.EnergyIconOverride
    v0.EnergyIconOverride = v14
    p193 = 40
  end
  if p193 == 40 then
    v13 = v0.Resource
    v12 = IsNull
    v12 = v12(v13)
    if v12 then
      p193 = 43
    else
      p193 = 41
    end
  end
  if p193 == 41 then
    v12 = v0.Resource
    v14 = true
    v12 = v12:GetCooldownDuration(v14)
    v13 = 1
    if v12 <= v13 then
      p193 = 43
    else
      p193 = 42
    end
  end
  if p193 == 42 then
    v15 = "<TIMER>"
    v16 = true
    v13 = v8:GetLocalized(v15, v16)
    v14 = TitleCase
    v17 = "/Lotus/Language/Labels/GAMEPLAY_POWER_COOLDOWN"
    v18 = false
    v14 = v14(v8:GetLocalized(v17, v18))
    v17 = 1
    v15 = table.insert
    v15(v2, v17, v14)
    v17 = 1
    v20 = " "
    v21 = u0
    v21 = v21.FormatNumber
    v23 = 1
    v24 = false
    v21 = v21(v12, v23, v24)
    v18 = v13 .. v20 .. v21
    v15 = table.insert
    v15(v3, v17, v18)
    v17 = 1
    v15 = table.insert
    v15(v4, v17, v12)
    v17 = 1
    v18 = 0
    v15 = table.insert
    v15(v5, v17, v18)
    p193 = 43
  end
  if p193 == 43 then
    v12 = v0.Energy
    if v12 == nil then
      p193 = 62
    else
      p193 = 44
    end
  end
  if p193 == 44 then
    v12 = v0.Energy
    if v12 == 0 then
      p193 = 62
    else
      p193 = 45
    end
  end
  if p193 == 45 then
    v12 = TitleCase
    v16 = v0.EnergyLabel
    v15 = v16 or "/Lotus/Language/Labels/Drain_Ability"
    v16 = false
    v12 = v12(v8:GetLocalized(v15, v16))
    v14 = v0.Energy
    v13 = tonumber
    v13 = v13(v14)
    v15 = v0.BaseEnergy
    v14 = tonumber
    v14 = v14(v15)
    if v14 ~= nil then
      p193 = 47
    else
      p193 = 46
    end
  end
  if p193 == 46 then
    v14 = v13
    p193 = 47
  end
  if p193 == 47 then
    v15 = v14 - v13
    v17 = v0.EnergyIconOverride
    v16 = v17 or "<ENERGY>"
    v20 = true
    v16 = v8:GetLocalized(v16, v20)
    v17 = u0
    v17 = v17.Ternary
    v19 = 3.4028234663852886e+38
    if v13 == v19 then
      p193 = 49
    else
      p193 = 48
    end
  end
  if p193 == 48 then
    v18 = false
    p193 = 50
  end
  if p193 == 49 then
    v18 = true
    p193 = 50
  end
  if p193 == 50 then
    v20 = u0
    v20 = v20.FormatNumber
    v22 = 2
    v23 = false
    v13 = v17(v18, v9, v20(v13, v22, v23))
    v17 = v0.EnergyValueMax
    if v17 == nil then
      p193 = 55
    else
      p193 = 51
    end
  end
  if p193 == 51 then
    v17 = v13
    v18 = " - "
    v19 = u0
    v19 = v19.Ternary
    v21 = v0.EnergyValueMax
    v22 = 3.4028234663852886e+38
    if v21 == v22 then
      p193 = 53
    else
      p193 = 52
    end
  end
  if p193 == 52 then
    v20 = false
    p193 = 54
  end
  if p193 == 53 then
    v20 = true
    p193 = 54
  end
  if p193 == 54 then
    v22 = u0
    v22 = v22.FormatNumber
    v23 = v0.EnergyValueMax
    v24 = 2
    v25 = false
    v19 = v19(v20, v9, v22(v23, v24, v25))
    v13 = v17 .. v18 .. v19
    p193 = 55
  end
  if p193 == 55 then
    v17 = v0.ModdedStats
    if (not (v17) and v15 ~= 0) then
      p193 = 58
    else
      p193 = 57
    end
  end
  if p193 == 57 then
    v18 = " "
    v13 = v16 .. v18 .. v13
    p193 = 59
  end
  if p193 == 58 then
    v18 = " "
    v19 = u0
    v19 = v19.FormatNumber
    v21 = 2
    v22 = false
    v19 = v19(v14, v21, v22)
    v14 = v16 .. v18 .. v19
    p193 = 59
  end
  if p193 == 59 then
    v17 = v0.EnergyFormatting
    if v17 == nil then
      p193 = 61
    else
      p193 = 60
    end
  end
  if p193 == 60 then
    v19 = v0.EnergyFormatting
    v20 = true
    v21 = { COUNT = nil }
    v21.COUNT = v13
    v13 = v8:GetLocalized(v19, v20, v21)
    p193 = 61
  end
  if p193 == 61 then
    v19 = 1
    v17 = table.insert
    v17(v2, v19, v12)
    v19 = 1
    v17 = table.insert
    v17(v3, v19, v13)
    v19 = 1
    v17 = table.insert
    v17(v4, v19, v14)
    v19 = 1
    v17 = table.insert
    v17(v5, v19, v15)
    p193 = 62
  end
  if p193 == 62 then
    v12 = _T
    v13 = { ForceOverride = nil, Level = nil, Ability = nil, Avatar = nil, Modded = nil }
    v14 = v0.ForceOverride
    v13.ForceOverride = v14
    v16 = v0.Level
    v15 = v16 or 0
    v14 = v15 + 1
    v13.Level = v14
    v14 = v0.Resource
    v13.Ability = v14
    v13.Avatar = v1
    v15 = v0.BaseOnly
    v14 = not v15
    v13.Modded = v14
    v12.AbilityLevelQueryParms = v13
    v14 = v0.Script
    v16 = true
    v1:RunScript(v14, v11, v16)
    v7 = _T.AbilityUpgradeLevelInfo
    v12 = true
    if v7 == nil then
      p193 = 66
    else
      p193 = 63
    end
  end
  if p193 == 63 then
    v13 = v7.Modded
    if v13 == nil then
      p193 = 65
    else
      p193 = 64
    end
  end
  if p193 == 64 then
    v12 = false
    p193 = 66
  end
  if p193 == 65 then
    v12 = true
    p193 = 66
  end
  if p193 == 66 then
    v0.mDarken = v12
    v14 = 1
    v12 = #v7
    v13 = 1
    if (v13 > 0 and v14 > v12) or (v13 < 0 and v14 < v12) then
      p193 = 116
    else
      p193 = 67
    end
  end
  if p193 == 67 then
    v15 = v7[v14]
    v16 = IsNull
    v16 = v16(v15)
    if v16 then
      p193 = 115
    else
      p193 = 68
    end
  end
  if p193 == 68 then
    v18 = v15.Label
    v19 = true
    v20 = {}
    v16 = v8:GetLocalized(v18, v19, v20)
    v18 = v15.Value
    v17 = v18 or ""
    v19 = v6[v14]
    v19 = v19.Value
    v18 = v19 or ""
    v20 = v15.ValueMax
    v19 = v20 or ""
    v21 = v6[v14]
    v21 = v21.ValueMax
    v20 = v21 or ""
    v21 = true
    if v17 ~= v18 then
      p193 = 72
    else
      p193 = 69
    end
  end
  if p193 == 69 then
    if v19 ~= v20 then
      p193 = 71
    else
      p193 = 70
    end
  end
  if p193 == 70 then
    v21 = false
    p193 = 72
  end
  if p193 == 71 then
    v21 = true
    p193 = 72
  end
  if p193 == 72 then
    if not v21 then
      p193 = 88
    else
      p193 = 73
    end
  end
  if p193 == 73 then
    v23 = v15.Value
    v22 = v23 or 0
    v24 = v6[v14]
    v24 = v24.Value
    v23 = v24 or 0
    v25 = v15.ValueMax
    v24 = v25 or 0
    v26 = v6[v14]
    v26 = v26.ValueMax
    v25 = v26 or 0
    v26 = u0
    v26 = v26.Ternary
    if v22 == v23 then
      p193 = 75
    else
      p193 = 74
    end
  end
  if p193 == 74 then
    v27 = false
    p193 = 76
  end
  if p193 == 75 then
    v27 = true
    p193 = 76
  end
  if p193 == 76 then
    if v24 < v25 then
      p193 = 78
    else
      p193 = 77
    end
  end
  if p193 == 77 then
    v28 = false
    p193 = 79
  end
  if p193 == 78 then
    v28 = true
    p193 = 79
  end
  if p193 == 79 then
    if v22 < v23 then
      p193 = 81
    else
      p193 = 80
    end
  end
  if p193 == 80 then
    v29 = false
    p193 = 82
  end
  if p193 == 81 then
    v29 = true
    p193 = 82
  end
  if p193 == 82 then
    v26 = v26(v27, v28, v29)
    v27 = v15.SmallerIsBetter
    if (not (not v27) and v26) then
      p193 = 86
    else
      p193 = 84
    end
  end
  if p193 == 84 then
    v27 = v15.SmallerIsBetter
    if (v27 or v26) then
      p193 = 87
    else
      p193 = 86
    end
  end
  if p193 == 86 then
    v21 = 1
    p193 = 89
  end
  if p193 == 87 then
    v21 = -1
    p193 = 89
  end
  if p193 == 88 then
    v21 = 0
    p193 = 89
  end
  if p193 == 89 then
    v22 = v15.Title
    if not v22 then
      p193 = 91
    else
      p193 = 90
    end
  end
  if p193 == 90 then
    v22 = "<b>"
    v25 = string.upper
    v23 = v25(v16)
    v24 = "</b>"
    v16 = v22 .. v23 .. v24
    p193 = 114
  end
  if p193 == 91 then
    v22 = TitleCase
    v16 = v22(v16)
    v22 = u0
    v22 = v22.Ternary
    v24 = 3.4028234663852886e+38
    if v17 == v24 then
      p193 = 93
    else
      p193 = 92
    end
  end
  if p193 == 92 then
    v23 = false
    p193 = 94
  end
  if p193 == 93 then
    v23 = true
    p193 = 94
  end
  if p193 == 94 then
    v25 = u0
    v25 = v25.FormatNumber
    v27 = 2
    v28 = false
    v17 = v22(v23, v9, v25(v17, v27, v28))
    v22 = u0
    v22 = v22.Ternary
    v24 = 3.4028234663852886e+38
    if v18 == v24 then
      p193 = 96
    else
      p193 = 95
    end
  end
  if p193 == 95 then
    v23 = false
    p193 = 97
  end
  if p193 == 96 then
    v23 = true
    p193 = 97
  end
  if p193 == 97 then
    v25 = u0
    v25 = v25.FormatNumber
    v27 = 2
    v28 = false
    v18 = v22(v23, v9, v25(v18, v27, v28))
    v22 = v15.ValueMax
    if v22 == nil then
      p193 = 102
    else
      p193 = 98
    end
  end
  if p193 == 98 then
    v22 = v17
    v23 = " - "
    v24 = u0
    v24 = v24.Ternary
    v26 = v15.ValueMax
    v27 = 3.4028234663852886e+38
    if v26 == v27 then
      p193 = 100
    else
      p193 = 99
    end
  end
  if p193 == 99 then
    v25 = false
    p193 = 101
  end
  if p193 == 100 then
    v25 = true
    p193 = 101
  end
  if p193 == 101 then
    v27 = u0
    v27 = v27.FormatNumber
    v28 = v15.ValueMax
    v29 = 2
    v30 = false
    v24 = v24(v25, v9, v27(v28, v29, v30))
    v17 = v22 .. v23 .. v24
    p193 = 102
  end
  if p193 == 102 then
    v22 = v6[v14]
    v22 = v22.ValueMax
    if v22 == nil then
      p193 = 107
    else
      p193 = 103
    end
  end
  if p193 == 103 then
    v22 = v18
    v23 = " - "
    v24 = u0
    v24 = v24.Ternary
    v26 = v6[v14]
    v26 = v26.ValueMax
    v27 = 3.4028234663852886e+38
    if v26 == v27 then
      p193 = 105
    else
      p193 = 104
    end
  end
  if p193 == 104 then
    v25 = false
    p193 = 106
  end
  if p193 == 105 then
    v25 = true
    p193 = 106
  end
  if p193 == 106 then
    v27 = u0
    v27 = v27.FormatNumber
    v28 = v6[v14]
    v28 = v28.ValueMax
    v29 = 2
    v30 = false
    v24 = v24(v25, v9, v27(v28, v29, v30))
    v18 = v22 .. v23 .. v24
    p193 = 107
  end
  if p193 == 107 then
    v22 = v15.ValueUnit
    if v22 == nil then
      p193 = 109
    else
      p193 = 108
    end
  end
  if p193 == 108 then
    v24 = v15.ValueUnit
    v25 = true
    v26 = { COUNT = nil }
    v26.COUNT = v17
    v17 = v8:GetLocalized(v24, v25, v26)
    p193 = 109
  end
  if p193 == 109 then
    v22 = v15.ValueIcon
    if v22 == nil then
      p193 = 114
    else
      p193 = 110
    end
  end
  if p193 == 110 then
    v22 = v0.ModdedStats
    if (not (v22) and v21 ~= 0) then
      p193 = 113
    else
      p193 = 112
    end
  end
  if p193 == 112 then
    v27 = v15.ValueIcon
    v28 = true
    v22 = v8:GetLocalized(v27, v28)
    v23 = " "
    v17 = v22 .. v23 .. v17
    p193 = 114
  end
  if p193 == 113 then
    v27 = v15.ValueIcon
    v28 = true
    v22 = v8:GetLocalized(v27, v28)
    v23 = " "
    v18 = v22 .. v23 .. v18
    p193 = 114
  end
  if p193 == 114 then
    v22 = table.insert
    v22(v2, v16)
    v22 = table.insert
    v22(v3, v17)
    v22 = table.insert
    v22(v4, v18)
    v22 = table.insert
    v22(v5, v21)
    p193 = 115
  end
  if p193 == 115 then
    p193 = 116
  end
  if p193 == 116 then
    v12 = _T
    v13 = nil
    v12.AbilityLevelQueryParms = v13
    v12 = _T
    v13 = nil
    v12.AbilityUpgradeLevelInfo = v13
    do return v2, v3, v4, v5 end
  end
end

function proto_44(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
  local v11, v12, v13, v14, v15, v16, v17, v18, v19, v22, v24
  v1 = v1 or "-"
  v3 = v3 or "-"
  v4 = v4 or 0
  v11 = u0
  if v11 then
    if not ((v1 ~= "-" or v3 ~= "-")) then
      v1 = ""
      v3 = ""
      v11 = #v0
      if v11 ~= 0 then
        v11 = "<font ><b>"
        v14 = string.upper
        v12 = v14(v0)
        v13 = "</b></font>"
        v0 = v11 .. v12 .. v13
      end
    else
      v11 = TitleCase
      v0 = v11(v0)
    end
    v12 = u1
    v12 = v12.Labels
    v11 = table.insert
    v11(v12, v0)
    v12 = u1
    v12 = v12.Values
    v11 = table.insert
    v11(v12, v1)
    v12 = u1
    v12 = v12.CompareValues
    v11 = table.insert
    v11(v12, v3)
    v12 = u1
    v12 = v12.Comparison
    v11 = table.insert
    v11(v12, v4)
    v12 = u1
    v12 = v12.ToolTips
    v13 = v5 or ""
    v11 = table.insert
    v11(v12, v13)
    v12 = u1
    v12 = v12.SecondaryToolTips
    v13 = v6 or ""
    v11 = table.insert
    v11(v12, v13)
    v12 = u1
    v12 = v12.StatIds
    v13 = v7 or ""
    v11 = table.insert
    v11(v12, v13)
    v12 = u1
    v12 = v12.SecondaryComparison
    v13 = v8 or -1
    v11 = table.insert
    v11(v12, v13)
    v12 = u1
    v12 = v12.HeaderOverrides
    v13 = v9 or ""
    v11 = table.insert
    v11(v12, v13)
    v12 = u1
    v12 = v12.SearchLabels
    v13 = v10 or ""
    v11 = table.insert
    v11(v12, v13)
    do return end
  end
  v11 = u2
  v11 = v11.Ternary
  v13 = u3
  v12 = IsNull
  v12 = v12(v13)
  v13 = "#999999"
  v14 = u3
  v11 = v11(v12, v13, v14)
  v12 = u2
  v12 = v12.Ternary
  v14 = u4
  v13 = IsNull
  v13 = v13(v14)
  v14 = "#FFFFFF"
  v15 = u4
  v12 = v12(v13, v14, v15)
  v13 = u2
  v13 = v13.Ternary
  v14 = u5
  v15 = "<b>"
  v16 = ""
  v13 = v13(v14, v15, v16)
  v14 = u2
  v14 = v14.Ternary
  v15 = u5
  v16 = "</b>"
  v17 = ""
  v14 = v14(v15, v16, v17)
  v17 = "%:"
  v18 = ""
  v0 = v0:gsub(v17, v18)
  v16 = u1
  v17 = "<font color=\""
  v19 = "\">"
  v15 = v16 .. v17 .. v11 .. v19 .. v0
  u1 = v15
  if v2 then
    v16 = u1
    v17 = ": "
    v15 = v16 .. v17
    u1 = v15
  end
  v16 = u1
  v17 = "</font>"
  v15 = v16 .. v17
  u1 = v15
  v16 = u1
  v17 = "<font color=\""
  v19 = "\">"
  v22 = "\r\n"
  v24 = "</font>"
  v15 = v16 .. v17 .. v12 .. v19 .. v13 .. v1 .. v22 .. v14 .. v24
  u1 = v15
  do return end
end

function proto_45(v0, v1)
  local v2, v3, v4
  v2 = v0.Order
  if v2 ~= nil then
    v2 = v1.Order
    if v2 ~= nil then
      v2 = v0.Order
      v3 = v1.Order
      if v2 ~= v3 then
        v3 = v0.Order
        v4 = v1.Order
        if v4 <= v3 then
          v2 = false
        else
          v2 = true
        end
        do return v2 end
      end
    end
  end
  v3 = v0.Label
  v2 = IsNull
  v2 = v2(v3)
  if v2 then
    v2 = false
    do return v2 end
  end
  v3 = v1.Label
  v2 = IsNull
  v2 = v2(v3)
  if v2 then
    v2 = true
    do return v2 end
  end
  v3 = v0.Label
  v4 = v1.Label
  if v4 <= v3 then
    v2 = false
  else
    v2 = true
  end
  do return v2 end
end

function proto_46(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
  local v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v24, v25, v26, v27, v28, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v49, v52
  v25 = {}
  v26 = pairs
  v27 = v24.mStats
  v26, v27, v28 = v26(v27)
  for v29, v30 in v26, v27, v28 do
    v32 = 0
    v30.Order = v32
    v32 = string.find
    v34 = "_RESIST$"
    v32 = v32(v29, v34)
    v32 = 2
    v30.Order = v32
    v32 = string.find
    v34 = "DT_"
    v32 = v32(v29, v34)
    v32 = 10
    v30.Order = v32
    v32 = v30.Previous
    v32 = v30.Previous
    v32 = v32.StatValue
    v32 = v30.Current
    v32 = v30.Current
    v32 = v32.StatValue
    v32 = 99
    v30.Order = v32
    v32 = true
    v30.Removed = v32
    v32 = v30.Current
    v32 = v30.Current
    v32 = v32.StatValue
    v32 = v30.Previous
    v32 = v30.Previous
    v32 = v32.StatValue
    v32 = true
    v30.New = v32
    v32 = v30.Label
    if v32 then
      v30.StatId = v29
      v32 = table.insert
      v32(v25, v30)
    end
    for v23, v24 in v20, v21, v22 do
      v21 = ""
      do return v13, v21 end
    end
    v25 = v24.mExtra
    if not v25 then
      v19 = v19 + 1
    end
    v32 = type
    v32 = v32(v30)
    if v32 ~= "table" then
      v31 = false
    else
      v31 = true
    end
    v26 = table.sort
    v26(v25, v18)
    if v17 then
      v27 = ""
      v15(v27)
    end
    v26 = u4
    v27 = v24.mName
    v26 = v26(v27)
    if not v26 then
      v26 = #v16
      v27 = 1
      if v27 < v26 then
        if v2 then
          v27 = v24.mName
          v15(v27)
        else
          v28 = "<font color=\""
          v29 = "#4dd9e5"
          v30 = "\"><b>"
          v31 = v24.mName
          v32 = "</b></font>"
          v27 = v28 .. v29 .. v30 .. v31 .. v32
          v15(v27)
        end
      end
    end
    v26 = ipairs
    v26, v27, v28 = v26(v25)
    for v29, v30 in v26, v27, v28 do
      v31 = v30.DisplayValue
      v32 = v30.StatValue
      v33 = nil
      v34 = nil
      v35 = nil
      v36 = nil
      v37 = nil
      v38 = nil
      v39 = false
      v40 = false
      if v31 == nil then
        if v32 ~= nil then
          v41 = u1
          v41 = v41.FormatNumber
          v43 = 0
          v44 = false
          v31 = v41(v32, v43, v44)
        else
          if v14 then
            v41 = 0
            v42 = v30.Previous
            if v42 ~= nil then
              v42 = v30.Previous
              v31 = v42.DisplayValue
              v42 = v30.Previous
              v42 = v42.StatValue
              if v42 ~= nil then
                v42 = v30.Previous
                v41 = v42.StatValue
                if v31 == nil then
                  v42 = u1
                  v42 = v42.FormatNumber
                  v44 = 0
                  v45 = false
                  v31 = v42(v41, v44, v45)
                end
              end
              v42 = v30.Previous
              v34 = v42.ToolTip
              v42 = v30.Previous
              v35 = v42.SecondaryToolTips
              v42 = v30.Previous
              v37 = v42.HeaderOverride
              v42 = v30.Previous
              v42 = v42.HideStat
              v39 = not v42
            end
            v42 = 0
            v43 = v30.Current
            if v43 ~= nil then
              v43 = v30.Current
              v32 = v43.DisplayValue
              v43 = v30.Current
              v43 = v43.StatValue
              if v43 ~= nil then
                v43 = v30.Current
                v42 = v43.StatValue
                if v32 == nil then
                  v43 = u1
                  v43 = v43.FormatNumber
                  v45 = 0
                  v46 = false
                  v32 = v43(v42, v45, v46)
                end
              end
              v43 = v30.Current
              v34 = v43.ToolTip
              v43 = u5
              v45 = v30.Current
              v45 = v45.SecondaryToolTips
              v36, v38 = v43(v12, v45, v35)
              v43 = v30.Current
              v40 = v43.HideStat
              v43 = v30.Current
              v37 = v43.HeaderOverride
            end
            v43 = v30.TextOnly
            if not v43 then
              if v42 < v41 then
                v33 = -1
              else
                if v41 < v42 then
                  v33 = 1
                end
              end
              v43 = v30.Removed
              if v43 then
                v33 = -2
              else
                v43 = v30.SmallerIsBetter
                if not ((not v43 or v33 == nil)) then
                  v33 = v33 * -1
                else
                  v43 = v30.New
                  if v43 then
                    v33 = -3
                  end
                end
              end
            end
          end
        end
      end
      if not ((not (not v40) and not v39)) then
        v42 = v30.Label
        v44 = true
        v49 = v30.StatId
        v52 = v30.SearchLabel
        v15(v42, v31, v44, v32, v33, v34, v36, v49, v38, v37, v52)
      end
    end
    v17 = true
    local p130 = 0
    if p130 == 0 then
      v11 = u0
      v11 = v11()
      v12 = v11.mMovie
      if not v2 then
        p130 = 2
      else
        p130 = 1
      end
    end
    if p130 == 1 then
      v13 = { Labels = nil, Values = nil, CompareValues = nil, Comparison = nil, ToolTips = nil, SecondaryToolTips = nil, StatIds = nil, SecondaryComparison = nil, HeaderOverrides = nil, SearchLabels = nil }
      v14 = {}
      v13.Labels = v14
      v14 = {}
      v13.Values = v14
      v14 = {}
      v13.CompareValues = v14
      v14 = {}
      v13.Comparison = v14
      v14 = {}
      v13.ToolTips = v14
      v14 = {}
      v13.SecondaryToolTips = v14
      v14 = {}
      v13.StatIds = v14
      v14 = {}
      v13.SecondaryComparison = v14
      v14 = {}
      v13.HeaderOverrides = v14
      v14 = {}
      v13.SearchLabels = v14
      if v13 then
        p130 = 3
      else
        p130 = 2
      end
    end
    if p130 == 2 then
      v13 = ""
      p130 = 3
    end
    if p130 == 3 then
      v15 = IsNull
      v15 = v15(v9)
      v14 = not v15
      v15 = IsNull
      v15 = v15(v0)
      if not v15 then
        p130 = 5
      else
        p130 = 4
      end
    end
    if p130 == 4 then
      v16 = ""
      do return v13, v16 end
    end
    if p130 == 5 then
      v15 = function(c13v0, c13v1, c13v2, c13v3, c13v4, c13v5, c13v6, c13v7, c13v8, c13v9, c13v10)
        local c13v11, c13v12, c13v13, c13v14, c13v15, c13v16, c13v17, c13v18, c13v19, c13v22, c13v24
        c13v1 = c13v1 or "-"
        c13v3 = c13v3 or "-"
        c13v4 = c13v4 or 0
        c13v11 = v2
        if c13v11 then
          if not ((c13v1 ~= "-" or c13v3 ~= "-")) then
            c13v1 = ""
            c13v3 = ""
            c13v11 = #c13v0
            if c13v11 ~= 0 then
              c13v11 = "<font ><b>"
              c13v14 = string.upper
              c13v12 = c13v14(c13v0)
              c13v13 = "</b></font>"
              c13v0 = c13v11 .. c13v12 .. c13v13
            end
          else
            c13v11 = TitleCase
            c13v0 = c13v11(c13v0)
          end
          c13v12 = v13
          c13v12 = c13v12.Labels
          c13v11 = table.insert
          c13v11(c13v12, c13v0)
          c13v12 = v13
          c13v12 = c13v12.Values
          c13v11 = table.insert
          c13v11(c13v12, c13v1)
          c13v12 = v13
          c13v12 = c13v12.CompareValues
          c13v11 = table.insert
          c13v11(c13v12, c13v3)
          c13v12 = v13
          c13v12 = c13v12.Comparison
          c13v11 = table.insert
          c13v11(c13v12, c13v4)
          c13v12 = v13
          c13v12 = c13v12.ToolTips
          c13v13 = c13v5 or ""
          c13v11 = table.insert
          c13v11(c13v12, c13v13)
          c13v12 = v13
          c13v12 = c13v12.SecondaryToolTips
          c13v13 = c13v6 or ""
          c13v11 = table.insert
          c13v11(c13v12, c13v13)
          c13v12 = v13
          c13v12 = c13v12.StatIds
          c13v13 = c13v7 or ""
          c13v11 = table.insert
          c13v11(c13v12, c13v13)
          c13v12 = v13
          c13v12 = c13v12.SecondaryComparison
          c13v13 = c13v8 or -1
          c13v11 = table.insert
          c13v11(c13v12, c13v13)
          c13v12 = v13
          c13v12 = c13v12.HeaderOverrides
          c13v13 = c13v9 or ""
          c13v11 = table.insert
          c13v11(c13v12, c13v13)
          c13v12 = v13
          c13v12 = c13v12.SearchLabels
          c13v13 = c13v10 or ""
          c13v11 = table.insert
          c13v11(c13v12, c13v13)
          do return end
        end
        c13v11 = u1
        c13v11 = c13v11.Ternary
        c13v13 = v4
        c13v12 = IsNull
        c13v12 = c13v12(c13v13)
        c13v13 = "#999999"
        c13v14 = v4
        c13v11 = c13v11(c13v12, c13v13, c13v14)
        c13v12 = u1
        c13v12 = c13v12.Ternary
        c13v14 = v5
        c13v13 = IsNull
        c13v13 = c13v13(c13v14)
        c13v14 = "#FFFFFF"
        c13v15 = v5
        c13v12 = c13v12(c13v13, c13v14, c13v15)
        c13v13 = u1
        c13v13 = c13v13.Ternary
        c13v14 = v6
        c13v15 = "<b>"
        c13v16 = ""
        c13v13 = c13v13(c13v14, c13v15, c13v16)
        c13v14 = u1
        c13v14 = c13v14.Ternary
        c13v15 = v6
        c13v16 = "</b>"
        c13v17 = ""
        c13v14 = c13v14(c13v15, c13v16, c13v17)
        c13v17 = "%:"
        c13v18 = ""
        c13v0 = c13v0:gsub(c13v17, c13v18)
        c13v16 = v13
        c13v17 = "<font color=\""
        c13v19 = "\">"
        c13v15 = c13v16 .. c13v17 .. c13v11 .. c13v19 .. c13v0
        v13 = c13v15
        if c13v2 then
          c13v16 = v13
          c13v17 = ": "
          c13v15 = c13v16 .. c13v17
          v13 = c13v15
        end
        c13v16 = v13
        c13v17 = "</font>"
        c13v15 = c13v16 .. c13v17
        v13 = c13v15
        c13v16 = v13
        c13v17 = "<font color=\""
        c13v19 = "\">"
        c13v22 = "\r\n"
        c13v24 = "</font>"
        c13v15 = c13v16 .. c13v17 .. c13v12 .. c13v19 .. c13v13 .. c13v1 .. c13v22 .. c13v14 .. c13v24
        v13 = c13v15
        do return end
      end
      v16 = v0
      v17 = type
      v17 = v17(v0)
      if v17 == "table" then
        p130 = 7
      else
        p130 = 6
      end
    end
    if p130 == 6 then
      v17 = u2
      v20 = false
      v21 = false
      v16 = v17(v0, v3, v20, v21, v8, v1)
      p130 = 7
    end
    if p130 == 7 then
      if not v14 then
        p130 = 12
      else
        p130 = 8
      end
    end
    if p130 == 8 then
      v17 = nil
      v18 = type
      v18 = v18(v9)
      if v18 ~= "table" then
        p130 = 10
      else
        p130 = 9
      end
    end
    if p130 == 9 then
      v17 = v9
      p130 = 11
    end
    if p130 == 10 then
      v18 = u2
      v21 = false
      v22 = false
      v17 = v18(v9, v3, v21, v22, v8, v1)
      p130 = 11
    end
    if p130 == 11 then
      v18 = u3
      v16 = v18(v16, v17)
      p130 = 12
    end
    if p130 == 12 then
      if not v10 then
        p130 = 14
      else
        p130 = 13
      end
    end
    if p130 == 13 then
      v20 = "/Lotus/Language/Stats/TIP_BaseStats"
      v21 = false
      v15(v12:GetLocalized(v20, v21))
      p130 = 14
    end
    if p130 == 14 then
      v17 = false
      v18 = function(c14v0, c14v1)
        local c14v2, c14v3, c14v4
        c14v2 = c14v0.Order
        if c14v2 ~= nil then
          c14v2 = c14v1.Order
          if c14v2 ~= nil then
            c14v2 = c14v0.Order
            c14v3 = c14v1.Order
            if c14v2 ~= c14v3 then
              c14v3 = c14v0.Order
              c14v4 = c14v1.Order
              if c14v4 <= c14v3 then
                c14v2 = false
              else
                c14v2 = true
              end
              do return c14v2 end
            end
          end
        end
        c14v3 = c14v0.Label
        c14v2 = IsNull
        c14v2 = c14v2(c14v3)
        if c14v2 then
          c14v2 = false
          do return c14v2 end
        end
        c14v3 = c14v1.Label
        c14v2 = IsNull
        c14v2 = c14v2(c14v3)
        if c14v2 then
          c14v2 = true
          do return c14v2 end
        end
        c14v3 = c14v0.Label
        c14v4 = c14v1.Label
        if c14v4 <= c14v3 then
          c14v2 = false
        else
          c14v2 = true
        end
        do return c14v2 end
      end
      v19 = 0
      v20 = ipairs
      v20, v21, v22 = v20(v16)
    end
  end
end

function proto_47(v0, v1, v2)
  local v3
  v3 = u0
  v3 = v3(v0, v1, v2)
  do return v3 end
end

function proto_48(v0, v1, v2, v3, v4)
  local v5
  v5 = u0
  v5 = v5(v0, v1, v2, v3, v4)
  do return v5 end
end

function proto_49(v0, v1, v2, v3, v4, v5, v6)
  local v7, v11
  v7 = u0
  v11 = false
  v7 = v7(v0, v1, v2, v11, v4, v5, v6)
  do return v7 end
end

function proto_50(v0, v1)
  local v2
  v2 = u0
  v2 = v2(v0, v1)
  do return v2 end
end

function proto_51(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
  local v11, v12
  v11 = u0
  v11, v12 = v11(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
  do return v11, v12 end
end

function proto_52(v0)
  local v1, v2, v3, v4
  v1 = u0
  v1, v2, v3, v4 = v1(v0)
  do return v1, v2, v3, v4 end
end

function proto_53(...)
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42
  v0 = module
  v1 = ...
  v2 = package.seeall
  v0(v1, v2)
  v0 = require
  v1 = "EE.Interface.Utilities"
  v0 = v0(v1)
  v1 = require
  v2 = "Lotus.Interface.LotusUtilities"
  v1 = v1(v2)
  v2 = require
  v3 = "Lotus.Interface.UIStyleUtilities"
  v2 = v2(v3)
  v3 = require
  v4 = "Lotus.Scripts.Libs.WeaponStatsLib"
  v3 = v3(v4)
  v4 = require
  v5 = "Lotus.Scripts.Libs.AbilitiesLib"
  v4 = v4(v5)
  v5 = require
  v6 = "Lotus.Scripts.Libs.SiriusOrionUtilsLib"
  v5 = v5(v6)
  v6 = Resource
  v7 = "/Lotus/PVP/PVPPowerSuitStatsModifier"
  v6 = v6(v7)
  v7 = Resource
  v8 = "/Lotus/Weapons/Ammo/RifleAmmoItem"
  v7 = v7(v8)
  v8 = Resource
  v9 = "/Lotus/Weapons/Ammo/PistolAmmoItem"
  v8 = v8(v9)
  v9 = nil
  v10 = nil
  v11 = nil
  v12 = function(c15v0)
    local c15v1
    c15v1 = true
    if c15v0 ~= nil then
      if c15v0 ~= "" then
        c15v1 = false
      else
        c15v1 = true
      end
    end
    do return c15v1 end
  end
  v13 = function(c26v0, c26v1)
    local c26v2, c26v3, c26v4, c26v5, c26v6, c26v7, c26v8, c26v9
    c26v2 = require
    c26v3 = "EE.Interface.Components.List"
    c26v2 = c26v2(c26v3)
    c26v3 = c26v2.CreateList
    c26v3 = c26v3(c26v0, c26v1)
    c26v5 = "StatCompare("
    c26v7 = ")::"
    c26v4 = c26v5 .. c26v1 .. c26v7
    c26v3.mPrefix = c26v4
    c26v4 = {}
    c26v3.mStats = c26v4
    c26v4 = true
    c26v3.mSort = c26v4
    c26v4 = false
    c26v3.mWrapAroundNavigation = c26v4
    c26v4 = 0.15
    c26v3.mElementTransitionTime = c26v4
    c26v4 = "#4dd9e5"
    c26v3.GroupTitleColor = c26v4
    c26v4 = _G
    c26v4 = c26v4.UIColor_White
    c26v3.LabelColor = c26v4
    c26v4 = _G
    c26v4 = c26v4.UIColor_White
    c26v3.PreviousStatColor = c26v4
    c26v4 = _G
    c26v4 = c26v4.UIColor_Green
    c26v3.StatIncreasedColor = c26v4
    c26v4 = _G
    c26v4 = c26v4.UIColor_Red
    c26v3.StatDecreasedColor = c26v4
    c26v4 = true
    c26v3.mGrowsUpwards = c26v4
    c26v4 = 23
    c26v3.mForcedVerticalSeparation = c26v4
    c26v4 = c26v3.mMovie
    c26v7 = 15
    c26v4 = c26v4:GetNumberVariable(c26v1, c26v7)
    c26v3.mOriginalElementHeight = c26v4
    c26v6 = "StatSelected"
    c26v7 = "StatFocused"
    c26v8 = "StatUnfocused"
    c26v9 = "StatPressed"
    c26v3:SetCallbacks(c26v6, c26v7, c26v8, c26v9)
    c26v4 = function(c16v0, c16v1)
      do return end
    end
    c26v3.Print = c26v4
    c26v4 = function(c17v0)
      local c17v1, c17v2, c17v3
      c17v1 = string.format
      c17v2 = "%x"
      c17v3 = c26v3
      c17v3 = c17v3.PreviousStatColor
      c17v1 = c17v1(c17v2, c17v3)
      do return c17v1 end
    end
    c26v3.GetPreviousStatColor = c26v4
    c26v4 = function(c18v0, c18v1, c18v2)
      local c18v3, c18v4, c18v5, c18v6, c18v8, c18v9, c18v10, c18v11
      c18v3 = c26v3
      c18v3 = c18v3.GetPreviousStatColor
      c18v3 = c18v3()
      c18v4 = true
      if c18v1 ~= nil then
        c18v4 = true
        if c18v2 ~= nil then
          c18v4 = c18v0.TextOnly
        end
      end
      if c18v1 == nil then
        if c18v1 <= c18v2 then
          c18v5 = false
        else
          c18v5 = true
        end
        c18v6 = c18v0.SmallerIsBetter
        if c18v6 then
          if c18v2 <= c18v1 then
            c18v5 = false
          else
            c18v5 = true
          end
        end
        c18v6 = v0
        c18v6 = c18v6.Ternary
        c18v8 = string.format
        c18v9 = "%x"
        c18v10 = c26v3
        c18v10 = c18v10.StatDecreasedColor
        c18v8 = c18v8(c18v9, c18v10)
        c18v9 = string.format
        c18v10 = "%x"
        c18v11 = c26v3
        c18v11 = c18v11.StatIncreasedColor
        c18v3 = c18v6(c18v5, c18v8, c18v9(c18v10, c18v11))
      end
      do return c18v3 end
    end
    c26v3.GetCurrentStatColor = c26v4
    c26v4 = function(c19v0)
      local c19v1, c19v2, c19v3, c19v4, c19v5, c19v6, c19v7, c19v8, c19v9, c19v10, c19v11, c19v12, c19v13, c19v14, c19v15, c19v16, c19v17, c19v18, c19v19, c19v20, c19v21, c19v22, c19v23, c19v24, c19v26, c19v27, c19v28
      local p118 = 0
      if p118 == 0 then
        c19v1 = c19v0.Label
        if c19v1 == nil then
          p118 = 4
        else
          p118 = 1
        end
      end
      if p118 == 1 then
        c19v2 = c26v3
        c19v2 = c19v2.TitleCase
        if not c19v2 then
          p118 = 4
        else
          p118 = 2
        end
      end
      if p118 == 2 then
        c19v2 = c19v0.Title
        if c19v2 then
          p118 = 4
        else
          p118 = 3
        end
      end
      if p118 == 3 then
        c19v2 = TitleCase
        c19v1 = c19v2(c19v1)
        p118 = 4
      end
      if p118 == 4 then
        c19v2 = c26v3
        c19v2 = c19v2.mMovie
        c19v5 = c19v0.mClipName
        c19v6 = ".Label"
        c19v4 = c19v5 .. c19v6
        c19v5 = 36
        c19v2:SetStringVariable(c19v4, c19v5, c19v1)
        c19v2 = c26v3
        c19v2 = c19v2.mMovie
        c19v5 = c19v0.mClipName
        c19v6 = ".Label"
        c19v4 = c19v5 .. c19v6
        c19v5 = _G
        c19v5 = c19v5.UIMaterial_PlainText
        c19v2:OverrideMaterial(c19v4, c19v5)
        c19v2 = c26v3
        c19v2 = c19v2.mMovie
        c19v4 = c19v0.mClipName
        c19v5 = "Label"
        c19v6 = 44
        c19v7 = c26v3
        c19v7 = c19v7.LabelColor
        c19v2:Name__52c1b74e(c19v4, c19v5, c19v6, c19v7)
        c19v2 = c26v3
        c19v2 = c19v2.mMovie
        c19v5 = c19v0.mClipName
        c19v6 = ".NewValue"
        c19v4 = c19v5 .. c19v6
        c19v5 = _G
        c19v5 = c19v5.UIMaterial_PlainText
        c19v2:OverrideMaterial(c19v4, c19v5)
        c19v2 = v0
        c19v2 = c19v2.Ternary
        c19v4 = c26v3
        c19v4 = c19v4.LabelAlpha
        if c19v4 ~= nil then
          p118 = 6
        else
          p118 = 5
        end
      end
      if p118 == 5 then
        c19v3 = false
        p118 = 7
      end
      if p118 == 6 then
        c19v3 = true
        p118 = 7
      end
      if p118 == 7 then
        c19v4 = c26v3
        c19v4 = c19v4.LabelAlpha
        c19v5 = 100
        c19v2 = c19v2(c19v3, c19v4, c19v5)
        c19v3 = 100
        c19v4 = c26v3
        c19v4 = c19v4.StatAltAlphaOffset
        if c19v4 == nil then
          p118 = 10
        else
          p118 = 8
        end
      end
      if p118 == 8 then
        c19v5 = c19v0.mIndex
        c19v4 = c19v5 % 2
        if c19v4 ~= 0 then
          p118 = 10
        else
          p118 = 9
        end
      end
      if p118 == 9 then
        c19v4 = c26v3
        c19v4 = c19v4.StatAltAlphaOffset
        c19v2 = c19v2 + c19v4
        c19v4 = c26v3
        c19v4 = c19v4.StatAltAlphaOffset
        c19v3 = c19v3 + c19v4
        p118 = 10
      end
      if p118 == 10 then
        c19v4 = c26v3
        c19v4 = c19v4.mMovie
        c19v6 = c19v0.mClipName
        c19v7 = "Label"
        c19v8 = 12
        c19v4:Name__52c1b74e(c19v6, c19v7, c19v8, c19v2)
        c19v4 = c26v3
        c19v4 = c19v4.mMovie
        c19v6 = c19v0.mClipName
        c19v7 = "NewValue"
        c19v8 = 12
        c19v4:Name__52c1b74e(c19v6, c19v7, c19v8, c19v3)
        c19v5 = c26v3
        c19v5 = c19v5.StatBgColor
        if c19v5 ~= nil then
          p118 = 12
        else
          p118 = 11
        end
      end
      if p118 == 11 then
        c19v4 = false
        p118 = 13
      end
      if p118 == 12 then
        c19v4 = true
        p118 = 13
      end
      if p118 == 13 then
        c19v5 = c26v3
        c19v5 = c19v5.mMovie
        c19v7 = c19v0.mClipName
        c19v8 = "Bg"
        c19v9 = 13
        c19v5:Makeposshield(c19v7, c19v8, c19v9, c19v4)
        if not c19v4 then
          p118 = 18
        else
          p118 = 14
        end
      end
      if p118 == 14 then
        c19v5 = c26v3
        c19v5 = c19v5.mMovie
        c19v7 = c19v0.mClipName
        c19v8 = "Bg"
        c19v9 = 11
        c19v10 = c26v3
        c19v10 = c19v10.StatBgColor
        c19v5:Name__52c1b74e(c19v7, c19v8, c19v9, c19v10)
        c19v5 = c26v3
        c19v5 = c19v5.mMovie
        c19v7 = c19v0.mClipName
        c19v8 = "Bg"
        c19v9 = 12
        c19v10 = v0
        c19v10 = c19v10.Ternary
        c19v13 = c19v0.mIndex
        c19v12 = c19v13 % 2
        if c19v12 ~= 0 then
          p118 = 16
        else
          p118 = 15
        end
      end
      if p118 == 15 then
        c19v11 = false
        p118 = 17
      end
      if p118 == 16 then
        c19v11 = true
        p118 = 17
      end
      if p118 == 17 then
        c19v12 = c26v3
        c19v12 = c19v12.StatBgAlpha
        c19v13 = 0
        c19v5:Name__52c1b74e(c19v7, c19v8, c19v9, c19v10(c19v11, c19v12, c19v13))
        p118 = 18
      end
      if p118 == 18 then
        c19v5 = c26v3
        c19v5 = c19v5.mMovie
        c19v8 = c19v0.mClipName
        c19v9 = ".Label"
        c19v7 = c19v8 .. c19v9
        c19v8 = 52
        c19v5 = c19v5:Name__9d78ed52(c19v7, c19v8)
        if not c19v5 then
          p118 = 20
        else
          p118 = 19
        end
      end
      if p118 == 19 then
        c19v6 = c26v3
        c19v6 = c19v6.mMovie
        c19v9 = c19v0.mClipName
        c19v10 = ".Label"
        c19v8 = c19v9 .. c19v10
        c19v9 = 41
        c19v6 = c19v6:GetNumberVariable(c19v8, c19v9)
        c19v7 = c26v3
        c19v7 = c19v7.mMovie
        c19v9 = c19v0.mClipName
        c19v10 = "NewValue"
        c19v11 = 1
        c19v13 = c19v6 / 2
        c19v12 = c19v13 - 9
        c19v7:Name__52c1b74e(c19v9, c19v10, c19v11, c19v12)
        c19v7 = c26v3
        c19v7 = c19v7.mMovie
        c19v9 = c19v0.mClipName
        c19v10 = "Line"
        c19v11 = 1
        c19v12 = c19v6 + 7
        c19v7:Name__52c1b74e(c19v9, c19v10, c19v11, c19v12)
        p118 = 20
      end
      if p118 == 20 then
        c19v6 = c26v3
        c19v6 = c19v6.mMovie
        c19v8 = c19v0.mClipName
        c19v9 = "Line"
        c19v10 = 15
        c19v11 = 2.5
        c19v6:Name__52c1b74e(c19v8, c19v9, c19v10, c19v11)
        c19v6 = c26v3
        c19v6 = c19v6.mMovie
        c19v9 = c19v0.mClipName
        c19v10 = ".Line"
        c19v8 = c19v9 .. c19v10
        c19v9 = _G
        c19v9 = c19v9.UIMaterial_SmoothEdgeNoDepthTest
        c19v6:OverrideMaterial(c19v8, c19v9)
        c19v6 = v0
        c19v6 = c19v6.Ternary
        c19v8 = c19v0.ValueUnit
        c19v7 = IsNull
        c19v7 = c19v7(c19v8)
        c19v8 = ""
        c19v9 = c19v0.ValueUnit
        c19v6 = c19v6(c19v7, c19v8, c19v9)
        c19v7 = ""
        c19v8 = c19v0.Previous
        if c19v8 == nil then
          p118 = 23
        else
          p118 = 21
        end
      end
      if p118 == 21 then
        c19v8 = c19v0.Previous
        c19v8 = c19v8.StatValue
        if c19v8 ~= nil then
          p118 = 26
        else
          p118 = 22
        end
      end
      if p118 == 22 then
        c19v8 = c19v0.Previous
        c19v8 = c19v8.DisplayValue
        if c19v8 ~= nil then
          p118 = 26
        else
          p118 = 23
        end
      end
      if p118 == 23 then
        c19v8 = c19v0.TextOnly
        if not c19v8 then
          p118 = 25
        else
          p118 = 24
        end
      end
      if p118 == 24 then
        c19v8 = { StatValue = 0, DisplayValue = nil }
        c19v9 = c26v3
        c19v9 = c19v9.mMovie
        c19v11 = "/Lotus/Language/Menu/Arsenal_Zero"
        c19v12 = false
        c19v9 = c19v9:GetLocalized(c19v11, c19v12)
        c19v8.DisplayValue = c19v9
        c19v0.Previous = c19v8
        p118 = 28
      end
      if p118 == 25 then
        c19v8 = { StatValue = 0, DisplayValue = "0" }
        c19v0.Previous = c19v8
        p118 = 28
      end
      if p118 == 26 then
        c19v8 = c19v0.Previous
        c19v8 = c19v8.DisplayValue
        if c19v8 ~= nil then
          p118 = 28
        else
          p118 = 27
        end
      end
      if p118 == 27 then
        c19v8 = c19v0.Previous
        c19v9 = v0
        c19v9 = c19v9.FormatNumber
        c19v10 = c19v0.Previous
        c19v10 = c19v10.StatValue
        c19v11 = 0
        c19v12 = false
        c19v9 = c19v9(c19v10, c19v11, c19v12)
        c19v8.DisplayValue = c19v9
        p118 = 28
      end
      if p118 == 28 then
        c19v8 = c19v0.Current
        if c19v8 == nil then
          p118 = 31
        else
          p118 = 29
        end
      end
      if p118 == 29 then
        c19v8 = c19v0.Current
        c19v8 = c19v8.StatValue
        if c19v8 ~= nil then
          p118 = 34
        else
          p118 = 30
        end
      end
      if p118 == 30 then
        c19v8 = c19v0.Current
        c19v8 = c19v8.DisplayValue
        if c19v8 ~= nil then
          p118 = 34
        else
          p118 = 31
        end
      end
      if p118 == 31 then
        c19v8 = c19v0.TextOnly
        if not c19v8 then
          p118 = 33
        else
          p118 = 32
        end
      end
      if p118 == 32 then
        c19v8 = { StatValue = 0, DisplayValue = nil }
        c19v9 = c26v3
        c19v9 = c19v9.mMovie
        c19v11 = "/Lotus/Language/Menu/Arsenal_Zero"
        c19v12 = false
        c19v9 = c19v9:GetLocalized(c19v11, c19v12)
        c19v8.DisplayValue = c19v9
        c19v0.Current = c19v8
        p118 = 36
      end
      if p118 == 33 then
        c19v8 = { StatValue = 0, DisplayValue = "0" }
        c19v0.Current = c19v8
        p118 = 36
      end
      if p118 == 34 then
        c19v8 = c19v0.Current
        c19v8 = c19v8.DisplayValue
        if c19v8 ~= nil then
          p118 = 36
        else
          p118 = 35
        end
      end
      if p118 == 35 then
        c19v8 = c19v0.Current
        c19v9 = v0
        c19v9 = c19v9.FormatNumber
        c19v10 = c19v0.Current
        c19v10 = c19v10.StatValue
        c19v11 = 0
        c19v12 = false
        c19v9 = c19v9(c19v10, c19v11, c19v12)
        c19v8.DisplayValue = c19v9
        p118 = 36
      end
      if p118 == 36 then
        c19v8 = c26v3
        c19v8 = c19v8.GetPreviousStatColor
        c19v8 = c19v8(c19v0)
        c19v9 = ""
        if c19v6 == "" then
          p118 = 40
        else
          p118 = 37
        end
      end
      if p118 == 37 then
        c19v10 = c26v3
        c19v10 = c19v10.mMovie
        c19v13 = true
        c19v14 = { COUNT = nil }
        c19v15 = c19v0.Previous
        c19v15 = c19v15.DisplayValue
        c19v14.COUNT = c19v15
        c19v7 = c19v10:GetLocalized(c19v6, c19v13, c19v14)
        c19v10 = c26v3
        c19v10 = c19v10.TitleCase
        if not c19v10 then
          p118 = 39
        else
          p118 = 38
        end
      end
      if p118 == 38 then
        c19v10 = TitleCase
        c19v7 = c19v10(c19v7)
        p118 = 39
      end
      if p118 == 39 then
        c19v10 = "<p><font color=\"#"
        c19v12 = "\">"
        c19v14 = "</font>"
        c19v9 = c19v10 .. c19v8 .. c19v12 .. c19v7 .. c19v14
        p118 = 41
      end
      if p118 == 40 then
        c19v10 = "<p><font color=\"#"
        c19v12 = "\">"
        c19v15 = v0
        c19v15 = c19v15.Ternary
        c19v16 = c26v3
        c19v16 = c19v16.TitleCase
        c19v17 = TitleCase
        c19v18 = c19v0.Previous
        c19v18 = c19v18.DisplayValue
        c19v17 = c19v17(c19v18)
        c19v18 = c19v0.Previous
        c19v18 = c19v18.DisplayValue
        c19v13 = c19v15(c19v16, c19v17, c19v18)
        c19v14 = "</font>"
        c19v9 = c19v10 .. c19v8 .. c19v12 .. c19v13 .. c19v14
        p118 = 41
      end
      if p118 == 41 then
        c19v10 = v0
        c19v10 = c19v10.Ternary
        c19v11 = c19v0.TextOnly
        c19v12 = c19v0.Previous
        c19v12 = c19v12.DisplayValue
        c19v13 = c19v0.Previous
        c19v13 = c19v13.StatValue
        c19v10 = c19v10(c19v11, c19v12, c19v13)
        c19v11 = v0
        c19v11 = c19v11.Ternary
        c19v12 = c19v0.TextOnly
        c19v13 = c19v0.Current
        c19v13 = c19v13.DisplayValue
        c19v14 = c19v0.Current
        c19v14 = c19v14.StatValue
        c19v11 = c19v11(c19v12, c19v13, c19v14)
        if c19v10 == c19v11 then
          p118 = 47
        else
          p118 = 42
        end
      end
      if p118 == 42 then
        c19v12 = c26v3
        c19v12 = c19v12.mMovie
        c19v14 = "<MINI_ARROW>"
        c19v15 = true
        c19v12 = c19v12:GetLocalized(c19v14, c19v15)
        c19v13 = c26v3
        c19v13 = c19v13.GetCurrentStatColor
        c19v13 = c19v13(c19v0, c19v10, c19v11)
        if c19v6 == "" then
          p118 = 46
        else
          p118 = 43
        end
      end
      if p118 == 43 then
        c19v14 = c26v3
        c19v14 = c19v14.mMovie
        c19v17 = true
        c19v18 = { COUNT = nil }
        c19v19 = c19v0.Current
        c19v19 = c19v19.DisplayValue
        c19v18.COUNT = c19v19
        c19v7 = c19v14:GetLocalized(c19v6, c19v17, c19v18)
        c19v14 = c26v3
        c19v14 = c19v14.TitleCase
        if not c19v14 then
          p118 = 45
        else
          p118 = 44
        end
      end
      if p118 == 44 then
        c19v14 = TitleCase
        c19v7 = c19v14(c19v7)
        p118 = 45
      end
      if p118 == 45 then
        c19v15 = "<font color=\"#"
        c19v17 = "\">"
        c19v20 = "</font>"
        c19v9 = c19v9 .. c19v15 .. c19v13 .. c19v17 .. c19v12 .. c19v7 .. c19v20
        p118 = 47
      end
      if p118 == 46 then
        c19v15 = "<font color=\"#"
        c19v17 = "\">"
        c19v21 = v0
        c19v21 = c19v21.Ternary
        c19v22 = c26v3
        c19v22 = c19v22.TitleCase
        c19v23 = TitleCase
        c19v24 = c19v0.Current
        c19v24 = c19v24.DisplayValue
        c19v23 = c19v23(c19v24)
        c19v24 = c19v0.Current
        c19v24 = c19v24.DisplayValue
        c19v19 = c19v21(c19v22, c19v23, c19v24)
        c19v20 = "</font>"
        c19v9 = c19v9 .. c19v15 .. c19v13 .. c19v17 .. c19v12 .. c19v19 .. c19v20
        p118 = 47
      end
      if p118 == 47 then
        c19v13 = "</p>"
        c19v9 = c19v9 .. c19v13
        c19v12 = c26v3
        c19v12 = c19v12.mMovie
        c19v15 = c19v0.mClipName
        c19v16 = ".NewValue"
        c19v14 = c19v15 .. c19v16
        c19v15 = 36
        c19v12:SetStringVariable(c19v14, c19v15, c19v9)
        c19v12 = false
        c19v13 = c19v0.mIndex
        c19v14 = c26v3
        c19v14 = c19v14:GetHowManyElements()
        if c19v13 ~= c19v14 then
          p118 = 49
        else
          p118 = 48
        end
      end
      if p118 == 48 then
        c19v12 = true
        p118 = 52
      end
      if p118 == 49 then
        c19v13 = c26v3
        c19v16 = c19v0.mIndex
        c19v15 = c19v16 + 1
        c19v13 = c19v13:GetElementInIndex(c19v15)
        c19v14 = c19v0.Order
        c19v15 = c19v13.Order
        if c19v14 ~= c19v15 then
          p118 = 51
        else
          p118 = 50
        end
      end
      if p118 == 50 then
        c19v12 = false
        p118 = 52
      end
      if p118 == 51 then
        c19v12 = true
        p118 = 52
      end
      if p118 == 52 then
        c19v13 = c26v3
        c19v13 = c19v13.mMovie
        c19v15 = c19v0.mClipName
        c19v16 = 13
        c19v18 = c19v0.Filler
        c19v17 = not c19v18
        c19v13:Name__d9713943(c19v15, c19v16, c19v17)
        c19v13 = c26v3
        c19v13 = c19v13.mMovie
        c19v15 = c19v0.mClipName
        c19v16 = "Line"
        c19v17 = 13
        c19v18 = not c19v12
        if not c19v18 then
          p118 = 54
        else
          p118 = 53
        end
      end
      if p118 == 53 then
        c19v19 = c19v0.Filler
        c19v18 = not c19v19
        p118 = 54
      end
      if p118 == 54 then
        c19v13:Makeposshield(c19v15, c19v16, c19v17, c19v18)
        c19v13 = c26v3
        c19v13 = c19v13.mMovie
        c19v15 = c19v0.mClipName
        c19v16 = "DotLine"
        c19v17 = 13
        c19v19 = c26v3
        c19v19 = c19v19.DotLink
        if not c19v19 then
          p118 = 58
        else
          p118 = 55
        end
      end
      if p118 == 55 then
        c19v20 = c19v0.Filler
        if c19v20 then
          p118 = 57
        else
          p118 = 56
        end
      end
      if p118 == 56 then
        c19v20 = c19v0.Title
        p118 = 57
      end
      if p118 == 57 then
        c19v19 = not c19v20
        p118 = 58
      end
      if p118 == 58 then
        if c19v19 == true then
          p118 = 60
        else
          p118 = 59
        end
      end
      if p118 == 59 then
        c19v18 = false
        p118 = 61
      end
      if p118 == 60 then
        c19v18 = true
        p118 = 61
      end
      if p118 == 61 then
        c19v13:Makeposshield(c19v15, c19v16, c19v17, c19v18)
        c19v13 = c19v0.Filler
        if c19v13 then
          p118 = 63
        else
          p118 = 62
        end
      end
      if p118 == 62 then
        c19v13 = c19v0.Title
        if not c19v13 then
          p118 = 64
        else
          p118 = 63
        end
      end
      if p118 == 63 then
        c19v13 = c26v3
        c19v13 = c19v13.mMovie
        c19v16 = c19v0.mClipName
        c19v17 = ".NewValue"
        c19v15 = c19v16 .. c19v17
        c19v16 = 36
        c19v17 = ""
        c19v13:SetStringVariable(c19v15, c19v16, c19v17)
        do return end
      end
      if p118 == 64 then
        c19v13 = c26v3
        c19v13 = c19v13.DotLink
        if not c19v13 then
          p118 = 68
        else
          p118 = 65
        end
      end
      if p118 == 65 then
        c19v13 = c26v3
        c19v13 = c19v13.Width
        if c19v13 == nil then
          p118 = 68
        else
          p118 = 66
        end
      end
      if p118 == 66 then
        c19v13 = c26v3
        c19v13 = c19v13.mMovie
        c19v16 = c19v0.mClipName
        c19v17 = ".Label"
        c19v15 = c19v16 .. c19v17
        c19v16 = 40
        c19v13 = c19v13:GetNumberVariable(c19v15, c19v16)
        c19v14 = c26v3
        c19v14 = c19v14.mMovie
        c19v17 = c19v0.mClipName
        c19v18 = ".NewValue"
        c19v16 = c19v17 .. c19v18
        c19v17 = 40
        c19v14 = c19v14:GetNumberVariable(c19v16, c19v17)
        c19v15 = v0
        c19v15 = c19v15.Round
        c19v18 = c26v3
        c19v18 = c19v18.Width
        c19v20 = c19v13 + c19v14
        c19v19 = c19v20 + 10
        c19v17 = c19v18 - c19v19
        c19v16 = c19v17 / 5
        c19v15 = c19v15(c19v16)
        c19v16 = c19v15 * 5
        c19v17 = c26v3
        c19v17 = c19v17.mMovie
        c19v20 = c19v0.mClipName
        c19v21 = ".DotLine"
        c19v19 = c19v20 .. c19v21
        c19v20 = "TileRepeats"
        c19v22 = 1
        c19v23 = 1
        c19v24 = 1
        c19v17:Name__e243d995(c19v19, c19v20, c19v15, c19v22, c19v23, c19v24)
        c19v17 = c26v3
        c19v17 = c19v17.mMovie
        c19v19 = c19v0.mClipName
        c19v20 = "DotLine"
        c19v21 = 14
        c19v17:Name__52c1b74e(c19v19, c19v20, c19v21, c19v16)
        c19v17 = c26v3
        c19v17 = c19v17.mMovie
        c19v19 = c19v0.mClipName
        c19v20 = "DotLine"
        c19v21 = 15
        c19v22 = 5
        c19v17:Name__52c1b74e(c19v19, c19v20, c19v21, c19v22)
        c19v17 = c26v3
        c19v17 = c19v17.mMovie
        c19v19 = c19v0.mClipName
        c19v20 = "DotLine"
        c19v21 = 12
        c19v22 = 10
        c19v17:Name__52c1b74e(c19v19, c19v20, c19v21, c19v22)
        c19v17 = c26v3
        c19v17 = c19v17.mMovie
        c19v19 = c19v0.mClipName
        c19v20 = "DotLine"
        c19v21 = 0
        c19v24 = c26v3
        c19v24 = c19v24.mMovie
        c19v27 = c19v0.mClipName
        c19v28 = ".Label"
        c19v26 = c19v27 .. c19v28
        c19v27 = 0
        c19v24 = c19v24:GetNumberVariable(c19v26, c19v27)
        c19v23 = c19v24 + c19v13
        c19v22 = c19v23 + 5
        c19v17:Name__52c1b74e(c19v19, c19v20, c19v21, c19v22)
        c19v18 = c26v3
        c19v18 = c19v18.DotLinkMat
        c19v17 = IsNull
        c19v17 = c19v17(c19v18)
        if c19v17 then
          p118 = 68
        else
          p118 = 67
        end
      end
      if p118 == 67 then
        c19v17 = c26v3
        c19v17 = c19v17.mMovie
        c19v20 = c19v0.mClipName
        c19v21 = ".DotLine"
        c19v19 = c19v20 .. c19v21
        c19v20 = c26v3
        c19v20 = c19v20.DotLinkMat
        c19v17:OverrideMaterial(c19v19, c19v20)
        p118 = 68
      end
      if p118 == 68 then
        do return end
      end
    end
    c26v3.mElementDrawCallback = c26v4
    c26v4 = c26v3.Redraw
    c26v3._list_Redraw = c26v4
    c26v4 = function(c20v0, c20v1, c20v2, c20v3)
      c20v0:Populate()
      c20v0:_list_Redraw(c20v1, c20v2, c20v3)
      do return end
    end
    c26v3.Redraw = c26v4
    c26v4 = function(c21v0, c21v1)
      do return end
    end
    c26v3.SetupPreInterpolationValues = c26v4
    c26v4 = c26v3.DefaultAlphaInterpolation
    c26v3.GetInterpolationProperties = c26v4
    c26v4 = function(c22v0)
      local c22v1, c22v2, c22v3, c22v4, c22v5, c22v6, c22v7, c22v8, c22v9, c22v10, c22v11, c22v12
      c22v1 = 0
      c22v4 = 1
      c22v5 = c22v0.mElements
      c22v2 = #c22v5
      c22v3 = 1
      for c22v4 = c22v4, c22v2, c22v3 do
        c22v6 = c22v0.mElements
        c22v5 = c22v6[c22v4]
        c22v6 = c22v5.Filler
        if c22v6 then
          c22v1 = c22v1 + 10
        else
          c22v6 = c22v0.mMovie
          c22v8 = c22v5.mClipName
          c22v9 = 15
          c22v6 = c22v6:GetNumberVariable(c22v8, c22v9)
          c22v8 = c22v0.mOriginalElementHeight
          c22v7 = c22v6 - c22v8
          c22v9 = c22v0.mForcedVerticalSeparation
          c22v8 = c22v1 + c22v9
          c22v9 = v0
          c22v9 = c22v9.Ternary
          c22v11 = 0
          if c22v7 <= c22v11 then
            c22v10 = false
          else
            c22v10 = true
          end
          c22v11 = c22v7 + 3
          c22v12 = 0
          c22v9 = c22v9(c22v10, c22v11, c22v12)
          c22v1 = c22v8 + c22v9
        end
      end
      do return c22v1 end
    end
    c26v3.GetHeight = c26v4
    c26v4 = function(c23v0, c23v1)
      local c23v2, c23v3, c23v4, c23v5, c23v6, c23v7, c23v8, c23v9, c23v10, c23v11, c23v12, c23v13
      c23v2 = c23v0.mInitialY
      c23v5 = 1
      c23v6 = c23v1.Id
      c23v3 = c23v6 - 1
      c23v4 = 1
      for c23v5 = c23v5, c23v3, c23v4 do
        c23v7 = c23v0.mElements
        c23v6 = c23v7[c23v5]
        c23v6 = c23v6.Filler
        if c23v6 then
          c23v6 = v0
          c23v6 = c23v6.Ternary
          c23v7 = c23v0.mGrowsUpwards
          c23v8 = 10
          c23v9 = -10
          c23v6 = c23v6(c23v7, c23v8, c23v9)
          c23v2 = c23v2 + c23v6
        else
          c23v6 = c23v0.mMovie
          c23v9 = c23v0.mElements
          c23v8 = c23v9[c23v5]
          c23v8 = c23v8.mClipName
          c23v9 = 15
          c23v6 = c23v6:GetNumberVariable(c23v8, c23v9)
          c23v8 = c23v0.mOriginalElementHeight
          c23v7 = c23v6 - c23v8
          c23v9 = c23v0.mForcedVerticalSeparation
          c23v10 = v0
          c23v10 = c23v10.Ternary
          c23v12 = 0
          if c23v7 <= c23v12 then
            c23v11 = false
          else
            c23v11 = true
          end
          c23v12 = c23v7 + 3
          c23v13 = 0
          c23v10 = c23v10(c23v11, c23v12, c23v13)
          c23v8 = c23v9 + c23v10
          c23v9 = v0
          c23v9 = c23v9.Ternary
          c23v10 = c23v0.mGrowsUpwards
          c23v12 = -c23v8
          c23v8 = c23v9(c23v10, c23v8, c23v12)
          c23v2 = c23v2 + c23v8
        end
      end
      do return c23v2 end
    end
    c26v3.CalculateY = c26v4
    c26v4 = function(c25v0)
      local c25v1, c25v2, c25v3, c25v4, c25v5, c25v6, c25v7, c25v8, c25v9, c25v10, c25v11, c25v12, c25v13, c25v14, c25v15, c25v16, c25v17, c25v18, c25v19, c25v20, c25v22, c25v23, c25v24, c25v25, c25v26, c25v27, c25v28, c25v29, c25v30
      c25v3 = true
      c25v4 = true
      c25v0:RemoveElements(c25v3, c25v4)
      c25v1 = {}
      c25v2 = false
      c25v3 = false
      c25v4 = false
      c25v5 = v0
      c25v5 = c25v5.Ternary
      c25v6 = c25v0.mGrowsUpwards
      c25v7 = 1
      c25v8 = 0
      c25v5 = c25v5(c25v6, c25v7, c25v8)
      c25v6 = c25v5 + 1
      c25v7 = c25v6 + 1
      c25v8 = c25v7 + 1
      c25v9 = c25v8 + 1
      c25v10 = c25v9 + 1
      c25v11 = c25v10 + 1
      c25v12 = c25v11 + 1
      c25v13 = v0
      c25v13 = c25v13.Ternary
      c25v14 = c25v0.mGrowsUpwards
      c25v15 = 0
      c25v13 = c25v13(c25v14, c25v15, c25v12)
      c25v14 = v0
      c25v14 = c25v14.Ternary
      c25v15 = c25v0.mGrowsUpwards
      c25v17 = 0
      c25v14 = c25v14(c25v15, c25v12, c25v17)
      c25v15 = v0
      c25v15 = c25v15.Ternary
      c25v16 = c25v0.mGrowsUpwards
      c25v17 = 0
      c25v20 = c25v0.mStats
      c25v19 = #c25v20
      c25v20 = c25v12 + 1
      c25v18 = c25v19 * c25v20
      c25v15 = c25v15(c25v16, c25v17, c25v18)
      c25v16 = false
      c25v17 = ipairs
      c25v18 = c25v0.mStats
      c25v17, c25v18, c25v19 = c25v17(c25v18)
      for c25v20, c25v21 in c25v17, c25v18, c25v19 do
        c25v27 = c25v0.mSort
        c25v27 = c25v11 + c25v15
        c25v26.Order = c25v27
        c25v29 = { Label = "", Previous = nil, Filler = true, Order = nil }
        c25v30 = c25v11 + c25v15
        c25v29.Order = c25v30
        c25v27 = table.insert
        c25v27(c25v1, c25v29)
        c25v27 = c25v5 + c25v15
        c25v26.Order = c25v27
        c25v2 = true
        c25v27 = string.find
        c25v29 = "_RESIST$"
        c25v27 = c25v27(c25v25, c25v29)
        c25v27 = c25v7 + c25v15
        c25v26.Order = c25v27
        c25v3 = true
        c25v27 = string.find
        c25v29 = "EmbedDT_"
        c25v27 = c25v27(c25v25, c25v29)
        c25v27 = c25v10 + c25v15
        c25v26.Order = c25v27
        c25v27 = string.find
        c25v29 = "Embed"
        c25v27 = c25v27(c25v25, c25v29)
        c25v27 = c25v8 + c25v15
        c25v26.Order = c25v27
        c25v27 = string.find
        c25v29 = "DT_"
        c25v27 = c25v27(c25v25, c25v29)
        c25v27 = string.find
        c25v29 = "Power_"
        c25v27 = c25v27(c25v25, c25v29)
        c25v27 = c25v9 + c25v15
        c25v26.Order = c25v27
        c25v4 = true
        c25v27 = c25v6 + c25v15
        c25v26.Order = c25v27
        c25v27 = table.insert
        c25v27(c25v1, c25v26)
        c25v27 = c25v26.ForceOrder
        if c25v27 ~= nil then
          c25v28 = c25v26.ForceOrder
          c25v27 = c25v28 + c25v15
          c25v26.Order = c25v27
          c25v27 = c25v26.ForceOrder
          if c25v27 == c25v5 then
            c25v2 = true
          else
            c25v27 = c25v26.ForceOrder
            if c25v27 == c25v7 then
              c25v3 = true
            else
              c25v27 = c25v26.ForceOrder
              if c25v27 == c25v9 then
                c25v4 = true
              end
            end
          end
        end
        c25v22 = c25v0.mSort
        if c25v22 then
          if c25v2 then
            c25v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
            c25v25 = c25v6 + c25v15
            c25v24.Order = c25v25
            c25v22 = table.insert
            c25v22(c25v1, c25v24)
          end
          if c25v3 then
            c25v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
            c25v25 = c25v7 + c25v15
            c25v24.Order = c25v25
            c25v22 = table.insert
            c25v22(c25v1, c25v24)
          end
          if c25v4 then
            c25v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
            c25v25 = c25v9 + c25v15
            c25v24.Order = c25v25
            c25v22 = table.insert
            c25v22(c25v1, c25v24)
          end
        end
        c25v16 = true
        c25v22 = v0
        c25v22 = c25v22.Ternary
        c25v23 = c25v0.mGrowsUpwards
        c25v25 = c25v12 + 1
        c25v24 = c25v25 + c25v15
        c25v26 = c25v12 + 1
        c25v25 = c25v26 - c25v15
        c25v15 = c25v22(c25v23, c25v24, c25v25)
        for c25v20, c25v21 in c25v17, c25v18, c25v19 do
          c25v17 = c25v0.mSort
          if c25v17 then
            c25v17 = table.sort
            c25v19 = function(c24v0, c24v1)
              local c24v2, c24v3, c24v4
              c24v2 = c24v0.Order
              c24v3 = c24v1.Order
              if c24v2 ~= c24v3 then
                c24v3 = c24v0.Order
                c24v4 = c24v1.Order
                if c24v4 <= c24v3 then
                  c24v2 = false
                else
                  c24v2 = true
                end
                do return c24v2 end
              end
              c24v3 = c24v0.Label
              c24v4 = c24v1.Label
              if c24v4 <= c24v3 then
                c24v2 = false
              else
                c24v2 = true
              end
              do return c24v2 end
            end
            c25v17(c25v1, c25v19)
          end
          c25v17 = 0
          c25v18 = pairs
          c25v18, c25v19, c25v20 = c25v18(c25v1)
          for c25v21, c25v22 in c25v18, c25v19, c25v20 do
            c25v23 = ResetLineCount
            c25v24 = 0
            c25v23(c25v24)
            c25v17 = c25v17 + 1
            c25v22.Id = c25v17
            c25v26 = true
            c25v0:AddElement(c25v22, c25v26)
          end
          do return end
        end
        if c25v16 then
          c25v24 = { Label = "", Previous = nil, Filler = true, Order = nil }
          c25v25 = v0
          c25v25 = c25v25.Ternary
          c25v26 = c25v0.mGrowsUpwards
          c25v28 = c25v14 - c25v15
          c25v25 = c25v25(c25v26, c25v15, c25v28)
          c25v24.Order = c25v25
          c25v22 = table.insert
          c25v22(c25v1, c25v24)
        end
        c25v22 = v12
        c25v23 = c25v21.mName
        c25v22 = c25v22(c25v23)
        if not c25v22 then
          c25v23 = c25v0.mStats
          c25v22 = #c25v23
          c25v23 = 1
          if c25v23 < c25v22 then
            c25v24 = { Label = nil, Previous = nil, Title = true, Order = nil }
            c25v26 = "<p><font color=\""
            c25v27 = c25v0.GroupTitleColor
            c25v28 = "\"><b>"
            c25v29 = c25v21.mName
            c25v30 = "</b></font></p>"
            c25v25 = c25v26 .. c25v27 .. c25v28 .. c25v29 .. c25v30
            c25v24.Label = c25v25
            c25v25 = c25v13 + c25v15
            c25v24.Order = c25v25
            c25v22 = table.insert
            c25v22(c25v1, c25v24)
          end
        end
        c25v22 = pairs
        c25v23 = c25v21.mStats
        c25v22, c25v23, c25v24 = c25v22(c25v23)
      end
    end
    c26v3.Populate = c26v4
    do return c26v3 end
  end
  Create = v13
  v13 = function(c27v0, c27v1, c27v2, c27v3, c27v4, c27v5, c27v6, c27v7, c27v8, c27v9, c27v10, c27v11)
    local c27v12, c27v14, c27v15
    if c27v5 ~= nil then
      c27v12 = v0
      c27v12 = c27v12.FormatNumber
      c27v14 = c27v7 or 1
      c27v15 = false
      c27v5 = c27v12(c27v5, c27v14, c27v15)
    end
    c27v12 = { DisplayValue = nil, StatValue = nil, TextOnly = nil, TextIfOneNil = nil, ToolTip = nil, ToolTipValue = nil, ToolTipLabel = nil, SecondaryToolTips = nil, HideStat = nil, HeaderOverride = nil, SmallerIsBetter = nil }
    c27v12.DisplayValue = c27v0
    c27v12.StatValue = c27v1
    c27v12.TextOnly = c27v2
    c27v12.TextIfOneNil = c27v3
    c27v12.ToolTip = c27v4
    c27v12.ToolTipValue = c27v5
    c27v12.ToolTipLabel = c27v6
    c27v12.SecondaryToolTips = c27v8
    c27v12.HideStat = c27v9
    c27v12.HeaderOverride = c27v10
    c27v12.SmallerIsBetter = c27v11
    do return c27v12 end
  end
  v14 = function(c28v0, c28v1)
    local c28v2, c28v3, c28v4, c28v5, c28v6, c28v8, c28v9, c28v10, c28v11, c28v13
    c28v2 = 9
    if c28v1 == 1 then
      c28v2 = 11
    else
      if c28v1 == -1 then
        c28v2 = 12
      end
    end
    c28v4 = "<font color=\"#"
    c28v9 = string.format
    c28v10 = "%X"
    c28v11 = v2
    c28v11 = c28v11.GetColor
    c28v13 = true
    c28v5 = c28v9(c28v10, c28v11(c28v2, c28v13))
    c28v6 = "\"><b>"
    c28v8 = "</b></font>"
    c28v3 = c28v4 .. c28v5 .. c28v6 .. c28v0 .. c28v8
    do return c28v3 end
  end
  v15 = function(c29v0, c29v1, c29v2)
    local c29v3, c29v4, c29v5, c29v6, c29v7, c29v8, c29v9, c29v10, c29v11, c29v12, c29v13, c29v14, c29v15, c29v16, c29v17, c29v18, c29v19, c29v20, c29v21, c29v22, c29v23, c29v24, c29v25, c29v26, c29v27, c29v28
    c29v24 = string.find
    c29v26 = "AMOUNT"
    c29v24 = c29v24(c29v22, c29v26)
    c29v18 = 0
    c29v24 = 0
    c29v24 = 0
    c29v3 = 3
    c29v15[c29v22] = c29v23
    c29v23 = v14
    c29v21 = c29v23(c29v5, c29v18)
    c29v25 = true
    c29v22 = c29v0:GetLocalized(c29v13, c29v25, c29v15)
    c29v4 = c29v4 .. c29v6 .. c29v21 .. c29v22
    c29v6 = "\r\n\r\n"
    c29v4 = ""
    c29v7 = "<MINI_DIAMOND> "
    c29v8 = true
    c29v5 = c29v0:GetLocalized(c29v7, c29v8)
    c29v6 = ""
    c29v7 = nil
    c29v8 = v0
    c29v8 = c29v8.CopyTableRecursive
    c29v7 = c29v8(c29v1)
    c29v8 = ipairs
    c29v8, c29v9, c29v10 = c29v8(c29v2)
    for c29v11, c29v12 in c29v8, c29v9, c29v10 do
      c29v13 = c29v12.VARS
      if c29v13 ~= nil then
        c29v14 = c29v12.VARS
        c29v13 = c29v14.AMOUNT
        if c29v13 ~= nil then
          c29v13 = c29v7[c29v11]
          if c29v13 == nil then
            c29v13 = v0
            c29v13 = c29v13.CopyTableRecursive
            c29v13 = c29v13(c29v12)
            c29v7[c29v11] = c29v13
            c29v13 = c29v7[c29v11]
            c29v13 = c29v13.VARS
            c29v14 = 0
            c29v13.AMOUNT = c29v14
          end
        end
      end
    end
    for c29v11, c29v12 in c29v8, c29v9, c29v10 do
    end
    c29v8 = ipairs
    c29v8, c29v9, c29v10 = c29v8(c29v7)
    c29v24 = c29v2[c29v11]
    if c29v24 == nil then
      c29v18 = 1
    else
      c29v25 = c29v2[c29v11]
      c29v25 = c29v25.VARS
      c29v24 = c29v25[c29v22]
      if not ((c29v24 == nil or c29v23 == nil)) then
        if c29v23 < c29v24 then
          c29v18 = -1
        else
          if c29v24 < c29v23 then
            c29v18 = 1
          end
        end
      end
    end
    c29v18 = c29v18 * c29v17
    c29v24 = c29v12.skipIndicatorComparison
    if c29v18 == 0 then
      c29v3 = 0
    else
      c29v24 = v0
      c29v24 = c29v24.Ternary
      c29v26 = 0
      if c29v18 <= c29v26 then
        c29v25 = false
      else
        c29v25 = true
      end
      c29v26 = 1
      c29v27 = 2
      c29v3 = c29v24(c29v25, c29v26, c29v27)
    end
    c29v24 = v0
    c29v24 = c29v24.Ternary
    c29v26 = 0
    if c29v18 <= c29v26 then
      c29v25 = false
    else
      c29v25 = true
    end
    c29v26 = 1
    c29v27 = 2
    c29v3 = c29v24(c29v25, c29v26, c29v27)
    c29v24 = ""
    c29v25 = c29v12.ShowAsPercent
    if c29v25 then
      c29v25 = v11
      c29v24 = c29v25(c29v23)
    else
      c29v25 = v0
      c29v25 = c29v25.FormatNumber
      c29v27 = 1
      c29v28 = false
      c29v24 = c29v25(c29v23, c29v27, c29v28)
    end
    c29v25 = v14
    c29v25 = c29v25(c29v24, c29v18)
    c29v15[c29v22] = c29v25
    for c29v11, c29v12 in c29v8, c29v9, c29v10 do
      do return c29v4, c29v3 end
    end
    c29v13 = c29v12.TEXT
    c29v14 = c29v12.VARS
    c29v15 = {}
    if c29v2 == nil then
      c29v16 = false
    else
      c29v16 = true
    end
    c29v17 = v0
    c29v17 = c29v17.Ternary
    c29v18 = c29v12.comparisonFlipped
    c29v19 = -1
    c29v20 = 1
    c29v17 = c29v17(c29v18, c29v19, c29v20)
    c29v18 = c29v12.skipFormatting
    if c29v18 then
      c29v5 = ""
      c29v6 = "\r\n"
    end
    c29v18 = 0
    c29v19 = pairs
    c29v19, c29v20, c29v21 = c29v19(c29v14)
  end
  v16 = function(c30v0)
    local c30v1, c30v2, c30v3, c30v4, c30v5, c30v6, c30v8
    c30v1 = WeakResource
    c30v2 = "/Lotus/Weapons/Tenno/LotusLongGun"
    c30v1 = c30v1(c30v2)
    c30v2 = WeakResource
    c30v3 = "/Lotus/Weapons/Sentients/OperatorAmplifiers/OperatorAmpWeapon"
    c30v2 = c30v2(c30v3)
    c30v3 = WeakResource
    c30v4 = "/Lotus/Weapons/Tenno/Archwing/Primary/ArchGun"
    c30v3 = c30v3(c30v4)
    c30v4 = WeakResource
    c30v5 = "/Lotus/Weapons/CrewShip/RailjackWeapon"
    c30v4 = c30v4(c30v5)
    c30v5 = WeakResource
    c30v6 = "/Lotus/Types/Friendly/Pets/BeastPetMeleeWeaponBase"
    c30v5 = c30v5(c30v6)
    c30v6 = c30v0:IsA(c30v1)
    if not c30v6 then
      c30v8 = gLotusPistolType
      c30v6 = c30v0:IsA(c30v8)
      if not c30v6 then
        c30v6 = c30v0:IsA(c30v3)
        if not c30v6 then
          c30v8 = gLotusMeleeWeaponType
          c30v6 = c30v0:IsA(c30v8)
          if not c30v6 then
            c30v6 = c30v0:IsA(c30v4)
            if not c30v6 then
              c30v6 = c30v0:IsA(c30v2)
              if not c30v6 then
                c30v6 = c30v0:IsA(c30v5)
              end
            end
          end
        end
      end
    end
    do return c30v6 end
  end
  v17 = function(c31v0)
    local c31v3
    c31v3 = gPowerSuitType
    do return c31v0:IsA(c31v3) end
  end
  v18 = function(c32v0, c32v1, c32v2)
    local c32v3, c32v4, c32v5, c32v6, c32v7, c32v8, c32v9, c32v10, c32v11, c32v12, c32v13, c32v14, c32v15, c32v16, c32v17, c32v18, c32v19, c32v20, c32v21, c32v22, c32v23, c32v24, c32v25, c32v26, c32v27, c32v28, c32v29, c32v30, c32v31, c32v32
    c32v3 = IsNull
    c32v3 = c32v3(c32v1)
    c32v3 = IsNull
    c32v3 = c32v3(c32v2)
    c32v3 = {}
    c32v4 = { mName = nil, mStats = nil, mIsMelee = false }
    c32v7 = "/Lotus/Language/Labels/RAILJACKUpper"
    c32v8 = false
    c32v5 = c32v0:GetLocalized(c32v7, c32v8)
    c32v4.mName = c32v5
    c32v5 = {}
    c32v4.mStats = c32v5
    c32v5 = c32v4.mStats
    c32v6 = c32v1:DamageControl()
    c32v7 = c32v1:InventoryControl()
    c32v8 = c32v1:MotionControl()
    c32v9 = c32v1:GetMaxHealth()
    c32v10 = v13
    c32v11 = nil
    c32v13 = nil
    c32v14 = true
    c32v10 = c32v10(c32v11, c32v9, c32v13, c32v14)
    c32v5.RailjackHealth = c32v10
    c32v10 = c32v6:GetMaxShield()
    c32v11 = c32v6:Name__e875637d()
    c32v12 = c32v11 / c32v10
    c32v11 = c32v12 * 100
    c32v12 = c32v6:GetShieldRechargeDelay()
    c32v13 = v13
    c32v14 = nil
    c32v16 = nil
    c32v17 = true
    c32v13 = c32v13(c32v14, c32v10, c32v16, c32v17)
    c32v5.Shield = c32v13
    c32v13 = v13
    c32v16 = "/Lotus/Language/Game/UNIT_PERCENT_PER_SECOND"
    c32v17 = false
    c32v18 = { COUNT = nil }
    c32v19 = v0
    c32v19 = c32v19.FormatNumber
    c32v21 = 1
    c32v22 = false
    c32v19 = c32v19(c32v11, c32v21, c32v22)
    c32v18.COUNT = c32v19
    c32v14 = c32v0:GetLocalized(c32v16, c32v17, c32v18)
    c32v15 = v0
    c32v15 = c32v15.Round
    c32v17 = 1
    c32v15 = c32v15(c32v11, c32v17)
    c32v16 = nil
    c32v17 = true
    c32v13 = c32v13(c32v14, c32v15, c32v16, c32v17)
    c32v5.ShieldRechargeRate = c32v13
    c32v13 = v13
    c32v16 = "/Lotus/Language/Menu/ProgressSeconds"
    c32v17 = false
    c32v18 = { CURRENT = nil }
    c32v19 = v0
    c32v19 = c32v19.FormatNumber
    c32v21 = 1
    c32v22 = false
    c32v19 = c32v19(c32v12, c32v21, c32v22)
    c32v18.CURRENT = c32v19
    c32v14 = c32v0:GetLocalized(c32v16, c32v17, c32v18)
    c32v15 = -c32v12
    c32v16 = nil
    c32v17 = true
    c32v13 = c32v13(c32v14, c32v15, c32v16, c32v17)
    c32v5.ShieldRechargeDelay = c32v13
    c32v13 = c32v6:GetArmourRating()
    c32v15 = 100
    c32v16 = c32v6:GetArmourResistance()
    c32v14 = c32v15 * c32v16
    c32v15 = v13
    c32v16 = nil
    c32v18 = nil
    c32v19 = true
    c32v20 = nil
    c32v15 = c32v15(c32v16, c32v13, c32v18, c32v19, c32v20, c32v14)
    c32v5.Armor = c32v15
    c32v18 = 0
    c32v16 = c32v8:GetMaxVelocity(c32v18)
    c32v17 = c32v1:GetZoneScale()
    c32v15 = c32v16 / c32v17
    c32v18 = c32v15.x
    c32v19 = c32v15.y
    c32v17 = c32v18 + c32v19
    c32v18 = c32v15.z
    c32v16 = c32v17 + c32v18
    c32v15 = c32v16 / 3
    c32v16 = v13
    c32v19 = "/Lotus/Language/Game/UNIT_METER_PER_SECOND"
    c32v20 = false
    c32v21 = { COUNT = nil }
    c32v22 = v0
    c32v22 = c32v22.FormatNumber
    c32v24 = 0
    c32v25 = false
    c32v22 = c32v22(c32v15, c32v24, c32v25)
    c32v21.COUNT = c32v22
    c32v17 = c32v0:GetLocalized(c32v19, c32v20, c32v21)
    c32v19 = nil
    c32v20 = true
    c32v16 = c32v16(c32v17, c32v15, c32v19, c32v20)
    c32v5.Engines = c32v16
    c32v18 = c32v8:Name__f0b747d5()
    c32v18 = c32v18.x
    c32v19 = 152
    c32v20 = c32v2:GetType()
    c32v16 = c32v7:GetUpgradeModifiedValue(c32v18, c32v19, c32v20, c32v2)
    c32v17 = v13
    c32v19 = "x"
    c32v20 = v0
    c32v20 = c32v20.FormatNumber
    c32v22 = 1
    c32v23 = false
    c32v20 = c32v20(c32v16, c32v22, c32v23)
    c32v18 = c32v19 .. c32v20
    c32v20 = nil
    c32v21 = true
    c32v17 = c32v17(c32v18, c32v16, c32v20, c32v21)
    c32v5.EngineBoost = c32v17
    c32v18 = 3
    c32v19 = 5
    c32v20 = 6
    c32v21 = 4
    c32v17 = {c32v18, c32v19, c32v20, c32v21}
    c32v20 = 1
    c32v18 = #c32v17
    c32v19 = 1
    for c32v20 = c32v20, c32v18, c32v19 do
      c32v21 = c32v17[c32v20]
      c32v24 = 100
      c32v25 = 42
      c32v26 = nil
      c32v27 = nil
      c32v22 = c32v7:GetUpgradeModifiedValue(c32v24, c32v25, c32v26, c32v27, c32v21)
      if c32v22 ~= 100 then
        c32v26 = v0
        c32v26 = c32v26.FormatNumber
        c32v27 = 100 - c32v22
        c32v28 = 1
        c32v29 = false
        c32v24 = c32v26(c32v27, c32v28, c32v29)
        c32v25 = "%"
        c32v23 = c32v24 .. c32v25
        c32v24 = v1
        c32v24 = c32v24.GetDamageTypeTag
        c32v24 = c32v24(c32v21)
        c32v25 = v13
        c32v28 = nil
        c32v29 = true
        c32v25 = c32v25(c32v23, c32v22, c32v28, c32v29)
        c32v5[c32v24] = c32v25
      end
    end
    if c32v3 then
      do return end
    end
    c32v20 = 0
    c32v21 = 144
    c32v22 = nil
    c32v23 = nil
    c32v24 = 23
    c32v18 = c32v7:GetUpgradeModifiedValue(c32v20, c32v21, c32v22, c32v23, c32v24)
    if c32v18 ~= 0 then
      c32v22 = v0
      c32v22 = c32v22.FormatNumber
      c32v23 = c32v18 * 100
      c32v24 = 1
      c32v25 = false
      c32v20 = c32v22(c32v23, c32v24, c32v25)
      c32v21 = "%"
      c32v19 = c32v20 .. c32v21
      c32v20 = v13
      c32v23 = nil
      c32v24 = true
      c32v20 = c32v20(c32v19, c32v18, c32v23, c32v24)
      c32v5.ElementRedirection = c32v20
    end
    c32v19 = c32v7:GetcheckCollision()
    c32v20 = v13
    c32v21 = nil
    c32v23 = nil
    c32v24 = true
    c32v20 = c32v20(c32v21, c32v19, c32v23, c32v24)
    c32v5.CargoCapacity = c32v20
    c32v20 = table.insert
    c32v20(c32v3, c32v4)
    c32v20 = { mName = nil, mStats = nil, mIsMelee = false }
    c32v23 = "/Lotus/Language/Labels/RAILJACK_BATTLE_MOD"
    c32v24 = false
    c32v21 = c32v0:GetLocalized(c32v23, c32v24)
    c32v20.mName = c32v21
    c32v21 = {}
    c32v20.mStats = c32v21
    c32v21 = c32v20.mStats
    c32v24 = 1
    c32v25 = 10
    c32v26 = c32v2:GetType()
    c32v22 = c32v7:GetUpgradeModifiedValue(c32v24, c32v25, c32v26, c32v2)
    c32v23 = v13
    c32v27 = v0
    c32v27 = c32v27.FormatNumber
    c32v28 = c32v22 * 100
    c32v29 = 0
    c32v30 = false
    c32v25 = c32v27(c32v28, c32v29, c32v30)
    c32v26 = "%"
    c32v24 = c32v25 .. c32v26
    c32v26 = nil
    c32v27 = true
    c32v23 = c32v23(c32v24, c32v22, c32v26, c32v27)
    c32v21.Railjack_Power_Strength = c32v23
    c32v25 = 1
    c32v26 = 9
    c32v27 = c32v2:GetType()
    c32v23 = c32v7:GetUpgradeModifiedValue(c32v25, c32v26, c32v27, c32v2)
    c32v24 = v13
    c32v28 = v0
    c32v28 = c32v28.FormatNumber
    c32v29 = c32v23 * 100
    c32v30 = 0
    c32v31 = false
    c32v26 = c32v28(c32v29, c32v30, c32v31)
    c32v27 = "%"
    c32v25 = c32v26 .. c32v27
    c32v27 = nil
    c32v28 = true
    c32v24 = c32v24(c32v25, c32v23, c32v27, c32v28)
    c32v21.Railjack_Power_Range = c32v24
    c32v26 = 1
    c32v27 = 3
    c32v28 = c32v2:GetType()
    c32v24 = c32v7:GetUpgradeModifiedValue(c32v26, c32v27, c32v28, c32v2)
    c32v25 = v13
    c32v29 = v0
    c32v29 = c32v29.FormatNumber
    c32v30 = c32v24 * 100
    c32v31 = 0
    c32v32 = false
    c32v27 = c32v29(c32v30, c32v31, c32v32)
    c32v28 = "%"
    c32v26 = c32v27 .. c32v28
    c32v28 = nil
    c32v29 = true
    c32v25 = c32v25(c32v26, c32v24, c32v28, c32v29)
    c32v21.Railjack_Power_Duration = c32v25
    c32v25 = table.insert
    c32v25(c32v3, c32v20)
    do return c32v3 end
  end
  v19 = function(c33v0, c33v1, c33v2, c33v3, c33v4)
    local c33v5, c33v6, c33v7, c33v8, c33v9, c33v10, c33v11, c33v12, c33v13, c33v14, c33v15, c33v16, c33v17, c33v18, c33v19, c33v20, c33v21, c33v22, c33v23, c33v24, c33v25, c33v26, c33v27, c33v28, c33v29, c33v30, c33v31, c33v32, c33v33, c33v34, c33v35, c33v36, c33v37, c33v38, c33v39, c33v40, c33v41, c33v42, c33v43, c33v44, c33v45
    c33v25 = gSentinelPowerSuitType
    c33v23 = c33v2:IsA(c33v25)
    c33v28 = nil
    if c33v18 then
      c33v31 = c33v27 - 1
      c33v28 = c33v2:GetAbilityByIndex(c33v31)
    else
      c33v31 = c33v27 - 1
      c33v28 = c33v2:Name__06c22bff(c33v31)
    end
    c33v29 = IsNull
    c33v29 = c33v29(c33v28)
    if not c33v29 then
      c33v30 = "Ability"
      c33v29 = c33v30 .. c33v27
      c33v32 = c33v28:GetLocalizeTag()
      c33v32 = c33v32:c_str()
      c33v33 = false
      c33v30 = c33v0:GetLocalized(c33v32, c33v33)
      c33v21[c33v29] = c33v30
      c33v30 = "AbilityDescription"
      c33v29 = c33v30 .. c33v27
      c33v32 = c33v28:GetLocalizeDescTag()
      c33v32 = c33v32:c_str()
      c33v33 = true
      c33v30 = c33v0:GetLocalized(c33v32, c33v33)
      c33v21[c33v29] = c33v30
      c33v30 = "AbilityIcon"
      c33v29 = c33v30 .. c33v27
      c33v30 = c33v28:GetIconTexture()
      c33v21[c33v29] = c33v30
      c33v30 = "AbilityType"
      c33v29 = c33v30 .. c33v27
      c33v21[c33v29] = c33v28
    else
      c33v30 = "Ability"
      c33v29 = c33v30 .. c33v27
      c33v30 = nil
      c33v21[c33v29] = c33v30
      c33v30 = "AbilityIcon"
      c33v29 = c33v30 .. c33v27
      c33v30 = nil
      c33v21[c33v29] = c33v30
    end
    c33v23 = 0
    if c33v3 then
      c33v24 = c33v2:GetUnmodifiedMaxEnergy()
      c33v27 = 100
      c33v2:SetMaxEnergy(c33v27)
      c33v23 = c33v2:GetMaxEnergy()
      c33v2:SetMaxEnergy(c33v24)
    else
      c33v23 = c33v2:GetMaxEnergy()
    end
    c33v24 = c33v23
    c33v27 = WeakResource
    c33v28 = "/Lotus/Powersuits/Priest/PriestBaseSuit"
    c33v25 = c33v2:IsA(c33v27(c33v28))
    if not c33v25 then
      c33v26 = c33v2:GetInitialEnergy()
      c33v25 = math.min
      c33v24 = c33v25(c33v26, c33v24)
    end
    c33v25 = v13
    c33v26 = nil
    c33v28 = nil
    c33v29 = true
    c33v30 = nil
    c33v25 = c33v25(c33v26, c33v23, c33v28, c33v29, c33v30, c33v24)
    c33v21.Power = c33v25
    c33v25 = c33v21.Power
    c33v27 = { TEXT = "/Lotus/Language/Stats/TIP_PowerStartingEnergy", VARS = nil, skipIndicatorComparison = true }
    c33v28 = { AMOUNT = nil }
    c33v28.AMOUNT = c33v24
    c33v27.VARS = c33v28
    c33v26 = {c33v27}
    c33v25.SecondaryToolTips = c33v26
    c33v25 = IsNull
    c33v25 = c33v25(c33v17)
    if not c33v25 then
      c33v27 = c33v2:GetEnergyRegenSpeed()
      c33v28 = 106
      c33v25 = c33v17:GetUpgradeModifiedValue(c33v27, c33v28)
      c33v27 = c33v21.Power
      c33v27 = c33v27.SecondaryToolTips
      c33v28 = { TEXT = "/Lotus/Language/Stats/TIP_PowerRecovery", VARS = nil }
      c33v29 = { AMOUNT = nil }
      c33v29.AMOUNT = c33v25
      c33v28.VARS = c33v29
      c33v26 = table.insert
      c33v26(c33v27, c33v28)
    end
    if not c33v3 then
      c33v27 = "/Lotus/Language/Menu/MenuOperator"
      c33v28 = false
      c33v25 = c33v0:GetLocalized(c33v27, c33v28)
      c33v4.mName = c33v25
      c33v25 = {}
      c33v26 = nil
      c33v27 = nil
      c33v28 = IsNull
      c33v28 = c33v28(c33v17)
      if not c33v28 then
        c33v31 = 0
        c33v32 = 12
        c33v29 = c33v17:GetUpgradeModifiedValue(c33v31, c33v32)
        c33v28 = c33v29 / 50000
        c33v26 = c33v28 * 100
        c33v31 = c33v2:Name__dee00179()
        c33v32 = 11
        c33v29 = c33v17:GetUpgradeModifiedValue(c33v31, c33v32)
        c33v31 = c33v28 / c33v29
        c33v30 = 1 - c33v31
        c33v27 = c33v30 * 100
      end
      if c33v26 ~= nil then
        c33v28 = v13
        c33v29 = v11
        c33v29 = c33v29(c33v26)
        c33v28 = c33v28(c33v29, c33v26)
        c33v25.UltInitCharge = c33v28
        if c33v27 ~= nil then
          c33v28 = c33v25.UltInitCharge
          c33v29 = {}
          c33v28.SecondaryToolTips = c33v29
          c33v29 = c33v25.UltInitCharge
          c33v29 = c33v29.SecondaryToolTips
          c33v30 = { TEXT = "/Lotus/Language/Stats/TIP_UltChargeRate", VARS = nil, ShowAsPercent = true }
          c33v31 = { AMOUNT = nil }
          c33v31.AMOUNT = c33v27
          c33v30.VARS = c33v31
          c33v28 = table.insert
          c33v28(c33v29, c33v30)
        end
      end
      c33v28 = nil
      c33v29 = _T.UltimateUpgradeInfo
      if c33v29 ~= nil then
        c33v29 = _T.UltimateUpgradeInfo.Ability
        if c33v29 ~= nil then
          c33v29 = Resource
          c33v30 = _T.UltimateUpgradeInfo.Ability
          c33v29 = c33v29(c33v30)
          c33v28 = c33v29:GetScript()
        end
      end
      c33v29 = IsNull
      c33v29 = c33v29(c33v28)
      if not c33v29 then
        c33v32 = Symbol
        c33v33 = "GetDuration"
        c33v32 = c33v32(c33v33)
        c33v33 = true
        c33v1:RunScript(c33v28, c33v32, c33v33)
        c33v29 = _T.UltimateUpgradeInfo.Duration
        if c33v29 ~= nil then
          c33v29 = _T.UltimateUpgradeInfo.Duration
          c33v30 = v13
          c33v31 = v10
          c33v31 = c33v31(c33v29)
          c33v30 = c33v30(c33v31, c33v29)
          c33v25.UltDuration = c33v30
          c33v30 = _T.UltimateUpgradeInfo
          c33v31 = nil
          c33v30.Duration = c33v31
        end
      end
      c33v29 = { mName = nil, mIsMelee = false, mBehaviorIndex = 0, mStats = nil }
      c33v30 = string.upper
      c33v33 = "/Lotus/Language/OldPeace/Antique"
      c33v34 = false
      c33v30 = c33v30(c33v0:GetLocalized(c33v33, c33v34))
      c33v29.mName = c33v30
      c33v29.mStats = c33v25
      c33v20 = c33v29
    end
    c33v27 = 1
    c33v25 = 4
    c33v26 = 1
    for c33v27 = c33v27, c33v25, c33v26 do
    end
    c33v24 = 0
    c33v25 = 2
    c33v26 = 1
    c33v27 = 3
    c33v28 = 4
    c33v29 = 5
    c33v30 = 6
    c33v31 = 7
    c33v32 = 8
    c33v33 = 14
    c33v23 = {c33v24, c33v25, c33v26, c33v27, c33v28, c33v29, c33v30, c33v31, c33v32, c33v33}
    c33v24 = c33v21.Armor
    c33v25 = {}
    c33v24.SecondaryToolTips = c33v25
    c33v26 = 1
    c33v24 = #c33v23
    c33v25 = 1
    for c33v26 = c33v26, c33v24, c33v25 do
      c33v27 = c33v23[c33v26]
      c33v30 = 100
      c33v31 = 42
      c33v32 = c33v2:GetType()
      c33v28 = c33v17:GetUpgradeModifiedValue(c33v30, c33v31, c33v32, c33v2, c33v27)
      if c33v28 ~= 100 then
        c33v28 = 100 - c33v28
        c33v32 = v0
        c33v32 = c33v32.FormatNumber
        c33v34 = 1
        c33v35 = false
        c33v30 = c33v32(c33v28, c33v34, c33v35)
        c33v31 = "%"
        c33v29 = c33v30 .. c33v31
        c33v31 = c33v21.Armor
        c33v31 = c33v31.SecondaryToolTips
        c33v32 = { TEXT = nil, VARS = nil }
        c33v34 = "/Lotus/Language/Stats/TIP_"
        c33v37 = v1
        c33v37 = c33v37.GetDamageTypeTag
        c33v35 = c33v37(c33v27)
        c33v36 = "_RESIST"
        c33v33 = c33v34 .. c33v35 .. c33v36
        c33v32.TEXT = c33v33
        c33v33 = { AMOUNT = nil }
        c33v33.AMOUNT = c33v28
        c33v32.VARS = c33v33
        c33v30 = table.insert
        c33v30(c33v31, c33v32)
      end
    end
    c33v5 = IsNull
    c33v5 = c33v5(c33v2)
    if c33v5 then
      do return end
    end
    c33v5 = {}
    c33v6 = 0
    c33v7 = 0
    c33v8 = 0
    c33v11 = WeakResource
    c33v12 = "/Lotus/Powersuits/Operator/AdultOperatorSuit"
    c33v9 = c33v2:IsA(c33v11(c33v12))
    if not c33v9 then
      c33v11 = WeakResource
      c33v12 = "/Lotus/Powersuits/Operator/OperatorSuit"
      c33v9 = c33v2:IsA(c33v11(c33v12))
    end
    c33v12 = gFlightJetPackItemType
    c33v10 = c33v2:IsA(c33v12)
    if c33v10 then
      c33v10 = c33v2:IsModular()
    end
    c33v11 = false
    if c33v10 then
      c33v12 = IsNull
      c33v12 = c33v12(c33v1)
      if c33v12 then
        c33v1 = c33v2:GetOwner()
        c33v11 = true
      end
    end
    c33v12 = nil
    c33v13 = nil
    c33v14 = nil
    c33v15 = nil
    c33v16 = nil
    c33v17 = IsNull
    c33v17 = c33v17(c33v1)
    if not c33v5 then
      c33v18 = _T.MenuSuitAvatar
      c33v17 = IsNull
      c33v17 = c33v17(c33v18)
      if not c33v17 then
        c33v17 = _T.MenuSuitAvatar
        c33v12 = c33v17:DamageControl()
      end
      c33v17 = Resource
      c33v18 = "/Lotus/Types/Player/TennoMainMenuDamageController"
      c33v17 = c33v17(c33v18)
      c33v18 = c33v2:Name__1a6427eb()
      c33v19 = 0
      if c33v19 < c33v18 then
        c33v8 = c33v2:Name__1a6427eb()
      else
        c33v19 = _T.CachedTennoAvatar
        c33v18 = IsNull
        c33v18 = c33v18(c33v19)
        if not c33v18 then
          c33v18 = _T.CachedTennoAvatar
          c33v8 = c33v18:GetMaxHealth()
        end
      end
      c33v18 = v0
      c33v18 = c33v18.Ternary
      c33v20 = c33v2:Name__3bba4acd()
      c33v21 = 0
      if c33v20 < c33v21 then
        c33v19 = false
      else
        c33v19 = true
      end
      c33v20 = c33v2:Name__3bba4acd()
      c33v6 = c33v18(c33v19, c33v20, c33v17:GetMaxShield())
      c33v18 = v0
      c33v18 = c33v18.Ternary
      c33v20 = c33v2:Name__ff0a0d5c()
      c33v21 = 0
      if c33v20 <= c33v21 then
        c33v19 = false
      else
        c33v19 = true
      end
      c33v20 = c33v2:Name__ff0a0d5c()
      c33v7 = c33v18(c33v19, c33v20, c33v17:GetArmourRating())
      c33v20 = true
      c33v13 = c33v17:GetShieldGateTimer(c33v20)
      c33v18 = 100
      c33v19 = c33v17:GetArmourResistance()
      c33v14 = c33v18 * c33v19
      if c33v3 then
        c33v18 = v6
        c33v8 = c33v18:Name__952c73e1(c33v8)
        c33v18 = v6
        c33v6 = c33v18:Name__f1628429(c33v6)
        c33v18 = v6
        c33v7 = c33v18:ModifyArmor(c33v7)
      end
    else
      c33v12 = c33v1:DamageControl()
      if c33v3 then
        c33v2:RemoveLevelUpgrades(c33v1)
      end
      c33v18 = c33v1:GetMaxHealth()
      c33v17 = math.floor
      c33v8 = c33v17(c33v18)
      c33v18 = c33v12:GetMaxShield()
      c33v17 = math.floor
      c33v6 = c33v17(c33v18)
      c33v18 = c33v12:GetArmourRating()
      c33v17 = math.floor
      c33v7 = c33v17(c33v18)
      c33v17 = c33v12:GetShield()
      c33v12:SetShield(c33v6)
      c33v20 = true
      c33v13 = c33v12:GetShieldGateTimer(c33v20)
      c33v12:SetShield(c33v17)
      c33v18 = 100
      c33v19 = c33v12:GetArmourResistance()
      c33v14 = c33v18 * c33v19
      c33v15 = c33v12:GetShieldRechargeRate()
      c33v16 = c33v12:GetShieldRechargeDelay()
    end
    c33v17 = IsNull
    c33v17 = c33v17(c33v4)
    if c33v17 then
      c33v17 = { mName = "", mStats = nil, mIsMelee = false }
      c33v18 = {}
      c33v17.mStats = c33v18
      c33v4 = c33v17
    end
    c33v17 = nil
    c33v18 = false
    c33v19 = IsNull
    c33v19 = c33v19(c33v1)
    if not c33v19 then
      c33v17 = c33v1:InventoryControl()
      if not c33v3 then
        c33v19 = v0
        c33v19 = c33v19.Ternary
        c33v21 = c33v17:IsSpaceMode()
        c33v20 = c33v21 or c33v11
        c33v21 = c33v17:Name__d22c79ce()
        c33v2 = c33v19(c33v20, c33v21, c33v17:GetActivePowerSuit())
        c33v18 = true
      end
    end
    c33v19 = nil
    c33v20 = nil
    c33v21 = c33v4.mStats
    c33v22 = v13
    c33v23 = nil
    c33v25 = nil
    c33v26 = true
    c33v22 = c33v22(c33v23, c33v8, c33v25, c33v26)
    c33v21.Health = c33v22
    c33v22 = nil
    c33v23 = IsNull
    c33v23 = c33v23(c33v17)
    if not c33v23 then
      c33v25 = 1
      c33v26 = 140
      c33v27 = c33v2:GetType()
      c33v23 = c33v17:GetUpgradeModifiedValue(c33v25, c33v26, c33v27, c33v2)
      if c33v23 == 0 then
        c33v28 = "<LOCKED> "
        c33v29 = true
        c33v24 = c33v0:GetLocalized(c33v28, c33v29)
        c33v25 = "0"
        c33v22 = c33v24 .. c33v25
      end
    end
    c33v23 = v13
    c33v26 = nil
    c33v27 = true
    c33v23 = c33v23(c33v22, c33v6, c33v26, c33v27)
    c33v21.Shield = c33v23
    c33v23 = c33v21.Shield
    c33v25 = { TEXT = "/Lotus/Language/Stats/TIP_ShieldGate", VARS = nil }
    c33v26 = { AMOUNT = nil }
    c33v26.AMOUNT = c33v13
    c33v25.VARS = c33v26
    c33v24 = {c33v25}
    c33v23.SecondaryToolTips = c33v24
    if c33v16 then
      c33v24 = c33v21.Shield
      c33v24 = c33v24.SecondaryToolTips
      c33v25 = { TEXT = "/Lotus/Language/Stats/TIP_PowersuitShieldRechargeDelay", VARS = nil, comparisonFlipped = true }
      c33v26 = { AMOUNT = nil }
      c33v26.AMOUNT = c33v16
      c33v25.VARS = c33v26
      c33v23 = table.insert
      c33v23(c33v24, c33v25)
    end
    if c33v15 then
      c33v24 = c33v21.Shield
      c33v24 = c33v24.SecondaryToolTips
      c33v25 = { TEXT = "/Lotus/Language/Stats/TIP_PowersuitShieldRechargeRate", VARS = nil }
      c33v26 = { AMOUNT = nil }
      c33v26.AMOUNT = c33v15
      c33v25.VARS = c33v26
      c33v23 = table.insert
      c33v23(c33v24, c33v25)
    end
    c33v23 = v13
    c33v24 = nil
    c33v26 = nil
    c33v27 = true
    c33v28 = nil
    c33v23 = c33v23(c33v24, c33v7, c33v26, c33v27, c33v28, c33v14)
    c33v21.Armor = c33v23
    c33v23 = IsNull
    c33v23 = c33v23(c33v17)
    c33v23 = IsNull
    c33v23 = c33v23(c33v2)
    if c33v23 then
      c33v25 = c33v2:GetMovementSpeedMultiplier()
      c33v26 = IsNull
      c33v26 = c33v26(c33v17)
      if not c33v26 then
        if c33v3 then
          c33v28 = 1
          c33v29 = 167
          c33v26 = c33v17:GetUpgradeModifiedValue(c33v28, c33v29)
          c33v27 = v13
          c33v28 = v0
          c33v28 = c33v28.FormatNumber
          c33v30 = 2
          c33v31 = false
          c33v28 = c33v28(c33v26, c33v30, c33v31)
          c33v30 = nil
          c33v31 = true
          c33v27 = c33v27(c33v28, c33v26, c33v30, c33v31)
          c33v21.ParkourBoost = c33v27
        end
        c33v28 = 152
        c33v29 = 2
        c33v17:AddUpgrade(c33v28, c33v29, c33v25)
        c33v26 = 1
        c33v27 = c33v17:IsSpaceMode()
        if c33v27 then
          c33v29 = 1
          c33v30 = 152
          c33v31 = c33v2:GetType()
          c33v33 = 25
          c33v34 = Symbol
          c33v35 = "ARCHWING_SPRINT_SPEED"
          c33v26 = c33v17:GetUpgradeModifiedValue(c33v29, c33v30, c33v31, c33v2, c33v33, c33v34(c33v35))
        else
          c33v29 = 1
          c33v30 = 152
          c33v26 = c33v17:GetUpgradeModifiedValue(c33v29, c33v30)
        end
        c33v29 = 152
        c33v30 = 2
        c33v17:RemoveUpgrade(c33v29, c33v30, c33v25)
        c33v27 = v13
        c33v28 = v0
        c33v28 = c33v28.FormatNumber
        c33v30 = 2
        c33v31 = false
        c33v28 = c33v28(c33v26, c33v30, c33v31)
        c33v30 = nil
        c33v31 = true
        c33v27 = c33v27(c33v28, c33v26, c33v30, c33v31)
        c33v21.Mult_SprintSpeed = c33v27
        c33v27 = {}
        c33v30 = 1
        c33v31 = 10
        c33v32 = c33v2:GetType()
        c33v28 = c33v17:GetUpgradeModifiedValue(c33v30, c33v31, c33v32, c33v2)
        c33v29 = v13
        c33v33 = v0
        c33v33 = c33v33.FormatNumber
        c33v34 = c33v28 * 100
        c33v35 = 0
        c33v36 = false
        c33v31 = c33v33(c33v34, c33v35, c33v36)
        c33v32 = "%"
        c33v30 = c33v31 .. c33v32
        c33v32 = nil
        c33v33 = true
        c33v29 = c33v29(c33v30, c33v28, c33v32, c33v33)
        c33v27.Power_Strength = c33v29
        c33v31 = 1
        c33v32 = 3
        c33v33 = c33v2:GetType()
        c33v29 = c33v17:GetUpgradeModifiedValue(c33v31, c33v32, c33v33, c33v2)
        c33v30 = v13
        c33v34 = v0
        c33v34 = c33v34.FormatNumber
        c33v35 = c33v29 * 100
        c33v36 = 0
        c33v37 = false
        c33v32 = c33v34(c33v35, c33v36, c33v37)
        c33v33 = "%"
        c33v31 = c33v32 .. c33v33
        c33v33 = nil
        c33v34 = true
        c33v30 = c33v30(c33v31, c33v29, c33v33, c33v34)
        c33v27.Power_Duration = c33v30
        c33v30 = "/Lotus/Language/Labels/AVATAR_ABILITY"
        c33v33 = WeakResource
        c33v34 = "/Lotus/Powersuits/IronFrame/IronFrameBaseSuit"
        c33v31 = c33v2:IsA(c33v33(c33v34))
        if c33v31 then
          c33v30 = "/Lotus/Language/Labels/AVATAR_SHIELD"
        else
          c33v33 = WeakResource
          c33v34 = "/Lotus/Powersuits/Garuda/GarudaBaseSuit"
          c33v31 = c33v2:IsA(c33v33(c33v34))
          if c33v31 then
            c33v30 = "/Lotus/Language/Labels/AVATAR_HEALTH_MAX"
          end
        end
        c33v31 = {}
        c33v34 = v5
        c33v34 = c33v34.AI_EFFICIENCY_SYM
        c33v32 = c33v17:Name__158ab814(c33v34)
        if c33v32 then
          c33v34 = { Type = nil, Tag = nil, Value = nil }
          c33v35 = 4
          c33v34.Type = c33v35
          c33v35 = v5
          c33v35 = c33v35.AI_EFFICIENCY_SYM
          c33v34.Tag = c33v35
          c33v37 = v5
          c33v37 = c33v37.AI_EFFICIENCY_SYM
          c33v35 = c33v17:Name__e470b32b(c33v37)
          c33v34.Value = c33v35
          c33v32 = table.insert
          c33v32(c33v31, c33v34)
          c33v34 = v5
          c33v34 = c33v34.AI_EFFICIENCY_SYM
          c33v17:Name__6e278845(c33v34)
        end
        c33v34 = v5
        c33v34 = c33v34.AI_EFFICIENCY_MIN_SYM
        c33v32 = c33v17:Name__158ab814(c33v34)
        if c33v32 then
          c33v34 = { Type = nil, Tag = nil, Value = nil }
          c33v35 = 5
          c33v34.Type = c33v35
          c33v35 = v5
          c33v35 = c33v35.AI_EFFICIENCY_MIN_SYM
          c33v34.Tag = c33v35
          c33v37 = v5
          c33v37 = c33v37.AI_EFFICIENCY_MIN_SYM
          c33v35 = c33v17:Name__e470b32b(c33v37)
          c33v34.Value = c33v35
          c33v32 = table.insert
          c33v32(c33v31, c33v34)
          c33v34 = v5
          c33v34 = c33v34.AI_EFFICIENCY_MIN_SYM
          c33v17:Name__6e278845(c33v34)
        end
        c33v35 = 1
        c33v33 = c33v2:Name__9d3a8775(c33v35)
        c33v32 = c33v33 * 100
        c33v33 = 200 - c33v32
        c33v34 = v13
        c33v38 = v0
        c33v38 = c33v38.FormatNumber
        c33v40 = 0
        c33v41 = false
        c33v36 = c33v38(c33v33, c33v40, c33v41)
        c33v37 = "%"
        c33v35 = c33v36 .. c33v37
        c33v37 = nil
        c33v38 = true
        c33v39 = nil
        c33v40 = nil
        c33v41 = TitleCase
        c33v45 = false
        c33v34 = c33v34(c33v35, c33v33, c33v37, c33v38, c33v39, c33v40, c33v41(c33v0:GetLocalized(c33v30, c33v45)))
        c33v27.Power_Efficiency = c33v34
        c33v37 = 1
        c33v35 = c33v2:Name__95d14356(c33v37)
        c33v34 = c33v35 * 100
        c33v35 = c33v27.Power_Efficiency
        c33v37 = { TEXT = "/Lotus/Language/Stats/TIP_Power_Efficiency_Cost", VARS = nil, comparisonFlipped = true }
        c33v38 = { AMOUNT = nil }
        c33v38.AMOUNT = c33v32
        c33v37.VARS = c33v38
        c33v38 = { TEXT = "/Lotus/Language/Stats/TIP_Power_Efficiency_TotalCost", VARS = nil, comparisonFlipped = true }
        c33v39 = { AMOUNT = nil }
        c33v39.AMOUNT = c33v34
        c33v38.VARS = c33v39
        c33v36 = {c33v37, c33v38}
        c33v35.SecondaryToolTips = c33v36
        c33v35 = pairs
        c33v35, c33v36, c33v37 = c33v35(c33v31)
        for c33v38, c33v39 in c33v35, c33v36, c33v37 do
          c33v42 = c33v39.Tag
          c33v43 = c33v39.Type
          c33v44 = 4
          c33v45 = c33v39.Value
          c33v17:Name__90fde101(c33v42, c33v43, c33v44, c33v45)
        end
        c33v37 = 1
        c33v38 = 9
        c33v39 = c33v2:GetType()
        c33v35 = c33v17:GetUpgradeModifiedValue(c33v37, c33v38, c33v39, c33v2)
        c33v36 = v13
        c33v40 = v0
        c33v40 = c33v40.FormatNumber
        c33v41 = c33v35 * 100
        c33v42 = 0
        c33v43 = false
        c33v38 = c33v40(c33v41, c33v42, c33v43)
        c33v39 = "%"
        c33v37 = c33v38 .. c33v39
        c33v39 = nil
        c33v40 = true
        c33v36 = c33v36(c33v37, c33v35, c33v39, c33v40)
        c33v27.Power_Range = c33v36
        c33v36 = v13
        c33v40 = v0
        c33v40 = c33v40.FormatNumber
        c33v41 = c33v29 * 100
        c33v42 = 0
        c33v43 = false
        c33v38 = c33v40(c33v41, c33v42, c33v43)
        c33v39 = "%"
        c33v37 = c33v38 .. c33v39
        c33v39 = nil
        c33v40 = true
        c33v36 = c33v36(c33v37, c33v29, c33v39, c33v40)
        c33v27.Status_Duration_Lavos = c33v36
        c33v36 = v13
        c33v40 = v0
        c33v40 = c33v40.FormatNumber
        c33v42 = 0
        c33v43 = false
        c33v38 = c33v40(c33v33, c33v42, c33v43)
        c33v39 = "%"
        c33v37 = c33v38 .. c33v39
        c33v39 = nil
        c33v40 = true
        c33v36 = c33v36(c33v37, c33v33, c33v39, c33v40)
        c33v27.Power_Efficiency_Lavos = c33v36
        c33v36 = { mName = nil, mIsMelee = false, mBehaviorIndex = 0, mStats = nil }
        c33v37 = string.upper
        c33v40 = "/Lotus/Language/Actions/AbilityXP"
        c33v41 = false
        c33v37 = c33v37(c33v0:GetLocalized(c33v40, c33v41))
        c33v36.mName = c33v37
        c33v36.mStats = c33v27
        c33v19 = c33v36
        for c33v38, c33v39 in c33v35, c33v36, c33v37 do
        end
      else
        c33v26 = v13
        c33v27 = v0
        c33v27 = c33v27.FormatNumber
        c33v29 = 2
        c33v30 = false
        c33v27 = c33v27(c33v25, c33v29, c33v30)
        c33v29 = nil
        c33v30 = true
        c33v26 = c33v26(c33v27, c33v25, c33v29, c33v30)
        c33v21.Mult_SprintSpeed = c33v26
      end
    else
      c33v23 = IsNull
      c33v23 = c33v23(c33v2)
      if not c33v23 then
        c33v25 = gSentinelPowerSuitType
        c33v23 = c33v2:IsA(c33v25)
        if c33v23 then
          c33v23 = IsNull
          c33v23 = c33v23(c33v1)
          if not c33v23 then
            c33v23 = c33v1:GetSelfRespawnTime()
            c33v24 = v13
            c33v25 = nil
            c33v27 = nil
            c33v28 = true
            c33v29 = nil
            c33v30 = nil
            c33v31 = nil
            c33v32 = nil
            c33v33 = nil
            c33v34 = nil
            c33v35 = nil
            c33v36 = true
            c33v24 = c33v24(c33v25, c33v23, c33v27, c33v28, c33v29, c33v30, c33v31, c33v32, c33v33, c33v34, c33v35, c33v36)
            c33v21.Self_Respawn_Time = c33v24
          end
        end
      end
    end
    c33v23 = table.insert
    c33v23(c33v5, c33v4)
    if c33v19 ~= nil then
      c33v23 = table.insert
      c33v23(c33v5, c33v19)
    end
    if c33v20 ~= nil then
      c33v25 = 1
      c33v23 = table.insert
      c33v23(c33v5, c33v25, c33v20)
    end
    do return c33v5 end
  end
  v11 = function(c34v0)
    local c34v1, c34v2, c34v3, c34v4, c34v6, c34v7
    c34v1 = Localize
    c34v2 = "/Lotus/Language/Game/PurifyPercent"
    c34v3 = { PERCENT = nil }
    c34v4 = v0
    c34v4 = c34v4.FormatNumber
    c34v6 = 1
    c34v7 = false
    c34v4 = c34v4(c34v0, c34v6, c34v7)
    c34v3.PERCENT = c34v4
    do return c34v1(c34v2, c34v3) end
  end
  v10 = function(c35v0, c35v1)
    local c35v2, c35v3, c35v4, c35v5, c35v8
    c35v2 = Localize
    c35v3 = "/Lotus/Language/Game/UNIT_SECOND"
    c35v4 = { COUNT = nil }
    c35v5 = v0
    c35v5 = c35v5.FormatNumber
    c35v8 = false
    c35v5 = c35v5(c35v0, c35v1, c35v8)
    c35v4.COUNT = c35v5
    do return c35v2(c35v3, c35v4) end
  end
  v20 = function(c36v0, c36v1)
    local c36v2, c36v3, c36v4, c36v5, c36v8
    c36v2 = Localize
    c36v3 = "/Lotus/Language/Game/UNIT_METER"
    c36v4 = { COUNT = nil }
    c36v5 = v0
    c36v5 = c36v5.FormatNumber
    c36v8 = false
    c36v5 = c36v5(c36v0, c36v1, c36v8)
    c36v4.COUNT = c36v5
    do return c36v2(c36v3, c36v4) end
  end
  v21 = function(c37v0)
    local c37v1, c37v2, c37v3, c37v4, c37v6, c37v7
    c37v1 = Localize
    c37v2 = "/Lotus/Language/Game/UNIT_DEGREE"
    c37v3 = { COUNT = nil }
    c37v4 = v0
    c37v4 = c37v4.FormatNumber
    c37v6 = 1
    c37v7 = false
    c37v4 = c37v4(c37v0, c37v6, c37v7)
    c37v3.COUNT = c37v4
    do return c37v1(c37v2, c37v3) end
  end
  v22 = function(c38v0)
    local c38v1, c38v2, c38v4, c38v5
    c38v1 = v13
    c38v2 = v0
    c38v2 = c38v2.FormatNumber
    c38v4 = 1
    c38v5 = false
    c38v2 = c38v2(c38v0, c38v4, c38v5)
    c38v4 = nil
    do return c38v1(c38v2, c38v0, c38v4) end
  end
  v23 = function(c39v0, c39v1, c39v2, c39v3, c39v4, c39v5)
    local c39v6, c39v7, c39v8, c39v9, c39v10, c39v11, c39v12, c39v13, c39v14
    c39v3 = c39v3 or 1
    c39v5 = c39v5 or ""
    c39v6 = v1
    c39v6 = c39v6.GetDamageTypeTag
    c39v7 = 0
    c39v8 = c39v1:GetBaseAmount()
    c39v8 = c39v8:GetModifiedValue()
    c39v11 = 0
    c39v9 = 19
    c39v10 = 1
    for c39v11 = c39v11, c39v9, c39v10 do
      c39v12 = c39v4[c39v11]
      c39v7 = c39v4[c39v11]
      c39v12 = c39v1:GetDamagePct(c39v11)
      c39v7 = c39v12 * c39v8
      c39v12 = 0
      if c39v12 < c39v7 then
        c39v14 = c39v6(c39v11)
        c39v12 = c39v5 .. c39v14
        c39v13 = v22
        c39v14 = c39v7 * c39v3
        c39v13 = c39v13(c39v14)
        c39v0[c39v12] = c39v13
      end
    end
    do return end
  end
  v24 = function(c40v0, c40v1, c40v2, c40v3, c40v4, c40v5, c40v6)
    local c40v7, c40v8, c40v9, c40v10, c40v11, c40v12, c40v13, c40v14, c40v15, c40v16, c40v17
    c40v7 = 0
    c40v8 = false
    c40v9 = c40v4 or c40v0
    c40v10 = next
    c40v10 = c40v10(c40v9)
    c40v17 = c40v10(c40v14)
    c40v15 = c40v3 .. c40v17
    c40v16 = c40v9[c40v15]
    if c40v16 then
      c40v16 = c40v9[c40v15]
      c40v16 = c40v16.StatValue
      c40v7 = c40v7 + c40v16
      c40v11 = c40v11 + 1
    end
    c40v3 = c40v3 or ""
    c40v10 = #c40v3
    c40v11 = 0
    if c40v11 < c40v10 then
      c40v10 = v24
      c40v7 = c40v10(c40v9, c40v1, c40v2)
    end
    c40v10 = v1
    c40v10 = c40v10.GetDamageTypeTag
    c40v11 = 0
    c40v14 = 0
    c40v12 = 19
    c40v13 = 1
    for c40v14 = c40v14, c40v12, c40v13 do
    end
    if not c40v10 then
      c40v12 = IsNull
      c40v12 = c40v12(c40v6)
      if not c40v12 then
        c40v12 = IsNull
        c40v12 = c40v12(c40v5)
        if not c40v12 then
          c40v14 = 0
          c40v15 = 253
          c40v16 = c40v5:GetType()
          c40v12 = c40v6:GetUpgradeModifiedValue(c40v14, c40v15, c40v16, c40v5)
          c40v13 = 0
          if c40v13 < c40v12 then
            c40v7 = c40v7 + c40v12
            c40v8 = true
          end
        end
      end
      c40v12 = 0
      if c40v12 then
        c40v12 = v22
        c40v13 = c40v7 * c40v2
        c40v12 = c40v12(c40v13)
        c40v13 = false
        c40v14 = 1
        if c40v11 <= c40v14 then
          c40v13 = false
          if c40v2 == 1 then
            c40v13 = not c40v8
          end
        end
        c40v12.Hidden = c40v13
        c40v0.Total = c40v12
      end
    end
    do return c40v7 end
  end
  v25 = function(c41v0, c41v1, c41v2, c41v3, c41v4, c41v5, c41v6, c41v7)
    local c41v8, c41v9, c41v10, c41v11, c41v12, c41v13, c41v14, c41v15, c41v16, c41v17, c41v18
    c41v3 = c41v3 or 1
    c41v4 = c41v4 or 1
    c41v6 = c41v6 or ""
    c41v8 = v1
    c41v8 = c41v8.GetDamageTypeTag
    c41v9 = 0
    c41v10 = 0
    c41v11 = 0
    c41v12 = c41v1:GetBaseAmount()
    c41v12 = c41v12:GetModifiedValue()
    c41v15 = 0
    c41v13 = 19
    c41v14 = 1
    for c41v15 = c41v15, c41v13, c41v14 do
      c41v16 = c41v1:GetDamagePct(c41v15)
      c41v17 = 0
      c41v9 = c41v1:GetDamagePct(c41v15)
      c41v16 = c41v5[c41v15]
      c41v9 = c41v5[c41v15]
      c41v16 = c41v1:GetDamagePct(c41v15)
      c41v9 = c41v16 * c41v12
      c41v16 = 0
      if c41v16 < c41v9 then
        c41v9 = c41v9 * c41v3
        c41v18 = c41v8(c41v15)
        c41v16 = c41v6 .. c41v18
        c41v17 = v22
        c41v17 = c41v17(c41v9)
        c41v0[c41v16] = c41v17
        c41v10 = c41v10 + c41v9
        c41v11 = c41v11 + 1
      end
    end
    c41v13 = 0
    if not ((c41v10 <= c41v13 or c41v7)) then
      c41v13 = v22
      c41v14 = c41v10 * c41v4
      c41v13 = c41v13(c41v14)
      c41v14 = false
      c41v15 = 1
      if c41v11 <= c41v15 then
        if c41v4 ~= 1 then
          c41v14 = false
        else
          c41v14 = true
        end
      end
      c41v13.Hidden = c41v14
      c41v0.Total = c41v13
    end
    do return end
  end
  v26 = function(c42v0, c42v1)
    local c42v2, c42v3, c42v4, c42v5, c42v6, c42v7, c42v8, c42v9
    c42v9 = c42v1.mStats
    c42v8 = c42v9[c42v5]
    c42v8 = c42v8.StatValue
    c42v7 = IsNull
    c42v7 = c42v7(c42v8)
    c42v8 = c42v1.mStats
    c42v7 = c42v8[c42v5]
    c42v7 = c42v7.StatValue
    c42v8 = c42v6.StatValue
    for c42v5, c42v6 in c42v2, c42v3, c42v4 do
      c42v2 = true
      do return c42v2 end
    end
    c42v9 = c42v1.mStats
    c42v8 = c42v9[c42v5]
    c42v7 = IsNull
    c42v7 = c42v7(c42v8)
    c42v2 = c42v0.mName
    c42v3 = c42v1.mName
    if c42v2 ~= c42v3 then
      c42v2 = false
      do return c42v2 end
    end
    c42v2 = c42v0.mBehaviorIndex
    c42v3 = c42v1.mBehaviorIndex
    if c42v2 ~= c42v3 then
      c42v2 = false
      do return c42v2 end
    end
    c42v2 = c42v0.mIsMelee
    c42v3 = c42v1.mIsMelee
    if c42v2 ~= c42v3 then
      c42v2 = false
      do return c42v2 end
    end
    c42v2 = c42v0.mExtra
    c42v3 = c42v1.mExtra
    if c42v2 ~= c42v3 then
      c42v2 = false
      do return c42v2 end
    end
    c42v3 = c42v0.mStats
    c42v2 = #c42v3
    c42v4 = c42v1.mStats
    c42v3 = #c42v4
    if c42v2 ~= c42v3 then
      c42v2 = false
      do return c42v2 end
    end
    c42v2 = pairs
    c42v3 = c42v0.mStats
    c42v2, c42v3, c42v4 = c42v2(c42v3)
    for c42v5, c42v6 in c42v2, c42v3, c42v4 do
    end
    c42v7 = false
    do return c42v7 end
  end
  v27 = function(c43v0, c43v1, c43v2, c43v3, c43v4, c43v5, c43v6, c43v7, c43v8, c43v9, c43v10, c43v11)
    local c43v12, c43v13, c43v14, c43v15, c43v16, c43v17, c43v18, c43v19, c43v20, c43v21, c43v22, c43v23, c43v24, c43v25, c43v26, c43v27, c43v28, c43v29, c43v30, c43v31, c43v32, c43v33, c43v34
    c43v12 = {}
    c43v13 = c43v1.projectileType
    c43v14 = c43v1.behaviorIndex
    c43v15 = c43v1.turboGlaive
    c43v16 = v3
    c43v16 = c43v16.GetProjectileAndDamageData
    c43v16, c43v17, c43v18 = c43v16(c43v0, c43v3, c43v13, c43v14, c43v15, c43v11)
    c43v21 = gWeaponProjectileFireBehaviorType
    c43v19 = c43v2:IsA(c43v21)
    if c43v19 then
      c43v19 = c43v2.advanceProjectileSequenceOnFire
      if c43v19 then
        c43v20 = c43v2:Name__c4f6d252()
        c43v19 = c43v20 - 1
        c43v20 = 0
        if c43v20 < c43v19 then
          c43v22 = 1
          c43v20 = c43v19
          c43v21 = 1
          for c43v22 = c43v22, c43v20, c43v21 do
            c43v2:SetProjectileIndex(c43v22)
            c43v23 = v3
            c43v23 = c43v23.GetProjectileAndDamageData
            c43v23, c43v24, c43v25 = c43v23(c43v0, c43v3, c43v13, c43v14, c43v15, c43v11)
            c43v28 = { DmgData = nil, RadialData = nil }
            c43v28.DmgData = c43v24
            c43v28.RadialData = c43v25
            c43v26 = table.insert
            c43v26(c43v12, c43v28)
          end
          c43v22 = 0
          c43v2:SetProjectileIndex(c43v22)
        end
      end
    end
    c43v19 = #c43v12
    c43v20 = {}
    if not c43v19 then
      local p39 = 7
      if p39 == 7 then
        c43v21 = v23
        c43v21(c43v20, c43v17, c43v4, c43v6, c43v7)
        c43v21 = c43v0:GetEmbedDamage(c43v16)
        c43v22 = c43v21:GetBaseAmount()
        c43v22 = c43v22:GetModifiedValue()
        c43v23 = next
        c43v23 = c43v23(c43v20)
        if c43v23 then
          p39 = 9
        else
          p39 = 8
        end
      end
      if p39 == 8 then
        c43v23 = 0
        if c43v22 <= c43v23 then
        else
          p39 = 9
        end
      end
      if p39 == 9 then
        c43v23 = c43v10
        c43v24 = 0
        if c43v19 <= c43v24 then
          p39 = 13
        else
          p39 = 10
        end
      end
      if p39 == 10 then
        if not c43v11 then
          p39 = 12
        else
          p39 = 11
        end
      end
      if p39 == 11 then
        c43v20 = {}
        p39 = 13
      end
      if p39 == 12 then
        c43v24 = Localize
        c43v25 = "/Lotus/Language/Stats/Attack1"
        c43v26 = {}
        c43v23 = c43v24(c43v25, c43v26)
        p39 = 13
      end
      if p39 == 13 then
        c43v24 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
        c43v25 = string.upper
        c43v25 = c43v25(c43v23)
        c43v24.mName = c43v25
        c43v25 = c43v1.behaviorIndex
        c43v24.mBehaviorIndex = c43v25
        c43v24.mStats = c43v20
        c43v25 = table.insert
        c43v25(c43v8, c43v24)
        c43v25 = 0
        if (c43v19 <= c43v25 or not c43v11) then
        else
          p39 = 15
        end
      end
      if p39 == 15 then
        c43v25 = {}
        c43v26 = v25
        c43v33 = nil
        c43v34 = true
        c43v26(c43v25, c43v17, c43v4, c43v6, c43v5, c43v7, c43v33, c43v34)
        c43v26 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
        c43v27 = string.upper
        c43v28 = Localize
        c43v29 = "/Lotus/Language/Stats/Attack1"
        c43v30 = {}
        c43v27 = c43v27(c43v28(c43v29, c43v30))
        c43v26.mName = c43v27
        c43v27 = c43v1.behaviorIndex
        c43v26.mBehaviorIndex = c43v27
        c43v26.mStats = c43v25
        c43v24 = c43v26
        c43v26 = table.insert
        c43v26(c43v8, c43v24)
        if not c43v18 then
        else
          p39 = 16
        end
      end
      if p39 == 16 then
        c43v26 = {}
        c43v27 = v23
        c43v33 = nil
        c43v27(c43v26, c43v18, c43v4, c43v6, c43v7, c43v33)
        c43v27 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
        c43v28 = string.upper
        c43v29 = Localize
        c43v30 = "/Lotus/Language/Labels/AVATAR_RADIAL_ATTACK"
        c43v31 = {}
        c43v28 = c43v28(c43v29(c43v30, c43v31))
        c43v27.mName = c43v28
        c43v28 = c43v1.behaviorIndex
        c43v27.mBehaviorIndex = c43v28
        c43v27.mStats = c43v26
        c43v28 = table.insert
        c43v28(c43v8, c43v27)
      end
    end
    c43v23 = 1
    c43v21 = c43v19
    c43v22 = 1
    for c43v23 = c43v23, c43v21, c43v22 do
      c43v24 = c43v12[c43v23]
      c43v24 = c43v24.DmgData
      c43v25 = c43v24:GetBaseAmount()
      c43v25 = c43v25:GetModifiedValue()
      c43v26 = 0
      if c43v26 < c43v25 then
        c43v25 = {}
        c43v26 = v25
        c43v33 = nil
        c43v26(c43v25, c43v24, c43v4, c43v6, c43v5, c43v7, c43v33, c43v11)
        c43v26 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
        c43v27 = string.upper
        c43v28 = Localize
        c43v30 = "/Lotus/Language/Stats/Attack"
        c43v31 = c43v23 + 1
        c43v29 = c43v30 .. c43v31
        c43v30 = {}
        c43v27 = c43v27(c43v28(c43v29, c43v30))
        c43v26.mName = c43v27
        c43v27 = c43v1.behaviorIndex
        c43v26.mBehaviorIndex = c43v27
        c43v26.mStats = c43v25
        c43v27 = table.insert
        c43v27(c43v8, c43v26)
        if c43v11 then
          c43v27 = c43v12[c43v23]
          c43v27 = c43v27.RadialData
          if c43v27 then
            c43v27 = {}
            c43v28 = v23
            c43v30 = c43v12[c43v23]
            c43v30 = c43v30.RadialData
            c43v34 = nil
            c43v28(c43v27, c43v30, c43v4, c43v6, c43v7, c43v34)
            c43v28 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
            c43v29 = string.upper
            c43v30 = Localize
            c43v31 = "/Lotus/Language/Labels/AVATAR_RADIAL_ATTACK"
            c43v32 = {}
            c43v29 = c43v29(c43v30(c43v31, c43v32))
            c43v28.mName = c43v29
            c43v29 = c43v1.behaviorIndex
            c43v28.mBehaviorIndex = c43v29
            c43v28.mStats = c43v27
            c43v29 = table.insert
            c43v29(c43v8, c43v28)
          end
        end
      end
    end
    do return c43v16, c43v17, c43v20 end
  end
  v28 = function(c44v0, c44v1)
    do return end
  end
  v29 = function(c45v0, c45v1)
    local c45v2, c45v3, c45v4, c45v9, c45v10
    c45v2 = ipairs
    c45v2, c45v3, c45v4 = c45v2(c45v1)
    for c45v5, c45v6 in c45v2, c45v3, c45v4 do
      c45v9 = c45v6:GetUpgradeType()
      c45v10 = c45v6:GetOperationType()
      c45v0:AddUpgrade(c45v9, c45v10, c45v6:GetValue())
    end
    do return end
  end
  v30 = function(c46v0, c46v1)
    local c46v2, c46v3, c46v4, c46v9, c46v10
    c46v2 = ipairs
    c46v2, c46v3, c46v4 = c46v2(c46v1)
    for c46v5, c46v6 in c46v2, c46v3, c46v4 do
      c46v9 = c46v6:GetUpgradeType()
      c46v10 = c46v6:GetOperationType()
      c46v0:RemoveUpgrade(c46v9, c46v10, c46v6:GetValue())
    end
    do return end
  end
  v31 = function(c47v0, c47v1, c47v2, c47v3)
    local c47v4, c47v5, c47v6, c47v9, c47v10, c47v11, c47v12, c47v13, c47v14, c47v15, c47v16
    c47v4 = ipairs
    c47v4, c47v5, c47v6 = c47v4(c47v1)
    for c47v7, c47v8 in c47v4, c47v5, c47v6 do
      c47v9 = c47v8:GetUpgradeType()
      c47v10 = 264
      if c47v9 == c47v10 then
        c47v10 = c47v8:GetDamageType()
        c47v11 = v1
        c47v11 = c47v11.GetDamageTypeTag
        c47v12 = c47v11(c47v10)
        c47v14 = 1
        c47v13 = c47v11(c47v14)
        c47v15 = 2
        c47v14 = c47v11(c47v15)
        c47v16 = 0
        c47v15 = c47v11(c47v16)
        c47v16 = c47v3[c47v13]
        if c47v16 then
          c47v16 = c47v3[c47v13]
          c47v3[c47v12] = c47v16
          c47v16 = nil
          c47v3[c47v13] = c47v16
        end
        c47v16 = c47v3[c47v14]
        if c47v16 then
          c47v16 = c47v3[c47v14]
          c47v3[c47v12] = c47v16
          c47v16 = nil
          c47v3[c47v14] = c47v16
        end
        c47v16 = c47v3[c47v15]
        if c47v16 then
          c47v16 = c47v3[c47v15]
          c47v3[c47v12] = c47v16
          c47v16 = nil
          c47v3[c47v15] = c47v16
        end
      end
    end
    do return end
  end
  v32 = function(c48v0, c48v1)
    local c48v2, c48v3, c48v4, c48v5, c48v6
    c48v4 = 1
    c48v2 = #c48v1
    c48v3 = 1
    for c48v4 = c48v4, c48v2, c48v3 do
      c48v5 = c48v1[c48v4]
      c48v6 = nil
      c48v0[c48v5] = c48v6
    end
    do return end
  end
  v33 = function(c49v0, c49v1)
    local c49v2, c49v3, c49v4, c49v5, c49v6, c49v7, c49v8
    c49v6 = 0
    c49v4 = 19
    c49v5 = 1
    for c49v6 = c49v6, c49v4, c49v5 do
      c49v7 = c49v0:GetDamagePct(c49v6)
      c49v8 = 0
      if c49v8 < c49v7 then
        c49v7 = c49v0:GetDamagePct(c49v6)
        c49v8 = c49v7 * c49v3
        c49v2 = c49v2 + c49v8
      end
    end
    c49v2 = 0
    c49v3 = c49v0:GetBaseAmount()
    c49v3 = c49v3:GetModifiedValue()
    if c49v1 then
      c49v4 = 0
      if c49v4 < c49v1 then
        c49v3 = c49v3 * c49v1
      end
    end
    c49v4 = 0
    do return c49v2 end
  end
  v34 = function(c50v0, c50v1, c50v2, c50v3, c50v4, c50v5, c50v6, c50v7, c50v8, c50v9, c50v10, c50v11, c50v12, c50v13)
    local c50v14, c50v15, c50v16, c50v17, c50v18, c50v19, c50v20, c50v21, c50v22, c50v23, c50v26
    c50v14 = v3
    c50v14 = c50v14.GetCritStats
    c50v23 = c50v5.turboGlaive
    c50v14, c50v15 = c50v14(c50v2, c50v11, c50v4, c50v10, c50v8, c50v7, c50v3, c50v9, c50v23)
    c50v17 = _T.Stats_CritChanceOverride
    c50v16 = IsNull
    c50v16 = c50v16(c50v17)
    if not c50v16 then
      c50v18 = _T.Stats_CritChanceOverride
      c50v19 = c50v2:GetType()
      c50v19 = c50v19:GetFullName()
      c50v17 = c50v18[c50v19]
      c50v16 = IsNull
      c50v16 = c50v16(c50v17)
      if not c50v16 then
        c50v19 = _T.Stats_CritChanceOverride
        c50v20 = c50v2:GetType()
        c50v20 = c50v20:GetFullName()
        c50v18 = c50v19[c50v20]
        c50v19 = c50v5.behaviorIndex
        c50v17 = c50v18[c50v19]
        c50v16 = IsNull
        c50v16 = c50v16(c50v17)
        if not c50v16 then
          c50v18 = _T.Stats_CritChanceOverride
          c50v19 = c50v2:GetType()
          c50v19 = c50v19:GetFullName()
          c50v17 = c50v18[c50v19]
          c50v18 = c50v5.behaviorIndex
          c50v16 = c50v17[c50v18]
          c50v14 = c50v14 + c50v16
        end
      end
    end
    c50v17 = _T.Stats_CritMultOverride
    c50v16 = IsNull
    c50v16 = c50v16(c50v17)
    if not c50v16 then
      c50v18 = _T.Stats_CritMultOverride
      c50v19 = c50v2:GetType()
      c50v19 = c50v19:GetFullName()
      c50v17 = c50v18[c50v19]
      c50v16 = IsNull
      c50v16 = c50v16(c50v17)
      if not c50v16 then
        c50v19 = _T.Stats_CritMultOverride
        c50v20 = c50v2:GetType()
        c50v20 = c50v20:GetFullName()
        c50v18 = c50v19[c50v20]
        c50v19 = c50v5.behaviorIndex
        c50v17 = c50v18[c50v19]
        c50v16 = IsNull
        c50v16 = c50v16(c50v17)
        if not c50v16 then
          c50v18 = _T.Stats_CritMultOverride
          c50v19 = c50v2:GetType()
          c50v19 = c50v19:GetFullName()
          c50v17 = c50v18[c50v19]
          c50v18 = c50v5.behaviorIndex
          c50v16 = c50v17[c50v18]
          c50v15 = c50v15 + c50v16
        end
      end
    end
    c50v14 = c50v14 * 100
    c50v16 = v13
    c50v17 = v11
    c50v17 = c50v17(c50v14)
    c50v19 = nil
    c50v16 = c50v16(c50v17, c50v14, c50v19)
    c50v1.CriticalChance = c50v16
    c50v16 = Localize
    c50v17 = "/Lotus/Language/Menu/WeaponStats_MultipilerStat"
    c50v18 = { STAT = nil }
    c50v19 = v0
    c50v19 = c50v19.FormatNumber
    c50v21 = 1
    c50v22 = false
    c50v19 = c50v19(c50v15, c50v21, c50v22)
    c50v18.STAT = c50v19
    c50v16 = c50v16(c50v17, c50v18)
    c50v17 = v13
    c50v20 = nil
    c50v17 = c50v17(c50v16, c50v15, c50v20)
    c50v1.CriticalMultiplier = c50v17
    if c50v16 then
      c50v17 = v0
      c50v17 = c50v17.Ternary
      c50v19 = c50v7.fireIterations
      c50v20 = 1
      if c50v19 <= c50v20 then
        c50v18 = false
      else
        c50v18 = true
      end
      c50v19 = "ProcChancePerShot"
      c50v20 = "ProcChance"
      c50v17 = c50v17(c50v18, c50v19, c50v20)
      c50v20 = c50v4.baseProcChance
      c50v19 = c50v20 * 100
      c50v20 = 0
      c50v18 = math.max
      c50v18 = c50v18(c50v19, c50v20)
      c50v19 = c50v6:IsContinuousBehavior()
      if c50v19 then
        c50v21 = gWeaponBeamStateBehaviorType
        c50v19 = c50v6:IsA(c50v21)
        if not c50v19 then
          c50v19 = c50v2:GetFireRate()
          c50v18 = c50v18 * c50v19
        end
      end
      if c50v12 then
        c50v21 = 7
        c50v19 = c50v12:GetDamagePct(c50v21)
        c50v20 = 0
        if not ((c50v19 <= c50v20 or not c50v3)) then
          c50v19 = c50v3:Name__f313e652()
          c50v20 = 0
          if c50v20 < c50v19 then
            c50v19 = c50v3:Name__f313e652()
            c50v18 = c50v19 * 100
            c50v22 = 364
            c50v23 = c50v2:GetType()
            c50v18 = c50v11:GetUpgradeModifiedValue(c50v18, c50v22, c50v23, c50v2)
          end
        end
      end
      if not ((not c50v13 or not c50v3)) then
        c50v19 = c50v2:GetEmbedDamage(c50v3)
        if c50v19 then
          c50v20 = c50v19.baseProcChance
          c50v21 = 0
          if c50v21 < c50v20 then
            c50v20 = c50v19.baseProcChance
            c50v18 = c50v20 * 100
          end
        end
      end
      c50v19 = v13
      c50v20 = v11
      c50v20 = c50v20(c50v18)
      c50v22 = nil
      c50v19 = c50v19(c50v20, c50v18, c50v22)
      c50v1[c50v17] = c50v19
      c50v19 = v24
      c50v21 = false
      c50v22 = 1
      c50v19 = c50v19(c50v1, c50v21, c50v22)
      c50v20 = c50v1[c50v17]
      c50v21 = v9
      c50v26 = false
      c50v21 = c50v21(c50v0, c50v1, c50v18, c50v19, c50v26, c50v8)
      c50v20.SecondaryToolTips = c50v21
    end
    do return end
  end
  v9 = function(c51v0, c51v1, c51v2, c51v3, c51v4, c51v5, c51v6)
    local c51v7, c51v8, c51v9, c51v10, c51v11, c51v12, c51v13, c51v14, c51v15, c51v16, c51v17, c51v18, c51v19, c51v20, c51v21, c51v22, c51v23, c51v24, c51v25
    c51v12 = IsNull
    c51v12 = c51v12(c51v6)
    c51v14 = 0
    c51v12 = 13
    c51v13 = 1
    for c51v14 = c51v14, c51v12, c51v13 do
      c51v15 = c51v6:Name__ece904ae(c51v10, c51v14)
      c51v15 = c51v6:Name__ece904ae(c51v11, c51v14)
      c51v15 = table.insert
      c51v15(c51v9, c51v14)
      c51v15 = IsNull
      c51v15 = c51v15(c51v5)
      if not c51v15 then
        c51v18 = false
        c51v15 = c51v5:GetForcedProc(c51v14, c51v18)
        if c51v15 then
          c51v15 = table.insert
          c51v15(c51v8, c51v14)
        end
      end
      c51v15 = IsNull
      c51v15 = c51v15(c51v6)
    end
    c51v7 = {}
    if not c51v4 then
      c51v9 = { TEXT = "/Lotus/Language/Stats/TIP_ProcChancePerDT", VARS = nil }
      c51v10 = {}
      c51v9.VARS = c51v10
      c51v7 = {c51v9}
    end
    c51v8 = pairs
    c51v8, c51v9, c51v10 = c51v8(c51v1)
    for c51v11, c51v12 in c51v8, c51v9, c51v10 do
      c51v13 = string.find
      c51v15 = "DT_"
      c51v13 = c51v13(c51v11, c51v15)
      if c51v13 ~= nil then
        c51v15 = 1
        c51v13 = math.max
        c51v13 = c51v13(c51v3, c51v15)
        c51v16 = c51v12.StatValue
        c51v15 = c51v16 / c51v13
        c51v14 = c51v15 * c51v2
        c51v15 = string.gsub
        c51v17 = "Embed"
        c51v18 = ""
        c51v15 = c51v15(c51v11, c51v17, c51v18)
        c51v19 = "/Lotus/Language/Game/"
        c51v18 = c51v19 .. c51v15
        c51v19 = true
        c51v16 = c51v0:GetLocalized(c51v18, c51v19)
        c51v17 = { DT_NAME = nil, AMOUNT = nil }
        c51v17.DT_NAME = c51v16
        c51v17.AMOUNT = c51v14
        c51v20 = { TEXT = "/Lotus/Language/Stats/TIP_DT_StatusChance", VARS = nil, skipFormatting = true }
        c51v20.VARS = c51v17
        c51v18 = table.insert
        c51v18(c51v7, c51v20)
      end
    end
    c51v8 = {}
    c51v9 = {}
    c51v10 = Symbol
    c51v11 = "MeleeSlam"
    c51v10 = c51v10(c51v11)
    c51v11 = Symbol
    c51v12 = "HeavySlam"
    c51v11 = c51v11(c51v12)
    c51v12 = IsNull
    c51v12 = c51v12(c51v5)
    local p44 = 17
    if p44 == 17 then
      c51v12 = #c51v8
      c51v13 = 0
      if c51v13 < c51v12 then
        p44 = 19
      else
        p44 = 18
      end
    end
    if p44 == 18 then
      c51v12 = #c51v9
      c51v13 = 0
      if c51v12 <= c51v13 then
        p44 = 25
      else
        p44 = 19
      end
    end
    if p44 == 19 then
      c51v14 = { TEXT = nil, VARS = nil }
      c51v19 = v14
      c51v22 = "<MINI_DIAMOND> "
      c51v23 = true
      c51v20 = c51v0:GetLocalized(c51v22, c51v23)
      c51v21 = 0
      c51v16 = c51v19(c51v20, c51v21)
      c51v17 = " "
      c51v20 = "/Lotus/Language/Stats/TIP_ForcedProcChancePerDT"
      c51v21 = false
      c51v18 = c51v0:GetLocalized(c51v20, c51v21)
      c51v15 = c51v16 .. c51v17 .. c51v18
      c51v14.TEXT = c51v15
      c51v15 = {}
      c51v14.VARS = c51v15
      c51v12 = table.insert
      c51v12(c51v7, c51v14)
      c51v12 = c51v8
      c51v13 = nil
      c51v14 = nil
      for c51v15, c51v16 in c51v12, c51v13, c51v14 do
        c51v17 = v1
        c51v17 = c51v17.GetDamageTypeTag
        c51v17 = c51v17(c51v16)
        c51v20 = { TEXT = nil, VARS = nil, skipFormatting = true }
        c51v24 = "/Lotus/Language/Game/"
        c51v23 = c51v24 .. c51v17
        c51v24 = true
        c51v21 = c51v0:GetLocalized(c51v23, c51v24)
        c51v20.TEXT = c51v21
        c51v21 = {}
        c51v20.VARS = c51v21
        c51v18 = table.insert
        c51v18(c51v7, c51v20)
      end
      c51v12 = c51v9
      c51v13 = nil
      c51v14 = nil
      for c51v15, c51v16 in c51v12, c51v13, c51v14 do
        c51v17 = v1
        c51v17 = c51v17.GetDamageTypeTag
        c51v17 = c51v17(c51v16)
        c51v20 = { TEXT = "/Lotus/Language/Stats/TIP_ForcedProcForSlamAttack", VARS = nil, skipFormatting = true }
        c51v21 = { DT_NAME = nil }
        c51v25 = "/Lotus/Language/Game/"
        c51v24 = c51v25 .. c51v17
        c51v25 = true
        c51v22 = c51v0:GetLocalized(c51v24, c51v25)
        c51v21.DT_NAME = c51v22
        c51v20.VARS = c51v21
        c51v18 = table.insert
        c51v18(c51v7, c51v20)
      end
      p44 = 25
    end
    if p44 == 25 then
      c51v12 = #c51v7
      c51v13 = 0
      if c51v12 <= c51v13 then
        p44 = 27
      else
        p44 = 26
      end
    end
    if p44 == 26 then
      do return c51v7 end
    end
    if p44 == 27 then
      c51v12 = nil
      do return c51v12 end
    end
  end
  v35 = function(c52v0, c52v1, c52v2, c52v3, c52v4, c52v5, c52v6, c52v7, c52v8, c52v9, c52v10, c52v11, c52v12, c52v13, c52v14, c52v15, c52v16, c52v17, c52v18)
    local c52v19, c52v20, c52v21, c52v22, c52v23, c52v24, c52v25, c52v26, c52v27, c52v28, c52v29, c52v30, c52v31, c52v32, c52v33, c52v34, c52v35, c52v36, c52v37, c52v38, c52v39, c52v40, c52v41, c52v42, c52v43, c52v44, c52v45, c52v46, c52v47, c52v48, c52v49
    c52v31 = c52v1:GetEmbedDamage(c52v2)
    c52v32 = c52v31:GetBaseAmount()
    c52v32 = c52v32:GetModifiedValue()
    c52v33 = 0
    c52v33 = v1
    c52v33 = c52v33.GetDamageTypeTag
    c52v36 = 0
    c52v34 = 19
    c52v35 = 1
    for c52v36 = c52v36, c52v34, c52v35 do
      c52v37 = c52v31:GetDamagePct(c52v36)
      c52v38 = 0
      if c52v38 < c52v37 then
        c52v37 = c52v33(c52v36)
        c52v38 = c52v22[c52v36]
        if c52v38 == nil then
          c52v38 = v13
          c52v39 = nil
          c52v40 = 0
          c52v41 = nil
          c52v38 = c52v38(c52v39, c52v40, c52v41)
          c52v22[c52v37] = c52v38
        end
        c52v38 = v22
        c52v40 = c52v22[c52v37]
        c52v40 = c52v40.StatValue
        c52v42 = c52v31:GetDamagePct(c52v36)
        c52v41 = c52v42 * c52v32
        c52v39 = c52v40 + c52v41
        c52v38 = c52v38(c52v39)
        c52v22[c52v37] = c52v38
      end
    end
    local c85 = -1
    repeat
      c52v30 = WeakResource
      c52v31 = "/Lotus/Weapons/Corpus/Bow/Longbow/CrpBowArrow"
      c52v30 = c52v30(c52v31)
      c52v31 = WeakResource
      c52v32 = "/Lotus/Weapons/Corpus/Bow/Longbow/CrpBowArrowPvP"
      c52v29 = {c52v30, c52v31(c52v32)}
      c52v30 = false
      c52v31 = pairs
      c52v31, c52v32, c52v33 = c52v31(c52v29)
      for c52v34, c52v35 in c52v31, c52v32, c52v33 do
        c52v36 = c52v2:IsA(c52v35)
        if c52v36 then
          c85 = 22
          break
        end
        c52v21 = false
        c52v22 = {}
        if not ((not (not c52v8) and c52v9)) then
          c52v23 = c52v3:GetBaseAmount()
          c52v23 = c52v23:GetModifiedValue()
          c52v24 = 0
          if c52v24 < c52v23 then
            c52v23 = v23
            c52v27 = 1
            c52v23(c52v22, c52v3, c52v10, c52v27, c52v11)
            c52v23 = v34
            c52v36 = nil
            c52v23(c52v0, c52v22, c52v1, c52v2, c52v3, c52v4, c52v5, c52v6, c52v7, c52v8, c52v14, c52v15, c52v36, c52v18)
            c52v23 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
            c52v24 = string.upper
            c52v25 = Localize
            c52v27 = {}
            c52v24 = c52v24(c52v25(c52v16, c52v27))
            c52v23.mName = c52v24
            c52v24 = c52v4.behaviorIndex
            c52v23.mBehaviorIndex = c52v24
            c52v23.mStats = c52v22
            c52v19 = c52v23
          end
        end
        c52v23 = {}
        c52v24 = 0
        c52v25 = nil
        c52v26 = false
        c52v29 = WeakResource
        c52v30 = "/Lotus/Weapons/ClanTech/Energy/EnergyRifle"
        c52v27 = c52v1:IsA(c52v29(c52v30))
        c52v30 = gRadialOnMissImpactBehaviorType
        c52v28 = c52v7:IsA(c52v30)
        if c52v28 then
          c52v25 = c52v7:GetRadialDamageData(c52v14)
          c52v28 = c52v25:GetBaseAmount()
          c52v24 = c52v28:GetModifiedValue()
        end
        if not ((c52v24 ~= 0 or c52v27)) then
          c52v30 = gRadialOnMissTraceFireBehaviorType
          c52v28 = c52v6:IsA(c52v30)
          if c52v28 then
            c52v25 = c52v6:GetRadialDamageData(c52v14)
          else
            c52v26 = true
            c52v30 = false
            c52v25 = c52v1:GetExplosionDamage(c52v30, c52v2)
          end
          c52v28 = c52v25:GetBaseAmount()
          c52v24 = c52v28:GetModifiedValue()
        end
        c52v28 = 0
        if (not (not c52v8) and c52v9) then
          local p80 = 13
          if p80 == 13 then
            c52v21 = c52v26
            c52v28 = v0
            c52v28 = c52v28.Ternary
            c52v30 = c52v3.hitType
            c52v31 = 2
            if c52v30 ~= c52v31 then
              p80 = 15
            else
              p80 = 14
            end
          end
          if p80 == 14 then
            c52v29 = c52v6:Name__f81ac8ed()
            if c52v29 then
              p80 = 18
            else
              p80 = 15
            end
          end
          if p80 == 15 then
            c52v30 = c52v3.hitType
            c52v31 = 4
            if c52v30 == c52v31 then
              p80 = 17
            else
              p80 = 16
            end
          end
          if p80 == 16 then
            c52v29 = false
            p80 = 18
          end
          if p80 == 17 then
            c52v29 = true
            p80 = 18
          end
          if p80 == 18 then
            c52v32 = true
            c52v33 = true
            c52v30 = c52v7:GetPlayerDamageMultiplier(c52v32, c52v33)
            c52v31 = 1
            c52v28 = c52v28(c52v29, c52v30, c52v31)
            c52v30 = v0
            c52v30 = c52v30.Ternary
            c52v33 = 1
            c52v30 = c52v30(c52v14, c52v28, c52v33)
            c52v29 = c52v12 * c52v30
            c52v30 = v23
            c52v30(c52v23, c52v25, c52v10, c52v29)
            c52v32 = c52v25.fallOff
            c52v31 = c52v32 * 100
            c52v32 = 0
            c52v30 = math.max
            c52v30 = c52v30(c52v31, c52v32)
            c52v31 = v13
            c52v32 = v11
            c52v32 = c52v32(c52v30)
            c52v34 = nil
            c52v31 = c52v31(c52v32, c52v30, c52v34)
            c52v23.DamageFallOff = c52v31
          end
        end
        c52v28 = false
        c52v29 = c52v1:Name__7ffc2d2c(c52v2)
        if not c52v29 then
          c85 = 47
          break
        end
      end
      if c85 ~= -1 then break end
      break
    until true
    if c85 == 22 then
      c52v30 = true
    end
    if c52v32 <= c52v33 then
      local p83 = 31
      if p83 == 31 then
        c52v33 = false
        if c52v24 == 0 then
          p83 = 34
        else
          p83 = 32
        end
      end
      if p83 == 32 then
        c52v34 = 0
        if (not (c52v34 < c52v32) and not c52v30) then
          p83 = 45
        else
          p83 = 34
        end
      end
      if p83 == 34 then
        c52v36 = true
        c52v25 = c52v1:GetExplosionDamage(c52v36, c52v2)
        c52v33 = true
        c52v34 = c52v25:GetBaseAmount()
        c52v24 = c52v34:GetModifiedValue()
        c52v34 = 0
        if c52v24 <= c52v34 then
          p83 = 45
        else
          p83 = 35
        end
      end
      if p83 == 35 then
        c52v28 = true
        if c52v18 then
          p83 = 37
        else
          p83 = 36
        end
      end
      if p83 == 36 then
        c52v34 = v23
        c52v38 = 1
        c52v39 = nil
        c52v40 = "Embed"
        c52v34(c52v23, c52v25, c52v10, c52v38, c52v39, c52v40)
        p83 = 37
      end
      if p83 == 37 then
        c52v34 = c52v1:ProjectileEmbedTime(c52v2)
        c52v35 = nil
        c52v36 = c52v34.minValue
        c52v37 = c52v34.maxValue
        if c52v36 ~= c52v37 then
          p83 = 39
        else
          p83 = 38
        end
      end
      if p83 == 38 then
        c52v36 = v0
        c52v36 = c52v36.FormatNumber
        c52v37 = c52v34.minValue
        c52v38 = 1
        c52v39 = false
        c52v35 = c52v36(c52v37, c52v38, c52v39)
        p83 = 40
      end
      if p83 == 39 then
        c52v39 = v0
        c52v39 = c52v39.FormatNumber
        c52v40 = c52v34.minValue
        c52v41 = 1
        c52v42 = false
        c52v36 = c52v39(c52v40, c52v41, c52v42)
        c52v37 = " - "
        c52v38 = v0
        c52v38 = c52v38.FormatNumber
        c52v39 = c52v34.maxValue
        c52v40 = 1
        c52v41 = false
        c52v38 = c52v38(c52v39, c52v40, c52v41)
        c52v35 = c52v36 .. c52v37 .. c52v38
        p83 = 40
      end
      if p83 == 40 then
        if c52v35 == nil then
          p83 = 43
        else
          p83 = 41
        end
      end
      if p83 == 41 then
        c52v38 = 0.5
        c52v36 = c52v34:MapToRange(c52v38)
        c52v37 = 0
        if c52v36 <= c52v37 then
          p83 = 43
        else
          p83 = 42
        end
      end
      if p83 == 42 then
        c52v37 = v13
        c52v40 = nil
        c52v41 = nil
        c52v42 = nil
        c52v43 = nil
        c52v44 = nil
        c52v45 = nil
        c52v46 = nil
        c52v47 = nil
        c52v48 = nil
        c52v49 = true
        c52v37 = c52v37(c52v35, c52v36, c52v40, c52v41, c52v42, c52v43, c52v44, c52v45, c52v46, c52v47, c52v48, c52v49)
        c52v23.EmbedDelay = c52v37
        p83 = 43
      end
      if p83 == 43 then
        c52v38 = c52v25.fallOff
        c52v37 = c52v38 * 100
        c52v38 = 0
        c52v36 = math.max
        c52v36 = c52v36(c52v37, c52v38)
        c52v37 = 0
        if c52v36 <= c52v37 then
          p83 = 45
        else
          p83 = 44
        end
      end
      if p83 == 44 then
        c52v37 = v13
        c52v38 = v11
        c52v38 = c52v38(c52v36)
        c52v40 = nil
        c52v37 = c52v37(c52v38, c52v36, c52v40)
        c52v23.EmbedFallOff = c52v37
        p83 = 45
      end
      if p83 == 45 then
        c52v34 = 0
        if c52v24 <= c52v34 then
        else
          p83 = 46
        end
      end
      if p83 == 46 then
        c52v21 = c52v33
      end
    end
    c52v29 = next
    c52v29 = c52v29(c52v23)
    if c52v29 then
      c52v29 = v13
      c52v30 = v20
      c52v31 = c52v25.radius
      c52v32 = 2
      c52v30 = c52v30(c52v31, c52v32)
      c52v31 = c52v25.radius
      c52v32 = nil
      c52v33 = nil
      c52v34 = v0
      c52v34 = c52v34.Ternary
      c52v36 = "MeleeRange"
      c52v37 = "AoERange"
      c52v29 = c52v29(c52v30, c52v31, c52v32, c52v33, c52v34(c52v8, c52v36, c52v37))
      c52v23.Range = c52v29
      c52v29 = v24
      c52v33 = v0
      c52v33 = c52v33.Ternary
      c52v35 = "Embed"
      c52v36 = nil
      c52v33 = c52v33(c52v28, c52v35, c52v36)
      c52v34 = nil
      c52v29(c52v23, c52v10, c52v13, c52v33, c52v34, c52v1, c52v15)
      c52v29 = v34
      c52v42 = nil
      c52v29(c52v0, c52v23, c52v1, c52v2, c52v25, c52v4, c52v5, c52v6, c52v7, c52v8, c52v14, c52v15, c52v42, c52v18)
      c52v29 = { mName = nil, mIsMelee = nil, mBehaviorIndex = nil, mStats = nil, mExtra = true }
      c52v30 = string.upper
      c52v31 = Localize
      c52v33 = {}
      c52v30 = c52v30(c52v31(c52v17, c52v33))
      c52v29.mName = c52v30
      c52v29.mIsMelee = c52v8
      c52v30 = c52v4.behaviorIndex
      c52v29.mBehaviorIndex = c52v30
      c52v29.mStats = c52v23
      c52v20 = c52v29
    end
    c52v29 = 1
    if not ((not (not c52v8) and c52v9)) then
      c52v29 = c52v13
    end
    c52v30 = v24
    c52v34 = nil
    c52v35 = nil
    c52v30(c52v22, c52v10, c52v29, c52v34, c52v35, c52v1, c52v15)
    do return c52v19, c52v20, c52v21 end
  end
  v36 = function(c53v0, c53v1, c53v2, c53v3, c53v4, c53v5, c53v6, c53v7, c53v8)
    local c53v9, c53v10, c53v11, c53v12, c53v13, c53v14, c53v15, c53v16, c53v17, c53v18, c53v19, c53v20, c53v21, c53v22, c53v23, c53v24, c53v25, c53v26, c53v27, c53v28, c53v29, c53v30, c53v31, c53v32, c53v33, c53v34, c53v35, c53v36, c53v37, c53v38, c53v39, c53v40, c53v42, c53v43, c53v44, c53v45, c53v46, c53v47, c53v48, c53v49, c53v50, c53v51, c53v52, c53v53, c53v54, c53v55, c53v56, c53v57, c53v58, c53v59, c53v60, c53v61, c53v62, c53v63, c53v64, c53v65, c53v66, c53v67, c53v68, c53v69, c53v70, c53v71, c53v72, c53v73, c53v74, c53v76, c53v77, c53v78, c53v79, c53v80, c53v81, c53v82, c53v83, c53v84, c53v85, c53v86, c53v87, c53v88, c53v89, c53v90, c53v91, c53v92, c53v93, c53v94, c53v95, c53v96, c53v97, c53v98
    c53v28 = 1
    c53v26 = #c53v9
    c53v27 = 1
    for c53v28 = c53v28, c53v26, c53v27 do
      c53v29 = c53v9[1]
      c53v30 = c53v9[c53v28]
      c53v31 = pairs
      c53v32 = c53v30.mStats
      c53v31, c53v32, c53v33 = c53v31(c53v32)
      for c53v34 in c53v31, c53v32, c53v33 do
        c53v36 = IsNull
        c53v36 = c53v36(c53v34)
        if not c53v36 then
          c53v37 = c53v29.mStats
          c53v36 = c53v37[c53v34]
          c53v38 = c53v30.mStats
          c53v37 = c53v38[c53v34]
          c53v38 = IsNull
          c53v38 = c53v38(c53v36)
          if not c53v38 then
            c53v38 = IsNull
            c53v38 = c53v38(c53v37)
            if not c53v38 then
              c53v38 = c53v37.DisplayValue
              c53v39 = c53v36.DisplayValue
              if c53v38 == c53v39 then
                c53v38 = c53v30.mStats
                c53v39 = nil
                c53v38[c53v34] = c53v39
              end
            end
          end
        end
      end
      for c53v34, c53v35 in c53v31, c53v32, c53v33 do
      end
    end
    c53v31 = c53v30.behaviorIndex
    c53v31 = v29
    c53v33 = c53v30.upgrades
    c53v31(c53v18, c53v33)
    c53v33 = c53v30.behaviorIndex
    c53v31 = c53v1:GetStateBehavior(c53v33)
    c53v34 = Name__539c8440
    c53v32 = c53v31:IsA(c53v34)
    c53v34 = gWeaponBurstStateBehaviorType
    c53v32 = c53v31:IsA(c53v34)
    c53v56 = c53v32:Name__f81ac8ed()
    c53v62 = 0
    c53v60 = 19
    c53v61 = 1
    for c53v62 = c53v62, c53v60, c53v61 do
      c53v63 = c53v58:GetDamagePct(c53v62)
      c53v64 = 0
      if c53v64 < c53v63 then
        c53v63 = c53v10(c53v62)
        c53v64 = c53v54[c53v63]
        if c53v64 == nil then
          c53v64 = v13
          c53v65 = nil
          c53v66 = 0
          c53v67 = nil
          c53v64 = c53v64(c53v65, c53v66, c53v67)
          c53v54[c53v63] = c53v64
        end
        c53v64 = v22
        c53v66 = c53v54[c53v63]
        c53v66 = c53v66.StatValue
        c53v68 = c53v58:GetDamagePct(c53v62)
        c53v67 = c53v68 * c53v59
        c53v65 = c53v66 + c53v67
        c53v64 = c53v64(c53v65)
        c53v54[c53v63] = c53v64
      end
    end
    c53v70 = pairs
    c53v70, c53v71, c53v72 = c53v70(c53v69)
    local c53v75 = c53v52:IsA(c53v74)
    c53v68 = true
    c53v70 = c53v1:GetEmbedDamage(c53v52)
    c53v71 = c53v70:GetBaseAmount()
    c53v71 = c53v71:GetModifiedValue()
    c53v72 = 0
    c53v74 = 0
    c53v72 = 19
    c53v73 = 1
    c53v73 = 0
    c53v69 = 0
    c53v70 = next
    c53v70 = c53v70(c53v60)
    c53v70 = c53v1:Name__e76ee792(c53v52)
    c53v71 = 0
    c53v71 = v13
    c53v72 = v0
    c53v72 = c53v72.FormatNumber
    c53v74 = 2
    c53v75 = false
    c53v72 = c53v72(c53v70, c53v74, c53v75)
    c53v74 = nil
    c53v75 = nil
    c53v76 = v0
    c53v76 = c53v76.Ternary
    c53v78 = "MeleeRange"
    c53v79 = "AoERange"
    c53v71 = c53v71(c53v72, c53v70, c53v74, c53v75, c53v76(c53v36, c53v78, c53v79))
    c53v60.EmbedDamageRadius = c53v71
    c53v70 = c53v32:GetAmmoRequirement()
    c53v71 = c53v31:IsContinuousBehavior()
    c53v73 = gWeaponBeamStateBehaviorType
    c53v71 = c53v31:IsA(c53v73)
    c53v71 = 0
    c53v71 = c53v50 / c53v70
    c53v74 = 0
    c53v72 = 19
    c53v73 = 1
    c53v72 = v24
    c53v69 = c53v72(c53v60, c53v11, c53v39)
    c53v50 = c53v70
    c53v70 = 1
    c53v71 = 0
    c53v71 = v34
    c53v84 = nil
    c53v71(c53v0, c53v54, c53v1, c53v52, c53v53, c53v30, c53v31, c53v32, c53v33, c53v36, c53v5, c53v18, c53v84, c53v17)
    c53v75 = 1 / c53v72
    c53v74 = c53v75 * 100
    c53v75 = 10
    c53v71 = "/Lotus/Language/Stats/TIP_Accuracy_VeryLow"
    c53v75 = 10
    c53v75 = 15.9
    c53v71 = "/Lotus/Language/Stats/TIP_Accuracy_Low"
    c53v75 = 16
    c53v75 = 32.9
    c53v71 = "/Lotus/Language/Stats/TIP_Accuracy_Medium"
    c53v75 = v13
    c53v79 = false
    c53v76 = c53v0:GetLocalized(c53v71, c53v79)
    c53v78 = true
    c53v75 = c53v75(c53v76, c53v74, c53v78)
    c53v34.Accuracy = c53v75
    c53v75 = c53v34.Accuracy
    c53v77 = { TEXT = "/Lotus/Language/Stats/TIP_Accuracy_Spread", VARS = nil, comparisonFlipped = true }
    c53v78 = { AMOUNT = nil }
    c53v78.AMOUNT = c53v73
    c53v77.VARS = c53v78
    c53v76 = {c53v77}
    c53v75.SecondaryToolTips = c53v76
    c53v77 = true
    c53v78 = 1
    c53v75 = c53v32:GetSpread(c53v77, c53v78)
    c53v77 = c53v34.Accuracy
    c53v77 = c53v77.SecondaryToolTips
    c53v78 = { TEXT = "/Lotus/Language/Stats/TIP_Accuracy_MaxSpread", VARS = nil, comparisonFlipped = true }
    c53v79 = { AMOUNT = nil }
    c53v79.AMOUNT = c53v75
    c53v78.VARS = c53v79
    c53v76 = table.insert
    c53v76(c53v77, c53v78)
    c53v71 = c53v33:Name__a7b87d06()
    c53v72 = c53v71:GetBaseAmount()
    c53v72 = c53v72:GetModifiedValue()
    c53v73 = 0
    c53v75 = 0
    c53v73 = 19
    c53v74 = 1
    c53v73 = { mName = nil, mIsMelee = false, mBehaviorIndex = nil, mStats = nil, mExtra = true }
    c53v74 = string.upper
    c53v77 = "/Lotus/Language/Labels/WEAPON_DAMAGE_AMOUNT"
    c53v78 = false
    c53v74 = c53v74(c53v0:GetLocalized(c53v77, c53v78))
    c53v73.mName = c53v74
    c53v74 = c53v30.behaviorIndex
    c53v73.mBehaviorIndex = c53v74
    c53v73.mStats = c53v54
    c53v74 = table.insert
    c53v74(c53v9, c53v73)
    c53v83 = {}
    c53v84 = c53v30.turboGlaive
    c53v76 = c53v1:Name__46beef39()
    c53v76 = c53v1:InfiniteClipsForPlayers()
    c53v74 = c53v1:Name__1d4c5bf4(c53v5)
    c53v76 = 0
    c53v76 = 1000000
    c53v79 = 220
    c53v74 = c53v18:GetUpgradeModifiedValue(c53v74, c53v79, c53v1:GetAmmoExType())
    c53v76 = c53v32:Name__eda17dce()
    c53v78 = WeakResource
    c53v79 = "/Lotus/Weapons/CrewShip/RailjackOrdnanceWeapon"
    c53v76 = c53v1:IsA(c53v78(c53v79))
    c53v80 = c53v32:Name__f81ac8ed()
    c53v82 = c53v32:GetProjectileType()
    c53v83 = false
    c53v79 = c53v1:Name__15392120(c53v82, c53v83)
    c53v79 = c53v33.damageFallOff
    c53v57 = c53v53.hitType
    c53v58 = 4
    if c53v57 ~= c53v58 then
      c53v56 = false
    else
      c53v56 = true
    end
    c53v71 = c53v62.radius
    c53v72 = 0
    if c53v72 < c53v71 then
      c53v71 = v13
      c53v72 = v20
      c53v73 = c53v62.radius
      c53v74 = 2
      c53v72 = c53v72(c53v73, c53v74)
      c53v73 = c53v62.radius
      c53v74 = nil
      c53v75 = nil
      c53v76 = v0
      c53v76 = c53v76.Ternary
      c53v78 = "MeleeRange"
      c53v79 = "AoERange"
      c53v71 = c53v71(c53v72, c53v73, c53v74, c53v75, c53v76(c53v36, c53v78, c53v79))
      c53v60.Range = c53v71
    end
    c53v76 = c53v10(c53v74)
    c53v75 = c53v54[c53v76]
    if c53v75 ~= nil then
      c53v75 = c53v10(c53v74)
      c53v76 = v22
      c53v79 = c53v10(c53v74)
      c53v78 = c53v54[c53v79]
      c53v78 = c53v78.StatValue
      c53v77 = c53v78 * c53v71
      c53v76 = c53v76(c53v77)
      c53v54[c53v75] = c53v76
    end
    c53v74 = c53v10(c53v73)
    c53v75 = c53v54[c53v74]
    if c53v75 ~= nil then
      c53v75 = v22
      c53v78 = c53v54[c53v74]
      c53v78 = c53v78.StatValue
      c53v77 = c53v78 * c53v3
      c53v78 = v0
      c53v78 = c53v78.Ternary
      c53v81 = 1
      c53v78 = c53v78(c53v5, c53v55, c53v81)
      c53v76 = c53v77 * c53v78
      c53v75 = c53v75(c53v76)
      c53v54[c53v74] = c53v75
    end
    c53v75 = 33
    if c53v75 <= c53v74 then
      c53v75 = 99.9
      if c53v74 < c53v75 then
        c53v71 = "/Lotus/Language/Stats/TIP_Accuracy_High"
      end
    end
    c53v76 = c53v71:GetDamagePct(c53v75)
    c53v77 = 0
    if c53v77 < c53v76 then
      c53v76 = c53v71:GetDamagePct(c53v75)
      c53v78 = c53v76 * c53v72
      c53v77 = c53v78 * c53v39
      c53v78 = c53v10(c53v75)
      c53v79 = v22
      c53v79 = c53v79(c53v77)
      c53v54[c53v78] = c53v79
    end
    if c53v37 ~= nil then
      c53v75 = c53v30.localizeTag
      if c53v75 == "/Lotus/Language/Menu/Loadout_FireModePrimary" then
        c53v75 = string.upper
        c53v78 = "/Lotus/Language/Menu/Loadout_FireModeMelee"
        c53v79 = false
        c53v75 = c53v75(c53v0:GetLocalized(c53v78, c53v79))
        c53v37.mName = c53v75
      end
    end
    c53v76 = IsNull
    c53v76 = c53v76(c53v71)
    if not c53v76 then
      c53v74 = c53v18:Name__3c47b5d8(c53v71)
    else
      c53v74 = 0
    end
    c53v76 = v13
    c53v77 = nil
    c53v78 = c53v2:Name__9e4171c1()
    c53v79 = nil
    c53v80 = nil
    c53v76 = c53v76(c53v77, c53v78, c53v79, c53v80)
    c53v34.EnergyPool = c53v76
    c53v76 = c53v32:Name__8bf9582a()
    c53v77 = c53v31:IsContinuousBehavior()
    if c53v77 then
      c53v77 = c53v76 * 100
      c53v78 = 3
      c53v76 = c53v77 * c53v78
      c53v77 = v13
      c53v81 = v0
      c53v81 = c53v81.FormatNumber
      c53v83 = 0
      c53v84 = false
      c53v79 = c53v81(c53v76, c53v83, c53v84)
      c53v80 = "/s"
      c53v78 = c53v79 .. c53v80
      c53v79 = -c53v76
      c53v80 = nil
      c53v77 = c53v77(c53v78, c53v79, c53v80)
      c53v34.EnergyPerSecond = c53v77
    else
      c53v77 = v13
      c53v78 = v0
      c53v78 = c53v78.FormatNumber
      c53v80 = 0
      c53v81 = false
      c53v78 = c53v78(c53v76, c53v80, c53v81)
      c53v79 = -c53v76
      c53v80 = nil
      c53v77 = c53v77(c53v78, c53v79, c53v80)
      c53v34.EnergyPerShot = c53v77
    end
    c53v70 = WeakResource
    c53v71 = "/Lotus/Weapons/Corpus/Bow/Longbow/CrpBowArrowBase"
    c53v69 = {c53v70(c53v71)}
    if c53v61 ~= 0 then
      c53v68 = false
    else
      c53v68 = true
    end
    c53v75 = c53v70:GetDamagePct(c53v74)
    c53v76 = 0
    if c53v76 < c53v75 then
      c53v75 = c53v10(c53v74)
      c53v76 = c53v54[c53v74]
      if c53v76 == nil then
        c53v76 = v13
        c53v77 = nil
        c53v78 = 0
        c53v79 = nil
        c53v76 = c53v76(c53v77, c53v78, c53v79)
        c53v54[c53v75] = c53v76
      end
      c53v76 = v22
      c53v78 = c53v54[c53v75]
      c53v78 = c53v78.StatValue
      c53v80 = c53v70:GetDamagePct(c53v74)
      c53v79 = c53v80 * c53v71
      c53v77 = c53v78 + c53v79
      c53v76 = c53v76(c53v77)
      c53v54[c53v75] = c53v76
    end
    c53v72 = c53v52
    if c53v72 then
      c53v74 = WeakResource
      c53v75 = "/Lotus/Weapons/Infested/Pistols/InfestedDartPistol/InfestedDartPistolBolt"
      c53v72 = c53v52:IsA(c53v74(c53v75))
    end
    c53v71 = v24
    c53v75 = v0
    c53v75 = c53v75.Ternary
    c53v77 = "Embed"
    c53v78 = nil
    c53v69 = c53v71(c53v60, c53v11, c53v39, c53v75(c53v67, c53v77, c53v78))
    c53v71 = "/Lotus/Language/Labels/AVATAR_RADIAL_ATTACK"
    c53v72 = c53v30.turboGlaive
    if c53v72 ~= nil then
      c53v71 = "/Lotus/Language/Labels/AVATAR_BOUNCE_ATTACK"
    else
      if c53v42 then
        c53v71 = "/Lotus/Language/Stats/ChargedRadialAttack"
      end
    end
    c53v72 = { mName = nil, mIsMelee = nil, mBehaviorIndex = nil, mStats = nil, mExtra = true }
    c53v73 = string.upper
    c53v77 = false
    c53v73 = c53v73(c53v0:GetLocalized(c53v71, c53v77))
    c53v72.mName = c53v73
    c53v72.mIsMelee = c53v36
    c53v73 = c53v30.behaviorIndex
    c53v72.mBehaviorIndex = c53v73
    c53v72.mStats = c53v60
    c53v73 = table.insert
    c53v73(c53v9, c53v72)
    c53v71 = 0
    if c53v71 < c53v61 then
      c53v71 = v34
      c53v71(c53v0, c53v60, c53v1, c53v52, c53v53, c53v30, c53v31, c53v32, c53v33, c53v36, c53v5, c53v18, c53v62, c53v17)
      if c53v15 then
        c53v71 = c53v60.Total
        c53v73 = c53v71.DisplayValue
        c53v76 = "/Lotus/Language/Labels/GENERIC_MULTIPLIER"
        c53v77 = false
        c53v78 = { VALUE = 3 }
        c53v74 = c53v0:GetLocalized(c53v76, c53v77, c53v78)
        c53v72 = c53v73 .. c53v74
        c53v71.DisplayValue = c53v72
        c53v60.Total = c53v71
      end
    end
    c53v71 = c53v53.baseAmount
    c53v71 = "/Lotus/Language/Stats/TIP_Accuracy_VeryHigh"
    c53v72 = v13
    c53v76 = false
    c53v73 = c53v0:GetLocalized(c53v71, c53v76)
    c53v74 = 100
    c53v75 = true
    c53v72 = c53v72(c53v73, c53v74, c53v75)
    c53v34.Accuracy = c53v72
    c53v74 = true
    c53v75 = 0
    c53v73 = c53v32:GetSpread(c53v74, c53v75)
    c53v76 = true
    c53v77 = 0
    c53v78 = false
    c53v74 = c53v32:GetSpread(c53v76, c53v77, c53v78)
    if c53v74 == 0 then
      c53v72 = c53v72 + 1
    end
    c53v74 = 0
    c53v74 = c53v32:Name__eda17dce()
    if c53v74 then
      c53v76 = c53v2:GetWeaponEnergyRegenSpeed()
      c53v77 = 106
      c53v74 = c53v18:GetUpgradeModifiedValue(c53v76, c53v77)
      c53v75 = v13
      c53v79 = v0
      c53v79 = c53v79.FormatNumber
      c53v81 = 0
      c53v82 = false
      c53v77 = c53v79(c53v74, c53v81, c53v82)
      c53v78 = "/s"
      c53v76 = c53v77 .. c53v78
      c53v78 = nil
      c53v75 = c53v75(c53v76, c53v74, c53v78)
      c53v34.RechargeRate = c53v75
      c53v75 = c53v2:Name__3bc90eb6()
      c53v78 = "/Lotus/Language/Menu/ProgressSeconds"
      c53v79 = false
      c53v80 = { CURRENT = nil }
      c53v81 = v0
      c53v81 = c53v81.FormatNumber
      c53v83 = 1
      c53v84 = false
      c53v81 = c53v81(c53v75, c53v83, c53v84)
      c53v80.CURRENT = c53v81
      c53v76 = c53v0:GetLocalized(c53v78, c53v79, c53v80)
      c53v77 = v13
      c53v79 = -c53v75
      c53v80 = nil
      c53v77 = c53v77(c53v76, c53v79, c53v80)
      c53v34.RechargeDelay = c53v77
    end
    c53v76 = gLotusWeaponProjectileFireBehaviorType
    c53v74 = c53v32:IsA(c53v76)
    if c53v74 then
      c53v74 = c53v32:Name__a27d16d0()
      if c53v74 ~= 0 then
        c53v75 = v34
        c53v88 = nil
        c53v75(c53v0, c53v34, c53v1, c53v52, c53v53, c53v30, c53v31, c53v32, c53v33, c53v36, c53v5, c53v18, c53v88, c53v17)
      end
    end
    if c53v21 then
      c53v71 = c53v30.turboGlaive
      if c53v71 ~= nil then
        c53v71 = {}
        c53v38 = true
        c53v74 = false
        c53v62 = c53v1:GetExplosionDamage(c53v74, c53v52)
        c53v74 = c53v52:Name__836612ff()
        c53v73 = c53v74 * 100
        c53v74 = 0
        c53v72 = math.max
        c53v72 = c53v72(c53v73, c53v74)
        c53v73 = v13
        c53v74 = v11
        c53v74 = c53v74(c53v72)
        c53v76 = nil
        c53v73 = c53v73(c53v74, c53v72, c53v76)
        c53v71.DamageFallOff = c53v73
        c53v73 = v13
        c53v74 = v20
        c53v75 = c53v62.radius
        c53v76 = 2
        c53v74 = c53v74(c53v75, c53v76)
        c53v75 = c53v62.radius
        c53v76 = nil
        c53v77 = nil
        c53v78 = v0
        c53v78 = c53v78.Ternary
        c53v80 = "MeleeRange"
        c53v81 = "AoERange"
        c53v73 = c53v73(c53v74, c53v75, c53v76, c53v77, c53v78(c53v36, c53v80, c53v81))
        c53v71.Range = c53v73
        c53v74 = v0
        c53v74 = c53v74.Ternary
        c53v77 = 1
        c53v74 = c53v74(c53v5, c53v55, c53v77)
        c53v73 = c53v3 * c53v74
        c53v74 = c53v52:Name__f53b9cc4()
        c53v48 = c53v73 * c53v74
        c53v73 = next
        c53v73 = c53v73(c53v54)
        if c53v73 then
          c53v73 = v25
          c53v78 = 1
          c53v73(c53v71, c53v62, c53v11, c53v48, c53v78)
        end
        c53v73 = { mName = nil, mBehaviorIndex = nil, mIsHeavyAttack = true, mStats = nil, mExtra = true }
        c53v74 = string.upper
        c53v77 = "/Lotus/Language/Labels/AVATAR_HEAVY_ATTACK"
        c53v78 = false
        c53v74 = c53v74(c53v0:GetLocalized(c53v77, c53v78))
        c53v73.mName = c53v74
        c53v74 = c53v30.behaviorIndex
        c53v73.mBehaviorIndex = c53v74
        c53v73.mStats = c53v71
        c53v74 = table.insert
        c53v74(c53v9, c53v73)
      end
    end
    if not ((c53v5 or not c53v11)) then
      c53v78 = WeakResource
      c53v79 = "/Lotus/Weapons/CrewShip/RailjackOrdnanceWeapon"
      c53v76 = c53v1:IsA(c53v78(c53v79))
      if c53v76 then
        c53v76 = c53v1:GetClipSize()
        c53v74 = c53v74 + c53v76
      end
    end
    c53v76 = math.floor
    c53v74 = c53v76(c53v74)
    c53v73 = v1
    c53v73 = c53v73.IsPseudoExalted
    c53v73 = c53v73(c53v1)
    c53v74 = c53v1:Name__ec99d38d()
    c53v74 = c53v74:GetWeaponRange()
    c53v75 = c53v18:IsSpaceMode()
    if c53v75 then
      c53v75 = c53v1:Name__ec99d38d()
      c53v77 = false
      c53v74 = c53v75:GetLockOnDistance(c53v77)
    end
    if c53v73 then
      c53v75 = _T.PseudoExaltedAdditionalStats
      if c53v75 then
        c53v75 = _T.PseudoExaltedAdditionalStats.mRange
        if c53v75 then
          c53v75 = _T.PseudoExaltedAdditionalStats.mRange
          c53v74 = c53v74 + c53v75
        end
      end
    end
    c53v75 = v13
    c53v76 = v20
    c53v78 = 2
    c53v76 = c53v76(c53v74, c53v78)
    c53v78 = nil
    c53v79 = nil
    c53v80 = v0
    c53v80 = c53v80.Ternary
    c53v82 = "MeleeRange"
    c53v83 = "AoERange"
    c53v75 = c53v75(c53v76, c53v74, c53v78, c53v79, c53v80(c53v36, c53v82, c53v83))
    c53v34.Range = c53v75
    c53v75 = c53v18:IsSpaceMode()
    c53v86 = 30
    c53v87 = true
    c53v2:SetPostureModifier(c53v86, c53v87)
    c53v86 = 4
    c53v84 = c53v33:Name__96ff68fb(c53v86)
    c53v87 = 4
    c53v85 = c53v33:GetMeleeAttack(c53v87)
    c53v86 = 1
    c53v87 = 1
    c53v88 = IsNull
    c53v88 = c53v88(c53v85)
    if not c53v88 then
      c53v86 = c53v85:Name__dab108e3()
      c53v88 = 1
      if c53v88 < c53v86 then
        c53v90 = 0
        c53v87 = c53v85:Name__1beb0183(c53v90)
        if c53v87 == 0.01 then
          c53v87 = 0
        end
      end
    end
    c53v88 = v33
    c53v88 = c53v88(c53v84, c53v87)
    c53v89 = v0
    c53v89 = c53v89.FormatNumber
    c53v90 = c53v88
    c53v91 = v0
    c53v91 = c53v91.Ternary
    c53v93 = 999.9
    if c53v93 <= c53v88 then
      c53v92 = false
    else
      c53v92 = true
    end
    c53v93 = 1
    c53v94 = 0
    c53v91 = c53v91(c53v92, c53v93, c53v94)
    c53v92 = false
    c53v89 = c53v89(c53v90, c53v91, c53v92)
    c53v90 = 1
    if c53v90 < c53v86 then
      c53v91 = " x"
      c53v92 = v0
      c53v92 = c53v92.FormatNumber
      c53v94 = 0
      c53v95 = false
      c53v92 = c53v92(c53v86, c53v94, c53v95)
      c53v89 = c53v89 .. c53v91 .. c53v92
    end
    c53v90 = v13
    c53v93 = nil
    c53v90 = c53v90(c53v89, c53v88, c53v93)
    c53v83.HeavyAttack = c53v90
    c53v92 = 30
    c53v93 = false
    c53v2:SetPostureModifier(c53v92, c53v93)
    c53v71 = c53v1:GetAmmoExType()
    c53v73 = c53v1:GetProductCategory()
    c53v74 = 16
    if c53v73 ~= c53v74 then
      c53v72 = false
    else
      c53v72 = true
    end
    c53v74 = c53v32:UsesAmmo()
    c53v73 = not c53v74
    if c53v73 then
      c53v73 = c53v32:ConsumesChargesForFire()
    end
    c53v74 = 0
    c53v75 = 0
    c53v59 = true
    c53v60 = true
    c53v57 = c53v33:GetPlayerDamageMultiplier(c53v59, c53v60)
    c53v58 = 1
    c53v55 = c53v55(c53v56, c53v57, c53v58)
    if not ((not c53v5 or c53v35)) then
      c53v56 = c53v1:Name__5a615971()
      c53v58 = 1
      c53v60 = 1
      c53v59 = c53v60 * c53v56
      c53v57 = c53v58 + c53v59
      c53v58 = Localize
      c53v59 = "/Lotus/Language/Menu/WeaponStats_MultipilerStat"
      c53v60 = { STAT = nil }
      c53v61 = v0
      c53v61 = c53v61.FormatNumber
      c53v63 = 1
      c53v64 = false
      c53v61 = c53v61(c53v57, c53v63, c53v64)
      c53v60.STAT = c53v61
      c53v58 = c53v58(c53v59, c53v60)
      c53v59 = v13
      c53v62 = nil
      c53v59 = c53v59(c53v58, c53v57, c53v62)
      c53v34.HeadShotMult = c53v59
    end
    if c53v16 then
      c53v56 = IsNull
      c53v56 = c53v56(c53v18)
      if not c53v56 then
        c53v58 = 1
        c53v59 = 275
        c53v60 = c53v1:GetType()
        c53v62 = 25
        c53v63 = EMPTY_SYMBOL
        c53v39 = c53v18:GetUpgradeModifiedValue(c53v58, c53v59, c53v60, c53v1, c53v62, c53v63)
      end
    end
    if c53v39 ~= 1 then
      c53v56 = false
    else
      c53v56 = true
    end
    c53v57 = v0
    c53v57 = c53v57.FormatNumber
    c53v59 = 1
    c53v60 = false
    c53v57 = c53v57(c53v39, c53v59, c53v60)
    c53v58 = c53v1:Name__62e4017e()
    if not ((not c53v58 or c53v16)) then
      c53v62 = "<LOCKED> "
      c53v63 = true
      c53v58 = c53v0:GetLocalized(c53v62, c53v63)
      c53v57 = c53v58 .. c53v57
      c53v56 = false
    end
    c53v58 = c53v32:IgnoreFireIterations()
    if not c53v58 then
      c53v58 = v13
      c53v61 = nil
      c53v62 = nil
      c53v63 = nil
      c53v64 = nil
      c53v65 = nil
      c53v66 = nil
      c53v67 = nil
      c53v58 = c53v58(c53v57, c53v39, c53v61, c53v62, c53v63, c53v64, c53v65, c53v66, c53v67, c53v56)
      c53v34.Multishot = c53v58
    else
      c53v39 = 1
    end
    c53v58 = c53v1:GetEmbedDamage(c53v52)
    c53v59 = c53v58:GetBaseAmount()
    c53v59 = c53v59:GetModifiedValue()
    c53v60 = 0
    if c53v68 then
      c53v68 = false
      c53v75 = true
      c53v62 = c53v1:GetExplosionDamage(c53v75, c53v52)
      c53v73 = c53v62:GetBaseAmount()
      c53v61 = c53v73:GetModifiedValue()
      c53v73 = 0
      if c53v73 < c53v61 then
        c53v38 = true
        c53v67 = true
        c53v68 = true
        c53v73 = v0
        c53v73 = c53v73.Ternary
        c53v76 = 1
        c53v73 = c53v73(c53v5, c53v55, c53v76)
        c53v48 = c53v47 * c53v73
        c53v73 = v23
        c53v78 = nil
        c53v79 = "Embed"
        c53v73(c53v60, c53v62, c53v11, c53v48, c53v78, c53v79)
      end
    end
    c53v73 = 0
    if not ((c53v59 <= c53v73 or c53v72)) then
      c53v38 = true
      c53v67 = true
    end
    if not c53v68 then
      c53v73 = c53v1:ProjectileEmbedTime(c53v52)
      c53v74 = nil
      c53v75 = c53v73.minValue
      c53v76 = c53v73.maxValue
      if c53v75 == c53v76 then
        c53v75 = v0
        c53v75 = c53v75.FormatNumber
        c53v76 = c53v73.minValue
        c53v77 = 1
        c53v78 = false
        c53v74 = c53v75(c53v76, c53v77, c53v78)
      else
        c53v78 = v0
        c53v78 = c53v78.FormatNumber
        c53v79 = c53v73.minValue
        c53v80 = 1
        c53v81 = false
        c53v75 = c53v78(c53v79, c53v80, c53v81)
        c53v76 = " - "
        c53v77 = v0
        c53v77 = c53v77.FormatNumber
        c53v78 = c53v73.maxValue
        c53v79 = 1
        c53v80 = false
        c53v77 = c53v77(c53v78, c53v79, c53v80)
        c53v74 = c53v75 .. c53v76 .. c53v77
      end
      if c53v74 ~= nil then
        c53v77 = 0.5
        c53v75 = c53v73:MapToRange(c53v77)
        c53v76 = 0
        if c53v76 < c53v75 then
          if c53v68 then
            c53v76 = v13
            c53v79 = nil
            c53v80 = nil
            c53v81 = nil
            c53v82 = nil
            c53v83 = nil
            c53v84 = nil
            c53v85 = nil
            c53v86 = nil
            c53v87 = nil
            c53v88 = true
            c53v76 = c53v76(c53v74, c53v75, c53v79, c53v80, c53v81, c53v82, c53v83, c53v84, c53v85, c53v86, c53v87, c53v88)
            c53v60.EmbedDelay = c53v76
          else
            c53v76 = v13
            c53v79 = nil
            c53v76 = c53v76(c53v74, c53v75, c53v79)
            c53v60.EmbedTime = c53v76
          end
        end
      end
      c53v77 = c53v62.fallOff
      c53v76 = c53v77 * 100
      c53v77 = 0
      c53v75 = math.max
      c53v75 = c53v75(c53v76, c53v77)
      c53v76 = 0
      if c53v76 < c53v75 then
        c53v76 = v13
        c53v77 = v11
        c53v77 = c53v77(c53v75)
        c53v79 = nil
        c53v76 = c53v76(c53v77, c53v75, c53v79)
        c53v60.EmbedFallOff = c53v76
      end
    end
    c53v71 = c53v30.turboGlaive
    if c53v71 == nil then
      c53v73 = Symbol
      c53v74 = "NO_ATTACK_SPEED"
      c53v71 = c53v1:Name__64182bfb(c53v73(c53v74))
      if not c53v71 then
        c53v71 = 2
        c53v72 = 1
        if c53v50 < c53v72 then
          c53v71 = 3
        end
        if c53v72 <= c53v50 then
          c53v72 = v13
          c53v73 = v0
          c53v73 = c53v73.FormatNumber
          c53v76 = false
          c53v73 = c53v73(c53v50, c53v71, c53v76)
          c53v75 = nil
          c53v72 = c53v72(c53v73, c53v50, c53v75)
          c53v34.FireRateMelee = c53v72
        else
          c53v74 = CanAllyPrime
          c53v72 = c53v31:IsA(c53v74)
          if c53v72 then
            c53v72 = c53v31:GetRefireWaitTime()
            c53v73 = 1 / c53v50
            if c53v73 < c53v72 then
              c53v50 = 1 / c53v72
            end
          end
          c53v72 = v0
          c53v72 = c53v72.FormatNumber
          c53v75 = false
          c53v72 = c53v72(c53v50, c53v71, c53v75)
          c53v73 = c53v1:Name__bf0191ef()
          c53v74 = 0
          if c53v74 < c53v73 then
            c53v77 = "<LOCKED> "
            c53v78 = true
            c53v73 = c53v0:GetLocalized(c53v77, c53v78)
            c53v72 = c53v73 .. c53v72
          end
          c53v73 = v13
          c53v76 = nil
          c53v73 = c53v73(c53v72, c53v50, c53v76)
          c53v34.FireRate = c53v73
        end
      end
    end
    c53v73 = 0
    c53v71 = 19
    c53v72 = 1
    c53v84 = IsNull
    c53v84 = c53v84(c53v75)
    if not c53v84 then
      c53v86 = Name__beda8ef9
      c53v84 = c53v31:IsA(c53v86)
      if c53v84 then
        c53v84 = c53v31:GetChargeTime()
        c53v88 = c53v75:Name__0683b84b()
        c53v89 = 327
        c53v90 = c53v1:GetType()
        c53v86 = c53v18:GetUpgradeModifiedValue(c53v88, c53v89, c53v90, c53v1)
        if c53v86 ~= 0 then
          c53v87 = c53v84 / c53v86
          c53v88 = v13
          c53v89 = v10
          c53v91 = 2
          c53v89 = c53v89(c53v87, c53v91)
          c53v90 = -c53v87
          c53v91 = nil
          c53v92 = nil
          c53v93 = nil
          c53v94 = nil
          c53v95 = nil
          c53v96 = 2
          c53v97 = nil
          if c53v85 ~= c53v86 then
            c53v98 = false
          else
            c53v98 = true
          end
          c53v88 = c53v88(c53v89, c53v90, c53v91, c53v92, c53v93, c53v94, c53v95, c53v96, c53v97, c53v98)
          c53v83.HeavyAttackWindUp = c53v88
        end
      end
    end
    c53v84 = Symbol
    c53v85 = "HeavySlam"
    c53v87 = c53v84(c53v85)
    c53v85 = c53v1:GetSlamRadius(c53v87)
    c53v86 = IsNull
    c53v86 = c53v86(c53v1:GetFiringAvatar())
    if not c53v86 then
      c53v86 = c53v1:GetFiringAvatar()
      c53v88 = 30
      c53v89 = true
      c53v86:SetPostureModifier(c53v88, c53v89)
      c53v86 = c53v1:Name__e22fb830(c53v84)
      c53v87 = c53v1:GetFiringAvatar()
      c53v89 = 30
      c53v90 = false
      c53v87:SetPostureModifier(c53v89, c53v90)
      c53v89 = c53v86.fallOffMax
      c53v88 = c53v89 * 100
      c53v89 = 0
      c53v87 = math.max
      c53v87 = c53v87(c53v88, c53v89)
      c53v88 = v22
      c53v89 = v33
      c53v88 = c53v88(c53v89(c53v86))
      c53v83.HeavySlamAttack = c53v88
      c53v88 = c53v83.HeavySlamAttack
      c53v90 = { TEXT = "/Lotus/Language/Stats/TIP_SlamAttackRadius", VARS = nil }
      c53v91 = { AMOUNT = nil }
      c53v91.AMOUNT = c53v85
      c53v90.VARS = c53v91
      c53v91 = { TEXT = "/Lotus/Language/Stats/TIP_SlamAttackFalloff", VARS = nil, comparisonFlipped = true }
      c53v92 = { AMOUNT = nil }
      c53v92.AMOUNT = c53v87
      c53v91.VARS = c53v92
      c53v89 = {c53v90, c53v91}
      c53v88.SecondaryToolTips = c53v89
    end
    c53v86 = c53v33:GetComboEfficiency()
    c53v86 = c53v86 * 100
    c53v87 = v13
    c53v88 = v11
    c53v88 = c53v88(c53v86)
    c53v89 = c53v86
    c53v90 = nil
    c53v91 = nil
    c53v92 = nil
    c53v93 = nil
    c53v94 = nil
    c53v95 = nil
    c53v96 = nil
    if c53v86 ~= 0 then
      c53v97 = false
    else
      c53v97 = true
    end
    c53v87 = c53v87(c53v88, c53v89, c53v90, c53v91, c53v92, c53v93, c53v94, c53v95, c53v96, c53v97)
    c53v83.ComboEfficiency = c53v87
    c53v87 = c53v1:Name__daee522c()
    if c53v87 then
      c53v87 = c53v1:GetEmpoweredMeleeChance()
      c53v88 = v13
      c53v89 = v11
      c53v90 = c53v87 * 100
      c53v89 = c53v89(c53v90)
      c53v90 = c53v87
      c53v91 = nil
      c53v92 = nil
      c53v93 = nil
      c53v94 = nil
      c53v95 = nil
      c53v96 = nil
      c53v97 = nil
      if c53v87 ~= 0 then
        c53v98 = false
      else
        c53v98 = true
      end
      c53v88 = c53v88(c53v89, c53v90, c53v91, c53v92, c53v93, c53v94, c53v95, c53v96, c53v97, c53v98)
      c53v83.Tennokai_Chance = c53v88
    end
    c53v87 = { mName = nil, mIsMelee = true, mIsHeavyAttack = true, mBehaviorIndex = nil, mStats = nil, mExtra = true }
    c53v88 = string.upper
    c53v91 = "/Lotus/Language/Labels/AVATAR_HEAVY_ATTACK"
    c53v92 = false
    c53v88 = c53v88(c53v0:GetLocalized(c53v91, c53v92))
    c53v87.mName = c53v88
    c53v88 = c53v30.behaviorIndex
    c53v87.mBehaviorIndex = c53v88
    c53v87.mStats = c53v83
    c53v88 = table.insert
    c53v88(c53v9, c53v87)
    if not c53v73 then
      c53v76 = v0
      c53v76 = c53v76.Round
      c53v76 = c53v76(c53v1:Name__bc09d984(c53v5))
      c53v77 = c53v1:InfiniteClipsForPlayers()
      c53v78 = nil
      if c53v77 then
        c53v76 = 4294967295
        c53v81 = "<INFINITE_SMALL>"
        c53v82 = true
        c53v78 = c53v0:GetLocalized(c53v81, c53v82)
      end
      c53v79 = 0
      if not c53v77 then
        if not ((c53v11 or c53v72)) then
          c53v79 = c53v1:Name__46beef39()
          if not ((c53v79 or c53v77)) then
            c53v79 = IsNull
            c53v79 = c53v79(c53v71)
            if not c53v79 then
              c53v79 = c53v1:IsHeavyWeapon()
              if not c53v79 then
                c53v75 = c53v1:GetAmmoPickupCount()
                if c53v75 == 0 then
                  c53v79 = v7
                  c53v79 = c53v79:GetAmmoExType()
                  if c53v71 == c53v79 then
                    c53v79 = v7
                    c53v75 = c53v79:GetAmmoAmount()
                  else
                    c53v79 = v8
                    c53v75 = c53v79:GetAmmoAmount()
                  end
                end
                c53v82 = 222
                c53v75 = c53v18:GetUpgradeModifiedValue(c53v75, c53v82, c53v71)
              end
            end
          end
        end
        c53v79 = c53v1:GetReloadTime()
        c53v80 = c53v1:GetClipSize()
        if not ((c53v80 ~= 0 or c53v77)) then
          c53v76 = 1
          c53v78 = nil
        else
          c53v81 = c53v1:GetGripType()
          c53v82 = 17
          if c53v81 == c53v82 then
            c53v76 = 0
          else
            c53v81 = 0
            if c53v81 < c53v80 then
              c53v76 = c53v80
              c53v78 = nil
            end
          end
        end
        c53v81 = v13
        c53v81 = c53v81(c53v78, c53v76)
        c53v34.Mag = c53v81
        c53v81 = c53v34.Mag
        c53v82 = {}
        c53v81.SecondaryToolTips = c53v82
        if c53v76 ~= 4294967295 then
          c53v82 = c53v34.Mag
          c53v82 = c53v82.SecondaryToolTips
          c53v83 = { TEXT = "/Lotus/Language/Stats/TIP_MaxAmmo", VARS = nil }
          c53v84 = { AMOUNT = nil }
          c53v84.AMOUNT = c53v74
          c53v83.VARS = c53v84
          c53v81 = table.insert
          c53v81(c53v82, c53v83)
          c53v82 = c53v34.Mag
          c53v82 = c53v82.SecondaryToolTips
          c53v83 = { TEXT = "/Lotus/Language/Stats/TIP_AmmoPickupCount", VARS = nil }
          c53v84 = { AMOUNT = nil }
          c53v84.AMOUNT = c53v75
          c53v83.VARS = c53v84
          c53v81 = table.insert
          c53v81(c53v82, c53v83)
        end
        c53v81 = c53v1:GetReloadTime()
        c53v82 = v13
        c53v83 = v10
        c53v85 = 1
        c53v83 = c53v83(c53v81, c53v85)
        c53v84 = -c53v81
        c53v85 = nil
        c53v86 = nil
        c53v87 = nil
        c53v88 = nil
        c53v89 = nil
        c53v90 = nil
        c53v91 = nil
        c53v93 = 0.01
        if c53v93 < c53v81 then
          c53v92 = false
        else
          c53v92 = true
        end
        c53v82 = c53v82(c53v83, c53v84, c53v85, c53v86, c53v87, c53v88, c53v89, c53v90, c53v91, c53v92)
        c53v34.Reload = c53v82
        c53v82 = v13
        c53v83 = v0
        c53v83 = c53v83.FormatNumber
        c53v85 = 0
        c53v86 = false
        c53v83 = c53v83(c53v70, c53v85, c53v86)
        c53v84 = -c53v70
        c53v85 = nil
        c53v82 = c53v82(c53v83, c53v84, c53v85)
        c53v34.AmmoReq = c53v82
      end
    else
      c53v76 = v13
      c53v77 = nil
      c53v78 = c53v1:Name__e9a55c21()
      c53v79 = nil
      c53v76 = c53v76(c53v77, c53v78, c53v79)
      c53v34.MaxCharges = c53v76
    end
    c53v60 = {}
    c53v61 = 0
    c53v62 = nil
    c53v63 = false
    c53v66 = WeakResource
    c53v67 = "/Lotus/Powersuits/Choir/ChoirEruptWeaponBase"
    c53v64 = c53v1:IsA(c53v66(c53v67))
    c53v65 = false
    c53v66 = c53v30.turboGlaive
    if c53v66 == nil then
      c53v65 = not c53v64
    end
    c53v68 = WeakResource
    c53v69 = "/Lotus/Weapons/ClanTech/Energy/EnergyRifle"
    c53v66 = c53v1:IsA(c53v68(c53v69))
    if c53v66 ~= nil then
      c53v70 = c53v52:Name__bf644496()
      c53v71 = 386
      c53v72 = c53v1:GetType()
      c53v68 = c53v18:GetUpgradeModifiedValue(c53v70, c53v71, c53v72, c53v1)
      c53v67 = c53v68 * 100
      c53v68 = 0
      if c53v67 <= c53v68 then
        c53v65 = false
      else
        c53v65 = true
      end
      if c53v65 then
        c53v68 = 100
        if c53v67 < c53v68 then
          c53v68 = v13
          c53v69 = v11
          c53v69 = c53v69(c53v67)
          c53v71 = nil
          c53v68 = c53v68(c53v69, c53v67, c53v71)
          c53v60.BounceChance = c53v68
        end
      end
    end
    if c53v65 then
      c53v69 = gRadialOnMissImpactBehaviorType
      c53v67 = c53v33:IsA(c53v69)
      if c53v67 then
        c53v62 = c53v33:GetRadialDamageData(c53v5)
        c53v67 = c53v62:GetBaseAmount()
        c53v61 = c53v67:GetModifiedValue()
      end
      if not c53v67 then
        c53v69 = gRadialOnMissTraceFireBehaviorType
        c53v67 = c53v32:IsA(c53v69)
        if c53v67 then
          c53v62 = c53v32:GetRadialDamageData(c53v5)
        else
          c53v63 = true
          c53v69 = false
          c53v62 = c53v1:GetExplosionDamage(c53v69, c53v52)
        end
        c53v67 = c53v62:GetBaseAmount()
        c53v61 = c53v67:GetModifiedValue()
      end
    end
    c53v67 = 0
    if not (((c53v61 <= c53v67 or c53v66) or c53v16)) then
      c53v38 = true
      c53v67 = v0
      c53v67 = c53v67.Ternary
      c53v70 = 1
      c53v67 = c53v67(c53v5, c53v55, c53v70)
      c53v48 = c53v47 * c53v67
      c53v67 = v23
      c53v67(c53v60, c53v62, c53v11, c53v48)
      c53v69 = c53v62.fallOff
      c53v68 = c53v69 * 100
      c53v69 = 0
      c53v67 = math.max
      c53v67 = c53v67(c53v68, c53v69)
      c53v68 = v13
      c53v69 = v11
      c53v69 = c53v69(c53v67)
      c53v71 = nil
      c53v68 = c53v68(c53v69, c53v67, c53v71)
      c53v60.DamageFallOff = c53v68
    end
    c53v67 = false
    c53v68 = false
    c53v69 = c53v1:Name__7ffc2d2c(c53v52)
    c53v75 = c53v1:GetMeleeTree()
    if not c53v73 then
      c53v78 = 6
      c53v76 = c53v33:Name__96ff68fb(c53v78)
      c53v77 = v22
      c53v78 = v33
      c53v77 = c53v77(c53v78(c53v76))
      c53v34.SlideAttack = c53v77
      c53v77 = c53v1:GetSlamRadius()
      c53v78 = IsNull
      c53v78 = c53v78(c53v1:GetFiringAvatar())
      if not c53v78 then
        c53v78 = c53v1:Name__e22fb830()
        c53v81 = c53v78.fallOffMax
        c53v80 = c53v81 * 100
        c53v81 = 0
        c53v79 = math.max
        c53v79 = c53v79(c53v80, c53v81)
        c53v80 = v22
        c53v81 = v33
        c53v80 = c53v80(c53v81(c53v78))
        c53v34.SlamAttack = c53v80
        c53v80 = c53v34.SlamAttack
        c53v82 = { TEXT = "/Lotus/Language/Stats/TIP_SlamAttackRadius", VARS = nil }
        c53v83 = { AMOUNT = nil }
        c53v83.AMOUNT = c53v77
        c53v82.VARS = c53v83
        c53v83 = { TEXT = "/Lotus/Language/Stats/TIP_SlamAttackFalloff", VARS = nil, comparisonFlipped = true }
        c53v84 = { AMOUNT = nil }
        c53v84.AMOUNT = c53v79
        c53v83.VARS = c53v84
        c53v81 = {c53v82, c53v83}
        c53v80.SecondaryToolTips = c53v81
      end
      c53v78 = IsNull
      c53v78 = c53v78(c53v75)
      if c53v78 then
        c53v80 = c53v75:Name__19894fe1()
        c53v81 = 311
        c53v82 = c53v1:GetType()
        c53v78 = c53v18:GetUpgradeModifiedValue(c53v80, c53v81, c53v82, c53v1)
        c53v79 = v13
        c53v80 = v11
        c53v81 = c53v78 * 100
        c53v80 = c53v80(c53v81)
        c53v82 = nil
        c53v79 = c53v79(c53v80, c53v78, c53v82)
        c53v34.FollowThrough = c53v79
        c53v81 = Symbol
        c53v82 = "SWORDS_AND_SHIELD_STANCE"
        c53v80 = c53v75:Name__64182bfb(c53v81(c53v82))
        if not c53v80 then
          c53v80 = c53v1:Name__c9440100()
        end
        c53v81 = c53v1:GetParryAngle()
        c53v82 = v13
        c53v83 = v21
        c53v83 = c53v83(c53v81)
        c53v85 = nil
        c53v86 = nil
        c53v87 = nil
        c53v89 = nil
        c53v90 = nil
        c53v91 = nil
        c53v92 = not c53v80
        c53v82 = c53v82(c53v83, c53v81, c53v85, c53v86, c53v87, c53v81, c53v89, c53v90, c53v91, c53v92)
        c53v34.BlockingAngle = c53v82
      end
    end
    c53v76 = c53v33:GetInitialHitCounter()
    c53v77 = c53v33:Name__fffb815c()
    c53v80 = true
    c53v78 = c53v33:Name__70a26833(c53v80)
    c53v79 = v10
    c53v81 = 1
    c53v79 = c53v79(c53v78, c53v81)
    if not ((not c53v77 or c53v78 == 0)) then
      c53v78 = 1e9999
      c53v82 = "<INFINITE_SMALL>"
      c53v83 = true
      c53v79 = c53v0:GetLocalized(c53v82, c53v83)
    end
    c53v82 = 1
    c53v83 = 317
    c53v84 = c53v1:GetType()
    c53v80 = c53v18:GetUpgradeModifiedValue(c53v82, c53v83, c53v84, c53v1)
    if c53v80 == 1 then
      c53v81 = false
    else
      c53v81 = true
    end
    c53v82 = c53v33:InfosClaw()
    c53v83 = v13
    c53v86 = nil
    c53v83 = c53v83(c53v79, c53v78, c53v86)
    c53v34.ComboDuration = c53v83
    c53v83 = c53v34.ComboDuration
    c53v84 = {}
    c53v83.SecondaryToolTips = c53v84
    if c53v82 then
      c53v83 = 0
      if c53v83 < c53v76 then
        c53v84 = c53v34.ComboDuration
        c53v84 = c53v84.SecondaryToolTips
        c53v85 = { TEXT = "/Lotus/Language/Stats/TIP_ComboCount", VARS = nil }
        c53v86 = { AMOUNT = nil }
        c53v86.AMOUNT = c53v76
        c53v85.VARS = c53v86
        c53v83 = table.insert
        c53v83(c53v84, c53v85)
      end
    end
    if c53v81 then
      c53v83 = 1
      if c53v83 < c53v80 then
        c53v84 = c53v80 - 1
        c53v83 = c53v84 * 100
        c53v85 = c53v34.ComboDuration
        c53v85 = c53v85.SecondaryToolTips
        c53v86 = { TEXT = "/Lotus/Language/Stats/TIP_ComboCountChance", VARS = nil }
        c53v87 = { AMOUNT = nil }
        c53v87.AMOUNT = c53v83
        c53v86.VARS = c53v87
        c53v84 = table.insert
        c53v84(c53v85, c53v86)
      end
    end
    c53v34 = c53v30.behaviorIndex
    c53v32 = c53v1:GetFireBehavior(c53v34)
    c53v35 = c53v30.behaviorIndex
    c53v33 = c53v1:GetImpactBehavior(c53v35)
    c53v36 = c53v30.behaviorIndex
    c53v37 = false
    c53v1:SetBehavior(c53v36, c53v37)
    c53v34 = {}
    c53v35 = c53v1:IsMeleeWeapon()
    if c53v35 then
      c53v37 = gMeleeImpactBehaviorType
      c53v35 = c53v33:IsA(c53v37)
    end
    c53v38 = Name__7e8c54ab
    c53v36 = c53v31:IsA(c53v38)
    c53v37 = nil
    c53v38 = false
    c53v39 = c53v30.extraStateBehavior
    if c53v39 then
      c53v39 = c53v31:Name__0641d38c()
      if c53v39 then
        c53v39 = "/Lotus/Language/Menu/SecondaryFire"
        c53v30.localizedTag = c53v39
      end
    end
    c53v39 = c53v30.localizedTag
    if c53v39 then
      c53v39 = { mName = nil, mIsMelee = nil, mBehaviorIndex = nil, mStats = nil }
      c53v40 = string.upper
      c53v43 = c53v30.localizedTag
      c53v44 = false
      c53v40 = c53v40(c53v0:GetLocalized(c53v43, c53v44))
      c53v39.mName = c53v40
      c53v39.mIsMelee = c53v36
      c53v40 = c53v30.behaviorIndex
      c53v39.mBehaviorIndex = c53v40
      c53v39.mStats = c53v34
      c53v37 = c53v39
      c53v39 = table.insert
      c53v39(c53v9, c53v37)
    end
    local c53v41 = 1
    c53v32:SetDeltaModifier(c53v41)
    if not c53v35 then
      c53v39 = c53v31:GetLocTag()
      c53v42 = c53v39:c_str()
      c53v43 = false
      c53v40 = c53v0:GetLocalized(c53v42, c53v43)
      if c53v40 ~= "" then
        c53v41 = StringSplit
        c53v42 = "/"
        c53v39 = c53v41(c53v42, c53v39)
        c53v41 = string.gsub
        c53v43 = #c53v39
        c53v42 = c53v39[c53v43]
        c53v43 = "Loadout_"
        c53v44 = ""
        c53v39 = c53v41(c53v42, c53v43, c53v44)
        c53v43 = gWeaponBurstStateBehaviorType
        c53v41 = c53v31:IsA(c53v43)
        if c53v41 then
          c53v41 = c53v31:Name__76f26b92()
          if c53v41 ~= nil then
            c53v43 = " "
            c53v46 = "/Lotus/Language/Stats/BurstNumShotsUnit"
            c53v47 = false
            c53v48 = { COUNT = nil }
            c53v48.COUNT = c53v41
            c53v44 = c53v0:GetLocalized(c53v46, c53v47, c53v48)
            c53v40 = c53v40 .. c53v43 .. c53v44
          end
        end
        c53v41 = v13
        c53v43 = nil
        c53v44 = true
        c53v45 = nil
        c53v41 = c53v41(c53v40, c53v43, c53v44, c53v45, c53v39)
        c53v34.Trigger = c53v41
      end
      c53v43 = gLotusWeaponProjectileFireBehaviorType
      c53v41 = c53v32:IsA(c53v43)
      if c53v41 then
        c53v41 = c53v32:Name__22e9974f()
        c53v42 = c53v32:Name__a27d16d0()
        if not ((not (c53v41 ~= 0) and c53v42 == 0)) then
          c53v43 = v13
          c53v48 = v0
          c53v48 = c53v48.FormatNumber
          c53v50 = 0
          c53v51 = false
          c53v45 = c53v48(c53v41, c53v50, c53v51)
          c53v46 = " - "
          c53v47 = v0
          c53v47 = c53v47.FormatNumber
          c53v49 = 0
          c53v50 = false
          c53v47 = c53v47(c53v42, c53v49, c53v50)
          c53v44 = c53v45 .. c53v46 .. c53v47
          c53v46 = nil
          c53v43 = c53v43(c53v44, c53v41, c53v46)
          c53v34.DT_StackDamage = c53v43
        end
      end
      c53v43 = 1
      c53v44 = 342
      c53v45 = c53v1:GetType()
      c53v41 = c53v18:GetUpgradeModifiedValue(c53v43, c53v44, c53v45, c53v1)
      if c53v41 ~= 0 then
        c53v42 = false
      else
        c53v42 = true
      end
      c53v43 = c53v1:IsSilent()
      c53v44 = c53v32:GetProjectileType()
      c53v45 = false
      c53v46 = IsNull
      c53v46 = c53v46(c53v44)
      if not c53v46 then
        c53v46 = Resource
        c53v44 = c53v46(c53v44)
        c53v46 = IsNull
        c53v46 = c53v46(c53v44)
        if not c53v46 then
          c53v45 = c53v44:Name__71a0f7f1()
        end
      end
      c53v46 = "/Lotus/Language/Labels/WEAPON_NOISELOUD"
      c53v47 = c53v43
      if not c53v47 then
        c53v47 = c53v45
        if not c53v47 then
          c53v47 = c53v42
        end
      end
      if c53v47 then
        c53v46 = "/Lotus/Language/Labels/WEAPON_NOISEQUIET"
      else
        c53v48 = 1
        if c53v41 < c53v48 then
          c53v48 = 0
          if c53v48 < c53v41 then
            c53v46 = "/Lotus/Language/Labels/WEAPON_NOISESUPPRESSED"
          end
        end
      end
      c53v48 = v13
      c53v52 = false
      c53v49 = c53v0:GetLocalized(c53v46, c53v52)
      c53v50 = nil
      c53v51 = true
      c53v52 = nil
      c53v53 = nil
      c53v54 = nil
      c53v55 = nil
      c53v56 = nil
      c53v57 = nil
      c53v58 = false
      if c53v41 == 1 then
        c53v58 = not c53v47
      end
      c53v48 = c53v48(c53v49, c53v50, c53v51, c53v52, c53v53, c53v54, c53v55, c53v56, c53v57, c53v58)
      c53v34.Noise = c53v48
    end
    c53v1:SetFullyCharged()
    c53v39 = 1
    c53v40 = c53v30.ignoreMultishot
    if not c53v40 then
      c53v39 = c53v32:Name__ce5dfdb0()
    end
    c53v40 = nil
    c53v41 = nil
    c53v42 = false
    c53v43 = false
    c53v44 = nil
    c53v45 = nil
    c53v46 = false
    c53v47 = c53v3
    c53v48 = 0
    c53v49 = false
    c53v50 = c53v1:Name__fa54e90a()
    c53v53 = Name__539c8440
    c53v51 = c53v31:IsA(c53v53)
    if c53v40 then
      c53v1:SetAmmoInClip(c53v1:Name__bc09d984(c53v5))
      c53v53 = 0
      c53v31:GotoState(c53v53)
      c53v47 = c53v31:Name__6760a39b()
      c53v51 = c53v31:Name__4f5ee78b()
      c53v52 = c53v31:Name__4f5ee78b()
      if not ((not ((c53v52 ~= 1 or c53v14)) and not c53v13)) then
        c53v54 = 1
        c53v31:SetDamageMultiplier(c53v54)
        c53v52 = c53v30.projectileType
        c53v53 = c53v30.behaviorIndex
        c53v54 = c53v30.turboGlaive
        c53v55 = v3
        c53v55 = c53v55.GetProjectileAndDamageData
        c53v55, c53v56 = c53v55(c53v1, c53v5, c53v52, c53v53, c53v54)
        c53v57 = v35
        c53v74 = "/Lotus/Language/Stats/QuickShot"
        c53v75 = "/Lotus/Language/Stats/QuickShotRadialAttack"
        c53v40, c53v41, c53v49 = c53v57(c53v0, c53v1, c53v55, c53v56, c53v30, c53v31, c53v32, c53v33, c53v36, c53v35, c53v11, c53v4, c53v3, c53v39, c53v5, c53v18, c53v74, c53v75, c53v17)
        c53v57 = true
        if c53v40 == nil then
          if c53v41 == nil then
            c53v57 = false
          else
            c53v57 = true
          end
        end
        c53v42 = c53v57
        c53v59 = gLotusWeaponProjectileFireBehaviorType
        c53v57 = c53v32:IsA(c53v59)
        if c53v40 ~= nil then
          c53v55 = c53v32:Name__e1882fa1()
          c53v57 = IsNull
          c53v57 = c53v57(c53v55)
          if not c53v57 then
            c53v57 = Resource
            c53v55 = c53v57(c53v55)
            c53v57 = IsNull
            c53v57 = c53v57(c53v55)
            if not c53v57 then
              c53v60 = 0
              c53v61 = c53v30.behaviorIndex
              c53v56 = c53v1:Name__1f4d79ac(c53v55, c53v60, c53v61)
              c53v57 = v35
              c53v74 = "/Lotus/Language/Stats/PerfectShot"
              c53v75 = "/Lotus/Language/Stats/PerfectShotRadialAttack"
              c53v44, c53v45, c53v38 = c53v57(c53v0, c53v1, c53v55, c53v56, c53v30, c53v31, c53v32, c53v33, c53v36, c53v35, c53v11, c53v4, c53v3, c53v39, c53v5, c53v18, c53v74, c53v75, c53v17)
              c53v57 = true
              if c53v44 == nil then
                if c53v45 == nil then
                  c53v57 = false
                else
                  c53v57 = true
                end
              end
              c53v46 = c53v57
            end
          end
        end
      end
      c53v52 = c53v1:GetChargeTime()
      c53v53 = 0
      if c53v50 <= c53v53 then
        c53v53 = IsNull
        c53v53 = c53v53(c53v18)
        if not c53v53 then
          c53v55 = 1
          c53v56 = 276
          c53v57 = c53v1:GetType()
          c53v50 = c53v18:GetUpgradeModifiedValue(c53v55, c53v56, c53v57, c53v1)
        end
      end
      c53v53 = v13
      c53v54 = v10
      c53v56 = 2
      c53v54 = c53v54(c53v52, c53v56)
      c53v55 = -c53v52
      c53v56 = nil
      c53v53 = c53v53(c53v54, c53v55, c53v56)
      c53v34.ChargeRate = c53v53
      c53v43 = true
      c53v53 = c53v32.chargedProjectileType
      c53v30.projectileType = c53v53
    else
      c53v53 = gWeaponBurstStateBehaviorType
      c53v51 = c53v31:IsA(c53v53)
      if c53v51 then
        c53v1:SetAmmoInClip(c53v1:Name__bc09d984(c53v5))
      end
    end
    if c53v42 then
      c53v51 = table.insert
      c53v51(c53v9, c53v40)
    end
    if c53v41 ~= nil then
      c53v51 = table.insert
      c53v51(c53v9, c53v41)
    end
    c53v51 = "/Lotus/Language/Labels/WEAPON_DAMAGE_AMOUNT"
    if c53v43 then
      c53v51 = "/Lotus/Language/Stats/ChargedShot"
    else
      c53v52 = c53v32.fireIterations
      c53v53 = 1
      if c53v53 < c53v52 then
        c53v51 = "/Lotus/Language/Game/DamagePerProjectile"
      end
    end
    c53v52 = v27
    c53v62 = c53v36 and c53v35
    c53v63 = Localize
    c53v65 = {}
    c53v63 = c53v63(c53v51, c53v65)
    c53v52, c53v53, c53v54 = c53v52(c53v1, c53v30, c53v32, c53v5, c53v11, c53v39, c53v47, c53v4, c53v9, c53v62, c53v63, c53v16)
    c53v55 = Resource
    c53v52 = c53v55(c53v52)
    c53v55 = v0
    c53v55 = c53v55.Ternary
    c53v57 = c53v53.hitType
    c53v58 = 2
    c53v76 = 1
    c53v77 = c53v52
    if c53v77 then
      c53v79 = WeakResource
      c53v80 = "/Lotus/Weapons/Infested/InfestedLich/LongGuns/1999InfShotgun/1999InfFaceSucker"
      c53v77 = c53v52:IsA(c53v79(c53v80))
    end
    if not (((not (not c53v36) and c53v35) or c53v77)) then
      c53v76 = c53v39
    end
    c53v78 = v24
    c53v82 = nil
    c53v83 = nil
    c53v78 = c53v78(c53v54, c53v11, c53v76, c53v82, c53v83, c53v1, c53v18)
    c53v79 = v31
    c53v81 = c53v30.upgrades
    c53v79(c53v18, c53v81, c53v1, c53v54)
    if not c53v77 then
      c53v79 = v0
      c53v79 = c53v79.Ternary
      c53v81 = c53v32.fireIterations
      c53v82 = 1
      if c53v81 <= c53v82 then
        c53v80 = false
      else
        c53v80 = true
      end
      c53v81 = "ProcChancePerShot"
      c53v82 = "ProcChance"
      c53v79 = c53v79(c53v80, c53v81, c53v82)
      c53v80 = 0
      c53v81 = c53v54[c53v79]
      if c53v81 ~= nil then
        c53v81 = c53v54[c53v79]
        c53v80 = c53v81.StatValue
        c53v81 = c53v54[c53v79]
        c53v82 = v9
        c53v87 = false
        c53v89 = v0
        c53v89 = c53v89.Ternary
        c53v92 = nil
        c53v82 = c53v82(c53v0, c53v54, c53v80, c53v78, c53v87, c53v33, c53v89(c53v35, c53v1, c53v92))
        c53v81.SecondaryToolTips = c53v82
      end
      c53v81 = c53v60[c53v79]
      if c53v81 ~= nil then
        c53v81 = c53v60[c53v79]
        c53v80 = c53v81.StatValue
      end
      c53v81 = 0
      if c53v82 < c53v81 then
        c53v81 = 0
        if c53v81 < c53v69 then
          c53v81 = c53v60[c53v79]
          c53v81 = c53v60[c53v79]
          c53v82 = v9
          c53v87 = false
          c53v89 = v0
          c53v89 = c53v89.Ternary
          c53v92 = nil
          c53v82 = c53v82(c53v0, c53v60, c53v80, c53v69, c53v87, c53v33, c53v89(c53v35, c53v1, c53v92))
          c53v81.SecondaryToolTips = c53v82
          c53v81 = c53v54[c53v79]
          c53v81 = c53v81.SecondaryToolTips
          if c53v81 == nil then
            c53v81 = c53v54[c53v79]
            c53v82 = {}
            c53v81.SecondaryToolTips = c53v82
          end
          c53v81 = v9
          c53v86 = true
          c53v88 = v0
          c53v88 = c53v88.Ternary
          c53v91 = nil
          c53v81 = c53v81(c53v0, c53v60, c53v80, c53v69, c53v86, c53v33, c53v88(c53v35, c53v1, c53v91))
          c53v83 = c53v54[c53v79]
          c53v83 = c53v83.SecondaryToolTips
          c53v84 = { TEXT = "/Lotus/Language/Stats/TIP_ProcChancePerRadialDT", VARS = nil }
          c53v85 = {}
          c53v84.VARS = c53v85
          c53v82 = table.insert
          c53v82(c53v83, c53v84)
          c53v82 = ipairs
          c53v82, c53v83, c53v84 = c53v82(c53v81)
          for c53v85, c53v86 in c53v82, c53v83, c53v84 do
            c53v88 = c53v54[c53v79]
            c53v88 = c53v88.SecondaryToolTips
            c53v87 = table.insert
            c53v87(c53v88, c53v86)
          end
          for c53v85, c53v86 in c53v82, c53v83, c53v84 do
          end
        end
      end
    end
    if c53v42 then
      c53v79 = #c53v9
      c53v80 = 1
      if c53v80 < c53v79 then
        c53v79 = #c53v9
        c53v80 = v26
        c53v81 = c53v9[c53v79]
        c53v83 = c53v79 - 1
        c53v82 = c53v9[c53v83]
        c53v80 = c53v80(c53v81, c53v82)
        if c53v80 then
          c53v80 = nil
          c53v9[c53v79] = c53v80
        end
      end
    end
    if c53v46 then
      c53v79 = table.insert
      c53v79(c53v9, c53v44)
    end
    if c53v45 ~= nil then
      c53v79 = table.insert
      c53v79(c53v9, c53v45)
    end
    c53v81 = gLotusWeaponType
    c53v79 = c53v1:IsA(c53v81)
    if not c53v42 then
      c53v81 = "ShouldShowOmegaAttenStat"
      c53v82 = ""
      c53v79 = c53v0:Execute(c53v81, c53v82)
      if not ((not c53v79 or c53v29 ~= 1)) then
        c53v79 = c53v1:GetOmegaAttenuation()
        c53v80 = ""
        c53v81 = 0.7
        if c53v79 < c53v81 then
          c53v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenLowest"
          c53v84 = true
          c53v80 = c53v0:GetLocalized(c53v83, c53v84)
        else
          c53v81 = 0.9
          if c53v79 < c53v81 then
            c53v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenLow"
            c53v84 = true
            c53v80 = c53v0:GetLocalized(c53v83, c53v84)
          else
            c53v81 = 1.109
            if c53v79 <= c53v81 then
              c53v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenMedium"
              c53v84 = true
              c53v80 = c53v0:GetLocalized(c53v83, c53v84)
            else
              c53v81 = 1.309
              if c53v79 <= c53v81 then
                c53v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenHigh"
                c53v84 = true
                c53v80 = c53v0:GetLocalized(c53v83, c53v84)
              else
                c53v83 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenHighest"
                c53v84 = true
                c53v80 = c53v0:GetLocalized(c53v83, c53v84)
              end
            end
          end
        end
        c53v81 = v13
        c53v84 = nil
        c53v81 = c53v81(c53v80, c53v79, c53v84)
        c53v34.OmegaAtten = c53v81
      end
    end
    c53v81 = gWeaponTraceFireBehaviorType
    c53v79 = c53v32:IsA(c53v81)
    if c53v79 then
      c53v79 = c53v32:Name__a75a0be1()
      if not c53v79 then
        c53v80 = c53v32:GetTracePunctureDepth()
        c53v81 = v13
        c53v82 = v0
        c53v82 = c53v82.FormatNumber
        c53v84 = 1
        c53v85 = false
        c53v82 = c53v82(c53v80, c53v84, c53v85)
        c53v83 = c53v80
        c53v84 = nil
        c53v85 = nil
        c53v86 = nil
        c53v87 = nil
        c53v88 = nil
        c53v89 = nil
        c53v90 = nil
        if c53v80 ~= 0 then
          c53v91 = false
        else
          c53v91 = true
        end
        c53v81 = c53v81(c53v82, c53v83, c53v84, c53v85, c53v86, c53v87, c53v88, c53v89, c53v90, c53v91)
        c53v34.Punchthrough = c53v81
      else
        c53v80 = v13
        c53v83 = "<INFINITE_SMALL>"
        c53v84 = true
        c53v81 = c53v0:GetLocalized(c53v83, c53v84)
        c53v82 = 4294967295
        c53v83 = nil
        c53v80 = c53v80(c53v81, c53v82, c53v83)
        c53v34.Punchthrough = c53v80
      end
      c53v82 = 1
      c53v83 = 380
      c53v84 = c53v1:GetType()
      c53v80 = c53v18:GetUpgradeModifiedValue(c53v82, c53v83, c53v84, c53v1)
      if c53v80 ~= 0 then
        c53v38 = false
      else
        c53v38 = true
      end
      c53v83 = gWeaponBeamFireBehaviorType
      c53v81 = c53v32:IsA(c53v83)
      if c53v81 then
        c53v81 = c53v32:Name__f8393ca5()
        c53v82 = v13
        c53v83 = v0
        c53v83 = c53v83.FormatNumber
        c53v85 = 1
        c53v86 = false
        c53v83 = c53v83(c53v81, c53v85, c53v86)
        c53v82 = c53v82(c53v83, c53v81)
        c53v34.BeamRange = c53v82
      end
    else
      c53v81 = gWeaponProjectileFireBehaviorType
      c53v79 = c53v32:IsA(c53v81)
      if c53v79 then
        c53v79 = 0
        c53v80 = false
        c53v81 = c53v30.turboGlaive
        if c53v81 == true then
          c53v79 = c53v1:Name__81e9daf5(c53v32:GetTurboProjectileType(c53v5))
        else
          c53v81 = c53v32:GetProjectileType()
          c53v82 = IsNull
          c53v82 = c53v82(c53v81)
          if not c53v82 then
            c53v84 = gWaveProjectileType
            c53v82 = c53v81:IsA(c53v84)
            if c53v82 then
              c53v82 = Resource
              c53v82 = c53v82(c53v81)
              c53v83 = IsNull
              c53v83 = c53v83(c53v82)
              if not c53v83 then
                c53v83 = c53v82:AllowNormalContactBehavior()
                c53v80 = not c53v83
              end
            end
          end
          c53v79 = c53v1:Name__81e9daf5(c53v32:GetProjectileType())
        end
        if c53v80 then
          c53v81 = v13
          c53v84 = "<INFINITE_SMALL>"
          c53v85 = true
          c53v82 = c53v0:GetLocalized(c53v84, c53v85)
          c53v83 = 4294967295
          c53v84 = nil
          c53v81 = c53v81(c53v82, c53v83, c53v84)
          c53v34.Punchthrough = c53v81
        else
          c53v81 = v13
          c53v82 = v0
          c53v82 = c53v82.FormatNumber
          c53v84 = 1
          c53v85 = false
          c53v82 = c53v82(c53v79, c53v84, c53v85)
          c53v83 = c53v79
          c53v84 = nil
          c53v85 = nil
          c53v86 = nil
          c53v87 = nil
          c53v88 = nil
          c53v89 = nil
          c53v90 = nil
          if c53v79 ~= 0 then
            c53v91 = false
          else
            c53v91 = true
          end
          c53v81 = c53v81(c53v82, c53v83, c53v84, c53v85, c53v86, c53v87, c53v88, c53v89, c53v90, c53v91)
          c53v34.Punchthrough = c53v81
        end
      end
    end
    if c53v38 then
      if not ((not (not c53v42) and not c53v49)) then
        c53v79 = c53v34.Punchthrough
        if c53v79 ~= nil then
          c53v79 = v13
          c53v85 = "<LOCKED> "
          c53v86 = true
          c53v81 = c53v0:GetLocalized(c53v85, c53v86)
          c53v82 = "0"
          c53v80 = c53v81 .. c53v82
          c53v81 = 0
          c53v82 = nil
          c53v79 = c53v79(c53v80, c53v81, c53v82)
          c53v34.Punchthrough = c53v79
        end
      end
    end
    c53v79 = 0
    c53v82 = gWeaponProjectileFireBehaviorType
    c53v80 = c53v32:IsA(c53v82)
    c53v80 = c53v79.maxValue
    c53v81 = 0
    if c53v81 < c53v80 then
      c53v80 = { minValue = nil, maxValue = nil }
      c53v83 = c53v79.minValue
      c53v84 = 379
      c53v85 = c53v1:GetType()
      c53v81 = c53v18:GetUpgradeModifiedValue(c53v83, c53v84, c53v85, c53v1)
      c53v80.minValue = c53v81
      c53v83 = c53v79.maxValue
      c53v84 = 379
      c53v85 = c53v1:GetType()
      c53v81 = c53v18:GetUpgradeModifiedValue(c53v83, c53v84, c53v85, c53v1)
      c53v80.maxValue = c53v81
      c53v79 = c53v80
      c53v80 = c53v79.maxValue
      c53v81 = 0
      if c53v81 < c53v80 then
        c53v80 = v20
        c53v81 = c53v79.minValue
        c53v82 = v0
        c53v82 = c53v82.Ternary
        c53v84 = c53v79.minValue
        c53v85 = 999.9
        if c53v85 <= c53v84 then
          c53v83 = false
        else
          c53v83 = true
        end
        c53v84 = 1
        c53v85 = 0
        c53v80 = c53v80(c53v81, c53v82(c53v83, c53v84, c53v85))
        c53v81 = v20
        c53v82 = c53v79.maxValue
        c53v83 = v0
        c53v83 = c53v83.Ternary
        c53v85 = c53v79.maxValue
        c53v86 = 999.9
        if c53v86 <= c53v85 then
          c53v84 = false
        else
          c53v84 = true
        end
        c53v85 = 1
        c53v86 = 0
        c53v81 = c53v81(c53v82, c53v83(c53v84, c53v85, c53v86))
        c53v84 = " - "
        c53v82 = c53v80 .. c53v84 .. c53v81
        c53v83 = v13
        c53v85 = c53v79.minValue
        c53v86 = false
        c53v87 = true
        c53v83 = c53v83(c53v82, c53v85, c53v86, c53v87)
        c53v34.DamageFallOff = c53v83
      else
        c53v80 = v13
        c53v81 = "0"
        c53v82 = 0
        c53v83 = false
        c53v84 = true
        c53v80 = c53v80(c53v81, c53v82, c53v83, c53v84)
        c53v34.DamageFallOff = c53v80
      end
    end
    c53v80 = v1
    c53v80 = c53v80.IsPseudoExalted
    c53v80 = c53v80(c53v1)
    if c53v80 <= c53v81 then
      c53v80 = _T.PseudoExaltedAdditionalStats
      if c53v80 ~= nil then
        c53v80 = _T.PseudoExaltedAdditionalStats.GetDamageData
        if c53v80 ~= nil then
          c53v80 = _T.PseudoExaltedAdditionalStats.mName
          if c53v80 ~= nil then
            c53v82 = true
            c53v33:SetAlternateAttack(c53v82)
            c53v80 = _T.PseudoExaltedAdditionalStats.GetDamageData
            c53v83 = c53v80()
            c53v33:Name__54e4179e(c53v83)
            c53v83 = false
            c53v33:SetAlternateAttack(c53v83)
            c53v81 = _T.PseudoExaltedAdditionalStats.mCritChance
            if c53v81 then
              c53v83 = 244
              c53v84 = 0
              c53v85 = _T.PseudoExaltedAdditionalStats.mCritMult
              c53v86 = c53v1:GetType()
              c53v18:AddUpgrade(c53v83, c53v84, c53v85, c53v86, c53v1)
            end
            c53v81 = _T.PseudoExaltedAdditionalStats.mCritMult
            if c53v81 then
              c53v83 = 248
              c53v84 = 0
              c53v85 = _T.PseudoExaltedAdditionalStats.mCritMult
              c53v86 = c53v1:GetType()
              c53v18:AddUpgrade(c53v83, c53v84, c53v85, c53v86, c53v1)
            end
            c53v81 = {}
            c53v82 = v25
            c53v82(c53v81, c53v80)
            c53v82 = v34
            c53v86 = c53v32:GetProjectileType()
            c53v95 = nil
            c53v82(c53v0, c53v81, c53v1, c53v86, c53v80, c53v30, c53v31, c53v32, c53v33, c53v36, c53v5, c53v18, c53v95, c53v17)
            c53v82 = _T.PseudoExaltedAdditionalStats.mCritChance
            if c53v82 then
              c53v84 = 244
              c53v85 = 0
              c53v86 = _T.PseudoExaltedAdditionalStats.mCritMult
              c53v87 = c53v1:GetType()
              c53v18:RemoveUpgrade(c53v84, c53v85, c53v86, c53v87, c53v1)
            end
            c53v82 = _T.PseudoExaltedAdditionalStats.mCritMult
            if c53v82 then
              c53v84 = 248
              c53v85 = 0
              c53v86 = _T.PseudoExaltedAdditionalStats.mCritMult
              c53v87 = c53v1:GetType()
              c53v18:RemoveUpgrade(c53v84, c53v85, c53v86, c53v87, c53v1)
            end
            c53v82 = next
            c53v82 = c53v82(c53v81)
            if c53v82 then
              c53v82 = { mName = nil, mBehaviorIndex = nil, mStats = nil, mExtra = true }
              c53v83 = string.upper
              c53v86 = _T.PseudoExaltedAdditionalStats.mName
              c53v87 = false
              c53v83 = c53v83(c53v0:GetLocalized(c53v86, c53v87))
              c53v82.mName = c53v83
              c53v83 = c53v30.behaviorIndex
              c53v82.mBehaviorIndex = c53v83
              c53v82.mStats = c53v81
              c53v83 = table.insert
              c53v83(c53v9, c53v82)
            end
          end
        end
      end
    end
    c53v80 = v28
    c53v80(c53v1, c53v34)
    c53v80 = v30
    c53v82 = c53v30.upgrades
    c53v80(c53v18, c53v82)
    c53v80 = v32
    c53v82 = c53v30.unusedStats
    c53v80(c53v34, c53v82)
    c53v9 = IsNull
    c53v9 = c53v9(c53v2)
    c53v24 = #c53v19
    c53v26 = { localizedTag = "/Lotus/Language/Menu/Loadout_FireModePrimary", behaviorIndex = 0 }
    c53v24 = table.insert
    c53v24(c53v23, c53v26)
    c53v26 = c53v1:IsMeleeWeapon()
    c53v26 = c53v1:GetNumUpgrades()
    c53v28 = #c53v23
    c53v27 = c53v23[c53v28]
    c53v28 = {}
    c53v27.upgrades = c53v28
    c53v29 = 0
    c53v27 = c53v26 - 1
    c53v28 = 1
    for c53v29 = c53v29, c53v27, c53v28 do
      c53v30 = c53v1:GetUpgrade(c53v29)
      c53v31 = IsNull
      c53v31 = c53v31(c53v30)
      if not c53v31 then
        c53v33 = gLotusArtifactUpgradeType
        c53v31 = c53v30:IsA(c53v33)
        c53v31 = c53v30:Deckww()
        c53v32 = pairs
        c53v32, c53v33, c53v34 = c53v32(c53v31)
        for c53v35, c53v36 in c53v32, c53v33, c53v34 do
          c53v37 = IsNull
          c53v37 = c53v37(c53v30)
          if not c53v37 then
            c53v37 = IsNull
            c53v37 = c53v37(c53v36)
            if not c53v37 then
              c53v37 = Resource
              c53v37 = c53v37(c53v36)
              c53v40 = 1
              c53v38 = c53v37:GetNumUpgrades()
              c53v39 = 1
              for c53v40 = c53v40, c53v38, c53v39 do
                c53v43 = #c53v23
                c53v42 = c53v23[c53v43]
                c53v42 = c53v42.upgrades
                c53v45 = c53v40 - 1
                c53v41 = table.insert
                c53v41(c53v42, c53v37:GetUpgrade(c53v45))
              end
            end
          end
        end
        for c53v35, c53v36 in c53v32, c53v33, c53v34 do
        end
      end
    end
    c53v24 = ipairs
    c53v24, c53v25, c53v26 = c53v24(c53v19)
    for c53v27, c53v28 in c53v24, c53v25, c53v26 do
      if c53v27 <= c53v20 then
        c53v31 = { localizedTag = nil, behaviorIndex = nil }
        c53v32 = c53v28.localizedTag
        c53v31.localizedTag = c53v32
        c53v32 = c53v28.behaviorIndex
        c53v31.behaviorIndex = c53v32
        c53v29 = table.insert
        c53v29(c53v23, c53v31)
      end
    end
    c53v9 = IsNull
    c53v9 = c53v9(c53v2)
    if c53v9 then
      c53v9 = v1
      c53v9 = c53v9.GetMainMenuSuitAvatar
      c53v2 = c53v9()
    end
    c53v9 = IsNull
    c53v9 = c53v9(c53v1)
    c53v24 = c53v1:IsEvolvingWeapon()
    c53v25 = IsNull
    c53v25 = c53v25(c53v1:GetEvolutionReq())
    if not c53v25 then
      c53v27 = 9
      c53v25 = c53v1:HasFeature(c53v27)
      if not c53v25 then
        c53v26 = _T.ZarimanEvolution_Open
        if c53v26 ~= true then
          c53v25 = false
        else
          c53v25 = true
        end
      end
    end
    c53v9 = {}
    if c53v3 == nil then
      c53v3 = 1
    end
    c53v12 = gLotusHybridWeaponType
    c53v10 = c53v1:IsA(c53v12)
    if c53v3 ~= nil then
      c53v10 = c53v1:GetChildWeapon(c53v2)
      c53v11 = IsNull
      c53v11 = c53v11(c53v10)
      if not c53v11 then
        c53v11 = IsWeak
        c53v11 = c53v11(c53v10)
        if c53v11 then
          c53v11 = Resource
          c53v10 = c53v11(c53v10)
        end
        c53v1 = c53v10
      end
    end
    if c53v7 then
      c53v12 = true
      c53v1:Name__392c190e(c53v12)
      c53v10 = _T.mMechaSuitMode
      if c53v10 then
        c53v12 = true
        c53v1:Name__4de9e1f8(c53v12)
        c53v12 = 1
        c53v1:Name__19307ea9(c53v12)
      else
        c53v1:Name__19307ea9(c53v1:Name__974a9860())
      end
    end
    c53v10 = v1
    c53v10 = c53v10.GetDamageTypeTag
    c53v13 = WeakResource
    c53v14 = "/Lotus/Weapons/CrewShip/RailjackWeapon"
    c53v11 = c53v1:IsA(c53v13(c53v14))
    c53v14 = WeakResource
    c53v15 = "/Lotus/Weapons/Tenno/Pistols/PrimeBallistica/PrimeBallistica"
    c53v12 = c53v1:IsA(c53v14(c53v15))
    c53v15 = WeakResource
    c53v16 = "/Lotus/Weapons/Syndicates/RedVeil/Pistols/RVBallistica"
    c53v13 = c53v1:IsA(c53v15(c53v16))
    c53v14 = not c53v12
    if c53v14 then
      c53v14 = not c53v13
      if c53v14 then
        c53v16 = WeakResource
        c53v17 = "/Lotus/Weapons/Tenno/Pistols/AutomaticHandCrossbow/AutoCrossBow"
        c53v14 = c53v1:IsA(c53v16(c53v17))
      end
    end
    c53v17 = WeakResource
    c53v18 = "/Lotus/Weapons/Infested/InfestedLich/Pistols/CodaCatabolyst"
    c53v15 = c53v1:IsA(c53v17(c53v18))
    c53v18 = WeakResource
    c53v19 = "/Lotus/Weapons/Tenno/Archwing/Primary/NokkoArchGun/NokkoArchGun"
    c53v16 = c53v1:IsA(c53v18(c53v19))
    c53v19 = WeakResource
    c53v20 = "/Lotus/Weapons/Grineer/Pistols/GrineerCrossbow/GrineerGooGun"
    c53v17 = c53v1:IsA(c53v19(c53v20))
    c53v18 = c53v2:InventoryControl()
    c53v19 = c53v1:GetFireModes()
    c53v20 = c53v1:Name__ddcba1ac()
    c53v21 = false
    c53v22 = 1
    if c53v22 < c53v20 then
      c53v22 = c53v1:IsAlternateFireDisabled()
      if c53v22 then
        c53v20 = 1
      end
    end
    c53v22 = false
    c53v23 = #c53v19
    if c53v23 == 0 then
      c53v23 = 1
      if c53v20 <= c53v23 then
        c53v22 = false
      else
        c53v22 = true
      end
    end
    c53v23 = IsNull
    c53v23 = c53v23(c53v8)
    if not c53v23 then
      c53v25 = "/Lotus/Language/Stats/Loadout_UpgradeWeaponBonus"
      c53v26 = false
      c53v23 = c53v0:GetLocalized(c53v25, c53v26)
      c53v24 = {}
      c53v28 = v0
      c53v28 = c53v28.FormatNumber
      c53v30 = c53v8.DmgVal
      c53v29 = c53v30 * 100
      c53v30 = 1
      c53v31 = false
      c53v26 = c53v28(c53v29, c53v30, c53v31)
      c53v27 = "%"
      c53v25 = c53v26 .. c53v27
      c53v26 = v13
      c53v28 = c53v8.DmgVal
      c53v26 = c53v26(c53v25, c53v28)
      c53v24.UpgradeBonus = c53v26
      c53v26 = c53v24.UpgradeBonus
      c53v27 = "UpgradeBonus"
      c53v26.Key = c53v27
      c53v26 = v1
      c53v26 = c53v26.GetDamageTypeTag
      c53v27 = c53v8.DmgType
      c53v26 = c53v26(c53v27)
      c53v27 = c53v24.UpgradeBonus
      c53v28 = TitleCase
      c53v32 = "/Lotus/Language/Game/"
      c53v31 = c53v32 .. c53v26
      c53v32 = true
      c53v28 = c53v28(c53v0:GetLocalized(c53v31, c53v32))
      c53v27.Label = c53v28
      c53v28 = "/Lotus/Language/Game/"
      c53v30 = "_NoIcon"
      c53v27 = c53v28 .. c53v26 .. c53v30
      c53v31 = false
      c53v28 = c53v0:GetLocalized(c53v27, c53v31)
      if c53v28 == c53v27 then
        c53v31 = "/Lotus/Language/Game/"
        c53v30 = c53v31 .. c53v26
        c53v31 = true
        c53v27 = c53v0:GetLocalized(c53v30, c53v31)
      else
        c53v31 = false
        c53v27 = c53v0:GetLocalized(c53v27, c53v31)
      end
      c53v28 = c53v24.UpgradeBonus
      c53v28.SearchLabel = c53v27
      c53v28 = c53v24.UpgradeBonus
      c53v31 = "/Lotus/Language/Stats/Loadout_UpgradeWeaponBonus_TooltipLabel"
      c53v32 = false
      c53v29 = c53v0:GetLocalized(c53v31, c53v32)
      c53v28.HeaderOverride = c53v29
      c53v28 = c53v24.UpgradeBonus
      c53v31 = "/Lotus/Language/Stats/Loadout_UpgradeWeaponBonus_Desc"
      c53v32 = false
      c53v29 = c53v0:GetLocalized(c53v31, c53v32)
      c53v28.ToolTip = c53v29
      c53v28 = { mName = nil, mIsMelee = false, mBehaviorIndex = 0, mStats = nil }
      c53v29 = string.upper
      c53v29 = c53v29(c53v23)
      c53v28.mName = c53v29
      c53v28.mStats = c53v24
      c53v29 = table.insert
      c53v29(c53v9, c53v28)
    end
    c53v23 = {}
    c53v24 = IsNull
    c53v24 = c53v24(c53v19)
    if c53v9 then
      c53v9 = nil
      do return c53v9 end
    end
    if not c53v9 then
    end
    if not c53v9 then
      c53v26 = 2
      if c53v26 < c53v20 then
        c53v20 = c53v20 - 1
      end
    end
    if not c53v9 then
      c53v26 = { upgrades = nil, localizedTag = "/Lotus/Language/Mods/ZarimanRifleAltFireUnlockEvo", behaviorIndex = 0 }
      c53v27 = {}
      c53v26.upgrades = c53v27
      c53v27 = c53v1:GetEvolutionInfo()
      c53v28 = {}
      c53v29 = c53v1:Name__26aaad0c()
      c53v29 = Resource
      c53v33 = c53v27.mEvolutions
      c53v32 = c53v33[1]
      c53v32 = c53v32:Name__a013d615()
      c53v31 = c53v32[1]
      c53v31 = c53v31.mUpgrades
      c53v30 = c53v31[1]
      c53v29 = c53v29(c53v30)
      c53v28 = {}
      c53v30 = table.insert
      c53v30(c53v28, c53v29)
      c53v29 = c53v1:Name__da70379a()
      c53v30 = pairs
      c53v30, c53v31, c53v32 = c53v30(c53v29)
      for c53v33, c53v34 in c53v30, c53v31, c53v32 do
        c53v35 = IsNull
        c53v35 = c53v35(c53v34)
        if not c53v35 then
          c53v37 = Resource
          c53v35 = table.insert
          c53v35(c53v28, c53v37(c53v34))
        end
      end
      for c53v33, c53v34 in c53v30, c53v31, c53v32 do
      end
      c53v29 = pairs
      c53v29, c53v30, c53v31 = c53v29(c53v28)
      for c53v32, c53v33 in c53v29, c53v30, c53v31 do
        c53v34 = IsNull
        c53v34 = c53v34(c53v33)
        if not c53v34 then
          c53v36 = 1
          c53v34 = c53v33:GetNumUpgrades()
          c53v35 = 1
          for c53v36 = c53v36, c53v34, c53v35 do
            c53v38 = c53v26.upgrades
            c53v41 = c53v36 - 1
            c53v37 = table.insert
            c53v37(c53v38, c53v33:GetUpgrade(c53v41))
          end
          c53v36 = gLotusArtifactUpgradeType
          c53v34 = c53v33:IsA(c53v36)
          c53v34 = c53v33:Deckww()
          c53v35 = pairs
          c53v35, c53v36, c53v37 = c53v35(c53v34)
          for c53v38, c53v39 in c53v35, c53v36, c53v37 do
            c53v40 = IsNull
            c53v40 = c53v40(c53v39)
            if not c53v40 then
              c53v40 = Resource
              c53v40 = c53v40(c53v39)
              c53v43 = 1
              c53v41 = c53v40:GetNumUpgrades()
              c53v42 = 1
              for c53v43 = c53v43, c53v41, c53v42 do
                c53v45 = c53v26.upgrades
                c53v48 = c53v43 - 1
                c53v44 = table.insert
                c53v44(c53v45, c53v40:GetUpgrade(c53v48))
              end
            end
          end
          for c53v38, c53v39 in c53v35, c53v36, c53v37 do
          end
        end
      end
      c53v29 = table.insert
      c53v29(c53v23, c53v26)
    end
    c53v19 = c53v23
    c53v28 = gLotusSentinelAvatarType
    c53v26 = c53v2:IsA(c53v28)
    if not c53v9 then
      c53v26 = _T.ScriptedFireModes
      if c53v26 then
        c53v28 = _T.ScriptedFireModes.mWeaponType
        c53v26 = c53v1:IsA(c53v28)
        if c53v26 then
          c53v26 = ipairs
          c53v27 = _T.ScriptedFireModes.mStats
          c53v26, c53v27, c53v28 = c53v26(c53v27)
          for c53v29, c53v30 in c53v26, c53v27, c53v28 do
            c53v31 = c53v1:Name__4648fc4e()
            c53v32 = c53v30.weaponSlot
            if c53v31 == c53v32 then
              c53v31 = table.insert
              c53v31(c53v19, c53v30)
            end
          end
          c53v26 = c53v1:Name__6a099bbc()
          for c53v29, c53v30 in c53v26, c53v27, c53v28 do
            c53v26 = WeakResource
            c53v27 = "/Lotus/Types/Weapon/GlaiveProjectileFireBehavior"
            c53v26 = c53v26(c53v27)
            c53v29 = 0
            c53v27 = c53v20 - 1
            c53v28 = 1
            for c53v29 = c53v29, c53v27, c53v28 do
              c53v30 = c53v1:GetFireBehavior(c53v29)
              c53v30 = c53v30:IsA(c53v26)
              if c53v30 then break end
              if c53v30 then
                c53v21 = true
                c53v32 = 1
                c53v30 = #c53v19
                c53v31 = 1
                for c53v32 = c53v32, c53v30, c53v31 do
                  c53v33 = c53v19[c53v32]
                  c53v33 = c53v33.behaviorIndex
                  if c53v33 == c53v29 then break end
                  if c53v33 == c53v29 then
                    c53v33 = c53v19[c53v32]
                    c53v34 = false
                    c53v33.turboGlaive = c53v34
                    c53v33 = { localizedTag = "/Lotus/Language/Menu/Loadout_FireModeTurboThrow", behaviorIndex = nil, turboGlaive = true }
                    c53v33.behaviorIndex = c53v29
                    c53v34 = table.insert
                    c53v34(c53v19, c53v33)
                  else
                  end
                end
              end
            end
          end
        end
      end
    end
    if c53v22 then
      c53v28 = #c53v19
      c53v26 = c53v20 - 1
      c53v27 = 1
      for c53v28 = c53v28, c53v26, c53v27 do
        c53v31 = { behaviorIndex = nil, extraStateBehavior = true }
        c53v31.behaviorIndex = c53v28
        c53v29 = table.insert
        c53v29(c53v19, c53v31)
      end
    end
    c53v26 = ipairs
    c53v26, c53v27, c53v28 = c53v26(c53v19)
    if c53v20 <= c53v31 then
      c53v31 = print
      c53v33 = "Error: Invalid fire mode behavior index for weapon "
      c53v34 = c53v1:GetName()
      c53v35 = " fireMode index = "
      c53v36 = tostring
      c53v36 = c53v36(c53v29)
      c53v32 = c53v33 .. c53v34 .. c53v35 .. c53v36
      c53v31(c53v32)
    end
    c53v26 = IsNull
    c53v26 = c53v26(c53v1)
    if not c53v26 then
      c53v26 = c53v1:GetBehavior()
      if c53v26 ~= 0 then
        c53v28 = 0
        c53v29 = false
        c53v1:SetBehavior(c53v28, c53v29)
      end
    end
    c53v26 = _T.PseudoExaltedAdditionalStats
    local p968 = 561
    if p968 == 561 then
      c53v26 = _T.PseudoExaltedAdditionalStats.GetStats
      if c53v26 == nil then
      else
        p968 = 562
      end
    end
    if p968 == 562 then
      c53v26 = {}
      c53v27 = _T.PseudoExaltedAdditionalStats.GetStats
      c53v30 = _T.MenuSuitAvatar
      c53v29 = IsNull
      c53v29 = c53v29(c53v30)
      if c53v29 then
        p968 = 564
      else
        p968 = 563
      end
    end
    if p968 == 563 then
      c53v28 = _T.MenuSuitAvatar
      if c53v28 then
        p968 = 565
      else
        p968 = 564
      end
    end
    if p968 == 564 then
      c53v28 = gRegion
      c53v28 = c53v28:GetLocalPlayerAvatar()
      p968 = 565
    end
    if p968 == 565 then
      c53v28 = c53v27(c53v28)
      c53v29 = nil
      c53v30 = nil
      for c53v31, c53v32 in c53v28, c53v29, c53v30 do
        c53v33 = c53v32.StatTag
        c53v34 = v13
        c53v37 = c53v32.ValueUnit
        c53v38 = true
        c53v39 = { COUNT = nil }
        c53v40 = c53v32.Value
        c53v39.COUNT = c53v40
        c53v35 = c53v0:GetLocalized(c53v37, c53v38, c53v39)
        c53v36 = c53v32.Value
        c53v37 = false
        c53v38 = true
        c53v34 = c53v34(c53v35, c53v36, c53v37, c53v38)
        c53v26[c53v33] = c53v34
      end
      c53v28 = next
      c53v28 = c53v28(c53v26)
      if c53v28 then
        c53v28 = { mName = nil, mBehaviorIndex = 0, mStats = nil, mExtra = true }
        c53v29 = string.upper
        c53v32 = _T.PseudoExaltedAdditionalStats.mName
        c53v33 = false
        c53v29 = c53v29(c53v0:GetLocalized(c53v32, c53v33))
        c53v28.mName = c53v29
        c53v28.mStats = c53v26
        c53v29 = table.insert
        c53v29(c53v9, c53v28)
      end
    end
    for c53v31, c53v32 in c53v28, c53v29, c53v30 do
    end
    if c53v16 then
      c53v26 = v24
      c53v27 = c53v9[2]
      c53v27 = c53v27.mStats
      c53v29 = 6
      c53v30 = nil
      c53v31 = c53v9[3]
      c53v31 = c53v31.mStats
      c53v26(c53v27, c53v11, c53v29, c53v30, c53v31)
      c53v26 = v24
      c53v28 = #c53v9
      c53v27 = c53v9[c53v28]
      c53v27 = c53v27.mStats
      c53v29 = 6
      c53v30 = nil
      c53v31 = c53v9[4]
      c53v31 = c53v31.mStats
      c53v26(c53v27, c53v11, c53v29, c53v30, c53v31)
      c53v26 = table.remove
      c53v28 = #c53v9
      c53v26 = c53v26(c53v9, c53v28)
      c53v29 = 3
      c53v27 = table.insert
      c53v27(c53v9, c53v29, c53v26)
    end
    if c53v7 then
      c53v1:Name__77aaecad()
      c53v28 = false
      c53v1:Name__392c190e(c53v28)
    end
    do return c53v9 end
  end
  v37 = function()
    local c54v0, c54v1, c54v2
    c54v0 = 2
    c54v1 = getfenv
    c54v1 = c54v1(c54v0)
    while true do
      c54v2 = c54v1.mMovie
      if c54v2 then break end
      c54v0 = c54v0 + 1
      c54v2 = getfenv
      c54v1 = c54v2(c54v0)
    end
    do return c54v1 end
  end
  v38 = function(c56v0, c56v1, c56v2, c56v3, c56v4, c56v5, c56v6)
    local c56v7, c56v8, c56v9, c56v10, c56v11, c56v12, c56v13, c56v14, c56v15, c56v16, c56v17, c56v18, c56v19, c56v20, c56v21, c56v22, c56v23, c56v24, c56v25, c56v26, c56v27, c56v28, c56v29, c56v30, c56v31, c56v32, c56v33, c56v34, c56v35, c56v36, c56v37, c56v38, c56v39, c56v40, c56v41, c56v42
    c56v34 = c56v33.Label
    c56v34 = nil
    c56v10[c56v32] = c56v34
    c56v38 = 1
    c56v39 = 1
    c56v36 = string.sub
    c56v36 = c56v36(c56v22, c56v38, c56v39)
    c56v22 = ""
    c56v36 = c56v33.ToolTip
    if c56v36 ~= nil then
      c56v39 = "/Lotus/Language/Stats/TIP_"
      c56v40 = c56v33.ToolTip
      c56v38 = c56v39 .. c56v40
      c56v39 = true
      c56v40 = { OPEN_COLOR = nil, CLOSE_COLOR = "</font>", AMOUNT = nil, LABEL = nil }
      c56v40.OPEN_COLOR = c56v34
      c56v40.AMOUNT = c56v35
      c56v41 = c56v33.ToolTipLabel
      c56v40.LABEL = c56v41
      c56v23 = c56v8:GetLocalized(c56v38, c56v39, c56v40)
      c56v36 = #c56v23
      c56v37 = 0
      if c56v37 < c56v36 then
        c56v38 = 1
        c56v39 = 1
        c56v36 = string.sub
        c56v36 = c56v36(c56v23, c56v38, c56v39)
        if c56v36 ~= "/" then
          c56v36 = #c56v22
          c56v37 = 0
          if c56v37 < c56v36 then
            c56v37 = "\r"
            c56v22 = c56v22 .. c56v37 .. c56v23
          else
            c56v22 = c56v23
          end
        end
      end
    end
    c56v36 = #c56v22
    c56v37 = 0
    if c56v37 < c56v36 then
      c56v33.ToolTip = c56v22
    end
    for c56v27, c56v28 in c56v24, c56v25, c56v26 do
      do return c56v9 end
    end
    c56v29 = pairs
    c56v30 = c56v28.mStats
    c56v29, c56v30, c56v31 = c56v29(c56v30)
    for c56v32, c56v33 in c56v29, c56v30, c56v31 do
      c56v35 = "<font color=\"#"
      c56v38 = string.format
      c56v39 = "%X"
      c56v40 = v2
      c56v40 = c56v40.GetColor
      c56v41 = 10
      c56v42 = true
      c56v36 = c56v38(c56v39, c56v40(c56v41, c56v42))
      c56v37 = "\">"
      c56v34 = c56v35 .. c56v36 .. c56v37
      c56v35 = c56v33.ToolTipValue
      if c56v35 ~= nil then
        c56v37 = "<b>"
        c56v39 = "</b></font>"
        c56v35 = c56v34 .. c56v37 .. c56v35 .. c56v39
      end
      c56v36 = string.find
      c56v38 = "EmbedDT_"
      c56v36 = c56v36(c56v32, c56v38)
      if c56v36 ~= nil then
        c56v36 = string.gsub
        c56v38 = "Embed"
        c56v39 = ""
        c56v32 = c56v36(c56v32, c56v38, c56v39)
      end
      c56v39 = "/Lotus/Language/Stats/TIP_"
      c56v38 = c56v39 .. c56v32
      c56v39 = true
      c56v40 = { OPEN_COLOR = nil, CLOSE_COLOR = "</font>", AMOUNT = nil, LABEL = nil }
      c56v40.OPEN_COLOR = c56v34
      c56v40.AMOUNT = c56v35
      c56v41 = c56v33.ToolTipLabel
      c56v40.LABEL = c56v41
      c56v22 = c56v8:GetLocalized(c56v38, c56v39, c56v40)
      c56v36 = #c56v22
      c56v22 = v16
      c56v22 = c56v22(c56v0)
      c56v22 = IsNull
      c56v22 = c56v22(c56v1)
      c56v33 = WeakResource
      c56v34 = "/Lotus/Weapons/CrewShip/RailjackOrdnanceWeapon"
      c56v31 = c56v22:IsA(c56v33(c56v34))
      c56v32 = "Mag"
      c56v33 = "/Lotus/Language/Labels/WEAPON_HEAT_CLIP"
      c56v11(c56v32, c56v33)
      c56v32 = "AmmoReq"
      c56v33 = "/Lotus/Language/Labels/WEAPON_HEAT_GENERATION"
      c56v11(c56v32, c56v33)
      c56v32 = "Mag"
      c56v33 = "/Lotus/Language/Labels/WEAPON_CLIP"
      c56v34 = 3
      c56v11(c56v32, c56v33, c56v34)
      c56v23 = #c56v21
      c56v24 = 1
      if c56v24 < c56v23 then
        c56v23 = table.remove
        c56v25 = #c56v21
        c56v23(c56v21, c56v25)
      end
      if not ((c56v17 or c56v13)) then
        c56v9 = c56v21
      end
      c56v23 = #c56v21
      c56v24 = 1
      if c56v24 < c56v23 then
        c56v25 = WeakResource
        c56v26 = "/Lotus/Powersuits/Alchemist/AlchemistBaseSuit"
        c56v23 = c56v0:IsA(c56v25(c56v26))
        c56v24 = c56v21[2]
        c56v10 = c56v24.mStats
        c56v25 = "Power_Strength"
        c56v26 = "/Lotus/Language/Labels/AVATAR_ABILITY_STRENGTH"
        c56v11(c56v25, c56v26)
        if c56v23 then
          c56v25 = "Status_Duration_Lavos"
          c56v31 = "<WARNING> "
          c56v32 = true
          c56v27 = c56v8:GetLocalized(c56v31, c56v32)
          c56v30 = "/Lotus/Language/Labels/WEAPON_PROC_TIME"
          c56v31 = true
          c56v28 = c56v8:GetLocalized(c56v30, c56v31)
          c56v26 = c56v27 .. c56v28
          c56v27 = nil
          c56v28 = "/Lotus/Language/Labels/WEAPON_PROC_TIME"
          c56v11(c56v25, c56v26, c56v27, c56v28)
          c56v25 = "Power_Efficiency_Lavos"
          c56v31 = "<WARNING> "
          c56v32 = true
          c56v27 = c56v8:GetLocalized(c56v31, c56v32)
          c56v30 = "/Lotus/Language/Labels/AVATAR_ABILITY_EFFICIENCY"
          c56v31 = true
          c56v28 = c56v8:GetLocalized(c56v30, c56v31)
          c56v26 = c56v27 .. c56v28
          c56v27 = nil
          c56v28 = "/Lotus/Language/Labels/AVATAR_ABILITY_EFFICIENCY"
          c56v11(c56v25, c56v26, c56v27, c56v28)
        else
          c56v25 = "Power_Efficiency"
          c56v26 = "/Lotus/Language/Labels/AVATAR_ABILITY_EFFICIENCY"
          c56v11(c56v25, c56v26)
        end
        c56v25 = "Power_Range"
        c56v26 = "/Lotus/Language/Labels/AVATAR_ABILITY_RANGE"
        c56v11(c56v25, c56v26)
        c56v25 = "Power_Duration"
        c56v26 = "/Lotus/Language/Labels/AVATAR_ABILITY_DURATION"
        c56v11(c56v25, c56v26)
      end
      if c56v14 then
        c56v22 = c56v0:GetOwner()
        c56v22 = c56v22:MotionControl()
        c56v23 = IsNull
        c56v23 = c56v23(c56v22)
        if not c56v23 then
          c56v25 = gHoverboardMotionControllerType
          c56v23 = c56v22:IsA(c56v25)
          if c56v23 then
            c56v24 = { mName = "", mStats = nil, mIsMelee = false }
            c56v25 = {}
            c56v24.mStats = c56v25
            c56v9 = {c56v24}
            c56v23 = c56v9[1]
            c56v23 = c56v23.mStats
            c56v24 = c56v22:Name__667aeb05()
            c56v27 = true
            c56v25 = c56v22:Name__3904d0a3(c56v27)
            c56v28 = true
            c56v29 = true
            c56v26 = c56v22:Name__3df08c85(c56v28, c56v29)
            c56v27 = c56v22:GetDoubleJumpHeight()
            c56v28 = c56v22:GetJumpChargeTime()
            c56v29 = v13
            c56v30 = v0
            c56v30 = c56v30.FormatNumber
            c56v32 = 2
            c56v33 = false
            c56v30 = c56v30(c56v24, c56v32, c56v33)
            c56v32 = nil
            c56v33 = true
            c56v29 = c56v29(c56v30, c56v24, c56v32, c56v33)
            c56v23.JumpHeight = c56v29
            c56v29 = v13
            c56v30 = v0
            c56v30 = c56v30.FormatNumber
            c56v32 = 2
            c56v33 = false
            c56v30 = c56v30(c56v25, c56v32, c56v33)
            c56v32 = nil
            c56v33 = true
            c56v29 = c56v29(c56v30, c56v25, c56v32, c56v33)
            c56v23.VehicleSpeed = c56v29
            c56v29 = v13
            c56v30 = v0
            c56v30 = c56v30.FormatNumber
            c56v32 = 2
            c56v33 = false
            c56v30 = c56v30(c56v26, c56v32, c56v33)
            c56v32 = nil
            c56v33 = true
            c56v29 = c56v29(c56v30, c56v26, c56v32, c56v33)
            c56v23.BoostSpeed = c56v29
            c56v29 = v13
            c56v30 = v0
            c56v30 = c56v30.FormatNumber
            c56v32 = 2
            c56v33 = false
            c56v30 = c56v30(c56v27, c56v32, c56v33)
            c56v32 = nil
            c56v33 = true
            c56v29 = c56v29(c56v30, c56v27, c56v32, c56v33)
            c56v23.DoubleJumpHeight = c56v29
            c56v29 = v13
            c56v30 = v0
            c56v30 = c56v30.FormatNumber
            c56v32 = 2
            c56v33 = false
            c56v30 = c56v30(c56v28, c56v32, c56v33)
            c56v31 = -c56v28
            c56v32 = nil
            c56v33 = true
            c56v29 = c56v29(c56v30, c56v31, c56v32, c56v33)
            c56v23.JumpChargeTime = c56v29
            c56v29 = c56v9[1]
            c56v10 = c56v29.mStats
            c56v30 = "JumpHeight"
            c56v31 = "/Lotus/Language/Labels/VEHICLE_JUMP_HEIGHT"
            c56v11(c56v30, c56v31)
            c56v30 = "VehicleSpeed"
            c56v31 = "/Lotus/Language/Labels/VEHICLE_SPEED"
            c56v11(c56v30, c56v31)
            c56v30 = "BoostSpeed"
            c56v31 = "/Lotus/Language/Labels/VEHICLE_SPRINT_SPEED"
            c56v11(c56v30, c56v31)
            c56v30 = "JumpChargeTime"
            c56v31 = "/Lotus/Language/Labels/VEHICLE_JUMP_CHARGE_TIME"
            c56v11(c56v30, c56v31)
            c56v30 = "DoubleJumpHeight"
            c56v31 = "/Lotus/Language/Labels/VEHICLE_DOUBLE_JUMP_HEIGHT"
            c56v11(c56v30, c56v31)
          end
        end
      end
      c56v10 = c56v30.mStats
      c56v31 = true
      c56v30.mIsWeapon = c56v31
      c56v31 = IsNull
      c56v31 = c56v31(c56v22)
      if not c56v31 then
        c56v33 = gWeaponExType
        c56v31 = c56v22:IsA(c56v33)
        if c56v31 then
          c56v31 = c56v30.mBehaviorIndex
          c56v32 = c56v22:Name__ddcba1ac()
          if c56v31 < c56v32 then
            c56v33 = c56v30.mBehaviorIndex
            c56v23 = c56v22:GetStateBehavior(c56v33)
            c56v33 = gGlaiveAlternateGrenadeStateBehaviorType
            c56v24 = c56v23:IsA(c56v33)
          end
        end
      end
      c56v33 = 0
      c56v31 = 19
      c56v32 = 1
      for c56v33 = c56v33, c56v31, c56v32 do
        c56v39 = "Embed"
        c56v38 = c56v39 .. c56v34
        c56v37 = c56v10[c56v38]
        if c56v37 ~= nil then
          c56v39 = "Embed"
          c56v38 = c56v39 .. c56v34
          c56v40 = "/Lotus/Language/Game/"
          c56v39 = c56v40 .. c56v34
          c56v40 = nil
          c56v11(c56v38, c56v39, c56v40, c56v35)
        end
        c56v34 = v1
        c56v34 = c56v34.GetDamageTypeTag
        c56v36 = c56v15 or c56v16
        c56v34 = c56v34(c56v33, c56v36)
        c56v36 = "/Lotus/Language/Game/"
        c56v38 = "_NoIcon"
        c56v35 = c56v36 .. c56v34 .. c56v38
        c56v39 = "/Lotus/Language/Game/"
        c56v38 = c56v39 .. c56v34
        c56v39 = true
        c56v36 = c56v8:GetLocalized(c56v38, c56v39)
        c56v40 = false
        c56v37 = c56v8:GetLocalized(c56v35, c56v40)
        if c56v37 == c56v35 then
          c56v40 = false
          c56v35 = c56v8:GetLocalized(c56v36, c56v40)
        else
          c56v40 = false
          c56v35 = c56v8:GetLocalized(c56v35, c56v40)
        end
        c56v37 = c56v10[c56v34]
        if c56v37 ~= c56v35 then
          c56v37 = c56v10[c56v34]
          if c56v37 ~= nil then
            c56v37 = c56v10[c56v34]
            c56v37.ToolTipLabel = c56v36
          end
          c56v40 = nil
          c56v11(c56v34, c56v36, c56v40, c56v35)
        end
      end
      c56v32 = "MaxAmmo"
      c56v33 = "/Lotus/Language/Labels/WEAPON_AMMO_MAX"
      c56v11(c56v32, c56v33)
      c56v32 = "AmmoPickupCount"
      c56v33 = "/Lotus/Language/Labels/WEAPON_AMMO_RETRIEVED"
      c56v11(c56v32, c56v33)
      c56v32 = "MaxCharges"
      c56v33 = "/Lotus/Language/Labels/WEAPON_CHARGES_MAX"
      c56v34 = nil
      c56v35 = false
      c56v11(c56v32, c56v33, c56v34, c56v35)
      c56v31 = c56v30.mIsMelee
      if not c56v31 then
        c56v32 = "RechargeRate"
        c56v33 = "/Lotus/Language/Labels/RECHARGE_RATE"
        c56v11(c56v32, c56v33)
        c56v32 = "RechargeDelay"
        c56v33 = "/Lotus/Language/Labels/RECHARGE_DELAY"
        c56v11(c56v32, c56v33)
        c56v32 = "DT_StackDamage"
        c56v33 = "/Lotus/Language/Labels/WEAPON_STACKDAMAGE"
        c56v11(c56v32, c56v33)
        c56v32 = "Multishot"
        c56v33 = "/Lotus/Language/Labels/WEAPON_FIRE_ITERATIONS"
        c56v34 = 2
        c56v11(c56v32, c56v33, c56v34)
        c56v32 = "Noise"
        c56v33 = "/Lotus/Language/Labels/WEAPON_NOISE"
        c56v34 = 6
        c56v11(c56v32, c56v33, c56v34)
        if not c56v24 then
          c56v32 = "Reload"
          c56v33 = "/Lotus/Language/Labels/WEAPON_RELOAD"
          c56v34 = 3
          c56v11(c56v32, c56v33, c56v34)
          c56v32 = "Trigger"
          c56v33 = "/Lotus/Language/Labels/WEAPON_TRIGGER"
          c56v34 = 5
          c56v35 = false
          c56v11(c56v32, c56v33, c56v34, c56v35)
        end
      else
        c56v32 = "Stamina"
        c56v33 = "/Lotus/Language/Labels/AVATAR_STAMINA"
        c56v11(c56v32, c56v33)
      end
      c56v32 = "Punchthrough"
      c56v33 = "/Lotus/Language/Labels/WEAPON_PUNCTURE_DEPTH"
      c56v34 = 7
      c56v11(c56v32, c56v33, c56v34)
      c56v32 = "BeamRange"
      c56v33 = "/Lotus/Language/Stats/WeaponStats_BeamRange"
      c56v34 = 8
      c56v11(c56v32, c56v33, c56v34)
      c56v32 = "OmegaAtten"
      c56v33 = "/Lotus/Language/Menu/WeaponStats_OmegaAttenuationTitle"
      c56v34 = 9
      c56v35 = "/Lotus/Language/Labels/OMEGA"
      c56v11(c56v32, c56v33, c56v34, c56v35)
      c56v32 = "DamageFallOff"
      c56v33 = "/Lotus/Language/Game/WEAPON_FALLOFF"
      c56v34 = nil
      c56v35 = false
      c56v11(c56v32, c56v33, c56v34, c56v35)
      c56v32 = "BounceChance"
      c56v33 = "/Lotus/Language/Labels/BOUNCE_CHANCE"
      c56v11(c56v32, c56v33)
      c56v22 = c56v0
      if c56v15 then
        c56v22 = c56v0:GetPilotWeapon()
      else
        if c56v17 then
          c56v23 = c56v1:InventoryControl()
          c56v25 = 5
          c56v22 = c56v23:GetWeaponInSlot(c56v25)
        else
          if c56v13 then
            c56v23 = c56v1:InventoryControl()
            c56v25 = 1
            c56v22 = c56v23:GetWeaponInSlot(c56v25)
          end
        end
      end
      c56v23 = v36
      c56v27 = 1
      c56v9 = c56v23(c56v8, c56v22, c56v1, c56v27, c56v19, c56v20, c56v3, c56v4, c56v5)
      if not c56v15 then
        if c56v15 then
          c56v23 = c56v9[1]
          c56v24 = string.upper
          c56v31 = "/Lotus/Language/Railjack/TacCallPilot"
          c56v32 = false
          c56v26 = c56v8:GetLocalized(c56v31, c56v32)
          c56v27 = " - "
          c56v30 = c56v22:GetLocalizeTag()
          c56v30 = c56v30:c_str()
          c56v31 = false
          c56v28 = c56v8:GetLocalized(c56v30, c56v31)
          c56v25 = c56v26 .. c56v27 .. c56v28
          c56v24 = c56v24(c56v25)
          c56v23.mName = c56v24
          c56v22 = c56v0:GetTurretWeapon()
          c56v23 = v36
          c56v27 = 1
          c56v23 = c56v23(c56v8, c56v22, c56v1, c56v27, c56v19, c56v20, c56v3, c56v4)
          if c56v23 ~= nil then
            c56v24 = c56v23[1]
            c56v25 = string.upper
            c56v32 = "/Lotus/Language/Railjack/RailjackGunnery"
            c56v33 = false
            c56v27 = c56v8:GetLocalized(c56v32, c56v33)
            c56v28 = " - "
            c56v31 = c56v22:GetLocalizeTag()
            c56v31 = c56v31:c_str()
            c56v32 = false
            c56v29 = c56v8:GetLocalized(c56v31, c56v32)
            c56v26 = c56v27 .. c56v28 .. c56v29
            c56v25 = c56v25(c56v26)
            c56v24.mName = c56v25
            c56v26 = 1
            c56v24 = #c56v23
            c56v25 = 1
            for c56v26 = c56v26, c56v24, c56v25 do
              c56v29 = c56v23[c56v26]
              c56v27 = table.insert
              c56v27(c56v9, c56v29)
            end
          end
        else
          if c56v17 then
            c56v23 = c56v9[1]
            c56v24 = string.upper
            c56v27 = "/Lotus/Language/Menu/Loadout_FireModeMelee"
            c56v28 = false
            c56v24 = c56v24(c56v8:GetLocalized(c56v27, c56v28))
            c56v23.mName = c56v24
          else
            if c56v13 then
              c56v23 = c56v9[1]
              c56v26 = "/Lotus/Language/Menu/TennoCustomization_Amp"
              c56v27 = false
              c56v24 = c56v8:GetLocalized(c56v26, c56v27)
              c56v23.mName = c56v24
            end
          end
        end
        if c56v6 then
          c56v23 = v36
          c56v27 = 1
          c56v23 = c56v23(c56v8, c56v6, c56v1, c56v27, c56v19, c56v20, c56v3, c56v4)
          if c56v23 ~= nil then
            c56v26 = 1
            c56v24 = #c56v23
            c56v25 = 1
            for c56v26 = c56v26, c56v24, c56v25 do
              c56v29 = c56v23[c56v26]
              c56v27 = table.insert
              c56v27(c56v9, c56v29)
            end
          end
        end
      else
        c56v9 = {}
      end
      c56v23 = nil
      c56v24 = nil
      if c56v4 then
        c56v27 = true
        c56v0:Name__392c190e(c56v27)
        c56v25 = _T.mMechaSuitMode
        if c56v25 then
          c56v27 = true
          c56v0:Name__4de9e1f8(c56v27)
          c56v27 = 1
          c56v0:Name__19307ea9(c56v27)
        else
          c56v0:Name__19307ea9(c56v0:Name__974a9860())
        end
      end
      c56v25 = false
      c56v26 = IsNull
      c56v26 = c56v26(c56v22)
      if not c56v26 then
        c56v26 = c56v22:GetHolsterCategory()
        c56v27 = 13
        if c56v26 ~= c56v27 then
          c56v25 = false
        else
          c56v25 = true
        end
      end
      c56v26 = ipairs
      c56v26, c56v27, c56v28 = c56v26(c56v9)
      c56v32 = "Total"
      c56v33 = "/Lotus/Language/Menu/Store_Total"
      c56v34 = nil
      c56v35 = false
      c56v11(c56v32, c56v33, c56v34, c56v35)
      c56v31 = c56v11
      c56v32 = "Range"
      c56v33 = v0
      c56v33 = c56v33.Ternary
      c56v34 = c56v18
      if c56v34 then
        c56v34 = c56v30.mIsHeavyAttack
      end
      c56v35 = "/Lotus/Language/Labels/AVATAR_RANGE_SEARCH"
      c56v36 = "/Lotus/Language/Labels/AVATAR_RANGE"
      c56v33 = c56v33(c56v34, c56v35, c56v36)
      c56v34 = v0
      c56v34 = c56v34.Ternary
      c56v35 = c56v30.mIsMelee
      c56v36 = 2
      c56v37 = 8
      c56v31(c56v32, c56v33, c56v34(c56v35, c56v36, c56v37))
      c56v32 = "EmbedDamageRadius"
      c56v33 = "/Lotus/Language/Stats/EmbedDamageRadius"
      c56v34 = nil
      c56v35 = false
      c56v11(c56v32, c56v33, c56v34, c56v35)
      c56v32 = "HeavyAttack"
      c56v33 = "/Lotus/Language/Labels/WEAPON_DAMAGE_AMOUNT"
      c56v34 = 1
      c56v11(c56v32, c56v33, c56v34)
      c56v31 = c56v30.mIsMelee
      if not c56v34 then
        c56v32 = "Accuracy"
        c56v33 = "/Lotus/Language/Labels/WEAPON_SPREAD"
        c56v34 = 4
        c56v11(c56v32, c56v33, c56v34)
        c56v32 = IsNull
        c56v32 = c56v32(c56v22)
        c56v31 = not c56v32
        if c56v31 then
          c56v33 = WeakResource
          c56v34 = "/Lotus/Weapons/Infested/LongGuns/InfSniperRifle/InfSniperRifle"
          c56v31 = c56v22:IsA(c56v33(c56v34))
        end
        c56v33 = "EmbedDelay"
        c56v34 = "/Lotus/Language/Labels/WEAPON_EMBED_DELAY"
        c56v35 = nil
        c56v36 = v0
        c56v36 = c56v36.Ternary
        c56v38 = false
        c56v39 = ""
        c56v11(c56v33, c56v34, c56v35, c56v36(c56v31, c56v38, c56v39))
        c56v33 = "EmbedTime"
        c56v34 = "/Lotus/Language/Stats/EmbedTime"
        c56v35 = nil
        c56v36 = false
        c56v11(c56v33, c56v34, c56v35, c56v36)
        c56v33 = "EmbedFallOff"
        c56v34 = "/Lotus/Language/Stats/EmbedFalloff"
        c56v35 = nil
        c56v36 = false
        c56v11(c56v33, c56v34, c56v35, c56v36)
      else
        c56v31 = IsNull
        c56v31 = c56v31(c56v1)
        if not c56v31 then
          c56v31 = c56v1:InventoryControl()
          c56v31 = c56v31:IsSpaceMode()
          if not c56v31 then
            c56v32 = "SlamAttack"
            c56v33 = "/Lotus/Language/Labels/AVATAR_SLAM_ATTACK"
            c56v34 = 3
            c56v11(c56v32, c56v33, c56v34)
            c56v32 = "SlideAttack"
            c56v33 = "/Lotus/Language/Labels/AVATAR_SLIDE_ATTACK"
            c56v34 = 4
            c56v11(c56v32, c56v33, c56v34)
            c56v32 = "ComboDuration"
            c56v33 = "/Lotus/Language/Labels/AVATAR_COMBO_DURATION"
            c56v34 = 5
            c56v35 = v0
            c56v35 = c56v35.Ternary
            c56v37 = false
            c56v38 = "/Lotus/Language/Menu/Combo"
            c56v11(c56v32, c56v33, c56v34, c56v35(c56v17, c56v37, c56v38))
            c56v32 = "FollowThrough"
            c56v33 = "/Lotus/Language/Labels/AVATAR_FOLLOW_THROUGH"
            c56v34 = 6
            c56v35 = false
            c56v11(c56v32, c56v33, c56v34, c56v35)
            c56v32 = "BlockingAngle"
            c56v33 = "/Lotus/Language/Labels/AVATAR_BLOCKING_ANGLE"
            c56v34 = 7
            c56v35 = "/Lotus/Language/Menu/Input_FIGHTER_PARRY"
            c56v11(c56v32, c56v33, c56v34, c56v35)
            c56v32 = "SlamAttackRadialDamage"
            c56v33 = "/Lotus/Language/Labels/AVATAR_SLAM_RADIAL_DAMAGE"
            c56v11(c56v32, c56v33)
            c56v32 = "SlamAttackRadius"
            c56v33 = "/Lotus/Language/Labels/AVATAR_SLAM_RADIUS"
            c56v11(c56v32, c56v33)
            c56v32 = "HeavySlamAttack"
            c56v33 = "/Lotus/Language/Labels/AVATAR_SLAM_ATTACK"
            c56v34 = 2
            c56v11(c56v32, c56v33, c56v34)
            c56v32 = "ComboEfficiency"
            c56v33 = "/Lotus/Language/Labels/AVATAR_ABILITY_EFFICIENCY"
            c56v34 = 3
            c56v11(c56v32, c56v33, c56v34)
            c56v32 = "Tennokai_Chance"
            c56v33 = "/Lotus/Language/Labels/TENNOKAI_CHANCE"
            c56v34 = 4
            c56v35 = "/Lotus/Language/ModTips/PerfectHeavyMelee"
            c56v11(c56v32, c56v33, c56v34, c56v35)
            c56v32 = "HeavyAttackWindUp"
            c56v33 = "/Lotus/Language/Labels/AVATAR_ATTACK_WIND_UP"
            c56v34 = 5
            c56v11(c56v32, c56v33, c56v34)
            c56v32 = "HeavySlamAttackRadialDamage"
            c56v33 = "/Lotus/Language/Labels/AVATAR_SLAM_RADIAL_DAMAGE"
            c56v11(c56v32, c56v33)
            c56v32 = "HeavySlamAttackRadius"
            c56v33 = "/Lotus/Language/Labels/AVATAR_SLAM_RADIUS"
            c56v11(c56v32, c56v33)
            c56v32 = "ComboCount"
            c56v33 = "/Lotus/Language/Labels/AVATAR_COMBO_COUNT"
            c56v11(c56v32, c56v33)
          end
        end
      end
      if not ((c56v25 or c56v24)) then
        c56v31 = c56v30.mIsMelee
        if c56v31 then
          c56v32 = "FireRateMelee"
          c56v33 = "/Lotus/Language/Labels/WEAPON_MELEE_FIRE_RATE"
          c56v34 = 1
          c56v11(c56v32, c56v33, c56v34)
        else
          c56v32 = "FireRate"
          c56v33 = "/Lotus/Language/Labels/WEAPON_FIRE_RATE"
          c56v34 = 1
          c56v11(c56v32, c56v33, c56v34)
        end
      end
      if c56v20 then
        c56v32 = "HeadShotMult"
        c56v33 = "/Lotus/Language/Labels/WEAPON_HEADSHOT_MULTIPLIER"
        c56v34 = 2
        c56v11(c56v32, c56v33, c56v34)
      else
        c56v32 = "CriticalChance"
        c56v33 = "/Lotus/Language/Labels/WEAPON_CRIT_CHANCE"
        c56v34 = 1
        c56v11(c56v32, c56v33, c56v34)
        c56v32 = "CriticalMultiplier"
        c56v33 = "/Lotus/Language/Labels/WEAPON_CRIT_MULTIPLIER"
        c56v34 = 2
        c56v35 = "/Lotus/Language/Labels/WEAPON_CRIT_DAMAGE"
        c56v11(c56v32, c56v33, c56v34, c56v35)
        c56v32 = "ExplosionRadius"
        c56v33 = "/Lotus/Language/Labels/WEAPON_EXPLOSION_RADIUS"
        c56v34 = nil
        c56v35 = false
        c56v11(c56v32, c56v33, c56v34, c56v35)
      end
      if c56v23 then
        c56v33 = Name__539c8440
        c56v31 = c56v23:IsA(c56v33)
        if c56v31 then
          c56v32 = "ChargeRate"
          c56v33 = "/Lotus/Language/Labels/WEAPON_CHARGE_RATE"
          c56v34 = 1
          c56v35 = "/Lotus/Language/Labels/WEAPON_FIRE_RATE"
          c56v11(c56v32, c56v33, c56v34, c56v35)
        end
      end
      c56v32 = "ProcChance"
      c56v33 = "/Lotus/Language/Labels/WEAPON_PROC"
      c56v34 = 3
      c56v11(c56v32, c56v33, c56v34)
      c56v32 = "ProcChancePerShot"
      c56v33 = "/Lotus/Language/Game/StatusPerProjectile"
      c56v34 = 3
      c56v35 = "/Lotus/Language/Labels/WEAPON_PROC_CHANCE"
      c56v11(c56v32, c56v33, c56v34, c56v35)
      c56v32 = "EnergyPool"
      c56v33 = "/Lotus/Language/Labels/ENERGY_POOL"
      c56v11(c56v32, c56v33)
      c56v32 = "EnergyPerSecond"
      c56v33 = "/Lotus/Language/Labels/ENERGY_PER_SECOND"
      c56v11(c56v32, c56v33)
      c56v32 = "EnergyPerShot"
      c56v33 = "/Lotus/Language/Labels/ENERGY_PER_SHOT"
      c56v11(c56v32, c56v33)
      c56v23 = gSentinelPowerSuitType
      c56v21 = c56v0:IsA(c56v23)
      c56v21 = nil
      c56v23 = c56v1:InventoryControl()
      c56v23 = c56v23:IsSpaceMode()
      c56v24 = "Mult_SprintSpeed"
      c56v25 = "/Lotus/Language/Labels/AVATAR_SPRINT_SPEED_SEARCH"
      c56v26 = 5
      c56v11(c56v24, c56v25, c56v26)
      c56v24 = "Mult_SprintSpeed"
      c56v25 = "/Lotus/Language/Labels/AVATAR_SPRINT_SPEED"
      c56v26 = 5
      c56v27 = v0
      c56v27 = c56v27.Ternary
      c56v29 = false
      c56v30 = ""
      c56v11(c56v24, c56v25, c56v26, c56v27(c56v17, c56v29, c56v30))
      c56v24 = "Shield"
      c56v25 = "/Lotus/Language/Labels/AVATAR_SHIELD"
      c56v26 = 2
      c56v11(c56v24, c56v25, c56v26)
      c56v21 = IsNull
      c56v21 = c56v21(c56v1)
      if c56v21 then
        c56v1 = c56v0:GetOwner()
      end
      c56v24 = "Stamina"
      c56v25 = "/Lotus/Language/Labels/AVATAR_STAMINA"
      c56v11(c56v24, c56v25)
      c56v24 = "Power"
      c56v25 = "/Lotus/Language/Labels/AVATAR_ABILITY"
      c56v26 = 4
      c56v11(c56v24, c56v25, c56v26)
      c56v24 = "ParkourBoost"
      c56v25 = "/Lotus/Language/Menu/WeaponStats_Bullet_Glide"
      c56v11(c56v24, c56v25)
      c56v25 = gSentinelPowerSuitType
      c56v23 = c56v0:IsA(c56v25)
      if c56v23 then
        c56v24 = "Self_Respawn_Time"
        c56v25 = "/Lotus/Language/Labels/AVATAR_RESPAWN_TIME"
        c56v26 = nil
        c56v27 = "/Lotus/Language/Labels/AVATAR_RESPAWN_TIME_SEARCH"
        c56v11(c56v24, c56v25, c56v26, c56v27)
      end
      c56v25 = 0
      c56v23 = 19
      c56v24 = 1
      for c56v25 = c56v25, c56v23, c56v24 do
        c56v29 = v1
        c56v29 = c56v29.GetDamageTypeTag
        c56v27 = c56v29(c56v25)
        c56v28 = "_RESIST"
        c56v26 = c56v27 .. c56v28
        c56v27 = c56v10[c56v26]
        if c56v27 ~= nil then
          c56v30 = "/Lotus/Language/Game/"
          c56v29 = c56v30 .. c56v26
          c56v30 = true
          c56v27 = c56v8:GetLocalized(c56v29, c56v30)
          c56v28 = c56v10[c56v26]
          if c56v28 ~= nil then
            c56v28 = c56v10[c56v26]
            c56v28.ToolTipLabel = c56v27
          end
          c56v29 = "/Lotus/Language/Game/"
          c56v31 = "_NoIcon"
          c56v28 = c56v29 .. c56v26 .. c56v31
          c56v32 = false
          c56v29 = c56v8:GetLocalized(c56v28, c56v32)
          if c56v29 == c56v28 then
            c56v32 = false
            c56v28 = c56v8:GetLocalized(c56v27, c56v32)
          else
            c56v32 = false
            c56v28 = c56v8:GetLocalized(c56v28, c56v32)
          end
          c56v32 = nil
          c56v11(c56v26, c56v27, c56v32, c56v28)
        end
      end
      c56v22 = v19
      c56v21 = c56v22(c56v8, c56v1, c56v0, c56v20)
      if c56v21 == nil then
        c56v22 = {}
        do return c56v22 end
      end
      c56v22 = 1
      if c56v13 then
        c56v23 = c56v21[c56v22]
        c56v10 = c56v23.mStats
        c56v24 = "UltInitCharge"
        c56v25 = "/Lotus/Language/Labels/AVATAR_ABILITY_OPERATOR_ULTIMATE_INITIAL_CHARGE"
        c56v26 = 1
        c56v11(c56v24, c56v25, c56v26)
        c56v24 = "UltDuration"
        c56v25 = "/Lotus/Language/Labels/AVATAR_ABILITY_DURATION"
        c56v26 = 2
        c56v11(c56v24, c56v25, c56v26)
        c56v22 = c56v22 + 1
      end
      c56v23 = c56v21[c56v22]
      c56v10 = c56v23.mStats
      c56v24 = "Health"
      c56v25 = "/Lotus/Language/Labels/AVATAR_HEALTH_MAX"
      c56v26 = 1
      c56v11(c56v24, c56v25, c56v26)
      c56v24 = "Armor"
      c56v25 = "/Lotus/Language/Labels/AVATAR_ARMOUR"
      c56v26 = 3
      c56v11(c56v24, c56v25, c56v26)
      c56v23 = IsNull
      c56v23 = c56v23(c56v1)
      c56v7 = v37
      c56v7 = c56v7()
      c56v8 = c56v7.mMovie
      c56v9 = {}
      c56v10 = nil
      c56v11 = IsNull
      c56v11 = c56v11(c56v0)
      if c56v11 then
        do return c56v9 end
      end
      c56v11 = function(c55v0, c55v1, c55v2, c55v3)
        local c55v5, c55v6, c55v8, c55v9
        local c55v4 = c56v10
        if c55v4 == nil then
          do return end
        end
        c55v5 = c56v10
        c55v4 = c55v5[c55v0]
        if c55v4 == nil then
          do return end
        end
        if c55v2 == nil then
          c55v2 = 100
        end
        c55v5 = c56v2
        if not c55v5 then
          c55v5 = c56v8
          c55v8 = true
          c55v1 = c55v5:GetLocalized(c55v1, c55v8)
        end
        c55v5 = TitleCase
        c55v5 = c55v5(c55v1)
        c55v4.Label = c55v5
        c55v4.Key = c55v0
        c55v4.Order = c55v2
        if c55v3 ~= false then
          if not ((c55v3 == nil or c55v3 == "")) then
            c55v5 = TitleCase
            c55v6 = c56v8
            c55v9 = false
            c55v5 = c55v5(c55v6:GetLocalized(c55v3, c55v9))
            c55v4.SearchLabel = c55v5
            do return end
          end
          c55v5 = TitleCase
          c55v5 = c55v5(c55v1)
          c55v4.SearchLabel = c55v5
        end
        do return end
      end
      c56v12 = v17
      c56v12 = c56v12(c56v0)
      c56v15 = WeakResource
      c56v16 = "/Lotus/Powersuits/Operator/AdultOperatorSuit"
      c56v13 = c56v0:IsA(c56v15(c56v16))
      if not c56v13 then
        c56v15 = WeakResource
        c56v16 = "/Lotus/Powersuits/Operator/OperatorSuit"
        c56v13 = c56v0:IsA(c56v15(c56v16))
      end
      c56v14 = false
      c56v17 = gCrewShipType
      c56v15 = c56v0:IsA(c56v17)
      c56v18 = WeakResource
      c56v19 = "/Lotus/Weapons/CrewShip/RailjackWeapon"
      c56v16 = c56v0:IsA(c56v18(c56v19))
      c56v19 = WeakResource
      c56v20 = "/Lotus/Powersuits/EntratiMech/BaseMechSuit"
      c56v17 = c56v0:IsA(c56v19(c56v20))
      c56v20 = WeakResource
      c56v21 = "/Lotus/Weapons/Tenno/Melee/LotusGlaiveWeaponBase"
      c56v18 = c56v0:IsA(c56v20(c56v21))
      c56v19 = {}
      c56v21 = _T.ArsenalState
      c56v22 = 2
      if c56v21 ~= c56v22 then
        c56v20 = false
      else
        c56v20 = true
      end
      c56v23 = WeakResource
      c56v24 = "/Lotus/Types/Vehicles/Hoverboard/HoverboardSuit"
      c56v21 = c56v0:IsA(c56v23(c56v24))
      if c56v21 then
        c56v14 = true
      end
      c56v23 = gPetPowerSuitType
      c56v21 = c56v0:IsA(c56v23)
      if c56v22 then
        if c56v4 then
          c56v0:Name__77aaecad()
          c56v28 = false
          c56v0:Name__392c190e(c56v28)
        end
      end
      c56v22 = ipairs
      c56v22, c56v23, c56v24 = c56v22(c56v21)
      for c56v25, c56v26 in c56v22, c56v23, c56v24 do
        c56v27 = table.insert
        c56v27(c56v9, c56v25, c56v26)
      end
      for c56v25, c56v26 in c56v22, c56v23, c56v24 do
      end
      if c56v15 then
        c56v22 = v18
        c56v9 = c56v22(c56v8, c56v1, c56v0)
        c56v22 = c56v9[1]
        c56v10 = c56v22.mStats
        c56v23 = "Shield"
        c56v24 = "/Lotus/Language/Labels/AVATAR_SHIELD"
        c56v25 = 3
        c56v11(c56v23, c56v24, c56v25)
        c56v23 = "Engines"
        c56v24 = "/Lotus/Language/Railjack/BonusEngine"
        c56v25 = 5
        c56v26 = "/Lotus/Language/Labels/AVATAR_MOVEMENT_SPEED"
        c56v11(c56v23, c56v24, c56v25, c56v26)
        c56v23 = "EngineBoost"
        c56v24 = "/Lotus/Language/Railjack/BonusEngineBoost"
        c56v25 = 6
        c56v11(c56v23, c56v24, c56v25)
        c56v23 = "RailjackHealth"
        c56v24 = "/Lotus/Language/Labels/RAILJACK_HEALTH_MAX"
        c56v25 = 1
        c56v11(c56v23, c56v24, c56v25)
        c56v23 = "Armor"
        c56v24 = "/Lotus/Language/Labels/AVATAR_ARMOUR"
        c56v25 = 2
        c56v11(c56v23, c56v24, c56v25)
        c56v23 = "ShieldRechargeRate"
        c56v24 = "/Lotus/Language/Labels/AVATAR_SHIELD_RECHARGE_RATE"
        c56v25 = nil
        c56v11(c56v23, c56v24, c56v25)
        c56v23 = "ShieldRechargeDelay"
        c56v24 = "/Lotus/Language/Labels/AVATAR_SHIELD_RECHARGE_DELAY"
        c56v11(c56v23, c56v24)
        c56v23 = "ElementRedirection"
        c56v24 = "/Lotus/Language/Labels/AVATAR_SHIELD_REDIRECTION"
        c56v11(c56v23, c56v24)
        c56v23 = "DT_FIRE"
        c56v24 = "/Lotus/Language/Labels/FIRE_RESIST"
        c56v11(c56v23, c56v24)
        c56v23 = "DT_ELECTRICITY"
        c56v24 = "/Lotus/Language/Labels/ELECTRICITY_RESIST"
        c56v11(c56v23, c56v24)
        c56v23 = "DT_POISON"
        c56v24 = "/Lotus/Language/Labels/POISON_RESIST"
        c56v11(c56v23, c56v24)
        c56v23 = "DT_FREEZE"
        c56v24 = "/Lotus/Language/Labels/FREEZE_RESIST"
        c56v11(c56v23, c56v24)
        c56v23 = "CargoCapacity"
        c56v24 = "/Lotus/Language/Labels/RAILJACK_CARGO_CAPACITY"
        c56v25 = 4
        c56v11(c56v23, c56v24, c56v25)
        c56v22 = c56v9[2]
        c56v10 = c56v22.mStats
        c56v23 = "Railjack_Power_Strength"
        c56v24 = "/Lotus/Language/Labels/AVATAR_ABILITY_STRENGTH"
        c56v25 = 1
        c56v26 = false
        c56v11(c56v23, c56v24, c56v25, c56v26)
        c56v23 = "Railjack_Power_Duration"
        c56v24 = "/Lotus/Language/Labels/AVATAR_ABILITY_DURATION"
        c56v25 = 2
        c56v26 = false
        c56v11(c56v23, c56v24, c56v25, c56v26)
        c56v23 = "Railjack_Power_Range"
        c56v24 = "/Lotus/Language/Labels/AVATAR_RANGE"
        c56v25 = 3
        c56v26 = false
        c56v11(c56v23, c56v24, c56v25, c56v26)
      end
      c56v24 = WeakResource
      c56v25 = "/Lotus/Types/Friendly/Pets/BeastPetMeleeWeaponBase"
      c56v22 = c56v0:IsA(c56v24(c56v25))
      if (not (c56v17) and not c56v13) then
        c56v22 = ipairs
        c56v22, c56v23, c56v24 = c56v22(c56v9)
        for c56v25, c56v26 in c56v22, c56v23, c56v24 do
          c56v10 = c56v26.mStats
          c56v27 = _T.MenuSuitAvatar
          c56v28 = IsNull
          c56v28 = c56v28(c56v27)
          if c56v28 then
            c56v28 = v1
            c56v28 = c56v28.GetMainMenuSuitAvatar
            c56v27 = c56v28()
          end
          c56v28 = IsNull
          c56v28 = c56v28(c56v27)
          if not c56v28 then
            c56v28 = IsNull
            c56v28 = c56v28(c56v1)
            if not c56v28 then
              c56v28 = c56v27:InventoryControl()
              c56v30 = 1
              c56v28 = c56v28:GetWeaponInSlot(c56v30)
              c56v29 = IsNull
              c56v29 = c56v29(c56v28)
              if not c56v29 then
                c56v29 = c56v28:GetDamageData()
                c56v30 = c56v1:InventoryControl()
                c56v32 = c56v29.criticalChance
                c56v33 = 127
                c56v34 = c56v0:GetType()
                c56v30 = c56v30:GetUpgradeModifiedValue(c56v32, c56v33, c56v34, c56v0)
                c56v32 = c56v10.CriticalChance
                c56v31 = IsNull
                c56v31 = c56v31(c56v32)
                if not c56v31 then
                  c56v33 = c56v10.CriticalChance
                  c56v33 = c56v33.StatValue
                  c56v34 = 100
                  c56v32 = c56v33 / c56v34
                  c56v34 = c56v29.criticalChance
                  c56v33 = c56v30 - c56v34
                  c56v31 = c56v32 + c56v33
                  c56v32 = c56v10.CriticalChance
                  c56v36 = v0
                  c56v36 = c56v36.FormatNumber
                  c56v38 = 100
                  c56v37 = c56v31 * c56v38
                  c56v38 = 1
                  c56v39 = false
                  c56v34 = c56v36(c56v37, c56v38, c56v39)
                  c56v35 = "%"
                  c56v33 = c56v34 .. c56v35
                  c56v32.DisplayValue = c56v33
                  c56v32 = c56v10.CriticalChance
                  c56v34 = 100
                  c56v33 = c56v31 * c56v34
                  c56v32.StatValue = c56v33
                end
                c56v32 = c56v10.ProcChance
                c56v31 = IsNull
                c56v31 = c56v31(c56v32)
                if not c56v31 then
                  c56v32 = c56v0:GetDamageData()
                  c56v32 = c56v32.baseProcChance
                  c56v34 = c56v29.baseProcChance
                  c56v35 = c56v1:InventoryControl()
                  c56v37 = 0
                  c56v38 = 136
                  c56v35 = c56v35:GetUpgradeModifiedValue(c56v37, c56v38)
                  c56v33 = c56v34 * c56v35
                  c56v31 = c56v32 + c56v33
                  c56v32 = c56v10.ProcChance
                  c56v36 = v0
                  c56v36 = c56v36.FormatNumber
                  c56v38 = 100
                  c56v37 = c56v31 * c56v38
                  c56v38 = 1
                  c56v39 = false
                  c56v34 = c56v36(c56v37, c56v38, c56v39)
                  c56v35 = "%"
                  c56v33 = c56v34 .. c56v35
                  c56v32.DisplayValue = c56v33
                  c56v32 = c56v10.ProcChance
                  c56v34 = 100
                  c56v33 = c56v31 * c56v34
                  c56v32.StatValue = c56v33
                end
              end
            end
          end
        end
      end
      c56v22 = IsNull
      c56v22 = c56v22(c56v5)
      if not c56v22 then
        c56v23 = "UpgradeBonus"
        c56v24 = "/Lotus/Language/Kingpins/NemesisView_StatWeaponBonus"
        c56v11(c56v23, c56v24)
      end
      c56v22 = nil
      c56v23 = nil
      c56v24 = ipairs
      c56v24, c56v25, c56v26 = c56v24(c56v9)
    end
  end
  v39 = function(c57v0, c57v1)
    local c57v2, c57v3, c57v4, c57v5, c57v6, c57v7, c57v8, c57v9, c57v10, c57v11, c57v12, c57v13, c57v14, c57v15, c57v16, c57v17, c57v18, c57v19, c57v20, c57v21, c57v22, c57v23, c57v24, c57v25, c57v26, c57v27, c57v28, c57v29, c57v30, c57v31, c57v32, c57v33, c57v34
    c57v12 = "/Lotus/Language/Menu/NotAvailable"
    c57v13 = false
    c57v10 = c57v3:GetLocalized(c57v12, c57v13)
    c57v11 = v0
    c57v11 = c57v11.Ternary
    if c57v8 <= c57v7 then
      c57v12 = false
    else
      c57v12 = true
    end
    c57v11 = c57v11(c57v12, c57v1, c57v0)
    c57v14 = c57v6 + 1
    c57v12 = #c57v11
    c57v13 = 1
    for c57v14 = c57v14, c57v12, c57v13 do
      c57v18 = table.insert
      c57v18(c57v5, c57v16)
      c57v15 = c57v11[c57v14]
      c57v15 = c57v15.mName
      if not ((c57v1 == nil or c57v0 == nil)) then
        if c57v7 < c57v8 then
          c57v15 = c57v10 .. c57v4 .. c57v15
        else
          c57v15 = c57v15 .. c57v4 .. c57v10
        end
      end
      c57v16 = { mName = nil, mStats = nil }
      c57v16.mName = c57v15
      c57v17 = {}
      c57v16.mStats = c57v17
      c57v17 = c57v16.mStats
      c57v18 = pairs
      c57v19 = c57v11[c57v14]
      c57v19 = c57v19.mStats
      c57v18, c57v19, c57v20 = c57v18(c57v19)
      for c57v21, c57v22 in c57v18, c57v19, c57v20 do
        c57v23 = c57v22.Key
        if c57v23 ~= nil then
          c57v23 = c57v22.Key
          c57v24 = { Label = nil, TextOnly = nil, Order = nil }
          c57v25 = c57v22.Label
          c57v24.Label = c57v25
          c57v25 = c57v22.TextOnly
          c57v24.TextOnly = c57v25
          c57v25 = c57v22.Order
          c57v24.Order = c57v25
          c57v17[c57v23] = c57v24
          if c57v11 == c57v1 then
            c57v24 = c57v22.Key
            c57v23 = c57v17[c57v24]
            c57v24 = { StatValue = nil, DisplayValue = nil }
            c57v25 = c57v22.StatValue
            c57v24.StatValue = c57v25
            c57v25 = c57v22.DisplayValue
            c57v24.DisplayValue = c57v25
            c57v23.Current = c57v24
            if c57v0 == nil then
              c57v24 = c57v22.Key
              c57v23 = c57v17[c57v24]
              c57v25 = c57v22.Key
              c57v24 = c57v17[c57v25]
              c57v24 = c57v24.Current
              c57v23.Previous = c57v24
            end
          else
            c57v24 = c57v22.Key
            c57v23 = c57v17[c57v24]
            c57v24 = { StatValue = nil, DisplayValue = nil }
            c57v25 = c57v22.StatValue
            c57v24.StatValue = c57v25
            c57v25 = c57v22.DisplayValue
            c57v24.DisplayValue = c57v25
            c57v23.Previous = c57v24
            if c57v1 == nil then
              c57v24 = c57v22.Key
              c57v23 = c57v17[c57v24]
              c57v25 = c57v22.Key
              c57v24 = c57v17[c57v25]
              c57v24 = c57v24.Previous
              c57v23.Current = c57v24
            end
          end
        end
      end
    end
    c57v2 = v37
    c57v2 = c57v2()
    c57v3 = c57v2.mMovie
    c57v5 = " "
    c57v10 = "<MINI_ARROW>"
    c57v11 = true
    c57v6 = c57v3:GetLocalized(c57v10, c57v11)
    c57v7 = " "
    c57v4 = c57v5 .. c57v6 .. c57v7
    c57v5 = {}
    c57v7 = #c57v0
    c57v8 = #c57v1
    c57v6 = math.min
    c57v6 = c57v6(c57v7, c57v8)
    c57v9 = 1
    c57v7 = c57v6
    c57v8 = 1
    for c57v9 = c57v9, c57v7, c57v8 do
      c57v10 = c57v0[c57v9]
      c57v11 = c57v1[c57v9]
      c57v12 = ""
      c57v13 = v12
      c57v14 = c57v10.mName
      c57v13 = c57v13(c57v14)
      c57v13 = v12
      c57v14 = c57v11.mName
      c57v13 = c57v13(c57v14)
      c57v21 = c57v20.Key
      c57v22 = c57v20.Key
      c57v21 = c57v14[c57v22]
      c57v22 = c57v20.Key
      c57v21 = c57v14[c57v22]
      c57v21 = c57v21.Current
      c57v23 = c57v20.Key
      c57v22 = c57v14[c57v23]
      c57v22 = c57v22.Previous
      c57v23 = c57v21.StatValue
      c57v24 = c57v22.StatValue
      c57v23 = c57v21.DisplayValue
      c57v24 = c57v22.DisplayValue
      c57v15 = false
      c57v13 = c57v11.mName
      c57v14 = c57v10.mName
      if c57v13 ~= c57v14 then
        c57v13 = c57v10.mName
        c57v15 = c57v11.mName
        c57v12 = c57v13 .. c57v4 .. c57v15
      else
        c57v12 = c57v11.mName
      end
      c57v13 = v12
      c57v14 = c57v10.mName
      c57v13 = c57v13(c57v14)
      if c57v13 then
        c57v12 = c57v11.mName
      else
        c57v13 = v12
        c57v14 = c57v11.mName
        c57v13 = c57v13(c57v14)
        if c57v13 then
          c57v12 = c57v10.mName
        end
      end
      c57v24 = c57v20.Key
      c57v23 = c57v14[c57v24]
      c57v23 = c57v23.TextIfOneNil
      if c57v23 then
        c57v24 = c57v20.Key
        c57v23 = c57v14[c57v24]
        c57v24 = false
        c57v23.TextOnly = c57v24
      end
      c57v22 = c57v20.Key
      c57v21 = c57v14[c57v22]
      c57v21 = c57v21.Hidden
      if c57v21 then
        c57v21 = c57v20.Hidden
        if c57v21 then
          c57v21 = c57v20.Key
          c57v22 = nil
          c57v14[c57v21] = c57v22
        end
      end
      c57v21 = c57v20.Key
      c57v22 = { Label = nil, TextOnly = nil, TextIfOneNil = nil, SmallerIsBetter = nil, Current = nil, Previous = nil, Order = nil, SearchLabel = nil }
      c57v23 = c57v20.Label
      c57v22.Label = c57v23
      c57v23 = c57v20.TextOnly
      if not c57v23 then
        c57v23 = c57v20.TextIfOneNil
      end
      c57v22.TextOnly = c57v23
      c57v23 = c57v20.TextIfOneNil
      c57v22.TextIfOneNil = c57v23
      c57v23 = c57v20.SmallerIsBetter
      c57v22.SmallerIsBetter = c57v23
      c57v23 = v13
      c57v24 = c57v20.DisplayValue
      c57v25 = c57v20.StatValue
      c57v26 = nil
      c57v27 = nil
      c57v28 = c57v20.ToolTip
      c57v29 = nil
      c57v30 = nil
      c57v31 = nil
      c57v32 = c57v20.SecondaryToolTips
      c57v33 = c57v20.HideStat
      c57v34 = c57v20.HeaderOverride
      c57v23 = c57v23(c57v24, c57v25, c57v26, c57v27, c57v28, c57v29, c57v30, c57v31, c57v32, c57v33, c57v34)
      c57v22.Current = c57v23
      c57v23 = {}
      c57v22.Previous = c57v23
      c57v23 = c57v20.Order
      c57v22.Order = c57v23
      c57v23 = c57v20.SearchLabel
      c57v22.SearchLabel = c57v23
      c57v14[c57v21] = c57v22
      c57v15 = false
      if c57v15 then
        c57v16 = c57v11.mName
        c57v13.mName = c57v16
      end
      c57v16 = table.insert
      c57v16(c57v5, c57v13)
      c57v13 = { mName = nil, mStats = nil }
      c57v13.mName = c57v12
      c57v14 = {}
      c57v13.mStats = c57v14
      c57v14 = c57v13.mStats
      c57v15 = true
      c57v16 = pairs
      c57v17 = c57v10.mStats
      c57v16, c57v17, c57v18 = c57v16(c57v17)
      for c57v19, c57v20 in c57v16, c57v17, c57v18 do
        if c57v20 ~= nil then
          c57v21 = c57v20.Key
          if c57v21 ~= nil then
            c57v21 = c57v20.Key
            c57v22 = { Label = nil, TextOnly = nil, TextIfOneNil = nil, SmallerIsBetter = nil, Previous = nil, Current = nil, Hidden = nil, Order = nil, SearchLabel = nil }
            c57v23 = c57v20.Label
            c57v22.Label = c57v23
            c57v23 = c57v20.TextOnly
            if not c57v23 then
              c57v23 = c57v20.TextIfOneNil
            end
            c57v22.TextOnly = c57v23
            c57v23 = c57v20.TextIfOneNil
            c57v22.TextIfOneNil = c57v23
            c57v23 = c57v20.SmallerIsBetter
            c57v22.SmallerIsBetter = c57v23
            c57v23 = v13
            c57v24 = c57v20.DisplayValue
            c57v25 = c57v20.StatValue
            c57v26 = nil
            c57v27 = nil
            c57v28 = c57v20.ToolTip
            c57v29 = nil
            c57v30 = nil
            c57v31 = nil
            c57v32 = c57v20.SecondaryToolTips
            c57v33 = c57v20.HideStat
            c57v34 = c57v20.HeaderOverride
            c57v23 = c57v23(c57v24, c57v25, c57v26, c57v27, c57v28, c57v29, c57v30, c57v31, c57v32, c57v33, c57v34)
            c57v22.Previous = c57v23
            c57v23 = {}
            c57v22.Current = c57v23
            c57v23 = c57v20.Hidden
            c57v22.Hidden = c57v23
            c57v23 = c57v20.Order
            c57v22.Order = c57v23
            c57v23 = c57v20.SearchLabel
            c57v22.SearchLabel = c57v23
            c57v14[c57v21] = c57v22
          end
        end
      end
      c57v16 = pairs
      c57v17 = c57v11.mStats
      c57v16, c57v17, c57v18 = c57v16(c57v17)
      for c57v19, c57v20 in c57v16, c57v17, c57v18 do
        c57v22 = c57v20.Key
        c57v21 = c57v14[c57v22]
        c57v22 = v13
        c57v23 = c57v20.DisplayValue
        c57v24 = c57v20.StatValue
        c57v25 = nil
        c57v26 = nil
        c57v27 = c57v20.ToolTip
        c57v28 = nil
        c57v29 = nil
        c57v30 = nil
        c57v31 = c57v20.SecondaryToolTips
        c57v32 = c57v20.HideStat
        c57v33 = c57v20.HeaderOverride
        c57v22 = c57v22(c57v23, c57v24, c57v25, c57v26, c57v27, c57v28, c57v29, c57v30, c57v31, c57v32, c57v33)
        c57v21.Current = c57v22
        c57v22 = c57v20.Key
        c57v21 = c57v14[c57v22]
        c57v23 = c57v20.Key
        c57v22 = c57v14[c57v23]
        c57v22 = c57v22.TextOnly
        if not c57v22 then
          c57v22 = c57v20.TextOnly
        end
        c57v21.TextOnly = c57v22
        c57v22 = c57v20.Key
        c57v21 = c57v14[c57v22]
        c57v23 = c57v20.Key
        c57v22 = c57v14[c57v23]
        c57v22 = c57v22.TextIfOneNil
        if not c57v22 then
          c57v22 = c57v20.TextIfOneNil
        end
        c57v21.TextIfOneNil = c57v22
        c57v22 = c57v20.Key
        c57v21 = c57v14[c57v22]
        c57v23 = c57v20.Key
        c57v22 = c57v14[c57v23]
        c57v22 = c57v22.Order
        if not c57v22 then
          c57v22 = c57v20.Order
        end
        c57v21.Order = c57v22
        c57v22 = c57v20.Key
        c57v21 = c57v14[c57v22]
        c57v21 = c57v21.Previous
      end
    end
    c57v7 = #c57v0
    c57v8 = #c57v1
    c57v10 = c57v7 - c57v8
    c57v9 = math.abs
    c57v9 = c57v9(c57v10)
    do return c57v5 end
  end
  v40 = function(c58v0)
    local c58v1, c58v2, c58v3, c58v4, c58v5, c58v6, c58v7, c58v8, c58v9, c58v10, c58v11, c58v12, c58v13, c58v14, c58v15, c58v16, c58v17, c58v18, c58v19, c58v20, c58v21, c58v22, c58v23, c58v24, c58v25, c58v26, c58v27, c58v28, c58v29, c58v30
    local p193 = 0
    if p193 == 0 then
      c58v3 = _T.MenuSuitAvatar
      c58v2 = IsNull
      c58v2 = c58v2(c58v3)
      if c58v2 then
        p193 = 2
      else
        p193 = 1
      end
    end
    if p193 == 1 then
      c58v1 = _T.MenuSuitAvatar
      if c58v1 then
        p193 = 3
      else
        p193 = 2
      end
    end
    if p193 == 2 then
      c58v1 = gRegion
      c58v1 = c58v1:GetLocalPlayerAvatar()
      p193 = 3
    end
    if p193 == 3 then
      c58v3 = _T.ModPreviewAvatar
      c58v2 = IsNull
      c58v2 = c58v2(c58v3)
      if c58v2 then
        p193 = 5
      else
        p193 = 4
      end
    end
    if p193 == 4 then
      c58v1 = _T.ModPreviewAvatar
      p193 = 18
    end
    if p193 == 5 then
      c58v3 = _T.RailjackAvatar
      c58v2 = IsNull
      c58v2 = c58v2(c58v3)
      if c58v2 then
        p193 = 8
      else
        p193 = 6
      end
    end
    if p193 == 6 then
      c58v2 = c58v0.IsRailjackAbility
      if not c58v2 then
        p193 = 8
      else
        p193 = 7
      end
    end
    if p193 == 7 then
      c58v1 = _T.RailjackAvatar
      p193 = 18
    end
    if p193 == 8 then
      c58v2 = IsNull
      c58v2 = c58v2(c58v1)
      if c58v2 then
        p193 = 11
      else
        p193 = 9
      end
    end
    if p193 == 9 then
      c58v4 = gLotusVehicleAvatarType
      c58v2 = c58v1:IsA(c58v4)
      if not c58v2 then
        p193 = 11
      else
        p193 = 10
      end
    end
    if p193 == 10 then
      c58v1 = c58v1:GetRider()
      p193 = 18
    end
    if p193 == 11 then
      c58v2 = _T.mMechaSuitMode
      if not c58v2 then
        p193 = 14
      else
        p193 = 12
      end
    end
    if p193 == 12 then
      c58v3 = _T.MechAvatar
      c58v2 = IsNull
      c58v2 = c58v2(c58v3)
      if c58v2 then
        p193 = 14
      else
        p193 = 13
      end
    end
    if p193 == 13 then
      c58v1 = _T.MechAvatar
      p193 = 18
    end
    if p193 == 14 then
      c58v2 = _T.mSpecialSuitMode
      if c58v2 then
        p193 = 16
      else
        p193 = 15
      end
    end
    if p193 == 15 then
      c58v2 = _T.mCachedSpecialSuitMode
      if not c58v2 then
        p193 = 18
      else
        p193 = 16
      end
    end
    if p193 == 16 then
      c58v3 = _T.SpecialSuitAvatar
      c58v2 = IsNull
      c58v2 = c58v2(c58v3)
      if c58v2 then
        p193 = 18
      else
        p193 = 17
      end
    end
    if p193 == 17 then
      c58v1 = _T.SpecialSuitAvatar
      p193 = 18
    end
    if p193 == 18 then
      c58v2 = IsNull
      c58v2 = c58v2(c58v0)
      if c58v2 then
        p193 = 22
      else
        p193 = 19
      end
    end
    if p193 == 19 then
      c58v2 = c58v0.IsAbility
      if not c58v2 then
        p193 = 22
      else
        p193 = 20
      end
    end
    if p193 == 20 then
      c58v2 = IsNull
      c58v2 = c58v2(c58v1)
      if c58v2 then
        p193 = 22
      else
        p193 = 21
      end
    end
    if p193 == 21 then
      c58v3 = c58v0.Movie
      c58v2 = IsNull
      c58v2 = c58v2(c58v3)
      if not c58v2 then
        p193 = 23
      else
        p193 = 22
      end
    end
    if p193 == 22 then
      c58v2 = {}
      c58v3 = {}
      c58v4 = {}
      c58v5 = {}
      do return c58v2, c58v3, c58v4, c58v5 end
    end
    if p193 == 23 then
      c58v2 = {}
      c58v3 = {}
      c58v4 = {}
      c58v5 = {}
      c58v6 = nil
      c58v7 = nil
      c58v8 = c58v0.Movie
      c58v11 = "/Lotus/Language/Menu/Ability_DurationInfinite"
      c58v12 = true
      c58v13 = {}
      c58v9 = c58v8:GetLocalized(c58v11, c58v12, c58v13)
      c58v10 = c58v1:InventoryControl()
      c58v11 = IsNull
      c58v11 = c58v11(c58v10)
      if c58v11 then
        p193 = 27
      else
        p193 = 24
      end
    end
    if p193 == 24 then
      c58v11 = c58v10:GetActivePowerSuit()
      c58v12 = IsNull
      c58v12 = c58v12(c58v11)
      if c58v12 then
        p193 = 27
      else
        p193 = 25
      end
    end
    if p193 == 25 then
      c58v12 = c58v0.AbilityIndex
      if c58v12 == nil then
        p193 = 27
      else
        p193 = 26
      end
    end
    if p193 == 26 then
      c58v14 = c58v0.AbilityIndex
      c58v11:Name__a5cba175(c58v14)
      p193 = 27
    end
    if p193 == 27 then
      c58v11 = Symbol
      c58v12 = "GetAbilityUpgradeLevelInfo"
      c58v11 = c58v11(c58v12)
      c58v12 = _T
      c58v13 = { ForceOverride = nil, Level = nil, Ability = nil, Avatar = nil, Modded = false }
      c58v14 = c58v0.ForceOverride
      c58v13.ForceOverride = c58v14
      c58v16 = c58v0.Level
      c58v15 = c58v16 or 0
      c58v14 = c58v15 + 1
      c58v13.Level = c58v14
      c58v14 = c58v0.Resource
      c58v13.Ability = c58v14
      c58v13.Avatar = c58v1
      c58v12.AbilityLevelQueryParms = c58v13
      c58v14 = c58v0.Script
      c58v16 = true
      c58v1:RunScript(c58v14, c58v11, c58v16)
      c58v6 = _T.AbilityUpgradeLevelInfo
      c58v12 = IsNull
      c58v12 = c58v12(c58v6)
      if c58v12 then
        p193 = 40
      else
        p193 = 28
      end
    end
    if p193 == 28 then
      c58v12 = c58v6.EnergyCost
      if c58v12 == nil then
        p193 = 40
      else
        p193 = 29
      end
    end
    if p193 == 29 then
      c58v12 = c58v6.EnergyCost
      if c58v12 ~= false then
        p193 = 31
      else
        p193 = 30
      end
    end
    if p193 == 30 then
      c58v12 = nil
      c58v0.Energy = c58v12
      p193 = 40
    end
    if p193 == 31 then
      c58v12 = c58v6.EnergyCost
      c58v13 = c58v6.EnergyCostMax
      c58v15 = c58v0.Suit
      c58v14 = IsNull
      c58v14 = c58v14(c58v15)
      if c58v14 then
        p193 = 37
      else
        p193 = 32
      end
    end
    if p193 == 32 then
      c58v14 = c58v6.EnergyIconOverride
      if c58v14 ~= nil then
        p193 = 37
      else
        p193 = 33
      end
    end
    if p193 == 33 then
      c58v14 = c58v0.Suit
      c58v15 = IsWeak
      c58v15 = c58v15(c58v14)
      if not c58v15 then
        p193 = 35
      else
        p193 = 34
      end
    end
    if p193 == 34 then
      c58v15 = Resource
      c58v14 = c58v15(c58v14)
      p193 = 35
    end
    if p193 == 35 then
      c58v17 = c58v6.EnergyCost
      c58v12 = c58v14:Name__9d3a8775(c58v17)
      if not c58v13 then
        p193 = 37
      else
        p193 = 36
      end
    end
    if p193 == 36 then
      c58v17 = c58v6.EnergyCostMax
      c58v13 = c58v14:Name__9d3a8775(c58v17)
      p193 = 37
    end
    if p193 == 37 then
      c58v0.Energy = c58v12
      c58v14 = c58v6.BaseEnergyCost
      if c58v14 then
        p193 = 39
      else
        p193 = 38
      end
    end
    if p193 == 38 then
      c58v14 = c58v6.EnergyCost
      p193 = 39
    end
    if p193 == 39 then
      c58v0.BaseEnergy = c58v14
      c58v0.EnergyValueMax = c58v13
      c58v14 = c58v6.EnergyLabel
      c58v0.EnergyLabel = c58v14
      c58v14 = c58v6.EnergyFormatting
      c58v0.EnergyFormatting = c58v14
      c58v14 = c58v6.EnergyIconOverride
      c58v0.EnergyIconOverride = c58v14
      p193 = 40
    end
    if p193 == 40 then
      c58v13 = c58v0.Resource
      c58v12 = IsNull
      c58v12 = c58v12(c58v13)
      if c58v12 then
        p193 = 43
      else
        p193 = 41
      end
    end
    if p193 == 41 then
      c58v12 = c58v0.Resource
      c58v14 = true
      c58v12 = c58v12:GetCooldownDuration(c58v14)
      c58v13 = 1
      if c58v12 <= c58v13 then
        p193 = 43
      else
        p193 = 42
      end
    end
    if p193 == 42 then
      c58v15 = "<TIMER>"
      c58v16 = true
      c58v13 = c58v8:GetLocalized(c58v15, c58v16)
      c58v14 = TitleCase
      c58v17 = "/Lotus/Language/Labels/GAMEPLAY_POWER_COOLDOWN"
      c58v18 = false
      c58v14 = c58v14(c58v8:GetLocalized(c58v17, c58v18))
      c58v17 = 1
      c58v15 = table.insert
      c58v15(c58v2, c58v17, c58v14)
      c58v17 = 1
      c58v20 = " "
      c58v21 = v0
      c58v21 = c58v21.FormatNumber
      c58v23 = 1
      c58v24 = false
      c58v21 = c58v21(c58v12, c58v23, c58v24)
      c58v18 = c58v13 .. c58v20 .. c58v21
      c58v15 = table.insert
      c58v15(c58v3, c58v17, c58v18)
      c58v17 = 1
      c58v15 = table.insert
      c58v15(c58v4, c58v17, c58v12)
      c58v17 = 1
      c58v18 = 0
      c58v15 = table.insert
      c58v15(c58v5, c58v17, c58v18)
      p193 = 43
    end
    if p193 == 43 then
      c58v12 = c58v0.Energy
      if c58v12 == nil then
        p193 = 62
      else
        p193 = 44
      end
    end
    if p193 == 44 then
      c58v12 = c58v0.Energy
      if c58v12 == 0 then
        p193 = 62
      else
        p193 = 45
      end
    end
    if p193 == 45 then
      c58v12 = TitleCase
      c58v16 = c58v0.EnergyLabel
      c58v15 = c58v16 or "/Lotus/Language/Labels/Drain_Ability"
      c58v16 = false
      c58v12 = c58v12(c58v8:GetLocalized(c58v15, c58v16))
      c58v14 = c58v0.Energy
      c58v13 = tonumber
      c58v13 = c58v13(c58v14)
      c58v15 = c58v0.BaseEnergy
      c58v14 = tonumber
      c58v14 = c58v14(c58v15)
      if c58v14 ~= nil then
        p193 = 47
      else
        p193 = 46
      end
    end
    if p193 == 46 then
      c58v14 = c58v13
      p193 = 47
    end
    if p193 == 47 then
      c58v15 = c58v14 - c58v13
      c58v17 = c58v0.EnergyIconOverride
      c58v16 = c58v17 or "<ENERGY>"
      c58v20 = true
      c58v16 = c58v8:GetLocalized(c58v16, c58v20)
      c58v17 = v0
      c58v17 = c58v17.Ternary
      c58v19 = 3.4028234663852886e+38
      if c58v13 == c58v19 then
        p193 = 49
      else
        p193 = 48
      end
    end
    if p193 == 48 then
      c58v18 = false
      p193 = 50
    end
    if p193 == 49 then
      c58v18 = true
      p193 = 50
    end
    if p193 == 50 then
      c58v20 = v0
      c58v20 = c58v20.FormatNumber
      c58v22 = 2
      c58v23 = false
      c58v13 = c58v17(c58v18, c58v9, c58v20(c58v13, c58v22, c58v23))
      c58v17 = c58v0.EnergyValueMax
      if c58v17 == nil then
        p193 = 55
      else
        p193 = 51
      end
    end
    if p193 == 51 then
      c58v17 = c58v13
      c58v18 = " - "
      c58v19 = v0
      c58v19 = c58v19.Ternary
      c58v21 = c58v0.EnergyValueMax
      c58v22 = 3.4028234663852886e+38
      if c58v21 == c58v22 then
        p193 = 53
      else
        p193 = 52
      end
    end
    if p193 == 52 then
      c58v20 = false
      p193 = 54
    end
    if p193 == 53 then
      c58v20 = true
      p193 = 54
    end
    if p193 == 54 then
      c58v22 = v0
      c58v22 = c58v22.FormatNumber
      c58v23 = c58v0.EnergyValueMax
      c58v24 = 2
      c58v25 = false
      c58v19 = c58v19(c58v20, c58v9, c58v22(c58v23, c58v24, c58v25))
      c58v13 = c58v17 .. c58v18 .. c58v19
      p193 = 55
    end
    if p193 == 55 then
      c58v17 = c58v0.ModdedStats
      if (not (c58v17) and c58v15 ~= 0) then
        p193 = 58
      else
        p193 = 57
      end
    end
    if p193 == 57 then
      c58v18 = " "
      c58v13 = c58v16 .. c58v18 .. c58v13
      p193 = 59
    end
    if p193 == 58 then
      c58v18 = " "
      c58v19 = v0
      c58v19 = c58v19.FormatNumber
      c58v21 = 2
      c58v22 = false
      c58v19 = c58v19(c58v14, c58v21, c58v22)
      c58v14 = c58v16 .. c58v18 .. c58v19
      p193 = 59
    end
    if p193 == 59 then
      c58v17 = c58v0.EnergyFormatting
      if c58v17 == nil then
        p193 = 61
      else
        p193 = 60
      end
    end
    if p193 == 60 then
      c58v19 = c58v0.EnergyFormatting
      c58v20 = true
      c58v21 = { COUNT = nil }
      c58v21.COUNT = c58v13
      c58v13 = c58v8:GetLocalized(c58v19, c58v20, c58v21)
      p193 = 61
    end
    if p193 == 61 then
      c58v19 = 1
      c58v17 = table.insert
      c58v17(c58v2, c58v19, c58v12)
      c58v19 = 1
      c58v17 = table.insert
      c58v17(c58v3, c58v19, c58v13)
      c58v19 = 1
      c58v17 = table.insert
      c58v17(c58v4, c58v19, c58v14)
      c58v19 = 1
      c58v17 = table.insert
      c58v17(c58v5, c58v19, c58v15)
      p193 = 62
    end
    if p193 == 62 then
      c58v12 = _T
      c58v13 = { ForceOverride = nil, Level = nil, Ability = nil, Avatar = nil, Modded = nil }
      c58v14 = c58v0.ForceOverride
      c58v13.ForceOverride = c58v14
      c58v16 = c58v0.Level
      c58v15 = c58v16 or 0
      c58v14 = c58v15 + 1
      c58v13.Level = c58v14
      c58v14 = c58v0.Resource
      c58v13.Ability = c58v14
      c58v13.Avatar = c58v1
      c58v15 = c58v0.BaseOnly
      c58v14 = not c58v15
      c58v13.Modded = c58v14
      c58v12.AbilityLevelQueryParms = c58v13
      c58v14 = c58v0.Script
      c58v16 = true
      c58v1:RunScript(c58v14, c58v11, c58v16)
      c58v7 = _T.AbilityUpgradeLevelInfo
      c58v12 = true
      if c58v7 == nil then
        p193 = 66
      else
        p193 = 63
      end
    end
    if p193 == 63 then
      c58v13 = c58v7.Modded
      if c58v13 == nil then
        p193 = 65
      else
        p193 = 64
      end
    end
    if p193 == 64 then
      c58v12 = false
      p193 = 66
    end
    if p193 == 65 then
      c58v12 = true
      p193 = 66
    end
    if p193 == 66 then
      c58v0.mDarken = c58v12
      c58v14 = 1
      c58v12 = #c58v7
      c58v13 = 1
      if (c58v13 > 0 and c58v14 > c58v12) or (c58v13 < 0 and c58v14 < c58v12) then
        p193 = 116
      else
        p193 = 67
      end
    end
    if p193 == 67 then
      c58v15 = c58v7[c58v14]
      c58v16 = IsNull
      c58v16 = c58v16(c58v15)
      if c58v16 then
        p193 = 115
      else
        p193 = 68
      end
    end
    if p193 == 68 then
      c58v18 = c58v15.Label
      c58v19 = true
      c58v20 = {}
      c58v16 = c58v8:GetLocalized(c58v18, c58v19, c58v20)
      c58v18 = c58v15.Value
      c58v17 = c58v18 or ""
      c58v19 = c58v6[c58v14]
      c58v19 = c58v19.Value
      c58v18 = c58v19 or ""
      c58v20 = c58v15.ValueMax
      c58v19 = c58v20 or ""
      c58v21 = c58v6[c58v14]
      c58v21 = c58v21.ValueMax
      c58v20 = c58v21 or ""
      c58v21 = true
      if c58v17 ~= c58v18 then
        p193 = 72
      else
        p193 = 69
      end
    end
    if p193 == 69 then
      if c58v19 ~= c58v20 then
        p193 = 71
      else
        p193 = 70
      end
    end
    if p193 == 70 then
      c58v21 = false
      p193 = 72
    end
    if p193 == 71 then
      c58v21 = true
      p193 = 72
    end
    if p193 == 72 then
      if not c58v21 then
        p193 = 88
      else
        p193 = 73
      end
    end
    if p193 == 73 then
      c58v23 = c58v15.Value
      c58v22 = c58v23 or 0
      c58v24 = c58v6[c58v14]
      c58v24 = c58v24.Value
      c58v23 = c58v24 or 0
      c58v25 = c58v15.ValueMax
      c58v24 = c58v25 or 0
      c58v26 = c58v6[c58v14]
      c58v26 = c58v26.ValueMax
      c58v25 = c58v26 or 0
      c58v26 = v0
      c58v26 = c58v26.Ternary
      if c58v22 == c58v23 then
        p193 = 75
      else
        p193 = 74
      end
    end
    if p193 == 74 then
      c58v27 = false
      p193 = 76
    end
    if p193 == 75 then
      c58v27 = true
      p193 = 76
    end
    if p193 == 76 then
      if c58v24 < c58v25 then
        p193 = 78
      else
        p193 = 77
      end
    end
    if p193 == 77 then
      c58v28 = false
      p193 = 79
    end
    if p193 == 78 then
      c58v28 = true
      p193 = 79
    end
    if p193 == 79 then
      if c58v22 < c58v23 then
        p193 = 81
      else
        p193 = 80
      end
    end
    if p193 == 80 then
      c58v29 = false
      p193 = 82
    end
    if p193 == 81 then
      c58v29 = true
      p193 = 82
    end
    if p193 == 82 then
      c58v26 = c58v26(c58v27, c58v28, c58v29)
      c58v27 = c58v15.SmallerIsBetter
      if (not (not c58v27) and c58v26) then
        p193 = 86
      else
        p193 = 84
      end
    end
    if p193 == 84 then
      c58v27 = c58v15.SmallerIsBetter
      if (c58v27 or c58v26) then
        p193 = 87
      else
        p193 = 86
      end
    end
    if p193 == 86 then
      c58v21 = 1
      p193 = 89
    end
    if p193 == 87 then
      c58v21 = -1
      p193 = 89
    end
    if p193 == 88 then
      c58v21 = 0
      p193 = 89
    end
    if p193 == 89 then
      c58v22 = c58v15.Title
      if not c58v22 then
        p193 = 91
      else
        p193 = 90
      end
    end
    if p193 == 90 then
      c58v22 = "<b>"
      c58v25 = string.upper
      c58v23 = c58v25(c58v16)
      c58v24 = "</b>"
      c58v16 = c58v22 .. c58v23 .. c58v24
      p193 = 114
    end
    if p193 == 91 then
      c58v22 = TitleCase
      c58v16 = c58v22(c58v16)
      c58v22 = v0
      c58v22 = c58v22.Ternary
      c58v24 = 3.4028234663852886e+38
      if c58v17 == c58v24 then
        p193 = 93
      else
        p193 = 92
      end
    end
    if p193 == 92 then
      c58v23 = false
      p193 = 94
    end
    if p193 == 93 then
      c58v23 = true
      p193 = 94
    end
    if p193 == 94 then
      c58v25 = v0
      c58v25 = c58v25.FormatNumber
      c58v27 = 2
      c58v28 = false
      c58v17 = c58v22(c58v23, c58v9, c58v25(c58v17, c58v27, c58v28))
      c58v22 = v0
      c58v22 = c58v22.Ternary
      c58v24 = 3.4028234663852886e+38
      if c58v18 == c58v24 then
        p193 = 96
      else
        p193 = 95
      end
    end
    if p193 == 95 then
      c58v23 = false
      p193 = 97
    end
    if p193 == 96 then
      c58v23 = true
      p193 = 97
    end
    if p193 == 97 then
      c58v25 = v0
      c58v25 = c58v25.FormatNumber
      c58v27 = 2
      c58v28 = false
      c58v18 = c58v22(c58v23, c58v9, c58v25(c58v18, c58v27, c58v28))
      c58v22 = c58v15.ValueMax
      if c58v22 == nil then
        p193 = 102
      else
        p193 = 98
      end
    end
    if p193 == 98 then
      c58v22 = c58v17
      c58v23 = " - "
      c58v24 = v0
      c58v24 = c58v24.Ternary
      c58v26 = c58v15.ValueMax
      c58v27 = 3.4028234663852886e+38
      if c58v26 == c58v27 then
        p193 = 100
      else
        p193 = 99
      end
    end
    if p193 == 99 then
      c58v25 = false
      p193 = 101
    end
    if p193 == 100 then
      c58v25 = true
      p193 = 101
    end
    if p193 == 101 then
      c58v27 = v0
      c58v27 = c58v27.FormatNumber
      c58v28 = c58v15.ValueMax
      c58v29 = 2
      c58v30 = false
      c58v24 = c58v24(c58v25, c58v9, c58v27(c58v28, c58v29, c58v30))
      c58v17 = c58v22 .. c58v23 .. c58v24
      p193 = 102
    end
    if p193 == 102 then
      c58v22 = c58v6[c58v14]
      c58v22 = c58v22.ValueMax
      if c58v22 == nil then
        p193 = 107
      else
        p193 = 103
      end
    end
    if p193 == 103 then
      c58v22 = c58v18
      c58v23 = " - "
      c58v24 = v0
      c58v24 = c58v24.Ternary
      c58v26 = c58v6[c58v14]
      c58v26 = c58v26.ValueMax
      c58v27 = 3.4028234663852886e+38
      if c58v26 == c58v27 then
        p193 = 105
      else
        p193 = 104
      end
    end
    if p193 == 104 then
      c58v25 = false
      p193 = 106
    end
    if p193 == 105 then
      c58v25 = true
      p193 = 106
    end
    if p193 == 106 then
      c58v27 = v0
      c58v27 = c58v27.FormatNumber
      c58v28 = c58v6[c58v14]
      c58v28 = c58v28.ValueMax
      c58v29 = 2
      c58v30 = false
      c58v24 = c58v24(c58v25, c58v9, c58v27(c58v28, c58v29, c58v30))
      c58v18 = c58v22 .. c58v23 .. c58v24
      p193 = 107
    end
    if p193 == 107 then
      c58v22 = c58v15.ValueUnit
      if c58v22 == nil then
        p193 = 109
      else
        p193 = 108
      end
    end
    if p193 == 108 then
      c58v24 = c58v15.ValueUnit
      c58v25 = true
      c58v26 = { COUNT = nil }
      c58v26.COUNT = c58v17
      c58v17 = c58v8:GetLocalized(c58v24, c58v25, c58v26)
      p193 = 109
    end
    if p193 == 109 then
      c58v22 = c58v15.ValueIcon
      if c58v22 == nil then
        p193 = 114
      else
        p193 = 110
      end
    end
    if p193 == 110 then
      c58v22 = c58v0.ModdedStats
      if (not (c58v22) and c58v21 ~= 0) then
        p193 = 113
      else
        p193 = 112
      end
    end
    if p193 == 112 then
      c58v27 = c58v15.ValueIcon
      c58v28 = true
      c58v22 = c58v8:GetLocalized(c58v27, c58v28)
      c58v23 = " "
      c58v17 = c58v22 .. c58v23 .. c58v17
      p193 = 114
    end
    if p193 == 113 then
      c58v27 = c58v15.ValueIcon
      c58v28 = true
      c58v22 = c58v8:GetLocalized(c58v27, c58v28)
      c58v23 = " "
      c58v18 = c58v22 .. c58v23 .. c58v18
      p193 = 114
    end
    if p193 == 114 then
      c58v22 = table.insert
      c58v22(c58v2, c58v16)
      c58v22 = table.insert
      c58v22(c58v3, c58v17)
      c58v22 = table.insert
      c58v22(c58v4, c58v18)
      c58v22 = table.insert
      c58v22(c58v5, c58v21)
      p193 = 115
    end
    if p193 == 115 then
      p193 = 116
    end
    if p193 == 116 then
      c58v12 = _T
      c58v13 = nil
      c58v12.AbilityLevelQueryParms = c58v13
      c58v12 = _T
      c58v13 = nil
      c58v12.AbilityUpgradeLevelInfo = c58v13
      do return c58v2, c58v3, c58v4, c58v5 end
    end
  end
  v41 = function(c61v0, c61v1, c61v2, c61v3, c61v4, c61v5, c61v6, c61v7, c61v8, c61v9, c61v10)
    local c61v11, c61v12, c61v13, c61v14, c61v15, c61v16, c61v17, c61v18, c61v19, c61v20, c61v21, c61v22, c61v24, c61v25, c61v26, c61v27, c61v28, c61v31, c61v32, c61v33, c61v34, c61v35, c61v36, c61v37, c61v38, c61v39, c61v40, c61v41, c61v42, c61v43, c61v44, c61v45, c61v46, c61v49, c61v52
    c61v25 = {}
    c61v26 = pairs
    c61v27 = c61v24.mStats
    c61v26, c61v27, c61v28 = c61v26(c61v27)
    for c61v29, c61v30 in c61v26, c61v27, c61v28 do
      c61v32 = 0
      c61v30.Order = c61v32
      c61v32 = string.find
      c61v34 = "_RESIST$"
      c61v32 = c61v32(c61v29, c61v34)
      c61v32 = 2
      c61v30.Order = c61v32
      c61v32 = string.find
      c61v34 = "DT_"
      c61v32 = c61v32(c61v29, c61v34)
      c61v32 = 10
      c61v30.Order = c61v32
      c61v32 = c61v30.Previous
      c61v32 = c61v30.Previous
      c61v32 = c61v32.StatValue
      c61v32 = c61v30.Current
      c61v32 = c61v30.Current
      c61v32 = c61v32.StatValue
      c61v32 = 99
      c61v30.Order = c61v32
      c61v32 = true
      c61v30.Removed = c61v32
      c61v32 = c61v30.Current
      c61v32 = c61v30.Current
      c61v32 = c61v32.StatValue
      c61v32 = c61v30.Previous
      c61v32 = c61v30.Previous
      c61v32 = c61v32.StatValue
      c61v32 = true
      c61v30.New = c61v32
      c61v32 = c61v30.Label
      if c61v32 then
        c61v30.StatId = c61v29
        c61v32 = table.insert
        c61v32(c61v25, c61v30)
      end
      for c61v23, c61v24 in c61v20, c61v21, c61v22 do
        c61v21 = ""
        do return c61v13, c61v21 end
      end
      c61v25 = c61v24.mExtra
      if not c61v25 then
        c61v19 = c61v19 + 1
      end
      c61v32 = type
      c61v32 = c61v32(c61v30)
      if c61v32 ~= "table" then
        c61v31 = false
      else
        c61v31 = true
      end
      c61v26 = table.sort
      c61v26(c61v25, c61v18)
      if c61v17 then
        c61v27 = ""
        c61v15(c61v27)
      end
      c61v26 = v12
      c61v27 = c61v24.mName
      c61v26 = c61v26(c61v27)
      if not c61v26 then
        c61v26 = #c61v16
        c61v27 = 1
        if c61v27 < c61v26 then
          if c61v2 then
            c61v27 = c61v24.mName
            c61v15(c61v27)
          else
            c61v28 = "<font color=\""
            c61v29 = "#4dd9e5"
            c61v30 = "\"><b>"
            c61v31 = c61v24.mName
            c61v32 = "</b></font>"
            c61v27 = c61v28 .. c61v29 .. c61v30 .. c61v31 .. c61v32
            c61v15(c61v27)
          end
        end
      end
      c61v26 = ipairs
      c61v26, c61v27, c61v28 = c61v26(c61v25)
      for c61v29, c61v30 in c61v26, c61v27, c61v28 do
        c61v31 = c61v30.DisplayValue
        c61v32 = c61v30.StatValue
        c61v33 = nil
        c61v34 = nil
        c61v35 = nil
        c61v36 = nil
        c61v37 = nil
        c61v38 = nil
        c61v39 = false
        c61v40 = false
        if c61v31 == nil then
          if c61v32 ~= nil then
            c61v41 = v0
            c61v41 = c61v41.FormatNumber
            c61v43 = 0
            c61v44 = false
            c61v31 = c61v41(c61v32, c61v43, c61v44)
          else
            if c61v14 then
              c61v41 = 0
              c61v42 = c61v30.Previous
              if c61v42 ~= nil then
                c61v42 = c61v30.Previous
                c61v31 = c61v42.DisplayValue
                c61v42 = c61v30.Previous
                c61v42 = c61v42.StatValue
                if c61v42 ~= nil then
                  c61v42 = c61v30.Previous
                  c61v41 = c61v42.StatValue
                  if c61v31 == nil then
                    c61v42 = v0
                    c61v42 = c61v42.FormatNumber
                    c61v44 = 0
                    c61v45 = false
                    c61v31 = c61v42(c61v41, c61v44, c61v45)
                  end
                end
                c61v42 = c61v30.Previous
                c61v34 = c61v42.ToolTip
                c61v42 = c61v30.Previous
                c61v35 = c61v42.SecondaryToolTips
                c61v42 = c61v30.Previous
                c61v37 = c61v42.HeaderOverride
                c61v42 = c61v30.Previous
                c61v42 = c61v42.HideStat
                c61v39 = not c61v42
              end
              c61v42 = 0
              c61v43 = c61v30.Current
              if c61v43 ~= nil then
                c61v43 = c61v30.Current
                c61v32 = c61v43.DisplayValue
                c61v43 = c61v30.Current
                c61v43 = c61v43.StatValue
                if c61v43 ~= nil then
                  c61v43 = c61v30.Current
                  c61v42 = c61v43.StatValue
                  if c61v32 == nil then
                    c61v43 = v0
                    c61v43 = c61v43.FormatNumber
                    c61v45 = 0
                    c61v46 = false
                    c61v32 = c61v43(c61v42, c61v45, c61v46)
                  end
                end
                c61v43 = c61v30.Current
                c61v34 = c61v43.ToolTip
                c61v43 = v15
                c61v45 = c61v30.Current
                c61v45 = c61v45.SecondaryToolTips
                c61v36, c61v38 = c61v43(c61v12, c61v45, c61v35)
                c61v43 = c61v30.Current
                c61v40 = c61v43.HideStat
                c61v43 = c61v30.Current
                c61v37 = c61v43.HeaderOverride
              end
              c61v43 = c61v30.TextOnly
              if not c61v43 then
                if c61v42 < c61v41 then
                  c61v33 = -1
                else
                  if c61v41 < c61v42 then
                    c61v33 = 1
                  end
                end
                c61v43 = c61v30.Removed
                if c61v43 then
                  c61v33 = -2
                else
                  c61v43 = c61v30.SmallerIsBetter
                  if not ((not c61v43 or c61v33 == nil)) then
                    c61v33 = c61v33 * -1
                  else
                    c61v43 = c61v30.New
                    if c61v43 then
                      c61v33 = -3
                    end
                  end
                end
              end
            end
          end
        end
        if not ((not (not c61v40) and not c61v39)) then
          c61v42 = c61v30.Label
          c61v44 = true
          c61v49 = c61v30.StatId
          c61v52 = c61v30.SearchLabel
          c61v15(c61v42, c61v31, c61v44, c61v32, c61v33, c61v34, c61v36, c61v49, c61v38, c61v37, c61v52)
        end
      end
      c61v17 = true
      local p130 = 0
      if p130 == 0 then
        c61v11 = v37
        c61v11 = c61v11()
        c61v12 = c61v11.mMovie
        if not c61v2 then
          p130 = 2
        else
          p130 = 1
        end
      end
      if p130 == 1 then
        c61v13 = { Labels = nil, Values = nil, CompareValues = nil, Comparison = nil, ToolTips = nil, SecondaryToolTips = nil, StatIds = nil, SecondaryComparison = nil, HeaderOverrides = nil, SearchLabels = nil }
        c61v14 = {}
        c61v13.Labels = c61v14
        c61v14 = {}
        c61v13.Values = c61v14
        c61v14 = {}
        c61v13.CompareValues = c61v14
        c61v14 = {}
        c61v13.Comparison = c61v14
        c61v14 = {}
        c61v13.ToolTips = c61v14
        c61v14 = {}
        c61v13.SecondaryToolTips = c61v14
        c61v14 = {}
        c61v13.StatIds = c61v14
        c61v14 = {}
        c61v13.SecondaryComparison = c61v14
        c61v14 = {}
        c61v13.HeaderOverrides = c61v14
        c61v14 = {}
        c61v13.SearchLabels = c61v14
        if c61v13 then
          p130 = 3
        else
          p130 = 2
        end
      end
      if p130 == 2 then
        c61v13 = ""
        p130 = 3
      end
      if p130 == 3 then
        c61v15 = IsNull
        c61v15 = c61v15(c61v9)
        c61v14 = not c61v15
        c61v15 = IsNull
        c61v15 = c61v15(c61v0)
        if not c61v15 then
          p130 = 5
        else
          p130 = 4
        end
      end
      if p130 == 4 then
        c61v16 = ""
        do return c61v13, c61v16 end
      end
      if p130 == 5 then
        c61v15 = function(c59v0, c59v1, c59v2, c59v3, c59v4, c59v5, c59v6, c59v7, c59v8, c59v9, c59v10)
          local c59v11, c59v12, c59v13, c59v14, c59v15, c59v16, c59v17, c59v18, c59v19, c59v22, c59v24
          c59v1 = c59v1 or "-"
          c59v3 = c59v3 or "-"
          c59v4 = c59v4 or 0
          c59v11 = c61v2
          if c59v11 then
            if not ((c59v1 ~= "-" or c59v3 ~= "-")) then
              c59v1 = ""
              c59v3 = ""
              c59v11 = #c59v0
              if c59v11 ~= 0 then
                c59v11 = "<font ><b>"
                c59v14 = string.upper
                c59v12 = c59v14(c59v0)
                c59v13 = "</b></font>"
                c59v0 = c59v11 .. c59v12 .. c59v13
              end
            else
              c59v11 = TitleCase
              c59v0 = c59v11(c59v0)
            end
            c59v12 = c61v13
            c59v12 = c59v12.Labels
            c59v11 = table.insert
            c59v11(c59v12, c59v0)
            c59v12 = c61v13
            c59v12 = c59v12.Values
            c59v11 = table.insert
            c59v11(c59v12, c59v1)
            c59v12 = c61v13
            c59v12 = c59v12.CompareValues
            c59v11 = table.insert
            c59v11(c59v12, c59v3)
            c59v12 = c61v13
            c59v12 = c59v12.Comparison
            c59v11 = table.insert
            c59v11(c59v12, c59v4)
            c59v12 = c61v13
            c59v12 = c59v12.ToolTips
            c59v13 = c59v5 or ""
            c59v11 = table.insert
            c59v11(c59v12, c59v13)
            c59v12 = c61v13
            c59v12 = c59v12.SecondaryToolTips
            c59v13 = c59v6 or ""
            c59v11 = table.insert
            c59v11(c59v12, c59v13)
            c59v12 = c61v13
            c59v12 = c59v12.StatIds
            c59v13 = c59v7 or ""
            c59v11 = table.insert
            c59v11(c59v12, c59v13)
            c59v12 = c61v13
            c59v12 = c59v12.SecondaryComparison
            c59v13 = c59v8 or -1
            c59v11 = table.insert
            c59v11(c59v12, c59v13)
            c59v12 = c61v13
            c59v12 = c59v12.HeaderOverrides
            c59v13 = c59v9 or ""
            c59v11 = table.insert
            c59v11(c59v12, c59v13)
            c59v12 = c61v13
            c59v12 = c59v12.SearchLabels
            c59v13 = c59v10 or ""
            c59v11 = table.insert
            c59v11(c59v12, c59v13)
            do return end
          end
          c59v11 = v0
          c59v11 = c59v11.Ternary
          c59v13 = c61v4
          c59v12 = IsNull
          c59v12 = c59v12(c59v13)
          c59v13 = "#999999"
          c59v14 = c61v4
          c59v11 = c59v11(c59v12, c59v13, c59v14)
          c59v12 = v0
          c59v12 = c59v12.Ternary
          c59v14 = c61v5
          c59v13 = IsNull
          c59v13 = c59v13(c59v14)
          c59v14 = "#FFFFFF"
          c59v15 = c61v5
          c59v12 = c59v12(c59v13, c59v14, c59v15)
          c59v13 = v0
          c59v13 = c59v13.Ternary
          c59v14 = c61v6
          c59v15 = "<b>"
          c59v16 = ""
          c59v13 = c59v13(c59v14, c59v15, c59v16)
          c59v14 = v0
          c59v14 = c59v14.Ternary
          c59v15 = c61v6
          c59v16 = "</b>"
          c59v17 = ""
          c59v14 = c59v14(c59v15, c59v16, c59v17)
          c59v17 = "%:"
          c59v18 = ""
          c59v0 = c59v0:gsub(c59v17, c59v18)
          c59v16 = c61v13
          c59v17 = "<font color=\""
          c59v19 = "\">"
          c59v15 = c59v16 .. c59v17 .. c59v11 .. c59v19 .. c59v0
          c61v13 = c59v15
          if c59v2 then
            c59v16 = c61v13
            c59v17 = ": "
            c59v15 = c59v16 .. c59v17
            c61v13 = c59v15
          end
          c59v16 = c61v13
          c59v17 = "</font>"
          c59v15 = c59v16 .. c59v17
          c61v13 = c59v15
          c59v16 = c61v13
          c59v17 = "<font color=\""
          c59v19 = "\">"
          c59v22 = "\r\n"
          c59v24 = "</font>"
          c59v15 = c59v16 .. c59v17 .. c59v12 .. c59v19 .. c59v13 .. c59v1 .. c59v22 .. c59v14 .. c59v24
          c61v13 = c59v15
          do return end
        end
        c61v16 = c61v0
        c61v17 = type
        c61v17 = c61v17(c61v0)
        if c61v17 == "table" then
          p130 = 7
        else
          p130 = 6
        end
      end
      if p130 == 6 then
        c61v17 = v38
        c61v20 = false
        c61v21 = false
        c61v16 = c61v17(c61v0, c61v3, c61v20, c61v21, c61v8, c61v1)
        p130 = 7
      end
      if p130 == 7 then
        if not c61v14 then
          p130 = 12
        else
          p130 = 8
        end
      end
      if p130 == 8 then
        c61v17 = nil
        c61v18 = type
        c61v18 = c61v18(c61v9)
        if c61v18 ~= "table" then
          p130 = 10
        else
          p130 = 9
        end
      end
      if p130 == 9 then
        c61v17 = c61v9
        p130 = 11
      end
      if p130 == 10 then
        c61v18 = v38
        c61v21 = false
        c61v22 = false
        c61v17 = c61v18(c61v9, c61v3, c61v21, c61v22, c61v8, c61v1)
        p130 = 11
      end
      if p130 == 11 then
        c61v18 = v39
        c61v16 = c61v18(c61v16, c61v17)
        p130 = 12
      end
      if p130 == 12 then
        if not c61v10 then
          p130 = 14
        else
          p130 = 13
        end
      end
      if p130 == 13 then
        c61v20 = "/Lotus/Language/Stats/TIP_BaseStats"
        c61v21 = false
        c61v15(c61v12:GetLocalized(c61v20, c61v21))
        p130 = 14
      end
      if p130 == 14 then
        c61v17 = false
        c61v18 = function(c60v0, c60v1)
          local c60v2, c60v3, c60v4
          c60v2 = c60v0.Order
          if c60v2 ~= nil then
            c60v2 = c60v1.Order
            if c60v2 ~= nil then
              c60v2 = c60v0.Order
              c60v3 = c60v1.Order
              if c60v2 ~= c60v3 then
                c60v3 = c60v0.Order
                c60v4 = c60v1.Order
                if c60v4 <= c60v3 then
                  c60v2 = false
                else
                  c60v2 = true
                end
                do return c60v2 end
              end
            end
          end
          c60v3 = c60v0.Label
          c60v2 = IsNull
          c60v2 = c60v2(c60v3)
          if c60v2 then
            c60v2 = false
            do return c60v2 end
          end
          c60v3 = c60v1.Label
          c60v2 = IsNull
          c60v2 = c60v2(c60v3)
          if c60v2 then
            c60v2 = true
            do return c60v2 end
          end
          c60v3 = c60v0.Label
          c60v4 = c60v1.Label
          if c60v4 <= c60v3 then
            c60v2 = false
          else
            c60v2 = true
          end
          do return c60v2 end
        end
        c61v19 = 0
        c61v20 = ipairs
        c61v20, c61v21, c61v22 = c61v20(c61v16)
      end
    end
  end
  v42 = function(c62v0, c62v1, c62v2)
    local c62v3
    c62v3 = v18
    c62v3 = c62v3(c62v0, c62v1, c62v2)
    do return c62v3 end
  end
  GetCrewShipStats = v42
  v42 = function(c63v0, c63v1, c63v2, c63v3, c63v4)
    local c63v5
    c63v5 = v19
    c63v5 = c63v5(c63v0, c63v1, c63v2, c63v3, c63v4)
    do return c63v5 end
  end
  GetPowerSuitStats = v42
  v42 = function(c64v0, c64v1, c64v2, c64v3, c64v4, c64v5, c64v6)
    local c64v7, c64v11
    c64v7 = v38
    c64v11 = false
    c64v7 = c64v7(c64v0, c64v1, c64v2, c64v11, c64v4, c64v5, c64v6)
    do return c64v7 end
  end
  GetLabelledStats = v42
  v42 = function(c65v0, c65v1)
    local c65v2
    c65v2 = v39
    c65v2 = c65v2(c65v0, c65v1)
    do return c65v2 end
  end
  GetStatsComparison = v42
  v42 = function(c66v0, c66v1, c66v2, c66v3, c66v4, c66v5, c66v6, c66v7, c66v8, c66v9, c66v10)
    local c66v11, c66v12
    c66v11 = v41
    c66v11, c66v12 = c66v11(c66v0, c66v1, c66v2, c66v3, c66v4, c66v5, c66v6, c66v7, c66v8, c66v9, c66v10)
    do return c66v11, c66v12 end
  end
  GetStatsTextForItem = v42
  v42 = function(c67v0)
    local c67v1, c67v2, c67v3, c67v4
    c67v1 = v40
    c67v1, c67v2, c67v3, c67v4 = c67v1(c67v0)
    do return c67v1, c67v2, c67v3, c67v4 end
  end
  GetStatsTextForAbility = v42
  do return end
end
