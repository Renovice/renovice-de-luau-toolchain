function proto_0()
  local v0, v2, v3
  v0 = mMovie
  v2 = "Popup.VideoPreview.Image"
  v0:StopVideoTexture(v2)
  v0 = mMovie
  v2 = "Popup.VideoPreview.Image"
  v3 = nil
  v0:OverrideTexture(v2, v3)
  v0 = mMovie
  v2 = false
  v0:SetVisible(v2)
  v0 = u0
  if not v0 then
    v0 = mMovie
    v0:Close()
  end
  do return end
end
function proto_1()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8
  v0 = u0
  if not v0 then
    v0 = true
    u0 = v0
    v0 = u1
    if not v0 then
      v0 = u2
      v2 = u3
      v0:RemoveTimer(v2)
      v0 = _T
      v3 = _T.ItemInfoPopupCount
      v2 = v3 or 1
      v1 = v2 - 1
      v0.ItemInfoPopupCount = v1
    end
    v0 = u4
    if v0 then
      v0 = u5
      v1 = false
      v0(v1)
    end
    v0 = nil
    u6 = v0
    v0 = u7
    v1 = nil
    v0.TargetX = v1
    v0 = u7
    v1 = nil
    v0.TargetY = v1
    v0 = FlashInterpolate
    v1 = mMovie
    v2 = "Popup"
    v3 = 2
    v5 = 12
    v4 = {v5}
    v6 = 0
    v5 = {v6}
    v6 = 0.1
    v7 = 0
    v8 = function()
      local c1v0, c1v2, c1v3
      c1v0 = mMovie
      c1v2 = "Popup.VideoPreview.Image"
      c1v0:StopVideoTexture(c1v2)
      c1v0 = mMovie
      c1v2 = "Popup.VideoPreview.Image"
      c1v3 = nil
      c1v0:OverrideTexture(c1v2, c1v3)
      c1v0 = mMovie
      c1v2 = false
      c1v0:SetVisible(c1v2)
      c1v0 = u1
      if not c1v0 then
        c1v0 = mMovie
        c1v0:Close()
      end
      do return end
    end
    v0(v1, v2, v3, v4, v5, v6, v7, v8)
  end
  do return end
end

function proto_2(v0)
  local v1, v3, v4
  v1 = string.gsub
  v3 = "[%(%)%.%%%+%-%*%?%[%]%^%$]"
  v4 = "%%%0"
  do return v1(v0, v3, v4) end
end

function proto_3()
  local v0, v1, v2
  v0 = _T.InfoPopup_Grid
  v1 = false
  if v0 ~= nil then
    v1 = v0.CanPreviewElements
  end
  v2 = u0
  if v0 == nil then
    v2 = u0
    v2 = v2.CanPreviewOverride
    if v2 ~= nil then
      v2 = v1
      if v2 then
        v2 = u0
        v2 = v2.CanPreviewOverride
      end
      v1 = v2
    end
  end
  do return v1 end
end

function proto_4()
  local v0, v1
  v0 = false
  v1 = u0
  if v1 ~= nil then
    v1 = u0
    v1 = v1.mUnequipItem
    if v1 == nil then
      v0 = false
    else
      v0 = true
    end
  end
  do return v0 end
end

function proto_5()
  local v0, v1
  v0 = false
  v1 = u0
  if v1 ~= nil then
    v1 = u0
    v1 = v1.RightPressedCallback
    if v1 == nil then
      v0 = false
    else
      v0 = true
    end
  end
  do return v0 end
end

function proto_6()
  local v0, v1, v2
  v0 = Engine.IsPlayingWithTouchscreen
  v0 = v0()
  if not v0 then
    v0 = false
    do return v0 end
  end
  v0 = _T.InfoPopup_Grid
  if v0 ~= nil then
    v1 = v0.ShowSelectButton
    if v1 ~= nil then
      v1 = v0.ShowSelectButton
      v2 = _T.InfoPopup_Data
      do return v1(v2) end
    end
  end
  v1 = false
  do return v1 end
end

function proto_7()
  local v0, v1, v3, v4
  v0 = _T.InfoPopup_Grid
  if v0 ~= nil then
    v1 = v0.GetSelectButtonText
    if v1 ~= nil then
      v1 = v0.GetSelectButtonText
      do return v1() end
    end
  end
  v1 = mMovie
  v3 = "/Lotus/Language/Menu/Select"
  v4 = false
  do return v1:GetLocalized(v3, v4) end
end

function proto_8()
  local v0, v1, v2, v3, v4
  v1 = u0
  v0 = IsNull
  v0 = v0(v1)
  if v0 then
    do return end
  end
  v0 = u0
  v2 = u1
  v0:SetText(v2())
  v0 = mMovie
  v2 = "Popup.SelectButton"
  v3 = 14
  v4 = u2
  v0:SetNumberVariable(v2, v3, v4)
  v0 = mMovie
  v2 = "Popup.SelectButton"
  v3 = 0
  v4 = 54
  v0:SetNumberVariable(v2, v3, v4)
  do return end
end

function proto_9()
  local v0, v1, v2, v3, v4, v5
  v0 = _T.InfoPopup_Grid
  if v0 ~= nil then
    v1 = v0.SelectButtonCallback
    if v1 ~= nil then
      v1 = v0.SelectButtonCallback
      v1()
      v2 = u0
      v1 = IsNull
      v1 = v1(v2)
      if v1 then
        do return end
      end
      v1 = u0
      v3 = u1
      v1:SetText(v3())
      v1 = mMovie
      v3 = "Popup.SelectButton"
      v4 = 14
      v5 = u2
      v1:SetNumberVariable(v3, v4, v5)
      v1 = mMovie
      v3 = "Popup.SelectButton"
      v4 = 0
      v5 = 54
      v1:SetNumberVariable(v3, v4, v5)
    end
  end
  do return end
end

function proto_10()
  local v0, v1, v2, v3, v4, v5
  v0 = mMovie
  v0 = v0:GetInputFilter()
  u0 = v0
  v0 = require
  v1 = "Lotus.Interface.Components.ThemedButton"
  v0 = v0(v1)
  v1 = v0.Create
  v2 = mMovie
  v3 = "Popup.SelectButton"
  v4 = ""
  v5 = nil
  v1 = v1(v2, v3, v4, v5)
  u1 = v1
  v1 = u1
  v3 = "OnSelectButtonPressed"
  v1:SetReleasedCallback(v3)
  v1 = u1
  v1:SetSpecialMode()
  v1 = u1
  v3 = 280
  v1:SetWidth(v3)
  v1 = mMovie
  v3 = "Popup.SelectButton"
  v4 = 13
  v5 = false
  v1:Name__d9713943(v3, v4, v5)
  v1 = u1
  v3 = false
  v1:SetActive(v3)
  v1 = u1
  v1:Redraw()
  do return end
end

function proto_11()
  local v0, v1, v2, v3, v4, v5, v6
  v1 = u0
  v0 = IsNull
  v0 = v0(v1)
  if v0 then
    do return end
  end
  v1 = Engine.IsPlayingWithTouchscreen
  v1 = v1()
  if not v0 then
    v0 = false
  else
    local p20 = 4
    if p20 == 4 then
      v1 = _T.InfoPopup_Grid
      if v1 == nil then
        p20 = 7
      else
        p20 = 5
      end
    end
    if p20 == 5 then
      v2 = v1.ShowSelectButton
      if v2 == nil then
        p20 = 7
      else
        p20 = 6
      end
    end
    if p20 == 6 then
      v2 = v1.ShowSelectButton
      v3 = _T.InfoPopup_Data
      v0 = v2(v3)
    end
    if p20 == 7 then
      v0 = false
    end
  end
  v1 = u1
  if v0 == v1 then
    do return end
  end
  u1 = v0
  v1 = mMovie
  v3 = u2
  v3 = v3.Ternary
  v4 = u1
  v5 = u3
  v6 = u4
  v1:SetInputFilter(v3(v4, v5, v6))
  v1 = mMovie
  v3 = "Popup.SelectButton"
  v4 = 13
  v5 = u1
  v1:Name__d9713943(v3, v4, v5)
  v1 = u0
  v3 = u1
  v1:SetActive(v3)
  v2 = u0
  v1 = IsNull
  v1 = v1(v2)
  if v1 then
  else
    v1 = u0
    v3 = u5
    v1:SetText(v3())
    v1 = mMovie
    v3 = "Popup.SelectButton"
    v4 = 14
    v5 = u6
    v1:SetNumberVariable(v3, v4, v5)
    v1 = mMovie
    v3 = "Popup.SelectButton"
    v4 = 0
    v5 = 54
    v1:SetNumberVariable(v3, v4, v5)
  end
  v1 = u0
  v1:Redraw()
  do return end
end

function proto_12(v0, v1)
  local v2, v3, v4, v5, v6, v7, v8
  v2 = mMovie
  v4 = "Popup"
  v5 = 2
  v2 = v2:GetNumberVariable(v4, v5)
  v3 = mMovie
  v5 = "Popup"
  v6 = 3
  v3 = v3:GetNumberVariable(v5, v6)
  v4 = { x = nil, y = nil }
  v4.x = v2
  v4.y = v3
  v5 = u0
  v5 = v5.TransformPixelToViewportCoordinates
  v6 = mMovie
  v4 = v5(v6, v4)
  v5 = { x = nil, y = nil }
  v7 = u1
  v6 = v2 + v7
  v5.x = v6
  v7 = u2
  v6 = v3 + v7
  v5.y = v6
  v6 = u0
  v6 = v6.TransformPixelToViewportCoordinates
  v7 = mMovie
  v5 = v6(v7, v5)
  v6 = { xMin = nil, yMin = nil, xMax = nil, yMax = nil }
  v7 = v4.x
  v6.xMin = v7
  v7 = v4.y
  v6.yMin = v7
  v7 = v5.x
  v6.xMax = v7
  v7 = v5.y
  v6.yMax = v7
  v7 = false
  v8 = v6.xMin
  if v8 < v0 then
    v7 = false
    v8 = v6.xMax
    if v0 < v8 then
      v7 = false
      v8 = v6.yMin
      if v8 < v1 then
        v8 = v6.yMax
        if v8 <= v1 then
          v7 = false
        else
          v7 = true
        end
      end
    end
  end
  do return v7 end
end

function proto_13()
  do return end
end

function proto_14()
  local v0, v1, v2, v3, v4
  local p40 = 0
  if p40 == 0 then
    v2 = _T.InfoPopup_Grid
    v3 = false
    if v2 == nil then
      p40 = 2
    else
      p40 = 1
    end
  end
  if p40 == 1 then
    v3 = v2.CanPreviewElements
    p40 = 2
  end
  if p40 == 2 then
    v4 = u0
    if v4 == nil then
      p40 = 7
    else
      p40 = 3
    end
  end
  if p40 == 3 then
    v4 = u0
    v4 = v4.CanPreviewOverride
    if v4 == nil then
      p40 = 7
    else
      p40 = 4
    end
  end
  if p40 == 4 then
    v4 = v3
    if not v4 then
      p40 = 6
    else
      p40 = 5
    end
  end
  if p40 == 5 then
    v4 = u0
    v4 = v4.CanPreviewOverride
    p40 = 6
  end
  if p40 == 6 then
    v3 = v4
    p40 = 7
  end
  if p40 == 7 then
    v1 = v3
    if v1 then
      p40 = 18
    else
      p40 = 8
    end
  end
  if p40 == 8 then
    v1 = false
    v2 = u0
    if v2 == nil then
      p40 = 12
    else
      p40 = 9
    end
  end
  if p40 == 9 then
    v2 = u0
    v2 = v2.mUnequipItem
    if v2 ~= nil then
      p40 = 11
    else
      p40 = 10
    end
  end
  if p40 == 10 then
    v1 = false
    p40 = 12
  end
  if p40 == 11 then
    v1 = true
    p40 = 12
  end
  if p40 == 12 then
    if v1 then
      p40 = 18
    else
      p40 = 13
    end
  end
  if p40 == 13 then
    v0 = false
    v1 = u0
    if v1 == nil then
      p40 = 17
    else
      p40 = 14
    end
  end
  if p40 == 14 then
    v1 = u0
    v1 = v1.RightPressedCallback
    if v1 ~= nil then
      p40 = 16
    else
      p40 = 15
    end
  end
  if p40 == 15 then
    v0 = false
    p40 = 17
  end
  if p40 == 16 then
    v0 = true
    p40 = 17
  end
  if p40 == 17 then
    if not v0 then
      p40 = 25
    else
      p40 = 18
    end
  end
  if p40 == 18 then
    v2 = Engine.IsPlayingWithTouchscreen
    v2 = v2()
    if v2 then
      p40 = 20
    else
      p40 = 19
    end
  end
  if p40 == 19 then
    v1 = false
    p40 = 24
  end
  if p40 == 20 then
    v2 = _T.InfoPopup_Grid
    if v2 == nil then
      p40 = 23
    else
      p40 = 21
    end
  end
  if p40 == 21 then
    v3 = v2.ShowSelectButton
    if v3 == nil then
      p40 = 23
    else
      p40 = 22
    end
  end
  if p40 == 22 then
    v3 = v2.ShowSelectButton
    v4 = _T.InfoPopup_Data
    v1 = v3(v4)
    p40 = 24
  end
  if p40 == 23 then
    v1 = false
    p40 = 24
  end
  if p40 == 24 then
    v0 = not v1
    p40 = 25
  end
  if p40 == 25 then
    do return v0 end
  end
end

function proto_15()
  do return end
end

function proto_16()
  do return end
end

function proto_17(v0, v1, v2, v3)
  local v4, v5, v6, v7, v8, v9
  v4 = false
  v5 = u0
  if v5 ~= nil then
    v5 = u0
    v5 = v5.ModdedStats
    v4 = not v5
    if v4 then
      v4 = false
      if v2 ~= 0 then
        if v1 == nil then
          v4 = false
        else
          v4 = true
        end
      end
    end
  end
  v5 = true
  if v3 ~= true then
    if v2 ~= nil then
      v5 = false
    else
      v5 = true
    end
  end
  v3 = v5
  if v4 then
    v5 = mMovie
    v7 = "<MINI_ARROW>"
    v8 = true
    v6 = v5:GetLocalized(v7, v8)
    v0 = v6 .. v0
  end
  if not v3 then
    v5 = 0
    if v2 < v5 then
      v5 = "<font color=\""
      v6 = u1
      v6 = v6.NegativeHex
      v7 = "\">"
      v9 = "</font>"
      v0 = v5 .. v6 .. v7 .. v0 .. v9
    else
      v5 = 0
      if v5 < v2 then
        v5 = "<font color=\""
        v6 = u1
        v6 = v6.PositiveHex
        v7 = "\">"
        v9 = "</font>"
        v0 = v5 .. v6 .. v7 .. v0 .. v9
      end
    end
  end
  if v4 then
    v0 = v1 .. v0
  end
  do return v0 end
end

function proto_18()
  local v0, v1, v2, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16
  local v3 = 1
  v1 = u7
  v2 = 1
  for v3 = v3, v1, v2 do
    v5 = "Popup.ItemStats.Item"
    v4 = v5 .. v3
    v5 = mMovie
    v8 = "Backer"
    v9 = 11
    v10 = u6
    v10 = v10.Background1
    v5:Name__52c1b74e(v4, v8, v9, v10)
    v6 = u0
    v6 = v6.Labels
    v5 = v6[v3]
    if v5 ~= nil then
      v7 = u0
      v7 = v7.Values
      v6 = v7[v3]
      if v6 == "" then
        v6 = "<p><font color=\""
        v7 = u6
        v7 = v7.FloatingContentHighlightHex
        v8 = "\">"
        v10 = "</font></p>"
        v5 = v6 .. v7 .. v8 .. v5 .. v10
        v6 = mMovie
        v10 = ".Labels"
        v8 = v4 .. v10
        v9 = 36
        v6:SetStringVariable(v8, v9, v5)
      else
        v6 = "<p><font color=\""
        v7 = u6
        v7 = v7.FloatingContentHex
        v8 = "\">"
        v10 = "</font></p>"
        v5 = v6 .. v7 .. v8 .. v5 .. v10
        v6 = mMovie
        v10 = ".Labels"
        v8 = v4 .. v10
        v9 = 36
        v6:SetStringVariable(v8, v9, v5)
        v7 = "<p><font color=\""
        v8 = u6
        v8 = v8.FloatingContentHighlightHex
        v9 = "\">"
        v12 = u1
        v14 = u0
        v14 = v14.Values
        v13 = v14[v3]
        v15 = u0
        v15 = v15.BaseValues
        v14 = v15[v3]
        v16 = u0
        v16 = v16.StatChanges
        v15 = v16[v3]
        v10 = v12(v13, v14, v15)
        v11 = "</font></p>"
        v6 = v7 .. v8 .. v9 .. v10 .. v11
        v7 = mMovie
        v11 = ".Stats"
        v9 = v4 .. v11
        v10 = 36
        v7:SetStringVariable(v9, v10, v6)
      end
    end
  end
  v1 = mMovie
  v0 = IsNull
  v0 = v0(v1)
  v0 = u0
  v0 = v0.BonusStats
  v1 = ""
  v2 = v0.StatChanges
  v5 = 1
  v6 = v0.Labels
  v3 = #v6
  v4 = 1
  for v5 = v5, v3, v4 do
    v6 = #v1
    v7 = 0
    if v7 < v6 then
      v7 = "\r\n"
      v1 = v1 .. v7
    end
    v6 = nil
    if v2 ~= nil then
      v6 = v2[v5]
    end
    v7 = u1
    v9 = v0.Values
    v8 = v9[v5]
    v9 = nil
    v7 = v7(v8, v9, v6)
    v8 = string.gsub
    v10 = "%%"
    v11 = "%%%0"
    v7 = v8(v7, v10, v11)
    v8 = string.gsub
    v10 = v0.Labels
    v9 = v10[v5]
    v10 = "%[STAT%]"
    v8 = v8(v9, v10, v7)
    v1 = v1 .. v8
  end
  if v0 then
    local p25 = 8
    if p25 == 8 then
      v3 = u2
      v4 = u3
      v4 = v4.STATS
      if v3 == v4 then
        p25 = 11
      else
        p25 = 9
      end
    end
    if p25 == 9 then
      v3 = u4
      if v3 == 0 then
        p25 = 11
      else
        p25 = 10
      end
    end
    if p25 == 10 then
      v8 = u5
      v9 = 1
      v10 = u4
      v7 = string.sub
      v3 = v7(v8, v9, v10)
      v4 = "\r\n\r\n"
      v7 = u5
      v9 = u4
      v8 = v9 + 1
      v6 = string.sub
      v6 = v6(v7, v8)
      v1 = v3 .. v4 .. v1 .. v6
      p25 = 12
    end
    if p25 == 11 then
      v1 = u5
      p25 = 12
    end
    if p25 == 12 then
      v3 = mMovie
      v5 = "Popup.Description"
      v6 = 36
      v8 = "<p><font color=\""
      v9 = u6
      v9 = v9.ContentHex
      v10 = "\">"
      v12 = "</font></p>"
      v7 = v8 .. v9 .. v10 .. v1 .. v12
      v3:SetStringVariable(v5, v6, v7)
    end
  end
  do return end
end

function proto_19()
  local v0, v1, v2
  v1 = _T.ItemInfoStatComparison
  v0 = IsNull
  v0 = v0(v1)
  if v0 then
    do return end
  end
  v0 = u0
  if v0 then
    v0 = _T.ItemInfoStatComparison
    v0()
    do return end
  end
  v0 = _T.ItemInfoStatComparison
  v1 = u1
  v2 = u2
  v0(v1, v2)
  do return end
end

function proto_20(v0, v1)
  local v2, v3, v4, v5, v6, v7
  v3 = IsNull
  v3 = v3(v1)
  if not v3 then
    v2 = v1
  else
    v4 = u0
    v4 = v4.Suit
    v3 = IsNull
    v3 = v3(v4)
    if not v3 then
      v3 = u0
      v2 = v3.Suit
      v3 = IsWeak
      v3 = v3(v2)
      if v3 then
        v3 = Resource
        v2 = v3(v2)
      end
    end
  end
  v3 = u0
  v3 = v3.AdditionalPreviewImages
  if v3 then
    v3 = u1
    v3 = v3.mCurrentElementIndex
    v4 = 1
    if v4 < v3 then
      v3 = u0
      v5 = u0
      v5 = v5.AdditionalPreviewImages
      v7 = u1
      v7 = v7.mCurrentElementIndex
      v6 = v7 - 1
      v4 = v5[v6]
      v3.PreviewImage = v4
    else
      v3 = u0
      v4 = v0:GetVideoTexture()
      v3.PreviewImage = v4
    end
    v3 = u0
    v4 = true
    v3.RefreshImage = v4
  end
  do return end
end

function proto_21(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15
  local p36 = 0
  if p36 == 0 then
    v1 = IsNull
    v1 = v1(v0)
    if v1 then
      p36 = 2
    else
      p36 = 1
    end
  end
  if p36 == 1 then
    v1 = IsWeak
    v1 = v1(v0)
    if not v1 then
      p36 = 3
    else
      p36 = 2
    end
  end
  if p36 == 2 then
    do return end
  end
  if p36 == 3 then
    v2 = u0
    v2 = v2:GetHowManyElements()
    v3 = 1
    if v3 < v2 then
      p36 = 5
    else
      p36 = 4
    end
  end
  if p36 == 4 then
    v1 = false
    p36 = 6
  end
  if p36 == 5 then
    v1 = true
    p36 = 6
  end
  if p36 == 6 then
    v2 = require
    v3 = "Lotus.Powersuits.PowersuitAbilities.PVPLib"
    v2 = v2(v3)
    v3 = nil
    v4 = false
    v5 = u1
    v5 = v5.ForceOverrideDesc
    if not v5 then
      p36 = 9
    else
      p36 = 7
    end
  end
  if p36 == 7 then
    v5 = v0:Name__b92141d1()
    v6 = EMPTY_SYMBOL
    if v5 == v6 then
      p36 = 9
    else
      p36 = 8
    end
  end
  if p36 == 8 then
    v5 = v0:Name__b92141d1()
    v3 = v5:c_str()
    p36 = 10
  end
  if p36 == 9 then
    v5 = v0:GetLocalizeDescTag()
    v3 = v5:c_str()
    v4 = true
    p36 = 10
  end
  if p36 == 10 then
    v5 = v2.IsPvpEnabled
    v5 = v5()
    if not v5 then
      p36 = 13
    else
      p36 = 11
    end
  end
  if p36 == 11 then
    v6 = v0:GetPvpDescription()
    v7 = string.len
    v7 = v7(v6)
    if v7 == 0 then
      p36 = 13
    else
      p36 = 12
    end
  end
  if p36 == 12 then
    v3 = v6
    p36 = 13
  end
  if p36 == 13 then
    v6 = nil
    if not v4 then
      p36 = 17
    else
      p36 = 14
    end
  end
  if p36 == 14 then
    v7 = v0:GetScript()
    v8 = gRegion
    v8 = v8:GetLocalPlayerAvatar()
    v9 = IsNull
    v9 = v9(v8)
    if v9 then
      p36 = 17
    else
      p36 = 15
    end
  end
  if p36 == 15 then
    v12 = u2
    v12 = v12.GetDescInfoSym
    v13 = true
    v8:RunScript(v7, v12, v13)
    v9 = _T.AbilityDescriptionInfo
    if v9 == nil then
      p36 = 17
    else
      p36 = 16
    end
  end
  if p36 == 16 then
    v6 = _T.AbilityDescriptionInfo.Params
    v9 = _T
    v10 = nil
    v9.AbilityDescriptionInfo = v10
    p36 = 17
  end
  if p36 == 17 then
    v7 = mMovie
    v10 = true
    v7 = v7:GetLocalized(v3, v10, v6)
    v8 = u1
    v8 = v8.Description
    if (not (v8 == "") and not v1) then
      p36 = 22
    else
      p36 = 19
    end
  end
  if p36 == 19 then
    v8 = u1
    v8.Description = v3
    v8 = ""
    if not v1 then
      p36 = 22
    else
      p36 = 20
    end
  end
  if p36 == 20 then
    v9 = u1
    v9 = v9.PageCallout
    if not v9 then
      p36 = 22
    else
      p36 = 21
    end
  end
  if p36 == 21 then
    v9 = mMovie
    v11 = u3
    v11 = v11.Ternary
    v12 = Engine.Name__9472b1e7
    v12 = v12()
    v13 = "<MENU_RTRIGGER1>"
    v14 = "<NEXT_MENU>"
    v11 = v11(v12, v13, v14)
    v12 = true
    v9 = v9:GetLocalized(v11, v12)
    v10 = mMovie
    v12 = u1
    v12 = v12.PageCallout
    v13 = false
    v14 = { CALLOUT = nil }
    v14.CALLOUT = v9
    v8 = v10:GetLocalized(v12, v13, v14)
    v10 = StringSplit
    v11 = "<br>"
    v10 = v10(v11, v7)
    v15 = u0
    v15 = v15.mCurrentElementIndex
    v14 = v15 or 1
    v11 = v10[v14]
    v12 = "\r\n\r\n"
    v7 = v11 .. v12 .. v8
    p36 = 22
  end
  if p36 == 22 then
    v8 = u1
    v8.LocalizedDesc = v7
    do return end
  end
end

function proto_22(v0)
  local v1, v2
  v1 = u0
  v1 = v1.UpdateColor
  v2 = v0.mClipName
  v1(v2)
  do return end
end

function proto_23()
  local v0, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13
  v0 = u0
  v0 = v0.ConvertColorNumberToProceduralRGB
  local v1 = u1
  v1 = v1.GetColor
  v2 = 3
  v3 = true
  v4 = u2
  v0 = v0(v1(v2, v3, v4))
  v1 = u3
  v2 = u1
  v2 = v2.GetColor
  v3 = 2
  v4 = true
  v5 = u2
  v2 = v2(v3, v4, v5)
  v1.Background1 = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToProceduralRGB
  v3 = u3
  v3 = v3.Background1
  v2 = v2(v3)
  v1.Background1RGB = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToHex
  v3 = u1
  v3 = v3.GetColor
  v4 = 5
  v5 = true
  v6 = u2
  v2 = v2(v3(v4, v5, v6))
  v1.Background4Hex = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToProceduralRGB
  v3 = u1
  v3 = v3.GetColor
  v4 = 1
  v5 = true
  v6 = u2
  v2 = v2(v3(v4, v5, v6))
  v1.BackerHighlightRGB = v2
  v1 = u3
  v2 = u1
  v2 = v2.GetColor
  v3 = 6
  v4 = true
  v5 = u2
  v2 = v2(v3, v4, v5)
  v1.Content = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToHex
  v3 = u3
  v3 = v3.Content
  v2 = v2(v3)
  v1.ContentHex = v2
  v1 = u3
  v2 = u1
  v2 = v2.GetColor
  v3 = 9
  v4 = true
  v5 = u2
  v2 = v2(v3, v4, v5)
  v1.FloatingContent = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToHex
  v3 = u3
  v3 = v3.FloatingContent
  v2 = v2(v3)
  v1.FloatingContentHex = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToProceduralRGB
  v3 = u3
  v3 = v3.FloatingContent
  v2 = v2(v3)
  v1.FloatingContentRGB = v2
  v1 = u3
  v2 = u1
  v2 = v2.GetColor
  v3 = 10
  v4 = true
  v5 = u2
  v2 = v2(v3, v4, v5)
  v1.FloatingContentHighlight = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToHex
  v3 = u3
  v3 = v3.FloatingContentHighlight
  v2 = v2(v3)
  v1.FloatingContentHighlightHex = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToProceduralRGB
  v3 = u3
  v3 = v3.FloatingContentHighlight
  v2 = v2(v3)
  v1.FloatingContentHighlightRGB = v2
  v1 = u3
  v2 = u1
  v2 = v2.GetColor
  v3 = 11
  v4 = true
  v5 = u2
  v2 = v2(v3, v4, v5)
  v1.Positive = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToHex
  v3 = u3
  v3 = v3.Positive
  v2 = v2(v3)
  v1.PositiveHex = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToProceduralRGB
  v3 = u3
  v3 = v3.Positive
  v2 = v2(v3)
  v1.PositiveRGB = v2
  v1 = u3
  v2 = u1
  v2 = v2.GetColor
  v3 = 12
  v4 = true
  v5 = u2
  v2 = v2(v3, v4, v5)
  v1.Negative = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToHex
  v3 = u3
  v3 = v3.Negative
  v2 = v2(v3)
  v1.NegativeHex = v2
  v1 = u3
  v2 = u0
  v2 = v2.ConvertColorNumberToProceduralRGB
  v3 = u3
  v3 = v3.Negative
  v2 = v2(v3)
  v1.NegativeRGB = v2
  v1 = mMovie
  v3 = "Popup.Bg"
  v4 = "StartColor"
  v5 = u3
  v5 = v5.Background1RGB
  v5 = v5.r
  v6 = u3
  v6 = v6.Background1RGB
  v6 = v6.g
  v7 = u3
  v7 = v7.Background1RGB
  v7 = v7.b
  v8 = 1
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v3 = "Popup.Bg"
  v4 = "EndColor"
  v5 = v0.r
  v6 = v0.g
  v7 = v0.b
  v8 = 0.95
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = u4
  if v1 == "" then
    v1 = mMovie
    v3 = "Popup.TitleBg"
    v4 = "RectEdgeColor"
    v5 = u3
    v5 = v5.BackerHighlightRGB
    v5 = v5.r
    v6 = u3
    v6 = v6.BackerHighlightRGB
    v6 = v6.g
    v7 = u3
    v7 = v7.BackerHighlightRGB
    v7 = v7.b
    v8 = 0.2
    v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  else
    v1 = mMovie
    v3 = "Popup.TitleBg"
    v4 = "RectEdgeColor"
    v5 = 0
    v6 = 0
    v7 = 0
    v8 = 0
    v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  end
  v1 = mMovie
  v3 = "Popup.TitleBg"
  v4 = "RectInnerColor"
  v5 = u3
  v5 = v5.Background1RGB
  v5 = v5.r
  v6 = u3
  v6 = v6.Background1RGB
  v6 = v6.g
  v7 = u3
  v7 = v7.Background1RGB
  v7 = v7.b
  v8 = 1
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v3 = "Popup.Header.Bg"
  v4 = "RectEdgeColor"
  v5 = u3
  v5 = v5.BackerHighlightRGB
  v5 = v5.r
  v6 = u3
  v6 = v6.BackerHighlightRGB
  v6 = v6.g
  v7 = u3
  v7 = v7.BackerHighlightRGB
  v7 = v7.b
  v8 = 0.2
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v3 = "Popup.Header.Bg"
  v4 = "RectInnerColor"
  v5 = u3
  v5 = v5.Background1RGB
  v5 = v5.r
  v6 = u3
  v6 = v6.Background1RGB
  v6 = v6.g
  v7 = u3
  v7 = v7.Background1RGB
  v7 = v7.b
  v8 = 1
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v3 = "Popup.Header.Fade"
  v4 = "RectEdgeColor"
  v5 = 0
  v6 = 0
  v7 = 0
  v8 = 0
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v3 = "Popup.Header.Fade"
  v4 = "RectInnerColor"
  v5 = u3
  v5 = v5.FloatingContentRGB
  v5 = v5.r
  v6 = u3
  v6 = v6.FloatingContentRGB
  v6 = v6.g
  v7 = u3
  v7 = v7.FloatingContentRGB
  v7 = v7.b
  v8 = 0.4
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v3 = "Popup.Header.Label"
  v4 = 11
  v5 = u3
  v5 = v5.FloatingContentHighlight
  v1:SetNumberVariable(v3, v4, v5)
  v1 = u5
  v2 = u6
  v2 = v2.BASE
  if v1 == v2 then
    v1 = u7
    v1 = mMovie
    v3 = "Popup.Description"
    v4 = 36
    v6 = "<p><font color=\""
    v7 = u3
    v7 = v7.ContentHex
    v8 = "\">"
    v9 = u8
    v10 = "</font></p>"
    v5 = v6 .. v7 .. v8 .. v9 .. v10
    v1:SetStringVariable(v3, v4, v5)
    v1 = _T.InfoPopup_Grid
    v2 = u9
    v2 = v2.GetGridItemName
    v3 = mMovie
    v5 = u7
    v6 = u7
    v6 = v6.MetaData
    v2, v3 = v2(v3, v1, v5, v6)
    v4 = u9
    v4 = v4.GetGridItemTags
    v5 = mMovie
    v7 = u7
    v8 = u7
    v8 = v8.MetaData
    v4 = v4(v5, v1, v7, v8, v3)
    u10 = v4
    v4 = 1
    v5 = ipairs
    v6 = u10
    v5, v6, v7 = v5(v6)
    for v8, v9 in v5, v6, v7 do
      v10 = v9.ExcludeFromInfoPopup
      if not v10 then
        v10 = ""
        v11 = u9
        v11 = v11.GetPriceLabelClip
        v12 = mMovie
        v13 = "Popup"
        v10, v4 = v11(v12, v13, v4)
        v11 = true
        v9.FitText = v11
        v12 = u11
        v13 = u12
        v11 = v12 - v13
        v9.MaxWidth = v11
        v11 = u9
        v11 = v11.DrawPriceLabel
        v12 = mMovie
        v11(v12, v10, v9)
        v9.ClipName = v10
      end
    end
    for v8, v9 in v5, v6, v7 do
    end
  end
  v2 = "AbilityInfo.Passive.Description"
  v1 = {v2}
  v5 = "AbilityInfo.Ability"
  v9 = 1
  v8 = tostring
  v6 = v8(v9)
  v7 = ".Description"
  v4 = v5 .. v6 .. v7
  v2 = table.insert
  v2(v1, v4)
  v5 = "AbilityInfo.Ability"
  v9 = 2
  v8 = tostring
  v6 = v8(v9)
  v7 = ".Description"
  v4 = v5 .. v6 .. v7
  v2 = table.insert
  v2(v1, v4)
  v5 = "AbilityInfo.Ability"
  v9 = 3
  v8 = tostring
  v6 = v8(v9)
  v7 = ".Description"
  v4 = v5 .. v6 .. v7
  v2 = table.insert
  v2(v1, v4)
  v5 = "AbilityInfo.Ability"
  v9 = 4
  v8 = tostring
  v6 = v8(v9)
  v7 = ".Description"
  v4 = v5 .. v6 .. v7
  v2 = table.insert
  v2(v1, v4)
  v4 = 1
  v2 = #v1
  v3 = 1
  for v4 = v4, v2, v3 do
    v5 = mMovie
    v7 = "Popup"
    v8 = v1[v4]
    v9 = 11
    v10 = u3
    v10 = v10.Content
    v5:Name__52c1b74e(v7, v8, v9, v10)
  end
  v2 = {}
  v5 = 1
  v3 = #v2
  v4 = 1
  for v5 = v5, v3, v4 do
    v6 = mMovie
    v8 = "Popup"
    v9 = v2[v5]
    v10 = 11
    v11 = u3
    v11 = v11.FloatingContent
    v6:Name__52c1b74e(v8, v9, v10, v11)
  end
  v4 = "InfoToggle"
  v5 = "Subtitle"
  v6 = "TagSeparator"
  v7 = "PreviewTag"
  v8 = "PreviewCallout"
  v9 = "AbilityInfo.Passive.Name"
  v10 = "AbilityInfo.PassiveSeparator"
  v11 = "AbilityInfo.Passive.Icon"
  v12 = "PrereqSeparator.Separator"
  v13 = "IngredientsSeparator.Separator"
  v3 = {v4, v5, v6, v7, v8, v9, v10, v11, v12, v13}
  v6 = 1
  v4 = 4
  v5 = 1
  for v6 = v6, v4, v5 do
    v10 = "AbilityInfo.Ability"
    v13 = tostring
    v11 = v13(v6)
    v12 = ".Name"
    v9 = v10 .. v11 .. v12
    v7 = table.insert
    v7(v3, v9)
    v10 = "AbilityInfo.Ability"
    v13 = tostring
    v11 = v13(v6)
    v12 = ".Icon"
    v9 = v10 .. v11 .. v12
    v7 = table.insert
    v7(v3, v9)
  end
  v6 = 1
  v4 = #v3
  v5 = 1
  for v6 = v6, v4, v5 do
    v7 = mMovie
    v9 = "Popup"
    v10 = v3[v6]
    v11 = 11
    v12 = u3
    v12 = v12.FloatingContentHighlight
    v7:Name__52c1b74e(v9, v10, v11, v12)
  end
  v5 = u13
  v4 = IsNull
  v4 = v4(v5)
  if not v4 then
    v4 = u13
    v6 = function(c2v0)
      local c2v1, c2v2
      c2v1 = u13
      c2v1 = c2v1.UpdateColor
      c2v2 = c2v0.mClipName
      c2v1(c2v2)
      do return end
    end
    v4:RunForAllElements(v6)
  end
  v4 = mMovie
  v6 = "Popup.Title"
  v7 = 36
  v9 = "<p><font color=\""
  v10 = u3
  v10 = v10.FloatingContentHighlightHex
  v11 = "\">"
  v12 = u14
  v13 = "</font></p>"
  v8 = v9 .. v10 .. v11 .. v12 .. v13
  v4:SetStringVariable(v6, v7, v8)
  v5 = _T.ItemInfoStatComparison
  v4 = IsNull
  v4 = v4(v5)
  if v4 then
  else
    v4 = u15
    if v4 then
      v4 = _T.ItemInfoStatComparison
      v4()
    else
      v4 = _T.ItemInfoStatComparison
      v5 = u16
      v6 = u17
      v4(v5, v6)
    end
  end
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.Trait.Desc"
  v7 = 11
  v8 = u3
  v8 = v8.Content
  v4:SetNumberVariable(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.Trait.Icon"
  v7 = 11
  v8 = u3
  v8 = v8.FloatingContent
  v4:SetNumberVariable(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills.Faction"
  v7 = 11
  v8 = u3
  v8 = v8.Content
  v4:SetNumberVariable(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills.Rank"
  v7 = 44
  v8 = u3
  v8 = v8.Content
  v4:SetNumberVariable(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Separator"
  v7 = 11
  v8 = u3
  v8 = v8.FloatingContentHighlight
  v4:SetNumberVariable(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Name"
  v7 = 44
  v8 = u3
  v8 = v8.FloatingContent
  v4:SetNumberVariable(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Rank"
  v7 = 44
  v8 = u3
  v8 = v8.FloatingContentHighlight
  v4:SetNumberVariable(v6, v7, v8)
  v5 = u18
  v4 = IsNull
  v4 = v4(v5)
  if not v4 then
    v4 = u18
    v4:UpdateColors()
  end
  do return end
end

function proto_24(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8
  v1 = v0.mClipName
  if v1 == nil then
    do return end
  end
  v1 = false
  v2 = u0
  v2 = v2.mSelectedElement
  if v2 ~= nil then
    v2 = u0
    v2 = v2.mSelectedElement
    v2 = v2.Id
    v3 = v0.Id
    if v2 ~= v3 then
      v1 = false
    else
      v1 = true
    end
  end
  v2 = FlashMethod
  v3 = mMovie
  v5 = v0.mClipName
  v6 = ".gotoAndStop"
  v4 = v5 .. v6
  v5 = u1
  v5 = v5.Ternary
  v7 = "Selected"
  v8 = "Unfocused"
  v2(v3, v4, v5(v1, v7, v8))
  do return end
end

function proto_25(v0)
  local v1
  v1 = u0
  v1 = v1.mElementDrawCallback
  v1(v0)
  do return end
end

function proto_26(v0)
  local v1, v2, v3, v4, v5, v6, v7
  local p27 = 0
  if p27 == 0 then
    v1 = v0.State
    u0 = v1
    v1 = v0.StatId
    u1 = v1
    v1 = u0
    v2 = u2
    v2 = v2.BASE
    if v1 ~= v2 then
      p27 = 4
    else
      p27 = 1
    end
  end
  if p27 == 1 then
    v1 = u3
    v1 = v1.AllInOne
    if v1 then
      p27 = 4
    else
      p27 = 2
    end
  end
  if p27 == 2 then
    v1 = u3
    v1 = v1.Category
    v2 = 43
    if v1 == v2 then
      p27 = 4
    else
      p27 = 3
    end
  end
  if p27 == 3 then
    v1 = u3
    v1 = v1.Category
    v2 = 46
    if v1 ~= v2 then
      p27 = 16
    else
      p27 = 4
    end
  end
  if p27 == 4 then
    v2 = u4
    v1 = IsNull
    v1 = v1(v2)
    if not v1 then
      p27 = 16
    else
      p27 = 5
    end
  end
  if p27 == 5 then
    v1 = {}
    v3 = u5
    v2 = IsNull
    v2 = v2(v3)
    if not v2 then
      v4 = u5
      v2 = table.insert
      v2(v1, v4:GetFullName())
    end
    v3 = u6
    v3 = v3.mExtraLoad
    v2 = IsNull
    v2 = v2(v3)
    v2 = pairs
    v3 = u6
    v3 = v3.mExtraLoad
    v2, v3, v4 = v2(v3)
    for v5, v6 in v2, v3, v4 do
      v7 = table.insert
      v7(v1, v6:GetFullName())
    end
    for v5, v6 in v2, v3, v4 do
    end
    v3 = u3
    v3 = v3.mExtraAbility
    v2 = IsNull
    v2 = v2(v3)
    if not v2 then
      v4 = u3
      v4 = v4.mExtraAbility
      v2 = table.insert
      v2(v1, v4:GetFullName())
    end
    v2 = #v1
    v3 = 0
    if v3 < v2 then
      v2 = UISys.ScriptResLoader_Create
      v4 = true
      v2 = v2(v1, v4)
      u4 = v2
      v2 = u7
      v3 = true
      v2(v3)
    else
      v2 = u8
      v2()
    end
    p27 = 17
  end
  if p27 == 16 then
    v1 = u8
    v1()
    p27 = 17
  end
  if p27 == 17 then
    v1 = u6
    v3 = function(c3v0)
      local c3v1
      c3v1 = u6
      c3v1 = c3v1.mElementDrawCallback
      c3v1(c3v0)
      do return end
    end
    v1:RunForAllElements(v3)
    do return end
  end
end

function proto_27()
  local v0, v1, v2, v3
  v0 = require
  v1 = "EE.Interface.Components.List"
  v0 = v0(v1)
  v1 = v0.CreateList
  v2 = mMovie
  v3 = "Popup.InfoToggle.List.Dot"
  v1 = v1(v2, v3)
  u0 = v1
  v1 = u0
  v2 = 14
  v1.mForcedHorizontalSeparation = v2
  v1 = u0
  v2 = 0
  v1.mForcedVerticalSeparation = v2
  v1 = u0
  v2 = function(c4v0)
    local c4v1, c4v2, c4v3, c4v4, c4v5, c4v6, c4v7, c4v8
    c4v1 = c4v0.mClipName
    if c4v1 == nil then
      do return end
    end
    c4v1 = false
    c4v2 = u0
    c4v2 = c4v2.mSelectedElement
    if c4v2 ~= nil then
      c4v2 = u0
      c4v2 = c4v2.mSelectedElement
      c4v2 = c4v2.Id
      c4v3 = c4v0.Id
      if c4v2 ~= c4v3 then
        c4v1 = false
      else
        c4v1 = true
      end
    end
    c4v2 = FlashMethod
    c4v3 = mMovie
    c4v5 = c4v0.mClipName
    c4v6 = ".gotoAndStop"
    c4v4 = c4v5 .. c4v6
    c4v5 = u1
    c4v5 = c4v5.Ternary
    c4v7 = "Selected"
    c4v8 = "Unfocused"
    c4v2(c4v3, c4v4, c4v5(c4v1, c4v7, c4v8))
    do return end
  end
  v1.mElementDrawCallback = v2
  v1 = u0
  v2 = function(c6v0)
    local c6v1, c6v2, c6v3, c6v4, c6v5, c6v6, c6v7
    local p27 = 0
    if p27 == 0 then
      c6v1 = c6v0.State
      u0 = c6v1
      c6v1 = c6v0.StatId
      u9 = c6v1
      c6v1 = u0
      c6v2 = u0
      c6v2 = c6v2.BASE
      if c6v1 ~= c6v2 then
        p27 = 4
      else
        p27 = 1
      end
    end
    if p27 == 1 then
      c6v1 = u9
      c6v1 = c6v1.AllInOne
      if c6v1 then
        p27 = 4
      else
        p27 = 2
      end
    end
    if p27 == 2 then
      c6v1 = u9
      c6v1 = c6v1.Category
      c6v2 = 43
      if c6v1 == c6v2 then
        p27 = 4
      else
        p27 = 3
      end
    end
    if p27 == 3 then
      c6v1 = u9
      c6v1 = c6v1.Category
      c6v2 = 46
      if c6v1 ~= c6v2 then
        p27 = 16
      else
        p27 = 4
      end
    end
    if p27 == 4 then
      c6v2 = u0
      c6v1 = IsNull
      c6v1 = c6v1(c6v2)
      if not c6v1 then
        p27 = 16
      else
        p27 = 5
      end
    end
    if p27 == 5 then
      c6v1 = {}
      c6v3 = u9
      c6v2 = IsNull
      c6v2 = c6v2(c6v3)
      if not c6v2 then
        c6v4 = u9
        c6v2 = table.insert
        c6v2(c6v1, c6v4:GetFullName())
      end
      c6v3 = u0
      c6v3 = c6v3.mExtraLoad
      c6v2 = IsNull
      c6v2 = c6v2(c6v3)
      c6v2 = pairs
      c6v3 = u0
      c6v3 = c6v3.mExtraLoad
      c6v2, c6v3, c6v4 = c6v2(c6v3)
      for c6v5, c6v6 in c6v2, c6v3, c6v4 do
        c6v7 = table.insert
        c6v7(c6v1, c6v6:GetFullName())
      end
      for c6v5, c6v6 in c6v2, c6v3, c6v4 do
      end
      c6v3 = u9
      c6v3 = c6v3.mExtraAbility
      c6v2 = IsNull
      c6v2 = c6v2(c6v3)
      if not c6v2 then
        c6v4 = u9
        c6v4 = c6v4.mExtraAbility
        c6v2 = table.insert
        c6v2(c6v1, c6v4:GetFullName())
      end
      c6v2 = #c6v1
      c6v3 = 0
      if c6v3 < c6v2 then
        c6v2 = UISys.ScriptResLoader_Create
        c6v4 = true
        c6v2 = c6v2(c6v1, c6v4)
        u0 = c6v2
        c6v2 = u9
        c6v3 = true
        c6v2(c6v3)
      else
        c6v2 = u9
        c6v2()
      end
      p27 = 17
    end
    if p27 == 16 then
      c6v1 = u9
      c6v1()
      p27 = 17
    end
    if p27 == 17 then
      c6v1 = u0
      c6v3 = function(c5v0)
        local c5v1
        c5v1 = u0
        c5v1 = c5v1.mElementDrawCallback
        c5v1(c5v0)
        do return end
      end
      c6v1:RunForAllElements(c6v3)
      do return end
    end
  end
  v1.mOnSelectedCallback = v2
  do return end
end

function proto_28()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12
  v0 = u0
  v0 = v0.Ternary
  v1 = Engine.Name__9472b1e7
  v1 = v1()
  if not v1 then
    v1 = Engine.IsPS
    v1 = v1()
    if not v1 then
      v1 = Engine.IsSwitch2
      v1 = v1()
    end
  end
  v2 = "<MENU_RTRIGGER1>"
  v3 = "<NEXT_MENU>"
  v0 = v0(v1, v2, v3)
  v1 = mMovie
  v3 = u0
  v3 = v3.Ternary
  v4 = Engine.IsPlayingWithController
  v4 = v4()
  v5 = "<MENU_RTHUMB>"
  v6 = "<MENU_RIGHT_CLICK>"
  v3 = v3(v4, v5, v6)
  v4 = true
  v1 = v1:GetLocalized(v3, v4)
  v2 = "/Lotus/Language/OstronCrafting/Crafting_Preview_NoIcon"
  v3 = u1
  if v1 then
    v3 = u1
    v3 = v3.PreviewTagOverride
    if v3 ~= nil then
      v3 = u1
      v2 = v3.PreviewTagOverride
    else
      v3 = u1
      v3 = v3.mUnequipItem
      if v3 ~= nil then
        v2 = "/Lotus/Language/Menu/Loadout_Remove"
      end
    end
    v3 = u1
    v3 = v3.PreviewCalloutFunction
    if v3 ~= nil then
      v3 = mMovie
      v5 = u1
      v5 = v5.PreviewCalloutFunction
      v5 = v5()
      v6 = true
      v1 = v3:GetLocalized(v5, v6)
    end
    v3 = u1
    v3 = v3.CalloutOverride
    if v3 ~= nil then
      v3 = u1
      v0 = v3.CalloutOverride
    end
    v3 = u1
    v3 = v3.HidePreviewCallout
    if v3 ~= nil then
      v1 = ""
    end
  end
  v3 = mMovie
  v5 = "Popup.PreviewCallout"
  v6 = 36
  v3:SetStringVariable(v5, v6, v1)
  v3 = mMovie
  v5 = "Popup.PreviewCallout"
  v6 = 40
  v3 = v3:GetNumberVariable(v5, v6)
  v4 = mMovie
  v6 = "Popup.PreviewTag"
  v7 = 36
  v8 = string.upper
  v9 = mMovie
  v12 = false
  v4:SetStringVariable(v6, v7, v8(v9:GetLocalized(v2, v12)))
  v5 = mMovie
  v7 = "Popup.PreviewTag"
  v8 = 40
  v5 = v5:GetNumberVariable(v7, v8)
  v4 = v5 + 5
  v5 = mMovie
  v7 = "Popup.PreviewTag"
  v8 = 0
  v10 = u2
  v9 = v10 - v4
  v5:SetNumberVariable(v7, v8, v9)
  v5 = mMovie
  v7 = "Popup.PreviewCallout"
  v8 = 0
  v10 = u2
  v12 = v4 + v3
  v11 = v12 + 5
  v9 = v10 - v11
  v5:SetNumberVariable(v7, v8, v9)
  v5 = mMovie
  v7 = "Popup.InfoToggle.Callout.text"
  v5:SetLocalized(v7, v0)
  v5 = u1
  if v5 then
    v6 = u1
    v6 = v6.Resource
    v5 = IsNull
    v5 = v5(v6)
    if not v5 then
      v5 = u1
      v5 = v5.IsAbility
      if v5 then
        v5 = u3
        v6 = u1
        v6 = v6.Resource
        v5(v6)
      end
    end
  end
  do return end
end

function proto_29()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10
  v0 = u0
  v0 = v0:GetHowManyElements()
  v1 = mMovie
  v3 = "Popup.InfoToggle.Callout"
  v4 = 40
  v1 = v1:GetNumberVariable(v3, v4)
  v2 = mMovie
  v4 = "Popup.InfoToggle.List"
  v5 = 0
  v10 = u0
  v10 = v10.mForcedHorizontalSeparation
  v9 = v0 * v10
  v8 = v9 + v1
  v7 = v8 + 5
  v6 = -v7
  v2:SetNumberVariable(v4, v5, v6)
  v3 = 1
  if v0 <= v3 then
    v2 = false
  else
    v2 = true
  end
  v3 = false
  v4 = u1
  if v4 ~= nil then
    v4 = u1
    v4 = v4.CalloutOverride
    if v4 == nil then
      v3 = false
    else
      v3 = true
    end
  end
  v4 = mMovie
  v6 = "Popup.InfoToggle"
  v7 = 13
  v8 = v2 or v3
  v4:Name__d9713943(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.InfoToggle.List"
  v7 = 13
  v4:Name__d9713943(v6, v7, v2)
  do return end
end

function proto_30(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23
  local p112 = 0
  if p112 == 0 then
    v1 = mMovie
    v4 = v0.mClipName
    v5 = ".Icon"
    v3 = v4 .. v5
    v4 = v0.Icon
    v1:OverrideTexture(v3, v4)
    v1 = mMovie
    v4 = v0.mClipName
    v5 = ".Icon"
    v3 = v4 .. v5
    v4 = v0.Material
    v1:OverrideMaterial(v3, v4)
    v1 = 52
    v2 = v0.mIconDimOffset
    if v2 == nil then
      p112 = 2
    else
      p112 = 1
    end
  end
  if p112 == 1 then
    v2 = v0.mIconDimOffset
    v1 = v1 + v2
    p112 = 2
  end
  if p112 == 2 then
    v2 = 28
    v3 = v0.mIconXOffset
    if v3 == nil then
      p112 = 4
    else
      p112 = 3
    end
  end
  if p112 == 3 then
    v3 = v0.mIconXOffset
    v2 = v2 + v3
    p112 = 4
  end
  if p112 == 4 then
    v3 = v2
    v4 = v0.mIconYOffset
    if v4 == nil then
      p112 = 6
    else
      p112 = 5
    end
  end
  if p112 == 5 then
    v4 = v0.mIconYOffset
    v3 = v3 + v4
    p112 = 6
  end
  if p112 == 6 then
    v4 = mMovie
    v6 = v0.mClipName
    v7 = "Icon"
    v8 = 0
    v4:Name__52c1b74e(v6, v7, v8, v2)
    v4 = mMovie
    v6 = v0.mClipName
    v7 = "Icon"
    v8 = 1
    v4:Name__52c1b74e(v6, v7, v8, v3)
    v4 = mMovie
    v6 = v0.mClipName
    v7 = "IconMask"
    v8 = 0
    v4:Name__52c1b74e(v6, v7, v8, v2)
    v4 = mMovie
    v6 = v0.mClipName
    v7 = "IconMask"
    v8 = 1
    v4:Name__52c1b74e(v6, v7, v8, v3)
    v4 = v1
    v5 = v0.Themed
    if v5 then
      p112 = 8
    else
      p112 = 7
    end
  end
  if p112 == 7 then
    v4 = v4 * 1.6
    p112 = 8
  end
  if p112 == 8 then
    v5 = mMovie
    v7 = v0.mClipName
    v8 = "Icon"
    v9 = 14
    v5:Name__52c1b74e(v7, v8, v9, v4)
    v5 = mMovie
    v7 = v0.mClipName
    v8 = "Icon"
    v9 = 15
    v5:Name__52c1b74e(v7, v8, v9, v1)
    v5 = mMovie
    v7 = v0.mClipName
    v8 = "Icon"
    v9 = 11
    v10 = u0
    v10 = v10.Ternary
    v12 = v0.TintIconColor
    if v12 ~= nil then
      p112 = 10
    else
      p112 = 9
    end
  end
  if p112 == 9 then
    v11 = false
    p112 = 11
  end
  if p112 == 10 then
    v11 = true
    p112 = 11
  end
  if p112 == 11 then
    v12 = v0.TintIconColor
    v13 = _G
    v13 = v13.UIColor_White
    v5:Name__52c1b74e(v7, v8, v9, v10(v11, v12, v13))
    v5 = v0.mIconScale
    if v5 == nil then
      p112 = 13
    else
      p112 = 12
    end
  end
  if p112 == 12 then
    v5 = mMovie
    v7 = v0.mClipName
    v8 = "Icon"
    v9 = 5
    v10 = v0.mIconScale
    v5:Name__52c1b74e(v7, v8, v9, v10)
    v5 = mMovie
    v7 = v0.mClipName
    v8 = "Icon"
    v9 = 6
    v10 = v0.mIconScale
    v5:Name__52c1b74e(v7, v8, v9, v10)
    p112 = 13
  end
  if p112 == 13 then
    v5 = false
    v6 = u1
    v6 = v6.MetaData
    if v6 == nil then
      p112 = 17
    else
      p112 = 14
    end
  end
  if p112 == 14 then
    v5 = u1
    v5 = v5.MetaData
    v5 = v5.CheckResearch
    if not v5 then
      p112 = 17
    else
      p112 = 15
    end
  end
  if p112 == 15 then
    v5 = false
    v6 = u2
    v7 = u3
    v7 = v7.CRAFTING
    if v6 == v7 then
      p112 = 17
    else
      p112 = 16
    end
  end
  if p112 == 16 then
    v6 = u1
    v6 = v6.mTechItem
    v5 = not v6
    p112 = 17
  end
  if p112 == 17 then
    v6 = true
    v7 = u1
    v7 = v7.mPrereqElement
    if v7 == nil then
      p112 = 21
    else
      p112 = 18
    end
  end
  if p112 == 18 then
    v7 = u1
    v7 = v7.mPrereqElement
    v7 = v7.TimeRemaining
    v8 = 0
    if v7 < v8 then
      p112 = 20
    else
      p112 = 19
    end
  end
  if p112 == 19 then
    v6 = false
    p112 = 21
  end
  if p112 == 20 then
    v6 = true
    p112 = 21
  end
  if p112 == 21 then
    v7 = not v6
    if not v5 then
      p112 = 23
    else
      p112 = 22
    end
  end
  if p112 == 22 then
    v0.mIncomplete = v7
    p112 = 23
  end
  if p112 == 23 then
    if v7 then
      p112 = 27
    else
      p112 = 24
    end
  end
  if p112 == 24 then
    v8 = v0.mIncomplete
    if not v8 then
      p112 = 26
    else
      p112 = 25
    end
  end
  if p112 == 25 then
    v9 = v0.mHasResources
    v8 = not v9
    p112 = 26
  end
  if p112 == 26 then
    v7 = v8
    p112 = 27
  end
  if p112 == 27 then
    v8 = u0
    v8 = v8.Ternary
    v10 = u4
    v10 = v10.ContentHex
    v11 = u4
    v11 = v11.FloatingContentHex
    v8 = v8(v7, v10, v11)
    v9 = u0
    v9 = v9.Ternary
    v11 = u4
    v11 = v11.ContentHex
    v12 = u4
    v12 = v12.FloatingContentHighlightHex
    v9 = v9(v7, v11, v12)
    v11 = "<p><font color=\""
    v13 = "\">"
    v16 = TitleCase
    v17 = v0.Name
    v14 = v16(v17)
    v15 = "</font>"
    v10 = v11 .. v8 .. v13 .. v14 .. v15
    v11 = v0.HideCount
    if v11 == true then
      p112 = 34
    else
      p112 = 28
    end
  end
  if p112 == 28 then
    v12 = "<font color=\""
    v14 = "\"><br>"
    v10 = v10 .. v12 .. v9 .. v14
    v11 = v0.SubText
    if v11 == nil then
      p112 = 30
    else
      p112 = 29
    end
  end
  if p112 == 29 then
    v12 = v0.SubText
    v10 = v10 .. v12
    p112 = 33
  end
  if p112 == 30 then
    if not v5 then
      p112 = 32
    else
      p112 = 31
    end
  end
  if p112 == 31 then
    v12 = u0
    v12 = v12.FormatNumber
    v13 = v0.Req
    v12 = v12(v13)
    v10 = v10 .. v12
    p112 = 33
  end
  if p112 == 32 then
    v15 = u0
    v15 = v15.FormatNumber
    v16 = v0.Count
    v12 = v15(v16)
    v13 = "/"
    v14 = u0
    v14 = v14.FormatNumber
    v15 = v0.Req
    v14 = v14(v15)
    v10 = v10 .. v12 .. v13 .. v14
    p112 = 33
  end
  if p112 == 33 then
    v12 = "</font>"
    v10 = v10 .. v12
    p112 = 34
  end
  if p112 == 34 then
    v12 = "</p>"
    v10 = v10 .. v12
    v11 = mMovie
    v13 = v0.mClipName
    v14 = "Name"
    v15 = 46
    v16 = "center"
    v11:Name__f4a9016a(v13, v14, v15, v16)
    v11 = mMovie
    v13 = v0.mClipName
    v14 = "Name"
    v15 = 36
    v11:Name__f4a9016a(v13, v14, v15, v10)
    v12 = v0.Name
    v11 = #v12
    if v11 ~= 0 then
      p112 = 38
    else
      p112 = 35
    end
  end
  if p112 == 35 then
    v11 = v0.SubText
    if v11 == nil then
      p112 = 38
    else
      p112 = 36
    end
  end
  if p112 == 36 then
    v12 = v0.SubText
    v11 = #v12
    v12 = 93
    if v11 <= v12 then
      p112 = 38
    else
      p112 = 37
    end
  end
  if p112 == 37 then
    v11 = mMovie
    v13 = v0.mClipName
    v14 = "Name"
    v15 = 1
    v16 = -20
    v11:Name__52c1b74e(v13, v14, v15, v16)
    v11 = u5
    v12 = 5
    v11.mInitialY = v12
    p112 = 38
  end
  if p112 == 38 then
    v11 = mMovie
    v13 = v0.mClipName
    v14 = "Name"
    v15 = 41
    v11 = v11:Name__46690123(v13, v14, v15)
    v0.mHeight = v11
    v11 = mMovie
    v13 = v0.mClipName
    v14 = 12
    v15 = u0
    v15 = v15.Ternary
    v17 = 40
    v18 = 100
    v11:SetNumberVariable(v13, v14, v15(v7, v17, v18))
    v11 = mMovie
    v13 = v0.mClipName
    v14 = "Check"
    v15 = 13
    v17 = v0.mIncomplete
    if v17 == nil then
      p112 = 40
    else
      p112 = 39
    end
  end
  if p112 == 39 then
    v17 = v0.mIncomplete
    v16 = not v17
    if not v16 then
      p112 = 41
    else
      p112 = 40
    end
  end
  if p112 == 40 then
    v17 = v0.HideCheck
    v16 = not v17
    p112 = 41
  end
  if p112 == 41 then
    v11:Makeposshield(v13, v14, v15, v16)
    v11 = mMovie
    v13 = v0.mClipName
    v14 = "Check"
    v15 = 11
    v16 = u4
    v16 = v16.FloatingContentHighlight
    v11:Name__52c1b74e(v13, v14, v15, v16)
    v11 = 58
    v12 = v0.mBgDimOffset
    if v12 == nil then
      p112 = 43
    else
      p112 = 42
    end
  end
  if p112 == 42 then
    v12 = v0.mBgDimOffset
    v11 = v11 + v12
    p112 = 43
  end
  if p112 == 43 then
    v12 = 28
    v13 = v0.mIconXOffset
    if v13 == nil then
      p112 = 45
    else
      p112 = 44
    end
  end
  if p112 == 44 then
    v13 = v0.mIconXOffset
    v12 = v12 + v13
    p112 = 45
  end
  if p112 == 45 then
    v13 = 28
    v14 = v0.mIconYOffset
    if v14 == nil then
      p112 = 47
    else
      p112 = 46
    end
  end
  if p112 == 46 then
    v14 = v0.mIconYOffset
    v13 = v13 + v14
    p112 = 47
  end
  if p112 == 47 then
    v14 = mMovie
    v16 = v0.mClipName
    v17 = "Bg"
    v18 = 0
    v14:Name__52c1b74e(v16, v17, v18, v12)
    v14 = mMovie
    v16 = v0.mClipName
    v17 = "Bg"
    v18 = 1
    v14:Name__52c1b74e(v16, v17, v18, v13)
    v14 = mMovie
    v16 = v0.mClipName
    v17 = "Bg"
    v18 = 14
    v14:Name__52c1b74e(v16, v17, v18, v11)
    v14 = mMovie
    v16 = v0.mClipName
    v17 = "Bg"
    v18 = 15
    v14:Name__52c1b74e(v16, v17, v18, v11)
    v14 = mMovie
    v16 = v0.mClipName
    v17 = "IconMask"
    v18 = 14
    v19 = v11 - 6
    v14:Name__52c1b74e(v16, v17, v18, v19)
    v14 = mMovie
    v16 = v0.mClipName
    v17 = "IconMask"
    v18 = 15
    v19 = v11 - 6
    v14:Name__52c1b74e(v16, v17, v18, v19)
    v14 = v0.mBgOverride
    if v14 == nil then
      p112 = 49
    else
      p112 = 48
    end
  end
  if p112 == 48 then
    v14 = mMovie
    v17 = v0.mClipName
    v18 = ".Bg"
    v16 = v17 .. v18
    v17 = v0.mBgOverride
    v18 = _G
    v18 = v18.UIMaterial_Plain
    v14:Name__9c27ee88(v16, v17, v18)
    v14 = mMovie
    v16 = v0.mClipName
    v17 = "Bg"
    v18 = 11
    v19 = u4
    v19 = v19.FloatingContentHighlight
    v14:Name__52c1b74e(v16, v17, v18, v19)
    p112 = 50
  end
  if p112 == 49 then
    v14 = u4
    v14 = v14.Background1RGB
    v15 = u4
    v15 = v15.BackerHighlightRGB
    v16 = mMovie
    v19 = v0.mClipName
    v20 = ".Bg"
    v18 = v19 .. v20
    v19 = _G
    v19 = v19.UIMaterial_RectangleNoDepth
    v16:OverrideMaterial(v18, v19)
    v16 = mMovie
    v18 = v0.mClipName
    v19 = "Bg"
    v20 = 11
    v21 = _G
    v21 = v21.UIColor_White
    v16:Name__52c1b74e(v18, v19, v20, v21)
    v16 = mMovie
    v19 = v0.mClipName
    v20 = ".Bg"
    v18 = v19 .. v20
    v19 = "RectEdgeColor"
    v20 = v15.r
    v21 = v15.g
    v22 = v15.b
    v23 = 0.05
    v16:Name__e243d995(v18, v19, v20, v21, v22, v23)
    v16 = mMovie
    v19 = v0.mClipName
    v20 = ".Bg"
    v18 = v19 .. v20
    v19 = "RectInnerColor"
    v20 = v14.r
    v21 = v14.g
    v22 = v14.b
    v23 = 0.9
    v16:Name__e243d995(v18, v19, v20, v21, v22, v23)
    p112 = 50
  end
  if p112 == 50 then
    v14 = v0.mBGScale
    if v14 == nil then
      p112 = 52
    else
      p112 = 51
    end
  end
  if p112 == 51 then
    v14 = mMovie
    v16 = v0.mClipName
    v17 = "Bg"
    v18 = 5
    v19 = v0.mBGScale
    v14:Name__52c1b74e(v16, v17, v18, v19)
    v14 = mMovie
    v16 = v0.mClipName
    v17 = "Bg"
    v18 = 6
    v19 = v0.mBGScale
    v14:Name__52c1b74e(v16, v17, v18, v19)
    p112 = 52
  end
  if p112 == 52 then
    v14 = v0.mIndex
    if v14 ~= nil then
      p112 = 54
    else
      p112 = 53
    end
  end
  if p112 == 53 then
    v15 = u5
    v17 = v0.Id
    v14 = v15:GetElementIndexById(v17)
    p112 = 54
  end
  if p112 == 54 then
    v15 = u5
    v15 = v15.mInitialY
    v16 = IsNull
    v16 = v16(v14)
    if v16 then
      p112 = 59
    else
      p112 = 55
    end
  end
  if p112 == 55 then
    v16 = 1
    if v14 <= v16 then
      p112 = 59
    else
      p112 = 56
    end
  end
  if p112 == 56 then
    v18 = 1
    v16 = v14 - 1
    v17 = 1
    if (v17 > 0 and v18 > v16) or (v17 < 0 and v18 < v16) then
      p112 = 58
    else
      p112 = 57
    end
  end
  if p112 == 57 then
    v20 = u5
    v20 = v20.mForcedVerticalSeparation
    v23 = u5
    v23 = v23.mElements
    v22 = v23[v18]
    v22 = v22.mHeight
    v21 = v22 or 0
    v19 = math.max
    v19 = v19(v20, v21)
    v15 = v15 + v19
    p112 = 58
  end
  if p112 == 58 then
    v18 = 5
    v19 = v14 - 1
    v17 = v18 * v19
    v16 = v15 + v17
    v20 = v0.mHeight
    v21 = u5
    v21 = v21.mForcedVerticalSeparation
    v19 = v20 - v21
    v18 = v19 / 2
    v19 = 0
    v17 = math.max
    v17 = v17(v18, v19)
    v15 = v16 + v17
    p112 = 59
  end
  if p112 == 59 then
    v16 = mMovie
    v18 = v0.mClipName
    v19 = 1
    v20 = u0
    v20 = v20.Round
    v16:SetNumberVariable(v18, v19, v20(v15))
    do return end
  end
end

function proto_31(v0, v1)
  local v2
  v2 = 0
  do return v2 end
end

function proto_32()
  local v0, v1, v2, v3
  v0 = require
  v1 = "EE.Interface.Components.List"
  v0 = v0(v1)
  v1 = v0.CreateList
  v2 = mMovie
  v3 = "Popup.Ingredients.Ingredient"
  v1 = v1(v2, v3)
  u0 = v1
  v1 = u0
  v2 = 0
  v1.mForcedHorizontalSeparation = v2
  v1 = u0
  v2 = 62
  v1.mForcedVerticalSeparation = v2
  v1 = u0
  v2 = function(c7v0)
    local c7v1, c7v2, c7v3, c7v4, c7v5, c7v6, c7v7, c7v8, c7v9, c7v10, c7v11, c7v12, c7v13, c7v14, c7v15, c7v16, c7v17, c7v18, c7v19, c7v20, c7v21, c7v22, c7v23
    local p112 = 0
    if p112 == 0 then
      c7v1 = mMovie
      c7v4 = c7v0.mClipName
      c7v5 = ".Icon"
      c7v3 = c7v4 .. c7v5
      c7v4 = c7v0.Icon
      c7v1:OverrideTexture(c7v3, c7v4)
      c7v1 = mMovie
      c7v4 = c7v0.mClipName
      c7v5 = ".Icon"
      c7v3 = c7v4 .. c7v5
      c7v4 = c7v0.Material
      c7v1:OverrideMaterial(c7v3, c7v4)
      c7v1 = 52
      c7v2 = c7v0.mIconDimOffset
      if c7v2 == nil then
        p112 = 2
      else
        p112 = 1
      end
    end
    if p112 == 1 then
      c7v2 = c7v0.mIconDimOffset
      c7v1 = c7v1 + c7v2
      p112 = 2
    end
    if p112 == 2 then
      c7v2 = 28
      c7v3 = c7v0.mIconXOffset
      if c7v3 == nil then
        p112 = 4
      else
        p112 = 3
      end
    end
    if p112 == 3 then
      c7v3 = c7v0.mIconXOffset
      c7v2 = c7v2 + c7v3
      p112 = 4
    end
    if p112 == 4 then
      c7v3 = c7v2
      c7v4 = c7v0.mIconYOffset
      if c7v4 == nil then
        p112 = 6
      else
        p112 = 5
      end
    end
    if p112 == 5 then
      c7v4 = c7v0.mIconYOffset
      c7v3 = c7v3 + c7v4
      p112 = 6
    end
    if p112 == 6 then
      c7v4 = mMovie
      c7v6 = c7v0.mClipName
      c7v7 = "Icon"
      c7v8 = 0
      c7v4:Name__52c1b74e(c7v6, c7v7, c7v8, c7v2)
      c7v4 = mMovie
      c7v6 = c7v0.mClipName
      c7v7 = "Icon"
      c7v8 = 1
      c7v4:Name__52c1b74e(c7v6, c7v7, c7v8, c7v3)
      c7v4 = mMovie
      c7v6 = c7v0.mClipName
      c7v7 = "IconMask"
      c7v8 = 0
      c7v4:Name__52c1b74e(c7v6, c7v7, c7v8, c7v2)
      c7v4 = mMovie
      c7v6 = c7v0.mClipName
      c7v7 = "IconMask"
      c7v8 = 1
      c7v4:Name__52c1b74e(c7v6, c7v7, c7v8, c7v3)
      c7v4 = c7v1
      c7v5 = c7v0.Themed
      if c7v5 then
        p112 = 8
      else
        p112 = 7
      end
    end
    if p112 == 7 then
      c7v4 = c7v4 * 1.6
      p112 = 8
    end
    if p112 == 8 then
      c7v5 = mMovie
      c7v7 = c7v0.mClipName
      c7v8 = "Icon"
      c7v9 = 14
      c7v5:Name__52c1b74e(c7v7, c7v8, c7v9, c7v4)
      c7v5 = mMovie
      c7v7 = c7v0.mClipName
      c7v8 = "Icon"
      c7v9 = 15
      c7v5:Name__52c1b74e(c7v7, c7v8, c7v9, c7v1)
      c7v5 = mMovie
      c7v7 = c7v0.mClipName
      c7v8 = "Icon"
      c7v9 = 11
      c7v10 = u0
      c7v10 = c7v10.Ternary
      c7v12 = c7v0.TintIconColor
      if c7v12 ~= nil then
        p112 = 10
      else
        p112 = 9
      end
    end
    if p112 == 9 then
      c7v11 = false
      p112 = 11
    end
    if p112 == 10 then
      c7v11 = true
      p112 = 11
    end
    if p112 == 11 then
      c7v12 = c7v0.TintIconColor
      c7v13 = _G
      c7v13 = c7v13.UIColor_White
      c7v5:Name__52c1b74e(c7v7, c7v8, c7v9, c7v10(c7v11, c7v12, c7v13))
      c7v5 = c7v0.mIconScale
      if c7v5 == nil then
        p112 = 13
      else
        p112 = 12
      end
    end
    if p112 == 12 then
      c7v5 = mMovie
      c7v7 = c7v0.mClipName
      c7v8 = "Icon"
      c7v9 = 5
      c7v10 = c7v0.mIconScale
      c7v5:Name__52c1b74e(c7v7, c7v8, c7v9, c7v10)
      c7v5 = mMovie
      c7v7 = c7v0.mClipName
      c7v8 = "Icon"
      c7v9 = 6
      c7v10 = c7v0.mIconScale
      c7v5:Name__52c1b74e(c7v7, c7v8, c7v9, c7v10)
      p112 = 13
    end
    if p112 == 13 then
      c7v5 = false
      c7v6 = u0
      c7v6 = c7v6.MetaData
      if c7v6 == nil then
        p112 = 17
      else
        p112 = 14
      end
    end
    if p112 == 14 then
      c7v5 = u0
      c7v5 = c7v5.MetaData
      c7v5 = c7v5.CheckResearch
      if not c7v5 then
        p112 = 17
      else
        p112 = 15
      end
    end
    if p112 == 15 then
      c7v5 = false
      c7v6 = u0
      c7v7 = u0
      c7v7 = c7v7.CRAFTING
      if c7v6 == c7v7 then
        p112 = 17
      else
        p112 = 16
      end
    end
    if p112 == 16 then
      c7v6 = u0
      c7v6 = c7v6.mTechItem
      c7v5 = not c7v6
      p112 = 17
    end
    if p112 == 17 then
      c7v6 = true
      c7v7 = u0
      c7v7 = c7v7.mPrereqElement
      if c7v7 == nil then
        p112 = 21
      else
        p112 = 18
      end
    end
    if p112 == 18 then
      c7v7 = u0
      c7v7 = c7v7.mPrereqElement
      c7v7 = c7v7.TimeRemaining
      c7v8 = 0
      if c7v7 < c7v8 then
        p112 = 20
      else
        p112 = 19
      end
    end
    if p112 == 19 then
      c7v6 = false
      p112 = 21
    end
    if p112 == 20 then
      c7v6 = true
      p112 = 21
    end
    if p112 == 21 then
      c7v7 = not c7v6
      if not c7v5 then
        p112 = 23
      else
        p112 = 22
      end
    end
    if p112 == 22 then
      c7v0.mIncomplete = c7v7
      p112 = 23
    end
    if p112 == 23 then
      if c7v7 then
        p112 = 27
      else
        p112 = 24
      end
    end
    if p112 == 24 then
      c7v8 = c7v0.mIncomplete
      if not c7v8 then
        p112 = 26
      else
        p112 = 25
      end
    end
    if p112 == 25 then
      c7v9 = c7v0.mHasResources
      c7v8 = not c7v9
      p112 = 26
    end
    if p112 == 26 then
      c7v7 = c7v8
      p112 = 27
    end
    if p112 == 27 then
      c7v8 = u0
      c7v8 = c7v8.Ternary
      c7v10 = u0
      c7v10 = c7v10.ContentHex
      c7v11 = u0
      c7v11 = c7v11.FloatingContentHex
      c7v8 = c7v8(c7v7, c7v10, c7v11)
      c7v9 = u0
      c7v9 = c7v9.Ternary
      c7v11 = u0
      c7v11 = c7v11.ContentHex
      c7v12 = u0
      c7v12 = c7v12.FloatingContentHighlightHex
      c7v9 = c7v9(c7v7, c7v11, c7v12)
      c7v11 = "<p><font color=\""
      c7v13 = "\">"
      c7v16 = TitleCase
      c7v17 = c7v0.Name
      c7v14 = c7v16(c7v17)
      c7v15 = "</font>"
      c7v10 = c7v11 .. c7v8 .. c7v13 .. c7v14 .. c7v15
      c7v11 = c7v0.HideCount
      if c7v11 == true then
        p112 = 34
      else
        p112 = 28
      end
    end
    if p112 == 28 then
      c7v12 = "<font color=\""
      c7v14 = "\"><br>"
      c7v10 = c7v10 .. c7v12 .. c7v9 .. c7v14
      c7v11 = c7v0.SubText
      if c7v11 == nil then
        p112 = 30
      else
        p112 = 29
      end
    end
    if p112 == 29 then
      c7v12 = c7v0.SubText
      c7v10 = c7v10 .. c7v12
      p112 = 33
    end
    if p112 == 30 then
      if not c7v5 then
        p112 = 32
      else
        p112 = 31
      end
    end
    if p112 == 31 then
      c7v12 = u0
      c7v12 = c7v12.FormatNumber
      c7v13 = c7v0.Req
      c7v12 = c7v12(c7v13)
      c7v10 = c7v10 .. c7v12
      p112 = 33
    end
    if p112 == 32 then
      c7v15 = u0
      c7v15 = c7v15.FormatNumber
      c7v16 = c7v0.Count
      c7v12 = c7v15(c7v16)
      c7v13 = "/"
      c7v14 = u0
      c7v14 = c7v14.FormatNumber
      c7v15 = c7v0.Req
      c7v14 = c7v14(c7v15)
      c7v10 = c7v10 .. c7v12 .. c7v13 .. c7v14
      p112 = 33
    end
    if p112 == 33 then
      c7v12 = "</font>"
      c7v10 = c7v10 .. c7v12
      p112 = 34
    end
    if p112 == 34 then
      c7v12 = "</p>"
      c7v10 = c7v10 .. c7v12
      c7v11 = mMovie
      c7v13 = c7v0.mClipName
      c7v14 = "Name"
      c7v15 = 46
      c7v16 = "center"
      c7v11:Name__f4a9016a(c7v13, c7v14, c7v15, c7v16)
      c7v11 = mMovie
      c7v13 = c7v0.mClipName
      c7v14 = "Name"
      c7v15 = 36
      c7v11:Name__f4a9016a(c7v13, c7v14, c7v15, c7v10)
      c7v12 = c7v0.Name
      c7v11 = #c7v12
      if c7v11 ~= 0 then
        p112 = 38
      else
        p112 = 35
      end
    end
    if p112 == 35 then
      c7v11 = c7v0.SubText
      if c7v11 == nil then
        p112 = 38
      else
        p112 = 36
      end
    end
    if p112 == 36 then
      c7v12 = c7v0.SubText
      c7v11 = #c7v12
      c7v12 = 93
      if c7v11 <= c7v12 then
        p112 = 38
      else
        p112 = 37
      end
    end
    if p112 == 37 then
      c7v11 = mMovie
      c7v13 = c7v0.mClipName
      c7v14 = "Name"
      c7v15 = 1
      c7v16 = -20
      c7v11:Name__52c1b74e(c7v13, c7v14, c7v15, c7v16)
      c7v11 = u0
      c7v12 = 5
      c7v11.mInitialY = c7v12
      p112 = 38
    end
    if p112 == 38 then
      c7v11 = mMovie
      c7v13 = c7v0.mClipName
      c7v14 = "Name"
      c7v15 = 41
      c7v11 = c7v11:Name__46690123(c7v13, c7v14, c7v15)
      c7v0.mHeight = c7v11
      c7v11 = mMovie
      c7v13 = c7v0.mClipName
      c7v14 = 12
      c7v15 = u0
      c7v15 = c7v15.Ternary
      c7v17 = 40
      c7v18 = 100
      c7v11:SetNumberVariable(c7v13, c7v14, c7v15(c7v7, c7v17, c7v18))
      c7v11 = mMovie
      c7v13 = c7v0.mClipName
      c7v14 = "Check"
      c7v15 = 13
      c7v17 = c7v0.mIncomplete
      if c7v17 == nil then
        p112 = 40
      else
        p112 = 39
      end
    end
    if p112 == 39 then
      c7v17 = c7v0.mIncomplete
      c7v16 = not c7v17
      if not c7v16 then
        p112 = 41
      else
        p112 = 40
      end
    end
    if p112 == 40 then
      c7v17 = c7v0.HideCheck
      c7v16 = not c7v17
      p112 = 41
    end
    if p112 == 41 then
      c7v11:Makeposshield(c7v13, c7v14, c7v15, c7v16)
      c7v11 = mMovie
      c7v13 = c7v0.mClipName
      c7v14 = "Check"
      c7v15 = 11
      c7v16 = u0
      c7v16 = c7v16.FloatingContentHighlight
      c7v11:Name__52c1b74e(c7v13, c7v14, c7v15, c7v16)
      c7v11 = 58
      c7v12 = c7v0.mBgDimOffset
      if c7v12 == nil then
        p112 = 43
      else
        p112 = 42
      end
    end
    if p112 == 42 then
      c7v12 = c7v0.mBgDimOffset
      c7v11 = c7v11 + c7v12
      p112 = 43
    end
    if p112 == 43 then
      c7v12 = 28
      c7v13 = c7v0.mIconXOffset
      if c7v13 == nil then
        p112 = 45
      else
        p112 = 44
      end
    end
    if p112 == 44 then
      c7v13 = c7v0.mIconXOffset
      c7v12 = c7v12 + c7v13
      p112 = 45
    end
    if p112 == 45 then
      c7v13 = 28
      c7v14 = c7v0.mIconYOffset
      if c7v14 == nil then
        p112 = 47
      else
        p112 = 46
      end
    end
    if p112 == 46 then
      c7v14 = c7v0.mIconYOffset
      c7v13 = c7v13 + c7v14
      p112 = 47
    end
    if p112 == 47 then
      c7v14 = mMovie
      c7v16 = c7v0.mClipName
      c7v17 = "Bg"
      c7v18 = 0
      c7v14:Name__52c1b74e(c7v16, c7v17, c7v18, c7v12)
      c7v14 = mMovie
      c7v16 = c7v0.mClipName
      c7v17 = "Bg"
      c7v18 = 1
      c7v14:Name__52c1b74e(c7v16, c7v17, c7v18, c7v13)
      c7v14 = mMovie
      c7v16 = c7v0.mClipName
      c7v17 = "Bg"
      c7v18 = 14
      c7v14:Name__52c1b74e(c7v16, c7v17, c7v18, c7v11)
      c7v14 = mMovie
      c7v16 = c7v0.mClipName
      c7v17 = "Bg"
      c7v18 = 15
      c7v14:Name__52c1b74e(c7v16, c7v17, c7v18, c7v11)
      c7v14 = mMovie
      c7v16 = c7v0.mClipName
      c7v17 = "IconMask"
      c7v18 = 14
      c7v19 = c7v11 - 6
      c7v14:Name__52c1b74e(c7v16, c7v17, c7v18, c7v19)
      c7v14 = mMovie
      c7v16 = c7v0.mClipName
      c7v17 = "IconMask"
      c7v18 = 15
      c7v19 = c7v11 - 6
      c7v14:Name__52c1b74e(c7v16, c7v17, c7v18, c7v19)
      c7v14 = c7v0.mBgOverride
      if c7v14 == nil then
        p112 = 49
      else
        p112 = 48
      end
    end
    if p112 == 48 then
      c7v14 = mMovie
      c7v17 = c7v0.mClipName
      c7v18 = ".Bg"
      c7v16 = c7v17 .. c7v18
      c7v17 = c7v0.mBgOverride
      c7v18 = _G
      c7v18 = c7v18.UIMaterial_Plain
      c7v14:Name__9c27ee88(c7v16, c7v17, c7v18)
      c7v14 = mMovie
      c7v16 = c7v0.mClipName
      c7v17 = "Bg"
      c7v18 = 11
      c7v19 = u0
      c7v19 = c7v19.FloatingContentHighlight
      c7v14:Name__52c1b74e(c7v16, c7v17, c7v18, c7v19)
      p112 = 50
    end
    if p112 == 49 then
      c7v14 = u0
      c7v14 = c7v14.Background1RGB
      c7v15 = u0
      c7v15 = c7v15.BackerHighlightRGB
      c7v16 = mMovie
      c7v19 = c7v0.mClipName
      c7v20 = ".Bg"
      c7v18 = c7v19 .. c7v20
      c7v19 = _G
      c7v19 = c7v19.UIMaterial_RectangleNoDepth
      c7v16:OverrideMaterial(c7v18, c7v19)
      c7v16 = mMovie
      c7v18 = c7v0.mClipName
      c7v19 = "Bg"
      c7v20 = 11
      c7v21 = _G
      c7v21 = c7v21.UIColor_White
      c7v16:Name__52c1b74e(c7v18, c7v19, c7v20, c7v21)
      c7v16 = mMovie
      c7v19 = c7v0.mClipName
      c7v20 = ".Bg"
      c7v18 = c7v19 .. c7v20
      c7v19 = "RectEdgeColor"
      c7v20 = c7v15.r
      c7v21 = c7v15.g
      c7v22 = c7v15.b
      c7v23 = 0.05
      c7v16:Name__e243d995(c7v18, c7v19, c7v20, c7v21, c7v22, c7v23)
      c7v16 = mMovie
      c7v19 = c7v0.mClipName
      c7v20 = ".Bg"
      c7v18 = c7v19 .. c7v20
      c7v19 = "RectInnerColor"
      c7v20 = c7v14.r
      c7v21 = c7v14.g
      c7v22 = c7v14.b
      c7v23 = 0.9
      c7v16:Name__e243d995(c7v18, c7v19, c7v20, c7v21, c7v22, c7v23)
      p112 = 50
    end
    if p112 == 50 then
      c7v14 = c7v0.mBGScale
      if c7v14 == nil then
        p112 = 52
      else
        p112 = 51
      end
    end
    if p112 == 51 then
      c7v14 = mMovie
      c7v16 = c7v0.mClipName
      c7v17 = "Bg"
      c7v18 = 5
      c7v19 = c7v0.mBGScale
      c7v14:Name__52c1b74e(c7v16, c7v17, c7v18, c7v19)
      c7v14 = mMovie
      c7v16 = c7v0.mClipName
      c7v17 = "Bg"
      c7v18 = 6
      c7v19 = c7v0.mBGScale
      c7v14:Name__52c1b74e(c7v16, c7v17, c7v18, c7v19)
      p112 = 52
    end
    if p112 == 52 then
      c7v14 = c7v0.mIndex
      if c7v14 ~= nil then
        p112 = 54
      else
        p112 = 53
      end
    end
    if p112 == 53 then
      c7v15 = u0
      c7v17 = c7v0.Id
      c7v14 = c7v15:GetElementIndexById(c7v17)
      p112 = 54
    end
    if p112 == 54 then
      c7v15 = u0
      c7v15 = c7v15.mInitialY
      c7v16 = IsNull
      c7v16 = c7v16(c7v14)
      if c7v16 then
        p112 = 59
      else
        p112 = 55
      end
    end
    if p112 == 55 then
      c7v16 = 1
      if c7v14 <= c7v16 then
        p112 = 59
      else
        p112 = 56
      end
    end
    if p112 == 56 then
      c7v18 = 1
      c7v16 = c7v14 - 1
      c7v17 = 1
      if (c7v17 > 0 and c7v18 > c7v16) or (c7v17 < 0 and c7v18 < c7v16) then
        p112 = 58
      else
        p112 = 57
      end
    end
    if p112 == 57 then
      c7v20 = u0
      c7v20 = c7v20.mForcedVerticalSeparation
      c7v23 = u0
      c7v23 = c7v23.mElements
      c7v22 = c7v23[c7v18]
      c7v22 = c7v22.mHeight
      c7v21 = c7v22 or 0
      c7v19 = math.max
      c7v19 = c7v19(c7v20, c7v21)
      c7v15 = c7v15 + c7v19
      p112 = 58
    end
    if p112 == 58 then
      c7v18 = 5
      c7v19 = c7v14 - 1
      c7v17 = c7v18 * c7v19
      c7v16 = c7v15 + c7v17
      c7v20 = c7v0.mHeight
      c7v21 = u0
      c7v21 = c7v21.mForcedVerticalSeparation
      c7v19 = c7v20 - c7v21
      c7v18 = c7v19 / 2
      c7v19 = 0
      c7v17 = math.max
      c7v17 = c7v17(c7v18, c7v19)
      c7v15 = c7v16 + c7v17
      p112 = 59
    end
    if p112 == 59 then
      c7v16 = mMovie
      c7v18 = c7v0.mClipName
      c7v19 = 1
      c7v20 = u0
      c7v20 = c7v20.Round
      c7v16:SetNumberVariable(c7v18, c7v19, c7v20(c7v15))
      do return end
    end
  end
  v1.mElementDrawCallback = v2
  v1 = u0
  v2 = function(c8v0, c8v1)
    local c8v2
    c8v2 = 0
    do return c8v2 end
  end
  v1.CalculateY = v2
  do return end
end

function proto_33(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16
  v1 = mMovie
  v4 = v0.mClipName
  v5 = ".Icon"
  v3 = v4 .. v5
  v4 = v0.Icon
  v1:OverrideTexture(v3, v4)
  v1 = mMovie
  v4 = v0.mClipName
  v5 = ".Icon"
  v3 = v4 .. v5
  v4 = v0.Material
  v1:OverrideMaterial(v3, v4)
  v1 = 50
  v2 = v0.Themed
  if not v2 then
    v1 = v1 * 1.6
  end
  v2 = mMovie
  v4 = v0.mClipName
  v5 = "Icon"
  v6 = 14
  v2:Name__52c1b74e(v4, v5, v6, v1)
  v2 = mMovie
  v4 = v0.mClipName
  v5 = "Icon"
  v6 = 11
  v7 = u0
  v7 = v7.Ternary
  v9 = v0.TintIconColor
  if v9 == nil then
    v8 = false
  else
    v8 = true
  end
  v9 = v0.TintIconColor
  v10 = _G
  v10 = v10.UIColor_White
  v2:Name__52c1b74e(v4, v5, v6, v7(v8, v9, v10))
  v2 = u1
  v2 = v2.FloatingContentHex
  v3 = u1
  v3 = v3.FloatingContentHighlightHex
  v5 = "<p><font color=\""
  v7 = "\">"
  v10 = TitleCase
  v11 = v0.Name
  v8 = v10(v11)
  v9 = "</font>"
  v4 = v5 .. v2 .. v7 .. v8 .. v9
  v5 = v0.HideCount
  if v5 ~= true then
    v6 = "<font color=\""
    v8 = "\"><br>"
    v4 = v4 .. v6 .. v3 .. v8
    v5 = v0.SubText
    if v5 ~= nil then
      v6 = v0.SubText
      v4 = v4 .. v6
    else
      v6 = u0
      v6 = v6.FormatNumber
      v7 = v0.Req
      v6 = v6(v7)
      v4 = v4 .. v6
    end
    v6 = "</font>"
    v4 = v4 .. v6
  end
  v6 = "</p>"
  v4 = v4 .. v6
  v5 = mMovie
  v7 = v0.mClipName
  v8 = "Name"
  v9 = 46
  v10 = "center"
  v5:Name__f4a9016a(v7, v8, v9, v10)
  v5 = mMovie
  v7 = v0.mClipName
  v8 = "Name"
  v9 = 36
  v5:Name__f4a9016a(v7, v8, v9, v4)
  v5 = mMovie
  v7 = v0.mClipName
  v8 = "Name"
  v9 = 41
  v5 = v5:Name__46690123(v7, v8, v9)
  v0.mHeight = v5
  v5 = mMovie
  v7 = v0.mClipName
  v8 = "Check"
  v9 = 13
  v10 = false
  v5:Makeposshield(v7, v8, v9, v10)
  v5 = u1
  v5 = v5.Background1RGB
  v6 = u1
  v6 = v6.BackerHighlightRGB
  v7 = mMovie
  v10 = v0.mClipName
  v11 = ".Bg"
  v9 = v10 .. v11
  v10 = _G
  v10 = v10.UIMaterial_RectangleNoDepth
  v7:OverrideMaterial(v9, v10)
  v7 = mMovie
  v10 = v0.mClipName
  v11 = ".Bg"
  v9 = v10 .. v11
  v10 = "RectEdgeColor"
  v11 = v6.r
  v12 = v6.g
  v13 = v6.b
  v14 = 0.05
  v7:Name__e243d995(v9, v10, v11, v12, v13, v14)
  v7 = mMovie
  v10 = v0.mClipName
  v11 = ".Bg"
  v9 = v10 .. v11
  v10 = "RectInnerColor"
  v11 = v5.r
  v12 = v5.g
  v13 = v5.b
  v14 = 0.9
  v7:Name__e243d995(v9, v10, v11, v12, v13, v14)
  v7 = v0.mIndex
  if v7 == nil then
    v8 = u2
    v10 = v0.Id
    v7 = v8:GetElementIndexById(v10)
  end
  v8 = u2
  v8 = v8.mInitialY
  v9 = IsNull
  v9 = v9(v7)
  if v7 ~= nil then
    v9 = 1
    if v9 < v7 then
      v11 = 1
      v9 = v7 - 1
      v10 = 1
      for v11 = v11, v9, v10 do
        v13 = u2
        v13 = v13.mForcedVerticalSeparation
        v16 = u2
        v16 = v16.mElements
        v15 = v16[v11]
        v15 = v15.mHeight
        v14 = v15 or 0
        v12 = math.max
        v12 = v12(v13, v14)
        v8 = v8 + v12
      end
      v11 = 5
      v12 = v7 - 1
      v10 = v11 * v12
      v9 = v8 + v10
      v13 = v0.mHeight
      v14 = u2
      v14 = v14.mForcedVerticalSeparation
      v12 = v13 - v14
      v11 = v12 / 2
      v12 = 0
      v10 = math.max
      v10 = v10(v11, v12)
      v8 = v9 + v10
    end
  end
  v9 = mMovie
  v11 = v0.mClipName
  v12 = 1
  v13 = u0
  v13 = v13.Round
  v9:SetNumberVariable(v11, v12, v13(v8))
  do return end
end

function proto_34(v0, v1)
  local v2
  v2 = 0
  do return v2 end
end

function proto_35()
  local v0, v1, v2, v3
  v0 = require
  v1 = "EE.Interface.Components.List"
  v0 = v0(v1)
  v1 = v0.CreateList
  v2 = mMovie
  v3 = "Popup.IngredientsSecondary.Ingredient"
  v1 = v1(v2, v3)
  u0 = v1
  v1 = u0
  v2 = 0
  v1.mForcedHorizontalSeparation = v2
  v1 = u0
  v2 = 62
  v1.mForcedVerticalSeparation = v2
  v1 = u0
  v2 = function(c9v0)
    local c9v1, c9v2, c9v3, c9v4, c9v5, c9v6, c9v7, c9v8, c9v9, c9v10, c9v11, c9v12, c9v13, c9v14, c9v15, c9v16
    c9v1 = mMovie
    c9v4 = c9v0.mClipName
    c9v5 = ".Icon"
    c9v3 = c9v4 .. c9v5
    c9v4 = c9v0.Icon
    c9v1:OverrideTexture(c9v3, c9v4)
    c9v1 = mMovie
    c9v4 = c9v0.mClipName
    c9v5 = ".Icon"
    c9v3 = c9v4 .. c9v5
    c9v4 = c9v0.Material
    c9v1:OverrideMaterial(c9v3, c9v4)
    c9v1 = 50
    c9v2 = c9v0.Themed
    if not c9v2 then
      c9v1 = c9v1 * 1.6
    end
    c9v2 = mMovie
    c9v4 = c9v0.mClipName
    c9v5 = "Icon"
    c9v6 = 14
    c9v2:Name__52c1b74e(c9v4, c9v5, c9v6, c9v1)
    c9v2 = mMovie
    c9v4 = c9v0.mClipName
    c9v5 = "Icon"
    c9v6 = 11
    c9v7 = u0
    c9v7 = c9v7.Ternary
    c9v9 = c9v0.TintIconColor
    if c9v9 == nil then
      c9v8 = false
    else
      c9v8 = true
    end
    c9v9 = c9v0.TintIconColor
    c9v10 = _G
    c9v10 = c9v10.UIColor_White
    c9v2:Name__52c1b74e(c9v4, c9v5, c9v6, c9v7(c9v8, c9v9, c9v10))
    c9v2 = u0
    c9v2 = c9v2.FloatingContentHex
    c9v3 = u0
    c9v3 = c9v3.FloatingContentHighlightHex
    c9v5 = "<p><font color=\""
    c9v7 = "\">"
    c9v10 = TitleCase
    c9v11 = c9v0.Name
    c9v8 = c9v10(c9v11)
    c9v9 = "</font>"
    c9v4 = c9v5 .. c9v2 .. c9v7 .. c9v8 .. c9v9
    c9v5 = c9v0.HideCount
    if c9v5 ~= true then
      c9v6 = "<font color=\""
      c9v8 = "\"><br>"
      c9v4 = c9v4 .. c9v6 .. c9v3 .. c9v8
      c9v5 = c9v0.SubText
      if c9v5 ~= nil then
        c9v6 = c9v0.SubText
        c9v4 = c9v4 .. c9v6
      else
        c9v6 = u0
        c9v6 = c9v6.FormatNumber
        c9v7 = c9v0.Req
        c9v6 = c9v6(c9v7)
        c9v4 = c9v4 .. c9v6
      end
      c9v6 = "</font>"
      c9v4 = c9v4 .. c9v6
    end
    c9v6 = "</p>"
    c9v4 = c9v4 .. c9v6
    c9v5 = mMovie
    c9v7 = c9v0.mClipName
    c9v8 = "Name"
    c9v9 = 46
    c9v10 = "center"
    c9v5:Name__f4a9016a(c9v7, c9v8, c9v9, c9v10)
    c9v5 = mMovie
    c9v7 = c9v0.mClipName
    c9v8 = "Name"
    c9v9 = 36
    c9v5:Name__f4a9016a(c9v7, c9v8, c9v9, c9v4)
    c9v5 = mMovie
    c9v7 = c9v0.mClipName
    c9v8 = "Name"
    c9v9 = 41
    c9v5 = c9v5:Name__46690123(c9v7, c9v8, c9v9)
    c9v0.mHeight = c9v5
    c9v5 = mMovie
    c9v7 = c9v0.mClipName
    c9v8 = "Check"
    c9v9 = 13
    c9v10 = false
    c9v5:Makeposshield(c9v7, c9v8, c9v9, c9v10)
    c9v5 = u0
    c9v5 = c9v5.Background1RGB
    c9v6 = u0
    c9v6 = c9v6.BackerHighlightRGB
    c9v7 = mMovie
    c9v10 = c9v0.mClipName
    c9v11 = ".Bg"
    c9v9 = c9v10 .. c9v11
    c9v10 = _G
    c9v10 = c9v10.UIMaterial_RectangleNoDepth
    c9v7:OverrideMaterial(c9v9, c9v10)
    c9v7 = mMovie
    c9v10 = c9v0.mClipName
    c9v11 = ".Bg"
    c9v9 = c9v10 .. c9v11
    c9v10 = "RectEdgeColor"
    c9v11 = c9v6.r
    c9v12 = c9v6.g
    c9v13 = c9v6.b
    c9v14 = 0.05
    c9v7:Name__e243d995(c9v9, c9v10, c9v11, c9v12, c9v13, c9v14)
    c9v7 = mMovie
    c9v10 = c9v0.mClipName
    c9v11 = ".Bg"
    c9v9 = c9v10 .. c9v11
    c9v10 = "RectInnerColor"
    c9v11 = c9v5.r
    c9v12 = c9v5.g
    c9v13 = c9v5.b
    c9v14 = 0.9
    c9v7:Name__e243d995(c9v9, c9v10, c9v11, c9v12, c9v13, c9v14)
    c9v7 = c9v0.mIndex
    if c9v7 == nil then
      c9v8 = u0
      c9v10 = c9v0.Id
      c9v7 = c9v8:GetElementIndexById(c9v10)
    end
    c9v8 = u0
    c9v8 = c9v8.mInitialY
    c9v9 = IsNull
    c9v9 = c9v9(c9v7)
    if c9v7 ~= nil then
      c9v9 = 1
      if c9v9 < c9v7 then
        c9v11 = 1
        c9v9 = c9v7 - 1
        c9v10 = 1
        for c9v11 = c9v11, c9v9, c9v10 do
          c9v13 = u0
          c9v13 = c9v13.mForcedVerticalSeparation
          c9v16 = u0
          c9v16 = c9v16.mElements
          c9v15 = c9v16[c9v11]
          c9v15 = c9v15.mHeight
          c9v14 = c9v15 or 0
          c9v12 = math.max
          c9v12 = c9v12(c9v13, c9v14)
          c9v8 = c9v8 + c9v12
        end
        c9v11 = 5
        c9v12 = c9v7 - 1
        c9v10 = c9v11 * c9v12
        c9v9 = c9v8 + c9v10
        c9v13 = c9v0.mHeight
        c9v14 = u0
        c9v14 = c9v14.mForcedVerticalSeparation
        c9v12 = c9v13 - c9v14
        c9v11 = c9v12 / 2
        c9v12 = 0
        c9v10 = math.max
        c9v10 = c9v10(c9v11, c9v12)
        c9v8 = c9v9 + c9v10
      end
    end
    c9v9 = mMovie
    c9v11 = c9v0.mClipName
    c9v12 = 1
    c9v13 = u0
    c9v13 = c9v13.Round
    c9v9:SetNumberVariable(c9v11, c9v12, c9v13(c9v8))
    do return end
  end
  v1.mElementDrawCallback = v2
  v1 = u0
  v2 = function(c10v0, c10v1)
    local c10v2
    c10v2 = 0
    do return c10v2 end
  end
  v1.CalculateY = v2
  do return end
end

function proto_36(v0, v1)
  local v2, v5, v6, v7
  v2 = mMovie
  v5 = "Bg"
  v6 = 12
  v7 = 5
  v2:Name__52c1b74e(v0, v5, v6, v7)
  do return end
end

function proto_37(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8
  v1 = mMovie
  v3 = v0.mClipName
  v4 = "Icon"
  v5 = 11
  v6 = u0
  v6 = v6.FloatingContent
  v1:Name__52c1b74e(v3, v4, v5, v6)
  v1 = mMovie
  v3 = v0.mClipName
  v4 = "Label"
  v5 = 44
  v6 = u0
  v6 = v6.FloatingContentHighlight
  v1:Name__52c1b74e(v3, v4, v5, v6)
  v1 = mMovie
  v3 = v0.mClipName
  v4 = "Bg"
  v5 = 11
  v6 = u0
  v6 = v6.Content
  v1:Name__52c1b74e(v3, v4, v5, v6)
  v1 = mMovie
  v4 = v0.mClipName
  v5 = ".Icon"
  v3 = v4 .. v5
  v5 = crewSkillIcons
  v7 = v0.Skill
  v6 = v7 + 1
  v4 = v5[v6]
  v1:OverrideTexture(v3, v4)
  v1 = mMovie
  v3 = v0.mClipName
  v4 = "Bg"
  v5 = 13
  v8 = v0.mIndex
  v7 = v8 % 2
  if v7 ~= 1 then
    v6 = false
  else
    v6 = true
  end
  v1:Makeposshield(v3, v4, v5, v6)
  v1 = TitleCase
  v2 = mMovie
  v5 = "/Lotus/Language/Railjack/CrewSkill"
  v7 = v0.Skill
  v6 = tostring
  v6 = v6(v7)
  v4 = v5 .. v6
  v5 = false
  v1 = v1(v2:GetLocalized(v4, v5))
  v2 = mMovie
  v4 = "/Lotus/Language/Railjack/CrewSkillLong"
  v5 = false
  v6 = { LEVEL = nil, SKILL = nil }
  v7 = v0.Level
  v6.LEVEL = v7
  v6.SKILL = v1
  v2 = v2:GetLocalized(v4, v5, v6)
  v3 = mMovie
  v5 = v0.mClipName
  v6 = "Label"
  v7 = 36
  v3:Name__f4a9016a(v5, v6, v7, v2)
  do return end
end

function proto_38()
  local v0, v1, v2, v3, v4, v5, v6
  v0 = require
  v1 = "EE.Interface.Components.List"
  v0 = v0(v1)
  v1 = v0.CreateList
  v2 = mMovie
  v3 = "Popup.CrewMemberInfo.Skill1"
  v1 = v1(v2, v3)
  u0 = v1
  v1 = u0
  v2 = 0
  v1.mForcedHorizontalSeparation = v2
  v1 = u0
  v2 = 32
  v1.mForcedVerticalSeparation = v2
  v1 = u0
  v2 = function(c11v0, c11v1)
    local c11v2, c11v5, c11v6, c11v7
    c11v2 = mMovie
    c11v5 = "Bg"
    c11v6 = 12
    c11v7 = 5
    c11v2:Name__52c1b74e(c11v0, c11v5, c11v6, c11v7)
    do return end
  end
  v1.mClipCreatedCallback = v2
  v1 = u0
  v2 = function(c12v0)
    local c12v1, c12v2, c12v3, c12v4, c12v5, c12v6, c12v7, c12v8
    c12v1 = mMovie
    c12v3 = c12v0.mClipName
    c12v4 = "Icon"
    c12v5 = 11
    c12v6 = u1
    c12v6 = c12v6.FloatingContent
    c12v1:Name__52c1b74e(c12v3, c12v4, c12v5, c12v6)
    c12v1 = mMovie
    c12v3 = c12v0.mClipName
    c12v4 = "Label"
    c12v5 = 44
    c12v6 = u1
    c12v6 = c12v6.FloatingContentHighlight
    c12v1:Name__52c1b74e(c12v3, c12v4, c12v5, c12v6)
    c12v1 = mMovie
    c12v3 = c12v0.mClipName
    c12v4 = "Bg"
    c12v5 = 11
    c12v6 = u1
    c12v6 = c12v6.Content
    c12v1:Name__52c1b74e(c12v3, c12v4, c12v5, c12v6)
    c12v1 = mMovie
    c12v4 = c12v0.mClipName
    c12v5 = ".Icon"
    c12v3 = c12v4 .. c12v5
    c12v5 = crewSkillIcons
    c12v7 = c12v0.Skill
    c12v6 = c12v7 + 1
    c12v4 = c12v5[c12v6]
    c12v1:OverrideTexture(c12v3, c12v4)
    c12v1 = mMovie
    c12v3 = c12v0.mClipName
    c12v4 = "Bg"
    c12v5 = 13
    c12v8 = c12v0.mIndex
    c12v7 = c12v8 % 2
    if c12v7 ~= 1 then
      c12v6 = false
    else
      c12v6 = true
    end
    c12v1:Makeposshield(c12v3, c12v4, c12v5, c12v6)
    c12v1 = TitleCase
    c12v2 = mMovie
    c12v5 = "/Lotus/Language/Railjack/CrewSkill"
    c12v7 = c12v0.Skill
    c12v6 = tostring
    c12v6 = c12v6(c12v7)
    c12v4 = c12v5 .. c12v6
    c12v5 = false
    c12v1 = c12v1(c12v2:GetLocalized(c12v4, c12v5))
    c12v2 = mMovie
    c12v4 = "/Lotus/Language/Railjack/CrewSkillLong"
    c12v5 = false
    c12v6 = { LEVEL = nil, SKILL = nil }
    c12v7 = c12v0.Level
    c12v6.LEVEL = c12v7
    c12v6.SKILL = c12v1
    c12v2 = c12v2:GetLocalized(c12v4, c12v5, c12v6)
    c12v3 = mMovie
    c12v5 = c12v0.mClipName
    c12v6 = "Label"
    c12v7 = 36
    c12v3:Name__f4a9016a(c12v5, c12v6, c12v7, c12v2)
    do return end
  end
  v1.mElementDrawCallback = v2
  v1 = 3
  v2 = gRegion
  v2 = v2:IsMaster()
  if not v2 then
    v1 = 4
  end
  v2 = mMovie
  v4 = "Popup.CrewMemberInfo.BelowSkills.HealthInfo"
  v5 = 1
  v6 = 40
  v2:SetNumberVariable(v4, v5, v6)
  v2 = mMovie
  v4 = "Popup.CrewMemberInfo.BelowSkills.HealthLabel"
  v5 = 1
  v6 = 15
  v2:SetNumberVariable(v4, v5, v6)
  v2 = mMovie
  v4 = "Popup.CrewMemberInfo.BelowSkills.Faction"
  v5 = 12
  v6 = 70
  v2:SetNumberVariable(v4, v5, v6)
  v2 = u2
  v2 = v2.DrawSeparator
  v3 = mMovie
  v4 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Separator"
  v5 = 325
  v2(v3, v4, v5)
  do return end
end

function proto_39(v0, v1)
  local v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24
  v2 = mMovie
  v4 = "Popup.CrewMemberInfo"
  v5 = 13
  v6 = not v1
  v2:Name__d9713943(v4, v5, v6)
  if v1 then
    do return end
  end
  v2 = 0
  v3 = mMovie
  v5 = "Popup.CrewMemberInfo.Trait"
  v6 = 13
  v8 = u0
  v8 = v8.IsEliteCrewMember
  if v8 ~= true then
    v7 = false
  else
    v7 = true
  end
  v3:Name__d9713943(v5, v6, v7)
  v3 = u0
  v3 = v3.IsEliteCrewMember
  if v3 then
    v2 = 72
    v3 = mMovie
    v5 = "Popup.CrewMemberInfo.Trait.Desc"
    v6 = 46
    v7 = "center"
    v3:SetStringVariable(v5, v6, v7)
    v3 = u1
    v3 = v3.GetCrewMemberTrait
    v4 = u0
    v4 = v4.CrewMemberInfo
    v4 = v4.mCrewMemberGeneratedDetails
    v4 = v4.mSkillUpgrade
    v3 = v3(v4)
    v4 = u2
    v4 = v4.FitTextIntoLines
    v5 = mMovie
    v6 = "Popup.CrewMemberInfo.Trait.Desc"
    v7 = 3
    v9 = "..."
    v4(v5, v6, v7, v3, v9)
  end
  v3 = mMovie
  v5 = "Popup.CrewMemberInfo"
  v6 = 1
  v9 = u3
  v8 = v9 + 10
  v7 = v8 + v2
  v3:SetNumberVariable(v5, v6, v7)
  v3 = u4
  v5 = true
  v6 = true
  v3:RemoveElements(v5, v6)
  if not v1 then
    v5 = 0
    v6 = 5
    v3 = v6 - 1
    v4 = 1
    for v5 = v5, v3, v4 do
      v6 = u4
      v8 = { Skill = nil, Level = nil }
      v8.Skill = v5
      v9 = u0
      v9 = v9.CrewMemberInfo
      v9 = v9:GetSkillEfficiency(v5)
      v8.Level = v9
      v9 = true
      v6:AddElement(v8, v9)
    end
  end
  v3 = u4
  v5 = nil
  v6 = nil
  v7 = true
  v3:Redraw(v5, v6, v7)
  v4 = u4
  v4 = v4:GetHowManyElements()
  v5 = u4
  v5 = v5.mForcedVerticalSeparation
  v3 = v4 * v5
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills"
  v7 = 1
  v8 = v3 + 5
  v4:SetNumberVariable(v6, v7, v8)
  v6 = u3
  v5 = v6 + v2
  v4 = v5 + v3
  u3 = v4
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills.HealthInfo"
  v7 = 13
  v8 = false
  v4:Name__d9713943(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills.HealthLabel"
  v7 = 13
  v8 = false
  v4:Name__d9713943(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo"
  v7 = 1
  v8 = 0
  v4:SetNumberVariable(v6, v7, v8)
  v4 = mMovie
  v6 = "Popup.CrewMemberInfo.BelowSkills.Faction"
  v7 = 1
  v8 = 40
  v4:SetNumberVariable(v6, v7, v8)
  v4 = crewIconMap
  v6 = string.lower
  v7 = u0
  v7 = v7.CrewMemberInfo
  v7 = v7.mFaction
  v6 = v6(v7:c_str())
  v7 = 0
  v4 = v4:Name__8d37ff34(v6, v7)
  v5 = mMovie
  v7 = "Popup.CrewMemberInfo.BelowSkills.Faction"
  v8 = v4
  if not v8 then
    v8 = u0
    v8 = v8.Icon
  end
  v5:OverrideTexture(v7, v8)
  v5 = u0
  v5 = v5.CrewMemberInfo
  v5 = v5.mPowersuitInfo
  v6 = gGameConfig
  v8 = v5.mXP
  v9 = v5.mItemType
  v6 = v6:GetItemLevel(v8, v9)
  v7 = gGameConfig
  v9 = v5.mItemType
  v10 = v5.mPolarized
  v7 = v7:Name__123bb887(v9, v10)
  v8 = math.min
  v6 = v8(v7, v6)
  v8 = " "
  v9 = mMovie
  v11 = "Popup.CrewMemberInfo.BelowSkills.Rank"
  v12 = 36
  v13 = TitleCase
  v9:SetStringVariable(v11, v12, v13(v8))
  v9 = u0
  v9 = v9.CrewMemberInfo
  v9 = v9.mWeaponId
  v9 = v9.mId
  v10 = false
  v11 = Lotus_Game.InvalidItemID
  if v9 ~= v11 then
    v10 = false
    if v9 ~= "" then
      v11 = tonumber
      v11 = v11(v9)
      if v11 == 0 then
        v10 = false
      else
        v10 = true
      end
    end
  end
  v11 = mMovie
  v13 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo"
  v14 = 13
  v11:Name__d9713943(v13, v14, v10)
  if not v10 then
    v12 = u3
    v11 = v12 + 75
    u3 = v11
    v11 = mMovie
    v13 = "Popup.CrewMemberInfo.BelowSkills.Faction"
    v14 = 0
    v15 = 165
    v11:SetNumberVariable(v13, v14, v15)
    do return end
  end
  v11 = gGameData
  v11 = v11:GetInventory()
  v12 = v11:Name__34888a88(v9)
  v13 = IsNull
  v13 = v13(v12)
  if not v13 then
    v13 = gGameRules
    v13 = v13:GetStoreManifest()
    v14 = IsNull
    v14 = v14(v13)
    if not v14 then
      v14 = u5
      v14 = v14.GetItemTypeWithStoreInfo
      v15 = mMovie
      v16 = v12.mItemType
      v18 = { ItemInfo = nil }
      v18.ItemInfo = v12
      v19 = true
      v14 = v14(v15, v16, v13, v18, v19)
      v15 = IsNull
      v15 = v15(v14)
      if not v15 then
        v15 = mMovie
        v17 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Icon"
        v18 = v14.Icon
        v15:OverrideTexture(v17, v18)
        v15 = mMovie
        v17 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Icon"
        v18 = 14
        v20 = 64
        v21 = u2
        v21 = v21.Ternary
        v22 = v14.Themed
        v23 = 1
        v24 = 1.6
        v21 = v21(v22, v23, v24)
        v19 = v20 * v21
        v15:SetNumberVariable(v17, v18, v19)
        v15 = mMovie
        v17 = v14.Name
        v18 = false
        v15 = v15:GetLocalized(v17, v18)
        v16 = mMovie
        v18 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Name"
        v19 = 14
        v20 = 210
        v16:SetNumberVariable(v18, v19, v20)
        v16 = u2
        v16 = v16.SetFitText
        v17 = mMovie
        v18 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Name"
        v19 = "..."
        v16(v17, v18, v19)
        v16 = mMovie
        v18 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Name"
        v19 = 36
        v16:SetStringVariable(v18, v19, v15)
        v16 = gGameConfig
        v18 = v12.mXP
        v19 = v12.mItemType
        v16 = v16:GetItemLevel(v18, v19)
        v17 = mMovie
        v19 = "/Lotus/Language/Menu/Global_FormattedRankCaps"
        v20 = false
        v21 = { RANK = nil }
        v22 = u2
        v22 = v22.FormatNumber
        v22 = v22(v16)
        v21.RANK = v22
        v8 = v17:GetLocalized(v19, v20, v21)
        v17 = mMovie
        v19 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Rank"
        v20 = 36
        v21 = TitleCase
        v17:SetStringVariable(v19, v20, v21(v8))
      end
    end
  end
  v14 = u3
  v13 = v14 + 75
  u3 = v13
  v13 = mMovie
  v15 = "Popup.CrewMemberInfo.BelowSkills.Faction"
  v16 = 0
  v17 = 300
  v13:SetNumberVariable(v15, v16, v17)
  do return end
end

function proto_40(v0)
  local v1
  v1 = mMovie
  v1:SetMouseVisible(v0)
  do return end
end

function proto_41()
  local v0, v1
  v0 = _T
  v1 = nil
  v0.ShowItemInfoPopupCursor = v1
  v0 = u0
  if v0 then
    v0 = _T
    v1 = 0
    v0.ItemInfoPopupCount = v1
    v0 = _T
    v1 = nil
    v0.ItemInfoStatComparison = v1
  end
  do return end
end

function proto_42(v0, v1)
  local v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14
  v2 = v0.Labels
  v3 = v1.Labels
  v4 = {}
  v0.StatChanges = v4
  v4 = {}
  v1.StatChanges = v4
  v4 = {}
  v7 = 1
  v5 = #v2
  v6 = 1
  for v7 = v7, v5, v6 do
    v8 = v2[v7]
    v4[v8] = v7
  end
  v7 = 1
  v5 = #v3
  v6 = 1
  for v7 = v7, v5, v6 do
    v9 = v3[v7]
    v8 = v4[v9]
    v10 = v1.CompareValues
    v9 = v10[v7]
    if v8 == nil then
    else
      v10 = v3[v7]
      v11 = nil
      v4[v10] = v11
      v11 = v0.CompareValues
      v10 = v11[v8]
      if v10 ~= v9 then
        v13 = tonumber
        v13 = v13(v10)
        v12 = v13 or 0
        v14 = tonumber
        v14 = v14(v9)
        v13 = v14 or 0
        if v13 <= v12 then
          v11 = false
        else
          v11 = true
        end
        v12 = v0.StatChanges
        if not v11 then
          v13 = 1
        else
          v13 = -1
        end
        v12[v8] = v13
        v12 = v1.StatChanges
        if v11 then
          v13 = 1
        else
          v13 = -1
        end
        v12[v7] = v13
      end
    end
  end
  do return end
end

function proto_43(v0, v1)
  local v2, v3, v4
  v2 = v0
  if not v2 then
    v2 = u0
  end
  u0 = v2
  v2 = v1
  if not v2 then
    v2 = u1
  end
  u1 = v2
  v2 = u0
  if v2 then
    v2 = u0
    v2 = v2.CompareValues
    if v2 ~= nil then
      v2 = u2
      v2 = v2.CompareValues
      if v2 ~= nil then
        v2 = u3
        v3 = u2
        v4 = u0
        v2(v3, v4)
        v2 = u2
        v3 = u2
        v3 = v3.BonusStats
        if not v3 then
          v3 = {}
        end
        v2.BonusStats = v3
        v2 = u0
        v3 = u0
        v3 = v3.BonusStats
        if not v3 then
          v3 = {}
        end
        v2.BonusStats = v3
        v2 = u3
        v3 = u2
        v3 = v3.BonusStats
        v4 = u0
        v4 = v4.BonusStats
        v2(v3, v4)
      end
    end
  end
  v2 = u4
  v2()
  v2 = u1
  if v2 ~= nil then
    v2 = u1
    v2()
  end
  do return end
end

function proto_44(v0, v1)
  local v2, v3, v4, v5
  v3 = 50
  v5 = v0 / v1
  v4 = v5 * 50
  v2 = v3 + v4
  v3 = u0
  v3 = v3.AttackerFaction
  v4 = 2
  if v3 == v4 then
    v3 = 100
    v5 = v0 / v1
    v4 = v5 * 100
    v2 = v3 + v4
  end
  do return v2 end
end

function proto_45(v0)
  local v1, v3, v4, v5, v6, v7, v8
  v1 = mMovie
  v5 = ".ProgressBar.LeftFill"
  v3 = v0 .. v5
  v4 = "RectInnerColor"
  v5 = u0
  v5 = v5.FloatingContentRGB
  v5 = v5.r
  v6 = u0
  v6 = v6.FloatingContentRGB
  v6 = v6.g
  v7 = u0
  v7 = v7.FloatingContentRGB
  v7 = v7.b
  v8 = 0.4
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v5 = ".ProgressBar.LeftFill"
  v3 = v0 .. v5
  v4 = "RectEdgeColor"
  v5 = 0
  v6 = 0
  v7 = 0
  v8 = 0
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v5 = ".ProgressBar.RightFill"
  v3 = v0 .. v5
  v4 = "RectInnerColor"
  v5 = u0
  v5 = v5.FloatingContentRGB
  v5 = v5.r
  v6 = u0
  v6 = v6.FloatingContentRGB
  v6 = v6.g
  v7 = u0
  v7 = v7.FloatingContentRGB
  v7 = v7.b
  v8 = 1
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v5 = ".ProgressBar.RightFill"
  v3 = v0 .. v5
  v4 = "RectEdgeColor"
  v5 = 0
  v6 = 0
  v7 = 0
  v8 = 0
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v5 = ".ProgressBar.Bg"
  v3 = v0 .. v5
  v4 = "RectInnerColor"
  v5 = u0
  v5 = v5.Background1RGB
  v5 = v5.r
  v6 = u0
  v6 = v6.Background1RGB
  v6 = v6.g
  v7 = u0
  v7 = v7.Background1RGB
  v7 = v7.b
  v8 = 1
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v5 = ".ProgressBar.Bg"
  v3 = v0 .. v5
  v4 = "RectEdgeColor"
  v5 = u0
  v5 = v5.FloatingContentRGB
  v5 = v5.r
  v6 = u0
  v6 = v6.FloatingContentRGB
  v6 = v6.g
  v7 = u0
  v7 = v7.FloatingContentRGB
  v7 = v7.b
  v8 = 1
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v4 = "Progress"
  v5 = 44
  v6 = u0
  v6 = v6.Content
  v1:Name__52c1b74e(v0, v4, v5, v6)
  v1 = mMovie
  v4 = "LRewards"
  v5 = 44
  v6 = u0
  v6 = v6.Content
  v1:Name__52c1b74e(v0, v4, v5, v6)
  v1 = mMovie
  v4 = "RRewards"
  v5 = 44
  v6 = u0
  v6 = v6.Content
  v1:Name__52c1b74e(v0, v4, v5, v6)
  do return end
end

function proto_46(v0, v1)
  local v2, v4, v5, v6
  v2 = u0
  v2 = v2.UpdateColor
  v2(v0)
  v2 = mMovie
  v6 = ".ProgressBar.LeftFill"
  v4 = v0 .. v6
  v5 = _G
  v5 = v5.UIMaterial_RectangleNoDepth
  v2:OverrideMaterial(v4, v5)
  v2 = mMovie
  v6 = ".ProgressBar.RightFill"
  v4 = v0 .. v6
  v5 = _G
  v5 = v5.UIMaterial_RectangleNoDepth
  v2:OverrideMaterial(v4, v5)
  v2 = mMovie
  v6 = ".ProgressBar.Bg"
  v4 = v0 .. v6
  v5 = _G
  v5 = v5.UIMaterial_RectangleNoDepth
  v2:OverrideMaterial(v4, v5)
  do return end
end

function proto_47(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14
  v1 = mMovie
  v3 = v0.Node
  v3 = v3:c_str()
  v4 = false
  v1 = v1:GetLocalized(v3, v4)
  v2 = v0.CustomEntry
  if not v2 then
    v2 = "<p><font size=\"19\"><b>"
    v4 = "</b></font></p>"
    v1 = v2 .. v1 .. v4
  end
  v2 = mMovie
  v4 = v0.mClipName
  v5 = "Title"
  v6 = 36
  v2:Name__f4a9016a(v4, v5, v6, v1)
  v2 = mMovie
  v4 = v0.mClipName
  v5 = "Title"
  v6 = 45
  v7 = u0
  v7 = v7.Ternary
  v8 = v0.CustomEntry
  v9 = "left"
  v10 = "center"
  v2:Name__f4a9016a(v4, v5, v6, v7(v8, v9, v10))
  v2 = mMovie
  v4 = v0.mClipName
  v5 = "Title"
  v6 = 0
  v7 = u0
  v7 = v7.Ternary
  v8 = v0.CustomEntry
  v9 = 2
  v10 = 115
  v2:Name__52c1b74e(v4, v5, v6, v7(v8, v9, v10))
  v2 = mMovie
  v4 = v0.mClipName
  v5 = "Title"
  v6 = 1
  v7 = u0
  v7 = v7.Ternary
  v8 = v0.CustomEntry
  v9 = 45
  v10 = 0
  v2:Name__52c1b74e(v4, v5, v6, v7(v8, v9, v10))
  v2 = mMovie
  v4 = v0.mClipName
  v5 = "Title"
  v6 = 44
  v7 = u0
  v7 = v7.Ternary
  v8 = v0.CustomEntry
  v9 = u1
  v9 = v9.FloatingContentHighlight
  v10 = u1
  v10 = v10.FloatingContent
  v2:Name__52c1b74e(v4, v5, v6, v7(v8, v9, v10))
  v2 = false
  v3 = v0.Delta
  if v3 ~= nil then
    v2 = false
    v3 = v0.Delta
    if v3 ~= 0 then
      v3 = v0.HideProgress
      v2 = not v3
    end
  end
  v3 = mMovie
  v5 = v0.mClipName
  v6 = "Progress"
  v7 = 13
  v3:Makeposshield(v5, v6, v7, v2)
  if v2 then
    v3 = 0
    v4 = mMovie
    v6 = v0.mClipName
    v7 = "Progress"
    v8 = 36
    v14 = v0.Delta
    v13 = tostring
    v10 = v13(v14)
    v11 = "/"
    v13 = 3
    v12 = tostring
    v12 = v12(v13)
    v9 = v10 .. v11 .. v12
    v4:Name__f4a9016a(v6, v7, v8, v9)
    v4 = mMovie
    v6 = v0.mClipName
    v7 = "Progress"
    v8 = 45
    v9 = u0
    v9 = v9.Ternary
    v10 = v0.SupportAttacker
    v11 = "left"
    v12 = "right"
    v4:Name__f4a9016a(v6, v7, v8, v9(v10, v11, v12))
    v4 = v0.SupportAttacker
    if not v4 then
      v4 = mMovie
      v7 = v0.mClipName
      v8 = ".Progress"
      v6 = v7 .. v8
      v7 = 14
      v4 = v4:GetNumberVariable(v6, v7)
      v5 = u2
      v5 = v5.BarWidth
      v3 = v5 - v4
    end
    v4 = mMovie
    v6 = v0.mClipName
    v7 = "Progress"
    v8 = 0
    v4:Name__52c1b74e(v6, v7, v8, v3)
  end
  v3 = v0.CustomEntry
  if v3 then
    v3 = mMovie
    v5 = v0.mClipName
    v6 = "ProgressBar.LeftFill"
    v7 = 14
    v8 = 0.001
    v3:Name__52c1b74e(v5, v6, v7, v8)
    v3 = Clamp
    v5 = u2
    v5 = v5.BarWidth
    v6 = v0.Delta
    v4 = v5 * v6
    v5 = 0.001
    v6 = u2
    v6 = v6.BarWidth
    v3 = v3(v4, v5, v6)
    v4 = mMovie
    v6 = v0.mClipName
    v7 = "ProgressBar.RightFill"
    v8 = 14
    v4:Name__52c1b74e(v6, v7, v8, v3)
    v4 = mMovie
    v6 = v0.mClipName
    v7 = "ProgressBar.RightFill"
    v8 = 0
    v4:Name__52c1b74e(v6, v7, v8, v3)
  else
    v4 = v0.Count
    v5 = v0.Goal
    v7 = 50
    v9 = v4 / v5
    v8 = v9 * 50
    v6 = v7 + v8
    v7 = u3
    v7 = v7.AttackerFaction
    v8 = 2
    if v7 == v8 then
      v7 = 100
      v9 = v4 / v5
      v8 = v9 * 100
      v6 = v7 + v8
    end
    v3 = v6
    v5 = u2
    v5 = v5.BarWidth
    v6 = v3 / 100
    v4 = v5 * v6
    v5 = mMovie
    v7 = v0.mClipName
    v8 = "ProgressBar.LeftFill"
    v9 = 14
    v10 = Clamp
    v11 = v4 + 2
    v12 = 0.001
    v13 = u2
    v13 = v13.BarWidth
    v5:Name__52c1b74e(v7, v8, v9, v10(v11, v12, v13))
    v5 = mMovie
    v7 = v0.mClipName
    v8 = "ProgressBar.RightFill"
    v9 = 14
    v10 = Clamp
    v13 = u2
    v13 = v13.BarWidth
    v12 = v13 - v4
    v11 = v12 + 2
    v12 = 0.001
    v13 = u2
    v13 = v13.BarWidth
    v5:Name__52c1b74e(v7, v8, v9, v10(v11, v12, v13))
    v5 = mMovie
    v7 = v0.mClipName
    v8 = "ProgressBar.RightFill"
    v9 = 0
    v10 = u2
    v10 = v10.BarWidth
    v5:Name__52c1b74e(v7, v8, v9, v10)
  end
  v3 = mMovie
  v5 = v0.mClipName
  v6 = "ProgressBar.Bg"
  v7 = 14
  v8 = u2
  v8 = v8.BarWidth
  v3:Name__52c1b74e(v5, v6, v7, v8)
  v4 = v0.AttackerReward
  v3 = IsNull
  v3 = v3(v4)
  if not v3 then
    v4 = v0.DefenderReward
    v3 = IsNull
    v3 = v3(v4)
    if not v3 then
      v3 = TitleCase
      v4 = u4
      v4 = v4.GetRewardDesc
      v5 = mMovie
      v6 = v0.AttackerReward
      v3 = v3(v4(v5, v6))
      v4 = TitleCase
      v5 = u4
      v5 = v5.GetRewardDesc
      v6 = mMovie
      v7 = v0.DefenderReward
      v4 = v4(v5(v6, v7))
      v5 = u0
      v5 = v5.FitTextIntoLines
      v6 = mMovie
      v8 = v0.mClipName
      v9 = ".LRewards"
      v7 = v8 .. v9
      v8 = 2
      v10 = "..."
      v5(v6, v7, v8, v3, v10)
      v5 = u0
      v5 = v5.FitTextIntoLines
      v6 = mMovie
      v8 = v0.mClipName
      v9 = ".RRewards"
      v7 = v8 .. v9
      v8 = 2
      v10 = "..."
      v5(v6, v7, v8, v4, v10)
      do return end
    end
  end
  v3 = mMovie
  v5 = v0.mClipName
  v6 = "LRewards"
  v7 = 36
  v8 = ""
  v3:Name__f4a9016a(v5, v6, v7, v8)
  v3 = mMovie
  v5 = v0.mClipName
  v6 = "RRewards"
  v7 = 36
  v8 = ""
  v3:Name__f4a9016a(v5, v6, v7, v8)
  do return end
end

function proto_48()
  local v0, v1, v2, v3
  v0 = require
  v1 = "EE.Interface.Components.List"
  v0 = v0(v1)
  v1 = v0.CreateList
  v2 = mMovie
  v3 = "Popup.Invasion.Subinvasion"
  v1 = v1(v2, v3)
  u0 = v1
  v1 = u0
  v2 = 330
  v1.BarWidth = v2
  v1 = u0
  v2 = 0
  v1.mForcedHorizontalSeparation = v2
  v1 = u0
  v2 = 75
  v1.mForcedVerticalSeparation = v2
  v1 = function(c13v0, c13v1)
    local c13v2, c13v3, c13v4, c13v5
    c13v3 = 50
    c13v5 = c13v0 / c13v1
    c13v4 = c13v5 * 50
    c13v2 = c13v3 + c13v4
    c13v3 = u1
    c13v3 = c13v3.AttackerFaction
    c13v4 = 2
    if c13v3 == c13v4 then
      c13v3 = 100
      c13v5 = c13v0 / c13v1
      c13v4 = c13v5 * 100
      c13v2 = c13v3 + c13v4
    end
    do return c13v2 end
  end
  v2 = u0
  v3 = function(c14v0)
    local c14v1, c14v3, c14v4, c14v5, c14v6, c14v7, c14v8
    c14v1 = mMovie
    c14v5 = ".ProgressBar.LeftFill"
    c14v3 = c14v0 .. c14v5
    c14v4 = "RectInnerColor"
    c14v5 = u2
    c14v5 = c14v5.FloatingContentRGB
    c14v5 = c14v5.r
    c14v6 = u2
    c14v6 = c14v6.FloatingContentRGB
    c14v6 = c14v6.g
    c14v7 = u2
    c14v7 = c14v7.FloatingContentRGB
    c14v7 = c14v7.b
    c14v8 = 0.4
    c14v1:Name__e243d995(c14v3, c14v4, c14v5, c14v6, c14v7, c14v8)
    c14v1 = mMovie
    c14v5 = ".ProgressBar.LeftFill"
    c14v3 = c14v0 .. c14v5
    c14v4 = "RectEdgeColor"
    c14v5 = 0
    c14v6 = 0
    c14v7 = 0
    c14v8 = 0
    c14v1:Name__e243d995(c14v3, c14v4, c14v5, c14v6, c14v7, c14v8)
    c14v1 = mMovie
    c14v5 = ".ProgressBar.RightFill"
    c14v3 = c14v0 .. c14v5
    c14v4 = "RectInnerColor"
    c14v5 = u2
    c14v5 = c14v5.FloatingContentRGB
    c14v5 = c14v5.r
    c14v6 = u2
    c14v6 = c14v6.FloatingContentRGB
    c14v6 = c14v6.g
    c14v7 = u2
    c14v7 = c14v7.FloatingContentRGB
    c14v7 = c14v7.b
    c14v8 = 1
    c14v1:Name__e243d995(c14v3, c14v4, c14v5, c14v6, c14v7, c14v8)
    c14v1 = mMovie
    c14v5 = ".ProgressBar.RightFill"
    c14v3 = c14v0 .. c14v5
    c14v4 = "RectEdgeColor"
    c14v5 = 0
    c14v6 = 0
    c14v7 = 0
    c14v8 = 0
    c14v1:Name__e243d995(c14v3, c14v4, c14v5, c14v6, c14v7, c14v8)
    c14v1 = mMovie
    c14v5 = ".ProgressBar.Bg"
    c14v3 = c14v0 .. c14v5
    c14v4 = "RectInnerColor"
    c14v5 = u2
    c14v5 = c14v5.Background1RGB
    c14v5 = c14v5.r
    c14v6 = u2
    c14v6 = c14v6.Background1RGB
    c14v6 = c14v6.g
    c14v7 = u2
    c14v7 = c14v7.Background1RGB
    c14v7 = c14v7.b
    c14v8 = 1
    c14v1:Name__e243d995(c14v3, c14v4, c14v5, c14v6, c14v7, c14v8)
    c14v1 = mMovie
    c14v5 = ".ProgressBar.Bg"
    c14v3 = c14v0 .. c14v5
    c14v4 = "RectEdgeColor"
    c14v5 = u2
    c14v5 = c14v5.FloatingContentRGB
    c14v5 = c14v5.r
    c14v6 = u2
    c14v6 = c14v6.FloatingContentRGB
    c14v6 = c14v6.g
    c14v7 = u2
    c14v7 = c14v7.FloatingContentRGB
    c14v7 = c14v7.b
    c14v8 = 1
    c14v1:Name__e243d995(c14v3, c14v4, c14v5, c14v6, c14v7, c14v8)
    c14v1 = mMovie
    c14v4 = "Progress"
    c14v5 = 44
    c14v6 = u2
    c14v6 = c14v6.Content
    c14v1:Name__52c1b74e(c14v0, c14v4, c14v5, c14v6)
    c14v1 = mMovie
    c14v4 = "LRewards"
    c14v5 = 44
    c14v6 = u2
    c14v6 = c14v6.Content
    c14v1:Name__52c1b74e(c14v0, c14v4, c14v5, c14v6)
    c14v1 = mMovie
    c14v4 = "RRewards"
    c14v5 = 44
    c14v6 = u2
    c14v6 = c14v6.Content
    c14v1:Name__52c1b74e(c14v0, c14v4, c14v5, c14v6)
    do return end
  end
  v2.UpdateColor = v3
  v2 = u0
  v3 = function(c15v0, c15v1)
    local c15v2, c15v4, c15v5, c15v6
    c15v2 = u0
    c15v2 = c15v2.UpdateColor
    c15v2(c15v0)
    c15v2 = mMovie
    c15v6 = ".ProgressBar.LeftFill"
    c15v4 = c15v0 .. c15v6
    c15v5 = _G
    c15v5 = c15v5.UIMaterial_RectangleNoDepth
    c15v2:OverrideMaterial(c15v4, c15v5)
    c15v2 = mMovie
    c15v6 = ".ProgressBar.RightFill"
    c15v4 = c15v0 .. c15v6
    c15v5 = _G
    c15v5 = c15v5.UIMaterial_RectangleNoDepth
    c15v2:OverrideMaterial(c15v4, c15v5)
    c15v2 = mMovie
    c15v6 = ".ProgressBar.Bg"
    c15v4 = c15v0 .. c15v6
    c15v5 = _G
    c15v5 = c15v5.UIMaterial_RectangleNoDepth
    c15v2:OverrideMaterial(c15v4, c15v5)
    do return end
  end
  v2.mClipCreatedCallback = v3
  v2 = u0
  v3 = function(c16v0)
    local c16v1, c16v2, c16v3, c16v4, c16v5, c16v6, c16v7, c16v8, c16v9, c16v10, c16v11, c16v12, c16v13, c16v14
    c16v1 = mMovie
    c16v3 = c16v0.Node
    c16v3 = c16v3:c_str()
    c16v4 = false
    c16v1 = c16v1:GetLocalized(c16v3, c16v4)
    c16v2 = c16v0.CustomEntry
    if not c16v2 then
      c16v2 = "<p><font size=\"19\"><b>"
      c16v4 = "</b></font></p>"
      c16v1 = c16v2 .. c16v1 .. c16v4
    end
    c16v2 = mMovie
    c16v4 = c16v0.mClipName
    c16v5 = "Title"
    c16v6 = 36
    c16v2:Name__f4a9016a(c16v4, c16v5, c16v6, c16v1)
    c16v2 = mMovie
    c16v4 = c16v0.mClipName
    c16v5 = "Title"
    c16v6 = 45
    c16v7 = u1
    c16v7 = c16v7.Ternary
    c16v8 = c16v0.CustomEntry
    c16v9 = "left"
    c16v10 = "center"
    c16v2:Name__f4a9016a(c16v4, c16v5, c16v6, c16v7(c16v8, c16v9, c16v10))
    c16v2 = mMovie
    c16v4 = c16v0.mClipName
    c16v5 = "Title"
    c16v6 = 0
    c16v7 = u1
    c16v7 = c16v7.Ternary
    c16v8 = c16v0.CustomEntry
    c16v9 = 2
    c16v10 = 115
    c16v2:Name__52c1b74e(c16v4, c16v5, c16v6, c16v7(c16v8, c16v9, c16v10))
    c16v2 = mMovie
    c16v4 = c16v0.mClipName
    c16v5 = "Title"
    c16v6 = 1
    c16v7 = u1
    c16v7 = c16v7.Ternary
    c16v8 = c16v0.CustomEntry
    c16v9 = 45
    c16v10 = 0
    c16v2:Name__52c1b74e(c16v4, c16v5, c16v6, c16v7(c16v8, c16v9, c16v10))
    c16v2 = mMovie
    c16v4 = c16v0.mClipName
    c16v5 = "Title"
    c16v6 = 44
    c16v7 = u1
    c16v7 = c16v7.Ternary
    c16v8 = c16v0.CustomEntry
    c16v9 = u0
    c16v9 = c16v9.FloatingContentHighlight
    c16v10 = u0
    c16v10 = c16v10.FloatingContent
    c16v2:Name__52c1b74e(c16v4, c16v5, c16v6, c16v7(c16v8, c16v9, c16v10))
    c16v2 = false
    c16v3 = c16v0.Delta
    if c16v3 ~= nil then
      c16v2 = false
      c16v3 = c16v0.Delta
      if c16v3 ~= 0 then
        c16v3 = c16v0.HideProgress
        c16v2 = not c16v3
      end
    end
    c16v3 = mMovie
    c16v5 = c16v0.mClipName
    c16v6 = "Progress"
    c16v7 = 13
    c16v3:Makeposshield(c16v5, c16v6, c16v7, c16v2)
    if c16v2 then
      c16v3 = 0
      c16v4 = mMovie
      c16v6 = c16v0.mClipName
      c16v7 = "Progress"
      c16v8 = 36
      c16v14 = c16v0.Delta
      c16v13 = tostring
      c16v10 = c16v13(c16v14)
      c16v11 = "/"
      c16v13 = 3
      c16v12 = tostring
      c16v12 = c16v12(c16v13)
      c16v9 = c16v10 .. c16v11 .. c16v12
      c16v4:Name__f4a9016a(c16v6, c16v7, c16v8, c16v9)
      c16v4 = mMovie
      c16v6 = c16v0.mClipName
      c16v7 = "Progress"
      c16v8 = 45
      c16v9 = u1
      c16v9 = c16v9.Ternary
      c16v10 = c16v0.SupportAttacker
      c16v11 = "left"
      c16v12 = "right"
      c16v4:Name__f4a9016a(c16v6, c16v7, c16v8, c16v9(c16v10, c16v11, c16v12))
      c16v4 = c16v0.SupportAttacker
      if not c16v4 then
        c16v4 = mMovie
        c16v7 = c16v0.mClipName
        c16v8 = ".Progress"
        c16v6 = c16v7 .. c16v8
        c16v7 = 14
        c16v4 = c16v4:GetNumberVariable(c16v6, c16v7)
        c16v5 = u0
        c16v5 = c16v5.BarWidth
        c16v3 = c16v5 - c16v4
      end
      c16v4 = mMovie
      c16v6 = c16v0.mClipName
      c16v7 = "Progress"
      c16v8 = 0
      c16v4:Name__52c1b74e(c16v6, c16v7, c16v8, c16v3)
    end
    c16v3 = c16v0.CustomEntry
    if c16v3 then
      c16v3 = mMovie
      c16v5 = c16v0.mClipName
      c16v6 = "ProgressBar.LeftFill"
      c16v7 = 14
      c16v8 = 0.001
      c16v3:Name__52c1b74e(c16v5, c16v6, c16v7, c16v8)
      c16v3 = Clamp
      c16v5 = u0
      c16v5 = c16v5.BarWidth
      c16v6 = c16v0.Delta
      c16v4 = c16v5 * c16v6
      c16v5 = 0.001
      c16v6 = u0
      c16v6 = c16v6.BarWidth
      c16v3 = c16v3(c16v4, c16v5, c16v6)
      c16v4 = mMovie
      c16v6 = c16v0.mClipName
      c16v7 = "ProgressBar.RightFill"
      c16v8 = 14
      c16v4:Name__52c1b74e(c16v6, c16v7, c16v8, c16v3)
      c16v4 = mMovie
      c16v6 = c16v0.mClipName
      c16v7 = "ProgressBar.RightFill"
      c16v8 = 0
      c16v4:Name__52c1b74e(c16v6, c16v7, c16v8, c16v3)
    else
      c16v4 = c16v0.Count
      c16v5 = c16v0.Goal
      c16v7 = 50
      c16v9 = c16v4 / c16v5
      c16v8 = c16v9 * 50
      c16v6 = c16v7 + c16v8
      c16v7 = u1
      c16v7 = c16v7.AttackerFaction
      c16v8 = 2
      if c16v7 == c16v8 then
        c16v7 = 100
        c16v9 = c16v4 / c16v5
        c16v8 = c16v9 * 100
        c16v6 = c16v7 + c16v8
      end
      c16v3 = c16v6
      c16v5 = u0
      c16v5 = c16v5.BarWidth
      c16v6 = c16v3 / 100
      c16v4 = c16v5 * c16v6
      c16v5 = mMovie
      c16v7 = c16v0.mClipName
      c16v8 = "ProgressBar.LeftFill"
      c16v9 = 14
      c16v10 = Clamp
      c16v11 = c16v4 + 2
      c16v12 = 0.001
      c16v13 = u0
      c16v13 = c16v13.BarWidth
      c16v5:Name__52c1b74e(c16v7, c16v8, c16v9, c16v10(c16v11, c16v12, c16v13))
      c16v5 = mMovie
      c16v7 = c16v0.mClipName
      c16v8 = "ProgressBar.RightFill"
      c16v9 = 14
      c16v10 = Clamp
      c16v13 = u0
      c16v13 = c16v13.BarWidth
      c16v12 = c16v13 - c16v4
      c16v11 = c16v12 + 2
      c16v12 = 0.001
      c16v13 = u0
      c16v13 = c16v13.BarWidth
      c16v5:Name__52c1b74e(c16v7, c16v8, c16v9, c16v10(c16v11, c16v12, c16v13))
      c16v5 = mMovie
      c16v7 = c16v0.mClipName
      c16v8 = "ProgressBar.RightFill"
      c16v9 = 0
      c16v10 = u0
      c16v10 = c16v10.BarWidth
      c16v5:Name__52c1b74e(c16v7, c16v8, c16v9, c16v10)
    end
    c16v3 = mMovie
    c16v5 = c16v0.mClipName
    c16v6 = "ProgressBar.Bg"
    c16v7 = 14
    c16v8 = u0
    c16v8 = c16v8.BarWidth
    c16v3:Name__52c1b74e(c16v5, c16v6, c16v7, c16v8)
    c16v4 = c16v0.AttackerReward
    c16v3 = IsNull
    c16v3 = c16v3(c16v4)
    if not c16v3 then
      c16v4 = c16v0.DefenderReward
      c16v3 = IsNull
      c16v3 = c16v3(c16v4)
      if not c16v3 then
        c16v3 = TitleCase
        c16v4 = u4
        c16v4 = c16v4.GetRewardDesc
        c16v5 = mMovie
        c16v6 = c16v0.AttackerReward
        c16v3 = c16v3(c16v4(c16v5, c16v6))
        c16v4 = TitleCase
        c16v5 = u4
        c16v5 = c16v5.GetRewardDesc
        c16v6 = mMovie
        c16v7 = c16v0.DefenderReward
        c16v4 = c16v4(c16v5(c16v6, c16v7))
        c16v5 = u1
        c16v5 = c16v5.FitTextIntoLines
        c16v6 = mMovie
        c16v8 = c16v0.mClipName
        c16v9 = ".LRewards"
        c16v7 = c16v8 .. c16v9
        c16v8 = 2
        c16v10 = "..."
        c16v5(c16v6, c16v7, c16v8, c16v3, c16v10)
        c16v5 = u1
        c16v5 = c16v5.FitTextIntoLines
        c16v6 = mMovie
        c16v8 = c16v0.mClipName
        c16v9 = ".RRewards"
        c16v7 = c16v8 .. c16v9
        c16v8 = 2
        c16v10 = "..."
        c16v5(c16v6, c16v7, c16v8, c16v4, c16v10)
        do return end
      end
    end
    c16v3 = mMovie
    c16v5 = c16v0.mClipName
    c16v6 = "LRewards"
    c16v7 = 36
    c16v8 = ""
    c16v3:Name__f4a9016a(c16v5, c16v6, c16v7, c16v8)
    c16v3 = mMovie
    c16v5 = c16v0.mClipName
    c16v6 = "RRewards"
    c16v7 = 36
    c16v8 = ""
    c16v3:Name__f4a9016a(c16v5, c16v6, c16v7, c16v8)
    do return end
  end
  v2.mElementDrawCallback = v3
  do return end
end

function proto_49()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8
  v0 = _T
  v3 = _T.ItemInfoPopupCount
  v2 = v3 or 0
  v1 = v2 + 1
  v0.ItemInfoPopupCount = v1
  v0 = _T.ItemInfoStatComparison
  if v0 == nil then
    v0 = _T
    v1 = u0
    v0.ItemInfoStatComparison = v1
  end
  v0 = mMovie
  v2 = false
  v0:SetVisible(v2)
  v0 = mMovie
  v2 = true
  v0:SetIgnoreInput(v2)
  v0 = mMovie
  v2 = false
  v0:SetForcedInput(v2)
  v0 = mMovie
  v2 = true
  v0:Name__f7d22364(v2)
  v0 = require
  v1 = "Lotus.Interface.Libs.TimerMgr"
  v0 = v0(v1)
  v1 = v0.CreateTimerMgr
  v1 = v1()
  u1 = v1
  v1 = _T
  v2 = u2
  v1.ShowItemInfoPopupCursor = v2
  v1 = u4
  v1 = v1.GetRegularCreditsStoreItem
  v1 = v1()
  u3 = v1
  v1 = mMovie
  v3 = "Popup.Bg"
  v4 = midBgTexture
  v5 = midBgMaterial
  v1:Name__9c27ee88(v3, v4, v5)
  v1 = u4
  v1 = v1.DrawSeparator
  v2 = mMovie
  v3 = "Popup.TagSeparator"
  v4 = 330
  v1(v2, v3, v4)
  v1 = u4
  v1 = v1.DrawSeparator
  v2 = mMovie
  v3 = "Popup.PrereqSeparator.Separator"
  v4 = 330
  v1(v2, v3, v4)
  v1 = u4
  v1 = v1.DrawSeparator
  v2 = mMovie
  v3 = "Popup.IngredientsSeparator.Separator"
  v4 = 330
  v1(v2, v3, v4)
  v1 = u4
  v1 = v1.DrawSeparator
  v2 = mMovie
  v3 = "Popup.AbilityInfo.PassiveSeparator"
  v4 = 330
  v1(v2, v3, v4)
  v1 = mMovie
  v3 = "Popup.AbilityInfo.Passive.Icon"
  v4 = passiveIcon
  v1:OverrideTexture(v3, v4)
  v1 = mMovie
  v3 = "Popup.Bg"
  v4 = "RectEdgeColor"
  v5 = 0
  v6 = 0
  v7 = 0
  v8 = 0
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v3 = "Popup.Bg"
  v4 = "RectInnerColor"
  v5 = 1
  v6 = 1
  v7 = 1
  v8 = 1
  v1:Name__e243d995(v3, v4, v5, v6, v7, v8)
  v1 = mMovie
  v3 = "Popup.Header.Fade"
  v4 = _G
  v4 = v4.UIMaterial_RectangleNoDepth
  v1:OverrideMaterial(v3, v4)
  v1 = mMovie
  v3 = "Popup.Header.Bg"
  v4 = _G
  v4 = v4.UIMaterial_RectangleNoDepth
  v1:OverrideMaterial(v3, v4)
  v1 = mMovie
  v3 = "Popup.TitleBg"
  v4 = _G
  v4 = v4.UIMaterial_RectangleNoDepth
  v1:OverrideMaterial(v3, v4)
  v1 = mMovie
  v3 = "Popup.TitleBg"
  v4 = 14
  v1 = v1:GetNumberVariable(v3, v4)
  u5 = v1
  v1 = Engine.IsMobile
  v1 = v1()
  if v1 then
    v1 = mMovie
    v3 = "Popup.TitleBg"
    v4 = nil
    v5 = nil
    v6 = nil
    v7 = "OnPopupTitleBgPressed"
    v1:SetCallbacks(v3, v4, v5, v6, v7)
  end
  v1 = u6
  v1()
  v1 = u7
  v1()
  v1 = u8
  v1()
  v1 = u9
  v1()
  v1 = u10
  v1()
  v1 = u11
  v1()
  v1 = u12
  v1()
  v1 = u13
  v1()
  v1 = require
  v2 = "Lotus.Interface.Components.ThemedSpinner"
  v1 = v1(v2)
  v2 = v1.Create
  v3 = mMovie
  v4 = "Popup.Spinner"
  v2 = v2(v3, v4)
  u14 = v2
  v2 = gPlayerProfileMgr
  v2 = v2:IsLoggedIn()
  if v2 then
    v2 = ObjectPortHandler
    v3 = gPlayerProfileMgr
    v5 = 0
    v3 = v3:GetPlayerProfile(v5)
    v3 = v3:GetGameSpecificData()
    v4 = "OnProfileSaved"
    v2(v3, v4)
  end
  v3 = { AbilityResource = nil, Images = nil, PageCallout = "/Lotus/Language/Suits/PagemasterFinalChapterTabCallout" }
  v4 = u16
  v3.AbilityResource = v4
  v4 = pagemasterFinalChapterAdditionalImages
  v3.Images = v4
  v2 = {v3}
  u15 = v2
  do return end
end

function proto_50(v0)
  local v1, v2, v3, v4, v5, v6, v7
  if v0 == nil then
    v0 = 1
  end
  v1 = "Popup.TagContainer.Tag1"
  v2 = 1
  while true do
    v3 = mMovie
    v3 = v3:HasVariable(v1)
    if not v3 then
      do return end
    end
    v3 = mMovie
    v5 = v1
    v6 = 13
    if v0 <= v2 then
      v7 = false
    else
      v7 = true
    end
    v3:Name__d9713943(v5, v6, v7)
    v2 = v2 + 1
    v3 = "Popup.TagContainer.Tag"
    v4 = tostring
    v4 = v4(v2)
    v1 = v3 .. v4
  end
end

function proto_51(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8
  v1 = u0
  v4 = u1
  v3 = v1 - v4
  v2 = v3 - v0
  v3 = 0
  if v2 <= v3 then
    v1 = v1 - 7
  end
  v3 = mMovie
  v5 = "Popup.Header.Bg"
  v6 = 15
  v8 = u2
  v7 = v1 + v8
  v3:SetNumberVariable(v5, v6, v7)
  v3 = mMovie
  v5 = "Popup.TitleBg"
  v6 = 15
  v3:SetNumberVariable(v5, v6, v1)
  v3 = mMovie
  v5 = "Popup.Bg"
  v6 = 13
  v8 = 0
  if v2 <= v8 then
    v7 = false
  else
    v7 = true
  end
  v3:Name__d9713943(v5, v6, v7)
  v3 = mMovie
  v5 = "Popup.Bg"
  v6 = 15
  v8 = 1
  v7 = math.max
  v7 = v7(v8, v2)
  v3:SetNumberVariable(v5, v6, v7)
  v3 = mMovie
  v5 = "Popup.Bg"
  v6 = 1
  v7 = u1
  v3:SetNumberVariable(v5, v6, v7)
  v3 = mMovie
  v5 = "Popup.PreviewTag"
  v6 = 1
  v8 = v0 - 6
  v7 = v1 - v8
  v3:SetNumberVariable(v5, v6, v7)
  v3 = mMovie
  v5 = "Popup.PreviewCallout"
  v6 = 1
  v8 = v0 - 6
  v7 = v1 - v8
  v3:SetNumberVariable(v5, v6, v7)
  v3 = mMovie
  v5 = "Popup.Blurer"
  v6 = 15
  v3:SetNumberVariable(v5, v6, v1)
  v3 = mMovie
  v5 = "Popup.SelectButton"
  v6 = 1
  v8 = v0 - 18
  v7 = v1 - v8
  v3:SetNumberVariable(v5, v6, v7)
  do return end
end

function proto_52(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17
  u0 = v0
  v1 = u1
  v1:SetActive(v0)
  v2 = "Description"
  v3 = "AbilityInfo"
  v4 = "ItemStats"
  v5 = "TagSeparator"
  v6 = "Ingredients"
  v7 = "IngredientsSeparator"
  v8 = "IngredientsSecondary"
  v9 = "PrereqSeparator"
  v10 = "Prerequisite"
  v11 = "RankedProgress"
  v12 = "RarityBar"
  v13 = "Affiliation1"
  v14 = "VideoPreview"
  v15 = "ExtraDesc"
  v16 = "CrewMemberInfo"
  v17 = "Invasion"
  v1 = {v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17}
  v2 = u2
  v2()
  v2 = pairs
  v2, v3, v4 = v2(v1)
  for v5, v6 in v2, v3, v4 do
    v7 = mMovie
    v9 = "Popup"
    v11 = 13
    v12 = false
    v7:Makeposshield(v9, v6, v11, v12)
  end
  v2 = u3
  if v2 == 0 then
    v2 = 120
    u3 = v2
    v2 = u4
    v3 = 9
    v2(v3)
  end
  v2 = mMovie
  v4 = "Popup.Spinner"
  v5 = 1
  v7 = u5
  v10 = u3
  v11 = u5
  v9 = v10 - v11
  v8 = v9 / 2
  v6 = v7 + v8
  v2:SetNumberVariable(v4, v5, v6)
  for v5, v6 in v2, v3, v4 do
  end
  do return end
end

function proto_53()
  local v0
  v0 = true
  u0 = v0
  do return end
end

function proto_54(v0)
  local v1, v2, v3, v4
  v1 = u0
  if v1 then
    v2 = gGameData
    v1 = IsNull
    v1 = v1(v2)
    if not v1 then
      v1 = false
      u0 = v1
      v1 = u1
      v3 = 5
      v4 = function()
        local c17v0
        c17v0 = true
        u0 = c17v0
        do return end
      end
      v1:AddTimer(v3, v4)
      v1 = {}
      u2 = v1
      v1 = gGameData
      v1 = v1:GetInventory()
      v2 = IsNull
      v2 = v2(v1)
      if not v2 then
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetSuits())
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetLongGuns())
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetPistols())
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetMelee())
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetSpaceSuits())
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetSpaceGuns())
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetSpaceMelee())
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetConsumables())
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetRecipes())
        v2 = u3
        v2 = v2.AddTableToPurchasedItems
        v3 = u2
        v2(v3, v1:GetWeaponSkins())
        if v0 then
          v2 = u3
          v2 = v2.AddTableToPurchasedItems
          v3 = u2
          v2(v3, v1:GetUpgrades())
          v2 = u3
          v2 = v2.AddTableToPurchasedItems
          v3 = u2
          v2(v3, v1:GetRawUpgrades())
        end
      end
    end
  end
  do return end
end

function proto_55(v0)
  local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14
  local p113 = 0
  if p113 == 0 then
    v1 = u0
    v3 = true
    v4 = true
    v1:RemoveElements(v3, v4)
    v1 = u0
    v2 = false
    v1.mAbilitiesAvailable = v2
    v1 = u0
    v2 = false
    v1.mStatsAvailable = v2
    v1 = u0
    v2 = false
    v1.mLeaveRoom = v2
    v1 = 1
    v2 = u1
    v2 = v2.NumItemPopupPages
    if not v2 then
      p113 = 2
    else
      p113 = 1
    end
  end
  if p113 == 1 then
    v3 = u1
    v3 = v3.NumItemPopupPages
    v2 = math.max
    v1 = v2(v3, v1)
    p113 = 2
  end
  if p113 == 2 then
    v2 = u1
    v2 = v2.Hints
    if not v2 then
      p113 = 4
    else
      p113 = 3
    end
  end
  if p113 == 3 then
    v4 = u1
    v4 = v4.Hints
    v3 = #v4
    v2 = math.max
    v1 = v2(v3, v1)
    p113 = 4
  end
  if p113 == 4 then
    v2 = u1
    v2 = v2.AreStatsBuried
    if not v2 then
      p113 = 6
    else
      p113 = 5
    end
  end
  if p113 == 5 then
    v1 = v1 + 1
    p113 = 6
  end
  if p113 == 6 then
    v4 = 1
    v2 = v1
    v3 = 1
    if (v3 > 0 and v4 > v2) or (v3 < 0 and v4 < v2) then
      p113 = 8
    else
      p113 = 7
    end
  end
  if p113 == 7 then
    v5 = u0
    v7 = { State = nil }
    v8 = u2
    v8 = v8.BASE
    v7.State = v8
    v8 = true
    v5:AddElement(v7, v8)
    p113 = 8
  end
  if p113 == 8 then
    if v0 == nil then
      p113 = 12
    else
      p113 = 9
    end
  end
  if p113 == 9 then
    v2 = v0.AdditionalTabInfo
    if v2 == nil then
      p113 = 12
    else
      p113 = 10
    end
  end
  if p113 == 10 then
    v3 = v0.AdditionalTabInfo
    v4 = u1
    v3 = v3(v4)
    v2 = #v3
    v3 = 0
    if v2 <= v3 then
      p113 = 12
    else
      p113 = 11
    end
  end
  if p113 == 11 then
    v2 = u0
    v4 = { State = nil }
    v5 = u2
    v5 = v5.INFO
    v4.State = v5
    v5 = true
    v2:AddElement(v4, v5)
    p113 = 12
  end
  if p113 == 12 then
    v2 = u1
    v2 = v2.TimeRemaining
    if v2 == nil then
      p113 = 15
    else
      p113 = 13
    end
  end
  if p113 == 13 then
    v2 = u1
    v2 = v2.HideRecipe
    if v2 then
      p113 = 15
    else
      p113 = 14
    end
  end
  if p113 == 14 then
    v2 = u0
    v4 = { State = nil }
    v5 = u2
    v5 = v5.CRAFTING
    v4.State = v5
    v5 = true
    v2:AddElement(v4, v5)
    p113 = 15
  end
  if p113 == 15 then
    v2 = u1
    v2 = v2.mIsNemesis
    v3 = u1
    v3 = v3.ResultStoreItem
    if v3 then
      p113 = 17
    else
      p113 = 16
    end
  end
  if p113 == 16 then
    v3 = u1
    v3 = v3.StoreItem
    p113 = 17
  end
  if p113 == 17 then
    if v2 then
      p113 = 19
    else
      p113 = 18
    end
  end
  if p113 == 18 then
    v4 = IsNull
    v4 = v4(v3)
    if v4 then
      p113 = 60
    else
      p113 = 19
    end
  end
  if p113 == 19 then
    v4 = IsNull
    v4 = v4(v3)
    if v4 then
      p113 = 23
    else
      p113 = 20
    end
  end
  if p113 == 20 then
    v4 = IsNull
    v4 = v4(v3:GetItem())
    if v4 then
      p113 = 23
    else
      p113 = 21
    end
  end
  if p113 == 21 then
    v4 = v3:GetItem()
    v6 = Name__d7185637
    v4 = v4:IsA(v6)
    if not v4 then
      p113 = 23
    else
      p113 = 22
    end
  end
  if p113 == 22 then
    v4 = u0
    v5 = true
    v4.mLeaveRoom = v5
    p113 = 23
  end
  if p113 == 23 then
    v4 = nil
    v5 = IsNull
    v5 = v5(v3)
    if v5 then
      p113 = 25
    else
      p113 = 24
    end
  end
  if p113 == 24 then
    v4 = v3:GetProductCategory()
    p113 = 25
  end
  if p113 == 25 then
    v5 = v2
    if v5 then
      p113 = 31
    else
      p113 = 26
    end
  end
  if p113 == 26 then
    v5 = true
    v6 = 3
    if v4 == v6 then
      p113 = 31
    else
      p113 = 27
    end
  end
  if p113 == 27 then
    v5 = true
    v6 = 27
    if v4 == v6 then
      p113 = 31
    else
      p113 = 28
    end
  end
  if p113 == 28 then
    v6 = 48
    if v4 == v6 then
      p113 = 30
    else
      p113 = 29
    end
  end
  if p113 == 29 then
    v5 = false
    p113 = 31
  end
  if p113 == 30 then
    v5 = true
    p113 = 31
  end
  if p113 == 31 then
    v6 = true
    v7 = 0
    if v4 == v7 then
      p113 = 41
    else
      p113 = 32
    end
  end
  if p113 == 32 then
    v6 = true
    v7 = 1
    if v4 == v7 then
      p113 = 41
    else
      p113 = 33
    end
  end
  if p113 == 33 then
    v6 = true
    v7 = 5
    if v4 == v7 then
      p113 = 41
    else
      p113 = 34
    end
  end
  if p113 == 34 then
    v6 = true
    v7 = 28
    if v4 == v7 then
      p113 = 41
    else
      p113 = 35
    end
  end
  if p113 == 35 then
    v6 = true
    v7 = 29
    if v4 == v7 then
      p113 = 41
    else
      p113 = 36
    end
  end
  if p113 == 36 then
    v6 = true
    v7 = 37
    if v4 == v7 then
      p113 = 41
    else
      p113 = 37
    end
  end
  if p113 == 37 then
    v6 = true
    v7 = 16
    if v4 == v7 then
      p113 = 41
    else
      p113 = 38
    end
  end
  if p113 == 38 then
    v7 = 43
    if v4 == v7 then
      p113 = 40
    else
      p113 = 39
    end
  end
  if p113 == 39 then
    v6 = false
    p113 = 41
  end
  if p113 == 40 then
    v6 = true
    p113 = 41
  end
  if p113 == 41 then
    v7 = true
    v8 = 15
    if v4 == v8 then
      p113 = 45
    else
      p113 = 42
    end
  end
  if p113 == 42 then
    v8 = 39
    if v4 == v8 then
      p113 = 44
    else
      p113 = 43
    end
  end
  if p113 == 43 then
    v7 = false
    p113 = 45
  end
  if p113 == 44 then
    v7 = true
    p113 = 45
  end
  if p113 == 45 then
    v8 = u0
    v9 = v5
    if not v9 then
      p113 = 47
    else
      p113 = 46
    end
  end
  if p113 == 46 then
    v10 = u1
    v10 = v10.HideAbilities
    v9 = not v10
    p113 = 47
  end
  if p113 == 47 then
    v8.mAbilitiesAvailable = v9
    v8 = u0
    if (v5 or v6) then
      p113 = 50
    else
      p113 = 49
    end
  end
  if p113 == 49 then
    v9 = v7
    if not v9 then
      p113 = 51
    else
      p113 = 50
    end
  end
  if p113 == 50 then
    v10 = u1
    v10 = v10.HideStats
    v9 = not v10
    p113 = 51
  end
  if p113 == 51 then
    v8.mStatsAvailable = v9
    v8 = u0
    v8 = v8.mAbilitiesAvailable
    if v8 then
      v8 = u1
      v8 = v8.AllInOne
      if not v8 then
        v8 = u0
        v10 = { State = nil }
        v11 = u2
        v11 = v11.ABILITIES
        v10.State = v11
        v11 = true
        v8:AddElement(v10, v11)
        v8 = IsNull
        v8 = v8(v3)
        if not v8 then
          v8 = IsNull
          v8 = v8(v3:GetItem())
          if not v8 then
            v8 = v3:GetItem()
            v10 = u3
            v10 = v10.Sirius
            v8 = v8:IsA(v10)
            if v8 then
              v8 = u0
              v10 = { State = nil, SuitOverride = nil }
              v11 = u2
              v11 = v11.ABILITIES
              v10.State = v11
              v11 = u3
              v11 = v11.Orion
              v10.SuitOverride = v11
              v11 = true
              v8:AddElement(v10, v11)
              v8 = u0
              v10 = u3
              v10 = v10.Orion
              v9 = {v10}
              v8.mExtraLoad = v9
            end
          end
        end
      end
    end
    v8 = u0
    v8 = v8.mStatsAvailable
    if v8 then
      v10 = u4
      v10 = v10.Ternary
      v11 = u1
      v11 = v11.AllInOne
      v12 = 2
      v13 = 1
      v10 = v10(v11, v12, v13)
      v8 = u5
      v9 = 1
      for v10 = v10, v8, v9 do
        v11 = u0
        v13 = { State = nil, StatId = nil }
        v14 = u2
        v14 = v14.STATS
        v13.State = v14
        v13.StatId = v10
        v14 = true
        v11:AddElement(v13, v14)
      end
    end
    p113 = 60
  end
  if p113 == 60 then
    v4 = u0
    v6 = nil
    v7 = nil
    v8 = true
    v4:Redraw(v6, v7, v8)
    v4 = u6
    v4()
    do return end
  end
end

function proto_56()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v15
  local p49 = 0
  if p49 == 0 then
    v0 = u0
    v1 = false
    u0 = v1
    v1 = ""
    v2 = true
    v4 = u1
    v4 = v4.mPrereqElement
    if v4 ~= nil then
      p49 = 2
    else
      p49 = 1
    end
  end
  if p49 == 1 then
    v3 = false
    p49 = 3
  end
  if p49 == 2 then
    v3 = true
    p49 = 3
  end
  if p49 == 3 then
    v4 = u1
    v4 = v4.StoreItem
    v5 = v4:IsPersonalGuildHybridResearch()
    v6 = ""
    v7 = u1
    v7 = v7.MetaData
    if v7 == nil then
      p49 = 27
    else
      p49 = 4
    end
  end
  if p49 == 4 then
    v7 = u1
    v7 = v7.MetaData
    v7 = v7.CheckResearch
    if not v7 then
      p49 = 27
    else
      p49 = 5
    end
  end
  if p49 == 5 then
    v7 = u2
    v8 = u3
    v8 = v8.CRAFTING
    if v7 == v8 then
      p49 = 27
    else
      p49 = 6
    end
  end
  if p49 == 6 then
    v7 = u1
    v7 = v7.Researched
    if v7 then
      p49 = 10
    else
      p49 = 7
    end
  end
  if p49 == 7 then
    v7 = u1
    v7 = v7.InProgress
    if v7 then
      p49 = 10
    else
      p49 = 8
    end
  end
  if p49 == 8 then
    if not v3 then
      p49 = 25
    else
      p49 = 9
    end
  end
  if p49 == 9 then
    v7 = u1
    v7 = v7.mPrereqElement
    v7 = v7.TimeRemaining
    v8 = 0
    if v7 < v8 then
      p49 = 25
    else
      p49 = 10
    end
  end
  if p49 == 10 then
    v2 = false
    if not v0 then
      p49 = 13
    else
      p49 = 11
    end
  end
  if p49 == 11 then
    v7 = u1
    v7 = v7.mCompletionDate
    if v7 == nil then
      p49 = 13
    else
      p49 = 12
    end
  end
  if p49 == 12 then
    v7 = u1
    v8 = Engine.Name__b38e1642
    v9 = u1
    v9 = v9.mCompletionDate
    v8 = v8(v9)
    v7.TimeRemaining = v8
    p49 = 13
  end
  if p49 == 13 then
    v7 = u1
    v7 = v7.TimeRemaining
    v8 = 0
    if v7 <= v8 then
      p49 = 15
    else
      p49 = 14
    end
  end
  if p49 == 14 then
    v7 = mMovie
    v9 = "/Lotus/Language/Dojo/ResearchStatusInProgress"
    v10 = false
    v1 = v7:GetLocalized(v9, v10)
    v7 = u4
    v7 = v7.SecondsToFormattedTime
    v8 = mMovie
    v9 = u1
    v9 = v9.TimeRemaining
    v10 = "Compact"
    v6 = v7(v8, v9, v10)
    v7 = true
    u0 = v7
    p49 = 32
  end
  if p49 == 15 then
    if not v3 then
      p49 = 18
    else
      p49 = 16
    end
  end
  if p49 == 16 then
    v7 = u1
    v7 = v7.Researched
    if v7 then
      p49 = 18
    else
      p49 = 17
    end
  end
  if p49 == 17 then
    v7 = mMovie
    v9 = "/Lotus/Language/Dojo/ResearchPrereqNeededHint"
    v10 = false
    v11 = { PREREQ = nil }
    v12 = u1
    v12 = v12.mPrereqElement
    v12 = v12.Name
    v11.PREREQ = v12
    v1 = v7:GetLocalized(v9, v10, v11)
    p49 = 32
  end
  if p49 == 18 then
    v7 = _T.ShowDojoColors
    if not v7 then
      p49 = 20
    else
      p49 = 19
    end
  end
  if p49 == 19 then
    v7 = mMovie
    v9 = "/Lotus/Language/Dojo/ResearchColorCompleteHint"
    v10 = false
    v1 = v7:GetLocalized(v9, v10)
    p49 = 32
  end
  if p49 == 20 then
    if not v5 then
      p49 = 22
    else
      p49 = 21
    end
  end
  if p49 == 21 then
    v7 = mMovie
    v9 = "/Lotus/Language/Railjack/ResearchCompleteHintFabrication"
    v10 = false
    v1 = v7:GetLocalized(v9, v10)
    p49 = 32
  end
  if p49 == 22 then
    v7 = u1
    v7 = v7.IsNpcDeco
    if not v7 then
      p49 = 24
    else
      p49 = 23
    end
  end
  if p49 == 23 then
    v7 = mMovie
    v9 = "/Lotus/Language/DojoDecosNpcs/NpcResearchCompleteHint"
    v10 = false
    v1 = v7:GetLocalized(v9, v10)
    p49 = 32
  end
  if p49 == 24 then
    v7 = mMovie
    v9 = "/Lotus/Language/Dojo/ResearchCompleteHint"
    v10 = false
    v1 = v7:GetLocalized(v9, v10)
    p49 = 32
  end
  if p49 == 25 then
    v7 = mMovie
    v9 = "/Lotus/Language/Dojo/ResearchRequirements"
    v10 = false
    v1 = v7:GetLocalized(v9, v10)
    if v5 then
      p49 = 32
    else
      p49 = 26
    end
  end
  if p49 == 26 then
    v7 = u4
    v7 = v7.SecondsToFormattedTime
    v8 = mMovie
    v9 = v4:GetResearchTime()
    v10 = "CompactHours"
    v6 = v7(v8, v9, v10)
    p49 = 32
  end
  if p49 == 27 then
    v7 = mMovie
    v9 = "/Lotus/Language/Menu/Store_RecipeComponents"
    v10 = false
    v1 = v7:GetLocalized(v9, v10)
    if not v5 then
      p49 = 29
    else
      p49 = 28
    end
  end
  if p49 == 28 then
    v7 = mMovie
    v9 = "/Lotus/Language/Railjack/FabricationRequirements"
    v10 = true
    v1 = v7:GetLocalized(v9, v10)
    p49 = 32
  end
  if p49 == 29 then
    v7 = u1
    v7 = v7.IsNpcDeco
    if not v7 then
      p49 = 31
    else
      p49 = 30
    end
  end
  if p49 == 30 then
    v7 = mMovie
    v9 = "/Lotus/Language/DojoDecosNpcs/NpcRecipeComponents"
    v10 = false
    v1 = v7:GetLocalized(v9, v10)
    p49 = 32
  end
  if p49 == 31 then
    v7 = u4
    v7 = v7.SecondsToFormattedTime
    v8 = mMovie
    v9 = v4:GetBuildTime()
    v10 = "CompactHours"
    v6 = v7(v8, v9, v10)
    p49 = 32
  end
  if p49 == 32 then
    v7 = #v6
    v8 = 0
    if v7 <= v8 then
      p49 = 34
    else
      p49 = 33
    end
  end
  if p49 == 33 then
    v7 = "<br>"
    v10 = mMovie
    v12 = "<TIMER> "
    v13 = true
    v8 = v10:GetLocalized(v12, v13)
    v6 = v7 .. v8 .. v6
    p49 = 34
  end
  if p49 == 34 then
    v7 = "<p><font color=\""
    v8 = u5
    v8 = v8.FloatingContentHex
    v9 = "\">"
    v11 = "<font color=\""
    v12 = u5
    v12 = v12.FloatingContentHighlightHex
    v13 = "\">"
    v15 = "</font></font></p>"
    v1 = v7 .. v8 .. v9 .. v1 .. v11 .. v12 .. v13 .. v6 .. v15
    v7 = mMovie
    v9 = "Popup.PrereqSeparator.Description"
    v10 = 36
    v7:SetStringVariable(v9, v10, v1)
    do return v2, v3 end
  end
end

function proto_57(v0)
  local v1, v2, v3, v4, v5
  v1 = v0.Type
  if v1 ~= nil then
    v1 = v0.Type
    v2 = u0
    v2 = v2.mItemType
    if v1 == v2 then
      v2 = u1
      v4 = v0.Req
      v5 = v0.Count
      v3 = math.min
      v3 = v3(v4, v5)
      v1 = v2 - v3
      u1 = v1
    end
  end
  do return end
end

function proto_58()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24
  local p110 = 0
  if p110 == 0 then
    v0 = u0
    v0 = v0.StoreItem
    v1 = gGameRules
    v1 = v1:GetStoreManifest()
    v2 = nil
    v3 = IsNull
    v3 = v3(v1)
    if v3 then
      p110 = 76
    else
      p110 = 1
    end
  end
  if p110 == 1 then
    v3 = u1
    v3, v4 = v3()
    v5 = u2
    v7 = true
    v8 = true
    v5:RemoveElements(v7, v8)
    v5 = u3
    v6 = false
    v5(v6)
    if not v3 then
      p110 = 75
    else
      p110 = 2
    end
  end
  if p110 == 2 then
    v6 = gGameData
    v5 = IsNull
    v5 = v5(v6)
    if v5 then
      p110 = 4
    else
      p110 = 3
    end
  end
  if p110 == 3 then
    v5 = gGameData
    v2 = v5:GetInventory()
    p110 = 4
  end
  if p110 == 4 then
    v5 = 0
    v6 = u0
    v6 = v6.MetaData
    if v6 == nil then
      p110 = 7
    else
      p110 = 5
    end
  end
  if p110 == 5 then
    v6 = u0
    v6 = v6.MetaData
    v6 = v6.GuildTier
    if v6 == nil then
      p110 = 7
    else
      p110 = 6
    end
  end
  if p110 == 6 then
    v6 = u0
    v6 = v6.MetaData
    v5 = v6.GuildTier
    p110 = 9
  end
  if p110 == 7 then
    v6 = gGameRules
    v8 = gLotusDojoGameRulesType
    v6 = v6:IsA(v8)
    if not v6 then
      p110 = 9
    else
      p110 = 8
    end
  end
  if p110 == 8 then
    v6 = gGameRules
    v5 = v6:GetGuildTier()
    p110 = 9
  end
  if p110 == 9 then
    v7 = u0
    v7 = v7.IsNpcDeco
    if not v7 then
      p110 = 11
    else
      p110 = 10
    end
  end
  if p110 == 10 then
    v6 = gGameData
    v6 = v6:GetGuildVault()
    p110 = 12
  end
  if p110 == 11 then
    v6 = nil
    p110 = 12
  end
  if p110 == 12 then
    v7 = false
    v8 = u0
    v8 = v8.MetaData
    if v8 == nil then
      p110 = 17
    else
      p110 = 13
    end
  end
  if p110 == 13 then
    v7 = u0
    v7 = v7.MetaData
    v7 = v7.CheckResearch
    if not v7 then
      p110 = 17
    else
      p110 = 14
    end
  end
  if p110 == 14 then
    v8 = u4
    v9 = u5
    v9 = v9.CRAFTING
    if v8 ~= v9 then
      p110 = 16
    else
      p110 = 15
    end
  end
  if p110 == 15 then
    v7 = false
    p110 = 17
  end
  if p110 == 16 then
    v7 = true
    p110 = 17
  end
  if p110 == 17 then
    if not v7 then
      p110 = 19
    else
      p110 = 18
    end
  end
  if p110 == 18 then
    v8 = v0:GetResearchIngredients()
    if v8 then
      p110 = 20
    else
      p110 = 19
    end
  end
  if p110 == 19 then
    v8 = v0:GetIngredients()
    p110 = 20
  end
  if p110 == 20 then
    v11 = 1
    v9 = #v8
    v10 = 1
    for v11 = v11, v9, v10 do
      v12 = v8[v11]
      v15 = v12.mItemType
      v13 = v1:Name__1dc35bd2(v15)
      v14 = IsNull
      v14 = v14(v13)
      v14 = 0
      v15 = u2
      v17 = function(c18v0)
        local c18v1, c18v2, c18v3, c18v4, c18v5
        c18v1 = c18v0.Type
        if c18v1 ~= nil then
          c18v1 = c18v0.Type
          c18v2 = v12
          c18v2 = c18v2.mItemType
          if c18v1 == c18v2 then
            c18v2 = v14
            c18v4 = c18v0.Req
            c18v5 = c18v0.Count
            c18v3 = math.min
            c18v3 = c18v3(c18v4, c18v5)
            c18v1 = c18v2 - c18v3
            v14 = c18v1
          end
        end
        do return end
      end
      v15:RunForAllElements(v17)
      v15 = 0
      v16 = v6.mMiscItems
      v19 = 1
      v17 = #v16
      v18 = 1
      for v19 = v19, v17, v18 do
        v20 = v16[v19]
        v20 = v20.mItemType
        v21 = v12.mItemType
        if v20 == v21 then break end
      end
      v20 = v16[v19]
      v15 = v20.mItemCount
      v17 = u6
      v18 = v12.mItemType
      v18 = v18:GetFullName()
      v16 = v17[v18]
      v17 = u6
      v18 = v12.mItemType
      v18 = v18:GetFullName()
      v16 = v17[v18]
      v16 = v16.Count
      v17 = u6
      v18 = v12.mItemType
      v18 = v18:GetFullName()
      v16 = v17[v18]
      v15 = v16.Count
      v14 = v14 + v15
      v16 = u7
      v16 = v16.GetStoreItemInfo
      v17 = mMovie
      v19 = nil
      v20 = nil
      v21 = nil
      v22 = true
      v16 = v16(v17, v13, v19, v20, v21, v22)
      v17 = v12.mItemCount
      v16.Req = v17
      v17 = 0
      v18 = u0
      v18 = v18.IsNpcDeco
      v18 = gGameConfig
      v20 = nil
      v21 = v16.Req
      v23 = true
      v18 = v18:Name__4edc466d(v20, v21, v5, v23)
      v16.Req = v18
      v18 = u0
      v18 = v18.mTechItem
      v21 = 1
      v22 = v18.mReqItems
      v19 = #v22
      v20 = 1
      v16 = IsNull
      v16 = v16(v2)
      if not v16 then
        v18 = v12.mItemType
        v15 = v2:Name__2f311bf1(v18)
      end
      v23 = v18.mReqItems
      v22 = v23[v21]
      v22 = v22.mItemType
      v23 = v12.mItemType
      if v22 == v23 then
        v22 = v16.Req
        v24 = v18.mReqItems
        v23 = v24[v21]
        v23 = v23.mItemCount
        v17 = v22 - v23
      end
      v18 = v12.mItemType
      v20 = gLotusWeaponType
      v18 = v18:IsA(v20)
      if v18 then
        v18 = Clamp
        v20 = 0
        v21 = v12.mItemCount
        v14 = v18(v14, v20, v21)
      else
        v20 = 0
        v18 = math.max
        v14 = v18(v14, v20)
      end
      if not v18 then
        v18 = v16.Req
        if v17 < v18 then
          v18 = true
          v16.mIncomplete = v18
        end
        v20 = v16.Req
        v19 = v20 - v17
        if v14 < v19 then
          v18 = false
        else
          v18 = true
        end
        v16.mHasResources = v18
        v16.Count = v17
      else
        v19 = v16.Req
        if v19 <= v14 then
          v18 = false
        else
          v18 = true
        end
        v16.mIncomplete = v18
        v19 = v16.mIncomplete
        v18 = not v19
        v16.mHasResources = v18
        v16.Count = v14
      end
      v18 = u2
      v21 = true
      v18:AddElement(v16, v21)
    end
    local p106 = 56
    if p106 == 56 then
      if not v7 then
        p106 = 58
      else
        p106 = 57
      end
    end
    if p106 == 57 then
      v9 = v0:Name__aa50aeaf()
      if v9 then
        p106 = 59
      else
        p106 = 58
      end
    end
    if p106 == 58 then
      v9 = v0:GetBuildPrice()
      p106 = 59
    end
    if p106 == 59 then
      v10 = 0
      if v9 <= v10 then
      else
        p106 = 60
      end
    end
    if p106 == 60 then
      v10 = { Themed = true, Name = nil, Icon = nil }
      v11 = mMovie
      v13 = u8
      v13 = v13:GetLocalizeTag()
      v13 = v13:c_str()
      v14 = false
      v11 = v11:GetLocalized(v13, v14)
      v10.Name = v11
      v11 = u8
      v11 = v11:GetIconTexture()
      v10.Icon = v11
      v11 = 0
      if v7 then
        p106 = 62
      else
        p106 = 61
      end
    end
    if p106 == 61 then
      v12 = u0
      v12 = v12.IsNpcDeco
      if not v12 then
        p106 = 72
      else
        p106 = 62
      end
    end
    if p106 == 62 then
      v12 = gGameConfig
      v14 = nil
      v17 = true
      v9 = v12:Name__4edc466d(v14, v9, v5, v17)
      if not v7 then
        p106 = 70
      else
        p106 = 63
      end
    end
    if p106 == 63 then
      v12 = u0
      v12 = v12.mTechItem
      if not v12 then
        p106 = 70
      else
        p106 = 64
      end
    end
    if p106 == 64 then
      v12 = u0
      v12 = v12.mTechItem
      v12 = v12.mReqCredits
      v11 = v9 - v12
      if v9 <= v11 then
        p106 = 66
      else
        p106 = 65
      end
    end
    if p106 == 65 then
      v12 = true
      v10.mIncomplete = v12
      p106 = 66
    end
    if p106 == 66 then
      v13 = gGameData
      v13 = v13:GetRegularCredits()
      v14 = v9 - v11
      if v14 <= v13 then
        p106 = 68
      else
        p106 = 67
      end
    end
    if p106 == 67 then
      v12 = false
      p106 = 69
    end
    if p106 == 68 then
      v12 = true
      p106 = 69
    end
    if p106 == 69 then
      v10.mHasResources = v12
      p106 = 74
    end
    if p106 == 70 then
      v12 = u0
      v12 = v12.IsNpcDeco
      if not v12 then
        p106 = 74
      else
        p106 = 71
      end
    end
    if p106 == 71 then
      v11 = v6:GetRegularCredits()
      p106 = 74
    end
    if p106 == 72 then
      v13 = gGameData
      v12 = IsNull
      v12 = v12(v13)
      if v12 then
        p106 = 74
      else
        p106 = 73
      end
    end
    if p106 == 73 then
      v12 = gGameData
      v11 = v12:GetRegularCredits()
      p106 = 74
    end
    if p106 == 74 then
      v10.Count = v11
      v10.Req = v9
      v12 = u2
      v14 = 1
      v16 = true
      v12:InsertElement(v14, v10, v16)
    end
    p110 = 75
  end
  if p110 == 75 then
    v5 = u2
    v7 = nil
    v8 = nil
    v9 = true
    v5:Redraw(v7, v8, v9)
    do return v3, v4 end
  end
  if p110 == 76 then
    v3 = false
    v4 = false
    do return v3, v4 end
  end
end

function proto_59(v0)
  local v1, v2, v3, v4, v5
  local p35 = 0
  if p35 == 0 then
    v1 = 20
    if v0 == v1 then
      p35 = 3
    else
      p35 = 1
    end
  end
  if p35 == 1 then
    v1 = 22
    if v0 == v1 then
      p35 = 3
    else
      p35 = 2
    end
  end
  if p35 == 2 then
    v1 = 21
    if v0 ~= v1 then
      p35 = 4
    else
      p35 = 3
    end
  end
  if p35 == 3 then
    v1 = true
    do return v1 end
  end
  if p35 == 4 then
    v1 = nil
    v2 = nil
    v3 = 23
    if v0 ~= v3 then
      p35 = 6
    else
      p35 = 5
    end
  end
  if p35 == 5 then
    v3 = WeakResource
    v4 = "/Lotus/Types/Keys/EntratiLab/EntratiQuestKeyChain"
    v1 = v3(v4)
    p35 = 25
  end
  if p35 == 6 then
    v3 = 24
    if v0 ~= v3 then
      p35 = 8
    else
      p35 = 7
    end
  end
  if p35 == 7 then
    v3 = WeakResource
    v4 = "/Lotus/Types/Keys/OrokinMoonQuest/OrokinMoonQuestKeyChain"
    v1 = v3(v4)
    p35 = 25
  end
  if p35 == 8 then
    v3 = 25
    if v0 ~= v3 then
      p35 = 10
    else
      p35 = 9
    end
  end
  if p35 == 9 then
    v2 = "MarsToPhobosJunction"
    p35 = 25
  end
  if p35 == 10 then
    v3 = 26
    if v0 ~= v3 then
      p35 = 12
    else
      p35 = 11
    end
  end
  if p35 == 11 then
    v3 = WeakResource
    v4 = "/Lotus/Types/Keys/NewWarQuest/NewWarQuestKeyChain"
    v1 = v3(v4)
    p35 = 25
  end
  if p35 == 12 then
    v3 = 27
    if v0 ~= v3 then
      p35 = 14
    else
      p35 = 13
    end
  end
  if p35 == 13 then
    v3 = WeakResource
    v4 = "/Lotus/Types/Keys/ZarimanQuest/ZarimanQuestKeyChain"
    v1 = v3(v4)
    p35 = 25
  end
  if p35 == 14 then
    v3 = 29
    if v0 ~= v3 then
      p35 = 16
    else
      p35 = 15
    end
  end
  if p35 == 15 then
    v3 = WeakResource
    v4 = "/Lotus/Types/Keys/WarWithinQuest/WarWithinQuestKeyChain"
    v1 = v3(v4)
    p35 = 25
  end
  if p35 == 16 then
    v3 = 30
    if v0 ~= v3 then
      p35 = 18
    else
      p35 = 17
    end
  end
  if p35 == 17 then
    v3 = WeakResource
    v4 = "/Lotus/Types/Keys/InfestedMicroplanetQuest/InfestedMicroplanetQuestKeyChain"
    v1 = v3(v4)
    p35 = 25
  end
  if p35 == 18 then
    v3 = 31
    if v0 ~= v3 then
      p35 = 20
    else
      p35 = 19
    end
  end
  if p35 == 19 then
    v2 = "CeresToJupiterJunction"
    p35 = 25
  end
  if p35 == 20 then
    v3 = 28
    if v0 == v3 then
      p35 = 22
    else
      p35 = 21
    end
  end
  if p35 == 21 then
    v3 = 32
    if v0 ~= v3 then
      p35 = 23
    else
      p35 = 22
    end
  end
  if p35 == 22 then
    v3 = WeakResource
    v4 = "/Lotus/Types/Keys/1999Quest/1999QuestKeyChain"
    v1 = v3(v4)
    p35 = 25
  end
  if p35 == 23 then
    v3 = 33
    if v0 ~= v3 then
      p35 = 25
    else
      p35 = 24
    end
  end
  if p35 == 24 then
    v3 = WeakResource
    v4 = "/Lotus/Types/Keys/TauPrequel/TauPrequelQuestKeyChain"
    v1 = v3(v4)
    p35 = 25
  end
  if p35 == 25 then
    if v1 == nil then
      p35 = 27
    else
      p35 = 26
    end
  end
  if p35 == 26 then
    v3 = u0
    v3 = v3.HasCompletedQuest
    do return v3(v1) end
  end
  if p35 == 27 then
    if v2 == nil then
      p35 = 29
    else
      p35 = 28
    end
  end
  if p35 == 28 then
    v3 = gGameData
    v5 = Symbol
    do return v3:HasCompletedMission(v5(v2)) end
  end
  if p35 == 29 then
    v3 = false
    do return v3 end
  end
end

function proto_60(v0, v1)
  local v2, v3, v4, v5
  v2 = v0.Resist
  v3 = v1.Resist
  if v2 ~= v3 then
    v3 = v0.Resist
    v4 = v1.Resist
    if v4 <= v3 then
      v2 = false
    else
      v2 = true
    end
    do return v2 end
  end
  v3 = string.lower
  v4 = v0.Name
  v3 = v3(v4)
  v4 = string.lower
  v5 = v1.Name
  v4 = v4(v5)
  if v4 <= v3 then
    v2 = false
  else
    v2 = true
  end
  do return v2 end
end

function proto_61(v0, v1, v2, v3, v4, v5, v6, v7, v8)
  local v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v24, v25, v28, v29, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45
  local v22 = v0.mEvoInfo
  v22 = u8
  v22 = v22.ReplaceTextColors
  local v23 = u7
  v24 = u9
  v22 = v22(v23, v24)
  u7 = v22
  v28 = u1
  v28 = v28.Affiliations
  v29 = u3
  local v30 = 10
  v28 = v29 + v30
  u3 = v28
  v28 = u1
  v28 = v28.Affiliations
  v7 = #v28
  v31 = u32
  v30 = v31 + 1
  v28 = v7
  v29 = 1
  for v30 = v30, v28, v29 do
    v32 = "Popup.Affiliation"
    v31 = v32 .. v30
    v32 = mMovie
    v32 = v32:HasVariable(v31)
    if not v32 then
      v32 = FlashMethod
      v33 = mMovie
      v34 = "Popup.Affiliation1.duplicateMovieClip"
      v36 = "Affiliation"
      v35 = v36 .. v30
      v32(v33, v34, v35, v30)
    end
  end
  v22 = mMovie
  v24 = "Popup.Description"
  v25 = 36
  local v27 = "<p><font color=\""
  v28 = u9
  v28 = v28.ContentHex
  v29 = "\">"
  v30 = u7
  v32 = "</font></p>"
  local v26 = v27 .. v28 .. v29 .. v30 .. v3 .. v32
  v22:SetStringVariable(v24, v25, v26)
  v3 = ""
  v22 = u7
  if v22 ~= "" then
    v23 = u3
    v24 = mMovie
    v26 = "Popup.Description"
    v27 = 41
    v24 = v24:GetNumberVariable(v26, v27)
    v22 = v23 + v24
    u3 = v22
  else
    v20 = false
    v23 = u3
    v24 = 21
    v22 = v23 - v24
    u3 = v22
  end
  v22 = mMovie
  v24 = "Popup.TagSeparator"
  v25 = 13
  v22:Name__d9713943(v24, v25, v20)
  v22 = mMovie
  v24 = "Popup.CrewMemberInfo"
  v25 = 13
  v27 = u1
  v27 = v27.CrewMemberInfo
  if v27 == nil then
    v26 = false
  else
    v26 = true
  end
  v22:Name__d9713943(v24, v25, v26)
  v22 = u1
  v22 = v22.CrewMemberInfo
  if v22 ~= nil then
    v22 = u30
    v24 = u1
    v24 = v24.CrewMemberInfo
    v22(v6, v24:IsNemesis())
  end
  v22 = nil
  v23 = { W = 330, H = 330 }
  v25 = u1
  v25 = v25.HintIcons
  v24 = #v25
  v25 = 0
  if v22 == "" then
    v25 = u1
    v25 = v25.HintIcons
    v27 = u10
    v27 = v27.mCurrentElementIndex
    v26 = v27 or 1
    v24 = v25[v26]
    if v24 ~= nil then
      v22 = v24.Icon
      v25 = u6
      v25 = v25.Ternary
      v27 = v24.W
      if v27 == nil then
        v26 = false
      else
        v26 = true
      end
      v27 = v24.W
      v28 = v23.W
      v25 = v25(v26, v27, v28)
      v23.W = v25
      v25 = u6
      v25 = v25.Ternary
      v27 = v24.H
      if v27 == nil then
        v26 = false
      else
        v26 = true
      end
      v27 = v24.H
      v28 = v23.H
      v25 = v25(v26, v27, v28)
      v23.H = v25
    end
  end
  if v22 == nil then
    v24 = false
  else
    v24 = true
  end
  v25 = mMovie
  v27 = "Popup.GenericIcon"
  v28 = 13
  v25:Name__d9713943(v27, v28, v24)
  if v24 then
    v25 = mMovie
    v27 = "Popup.GenericIcon"
    v25:OverrideTexture(v27, v22)
    v25 = mMovie
    v27 = "Popup.GenericIcon"
    v28 = 1
    v30 = u3
    v31 = 10
    v29 = v30 + v31
    v25:SetNumberVariable(v27, v28, v29)
    v25 = mMovie
    v27 = "Popup.GenericIcon"
    v28 = 14
    v29 = v23.W
    v25:SetNumberVariable(v27, v28, v29)
    v25 = mMovie
    v27 = "Popup.GenericIcon"
    v28 = 15
    v29 = v23.H
    v25:SetNumberVariable(v27, v28, v29)
    v25 = u3
    v26 = v23.H
    v25 = v25 + v26
    u3 = v25
  end
  v25 = mMovie
  v27 = "Popup.ExtraDesc"
  v28 = 13
  v30 = u1
  v30 = v30.ExtraDesc
  if v30 == nil then
    v29 = false
  else
    v29 = true
  end
  v25:Name__d9713943(v27, v28, v29)
  v25 = u1
  v25 = v25.ExtraDesc
  if v25 ~= nil then
    v25 = mMovie
    v27 = "Popup.ExtraDesc.Bg"
    v28 = _G
    v28 = v28.UIMaterial_RectangleNoDepth
    v25:OverrideMaterial(v27, v28)
    v25 = u9
    v25 = v25.Background1RGB
    v26 = u9
    v26 = v26.FloatingContentRGB
    v27 = mMovie
    v29 = "Popup.ExtraDesc.Bg"
    v30 = "RectInnerColor"
    v31 = v25.r
    v32 = v25.g
    v33 = v25.b
    v34 = 0.2
    v27:Name__e243d995(v29, v30, v31, v32, v33, v34)
    v27 = mMovie
    v29 = "Popup.ExtraDesc.Bg"
    v30 = "RectEdgeColor"
    v31 = v26.r
    v32 = v26.g
    v33 = v26.b
    v34 = 0.7
    v27:Name__e243d995(v29, v30, v31, v32, v33, v34)
    v27 = mMovie
    v29 = "Popup.ExtraDesc.Icon"
    v30 = u1
    v30 = v30.ExtraDesc
    v30 = v30.Icon
    v27:OverrideTexture(v29, v30)
    v27 = mMovie
    v29 = "Popup.ExtraDesc.Icon"
    v30 = 11
    v31 = u9
    v31 = v31.FloatingContentHighlight
    v27:SetNumberVariable(v29, v30, v31)
    v27 = mMovie
    v29 = "Popup.ExtraDesc.Title"
    v30 = 36
    v31 = u1
    v31 = v31.ExtraDesc
    v31 = v31.Title
    v27:SetStringVariable(v29, v30, v31)
    v27 = mMovie
    v29 = "Popup.ExtraDesc.Title"
    v30 = 44
    v31 = u9
    v31 = v31.FloatingContentHighlight
    v27:SetNumberVariable(v29, v30, v31)
    v27 = mMovie
    v29 = "Popup.ExtraDesc.Desc"
    v30 = 36
    v31 = u1
    v31 = v31.ExtraDesc
    v31 = v31.Desc
    v27:SetStringVariable(v29, v30, v31)
    v27 = mMovie
    v29 = "Popup.ExtraDesc.Desc"
    v30 = 44
    v31 = u9
    v31 = v31.Content
    v27:SetNumberVariable(v29, v30, v31)
    v27 = mMovie
    v29 = "Popup.ExtraDesc.Desc"
    v30 = 41
    v27 = v27:GetNumberVariable(v29, v30)
    v28 = mMovie
    v30 = "Popup.ExtraDesc.Bg"
    v31 = 15
    v33 = 50
    v32 = v27 + v33
    v28:SetNumberVariable(v30, v31, v32)
    v28 = mMovie
    v30 = "Popup.ExtraDesc"
    v31 = 1
    v33 = u3
    v32 = v33 + 5
    v28:SetNumberVariable(v30, v31, v32)
    v30 = u3
    v29 = v30 + v27
    v30 = 55
    v28 = v29 + v30
    u3 = v28
  end
  v25 = mMovie
  v27 = "Popup.Invasion"
  v28 = 13
  v30 = u1
  v30 = v30.SubInvasions
  if v30 == nil then
    v29 = false
  else
    v29 = true
  end
  v25:Name__d9713943(v27, v28, v29)
  v25 = u1
  v25 = v25.SubInvasions
  if v30 ~= nil then
    v26 = u1
    v26 = v26.SubInvasions
    v25 = v26[1]
    v25 = v25.CustomEntry
    v26 = u31
    v27 = u6
    v27 = v27.Ternary
    v29 = 50
    v30 = 75
    v27 = v27(v25, v29, v30)
    v26.mForcedVerticalSeparation = v27
    v26 = mMovie
    v28 = "Popup.Invasion"
    v29 = 1
    v31 = u3
    v32 = u6
    v32 = v32.Ternary
    v34 = -15
    v35 = 5
    v32 = v32(v25, v34, v35)
    v30 = v31 + v32
    v26:SetNumberVariable(v28, v29, v30)
    v26 = u31
    v28 = true
    v29 = true
    v26:RemoveElements(v28, v29)
    v28 = 1
    v29 = u1
    v29 = v29.SubInvasions
    v26 = #v29
    v27 = 1
    for v28 = v28, v26, v27 do
      v29 = u31
      v32 = u1
      v32 = v32.SubInvasions
      v31 = v32[v28]
      v32 = true
      v29:AddElement(v31, v32)
    end
    v26 = u31
    v28 = nil
    v29 = true
    v30 = true
    v26:Redraw(v28, v29, v30)
    v27 = u3
    v29 = u31
    v29 = v29:GetHowManyElements()
    v30 = u31
    v30 = v30.mForcedVerticalSeparation
    v28 = v29 * v30
    v26 = v27 + v28
    u3 = v26
  end
  v25 = u1
  v25 = v25.RarityChances
  if v25 ~= nil then
    v25 = mMovie
    v27 = "Popup.RarityBar"
    v28 = 13
    v29 = true
    v25:Name__d9713943(v27, v28, v29)
    v25 = u0
    v25 = v25.DrawRarityBar
    v26 = mMovie
    v27 = "Popup.RarityBar"
    v28 = u1
    v28 = v28.RarityChances
    v29 = 330
    v30 = barMaterial
    v31 = 0
    v32 = -16
    v33 = 10
    v35 = u3
    v36 = 30
    v34 = v35 + v36
    v25(v26, v27, v28, v29, v30, v31, v32, v33, v34)
    v26 = u3
    v27 = 40
    v25 = v26 + v27
    u3 = v25
  else
    v25 = mMovie
    v27 = "Popup.RarityBar"
    v28 = 13
    v29 = false
    v25:Name__d9713943(v27, v28, v29)
  end
  v25 = mMovie
  v27 = "Popup.Prerequisite"
  v28 = 13
  v25:Name__d9713943(v27, v28, v19)
  if v25 == nil then
    v25 = mMovie
    v27 = "Popup.Prerequisite"
    v28 = 1
    v30 = u3
    v31 = 20
    v29 = v30 + v31
    v25:SetNumberVariable(v27, v28, v29)
    v26 = u3
    v27 = 123
    v25 = v26 + v27
    u3 = v25
    v25 = u1
    v25 = v25.mPrereqElement
    v26 = mMovie
    v28 = "Popup.Prerequisite.Icon"
    v29 = v25.Icon
    v26:OverrideTexture(v28, v29)
    v26 = mMovie
    v28 = "Popup.Prerequisite.Icon"
    v29 = v25.Material
    v26:OverrideMaterial(v28, v29)
    v26 = mMovie
    v28 = "Popup.Prerequisite.Icon"
    v29 = 15
    v26 = v26:GetNumberVariable(v28, v29)
    v27 = v25.Themed
    if not v27 then
      v27 = 1.6
      v26 = v26 * v27
    end
    v27 = mMovie
    v29 = "Popup.Prerequisite.Icon"
    v30 = 14
    v27:SetNumberVariable(v29, v30, v26)
    v28 = "<p><font color=\""
    v29 = u9
    v29 = v29.FloatingContentHighlightHex
    v30 = "\">"
    v33 = string.upper
    v34 = Localize
    v35 = "/Lotus/Language/Dojo/Prerequisite"
    v36 = {}
    v31 = v33(v34(v35, v36))
    v32 = "</font></p>"
    v27 = v28 .. v29 .. v30 .. v31 .. v32
    v28 = mMovie
    v30 = "Popup.Prerequisite.Header"
    v31 = 36
    v28:SetStringVariable(v30, v31, v27)
    v29 = "<p><font color=\""
    v30 = u9
    v30 = v30.FloatingContentHighlightHex
    v31 = "\">"
    v32 = "<font color=\""
    v33 = u9
    v33 = v33.FloatingContentHex
    v34 = "\">"
    v37 = TitleCase
    v38 = v25.Name
    v35 = v37(v38)
    v36 = "<br></font>"
    v28 = v29 .. v30 .. v31 .. v32 .. v33 .. v34 .. v35 .. v36
    v31 = v25.mCompletionDate
    v30 = IsNull
    v30 = v30(v31)
    v29 = not v30
    if v29 then
      v30 = Engine.Name__b38e1642
      v31 = v25.mCompletionDate
      v30 = v30(v31)
      v31 = 0
      if v31 < v30 then
        v29 = false
      else
        v29 = true
      end
    end
    if v29 then
      v31 = "<font color=\""
      v32 = u9
      v32 = v32.PositiveHex
      v33 = "\">"
      v37 = mMovie
      v39 = "<CHECKMARK_NO_BORDER> "
      v40 = true
      v34 = v37:GetLocalized(v39, v40)
      v35 = "</font>"
      v36 = mMovie
      v38 = "/Lotus/Language/Categories/RESEARCHED"
      v39 = true
      v36 = v36:GetLocalized(v38, v39)
      v28 = v28 .. v31 .. v32 .. v33 .. v34 .. v35 .. v36
    else
      v31 = "<font color=\""
      v32 = u9
      v32 = v32.NegativeHex
      v33 = "\">"
      v37 = mMovie
      v39 = "<CHECKMARK_FAIL_NO_BORDER> "
      v40 = true
      v34 = v37:GetLocalized(v39, v40)
      v35 = "</font>"
      v36 = mMovie
      v38 = "/Lotus/Language/Menu/Profile_ResearchNotStarted"
      v39 = true
      v36 = v36:GetLocalized(v38, v39)
      v28 = v28 .. v31 .. v32 .. v33 .. v34 .. v35 .. v36
    end
    v31 = "</font></p>"
    v28 = v28 .. v31
    v30 = mMovie
    v32 = "Popup.Prerequisite.Name"
    v33 = 46
    v34 = "center"
    v30:SetStringVariable(v32, v33, v34)
    v30 = mMovie
    v32 = "Popup.Prerequisite.Name"
    v33 = 36
    v30:SetStringVariable(v32, v33, v28)
    v30 = mMovie
    v32 = "Popup.Prerequisite.Bg"
    v33 = 13
    v36 = v25.Background
    v35 = IsNull
    v35 = v35(v36)
    v34 = not v35
    v30:Name__d9713943(v32, v33, v34)
    v30 = mMovie
    v32 = "Popup.Prerequisite.Bg"
    v33 = v25.Background
    v30:OverrideTexture(v32, v33)
    v30 = mMovie
    v32 = "Popup.Prerequisite.Bg"
    v33 = 11
    v34 = u9
    v34 = v34.FloatingContent
    v30:SetNumberVariable(v32, v33, v34)
    v30 = mMovie
    v32 = "Popup.Prerequisite.Bg"
    v33 = _G
    v33 = v33.UIMaterial_RectangleNoDepth
    v30:OverrideMaterial(v32, v33)
    v30 = mMovie
    v32 = "Popup.Prerequisite.Bg"
    v33 = "RectEdgeColor"
    v34 = 1
    v35 = 1
    v36 = 1
    v37 = 0
    v30:Name__e243d995(v32, v33, v34, v35, v36, v37)
    v30 = mMovie
    v32 = "Popup.Prerequisite.Bg"
    v33 = "RectInnerColor"
    v34 = 1
    v35 = 1
    v36 = 1
    v37 = 1
    v30:Name__e243d995(v32, v33, v34, v35, v36, v37)
    v30 = u9
    v30 = v30.Background1RGB
    v31 = u9
    v31 = v31.BackerHighlightRGB
    v32 = mMovie
    v34 = "Popup.Prerequisite.Border"
    v35 = _G
    v35 = v35.UIMaterial_RectangleNoDepth
    v32:OverrideMaterial(v34, v35)
    v32 = mMovie
    v34 = "Popup.Prerequisite.Border"
    v35 = "RectEdgeColor"
    v36 = v31.r
    v37 = v31.g
    v38 = v31.b
    v39 = 0.2
    v32:Name__e243d995(v34, v35, v36, v37, v38, v39)
    v32 = mMovie
    v34 = "Popup.Prerequisite.Border"
    v35 = "RectInnerColor"
    v36 = v30.r
    v37 = v30.g
    v38 = v30.b
    v39 = 0.2
    v32:Name__e243d995(v34, v35, v36, v37, v38, v39)
  end
  v25 = false
  v26 = u1
  v26 = v26.SecondaryDesc
  if v26 ~= nil then
    v26 = u1
    v26 = v26.SecondaryDesc
    if v26 == "" then
      v25 = false
    else
      v25 = true
    end
  end
  if v25 then
    v27 = "<p><font color=\""
    v28 = u9
    v28 = v28.ContentHex
    v29 = "\">"
    v30 = u1
    v30 = v30.SecondaryDesc
    v31 = "</font></p>"
    v26 = v27 .. v28 .. v29 .. v30 .. v31
    v27 = mMovie
    v29 = "Popup.PrereqSeparator.Description"
    v30 = 36
    v27:SetStringVariable(v29, v30, v26)
  end
  v26 = v25
  if not v26 then
    v27 = u1
    v27 = v27.HideRecipe
    v26 = not v27
    if v26 then
      v26 = u1
      v26 = v26.Researched
      if not v26 then
        v26 = u1
        v26 = v26.InProgress
        if not v26 then
          v26 = v19
        end
      end
    end
  end
  v27 = mMovie
  v29 = "Popup.PrereqSeparator"
  v30 = 13
  v27:Name__d9713943(v29, v30, v26)
  if v26 then
    v27 = mMovie
    v29 = "Popup.PrereqSeparator"
    v30 = 1
    v32 = u3
    v33 = 10
    v31 = v32 + v33
    v27:SetNumberVariable(v29, v30, v31)
    v29 = u3
    v30 = mMovie
    v32 = "Popup.PrereqSeparator.Description"
    v33 = 41
    v30 = v30:GetNumberVariable(v32, v33)
    v28 = v29 + v30
    v29 = 21
    v27 = v28 + v29
    u3 = v27
  end
  v27 = mMovie
  v29 = "Popup.Ingredients"
  v30 = 13
  v27:Name__d9713943(v29, v30, v17)
  v27 = mMovie
  v29 = "Popup.Ingredients"
  v30 = 1
  v32 = u3
  v33 = 10
  v31 = v32 + v33
  v27:SetNumberVariable(v29, v30, v31)
  v27 = 0
  v28 = ipairs
  v29 = u15
  v29 = v29.mElements
  v28, v29, v30 = v28(v29)
  for v31, v32 in v28, v29, v30 do
    v33 = v27 + 5
    v35 = u15
    v35 = v35.mForcedVerticalSeparation
    v37 = v32.mHeight
    v36 = v37 or 0
    v34 = math.max
    v34 = v34(v35, v36)
    v27 = v33 + v34
  end
  v30 = u3
  v31 = mMovie
  v33 = "Popup.Ingredients.ingredient"
  v34 = 1
  v31 = v31:GetNumberVariable(v33, v34)
  v29 = v30 + v31
  v28 = v29 + v27
  u3 = v28
  for v31, v32 in v28, v29, v30 do
  end
  v27 = v17 and v18
  v28 = mMovie
  v30 = "Popup.IngredientsSeparator"
  v31 = 13
  v28:Name__d9713943(v30, v31, v27)
  if v27 then
    v28 = mMovie
    v30 = "Popup.IngredientsSeparator"
    v31 = 1
    v33 = u3
    v34 = 10
    v32 = v33 + v34
    v28:SetNumberVariable(v30, v31, v32)
    v30 = u3
    v31 = mMovie
    v33 = "Popup.IngredientsSeparator.Description"
    v34 = 41
    v31 = v31:GetNumberVariable(v33, v34)
    v29 = v30 + v31
    v30 = 21
    v28 = v29 + v30
    u3 = v28
  end
  v28 = mMovie
  v30 = "Popup.IngredientsSecondary"
  v31 = 13
  v28:Name__d9713943(v30, v31, v18)
  if not v17 then
    v28 = mMovie
    v30 = "Popup.IngredientsSecondary"
    v31 = 1
    v33 = u3
    v34 = 10
    v32 = v33 + v34
    v28:SetNumberVariable(v30, v31, v32)
    v28 = 0
    v29 = ipairs
    v30 = u17
    v30 = v30.mElements
    v29, v30, v31 = v29(v30)
    for v32, v33 in v29, v30, v31 do
      v34 = v28 + 5
      v36 = u17
      v36 = v36.mForcedVerticalSeparation
      v38 = v33.mHeight
      v37 = v38 or 0
      v35 = math.max
      v35 = v35(v36, v37)
      v28 = v34 + v35
    end
    v31 = u3
    v32 = mMovie
    v34 = "Popup.IngredientsSecondary.ingredient"
    v35 = 1
    v32 = v32:GetNumberVariable(v34, v35)
    v30 = v31 + v32
    v29 = v30 + v28
    u3 = v29
  end
  v28 = u1
  v28 = v28.CustomEntry
  v23 = table.sort
  v25 = function(c19v0, c19v1)
    local c19v2, c19v3, c19v4, c19v5
    c19v2 = c19v0.Resist
    c19v3 = c19v1.Resist
    if c19v2 ~= c19v3 then
      c19v3 = c19v0.Resist
      c19v4 = c19v1.Resist
      if c19v4 <= c19v3 then
        c19v2 = false
      else
        c19v2 = true
      end
      do return c19v2 end
    end
    c19v3 = string.lower
    c19v4 = c19v0.Name
    c19v3 = c19v3(c19v4)
    c19v4 = string.lower
    c19v5 = c19v1.Name
    c19v4 = c19v4(c19v5)
    if c19v4 <= c19v3 then
      c19v2 = false
    else
      c19v2 = true
    end
    do return c19v2 end
  end
  v23(v21, v25)
  v23 = #v21
  v24 = 0
  v24 = "<font color=\""
  v25 = u9
  v25 = v25.FloatingContentHighlightHex
  v26 = "\">"
  v29 = mMovie
  v31 = "/Lotus/Language/Stats/FactionResistsTitle"
  v32 = false
  v27 = v29:GetLocalized(v31, v32)
  v28 = "</font><br>"
  v23 = v24 .. v25 .. v26 .. v27 .. v28
  v26 = 1
  v24 = #v21
  v25 = 1
  for v26 = v26, v24, v25 do
    v36 = u9
    v36 = v36.PositiveHex
    v37 = u9
    v37 = v37.NegativeHex
    v30 = v34(v35, v36, v37)
    v31 = "\"><b>x"
    v34 = v27.Resist
    v32 = 1 - v34
    v33 = "</b></font>"
    v28 = v29 .. v30 .. v31 .. v32 .. v33
    v32 = mMovie
    v34 = "/Lotus/Language/Stats/FactionResistsEntry"
    v35 = false
    v36 = { VAL = nil, FACTION = nil, OPEN_COLOR = nil, CLOSE_COLOR = "</font>" }
    v36.VAL = v28
    v37 = v27.Name
    v36.FACTION = v37
    v38 = "<font color=\""
    v39 = u9
    v39 = v39.FloatingContentHex
    v40 = "\">"
    v37 = v38 .. v39 .. v40
    v36.OPEN_COLOR = v37
    v30 = v32:GetLocalized(v34, v35, v36)
    v31 = "<br>"
    v23 = v23 .. v30 .. v31
    v27 = v21[v26]
    v29 = "<font color=\""
    v34 = u6
    v34 = v34.Ternary
    v36 = v27.Resist
    v37 = 0
    if v37 <= v36 then
      v35 = false
    else
      v35 = true
    end
  end
  v20 = string.find
  v21 = u1
  v21 = v21.StatId
  v22 = "DT_"
  v20 = v20(v21, v22)
  v20 = u8
  v20 = v20.GetDamageTypeIndex
  v21 = u1
  v21 = v21.StatId
  v20 = v20(v21)
  v21 = {}
  v22 = gGameConfig
  v25 = false
  v22 = v22:Name__d18513f7(v20, v25)
  v25 = 20
  v23 = 33
  v24 = 1
  for v25 = v25, v23, v24 do
    v27 = v25 + 1
    v26 = v22[v27]
    if v26 ~= 0 then
      v26 = u26
      v26 = v26(v25)
      if v26 then
        v26 = u8
        v26 = v26.GetResistTag
        v26 = v26(v25)
        v28 = "/Lotus/Language/Stats/ResistKey_"
        v27 = v28 .. v26
        v30 = { Name = nil, Resist = nil }
        v31 = mMovie
        v34 = false
        v31 = v31:GetLocalized(v27, v34)
        v30.Name = v31
        v32 = v25 + 1
        v31 = v22[v32]
        v30.Resist = v31
        v28 = table.insert
        v28(v21, v30)
      end
    end
  end
  v21 = u1
  v21 = v21.mMod
  v20 = IsNull
  v20 = v20(v21)
  v20 = u1
  v20 = v20.ArcaneRank
  v20 = u1
  v20 = v20.ArcaneMaxRank
  v20 = u1
  v20 = v20.ArcaneRank
  v24 = v23:Name__65a6ff3f(v20)
  v25 = mMovie
  v27 = v23:GetEnhancementDescription(v24)
  v28 = true
  v22 = v25:GetLocalized(v27, v28)
  v25 = u1
  v25 = v25.CountTable
  v26 = u1
  v26 = v26.CountTable
  v25 = #v26
  v26 = 0
  v29 = v25[v28]
  if v29 ~= 0 then
    v30 = " <font color=\""
    v31 = u9
    v31 = v31.FloatingContentHighlightHex
    v32 = "\">"
    v39 = u0
    v39 = v39.GetArcaneRankString
    v40 = ""
    v41 = v28 - 1
    v42 = u1
    v42 = v42.ArcaneMaxRank
    v43 = mMovie
    v33 = v39(v40, v41, v42, v43)
    v34 = "</font> <font color=\""
    v35 = u9
    v35 = v35.FloatingContentHex
    v36 = "\">"
    v39 = u6
    v39 = v39.FormatNumber
    v40 = v25[v28]
    v37 = v39(v40)
    v38 = "</font>"
    v29 = v30 .. v31 .. v32 .. v33 .. v34 .. v35 .. v36 .. v37 .. v38
    v31 = u7
    v33 = "<br>"
    v30 = v31 .. v29 .. v33
    u7 = v30
  end
  v20 = u1
  v20 = v20.CompatLabel
  if v20 ~= nil then
    v21 = u7
    v22 = u1
    v22 = v22.CompatLabel
    v23 = "<br><br>"
    v20 = v21 .. v22 .. v23
    u7 = v20
  end
  v21 = u1
  v21 = v21.ArcaneRank
  v22 = 0
  v24 = u6
  v24 = v24.Ternary
  if v20 ~= 0 then
    v25 = false
  else
    v25 = true
  end
  v26 = mMovie
  v28 = "/Lotus/Language/Ranks/Rank0"
  v29 = false
  v26 = v26:GetLocalized(v28, v29)
  v27 = mMovie
  v29 = "/Lotus/Language/Menu/Global_FormattedRankCaps"
  v30 = false
  v31 = { RANK = nil }
  v31.RANK = v20
  v22 = v24(v25, v26, v27:GetLocalized(v29, v30, v31))
  v23 = "  "
  v21 = v22 .. v23
  v22 = ""
  v23 = nil
  v25 = u1
  v25 = v25.Arcane
  v24 = IsNull
  v24 = v24(v25)
  if not v24 then
    v24 = u1
    v24 = v24.Arcane
    v23 = v24.mInstance
  else
    v24 = IsNull
    v24 = v24(v2)
    if not v24 then
      v24 = IsNull
      v24 = v24(v2:GetItem())
      if not v24 then
        v24 = v2:GetItem()
        v26 = gLotusArtifactUpgradeType
        v24 = v24:IsA(v26)
        if v24 then
          v24 = Lotus_Game.UpgradeInfo
          v24 = v24()
          v25 = v2:GetItem()
          v24.mItemType = v25
          v23 = v24.mInstance
        end
      end
    end
  end
  v24 = IsNull
  v24 = v24(v23)
  v25 = {}
  v28 = 1
  v29 = u1
  v29 = v29.ArcaneMaxRank
  v26 = v29 + 1
  v27 = 1
  for v28 = v28, v26, v27 do
    v31 = 0
    v29 = table.insert
    v29(v25, v31)
  end
  v28 = 1
  v29 = u1
  v29 = v29.CountTable
  v26 = #v29
  v27 = 1
  for v28 = v28, v26, v27 do
    v29 = u25
    v29 = v29.GetArcaneRank
    v30 = { mInstance = nil }
    v30.mInstance = v23
    v32 = u1
    v32 = v32.CountTable
    v31 = v32[v28]
    v31 = v31.fp
    v29 = v29(v30, v31)
    v30 = v29 + 1
    v31 = v25[v30]
    v33 = u1
    v33 = v33.CountTable
    v32 = v33[v28]
    v32 = v32.Count
    v31 = v31 + v32
    v25[v30] = v31
  end
  v27 = u7
  v28 = "<font color=\""
  v29 = u9
  v29 = v29.FloatingContentHighlightHex
  v30 = "\">"
  v35 = mMovie
  v37 = "<OWNED>"
  v38 = true
  v31 = v35:GetLocalized(v37, v38)
  v32 = " "
  v35 = mMovie
  v37 = "/Lotus/Language/Menu/Store_Owned"
  v38 = false
  v33 = v35:GetLocalized(v37, v38)
  v34 = "</font><br>"
  v26 = v27 .. v28 .. v29 .. v30 .. v31 .. v32 .. v33 .. v34
  u7 = v26
  v28 = 1
  v26 = #v25
  v27 = 1
  local c753 = -1
  repeat
    v26 = v16[v20]
    v28 = v25 - 1
    v26 = v26:Name__1beb0183(v28)
    if v26 == 0.01 then
      v26 = 0
    end
    v27 = "/Lotus/Language/Melee/ComboAttack"
    v28 = v16[v20]
    v30 = v25 - 1
    v28 = v28:Name__8418dab6(v30)
    v29 = tostring
    v29 = v29(v28)
    if v29 ~= "" then
      v27 = "/Lotus/Language/Melee/ComboSlam"
    end
    v30 = u7
    v31 = "    "
    v32 = mMovie
    v35 = false
    v36 = { OPEN_COLOR = nil, VALUE = nil, CLOSE_COLOR = "</font>" }
    v36.OPEN_COLOR = v17
    v37 = u6
    v37 = v37.FormatNumber
    v39 = 100
    v38 = v39 * v26
    v37 = v37(v38)
    v36.VALUE = v37
    v32 = v32:GetLocalized(v27, v35, v36)
    v29 = v30 .. v31 .. v32
    u7 = v29
    v31 = 0
    v32 = 30
    v29 = v32 - 1
    v30 = 1
    for v31 = v31, v29, v30 do
      v32 = v16[v20]
      v34 = v25 - 1
      v35 = false
      v32 = v32:Name__4be70667(v34, v35, v31)
      if v32 then
        v33 = u7
        v34 = " + "
        v35 = mMovie
        v38 = "<"
        v41 = u8
        v41 = v41.GetProcTypeTag
        v39 = v41(v31)
        v40 = ">"
        v37 = v38 .. v39 .. v40
        v38 = true
        v35 = v35:GetLocalized(v37, v38)
        v32 = v33 .. v34 .. v35
        u7 = v32
      end
    end
    if c753 ~= -1 then break end
    v16 = u1
    v16 = v16.mMeleeSet
    v16 = v16:GetAttacks()
    v17 = u1
    v17 = v17.mMeleeCallouts
    if v17 == nil then
      v17 = u1
      v18 = {}
      v17.mMeleeCallouts = v18
    end
    v18 = "<font color=\""
    v19 = u9
    v19 = v19.FloatingContentHighlightHex
    v20 = "\">"
    v17 = v18 .. v19 .. v20
    v20 = 1
    v18 = #v16
    v19 = 1
    v30 = u7
    v31 = u6
    v31 = v31.Ternary
    if v25 ~= v22 then
      v32 = false
    else
      v32 = true
    end
    v33 = ""
    v34 = "<br>"
    v31 = v31(v32, v33, v34)
    v29 = v30 .. v31
    u7 = v29
    v24 = u7
    v25 = u6
    v25 = v25.Ternary
    v27 = #v16
    if v20 ~= v27 then
      v26 = false
    else
      v26 = true
    end
    v27 = ""
    v28 = "<br><br>"
    v25 = v25(v26, v27, v28)
    v23 = v24 .. v25
    u7 = v23
    v21 = ""
    v23 = u1
    v23 = v23.mMeleeCallouts
    v22 = v23[v20]
    if v22 ~= nil then
      v23 = u1
      v23 = v23.mMeleeCallouts
      v22 = v23[v20]
      if not ((not ((v22 == "<MELEE>" or v22 == "<AIM_WEAPON>")) and v22 ~= "<MELEE_CHANNEL>")) then
        v23 = mMovie
        v25 = "/Lotus/Language/Melee/ComboBtnPress"
        v26 = true
        v27 = { ACTION = nil }
        v27.ACTION = v22
        v22 = v23:GetLocalized(v25, v26, v27)
      else
        v23 = mMovie
        v26 = true
        v22 = v23:GetLocalized(v22, v26)
      end
      v24 = "<br>"
      v21 = v22 .. v24
    end
    v23 = u7
    v22 = v23 .. v21
    u7 = v22
    v23 = 1
    v24 = v16[v20]
    v22 = math.max
    v22 = v22(v23, v24:Name__dab108e3())
    v25 = 1
    v23 = v22
    v24 = 1
    v21 = v20.ExcludeFromInfoPopup
    v21 = ""
    v22 = false
    v23 = v20.Type
    v24 = u0
    v24 = v24.LABEL_TYPE_UGC
    v23 = v20.RightAlign
    v22 = not v15
    v22 = true
    v23 = v20.Type
    v24 = u0
    v24 = v24.LABEL_TYPE_FAVORITE
    v22 = not v15
    if v22 then
      v23 = v20.UseFullLabel
      v22 = not v23
    end
    v20.RightAlignPopup = v22
    if v22 then
      v23 = v20.Type
      v24 = u0
      v24 = v24.LABEL_TYPE_REUSABLE_BLUEPRINT
      if v23 == v24 then
        v13 = true
        if v14 ~= 1 then
          v23 = ""
          v20.Name = v23
        end
      else
        v23 = v20.Type
        v24 = u0
        v24 = v24.LABEL_TYPE_RIGHT_TEXT
        if not ((v23 == v24 or v14 == 1)) then
          v23 = ""
          v20.Name = v23
        end
      end
    else
      v23 = v20.PopUpLabel
      if v23 ~= nil then
        v23 = mMovie
        v25 = v20.PopUpLabel
        v26 = true
        v23 = v23:GetLocalized(v25, v26)
        v20.Name = v23
      end
    end
    v23 = u0
    v23 = v23.GetPriceLabelClip
    v24 = mMovie
    v25 = "Popup"
    v21, v1 = v23(v24, v25, v1)
    if not v22 then
      v23 = true
      v20.FitText = v23
      v24 = u5
      v25 = u4
      v23 = v24 - v25
      v20.MaxWidth = v23
    end
    v23 = v20.LabelPrefix
    if v23 == "<PRIME_TOKEN>" then
      v23 = 0
      v20.LabelOffset = v23
    end
    v23 = u0
    v23 = v23.DrawPriceLabel
    v24 = mMovie
    v23(v24, v21, v20)
    v20.ClipName = v21
    v24 = mMovie
    v28 = ".Label"
    v26 = v21 .. v28
    v27 = 41
    v24 = v24:GetNumberVariable(v26, v27)
    v25 = u6
    v25 = v25.Ternary
    v27 = v20.TagBuffer
    if v27 ~= nil then
      v26 = false
    else
      v26 = true
    end
    v27 = 13
    v28 = v20.TagBuffer
    v25 = v25(v26, v27, v28)
    v23 = v24 + v25
    if v22 then
      v25 = mMovie
      v29 = ".IconText"
      v27 = v21 .. v29
      v28 = 40
      v25 = v25:GetNumberVariable(v27, v28)
      v24 = v25 or 0
      v25 = 0
      if v25 < v24 then
        v25 = v12 - v24
        v12 = v25 + 5
      end
      v25 = mMovie
      v28 = 1
      v29 = 0
      v25:SetNumberVariable(v21, v28, v29)
      v25 = mMovie
      v28 = 0
      v25:SetNumberVariable(v21, v28, v12)
      v12 = v12 + -32
      v25 = 0
      if v24 <= v25 then
        v25 = math.max
        v11 = v25(v11, v23)
      end
    else
      v24 = mMovie
      v27 = 1
      v24:SetNumberVariable(v21, v27, v11)
      v11 = v11 + v23
      v15 = false
    end
    local p737 = 0
    if p737 == 0 then
      v9 = u0
      v9 = v9.GetGridItemName
      v10 = mMovie
      v12 = u1
      v13 = u1
      v13 = v13.MetaData
      v9, v10 = v9(v10, v0, v12, v13)
      v11 = {}
      u2 = v11
      v11 = u1
      v11 = v11.CustomEntry
      if not v11 then
        p737 = 3
      else
        p737 = 1
      end
    end
    if p737 == 1 then
      v12 = u1
      v12 = v12.Tags
      v11 = IsNull
      v11 = v11(v12)
      if v11 then
        p737 = 3
      else
        p737 = 2
      end
    end
    if p737 == 2 then
      v11 = u1
      v11 = v11.Tags
      u2 = v11
      p737 = 7
    end
    if p737 == 3 then
      v11 = u1
      v11 = v11.ShowInfoPopupOwned
      if not v11 then
        p737 = 6
      else
        p737 = 4
      end
    end
    if p737 == 4 then
      v11 = u1
      v11 = v11.MetaData
      if not v11 then
        p737 = 6
      else
        p737 = 5
      end
    end
    if p737 == 5 then
      v11 = u1
      v11 = v11.MetaData
      v12 = nil
      v11.HideOwned = v12
      v11 = u1
      v11 = v11.MetaData
      v12 = 0
      v11.HideCountThreshold = v12
      v11 = u1
      v11 = v11.MetaData
      v12 = { TagOverride = "/Lotus/Language/Menu/Crafting_Owned_Icon_Label", mShowOne = true }
      v11.OwnedInfo = v12
      p737 = 6
    end
    if p737 == 6 then
      v11 = u0
      v11 = v11.GetGridItemTags
      v12 = mMovie
      v14 = u1
      v15 = u1
      v15 = v15.MetaData
      v11 = v11(v12, v0, v14, v15, v10)
      u2 = v11
      p737 = 7
    end
    if p737 == 7 then
      v11 = mMovie
      v13 = "Popup.TagContainer"
      v14 = 1
      v15 = u3
      v11:SetNumberVariable(v13, v14, v15)
      v11 = 0
      v12 = 300
      v13 = false
      v14 = 0
      v15 = ipairs
      v16 = u2
      v15, v16, v17 = v15(v16)
      for v18, v19 in v15, v16, v17 do
        v20 = v19.ExcludeFromInfoPopup
        if not v20 then
          v14 = v14 + 1
        end
      end
      if c753 ~= -1 then break end
      v15 = true
      v16 = ipairs
      v17 = u2
      v16, v17, v18 = v16(v17)
      for v19, v20 in v16, v17, v18 do
        v21 = v20.ExcludeFromInfoPopup
        if not v21 then
          v21 = v20.UseFullLabel
          if not v21 then
            v22 = u4
            v21 = v22 + 35
            u4 = v21
          end
        end
      end
      if c753 ~= -1 then break end
      v16 = ipairs
      v17 = u2
      v16, v17, v18 = v16(v17)
    end
    for v18, v19 in v15, v16, v17 do
    end
    if c753 ~= -1 then break end
    if v11 == 0 then
      v16 = 0
      if v16 < v14 then
        v11 = 30
      end
    end
    v17 = u3
    v16 = v17 + v11
    u3 = v16
    v16 = u1
    v16 = v16.NotOwned
    if v11 ~= 0 then
      v16 = IsNull
      v16 = v16(v2)
      if not v16 then
        v16 = mMovie
        v18 = v2:DestroyactionBtn()
        v18 = v18:c_str()
        v19 = true
        v16 = v16:GetLocalized(v18, v19)
        if v16 ~= "" then
          v17 = u7
          if v17 ~= "" then
            v18 = u7
            v19 = "\r\n\r\n"
            v17 = v18 .. v19
            u7 = v17
          end
          v18 = u7
          v20 = "\r\n\r\n"
          v17 = v18 .. v16 .. v20
          u7 = v17
        end
      end
    end
    v16 = u1
    v16 = v16.ArcaneCategory
    if v16 ~= nil then
      v16 = u8
      v16 = v16.GetArcaneSlotRequirementMessage
      v17 = u1
      v17 = v17.ArcaneCategory
      v16, v17 = v16(v17)
      v19 = u7
      v22 = Localize
      v24 = { ITEM = nil }
      v24.ITEM = v17
      v20 = v22(v16, v24)
      v21 = "\r\n\r\n"
      v18 = v19 .. v20 .. v21
      u7 = v18
    end
    v16 = u1
    v16 = v16.NextSuitLevel
    if v16 == nil then
      v16 = TitleCase
      v17 = mMovie
      v19 = "/Lotus/Language/Menu/Global_FormattedRankCaps"
      v20 = true
      v21 = { RANK = nil }
      v22 = u1
      v22 = v22.NextSuitLevel
      v21.RANK = v22
      v16 = v16(v17:GetLocalized(v19, v20, v21))
      v17 = "<font color=\""
      v18 = u9
      v18 = v18.ContentHex
      v19 = "\">"
      v21 = "</font>"
      v16 = v17 .. v18 .. v19 .. v16 .. v21
      v17 = u1
      v17 = v17.Locked
      if v17 then
        v18 = u7
        v21 = mMovie
        v23 = "/Lotus/Language/Suits/AbilityUnlockedAt"
        v24 = true
        v25 = { RANK = nil }
        v25.RANK = v16
        v19 = v21:GetLocalized(v23, v24, v25)
        v20 = "\r\n\r\n"
        v17 = v18 .. v19 .. v20
        u7 = v17
      else
        v18 = u7
        v21 = mMovie
        v23 = "/Lotus/Language/Suits/AbilityUpgradeAt"
        v24 = true
        v25 = { RANK = nil }
        v25.RANK = v16
        v19 = v21:GetLocalized(v23, v24, v25)
        v20 = "\r\n\r\n"
        v17 = v18 .. v19 .. v20
        u7 = v17
      end
      v18 = "<font color=\""
      v19 = u9
      v19 = v19.FloatingContentHex
      v20 = "\">"
      v21 = u7
      v22 = "</font>"
      v17 = v18 .. v19 .. v20 .. v21 .. v22
      u7 = v17
    end
    v17 = u1
    v17 = v17.Hints
    v16 = #v17
    v17 = 0
    if v17 < v16 then
      v17 = u7
      v19 = u1
      v19 = v19.Hints
      v21 = u10
      v21 = v21.mCurrentElementIndex
      v20 = v21 or 1
      v18 = v19[v20]
      v16 = v17 .. v18
      u7 = v16
    end
    v17 = u1
    v17 = v17.mMeleeSet
    v16 = IsNull
    v16 = v16(v17)
    v16 = nil
    v17 = IsNull
    v17 = v17(v2)
    if not v17 then
      v16 = v2:GetItem()
    end
    v17 = u1
    v17 = v17.SkipDesc
    if v17 then
      local p738 = 97
      if p738 == 97 then
        v17 = IsNull
        v17 = v17(v16)
        if v17 then
          p738 = 100
        else
          p738 = 98
        end
      end
      if p738 == 98 then
        v19 = gVoidProjectionItemType
        v17 = v16:IsA(v19)
        if not v17 then
          p738 = 100
        else
          p738 = 99
        end
      end
      if p738 == 99 then
        v19 = WeakResource
        v20 = "/Lotus/Types/Game/Projections/T5VoidProjectionImmortal"
        v17 = v16:IsA(v19(v20))
        v18 = u11
        v18(v17)
        v19 = u7
        v20 = u12
        v20 = v20.GetRelicInfo
        v21 = mMovie
        v23 = true
        v24 = u13
        v20 = v20(v21, v2, v23, v24)
        v18 = v19 .. v20
        u7 = v18
      end
      if p738 == 100 then
        if not v13 then
          p738 = 102
        else
          p738 = 101
        end
      end
      if p738 == 101 then
        v22 = mMovie
        v24 = "/Lotus/Language/Menu/Blueprint_UnlimitedCharges"
        v25 = true
        v18 = v22:GetLocalized(v24, v25)
        v19 = "<br>"
        v20 = u7
        v21 = mMovie
        v23 = u1
        v23 = v23.Description
        v24 = false
        v21 = v21:GetLocalized(v23, v24)
        v17 = v18 .. v19 .. v20 .. v21
        u7 = v17
      end
      if p738 == 102 then
        v18 = u1
        v18 = v18.mMod
        v17 = IsNull
        v17 = v17(v18)
        if not v17 then
        else
          p738 = 103
        end
      end
      if p738 == 103 then
        v17 = u6
        v17 = v17.Ternary
        v19 = u1
        v19 = v19.LocalizedDesc
        if v19 ~= nil then
          p738 = 105
        else
          p738 = 104
        end
      end
      if p738 == 104 then
        v18 = false
        p738 = 106
      end
      if p738 == 105 then
        v18 = true
        p738 = 106
      end
      if p738 == 106 then
        v19 = u1
        v19 = v19.LocalizedDesc
        v20 = mMovie
        v22 = u1
        v22 = v22.Description
        v23 = false
        v17 = v17(v18, v19, v20:GetLocalized(v22, v23))
        v19 = u7
        v18 = v19 .. v17
        u7 = v18
      end
    end
    v18 = u1
    v18 = v18.MergeDesc
    v17 = #v18
    v18 = 0
    if v18 < v17 then
      v18 = u7
      v17 = #v18
      v18 = 0
      if v18 < v17 then
        v18 = u7
        v19 = "<br><br>"
        v17 = v18 .. v19
        u7 = v17
      end
      v18 = u7
      v19 = u1
      v19 = v19.MergeDesc
      v17 = v18 .. v19
      u7 = v17
    end
    v18 = u1
    v18 = v18.ListItems
    v17 = #v18
    v18 = 0
    v17 = ""
    v18 = ipairs
    v19 = u1
    v19 = v19.ListItems
    v18, v19, v20 = v18(v19)
    for v21, v22 in v18, v19, v20 do
      v24 = v22.Label
      v23 = #v24
      v24 = 0
      if v24 < v23 then
        v23 = #v17
        v24 = 0
        if v24 < v23 then
          v24 = "<br>"
          v17 = v17 .. v24
        end
        v24 = v22.Label
        v17 = v17 .. v24
      end
      v24 = v22.Desc
      v23 = #v24
      v24 = 0
      if v24 < v23 then
        v24 = "<font color=\""
        v25 = u9
        v25 = v25.ContentHex
        v26 = "\">"
        v17 = v17 .. v24 .. v25 .. v26
        v25 = 1
        v26 = v22.Desc
        v23 = #v26
        v24 = 1
        for v25 = v25, v23, v24 do
          v27 = "<br>     "
          v29 = v22.Desc
          v28 = v29[v25]
          v17 = v17 .. v27 .. v28
        end
        if c753 ~= -1 then break end
        v24 = "</font>"
        v17 = v17 .. v24
      end
    end
    if c753 ~= -1 then break end
    v18 = #v17
    v19 = 0
    if v19 < v18 then
      v19 = u7
      v18 = #v19
      v19 = 0
      if v19 < v18 then
        v19 = u7
        v20 = "<br><br>"
        v18 = v19 .. v20
        u7 = v18
      end
      v19 = u7
      v20 = "<font color=\""
      v21 = u9
      v21 = v21.FloatingContentHex
      v22 = "\">"
      v24 = "</font>"
      v18 = v19 .. v20 .. v21 .. v22 .. v17 .. v24
      u7 = v18
    end
    for v21, v22 in v18, v19, v20 do
    end
    if c753 ~= -1 then break end
    v17 = u1
    v17 = v17.SalvageTimeRemaining
    if v17 ~= nil then
      v17 = Engine.Name__b38e1642
      v18 = u1
      v18 = v18.SalvageTimeRemaining
      v17 = v17(v18)
      v18 = 0
      if v18 < v17 then
        v18 = u8
        v18 = v18.GetTwitterStyleTime
        v20 = true
        v21 = true
        v18 = v18(v17, v20, v21)
        v19 = mMovie
        v21 = "/Lotus/Language/Railjack/SalvageTimeRemaining"
        v22 = true
        v23 = { REPAIR_TIME = nil }
        v23.REPAIR_TIME = v18
        v19 = v19:GetLocalized(v21, v22, v23)
        v21 = "<font color=\""
        v22 = u9
        v22 = v22.FloatingContentHex
        v23 = "\">"
        v25 = "</font>"
        v26 = "<br>"
        v27 = u7
        v20 = v21 .. v22 .. v23 .. v19 .. v25 .. v26 .. v27
        u7 = v20
      else
        v19 = "<font color=\""
        v20 = u9
        v20 = v20.FloatingContentHex
        v21 = "\">"
        v26 = mMovie
        v28 = "/Lotus/Language/Railjack/SalvageReadyToClaim"
        v29 = true
        v22 = v26:GetLocalized(v28, v29)
        v23 = "</font>"
        v24 = "<br>"
        v25 = u7
        v18 = v19 .. v20 .. v21 .. v22 .. v23 .. v24 .. v25
        u7 = v18
      end
    end
    v17 = u1
    v17 = v17.ShowDucatTag
    if v17 == nil then
      v17 = IsNull
      v17 = v17(v2)
      if not v17 then
        v17 = u1
        v18 = v2:Name__2159a733()
        v17.PrimePrice = v18
      end
      v17 = u1
      v17 = v17.PrimePrice
      if v17 then
        v17 = u1
        v17 = v17.PrimePrice
        v18 = 0
        if v18 < v17 then
          v17 = u7
          if v17 ~= "" then
            v18 = u7
            v19 = "<br><br>"
            v17 = v18 .. v19
            u7 = v17
          end
          v18 = u7
          v19 = mMovie
          v21 = "/Lotus/Language/Menu/Global_ValuePrimeBucks"
          v22 = true
          v23 = { COST = nil }
          v24 = u1
          v24 = v24.PrimePrice
          v23.COST = v24
          v19 = v19:GetLocalized(v21, v22, v23)
          v17 = v18 .. v19
          u7 = v17
        end
      end
    end
    v17 = u7
    if not ((v17 == "" or v3 == "")) then
      v18 = u7
      v17 = string.len
      v17 = v17(v18)
      u14 = v17
    end
    v17 = false
    v18 = false
    v19 = false
    v20 = u1
    v20 = v20.IngredientOverride
    if v20 == nil then
      c753 = 145
    else
      c753 = 142
    end
    do break end
    break
  until true
  if c753 == 142 then
    v17 = true
    v20 = u15
    v22 = true
    v23 = true
    v20:RemoveElements(v22, v23)
    v22 = 1
    v23 = u1
    v23 = v23.IngredientOverride
    v20 = #v23
    v21 = 1
    for v22 = v22, v20, v21 do
      v23 = u15
      v26 = u1
      v26 = v26.IngredientOverride
      v25 = v26[v22]
      v26 = true
      v23:AddElement(v25, v26)
    end
    v20 = u15
    v22 = nil
    v23 = nil
    v24 = true
    v20:Redraw(v22, v23, v24)
  elseif c753 == 145 then
    local p752 = 145
    if p752 == 145 then
      v20 = IsNull
      v20 = v20(v2)
      if v20 then
        p752 = 202
      else
        p752 = 146
      end
    end
    if p752 == 146 then
      v22 = gRecipeStoreItemType
      v20 = v2:IsA(v22)
      if not v20 then
        p752 = 202
      else
        p752 = 147
      end
    end
    if p752 == 147 then
      v20 = u1
      v20 = v20.HideRecipe
      if v20 then
        p752 = 202
      else
        p752 = 148
      end
    end
    if p752 == 148 then
      v21 = _T
      v23 = "InfoPopup_Data"
      v24 = u16
      v22 = v23 .. v24
      v20 = v21[v22]
      if not v20 then
        p752 = 178
      else
        p752 = 149
      end
    end
    if p752 == 149 then
      v21 = v20.NumPortals
      if v21 == nil then
        p752 = 178
      else
        p752 = 150
      end
    end
    if p752 == 150 then
      v22 = _T.DojoMgr
      v21 = IsNull
      v21 = v21(v22)
      if v21 then
        p752 = 178
      else
        p752 = 151
      end
    end
    if p752 == 151 then
      v21 = v20.Recipe
      v21 = v21:Name__b7a123a6()
      v23 = v20.NumPortals
      if v23 == 1 then
        p752 = 153
      else
        p752 = 152
      end
    end
    if p752 == 152 then
      v22 = mMovie
      v24 = "/Lotus/Language/Dojo/NumberOfDoors"
      v25 = false
      v26 = { DOORS = nil }
      v27 = v20.NumPortals
      v26.DOORS = v27
      v22 = v22:GetLocalized(v24, v25, v26)
      if v22 then
        p752 = 154
      else
        p752 = 153
      end
    end
    if p752 == 153 then
      v22 = mMovie
      v24 = "/Lotus/Language/Dojo/OneDoor"
      v25 = false
      v26 = nil
      v22 = v22:GetLocalized(v24, v25, v26)
      p752 = 154
    end
    if p752 == 154 then
      v23 = v20.NumPortals
      v24 = 1
      if v23 <= v24 then
        v24 = " / "
        v25 = mMovie
        v27 = "/Lotus/Language/Dojo/DeadEndWarning"
        v28 = false
        v29 = nil
        v25 = v25:GetLocalized(v27, v28, v29)
        v22 = v22 .. v24 .. v25
      end
      v23 = 0
      if v23 < v21 then
        v24 = "/Lotus/Language/Clan/Tier"
        v26 = "Name"
        v23 = v24 .. v21 .. v26
        v24 = { TierClanSize = nil, TierName = nil }
        v25 = gGameConfig
        v25 = v25:Name__55bcce29(v21)
        v24.TierClanSize = v25
        v25 = mMovie
        v28 = false
        v25 = v25:GetLocalized(v23, v28)
        v24.TierName = v25
        v25 = mMovie
        v27 = v20.Recipe
        v27 = v27:GetLocalizeDescTag()
        v27 = v27:c_str()
        v28 = true
        v25 = v25:GetLocalized(v27, v28, v24)
        u7 = v25
      end
      v24 = "<font color=\""
      v25 = u9
      v25 = v25.FloatingContentHighlightHex
      v26 = "\">"
      v28 = "</font>"
      v29 = "<br>"
      v30 = u7
      v31 = "<br><br><font color=\""
      v32 = u9
      v32 = v32.FloatingContentHighlightHex
      v33 = "\">"
      v36 = mMovie
      v38 = "/Lotus/Language/Dojo/RequireLabel"
      v39 = true
      v34 = v36:GetLocalized(v38, v39)
      v35 = "<br></font>"
      v23 = v24 .. v25 .. v26 .. v22 .. v28 .. v29 .. v30 .. v31 .. v32 .. v33 .. v34 .. v35
      u7 = v23
      v23 = gGameRules
      v23 = v23:GetDojoRecipeManifest()
      v24 = gGameRules
      v24 = v24:GetStoreManifest()
      v25 = v20.Recipe
      v25 = v25:GetPrerequisites()
      v17 = true
      v26 = u15
      v28 = true
      v29 = true
      v26:RemoveElements(v28, v29)
      v26 = IsNull
      v26 = v26(v25)
      if v24 < v23 then
        v26 = #v25
        v27 = 0
        if v27 < v26 then
          v28 = 1
          v26 = #v25
          v27 = 1
          for v28 = v28, v26, v27 do
            v29 = v25[v28]
            v32 = 1
            v30 = #v29
            v31 = 1
            for v32 = v32, v30, v31 do
              v34 = v29[v32]
              v33 = IsNull
              v33 = v33(v34)
              if not v33 then
                v35 = v29[v32]
                v33 = v23:Name__b7399832(v35)
                v34 = IsNull
                v34 = v34(v33)
                if not v34 then
                  v36 = WeakResource
                  v34 = v24:GetStoreItem(v36(v33:GetFullName()))
                  v35 = u12
                  v35 = v35.GetStoreItemInfo
                  v36 = mMovie
                  v38 = nil
                  v39 = nil
                  v40 = nil
                  v41 = true
                  v35 = v35(v36, v34, v38, v39, v40, v41)
                  v36 = true
                  v35.HideCount = v36
                  v36 = 1
                  v35.Req = v36
                  v36 = u6
                  v36 = v36.Ternary
                  v37 = _T.DojoMgr.mDojo
                  v37 = v37:Name__b0f5b417(v29)
                  v38 = 1
                  v39 = 0
                  v36 = v36(v37, v38, v39)
                  v35.Count = v36
                  v36 = mMovie
                  v38 = v34:GetLocalizeTag()
                  v38 = v38:c_str()
                  v39 = false
                  v36 = v36:GetLocalized(v38, v39)
                  v35.Name = v36
                  v36 = v20.InfoMaterial
                  v35.Material = v36
                  v36 = u15
                  v39 = true
                  v36:AddElement(v35, v39)
                end
              end
            end
          end
        end
      end
      v27 = v20.Recipe
      v27 = v27:DisableModeActionDMTWEAK()
      v26 = -v27
      v27 = _T.DojoMgr.mDojo
      v27 = v27:DisableModeActionDMTWEAK()
      v28 = { Icon = nil, TintIconColor = nil, Themed = true, Req = 1, Count = nil, SubText = nil }
      v29 = capacityIcon
      v28.Icon = v29
      v29 = u9
      v29 = v29.FloatingContent
      v28.TintIconColor = v29
      v29 = u6
      v29 = v29.Ternary
      if v27 < v26 then
        v30 = false
      else
        v30 = true
      end
      v31 = 1
      v32 = 0
      v29 = v29(v30, v31, v32)
      v28.Count = v29
      v29 = mMovie
      v31 = "/Lotus/Language/Dojo/AvailableLabel"
      v32 = false
      v33 = { COUNT = nil }
      v33.COUNT = v27
      v29 = v29:GetLocalized(v31, v32, v33)
      v28.SubText = v29
      v29 = ""
      v30 = 0
      if v26 < v30 then
        v26 = -v26
        v30 = mMovie
        v32 = "<UPARROW>"
        v33 = true
        v29 = v30:GetLocalized(v32, v33)
      end
      v35 = mMovie
      v37 = "/Lotus/Language/Dojo/CapacityLabel"
      v38 = false
      v31 = v35:GetLocalized(v37, v38)
      v32 = " "
      v30 = v31 .. v32 .. v26 .. v29
      v28.Name = v30
      v30 = u15
      v33 = true
      v30:AddElement(v28, v33)
      v31 = v20.Recipe
      v31 = v31:GetEnergy()
      v30 = -v31
      v31 = _T.DojoMgr.mDojo
      v31 = v31:GetEnergy()
      v32 = { Icon = nil, TintIconColor = nil, Themed = true, Req = 1, Count = nil, SubText = nil }
      v33 = energyIcon
      v32.Icon = v33
      v33 = u9
      v33 = v33.FloatingContent
      v32.TintIconColor = v33
      v33 = u6
      v33 = v33.Ternary
      if v31 < v30 then
        v34 = false
      else
        v34 = true
      end
      v35 = 1
      v36 = 0
      v33 = v33(v34, v35, v36)
      v32.Count = v33
      v33 = mMovie
      v35 = "/Lotus/Language/Dojo/AvailableLabel"
      v36 = false
      v37 = { COUNT = nil }
      v37.COUNT = v31
      v33 = v33:GetLocalized(v35, v36, v37)
      v32.SubText = v33
      v29 = ""
      v33 = 0
      if v30 < v33 then
        v30 = -v30
        v33 = mMovie
        v35 = "<UPARROW>"
        v36 = true
        v29 = v33:GetLocalized(v35, v36)
      end
      v38 = mMovie
      v40 = "/Lotus/Language/Dojo/EnergyLabel"
      v41 = false
      v34 = v38:GetLocalized(v40, v41)
      v35 = " "
      v33 = v34 .. v35 .. v30 .. v29
      v32.Name = v33
      v33 = u15
      v36 = true
      v33:AddElement(v32, v36)
      v33 = u15
      v35 = nil
      v36 = nil
      v37 = true
      v33:Redraw(v35, v36, v37)
    end
    if p752 == 178 then
      local p741 = 178
      if p741 == 178 then
        if not v20 then
          p741 = 199
        else
          p741 = 179
        end
      end
      if p741 == 179 then
        v21 = v20.Capacity
        if v21 == nil then
          p741 = 199
        else
          p741 = 180
        end
      end
      if p741 == 180 then
        v22 = _T.DojoMgr
        v21 = IsNull
        v21 = v21(v22)
        if v21 then
          p741 = 199
        else
          p741 = 181
        end
      end
      if p741 == 181 then
        v17 = true
        v21 = u15
        v23 = true
        v24 = true
        v21:RemoveElements(v23, v24)
        v21 = 0
        v22 = _T.ComponentParams
        if v22 ~= nil then
          v22 = _T.DojoMgr.mDojo
          v24 = _T.ComponentParams
          v22 = v22:GetJsonComponent(v24)
          v21 = v22:Name__3a074c8c()
        end
        v23 = v20.IsNpcDeco
        if v23 then
          v22 = "/Lotus/Language/DojoDecosNpcs/CapacityLabelNpc"
        else
          v22 = "/Lotus/Language/Dojo/CapacityLabel"
        end
        v23 = { Icon = nil, TintIconColor = nil, Themed = true, Name = nil, Req = 1, Count = nil, SubText = nil }
        v24 = capacityIcon
        v23.Icon = v24
        v24 = u9
        v24 = v24.FloatingContent
        v23.TintIconColor = v24
        v28 = mMovie
        v31 = false
        v25 = v28:GetLocalized(v22, v31)
        v26 = " "
        v27 = v20.Capacity
        v24 = v25 .. v26 .. v27
        v23.Name = v24
        v24 = u6
        v24 = v24.Ternary
        v26 = v20.Capacity
        if v21 < v26 then
          v25 = false
        else
          v25 = true
        end
        v26 = 1
        v27 = 0
        v24 = v24(v25, v26, v27)
        v23.Count = v24
        v24 = mMovie
        v26 = "/Lotus/Language/Dojo/AvailableLabel"
        v27 = false
        v28 = { COUNT = nil }
        v28.COUNT = v21
        v24 = v24:GetLocalized(v26, v27, v28)
        v23.SubText = v24
        v24 = u15
        v27 = true
        v24:AddElement(v23, v27)
        v24 = u15
        v26 = nil
        v27 = nil
        v28 = true
        v24:Redraw(v26, v27, v28)
        v24 = v20.HideRecipe
        if v22 == nil then
          v25 = v20.Recipe
          v24 = IsNull
          v24 = v24(v25)
          if not v24 then
            v18 = true
            v24 = u17
            v26 = true
            v27 = true
            v24:RemoveElements(v26, v27)
            v24 = gGameRules
            v24 = v24:GetStoreManifest()
            v25 = ""
            v26 = v20.IsNpcDeco
            if v26 then
              v26 = "<p><font color=\""
              v27 = u9
              v27 = v27.FloatingContentHex
              v28 = "\">"
              v31 = mMovie
              v33 = "/Lotus/Language/DojoDecosNpcs/NpcRecipeComponents"
              v34 = false
              v29 = v31:GetLocalized(v33, v34)
              v30 = "</p>"
              v25 = v26 .. v27 .. v28 .. v29 .. v30
            else
              v30 = mMovie
              v32 = "<TIMER> "
              v33 = true
              v27 = v30:GetLocalized(v32, v33)
              v28 = " "
              v29 = u8
              v29 = v29.SecondsToFormattedTime
              v30 = mMovie
              v31 = v20.Recipe
              v31 = v31:GetBuildTime()
              v32 = "CompactHours"
              v29 = v29(v30, v31, v32)
              v26 = v27 .. v28 .. v29
              v27 = "<p><font color=\""
              v28 = u9
              v28 = v28.FloatingContentHex
              v29 = "\">"
              v36 = mMovie
              v38 = "/Lotus/Language/Menu/DetailedPurchase_BpAbout"
              v39 = false
              v30 = v36:GetLocalized(v38, v39)
              v31 = "<br><font color=\""
              v32 = u9
              v32 = v32.FloatingContentHighlightHex
              v33 = "\">"
              v35 = "</font></font></p>"
              v25 = v27 .. v28 .. v29 .. v30 .. v31 .. v32 .. v33 .. v26 .. v35
            end
            v26 = mMovie
            v28 = "Popup.IngredientsSeparator.Description"
            v29 = 36
            v26:SetStringVariable(v28, v29, v25)
            v26 = gGameConfig
            v28 = v20.Recipe
            v29 = v20.Recipe
            v29 = v29:GetBuildPrice()
            v30 = _T.DojoMgr.mGameRules
            v30 = v30:GetGuildTier()
            v31 = false
            v26 = v26:Name__4edc466d(v28, v29, v30, v31)
            v27 = 0
            if v27 < v26 then
              v27 = {}
              v28 = mMovie
              v30 = u18
              v30 = v30:GetLocalizeTag()
              v30 = v30:c_str()
              v31 = false
              v28 = v28:GetLocalized(v30, v31)
              v27.Name = v28
              v27.Req = v26
              v28 = u18
              v28 = v28:GetIconTexture()
              v27.Icon = v28
              v28 = true
              v27.Themed = v28
              v28 = u17
              v31 = true
              v28:AddElement(v27, v31)
            end
            v27 = v20.Recipe
            v27 = v27:GetIngredients()
            v30 = 1
            v28 = #v27
            v29 = 1
            for v30 = v30, v28, v29 do
              v31 = v27[v30]
              v34 = v31.mItemType
              v32 = v24:Name__1dc35bd2(v34)
              v33 = u12
              v33 = v33.GetStoreItemInfo
              v34 = mMovie
              v36 = nil
              v37 = nil
              v38 = nil
              v39 = true
              v33 = v33(v34, v32, v36, v37, v38, v39)
              v34 = gGameConfig
              v36 = v20.Recipe
              v37 = v27[v30]
              v37 = v37.mItemCount
              v38 = _T.DojoMgr.mGameRules
              v38 = v38:GetGuildTier()
              v39 = false
              v34 = v34:Name__4edc466d(v36, v37, v38, v39)
              v33.Req = v34
              v34 = u17
              v37 = true
              v34:AddElement(v33, v37)
            end
            v28 = u17
            v30 = nil
            v31 = nil
            v32 = true
            v28:Redraw(v30, v31, v32)
          end
        end
      end
      if p741 == 199 then
        v22 = gGameRules
        v21 = IsNull
        v21 = v21(v22)
        if v21 then
        else
          p741 = 200
        end
      end
      if p741 == 200 then
        v21 = gGameRules
        v23 = gLotusGameRulesType
        v21 = v21:IsA(v23)
        if v21 then
        else
          p741 = 201
        end
      end
      if p741 == 201 then
        v21 = u19
        v17, v19 = v21()
      end
    end
    if p752 == 202 then
      v20 = u1
      v20 = v20.Capacity
      if v20 == nil then
      else
        p752 = 203
      end
    end
    if p752 == 203 then
      v20 = gRegion
      v20 = v20:GetLocalPlayerAvatar()
      v21 = IsNull
      v21 = v21(v20)
      if v21 then
      else
        p752 = 204
      end
    end
    if p752 == 204 then
      v17 = true
      v21 = u15
      v23 = true
      v24 = true
      v21:RemoveElements(v23, v24)
      v21 = { availableCapacity = 0, capacityParams = nil }
      v23 = _T.DojoMgr
      v22 = IsNull
      v22 = v22(v23)
      if not v22 then
        p752 = 206
      else
        p752 = 205
      end
    end
    if p752 == 205 then
      v22 = u20
      v22 = v22.GetShipDecoRoom
      v22 = v22()
      v21.capacityParams = v22
      v22 = u20
      v22 = v22.GetShipDecoBootLocation
      v22 = v22()
      v23 = gGameData
      v25 = v21.capacityParams
      v23 = v23:Name__64c9c8f8(v25, v22)
      v21.availableCapacity = v23
      p752 = 207
    end
    if p752 == 206 then
      v22 = _T.DojoMgr
      v24 = v20:GetZone()
      v22 = v22:BuildComponentParams(v24:GetAttribs())
      v21.capacityParams = v22
      v22 = _T.DojoMgr.mDojo
      v24 = v21.capacityParams
      v22 = v22:GetJsonComponent(v24)
      v22 = v22:Name__3a074c8c()
      v21.availableCapacity = v22
      p752 = 207
    end
    if p752 == 207 then
      v22 = { Icon = nil, TintIconColor = nil, Themed = true, Name = nil, Req = 1, Count = nil, SubText = nil }
      v23 = capacityIcon
      v22.Icon = v23
      v23 = u9
      v23 = v23.FloatingContent
      v22.TintIconColor = v23
      v27 = mMovie
      v29 = "/Lotus/Language/Dojo/CapacityLabel"
      v30 = false
      v24 = v27:GetLocalized(v29, v30)
      v25 = " "
      v26 = u1
      v26 = v26.Capacity
      v23 = v24 .. v25 .. v26
      v22.Name = v23
      v23 = u6
      v23 = v23.Ternary
      v25 = u1
      v25 = v25.Capacity
      v26 = v21.availableCapacity
      if v25 <= v26 then
        p752 = 209
      else
        p752 = 208
      end
    end
    if p752 == 208 then
      v24 = false
      p752 = 210
    end
    if p752 == 209 then
      v24 = true
      p752 = 210
    end
    if p752 == 210 then
      v25 = 1
      v26 = 0
      v23 = v23(v24, v25, v26)
      v22.Count = v23
      v23 = mMovie
      v25 = "/Lotus/Language/Dojo/AvailableLabel"
      v26 = false
      v27 = { COUNT = nil }
      v28 = v21.availableCapacity
      v27.COUNT = v28
      v23 = v23:GetLocalized(v25, v26, v27)
      v22.SubText = v23
      v23 = u15
      v26 = true
      v23:AddElement(v22, v26)
      v23 = u15
      v25 = nil
      v26 = nil
      v27 = true
      v23:Redraw(v25, v26, v27)
    end
  end
  v21 = u1
  v21 = v21.CodexEntry
  v20 = IsNull
  v20 = v20(v21)
  if not v20 then
    v21 = u7
    v20 = string.len
    v20 = v20(v21)
    v21 = 0
    if v21 < v20 then
      v21 = u7
      v21 = v21:sub(v20, v20)
      if v21 ~= "\r" then
        v23 = u7
        v24 = "\r"
        v22 = v23 .. v24
        u7 = v22
      end
    end
    v22 = u7
    v23 = u21
    v23 = v23.GetEnemyInfoText
    v24 = mMovie
    v25 = u1
    v25 = v25.CodexEntry
    v26 = u9
    v26 = v26.FloatingContentHighlightHex
    v27 = u9
    v27 = v27.ContentHex
    v28 = u1
    v28 = v28.SkipFaction
    v29 = u1
    v29 = v29.SkipRegions
    v30 = u1
    v30 = v30.SkipEnemyDesc
    v23 = v23(v24, v25, v26, v27, v28, v29, v30)
    v21 = v22 .. v23
    u7 = v21
  end
  v20 = IsNull
  v20 = v20(v16)
  if v20 then
    v22 = Name__d7185637
    v20 = v16:IsA(v22)
    if v20 then
      v21 = u1
      v21 = v21.mMod
      v20 = IsNull
      v20 = v20(v21)
      if v20 then
        v20 = u12
        v20 = v20.GetBoosterPackInfo
        v21 = mMovie
        v22 = Resource
        v22 = v22(v16)
        v23 = true
        v24 = true
        v20, v21, v22 = v20(v21, v22, v23, v24)
        if v21 ~= nil then
          v23 = u22
          if not v23 then
            v23 = u10
            v25 = { State = nil }
            v26 = u23
            v26 = v26.BASE
            v25.State = v26
            v23:AddElement(v25)
            v23 = u24
            v23()
          end
        end
        v23 = u10
        v23 = v23.mCurrentElementIndex
        if v23 == 1 then
          v24 = u7
          v23 = v24 .. v20
          u7 = v23
        else
          if v21 ~= nil then
            v24 = u7
            v23 = v24 .. v21
            u7 = v23
          end
        end
        v23 = true
        u22 = v23
      end
    end
  end
  v20 = IsNull
  v20 = v20(v0)
  if not v20 then
    v20 = IsNull
    v20 = v20(v2)
    if not v20 then
      v20 = v2:IsPackage()
      if v20 then
        v20 = u12
        v20 = v20.GetPackageContentsDesc
        v21 = mMovie
        v23 = v0.PurchasedItems
        v24 = true
        v25 = u9
        v25 = v25.FloatingContentHighlightHex
        v26 = u9
        v26 = v26.Background4Hex
        v27 = u9
        v27 = v27.FloatingContentHex
        v28 = 18
        v20 = v20(v21, v2, v23, v24, v25, v26, v27, v28)
        v21 = u7
        if not ((v21 == "" or v20 == "")) then
          v22 = u7
          v23 = "<br><br>"
          v21 = v22 .. v23
          u7 = v21
        end
        v22 = u7
        v21 = v22 .. v20
        u7 = v21
      end
    end
    v20 = nil
    v22 = gGameRules
    v21 = IsNull
    v21 = v21(v22)
    if not v21 then
      v22 = gGameData
      v21 = IsNull
      v21 = v21(v22)
      if not v21 then
        v21 = nil
        v22 = nil
        v23 = u12
        v23 = v23.GetCompatWarning
        v24 = mMovie
        v26 = gGameRules
        v26 = v26:GetStoreManifest()
        v27 = gGameData
        v27 = v27:GetInventory()
        v28 = { Items = nil, Dictionary = nil }
        v29 = v0.PurchasedItems
        v28.Items = v29
        v29 = v0.PurchasedIsDictionary
        v28.Dictionary = v29
        v29 = true
        v21, v20, v22 = v23(v24, v2, v26, v27, v28, v29)
      end
    end
    if v20 then
      v21 = u7
      if v21 ~= "" then
        v22 = u7
        v23 = "<br><br>"
        v21 = v22 .. v23
        u7 = v21
      end
      v22 = u7
      v26 = mMovie
      v28 = "<WARNING>"
      v29 = true
      v23 = v26:GetLocalized(v28, v29)
      v24 = " "
      v21 = v22 .. v23 .. v24 .. v20
      u7 = v21
    end
  end
  v20 = u1
  v20 = v20.mModDescOverride
  if v20 then
    v27 = u7
    v28 = "<br>"
    v26 = v27 .. v28
    u7 = v26
  end
  if v20 then
    v21 = u7
    v22 = u1
    v22 = v22.mModDescOverride
    v20 = v21 .. v22
    u7 = v20
  else
    v21 = u7
    v22 = u1
    v22 = v22.mMod
    v22 = v22.Card
    v22 = v22.mDesc
    v20 = v21 .. v22
    u7 = v20
    v20 = u12
    v20 = v20.GetUpgradeInfo
    v21 = mMovie
    v23 = u9
    v23 = v23.FloatingContentHighlightHex
    v24 = u9
    v24 = v24.ContentHex
    v25 = nil
    v26 = ""
    v27 = u1
    v27 = v27.RawItem
    v20 = v20(v21, v2, v23, v24, v25, v26, v27)
    v21 = mMovie
    v23 = "Popup.Description"
    v24 = 36
    v26 = "<p><font color=\""
    v27 = u9
    v27 = v27.ContentHex
    v28 = "\">"
    v30 = "</font></p>"
    v25 = v26 .. v27 .. v28 .. v20 .. v30
    v21:SetStringVariable(v23, v24, v25)
    v21 = mMovie
    v23 = "Popup.Description"
    v24 = 41
    v21 = v21:GetNumberVariable(v23, v24)
    v22 = mMovie
    v22 = v22:GetMovieHeight()
    v24 = 0.8
    v23 = v22 * v24
    if v23 < v21 then
      v23 = u12
      v23 = v23.GetUpgradeInfo
      v24 = mMovie
      v26 = u9
      v26 = v26.FloatingContentHighlightHex
      v27 = u9
      v27 = v27.ContentHex
      v28 = nil
      v29 = ""
      v30 = u1
      v30 = v30.RawItem
      v31 = true
      v32 = "<br><br>...<br><br>"
      v20 = v23(v24, v2, v26, v27, v28, v29, v30, v31, v32)
    end
    v24 = u7
    v23 = v24 .. v20
    u7 = v23
    local p742 = 273
    if p742 == 273 then
      v24 = u1
      v24 = v24.ShowAllRanks
      if v24 then
        p742 = 275
      else
        p742 = 274
      end
    end
    if p742 == 274 then
      v24 = u1
      v24 = v24.ShowFirstLastRank
      if not v24 then
        p742 = 276
      else
        p742 = 275
      end
    end
    if p742 == 275 then
      v25 = u7
      v26 = u12
      v26 = v26.GetUpgradeInfo
      v27 = mMovie
      v29 = u9
      v29 = v29.FloatingContentHighlightHex
      v30 = u9
      v30 = v30.FloatingContentHex
      v31 = " "
      v32 = ""
      v33 = nil
      v34 = u1
      v34 = v34.ShowFirstLastRank
      v26 = v26(v27, v2, v29, v30, v31, v32, v33, v34)
      v24 = v25 .. v26
      u7 = v24
    end
    if p742 == 276 then
      v25 = u7
      v26 = "<font color=\""
      v27 = u9
      v27 = v27.FloatingContentHighlightHex
      v28 = "\">"
      v35 = string.upper
      v29 = v35(v21)
      v30 = "</font><font color=\""
      v31 = u9
      v31 = v31.FloatingContentHex
      v32 = "\">"
      v34 = "</font>"
      v24 = v25 .. v26 .. v27 .. v28 .. v29 .. v30 .. v31 .. v32 .. v22 .. v34
      u7 = v24
    end
  end
  v20 = u1
  v20 = v20.StatId
  if v23 <= v24 then
    v26 = "<br><font color=\""
    v27 = u9
    v27 = v27.FloatingContentHighlightHex
    v28 = "\">"
    v32 = mMovie
    v34 = "/Lotus/Language/Stats/StatusEffectTitle"
    v35 = false
    v29 = v32:GetLocalized(v34, v35)
    v30 = "</font><br>"
    v31 = u7
    v24 = v23 .. v26 .. v27 .. v28 .. v29 .. v30 .. v31
    u7 = v24
  end
  v21 = u3
  if v21 <= v5 then
    v20 = false
  else
    v20 = true
  end
  if not v20 then
    v22 = u3
    v23 = 11
    v21 = v22 - v23
    u3 = v21
  else
    v22 = u3
    v23 = 6
    v21 = v22 + v23
    u3 = v21
  end
  v21 = mMovie
  v23 = "Popup.TagSeparator"
  v24 = 1
  v25 = u3
  v21:SetNumberVariable(v23, v24, v25)
  v21 = u1
  v21 = v21.CustomEntry
  if v21 then
    v21 = u1
    v21 = v21.RankedProgress
    if v21 ~= nil then
      v21 = u27
      v21 = v21.DrawRankIndicator
      v22 = mMovie
      v23 = "Popup.RankedProgress.Rank"
      v24 = { Level = nil }
      v25 = u1
      v25 = v25.RankedProgress
      v25 = v25.Rank
      v24.Level = v25
      v21(v22, v23, v24)
      v21 = mMovie
      v23 = "Popup.RankedProgress.Bar.Fill"
      v24 = _G
      v24 = v24.UIMaterial_RectangleNoDepth
      v21:OverrideMaterial(v23, v24)
      v21 = mMovie
      v23 = "Popup.RankedProgress.Bar.Bg"
      v24 = _G
      v24 = v24.UIMaterial_RectangleNoDepth
      v21:OverrideMaterial(v23, v24)
      v21 = mMovie
      v23 = "Popup.RankedProgress.Title"
      v24 = 44
      v25 = u9
      v25 = v25.FloatingContent
      v21:SetNumberVariable(v23, v24, v25)
      v21 = mMovie
      v23 = "Popup.RankedProgress.Progress"
      v24 = 44
      v25 = u9
      v25 = v25.FloatingContentHighlight
      v21:SetNumberVariable(v23, v24, v25)
      v21 = u9
      v21 = v21.Background1RGB
      v22 = u9
      v22 = v22.FloatingContentRGB
      v23 = mMovie
      v25 = "Popup.RankedProgress.Bar.Fill"
      v26 = "RectInnerColor"
      v27 = v22.r
      v28 = v22.g
      v29 = v22.b
      v30 = 1
      v23:Name__e243d995(v25, v26, v27, v28, v29, v30)
      v23 = mMovie
      v25 = "Popup.RankedProgress.Bar.Fill"
      v26 = "RectEdgeColor"
      v27 = v22.r
      v28 = v22.g
      v29 = v22.b
      v30 = 1
      v23:Name__e243d995(v25, v26, v27, v28, v29, v30)
      v23 = mMovie
      v25 = "Popup.RankedProgress.Bar.Bg"
      v26 = "RectInnerColor"
      v27 = v21.r
      v28 = v21.g
      v29 = v21.b
      v30 = 0
      v23:Name__e243d995(v25, v26, v27, v28, v29, v30)
      v23 = mMovie
      v25 = "Popup.RankedProgress.Bar.Bg"
      v26 = "RectEdgeColor"
      v27 = v22.r
      v28 = v22.g
      v29 = v22.b
      v30 = 1
      v23:Name__e243d995(v25, v26, v27, v28, v29, v30)
      v23 = mMovie
      v25 = "Popup.RankedProgress.Bar.Bg"
      v26 = 14
      v27 = 256
      v23:SetNumberVariable(v25, v26, v27)
      v23 = mMovie
      v25 = "Popup.RankedProgress.Bar.Fill"
      v26 = 14
      v29 = 252
      v32 = u1
      v32 = v32.RankedProgress
      v32 = v32.Progress
      v33 = u1
      v33 = v33.RankedProgress
      v33 = v33.Required
      v31 = math.min
      v31 = v31(v32, v33)
      v32 = u1
      v32 = v32.RankedProgress
      v32 = v32.Required
      v30 = v31 / v32
      v28 = v29 * v30
      v29 = 0.1
      v27 = math.max
      v27 = v27(v28, v29)
      v23:SetNumberVariable(v25, v26, v27)
      v23 = mMovie
      v25 = "Popup.RankedProgress.Progress"
      v26 = 14
      v27 = 256
      v23:SetNumberVariable(v25, v26, v27)
      v23 = mMovie
      v25 = "Popup.RankedProgress.Title"
      v26 = 36
      v27 = u1
      v27 = v27.RankedProgress
      v27 = v27.Name
      v23:SetStringVariable(v25, v26, v27)
      v23 = mMovie
      v25 = "Popup.RankedProgress.Progress"
      v26 = 36
      v28 = u1
      v28 = v28.RankedProgress
      v28 = v28.ProgressPrefix
      v32 = u6
      v32 = v32.FormatNumber
      v33 = u1
      v33 = v33.RankedProgress
      v33 = v33.Progress
      v29 = v32(v33)
      v30 = "/"
      v31 = u6
      v31 = v31.FormatNumber
      v32 = u1
      v32 = v32.RankedProgress
      v32 = v32.Required
      v31 = v31(v32)
      v27 = v28 .. v29 .. v30 .. v31
      v23:SetStringVariable(v25, v26, v27)
      v23 = mMovie
      v25 = "Popup.RankedProgress"
      v26 = 13
      v27 = true
      v23:Name__d9713943(v25, v26, v27)
      v23 = mMovie
      v25 = "Popup.RankedProgress"
      v26 = 1
      v27 = u3
      v23:SetNumberVariable(v25, v26, v27)
      v24 = u3
      v25 = 64
      v23 = v24 + v25
      u3 = v23
    end
  end
  v22 = u1
  v22 = v22.PreviewImage
  if v22 == nil then
    v21 = false
  else
    v21 = true
  end
  if v5 < v21 then
    v22 = 185
    v23 = mMovie
    v25 = "Popup.VideoPreview"
    v26 = 1
    v27 = u3
    v23:SetNumberVariable(v25, v26, v27)
    v23 = mMovie
    v25 = "Popup.VideoPreview.Mask"
    v26 = 14
    v27 = 330
    v23:SetNumberVariable(v25, v26, v27)
    v23 = mMovie
    v25 = "Popup.VideoPreview.Mask"
    v26 = 15
    v23:SetNumberVariable(v25, v26, v22)
    v23 = u1
    v23 = v23.PreviewImage
    v25 = gVideoTextureType
    v23 = v23:IsA(v25)
    if v23 then
      v23 = mMovie
      v25 = "Popup.VideoPreview.Image"
      v26 = 1
      v27 = 0
      v23:SetNumberVariable(v25, v26, v27)
      v23 = mMovie
      v25 = "Popup.VideoPreview.Image"
      v26 = 14
      v27 = 330
      v23:SetNumberVariable(v25, v26, v27)
      v23 = mMovie
      v25 = "Popup.VideoPreview.Image"
      v26 = 15
      v23:SetNumberVariable(v25, v26, v22)
    else
      v23 = 330
      v24 = u1
      v24 = v24.PreviewImageHeightRatio
      if v24 then
        v25 = u1
        v25 = v25.PreviewImageHeightRatio
        v24 = tonumber
        v24 = v24(v25)
        v26 = 185
        v25 = v26 / v24
        v26 = 12
        v22 = v25 - v26
        v23 = v23 * v24
      end
      v24 = mMovie
      v26 = "Popup.VideoPreview.Image"
      v27 = 1
      v29 = u1
      v29 = v29.AbilityInitialized
      if v29 then
        v28 = -30
      else
        v30 = 330
        v29 = v22 - v30
        v30 = 2
        v28 = v29 / v30
      end
      v24:SetNumberVariable(v26, v27, v28)
      v24 = mMovie
      v26 = "Popup.VideoPreview.Image"
      v27 = 14
      v28 = 330
      v24:SetNumberVariable(v26, v27, v28)
      v24 = mMovie
      v26 = "Popup.VideoPreview.Image"
      v27 = 15
      v24:SetNumberVariable(v26, v27, v23)
      v24 = mMovie
      v26 = "Popup.VideoPreview.Image"
      v27 = parallaxIconMaterial
      v24:OverrideMaterial(v26, v27)
      v24 = mMovie
      v26 = "Popup.VideoPreview.Image"
      v27 = "DetailMapParams"
      v28 = 0
      v29 = 0
      v30 = 1
      v31 = 1
      v24:Name__e243d995(v26, v27, v28, v29, v30, v31)
      v24 = mMovie
      v26 = "Popup.VideoPreview.Image"
      v27 = "BlendOffsetParallax"
      v28 = 1
      v29 = 0.5
      v30 = 1
      v31 = 0.025
      v24:Name__e243d995(v26, v27, v28, v29, v30, v31)
      v24 = mMovie
      v26 = "Popup.VideoPreview.Image"
      v27 = "TintColor"
      v28 = 1
      v29 = 1
      v30 = 1
      v31 = 0
      v24:Name__e243d995(v26, v27, v28, v29, v30, v31)
      v25 = u1
      v25 = v25.AutoParallaxX
      if v25 then
        v24 = 1
      else
        v24 = 0
      end
      v26 = u1
      v26 = v26.AutoParallaxY
      if v26 then
        v25 = 1
      else
        v25 = 0
      end
      v26 = mMovie
      v28 = "Popup.VideoPreview.Image"
      v29 = "AutoOffsetParallax"
      v32 = 1
      v33 = 0
      v26:Name__e243d995(v28, v29, v24, v25, v32, v33)
    end
    v24 = IsWeak
    v25 = u1
    v25 = v25.PreviewImage
    v24 = v24(v25)
    v23 = not v24
    v24 = mMovie
    v26 = "Popup.VideoPreview.Image"
    v27 = 13
    v24:Name__d9713943(v26, v27, v23)
    if v23 then
      v24 = u1
      v24 = v24.SkipVideoReset
      if not v24 then
        v24 = mMovie
        v26 = "Popup.VideoPreview.Image"
        v24:StopVideoTexture(v26)
        v24 = mMovie
        v26 = "Popup.VideoPreview.Image"
        v27 = u1
        v27 = v27.PreviewImage
        v24:OverrideTexture(v26, v27)
        v24 = mMovie
        v26 = "Popup.VideoPreview.Image"
        v24:Name__f55ae1a2(v26)
      else
        v24 = mMovie
        v26 = "Popup.VideoPreview.Image"
        v27 = u1
        v27 = v27.PreviewImage
        v24:OverrideTexture(v26, v27)
        v24 = u1
        v25 = nil
        v24.SkipVideoReset = v25
      end
    else
      v24 = u28
      v26 = true
      v24:SetActive(v26)
      v24 = mMovie
      v26 = "Popup.Spinner"
      v27 = 1
      v29 = u29
      v30 = 93
      v28 = v29 + v30
      v24:SetNumberVariable(v26, v27, v28)
    end
    v24 = u1
    v24 = v24.PreviewImageHeightRatio
    if v24 then
      v22 = 185
    end
    v26 = u3
    v25 = v26 + v22
    v26 = 6
    v24 = v25 + v26
    u3 = v24
  else
    v23 = u3
    v24 = 10
    v22 = v23 + v24
    u3 = v22
  end
  v22 = mMovie
  v24 = "Popup.VideoPreview"
  v25 = 13
  v22:Name__d9713943(v24, v25, v21)
  v22 = mMovie
  v24 = "Popup.Description"
  v25 = 1
  v26 = u3
  v22:SetNumberVariable(v24, v25, v26)
  v22 = u14
  if v22 ~= 0 then
    v22 = "\r\n\r\n"
    v3 = v22 .. v3
  end
  v22 = u1
  v22 = v22.FontNameOverride
  if v22 then
    v22 = mMovie
    v24 = "Popup.Description"
    v25 = 49
    v26 = u1
    v26 = v26.FontNameOverride
    v22:SetStringVariable(v24, v25, v26)
  else
    v22 = mMovie
    v24 = "Popup.Description"
    v25 = 49
    v26 = "Roboto Regular"
    v22:SetStringVariable(v24, v25, v26)
  end
  v22 = u1
  v22 = v22.ReplaceAndReduceMissingChars
  if v22 then
    v22 = u0
    v22 = v22.ReplaceAndReduceMissingChars
    v23 = u7
    v22 = v22(v23)
    u7 = v22
    v22 = u0
    v22 = v22.ReplaceAndReduceMissingChars
    v3 = v22(v3)
  end
  if not v0 then
    v28 = u32
    if v7 < v28 then
      v29 = v7 + 1
      v30 = 2
      v28 = math.max
      v31 = v28(v29, v30)
      v29 = u32
      v30 = 1
      for v31 = v31, v29, v30 do
        v32 = FlashMethod
        v33 = mMovie
        v35 = "Popup.Affiliation"
        v37 = ".removeMovieClip"
        v34 = v35 .. v31 .. v37
        v32(v33, v34)
      end
    end
    v29 = 1
    v28 = math.max
    v28 = v28(v29, v7)
    u32 = v28
    v28 = ipairs
    v29 = u1
    v29 = v29.Affiliations
    v28, v29, v30 = v28(v29)
    for v31, v32 in v28, v29, v30 do
      v34 = "Popup.Affiliation"
      v33 = v34 .. v31
      v34 = mMovie
      v37 = 13
      v38 = true
      v34:Name__d9713943(v33, v37, v38)
      v34 = mMovie
      v37 = 1
      v38 = u3
      v34:SetNumberVariable(v33, v37, v38)
      v35 = v32.Level
      v36 = 0
      if v35 < v36 then
        v34 = false
      else
        v34 = true
      end
      v35 = mMovie
      v38 = "Border"
      v39 = 13
      v40 = false
      v35:Makeposshield(v33, v38, v39, v40)
      v35 = mMovie
      v38 = "Bg"
      v39 = 13
      v40 = false
      v35:Makeposshield(v33, v38, v39, v40)
      v35 = mMovie
      v38 = "Border"
      v39 = 14
      v40 = u5
      v35:Name__52c1b74e(v33, v38, v39, v40)
      v35 = mMovie
      v38 = "Bg"
      v39 = 14
      v40 = u5
      v35:Name__52c1b74e(v33, v38, v39, v40)
      v35 = mMovie
      v38 = "Border"
      v39 = 11
      v40 = u9
      v40 = v40.Background1
      v35:Name__52c1b74e(v33, v38, v39, v40)
      v35 = mMovie
      v39 = ".Bg"
      v37 = v33 .. v39
      v38 = midBgTexture
      v39 = midBgMaterial
      v35:Name__9c27ee88(v37, v38, v39)
      v35 = mMovie
      v39 = ".Bg"
      v37 = v33 .. v39
      v38 = "StartColor"
      v39 = u9
      v39 = v39.Background1RGB
      v39 = v39.r
      v40 = u9
      v40 = v40.Background1RGB
      v40 = v40.g
      v41 = u9
      v41 = v41.Background1RGB
      v41 = v41.b
      v42 = 1
      v35:Name__e243d995(v37, v38, v39, v40, v41, v42)
      v35 = u6
      v35 = v35.Ternary
      v37 = u9
      v37 = v37.PositiveRGB
      v38 = u9
      v38 = v38.NegativeRGB
      v35 = v35(v34, v37, v38)
      v36 = mMovie
      v40 = ".Bg"
      v38 = v33 .. v40
      v39 = "EndColor"
      v41 = v35.r
      v40 = v41 / 1
      v42 = v35.g
      v41 = v42 / 1
      v43 = v35.b
      v42 = v43 / 1
      v43 = 1
      v36:Name__e243d995(v38, v39, v40, v41, v42, v43)
      v36 = mMovie
      v40 = ".Icon"
      v38 = v33 .. v40
      v39 = v32.Icon
      v36:OverrideTexture(v38, v39)
      v36 = mMovie
      v39 = "Icon"
      v40 = 11
      v41 = u9
      v41 = v41.FloatingContentHighlight
      v36:Name__52c1b74e(v33, v39, v40, v41)
      v36 = mMovie
      v39 = "Name"
      v40 = 44
      v41 = u9
      v41 = v41.Content
      v36:Name__52c1b74e(v33, v39, v40, v41)
      v36 = mMovie
      v39 = "Label"
      v40 = 36
      v41 = v32.Label
      v36:Name__f4a9016a(v33, v39, v40, v41)
      v36 = mMovie
      v39 = "Label"
      v40 = 41
      v36 = v36:Name__46690123(v33, v39, v40)
      v37 = mMovie
      v40 = "Label"
      v41 = 1
      v43 = 36
      v45 = 2
      v44 = v36 / v45
      v42 = v43 - v44
      v37:Name__52c1b74e(v33, v40, v41, v42)
      v38 = u3
      v39 = u6
      v39 = v39.Ternary
      v42 = u1
      v42 = v42.Affiliations
      v41 = #v42
      if v31 == v41 then
        v40 = false
      else
        v40 = true
      end
      v41 = 70
      v42 = 60
      v39 = v39(v40, v41, v42)
      v37 = v38 + v39
      u3 = v37
    end
  end
  v28 = u1
  v28 = v28.IsAbility
  if v28 then
    v28 = u33
    v29 = u33
    v30 = u33
    v31 = u33
    v32 = u34
    v32 = v32.GetStatsTextForAbility
    v33 = u1
    v32, v33, v34, v35 = v32(v33)
    v28.Labels = v32
    v29.Values = v33
    v30.BaseValues = v34
    v31.StatChanges = v35
  else
    v28 = u1
    v28 = v28.mDisplayStats
    if v28 ~= nil then
      v28 = u1
      v28 = v28.mDisplayStats
      u33 = v28
    end
  end
  do return v1, v3, v7 end
end

function proto_62()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37
  local p390 = 156
  if p390 == 0 then
    v2 = u0
    v1 = IsNull
    v1 = v1(v2)
    if v1 then
      p390 = 9
    else
      p390 = 1
    end
  end
  if p390 == 1 then
    v1 = u1
    v2 = u2
    v2 = v2.BASE
    if v1 ~= v2 then
      p390 = 5
    else
      p390 = 2
    end
  end
  if p390 == 2 then
    v1 = u3
    v1 = v1.AllInOne
    if v1 then
      p390 = 5
    else
      p390 = 3
    end
  end
  if p390 == 3 then
    v1 = u3
    v1 = v1.Category
    v2 = 43
    if v1 == v2 then
      p390 = 5
    else
      p390 = 4
    end
  end
  if p390 == 4 then
    v1 = u3
    v1 = v1.Category
    v2 = 46
    if v1 ~= v2 then
      p390 = 9
    else
      p390 = 5
    end
  end
  if p390 == 5 then
    v1 = u4
    v1 = v1.mSelectedElement
    v2 = IsNull
    v2 = v2(v1)
    if v2 then
      p390 = 8
    else
      p390 = 6
    end
  end
  if p390 == 6 then
    v3 = v1.SuitOverride
    v2 = IsNull
    v2 = v2(v3)
    if v2 then
      p390 = 8
    else
      p390 = 7
    end
  end
  if p390 == 7 then
    v2 = Resource
    v3 = v1.SuitOverride
    v0 = v2(v3)
    p390 = 9
  end
  if p390 == 8 then
    v2 = Resource
    v3 = u0
    v0 = v2(v3)
    p390 = 9
  end
  if p390 == 9 then
    v1 = u3
    v1 = v1.IsAbility
    if not v1 then
      p390 = 14
    else
      p390 = 10
    end
  end
  if p390 == 10 then
    v1 = u3
    v1 = v1.AbilityInitialized
    if v1 then
      p390 = 12
    else
      p390 = 11
    end
  end
  if p390 == 11 then
    v1 = u5
    v1(v0)
    p390 = 14
  end
  if p390 == 12 then
    v2 = u3
    v2 = v2.Resource
    v1 = IsNull
    v1 = v1(v2)
    if v1 then
      p390 = 14
    else
      p390 = 13
    end
  end
  if p390 == 13 then
    v1 = u6
    v2 = u3
    v2 = v2.Resource
    v3 = u3
    v3 = v3.mSuit
    v1(v2, v3)
    v1 = u7
    v2 = u3
    v2 = v2.Resource
    v1(v2)
    p390 = 14
  end
  if p390 == 14 then
    v1 = _T.InfoPopup_Grid
    v2 = u3
    v2 = v2.StoreItem
    v3 = nil
    v4 = IsNull
    v4 = v4(v2)
    if v4 then
      p390 = 16
    else
      p390 = 15
    end
  end
  if p390 == 15 then
    v3 = v2:GetProductCategory()
    p390 = 16
  end
  if p390 == 16 then
    v5 = u8
    v4 = v5 + 10
    u9 = v4
    v5 = true
    v6 = u1
    v7 = u2
    v7 = v7.BASE
    if v6 == v7 then
      p390 = 20
    else
      p390 = 17
    end
  end
  if p390 == 17 then
    v6 = u1
    v7 = u2
    v7 = v7.INFO
    if v6 == v7 then
      p390 = 19
    else
      p390 = 18
    end
  end
  if p390 == 18 then
    v5 = false
    p390 = 20
  end
  if p390 == 19 then
    v5 = true
    p390 = 20
  end
  if p390 == 20 then
    v6 = mMovie
    v8 = "Popup.TagSeparator"
    v9 = 13
    v11 = u1
    v12 = u2
    v12 = v12.BASE
    if v11 == v12 then
      p390 = 22
    else
      p390 = 21
    end
  end
  if p390 == 21 then
    v10 = false
    p390 = 23
  end
  if p390 == 22 then
    v10 = true
    p390 = 23
  end
  if p390 == 23 then
    v6:Name__d9713943(v8, v9, v10)
    v6 = mMovie
    v8 = "Popup.Ingredients"
    v9 = 13
    v11 = u1
    v12 = u2
    v12 = v12.CRAFTING
    if v11 == v12 then
      p390 = 25
    else
      p390 = 24
    end
  end
  if p390 == 24 then
    v10 = false
    p390 = 26
  end
  if p390 == 25 then
    v10 = true
    p390 = 26
  end
  if p390 == 26 then
    v6:Name__d9713943(v8, v9, v10)
    v6 = mMovie
    v8 = "Popup.IngredientsSeparator"
    v9 = 13
    v10 = false
    v6:Name__d9713943(v8, v9, v10)
    v6 = mMovie
    v8 = "Popup.IngredientsSecondary"
    v9 = 13
    v10 = false
    v6:Name__d9713943(v8, v9, v10)
    v6 = mMovie
    v8 = "Popup.PrereqSeparator"
    v9 = 13
    v11 = u1
    v12 = u2
    v12 = v12.CRAFTING
    if v11 == v12 then
      p390 = 28
    else
      p390 = 27
    end
  end
  if p390 == 27 then
    v10 = false
    p390 = 29
  end
  if p390 == 28 then
    v10 = true
    p390 = 29
  end
  if p390 == 29 then
    v6:Name__d9713943(v8, v9, v10)
    v6 = mMovie
    v8 = "Popup.PrereqSeparator.Separator"
    v9 = 13
    v11 = u1
    v12 = u2
    v12 = v12.CRAFTING
    if v11 ~= v12 then
      p390 = 31
    else
      p390 = 30
    end
  end
  if p390 == 30 then
    v10 = false
    p390 = 32
  end
  if p390 == 31 then
    v10 = true
    p390 = 32
  end
  if p390 == 32 then
    v6:Name__d9713943(v8, v9, v10)
    v6 = mMovie
    v8 = "Popup.Prerequisite"
    v9 = 13
    v10 = false
    v6:Name__d9713943(v8, v9, v10)
    v6 = mMovie
    v8 = "Popup.RankedProgress"
    v9 = 13
    v10 = false
    v6:Name__d9713943(v8, v9, v10)
    v6 = mMovie
    v8 = "Popup.Affiliation1"
    v9 = 13
    v10 = false
    v6:Name__d9713943(v8, v9, v10)
    v6 = mMovie
    v8 = "Popup.GenericIcon"
    v9 = 13
    v10 = false
    v6:Name__d9713943(v8, v9, v10)
    v6 = 1
    v7 = 0
    v8 = ""
    v9 = ""
    u10 = v9
    v9 = 0
    u11 = v9
    v9 = 10
    u12 = v9
    v9 = {}
    u13 = v9
    v9 = u13
    v10 = {}
    v9.Labels = v10
    v9 = u13
    v10 = {}
    v9.Values = v10
    v9 = u14
    v9 = v9.Ternary
    v11 = u3
    v11 = v11.StatWeapon
    if v11 ~= nil then
      p390 = 34
    else
      p390 = 33
    end
  end
  if p390 == 33 then
    v10 = false
    p390 = 35
  end
  if p390 == 34 then
    v10 = true
    p390 = 35
  end
  if p390 == 35 then
    v11 = u3
    v11 = v11.StatWeapon
    v9 = v9(v10, v11, v0)
    v10 = u1
    v11 = u2
    v11 = v11.STATS
    if v10 == v11 then
      p390 = 38
    else
      p390 = 36
    end
  end
  if p390 == 36 then
    v10 = u3
    v10 = v10.AllInOne
    if not v10 then
      p390 = 57
    else
      p390 = 37
    end
  end
  if p390 == 37 then
    v10 = u4
    v10 = v10.mStatsAvailable
    if not v10 then
      p390 = 57
    else
      p390 = 38
    end
  end
  if p390 == 38 then
    v10 = u14
    v10 = v10.Ternary
    v12 = u3
    v12 = v12.StatOwner
    if v12 ~= nil then
      p390 = 40
    else
      p390 = 39
    end
  end
  if p390 == 39 then
    v11 = false
    p390 = 41
  end
  if p390 == 40 then
    v11 = true
    p390 = 41
  end
  if p390 == 41 then
    v12 = u3
    v12 = v12.StatOwner
    v13 = nil
    v10 = v10(v11, v12, v13)
    v11 = true
    v13 = u3
    v13 = v13.StatWeapon
    v12 = IsNull
    v12 = v12(v13)
    if not v12 then
      p390 = 46
    else
      p390 = 42
    end
  end
  if p390 == 42 then
    v12 = u15
    v12 = v12.GetModularType
    v13 = u0
    v12, v13 = v12(v13)
    if v12 == nil then
      p390 = 44
    else
      p390 = 43
    end
  end
  if p390 == 43 then
    v11 = false
    p390 = 46
  end
  if p390 == 44 then
    v14 = u3
    v14 = v14.IsAmp
    if not v14 then
      p390 = 46
    else
      p390 = 45
    end
  end
  if p390 == 45 then
    v14 = u3
    v14 = v14.RawItem
    v15 = gRegion
    v17 = Type
    v17 = v17(v9)
    v19 = 0
    v9 = v15:CreateObject(v17, v10, v19)
    v9:SetOwner(v10)
    v17 = v14.mModularParts
    v20 = 3
    v9:SetModularParts(v17, v14:HasFeature(v20))
    p390 = 46
  end
  if p390 == 46 then
    if v11 then
      p390 = 48
    else
      p390 = 47
    end
  end
  if p390 == 47 then
    v12 = u13
    v14 = mMovie
    v16 = "/Lotus/Language/Menu/StatsUnavailable"
    v17 = false
    v13 = {v14:GetLocalized(v16, v17)}
    v12.Labels = v13
    v12 = u13
    v14 = ""
    v13 = {v14}
    v12.Values = v13
    p390 = 53
  end
  if p390 == 48 then
    v12 = IsNull
    v12 = v12(v9)
    if v12 then
      p390 = 53
    else
      p390 = 49
    end
  end
  if p390 == 49 then
    v12 = u16
    v12 = v12.GetDisplayStats
    v13 = v9
    v14 = true
    v15 = v10
    v16 = u14
    v16 = v16.Ternary
    v18 = u17
    if v18 == nil then
      p390 = 51
    else
      p390 = 50
    end
  end
  if p390 == 50 then
    v17 = false
    p390 = 52
  end
  if p390 == 51 then
    v17 = true
    p390 = 52
  end
  if p390 == 52 then
    v18 = 1
    v19 = u17
    v12 = v12(v13, v14, v15, v16(v17, v18, v19))
    u13 = v12
    p390 = 53
  end
  if p390 == 53 then
    v13 = u3
    v13 = v13.StatWeapon
    v12 = IsNull
    v12 = v12(v13)
    if not v12 then
      p390 = 56
    else
      p390 = 54
    end
  end
  if p390 == 54 then
    v12 = u3
    v12 = v12.IsAmp
    if not v12 then
      p390 = 56
    else
      p390 = 55
    end
  end
  if p390 == 55 then
    v12 = gRegion
    v12:DestroyObject(v9)
    v9 = v0
    p390 = 56
  end
  if p390 == 56 then
    v12 = mMovie
    v14 = "Popup.ItemStats"
    v15 = 12
    v16 = 0
    v12:SetNumberVariable(v14, v15, v16)
    v12 = FlashInterpolate
    v13 = mMovie
    v14 = "Popup.ItemStats"
    v15 = 8
    v17 = 12
    v16 = {v17}
    v18 = 100
    v17 = {v18}
    v18 = 0.2
    v12(v13, v14, v15, v16, v17, v18)
    p390 = 57
  end
  if p390 == 57 then
    v10 = u13
    v11 = {}
    v10.BaseValues = v11
    v10 = u13
    v11 = {}
    v10.StatChanges = v11
    v11 = u3
    v11 = v11.StatWeapon
    v10 = IsNull
    v10 = v10(v11)
    if not v10 then
      p390 = 82
    else
      p390 = 58
    end
  end
  if p390 == 58 then
    v10 = IsNull
    v10 = v10(v9)
    if v10 then
      p390 = 82
    else
      p390 = 59
    end
  end
  if p390 == 59 then
    v10 = u3
    v10 = v10.Category
    v11 = 43
    if v10 == v11 then
      p390 = 61
    else
      p390 = 60
    end
  end
  if p390 == 60 then
    v10 = u3
    v10 = v10.Category
    v11 = 46
    if v10 ~= v11 then
      p390 = 82
    else
      p390 = 61
    end
  end
  if p390 == 61 then
    v10 = v2:GetItem()
    v12 = u3
    v12 = v12.ResultItemType
    v11 = IsNull
    v11 = v11(v12)
    if v11 then
      p390 = 63
    else
      p390 = 62
    end
  end
  if p390 == 62 then
    v11 = u3
    v10 = v11.ResultItemType
    p390 = 69
  end
  if p390 == 63 then
    v11 = u3
    v11 = v11.RawItem
    if v11 == nil then
      p390 = 69
    else
      p390 = 64
    end
  end
  if p390 == 64 then
    v11 = u3
    v11 = v11.RawItem
    v13 = v11.mUpgradeType
    v12 = IsNull
    v12 = v12(v13)
    if not v12 then
      p390 = 67
    else
      p390 = 65
    end
  end
  if p390 == 65 then
    v13 = v11.Item
    v12 = IsNull
    v12 = v12(v13)
    if v12 then
      p390 = 67
    else
      p390 = 66
    end
  end
  if p390 == 66 then
    v11 = v11.Item
    p390 = 67
  end
  if p390 == 67 then
    v13 = v11.mUpgradeType
    v12 = IsNull
    v12 = v12(v13)
    if v12 then
      p390 = 69
    else
      p390 = 68
    end
  end
  if p390 == 68 then
    v12 = Lotus_Game.UpgradeInfo
    v12 = v12()
    v13 = v11.mUpgradeType
    v12.mItemType = v13
    v10 = v12.mInstance
    p390 = 69
  end
  if p390 == 69 then
    v11 = Resource
    v11 = v11(v10)
    v12 = ""
    v13 = u3
    if v13 == nil then
      p390 = 74
    else
      p390 = 70
    end
  end
  if p390 == 70 then
    v13 = u3
    v13 = v13.RawItem
    if v13 == nil then
      p390 = 74
    else
      p390 = 71
    end
  end
  if p390 == 71 then
    v13 = u3
    v13 = v13.RawItem
    v12 = v13.mUpgradeFingerprint
    v13 = #v12
    if v13 ~= 0 then
      p390 = 74
    else
      p390 = 72
    end
  end
  if p390 == 72 then
    v13 = u3
    v13 = v13.RawItem
    v13 = v13.Item
    if v13 == nil then
      p390 = 74
    else
      p390 = 73
    end
  end
  if p390 == 73 then
    v13 = u3
    v13 = v13.RawItem
    v13 = v13.Item
    v12 = v13.mUpgradeFingerprint
    p390 = 74
  end
  if p390 == 74 then
    if v12 ~= nil then
      p390 = 76
    else
      p390 = 75
    end
  end
  if p390 == 75 then
    v12 = ""
    p390 = 76
  end
  if p390 == 76 then
    v13 = IsNull
    v13 = v13(v11)
    if v13 then
      p390 = 82
    else
      p390 = 77
    end
  end
  if p390 == 77 then
    v15 = gLotusWeaponUpgradeBaseType
    v13 = v11:IsA(v15)
    if not v13 then
      p390 = 82
    else
      p390 = 78
    end
  end
  if p390 == 78 then
    v13 = v11:Name__0f7cb43a(v12)
    v14 = { mUpgradeType = nil, mDesc = "" }
    v14.mUpgradeType = v3
    v15 = u18
    v15 = v15.UpdateCrewShipCard
    v18 = mMovie
    v15(v14, v13, v18)
    v8 = v14.mDesc
    if v8 == "" then
      p390 = 82
    else
      p390 = 79
    end
  end
  if p390 == 79 then
    v15 = StringSplit
    v16 = "\r\n"
    v15 = v15(v16, v8)
    v16 = { Values = nil, Labels = nil, CompareValues = nil }
    v17 = {}
    v16.Values = v17
    v17 = {}
    v16.Labels = v17
    v17 = {}
    v16.CompareValues = v17
    v19 = 1
    v17 = #v15
    v18 = 1
    if (v18 > 0 and v19 > v17) or (v18 < 0 and v19 < v17) then
      p390 = 81
    else
      p390 = 80
    end
  end
  if p390 == 80 then
    v21 = string.match
    v22 = v15[v19]
    v23 = "%p*%d*%.?%d+[^%s]*"
    v21 = v21(v22, v23)
    v20 = v21 or 0
    v22 = v16.Values
    v21 = table.insert
    v21(v22, v20)
    v22 = v16.CompareValues
    v24 = string.match
    v26 = "%d*%.?%d+"
    v23 = tonumber
    v23 = v23(v24(v20, v26))
    v21 = table.insert
    v21(v22, v23)
    v21 = v20
    v22 = string.gsub
    v24 = "[%(%)%.%%%+%-%*%?%[%]%^%$]"
    v25 = "%%%0"
    v20 = v22(v21, v24, v25)
    v21 = string.gsub
    v22 = v15[v19]
    v24 = "[STAT]"
    v21 = v21(v22, v20, v24)
    v23 = v16.Labels
    v22 = table.insert
    v22(v23, v21)
    p390 = 81
  end
  if p390 == 81 then
    v17 = u13
    v17.BonusStats = v16
    p390 = 82
  end
  if p390 == 82 then
    v10 = u3
    v10 = v10.NumItemPopupPages
    if not v10 then
      p390 = 86
    else
      p390 = 83
    end
  end
  if p390 == 83 then
    v11 = u3
    v11 = v11.NumItemPopupPages
    v12 = 1
    if v12 < v11 then
      p390 = 85
    else
      p390 = 84
    end
  end
  if p390 == 84 then
    v10 = false
    p390 = 86
  end
  if p390 == 85 then
    v10 = true
    p390 = 86
  end
  if p390 == 86 then
    v11 = u1
    v12 = u2
    v12 = v12.BASE
    if v11 ~= v12 then
      p390 = 88
    else
      p390 = 87
    end
  end
  if p390 == 87 then
    v11 = u19
    v6, v8, v7 = v11(v1, v6, v2, v8, v3, v4, v0, v7, v10)
    p390 = 102
  end
  if p390 == 88 then
    v11 = u1
    v12 = u2
    v12 = v12.CRAFTING
    if v11 ~= v12 then
      p390 = 93
    else
      p390 = 89
    end
  end
  if p390 == 89 then
    v12 = u9
    v11 = v12 - 13
    u9 = v11
    v11 = mMovie
    v13 = "Popup.PrereqSeparator"
    v14 = 1
    v15 = u9
    v11:SetNumberVariable(v13, v14, v15)
    v13 = u9
    v14 = mMovie
    v16 = "Popup.PrereqSeparator.Description"
    v17 = 41
    v14 = v14:GetNumberVariable(v16, v17)
    v12 = v13 + v14
    v11 = v12 + 21
    u9 = v11
    v11 = u20
    v11()
    v11 = mMovie
    v13 = "Popup.Ingredients"
    v14 = 1
    v15 = u9
    v11:SetNumberVariable(v13, v14, v15)
    v11 = 0
    v12 = ipairs
    v13 = u21
    v13 = v13.mElements
    v12, v13, v14 = v12(v13)
    p390 = 91
  end
  if p390 == 90 then
    v17 = v11 + 5
    v19 = u21
    v19 = v19.mForcedVerticalSeparation
    v21 = v16.mHeight
    v20 = v21 or 0
    v18 = math.max
    v18 = v18(v19, v20)
    v11 = v17 + v18
    p390 = 91
  end
  if p390 == 91 then
    p390 = 92
  end
  if p390 == 92 then
    v15 = u9
    v16 = mMovie
    v18 = "Popup.Ingredients.ingredient"
    v19 = 1
    v16 = v16:GetNumberVariable(v18, v19)
    v14 = v15 + v16
    v13 = v14 + v11
    v12 = v13 - 10
    u9 = v12
    p390 = 102
  end
  if p390 == 93 then
    v11 = u1
    v12 = u2
    v12 = v12.INFO
    if v11 ~= v12 then
      p390 = 102
    else
      p390 = 94
    end
  end
  if p390 == 94 then
    v11 = IsNull
    v11 = v11(v1)
    if v11 then
      p390 = 97
    else
      p390 = 95
    end
  end
  if p390 == 95 then
    v11 = v1.AdditionalTabInfo
    if v11 == nil then
      p390 = 97
    else
      p390 = 96
    end
  end
  if p390 == 96 then
    v11 = v1.AdditionalTabInfo
    v12 = u3
    v11 = v11(v12)
    u10 = v11
    p390 = 97
  end
  if p390 == 97 then
    v12 = u10
    v11 = type
    v11 = v11(v12)
    if v11 == "string" then
      p390 = 99
    else
      p390 = 98
    end
  end
  if p390 == 98 then
    v11 = print
    v13 = "AdditionalTabInfo returned "
    v17 = u10
    v16 = type
    v14 = v16(v17)
    v15 = ", should be string"
    v12 = v13 .. v14 .. v15
    v11(v12)
    v11 = ""
    u10 = v11
    p390 = 99
  end
  if p390 == 99 then
    v12 = u9
    v11 = v12 - 2
    u9 = v11
    v11 = mMovie
    v13 = "Popup.Description"
    v14 = 1
    v15 = u9
    v11:SetNumberVariable(v13, v14, v15)
    v11 = mMovie
    v13 = "Popup.Description"
    v14 = 36
    v16 = "<p><font color=\""
    v17 = u22
    v17 = v17.ContentHex
    v18 = "\">"
    v19 = u10
    v20 = "</font></p>"
    v15 = v16 .. v17 .. v18 .. v19 .. v20
    v11:SetStringVariable(v13, v14, v15)
    v11 = u10
    if v11 == "" then
      p390 = 101
    else
      p390 = 100
    end
  end
  if p390 == 100 then
    v12 = u9
    v13 = mMovie
    v15 = "Popup.Description"
    v16 = 41
    v13 = v13:GetNumberVariable(v15, v16)
    v11 = v12 + v13
    u9 = v11
    p390 = 102
  end
  if p390 == 101 then
    v12 = u9
    v11 = v12 - 17
    u9 = v11
    p390 = 102
  end
  if p390 == 102 then
    v11 = true
    v12 = u1
    v13 = u2
    v13 = v13.ABILITIES
    if v12 == v13 then
      p390 = 108
    else
      p390 = 103
    end
  end
  if p390 == 103 then
    v12 = u3
    v12 = v12.AllInOne
    if not v12 then
      p390 = 105
    else
      p390 = 104
    end
  end
  if p390 == 104 then
    v12 = u4
    v12 = v12.mAbilitiesAvailable
    p390 = 105
  end
  if p390 == 105 then
    if v12 == true then
      p390 = 107
    else
      p390 = 106
    end
  end
  if p390 == 106 then
    v11 = false
    p390 = 108
  end
  if p390 == 107 then
    v11 = true
    p390 = 108
  end
  if p390 == 108 then
    v12 = mMovie
    v14 = "Popup.AbilityInfo"
    v15 = 13
    v12:Name__d9713943(v14, v15, v11)
    if not v11 then
      p390 = 127
    else
      p390 = 109
    end
  end
  if p390 == 109 then
    v12 = mMovie
    v14 = "Popup.AbilityInfo.Ability1"
    v15 = 1
    v12 = v12:GetNumberVariable(v14, v15)
    v13 = mMovie
    v15 = "Popup.AbilityInfo"
    v16 = 1
    v17 = u9
    v13:SetNumberVariable(v15, v16, v17)
    v13 = IsNull
    v13 = v13(v0)
    if not v13 then
      p390 = 111
    else
      p390 = 110
    end
  end
  if p390 == 110 then
    v13 = print
    v14 = "WARNING: no suit for ability info!"
    v13(v14)
    p390 = 127
  end
  if p390 == 111 then
    v14 = u23
    v14 = v14.GetPowerSuitStats
    v15 = mMovie
    v16 = nil
    v14 = v14(v15, v16, v0)
    v13 = v14[1]
    v13 = v13.mStats
    v14 = u3
    v14 = v14.mIsNemesis
    if not v14 then
      p390 = 114
    else
      p390 = 112
    end
  end
  if p390 == 112 then
    v14 = Resource
    v15 = u3
    v15 = v15.mExtraAbility
    v14 = v14(v15)
    v15 = IsNull
    v15 = v15(v14)
    if v15 then
      p390 = 114
    else
      p390 = 113
    end
  end
  if p390 == 113 then
    v15 = mMovie
    v17 = v14:GetLocalizeTag()
    v17 = v17:c_str()
    v18 = false
    v15 = v15:GetLocalized(v17, v18)
    v13.Ability4 = v15
    v15 = mMovie
    v17 = v14:GetLocalizeDescTag()
    v17 = v17:c_str()
    v18 = true
    v15 = v15:GetLocalized(v17, v18)
    v13.AbilityDescription4 = v15
    v15 = v14:GetIconTexture()
    v13.AbilityIcon4 = v15
    v13.AbilityType4 = v14
    p390 = 114
  end
  if p390 == 114 then
    v16 = 1
    v14 = 4
    v15 = 1
    if (v15 > 0 and v16 > v14) or (v15 < 0 and v16 < v14) then
      p390 = 118
    else
      p390 = 115
    end
  end
  if p390 == 115 then
    v18 = "Popup.AbilityInfo.Ability"
    v19 = tostring
    v19 = v19(v16)
    v17 = v18 .. v19
    v20 = "Ability"
    v19 = v20 .. v16
    v18 = v13[v19]
    if v18 == nil then
      p390 = 117
    else
      p390 = 116
    end
  end
  if p390 == 116 then
    v18 = mMovie
    v21 = 1
    v18:SetNumberVariable(v17, v21, v12)
    v18 = mMovie
    v22 = ".Name"
    v20 = v17 .. v22
    v21 = 36
    v22 = string.upper
    v25 = "Ability"
    v24 = v25 .. v16
    v23 = v13[v24]
    v18:SetStringVariable(v20, v21, v22(v23))
    v18 = u14
    v18 = v18.SetFitText
    v19 = mMovie
    v22 = ".Description"
    v20 = v17 .. v22
    v21 = "..."
    v18(v19, v20, v21)
    v18 = mMovie
    v21 = "Description"
    v22 = 91
    v23 = 6
    v18:Name__52c1b74e(v17, v21, v22, v23)
    v18 = mMovie
    v22 = ".Description"
    v20 = v17 .. v22
    v21 = 36
    v24 = "AbilityDescription"
    v23 = v24 .. v16
    v22 = v13[v23]
    v18:SetStringVariable(v20, v21, v22)
    v20 = "AbilityIcon"
    v19 = v20 .. v16
    v18 = v13[v19]
    v19 = mMovie
    v23 = ".Icon"
    v21 = v17 .. v23
    v19:OverrideTexture(v21, v18)
    v19 = mMovie
    v22 = "Icon"
    v23 = 13
    v25 = IsNull
    v25 = v25(v18)
    v24 = not v25
    v19:Makeposshield(v17, v22, v23, v24)
    v19 = mMovie
    v23 = ".Name"
    v21 = v17 .. v23
    v22 = 41
    v19 = v19:GetNumberVariable(v21, v22)
    v20 = mMovie
    v24 = ".Description"
    v22 = v17 .. v24
    v23 = 41
    v20 = v20:GetNumberVariable(v22, v23)
    v22 = v12 + v19
    v21 = v22 + v20
    v12 = v21 + 20
    p390 = 117
  end
  if p390 == 117 then
    p390 = 118
  end
  if p390 == 118 then
    v12 = v12 + 4
    v14 = ""
    v16 = gRegion
    v15 = IsNull
    v15 = v15(v16)
    if v15 then
      p390 = 121
    else
      p390 = 119
    end
  end
  if p390 == 119 then
    v15 = u3
    v15 = v15.mIsNemesis
    if v15 then
      p390 = 121
    else
      p390 = 120
    end
  end
  if p390 == 120 then
    v15 = u24
    v15 = v15.GetPassiveDescription
    v16 = mMovie
    v17 = gRegion
    v17 = v17:GetLocalPlayerAvatar()
    v14 = v15(v16, v17, v0)
    p390 = 121
  end
  if p390 == 121 then
    if v14 ~= "" then
      p390 = 123
    else
      p390 = 122
    end
  end
  if p390 == 122 then
    v15 = false
    p390 = 124
  end
  if p390 == 123 then
    v15 = true
    p390 = 124
  end
  if p390 == 124 then
    v16 = mMovie
    v18 = "Popup.AbilityInfo.Passive"
    v19 = 13
    v16:Name__d9713943(v18, v19, v15)
    v16 = mMovie
    v18 = "Popup.AbilityInfo.PassiveSeparator"
    v19 = 13
    v16:Name__d9713943(v18, v19, v15)
    if not v15 then
      p390 = 126
    else
      p390 = 125
    end
  end
  if p390 == 125 then
    v16 = mMovie
    v18 = "Popup.AbilityInfo.Passive.Name.text"
    v19 = "/Lotus/Language/Menu/Ability_Passive"
    v16:SetLocalized(v18, v19)
    v16 = u14
    v16 = v16.SetFitText
    v17 = mMovie
    v18 = "Popup.AbilityInfo.Passive.Description"
    v19 = "..."
    v16(v17, v18, v19)
    v16 = mMovie
    v18 = "Popup.AbilityInfo.Passive.Description"
    v19 = 91
    v20 = 6
    v16:SetNumberVariable(v18, v19, v20)
    v16 = mMovie
    v18 = "Popup.AbilityInfo.Passive.Description"
    v19 = 36
    v16:SetStringVariable(v18, v19, v14)
    v16 = mMovie
    v18 = "Popup.AbilityInfo.PassiveSeparator"
    v19 = 1
    v16:SetNumberVariable(v18, v19, v12)
    v16 = mMovie
    v18 = "Popup.AbilityInfo.Passive"
    v19 = 1
    v20 = v12 + 12
    v16:SetNumberVariable(v18, v19, v20)
    p390 = 126
  end
  if p390 == 126 then
    v18 = u9
    v17 = v18 + v12
    v18 = u14
    v18 = v18.Ternary
    v21 = mMovie
    v23 = "Popup.AbilityInfo.Passive.Description"
    v24 = 41
    v21 = v21:GetNumberVariable(v23, v24)
    v20 = v21 + 38
    v21 = -20
    v18 = v18(v15, v20, v21)
    v16 = v17 + v18
    u9 = v16
    p390 = 127
  end
  if p390 == 127 then
    if v8 == "" then
      p390 = 131
    else
      p390 = 128
    end
  end
  if p390 == 128 then
    v12 = u1
    v13 = u2
    v13 = v13.STATS
    if v12 ~= v13 then
      p390 = 130
    else
      p390 = 129
    end
  end
  if p390 == 129 then
    v12 = mMovie
    v14 = "Popup.Description"
    v15 = 1
    v16 = u9
    v12:SetNumberVariable(v14, v15, v16)
    v13 = u9
    v12 = v13 + 5
    u9 = v12
    p390 = 130
  end
  if p390 == 130 then
    v12 = mMovie
    v14 = "Popup.Description"
    v15 = 36
    v17 = "<p><font color=\""
    v18 = u22
    v18 = v18.ContentHex
    v19 = "\">"
    v21 = "</font></p>"
    v16 = v17 .. v18 .. v19 .. v8 .. v21
    v12:SetStringVariable(v14, v15, v16)
    v13 = u9
    v14 = mMovie
    v16 = "Popup.Description"
    v17 = 41
    v14 = v14:GetNumberVariable(v16, v17)
    v12 = v13 + v14
    u9 = v12
    v5 = true
    p390 = 131
  end
  if p390 == 131 then
    v12 = u25
    v13 = 1
    if v12 <= v13 then
      p390 = 135
    else
      p390 = 132
    end
  end
  if p390 == 132 then
    v13 = v7 + 1
    v14 = 2
    v12 = math.max
    v15 = v12(v13, v14)
    v13 = u25
    v14 = 1
    if (v14 > 0 and v15 > v13) or (v14 < 0 and v15 < v13) then
      p390 = 134
    else
      p390 = 133
    end
  end
  if p390 == 133 then
    v16 = FlashMethod
    v17 = mMovie
    v19 = "Popup.Affiliation"
    v21 = ".removeMovieClip"
    v18 = v19 .. v15 .. v21
    v16(v17, v18)
    p390 = 134
  end
  if p390 == 134 then
    v14 = 1
    v13 = math.max
    v13 = v13(v14, v7)
    u25 = v13
    p390 = 135
  end
  if p390 == 135 then
    v12 = false
    v13 = u3
    if not v13 then
      p390 = 137
    else
      p390 = 136
    end
  end
  if p390 == 136 then
    v13 = u3
    v13 = v13.mShowOnlyStats
    p390 = 137
  end
  if p390 == 137 then
    v15 = u13
    v15 = v15.Labels
    v14 = #v15
    v15 = 0
    if v14 <= v15 then
      p390 = 185
    else
      p390 = 138
    end
  end
  if p390 == 138 then
    v14 = u3
    v14 = v14.AreStatsBuried
    if not v14 then
      p390 = 140
    else
      p390 = 139
    end
  end
  if p390 == 139 then
    v14 = u4
    v14 = v14.mCurrentElementIndex
    v16 = u4
    v16 = v16.mElements
    v15 = #v16
    if v14 ~= v15 then
      p390 = 185
    else
      p390 = 140
    end
  end
  if p390 == 140 then
    v14 = u1
    v15 = u2
    v15 = v15.STATS
    if v14 == v15 then
      p390 = 142
    else
      p390 = 141
    end
  end
  if p390 == 141 then
    v15 = u9
    v16 = u14
    v16 = v16.Ternary
    v18 = 10
    v19 = 23
    v16 = v16(v13, v18, v19)
    v14 = v15 + v16
    u9 = v14
    p390 = 142
  end
  if p390 == 142 then
    v14 = u26
    v16 = u13
    v16 = v16.Labels
    v15 = type
    v15 = v15(v16)
    if v15 ~= "table" then
      p390 = 178
    else
      p390 = 143
    end
  end
  if p390 == 143 then
    v16 = u13
    v16 = v16.Labels
    v15 = #v16
    u26 = v15
    if not v10 then
      p390 = 156
    else
      p390 = 144
    end
  end
  if p390 == 144 then
    v15 = u3
    v15 = v15.AreStatsBuried
    if v15 then
      p390 = 156
    else
      p390 = 145
    end
  end
  if p390 == 145 then
    v15 = {}
    v16 = {}
    v17 = {}
    v18 = {}
    v19 = 0
    v22 = 1
    v20 = u26
    v21 = 1
    if (v21 > 0 and v22 > v20) or (v21 < 0 and v22 < v20) then
      p390 = 155
    else
      p390 = 146
    end
  end
  if p390 == 146 then
    v24 = u13
    v24 = v24.Labels
    v23 = v24[v22]
    if v23 == "" then
      p390 = 149
    else
      p390 = 147
    end
  end
  if p390 == 147 then
    v24 = u13
    v24 = v24.Values
    v23 = v24[v22]
    if v23 ~= "" then
      p390 = 149
    else
      p390 = 148
    end
  end
  if p390 == 148 then
    v19 = v19 + 1
    p390 = 149
  end
  if p390 == 149 then
    if v19 == 0 then
      p390 = 153
    else
      p390 = 150
    end
  end
  if p390 == 150 then
    v23 = u4
    v23 = v23.mCurrentElementIndex
    if v19 == v23 then
      p390 = 153
    else
      p390 = 151
    end
  end
  if p390 == 151 then
    v23 = u4
    v23 = v23.mCurrentElementIndex
    v25 = u4
    v25 = v25.mElements
    v24 = #v25
    if v23 ~= v24 then
      p390 = 154
    else
      p390 = 152
    end
  end
  if p390 == 152 then
    v23 = u4
    v23 = v23.mCurrentElementIndex
    if v19 <= v23 then
      p390 = 154
    else
      p390 = 153
    end
  end
  if p390 == 153 then
    v26 = u13
    v26 = v26.Labels
    v25 = v26[v22]
    v23 = table.insert
    v23(v15, v25)
    v26 = u13
    v26 = v26.Values
    v25 = v26[v22]
    v23 = table.insert
    v23(v16, v25)
    v26 = u13
    v26 = v26.BaseValues
    v25 = v26[v22]
    v23 = table.insert
    v23(v17, v25)
    v26 = u13
    v26 = v26.StatChanges
    v25 = v26[v22]
    v23 = table.insert
    v23(v18, v25)
    p390 = 154
  end
  if p390 == 154 then
    p390 = 155
  end
  if p390 == 155 then
    v20 = u13
    v20.Labels = v15
    v20 = u13
    v20.Values = v16
    v20 = u13
    v20.BaseValues = v17
    v20 = u13
    v20.StatChanges = v18
    v20 = #v15
    u26 = v20
    p390 = 156
  end
  if p390 == 156 then
    v15 = 0
    v18 = 1
    v16 = u26
    v17 = 1
    if (v17 > 0 and v18 > v16) or (v17 < 0 and v18 < v16) then
      p390 = 173
    else
      p390 = 157
    end
  end
  if p390 == 157 then
    v20 = "Popup.ItemStats.Item"
    v19 = v20 .. v18
    v20 = mMovie
    v20 = v20:HasVariable(v19)
    if v20 then
      p390 = 159
    else
      p390 = 158
    end
  end
  if p390 == 158 then
    v20 = FlashMethod
    v21 = mMovie
    v22 = "Popup.ItemStats.Item1.duplicateMovieClip"
    v24 = "Item"
    v23 = v24 .. v18
    v20(v21, v22, v23, v18)
    p390 = 159
  end
  if p390 == 159 then
    v21 = u13
    v21 = v21.Labels
    v20 = v21[v18]
    v21 = u27
    v23 = u13
    v23 = v23.Values
    v22 = v23[v18]
    v24 = u13
    v24 = v24.BaseValues
    v23 = v24[v18]
    v25 = u13
    v25 = v25.StatChanges
    v24 = v25[v18]
    v25 = true
    v21 = v21(v22, v23, v24, v25)
    v22 = mMovie
    v25 = 1
    v22:SetNumberVariable(v19, v25, v15)
    v22 = mMovie
    v25 = "Backer"
    v26 = 12
    v29 = v18 % 2
    v28 = v29 * 35
    v27 = 35 - v28
    v22:Name__52c1b74e(v19, v25, v26, v27)
    v22 = mMovie
    v25 = "Backer"
    v26 = 1
    v27 = 1
    v22:Name__52c1b74e(v19, v25, v26, v27)
    v22 = mMovie
    v25 = "Labels"
    v26 = 52
    v27 = false
    v22:Makeposshield(v19, v25, v26, v27)
    v22 = mMovie
    v26 = ".Labels"
    v24 = v19 .. v26
    v25 = 36
    v22:SetStringVariable(v24, v25, v20)
    v22 = mMovie
    v26 = ".Stats"
    v24 = v19 .. v26
    v25 = 36
    v22:SetStringVariable(v24, v25, v21)
    v22 = 1
    v23 = mMovie
    v27 = ".Labels"
    v25 = v19 .. v27
    v26 = 40
    v23 = v23:GetNumberVariable(v25, v26)
    v25 = mMovie
    v29 = ".Stats"
    v27 = v19 .. v29
    v28 = 40
    v25 = v25:GetNumberVariable(v27, v28)
    v24 = v25 + 20
    v24 = 330 - v24
    v26 = u13
    v26 = v26.Values
    v25 = v26[v18]
    if (not (v25 == "") and v24 < v23) then
      p390 = 162
    else
      p390 = 161
    end
  end
  if p390 == 161 then
    v25 = 330
    if v23 <= v25 then
      p390 = 163
    else
      p390 = 162
    end
  end
  if p390 == 162 then
    v25 = mMovie
    v28 = "Stats"
    v29 = 52
    v30 = true
    v25:Makeposshield(v19, v28, v29, v30)
    v25 = mMovie
    v28 = "Stats"
    v29 = 0
    v30 = 0
    v25:Name__52c1b74e(v19, v28, v29, v30)
    v25 = mMovie
    v28 = "Stats"
    v29 = 14
    v30 = 330
    v25:Name__52c1b74e(v19, v28, v29, v30)
    v25 = mMovie
    v29 = ".Stats"
    v27 = v19 .. v29
    v28 = 36
    v30 = "\r\n"
    v29 = v30 .. v21
    v25:SetStringVariable(v27, v28, v29)
    v25 = mMovie
    v29 = ".Stats"
    v27 = v19 .. v29
    v28 = 43
    v22 = v25:GetNumberVariable(v27, v28)
    p390 = 163
  end
  if p390 == 163 then
    v25 = mMovie
    v28 = "Backer"
    v29 = 14
    v25 = v25:Name__46690123(v19, v28, v29)
    if v23 <= v25 then
      p390 = 165
    else
      p390 = 164
    end
  end
  if p390 == 164 then
    v26 = mMovie
    v29 = "Labels"
    v30 = 14
    v31 = 310
    v26:Name__52c1b74e(v19, v29, v30, v31)
    v26 = mMovie
    v29 = "Labels"
    v30 = 52
    v31 = true
    v26:Makeposshield(v19, v29, v30, v31)
    p390 = 165
  end
  if p390 == 165 then
    v26 = 1
    v27 = 2
    v28 = 0
    if not v13 then
      p390 = 168
    else
      p390 = 166
    end
  end
  if p390 == 166 then
    v29 = u26
    if v18 ~= v29 then
      p390 = 168
    else
      p390 = 167
    end
  end
  if p390 == 167 then
    v27 = 10
    v28 = 10
    v29 = mMovie
    v33 = ".Labels"
    v31 = v19 .. v33
    v32 = 43
    v26 = v29:GetNumberVariable(v31, v32)
    v29 = mMovie
    v32 = "Labels"
    v33 = 1
    v36 = v26 - 1
    v35 = v36 * 23
    v34 = v35 + v27
    v29:Name__52c1b74e(v19, v32, v33, v34)
    p390 = 169
  end
  if p390 == 168 then
    v29 = mMovie
    v32 = "Labels"
    v33 = 1
    v34 = 2
    v29:Name__52c1b74e(v19, v32, v33, v34)
    p390 = 169
  end
  if p390 == 169 then
    v29 = v22 * 23
    v30 = #v20
    if v30 ~= 0 then
      p390 = 171
    else
      p390 = 170
    end
  end
  if p390 == 170 then
    v29 = 16
    p390 = 172
  end
  if p390 == 171 then
    v30 = mMovie
    v33 = "Stats"
    v34 = 1
    v37 = v22 - 1
    v36 = v37 * 23
    v35 = v36 + v27
    v30:Name__52c1b74e(v19, v33, v34, v35)
    p390 = 172
  end
  if p390 == 172 then
    v30 = mMovie
    v33 = "Backer"
    v34 = 15
    v35 = v29 + v28
    v30:Name__52c1b74e(v19, v33, v34, v35)
    v15 = v15 + v29
    p390 = 173
  end
  if p390 == 173 then
    v17 = _T.ItemInfoStatComparison
    v16 = IsNull
    v16 = v16(v17)
    if not v16 then
      p390 = 175
    else
      p390 = 174
    end
  end
  if p390 == 174 then
    p390 = 179
  end
  if p390 == 175 then
    v16 = u28
    if not v16 then
      p390 = 177
    else
      p390 = 176
    end
  end
  if p390 == 176 then
    v16 = _T.ItemInfoStatComparison
    v16()
    p390 = 179
  end
  if p390 == 177 then
    v16 = _T.ItemInfoStatComparison
    v17 = u13
    v18 = u29
    v16(v17, v18)
    p390 = 179
  end
  if p390 == 178 then
    v15 = 1
    u26 = v15
    v15 = mMovie
    v17 = "Popup.ItemStats.Item1.Backer"
    v18 = 12
    v19 = 0
    v15:SetNumberVariable(v17, v18, v19)
    v15 = mMovie
    v17 = "Popup.ItemStats.Item1.Labels"
    v18 = 36
    v19 = u13
    v19 = v19.Labels
    v15:SetStringVariable(v17, v18, v19)
    v15 = mMovie
    v17 = "Popup.ItemStats.Item1.Stats"
    v18 = 36
    v19 = u13
    v19 = v19.Values
    v15:SetStringVariable(v17, v18, v19)
    p390 = 179
  end
  if p390 == 179 then
    v15 = u26
    v16 = 0
    if v15 <= v16 then
      v12 = false
    else
      v12 = true
    end
    v19 = u26
    v18 = v19 + 1
    v19 = 2
    v17 = math.max
    v17 = v17(v18, v19)
    v15 = v14
    v16 = 1
    if v16 < v15 then
      for v17 = v17, v15, v16 do
        v18 = FlashMethod
        v19 = mMovie
        v21 = "Popup.ItemStats.Item"
        v23 = ".removeMovieClip"
        v20 = v21 .. v17 .. v23
        v18(v19, v20)
      end
    end
    p390 = 192
  end
  if p390 == 185 then
    v14 = u13
    v14 = v14.BonusStats
    if v14 == nil then
      p390 = 192
    else
      p390 = 186
    end
  end
  if p390 == 186 then
    v15 = u13
    v15 = v15.BonusStats
    v15 = v15.Labels
    v14 = #v15
    v15 = 0
    if v14 <= v15 then
      p390 = 192
    else
      p390 = 187
    end
  end
  if p390 == 187 then
    v15 = _T.ItemInfoStatComparison
    v14 = IsNull
    v14 = v14(v15)
    if not v14 then
      p390 = 189
    else
      p390 = 188
    end
  end
  if p390 == 188 then
    p390 = 192
  end
  if p390 == 189 then
    v14 = u28
    if not v14 then
      p390 = 191
    else
      p390 = 190
    end
  end
  if p390 == 190 then
    v14 = _T.ItemInfoStatComparison
    v14()
    p390 = 192
  end
  if p390 == 191 then
    v14 = _T.ItemInfoStatComparison
    v15 = u13
    v16 = u29
    v14(v15, v16)
    p390 = 192
  end
  if p390 == 192 then
    v14 = mMovie
    v16 = "Popup.Description"
    v17 = 13
    v14:Name__d9713943(v16, v17, v5)
    v14 = mMovie
    v16 = "Popup.ItemStats"
    v17 = 13
    v14:Name__d9713943(v16, v17, v12)
    if not v12 then
      p390 = 194
    else
      p390 = 193
    end
  end
  if p390 == 193 then
    v14 = mMovie
    v16 = "Popup.ItemStats"
    v17 = 1
    v18 = u9
    v14:SetNumberVariable(v16, v17, v18)
    v15 = u9
    v16 = mMovie
    v18 = "Popup.ItemStats"
    v19 = 15
    v16 = v16:GetNumberVariable(v18, v19)
    v14 = v15 + v16
    u9 = v14
    p390 = 194
  end
  if p390 == 194 then
    v14 = u30
    v14(v6)
    v14 = u31
    v14()
    v14 = 9
    if not v13 then
      p390 = 203
    else
      p390 = 195
    end
  end
  if p390 == 195 then
    v16 = Engine.IsPlayingWithTouchscreen
    v16 = v16()
    if v16 then
      p390 = 197
    else
      p390 = 196
    end
  end
  if p390 == 196 then
    v15 = false
    p390 = 201
  end
  if p390 == 197 then
    v16 = _T.InfoPopup_Grid
    if v16 == nil then
      p390 = 200
    else
      p390 = 198
    end
  end
  if p390 == 198 then
    v17 = v16.ShowSelectButton
    if v17 == nil then
      p390 = 200
    else
      p390 = 199
    end
  end
  if p390 == 199 then
    v17 = v16.ShowSelectButton
    v18 = _T.InfoPopup_Data
    v15 = v17(v18)
    p390 = 201
  end
  if p390 == 200 then
    v15 = false
    p390 = 201
  end
  if p390 == 201 then
    if v15 then
      p390 = 203
    else
      p390 = 202
    end
  end
  if p390 == 202 then
    v14 = 2
    p390 = 238
  end
  if p390 == 203 then
    v16 = Engine.IsPlayingWithTouchscreen
    v16 = v16()
    if v16 then
      p390 = 205
    else
      p390 = 204
    end
  end
  if p390 == 204 then
    v15 = false
    p390 = 209
  end
  if p390 == 205 then
    v16 = _T.InfoPopup_Grid
    if v16 == nil then
      p390 = 208
    else
      p390 = 206
    end
  end
  if p390 == 206 then
    v17 = v16.ShowSelectButton
    if v17 == nil then
      p390 = 208
    else
      p390 = 207
    end
  end
  if p390 == 207 then
    v17 = v16.ShowSelectButton
    v18 = _T.InfoPopup_Data
    v15 = v17(v18)
    p390 = 209
  end
  if p390 == 208 then
    v15 = false
    p390 = 209
  end
  if p390 == 209 then
    if not v15 then
      p390 = 211
    else
      p390 = 210
    end
  end
  if p390 == 210 then
    v15 = mMovie
    v17 = "Popup.SelectButton"
    v18 = 15
    v15 = v15:GetNumberVariable(v17, v18)
    v14 = v14 + v15
    p390 = 237
  end
  if p390 == 211 then
    v15 = u14
    v15 = v15.Ternary
    v18 = _T.InfoPopup_Grid
    v19 = false
    if v18 == nil then
      p390 = 213
    else
      p390 = 212
    end
  end
  if p390 == 212 then
    v19 = v18.CanPreviewElements
    p390 = 213
  end
  if p390 == 213 then
    v20 = u3
    if v20 == nil then
      p390 = 218
    else
      p390 = 214
    end
  end
  if p390 == 214 then
    v20 = u3
    v20 = v20.CanPreviewOverride
    if v20 == nil then
      p390 = 218
    else
      p390 = 215
    end
  end
  if p390 == 215 then
    v20 = v19
    if not v20 then
      p390 = 217
    else
      p390 = 216
    end
  end
  if p390 == 216 then
    v20 = u3
    v20 = v20.CanPreviewOverride
    p390 = 217
  end
  if p390 == 217 then
    v19 = v20
    p390 = 218
  end
  if p390 == 218 then
    v17 = v19
    if v17 then
      p390 = 229
    else
      p390 = 219
    end
  end
  if p390 == 219 then
    v17 = false
    v18 = u3
    if v18 == nil then
      p390 = 223
    else
      p390 = 220
    end
  end
  if p390 == 220 then
    v18 = u3
    v18 = v18.mUnequipItem
    if v18 ~= nil then
      p390 = 222
    else
      p390 = 221
    end
  end
  if p390 == 221 then
    v17 = false
    p390 = 223
  end
  if p390 == 222 then
    v17 = true
    p390 = 223
  end
  if p390 == 223 then
    if v17 then
      p390 = 229
    else
      p390 = 224
    end
  end
  if p390 == 224 then
    v16 = false
    v17 = u3
    if v17 == nil then
      p390 = 228
    else
      p390 = 225
    end
  end
  if p390 == 225 then
    v17 = u3
    v17 = v17.RightPressedCallback
    if v17 ~= nil then
      p390 = 227
    else
      p390 = 226
    end
  end
  if p390 == 226 then
    v16 = false
    p390 = 228
  end
  if p390 == 227 then
    v16 = true
    p390 = 228
  end
  if p390 == 228 then
    if not v16 then
      p390 = 236
    else
      p390 = 229
    end
  end
  if p390 == 229 then
    v18 = Engine.IsPlayingWithTouchscreen
    v18 = v18()
    if v18 then
      p390 = 231
    else
      p390 = 230
    end
  end
  if p390 == 230 then
    v17 = false
    p390 = 235
  end
  if p390 == 231 then
    v18 = _T.InfoPopup_Grid
    if v18 == nil then
      p390 = 234
    else
      p390 = 232
    end
  end
  if p390 == 232 then
    v19 = v18.ShowSelectButton
    if v19 == nil then
      p390 = 234
    else
      p390 = 233
    end
  end
  if p390 == 233 then
    v19 = v18.ShowSelectButton
    v20 = _T.InfoPopup_Data
    v17 = v19(v20)
    p390 = 235
  end
  if p390 == 234 then
    v17 = false
    p390 = 235
  end
  if p390 == 235 then
    v16 = not v17
    p390 = 236
  end
  if p390 == 236 then
    v17 = 25
    v18 = 0
    v15 = v15(v16, v17, v18)
    v14 = v14 + v15
    p390 = 237
  end
  if p390 == 237 then
    v17 = u9
    v16 = v17 + 10
    v15 = v16 + v14
    u9 = v15
    p390 = 238
  end
  if p390 == 238 then
    v15 = u32
    v15(v14)
    do return end
  end
end

function proto_63()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12
  local p118 = 0
  if p118 == 0 then
    v1 = u0
    if v1 ~= "" then
      p118 = 2
    else
      p118 = 1
    end
  end
  if p118 == 1 then
    v0 = false
    p118 = 3
  end
  if p118 == 2 then
    v0 = true
    p118 = 3
  end
  if p118 == 3 then
    v1 = mMovie
    v3 = "Popup.Header"
    v4 = 13
    v1:Name__d9713943(v3, v4, v0)
    if not v0 then
      p118 = 5
    else
      p118 = 4
    end
  end
  if p118 == 4 then
    v1 = 22
    p118 = 6
  end
  if p118 == 5 then
    v1 = 0
    p118 = 6
  end
  if p118 == 6 then
    u1 = v1
    v1 = mMovie
    v3 = "Popup.Header.Label"
    v4 = 14
    v5 = 330
    v1:SetNumberVariable(v3, v4, v5)
    v1 = mMovie
    v3 = "Popup.Header.Label"
    v4 = 36
    v5 = u0
    v1:SetStringVariable(v3, v4, v5)
    v1 = _T.InfoPopup_Grid
    v2 = string.upper
    v3 = u3
    v3 = v3.GetGridItemName
    v4 = mMovie
    v6 = u4
    v7 = u4
    v7 = v7.MetaData
    v2 = v2(v3(v4, v1, v6, v7))
    u2 = v2
    v2 = u2
    if v2 == "" then
      p118 = 9
    else
      p118 = 7
    end
  end
  if p118 == 7 then
    v2 = u4
    v2 = v2.IsEliteCrewMember
    if not v2 then
      p118 = 9
    else
      p118 = 8
    end
  end
  if p118 == 8 then
    v3 = u2
    v4 = mMovie
    v6 = " <ELITE_CREW_MEMBER>"
    v7 = true
    v4 = v4:GetLocalized(v6, v7)
    v2 = v3 .. v4
    u2 = v2
    p118 = 9
  end
  if p118 == 9 then
    v2 = 0
    u5 = v2
    v2 = 0
    u6 = v2
    v2 = u7
    v2(v1)
    v2 = 0
    v3 = u8
    v3 = v3:GetHowManyElements()
    v4 = 1
    if v4 < v3 then
      p118 = 11
    else
      p118 = 10
    end
  end
  if p118 == 10 then
    v3 = u8
    v3 = v3.mLeaveRoom
    if not v3 then
      p118 = 12
    else
      p118 = 11
    end
  end
  if p118 == 11 then
    v4 = mMovie
    v6 = "Popup.InfoToggle.Callout"
    v7 = 40
    v4 = v4:GetNumberVariable(v6, v7)
    v3 = v4 or 0
    v5 = 5
    v4 = v5 + v3
    v6 = u8
    v6 = v6.mForcedHorizontalSeparation
    v7 = u8
    v7 = v7:GetHowManyElements()
    v5 = v6 * v7
    v2 = v4 + v5
    p118 = 12
  end
  if p118 == 12 then
    v3 = mMovie
    v5 = "Popup.Title"
    v6 = 14
    v7 = 330
    v3:SetNumberVariable(v5, v6, v7)
    v3 = mMovie
    v5 = "Popup.Title"
    v6 = 36
    v8 = "<p><font color=\""
    v9 = u9
    v9 = v9.FloatingContentHighlightHex
    v10 = "\">"
    v11 = u2
    v12 = "</font></p>"
    v7 = v8 .. v9 .. v10 .. v11 .. v12
    v3:SetStringVariable(v5, v6, v7)
    v3 = u2
    if v3 == "" then
      p118 = 16
    else
      p118 = 13
    end
  end
  if p118 == 13 then
    v5 = u6
    v6 = mMovie
    v8 = "Popup.Title"
    v9 = 41
    v6 = v6:GetNumberVariable(v8, v9)
    v4 = v5 + v6
    v3 = v4 - 9
    u6 = v3
    v4 = mMovie
    v6 = "Popup.Title"
    v7 = 93
    v4 = v4:GetNumberVariable(v6, v7)
    v3 = v4 + v2
    v4 = 330
    if v3 <= v4 then
      p118 = 15
    else
      p118 = 14
    end
  end
  if p118 == 14 then
    v4 = u6
    v3 = v4 + 20
    u6 = v3
    p118 = 15
  end
  if p118 == 15 then
    v3 = mMovie
    v5 = "Popup.InfoToggle"
    v6 = 1
    v7 = u6
    v3:SetNumberVariable(v5, v6, v7)
    v4 = u6
    v3 = v4 + 25
    u6 = v3
    p118 = 17
  end
  if p118 == 16 then
    v4 = u6
    v3 = v4 + 9
    u6 = v3
    p118 = 17
  end
  if p118 == 17 then
    v3 = u10
    v3()
    v3 = nil
    v4 = true
    v5 = u4
    v5 = v5.BuySlot
    if not v5 then
      p118 = 24
    else
      p118 = 18
    end
  end
  if p118 == 18 then
    v5 = u4
    v5 = v5.Disabled
    if v5 then
      p118 = 24
    else
      p118 = 19
    end
  end
  if p118 == 19 then
    v5 = u4
    v5 = v5.EmptyCount
    v6 = u4
    v6 = v6.MaxCount
    if v6 == nil then
      p118 = 21
    else
      p118 = 20
    end
  end
  if p118 == 20 then
    v6 = mMovie
    v8 = "/Lotus/Language/Menu/Global_LimitedExtraSlots"
    v9 = true
    v10 = { CUR = nil, MAX = nil }
    v10.CUR = v5
    v11 = u4
    v11 = v11.MaxCount
    v10.MAX = v11
    v3 = v6:GetLocalized(v8, v9, v10)
    p118 = 37
  end
  if p118 == 21 then
    if v5 ~= 1 then
      p118 = 23
    else
      p118 = 22
    end
  end
  if p118 == 22 then
    v6 = mMovie
    v8 = "/Lotus/Language/Menu/Global_FreeSlot"
    v9 = true
    v3 = v6:GetLocalized(v8, v9)
    p118 = 37
  end
  if p118 == 23 then
    v6 = mMovie
    v8 = "/Lotus/Language/Menu/Global_FreeSlots"
    v9 = true
    v10 = { free = nil }
    v10.free = v5
    v3 = v6:GetLocalized(v8, v9, v10)
    p118 = 37
  end
  if p118 == 24 then
    v5 = u4
    v5 = v5.IsAbility
    if not v5 then
      p118 = 31
    else
      p118 = 25
    end
  end
  if p118 == 25 then
    v5 = u4
    v5 = v5.HideAbilityRank
    if v5 then
      p118 = 31
    else
      p118 = 26
    end
  end
  if p118 == 26 then
    v5 = u4
    v5 = v5.Level
    if v5 ~= 3 then
      p118 = 28
    else
      p118 = 27
    end
  end
  if p118 == 27 then
    v5 = TitleCase
    v6 = mMovie
    v8 = "/Lotus/Language/Ranks/MaxRank"
    v9 = true
    v3 = v5(v6:GetLocalized(v8, v9))
    p118 = 29
  end
  if p118 == 28 then
    v5 = TitleCase
    v6 = mMovie
    v8 = "/Lotus/Language/Menu/Global_FormattedRankCaps"
    v9 = true
    v10 = { RANK = nil }
    v11 = u4
    v11 = v11.Level
    v10.RANK = v11
    v3 = v5(v6:GetLocalized(v8, v9, v10))
    p118 = 29
  end
  if p118 == 29 then
    v5 = u4
    v5 = v5.Locked
    if not v5 then
      p118 = 37
    else
      p118 = 30
    end
  end
  if p118 == 30 then
    v6 = mMovie
    v8 = "<LOCKED>"
    v9 = true
    v6 = v6:GetLocalized(v8, v9)
    v3 = v3 .. v6
    p118 = 37
  end
  if p118 == 31 then
    v5 = u4
    v5 = v5.IsPAUpgrade
    if not v5 then
      p118 = 33
    else
      p118 = 32
    end
  end
  if p118 == 32 then
    v5 = mMovie
    v7 = "/Lotus/Language/PrimeStore/PrimeAccessUpgradeSubtitle"
    v8 = true
    v3 = v5:GetLocalized(v7, v8)
    p118 = 37
  end
  if p118 == 33 then
    v5 = u4
    v5 = v5.WeeklyLocked
    if not v5 then
      p118 = 35
    else
      p118 = 34
    end
  end
  if p118 == 34 then
    v5 = mMovie
    v7 = "/Lotus/Language/Store/PerWeekPurchase"
    v8 = false
    v3 = v5:GetLocalized(v7, v8)
    v4 = false
    p118 = 37
  end
  if p118 == 35 then
    v5 = u4
    v5 = v5.SubtitleOverride
    if not v5 then
      p118 = 37
    else
      p118 = 36
    end
  end
  if p118 == 36 then
    v5 = u4
    v3 = v5.SubtitleOverride
    p118 = 37
  end
  if p118 == 37 then
    if v3 ~= nil then
      p118 = 39
    else
      p118 = 38
    end
  end
  if p118 == 38 then
    v5 = false
    p118 = 40
  end
  if p118 == 39 then
    v5 = true
    p118 = 40
  end
  if p118 == 40 then
    v6 = mMovie
    v8 = "Popup.Subtitle"
    v9 = 13
    v6:Name__d9713943(v8, v9, v5)
    if not v5 then
      p118 = 44
    else
      p118 = 41
    end
  end
  if p118 == 41 then
    v6 = mMovie
    v8 = "Popup.Subtitle"
    v9 = 1
    v11 = u6
    v10 = v11 - 8
    v6:SetNumberVariable(v8, v9, v10)
    if not v4 then
      p118 = 43
    else
      p118 = 42
    end
  end
  if p118 == 42 then
    v6 = string.upper
    v3 = v6(v3)
    p118 = 43
  end
  if p118 == 43 then
    v6 = mMovie
    v8 = "Popup.Subtitle"
    v9 = 36
    v6:SetStringVariable(v8, v9, v3)
    v7 = u6
    v8 = mMovie
    v10 = "Popup.Subtitle"
    v11 = 41
    v8 = v8:GetNumberVariable(v10, v11)
    v6 = v7 + v8
    u6 = v6
    p118 = 44
  end
  if p118 == 44 then
    v6 = u4
    v6 = v6.DefaultItemInfoTab
    if v6 == nil then
      p118 = 47
    else
      p118 = 45
    end
  end
  if p118 == 45 then
    v6 = u8
    v8 = u4
    v8 = v8.DefaultItemInfoTab
    v6 = v6:GetElementInIndex(v8)
    if v6 == nil then
      p118 = 47
    else
      p118 = 46
    end
  end
  if p118 == 46 then
    v6 = u8
    v8 = u4
    v8 = v8.DefaultItemInfoTab
    v6:FocusElement(v8)
    p118 = 48
  end
  if p118 == 47 then
    v6 = u8
    v8 = 1
    v6:FocusElement(v8)
    p118 = 48
  end
  if p118 == 48 then
    v6 = u8
    v6:SelectCurrentElement()
    v8 = _T.InfoPopup_Grid
    v9 = false
    if v8 == nil then
      p118 = 50
    else
      p118 = 49
    end
  end
  if p118 == 49 then
    v9 = v8.CanPreviewElements
    p118 = 50
  end
  if p118 == 50 then
    v10 = u4
    if v10 == nil then
      p118 = 55
    else
      p118 = 51
    end
  end
  if p118 == 51 then
    v10 = u4
    v10 = v10.CanPreviewOverride
    if v10 == nil then
      p118 = 55
    else
      p118 = 52
    end
  end
  if p118 == 52 then
    v10 = v9
    if not v10 then
      p118 = 54
    else
      p118 = 53
    end
  end
  if p118 == 53 then
    v10 = u4
    v10 = v10.CanPreviewOverride
    p118 = 54
  end
  if p118 == 54 then
    v9 = v10
    p118 = 55
  end
  if p118 == 55 then
    v7 = v9
    if v7 then
      p118 = 66
    else
      p118 = 56
    end
  end
  if p118 == 56 then
    v7 = false
    v8 = u4
    if v8 == nil then
      p118 = 60
    else
      p118 = 57
    end
  end
  if p118 == 57 then
    v8 = u4
    v8 = v8.mUnequipItem
    if v8 ~= nil then
      p118 = 59
    else
      p118 = 58
    end
  end
  if p118 == 58 then
    v7 = false
    p118 = 60
  end
  if p118 == 59 then
    v7 = true
    p118 = 60
  end
  if p118 == 60 then
    if v7 then
      p118 = 66
    else
      p118 = 61
    end
  end
  if p118 == 61 then
    v6 = false
    v7 = u4
    if v7 == nil then
      p118 = 65
    else
      p118 = 62
    end
  end
  if p118 == 62 then
    v7 = u4
    v7 = v7.RightPressedCallback
    if v7 ~= nil then
      p118 = 64
    else
      p118 = 63
    end
  end
  if p118 == 63 then
    v6 = false
    p118 = 65
  end
  if p118 == 64 then
    v6 = true
    p118 = 65
  end
  if p118 == 65 then
    if not v6 then
      p118 = 73
    else
      p118 = 66
    end
  end
  if p118 == 66 then
    v8 = Engine.IsPlayingWithTouchscreen
    v8 = v8()
    if v8 then
      p118 = 68
    else
      p118 = 67
    end
  end
  if p118 == 67 then
    v7 = false
    p118 = 72
  end
  if p118 == 68 then
    v8 = _T.InfoPopup_Grid
    if v8 == nil then
      p118 = 71
    else
      p118 = 69
    end
  end
  if p118 == 69 then
    v9 = v8.ShowSelectButton
    if v9 == nil then
      p118 = 71
    else
      p118 = 70
    end
  end
  if p118 == 70 then
    v9 = v8.ShowSelectButton
    v10 = _T.InfoPopup_Data
    v7 = v9(v10)
    p118 = 72
  end
  if p118 == 71 then
    v7 = false
    p118 = 72
  end
  if p118 == 72 then
    v6 = not v7
    p118 = 73
  end
  if p118 == 73 then
    v7 = mMovie
    v9 = "Popup.PreviewTag"
    v10 = 13
    v7:Name__d9713943(v9, v10, v6)
    v7 = mMovie
    v9 = "Popup.PreviewCallout"
    v10 = 13
    v7:Name__d9713943(v9, v10, v6)
    v8 = u11
    v7 = IsNull
    v7 = v7(v8)
    if not v7 then
      p118 = 75
    else
      p118 = 74
    end
  end
  if p118 == 74 then
    do return end
  end
  if p118 == 75 then
    v7 = u11
    v9 = u12
    v7:SetText(v9())
    v7 = mMovie
    v9 = "Popup.SelectButton"
    v10 = 14
    v11 = u13
    v7:SetNumberVariable(v9, v10, v11)
    v7 = mMovie
    v9 = "Popup.SelectButton"
    v10 = 0
    v11 = 54
    v7:SetNumberVariable(v9, v10, v11)
    do return end
  end
end

function proto_64()
  local v0, v1, v2, v3, v4, v5, v6
  v0 = mMovie
  v2 = "Popup"
  v3 = 12
  v4 = 0
  v0:SetNumberVariable(v2, v3, v4)
  v0 = FlashInterpolate
  v1 = mMovie
  v2 = "Popup"
  v3 = 1
  v5 = 12
  v4 = {v5}
  v6 = 100
  v5 = {v6}
  v6 = 0.2
  v0(v1, v2, v3, v4, v5, v6)
  v0 = Engine.IsMobile
  v0 = v0()
  if v0 then
    v1 = _T.MobileInfoPopup
    v0 = IsNull
    v0 = v0(v1)
    if not v0 then
      v0 = mMovie
      v2 = "Popup"
      v3 = 5
      v4 = _T.MobileInfoPopup.InfoPopupScale
      v0:SetNumberVariable(v2, v3, v4)
      v0 = mMovie
      v2 = "Popup"
      v3 = 6
      v4 = _T.MobileInfoPopup.InfoPopupScale
      v0:SetNumberVariable(v2, v3, v4)
      do return end
    end
    v0 = mMovie
    v2 = "Popup"
    v3 = 5
    v4 = 100
    v0:SetNumberVariable(v2, v3, v4)
    v0 = mMovie
    v2 = "Popup"
    v3 = 6
    v4 = 100
    v0:SetNumberVariable(v2, v3, v4)
  end
  do return end
end

function proto_65(v0, v1)
  local v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16
  local c76 = -1
  repeat
    v9 = ipairs
    v10 = verticalParallaxFrameTypes
    v9, v10, v11 = v9(v10)
    for v12, v13 in v9, v10, v11 do
      v14 = v2:IsA(v13)
      if v14 then
        c76 = 15
        break
      end
      v13 = v10.AbilityResource
      v11 = v0:IsA(v13)
      local p71 = 0
      if p71 == 0 then
        v2 = u0
        v2 = v2.AbilityInitialized
        if v2 then
          p71 = 2
        else
          p71 = 1
        end
      end
      if p71 == 1 then
        v2 = IsNull
        v2 = v2(v0)
        if not v2 then
          p71 = 3
        else
          p71 = 2
        end
      end
      if p71 == 2 then
        do return end
      end
      if p71 == 3 then
        v2 = nil
        v3 = IsNull
        v3 = v3(v1)
        if v3 then
          p71 = 5
        else
          p71 = 4
        end
      end
      if p71 == 4 then
        v2 = v1
        p71 = 8
      end
      if p71 == 5 then
        v4 = u0
        v4 = v4.Suit
        v3 = IsNull
        v3 = v3(v4)
        if v3 then
          p71 = 8
        else
          p71 = 6
        end
      end
      if p71 == 6 then
        v3 = u0
        v2 = v3.Suit
        v3 = IsWeak
        v3 = v3(v2)
        if not v3 then
          p71 = 8
        else
          p71 = 7
        end
      end
      if p71 == 7 then
        v3 = Resource
        v2 = v3(v2)
        p71 = 8
      end
      if p71 == 8 then
        v3 = v0:GetVideoTexture()
        v4 = nil
        v5 = nil
        v6 = pairs
        v7 = u1
        v6, v7, v8 = v6(v7)
      end
      for v9, v10 in v6, v7, v8 do
      end
      if c76 ~= -1 then break end
      if v11 then
        v4 = v10.Images
        v5 = v10.PageCallout
      end
      v6 = mMovie
      v8 = v0:GetLocalizeTag()
      v8 = v8:c_str()
      v9 = false
      v6 = v6:GetLocalized(v8, v9)
      v7 = v0:GetIconTexture()
      v8 = true
      v9 = IsNull
      v9 = v9(v2)
      if v9 then
        c76 = 17
        break
      end
    end
    if c76 ~= -1 then break end
    break
  until true
  if c76 == 15 then
    v8 = false
  end
  v10 = u0
  v10 = v10.ResLoader
  v9 = IsNull
  v9 = v9(v10)
  if v9 then
    v9 = IsNull
    v9 = v9(v3)
    if not v9 then
      v9 = {v3:GetFullName()}
      v10 = ipairs
      v10, v11, v12 = v10(v4)
      for v13, v14 in v10, v11, v12 do
        v15 = table.insert
        v15(v9, v14:GetFullName())
      end
      for v13, v14 in v10, v11, v12 do
      end
      v10 = u0
      v11 = UISys.ScriptResLoader_Create
      v11 = v11(v9)
      v10.ResLoader = v11
      v10 = u0
      v11 = true
      v10.ResLoading = v11
    end
  end
  v9 = u2
  v9(v0)
  v9 = u0
  v10 = string.upper
  v10 = v10(v6)
  v9.Name = v10
  v9 = u0
  v12 = true
  v13 = false
  v10 = v0:GetActivationEnergyCost(v12, v13)
  v9.Energy = v10
  v9 = u0
  v12 = false
  v13 = false
  v10 = v0:GetActivationEnergyCost(v12, v13)
  v9.BaseEnergy = v10
  v9 = u0
  v9.Icon = v7
  v9 = u0
  v9.PreviewImage = v3
  v9 = u0
  v9.AdditionalPreviewImages = v4
  v9 = u0
  v9.PageCallout = v5
  v9 = u0
  v10 = 3
  v9.MaxLevel = v10
  v9 = u0
  v10 = v0:GetScript()
  v9.Script = v10
  v9 = u0
  v10 = v0:GetLocalizeTag()
  v9.LocTag = v10
  v9 = u0
  v9.Resource = v0
  v9 = u0
  v9.AutoParallaxX = v8
  v9 = u0
  v10 = not v8
  v9.AutoParallaxY = v10
  v9 = nil
  v10 = u0
  v10 = v10.AbilityLevelOverride
  if v10 ~= nil then
    v10 = u0
    v9 = v10.AbilityLevelOverride
  else
    v10 = IsNull
    v10 = v10(v2)
    if not v10 then
      v11 = u0
      v11 = v11.AbilityIndex
      v10 = IsNull
      v10 = v10(v11)
      if not v10 then
        v12 = u0
        v12 = v12.AbilityIndex
        v10 = v2:GetAbilityLevel(v12)
        v9 = v10 - 1
      end
    end
  end
  v10 = 0
  v11 = u0
  v12 = false
  v11.Locked = v12
  if not v9 then
    v11 = u0
    v13 = 0
    v12 = math.max
    v12 = v12(v13, v9)
    v11.Level = v12
    v11 = IsNull
    v11 = v11(v2)
    if not v11 then
      v11 = v2:GetLevel()
      v14 = u0
      v14 = v14.AbilityIndex
      v10 = v2:Name__5682bdb4(v14)
      v12 = u0
      if v10 <= v11 then
        v13 = false
      else
        v13 = true
      end
      v12.Locked = v13
    end
  end
  v11 = u0
  v12 = true
  v11.IsAbility = v12
  v11 = u0
  v11 = v11.HideRankUp
  if not v11 then
    v11 = u0
    v11 = v11.Locked
    if not v11 then
      v11 = IsNull
      v11 = v11(v2)
      if not v11 then
        v11 = u0
        v14 = u0
        v14 = v14.AbilityIndex
        v16 = u0
        v16 = v16.Level
        v15 = v16 + 2
        v12 = v2:Name__0f88464a(v14, v15)
        v11.NextSuitLevel = v12
        v11 = u0
        v14 = u0
        v14 = v14.AbilityIndex
        v16 = u0
        v16 = v16.Level
        v15 = v16 + 1
        v12 = v2:Name__0f88464a(v14, v15)
        v11.LastSuitLevel = v12
        v11 = u0
        v11 = v11.NextSuitLevel
        if v11 == 255 then
          v11 = u0
          v12 = nil
          v11.NextSuitLevel = v12
        end
      end
    else
      v11 = u0
      v11.NextSuitLevel = v10
      v11 = u0
      v12 = 0
      v11.LastSuitLevel = v12
    end
    v11 = u0
    v11 = v11.NextSuitLevel
    if v11 ~= nil then
      v11 = gGameConfig
      v13 = u0
      v13 = v13.LastSuitLevel
      v11 = v11:Name__a534be9c(v13, v2)
      v13 = v2:GetXP()
      v12 = v13 - v11
      v14 = gGameConfig
      v16 = u0
      v16 = v16.NextSuitLevel
      v14 = v14:Name__a534be9c(v16, v2)
      v13 = v14 - v11
      v14 = u0
      v15 = v12 / v13
      v14.LevelProgress = v15
    end
  end
  v11 = u0
  v12 = true
  v11.AbilityInitialized = v12
  do return end
end

function proto_66()
  local v0, v1, v2
  local p9 = 0
  if p9 == 0 then
    u0 = v0
    v0 = u1
    if v0 == nil then
      p9 = 3
    else
      p9 = 1
    end
  end
  if p9 == 1 then
    v0 = u1
    v0 = v0.mTipSoundOverride
    if v0 == nil then
      p9 = 3
    else
      p9 = 2
    end
  end
  if p9 == 2 then
    v0 = u2
    v0 = v0.PlaySound
    v1 = u1
    v1 = v1.mTipSoundOverride
    v0(v1)
    p9 = 4
  end
  if p9 == 3 then
    v0 = u2
    v0 = v0.PlaySound
    v1 = _G
    v1 = v1.UISound_ItemTip
    v0(v1)
    p9 = 4
  end
  if p9 == 4 then
    v0 = u3
    v0()
    v0 = false
    u4 = v0
    v0 = mMovie
    v2 = true
    v0:SetVisible(v2)
    v0 = u5
    if not v0 then
      p9 = 6
    else
      p9 = 5
    end
  end
  if p9 == 5 then
    v0 = u6
    v0()
    p9 = 6
  end
  if p9 == 6 then
    do return end
  end
end

function proto_67()
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34
  local p272 = 0
  if p272 == 0 then
    v1 = mMovie
    v0 = IsNull
    v0 = v0(v1)
    if not v0 then
      p272 = 2
    else
      p272 = 1
    end
  end
  if p272 == 1 then
    do return end
  end
  if p272 == 2 then
    v0 = RealDeltaTime
    v0 = v0()
    v2 = u0
    v1 = IsNull
    v1 = v1(v2)
    if v1 then
      p272 = 4
    else
      p272 = 3
    end
  end
  if p272 == 3 then
    v1 = u0
    v1:Update(v0)
    p272 = 4
  end
  if p272 == 4 then
    v1 = mMovie
    v1:Name__b7f5bbc5(v0)
    v2 = u1
    v1 = IsNull
    v1 = v1(v2)
    if v1 then
      p272 = 6
    else
      p272 = 5
    end
  end
  if p272 == 5 then
    v1 = u1
    v1:Update()
    p272 = 6
  end
  if p272 == 6 then
    v1 = u2
    if not v1 then
      p272 = 9
    else
      p272 = 7
    end
  end
  if p272 == 7 then
    v1 = u3
    if v1 then
      p272 = 9
    else
      p272 = 8
    end
  end
  if p272 == 8 then
    do return end
  end
  if p272 == 9 then
    v2 = _T
    v4 = "InfoPopup_Data"
    v5 = u4
    v3 = v4 .. v5
    v1 = v2[v3]
    if v1 == nil then
      p272 = 16
    else
      p272 = 10
    end
  end
  if p272 == 10 then
    v2 = v1.StoreItem
    if v2 ~= nil then
      p272 = 12
    else
      p272 = 11
    end
  end
  if p272 == 11 then
    v2 = v1.mStoreItem
    v1.StoreItem = v2
    p272 = 12
  end
  if p272 == 12 then
    v2 = v1.StoreItem
    if v2 ~= nil then
      p272 = 16
    else
      p272 = 13
    end
  end
  if p272 == 13 then
    v2 = v1.CodexEntry
    if v2 ~= nil then
      p272 = 16
    else
      p272 = 14
    end
  end
  if p272 == 14 then
    v2 = v1.CustomEntry
    if v2 then
      p272 = 16
    else
      p272 = 15
    end
  end
  if p272 == 15 then
    v1 = nil
    p272 = 16
  end
  if p272 == 16 then
    v2 = u5
    if (v2 ~= nil or v1 ~= nil) then
      p272 = 19
    else
      p272 = 18
    end
  end
  if p272 == 18 then
    do return end
  end
  if p272 == 19 then
    v2 = true
    v3 = _T.RadialSolarMapOpen
    if v3 == true then
      p272 = 21
    else
      p272 = 20
    end
  end
  if p272 == 20 then
    v4 = _T.ShawzinMovie
    v3 = IsNull
    v3 = v3(v4)
    v2 = not v3
    p272 = 21
  end
  if p272 == 21 then
    v3 = u6
    if v3 == v2 then
      p272 = 23
    else
      p272 = 22
    end
  end
  if p272 == 22 then
    u6 = v2
    v3 = mMovie
    v5 = u6
    v3:SetPreDrawUpdate(v5)
    p272 = 23
  end
  if p272 == 23 then
    v3 = u7
    if not v3 then
      p272 = 27
    else
      p272 = 24
    end
  end
  if p272 == 24 then
    v4 = u8
    v3 = IsNull
    v3 = v3(v4)
    if v3 then
      p272 = 27
    else
      p272 = 25
    end
  end
  if p272 == 25 then
    v3 = u8
    v3 = v3:IsDone()
    if not v3 then
      p272 = 27
    else
      p272 = 26
    end
  end
  if p272 == 26 then
    v3 = u9
    v4 = false
    v3(v4)
    v3 = u10
    v3()
    p272 = 27
  end
  if p272 == 27 then
    v3 = u5
    if v3 ~= v1 then
      p272 = 30
    else
      p272 = 28
    end
  end
  if p272 == 28 then
    if v1 == nil then
      p272 = 85
    else
      p272 = 29
    end
  end
  if p272 == 29 then
    v3 = v1.Refresh
    if not v3 then
      p272 = 85
    else
      p272 = 30
    end
  end
  if p272 == 30 then
    v3 = true
    if v1 == nil then
      p272 = 34
    else
      p272 = 31
    end
  end
  if p272 == 31 then
    v4 = u5
    if v4 ~= nil then
      p272 = 33
    else
      p272 = 32
    end
  end
  if p272 == 32 then
    v3 = false
    p272 = 34
  end
  if p272 == 33 then
    v3 = true
    p272 = 34
  end
  if p272 == 34 then
    u5 = v1
    v4 = u0
    v6 = u11
    v4:RemoveTimer(v6)
    v4 = u1
    v6 = false
    v4:SetActive(v6)
    v4 = nil
    u12 = v4
    v4 = 1
    u13 = v4
    v4 = false
    u14 = v4
    v4 = false
    u15 = v4
    v4 = u5
    if v4 == nil then
      p272 = 79
    else
      p272 = 35
    end
  end
  if p272 == 35 then
    v4 = u5
    v4 = v4.mApplyThemes
    v5 = u16
    if v5 == v4 then
      p272 = 37
    else
      p272 = 36
    end
  end
  if p272 == 36 then
    u16 = v4
    v5 = u17
    v5()
    p272 = 37
  end
  if p272 == 37 then
    v5 = u5
    v5 = v5.mStatsCountOverride
    if not v5 then
      p272 = 39
    else
      p272 = 38
    end
  end
  if p272 == 38 then
    v5 = u5
    v5 = v5.mStatsCountOverride
    u13 = v5
    p272 = 39
  end
  if p272 == 39 then
    v5 = u5
    v6 = mMovie
    v5.Movie = v6
    v5 = u5
    v6 = u18
    v5.IsWithinPopup = v6
    v5 = u5
    v6 = 0
    v5.CompareHeight = v6
    v6 = u5
    v6 = v6.Refresh
    v5 = not v6
    v6 = u5
    v6 = v6.Refresh
    if not v6 then
      p272 = 43
    else
      p272 = 40
    end
  end
  if p272 == 40 then
    v6 = u5
    v7 = nil
    v6.Refresh = v7
    v6 = u5
    v6 = v6.IsAbility
    if not v6 then
      p272 = 42
    else
      p272 = 41
    end
  end
  if p272 == 41 then
    v6 = u5
    v7 = true
    v6.SkipVideoReset = v7
    p272 = 42
  end
  if p272 == 42 then
    v3 = false
    p272 = 43
  end
  if p272 == 43 then
    v6 = u5
    v6 = v6.IsAbility
    if not v6 then
      p272 = 62
    else
      p272 = 44
    end
  end
  if p272 == 44 then
    v6 = u5
    v6 = v6.AbilityInitialized
    if not v6 then
      p272 = 46
    else
      p272 = 45
    end
  end
  if p272 == 45 then
    v7 = u5
    v7 = v7.Resource
    v6 = IsNull
    v6 = v6(v7)
    if not v6 then
      p272 = 62
    else
      p272 = 46
    end
  end
  if p272 == 46 then
    v6 = u5
    v7 = false
    v6.AbilityInitialized = v7
    v7 = u5
    v7 = v7.Suit
    v6 = IsNull
    v6 = v6(v7)
    if not v6 then
      p272 = 51
    else
      p272 = 47
    end
  end
  if p272 == 47 then
    v7 = u5
    v7 = v7.SourceAvatar
    v6 = IsNull
    v6 = v6(v7)
    if v6 then
      p272 = 51
    else
      p272 = 48
    end
  end
  if p272 == 48 then
    v6 = u5
    v6 = v6.SourceAvatarAlternateSuit
    if not v6 then
      p272 = 50
    else
      p272 = 49
    end
  end
  if p272 == 49 then
    v6 = u5
    v7 = u5
    v7 = v7.SourceAvatar
    v7 = v7:InventoryControl()
    v7 = v7:Name__d22c79ce()
    v6.Suit = v7
    p272 = 51
  end
  if p272 == 50 then
    v6 = u5
    v7 = u5
    v7 = v7.SourceAvatar
    v7 = v7:InventoryControl()
    v7 = v7:GetActivePowerSuit()
    v6.Suit = v7
    p272 = 51
  end
  if p272 == 51 then
    v6 = u5
    v6 = v6.Resource
    v7 = nil
    v9 = u5
    v9 = v9.Suit
    v8 = IsNull
    v8 = v8(v9)
    if v8 then
      p272 = 54
    else
      p272 = 52
    end
  end
  if p272 == 52 then
    v8 = u5
    v7 = v8.Suit
    v8 = IsWeak
    v8 = v8(v7)
    if not v8 then
      p272 = 54
    else
      p272 = 53
    end
  end
  if p272 == 53 then
    v8 = Resource
    v7 = v8(v7)
    p272 = 54
  end
  if p272 == 54 then
    v8 = IsNull
    v8 = v8(v6)
    if not v8 then
      p272 = 58
    else
      p272 = 55
    end
  end
  if p272 == 55 then
    v9 = u5
    v9 = v9.AbilityIndex
    v8 = IsNull
    v8 = v8(v9)
    if v8 then
      p272 = 58
    else
      p272 = 56
    end
  end
  if p272 == 56 then
    v8 = IsNull
    v8 = v8(v7)
    if v8 then
      p272 = 58
    else
      p272 = 57
    end
  end
  if p272 == 57 then
    v10 = u5
    v10 = v10.AbilityIndex
    v6 = v7:GetAbilityByIndex(v10)
    p272 = 58
  end
  if p272 == 58 then
    v8 = IsNull
    v8 = v8(v6)
    if v8 then
      p272 = 62
    else
      p272 = 59
    end
  end
  if p272 == 59 then
    v8 = IsWeak
    v8 = v8(v6)
    if not v8 then
      p272 = 61
    else
      p272 = 60
    end
  end
  if p272 == 60 then
    v8 = u5
    v9 = true
    v8.AllInOne = v9
    v8 = u5
    v8.ResultItemType = v6
    p272 = 62
  end
  if p272 == 61 then
    v8 = u19
    v8(v6, v7)
    p272 = 62
  end
  if p272 == 62 then
    v7 = u5
    v7 = v7.CrewMemberInfo
    v6 = IsNull
    v6 = v6(v7)
    if v6 then
      p272 = 64
    else
      p272 = 63
    end
  end
  if p272 == 63 then
    v6 = u5
    v6 = v6.CrewMemberInfo
    v6 = v6.mPowersuitInfo
    v6 = v6.mItemType
    u12 = v6
    v6 = u5
    v8 = u5
    v8 = v8.CrewMemberInfo
    v8 = v8:IsNemesis()
    v7 = not v8
    v6.AllInOne = v7
    p272 = 73
  end
  if p272 == 64 then
    v7 = u5
    v7 = v7.StoreItem
    v6 = IsNull
    v6 = v6(v7)
    if v6 then
      p272 = 72
    else
      p272 = 65
    end
  end
  if p272 == 65 then
    v6 = u5
    v6 = v6.StoreItem
    v8 = v6:GetStatsCount()
    v9 = u13
    v7 = math.max
    v7 = v7(v8, v9)
    u13 = v7
    v9 = gLotusWeaponStoreItemType
    v7 = v6:IsA(v9)
    if not v7 then
      p272 = 69
    else
      p272 = 66
    end
  end
  if p272 == 66 then
    v7 = v6:IsEvolvingWeapon()
    if not v7 then
      p272 = 69
    else
      p272 = 67
    end
  end
  if p272 == 67 then
    v7 = u13
    v8 = 1
    if v7 <= v8 then
      p272 = 69
    else
      p272 = 68
    end
  end
  if p272 == 68 then
    v7 = u13
    v7 = v7 - 1
    u13 = v7
    p272 = 69
  end
  if p272 == 69 then
    v9 = gRecipeStoreItemType
    v7 = v6:IsA(v9)
    if not v7 then
      p272 = 71
    else
      p272 = 70
    end
  end
  if p272 == 70 then
    v7 = v6:GetResultType()
    u12 = v7
    p272 = 73
  end
  if p272 == 71 then
    v7 = v6:GetItem()
    u12 = v7
    p272 = 73
  end
  if p272 == 72 then
    v6 = u5
    v6 = v6.ResultItemType
    u12 = v6
    p272 = 73
  end
  if p272 == 73 then
    v7 = u12
    v6 = IsNull
    v6 = v6(v7)
    if v6 then
      p272 = 76
    else
      p272 = 74
    end
  end
  if p272 == 74 then
    v6 = u12
    v8 = u20
    v6 = v6:IsA(v8)
    if not v6 then
      p272 = 76
    else
      p272 = 75
    end
  end
  if p272 == 75 then
    v6 = u5
    v7 = true
    v6.AllInOne = v7
    p272 = 76
  end
  if p272 == 76 then
    v6 = u0
    v8 = 0.01
    v9 = function()
      local c20v0, c20v1, c20v2
      local p9 = 0
      if p9 == 0 then
        u11 = c20v0
        c20v0 = v5
        if c20v0 == nil then
          p9 = 3
        else
          p9 = 1
        end
      end
      if p9 == 1 then
        c20v0 = v5
        c20v0 = c20v0.mTipSoundOverride
        if c20v0 == nil then
          p9 = 3
        else
          p9 = 2
        end
      end
      if p9 == 2 then
        c20v0 = u21
        c20v0 = c20v0.PlaySound
        c20v1 = v5
        c20v1 = c20v1.mTipSoundOverride
        c20v0(c20v1)
        p9 = 4
      end
      if p9 == 3 then
        c20v0 = u21
        c20v0 = c20v0.PlaySound
        c20v1 = _G
        c20v1 = c20v1.UISound_ItemTip
        c20v0(c20v1)
        p9 = 4
      end
      if p9 == 4 then
        c20v0 = u22
        c20v0()
        c20v0 = false
        u2 = c20v0
        c20v0 = mMovie
        c20v2 = true
        c20v0:SetVisible(c20v2)
        c20v0 = v5
        if not c20v0 then
          p9 = 6
        else
          p9 = 5
        end
      end
      if p9 == 5 then
        c20v0 = u23
        c20v0()
        p9 = 6
      end
      if p9 == 6 then
        do return end
      end
    end
    v6 = v6:AddTimer(v8, v9)
    u11 = v6
    v6 = u5
    v6 = v6.MetaData
    if v6 ~= nil then
      p272 = 78
    else
      p272 = 77
    end
  end
  if p272 == 77 then
    v6 = u5
    v7 = { HideOwned = true }
    v6.MetaData = v7
    p272 = 79
  end
  if p272 == 78 then
    v6 = u5
    v6 = v6.MetaData
    v7 = true
    v6.HideOwned = v7
    v6 = u5
    v6 = v6.MetaData
    v7 = nil
    v6.ShowCheckmark = v7
    p272 = 79
  end
  if p272 == 79 then
    if not v3 then
      p272 = 81
    else
      p272 = 80
    end
  end
  if p272 == 80 then
    v4 = u24
    v4()
    p272 = 81
  end
  if p272 == 81 then
    v5 = u5
    if v5 ~= nil then
      p272 = 83
    else
      p272 = 82
    end
  end
  if p272 == 82 then
    v4 = false
    p272 = 84
  end
  if p272 == 83 then
    v4 = true
    p272 = 84
  end
  if p272 == 84 then
    v5 = mMovie
    v7 = not v4
    v5:SetIgnoreInput(v7)
    v5 = mMovie
    v5:SetForcedInput(v4)
    p272 = 85
  end
  if p272 == 85 then
    v3 = u5
    if v3 == nil then
      p272 = 153
    else
      p272 = 86
    end
  end
  if p272 == 86 then
    v3 = u14
    if not v3 then
      p272 = 89
    else
      p272 = 87
    end
  end
  if p272 == 87 then
    v4 = u5
    v4 = v4.StoreItem
    v3 = IsNull
    v3 = v3(v4)
    if v3 then
      p272 = 89
    else
      p272 = 88
    end
  end
  if p272 == 88 then
    v3 = u25
    v3()
    p272 = 89
  end
  if p272 == 89 then
    v3 = u5
    v3 = v3.RarityChances
    if v3 == nil then
      p272 = 91
    else
      p272 = 90
    end
  end
  if p272 == 90 then
    v3 = u26
    v6 = v0 / 2
    v7 = u26
    v7 = v7.x
    v5 = v6 + v7
    v4 = v5 % 1
    v3.x = v4
    v3 = u26
    v7 = -v0
    v6 = v7 / 40
    v7 = u26
    v7 = v7.y
    v5 = v6 + v7
    v4 = v5 % 1
    v3.y = v4
    v3 = u27
    v3 = v3.UpdateRarityBar
    v4 = mMovie
    v5 = "Popup.RarityBar"
    v6 = u26
    v7 = false
    v3(v4, v5, v6, v7)
    p272 = 91
  end
  if p272 == 91 then
    v3 = u5
    v3 = v3.ResLoading
    if v3 ~= nil then
      p272 = 95
    else
      p272 = 92
    end
  end
  if p272 == 92 then
    v4 = u5
    v4 = v4.PreviewImage
    v3 = IsNull
    v3 = v3(v4)
    if v3 then
      p272 = 95
    else
      p272 = 93
    end
  end
  if p272 == 93 then
    v3 = IsWeak
    v4 = u5
    v4 = v4.PreviewImage
    v3 = v3(v4)
    if not v3 then
      p272 = 95
    else
      p272 = 94
    end
  end
  if p272 == 94 then
    v3 = u5
    v4 = UISys.ScriptResLoader_Create
    v6 = u5
    v6 = v6.PreviewImage
    v5 = {v6:GetFullName()}
    v4 = v4(v5)
    v3.ResLoader = v4
    v3 = u5
    v4 = true
    v3.ResLoading = v4
    p272 = 95
  end
  if p272 == 95 then
    v3 = u5
    v3 = v3.ResLoading
    if v3 then
      p272 = 97
    else
      p272 = 96
    end
  end
  if p272 == 96 then
    v3 = u5
    v3 = v3.RefreshImage
    if not v3 then
      p272 = 102
    else
      p272 = 97
    end
  end
  if p272 == 97 then
    v4 = u5
    v4 = v4.ResLoader
    v3 = IsNull
    v3 = v3(v4)
    if v3 then
      p272 = 99
    else
      p272 = 98
    end
  end
  if p272 == 98 then
    v3 = u5
    v3 = v3.ResLoader
    v3 = v3:IsDone()
    if not v3 then
      p272 = 102
    else
      p272 = 99
    end
  end
  if p272 == 99 then
    v3 = print
    v4 = "loader done"
    v3(v4)
    v3 = u1
    v5 = false
    v3:SetActive(v5)
    v3 = u5
    v4 = false
    v3.ResLoading = v4
    v3 = u5
    v4 = false
    v3.RefreshImage = v4
    v4 = u5
    v4 = v4.PreviewImage
    v3 = IsNull
    v3 = v3(v4)
    if not v3 then
      p272 = 101
    else
      p272 = 100
    end
  end
  if p272 == 100 then
    v3 = mMovie
    v5 = "Popup.VideoPreview.Image"
    v6 = 13
    v7 = false
    v3:Name__d9713943(v5, v6, v7)
    p272 = 102
  end
  if p272 == 101 then
    v3 = u5
    v4 = Resource
    v5 = u5
    v5 = v5.PreviewImage
    v4 = v4(v5)
    v3.PreviewImage = v4
    v3 = mMovie
    v5 = "Popup.VideoPreview.Image"
    v6 = 13
    v7 = true
    v3:Name__d9713943(v5, v6, v7)
    v3 = mMovie
    v5 = "Popup.VideoPreview.Image"
    v3:StopVideoTexture(v5)
    v3 = mMovie
    v5 = "Popup.VideoPreview.Image"
    v6 = u5
    v6 = v6.PreviewImage
    v3:OverrideTexture(v5, v6)
    v3 = mMovie
    v5 = "Popup.VideoPreview.Image"
    v3:Name__f55ae1a2(v5)
    p272 = 102
  end
  if p272 == 102 then
    v3 = u0
    v5 = u11
    v3 = v3:HasTimer(v5)
    if v3 then
      p272 = 153
    else
      p272 = 103
    end
  end
  if p272 == 103 then
    v4 = _T
    v3 = v4.InfoPopup_Data
    if v3 == nil then
      p272 = 147
    else
      p272 = 104
    end
  end
  if p272 == 104 then
    v4 = v3.Rect
    v5 = nil
    v6 = 10
    v7 = mMovie
    v7 = v7:GetMovieWidth()
    v8 = mMovie
    v8 = v8:GetMovieHeight()
    v9 = _T.InfoPopup_Grid
    if v9 == nil then
      p272 = 107
    else
      p272 = 105
    end
  end
  if p272 == 105 then
    v10 = v9.PopupPadding
    if v10 == nil then
      p272 = 107
    else
      p272 = 106
    end
  end
  if p272 == 106 then
    v6 = v9.PopupPadding
    p272 = 107
  end
  if p272 == 107 then
    v10 = Engine.IsMobile
    v10 = v10()
    if not v10 then
      p272 = 110
    else
      p272 = 108
    end
  end
  if p272 == 108 then
    v10 = u27
    v10 = v10.DisableTooltips
    if v10 ~= true then
      p272 = 110
    else
      p272 = 109
    end
  end
  if p272 == 109 then
    v10 = mMovie
    v12 = false
    v10:SetVisible(v12)
    do return end
  end
  if p272 == 110 then
    v10 = v4.UseCursor
    if not v10 then
      p272 = 115
    else
      p272 = 111
    end
  end
  if p272 == 111 then
    v10 = mMovie
    v10 = v10:GetDrawScale()
    v12 = v7 / v10
    v13 = mMovie
    v13 = v13:GetViewportWidth()
    v11 = v12 / v13
    v13 = v8 / v10
    v14 = mMovie
    v14 = v14:GetViewportHeight()
    v12 = v13 / v14
    if v11 <= v12 then
      p272 = 113
    else
      p272 = 112
    end
  end
  if p272 == 112 then
    v10 = v11
    p272 = 114
  end
  if p272 == 113 then
    v10 = v12
    p272 = 114
  end
  if p272 == 114 then
    v13 = { x = nil, y = nil }
    v15 = mMovie
    v15 = v15:GetCursorX()
    v14 = v15 * v10
    v13.x = v14
    v15 = mMovie
    v15 = v15:GetCursorY()
    v14 = v15 * v10
    v13.y = v14
    v5 = v13
    p272 = 118
  end
  if p272 == 115 then
    v10 = v4.IsDiegetic
    if not v10 then
      p272 = 117
    else
      p272 = 116
    end
  end
  if p272 == 116 then
    v10 = v4.Movie
    v12 = v4.Movie
    v14 = v4.ClipName
    v15 = 2
    v12 = v12:GetNumberVariable(v14, v15)
    v13 = v4.Movie
    v15 = v4.ClipName
    v16 = 3
    v10 = v10:Name__3565d54e(v12, v13:GetNumberVariable(v15, v16))
    v11 = mMovie
    v14 = gRegion
    v14 = v14:GetLocalPlayer()
    v14 = v14:GetCamera()
    v15 = true
    v5 = v11:ProjectPosition(v10, v14, v15)
    p272 = 118
  end
  if p272 == 117 then
    v10 = u21
    v10 = v10.TransformViewportToPixelCoordinates
    v11 = mMovie
    v12 = { x = nil, y = nil }
    v13 = v4.X
    v12.x = v13
    v13 = v4.Y
    v12.y = v13
    v5 = v10(v11, v12)
    p272 = 118
  end
  if p272 == 118 then
    v10 = v4.W
    v11 = v4.H
    v12 = v3.CenterAlign
    if not v12 then
      p272 = 120
    else
      p272 = 119
    end
  end
  if p272 == 119 then
    v13 = u28
    v12 = -v13
    v10 = v12 / 2
    v11 = v11 / 2
    v6 = 0
    p272 = 122
  end
  if p272 == 120 then
    v12 = v3.TopLeftAligned
    if v12 then
      p272 = 122
    else
      p272 = 121
    end
  end
  if p272 == 121 then
    v10 = v10 / 2
    v11 = v11 / 2
    p272 = 122
  end
  if p272 == 122 then
    v12 = u29
    v14 = _T
    v13 = v14.InfoPopup_Data2
    if v13 == nil then
      p272 = 124
    else
      p272 = 123
    end
  end
  if p272 == 123 then
    v15 = v3.CompareHeight
    v14 = v15 or 0
    v13 = math.max
    v12 = v13(v14, v12)
    v3.CompareHeight = v12
    p272 = 124
  end
  if p272 == 124 then
    v15 = u4
    v14 = tonumber
    v14 = v14(v15)
    v13 = v14 or 1
    v17 = v5.x
    v16 = v17 + v10
    v15 = v16 + v6
    v18 = u28
    v17 = v18 + 2
    v18 = v13 - 1
    v16 = v17 * v18
    v14 = v15 + v16
    v15 = v5.y
    v16 = v3.CenterAlign
    if not v16 then
      p272 = 126
    else
      p272 = 125
    end
  end
  if p272 == 125 then
    v15 = v15 + v11
    p272 = 130
  end
  if p272 == 126 then
    v16 = v3.BottomAnchor
    if not v16 then
      p272 = 128
    else
      p272 = 127
    end
  end
  if p272 == 127 then
    v16 = v15 - v12
    v15 = v16 + v11
    p272 = 130
  end
  if p272 == 128 then
    v16 = v3.TopLeftAligned
    if v16 then
      p272 = 130
    else
      p272 = 129
    end
  end
  if p272 == 129 then
    v15 = v15 - v11
    p272 = 130
  end
  if p272 == 130 then
    v16 = u21
    v16 = v16.GetScreenDimensions
    v17 = mMovie
    v16, v17 = v16(v17)
    v18 = v8 * 0.05
    v20 = v18 + v12
    v19 = v17 - v20
    v20 = v3.CenterAlign
    if not v20 then
      p272 = 133
    else
      p272 = 131
    end
  end
  if p272 == 131 then
    if v15 <= v19 then
      p272 = 134
    else
      p272 = 132
    end
  end
  if p272 == 132 then
    v21 = v5.y
    v20 = v21 - v11
    v15 = v20 - v12
    p272 = 134
  end
  if p272 == 133 then
    v20 = Clamp
    v15 = v20(v15, v18, v19)
    p272 = 134
  end
  if p272 == 134 then
    v18 = v7 * 0.05
    v20 = v16 - v18
    v25 = _T.ItemInfoPopupCount
    v24 = v25 or 1
    v25 = v13 - 1
    v23 = v24 - v25
    v25 = u28
    v24 = v25 + 2
    v22 = v23 * v24
    v21 = v22 - 2
    v22 = v20 - v21
    if v22 < v14 then
      p272 = 136
    else
      p272 = 135
    end
  end
  if p272 == 135 then
    v22 = v3.RightAligned
    if not v22 then
      p272 = 139
    else
      p272 = 136
    end
  end
  if p272 == 136 then
    v22 = 0
    v23 = v3.TopLeftAligned
    if v23 then
      p272 = 138
    else
      p272 = 137
    end
  end
  if p272 == 137 then
    v22 = v10
    p272 = 138
  end
  if p272 == 138 then
    v26 = v5.x
    v25 = v26 - v22
    v24 = v25 - v6
    v27 = u28
    v26 = v27 + 2
    v25 = v26 * v13
    v23 = v24 - v25
    v14 = v23 + 2
    p272 = 139
  end
  if p272 == 139 then
    v23 = _T.ItemInfoPopupCount
    v22 = v23 or 1
    v24 = u28
    v23 = v24 + 2
    v26 = v22 - v13
    v25 = v23 * v26
    v24 = v23 + v25
    v20 = v20 - v24
    v24 = Clamp
    v14 = v24(v14, v18, v20)
    v24 = mMovie
    v26 = "Popup"
    v27 = 0
    v28 = math.ceil
    v28 = v28(v14)
    v24:SetNumberVariable(v26, v27, v28)
    v24 = mMovie
    v26 = "Popup"
    v27 = 1
    v28 = math.ceil
    v28 = v28(v15)
    v24:SetNumberVariable(v26, v27, v28)
    v24 = Engine.IsMobile
    v24 = v24()
    if not v24 then
      p272 = 147
    else
      p272 = 140
    end
  end
  if p272 == 140 then
    v25 = _T.MobileInfoPopup
    v24 = IsNull
    v24 = v24(v25)
    if v24 then
      p272 = 147
    else
      p272 = 141
    end
  end
  if p272 == 141 then
    v24 = v15
    v26 = _T.MobileInfoPopup.InfoPopupScale
    v25 = v26 / 100
    v26 = v12 * v25
    v28 = v15 + v26
    v27 = v28 + 20
    if v27 <= v17 then
      p272 = 143
    else
      p272 = 142
    end
  end
  if p272 == 142 then
    v28 = v17 - v26
    v24 = v28 - 50
    p272 = 143
  end
  if p272 == 143 then
    v28 = u21
    v28 = v28.Ternary
    v30 = _T.MobileInfoPopup.TaskInfoXOffset
    if v30 == 0 then
      p272 = 145
    else
      p272 = 144
    end
  end
  if p272 == 144 then
    v29 = false
    p272 = 146
  end
  if p272 == 145 then
    v29 = true
    p272 = 146
  end
  if p272 == 146 then
    v30 = _T.MobileInfoPopup.RewardInfoXOffset
    v31 = _T.MobileInfoPopup.TaskInfoXOffset
    v28 = v28(v29, v30, v31)
    v29 = mMovie
    v31 = "Popup"
    v32 = 0
    v34 = math.ceil
    v34 = v34(v14)
    v33 = v34 + v28
    v29:SetNumberVariable(v31, v32, v33)
    v29 = mMovie
    v31 = "Popup"
    v32 = 1
    v33 = math.ceil
    v33 = v33(v24)
    v29:SetNumberVariable(v31, v32, v33)
    p272 = 147
  end
  if p272 == 147 then
    v4 = u5
    v4 = v4.MetaData
    v4 = v4.UpdateExpiry
    if not v4 then
      p272 = 153
    else
      p272 = 148
    end
  end
  if p272 == 148 then
    v4 = ipairs
    v5 = u30
    v4, v5, v6 = v4(v5)
    p272 = 152
  end
  if p272 == 149 then
    v9 = v8.ExcludeFromInfoPopup
    if v9 then
      p272 = 152
    else
      p272 = 150
    end
  end
  if p272 == 150 then
    v9 = v8.Type
    v10 = u27
    v10 = v10.LABEL_TYPE_TIMER
    if v9 ~= v10 then
      p272 = 152
    else
      p272 = 151
    end
  end
  if p272 == 151 then
    v9 = Engine.Name__b38e1642
    v10 = u5
    v10 = v10.MetaData
    v10 = v10.Expiry
    v9 = v9(v10)
    v10 = u31
    v10 = v10.SecondsToFormattedTime
    v11 = mMovie
    v13 = "CompactTwoMax"
    v10 = v10(v11, v9, v13)
    v8.Name = v10
    v10 = u27
    v10 = v10.DrawPriceLabel
    v11 = mMovie
    v12 = v8.ClipName
    v10(v11, v12, v8)
    do return end
  end
  if p272 == 152 then
    p272 = 153
  end
  if p272 == 153 then
    do return end
  end
end

function proto_68(v0, v1)
  local v2, v3
  v3 = u0
  v2 = IsNull
  v2 = v2(v3)
  if not v2 then
    v2 = u0
    v2 = v2.mPreset
    if v2 ~= nil then
      v2 = u0
      v2 = v2.mPreset
      v2 = v2.mFavorite
      do return v2 end
    end
  end
  v2 = false
  do return v2 end
end

function proto_69()
  local v0
  v0 = u0
  v0()
  do return end
end

function proto_70()
  local v0
  v0 = u0
  v0()
  do return end
end

function proto_71(v0)
  local v1, v2
  v2 = u0
  v1 = IsNull
  v1 = v1(v2)
  if not v1 then
    v1 = u0
    v1 = v1:GetHowManyElements()
    v2 = 1
    if v2 < v1 then
      v1 = u1
      if v1 ~= nil then
        v1 = u2
        if not v1 then
          v1 = u3
          v1 = v1.INCREMENT
          if v0 == v1 then
            v1 = u0
            v1:FocusNextElement()
          else
            v1 = u0
            v1:FocusPreviousElement()
          end
          v1 = u0
          v1:SelectCurrentElement()
          v1 = u1
          v1 = v1.mPageSoundOverride
          if v1 ~= nil then
            v1 = u3
            v1 = v1.PlaySound
            v2 = u1
            v2 = v2.mPageSoundOverride
            v1(v2)
          else
            v1 = u3
            v1 = v1.PlaySound
            v2 = _G
            v2 = v2.UISound_ItemTipSection
            v1(v2)
          end
          v1 = true
          do return v1 end
        end
      end
    end
  end
  v1 = false
  do return v1 end
end

function proto_72()
  local v0, v1, v3, v4
  v0 = _T.InfoPopup_Grid
  local v2 = _T.InfoPopup_Grid
  v3 = false
  if v2 ~= nil then
    v3 = v2.CanPreviewElements
  end
  v4 = u0
  if v2 == nil then
    v4 = u0
    v4 = v4.CanPreviewOverride
    if v4 ~= nil then
      v4 = v3
      if v4 then
        v4 = u0
        v4 = v4.CanPreviewOverride
      end
      v3 = v4
    end
  end
  v1 = v3
  if not ((not v1 or v0 == nil)) then
    v1 = v0.PreviewCallback
    if v1 ~= nil then
      v0:PreviewCallback()
      v1 = true
      do return v1 end
    end
  end
  v1 = false
  v2 = u0
  if v2 ~= nil then
    v2 = u0
    v2 = v2.mUnequipItem
    if v2 == nil then
      v1 = false
    else
      v1 = true
    end
  end
  if not ((not v1 or v0 == nil)) then
    v1 = v0.UnequipCallback
    if v1 ~= nil then
      v0:UnequipCallback()
      v1 = true
      do return v1 end
    end
  end
  v1 = false
  v2 = u0
  if v2 ~= nil then
    v2 = u0
    v2 = v2.RightPressedCallback
    if v2 == nil then
      v1 = false
    else
      v1 = true
    end
  end
  if v1 then
    v1 = u0
    v1 = v1.RightPressedCallback
    v1()
    v1 = true
    do return v1 end
  end
  v1 = false
  do return v1 end
end

function proto_73()
  local v0
  v0 = u0
  v0 = v0()
  do return v0 end
end

function proto_74()
  local v0
  v0 = u0
  v0 = v0()
  do return v0 end
end

function proto_75()
  local v0, v1
  v0 = u0
  v1 = u1
  v1 = v1.INCREMENT
  v0 = v0(v1)
  do return v0 end
end

function proto_76()
  local v0, v1, v2
  v2 = u0
  v1 = IsNull
  v1 = v1(v2)
  v0 = not v1
  if v0 then
    v0 = false
    v1 = u0
    v1 = v1:GetHowManyElements()
    v2 = 1
    if v2 < v1 then
      v0 = false
      v1 = u1
      if v1 ~= nil then
        v1 = u2
        v0 = not v1
      end
    end
  end
  do return v0 end
end

function proto_77()
  local v0
  v0 = true
  do return v0 end
end

function proto_78(v0, v1, v2)
  local v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v18
  v3 = Engine.IsMobile
  v3 = v3()
  if v3 then
    v3 = string.find
    v5 = "MOUSE_B0"
    v3 = v3(v1, v5)
    if v3 ~= nil then
      v3 = mMovie
      v3 = v3:GetViewportWidth()
      v4 = mMovie
      v4 = v4:GetViewportHeight()
      v5 = mMovie
      v5 = v5:GetMovieWidth()
      v6 = mMovie
      v6 = v6:GetMovieHeight()
      v7 = v3 / v5
      v8 = v4 / v6
      v10 = mMovie
      v10 = v10:GetCursorX()
      v9 = v10 / v7
      v11 = mMovie
      v11 = v11:GetCursorY()
      v10 = v11 / v8
      if v2 == "1" then
        v12 = mMovie
        v12 = v12:GetCursorX()
        v11 = v12 / v3
        v13 = mMovie
        v13 = v13:GetCursorY()
        v12 = v13 / v4
        v13 = u0
        v13 = v13(v11, v12)
        if v13 then
          v14 = u1
          v15 = true
          v14.mouseDown = v15
          v14 = u1
          v15 = Vector
          v18 = 0
          v15 = v15(v9, v10, v18)
          v14.mouseDownPos = v15
        else
          v14 = _T.UpdateButtons
          if v14 ~= nil then
            v14 = _T.UpdateButtons
            v14()
          end
        end
      else
        if v2 == "0" then
          v11 = u1
          v11 = v11.mouseDown
          if v11 then
            v11 = u1
            v12 = false
            v11.mouseDown = v12
            v11 = Vector
            v14 = 0
            v11 = v11(v9, v10, v14)
            v13 = u1
            v13 = v13.mouseDownPos
            v12 = v11 - v13
            v14 = v12.x
            v13 = math.abs
            v13 = v13(v14)
            v14 = 80
            if v14 < v13 then
              v13 = v12.x
              v14 = 0
              if v14 < v13 then
                v13 = u2
                v14 = u3
                v14 = v14.DECREMENT
                v13(v14)
              else
                v13 = u2
                v14 = u3
                v14 = v14.INCREMENT
                v13(v14)
              end
            end
            v13 = u1
            v14 = false
            v13.dragStarted = v14
          end
        end
      end
    end
  end
  v3 = Engine.IsSwitch2
  v3 = v3()
  if v3 then
    v3 = Engine.KBMControlsDisabled
    v3 = v3()
    if not (((v3 or v1 ~= "EN_MOUSE_B0") or v2 ~= "1")) then
      v3 = u2
      v4 = u3
      v4 = v4.INCREMENT
      v3(v4)
    end
  end
  if v2 ~= "1" then
    v2 = false
  else
    v2 = true
  end
  if not ((not (v1 == "EN_LSHIFT") and v1 ~= "EN_RSHIFT")) then
    u4 = v2
    do return end
  end
  if not ((not v2 or v1 ~= "EN_TAB")) then
    v3 = u2
    v4 = u3
    v4 = v4.Ternary
    v5 = u4
    v6 = u3
    v6 = v6.DECREMENT
    v7 = u3
    v7 = v7.INCREMENT
    v3(v4(v5, v6, v7))
  end
  do return end
end

function proto_79(v0)
  local v1
  v1 = u0
  v1()
  v1 = u1
  v1()
  do return end
end

function proto_80()
  local v0
  v0 = true
  do return v0 end
end

function proto_81()
  local v0
  v0 = true
  do return v0 end
end

function proto_82()
  local v0
  v0 = u0
  if v0 ~= nil then
    v0 = u0
    v0 = v0.ShowDisposition
    do return v0 end
  end
  v0 = false
  do return v0 end
end

function proto_83(v0, v1)
  local v2, v3, v5
  v2 = false
  u0 = v2
  u1 = v0
  v2 = string.upper
  v3 = Localize
  v5 = true
  v2 = v2(v3(v1, v5))
  u2 = v2
  v2 = u3
  v2()
  do return end
end

function proto_84(...)
  local v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60, v61, v62, v63, v64, v65, v66, v67, v68, v69, v70, v71, v72, v73, v74, v75, v76, v77, v78, v79, v80, v81, v82, v83, v84, v85, v86, v87, v88, v89, v90, v91, v92, v93, v94, v95, v96, v97, v98, v99, v100, v101, v102, v103, v104, v105, v106, v107, v108, v109, v110, v111, v112, v113, v114
  v0 = require
  v1 = "Lotus.Interface.LotusUtilities"
  v0 = v0(v1)
  v1 = require
  v2 = "Lotus.Interface.UIUtilities"
  v1 = v1(v2)
  v2 = require
  v3 = "EE.Interface.Utilities"
  v2 = v2(v3)
  v3 = require
  v4 = "Lotus.Interface.UIStyleUtilities"
  v3 = v3(v4)
  v4 = require
  v5 = "Lotus.Interface.StoreItemUtilities"
  v4 = v4(v5)
  v5 = require
  v6 = "Lotus.Interface.Components.StatCompare"
  v5 = v5(v6)
  v6 = require
  v7 = "Lotus.Interface.CodexUtilities"
  v6 = v6(v7)
  v7 = require
  v8 = "Lotus.Interface.LoadoutUtilities"
  v7 = v7(v8)
  v8 = require
  v9 = "Lotus.Interface.ModularWeaponUtilities"
  v8 = v8(v9)
  v9 = require
  v10 = "Lotus.Interface.CardUtilitiesRedux"
  v9 = v9(v10)
  v10 = require
  v11 = "Lotus.Interface.SyndicateUtilities"
  v10 = v10(v11)
  v11 = require
  v12 = "Lotus.Scripts.Libs.CrewMemberUtilities"
  v11 = v11(v12)
  v12 = require
  v13 = "Lotus.Scripts.Libs.PlayerShipUtilities"
  v12 = v12(v13)
  v13 = Type
  v14 = "/Lotus/Types/Game/HealthShieldDisplay"
  v13 = v13(v14)
  v14 = WeakResource
  v15 = "/Lotus/Types/BoosterPacks/1999StickersPackBase"
  v14 = v14(v15)
  v15 = { Sirius = nil, Orion = nil, GetDescInfoSym = nil }
  v16 = WeakResource
  v17 = "/Lotus/Powersuits/SiriusOrion/SiriusBaseSuit"
  v16 = v16(v17)
  v15.Sirius = v16
  v16 = WeakResource
  v17 = "/Lotus/Powersuits/SiriusOrion/OrionBaseSuit"
  v16 = v16(v17)
  v15.Orion = v16
  v16 = Symbol
  v17 = "GetAbilityDescriptionInfo"
  v16 = v16(v17)
  v15.GetDescInfoSym = v16
  v16 = false
  v17 = nil
  v18 = nil
  v19 = { PreviousX = nil, PreviousY = nil, CurrentX = nil, CurrentY = nil, TargetX = nil, TargetY = nil }
  v20 = 0
  v21 = 0
  v22 = 0
  v23 = 0
  v24 = ""
  v25 = ""
  v26 = {}
  v27 = 0
  v28 = 10
  v29 = 1
  v30 = 1
  v31 = 0
  v32 = 1
  v33 = { Labels = nil, Values = nil, BaseValues = nil, StatChanges = nil }
  v34 = {}
  v33.Labels = v34
  v34 = {}
  v33.Values = v34
  v34 = {}
  v33.BaseValues = v34
  v34 = {}
  v33.StatChanges = v34
  v34 = nil
  v35 = nil
  v36 = nil
  v37 = nil
  v38 = nil
  v39 = false
  v40 = nil
  v41 = nil
  v42 = false
  v43 = nil
  v44 = nil
  v45 = {}
  v46 = true
  v47 = { x = 0, y = 0 }
  v48 = nil
  v49 = nil
  v50 = false
  v51 = nil
  v52 = nil
  v53 = false
  v54 = nil
  v55 = false
  v56 = nil
  v57 = Resource
  v58 = "/Lotus/Types/Input/ItemInfoPopupWithSelectButtonInputFilter"
  v57 = v57(v58)
  v58 = true
  v59 = ""
  v60 = ""
  v61 = {}
  v62 = false
  v63 = nil
  v64 = { BASE = 1, INFO = 2, ABILITIES = 3, STATS = 4, CRAFTING = 5 }
  v65 = nil
  v66 = nil
  v67 = nil
  v68 = { mouseDown = false, mouseDownTime = 0, mouseClickLimit = 0.01, dragStarted = false }
  v69 = WeakResource
  v70 = "/Lotus/Powersuits/Pagemaster/Abilities/PagemasterFinalChapterAbility"
  v69 = v69(v70)
  v70 = {}
  v71 = function()
    local c22v0, c22v1, c22v2, c22v3, c22v4, c22v5, c22v6, c22v7, c22v8
    c22v0 = v62
    if not c22v0 then
      c22v0 = true
      v62 = c22v0
      c22v0 = v58
      if not c22v0 then
        c22v0 = v37
        c22v2 = v36
        c22v0:RemoveTimer(c22v2)
        c22v0 = _T
        c22v3 = _T.ItemInfoPopupCount
        c22v2 = c22v3 or 1
        c22v1 = c22v2 - 1
        c22v0.ItemInfoPopupCount = c22v1
      end
      c22v0 = v39
      if c22v0 then
        c22v0 = v66
        c22v1 = false
        c22v0(c22v1)
      end
      c22v0 = nil
      v40 = c22v0
      c22v0 = v19
      c22v1 = nil
      c22v0.TargetX = c22v1
      c22v0 = v19
      c22v1 = nil
      c22v0.TargetY = c22v1
      c22v0 = FlashInterpolate
      c22v1 = mMovie
      c22v2 = "Popup"
      c22v3 = 2
      c22v5 = 12
      c22v4 = {c22v5}
      c22v6 = 0
      c22v5 = {c22v6}
      c22v6 = 0.1
      c22v7 = 0
      c22v8 = function()
        local c21v0, c21v2, c21v3
        c21v0 = mMovie
        c21v2 = "Popup.VideoPreview.Image"
        c21v0:StopVideoTexture(c21v2)
        c21v0 = mMovie
        c21v2 = "Popup.VideoPreview.Image"
        c21v3 = nil
        c21v0:OverrideTexture(c21v2, c21v3)
        c21v0 = mMovie
        c21v2 = false
        c21v0:SetVisible(c21v2)
        c21v0 = v58
        if not c21v0 then
          c21v0 = mMovie
          c21v0:Close()
        end
        do return end
      end
      c22v0(c22v1, c22v2, c22v3, c22v4, c22v5, c22v6, c22v7, c22v8)
    end
    do return end
  end
  v72 = function(c23v0)
    local c23v1, c23v3, c23v4
    c23v1 = string.gsub
    c23v3 = "[%(%)%.%%%+%-%*%?%[%]%^%$]"
    c23v4 = "%%%0"
    do return c23v1(c23v0, c23v3, c23v4) end
  end
  v73 = function()
    local c24v0, c24v1, c24v2
    c24v0 = _T.InfoPopup_Grid
    c24v1 = false
    if c24v0 ~= nil then
      c24v1 = c24v0.CanPreviewElements
    end
    c24v2 = v17
    if c24v0 == nil then
      c24v2 = v17
      c24v2 = c24v2.CanPreviewOverride
      if c24v2 ~= nil then
        c24v2 = c24v1
        if c24v2 then
          c24v2 = v17
          c24v2 = c24v2.CanPreviewOverride
        end
        c24v1 = c24v2
      end
    end
    do return c24v1 end
  end
  v74 = function()
    local c25v0, c25v1
    c25v0 = false
    c25v1 = v17
    if c25v1 ~= nil then
      c25v1 = v17
      c25v1 = c25v1.mUnequipItem
      if c25v1 == nil then
        c25v0 = false
      else
        c25v0 = true
      end
    end
    do return c25v0 end
  end
  v75 = function()
    local c26v0, c26v1
    c26v0 = false
    c26v1 = v17
    if c26v1 ~= nil then
      c26v1 = v17
      c26v1 = c26v1.RightPressedCallback
      if c26v1 == nil then
        c26v0 = false
      else
        c26v0 = true
      end
    end
    do return c26v0 end
  end
  v76 = function()
    local c27v0, c27v1, c27v2
    c27v0 = Engine.IsPlayingWithTouchscreen
    c27v0 = c27v0()
    if not c27v0 then
      c27v0 = false
      do return c27v0 end
    end
    c27v0 = _T.InfoPopup_Grid
    if c27v0 ~= nil then
      c27v1 = c27v0.ShowSelectButton
      if c27v1 ~= nil then
        c27v1 = c27v0.ShowSelectButton
        c27v2 = _T.InfoPopup_Data
        do return c27v1(c27v2) end
      end
    end
    c27v1 = false
    do return c27v1 end
  end
  v77 = function()
    local c28v0, c28v1, c28v3, c28v4
    c28v0 = _T.InfoPopup_Grid
    if c28v0 ~= nil then
      c28v1 = c28v0.GetSelectButtonText
      if c28v1 ~= nil then
        c28v1 = c28v0.GetSelectButtonText
        do return c28v1() end
      end
    end
    c28v1 = mMovie
    c28v3 = "/Lotus/Language/Menu/Select"
    c28v4 = false
    do return c28v1:GetLocalized(c28v3, c28v4) end
  end
  v78 = function()
    local c29v0, c29v1, c29v2, c29v3, c29v4
    c29v1 = v54
    c29v0 = IsNull
    c29v0 = c29v0(c29v1)
    if c29v0 then
      do return end
    end
    c29v0 = v54
    c29v2 = v77
    c29v0:SetText(c29v2())
    c29v0 = mMovie
    c29v2 = "Popup.SelectButton"
    c29v3 = 14
    c29v4 = v22
    c29v0:SetNumberVariable(c29v2, c29v3, c29v4)
    c29v0 = mMovie
    c29v2 = "Popup.SelectButton"
    c29v3 = 0
    c29v4 = 54
    c29v0:SetNumberVariable(c29v2, c29v3, c29v4)
    do return end
  end
  v79 = function()
    local c30v0, c30v1, c30v2, c30v3, c30v4, c30v5
    c30v0 = _T.InfoPopup_Grid
    if c30v0 ~= nil then
      c30v1 = c30v0.SelectButtonCallback
      if c30v1 ~= nil then
        c30v1 = c30v0.SelectButtonCallback
        c30v1()
        c30v2 = v54
        c30v1 = IsNull
        c30v1 = c30v1(c30v2)
        if c30v1 then
          do return end
        end
        c30v1 = v54
        c30v3 = v77
        c30v1:SetText(c30v3())
        c30v1 = mMovie
        c30v3 = "Popup.SelectButton"
        c30v4 = 14
        c30v5 = v22
        c30v1:SetNumberVariable(c30v3, c30v4, c30v5)
        c30v1 = mMovie
        c30v3 = "Popup.SelectButton"
        c30v4 = 0
        c30v5 = 54
        c30v1:SetNumberVariable(c30v3, c30v4, c30v5)
      end
    end
    do return end
  end
  OnSelectButtonPressed = v79
  v79 = function()
    local c31v0, c31v1, c31v2, c31v3, c31v4, c31v5
    c31v0 = mMovie
    c31v0 = c31v0:GetInputFilter()
    v56 = c31v0
    c31v0 = require
    c31v1 = "Lotus.Interface.Components.ThemedButton"
    c31v0 = c31v0(c31v1)
    c31v1 = c31v0.Create
    c31v2 = mMovie
    c31v3 = "Popup.SelectButton"
    c31v4 = ""
    c31v5 = nil
    c31v1 = c31v1(c31v2, c31v3, c31v4, c31v5)
    v54 = c31v1
    c31v1 = v54
    c31v3 = "OnSelectButtonPressed"
    c31v1:SetReleasedCallback(c31v3)
    c31v1 = v54
    c31v1:SetSpecialMode()
    c31v1 = v54
    c31v3 = 280
    c31v1:SetWidth(c31v3)
    c31v1 = mMovie
    c31v3 = "Popup.SelectButton"
    c31v4 = 13
    c31v5 = false
    c31v1:Name__d9713943(c31v3, c31v4, c31v5)
    c31v1 = v54
    c31v3 = false
    c31v1:SetActive(c31v3)
    c31v1 = v54
    c31v1:Redraw()
    do return end
  end
  v80 = function()
    local c32v0, c32v1, c32v2, c32v3, c32v4, c32v5, c32v6
    c32v1 = v54
    c32v0 = IsNull
    c32v0 = c32v0(c32v1)
    if c32v0 then
      do return end
    end
    c32v1 = Engine.IsPlayingWithTouchscreen
    c32v1 = c32v1()
    if not c32v0 then
      c32v0 = false
    else
      local p20 = 4
      if p20 == 4 then
        c32v1 = _T.InfoPopup_Grid
        if c32v1 == nil then
          p20 = 7
        else
          p20 = 5
        end
      end
      if p20 == 5 then
        c32v2 = c32v1.ShowSelectButton
        if c32v2 == nil then
          p20 = 7
        else
          p20 = 6
        end
      end
      if p20 == 6 then
        c32v2 = c32v1.ShowSelectButton
        c32v3 = _T.InfoPopup_Data
        c32v0 = c32v2(c32v3)
      end
      if p20 == 7 then
        c32v0 = false
      end
    end
    c32v1 = v55
    if c32v0 == c32v1 then
      do return end
    end
    v55 = c32v0
    c32v1 = mMovie
    c32v3 = v2
    c32v3 = c32v3.Ternary
    c32v4 = v55
    c32v5 = v57
    c32v6 = v56
    c32v1:SetInputFilter(c32v3(c32v4, c32v5, c32v6))
    c32v1 = mMovie
    c32v3 = "Popup.SelectButton"
    c32v4 = 13
    c32v5 = v55
    c32v1:Name__d9713943(c32v3, c32v4, c32v5)
    c32v1 = v54
    c32v3 = v55
    c32v1:SetActive(c32v3)
    c32v2 = v54
    c32v1 = IsNull
    c32v1 = c32v1(c32v2)
    if c32v1 then
    else
      c32v1 = v54
      c32v3 = v77
      c32v1:SetText(c32v3())
      c32v1 = mMovie
      c32v3 = "Popup.SelectButton"
      c32v4 = 14
      c32v5 = v22
      c32v1:SetNumberVariable(c32v3, c32v4, c32v5)
      c32v1 = mMovie
      c32v3 = "Popup.SelectButton"
      c32v4 = 0
      c32v5 = 54
      c32v1:SetNumberVariable(c32v3, c32v4, c32v5)
    end
    c32v1 = v54
    c32v1:Redraw()
    do return end
  end
  v81 = function(c33v0, c33v1)
    local c33v2, c33v3, c33v4, c33v5, c33v6, c33v7, c33v8
    c33v2 = mMovie
    c33v4 = "Popup"
    c33v5 = 2
    c33v2 = c33v2:GetNumberVariable(c33v4, c33v5)
    c33v3 = mMovie
    c33v5 = "Popup"
    c33v6 = 3
    c33v3 = c33v3:GetNumberVariable(c33v5, c33v6)
    c33v4 = { x = nil, y = nil }
    c33v4.x = c33v2
    c33v4.y = c33v3
    c33v5 = v2
    c33v5 = c33v5.TransformPixelToViewportCoordinates
    c33v6 = mMovie
    c33v4 = c33v5(c33v6, c33v4)
    c33v5 = { x = nil, y = nil }
    c33v7 = v22
    c33v6 = c33v2 + c33v7
    c33v5.x = c33v6
    c33v7 = v21
    c33v6 = c33v3 + c33v7
    c33v5.y = c33v6
    c33v6 = v2
    c33v6 = c33v6.TransformPixelToViewportCoordinates
    c33v7 = mMovie
    c33v5 = c33v6(c33v7, c33v5)
    c33v6 = { xMin = nil, yMin = nil, xMax = nil, yMax = nil }
    c33v7 = c33v4.x
    c33v6.xMin = c33v7
    c33v7 = c33v4.y
    c33v6.yMin = c33v7
    c33v7 = c33v5.x
    c33v6.xMax = c33v7
    c33v7 = c33v5.y
    c33v6.yMax = c33v7
    c33v7 = false
    c33v8 = c33v6.xMin
    if c33v8 < c33v0 then
      c33v7 = false
      c33v8 = c33v6.xMax
      if c33v0 < c33v8 then
        c33v7 = false
        c33v8 = c33v6.yMin
        if c33v8 < c33v1 then
          c33v8 = c33v6.yMax
          if c33v8 <= c33v1 then
            c33v7 = false
          else
            c33v7 = true
          end
        end
      end
    end
    do return c33v7 end
  end
  v82 = function()
    do return end
  end
  OnPopupTitleBgPressed = v82
  v82 = function()
    local c35v0, c35v1, c35v2, c35v3, c35v4
    local p40 = 0
    if p40 == 0 then
      c35v2 = _T.InfoPopup_Grid
      c35v3 = false
      if c35v2 == nil then
        p40 = 2
      else
        p40 = 1
      end
    end
    if p40 == 1 then
      c35v3 = c35v2.CanPreviewElements
      p40 = 2
    end
    if p40 == 2 then
      c35v4 = v17
      if c35v4 == nil then
        p40 = 7
      else
        p40 = 3
      end
    end
    if p40 == 3 then
      c35v4 = v17
      c35v4 = c35v4.CanPreviewOverride
      if c35v4 == nil then
        p40 = 7
      else
        p40 = 4
      end
    end
    if p40 == 4 then
      c35v4 = c35v3
      if not c35v4 then
        p40 = 6
      else
        p40 = 5
      end
    end
    if p40 == 5 then
      c35v4 = v17
      c35v4 = c35v4.CanPreviewOverride
      p40 = 6
    end
    if p40 == 6 then
      c35v3 = c35v4
      p40 = 7
    end
    if p40 == 7 then
      c35v1 = c35v3
      if c35v1 then
        p40 = 18
      else
        p40 = 8
      end
    end
    if p40 == 8 then
      c35v1 = false
      c35v2 = v17
      if c35v2 == nil then
        p40 = 12
      else
        p40 = 9
      end
    end
    if p40 == 9 then
      c35v2 = v17
      c35v2 = c35v2.mUnequipItem
      if c35v2 ~= nil then
        p40 = 11
      else
        p40 = 10
      end
    end
    if p40 == 10 then
      c35v1 = false
      p40 = 12
    end
    if p40 == 11 then
      c35v1 = true
      p40 = 12
    end
    if p40 == 12 then
      if c35v1 then
        p40 = 18
      else
        p40 = 13
      end
    end
    if p40 == 13 then
      c35v0 = false
      c35v1 = v17
      if c35v1 == nil then
        p40 = 17
      else
        p40 = 14
      end
    end
    if p40 == 14 then
      c35v1 = v17
      c35v1 = c35v1.RightPressedCallback
      if c35v1 ~= nil then
        p40 = 16
      else
        p40 = 15
      end
    end
    if p40 == 15 then
      c35v0 = false
      p40 = 17
    end
    if p40 == 16 then
      c35v0 = true
      p40 = 17
    end
    if p40 == 17 then
      if not c35v0 then
        p40 = 25
      else
        p40 = 18
      end
    end
    if p40 == 18 then
      c35v2 = Engine.IsPlayingWithTouchscreen
      c35v2 = c35v2()
      if c35v2 then
        p40 = 20
      else
        p40 = 19
      end
    end
    if p40 == 19 then
      c35v1 = false
      p40 = 24
    end
    if p40 == 20 then
      c35v2 = _T.InfoPopup_Grid
      if c35v2 == nil then
        p40 = 23
      else
        p40 = 21
      end
    end
    if p40 == 21 then
      c35v3 = c35v2.ShowSelectButton
      if c35v3 == nil then
        p40 = 23
      else
        p40 = 22
      end
    end
    if p40 == 22 then
      c35v3 = c35v2.ShowSelectButton
      c35v4 = _T.InfoPopup_Data
      c35v1 = c35v3(c35v4)
      p40 = 24
    end
    if p40 == 23 then
      c35v1 = false
      p40 = 24
    end
    if p40 == 24 then
      c35v0 = not c35v1
      p40 = 25
    end
    if p40 == 25 then
      do return c35v0 end
    end
  end
  v83 = function()
    do return end
  end
  v84 = function()
    do return end
  end
  OnProfileSaved = v84
  v84 = function(c38v0, c38v1, c38v2, c38v3)
    local c38v4, c38v5, c38v6, c38v7, c38v8, c38v9
    c38v4 = false
    c38v5 = v17
    if c38v5 ~= nil then
      c38v5 = v17
      c38v5 = c38v5.ModdedStats
      c38v4 = not c38v5
      if c38v4 then
        c38v4 = false
        if c38v2 ~= 0 then
          if c38v1 == nil then
            c38v4 = false
          else
            c38v4 = true
          end
        end
      end
    end
    c38v5 = true
    if c38v3 ~= true then
      if c38v2 ~= nil then
        c38v5 = false
      else
        c38v5 = true
      end
    end
    c38v3 = c38v5
    if c38v4 then
      c38v5 = mMovie
      c38v7 = "<MINI_ARROW>"
      c38v8 = true
      c38v6 = c38v5:GetLocalized(c38v7, c38v8)
      c38v0 = c38v6 .. c38v0
    end
    if not c38v3 then
      c38v5 = 0
      if c38v2 < c38v5 then
        c38v5 = "<font color=\""
        c38v6 = v61
        c38v6 = c38v6.NegativeHex
        c38v7 = "\">"
        c38v9 = "</font>"
        c38v0 = c38v5 .. c38v6 .. c38v7 .. c38v0 .. c38v9
      else
        c38v5 = 0
        if c38v5 < c38v2 then
          c38v5 = "<font color=\""
          c38v6 = v61
          c38v6 = c38v6.PositiveHex
          c38v7 = "\">"
          c38v9 = "</font>"
          c38v0 = c38v5 .. c38v6 .. c38v7 .. c38v0 .. c38v9
        end
      end
    end
    if c38v4 then
      c38v0 = c38v1 .. c38v0
    end
    do return c38v0 end
  end
  v85 = function()
    local c39v0, c39v1, c39v2, c39v4, c39v5, c39v6, c39v7, c39v8, c39v9, c39v10, c39v11, c39v12, c39v13, c39v14, c39v15, c39v16
    local c39v3 = 1
    c39v1 = v31
    c39v2 = 1
    for c39v3 = c39v3, c39v1, c39v2 do
      c39v5 = "Popup.ItemStats.Item"
      c39v4 = c39v5 .. c39v3
      c39v5 = mMovie
      c39v8 = "Backer"
      c39v9 = 11
      c39v10 = v61
      c39v10 = c39v10.Background1
      c39v5:Name__52c1b74e(c39v4, c39v8, c39v9, c39v10)
      c39v6 = v33
      c39v6 = c39v6.Labels
      c39v5 = c39v6[c39v3]
      if c39v5 ~= nil then
        c39v7 = v33
        c39v7 = c39v7.Values
        c39v6 = c39v7[c39v3]
        if c39v6 == "" then
          c39v6 = "<p><font color=\""
          c39v7 = v61
          c39v7 = c39v7.FloatingContentHighlightHex
          c39v8 = "\">"
          c39v10 = "</font></p>"
          c39v5 = c39v6 .. c39v7 .. c39v8 .. c39v5 .. c39v10
          c39v6 = mMovie
          c39v10 = ".Labels"
          c39v8 = c39v4 .. c39v10
          c39v9 = 36
          c39v6:SetStringVariable(c39v8, c39v9, c39v5)
        else
          c39v6 = "<p><font color=\""
          c39v7 = v61
          c39v7 = c39v7.FloatingContentHex
          c39v8 = "\">"
          c39v10 = "</font></p>"
          c39v5 = c39v6 .. c39v7 .. c39v8 .. c39v5 .. c39v10
          c39v6 = mMovie
          c39v10 = ".Labels"
          c39v8 = c39v4 .. c39v10
          c39v9 = 36
          c39v6:SetStringVariable(c39v8, c39v9, c39v5)
          c39v7 = "<p><font color=\""
          c39v8 = v61
          c39v8 = c39v8.FloatingContentHighlightHex
          c39v9 = "\">"
          c39v12 = v84
          c39v14 = v33
          c39v14 = c39v14.Values
          c39v13 = c39v14[c39v3]
          c39v15 = v33
          c39v15 = c39v15.BaseValues
          c39v14 = c39v15[c39v3]
          c39v16 = v33
          c39v16 = c39v16.StatChanges
          c39v15 = c39v16[c39v3]
          c39v10 = c39v12(c39v13, c39v14, c39v15)
          c39v11 = "</font></p>"
          c39v6 = c39v7 .. c39v8 .. c39v9 .. c39v10 .. c39v11
          c39v7 = mMovie
          c39v11 = ".Stats"
          c39v9 = c39v4 .. c39v11
          c39v10 = 36
          c39v7:SetStringVariable(c39v9, c39v10, c39v6)
        end
      end
    end
    c39v1 = mMovie
    c39v0 = IsNull
    c39v0 = c39v0(c39v1)
    c39v0 = v33
    c39v0 = c39v0.BonusStats
    c39v1 = ""
    c39v2 = c39v0.StatChanges
    c39v5 = 1
    c39v6 = c39v0.Labels
    c39v3 = #c39v6
    c39v4 = 1
    for c39v5 = c39v5, c39v3, c39v4 do
      c39v6 = #c39v1
      c39v7 = 0
      if c39v7 < c39v6 then
        c39v7 = "\r\n"
        c39v1 = c39v1 .. c39v7
      end
      c39v6 = nil
      if c39v2 ~= nil then
        c39v6 = c39v2[c39v5]
      end
      c39v7 = v84
      c39v9 = c39v0.Values
      c39v8 = c39v9[c39v5]
      c39v9 = nil
      c39v7 = c39v7(c39v8, c39v9, c39v6)
      c39v8 = string.gsub
      c39v10 = "%%"
      c39v11 = "%%%0"
      c39v7 = c39v8(c39v7, c39v10, c39v11)
      c39v8 = string.gsub
      c39v10 = c39v0.Labels
      c39v9 = c39v10[c39v5]
      c39v10 = "%[STAT%]"
      c39v8 = c39v8(c39v9, c39v10, c39v7)
      c39v1 = c39v1 .. c39v8
    end
    if c39v0 then
      local p25 = 8
      if p25 == 8 then
        c39v3 = v63
        c39v4 = v64
        c39v4 = c39v4.STATS
        if c39v3 == c39v4 then
          p25 = 11
        else
          p25 = 9
        end
      end
      if p25 == 9 then
        c39v3 = v27
        if c39v3 == 0 then
          p25 = 11
        else
          p25 = 10
        end
      end
      if p25 == 10 then
        c39v8 = v24
        c39v9 = 1
        c39v10 = v27
        c39v7 = string.sub
        c39v3 = c39v7(c39v8, c39v9, c39v10)
        c39v4 = "\r\n\r\n"
        c39v7 = v24
        c39v9 = v27
        c39v8 = c39v9 + 1
        c39v6 = string.sub
        c39v6 = c39v6(c39v7, c39v8)
        c39v1 = c39v3 .. c39v4 .. c39v1 .. c39v6
        p25 = 12
      end
      if p25 == 11 then
        c39v1 = v24
        p25 = 12
      end
      if p25 == 12 then
        c39v3 = mMovie
        c39v5 = "Popup.Description"
        c39v6 = 36
        c39v8 = "<p><font color=\""
        c39v9 = v61
        c39v9 = c39v9.ContentHex
        c39v10 = "\">"
        c39v12 = "</font></p>"
        c39v7 = c39v8 .. c39v9 .. c39v10 .. c39v1 .. c39v12
        c39v3:SetStringVariable(c39v5, c39v6, c39v7)
      end
    end
    do return end
  end
  v86 = function()
    local c40v0, c40v1, c40v2
    c40v1 = _T.ItemInfoStatComparison
    c40v0 = IsNull
    c40v0 = c40v0(c40v1)
    if c40v0 then
      do return end
    end
    c40v0 = v58
    if c40v0 then
      c40v0 = _T.ItemInfoStatComparison
      c40v0()
      do return end
    end
    c40v0 = _T.ItemInfoStatComparison
    c40v1 = v33
    c40v2 = v85
    c40v0(c40v1, c40v2)
    do return end
  end
  v87 = function(c41v0, c41v1)
    local c41v2, c41v3, c41v4, c41v5, c41v6, c41v7
    c41v3 = IsNull
    c41v3 = c41v3(c41v1)
    if not c41v3 then
      c41v2 = c41v1
    else
      c41v4 = v17
      c41v4 = c41v4.Suit
      c41v3 = IsNull
      c41v3 = c41v3(c41v4)
      if not c41v3 then
        c41v3 = v17
        c41v2 = c41v3.Suit
        c41v3 = IsWeak
        c41v3 = c41v3(c41v2)
        if c41v3 then
          c41v3 = Resource
          c41v2 = c41v3(c41v2)
        end
      end
    end
    c41v3 = v17
    c41v3 = c41v3.AdditionalPreviewImages
    if c41v3 then
      c41v3 = v18
      c41v3 = c41v3.mCurrentElementIndex
      c41v4 = 1
      if c41v4 < c41v3 then
        c41v3 = v17
        c41v5 = v17
        c41v5 = c41v5.AdditionalPreviewImages
        c41v7 = v18
        c41v7 = c41v7.mCurrentElementIndex
        c41v6 = c41v7 - 1
        c41v4 = c41v5[c41v6]
        c41v3.PreviewImage = c41v4
      else
        c41v3 = v17
        c41v4 = c41v0:GetVideoTexture()
        c41v3.PreviewImage = c41v4
      end
      c41v3 = v17
      c41v4 = true
      c41v3.RefreshImage = c41v4
    end
    do return end
  end
  v88 = function(c42v0)
    local c42v1, c42v2, c42v3, c42v4, c42v5, c42v6, c42v7, c42v8, c42v9, c42v10, c42v11, c42v12, c42v13, c42v14, c42v15
    local p36 = 0
    if p36 == 0 then
      c42v1 = IsNull
      c42v1 = c42v1(c42v0)
      if c42v1 then
        p36 = 2
      else
        p36 = 1
      end
    end
    if p36 == 1 then
      c42v1 = IsWeak
      c42v1 = c42v1(c42v0)
      if not c42v1 then
        p36 = 3
      else
        p36 = 2
      end
    end
    if p36 == 2 then
      do return end
    end
    if p36 == 3 then
      c42v2 = v18
      c42v2 = c42v2:GetHowManyElements()
      c42v3 = 1
      if c42v3 < c42v2 then
        p36 = 5
      else
        p36 = 4
      end
    end
    if p36 == 4 then
      c42v1 = false
      p36 = 6
    end
    if p36 == 5 then
      c42v1 = true
      p36 = 6
    end
    if p36 == 6 then
      c42v2 = require
      c42v3 = "Lotus.Powersuits.PowersuitAbilities.PVPLib"
      c42v2 = c42v2(c42v3)
      c42v3 = nil
      c42v4 = false
      c42v5 = v17
      c42v5 = c42v5.ForceOverrideDesc
      if not c42v5 then
        p36 = 9
      else
        p36 = 7
      end
    end
    if p36 == 7 then
      c42v5 = c42v0:Name__b92141d1()
      c42v6 = EMPTY_SYMBOL
      if c42v5 == c42v6 then
        p36 = 9
      else
        p36 = 8
      end
    end
    if p36 == 8 then
      c42v5 = c42v0:Name__b92141d1()
      c42v3 = c42v5:c_str()
      p36 = 10
    end
    if p36 == 9 then
      c42v5 = c42v0:GetLocalizeDescTag()
      c42v3 = c42v5:c_str()
      c42v4 = true
      p36 = 10
    end
    if p36 == 10 then
      c42v5 = c42v2.IsPvpEnabled
      c42v5 = c42v5()
      if not c42v5 then
        p36 = 13
      else
        p36 = 11
      end
    end
    if p36 == 11 then
      c42v6 = c42v0:GetPvpDescription()
      c42v7 = string.len
      c42v7 = c42v7(c42v6)
      if c42v7 == 0 then
        p36 = 13
      else
        p36 = 12
      end
    end
    if p36 == 12 then
      c42v3 = c42v6
      p36 = 13
    end
    if p36 == 13 then
      c42v6 = nil
      if not c42v4 then
        p36 = 17
      else
        p36 = 14
      end
    end
    if p36 == 14 then
      c42v7 = c42v0:GetScript()
      c42v8 = gRegion
      c42v8 = c42v8:GetLocalPlayerAvatar()
      c42v9 = IsNull
      c42v9 = c42v9(c42v8)
      if c42v9 then
        p36 = 17
      else
        p36 = 15
      end
    end
    if p36 == 15 then
      c42v12 = v15
      c42v12 = c42v12.GetDescInfoSym
      c42v13 = true
      c42v8:RunScript(c42v7, c42v12, c42v13)
      c42v9 = _T.AbilityDescriptionInfo
      if c42v9 == nil then
        p36 = 17
      else
        p36 = 16
      end
    end
    if p36 == 16 then
      c42v6 = _T.AbilityDescriptionInfo.Params
      c42v9 = _T
      c42v10 = nil
      c42v9.AbilityDescriptionInfo = c42v10
      p36 = 17
    end
    if p36 == 17 then
      c42v7 = mMovie
      c42v10 = true
      c42v7 = c42v7:GetLocalized(c42v3, c42v10, c42v6)
      c42v8 = v17
      c42v8 = c42v8.Description
      if (not (c42v8 == "") and not c42v1) then
        p36 = 22
      else
        p36 = 19
      end
    end
    if p36 == 19 then
      c42v8 = v17
      c42v8.Description = c42v3
      c42v8 = ""
      if not c42v1 then
        p36 = 22
      else
        p36 = 20
      end
    end
    if p36 == 20 then
      c42v9 = v17
      c42v9 = c42v9.PageCallout
      if not c42v9 then
        p36 = 22
      else
        p36 = 21
      end
    end
    if p36 == 21 then
      c42v9 = mMovie
      c42v11 = v2
      c42v11 = c42v11.Ternary
      c42v12 = Engine.Name__9472b1e7
      c42v12 = c42v12()
      c42v13 = "<MENU_RTRIGGER1>"
      c42v14 = "<NEXT_MENU>"
      c42v11 = c42v11(c42v12, c42v13, c42v14)
      c42v12 = true
      c42v9 = c42v9:GetLocalized(c42v11, c42v12)
      c42v10 = mMovie
      c42v12 = v17
      c42v12 = c42v12.PageCallout
      c42v13 = false
      c42v14 = { CALLOUT = nil }
      c42v14.CALLOUT = c42v9
      c42v8 = c42v10:GetLocalized(c42v12, c42v13, c42v14)
      c42v10 = StringSplit
      c42v11 = "<br>"
      c42v10 = c42v10(c42v11, c42v7)
      c42v15 = v18
      c42v15 = c42v15.mCurrentElementIndex
      c42v14 = c42v15 or 1
      c42v11 = c42v10[c42v14]
      c42v12 = "\r\n\r\n"
      c42v7 = c42v11 .. c42v12 .. c42v8
      p36 = 22
    end
    if p36 == 22 then
      c42v8 = v17
      c42v8.LocalizedDesc = c42v7
      do return end
    end
  end
  v89 = nil
  v90 = function()
    local c44v0, c44v2, c44v3, c44v4, c44v5, c44v6, c44v7, c44v8, c44v9, c44v10, c44v11, c44v12, c44v13
    c44v0 = v2
    c44v0 = c44v0.ConvertColorNumberToProceduralRGB
    local c44v1 = v3
    c44v1 = c44v1.GetColor
    c44v2 = 3
    c44v3 = true
    c44v4 = v89
    c44v0 = c44v0(c44v1(c44v2, c44v3, c44v4))
    c44v1 = v61
    c44v2 = v3
    c44v2 = c44v2.GetColor
    c44v3 = 2
    c44v4 = true
    c44v5 = v89
    c44v2 = c44v2(c44v3, c44v4, c44v5)
    c44v1.Background1 = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToProceduralRGB
    c44v3 = v61
    c44v3 = c44v3.Background1
    c44v2 = c44v2(c44v3)
    c44v1.Background1RGB = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToHex
    c44v3 = v3
    c44v3 = c44v3.GetColor
    c44v4 = 5
    c44v5 = true
    c44v6 = v89
    c44v2 = c44v2(c44v3(c44v4, c44v5, c44v6))
    c44v1.Background4Hex = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToProceduralRGB
    c44v3 = v3
    c44v3 = c44v3.GetColor
    c44v4 = 1
    c44v5 = true
    c44v6 = v89
    c44v2 = c44v2(c44v3(c44v4, c44v5, c44v6))
    c44v1.BackerHighlightRGB = c44v2
    c44v1 = v61
    c44v2 = v3
    c44v2 = c44v2.GetColor
    c44v3 = 6
    c44v4 = true
    c44v5 = v89
    c44v2 = c44v2(c44v3, c44v4, c44v5)
    c44v1.Content = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToHex
    c44v3 = v61
    c44v3 = c44v3.Content
    c44v2 = c44v2(c44v3)
    c44v1.ContentHex = c44v2
    c44v1 = v61
    c44v2 = v3
    c44v2 = c44v2.GetColor
    c44v3 = 9
    c44v4 = true
    c44v5 = v89
    c44v2 = c44v2(c44v3, c44v4, c44v5)
    c44v1.FloatingContent = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToHex
    c44v3 = v61
    c44v3 = c44v3.FloatingContent
    c44v2 = c44v2(c44v3)
    c44v1.FloatingContentHex = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToProceduralRGB
    c44v3 = v61
    c44v3 = c44v3.FloatingContent
    c44v2 = c44v2(c44v3)
    c44v1.FloatingContentRGB = c44v2
    c44v1 = v61
    c44v2 = v3
    c44v2 = c44v2.GetColor
    c44v3 = 10
    c44v4 = true
    c44v5 = v89
    c44v2 = c44v2(c44v3, c44v4, c44v5)
    c44v1.FloatingContentHighlight = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToHex
    c44v3 = v61
    c44v3 = c44v3.FloatingContentHighlight
    c44v2 = c44v2(c44v3)
    c44v1.FloatingContentHighlightHex = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToProceduralRGB
    c44v3 = v61
    c44v3 = c44v3.FloatingContentHighlight
    c44v2 = c44v2(c44v3)
    c44v1.FloatingContentHighlightRGB = c44v2
    c44v1 = v61
    c44v2 = v3
    c44v2 = c44v2.GetColor
    c44v3 = 11
    c44v4 = true
    c44v5 = v89
    c44v2 = c44v2(c44v3, c44v4, c44v5)
    c44v1.Positive = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToHex
    c44v3 = v61
    c44v3 = c44v3.Positive
    c44v2 = c44v2(c44v3)
    c44v1.PositiveHex = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToProceduralRGB
    c44v3 = v61
    c44v3 = c44v3.Positive
    c44v2 = c44v2(c44v3)
    c44v1.PositiveRGB = c44v2
    c44v1 = v61
    c44v2 = v3
    c44v2 = c44v2.GetColor
    c44v3 = 12
    c44v4 = true
    c44v5 = v89
    c44v2 = c44v2(c44v3, c44v4, c44v5)
    c44v1.Negative = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToHex
    c44v3 = v61
    c44v3 = c44v3.Negative
    c44v2 = c44v2(c44v3)
    c44v1.NegativeHex = c44v2
    c44v1 = v61
    c44v2 = v2
    c44v2 = c44v2.ConvertColorNumberToProceduralRGB
    c44v3 = v61
    c44v3 = c44v3.Negative
    c44v2 = c44v2(c44v3)
    c44v1.NegativeRGB = c44v2
    c44v1 = mMovie
    c44v3 = "Popup.Bg"
    c44v4 = "StartColor"
    c44v5 = v61
    c44v5 = c44v5.Background1RGB
    c44v5 = c44v5.r
    c44v6 = v61
    c44v6 = c44v6.Background1RGB
    c44v6 = c44v6.g
    c44v7 = v61
    c44v7 = c44v7.Background1RGB
    c44v7 = c44v7.b
    c44v8 = 1
    c44v1:Name__e243d995(c44v3, c44v4, c44v5, c44v6, c44v7, c44v8)
    c44v1 = mMovie
    c44v3 = "Popup.Bg"
    c44v4 = "EndColor"
    c44v5 = c44v0.r
    c44v6 = c44v0.g
    c44v7 = c44v0.b
    c44v8 = 0.95
    c44v1:Name__e243d995(c44v3, c44v4, c44v5, c44v6, c44v7, c44v8)
    c44v1 = v60
    if c44v1 == "" then
      c44v1 = mMovie
      c44v3 = "Popup.TitleBg"
      c44v4 = "RectEdgeColor"
      c44v5 = v61
      c44v5 = c44v5.BackerHighlightRGB
      c44v5 = c44v5.r
      c44v6 = v61
      c44v6 = c44v6.BackerHighlightRGB
      c44v6 = c44v6.g
      c44v7 = v61
      c44v7 = c44v7.BackerHighlightRGB
      c44v7 = c44v7.b
      c44v8 = 0.2
      c44v1:Name__e243d995(c44v3, c44v4, c44v5, c44v6, c44v7, c44v8)
    else
      c44v1 = mMovie
      c44v3 = "Popup.TitleBg"
      c44v4 = "RectEdgeColor"
      c44v5 = 0
      c44v6 = 0
      c44v7 = 0
      c44v8 = 0
      c44v1:Name__e243d995(c44v3, c44v4, c44v5, c44v6, c44v7, c44v8)
    end
    c44v1 = mMovie
    c44v3 = "Popup.TitleBg"
    c44v4 = "RectInnerColor"
    c44v5 = v61
    c44v5 = c44v5.Background1RGB
    c44v5 = c44v5.r
    c44v6 = v61
    c44v6 = c44v6.Background1RGB
    c44v6 = c44v6.g
    c44v7 = v61
    c44v7 = c44v7.Background1RGB
    c44v7 = c44v7.b
    c44v8 = 1
    c44v1:Name__e243d995(c44v3, c44v4, c44v5, c44v6, c44v7, c44v8)
    c44v1 = mMovie
    c44v3 = "Popup.Header.Bg"
    c44v4 = "RectEdgeColor"
    c44v5 = v61
    c44v5 = c44v5.BackerHighlightRGB
    c44v5 = c44v5.r
    c44v6 = v61
    c44v6 = c44v6.BackerHighlightRGB
    c44v6 = c44v6.g
    c44v7 = v61
    c44v7 = c44v7.BackerHighlightRGB
    c44v7 = c44v7.b
    c44v8 = 0.2
    c44v1:Name__e243d995(c44v3, c44v4, c44v5, c44v6, c44v7, c44v8)
    c44v1 = mMovie
    c44v3 = "Popup.Header.Bg"
    c44v4 = "RectInnerColor"
    c44v5 = v61
    c44v5 = c44v5.Background1RGB
    c44v5 = c44v5.r
    c44v6 = v61
    c44v6 = c44v6.Background1RGB
    c44v6 = c44v6.g
    c44v7 = v61
    c44v7 = c44v7.Background1RGB
    c44v7 = c44v7.b
    c44v8 = 1
    c44v1:Name__e243d995(c44v3, c44v4, c44v5, c44v6, c44v7, c44v8)
    c44v1 = mMovie
    c44v3 = "Popup.Header.Fade"
    c44v4 = "RectEdgeColor"
    c44v5 = 0
    c44v6 = 0
    c44v7 = 0
    c44v8 = 0
    c44v1:Name__e243d995(c44v3, c44v4, c44v5, c44v6, c44v7, c44v8)
    c44v1 = mMovie
    c44v3 = "Popup.Header.Fade"
    c44v4 = "RectInnerColor"
    c44v5 = v61
    c44v5 = c44v5.FloatingContentRGB
    c44v5 = c44v5.r
    c44v6 = v61
    c44v6 = c44v6.FloatingContentRGB
    c44v6 = c44v6.g
    c44v7 = v61
    c44v7 = c44v7.FloatingContentRGB
    c44v7 = c44v7.b
    c44v8 = 0.4
    c44v1:Name__e243d995(c44v3, c44v4, c44v5, c44v6, c44v7, c44v8)
    c44v1 = mMovie
    c44v3 = "Popup.Header.Label"
    c44v4 = 11
    c44v5 = v61
    c44v5 = c44v5.FloatingContentHighlight
    c44v1:SetNumberVariable(c44v3, c44v4, c44v5)
    c44v1 = v63
    c44v2 = v64
    c44v2 = c44v2.BASE
    if c44v1 == c44v2 then
      c44v1 = v17
      c44v1 = mMovie
      c44v3 = "Popup.Description"
      c44v4 = 36
      c44v6 = "<p><font color=\""
      c44v7 = v61
      c44v7 = c44v7.ContentHex
      c44v8 = "\">"
      c44v9 = v24
      c44v10 = "</font></p>"
      c44v5 = c44v6 .. c44v7 .. c44v8 .. c44v9 .. c44v10
      c44v1:SetStringVariable(c44v3, c44v4, c44v5)
      c44v1 = _T.InfoPopup_Grid
      c44v2 = v1
      c44v2 = c44v2.GetGridItemName
      c44v3 = mMovie
      c44v5 = v17
      c44v6 = v17
      c44v6 = c44v6.MetaData
      c44v2, c44v3 = c44v2(c44v3, c44v1, c44v5, c44v6)
      c44v4 = v1
      c44v4 = c44v4.GetGridItemTags
      c44v5 = mMovie
      c44v7 = v17
      c44v8 = v17
      c44v8 = c44v8.MetaData
      c44v4 = c44v4(c44v5, c44v1, c44v7, c44v8, c44v3)
      v26 = c44v4
      c44v4 = 1
      c44v5 = ipairs
      c44v6 = v26
      c44v5, c44v6, c44v7 = c44v5(c44v6)
      for c44v8, c44v9 in c44v5, c44v6, c44v7 do
        c44v10 = c44v9.ExcludeFromInfoPopup
        if not c44v10 then
          c44v10 = ""
          c44v11 = v1
          c44v11 = c44v11.GetPriceLabelClip
          c44v12 = mMovie
          c44v13 = "Popup"
          c44v10, c44v4 = c44v11(c44v12, c44v13, c44v4)
          c44v11 = true
          c44v9.FitText = c44v11
          c44v12 = v22
          c44v13 = v28
          c44v11 = c44v12 - c44v13
          c44v9.MaxWidth = c44v11
          c44v11 = v1
          c44v11 = c44v11.DrawPriceLabel
          c44v12 = mMovie
          c44v11(c44v12, c44v10, c44v9)
          c44v9.ClipName = c44v10
        end
      end
      for c44v8, c44v9 in c44v5, c44v6, c44v7 do
      end
    end
    c44v2 = "AbilityInfo.Passive.Description"
    c44v1 = {c44v2}
    c44v5 = "AbilityInfo.Ability"
    c44v9 = 1
    c44v8 = tostring
    c44v6 = c44v8(c44v9)
    c44v7 = ".Description"
    c44v4 = c44v5 .. c44v6 .. c44v7
    c44v2 = table.insert
    c44v2(c44v1, c44v4)
    c44v5 = "AbilityInfo.Ability"
    c44v9 = 2
    c44v8 = tostring
    c44v6 = c44v8(c44v9)
    c44v7 = ".Description"
    c44v4 = c44v5 .. c44v6 .. c44v7
    c44v2 = table.insert
    c44v2(c44v1, c44v4)
    c44v5 = "AbilityInfo.Ability"
    c44v9 = 3
    c44v8 = tostring
    c44v6 = c44v8(c44v9)
    c44v7 = ".Description"
    c44v4 = c44v5 .. c44v6 .. c44v7
    c44v2 = table.insert
    c44v2(c44v1, c44v4)
    c44v5 = "AbilityInfo.Ability"
    c44v9 = 4
    c44v8 = tostring
    c44v6 = c44v8(c44v9)
    c44v7 = ".Description"
    c44v4 = c44v5 .. c44v6 .. c44v7
    c44v2 = table.insert
    c44v2(c44v1, c44v4)
    c44v4 = 1
    c44v2 = #c44v1
    c44v3 = 1
    for c44v4 = c44v4, c44v2, c44v3 do
      c44v5 = mMovie
      c44v7 = "Popup"
      c44v8 = c44v1[c44v4]
      c44v9 = 11
      c44v10 = v61
      c44v10 = c44v10.Content
      c44v5:Name__52c1b74e(c44v7, c44v8, c44v9, c44v10)
    end
    c44v2 = {}
    c44v5 = 1
    c44v3 = #c44v2
    c44v4 = 1
    for c44v5 = c44v5, c44v3, c44v4 do
      c44v6 = mMovie
      c44v8 = "Popup"
      c44v9 = c44v2[c44v5]
      c44v10 = 11
      c44v11 = v61
      c44v11 = c44v11.FloatingContent
      c44v6:Name__52c1b74e(c44v8, c44v9, c44v10, c44v11)
    end
    c44v4 = "InfoToggle"
    c44v5 = "Subtitle"
    c44v6 = "TagSeparator"
    c44v7 = "PreviewTag"
    c44v8 = "PreviewCallout"
    c44v9 = "AbilityInfo.Passive.Name"
    c44v10 = "AbilityInfo.PassiveSeparator"
    c44v11 = "AbilityInfo.Passive.Icon"
    c44v12 = "PrereqSeparator.Separator"
    c44v13 = "IngredientsSeparator.Separator"
    c44v3 = {c44v4, c44v5, c44v6, c44v7, c44v8, c44v9, c44v10, c44v11, c44v12, c44v13}
    c44v6 = 1
    c44v4 = 4
    c44v5 = 1
    for c44v6 = c44v6, c44v4, c44v5 do
      c44v10 = "AbilityInfo.Ability"
      c44v13 = tostring
      c44v11 = c44v13(c44v6)
      c44v12 = ".Name"
      c44v9 = c44v10 .. c44v11 .. c44v12
      c44v7 = table.insert
      c44v7(c44v3, c44v9)
      c44v10 = "AbilityInfo.Ability"
      c44v13 = tostring
      c44v11 = c44v13(c44v6)
      c44v12 = ".Icon"
      c44v9 = c44v10 .. c44v11 .. c44v12
      c44v7 = table.insert
      c44v7(c44v3, c44v9)
    end
    c44v6 = 1
    c44v4 = #c44v3
    c44v5 = 1
    for c44v6 = c44v6, c44v4, c44v5 do
      c44v7 = mMovie
      c44v9 = "Popup"
      c44v10 = c44v3[c44v6]
      c44v11 = 11
      c44v12 = v61
      c44v12 = c44v12.FloatingContentHighlight
      c44v7:Name__52c1b74e(c44v9, c44v10, c44v11, c44v12)
    end
    c44v5 = v51
    c44v4 = IsNull
    c44v4 = c44v4(c44v5)
    if not c44v4 then
      c44v4 = v51
      c44v6 = function(c43v0)
        local c43v1, c43v2
        c43v1 = v51
        c43v1 = c43v1.UpdateColor
        c43v2 = c43v0.mClipName
        c43v1(c43v2)
        do return end
      end
      c44v4:RunForAllElements(c44v6)
    end
    c44v4 = mMovie
    c44v6 = "Popup.Title"
    c44v7 = 36
    c44v9 = "<p><font color=\""
    c44v10 = v61
    c44v10 = c44v10.FloatingContentHighlightHex
    c44v11 = "\">"
    c44v12 = v25
    c44v13 = "</font></p>"
    c44v8 = c44v9 .. c44v10 .. c44v11 .. c44v12 .. c44v13
    c44v4:SetStringVariable(c44v6, c44v7, c44v8)
    c44v5 = _T.ItemInfoStatComparison
    c44v4 = IsNull
    c44v4 = c44v4(c44v5)
    if c44v4 then
    else
      c44v4 = v58
      if c44v4 then
        c44v4 = _T.ItemInfoStatComparison
        c44v4()
      else
        c44v4 = _T.ItemInfoStatComparison
        c44v5 = v33
        c44v6 = v85
        c44v4(c44v5, c44v6)
      end
    end
    c44v4 = mMovie
    c44v6 = "Popup.CrewMemberInfo.Trait.Desc"
    c44v7 = 11
    c44v8 = v61
    c44v8 = c44v8.Content
    c44v4:SetNumberVariable(c44v6, c44v7, c44v8)
    c44v4 = mMovie
    c44v6 = "Popup.CrewMemberInfo.Trait.Icon"
    c44v7 = 11
    c44v8 = v61
    c44v8 = c44v8.FloatingContent
    c44v4:SetNumberVariable(c44v6, c44v7, c44v8)
    c44v4 = mMovie
    c44v6 = "Popup.CrewMemberInfo.BelowSkills.Faction"
    c44v7 = 11
    c44v8 = v61
    c44v8 = c44v8.Content
    c44v4:SetNumberVariable(c44v6, c44v7, c44v8)
    c44v4 = mMovie
    c44v6 = "Popup.CrewMemberInfo.BelowSkills.Rank"
    c44v7 = 44
    c44v8 = v61
    c44v8 = c44v8.Content
    c44v4:SetNumberVariable(c44v6, c44v7, c44v8)
    c44v4 = mMovie
    c44v6 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Separator"
    c44v7 = 11
    c44v8 = v61
    c44v8 = c44v8.FloatingContentHighlight
    c44v4:SetNumberVariable(c44v6, c44v7, c44v8)
    c44v4 = mMovie
    c44v6 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Name"
    c44v7 = 44
    c44v8 = v61
    c44v8 = c44v8.FloatingContent
    c44v4:SetNumberVariable(c44v6, c44v7, c44v8)
    c44v4 = mMovie
    c44v6 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Rank"
    c44v7 = 44
    c44v8 = v61
    c44v8 = c44v8.FloatingContentHighlight
    c44v4:SetNumberVariable(c44v6, c44v7, c44v8)
    c44v5 = v54
    c44v4 = IsNull
    c44v4 = c44v4(c44v5)
    if not c44v4 then
      c44v4 = v54
      c44v4:UpdateColors()
    end
    do return end
  end
  v91 = function()
    local c48v0, c48v1, c48v2, c48v3
    c48v0 = require
    c48v1 = "EE.Interface.Components.List"
    c48v0 = c48v0(c48v1)
    c48v1 = c48v0.CreateList
    c48v2 = mMovie
    c48v3 = "Popup.InfoToggle.List.Dot"
    c48v1 = c48v1(c48v2, c48v3)
    v18 = c48v1
    c48v1 = v18
    c48v2 = 14
    c48v1.mForcedHorizontalSeparation = c48v2
    c48v1 = v18
    c48v2 = 0
    c48v1.mForcedVerticalSeparation = c48v2
    c48v1 = v18
    c48v2 = function(c45v0)
      local c45v1, c45v2, c45v3, c45v4, c45v5, c45v6, c45v7, c45v8
      c45v1 = c45v0.mClipName
      if c45v1 == nil then
        do return end
      end
      c45v1 = false
      c45v2 = v18
      c45v2 = c45v2.mSelectedElement
      if c45v2 ~= nil then
        c45v2 = v18
        c45v2 = c45v2.mSelectedElement
        c45v2 = c45v2.Id
        c45v3 = c45v0.Id
        if c45v2 ~= c45v3 then
          c45v1 = false
        else
          c45v1 = true
        end
      end
      c45v2 = FlashMethod
      c45v3 = mMovie
      c45v5 = c45v0.mClipName
      c45v6 = ".gotoAndStop"
      c45v4 = c45v5 .. c45v6
      c45v5 = v2
      c45v5 = c45v5.Ternary
      c45v7 = "Selected"
      c45v8 = "Unfocused"
      c45v2(c45v3, c45v4, c45v5(c45v1, c45v7, c45v8))
      do return end
    end
    c48v1.mElementDrawCallback = c48v2
    c48v1 = v18
    c48v2 = function(c47v0)
      local c47v1, c47v2, c47v3, c47v4, c47v5, c47v6, c47v7
      local p27 = 0
      if p27 == 0 then
        c47v1 = c47v0.State
        v18 = c47v1
        c47v1 = c47v0.StatId
        v65 = c47v1
        c47v1 = v18
        c47v2 = v18
        c47v2 = c47v2.BASE
        if c47v1 ~= c47v2 then
          p27 = 4
        else
          p27 = 1
        end
      end
      if p27 == 1 then
        c47v1 = v65
        c47v1 = c47v1.AllInOne
        if c47v1 then
          p27 = 4
        else
          p27 = 2
        end
      end
      if p27 == 2 then
        c47v1 = v65
        c47v1 = c47v1.Category
        c47v2 = 43
        if c47v1 == c47v2 then
          p27 = 4
        else
          p27 = 3
        end
      end
      if p27 == 3 then
        c47v1 = v65
        c47v1 = c47v1.Category
        c47v2 = 46
        if c47v1 ~= c47v2 then
          p27 = 16
        else
          p27 = 4
        end
      end
      if p27 == 4 then
        c47v2 = v18
        c47v1 = IsNull
        c47v1 = c47v1(c47v2)
        if not c47v1 then
          p27 = 16
        else
          p27 = 5
        end
      end
      if p27 == 5 then
        c47v1 = {}
        c47v3 = v65
        c47v2 = IsNull
        c47v2 = c47v2(c47v3)
        if not c47v2 then
          c47v4 = v65
          c47v2 = table.insert
          c47v2(c47v1, c47v4:GetFullName())
        end
        c47v3 = v18
        c47v3 = c47v3.mExtraLoad
        c47v2 = IsNull
        c47v2 = c47v2(c47v3)
        c47v2 = pairs
        c47v3 = v18
        c47v3 = c47v3.mExtraLoad
        c47v2, c47v3, c47v4 = c47v2(c47v3)
        for c47v5, c47v6 in c47v2, c47v3, c47v4 do
          c47v7 = table.insert
          c47v7(c47v1, c47v6:GetFullName())
        end
        for c47v5, c47v6 in c47v2, c47v3, c47v4 do
        end
        c47v3 = v65
        c47v3 = c47v3.mExtraAbility
        c47v2 = IsNull
        c47v2 = c47v2(c47v3)
        if not c47v2 then
          c47v4 = v65
          c47v4 = c47v4.mExtraAbility
          c47v2 = table.insert
          c47v2(c47v1, c47v4:GetFullName())
        end
        c47v2 = #c47v1
        c47v3 = 0
        if c47v3 < c47v2 then
          c47v2 = UISys.ScriptResLoader_Create
          c47v4 = true
          c47v2 = c47v2(c47v1, c47v4)
          v18 = c47v2
          c47v2 = v65
          c47v3 = true
          c47v2(c47v3)
        else
          c47v2 = v65
          c47v2()
        end
        p27 = 17
      end
      if p27 == 16 then
        c47v1 = v65
        c47v1()
        p27 = 17
      end
      if p27 == 17 then
        c47v1 = v18
        c47v3 = function(c46v0)
          local c46v1
          c46v1 = v18
          c46v1 = c46v1.mElementDrawCallback
          c46v1(c46v0)
          do return end
        end
        c47v1:RunForAllElements(c47v3)
        do return end
      end
    end
    c48v1.mOnSelectedCallback = c48v2
    do return end
  end
  v92 = function()
    local c49v0, c49v1, c49v2, c49v3, c49v4, c49v5, c49v6, c49v7, c49v8, c49v9, c49v10, c49v11, c49v12
    c49v0 = v2
    c49v0 = c49v0.Ternary
    c49v1 = Engine.Name__9472b1e7
    c49v1 = c49v1()
    if not c49v1 then
      c49v1 = Engine.IsPS
      c49v1 = c49v1()
      if not c49v1 then
        c49v1 = Engine.IsSwitch2
        c49v1 = c49v1()
      end
    end
    c49v2 = "<MENU_RTRIGGER1>"
    c49v3 = "<NEXT_MENU>"
    c49v0 = c49v0(c49v1, c49v2, c49v3)
    c49v1 = mMovie
    c49v3 = v2
    c49v3 = c49v3.Ternary
    c49v4 = Engine.IsPlayingWithController
    c49v4 = c49v4()
    c49v5 = "<MENU_RTHUMB>"
    c49v6 = "<MENU_RIGHT_CLICK>"
    c49v3 = c49v3(c49v4, c49v5, c49v6)
    c49v4 = true
    c49v1 = c49v1:GetLocalized(c49v3, c49v4)
    c49v2 = "/Lotus/Language/OstronCrafting/Crafting_Preview_NoIcon"
    c49v3 = v17
    if c49v1 then
      c49v3 = v17
      c49v3 = c49v3.PreviewTagOverride
      if c49v3 ~= nil then
        c49v3 = v17
        c49v2 = c49v3.PreviewTagOverride
      else
        c49v3 = v17
        c49v3 = c49v3.mUnequipItem
        if c49v3 ~= nil then
          c49v2 = "/Lotus/Language/Menu/Loadout_Remove"
        end
      end
      c49v3 = v17
      c49v3 = c49v3.PreviewCalloutFunction
      if c49v3 ~= nil then
        c49v3 = mMovie
        c49v5 = v17
        c49v5 = c49v5.PreviewCalloutFunction
        c49v5 = c49v5()
        c49v6 = true
        c49v1 = c49v3:GetLocalized(c49v5, c49v6)
      end
      c49v3 = v17
      c49v3 = c49v3.CalloutOverride
      if c49v3 ~= nil then
        c49v3 = v17
        c49v0 = c49v3.CalloutOverride
      end
      c49v3 = v17
      c49v3 = c49v3.HidePreviewCallout
      if c49v3 ~= nil then
        c49v1 = ""
      end
    end
    c49v3 = mMovie
    c49v5 = "Popup.PreviewCallout"
    c49v6 = 36
    c49v3:SetStringVariable(c49v5, c49v6, c49v1)
    c49v3 = mMovie
    c49v5 = "Popup.PreviewCallout"
    c49v6 = 40
    c49v3 = c49v3:GetNumberVariable(c49v5, c49v6)
    c49v4 = mMovie
    c49v6 = "Popup.PreviewTag"
    c49v7 = 36
    c49v8 = string.upper
    c49v9 = mMovie
    c49v12 = false
    c49v4:SetStringVariable(c49v6, c49v7, c49v8(c49v9:GetLocalized(c49v2, c49v12)))
    c49v5 = mMovie
    c49v7 = "Popup.PreviewTag"
    c49v8 = 40
    c49v5 = c49v5:GetNumberVariable(c49v7, c49v8)
    c49v4 = c49v5 + 5
    c49v5 = mMovie
    c49v7 = "Popup.PreviewTag"
    c49v8 = 0
    c49v10 = v22
    c49v9 = c49v10 - c49v4
    c49v5:SetNumberVariable(c49v7, c49v8, c49v9)
    c49v5 = mMovie
    c49v7 = "Popup.PreviewCallout"
    c49v8 = 0
    c49v10 = v22
    c49v12 = c49v4 + c49v3
    c49v11 = c49v12 + 5
    c49v9 = c49v10 - c49v11
    c49v5:SetNumberVariable(c49v7, c49v8, c49v9)
    c49v5 = mMovie
    c49v7 = "Popup.InfoToggle.Callout.text"
    c49v5:SetLocalized(c49v7, c49v0)
    c49v5 = v17
    if c49v5 then
      c49v6 = v17
      c49v6 = c49v6.Resource
      c49v5 = IsNull
      c49v5 = c49v5(c49v6)
      if not c49v5 then
        c49v5 = v17
        c49v5 = c49v5.IsAbility
        if c49v5 then
          c49v5 = v88
          c49v6 = v17
          c49v6 = c49v6.Resource
          c49v5(c49v6)
        end
      end
    end
    do return end
  end
  v93 = function()
    local c50v0, c50v1, c50v2, c50v3, c50v4, c50v5, c50v6, c50v7, c50v8, c50v9, c50v10
    c50v0 = v18
    c50v0 = c50v0:GetHowManyElements()
    c50v1 = mMovie
    c50v3 = "Popup.InfoToggle.Callout"
    c50v4 = 40
    c50v1 = c50v1:GetNumberVariable(c50v3, c50v4)
    c50v2 = mMovie
    c50v4 = "Popup.InfoToggle.List"
    c50v5 = 0
    c50v10 = v18
    c50v10 = c50v10.mForcedHorizontalSeparation
    c50v9 = c50v0 * c50v10
    c50v8 = c50v9 + c50v1
    c50v7 = c50v8 + 5
    c50v6 = -c50v7
    c50v2:SetNumberVariable(c50v4, c50v5, c50v6)
    c50v3 = 1
    if c50v0 <= c50v3 then
      c50v2 = false
    else
      c50v2 = true
    end
    c50v3 = false
    c50v4 = v17
    if c50v4 ~= nil then
      c50v4 = v17
      c50v4 = c50v4.CalloutOverride
      if c50v4 == nil then
        c50v3 = false
      else
        c50v3 = true
      end
    end
    c50v4 = mMovie
    c50v6 = "Popup.InfoToggle"
    c50v7 = 13
    c50v8 = c50v2 or c50v3
    c50v4:Name__d9713943(c50v6, c50v7, c50v8)
    c50v4 = mMovie
    c50v6 = "Popup.InfoToggle.List"
    c50v7 = 13
    c50v4:Name__d9713943(c50v6, c50v7, c50v2)
    do return end
  end
  v94 = function()
    local c53v0, c53v1, c53v2, c53v3
    c53v0 = require
    c53v1 = "EE.Interface.Components.List"
    c53v0 = c53v0(c53v1)
    c53v1 = c53v0.CreateList
    c53v2 = mMovie
    c53v3 = "Popup.Ingredients.Ingredient"
    c53v1 = c53v1(c53v2, c53v3)
    v43 = c53v1
    c53v1 = v43
    c53v2 = 0
    c53v1.mForcedHorizontalSeparation = c53v2
    c53v1 = v43
    c53v2 = 62
    c53v1.mForcedVerticalSeparation = c53v2
    c53v1 = v43
    c53v2 = function(c51v0)
      local c51v1, c51v2, c51v3, c51v4, c51v5, c51v6, c51v7, c51v8, c51v9, c51v10, c51v11, c51v12, c51v13, c51v14, c51v15, c51v16, c51v17, c51v18, c51v19, c51v20, c51v21, c51v22, c51v23
      local p112 = 0
      if p112 == 0 then
        c51v1 = mMovie
        c51v4 = c51v0.mClipName
        c51v5 = ".Icon"
        c51v3 = c51v4 .. c51v5
        c51v4 = c51v0.Icon
        c51v1:OverrideTexture(c51v3, c51v4)
        c51v1 = mMovie
        c51v4 = c51v0.mClipName
        c51v5 = ".Icon"
        c51v3 = c51v4 .. c51v5
        c51v4 = c51v0.Material
        c51v1:OverrideMaterial(c51v3, c51v4)
        c51v1 = 52
        c51v2 = c51v0.mIconDimOffset
        if c51v2 == nil then
          p112 = 2
        else
          p112 = 1
        end
      end
      if p112 == 1 then
        c51v2 = c51v0.mIconDimOffset
        c51v1 = c51v1 + c51v2
        p112 = 2
      end
      if p112 == 2 then
        c51v2 = 28
        c51v3 = c51v0.mIconXOffset
        if c51v3 == nil then
          p112 = 4
        else
          p112 = 3
        end
      end
      if p112 == 3 then
        c51v3 = c51v0.mIconXOffset
        c51v2 = c51v2 + c51v3
        p112 = 4
      end
      if p112 == 4 then
        c51v3 = c51v2
        c51v4 = c51v0.mIconYOffset
        if c51v4 == nil then
          p112 = 6
        else
          p112 = 5
        end
      end
      if p112 == 5 then
        c51v4 = c51v0.mIconYOffset
        c51v3 = c51v3 + c51v4
        p112 = 6
      end
      if p112 == 6 then
        c51v4 = mMovie
        c51v6 = c51v0.mClipName
        c51v7 = "Icon"
        c51v8 = 0
        c51v4:Name__52c1b74e(c51v6, c51v7, c51v8, c51v2)
        c51v4 = mMovie
        c51v6 = c51v0.mClipName
        c51v7 = "Icon"
        c51v8 = 1
        c51v4:Name__52c1b74e(c51v6, c51v7, c51v8, c51v3)
        c51v4 = mMovie
        c51v6 = c51v0.mClipName
        c51v7 = "IconMask"
        c51v8 = 0
        c51v4:Name__52c1b74e(c51v6, c51v7, c51v8, c51v2)
        c51v4 = mMovie
        c51v6 = c51v0.mClipName
        c51v7 = "IconMask"
        c51v8 = 1
        c51v4:Name__52c1b74e(c51v6, c51v7, c51v8, c51v3)
        c51v4 = c51v1
        c51v5 = c51v0.Themed
        if c51v5 then
          p112 = 8
        else
          p112 = 7
        end
      end
      if p112 == 7 then
        c51v4 = c51v4 * 1.6
        p112 = 8
      end
      if p112 == 8 then
        c51v5 = mMovie
        c51v7 = c51v0.mClipName
        c51v8 = "Icon"
        c51v9 = 14
        c51v5:Name__52c1b74e(c51v7, c51v8, c51v9, c51v4)
        c51v5 = mMovie
        c51v7 = c51v0.mClipName
        c51v8 = "Icon"
        c51v9 = 15
        c51v5:Name__52c1b74e(c51v7, c51v8, c51v9, c51v1)
        c51v5 = mMovie
        c51v7 = c51v0.mClipName
        c51v8 = "Icon"
        c51v9 = 11
        c51v10 = v43
        c51v10 = c51v10.Ternary
        c51v12 = c51v0.TintIconColor
        if c51v12 ~= nil then
          p112 = 10
        else
          p112 = 9
        end
      end
      if p112 == 9 then
        c51v11 = false
        p112 = 11
      end
      if p112 == 10 then
        c51v11 = true
        p112 = 11
      end
      if p112 == 11 then
        c51v12 = c51v0.TintIconColor
        c51v13 = _G
        c51v13 = c51v13.UIColor_White
        c51v5:Name__52c1b74e(c51v7, c51v8, c51v9, c51v10(c51v11, c51v12, c51v13))
        c51v5 = c51v0.mIconScale
        if c51v5 == nil then
          p112 = 13
        else
          p112 = 12
        end
      end
      if p112 == 12 then
        c51v5 = mMovie
        c51v7 = c51v0.mClipName
        c51v8 = "Icon"
        c51v9 = 5
        c51v10 = c51v0.mIconScale
        c51v5:Name__52c1b74e(c51v7, c51v8, c51v9, c51v10)
        c51v5 = mMovie
        c51v7 = c51v0.mClipName
        c51v8 = "Icon"
        c51v9 = 6
        c51v10 = c51v0.mIconScale
        c51v5:Name__52c1b74e(c51v7, c51v8, c51v9, c51v10)
        p112 = 13
      end
      if p112 == 13 then
        c51v5 = false
        c51v6 = v43
        c51v6 = c51v6.MetaData
        if c51v6 == nil then
          p112 = 17
        else
          p112 = 14
        end
      end
      if p112 == 14 then
        c51v5 = v43
        c51v5 = c51v5.MetaData
        c51v5 = c51v5.CheckResearch
        if not c51v5 then
          p112 = 17
        else
          p112 = 15
        end
      end
      if p112 == 15 then
        c51v5 = false
        c51v6 = v43
        c51v7 = v43
        c51v7 = c51v7.CRAFTING
        if c51v6 == c51v7 then
          p112 = 17
        else
          p112 = 16
        end
      end
      if p112 == 16 then
        c51v6 = v43
        c51v6 = c51v6.mTechItem
        c51v5 = not c51v6
        p112 = 17
      end
      if p112 == 17 then
        c51v6 = true
        c51v7 = v43
        c51v7 = c51v7.mPrereqElement
        if c51v7 == nil then
          p112 = 21
        else
          p112 = 18
        end
      end
      if p112 == 18 then
        c51v7 = v43
        c51v7 = c51v7.mPrereqElement
        c51v7 = c51v7.TimeRemaining
        c51v8 = 0
        if c51v7 < c51v8 then
          p112 = 20
        else
          p112 = 19
        end
      end
      if p112 == 19 then
        c51v6 = false
        p112 = 21
      end
      if p112 == 20 then
        c51v6 = true
        p112 = 21
      end
      if p112 == 21 then
        c51v7 = not c51v6
        if not c51v5 then
          p112 = 23
        else
          p112 = 22
        end
      end
      if p112 == 22 then
        c51v0.mIncomplete = c51v7
        p112 = 23
      end
      if p112 == 23 then
        if c51v7 then
          p112 = 27
        else
          p112 = 24
        end
      end
      if p112 == 24 then
        c51v8 = c51v0.mIncomplete
        if not c51v8 then
          p112 = 26
        else
          p112 = 25
        end
      end
      if p112 == 25 then
        c51v9 = c51v0.mHasResources
        c51v8 = not c51v9
        p112 = 26
      end
      if p112 == 26 then
        c51v7 = c51v8
        p112 = 27
      end
      if p112 == 27 then
        c51v8 = v43
        c51v8 = c51v8.Ternary
        c51v10 = v43
        c51v10 = c51v10.ContentHex
        c51v11 = v43
        c51v11 = c51v11.FloatingContentHex
        c51v8 = c51v8(c51v7, c51v10, c51v11)
        c51v9 = v43
        c51v9 = c51v9.Ternary
        c51v11 = v43
        c51v11 = c51v11.ContentHex
        c51v12 = v43
        c51v12 = c51v12.FloatingContentHighlightHex
        c51v9 = c51v9(c51v7, c51v11, c51v12)
        c51v11 = "<p><font color=\""
        c51v13 = "\">"
        c51v16 = TitleCase
        c51v17 = c51v0.Name
        c51v14 = c51v16(c51v17)
        c51v15 = "</font>"
        c51v10 = c51v11 .. c51v8 .. c51v13 .. c51v14 .. c51v15
        c51v11 = c51v0.HideCount
        if c51v11 == true then
          p112 = 34
        else
          p112 = 28
        end
      end
      if p112 == 28 then
        c51v12 = "<font color=\""
        c51v14 = "\"><br>"
        c51v10 = c51v10 .. c51v12 .. c51v9 .. c51v14
        c51v11 = c51v0.SubText
        if c51v11 == nil then
          p112 = 30
        else
          p112 = 29
        end
      end
      if p112 == 29 then
        c51v12 = c51v0.SubText
        c51v10 = c51v10 .. c51v12
        p112 = 33
      end
      if p112 == 30 then
        if not c51v5 then
          p112 = 32
        else
          p112 = 31
        end
      end
      if p112 == 31 then
        c51v12 = v43
        c51v12 = c51v12.FormatNumber
        c51v13 = c51v0.Req
        c51v12 = c51v12(c51v13)
        c51v10 = c51v10 .. c51v12
        p112 = 33
      end
      if p112 == 32 then
        c51v15 = v43
        c51v15 = c51v15.FormatNumber
        c51v16 = c51v0.Count
        c51v12 = c51v15(c51v16)
        c51v13 = "/"
        c51v14 = v43
        c51v14 = c51v14.FormatNumber
        c51v15 = c51v0.Req
        c51v14 = c51v14(c51v15)
        c51v10 = c51v10 .. c51v12 .. c51v13 .. c51v14
        p112 = 33
      end
      if p112 == 33 then
        c51v12 = "</font>"
        c51v10 = c51v10 .. c51v12
        p112 = 34
      end
      if p112 == 34 then
        c51v12 = "</p>"
        c51v10 = c51v10 .. c51v12
        c51v11 = mMovie
        c51v13 = c51v0.mClipName
        c51v14 = "Name"
        c51v15 = 46
        c51v16 = "center"
        c51v11:Name__f4a9016a(c51v13, c51v14, c51v15, c51v16)
        c51v11 = mMovie
        c51v13 = c51v0.mClipName
        c51v14 = "Name"
        c51v15 = 36
        c51v11:Name__f4a9016a(c51v13, c51v14, c51v15, c51v10)
        c51v12 = c51v0.Name
        c51v11 = #c51v12
        if c51v11 ~= 0 then
          p112 = 38
        else
          p112 = 35
        end
      end
      if p112 == 35 then
        c51v11 = c51v0.SubText
        if c51v11 == nil then
          p112 = 38
        else
          p112 = 36
        end
      end
      if p112 == 36 then
        c51v12 = c51v0.SubText
        c51v11 = #c51v12
        c51v12 = 93
        if c51v11 <= c51v12 then
          p112 = 38
        else
          p112 = 37
        end
      end
      if p112 == 37 then
        c51v11 = mMovie
        c51v13 = c51v0.mClipName
        c51v14 = "Name"
        c51v15 = 1
        c51v16 = -20
        c51v11:Name__52c1b74e(c51v13, c51v14, c51v15, c51v16)
        c51v11 = v43
        c51v12 = 5
        c51v11.mInitialY = c51v12
        p112 = 38
      end
      if p112 == 38 then
        c51v11 = mMovie
        c51v13 = c51v0.mClipName
        c51v14 = "Name"
        c51v15 = 41
        c51v11 = c51v11:Name__46690123(c51v13, c51v14, c51v15)
        c51v0.mHeight = c51v11
        c51v11 = mMovie
        c51v13 = c51v0.mClipName
        c51v14 = 12
        c51v15 = v43
        c51v15 = c51v15.Ternary
        c51v17 = 40
        c51v18 = 100
        c51v11:SetNumberVariable(c51v13, c51v14, c51v15(c51v7, c51v17, c51v18))
        c51v11 = mMovie
        c51v13 = c51v0.mClipName
        c51v14 = "Check"
        c51v15 = 13
        c51v17 = c51v0.mIncomplete
        if c51v17 == nil then
          p112 = 40
        else
          p112 = 39
        end
      end
      if p112 == 39 then
        c51v17 = c51v0.mIncomplete
        c51v16 = not c51v17
        if not c51v16 then
          p112 = 41
        else
          p112 = 40
        end
      end
      if p112 == 40 then
        c51v17 = c51v0.HideCheck
        c51v16 = not c51v17
        p112 = 41
      end
      if p112 == 41 then
        c51v11:Makeposshield(c51v13, c51v14, c51v15, c51v16)
        c51v11 = mMovie
        c51v13 = c51v0.mClipName
        c51v14 = "Check"
        c51v15 = 11
        c51v16 = v43
        c51v16 = c51v16.FloatingContentHighlight
        c51v11:Name__52c1b74e(c51v13, c51v14, c51v15, c51v16)
        c51v11 = 58
        c51v12 = c51v0.mBgDimOffset
        if c51v12 == nil then
          p112 = 43
        else
          p112 = 42
        end
      end
      if p112 == 42 then
        c51v12 = c51v0.mBgDimOffset
        c51v11 = c51v11 + c51v12
        p112 = 43
      end
      if p112 == 43 then
        c51v12 = 28
        c51v13 = c51v0.mIconXOffset
        if c51v13 == nil then
          p112 = 45
        else
          p112 = 44
        end
      end
      if p112 == 44 then
        c51v13 = c51v0.mIconXOffset
        c51v12 = c51v12 + c51v13
        p112 = 45
      end
      if p112 == 45 then
        c51v13 = 28
        c51v14 = c51v0.mIconYOffset
        if c51v14 == nil then
          p112 = 47
        else
          p112 = 46
        end
      end
      if p112 == 46 then
        c51v14 = c51v0.mIconYOffset
        c51v13 = c51v13 + c51v14
        p112 = 47
      end
      if p112 == 47 then
        c51v14 = mMovie
        c51v16 = c51v0.mClipName
        c51v17 = "Bg"
        c51v18 = 0
        c51v14:Name__52c1b74e(c51v16, c51v17, c51v18, c51v12)
        c51v14 = mMovie
        c51v16 = c51v0.mClipName
        c51v17 = "Bg"
        c51v18 = 1
        c51v14:Name__52c1b74e(c51v16, c51v17, c51v18, c51v13)
        c51v14 = mMovie
        c51v16 = c51v0.mClipName
        c51v17 = "Bg"
        c51v18 = 14
        c51v14:Name__52c1b74e(c51v16, c51v17, c51v18, c51v11)
        c51v14 = mMovie
        c51v16 = c51v0.mClipName
        c51v17 = "Bg"
        c51v18 = 15
        c51v14:Name__52c1b74e(c51v16, c51v17, c51v18, c51v11)
        c51v14 = mMovie
        c51v16 = c51v0.mClipName
        c51v17 = "IconMask"
        c51v18 = 14
        c51v19 = c51v11 - 6
        c51v14:Name__52c1b74e(c51v16, c51v17, c51v18, c51v19)
        c51v14 = mMovie
        c51v16 = c51v0.mClipName
        c51v17 = "IconMask"
        c51v18 = 15
        c51v19 = c51v11 - 6
        c51v14:Name__52c1b74e(c51v16, c51v17, c51v18, c51v19)
        c51v14 = c51v0.mBgOverride
        if c51v14 == nil then
          p112 = 49
        else
          p112 = 48
        end
      end
      if p112 == 48 then
        c51v14 = mMovie
        c51v17 = c51v0.mClipName
        c51v18 = ".Bg"
        c51v16 = c51v17 .. c51v18
        c51v17 = c51v0.mBgOverride
        c51v18 = _G
        c51v18 = c51v18.UIMaterial_Plain
        c51v14:Name__9c27ee88(c51v16, c51v17, c51v18)
        c51v14 = mMovie
        c51v16 = c51v0.mClipName
        c51v17 = "Bg"
        c51v18 = 11
        c51v19 = v43
        c51v19 = c51v19.FloatingContentHighlight
        c51v14:Name__52c1b74e(c51v16, c51v17, c51v18, c51v19)
        p112 = 50
      end
      if p112 == 49 then
        c51v14 = v43
        c51v14 = c51v14.Background1RGB
        c51v15 = v43
        c51v15 = c51v15.BackerHighlightRGB
        c51v16 = mMovie
        c51v19 = c51v0.mClipName
        c51v20 = ".Bg"
        c51v18 = c51v19 .. c51v20
        c51v19 = _G
        c51v19 = c51v19.UIMaterial_RectangleNoDepth
        c51v16:OverrideMaterial(c51v18, c51v19)
        c51v16 = mMovie
        c51v18 = c51v0.mClipName
        c51v19 = "Bg"
        c51v20 = 11
        c51v21 = _G
        c51v21 = c51v21.UIColor_White
        c51v16:Name__52c1b74e(c51v18, c51v19, c51v20, c51v21)
        c51v16 = mMovie
        c51v19 = c51v0.mClipName
        c51v20 = ".Bg"
        c51v18 = c51v19 .. c51v20
        c51v19 = "RectEdgeColor"
        c51v20 = c51v15.r
        c51v21 = c51v15.g
        c51v22 = c51v15.b
        c51v23 = 0.05
        c51v16:Name__e243d995(c51v18, c51v19, c51v20, c51v21, c51v22, c51v23)
        c51v16 = mMovie
        c51v19 = c51v0.mClipName
        c51v20 = ".Bg"
        c51v18 = c51v19 .. c51v20
        c51v19 = "RectInnerColor"
        c51v20 = c51v14.r
        c51v21 = c51v14.g
        c51v22 = c51v14.b
        c51v23 = 0.9
        c51v16:Name__e243d995(c51v18, c51v19, c51v20, c51v21, c51v22, c51v23)
        p112 = 50
      end
      if p112 == 50 then
        c51v14 = c51v0.mBGScale
        if c51v14 == nil then
          p112 = 52
        else
          p112 = 51
        end
      end
      if p112 == 51 then
        c51v14 = mMovie
        c51v16 = c51v0.mClipName
        c51v17 = "Bg"
        c51v18 = 5
        c51v19 = c51v0.mBGScale
        c51v14:Name__52c1b74e(c51v16, c51v17, c51v18, c51v19)
        c51v14 = mMovie
        c51v16 = c51v0.mClipName
        c51v17 = "Bg"
        c51v18 = 6
        c51v19 = c51v0.mBGScale
        c51v14:Name__52c1b74e(c51v16, c51v17, c51v18, c51v19)
        p112 = 52
      end
      if p112 == 52 then
        c51v14 = c51v0.mIndex
        if c51v14 ~= nil then
          p112 = 54
        else
          p112 = 53
        end
      end
      if p112 == 53 then
        c51v15 = v43
        c51v17 = c51v0.Id
        c51v14 = c51v15:GetElementIndexById(c51v17)
        p112 = 54
      end
      if p112 == 54 then
        c51v15 = v43
        c51v15 = c51v15.mInitialY
        c51v16 = IsNull
        c51v16 = c51v16(c51v14)
        if c51v16 then
          p112 = 59
        else
          p112 = 55
        end
      end
      if p112 == 55 then
        c51v16 = 1
        if c51v14 <= c51v16 then
          p112 = 59
        else
          p112 = 56
        end
      end
      if p112 == 56 then
        c51v18 = 1
        c51v16 = c51v14 - 1
        c51v17 = 1
        if (c51v17 > 0 and c51v18 > c51v16) or (c51v17 < 0 and c51v18 < c51v16) then
          p112 = 58
        else
          p112 = 57
        end
      end
      if p112 == 57 then
        c51v20 = v43
        c51v20 = c51v20.mForcedVerticalSeparation
        c51v23 = v43
        c51v23 = c51v23.mElements
        c51v22 = c51v23[c51v18]
        c51v22 = c51v22.mHeight
        c51v21 = c51v22 or 0
        c51v19 = math.max
        c51v19 = c51v19(c51v20, c51v21)
        c51v15 = c51v15 + c51v19
        p112 = 58
      end
      if p112 == 58 then
        c51v18 = 5
        c51v19 = c51v14 - 1
        c51v17 = c51v18 * c51v19
        c51v16 = c51v15 + c51v17
        c51v20 = c51v0.mHeight
        c51v21 = v43
        c51v21 = c51v21.mForcedVerticalSeparation
        c51v19 = c51v20 - c51v21
        c51v18 = c51v19 / 2
        c51v19 = 0
        c51v17 = math.max
        c51v17 = c51v17(c51v18, c51v19)
        c51v15 = c51v16 + c51v17
        p112 = 59
      end
      if p112 == 59 then
        c51v16 = mMovie
        c51v18 = c51v0.mClipName
        c51v19 = 1
        c51v20 = v43
        c51v20 = c51v20.Round
        c51v16:SetNumberVariable(c51v18, c51v19, c51v20(c51v15))
        do return end
      end
    end
    c53v1.mElementDrawCallback = c53v2
    c53v1 = v43
    c53v2 = function(c52v0, c52v1)
      local c52v2
      c52v2 = 0
      do return c52v2 end
    end
    c53v1.CalculateY = c53v2
    do return end
  end
  v95 = function()
    local c56v0, c56v1, c56v2, c56v3
    c56v0 = require
    c56v1 = "EE.Interface.Components.List"
    c56v0 = c56v0(c56v1)
    c56v1 = c56v0.CreateList
    c56v2 = mMovie
    c56v3 = "Popup.IngredientsSecondary.Ingredient"
    c56v1 = c56v1(c56v2, c56v3)
    v44 = c56v1
    c56v1 = v44
    c56v2 = 0
    c56v1.mForcedHorizontalSeparation = c56v2
    c56v1 = v44
    c56v2 = 62
    c56v1.mForcedVerticalSeparation = c56v2
    c56v1 = v44
    c56v2 = function(c54v0)
      local c54v1, c54v2, c54v3, c54v4, c54v5, c54v6, c54v7, c54v8, c54v9, c54v10, c54v11, c54v12, c54v13, c54v14, c54v15, c54v16
      c54v1 = mMovie
      c54v4 = c54v0.mClipName
      c54v5 = ".Icon"
      c54v3 = c54v4 .. c54v5
      c54v4 = c54v0.Icon
      c54v1:OverrideTexture(c54v3, c54v4)
      c54v1 = mMovie
      c54v4 = c54v0.mClipName
      c54v5 = ".Icon"
      c54v3 = c54v4 .. c54v5
      c54v4 = c54v0.Material
      c54v1:OverrideMaterial(c54v3, c54v4)
      c54v1 = 50
      c54v2 = c54v0.Themed
      if not c54v2 then
        c54v1 = c54v1 * 1.6
      end
      c54v2 = mMovie
      c54v4 = c54v0.mClipName
      c54v5 = "Icon"
      c54v6 = 14
      c54v2:Name__52c1b74e(c54v4, c54v5, c54v6, c54v1)
      c54v2 = mMovie
      c54v4 = c54v0.mClipName
      c54v5 = "Icon"
      c54v6 = 11
      c54v7 = v44
      c54v7 = c54v7.Ternary
      c54v9 = c54v0.TintIconColor
      if c54v9 == nil then
        c54v8 = false
      else
        c54v8 = true
      end
      c54v9 = c54v0.TintIconColor
      c54v10 = _G
      c54v10 = c54v10.UIColor_White
      c54v2:Name__52c1b74e(c54v4, c54v5, c54v6, c54v7(c54v8, c54v9, c54v10))
      c54v2 = v44
      c54v2 = c54v2.FloatingContentHex
      c54v3 = v44
      c54v3 = c54v3.FloatingContentHighlightHex
      c54v5 = "<p><font color=\""
      c54v7 = "\">"
      c54v10 = TitleCase
      c54v11 = c54v0.Name
      c54v8 = c54v10(c54v11)
      c54v9 = "</font>"
      c54v4 = c54v5 .. c54v2 .. c54v7 .. c54v8 .. c54v9
      c54v5 = c54v0.HideCount
      if c54v5 ~= true then
        c54v6 = "<font color=\""
        c54v8 = "\"><br>"
        c54v4 = c54v4 .. c54v6 .. c54v3 .. c54v8
        c54v5 = c54v0.SubText
        if c54v5 ~= nil then
          c54v6 = c54v0.SubText
          c54v4 = c54v4 .. c54v6
        else
          c54v6 = v44
          c54v6 = c54v6.FormatNumber
          c54v7 = c54v0.Req
          c54v6 = c54v6(c54v7)
          c54v4 = c54v4 .. c54v6
        end
        c54v6 = "</font>"
        c54v4 = c54v4 .. c54v6
      end
      c54v6 = "</p>"
      c54v4 = c54v4 .. c54v6
      c54v5 = mMovie
      c54v7 = c54v0.mClipName
      c54v8 = "Name"
      c54v9 = 46
      c54v10 = "center"
      c54v5:Name__f4a9016a(c54v7, c54v8, c54v9, c54v10)
      c54v5 = mMovie
      c54v7 = c54v0.mClipName
      c54v8 = "Name"
      c54v9 = 36
      c54v5:Name__f4a9016a(c54v7, c54v8, c54v9, c54v4)
      c54v5 = mMovie
      c54v7 = c54v0.mClipName
      c54v8 = "Name"
      c54v9 = 41
      c54v5 = c54v5:Name__46690123(c54v7, c54v8, c54v9)
      c54v0.mHeight = c54v5
      c54v5 = mMovie
      c54v7 = c54v0.mClipName
      c54v8 = "Check"
      c54v9 = 13
      c54v10 = false
      c54v5:Makeposshield(c54v7, c54v8, c54v9, c54v10)
      c54v5 = v44
      c54v5 = c54v5.Background1RGB
      c54v6 = v44
      c54v6 = c54v6.BackerHighlightRGB
      c54v7 = mMovie
      c54v10 = c54v0.mClipName
      c54v11 = ".Bg"
      c54v9 = c54v10 .. c54v11
      c54v10 = _G
      c54v10 = c54v10.UIMaterial_RectangleNoDepth
      c54v7:OverrideMaterial(c54v9, c54v10)
      c54v7 = mMovie
      c54v10 = c54v0.mClipName
      c54v11 = ".Bg"
      c54v9 = c54v10 .. c54v11
      c54v10 = "RectEdgeColor"
      c54v11 = c54v6.r
      c54v12 = c54v6.g
      c54v13 = c54v6.b
      c54v14 = 0.05
      c54v7:Name__e243d995(c54v9, c54v10, c54v11, c54v12, c54v13, c54v14)
      c54v7 = mMovie
      c54v10 = c54v0.mClipName
      c54v11 = ".Bg"
      c54v9 = c54v10 .. c54v11
      c54v10 = "RectInnerColor"
      c54v11 = c54v5.r
      c54v12 = c54v5.g
      c54v13 = c54v5.b
      c54v14 = 0.9
      c54v7:Name__e243d995(c54v9, c54v10, c54v11, c54v12, c54v13, c54v14)
      c54v7 = c54v0.mIndex
      if c54v7 == nil then
        c54v8 = v44
        c54v10 = c54v0.Id
        c54v7 = c54v8:GetElementIndexById(c54v10)
      end
      c54v8 = v44
      c54v8 = c54v8.mInitialY
      c54v9 = IsNull
      c54v9 = c54v9(c54v7)
      if c54v7 ~= nil then
        c54v9 = 1
        if c54v9 < c54v7 then
          c54v11 = 1
          c54v9 = c54v7 - 1
          c54v10 = 1
          for c54v11 = c54v11, c54v9, c54v10 do
            c54v13 = v44
            c54v13 = c54v13.mForcedVerticalSeparation
            c54v16 = v44
            c54v16 = c54v16.mElements
            c54v15 = c54v16[c54v11]
            c54v15 = c54v15.mHeight
            c54v14 = c54v15 or 0
            c54v12 = math.max
            c54v12 = c54v12(c54v13, c54v14)
            c54v8 = c54v8 + c54v12
          end
          c54v11 = 5
          c54v12 = c54v7 - 1
          c54v10 = c54v11 * c54v12
          c54v9 = c54v8 + c54v10
          c54v13 = c54v0.mHeight
          c54v14 = v44
          c54v14 = c54v14.mForcedVerticalSeparation
          c54v12 = c54v13 - c54v14
          c54v11 = c54v12 / 2
          c54v12 = 0
          c54v10 = math.max
          c54v10 = c54v10(c54v11, c54v12)
          c54v8 = c54v9 + c54v10
        end
      end
      c54v9 = mMovie
      c54v11 = c54v0.mClipName
      c54v12 = 1
      c54v13 = v44
      c54v13 = c54v13.Round
      c54v9:SetNumberVariable(c54v11, c54v12, c54v13(c54v8))
      do return end
    end
    c56v1.mElementDrawCallback = c56v2
    c56v1 = v44
    c56v2 = function(c55v0, c55v1)
      local c55v2
      c55v2 = 0
      do return c55v2 end
    end
    c56v1.CalculateY = c56v2
    do return end
  end
  v96 = function()
    local c59v0, c59v1, c59v2, c59v3, c59v4, c59v5, c59v6
    c59v0 = require
    c59v1 = "EE.Interface.Components.List"
    c59v0 = c59v0(c59v1)
    c59v1 = c59v0.CreateList
    c59v2 = mMovie
    c59v3 = "Popup.CrewMemberInfo.Skill1"
    c59v1 = c59v1(c59v2, c59v3)
    v48 = c59v1
    c59v1 = v48
    c59v2 = 0
    c59v1.mForcedHorizontalSeparation = c59v2
    c59v1 = v48
    c59v2 = 32
    c59v1.mForcedVerticalSeparation = c59v2
    c59v1 = v48
    c59v2 = function(c57v0, c57v1)
      local c57v2, c57v5, c57v6, c57v7
      c57v2 = mMovie
      c57v5 = "Bg"
      c57v6 = 12
      c57v7 = 5
      c57v2:Name__52c1b74e(c57v0, c57v5, c57v6, c57v7)
      do return end
    end
    c59v1.mClipCreatedCallback = c59v2
    c59v1 = v48
    c59v2 = function(c58v0)
      local c58v1, c58v2, c58v3, c58v4, c58v5, c58v6, c58v7, c58v8
      c58v1 = mMovie
      c58v3 = c58v0.mClipName
      c58v4 = "Icon"
      c58v5 = 11
      c58v6 = v61
      c58v6 = c58v6.FloatingContent
      c58v1:Name__52c1b74e(c58v3, c58v4, c58v5, c58v6)
      c58v1 = mMovie
      c58v3 = c58v0.mClipName
      c58v4 = "Label"
      c58v5 = 44
      c58v6 = v61
      c58v6 = c58v6.FloatingContentHighlight
      c58v1:Name__52c1b74e(c58v3, c58v4, c58v5, c58v6)
      c58v1 = mMovie
      c58v3 = c58v0.mClipName
      c58v4 = "Bg"
      c58v5 = 11
      c58v6 = v61
      c58v6 = c58v6.Content
      c58v1:Name__52c1b74e(c58v3, c58v4, c58v5, c58v6)
      c58v1 = mMovie
      c58v4 = c58v0.mClipName
      c58v5 = ".Icon"
      c58v3 = c58v4 .. c58v5
      c58v5 = crewSkillIcons
      c58v7 = c58v0.Skill
      c58v6 = c58v7 + 1
      c58v4 = c58v5[c58v6]
      c58v1:OverrideTexture(c58v3, c58v4)
      c58v1 = mMovie
      c58v3 = c58v0.mClipName
      c58v4 = "Bg"
      c58v5 = 13
      c58v8 = c58v0.mIndex
      c58v7 = c58v8 % 2
      if c58v7 ~= 1 then
        c58v6 = false
      else
        c58v6 = true
      end
      c58v1:Makeposshield(c58v3, c58v4, c58v5, c58v6)
      c58v1 = TitleCase
      c58v2 = mMovie
      c58v5 = "/Lotus/Language/Railjack/CrewSkill"
      c58v7 = c58v0.Skill
      c58v6 = tostring
      c58v6 = c58v6(c58v7)
      c58v4 = c58v5 .. c58v6
      c58v5 = false
      c58v1 = c58v1(c58v2:GetLocalized(c58v4, c58v5))
      c58v2 = mMovie
      c58v4 = "/Lotus/Language/Railjack/CrewSkillLong"
      c58v5 = false
      c58v6 = { LEVEL = nil, SKILL = nil }
      c58v7 = c58v0.Level
      c58v6.LEVEL = c58v7
      c58v6.SKILL = c58v1
      c58v2 = c58v2:GetLocalized(c58v4, c58v5, c58v6)
      c58v3 = mMovie
      c58v5 = c58v0.mClipName
      c58v6 = "Label"
      c58v7 = 36
      c58v3:Name__f4a9016a(c58v5, c58v6, c58v7, c58v2)
      do return end
    end
    c59v1.mElementDrawCallback = c59v2
    c59v1 = 3
    c59v2 = gRegion
    c59v2 = c59v2:IsMaster()
    if not c59v2 then
      c59v1 = 4
    end
    c59v2 = mMovie
    c59v4 = "Popup.CrewMemberInfo.BelowSkills.HealthInfo"
    c59v5 = 1
    c59v6 = 40
    c59v2:SetNumberVariable(c59v4, c59v5, c59v6)
    c59v2 = mMovie
    c59v4 = "Popup.CrewMemberInfo.BelowSkills.HealthLabel"
    c59v5 = 1
    c59v6 = 15
    c59v2:SetNumberVariable(c59v4, c59v5, c59v6)
    c59v2 = mMovie
    c59v4 = "Popup.CrewMemberInfo.BelowSkills.Faction"
    c59v5 = 12
    c59v6 = 70
    c59v2:SetNumberVariable(c59v4, c59v5, c59v6)
    c59v2 = v1
    c59v2 = c59v2.DrawSeparator
    c59v3 = mMovie
    c59v4 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Separator"
    c59v5 = 325
    c59v2(c59v3, c59v4, c59v5)
    do return end
  end
  v97 = function(c60v0, c60v1)
    local c60v2, c60v3, c60v4, c60v5, c60v6, c60v7, c60v8, c60v9, c60v10, c60v11, c60v12, c60v13, c60v14, c60v15, c60v16, c60v17, c60v18, c60v19, c60v20, c60v21, c60v22, c60v23, c60v24
    c60v2 = mMovie
    c60v4 = "Popup.CrewMemberInfo"
    c60v5 = 13
    c60v6 = not c60v1
    c60v2:Name__d9713943(c60v4, c60v5, c60v6)
    if c60v1 then
      do return end
    end
    c60v2 = 0
    c60v3 = mMovie
    c60v5 = "Popup.CrewMemberInfo.Trait"
    c60v6 = 13
    c60v8 = v17
    c60v8 = c60v8.IsEliteCrewMember
    if c60v8 ~= true then
      c60v7 = false
    else
      c60v7 = true
    end
    c60v3:Name__d9713943(c60v5, c60v6, c60v7)
    c60v3 = v17
    c60v3 = c60v3.IsEliteCrewMember
    if c60v3 then
      c60v2 = 72
      c60v3 = mMovie
      c60v5 = "Popup.CrewMemberInfo.Trait.Desc"
      c60v6 = 46
      c60v7 = "center"
      c60v3:SetStringVariable(c60v5, c60v6, c60v7)
      c60v3 = v11
      c60v3 = c60v3.GetCrewMemberTrait
      c60v4 = v17
      c60v4 = c60v4.CrewMemberInfo
      c60v4 = c60v4.mCrewMemberGeneratedDetails
      c60v4 = c60v4.mSkillUpgrade
      c60v3 = c60v3(c60v4)
      c60v4 = v2
      c60v4 = c60v4.FitTextIntoLines
      c60v5 = mMovie
      c60v6 = "Popup.CrewMemberInfo.Trait.Desc"
      c60v7 = 3
      c60v9 = "..."
      c60v4(c60v5, c60v6, c60v7, c60v3, c60v9)
    end
    c60v3 = mMovie
    c60v5 = "Popup.CrewMemberInfo"
    c60v6 = 1
    c60v9 = v21
    c60v8 = c60v9 + 10
    c60v7 = c60v8 + c60v2
    c60v3:SetNumberVariable(c60v5, c60v6, c60v7)
    c60v3 = v48
    c60v5 = true
    c60v6 = true
    c60v3:RemoveElements(c60v5, c60v6)
    if not c60v1 then
      c60v5 = 0
      c60v6 = 5
      c60v3 = c60v6 - 1
      c60v4 = 1
      for c60v5 = c60v5, c60v3, c60v4 do
        c60v6 = v48
        c60v8 = { Skill = nil, Level = nil }
        c60v8.Skill = c60v5
        c60v9 = v17
        c60v9 = c60v9.CrewMemberInfo
        c60v9 = c60v9:GetSkillEfficiency(c60v5)
        c60v8.Level = c60v9
        c60v9 = true
        c60v6:AddElement(c60v8, c60v9)
      end
    end
    c60v3 = v48
    c60v5 = nil
    c60v6 = nil
    c60v7 = true
    c60v3:Redraw(c60v5, c60v6, c60v7)
    c60v4 = v48
    c60v4 = c60v4:GetHowManyElements()
    c60v5 = v48
    c60v5 = c60v5.mForcedVerticalSeparation
    c60v3 = c60v4 * c60v5
    c60v4 = mMovie
    c60v6 = "Popup.CrewMemberInfo.BelowSkills"
    c60v7 = 1
    c60v8 = c60v3 + 5
    c60v4:SetNumberVariable(c60v6, c60v7, c60v8)
    c60v6 = v21
    c60v5 = c60v6 + c60v2
    c60v4 = c60v5 + c60v3
    v21 = c60v4
    c60v4 = mMovie
    c60v6 = "Popup.CrewMemberInfo.BelowSkills.HealthInfo"
    c60v7 = 13
    c60v8 = false
    c60v4:Name__d9713943(c60v6, c60v7, c60v8)
    c60v4 = mMovie
    c60v6 = "Popup.CrewMemberInfo.BelowSkills.HealthLabel"
    c60v7 = 13
    c60v8 = false
    c60v4:Name__d9713943(c60v6, c60v7, c60v8)
    c60v4 = mMovie
    c60v6 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo"
    c60v7 = 1
    c60v8 = 0
    c60v4:SetNumberVariable(c60v6, c60v7, c60v8)
    c60v4 = mMovie
    c60v6 = "Popup.CrewMemberInfo.BelowSkills.Faction"
    c60v7 = 1
    c60v8 = 40
    c60v4:SetNumberVariable(c60v6, c60v7, c60v8)
    c60v4 = crewIconMap
    c60v6 = string.lower
    c60v7 = v17
    c60v7 = c60v7.CrewMemberInfo
    c60v7 = c60v7.mFaction
    c60v6 = c60v6(c60v7:c_str())
    c60v7 = 0
    c60v4 = c60v4:Name__8d37ff34(c60v6, c60v7)
    c60v5 = mMovie
    c60v7 = "Popup.CrewMemberInfo.BelowSkills.Faction"
    c60v8 = c60v4
    if not c60v8 then
      c60v8 = v17
      c60v8 = c60v8.Icon
    end
    c60v5:OverrideTexture(c60v7, c60v8)
    c60v5 = v17
    c60v5 = c60v5.CrewMemberInfo
    c60v5 = c60v5.mPowersuitInfo
    c60v6 = gGameConfig
    c60v8 = c60v5.mXP
    c60v9 = c60v5.mItemType
    c60v6 = c60v6:GetItemLevel(c60v8, c60v9)
    c60v7 = gGameConfig
    c60v9 = c60v5.mItemType
    c60v10 = c60v5.mPolarized
    c60v7 = c60v7:Name__123bb887(c60v9, c60v10)
    c60v8 = math.min
    c60v6 = c60v8(c60v7, c60v6)
    c60v8 = " "
    c60v9 = mMovie
    c60v11 = "Popup.CrewMemberInfo.BelowSkills.Rank"
    c60v12 = 36
    c60v13 = TitleCase
    c60v9:SetStringVariable(c60v11, c60v12, c60v13(c60v8))
    c60v9 = v17
    c60v9 = c60v9.CrewMemberInfo
    c60v9 = c60v9.mWeaponId
    c60v9 = c60v9.mId
    c60v10 = false
    c60v11 = Lotus_Game.InvalidItemID
    if c60v9 ~= c60v11 then
      c60v10 = false
      if c60v9 ~= "" then
        c60v11 = tonumber
        c60v11 = c60v11(c60v9)
        if c60v11 == 0 then
          c60v10 = false
        else
          c60v10 = true
        end
      end
    end
    c60v11 = mMovie
    c60v13 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo"
    c60v14 = 13
    c60v11:Name__d9713943(c60v13, c60v14, c60v10)
    if not c60v10 then
      c60v12 = v21
      c60v11 = c60v12 + 75
      v21 = c60v11
      c60v11 = mMovie
      c60v13 = "Popup.CrewMemberInfo.BelowSkills.Faction"
      c60v14 = 0
      c60v15 = 165
      c60v11:SetNumberVariable(c60v13, c60v14, c60v15)
      do return end
    end
    c60v11 = gGameData
    c60v11 = c60v11:GetInventory()
    c60v12 = c60v11:Name__34888a88(c60v9)
    c60v13 = IsNull
    c60v13 = c60v13(c60v12)
    if not c60v13 then
      c60v13 = gGameRules
      c60v13 = c60v13:GetStoreManifest()
      c60v14 = IsNull
      c60v14 = c60v14(c60v13)
      if not c60v14 then
        c60v14 = v4
        c60v14 = c60v14.GetItemTypeWithStoreInfo
        c60v15 = mMovie
        c60v16 = c60v12.mItemType
        c60v18 = { ItemInfo = nil }
        c60v18.ItemInfo = c60v12
        c60v19 = true
        c60v14 = c60v14(c60v15, c60v16, c60v13, c60v18, c60v19)
        c60v15 = IsNull
        c60v15 = c60v15(c60v14)
        if not c60v15 then
          c60v15 = mMovie
          c60v17 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Icon"
          c60v18 = c60v14.Icon
          c60v15:OverrideTexture(c60v17, c60v18)
          c60v15 = mMovie
          c60v17 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Icon"
          c60v18 = 14
          c60v20 = 64
          c60v21 = v2
          c60v21 = c60v21.Ternary
          c60v22 = c60v14.Themed
          c60v23 = 1
          c60v24 = 1.6
          c60v21 = c60v21(c60v22, c60v23, c60v24)
          c60v19 = c60v20 * c60v21
          c60v15:SetNumberVariable(c60v17, c60v18, c60v19)
          c60v15 = mMovie
          c60v17 = c60v14.Name
          c60v18 = false
          c60v15 = c60v15:GetLocalized(c60v17, c60v18)
          c60v16 = mMovie
          c60v18 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Name"
          c60v19 = 14
          c60v20 = 210
          c60v16:SetNumberVariable(c60v18, c60v19, c60v20)
          c60v16 = v2
          c60v16 = c60v16.SetFitText
          c60v17 = mMovie
          c60v18 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Name"
          c60v19 = "..."
          c60v16(c60v17, c60v18, c60v19)
          c60v16 = mMovie
          c60v18 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Name"
          c60v19 = 36
          c60v16:SetStringVariable(c60v18, c60v19, c60v15)
          c60v16 = gGameConfig
          c60v18 = c60v12.mXP
          c60v19 = c60v12.mItemType
          c60v16 = c60v16:GetItemLevel(c60v18, c60v19)
          c60v17 = mMovie
          c60v19 = "/Lotus/Language/Menu/Global_FormattedRankCaps"
          c60v20 = false
          c60v21 = { RANK = nil }
          c60v22 = v2
          c60v22 = c60v22.FormatNumber
          c60v22 = c60v22(c60v16)
          c60v21.RANK = c60v22
          c60v8 = c60v17:GetLocalized(c60v19, c60v20, c60v21)
          c60v17 = mMovie
          c60v19 = "Popup.CrewMemberInfo.BelowSkills.WeaponInfo.Rank"
          c60v20 = 36
          c60v21 = TitleCase
          c60v17:SetStringVariable(c60v19, c60v20, c60v21(c60v8))
        end
      end
    end
    c60v14 = v21
    c60v13 = c60v14 + 75
    v21 = c60v13
    c60v13 = mMovie
    c60v15 = "Popup.CrewMemberInfo.BelowSkills.Faction"
    c60v16 = 0
    c60v17 = 300
    c60v13:SetNumberVariable(c60v15, c60v16, c60v17)
    do return end
  end
  v98 = function(c61v0)
    local c61v1
    c61v1 = mMovie
    c61v1:SetMouseVisible(c61v0)
    do return end
  end
  v99 = function()
    local c62v0, c62v1
    c62v0 = _T
    c62v1 = nil
    c62v0.ShowItemInfoPopupCursor = c62v1
    c62v0 = v58
    if c62v0 then
      c62v0 = _T
      c62v1 = 0
      c62v0.ItemInfoPopupCount = c62v1
      c62v0 = _T
      c62v1 = nil
      c62v0.ItemInfoStatComparison = c62v1
    end
    do return end
  end
  Shutdown = v99
  v99 = function(c63v0, c63v1)
    local c63v2, c63v3, c63v4, c63v5, c63v6, c63v7, c63v8, c63v9, c63v10, c63v11, c63v12, c63v13, c63v14
    c63v2 = c63v0.Labels
    c63v3 = c63v1.Labels
    c63v4 = {}
    c63v0.StatChanges = c63v4
    c63v4 = {}
    c63v1.StatChanges = c63v4
    c63v4 = {}
    c63v7 = 1
    c63v5 = #c63v2
    c63v6 = 1
    for c63v7 = c63v7, c63v5, c63v6 do
      c63v8 = c63v2[c63v7]
      c63v4[c63v8] = c63v7
    end
    c63v7 = 1
    c63v5 = #c63v3
    c63v6 = 1
    for c63v7 = c63v7, c63v5, c63v6 do
      c63v9 = c63v3[c63v7]
      c63v8 = c63v4[c63v9]
      c63v10 = c63v1.CompareValues
      c63v9 = c63v10[c63v7]
      if c63v8 == nil then
      else
        c63v10 = c63v3[c63v7]
        c63v11 = nil
        c63v4[c63v10] = c63v11
        c63v11 = c63v0.CompareValues
        c63v10 = c63v11[c63v8]
        if c63v10 ~= c63v9 then
          c63v13 = tonumber
          c63v13 = c63v13(c63v10)
          c63v12 = c63v13 or 0
          c63v14 = tonumber
          c63v14 = c63v14(c63v9)
          c63v13 = c63v14 or 0
          if c63v13 <= c63v12 then
            c63v11 = false
          else
            c63v11 = true
          end
          c63v12 = c63v0.StatChanges
          if not c63v11 then
            c63v13 = 1
          else
            c63v13 = -1
          end
          c63v12[c63v8] = c63v13
          c63v12 = c63v1.StatChanges
          if c63v11 then
            c63v13 = 1
          else
            c63v13 = -1
          end
          c63v12[c63v7] = c63v13
        end
      end
    end
    do return end
  end
  v100 = function(c64v0, c64v1)
    local c64v2, c64v3, c64v4
    c64v2 = c64v0
    if not c64v2 then
      c64v2 = v34
    end
    v34 = c64v2
    c64v2 = c64v1
    if not c64v2 then
      c64v2 = v35
    end
    v35 = c64v2
    c64v2 = v34
    if c64v2 then
      c64v2 = v34
      c64v2 = c64v2.CompareValues
      if c64v2 ~= nil then
        c64v2 = v33
        c64v2 = c64v2.CompareValues
        if c64v2 ~= nil then
          c64v2 = v99
          c64v3 = v33
          c64v4 = v34
          c64v2(c64v3, c64v4)
          c64v2 = v33
          c64v3 = v33
          c64v3 = c64v3.BonusStats
          if not c64v3 then
            c64v3 = {}
          end
          c64v2.BonusStats = c64v3
          c64v2 = v34
          c64v3 = v34
          c64v3 = c64v3.BonusStats
          if not c64v3 then
            c64v3 = {}
          end
          c64v2.BonusStats = c64v3
          c64v2 = v99
          c64v3 = v33
          c64v3 = c64v3.BonusStats
          c64v4 = v34
          c64v4 = c64v4.BonusStats
          c64v2(c64v3, c64v4)
        end
      end
    end
    c64v2 = v85
    c64v2()
    c64v2 = v35
    if c64v2 ~= nil then
      c64v2 = v35
      c64v2()
    end
    do return end
  end
  v101 = function()
    local c69v0, c69v1, c69v2, c69v3
    c69v0 = require
    c69v1 = "EE.Interface.Components.List"
    c69v0 = c69v0(c69v1)
    c69v1 = c69v0.CreateList
    c69v2 = mMovie
    c69v3 = "Popup.Invasion.Subinvasion"
    c69v1 = c69v1(c69v2, c69v3)
    v51 = c69v1
    c69v1 = v51
    c69v2 = 330
    c69v1.BarWidth = c69v2
    c69v1 = v51
    c69v2 = 0
    c69v1.mForcedHorizontalSeparation = c69v2
    c69v1 = v51
    c69v2 = 75
    c69v1.mForcedVerticalSeparation = c69v2
    c69v1 = function(c65v0, c65v1)
      local c65v2, c65v3, c65v4, c65v5
      c65v3 = 50
      c65v5 = c65v0 / c65v1
      c65v4 = c65v5 * 50
      c65v2 = c65v3 + c65v4
      c65v3 = v17
      c65v3 = c65v3.AttackerFaction
      c65v4 = 2
      if c65v3 == c65v4 then
        c65v3 = 100
        c65v5 = c65v0 / c65v1
        c65v4 = c65v5 * 100
        c65v2 = c65v3 + c65v4
      end
      do return c65v2 end
    end
    c69v2 = v51
    c69v3 = function(c66v0)
      local c66v1, c66v3, c66v4, c66v5, c66v6, c66v7, c66v8
      c66v1 = mMovie
      c66v5 = ".ProgressBar.LeftFill"
      c66v3 = c66v0 .. c66v5
      c66v4 = "RectInnerColor"
      c66v5 = v61
      c66v5 = c66v5.FloatingContentRGB
      c66v5 = c66v5.r
      c66v6 = v61
      c66v6 = c66v6.FloatingContentRGB
      c66v6 = c66v6.g
      c66v7 = v61
      c66v7 = c66v7.FloatingContentRGB
      c66v7 = c66v7.b
      c66v8 = 0.4
      c66v1:Name__e243d995(c66v3, c66v4, c66v5, c66v6, c66v7, c66v8)
      c66v1 = mMovie
      c66v5 = ".ProgressBar.LeftFill"
      c66v3 = c66v0 .. c66v5
      c66v4 = "RectEdgeColor"
      c66v5 = 0
      c66v6 = 0
      c66v7 = 0
      c66v8 = 0
      c66v1:Name__e243d995(c66v3, c66v4, c66v5, c66v6, c66v7, c66v8)
      c66v1 = mMovie
      c66v5 = ".ProgressBar.RightFill"
      c66v3 = c66v0 .. c66v5
      c66v4 = "RectInnerColor"
      c66v5 = v61
      c66v5 = c66v5.FloatingContentRGB
      c66v5 = c66v5.r
      c66v6 = v61
      c66v6 = c66v6.FloatingContentRGB
      c66v6 = c66v6.g
      c66v7 = v61
      c66v7 = c66v7.FloatingContentRGB
      c66v7 = c66v7.b
      c66v8 = 1
      c66v1:Name__e243d995(c66v3, c66v4, c66v5, c66v6, c66v7, c66v8)
      c66v1 = mMovie
      c66v5 = ".ProgressBar.RightFill"
      c66v3 = c66v0 .. c66v5
      c66v4 = "RectEdgeColor"
      c66v5 = 0
      c66v6 = 0
      c66v7 = 0
      c66v8 = 0
      c66v1:Name__e243d995(c66v3, c66v4, c66v5, c66v6, c66v7, c66v8)
      c66v1 = mMovie
      c66v5 = ".ProgressBar.Bg"
      c66v3 = c66v0 .. c66v5
      c66v4 = "RectInnerColor"
      c66v5 = v61
      c66v5 = c66v5.Background1RGB
      c66v5 = c66v5.r
      c66v6 = v61
      c66v6 = c66v6.Background1RGB
      c66v6 = c66v6.g
      c66v7 = v61
      c66v7 = c66v7.Background1RGB
      c66v7 = c66v7.b
      c66v8 = 1
      c66v1:Name__e243d995(c66v3, c66v4, c66v5, c66v6, c66v7, c66v8)
      c66v1 = mMovie
      c66v5 = ".ProgressBar.Bg"
      c66v3 = c66v0 .. c66v5
      c66v4 = "RectEdgeColor"
      c66v5 = v61
      c66v5 = c66v5.FloatingContentRGB
      c66v5 = c66v5.r
      c66v6 = v61
      c66v6 = c66v6.FloatingContentRGB
      c66v6 = c66v6.g
      c66v7 = v61
      c66v7 = c66v7.FloatingContentRGB
      c66v7 = c66v7.b
      c66v8 = 1
      c66v1:Name__e243d995(c66v3, c66v4, c66v5, c66v6, c66v7, c66v8)
      c66v1 = mMovie
      c66v4 = "Progress"
      c66v5 = 44
      c66v6 = v61
      c66v6 = c66v6.Content
      c66v1:Name__52c1b74e(c66v0, c66v4, c66v5, c66v6)
      c66v1 = mMovie
      c66v4 = "LRewards"
      c66v5 = 44
      c66v6 = v61
      c66v6 = c66v6.Content
      c66v1:Name__52c1b74e(c66v0, c66v4, c66v5, c66v6)
      c66v1 = mMovie
      c66v4 = "RRewards"
      c66v5 = 44
      c66v6 = v61
      c66v6 = c66v6.Content
      c66v1:Name__52c1b74e(c66v0, c66v4, c66v5, c66v6)
      do return end
    end
    c69v2.UpdateColor = c69v3
    c69v2 = v51
    c69v3 = function(c67v0, c67v1)
      local c67v2, c67v4, c67v5, c67v6
      c67v2 = v51
      c67v2 = c67v2.UpdateColor
      c67v2(c67v0)
      c67v2 = mMovie
      c67v6 = ".ProgressBar.LeftFill"
      c67v4 = c67v0 .. c67v6
      c67v5 = _G
      c67v5 = c67v5.UIMaterial_RectangleNoDepth
      c67v2:OverrideMaterial(c67v4, c67v5)
      c67v2 = mMovie
      c67v6 = ".ProgressBar.RightFill"
      c67v4 = c67v0 .. c67v6
      c67v5 = _G
      c67v5 = c67v5.UIMaterial_RectangleNoDepth
      c67v2:OverrideMaterial(c67v4, c67v5)
      c67v2 = mMovie
      c67v6 = ".ProgressBar.Bg"
      c67v4 = c67v0 .. c67v6
      c67v5 = _G
      c67v5 = c67v5.UIMaterial_RectangleNoDepth
      c67v2:OverrideMaterial(c67v4, c67v5)
      do return end
    end
    c69v2.mClipCreatedCallback = c69v3
    c69v2 = v51
    c69v3 = function(c68v0)
      local c68v1, c68v2, c68v3, c68v4, c68v5, c68v6, c68v7, c68v8, c68v9, c68v10, c68v11, c68v12, c68v13, c68v14
      c68v1 = mMovie
      c68v3 = c68v0.Node
      c68v3 = c68v3:c_str()
      c68v4 = false
      c68v1 = c68v1:GetLocalized(c68v3, c68v4)
      c68v2 = c68v0.CustomEntry
      if not c68v2 then
        c68v2 = "<p><font size=\"19\"><b>"
        c68v4 = "</b></font></p>"
        c68v1 = c68v2 .. c68v1 .. c68v4
      end
      c68v2 = mMovie
      c68v4 = c68v0.mClipName
      c68v5 = "Title"
      c68v6 = 36
      c68v2:Name__f4a9016a(c68v4, c68v5, c68v6, c68v1)
      c68v2 = mMovie
      c68v4 = c68v0.mClipName
      c68v5 = "Title"
      c68v6 = 45
      c68v7 = v17
      c68v7 = c68v7.Ternary
      c68v8 = c68v0.CustomEntry
      c68v9 = "left"
      c68v10 = "center"
      c68v2:Name__f4a9016a(c68v4, c68v5, c68v6, c68v7(c68v8, c68v9, c68v10))
      c68v2 = mMovie
      c68v4 = c68v0.mClipName
      c68v5 = "Title"
      c68v6 = 0
      c68v7 = v17
      c68v7 = c68v7.Ternary
      c68v8 = c68v0.CustomEntry
      c68v9 = 2
      c68v10 = 115
      c68v2:Name__52c1b74e(c68v4, c68v5, c68v6, c68v7(c68v8, c68v9, c68v10))
      c68v2 = mMovie
      c68v4 = c68v0.mClipName
      c68v5 = "Title"
      c68v6 = 1
      c68v7 = v17
      c68v7 = c68v7.Ternary
      c68v8 = c68v0.CustomEntry
      c68v9 = 45
      c68v10 = 0
      c68v2:Name__52c1b74e(c68v4, c68v5, c68v6, c68v7(c68v8, c68v9, c68v10))
      c68v2 = mMovie
      c68v4 = c68v0.mClipName
      c68v5 = "Title"
      c68v6 = 44
      c68v7 = v17
      c68v7 = c68v7.Ternary
      c68v8 = c68v0.CustomEntry
      c68v9 = v51
      c68v9 = c68v9.FloatingContentHighlight
      c68v10 = v51
      c68v10 = c68v10.FloatingContent
      c68v2:Name__52c1b74e(c68v4, c68v5, c68v6, c68v7(c68v8, c68v9, c68v10))
      c68v2 = false
      c68v3 = c68v0.Delta
      if c68v3 ~= nil then
        c68v2 = false
        c68v3 = c68v0.Delta
        if c68v3 ~= 0 then
          c68v3 = c68v0.HideProgress
          c68v2 = not c68v3
        end
      end
      c68v3 = mMovie
      c68v5 = c68v0.mClipName
      c68v6 = "Progress"
      c68v7 = 13
      c68v3:Makeposshield(c68v5, c68v6, c68v7, c68v2)
      if c68v2 then
        c68v3 = 0
        c68v4 = mMovie
        c68v6 = c68v0.mClipName
        c68v7 = "Progress"
        c68v8 = 36
        c68v14 = c68v0.Delta
        c68v13 = tostring
        c68v10 = c68v13(c68v14)
        c68v11 = "/"
        c68v13 = 3
        c68v12 = tostring
        c68v12 = c68v12(c68v13)
        c68v9 = c68v10 .. c68v11 .. c68v12
        c68v4:Name__f4a9016a(c68v6, c68v7, c68v8, c68v9)
        c68v4 = mMovie
        c68v6 = c68v0.mClipName
        c68v7 = "Progress"
        c68v8 = 45
        c68v9 = v17
        c68v9 = c68v9.Ternary
        c68v10 = c68v0.SupportAttacker
        c68v11 = "left"
        c68v12 = "right"
        c68v4:Name__f4a9016a(c68v6, c68v7, c68v8, c68v9(c68v10, c68v11, c68v12))
        c68v4 = c68v0.SupportAttacker
        if not c68v4 then
          c68v4 = mMovie
          c68v7 = c68v0.mClipName
          c68v8 = ".Progress"
          c68v6 = c68v7 .. c68v8
          c68v7 = 14
          c68v4 = c68v4:GetNumberVariable(c68v6, c68v7)
          c68v5 = v51
          c68v5 = c68v5.BarWidth
          c68v3 = c68v5 - c68v4
        end
        c68v4 = mMovie
        c68v6 = c68v0.mClipName
        c68v7 = "Progress"
        c68v8 = 0
        c68v4:Name__52c1b74e(c68v6, c68v7, c68v8, c68v3)
      end
      c68v3 = c68v0.CustomEntry
      if c68v3 then
        c68v3 = mMovie
        c68v5 = c68v0.mClipName
        c68v6 = "ProgressBar.LeftFill"
        c68v7 = 14
        c68v8 = 0.001
        c68v3:Name__52c1b74e(c68v5, c68v6, c68v7, c68v8)
        c68v3 = Clamp
        c68v5 = v51
        c68v5 = c68v5.BarWidth
        c68v6 = c68v0.Delta
        c68v4 = c68v5 * c68v6
        c68v5 = 0.001
        c68v6 = v51
        c68v6 = c68v6.BarWidth
        c68v3 = c68v3(c68v4, c68v5, c68v6)
        c68v4 = mMovie
        c68v6 = c68v0.mClipName
        c68v7 = "ProgressBar.RightFill"
        c68v8 = 14
        c68v4:Name__52c1b74e(c68v6, c68v7, c68v8, c68v3)
        c68v4 = mMovie
        c68v6 = c68v0.mClipName
        c68v7 = "ProgressBar.RightFill"
        c68v8 = 0
        c68v4:Name__52c1b74e(c68v6, c68v7, c68v8, c68v3)
      else
        c68v4 = c68v0.Count
        c68v5 = c68v0.Goal
        c68v7 = 50
        c68v9 = c68v4 / c68v5
        c68v8 = c68v9 * 50
        c68v6 = c68v7 + c68v8
        c68v7 = v17
        c68v7 = c68v7.AttackerFaction
        c68v8 = 2
        if c68v7 == c68v8 then
          c68v7 = 100
          c68v9 = c68v4 / c68v5
          c68v8 = c68v9 * 100
          c68v6 = c68v7 + c68v8
        end
        c68v3 = c68v6
        c68v5 = v51
        c68v5 = c68v5.BarWidth
        c68v6 = c68v3 / 100
        c68v4 = c68v5 * c68v6
        c68v5 = mMovie
        c68v7 = c68v0.mClipName
        c68v8 = "ProgressBar.LeftFill"
        c68v9 = 14
        c68v10 = Clamp
        c68v11 = c68v4 + 2
        c68v12 = 0.001
        c68v13 = v51
        c68v13 = c68v13.BarWidth
        c68v5:Name__52c1b74e(c68v7, c68v8, c68v9, c68v10(c68v11, c68v12, c68v13))
        c68v5 = mMovie
        c68v7 = c68v0.mClipName
        c68v8 = "ProgressBar.RightFill"
        c68v9 = 14
        c68v10 = Clamp
        c68v13 = v51
        c68v13 = c68v13.BarWidth
        c68v12 = c68v13 - c68v4
        c68v11 = c68v12 + 2
        c68v12 = 0.001
        c68v13 = v51
        c68v13 = c68v13.BarWidth
        c68v5:Name__52c1b74e(c68v7, c68v8, c68v9, c68v10(c68v11, c68v12, c68v13))
        c68v5 = mMovie
        c68v7 = c68v0.mClipName
        c68v8 = "ProgressBar.RightFill"
        c68v9 = 0
        c68v10 = v51
        c68v10 = c68v10.BarWidth
        c68v5:Name__52c1b74e(c68v7, c68v8, c68v9, c68v10)
      end
      c68v3 = mMovie
      c68v5 = c68v0.mClipName
      c68v6 = "ProgressBar.Bg"
      c68v7 = 14
      c68v8 = v51
      c68v8 = c68v8.BarWidth
      c68v3:Name__52c1b74e(c68v5, c68v6, c68v7, c68v8)
      c68v4 = c68v0.AttackerReward
      c68v3 = IsNull
      c68v3 = c68v3(c68v4)
      if not c68v3 then
        c68v4 = c68v0.DefenderReward
        c68v3 = IsNull
        c68v3 = c68v3(c68v4)
        if not c68v3 then
          c68v3 = TitleCase
          c68v4 = v0
          c68v4 = c68v4.GetRewardDesc
          c68v5 = mMovie
          c68v6 = c68v0.AttackerReward
          c68v3 = c68v3(c68v4(c68v5, c68v6))
          c68v4 = TitleCase
          c68v5 = v0
          c68v5 = c68v5.GetRewardDesc
          c68v6 = mMovie
          c68v7 = c68v0.DefenderReward
          c68v4 = c68v4(c68v5(c68v6, c68v7))
          c68v5 = v17
          c68v5 = c68v5.FitTextIntoLines
          c68v6 = mMovie
          c68v8 = c68v0.mClipName
          c68v9 = ".LRewards"
          c68v7 = c68v8 .. c68v9
          c68v8 = 2
          c68v10 = "..."
          c68v5(c68v6, c68v7, c68v8, c68v3, c68v10)
          c68v5 = v17
          c68v5 = c68v5.FitTextIntoLines
          c68v6 = mMovie
          c68v8 = c68v0.mClipName
          c68v9 = ".RRewards"
          c68v7 = c68v8 .. c68v9
          c68v8 = 2
          c68v10 = "..."
          c68v5(c68v6, c68v7, c68v8, c68v4, c68v10)
          do return end
        end
      end
      c68v3 = mMovie
      c68v5 = c68v0.mClipName
      c68v6 = "LRewards"
      c68v7 = 36
      c68v8 = ""
      c68v3:Name__f4a9016a(c68v5, c68v6, c68v7, c68v8)
      c68v3 = mMovie
      c68v5 = c68v0.mClipName
      c68v6 = "RRewards"
      c68v7 = 36
      c68v8 = ""
      c68v3:Name__f4a9016a(c68v5, c68v6, c68v7, c68v8)
      do return end
    end
    c69v2.mElementDrawCallback = c69v3
    do return end
  end
  v102 = function()
    local c70v0, c70v1, c70v2, c70v3, c70v4, c70v5, c70v6, c70v7, c70v8
    c70v0 = _T
    c70v3 = _T.ItemInfoPopupCount
    c70v2 = c70v3 or 0
    c70v1 = c70v2 + 1
    c70v0.ItemInfoPopupCount = c70v1
    c70v0 = _T.ItemInfoStatComparison
    if c70v0 == nil then
      c70v0 = _T
      c70v1 = v100
      c70v0.ItemInfoStatComparison = c70v1
    end
    c70v0 = mMovie
    c70v2 = false
    c70v0:SetVisible(c70v2)
    c70v0 = mMovie
    c70v2 = true
    c70v0:SetIgnoreInput(c70v2)
    c70v0 = mMovie
    c70v2 = false
    c70v0:SetForcedInput(c70v2)
    c70v0 = mMovie
    c70v2 = true
    c70v0:Name__f7d22364(c70v2)
    c70v0 = require
    c70v1 = "Lotus.Interface.Libs.TimerMgr"
    c70v0 = c70v0(c70v1)
    c70v1 = c70v0.CreateTimerMgr
    c70v1 = c70v1()
    v37 = c70v1
    c70v1 = _T
    c70v2 = v98
    c70v1.ShowItemInfoPopupCursor = c70v2
    c70v1 = v1
    c70v1 = c70v1.GetRegularCreditsStoreItem
    c70v1 = c70v1()
    v52 = c70v1
    c70v1 = mMovie
    c70v3 = "Popup.Bg"
    c70v4 = midBgTexture
    c70v5 = midBgMaterial
    c70v1:Name__9c27ee88(c70v3, c70v4, c70v5)
    c70v1 = v1
    c70v1 = c70v1.DrawSeparator
    c70v2 = mMovie
    c70v3 = "Popup.TagSeparator"
    c70v4 = 330
    c70v1(c70v2, c70v3, c70v4)
    c70v1 = v1
    c70v1 = c70v1.DrawSeparator
    c70v2 = mMovie
    c70v3 = "Popup.PrereqSeparator.Separator"
    c70v4 = 330
    c70v1(c70v2, c70v3, c70v4)
    c70v1 = v1
    c70v1 = c70v1.DrawSeparator
    c70v2 = mMovie
    c70v3 = "Popup.IngredientsSeparator.Separator"
    c70v4 = 330
    c70v1(c70v2, c70v3, c70v4)
    c70v1 = v1
    c70v1 = c70v1.DrawSeparator
    c70v2 = mMovie
    c70v3 = "Popup.AbilityInfo.PassiveSeparator"
    c70v4 = 330
    c70v1(c70v2, c70v3, c70v4)
    c70v1 = mMovie
    c70v3 = "Popup.AbilityInfo.Passive.Icon"
    c70v4 = passiveIcon
    c70v1:OverrideTexture(c70v3, c70v4)
    c70v1 = mMovie
    c70v3 = "Popup.Bg"
    c70v4 = "RectEdgeColor"
    c70v5 = 0
    c70v6 = 0
    c70v7 = 0
    c70v8 = 0
    c70v1:Name__e243d995(c70v3, c70v4, c70v5, c70v6, c70v7, c70v8)
    c70v1 = mMovie
    c70v3 = "Popup.Bg"
    c70v4 = "RectInnerColor"
    c70v5 = 1
    c70v6 = 1
    c70v7 = 1
    c70v8 = 1
    c70v1:Name__e243d995(c70v3, c70v4, c70v5, c70v6, c70v7, c70v8)
    c70v1 = mMovie
    c70v3 = "Popup.Header.Fade"
    c70v4 = _G
    c70v4 = c70v4.UIMaterial_RectangleNoDepth
    c70v1:OverrideMaterial(c70v3, c70v4)
    c70v1 = mMovie
    c70v3 = "Popup.Header.Bg"
    c70v4 = _G
    c70v4 = c70v4.UIMaterial_RectangleNoDepth
    c70v1:OverrideMaterial(c70v3, c70v4)
    c70v1 = mMovie
    c70v3 = "Popup.TitleBg"
    c70v4 = _G
    c70v4 = c70v4.UIMaterial_RectangleNoDepth
    c70v1:OverrideMaterial(c70v3, c70v4)
    c70v1 = mMovie
    c70v3 = "Popup.TitleBg"
    c70v4 = 14
    c70v1 = c70v1:GetNumberVariable(c70v3, c70v4)
    v22 = c70v1
    c70v1 = Engine.IsMobile
    c70v1 = c70v1()
    if c70v1 then
      c70v1 = mMovie
      c70v3 = "Popup.TitleBg"
      c70v4 = nil
      c70v5 = nil
      c70v6 = nil
      c70v7 = "OnPopupTitleBgPressed"
      c70v1:SetCallbacks(c70v3, c70v4, c70v5, c70v6, c70v7)
    end
    c70v1 = v91
    c70v1()
    c70v1 = v94
    c70v1()
    c70v1 = v95
    c70v1()
    c70v1 = v101
    c70v1()
    c70v1 = v96
    c70v1()
    c70v1 = v79
    c70v1()
    c70v1 = v92
    c70v1()
    c70v1 = v90
    c70v1()
    c70v1 = require
    c70v2 = "Lotus.Interface.Components.ThemedSpinner"
    c70v1 = c70v1(c70v2)
    c70v2 = c70v1.Create
    c70v3 = mMovie
    c70v4 = "Popup.Spinner"
    c70v2 = c70v2(c70v3, c70v4)
    v38 = c70v2
    c70v2 = gPlayerProfileMgr
    c70v2 = c70v2:IsLoggedIn()
    if c70v2 then
      c70v2 = ObjectPortHandler
      c70v3 = gPlayerProfileMgr
      c70v5 = 0
      c70v3 = c70v3:GetPlayerProfile(c70v5)
      c70v3 = c70v3:GetGameSpecificData()
      c70v4 = "OnProfileSaved"
      c70v2(c70v3, c70v4)
    end
    c70v3 = { AbilityResource = nil, Images = nil, PageCallout = "/Lotus/Language/Suits/PagemasterFinalChapterTabCallout" }
    c70v4 = v69
    c70v3.AbilityResource = c70v4
    c70v4 = pagemasterFinalChapterAdditionalImages
    c70v3.Images = c70v4
    c70v2 = {c70v3}
    v70 = c70v2
    do return end
  end
  Initialize = v102
  v102 = function(c71v0)
    local c71v1, c71v2, c71v3, c71v4, c71v5, c71v6, c71v7
    if c71v0 == nil then
      c71v0 = 1
    end
    c71v1 = "Popup.TagContainer.Tag1"
    c71v2 = 1
    while true do
      c71v3 = mMovie
      c71v3 = c71v3:HasVariable(c71v1)
      if not c71v3 then
        do return end
      end
      c71v3 = mMovie
      c71v5 = c71v1
      c71v6 = 13
      if c71v0 <= c71v2 then
        c71v7 = false
      else
        c71v7 = true
      end
      c71v3:Name__d9713943(c71v5, c71v6, c71v7)
      c71v2 = c71v2 + 1
      c71v3 = "Popup.TagContainer.Tag"
      c71v4 = tostring
      c71v4 = c71v4(c71v2)
      c71v1 = c71v3 .. c71v4
    end
  end
  v103 = function(c72v0)
    local c72v1, c72v2, c72v3, c72v4, c72v5, c72v6, c72v7, c72v8
    c72v1 = v21
    c72v4 = v20
    c72v3 = c72v1 - c72v4
    c72v2 = c72v3 - c72v0
    c72v3 = 0
    if c72v2 <= c72v3 then
      c72v1 = c72v1 - 7
    end
    c72v3 = mMovie
    c72v5 = "Popup.Header.Bg"
    c72v6 = 15
    c72v8 = v23
    c72v7 = c72v1 + c72v8
    c72v3:SetNumberVariable(c72v5, c72v6, c72v7)
    c72v3 = mMovie
    c72v5 = "Popup.TitleBg"
    c72v6 = 15
    c72v3:SetNumberVariable(c72v5, c72v6, c72v1)
    c72v3 = mMovie
    c72v5 = "Popup.Bg"
    c72v6 = 13
    c72v8 = 0
    if c72v2 <= c72v8 then
      c72v7 = false
    else
      c72v7 = true
    end
    c72v3:Name__d9713943(c72v5, c72v6, c72v7)
    c72v3 = mMovie
    c72v5 = "Popup.Bg"
    c72v6 = 15
    c72v8 = 1
    c72v7 = math.max
    c72v7 = c72v7(c72v8, c72v2)
    c72v3:SetNumberVariable(c72v5, c72v6, c72v7)
    c72v3 = mMovie
    c72v5 = "Popup.Bg"
    c72v6 = 1
    c72v7 = v20
    c72v3:SetNumberVariable(c72v5, c72v6, c72v7)
    c72v3 = mMovie
    c72v5 = "Popup.PreviewTag"
    c72v6 = 1
    c72v8 = c72v0 - 6
    c72v7 = c72v1 - c72v8
    c72v3:SetNumberVariable(c72v5, c72v6, c72v7)
    c72v3 = mMovie
    c72v5 = "Popup.PreviewCallout"
    c72v6 = 1
    c72v8 = c72v0 - 6
    c72v7 = c72v1 - c72v8
    c72v3:SetNumberVariable(c72v5, c72v6, c72v7)
    c72v3 = mMovie
    c72v5 = "Popup.Blurer"
    c72v6 = 15
    c72v3:SetNumberVariable(c72v5, c72v6, c72v1)
    c72v3 = mMovie
    c72v5 = "Popup.SelectButton"
    c72v6 = 1
    c72v8 = c72v0 - 18
    c72v7 = c72v1 - c72v8
    c72v3:SetNumberVariable(c72v5, c72v6, c72v7)
    do return end
  end
  v66 = function(c73v0)
    local c73v1, c73v2, c73v3, c73v4, c73v5, c73v6, c73v7, c73v8, c73v9, c73v10, c73v11, c73v12, c73v13, c73v14, c73v15, c73v16, c73v17
    v39 = c73v0
    c73v1 = v38
    c73v1:SetActive(c73v0)
    c73v2 = "Description"
    c73v3 = "AbilityInfo"
    c73v4 = "ItemStats"
    c73v5 = "TagSeparator"
    c73v6 = "Ingredients"
    c73v7 = "IngredientsSeparator"
    c73v8 = "IngredientsSecondary"
    c73v9 = "PrereqSeparator"
    c73v10 = "Prerequisite"
    c73v11 = "RankedProgress"
    c73v12 = "RarityBar"
    c73v13 = "Affiliation1"
    c73v14 = "VideoPreview"
    c73v15 = "ExtraDesc"
    c73v16 = "CrewMemberInfo"
    c73v17 = "Invasion"
    c73v1 = {c73v2, c73v3, c73v4, c73v5, c73v6, c73v7, c73v8, c73v9, c73v10, c73v11, c73v12, c73v13, c73v14, c73v15, c73v16, c73v17}
    c73v2 = v102
    c73v2()
    c73v2 = pairs
    c73v2, c73v3, c73v4 = c73v2(c73v1)
    for c73v5, c73v6 in c73v2, c73v3, c73v4 do
      c73v7 = mMovie
      c73v9 = "Popup"
      c73v11 = 13
      c73v12 = false
      c73v7:Makeposshield(c73v9, c73v6, c73v11, c73v12)
    end
    c73v2 = v21
    if c73v2 == 0 then
      c73v2 = 120
      v21 = c73v2
      c73v2 = v103
      c73v3 = 9
      c73v2(c73v3)
    end
    c73v2 = mMovie
    c73v4 = "Popup.Spinner"
    c73v5 = 1
    c73v7 = v20
    c73v10 = v21
    c73v11 = v20
    c73v9 = c73v10 - c73v11
    c73v8 = c73v9 / 2
    c73v6 = c73v7 + c73v8
    c73v2:SetNumberVariable(c73v4, c73v5, c73v6)
    for c73v5, c73v6 in c73v2, c73v3, c73v4 do
    end
    do return end
  end
  v104 = function(c75v0)
    local c75v1, c75v2, c75v3, c75v4
    c75v1 = v46
    if c75v1 then
      c75v2 = gGameData
      c75v1 = IsNull
      c75v1 = c75v1(c75v2)
      if not c75v1 then
        c75v1 = false
        v46 = c75v1
        c75v1 = v37
        c75v3 = 5
        c75v4 = function()
          local c74v0
          c74v0 = true
          v46 = c74v0
          do return end
        end
        c75v1:AddTimer(c75v3, c75v4)
        c75v1 = {}
        v45 = c75v1
        c75v1 = gGameData
        c75v1 = c75v1:GetInventory()
        c75v2 = IsNull
        c75v2 = c75v2(c75v1)
        if not c75v2 then
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetSuits())
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetLongGuns())
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetPistols())
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetMelee())
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetSpaceSuits())
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetSpaceGuns())
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetSpaceMelee())
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetConsumables())
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetRecipes())
          c75v2 = v0
          c75v2 = c75v2.AddTableToPurchasedItems
          c75v3 = v45
          c75v2(c75v3, c75v1:GetWeaponSkins())
          if c75v0 then
            c75v2 = v0
            c75v2 = c75v2.AddTableToPurchasedItems
            c75v3 = v45
            c75v2(c75v3, c75v1:GetUpgrades())
            c75v2 = v0
            c75v2 = c75v2.AddTableToPurchasedItems
            c75v3 = v45
            c75v2(c75v3, c75v1:GetRawUpgrades())
          end
        end
      end
    end
    do return end
  end
  v105 = function(c76v0)
    local c76v1, c76v2, c76v3, c76v4, c76v5, c76v6, c76v7, c76v8, c76v9, c76v10, c76v11, c76v12, c76v13, c76v14
    local p113 = 0
    if p113 == 0 then
      c76v1 = v18
      c76v3 = true
      c76v4 = true
      c76v1:RemoveElements(c76v3, c76v4)
      c76v1 = v18
      c76v2 = false
      c76v1.mAbilitiesAvailable = c76v2
      c76v1 = v18
      c76v2 = false
      c76v1.mStatsAvailable = c76v2
      c76v1 = v18
      c76v2 = false
      c76v1.mLeaveRoom = c76v2
      c76v1 = 1
      c76v2 = v17
      c76v2 = c76v2.NumItemPopupPages
      if not c76v2 then
        p113 = 2
      else
        p113 = 1
      end
    end
    if p113 == 1 then
      c76v3 = v17
      c76v3 = c76v3.NumItemPopupPages
      c76v2 = math.max
      c76v1 = c76v2(c76v3, c76v1)
      p113 = 2
    end
    if p113 == 2 then
      c76v2 = v17
      c76v2 = c76v2.Hints
      if not c76v2 then
        p113 = 4
      else
        p113 = 3
      end
    end
    if p113 == 3 then
      c76v4 = v17
      c76v4 = c76v4.Hints
      c76v3 = #c76v4
      c76v2 = math.max
      c76v1 = c76v2(c76v3, c76v1)
      p113 = 4
    end
    if p113 == 4 then
      c76v2 = v17
      c76v2 = c76v2.AreStatsBuried
      if not c76v2 then
        p113 = 6
      else
        p113 = 5
      end
    end
    if p113 == 5 then
      c76v1 = c76v1 + 1
      p113 = 6
    end
    if p113 == 6 then
      c76v4 = 1
      c76v2 = c76v1
      c76v3 = 1
      if (c76v3 > 0 and c76v4 > c76v2) or (c76v3 < 0 and c76v4 < c76v2) then
        p113 = 8
      else
        p113 = 7
      end
    end
    if p113 == 7 then
      c76v5 = v18
      c76v7 = { State = nil }
      c76v8 = v64
      c76v8 = c76v8.BASE
      c76v7.State = c76v8
      c76v8 = true
      c76v5:AddElement(c76v7, c76v8)
      p113 = 8
    end
    if p113 == 8 then
      if c76v0 == nil then
        p113 = 12
      else
        p113 = 9
      end
    end
    if p113 == 9 then
      c76v2 = c76v0.AdditionalTabInfo
      if c76v2 == nil then
        p113 = 12
      else
        p113 = 10
      end
    end
    if p113 == 10 then
      c76v3 = c76v0.AdditionalTabInfo
      c76v4 = v17
      c76v3 = c76v3(c76v4)
      c76v2 = #c76v3
      c76v3 = 0
      if c76v2 <= c76v3 then
        p113 = 12
      else
        p113 = 11
      end
    end
    if p113 == 11 then
      c76v2 = v18
      c76v4 = { State = nil }
      c76v5 = v64
      c76v5 = c76v5.INFO
      c76v4.State = c76v5
      c76v5 = true
      c76v2:AddElement(c76v4, c76v5)
      p113 = 12
    end
    if p113 == 12 then
      c76v2 = v17
      c76v2 = c76v2.TimeRemaining
      if c76v2 == nil then
        p113 = 15
      else
        p113 = 13
      end
    end
    if p113 == 13 then
      c76v2 = v17
      c76v2 = c76v2.HideRecipe
      if c76v2 then
        p113 = 15
      else
        p113 = 14
      end
    end
    if p113 == 14 then
      c76v2 = v18
      c76v4 = { State = nil }
      c76v5 = v64
      c76v5 = c76v5.CRAFTING
      c76v4.State = c76v5
      c76v5 = true
      c76v2:AddElement(c76v4, c76v5)
      p113 = 15
    end
    if p113 == 15 then
      c76v2 = v17
      c76v2 = c76v2.mIsNemesis
      c76v3 = v17
      c76v3 = c76v3.ResultStoreItem
      if c76v3 then
        p113 = 17
      else
        p113 = 16
      end
    end
    if p113 == 16 then
      c76v3 = v17
      c76v3 = c76v3.StoreItem
      p113 = 17
    end
    if p113 == 17 then
      if c76v2 then
        p113 = 19
      else
        p113 = 18
      end
    end
    if p113 == 18 then
      c76v4 = IsNull
      c76v4 = c76v4(c76v3)
      if c76v4 then
        p113 = 60
      else
        p113 = 19
      end
    end
    if p113 == 19 then
      c76v4 = IsNull
      c76v4 = c76v4(c76v3)
      if c76v4 then
        p113 = 23
      else
        p113 = 20
      end
    end
    if p113 == 20 then
      c76v4 = IsNull
      c76v4 = c76v4(c76v3:GetItem())
      if c76v4 then
        p113 = 23
      else
        p113 = 21
      end
    end
    if p113 == 21 then
      c76v4 = c76v3:GetItem()
      c76v6 = Name__d7185637
      c76v4 = c76v4:IsA(c76v6)
      if not c76v4 then
        p113 = 23
      else
        p113 = 22
      end
    end
    if p113 == 22 then
      c76v4 = v18
      c76v5 = true
      c76v4.mLeaveRoom = c76v5
      p113 = 23
    end
    if p113 == 23 then
      c76v4 = nil
      c76v5 = IsNull
      c76v5 = c76v5(c76v3)
      if c76v5 then
        p113 = 25
      else
        p113 = 24
      end
    end
    if p113 == 24 then
      c76v4 = c76v3:GetProductCategory()
      p113 = 25
    end
    if p113 == 25 then
      c76v5 = c76v2
      if c76v5 then
        p113 = 31
      else
        p113 = 26
      end
    end
    if p113 == 26 then
      c76v5 = true
      c76v6 = 3
      if c76v4 == c76v6 then
        p113 = 31
      else
        p113 = 27
      end
    end
    if p113 == 27 then
      c76v5 = true
      c76v6 = 27
      if c76v4 == c76v6 then
        p113 = 31
      else
        p113 = 28
      end
    end
    if p113 == 28 then
      c76v6 = 48
      if c76v4 == c76v6 then
        p113 = 30
      else
        p113 = 29
      end
    end
    if p113 == 29 then
      c76v5 = false
      p113 = 31
    end
    if p113 == 30 then
      c76v5 = true
      p113 = 31
    end
    if p113 == 31 then
      c76v6 = true
      c76v7 = 0
      if c76v4 == c76v7 then
        p113 = 41
      else
        p113 = 32
      end
    end
    if p113 == 32 then
      c76v6 = true
      c76v7 = 1
      if c76v4 == c76v7 then
        p113 = 41
      else
        p113 = 33
      end
    end
    if p113 == 33 then
      c76v6 = true
      c76v7 = 5
      if c76v4 == c76v7 then
        p113 = 41
      else
        p113 = 34
      end
    end
    if p113 == 34 then
      c76v6 = true
      c76v7 = 28
      if c76v4 == c76v7 then
        p113 = 41
      else
        p113 = 35
      end
    end
    if p113 == 35 then
      c76v6 = true
      c76v7 = 29
      if c76v4 == c76v7 then
        p113 = 41
      else
        p113 = 36
      end
    end
    if p113 == 36 then
      c76v6 = true
      c76v7 = 37
      if c76v4 == c76v7 then
        p113 = 41
      else
        p113 = 37
      end
    end
    if p113 == 37 then
      c76v6 = true
      c76v7 = 16
      if c76v4 == c76v7 then
        p113 = 41
      else
        p113 = 38
      end
    end
    if p113 == 38 then
      c76v7 = 43
      if c76v4 == c76v7 then
        p113 = 40
      else
        p113 = 39
      end
    end
    if p113 == 39 then
      c76v6 = false
      p113 = 41
    end
    if p113 == 40 then
      c76v6 = true
      p113 = 41
    end
    if p113 == 41 then
      c76v7 = true
      c76v8 = 15
      if c76v4 == c76v8 then
        p113 = 45
      else
        p113 = 42
      end
    end
    if p113 == 42 then
      c76v8 = 39
      if c76v4 == c76v8 then
        p113 = 44
      else
        p113 = 43
      end
    end
    if p113 == 43 then
      c76v7 = false
      p113 = 45
    end
    if p113 == 44 then
      c76v7 = true
      p113 = 45
    end
    if p113 == 45 then
      c76v8 = v18
      c76v9 = c76v5
      if not c76v9 then
        p113 = 47
      else
        p113 = 46
      end
    end
    if p113 == 46 then
      c76v10 = v17
      c76v10 = c76v10.HideAbilities
      c76v9 = not c76v10
      p113 = 47
    end
    if p113 == 47 then
      c76v8.mAbilitiesAvailable = c76v9
      c76v8 = v18
      if (c76v5 or c76v6) then
        p113 = 50
      else
        p113 = 49
      end
    end
    if p113 == 49 then
      c76v9 = c76v7
      if not c76v9 then
        p113 = 51
      else
        p113 = 50
      end
    end
    if p113 == 50 then
      c76v10 = v17
      c76v10 = c76v10.HideStats
      c76v9 = not c76v10
      p113 = 51
    end
    if p113 == 51 then
      c76v8.mStatsAvailable = c76v9
      c76v8 = v18
      c76v8 = c76v8.mAbilitiesAvailable
      if c76v8 then
        c76v8 = v17
        c76v8 = c76v8.AllInOne
        if not c76v8 then
          c76v8 = v18
          c76v10 = { State = nil }
          c76v11 = v64
          c76v11 = c76v11.ABILITIES
          c76v10.State = c76v11
          c76v11 = true
          c76v8:AddElement(c76v10, c76v11)
          c76v8 = IsNull
          c76v8 = c76v8(c76v3)
          if not c76v8 then
            c76v8 = IsNull
            c76v8 = c76v8(c76v3:GetItem())
            if not c76v8 then
              c76v8 = c76v3:GetItem()
              c76v10 = v15
              c76v10 = c76v10.Sirius
              c76v8 = c76v8:IsA(c76v10)
              if c76v8 then
                c76v8 = v18
                c76v10 = { State = nil, SuitOverride = nil }
                c76v11 = v64
                c76v11 = c76v11.ABILITIES
                c76v10.State = c76v11
                c76v11 = v15
                c76v11 = c76v11.Orion
                c76v10.SuitOverride = c76v11
                c76v11 = true
                c76v8:AddElement(c76v10, c76v11)
                c76v8 = v18
                c76v10 = v15
                c76v10 = c76v10.Orion
                c76v9 = {c76v10}
                c76v8.mExtraLoad = c76v9
              end
            end
          end
        end
      end
      c76v8 = v18
      c76v8 = c76v8.mStatsAvailable
      if c76v8 then
        c76v10 = v2
        c76v10 = c76v10.Ternary
        c76v11 = v17
        c76v11 = c76v11.AllInOne
        c76v12 = 2
        c76v13 = 1
        c76v10 = c76v10(c76v11, c76v12, c76v13)
        c76v8 = v29
        c76v9 = 1
        for c76v10 = c76v10, c76v8, c76v9 do
          c76v11 = v18
          c76v13 = { State = nil, StatId = nil }
          c76v14 = v64
          c76v14 = c76v14.STATS
          c76v13.State = c76v14
          c76v13.StatId = c76v10
          c76v14 = true
          c76v11:AddElement(c76v13, c76v14)
        end
      end
      p113 = 60
    end
    if p113 == 60 then
      c76v4 = v18
      c76v6 = nil
      c76v7 = nil
      c76v8 = true
      c76v4:Redraw(c76v6, c76v7, c76v8)
      c76v4 = v93
      c76v4()
      do return end
    end
  end
  v106 = function()
    local c77v0, c77v1, c77v2, c77v3, c77v4, c77v5, c77v6, c77v7, c77v8, c77v9, c77v10, c77v11, c77v12, c77v13, c77v15
    local p49 = 0
    if p49 == 0 then
      c77v0 = v50
      c77v1 = false
      v50 = c77v1
      c77v1 = ""
      c77v2 = true
      c77v4 = v17
      c77v4 = c77v4.mPrereqElement
      if c77v4 ~= nil then
        p49 = 2
      else
        p49 = 1
      end
    end
    if p49 == 1 then
      c77v3 = false
      p49 = 3
    end
    if p49 == 2 then
      c77v3 = true
      p49 = 3
    end
    if p49 == 3 then
      c77v4 = v17
      c77v4 = c77v4.StoreItem
      c77v5 = c77v4:IsPersonalGuildHybridResearch()
      c77v6 = ""
      c77v7 = v17
      c77v7 = c77v7.MetaData
      if c77v7 == nil then
        p49 = 27
      else
        p49 = 4
      end
    end
    if p49 == 4 then
      c77v7 = v17
      c77v7 = c77v7.MetaData
      c77v7 = c77v7.CheckResearch
      if not c77v7 then
        p49 = 27
      else
        p49 = 5
      end
    end
    if p49 == 5 then
      c77v7 = v63
      c77v8 = v64
      c77v8 = c77v8.CRAFTING
      if c77v7 == c77v8 then
        p49 = 27
      else
        p49 = 6
      end
    end
    if p49 == 6 then
      c77v7 = v17
      c77v7 = c77v7.Researched
      if c77v7 then
        p49 = 10
      else
        p49 = 7
      end
    end
    if p49 == 7 then
      c77v7 = v17
      c77v7 = c77v7.InProgress
      if c77v7 then
        p49 = 10
      else
        p49 = 8
      end
    end
    if p49 == 8 then
      if not c77v3 then
        p49 = 25
      else
        p49 = 9
      end
    end
    if p49 == 9 then
      c77v7 = v17
      c77v7 = c77v7.mPrereqElement
      c77v7 = c77v7.TimeRemaining
      c77v8 = 0
      if c77v7 < c77v8 then
        p49 = 25
      else
        p49 = 10
      end
    end
    if p49 == 10 then
      c77v2 = false
      if not c77v0 then
        p49 = 13
      else
        p49 = 11
      end
    end
    if p49 == 11 then
      c77v7 = v17
      c77v7 = c77v7.mCompletionDate
      if c77v7 == nil then
        p49 = 13
      else
        p49 = 12
      end
    end
    if p49 == 12 then
      c77v7 = v17
      c77v8 = Engine.Name__b38e1642
      c77v9 = v17
      c77v9 = c77v9.mCompletionDate
      c77v8 = c77v8(c77v9)
      c77v7.TimeRemaining = c77v8
      p49 = 13
    end
    if p49 == 13 then
      c77v7 = v17
      c77v7 = c77v7.TimeRemaining
      c77v8 = 0
      if c77v7 <= c77v8 then
        p49 = 15
      else
        p49 = 14
      end
    end
    if p49 == 14 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/Dojo/ResearchStatusInProgress"
      c77v10 = false
      c77v1 = c77v7:GetLocalized(c77v9, c77v10)
      c77v7 = v0
      c77v7 = c77v7.SecondsToFormattedTime
      c77v8 = mMovie
      c77v9 = v17
      c77v9 = c77v9.TimeRemaining
      c77v10 = "Compact"
      c77v6 = c77v7(c77v8, c77v9, c77v10)
      c77v7 = true
      v50 = c77v7
      p49 = 32
    end
    if p49 == 15 then
      if not c77v3 then
        p49 = 18
      else
        p49 = 16
      end
    end
    if p49 == 16 then
      c77v7 = v17
      c77v7 = c77v7.Researched
      if c77v7 then
        p49 = 18
      else
        p49 = 17
      end
    end
    if p49 == 17 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/Dojo/ResearchPrereqNeededHint"
      c77v10 = false
      c77v11 = { PREREQ = nil }
      c77v12 = v17
      c77v12 = c77v12.mPrereqElement
      c77v12 = c77v12.Name
      c77v11.PREREQ = c77v12
      c77v1 = c77v7:GetLocalized(c77v9, c77v10, c77v11)
      p49 = 32
    end
    if p49 == 18 then
      c77v7 = _T.ShowDojoColors
      if not c77v7 then
        p49 = 20
      else
        p49 = 19
      end
    end
    if p49 == 19 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/Dojo/ResearchColorCompleteHint"
      c77v10 = false
      c77v1 = c77v7:GetLocalized(c77v9, c77v10)
      p49 = 32
    end
    if p49 == 20 then
      if not c77v5 then
        p49 = 22
      else
        p49 = 21
      end
    end
    if p49 == 21 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/Railjack/ResearchCompleteHintFabrication"
      c77v10 = false
      c77v1 = c77v7:GetLocalized(c77v9, c77v10)
      p49 = 32
    end
    if p49 == 22 then
      c77v7 = v17
      c77v7 = c77v7.IsNpcDeco
      if not c77v7 then
        p49 = 24
      else
        p49 = 23
      end
    end
    if p49 == 23 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/DojoDecosNpcs/NpcResearchCompleteHint"
      c77v10 = false
      c77v1 = c77v7:GetLocalized(c77v9, c77v10)
      p49 = 32
    end
    if p49 == 24 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/Dojo/ResearchCompleteHint"
      c77v10 = false
      c77v1 = c77v7:GetLocalized(c77v9, c77v10)
      p49 = 32
    end
    if p49 == 25 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/Dojo/ResearchRequirements"
      c77v10 = false
      c77v1 = c77v7:GetLocalized(c77v9, c77v10)
      if c77v5 then
        p49 = 32
      else
        p49 = 26
      end
    end
    if p49 == 26 then
      c77v7 = v0
      c77v7 = c77v7.SecondsToFormattedTime
      c77v8 = mMovie
      c77v9 = c77v4:GetResearchTime()
      c77v10 = "CompactHours"
      c77v6 = c77v7(c77v8, c77v9, c77v10)
      p49 = 32
    end
    if p49 == 27 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/Menu/Store_RecipeComponents"
      c77v10 = false
      c77v1 = c77v7:GetLocalized(c77v9, c77v10)
      if not c77v5 then
        p49 = 29
      else
        p49 = 28
      end
    end
    if p49 == 28 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/Railjack/FabricationRequirements"
      c77v10 = true
      c77v1 = c77v7:GetLocalized(c77v9, c77v10)
      p49 = 32
    end
    if p49 == 29 then
      c77v7 = v17
      c77v7 = c77v7.IsNpcDeco
      if not c77v7 then
        p49 = 31
      else
        p49 = 30
      end
    end
    if p49 == 30 then
      c77v7 = mMovie
      c77v9 = "/Lotus/Language/DojoDecosNpcs/NpcRecipeComponents"
      c77v10 = false
      c77v1 = c77v7:GetLocalized(c77v9, c77v10)
      p49 = 32
    end
    if p49 == 31 then
      c77v7 = v0
      c77v7 = c77v7.SecondsToFormattedTime
      c77v8 = mMovie
      c77v9 = c77v4:GetBuildTime()
      c77v10 = "CompactHours"
      c77v6 = c77v7(c77v8, c77v9, c77v10)
      p49 = 32
    end
    if p49 == 32 then
      c77v7 = #c77v6
      c77v8 = 0
      if c77v7 <= c77v8 then
        p49 = 34
      else
        p49 = 33
      end
    end
    if p49 == 33 then
      c77v7 = "<br>"
      c77v10 = mMovie
      c77v12 = "<TIMER> "
      c77v13 = true
      c77v8 = c77v10:GetLocalized(c77v12, c77v13)
      c77v6 = c77v7 .. c77v8 .. c77v6
      p49 = 34
    end
    if p49 == 34 then
      c77v7 = "<p><font color=\""
      c77v8 = v61
      c77v8 = c77v8.FloatingContentHex
      c77v9 = "\">"
      c77v11 = "<font color=\""
      c77v12 = v61
      c77v12 = c77v12.FloatingContentHighlightHex
      c77v13 = "\">"
      c77v15 = "</font></font></p>"
      c77v1 = c77v7 .. c77v8 .. c77v9 .. c77v1 .. c77v11 .. c77v12 .. c77v13 .. c77v6 .. c77v15
      c77v7 = mMovie
      c77v9 = "Popup.PrereqSeparator.Description"
      c77v10 = 36
      c77v7:SetStringVariable(c77v9, c77v10, c77v1)
      do return c77v2, c77v3 end
    end
  end
  v107 = function()
    local c79v0, c79v1, c79v2, c79v3, c79v4, c79v5, c79v6, c79v7, c79v8, c79v9, c79v10, c79v11, c79v12, c79v13, c79v14, c79v15, c79v16, c79v17, c79v18, c79v19, c79v20, c79v21, c79v22, c79v23, c79v24
    local p110 = 0
    if p110 == 0 then
      c79v0 = v17
      c79v0 = c79v0.StoreItem
      c79v1 = gGameRules
      c79v1 = c79v1:GetStoreManifest()
      c79v2 = nil
      c79v3 = IsNull
      c79v3 = c79v3(c79v1)
      if c79v3 then
        p110 = 76
      else
        p110 = 1
      end
    end
    if p110 == 1 then
      c79v3 = v106
      c79v3, c79v4 = c79v3()
      c79v5 = v43
      c79v7 = true
      c79v8 = true
      c79v5:RemoveElements(c79v7, c79v8)
      c79v5 = v104
      c79v6 = false
      c79v5(c79v6)
      if not c79v3 then
        p110 = 75
      else
        p110 = 2
      end
    end
    if p110 == 2 then
      c79v6 = gGameData
      c79v5 = IsNull
      c79v5 = c79v5(c79v6)
      if c79v5 then
        p110 = 4
      else
        p110 = 3
      end
    end
    if p110 == 3 then
      c79v5 = gGameData
      c79v2 = c79v5:GetInventory()
      p110 = 4
    end
    if p110 == 4 then
      c79v5 = 0
      c79v6 = v17
      c79v6 = c79v6.MetaData
      if c79v6 == nil then
        p110 = 7
      else
        p110 = 5
      end
    end
    if p110 == 5 then
      c79v6 = v17
      c79v6 = c79v6.MetaData
      c79v6 = c79v6.GuildTier
      if c79v6 == nil then
        p110 = 7
      else
        p110 = 6
      end
    end
    if p110 == 6 then
      c79v6 = v17
      c79v6 = c79v6.MetaData
      c79v5 = c79v6.GuildTier
      p110 = 9
    end
    if p110 == 7 then
      c79v6 = gGameRules
      c79v8 = gLotusDojoGameRulesType
      c79v6 = c79v6:IsA(c79v8)
      if not c79v6 then
        p110 = 9
      else
        p110 = 8
      end
    end
    if p110 == 8 then
      c79v6 = gGameRules
      c79v5 = c79v6:GetGuildTier()
      p110 = 9
    end
    if p110 == 9 then
      c79v7 = v17
      c79v7 = c79v7.IsNpcDeco
      if not c79v7 then
        p110 = 11
      else
        p110 = 10
      end
    end
    if p110 == 10 then
      c79v6 = gGameData
      c79v6 = c79v6:GetGuildVault()
      p110 = 12
    end
    if p110 == 11 then
      c79v6 = nil
      p110 = 12
    end
    if p110 == 12 then
      c79v7 = false
      c79v8 = v17
      c79v8 = c79v8.MetaData
      if c79v8 == nil then
        p110 = 17
      else
        p110 = 13
      end
    end
    if p110 == 13 then
      c79v7 = v17
      c79v7 = c79v7.MetaData
      c79v7 = c79v7.CheckResearch
      if not c79v7 then
        p110 = 17
      else
        p110 = 14
      end
    end
    if p110 == 14 then
      c79v8 = v63
      c79v9 = v64
      c79v9 = c79v9.CRAFTING
      if c79v8 ~= c79v9 then
        p110 = 16
      else
        p110 = 15
      end
    end
    if p110 == 15 then
      c79v7 = false
      p110 = 17
    end
    if p110 == 16 then
      c79v7 = true
      p110 = 17
    end
    if p110 == 17 then
      if not c79v7 then
        p110 = 19
      else
        p110 = 18
      end
    end
    if p110 == 18 then
      c79v8 = c79v0:GetResearchIngredients()
      if c79v8 then
        p110 = 20
      else
        p110 = 19
      end
    end
    if p110 == 19 then
      c79v8 = c79v0:GetIngredients()
      p110 = 20
    end
    if p110 == 20 then
      c79v11 = 1
      c79v9 = #c79v8
      c79v10 = 1
      for c79v11 = c79v11, c79v9, c79v10 do
        c79v12 = c79v8[c79v11]
        c79v15 = c79v12.mItemType
        c79v13 = c79v1:Name__1dc35bd2(c79v15)
        c79v14 = IsNull
        c79v14 = c79v14(c79v13)
        c79v14 = 0
        c79v15 = v43
        c79v17 = function(c78v0)
          local c78v1, c78v2, c78v3, c78v4, c78v5
          c78v1 = c78v0.Type
          if c78v1 ~= nil then
            c78v1 = c78v0.Type
            c78v2 = c79v12
            c78v2 = c78v2.mItemType
            if c78v1 == c78v2 then
              c78v2 = c79v14
              c78v4 = c78v0.Req
              c78v5 = c78v0.Count
              c78v3 = math.min
              c78v3 = c78v3(c78v4, c78v5)
              c78v1 = c78v2 - c78v3
              c79v14 = c78v1
            end
          end
          do return end
        end
        c79v15:RunForAllElements(c79v17)
        c79v15 = 0
        c79v16 = c79v6.mMiscItems
        c79v19 = 1
        c79v17 = #c79v16
        c79v18 = 1
        for c79v19 = c79v19, c79v17, c79v18 do
          c79v20 = c79v16[c79v19]
          c79v20 = c79v20.mItemType
          c79v21 = c79v12.mItemType
          if c79v20 == c79v21 then break end
        end
        c79v20 = c79v16[c79v19]
        c79v15 = c79v20.mItemCount
        c79v17 = v45
        c79v18 = c79v12.mItemType
        c79v18 = c79v18:GetFullName()
        c79v16 = c79v17[c79v18]
        c79v17 = v45
        c79v18 = c79v12.mItemType
        c79v18 = c79v18:GetFullName()
        c79v16 = c79v17[c79v18]
        c79v16 = c79v16.Count
        c79v17 = v45
        c79v18 = c79v12.mItemType
        c79v18 = c79v18:GetFullName()
        c79v16 = c79v17[c79v18]
        c79v15 = c79v16.Count
        c79v14 = c79v14 + c79v15
        c79v16 = v4
        c79v16 = c79v16.GetStoreItemInfo
        c79v17 = mMovie
        c79v19 = nil
        c79v20 = nil
        c79v21 = nil
        c79v22 = true
        c79v16 = c79v16(c79v17, c79v13, c79v19, c79v20, c79v21, c79v22)
        c79v17 = c79v12.mItemCount
        c79v16.Req = c79v17
        c79v17 = 0
        c79v18 = v17
        c79v18 = c79v18.IsNpcDeco
        c79v18 = gGameConfig
        c79v20 = nil
        c79v21 = c79v16.Req
        c79v23 = true
        c79v18 = c79v18:Name__4edc466d(c79v20, c79v21, c79v5, c79v23)
        c79v16.Req = c79v18
        c79v18 = v17
        c79v18 = c79v18.mTechItem
        c79v21 = 1
        c79v22 = c79v18.mReqItems
        c79v19 = #c79v22
        c79v20 = 1
        c79v16 = IsNull
        c79v16 = c79v16(c79v2)
        if not c79v16 then
          c79v18 = c79v12.mItemType
          c79v15 = c79v2:Name__2f311bf1(c79v18)
        end
        c79v23 = c79v18.mReqItems
        c79v22 = c79v23[c79v21]
        c79v22 = c79v22.mItemType
        c79v23 = c79v12.mItemType
        if c79v22 == c79v23 then
          c79v22 = c79v16.Req
          c79v24 = c79v18.mReqItems
          c79v23 = c79v24[c79v21]
          c79v23 = c79v23.mItemCount
          c79v17 = c79v22 - c79v23
        end
        c79v18 = c79v12.mItemType
        c79v20 = gLotusWeaponType
        c79v18 = c79v18:IsA(c79v20)
        if c79v18 then
          c79v18 = Clamp
          c79v20 = 0
          c79v21 = c79v12.mItemCount
          c79v14 = c79v18(c79v14, c79v20, c79v21)
        else
          c79v20 = 0
          c79v18 = math.max
          c79v14 = c79v18(c79v14, c79v20)
        end
        if not c79v18 then
          c79v18 = c79v16.Req
          if c79v17 < c79v18 then
            c79v18 = true
            c79v16.mIncomplete = c79v18
          end
          c79v20 = c79v16.Req
          c79v19 = c79v20 - c79v17
          if c79v14 < c79v19 then
            c79v18 = false
          else
            c79v18 = true
          end
          c79v16.mHasResources = c79v18
          c79v16.Count = c79v17
        else
          c79v19 = c79v16.Req
          if c79v19 <= c79v14 then
            c79v18 = false
          else
            c79v18 = true
          end
          c79v16.mIncomplete = c79v18
          c79v19 = c79v16.mIncomplete
          c79v18 = not c79v19
          c79v16.mHasResources = c79v18
          c79v16.Count = c79v14
        end
        c79v18 = v43
        c79v21 = true
        c79v18:AddElement(c79v16, c79v21)
      end
      local p106 = 56
      if p106 == 56 then
        if not c79v7 then
          p106 = 58
        else
          p106 = 57
        end
      end
      if p106 == 57 then
        c79v9 = c79v0:Name__aa50aeaf()
        if c79v9 then
          p106 = 59
        else
          p106 = 58
        end
      end
      if p106 == 58 then
        c79v9 = c79v0:GetBuildPrice()
        p106 = 59
      end
      if p106 == 59 then
        c79v10 = 0
        if c79v9 <= c79v10 then
        else
          p106 = 60
        end
      end
      if p106 == 60 then
        c79v10 = { Themed = true, Name = nil, Icon = nil }
        c79v11 = mMovie
        c79v13 = v52
        c79v13 = c79v13:GetLocalizeTag()
        c79v13 = c79v13:c_str()
        c79v14 = false
        c79v11 = c79v11:GetLocalized(c79v13, c79v14)
        c79v10.Name = c79v11
        c79v11 = v52
        c79v11 = c79v11:GetIconTexture()
        c79v10.Icon = c79v11
        c79v11 = 0
        if c79v7 then
          p106 = 62
        else
          p106 = 61
        end
      end
      if p106 == 61 then
        c79v12 = v17
        c79v12 = c79v12.IsNpcDeco
        if not c79v12 then
          p106 = 72
        else
          p106 = 62
        end
      end
      if p106 == 62 then
        c79v12 = gGameConfig
        c79v14 = nil
        c79v17 = true
        c79v9 = c79v12:Name__4edc466d(c79v14, c79v9, c79v5, c79v17)
        if not c79v7 then
          p106 = 70
        else
          p106 = 63
        end
      end
      if p106 == 63 then
        c79v12 = v17
        c79v12 = c79v12.mTechItem
        if not c79v12 then
          p106 = 70
        else
          p106 = 64
        end
      end
      if p106 == 64 then
        c79v12 = v17
        c79v12 = c79v12.mTechItem
        c79v12 = c79v12.mReqCredits
        c79v11 = c79v9 - c79v12
        if c79v9 <= c79v11 then
          p106 = 66
        else
          p106 = 65
        end
      end
      if p106 == 65 then
        c79v12 = true
        c79v10.mIncomplete = c79v12
        p106 = 66
      end
      if p106 == 66 then
        c79v13 = gGameData
        c79v13 = c79v13:GetRegularCredits()
        c79v14 = c79v9 - c79v11
        if c79v14 <= c79v13 then
          p106 = 68
        else
          p106 = 67
        end
      end
      if p106 == 67 then
        c79v12 = false
        p106 = 69
      end
      if p106 == 68 then
        c79v12 = true
        p106 = 69
      end
      if p106 == 69 then
        c79v10.mHasResources = c79v12
        p106 = 74
      end
      if p106 == 70 then
        c79v12 = v17
        c79v12 = c79v12.IsNpcDeco
        if not c79v12 then
          p106 = 74
        else
          p106 = 71
        end
      end
      if p106 == 71 then
        c79v11 = c79v6:GetRegularCredits()
        p106 = 74
      end
      if p106 == 72 then
        c79v13 = gGameData
        c79v12 = IsNull
        c79v12 = c79v12(c79v13)
        if c79v12 then
          p106 = 74
        else
          p106 = 73
        end
      end
      if p106 == 73 then
        c79v12 = gGameData
        c79v11 = c79v12:GetRegularCredits()
        p106 = 74
      end
      if p106 == 74 then
        c79v10.Count = c79v11
        c79v10.Req = c79v9
        c79v12 = v43
        c79v14 = 1
        c79v16 = true
        c79v12:InsertElement(c79v14, c79v10, c79v16)
      end
      p110 = 75
    end
    if p110 == 75 then
      c79v5 = v43
      c79v7 = nil
      c79v8 = nil
      c79v9 = true
      c79v5:Redraw(c79v7, c79v8, c79v9)
      do return c79v3, c79v4 end
    end
    if p110 == 76 then
      c79v3 = false
      c79v4 = false
      do return c79v3, c79v4 end
    end
  end
  v108 = function(c80v0)
    local c80v1, c80v2, c80v3, c80v4, c80v5
    local p35 = 0
    if p35 == 0 then
      c80v1 = 20
      if c80v0 == c80v1 then
        p35 = 3
      else
        p35 = 1
      end
    end
    if p35 == 1 then
      c80v1 = 22
      if c80v0 == c80v1 then
        p35 = 3
      else
        p35 = 2
      end
    end
    if p35 == 2 then
      c80v1 = 21
      if c80v0 ~= c80v1 then
        p35 = 4
      else
        p35 = 3
      end
    end
    if p35 == 3 then
      c80v1 = true
      do return c80v1 end
    end
    if p35 == 4 then
      c80v1 = nil
      c80v2 = nil
      c80v3 = 23
      if c80v0 ~= c80v3 then
        p35 = 6
      else
        p35 = 5
      end
    end
    if p35 == 5 then
      c80v3 = WeakResource
      c80v4 = "/Lotus/Types/Keys/EntratiLab/EntratiQuestKeyChain"
      c80v1 = c80v3(c80v4)
      p35 = 25
    end
    if p35 == 6 then
      c80v3 = 24
      if c80v0 ~= c80v3 then
        p35 = 8
      else
        p35 = 7
      end
    end
    if p35 == 7 then
      c80v3 = WeakResource
      c80v4 = "/Lotus/Types/Keys/OrokinMoonQuest/OrokinMoonQuestKeyChain"
      c80v1 = c80v3(c80v4)
      p35 = 25
    end
    if p35 == 8 then
      c80v3 = 25
      if c80v0 ~= c80v3 then
        p35 = 10
      else
        p35 = 9
      end
    end
    if p35 == 9 then
      c80v2 = "MarsToPhobosJunction"
      p35 = 25
    end
    if p35 == 10 then
      c80v3 = 26
      if c80v0 ~= c80v3 then
        p35 = 12
      else
        p35 = 11
      end
    end
    if p35 == 11 then
      c80v3 = WeakResource
      c80v4 = "/Lotus/Types/Keys/NewWarQuest/NewWarQuestKeyChain"
      c80v1 = c80v3(c80v4)
      p35 = 25
    end
    if p35 == 12 then
      c80v3 = 27
      if c80v0 ~= c80v3 then
        p35 = 14
      else
        p35 = 13
      end
    end
    if p35 == 13 then
      c80v3 = WeakResource
      c80v4 = "/Lotus/Types/Keys/ZarimanQuest/ZarimanQuestKeyChain"
      c80v1 = c80v3(c80v4)
      p35 = 25
    end
    if p35 == 14 then
      c80v3 = 29
      if c80v0 ~= c80v3 then
        p35 = 16
      else
        p35 = 15
      end
    end
    if p35 == 15 then
      c80v3 = WeakResource
      c80v4 = "/Lotus/Types/Keys/WarWithinQuest/WarWithinQuestKeyChain"
      c80v1 = c80v3(c80v4)
      p35 = 25
    end
    if p35 == 16 then
      c80v3 = 30
      if c80v0 ~= c80v3 then
        p35 = 18
      else
        p35 = 17
      end
    end
    if p35 == 17 then
      c80v3 = WeakResource
      c80v4 = "/Lotus/Types/Keys/InfestedMicroplanetQuest/InfestedMicroplanetQuestKeyChain"
      c80v1 = c80v3(c80v4)
      p35 = 25
    end
    if p35 == 18 then
      c80v3 = 31
      if c80v0 ~= c80v3 then
        p35 = 20
      else
        p35 = 19
      end
    end
    if p35 == 19 then
      c80v2 = "CeresToJupiterJunction"
      p35 = 25
    end
    if p35 == 20 then
      c80v3 = 28
      if c80v0 == c80v3 then
        p35 = 22
      else
        p35 = 21
      end
    end
    if p35 == 21 then
      c80v3 = 32
      if c80v0 ~= c80v3 then
        p35 = 23
      else
        p35 = 22
      end
    end
    if p35 == 22 then
      c80v3 = WeakResource
      c80v4 = "/Lotus/Types/Keys/1999Quest/1999QuestKeyChain"
      c80v1 = c80v3(c80v4)
      p35 = 25
    end
    if p35 == 23 then
      c80v3 = 33
      if c80v0 ~= c80v3 then
        p35 = 25
      else
        p35 = 24
      end
    end
    if p35 == 24 then
      c80v3 = WeakResource
      c80v4 = "/Lotus/Types/Keys/TauPrequel/TauPrequelQuestKeyChain"
      c80v1 = c80v3(c80v4)
      p35 = 25
    end
    if p35 == 25 then
      if c80v1 == nil then
        p35 = 27
      else
        p35 = 26
      end
    end
    if p35 == 26 then
      c80v3 = v0
      c80v3 = c80v3.HasCompletedQuest
      do return c80v3(c80v1) end
    end
    if p35 == 27 then
      if c80v2 == nil then
        p35 = 29
      else
        p35 = 28
      end
    end
    if p35 == 28 then
      c80v3 = gGameData
      c80v5 = Symbol
      do return c80v3:HasCompletedMission(c80v5(c80v2)) end
    end
    if p35 == 29 then
      c80v3 = false
      do return c80v3 end
    end
  end
  v109 = function(c82v0, c82v1, c82v2, c82v3, c82v4, c82v5, c82v6, c82v7, c82v8)
    local c82v9, c82v10, c82v11, c82v12, c82v13, c82v14, c82v15, c82v16, c82v17, c82v18, c82v19, c82v20, c82v21, c82v24, c82v25, c82v28, c82v29, c82v31, c82v32, c82v33, c82v34, c82v35, c82v36, c82v37, c82v38, c82v39, c82v40, c82v41, c82v42, c82v43, c82v44, c82v45
    local c82v22 = c82v0.mEvoInfo
    c82v22 = v0
    c82v22 = c82v22.ReplaceTextColors
    local c82v23 = v24
    c82v24 = v61
    c82v22 = c82v22(c82v23, c82v24)
    v24 = c82v22
    c82v28 = v17
    c82v28 = c82v28.Affiliations
    c82v29 = v21
    local c82v30 = 10
    c82v28 = c82v29 + c82v30
    v21 = c82v28
    c82v28 = v17
    c82v28 = c82v28.Affiliations
    c82v7 = #c82v28
    c82v31 = v32
    c82v30 = c82v31 + 1
    c82v28 = c82v7
    c82v29 = 1
    for c82v30 = c82v30, c82v28, c82v29 do
      c82v32 = "Popup.Affiliation"
      c82v31 = c82v32 .. c82v30
      c82v32 = mMovie
      c82v32 = c82v32:HasVariable(c82v31)
      if not c82v32 then
        c82v32 = FlashMethod
        c82v33 = mMovie
        c82v34 = "Popup.Affiliation1.duplicateMovieClip"
        c82v36 = "Affiliation"
        c82v35 = c82v36 .. c82v30
        c82v32(c82v33, c82v34, c82v35, c82v30)
      end
    end
    c82v22 = mMovie
    c82v24 = "Popup.Description"
    c82v25 = 36
    local c82v27 = "<p><font color=\""
    c82v28 = v61
    c82v28 = c82v28.ContentHex
    c82v29 = "\">"
    c82v30 = v24
    c82v32 = "</font></p>"
    local c82v26 = c82v27 .. c82v28 .. c82v29 .. c82v30 .. c82v3 .. c82v32
    c82v22:SetStringVariable(c82v24, c82v25, c82v26)
    c82v3 = ""
    c82v22 = v24
    if c82v22 ~= "" then
      c82v23 = v21
      c82v24 = mMovie
      c82v26 = "Popup.Description"
      c82v27 = 41
      c82v24 = c82v24:GetNumberVariable(c82v26, c82v27)
      c82v22 = c82v23 + c82v24
      v21 = c82v22
    else
      c82v20 = false
      c82v23 = v21
      c82v24 = 21
      c82v22 = c82v23 - c82v24
      v21 = c82v22
    end
    c82v22 = mMovie
    c82v24 = "Popup.TagSeparator"
    c82v25 = 13
    c82v22:Name__d9713943(c82v24, c82v25, c82v20)
    c82v22 = mMovie
    c82v24 = "Popup.CrewMemberInfo"
    c82v25 = 13
    c82v27 = v17
    c82v27 = c82v27.CrewMemberInfo
    if c82v27 == nil then
      c82v26 = false
    else
      c82v26 = true
    end
    c82v22:Name__d9713943(c82v24, c82v25, c82v26)
    c82v22 = v17
    c82v22 = c82v22.CrewMemberInfo
    if c82v22 ~= nil then
      c82v22 = v97
      c82v24 = v17
      c82v24 = c82v24.CrewMemberInfo
      c82v22(c82v6, c82v24:IsNemesis())
    end
    c82v22 = nil
    c82v23 = { W = 330, H = 330 }
    c82v25 = v17
    c82v25 = c82v25.HintIcons
    c82v24 = #c82v25
    c82v25 = 0
    if c82v22 == "" then
      c82v25 = v17
      c82v25 = c82v25.HintIcons
      c82v27 = v18
      c82v27 = c82v27.mCurrentElementIndex
      c82v26 = c82v27 or 1
      c82v24 = c82v25[c82v26]
      if c82v24 ~= nil then
        c82v22 = c82v24.Icon
        c82v25 = v2
        c82v25 = c82v25.Ternary
        c82v27 = c82v24.W
        if c82v27 == nil then
          c82v26 = false
        else
          c82v26 = true
        end
        c82v27 = c82v24.W
        c82v28 = c82v23.W
        c82v25 = c82v25(c82v26, c82v27, c82v28)
        c82v23.W = c82v25
        c82v25 = v2
        c82v25 = c82v25.Ternary
        c82v27 = c82v24.H
        if c82v27 == nil then
          c82v26 = false
        else
          c82v26 = true
        end
        c82v27 = c82v24.H
        c82v28 = c82v23.H
        c82v25 = c82v25(c82v26, c82v27, c82v28)
        c82v23.H = c82v25
      end
    end
    if c82v22 == nil then
      c82v24 = false
    else
      c82v24 = true
    end
    c82v25 = mMovie
    c82v27 = "Popup.GenericIcon"
    c82v28 = 13
    c82v25:Name__d9713943(c82v27, c82v28, c82v24)
    if c82v24 then
      c82v25 = mMovie
      c82v27 = "Popup.GenericIcon"
      c82v25:OverrideTexture(c82v27, c82v22)
      c82v25 = mMovie
      c82v27 = "Popup.GenericIcon"
      c82v28 = 1
      c82v30 = v21
      c82v31 = 10
      c82v29 = c82v30 + c82v31
      c82v25:SetNumberVariable(c82v27, c82v28, c82v29)
      c82v25 = mMovie
      c82v27 = "Popup.GenericIcon"
      c82v28 = 14
      c82v29 = c82v23.W
      c82v25:SetNumberVariable(c82v27, c82v28, c82v29)
      c82v25 = mMovie
      c82v27 = "Popup.GenericIcon"
      c82v28 = 15
      c82v29 = c82v23.H
      c82v25:SetNumberVariable(c82v27, c82v28, c82v29)
      c82v25 = v21
      c82v26 = c82v23.H
      c82v25 = c82v25 + c82v26
      v21 = c82v25
    end
    c82v25 = mMovie
    c82v27 = "Popup.ExtraDesc"
    c82v28 = 13
    c82v30 = v17
    c82v30 = c82v30.ExtraDesc
    if c82v30 == nil then
      c82v29 = false
    else
      c82v29 = true
    end
    c82v25:Name__d9713943(c82v27, c82v28, c82v29)
    c82v25 = v17
    c82v25 = c82v25.ExtraDesc
    if c82v25 ~= nil then
      c82v25 = mMovie
      c82v27 = "Popup.ExtraDesc.Bg"
      c82v28 = _G
      c82v28 = c82v28.UIMaterial_RectangleNoDepth
      c82v25:OverrideMaterial(c82v27, c82v28)
      c82v25 = v61
      c82v25 = c82v25.Background1RGB
      c82v26 = v61
      c82v26 = c82v26.FloatingContentRGB
      c82v27 = mMovie
      c82v29 = "Popup.ExtraDesc.Bg"
      c82v30 = "RectInnerColor"
      c82v31 = c82v25.r
      c82v32 = c82v25.g
      c82v33 = c82v25.b
      c82v34 = 0.2
      c82v27:Name__e243d995(c82v29, c82v30, c82v31, c82v32, c82v33, c82v34)
      c82v27 = mMovie
      c82v29 = "Popup.ExtraDesc.Bg"
      c82v30 = "RectEdgeColor"
      c82v31 = c82v26.r
      c82v32 = c82v26.g
      c82v33 = c82v26.b
      c82v34 = 0.7
      c82v27:Name__e243d995(c82v29, c82v30, c82v31, c82v32, c82v33, c82v34)
      c82v27 = mMovie
      c82v29 = "Popup.ExtraDesc.Icon"
      c82v30 = v17
      c82v30 = c82v30.ExtraDesc
      c82v30 = c82v30.Icon
      c82v27:OverrideTexture(c82v29, c82v30)
      c82v27 = mMovie
      c82v29 = "Popup.ExtraDesc.Icon"
      c82v30 = 11
      c82v31 = v61
      c82v31 = c82v31.FloatingContentHighlight
      c82v27:SetNumberVariable(c82v29, c82v30, c82v31)
      c82v27 = mMovie
      c82v29 = "Popup.ExtraDesc.Title"
      c82v30 = 36
      c82v31 = v17
      c82v31 = c82v31.ExtraDesc
      c82v31 = c82v31.Title
      c82v27:SetStringVariable(c82v29, c82v30, c82v31)
      c82v27 = mMovie
      c82v29 = "Popup.ExtraDesc.Title"
      c82v30 = 44
      c82v31 = v61
      c82v31 = c82v31.FloatingContentHighlight
      c82v27:SetNumberVariable(c82v29, c82v30, c82v31)
      c82v27 = mMovie
      c82v29 = "Popup.ExtraDesc.Desc"
      c82v30 = 36
      c82v31 = v17
      c82v31 = c82v31.ExtraDesc
      c82v31 = c82v31.Desc
      c82v27:SetStringVariable(c82v29, c82v30, c82v31)
      c82v27 = mMovie
      c82v29 = "Popup.ExtraDesc.Desc"
      c82v30 = 44
      c82v31 = v61
      c82v31 = c82v31.Content
      c82v27:SetNumberVariable(c82v29, c82v30, c82v31)
      c82v27 = mMovie
      c82v29 = "Popup.ExtraDesc.Desc"
      c82v30 = 41
      c82v27 = c82v27:GetNumberVariable(c82v29, c82v30)
      c82v28 = mMovie
      c82v30 = "Popup.ExtraDesc.Bg"
      c82v31 = 15
      c82v33 = 50
      c82v32 = c82v27 + c82v33
      c82v28:SetNumberVariable(c82v30, c82v31, c82v32)
      c82v28 = mMovie
      c82v30 = "Popup.ExtraDesc"
      c82v31 = 1
      c82v33 = v21
      c82v32 = c82v33 + 5
      c82v28:SetNumberVariable(c82v30, c82v31, c82v32)
      c82v30 = v21
      c82v29 = c82v30 + c82v27
      c82v30 = 55
      c82v28 = c82v29 + c82v30
      v21 = c82v28
    end
    c82v25 = mMovie
    c82v27 = "Popup.Invasion"
    c82v28 = 13
    c82v30 = v17
    c82v30 = c82v30.SubInvasions
    if c82v30 == nil then
      c82v29 = false
    else
      c82v29 = true
    end
    c82v25:Name__d9713943(c82v27, c82v28, c82v29)
    c82v25 = v17
    c82v25 = c82v25.SubInvasions
    if c82v30 ~= nil then
      c82v26 = v17
      c82v26 = c82v26.SubInvasions
      c82v25 = c82v26[1]
      c82v25 = c82v25.CustomEntry
      c82v26 = v51
      c82v27 = v2
      c82v27 = c82v27.Ternary
      c82v29 = 50
      c82v30 = 75
      c82v27 = c82v27(c82v25, c82v29, c82v30)
      c82v26.mForcedVerticalSeparation = c82v27
      c82v26 = mMovie
      c82v28 = "Popup.Invasion"
      c82v29 = 1
      c82v31 = v21
      c82v32 = v2
      c82v32 = c82v32.Ternary
      c82v34 = -15
      c82v35 = 5
      c82v32 = c82v32(c82v25, c82v34, c82v35)
      c82v30 = c82v31 + c82v32
      c82v26:SetNumberVariable(c82v28, c82v29, c82v30)
      c82v26 = v51
      c82v28 = true
      c82v29 = true
      c82v26:RemoveElements(c82v28, c82v29)
      c82v28 = 1
      c82v29 = v17
      c82v29 = c82v29.SubInvasions
      c82v26 = #c82v29
      c82v27 = 1
      for c82v28 = c82v28, c82v26, c82v27 do
        c82v29 = v51
        c82v32 = v17
        c82v32 = c82v32.SubInvasions
        c82v31 = c82v32[c82v28]
        c82v32 = true
        c82v29:AddElement(c82v31, c82v32)
      end
      c82v26 = v51
      c82v28 = nil
      c82v29 = true
      c82v30 = true
      c82v26:Redraw(c82v28, c82v29, c82v30)
      c82v27 = v21
      c82v29 = v51
      c82v29 = c82v29:GetHowManyElements()
      c82v30 = v51
      c82v30 = c82v30.mForcedVerticalSeparation
      c82v28 = c82v29 * c82v30
      c82v26 = c82v27 + c82v28
      v21 = c82v26
    end
    c82v25 = v17
    c82v25 = c82v25.RarityChances
    if c82v25 ~= nil then
      c82v25 = mMovie
      c82v27 = "Popup.RarityBar"
      c82v28 = 13
      c82v29 = true
      c82v25:Name__d9713943(c82v27, c82v28, c82v29)
      c82v25 = v1
      c82v25 = c82v25.DrawRarityBar
      c82v26 = mMovie
      c82v27 = "Popup.RarityBar"
      c82v28 = v17
      c82v28 = c82v28.RarityChances
      c82v29 = 330
      c82v30 = barMaterial
      c82v31 = 0
      c82v32 = -16
      c82v33 = 10
      c82v35 = v21
      c82v36 = 30
      c82v34 = c82v35 + c82v36
      c82v25(c82v26, c82v27, c82v28, c82v29, c82v30, c82v31, c82v32, c82v33, c82v34)
      c82v26 = v21
      c82v27 = 40
      c82v25 = c82v26 + c82v27
      v21 = c82v25
    else
      c82v25 = mMovie
      c82v27 = "Popup.RarityBar"
      c82v28 = 13
      c82v29 = false
      c82v25:Name__d9713943(c82v27, c82v28, c82v29)
    end
    c82v25 = mMovie
    c82v27 = "Popup.Prerequisite"
    c82v28 = 13
    c82v25:Name__d9713943(c82v27, c82v28, c82v19)
    if c82v25 == nil then
      c82v25 = mMovie
      c82v27 = "Popup.Prerequisite"
      c82v28 = 1
      c82v30 = v21
      c82v31 = 20
      c82v29 = c82v30 + c82v31
      c82v25:SetNumberVariable(c82v27, c82v28, c82v29)
      c82v26 = v21
      c82v27 = 123
      c82v25 = c82v26 + c82v27
      v21 = c82v25
      c82v25 = v17
      c82v25 = c82v25.mPrereqElement
      c82v26 = mMovie
      c82v28 = "Popup.Prerequisite.Icon"
      c82v29 = c82v25.Icon
      c82v26:OverrideTexture(c82v28, c82v29)
      c82v26 = mMovie
      c82v28 = "Popup.Prerequisite.Icon"
      c82v29 = c82v25.Material
      c82v26:OverrideMaterial(c82v28, c82v29)
      c82v26 = mMovie
      c82v28 = "Popup.Prerequisite.Icon"
      c82v29 = 15
      c82v26 = c82v26:GetNumberVariable(c82v28, c82v29)
      c82v27 = c82v25.Themed
      if not c82v27 then
        c82v27 = 1.6
        c82v26 = c82v26 * c82v27
      end
      c82v27 = mMovie
      c82v29 = "Popup.Prerequisite.Icon"
      c82v30 = 14
      c82v27:SetNumberVariable(c82v29, c82v30, c82v26)
      c82v28 = "<p><font color=\""
      c82v29 = v61
      c82v29 = c82v29.FloatingContentHighlightHex
      c82v30 = "\">"
      c82v33 = string.upper
      c82v34 = Localize
      c82v35 = "/Lotus/Language/Dojo/Prerequisite"
      c82v36 = {}
      c82v31 = c82v33(c82v34(c82v35, c82v36))
      c82v32 = "</font></p>"
      c82v27 = c82v28 .. c82v29 .. c82v30 .. c82v31 .. c82v32
      c82v28 = mMovie
      c82v30 = "Popup.Prerequisite.Header"
      c82v31 = 36
      c82v28:SetStringVariable(c82v30, c82v31, c82v27)
      c82v29 = "<p><font color=\""
      c82v30 = v61
      c82v30 = c82v30.FloatingContentHighlightHex
      c82v31 = "\">"
      c82v32 = "<font color=\""
      c82v33 = v61
      c82v33 = c82v33.FloatingContentHex
      c82v34 = "\">"
      c82v37 = TitleCase
      c82v38 = c82v25.Name
      c82v35 = c82v37(c82v38)
      c82v36 = "<br></font>"
      c82v28 = c82v29 .. c82v30 .. c82v31 .. c82v32 .. c82v33 .. c82v34 .. c82v35 .. c82v36
      c82v31 = c82v25.mCompletionDate
      c82v30 = IsNull
      c82v30 = c82v30(c82v31)
      c82v29 = not c82v30
      if c82v29 then
        c82v30 = Engine.Name__b38e1642
        c82v31 = c82v25.mCompletionDate
        c82v30 = c82v30(c82v31)
        c82v31 = 0
        if c82v31 < c82v30 then
          c82v29 = false
        else
          c82v29 = true
        end
      end
      if c82v29 then
        c82v31 = "<font color=\""
        c82v32 = v61
        c82v32 = c82v32.PositiveHex
        c82v33 = "\">"
        c82v37 = mMovie
        c82v39 = "<CHECKMARK_NO_BORDER> "
        c82v40 = true
        c82v34 = c82v37:GetLocalized(c82v39, c82v40)
        c82v35 = "</font>"
        c82v36 = mMovie
        c82v38 = "/Lotus/Language/Categories/RESEARCHED"
        c82v39 = true
        c82v36 = c82v36:GetLocalized(c82v38, c82v39)
        c82v28 = c82v28 .. c82v31 .. c82v32 .. c82v33 .. c82v34 .. c82v35 .. c82v36
      else
        c82v31 = "<font color=\""
        c82v32 = v61
        c82v32 = c82v32.NegativeHex
        c82v33 = "\">"
        c82v37 = mMovie
        c82v39 = "<CHECKMARK_FAIL_NO_BORDER> "
        c82v40 = true
        c82v34 = c82v37:GetLocalized(c82v39, c82v40)
        c82v35 = "</font>"
        c82v36 = mMovie
        c82v38 = "/Lotus/Language/Menu/Profile_ResearchNotStarted"
        c82v39 = true
        c82v36 = c82v36:GetLocalized(c82v38, c82v39)
        c82v28 = c82v28 .. c82v31 .. c82v32 .. c82v33 .. c82v34 .. c82v35 .. c82v36
      end
      c82v31 = "</font></p>"
      c82v28 = c82v28 .. c82v31
      c82v30 = mMovie
      c82v32 = "Popup.Prerequisite.Name"
      c82v33 = 46
      c82v34 = "center"
      c82v30:SetStringVariable(c82v32, c82v33, c82v34)
      c82v30 = mMovie
      c82v32 = "Popup.Prerequisite.Name"
      c82v33 = 36
      c82v30:SetStringVariable(c82v32, c82v33, c82v28)
      c82v30 = mMovie
      c82v32 = "Popup.Prerequisite.Bg"
      c82v33 = 13
      c82v36 = c82v25.Background
      c82v35 = IsNull
      c82v35 = c82v35(c82v36)
      c82v34 = not c82v35
      c82v30:Name__d9713943(c82v32, c82v33, c82v34)
      c82v30 = mMovie
      c82v32 = "Popup.Prerequisite.Bg"
      c82v33 = c82v25.Background
      c82v30:OverrideTexture(c82v32, c82v33)
      c82v30 = mMovie
      c82v32 = "Popup.Prerequisite.Bg"
      c82v33 = 11
      c82v34 = v61
      c82v34 = c82v34.FloatingContent
      c82v30:SetNumberVariable(c82v32, c82v33, c82v34)
      c82v30 = mMovie
      c82v32 = "Popup.Prerequisite.Bg"
      c82v33 = _G
      c82v33 = c82v33.UIMaterial_RectangleNoDepth
      c82v30:OverrideMaterial(c82v32, c82v33)
      c82v30 = mMovie
      c82v32 = "Popup.Prerequisite.Bg"
      c82v33 = "RectEdgeColor"
      c82v34 = 1
      c82v35 = 1
      c82v36 = 1
      c82v37 = 0
      c82v30:Name__e243d995(c82v32, c82v33, c82v34, c82v35, c82v36, c82v37)
      c82v30 = mMovie
      c82v32 = "Popup.Prerequisite.Bg"
      c82v33 = "RectInnerColor"
      c82v34 = 1
      c82v35 = 1
      c82v36 = 1
      c82v37 = 1
      c82v30:Name__e243d995(c82v32, c82v33, c82v34, c82v35, c82v36, c82v37)
      c82v30 = v61
      c82v30 = c82v30.Background1RGB
      c82v31 = v61
      c82v31 = c82v31.BackerHighlightRGB
      c82v32 = mMovie
      c82v34 = "Popup.Prerequisite.Border"
      c82v35 = _G
      c82v35 = c82v35.UIMaterial_RectangleNoDepth
      c82v32:OverrideMaterial(c82v34, c82v35)
      c82v32 = mMovie
      c82v34 = "Popup.Prerequisite.Border"
      c82v35 = "RectEdgeColor"
      c82v36 = c82v31.r
      c82v37 = c82v31.g
      c82v38 = c82v31.b
      c82v39 = 0.2
      c82v32:Name__e243d995(c82v34, c82v35, c82v36, c82v37, c82v38, c82v39)
      c82v32 = mMovie
      c82v34 = "Popup.Prerequisite.Border"
      c82v35 = "RectInnerColor"
      c82v36 = c82v30.r
      c82v37 = c82v30.g
      c82v38 = c82v30.b
      c82v39 = 0.2
      c82v32:Name__e243d995(c82v34, c82v35, c82v36, c82v37, c82v38, c82v39)
    end
    c82v25 = false
    c82v26 = v17
    c82v26 = c82v26.SecondaryDesc
    if c82v26 ~= nil then
      c82v26 = v17
      c82v26 = c82v26.SecondaryDesc
      if c82v26 == "" then
        c82v25 = false
      else
        c82v25 = true
      end
    end
    if c82v25 then
      c82v27 = "<p><font color=\""
      c82v28 = v61
      c82v28 = c82v28.ContentHex
      c82v29 = "\">"
      c82v30 = v17
      c82v30 = c82v30.SecondaryDesc
      c82v31 = "</font></p>"
      c82v26 = c82v27 .. c82v28 .. c82v29 .. c82v30 .. c82v31
      c82v27 = mMovie
      c82v29 = "Popup.PrereqSeparator.Description"
      c82v30 = 36
      c82v27:SetStringVariable(c82v29, c82v30, c82v26)
    end
    c82v26 = c82v25
    if not c82v26 then
      c82v27 = v17
      c82v27 = c82v27.HideRecipe
      c82v26 = not c82v27
      if c82v26 then
        c82v26 = v17
        c82v26 = c82v26.Researched
        if not c82v26 then
          c82v26 = v17
          c82v26 = c82v26.InProgress
          if not c82v26 then
            c82v26 = c82v19
          end
        end
      end
    end
    c82v27 = mMovie
    c82v29 = "Popup.PrereqSeparator"
    c82v30 = 13
    c82v27:Name__d9713943(c82v29, c82v30, c82v26)
    if c82v26 then
      c82v27 = mMovie
      c82v29 = "Popup.PrereqSeparator"
      c82v30 = 1
      c82v32 = v21
      c82v33 = 10
      c82v31 = c82v32 + c82v33
      c82v27:SetNumberVariable(c82v29, c82v30, c82v31)
      c82v29 = v21
      c82v30 = mMovie
      c82v32 = "Popup.PrereqSeparator.Description"
      c82v33 = 41
      c82v30 = c82v30:GetNumberVariable(c82v32, c82v33)
      c82v28 = c82v29 + c82v30
      c82v29 = 21
      c82v27 = c82v28 + c82v29
      v21 = c82v27
    end
    c82v27 = mMovie
    c82v29 = "Popup.Ingredients"
    c82v30 = 13
    c82v27:Name__d9713943(c82v29, c82v30, c82v17)
    c82v27 = mMovie
    c82v29 = "Popup.Ingredients"
    c82v30 = 1
    c82v32 = v21
    c82v33 = 10
    c82v31 = c82v32 + c82v33
    c82v27:SetNumberVariable(c82v29, c82v30, c82v31)
    c82v27 = 0
    c82v28 = ipairs
    c82v29 = v43
    c82v29 = c82v29.mElements
    c82v28, c82v29, c82v30 = c82v28(c82v29)
    for c82v31, c82v32 in c82v28, c82v29, c82v30 do
      c82v33 = c82v27 + 5
      c82v35 = v43
      c82v35 = c82v35.mForcedVerticalSeparation
      c82v37 = c82v32.mHeight
      c82v36 = c82v37 or 0
      c82v34 = math.max
      c82v34 = c82v34(c82v35, c82v36)
      c82v27 = c82v33 + c82v34
    end
    c82v30 = v21
    c82v31 = mMovie
    c82v33 = "Popup.Ingredients.ingredient"
    c82v34 = 1
    c82v31 = c82v31:GetNumberVariable(c82v33, c82v34)
    c82v29 = c82v30 + c82v31
    c82v28 = c82v29 + c82v27
    v21 = c82v28
    for c82v31, c82v32 in c82v28, c82v29, c82v30 do
    end
    c82v27 = c82v17 and c82v18
    c82v28 = mMovie
    c82v30 = "Popup.IngredientsSeparator"
    c82v31 = 13
    c82v28:Name__d9713943(c82v30, c82v31, c82v27)
    if c82v27 then
      c82v28 = mMovie
      c82v30 = "Popup.IngredientsSeparator"
      c82v31 = 1
      c82v33 = v21
      c82v34 = 10
      c82v32 = c82v33 + c82v34
      c82v28:SetNumberVariable(c82v30, c82v31, c82v32)
      c82v30 = v21
      c82v31 = mMovie
      c82v33 = "Popup.IngredientsSeparator.Description"
      c82v34 = 41
      c82v31 = c82v31:GetNumberVariable(c82v33, c82v34)
      c82v29 = c82v30 + c82v31
      c82v30 = 21
      c82v28 = c82v29 + c82v30
      v21 = c82v28
    end
    c82v28 = mMovie
    c82v30 = "Popup.IngredientsSecondary"
    c82v31 = 13
    c82v28:Name__d9713943(c82v30, c82v31, c82v18)
    if not c82v17 then
      c82v28 = mMovie
      c82v30 = "Popup.IngredientsSecondary"
      c82v31 = 1
      c82v33 = v21
      c82v34 = 10
      c82v32 = c82v33 + c82v34
      c82v28:SetNumberVariable(c82v30, c82v31, c82v32)
      c82v28 = 0
      c82v29 = ipairs
      c82v30 = v44
      c82v30 = c82v30.mElements
      c82v29, c82v30, c82v31 = c82v29(c82v30)
      for c82v32, c82v33 in c82v29, c82v30, c82v31 do
        c82v34 = c82v28 + 5
        c82v36 = v44
        c82v36 = c82v36.mForcedVerticalSeparation
        c82v38 = c82v33.mHeight
        c82v37 = c82v38 or 0
        c82v35 = math.max
        c82v35 = c82v35(c82v36, c82v37)
        c82v28 = c82v34 + c82v35
      end
      c82v31 = v21
      c82v32 = mMovie
      c82v34 = "Popup.IngredientsSecondary.ingredient"
      c82v35 = 1
      c82v32 = c82v32:GetNumberVariable(c82v34, c82v35)
      c82v30 = c82v31 + c82v32
      c82v29 = c82v30 + c82v28
      v21 = c82v29
    end
    c82v28 = v17
    c82v28 = c82v28.CustomEntry
    c82v23 = table.sort
    c82v25 = function(c81v0, c81v1)
      local c81v2, c81v3, c81v4, c81v5
      c81v2 = c81v0.Resist
      c81v3 = c81v1.Resist
      if c81v2 ~= c81v3 then
        c81v3 = c81v0.Resist
        c81v4 = c81v1.Resist
        if c81v4 <= c81v3 then
          c81v2 = false
        else
          c81v2 = true
        end
        do return c81v2 end
      end
      c81v3 = string.lower
      c81v4 = c81v0.Name
      c81v3 = c81v3(c81v4)
      c81v4 = string.lower
      c81v5 = c81v1.Name
      c81v4 = c81v4(c81v5)
      if c81v4 <= c81v3 then
        c81v2 = false
      else
        c81v2 = true
      end
      do return c81v2 end
    end
    c82v23(c82v21, c82v25)
    c82v23 = #c82v21
    c82v24 = 0
    c82v24 = "<font color=\""
    c82v25 = v61
    c82v25 = c82v25.FloatingContentHighlightHex
    c82v26 = "\">"
    c82v29 = mMovie
    c82v31 = "/Lotus/Language/Stats/FactionResistsTitle"
    c82v32 = false
    c82v27 = c82v29:GetLocalized(c82v31, c82v32)
    c82v28 = "</font><br>"
    c82v23 = c82v24 .. c82v25 .. c82v26 .. c82v27 .. c82v28
    c82v26 = 1
    c82v24 = #c82v21
    c82v25 = 1
    for c82v26 = c82v26, c82v24, c82v25 do
      c82v36 = v61
      c82v36 = c82v36.PositiveHex
      c82v37 = v61
      c82v37 = c82v37.NegativeHex
      c82v30 = c82v34(c82v35, c82v36, c82v37)
      c82v31 = "\"><b>x"
      c82v34 = c82v27.Resist
      c82v32 = 1 - c82v34
      c82v33 = "</b></font>"
      c82v28 = c82v29 .. c82v30 .. c82v31 .. c82v32 .. c82v33
      c82v32 = mMovie
      c82v34 = "/Lotus/Language/Stats/FactionResistsEntry"
      c82v35 = false
      c82v36 = { VAL = nil, FACTION = nil, OPEN_COLOR = nil, CLOSE_COLOR = "</font>" }
      c82v36.VAL = c82v28
      c82v37 = c82v27.Name
      c82v36.FACTION = c82v37
      c82v38 = "<font color=\""
      c82v39 = v61
      c82v39 = c82v39.FloatingContentHex
      c82v40 = "\">"
      c82v37 = c82v38 .. c82v39 .. c82v40
      c82v36.OPEN_COLOR = c82v37
      c82v30 = c82v32:GetLocalized(c82v34, c82v35, c82v36)
      c82v31 = "<br>"
      c82v23 = c82v23 .. c82v30 .. c82v31
      c82v27 = c82v21[c82v26]
      c82v29 = "<font color=\""
      c82v34 = v2
      c82v34 = c82v34.Ternary
      c82v36 = c82v27.Resist
      c82v37 = 0
      if c82v37 <= c82v36 then
        c82v35 = false
      else
        c82v35 = true
      end
    end
    c82v20 = string.find
    c82v21 = v17
    c82v21 = c82v21.StatId
    c82v22 = "DT_"
    c82v20 = c82v20(c82v21, c82v22)
    c82v20 = v0
    c82v20 = c82v20.GetDamageTypeIndex
    c82v21 = v17
    c82v21 = c82v21.StatId
    c82v20 = c82v20(c82v21)
    c82v21 = {}
    c82v22 = gGameConfig
    c82v25 = false
    c82v22 = c82v22:Name__d18513f7(c82v20, c82v25)
    c82v25 = 20
    c82v23 = 33
    c82v24 = 1
    for c82v25 = c82v25, c82v23, c82v24 do
      c82v27 = c82v25 + 1
      c82v26 = c82v22[c82v27]
      if c82v26 ~= 0 then
        c82v26 = v108
        c82v26 = c82v26(c82v25)
        if c82v26 then
          c82v26 = v0
          c82v26 = c82v26.GetResistTag
          c82v26 = c82v26(c82v25)
          c82v28 = "/Lotus/Language/Stats/ResistKey_"
          c82v27 = c82v28 .. c82v26
          c82v30 = { Name = nil, Resist = nil }
          c82v31 = mMovie
          c82v34 = false
          c82v31 = c82v31:GetLocalized(c82v27, c82v34)
          c82v30.Name = c82v31
          c82v32 = c82v25 + 1
          c82v31 = c82v22[c82v32]
          c82v30.Resist = c82v31
          c82v28 = table.insert
          c82v28(c82v21, c82v30)
        end
      end
    end
    c82v21 = v17
    c82v21 = c82v21.mMod
    c82v20 = IsNull
    c82v20 = c82v20(c82v21)
    c82v20 = v17
    c82v20 = c82v20.ArcaneRank
    c82v20 = v17
    c82v20 = c82v20.ArcaneMaxRank
    c82v20 = v17
    c82v20 = c82v20.ArcaneRank
    c82v24 = c82v23:Name__65a6ff3f(c82v20)
    c82v25 = mMovie
    c82v27 = c82v23:GetEnhancementDescription(c82v24)
    c82v28 = true
    c82v22 = c82v25:GetLocalized(c82v27, c82v28)
    c82v25 = v17
    c82v25 = c82v25.CountTable
    c82v26 = v17
    c82v26 = c82v26.CountTable
    c82v25 = #c82v26
    c82v26 = 0
    c82v29 = c82v25[c82v28]
    if c82v29 ~= 0 then
      c82v30 = " <font color=\""
      c82v31 = v61
      c82v31 = c82v31.FloatingContentHighlightHex
      c82v32 = "\">"
      c82v39 = v1
      c82v39 = c82v39.GetArcaneRankString
      c82v40 = ""
      c82v41 = c82v28 - 1
      c82v42 = v17
      c82v42 = c82v42.ArcaneMaxRank
      c82v43 = mMovie
      c82v33 = c82v39(c82v40, c82v41, c82v42, c82v43)
      c82v34 = "</font> <font color=\""
      c82v35 = v61
      c82v35 = c82v35.FloatingContentHex
      c82v36 = "\">"
      c82v39 = v2
      c82v39 = c82v39.FormatNumber
      c82v40 = c82v25[c82v28]
      c82v37 = c82v39(c82v40)
      c82v38 = "</font>"
      c82v29 = c82v30 .. c82v31 .. c82v32 .. c82v33 .. c82v34 .. c82v35 .. c82v36 .. c82v37 .. c82v38
      c82v31 = v24
      c82v33 = "<br>"
      c82v30 = c82v31 .. c82v29 .. c82v33
      v24 = c82v30
    end
    c82v20 = v17
    c82v20 = c82v20.CompatLabel
    if c82v20 ~= nil then
      c82v21 = v24
      c82v22 = v17
      c82v22 = c82v22.CompatLabel
      c82v23 = "<br><br>"
      c82v20 = c82v21 .. c82v22 .. c82v23
      v24 = c82v20
    end
    c82v21 = v17
    c82v21 = c82v21.ArcaneRank
    c82v22 = 0
    c82v24 = v2
    c82v24 = c82v24.Ternary
    if c82v20 ~= 0 then
      c82v25 = false
    else
      c82v25 = true
    end
    c82v26 = mMovie
    c82v28 = "/Lotus/Language/Ranks/Rank0"
    c82v29 = false
    c82v26 = c82v26:GetLocalized(c82v28, c82v29)
    c82v27 = mMovie
    c82v29 = "/Lotus/Language/Menu/Global_FormattedRankCaps"
    c82v30 = false
    c82v31 = { RANK = nil }
    c82v31.RANK = c82v20
    c82v22 = c82v24(c82v25, c82v26, c82v27:GetLocalized(c82v29, c82v30, c82v31))
    c82v23 = "  "
    c82v21 = c82v22 .. c82v23
    c82v22 = ""
    c82v23 = nil
    c82v25 = v17
    c82v25 = c82v25.Arcane
    c82v24 = IsNull
    c82v24 = c82v24(c82v25)
    if not c82v24 then
      c82v24 = v17
      c82v24 = c82v24.Arcane
      c82v23 = c82v24.mInstance
    else
      c82v24 = IsNull
      c82v24 = c82v24(c82v2)
      if not c82v24 then
        c82v24 = IsNull
        c82v24 = c82v24(c82v2:GetItem())
        if not c82v24 then
          c82v24 = c82v2:GetItem()
          c82v26 = gLotusArtifactUpgradeType
          c82v24 = c82v24:IsA(c82v26)
          if c82v24 then
            c82v24 = Lotus_Game.UpgradeInfo
            c82v24 = c82v24()
            c82v25 = c82v2:GetItem()
            c82v24.mItemType = c82v25
            c82v23 = c82v24.mInstance
          end
        end
      end
    end
    c82v24 = IsNull
    c82v24 = c82v24(c82v23)
    c82v25 = {}
    c82v28 = 1
    c82v29 = v17
    c82v29 = c82v29.ArcaneMaxRank
    c82v26 = c82v29 + 1
    c82v27 = 1
    for c82v28 = c82v28, c82v26, c82v27 do
      c82v31 = 0
      c82v29 = table.insert
      c82v29(c82v25, c82v31)
    end
    c82v28 = 1
    c82v29 = v17
    c82v29 = c82v29.CountTable
    c82v26 = #c82v29
    c82v27 = 1
    for c82v28 = c82v28, c82v26, c82v27 do
      c82v29 = v9
      c82v29 = c82v29.GetArcaneRank
      c82v30 = { mInstance = nil }
      c82v30.mInstance = c82v23
      c82v32 = v17
      c82v32 = c82v32.CountTable
      c82v31 = c82v32[c82v28]
      c82v31 = c82v31.fp
      c82v29 = c82v29(c82v30, c82v31)
      c82v30 = c82v29 + 1
      c82v31 = c82v25[c82v30]
      c82v33 = v17
      c82v33 = c82v33.CountTable
      c82v32 = c82v33[c82v28]
      c82v32 = c82v32.Count
      c82v31 = c82v31 + c82v32
      c82v25[c82v30] = c82v31
    end
    c82v27 = v24
    c82v28 = "<font color=\""
    c82v29 = v61
    c82v29 = c82v29.FloatingContentHighlightHex
    c82v30 = "\">"
    c82v35 = mMovie
    c82v37 = "<OWNED>"
    c82v38 = true
    c82v31 = c82v35:GetLocalized(c82v37, c82v38)
    c82v32 = " "
    c82v35 = mMovie
    c82v37 = "/Lotus/Language/Menu/Store_Owned"
    c82v38 = false
    c82v33 = c82v35:GetLocalized(c82v37, c82v38)
    c82v34 = "</font><br>"
    c82v26 = c82v27 .. c82v28 .. c82v29 .. c82v30 .. c82v31 .. c82v32 .. c82v33 .. c82v34
    v24 = c82v26
    c82v28 = 1
    c82v26 = #c82v25
    c82v27 = 1
    local c753 = -1
    repeat
      c82v26 = c82v16[c82v20]
      c82v28 = c82v25 - 1
      c82v26 = c82v26:Name__1beb0183(c82v28)
      if c82v26 == 0.01 then
        c82v26 = 0
      end
      c82v27 = "/Lotus/Language/Melee/ComboAttack"
      c82v28 = c82v16[c82v20]
      c82v30 = c82v25 - 1
      c82v28 = c82v28:Name__8418dab6(c82v30)
      c82v29 = tostring
      c82v29 = c82v29(c82v28)
      if c82v29 ~= "" then
        c82v27 = "/Lotus/Language/Melee/ComboSlam"
      end
      c82v30 = v24
      c82v31 = "    "
      c82v32 = mMovie
      c82v35 = false
      c82v36 = { OPEN_COLOR = nil, VALUE = nil, CLOSE_COLOR = "</font>" }
      c82v36.OPEN_COLOR = c82v17
      c82v37 = v2
      c82v37 = c82v37.FormatNumber
      c82v39 = 100
      c82v38 = c82v39 * c82v26
      c82v37 = c82v37(c82v38)
      c82v36.VALUE = c82v37
      c82v32 = c82v32:GetLocalized(c82v27, c82v35, c82v36)
      c82v29 = c82v30 .. c82v31 .. c82v32
      v24 = c82v29
      c82v31 = 0
      c82v32 = 30
      c82v29 = c82v32 - 1
      c82v30 = 1
      for c82v31 = c82v31, c82v29, c82v30 do
        c82v32 = c82v16[c82v20]
        c82v34 = c82v25 - 1
        c82v35 = false
        c82v32 = c82v32:Name__4be70667(c82v34, c82v35, c82v31)
        if c82v32 then
          c82v33 = v24
          c82v34 = " + "
          c82v35 = mMovie
          c82v38 = "<"
          c82v41 = v0
          c82v41 = c82v41.GetProcTypeTag
          c82v39 = c82v41(c82v31)
          c82v40 = ">"
          c82v37 = c82v38 .. c82v39 .. c82v40
          c82v38 = true
          c82v35 = c82v35:GetLocalized(c82v37, c82v38)
          c82v32 = c82v33 .. c82v34 .. c82v35
          v24 = c82v32
        end
      end
      if c753 ~= -1 then break end
      c82v16 = v17
      c82v16 = c82v16.mMeleeSet
      c82v16 = c82v16:GetAttacks()
      c82v17 = v17
      c82v17 = c82v17.mMeleeCallouts
      if c82v17 == nil then
        c82v17 = v17
        c82v18 = {}
        c82v17.mMeleeCallouts = c82v18
      end
      c82v18 = "<font color=\""
      c82v19 = v61
      c82v19 = c82v19.FloatingContentHighlightHex
      c82v20 = "\">"
      c82v17 = c82v18 .. c82v19 .. c82v20
      c82v20 = 1
      c82v18 = #c82v16
      c82v19 = 1
      c82v30 = v24
      c82v31 = v2
      c82v31 = c82v31.Ternary
      if c82v25 ~= c82v22 then
        c82v32 = false
      else
        c82v32 = true
      end
      c82v33 = ""
      c82v34 = "<br>"
      c82v31 = c82v31(c82v32, c82v33, c82v34)
      c82v29 = c82v30 .. c82v31
      v24 = c82v29
      c82v24 = v24
      c82v25 = v2
      c82v25 = c82v25.Ternary
      c82v27 = #c82v16
      if c82v20 ~= c82v27 then
        c82v26 = false
      else
        c82v26 = true
      end
      c82v27 = ""
      c82v28 = "<br><br>"
      c82v25 = c82v25(c82v26, c82v27, c82v28)
      c82v23 = c82v24 .. c82v25
      v24 = c82v23
      c82v21 = ""
      c82v23 = v17
      c82v23 = c82v23.mMeleeCallouts
      c82v22 = c82v23[c82v20]
      if c82v22 ~= nil then
        c82v23 = v17
        c82v23 = c82v23.mMeleeCallouts
        c82v22 = c82v23[c82v20]
        if not ((not ((c82v22 == "<MELEE>" or c82v22 == "<AIM_WEAPON>")) and c82v22 ~= "<MELEE_CHANNEL>")) then
          c82v23 = mMovie
          c82v25 = "/Lotus/Language/Melee/ComboBtnPress"
          c82v26 = true
          c82v27 = { ACTION = nil }
          c82v27.ACTION = c82v22
          c82v22 = c82v23:GetLocalized(c82v25, c82v26, c82v27)
        else
          c82v23 = mMovie
          c82v26 = true
          c82v22 = c82v23:GetLocalized(c82v22, c82v26)
        end
        c82v24 = "<br>"
        c82v21 = c82v22 .. c82v24
      end
      c82v23 = v24
      c82v22 = c82v23 .. c82v21
      v24 = c82v22
      c82v23 = 1
      c82v24 = c82v16[c82v20]
      c82v22 = math.max
      c82v22 = c82v22(c82v23, c82v24:Name__dab108e3())
      c82v25 = 1
      c82v23 = c82v22
      c82v24 = 1
      c82v21 = c82v20.ExcludeFromInfoPopup
      c82v21 = ""
      c82v22 = false
      c82v23 = c82v20.Type
      c82v24 = v1
      c82v24 = c82v24.LABEL_TYPE_UGC
      c82v23 = c82v20.RightAlign
      c82v22 = not c82v15
      c82v22 = true
      c82v23 = c82v20.Type
      c82v24 = v1
      c82v24 = c82v24.LABEL_TYPE_FAVORITE
      c82v22 = not c82v15
      if c82v22 then
        c82v23 = c82v20.UseFullLabel
        c82v22 = not c82v23
      end
      c82v20.RightAlignPopup = c82v22
      if c82v22 then
        c82v23 = c82v20.Type
        c82v24 = v1
        c82v24 = c82v24.LABEL_TYPE_REUSABLE_BLUEPRINT
        if c82v23 == c82v24 then
          c82v13 = true
          if c82v14 ~= 1 then
            c82v23 = ""
            c82v20.Name = c82v23
          end
        else
          c82v23 = c82v20.Type
          c82v24 = v1
          c82v24 = c82v24.LABEL_TYPE_RIGHT_TEXT
          if not ((c82v23 == c82v24 or c82v14 == 1)) then
            c82v23 = ""
            c82v20.Name = c82v23
          end
        end
      else
        c82v23 = c82v20.PopUpLabel
        if c82v23 ~= nil then
          c82v23 = mMovie
          c82v25 = c82v20.PopUpLabel
          c82v26 = true
          c82v23 = c82v23:GetLocalized(c82v25, c82v26)
          c82v20.Name = c82v23
        end
      end
      c82v23 = v1
      c82v23 = c82v23.GetPriceLabelClip
      c82v24 = mMovie
      c82v25 = "Popup"
      c82v21, c82v1 = c82v23(c82v24, c82v25, c82v1)
      if not c82v22 then
        c82v23 = true
        c82v20.FitText = c82v23
        c82v24 = v22
        c82v25 = v28
        c82v23 = c82v24 - c82v25
        c82v20.MaxWidth = c82v23
      end
      c82v23 = c82v20.LabelPrefix
      if c82v23 == "<PRIME_TOKEN>" then
        c82v23 = 0
        c82v20.LabelOffset = c82v23
      end
      c82v23 = v1
      c82v23 = c82v23.DrawPriceLabel
      c82v24 = mMovie
      c82v23(c82v24, c82v21, c82v20)
      c82v20.ClipName = c82v21
      c82v24 = mMovie
      c82v28 = ".Label"
      c82v26 = c82v21 .. c82v28
      c82v27 = 41
      c82v24 = c82v24:GetNumberVariable(c82v26, c82v27)
      c82v25 = v2
      c82v25 = c82v25.Ternary
      c82v27 = c82v20.TagBuffer
      if c82v27 ~= nil then
        c82v26 = false
      else
        c82v26 = true
      end
      c82v27 = 13
      c82v28 = c82v20.TagBuffer
      c82v25 = c82v25(c82v26, c82v27, c82v28)
      c82v23 = c82v24 + c82v25
      if c82v22 then
        c82v25 = mMovie
        c82v29 = ".IconText"
        c82v27 = c82v21 .. c82v29
        c82v28 = 40
        c82v25 = c82v25:GetNumberVariable(c82v27, c82v28)
        c82v24 = c82v25 or 0
        c82v25 = 0
        if c82v25 < c82v24 then
          c82v25 = c82v12 - c82v24
          c82v12 = c82v25 + 5
        end
        c82v25 = mMovie
        c82v28 = 1
        c82v29 = 0
        c82v25:SetNumberVariable(c82v21, c82v28, c82v29)
        c82v25 = mMovie
        c82v28 = 0
        c82v25:SetNumberVariable(c82v21, c82v28, c82v12)
        c82v12 = c82v12 + -32
        c82v25 = 0
        if c82v24 <= c82v25 then
          c82v25 = math.max
          c82v11 = c82v25(c82v11, c82v23)
        end
      else
        c82v24 = mMovie
        c82v27 = 1
        c82v24:SetNumberVariable(c82v21, c82v27, c82v11)
        c82v11 = c82v11 + c82v23
        c82v15 = false
      end
      local p737 = 0
      if p737 == 0 then
        c82v9 = v1
        c82v9 = c82v9.GetGridItemName
        c82v10 = mMovie
        c82v12 = v17
        c82v13 = v17
        c82v13 = c82v13.MetaData
        c82v9, c82v10 = c82v9(c82v10, c82v0, c82v12, c82v13)
        c82v11 = {}
        v26 = c82v11
        c82v11 = v17
        c82v11 = c82v11.CustomEntry
        if not c82v11 then
          p737 = 3
        else
          p737 = 1
        end
      end
      if p737 == 1 then
        c82v12 = v17
        c82v12 = c82v12.Tags
        c82v11 = IsNull
        c82v11 = c82v11(c82v12)
        if c82v11 then
          p737 = 3
        else
          p737 = 2
        end
      end
      if p737 == 2 then
        c82v11 = v17
        c82v11 = c82v11.Tags
        v26 = c82v11
        p737 = 7
      end
      if p737 == 3 then
        c82v11 = v17
        c82v11 = c82v11.ShowInfoPopupOwned
        if not c82v11 then
          p737 = 6
        else
          p737 = 4
        end
      end
      if p737 == 4 then
        c82v11 = v17
        c82v11 = c82v11.MetaData
        if not c82v11 then
          p737 = 6
        else
          p737 = 5
        end
      end
      if p737 == 5 then
        c82v11 = v17
        c82v11 = c82v11.MetaData
        c82v12 = nil
        c82v11.HideOwned = c82v12
        c82v11 = v17
        c82v11 = c82v11.MetaData
        c82v12 = 0
        c82v11.HideCountThreshold = c82v12
        c82v11 = v17
        c82v11 = c82v11.MetaData
        c82v12 = { TagOverride = "/Lotus/Language/Menu/Crafting_Owned_Icon_Label", mShowOne = true }
        c82v11.OwnedInfo = c82v12
        p737 = 6
      end
      if p737 == 6 then
        c82v11 = v1
        c82v11 = c82v11.GetGridItemTags
        c82v12 = mMovie
        c82v14 = v17
        c82v15 = v17
        c82v15 = c82v15.MetaData
        c82v11 = c82v11(c82v12, c82v0, c82v14, c82v15, c82v10)
        v26 = c82v11
        p737 = 7
      end
      if p737 == 7 then
        c82v11 = mMovie
        c82v13 = "Popup.TagContainer"
        c82v14 = 1
        c82v15 = v21
        c82v11:SetNumberVariable(c82v13, c82v14, c82v15)
        c82v11 = 0
        c82v12 = 300
        c82v13 = false
        c82v14 = 0
        c82v15 = ipairs
        c82v16 = v26
        c82v15, c82v16, c82v17 = c82v15(c82v16)
        for c82v18, c82v19 in c82v15, c82v16, c82v17 do
          c82v20 = c82v19.ExcludeFromInfoPopup
          if not c82v20 then
            c82v14 = c82v14 + 1
          end
        end
        if c753 ~= -1 then break end
        c82v15 = true
        c82v16 = ipairs
        c82v17 = v26
        c82v16, c82v17, c82v18 = c82v16(c82v17)
        for c82v19, c82v20 in c82v16, c82v17, c82v18 do
          c82v21 = c82v20.ExcludeFromInfoPopup
          if not c82v21 then
            c82v21 = c82v20.UseFullLabel
            if not c82v21 then
              c82v22 = v28
              c82v21 = c82v22 + 35
              v28 = c82v21
            end
          end
        end
        if c753 ~= -1 then break end
        c82v16 = ipairs
        c82v17 = v26
        c82v16, c82v17, c82v18 = c82v16(c82v17)
      end
      for c82v18, c82v19 in c82v15, c82v16, c82v17 do
      end
      if c753 ~= -1 then break end
      if c82v11 == 0 then
        c82v16 = 0
        if c82v16 < c82v14 then
          c82v11 = 30
        end
      end
      c82v17 = v21
      c82v16 = c82v17 + c82v11
      v21 = c82v16
      c82v16 = v17
      c82v16 = c82v16.NotOwned
      if c82v11 ~= 0 then
        c82v16 = IsNull
        c82v16 = c82v16(c82v2)
        if not c82v16 then
          c82v16 = mMovie
          c82v18 = c82v2:DestroyactionBtn()
          c82v18 = c82v18:c_str()
          c82v19 = true
          c82v16 = c82v16:GetLocalized(c82v18, c82v19)
          if c82v16 ~= "" then
            c82v17 = v24
            if c82v17 ~= "" then
              c82v18 = v24
              c82v19 = "\r\n\r\n"
              c82v17 = c82v18 .. c82v19
              v24 = c82v17
            end
            c82v18 = v24
            c82v20 = "\r\n\r\n"
            c82v17 = c82v18 .. c82v16 .. c82v20
            v24 = c82v17
          end
        end
      end
      c82v16 = v17
      c82v16 = c82v16.ArcaneCategory
      if c82v16 ~= nil then
        c82v16 = v0
        c82v16 = c82v16.GetArcaneSlotRequirementMessage
        c82v17 = v17
        c82v17 = c82v17.ArcaneCategory
        c82v16, c82v17 = c82v16(c82v17)
        c82v19 = v24
        c82v22 = Localize
        c82v24 = { ITEM = nil }
        c82v24.ITEM = c82v17
        c82v20 = c82v22(c82v16, c82v24)
        c82v21 = "\r\n\r\n"
        c82v18 = c82v19 .. c82v20 .. c82v21
        v24 = c82v18
      end
      c82v16 = v17
      c82v16 = c82v16.NextSuitLevel
      if c82v16 == nil then
        c82v16 = TitleCase
        c82v17 = mMovie
        c82v19 = "/Lotus/Language/Menu/Global_FormattedRankCaps"
        c82v20 = true
        c82v21 = { RANK = nil }
        c82v22 = v17
        c82v22 = c82v22.NextSuitLevel
        c82v21.RANK = c82v22
        c82v16 = c82v16(c82v17:GetLocalized(c82v19, c82v20, c82v21))
        c82v17 = "<font color=\""
        c82v18 = v61
        c82v18 = c82v18.ContentHex
        c82v19 = "\">"
        c82v21 = "</font>"
        c82v16 = c82v17 .. c82v18 .. c82v19 .. c82v16 .. c82v21
        c82v17 = v17
        c82v17 = c82v17.Locked
        if c82v17 then
          c82v18 = v24
          c82v21 = mMovie
          c82v23 = "/Lotus/Language/Suits/AbilityUnlockedAt"
          c82v24 = true
          c82v25 = { RANK = nil }
          c82v25.RANK = c82v16
          c82v19 = c82v21:GetLocalized(c82v23, c82v24, c82v25)
          c82v20 = "\r\n\r\n"
          c82v17 = c82v18 .. c82v19 .. c82v20
          v24 = c82v17
        else
          c82v18 = v24
          c82v21 = mMovie
          c82v23 = "/Lotus/Language/Suits/AbilityUpgradeAt"
          c82v24 = true
          c82v25 = { RANK = nil }
          c82v25.RANK = c82v16
          c82v19 = c82v21:GetLocalized(c82v23, c82v24, c82v25)
          c82v20 = "\r\n\r\n"
          c82v17 = c82v18 .. c82v19 .. c82v20
          v24 = c82v17
        end
        c82v18 = "<font color=\""
        c82v19 = v61
        c82v19 = c82v19.FloatingContentHex
        c82v20 = "\">"
        c82v21 = v24
        c82v22 = "</font>"
        c82v17 = c82v18 .. c82v19 .. c82v20 .. c82v21 .. c82v22
        v24 = c82v17
      end
      c82v17 = v17
      c82v17 = c82v17.Hints
      c82v16 = #c82v17
      c82v17 = 0
      if c82v17 < c82v16 then
        c82v17 = v24
        c82v19 = v17
        c82v19 = c82v19.Hints
        c82v21 = v18
        c82v21 = c82v21.mCurrentElementIndex
        c82v20 = c82v21 or 1
        c82v18 = c82v19[c82v20]
        c82v16 = c82v17 .. c82v18
        v24 = c82v16
      end
      c82v17 = v17
      c82v17 = c82v17.mMeleeSet
      c82v16 = IsNull
      c82v16 = c82v16(c82v17)
      c82v16 = nil
      c82v17 = IsNull
      c82v17 = c82v17(c82v2)
      if not c82v17 then
        c82v16 = c82v2:GetItem()
      end
      c82v17 = v17
      c82v17 = c82v17.SkipDesc
      if c82v17 then
        local p738 = 97
        if p738 == 97 then
          c82v17 = IsNull
          c82v17 = c82v17(c82v16)
          if c82v17 then
            p738 = 100
          else
            p738 = 98
          end
        end
        if p738 == 98 then
          c82v19 = gVoidProjectionItemType
          c82v17 = c82v16:IsA(c82v19)
          if not c82v17 then
            p738 = 100
          else
            p738 = 99
          end
        end
        if p738 == 99 then
          c82v19 = WeakResource
          c82v20 = "/Lotus/Types/Game/Projections/T5VoidProjectionImmortal"
          c82v17 = c82v16:IsA(c82v19(c82v20))
          c82v18 = v104
          c82v18(c82v17)
          c82v19 = v24
          c82v20 = v4
          c82v20 = c82v20.GetRelicInfo
          c82v21 = mMovie
          c82v23 = true
          c82v24 = v45
          c82v20 = c82v20(c82v21, c82v2, c82v23, c82v24)
          c82v18 = c82v19 .. c82v20
          v24 = c82v18
        end
        if p738 == 100 then
          if not c82v13 then
            p738 = 102
          else
            p738 = 101
          end
        end
        if p738 == 101 then
          c82v22 = mMovie
          c82v24 = "/Lotus/Language/Menu/Blueprint_UnlimitedCharges"
          c82v25 = true
          c82v18 = c82v22:GetLocalized(c82v24, c82v25)
          c82v19 = "<br>"
          c82v20 = v24
          c82v21 = mMovie
          c82v23 = v17
          c82v23 = c82v23.Description
          c82v24 = false
          c82v21 = c82v21:GetLocalized(c82v23, c82v24)
          c82v17 = c82v18 .. c82v19 .. c82v20 .. c82v21
          v24 = c82v17
        end
        if p738 == 102 then
          c82v18 = v17
          c82v18 = c82v18.mMod
          c82v17 = IsNull
          c82v17 = c82v17(c82v18)
          if not c82v17 then
          else
            p738 = 103
          end
        end
        if p738 == 103 then
          c82v17 = v2
          c82v17 = c82v17.Ternary
          c82v19 = v17
          c82v19 = c82v19.LocalizedDesc
          if c82v19 ~= nil then
            p738 = 105
          else
            p738 = 104
          end
        end
        if p738 == 104 then
          c82v18 = false
          p738 = 106
        end
        if p738 == 105 then
          c82v18 = true
          p738 = 106
        end
        if p738 == 106 then
          c82v19 = v17
          c82v19 = c82v19.LocalizedDesc
          c82v20 = mMovie
          c82v22 = v17
          c82v22 = c82v22.Description
          c82v23 = false
          c82v17 = c82v17(c82v18, c82v19, c82v20:GetLocalized(c82v22, c82v23))
          c82v19 = v24
          c82v18 = c82v19 .. c82v17
          v24 = c82v18
        end
      end
      c82v18 = v17
      c82v18 = c82v18.MergeDesc
      c82v17 = #c82v18
      c82v18 = 0
      if c82v18 < c82v17 then
        c82v18 = v24
        c82v17 = #c82v18
        c82v18 = 0
        if c82v18 < c82v17 then
          c82v18 = v24
          c82v19 = "<br><br>"
          c82v17 = c82v18 .. c82v19
          v24 = c82v17
        end
        c82v18 = v24
        c82v19 = v17
        c82v19 = c82v19.MergeDesc
        c82v17 = c82v18 .. c82v19
        v24 = c82v17
      end
      c82v18 = v17
      c82v18 = c82v18.ListItems
      c82v17 = #c82v18
      c82v18 = 0
      c82v17 = ""
      c82v18 = ipairs
      c82v19 = v17
      c82v19 = c82v19.ListItems
      c82v18, c82v19, c82v20 = c82v18(c82v19)
      for c82v21, c82v22 in c82v18, c82v19, c82v20 do
        c82v24 = c82v22.Label
        c82v23 = #c82v24
        c82v24 = 0
        if c82v24 < c82v23 then
          c82v23 = #c82v17
          c82v24 = 0
          if c82v24 < c82v23 then
            c82v24 = "<br>"
            c82v17 = c82v17 .. c82v24
          end
          c82v24 = c82v22.Label
          c82v17 = c82v17 .. c82v24
        end
        c82v24 = c82v22.Desc
        c82v23 = #c82v24
        c82v24 = 0
        if c82v24 < c82v23 then
          c82v24 = "<font color=\""
          c82v25 = v61
          c82v25 = c82v25.ContentHex
          c82v26 = "\">"
          c82v17 = c82v17 .. c82v24 .. c82v25 .. c82v26
          c82v25 = 1
          c82v26 = c82v22.Desc
          c82v23 = #c82v26
          c82v24 = 1
          for c82v25 = c82v25, c82v23, c82v24 do
            c82v27 = "<br>     "
            c82v29 = c82v22.Desc
            c82v28 = c82v29[c82v25]
            c82v17 = c82v17 .. c82v27 .. c82v28
          end
          if c753 ~= -1 then break end
          c82v24 = "</font>"
          c82v17 = c82v17 .. c82v24
        end
      end
      if c753 ~= -1 then break end
      c82v18 = #c82v17
      c82v19 = 0
      if c82v19 < c82v18 then
        c82v19 = v24
        c82v18 = #c82v19
        c82v19 = 0
        if c82v19 < c82v18 then
          c82v19 = v24
          c82v20 = "<br><br>"
          c82v18 = c82v19 .. c82v20
          v24 = c82v18
        end
        c82v19 = v24
        c82v20 = "<font color=\""
        c82v21 = v61
        c82v21 = c82v21.FloatingContentHex
        c82v22 = "\">"
        c82v24 = "</font>"
        c82v18 = c82v19 .. c82v20 .. c82v21 .. c82v22 .. c82v17 .. c82v24
        v24 = c82v18
      end
      for c82v21, c82v22 in c82v18, c82v19, c82v20 do
      end
      if c753 ~= -1 then break end
      c82v17 = v17
      c82v17 = c82v17.SalvageTimeRemaining
      if c82v17 ~= nil then
        c82v17 = Engine.Name__b38e1642
        c82v18 = v17
        c82v18 = c82v18.SalvageTimeRemaining
        c82v17 = c82v17(c82v18)
        c82v18 = 0
        if c82v18 < c82v17 then
          c82v18 = v0
          c82v18 = c82v18.GetTwitterStyleTime
          c82v20 = true
          c82v21 = true
          c82v18 = c82v18(c82v17, c82v20, c82v21)
          c82v19 = mMovie
          c82v21 = "/Lotus/Language/Railjack/SalvageTimeRemaining"
          c82v22 = true
          c82v23 = { REPAIR_TIME = nil }
          c82v23.REPAIR_TIME = c82v18
          c82v19 = c82v19:GetLocalized(c82v21, c82v22, c82v23)
          c82v21 = "<font color=\""
          c82v22 = v61
          c82v22 = c82v22.FloatingContentHex
          c82v23 = "\">"
          c82v25 = "</font>"
          c82v26 = "<br>"
          c82v27 = v24
          c82v20 = c82v21 .. c82v22 .. c82v23 .. c82v19 .. c82v25 .. c82v26 .. c82v27
          v24 = c82v20
        else
          c82v19 = "<font color=\""
          c82v20 = v61
          c82v20 = c82v20.FloatingContentHex
          c82v21 = "\">"
          c82v26 = mMovie
          c82v28 = "/Lotus/Language/Railjack/SalvageReadyToClaim"
          c82v29 = true
          c82v22 = c82v26:GetLocalized(c82v28, c82v29)
          c82v23 = "</font>"
          c82v24 = "<br>"
          c82v25 = v24
          c82v18 = c82v19 .. c82v20 .. c82v21 .. c82v22 .. c82v23 .. c82v24 .. c82v25
          v24 = c82v18
        end
      end
      c82v17 = v17
      c82v17 = c82v17.ShowDucatTag
      if c82v17 == nil then
        c82v17 = IsNull
        c82v17 = c82v17(c82v2)
        if not c82v17 then
          c82v17 = v17
          c82v18 = c82v2:Name__2159a733()
          c82v17.PrimePrice = c82v18
        end
        c82v17 = v17
        c82v17 = c82v17.PrimePrice
        if c82v17 then
          c82v17 = v17
          c82v17 = c82v17.PrimePrice
          c82v18 = 0
          if c82v18 < c82v17 then
            c82v17 = v24
            if c82v17 ~= "" then
              c82v18 = v24
              c82v19 = "<br><br>"
              c82v17 = c82v18 .. c82v19
              v24 = c82v17
            end
            c82v18 = v24
            c82v19 = mMovie
            c82v21 = "/Lotus/Language/Menu/Global_ValuePrimeBucks"
            c82v22 = true
            c82v23 = { COST = nil }
            c82v24 = v17
            c82v24 = c82v24.PrimePrice
            c82v23.COST = c82v24
            c82v19 = c82v19:GetLocalized(c82v21, c82v22, c82v23)
            c82v17 = c82v18 .. c82v19
            v24 = c82v17
          end
        end
      end
      c82v17 = v24
      if not ((c82v17 == "" or c82v3 == "")) then
        c82v18 = v24
        c82v17 = string.len
        c82v17 = c82v17(c82v18)
        v27 = c82v17
      end
      c82v17 = false
      c82v18 = false
      c82v19 = false
      c82v20 = v17
      c82v20 = c82v20.IngredientOverride
      if c82v20 == nil then
        c753 = 145
      else
        c753 = 142
      end
      do break end
      break
    until true
    if c753 == 142 then
      c82v17 = true
      c82v20 = v43
      c82v22 = true
      c82v23 = true
      c82v20:RemoveElements(c82v22, c82v23)
      c82v22 = 1
      c82v23 = v17
      c82v23 = c82v23.IngredientOverride
      c82v20 = #c82v23
      c82v21 = 1
      for c82v22 = c82v22, c82v20, c82v21 do
        c82v23 = v43
        c82v26 = v17
        c82v26 = c82v26.IngredientOverride
        c82v25 = c82v26[c82v22]
        c82v26 = true
        c82v23:AddElement(c82v25, c82v26)
      end
      c82v20 = v43
      c82v22 = nil
      c82v23 = nil
      c82v24 = true
      c82v20:Redraw(c82v22, c82v23, c82v24)
    elseif c753 == 145 then
      local p752 = 145
      if p752 == 145 then
        c82v20 = IsNull
        c82v20 = c82v20(c82v2)
        if c82v20 then
          p752 = 202
        else
          p752 = 146
        end
      end
      if p752 == 146 then
        c82v22 = gRecipeStoreItemType
        c82v20 = c82v2:IsA(c82v22)
        if not c82v20 then
          p752 = 202
        else
          p752 = 147
        end
      end
      if p752 == 147 then
        c82v20 = v17
        c82v20 = c82v20.HideRecipe
        if c82v20 then
          p752 = 202
        else
          p752 = 148
        end
      end
      if p752 == 148 then
        c82v21 = _T
        c82v23 = "InfoPopup_Data"
        c82v24 = v59
        c82v22 = c82v23 .. c82v24
        c82v20 = c82v21[c82v22]
        if not c82v20 then
          p752 = 178
        else
          p752 = 149
        end
      end
      if p752 == 149 then
        c82v21 = c82v20.NumPortals
        if c82v21 == nil then
          p752 = 178
        else
          p752 = 150
        end
      end
      if p752 == 150 then
        c82v22 = _T.DojoMgr
        c82v21 = IsNull
        c82v21 = c82v21(c82v22)
        if c82v21 then
          p752 = 178
        else
          p752 = 151
        end
      end
      if p752 == 151 then
        c82v21 = c82v20.Recipe
        c82v21 = c82v21:Name__b7a123a6()
        c82v23 = c82v20.NumPortals
        if c82v23 == 1 then
          p752 = 153
        else
          p752 = 152
        end
      end
      if p752 == 152 then
        c82v22 = mMovie
        c82v24 = "/Lotus/Language/Dojo/NumberOfDoors"
        c82v25 = false
        c82v26 = { DOORS = nil }
        c82v27 = c82v20.NumPortals
        c82v26.DOORS = c82v27
        c82v22 = c82v22:GetLocalized(c82v24, c82v25, c82v26)
        if c82v22 then
          p752 = 154
        else
          p752 = 153
        end
      end
      if p752 == 153 then
        c82v22 = mMovie
        c82v24 = "/Lotus/Language/Dojo/OneDoor"
        c82v25 = false
        c82v26 = nil
        c82v22 = c82v22:GetLocalized(c82v24, c82v25, c82v26)
        p752 = 154
      end
      if p752 == 154 then
        c82v23 = c82v20.NumPortals
        c82v24 = 1
        if c82v23 <= c82v24 then
          c82v24 = " / "
          c82v25 = mMovie
          c82v27 = "/Lotus/Language/Dojo/DeadEndWarning"
          c82v28 = false
          c82v29 = nil
          c82v25 = c82v25:GetLocalized(c82v27, c82v28, c82v29)
          c82v22 = c82v22 .. c82v24 .. c82v25
        end
        c82v23 = 0
        if c82v23 < c82v21 then
          c82v24 = "/Lotus/Language/Clan/Tier"
          c82v26 = "Name"
          c82v23 = c82v24 .. c82v21 .. c82v26
          c82v24 = { TierClanSize = nil, TierName = nil }
          c82v25 = gGameConfig
          c82v25 = c82v25:Name__55bcce29(c82v21)
          c82v24.TierClanSize = c82v25
          c82v25 = mMovie
          c82v28 = false
          c82v25 = c82v25:GetLocalized(c82v23, c82v28)
          c82v24.TierName = c82v25
          c82v25 = mMovie
          c82v27 = c82v20.Recipe
          c82v27 = c82v27:GetLocalizeDescTag()
          c82v27 = c82v27:c_str()
          c82v28 = true
          c82v25 = c82v25:GetLocalized(c82v27, c82v28, c82v24)
          v24 = c82v25
        end
        c82v24 = "<font color=\""
        c82v25 = v61
        c82v25 = c82v25.FloatingContentHighlightHex
        c82v26 = "\">"
        c82v28 = "</font>"
        c82v29 = "<br>"
        c82v30 = v24
        c82v31 = "<br><br><font color=\""
        c82v32 = v61
        c82v32 = c82v32.FloatingContentHighlightHex
        c82v33 = "\">"
        c82v36 = mMovie
        c82v38 = "/Lotus/Language/Dojo/RequireLabel"
        c82v39 = true
        c82v34 = c82v36:GetLocalized(c82v38, c82v39)
        c82v35 = "<br></font>"
        c82v23 = c82v24 .. c82v25 .. c82v26 .. c82v22 .. c82v28 .. c82v29 .. c82v30 .. c82v31 .. c82v32 .. c82v33 .. c82v34 .. c82v35
        v24 = c82v23
        c82v23 = gGameRules
        c82v23 = c82v23:GetDojoRecipeManifest()
        c82v24 = gGameRules
        c82v24 = c82v24:GetStoreManifest()
        c82v25 = c82v20.Recipe
        c82v25 = c82v25:GetPrerequisites()
        c82v17 = true
        c82v26 = v43
        c82v28 = true
        c82v29 = true
        c82v26:RemoveElements(c82v28, c82v29)
        c82v26 = IsNull
        c82v26 = c82v26(c82v25)
        if c82v24 < c82v23 then
          c82v26 = #c82v25
          c82v27 = 0
          if c82v27 < c82v26 then
            c82v28 = 1
            c82v26 = #c82v25
            c82v27 = 1
            for c82v28 = c82v28, c82v26, c82v27 do
              c82v29 = c82v25[c82v28]
              c82v32 = 1
              c82v30 = #c82v29
              c82v31 = 1
              for c82v32 = c82v32, c82v30, c82v31 do
                c82v34 = c82v29[c82v32]
                c82v33 = IsNull
                c82v33 = c82v33(c82v34)
                if not c82v33 then
                  c82v35 = c82v29[c82v32]
                  c82v33 = c82v23:Name__b7399832(c82v35)
                  c82v34 = IsNull
                  c82v34 = c82v34(c82v33)
                  if not c82v34 then
                    c82v36 = WeakResource
                    c82v34 = c82v24:GetStoreItem(c82v36(c82v33:GetFullName()))
                    c82v35 = v4
                    c82v35 = c82v35.GetStoreItemInfo
                    c82v36 = mMovie
                    c82v38 = nil
                    c82v39 = nil
                    c82v40 = nil
                    c82v41 = true
                    c82v35 = c82v35(c82v36, c82v34, c82v38, c82v39, c82v40, c82v41)
                    c82v36 = true
                    c82v35.HideCount = c82v36
                    c82v36 = 1
                    c82v35.Req = c82v36
                    c82v36 = v2
                    c82v36 = c82v36.Ternary
                    c82v37 = _T.DojoMgr.mDojo
                    c82v37 = c82v37:Name__b0f5b417(c82v29)
                    c82v38 = 1
                    c82v39 = 0
                    c82v36 = c82v36(c82v37, c82v38, c82v39)
                    c82v35.Count = c82v36
                    c82v36 = mMovie
                    c82v38 = c82v34:GetLocalizeTag()
                    c82v38 = c82v38:c_str()
                    c82v39 = false
                    c82v36 = c82v36:GetLocalized(c82v38, c82v39)
                    c82v35.Name = c82v36
                    c82v36 = c82v20.InfoMaterial
                    c82v35.Material = c82v36
                    c82v36 = v43
                    c82v39 = true
                    c82v36:AddElement(c82v35, c82v39)
                  end
                end
              end
            end
          end
        end
        c82v27 = c82v20.Recipe
        c82v27 = c82v27:DisableModeActionDMTWEAK()
        c82v26 = -c82v27
        c82v27 = _T.DojoMgr.mDojo
        c82v27 = c82v27:DisableModeActionDMTWEAK()
        c82v28 = { Icon = nil, TintIconColor = nil, Themed = true, Req = 1, Count = nil, SubText = nil }
        c82v29 = capacityIcon
        c82v28.Icon = c82v29
        c82v29 = v61
        c82v29 = c82v29.FloatingContent
        c82v28.TintIconColor = c82v29
        c82v29 = v2
        c82v29 = c82v29.Ternary
        if c82v27 < c82v26 then
          c82v30 = false
        else
          c82v30 = true
        end
        c82v31 = 1
        c82v32 = 0
        c82v29 = c82v29(c82v30, c82v31, c82v32)
        c82v28.Count = c82v29
        c82v29 = mMovie
        c82v31 = "/Lotus/Language/Dojo/AvailableLabel"
        c82v32 = false
        c82v33 = { COUNT = nil }
        c82v33.COUNT = c82v27
        c82v29 = c82v29:GetLocalized(c82v31, c82v32, c82v33)
        c82v28.SubText = c82v29
        c82v29 = ""
        c82v30 = 0
        if c82v26 < c82v30 then
          c82v26 = -c82v26
          c82v30 = mMovie
          c82v32 = "<UPARROW>"
          c82v33 = true
          c82v29 = c82v30:GetLocalized(c82v32, c82v33)
        end
        c82v35 = mMovie
        c82v37 = "/Lotus/Language/Dojo/CapacityLabel"
        c82v38 = false
        c82v31 = c82v35:GetLocalized(c82v37, c82v38)
        c82v32 = " "
        c82v30 = c82v31 .. c82v32 .. c82v26 .. c82v29
        c82v28.Name = c82v30
        c82v30 = v43
        c82v33 = true
        c82v30:AddElement(c82v28, c82v33)
        c82v31 = c82v20.Recipe
        c82v31 = c82v31:GetEnergy()
        c82v30 = -c82v31
        c82v31 = _T.DojoMgr.mDojo
        c82v31 = c82v31:GetEnergy()
        c82v32 = { Icon = nil, TintIconColor = nil, Themed = true, Req = 1, Count = nil, SubText = nil }
        c82v33 = energyIcon
        c82v32.Icon = c82v33
        c82v33 = v61
        c82v33 = c82v33.FloatingContent
        c82v32.TintIconColor = c82v33
        c82v33 = v2
        c82v33 = c82v33.Ternary
        if c82v31 < c82v30 then
          c82v34 = false
        else
          c82v34 = true
        end
        c82v35 = 1
        c82v36 = 0
        c82v33 = c82v33(c82v34, c82v35, c82v36)
        c82v32.Count = c82v33
        c82v33 = mMovie
        c82v35 = "/Lotus/Language/Dojo/AvailableLabel"
        c82v36 = false
        c82v37 = { COUNT = nil }
        c82v37.COUNT = c82v31
        c82v33 = c82v33:GetLocalized(c82v35, c82v36, c82v37)
        c82v32.SubText = c82v33
        c82v29 = ""
        c82v33 = 0
        if c82v30 < c82v33 then
          c82v30 = -c82v30
          c82v33 = mMovie
          c82v35 = "<UPARROW>"
          c82v36 = true
          c82v29 = c82v33:GetLocalized(c82v35, c82v36)
        end
        c82v38 = mMovie
        c82v40 = "/Lotus/Language/Dojo/EnergyLabel"
        c82v41 = false
        c82v34 = c82v38:GetLocalized(c82v40, c82v41)
        c82v35 = " "
        c82v33 = c82v34 .. c82v35 .. c82v30 .. c82v29
        c82v32.Name = c82v33
        c82v33 = v43
        c82v36 = true
        c82v33:AddElement(c82v32, c82v36)
        c82v33 = v43
        c82v35 = nil
        c82v36 = nil
        c82v37 = true
        c82v33:Redraw(c82v35, c82v36, c82v37)
      end
      if p752 == 178 then
        local p741 = 178
        if p741 == 178 then
          if not c82v20 then
            p741 = 199
          else
            p741 = 179
          end
        end
        if p741 == 179 then
          c82v21 = c82v20.Capacity
          if c82v21 == nil then
            p741 = 199
          else
            p741 = 180
          end
        end
        if p741 == 180 then
          c82v22 = _T.DojoMgr
          c82v21 = IsNull
          c82v21 = c82v21(c82v22)
          if c82v21 then
            p741 = 199
          else
            p741 = 181
          end
        end
        if p741 == 181 then
          c82v17 = true
          c82v21 = v43
          c82v23 = true
          c82v24 = true
          c82v21:RemoveElements(c82v23, c82v24)
          c82v21 = 0
          c82v22 = _T.ComponentParams
          if c82v22 ~= nil then
            c82v22 = _T.DojoMgr.mDojo
            c82v24 = _T.ComponentParams
            c82v22 = c82v22:GetJsonComponent(c82v24)
            c82v21 = c82v22:Name__3a074c8c()
          end
          c82v23 = c82v20.IsNpcDeco
          if c82v23 then
            c82v22 = "/Lotus/Language/DojoDecosNpcs/CapacityLabelNpc"
          else
            c82v22 = "/Lotus/Language/Dojo/CapacityLabel"
          end
          c82v23 = { Icon = nil, TintIconColor = nil, Themed = true, Name = nil, Req = 1, Count = nil, SubText = nil }
          c82v24 = capacityIcon
          c82v23.Icon = c82v24
          c82v24 = v61
          c82v24 = c82v24.FloatingContent
          c82v23.TintIconColor = c82v24
          c82v28 = mMovie
          c82v31 = false
          c82v25 = c82v28:GetLocalized(c82v22, c82v31)
          c82v26 = " "
          c82v27 = c82v20.Capacity
          c82v24 = c82v25 .. c82v26 .. c82v27
          c82v23.Name = c82v24
          c82v24 = v2
          c82v24 = c82v24.Ternary
          c82v26 = c82v20.Capacity
          if c82v21 < c82v26 then
            c82v25 = false
          else
            c82v25 = true
          end
          c82v26 = 1
          c82v27 = 0
          c82v24 = c82v24(c82v25, c82v26, c82v27)
          c82v23.Count = c82v24
          c82v24 = mMovie
          c82v26 = "/Lotus/Language/Dojo/AvailableLabel"
          c82v27 = false
          c82v28 = { COUNT = nil }
          c82v28.COUNT = c82v21
          c82v24 = c82v24:GetLocalized(c82v26, c82v27, c82v28)
          c82v23.SubText = c82v24
          c82v24 = v43
          c82v27 = true
          c82v24:AddElement(c82v23, c82v27)
          c82v24 = v43
          c82v26 = nil
          c82v27 = nil
          c82v28 = true
          c82v24:Redraw(c82v26, c82v27, c82v28)
          c82v24 = c82v20.HideRecipe
          if c82v22 == nil then
            c82v25 = c82v20.Recipe
            c82v24 = IsNull
            c82v24 = c82v24(c82v25)
            if not c82v24 then
              c82v18 = true
              c82v24 = v44
              c82v26 = true
              c82v27 = true
              c82v24:RemoveElements(c82v26, c82v27)
              c82v24 = gGameRules
              c82v24 = c82v24:GetStoreManifest()
              c82v25 = ""
              c82v26 = c82v20.IsNpcDeco
              if c82v26 then
                c82v26 = "<p><font color=\""
                c82v27 = v61
                c82v27 = c82v27.FloatingContentHex
                c82v28 = "\">"
                c82v31 = mMovie
                c82v33 = "/Lotus/Language/DojoDecosNpcs/NpcRecipeComponents"
                c82v34 = false
                c82v29 = c82v31:GetLocalized(c82v33, c82v34)
                c82v30 = "</p>"
                c82v25 = c82v26 .. c82v27 .. c82v28 .. c82v29 .. c82v30
              else
                c82v30 = mMovie
                c82v32 = "<TIMER> "
                c82v33 = true
                c82v27 = c82v30:GetLocalized(c82v32, c82v33)
                c82v28 = " "
                c82v29 = v0
                c82v29 = c82v29.SecondsToFormattedTime
                c82v30 = mMovie
                c82v31 = c82v20.Recipe
                c82v31 = c82v31:GetBuildTime()
                c82v32 = "CompactHours"
                c82v29 = c82v29(c82v30, c82v31, c82v32)
                c82v26 = c82v27 .. c82v28 .. c82v29
                c82v27 = "<p><font color=\""
                c82v28 = v61
                c82v28 = c82v28.FloatingContentHex
                c82v29 = "\">"
                c82v36 = mMovie
                c82v38 = "/Lotus/Language/Menu/DetailedPurchase_BpAbout"
                c82v39 = false
                c82v30 = c82v36:GetLocalized(c82v38, c82v39)
                c82v31 = "<br><font color=\""
                c82v32 = v61
                c82v32 = c82v32.FloatingContentHighlightHex
                c82v33 = "\">"
                c82v35 = "</font></font></p>"
                c82v25 = c82v27 .. c82v28 .. c82v29 .. c82v30 .. c82v31 .. c82v32 .. c82v33 .. c82v26 .. c82v35
              end
              c82v26 = mMovie
              c82v28 = "Popup.IngredientsSeparator.Description"
              c82v29 = 36
              c82v26:SetStringVariable(c82v28, c82v29, c82v25)
              c82v26 = gGameConfig
              c82v28 = c82v20.Recipe
              c82v29 = c82v20.Recipe
              c82v29 = c82v29:GetBuildPrice()
              c82v30 = _T.DojoMgr.mGameRules
              c82v30 = c82v30:GetGuildTier()
              c82v31 = false
              c82v26 = c82v26:Name__4edc466d(c82v28, c82v29, c82v30, c82v31)
              c82v27 = 0
              if c82v27 < c82v26 then
                c82v27 = {}
                c82v28 = mMovie
                c82v30 = v52
                c82v30 = c82v30:GetLocalizeTag()
                c82v30 = c82v30:c_str()
                c82v31 = false
                c82v28 = c82v28:GetLocalized(c82v30, c82v31)
                c82v27.Name = c82v28
                c82v27.Req = c82v26
                c82v28 = v52
                c82v28 = c82v28:GetIconTexture()
                c82v27.Icon = c82v28
                c82v28 = true
                c82v27.Themed = c82v28
                c82v28 = v44
                c82v31 = true
                c82v28:AddElement(c82v27, c82v31)
              end
              c82v27 = c82v20.Recipe
              c82v27 = c82v27:GetIngredients()
              c82v30 = 1
              c82v28 = #c82v27
              c82v29 = 1
              for c82v30 = c82v30, c82v28, c82v29 do
                c82v31 = c82v27[c82v30]
                c82v34 = c82v31.mItemType
                c82v32 = c82v24:Name__1dc35bd2(c82v34)
                c82v33 = v4
                c82v33 = c82v33.GetStoreItemInfo
                c82v34 = mMovie
                c82v36 = nil
                c82v37 = nil
                c82v38 = nil
                c82v39 = true
                c82v33 = c82v33(c82v34, c82v32, c82v36, c82v37, c82v38, c82v39)
                c82v34 = gGameConfig
                c82v36 = c82v20.Recipe
                c82v37 = c82v27[c82v30]
                c82v37 = c82v37.mItemCount
                c82v38 = _T.DojoMgr.mGameRules
                c82v38 = c82v38:GetGuildTier()
                c82v39 = false
                c82v34 = c82v34:Name__4edc466d(c82v36, c82v37, c82v38, c82v39)
                c82v33.Req = c82v34
                c82v34 = v44
                c82v37 = true
                c82v34:AddElement(c82v33, c82v37)
              end
              c82v28 = v44
              c82v30 = nil
              c82v31 = nil
              c82v32 = true
              c82v28:Redraw(c82v30, c82v31, c82v32)
            end
          end
        end
        if p741 == 199 then
          c82v22 = gGameRules
          c82v21 = IsNull
          c82v21 = c82v21(c82v22)
          if c82v21 then
          else
            p741 = 200
          end
        end
        if p741 == 200 then
          c82v21 = gGameRules
          c82v23 = gLotusGameRulesType
          c82v21 = c82v21:IsA(c82v23)
          if c82v21 then
          else
            p741 = 201
          end
        end
        if p741 == 201 then
          c82v21 = v107
          c82v17, c82v19 = c82v21()
        end
      end
      if p752 == 202 then
        c82v20 = v17
        c82v20 = c82v20.Capacity
        if c82v20 == nil then
        else
          p752 = 203
        end
      end
      if p752 == 203 then
        c82v20 = gRegion
        c82v20 = c82v20:GetLocalPlayerAvatar()
        c82v21 = IsNull
        c82v21 = c82v21(c82v20)
        if c82v21 then
        else
          p752 = 204
        end
      end
      if p752 == 204 then
        c82v17 = true
        c82v21 = v43
        c82v23 = true
        c82v24 = true
        c82v21:RemoveElements(c82v23, c82v24)
        c82v21 = { availableCapacity = 0, capacityParams = nil }
        c82v23 = _T.DojoMgr
        c82v22 = IsNull
        c82v22 = c82v22(c82v23)
        if not c82v22 then
          p752 = 206
        else
          p752 = 205
        end
      end
      if p752 == 205 then
        c82v22 = v12
        c82v22 = c82v22.GetShipDecoRoom
        c82v22 = c82v22()
        c82v21.capacityParams = c82v22
        c82v22 = v12
        c82v22 = c82v22.GetShipDecoBootLocation
        c82v22 = c82v22()
        c82v23 = gGameData
        c82v25 = c82v21.capacityParams
        c82v23 = c82v23:Name__64c9c8f8(c82v25, c82v22)
        c82v21.availableCapacity = c82v23
        p752 = 207
      end
      if p752 == 206 then
        c82v22 = _T.DojoMgr
        c82v24 = c82v20:GetZone()
        c82v22 = c82v22:BuildComponentParams(c82v24:GetAttribs())
        c82v21.capacityParams = c82v22
        c82v22 = _T.DojoMgr.mDojo
        c82v24 = c82v21.capacityParams
        c82v22 = c82v22:GetJsonComponent(c82v24)
        c82v22 = c82v22:Name__3a074c8c()
        c82v21.availableCapacity = c82v22
        p752 = 207
      end
      if p752 == 207 then
        c82v22 = { Icon = nil, TintIconColor = nil, Themed = true, Name = nil, Req = 1, Count = nil, SubText = nil }
        c82v23 = capacityIcon
        c82v22.Icon = c82v23
        c82v23 = v61
        c82v23 = c82v23.FloatingContent
        c82v22.TintIconColor = c82v23
        c82v27 = mMovie
        c82v29 = "/Lotus/Language/Dojo/CapacityLabel"
        c82v30 = false
        c82v24 = c82v27:GetLocalized(c82v29, c82v30)
        c82v25 = " "
        c82v26 = v17
        c82v26 = c82v26.Capacity
        c82v23 = c82v24 .. c82v25 .. c82v26
        c82v22.Name = c82v23
        c82v23 = v2
        c82v23 = c82v23.Ternary
        c82v25 = v17
        c82v25 = c82v25.Capacity
        c82v26 = c82v21.availableCapacity
        if c82v25 <= c82v26 then
          p752 = 209
        else
          p752 = 208
        end
      end
      if p752 == 208 then
        c82v24 = false
        p752 = 210
      end
      if p752 == 209 then
        c82v24 = true
        p752 = 210
      end
      if p752 == 210 then
        c82v25 = 1
        c82v26 = 0
        c82v23 = c82v23(c82v24, c82v25, c82v26)
        c82v22.Count = c82v23
        c82v23 = mMovie
        c82v25 = "/Lotus/Language/Dojo/AvailableLabel"
        c82v26 = false
        c82v27 = { COUNT = nil }
        c82v28 = c82v21.availableCapacity
        c82v27.COUNT = c82v28
        c82v23 = c82v23:GetLocalized(c82v25, c82v26, c82v27)
        c82v22.SubText = c82v23
        c82v23 = v43
        c82v26 = true
        c82v23:AddElement(c82v22, c82v26)
        c82v23 = v43
        c82v25 = nil
        c82v26 = nil
        c82v27 = true
        c82v23:Redraw(c82v25, c82v26, c82v27)
      end
    end
    c82v21 = v17
    c82v21 = c82v21.CodexEntry
    c82v20 = IsNull
    c82v20 = c82v20(c82v21)
    if not c82v20 then
      c82v21 = v24
      c82v20 = string.len
      c82v20 = c82v20(c82v21)
      c82v21 = 0
      if c82v21 < c82v20 then
        c82v21 = v24
        c82v21 = c82v21:sub(c82v20, c82v20)
        if c82v21 ~= "\r" then
          c82v23 = v24
          c82v24 = "\r"
          c82v22 = c82v23 .. c82v24
          v24 = c82v22
        end
      end
      c82v22 = v24
      c82v23 = v6
      c82v23 = c82v23.GetEnemyInfoText
      c82v24 = mMovie
      c82v25 = v17
      c82v25 = c82v25.CodexEntry
      c82v26 = v61
      c82v26 = c82v26.FloatingContentHighlightHex
      c82v27 = v61
      c82v27 = c82v27.ContentHex
      c82v28 = v17
      c82v28 = c82v28.SkipFaction
      c82v29 = v17
      c82v29 = c82v29.SkipRegions
      c82v30 = v17
      c82v30 = c82v30.SkipEnemyDesc
      c82v23 = c82v23(c82v24, c82v25, c82v26, c82v27, c82v28, c82v29, c82v30)
      c82v21 = c82v22 .. c82v23
      v24 = c82v21
    end
    c82v20 = IsNull
    c82v20 = c82v20(c82v16)
    if c82v20 then
      c82v22 = Name__d7185637
      c82v20 = c82v16:IsA(c82v22)
      if c82v20 then
        c82v21 = v17
        c82v21 = c82v21.mMod
        c82v20 = IsNull
        c82v20 = c82v20(c82v21)
        if c82v20 then
          c82v20 = v4
          c82v20 = c82v20.GetBoosterPackInfo
          c82v21 = mMovie
          c82v22 = Resource
          c82v22 = c82v22(c82v16)
          c82v23 = true
          c82v24 = true
          c82v20, c82v21, c82v22 = c82v20(c82v21, c82v22, c82v23, c82v24)
          if c82v21 ~= nil then
            c82v23 = v53
            if not c82v23 then
              c82v23 = v18
              c82v25 = { State = nil }
              c82v26 = v64
              c82v26 = c82v26.BASE
              c82v25.State = c82v26
              c82v23:AddElement(c82v25)
              c82v23 = v93
              c82v23()
            end
          end
          c82v23 = v18
          c82v23 = c82v23.mCurrentElementIndex
          if c82v23 == 1 then
            c82v24 = v24
            c82v23 = c82v24 .. c82v20
            v24 = c82v23
          else
            if c82v21 ~= nil then
              c82v24 = v24
              c82v23 = c82v24 .. c82v21
              v24 = c82v23
            end
          end
          c82v23 = true
          v53 = c82v23
        end
      end
    end
    c82v20 = IsNull
    c82v20 = c82v20(c82v0)
    if not c82v20 then
      c82v20 = IsNull
      c82v20 = c82v20(c82v2)
      if not c82v20 then
        c82v20 = c82v2:IsPackage()
        if c82v20 then
          c82v20 = v4
          c82v20 = c82v20.GetPackageContentsDesc
          c82v21 = mMovie
          c82v23 = c82v0.PurchasedItems
          c82v24 = true
          c82v25 = v61
          c82v25 = c82v25.FloatingContentHighlightHex
          c82v26 = v61
          c82v26 = c82v26.Background4Hex
          c82v27 = v61
          c82v27 = c82v27.FloatingContentHex
          c82v28 = 18
          c82v20 = c82v20(c82v21, c82v2, c82v23, c82v24, c82v25, c82v26, c82v27, c82v28)
          c82v21 = v24
          if not ((c82v21 == "" or c82v20 == "")) then
            c82v22 = v24
            c82v23 = "<br><br>"
            c82v21 = c82v22 .. c82v23
            v24 = c82v21
          end
          c82v22 = v24
          c82v21 = c82v22 .. c82v20
          v24 = c82v21
        end
      end
      c82v20 = nil
      c82v22 = gGameRules
      c82v21 = IsNull
      c82v21 = c82v21(c82v22)
      if not c82v21 then
        c82v22 = gGameData
        c82v21 = IsNull
        c82v21 = c82v21(c82v22)
        if not c82v21 then
          c82v21 = nil
          c82v22 = nil
          c82v23 = v4
          c82v23 = c82v23.GetCompatWarning
          c82v24 = mMovie
          c82v26 = gGameRules
          c82v26 = c82v26:GetStoreManifest()
          c82v27 = gGameData
          c82v27 = c82v27:GetInventory()
          c82v28 = { Items = nil, Dictionary = nil }
          c82v29 = c82v0.PurchasedItems
          c82v28.Items = c82v29
          c82v29 = c82v0.PurchasedIsDictionary
          c82v28.Dictionary = c82v29
          c82v29 = true
          c82v21, c82v20, c82v22 = c82v23(c82v24, c82v2, c82v26, c82v27, c82v28, c82v29)
        end
      end
      if c82v20 then
        c82v21 = v24
        if c82v21 ~= "" then
          c82v22 = v24
          c82v23 = "<br><br>"
          c82v21 = c82v22 .. c82v23
          v24 = c82v21
        end
        c82v22 = v24
        c82v26 = mMovie
        c82v28 = "<WARNING>"
        c82v29 = true
        c82v23 = c82v26:GetLocalized(c82v28, c82v29)
        c82v24 = " "
        c82v21 = c82v22 .. c82v23 .. c82v24 .. c82v20
        v24 = c82v21
      end
    end
    c82v20 = v17
    c82v20 = c82v20.mModDescOverride
    if c82v20 then
      c82v27 = v24
      c82v28 = "<br>"
      c82v26 = c82v27 .. c82v28
      v24 = c82v26
    end
    if c82v20 then
      c82v21 = v24
      c82v22 = v17
      c82v22 = c82v22.mModDescOverride
      c82v20 = c82v21 .. c82v22
      v24 = c82v20
    else
      c82v21 = v24
      c82v22 = v17
      c82v22 = c82v22.mMod
      c82v22 = c82v22.Card
      c82v22 = c82v22.mDesc
      c82v20 = c82v21 .. c82v22
      v24 = c82v20
      c82v20 = v4
      c82v20 = c82v20.GetUpgradeInfo
      c82v21 = mMovie
      c82v23 = v61
      c82v23 = c82v23.FloatingContentHighlightHex
      c82v24 = v61
      c82v24 = c82v24.ContentHex
      c82v25 = nil
      c82v26 = ""
      c82v27 = v17
      c82v27 = c82v27.RawItem
      c82v20 = c82v20(c82v21, c82v2, c82v23, c82v24, c82v25, c82v26, c82v27)
      c82v21 = mMovie
      c82v23 = "Popup.Description"
      c82v24 = 36
      c82v26 = "<p><font color=\""
      c82v27 = v61
      c82v27 = c82v27.ContentHex
      c82v28 = "\">"
      c82v30 = "</font></p>"
      c82v25 = c82v26 .. c82v27 .. c82v28 .. c82v20 .. c82v30
      c82v21:SetStringVariable(c82v23, c82v24, c82v25)
      c82v21 = mMovie
      c82v23 = "Popup.Description"
      c82v24 = 41
      c82v21 = c82v21:GetNumberVariable(c82v23, c82v24)
      c82v22 = mMovie
      c82v22 = c82v22:GetMovieHeight()
      c82v24 = 0.8
      c82v23 = c82v22 * c82v24
      if c82v23 < c82v21 then
        c82v23 = v4
        c82v23 = c82v23.GetUpgradeInfo
        c82v24 = mMovie
        c82v26 = v61
        c82v26 = c82v26.FloatingContentHighlightHex
        c82v27 = v61
        c82v27 = c82v27.ContentHex
        c82v28 = nil
        c82v29 = ""
        c82v30 = v17
        c82v30 = c82v30.RawItem
        c82v31 = true
        c82v32 = "<br><br>...<br><br>"
        c82v20 = c82v23(c82v24, c82v2, c82v26, c82v27, c82v28, c82v29, c82v30, c82v31, c82v32)
      end
      c82v24 = v24
      c82v23 = c82v24 .. c82v20
      v24 = c82v23
      local p742 = 273
      if p742 == 273 then
        c82v24 = v17
        c82v24 = c82v24.ShowAllRanks
        if c82v24 then
          p742 = 275
        else
          p742 = 274
        end
      end
      if p742 == 274 then
        c82v24 = v17
        c82v24 = c82v24.ShowFirstLastRank
        if not c82v24 then
          p742 = 276
        else
          p742 = 275
        end
      end
      if p742 == 275 then
        c82v25 = v24
        c82v26 = v4
        c82v26 = c82v26.GetUpgradeInfo
        c82v27 = mMovie
        c82v29 = v61
        c82v29 = c82v29.FloatingContentHighlightHex
        c82v30 = v61
        c82v30 = c82v30.FloatingContentHex
        c82v31 = " "
        c82v32 = ""
        c82v33 = nil
        c82v34 = v17
        c82v34 = c82v34.ShowFirstLastRank
        c82v26 = c82v26(c82v27, c82v2, c82v29, c82v30, c82v31, c82v32, c82v33, c82v34)
        c82v24 = c82v25 .. c82v26
        v24 = c82v24
      end
      if p742 == 276 then
        c82v25 = v24
        c82v26 = "<font color=\""
        c82v27 = v61
        c82v27 = c82v27.FloatingContentHighlightHex
        c82v28 = "\">"
        c82v35 = string.upper
        c82v29 = c82v35(c82v21)
        c82v30 = "</font><font color=\""
        c82v31 = v61
        c82v31 = c82v31.FloatingContentHex
        c82v32 = "\">"
        c82v34 = "</font>"
        c82v24 = c82v25 .. c82v26 .. c82v27 .. c82v28 .. c82v29 .. c82v30 .. c82v31 .. c82v32 .. c82v22 .. c82v34
        v24 = c82v24
      end
    end
    c82v20 = v17
    c82v20 = c82v20.StatId
    if c82v23 <= c82v24 then
      c82v26 = "<br><font color=\""
      c82v27 = v61
      c82v27 = c82v27.FloatingContentHighlightHex
      c82v28 = "\">"
      c82v32 = mMovie
      c82v34 = "/Lotus/Language/Stats/StatusEffectTitle"
      c82v35 = false
      c82v29 = c82v32:GetLocalized(c82v34, c82v35)
      c82v30 = "</font><br>"
      c82v31 = v24
      c82v24 = c82v23 .. c82v26 .. c82v27 .. c82v28 .. c82v29 .. c82v30 .. c82v31
      v24 = c82v24
    end
    c82v21 = v21
    if c82v21 <= c82v5 then
      c82v20 = false
    else
      c82v20 = true
    end
    if not c82v20 then
      c82v22 = v21
      c82v23 = 11
      c82v21 = c82v22 - c82v23
      v21 = c82v21
    else
      c82v22 = v21
      c82v23 = 6
      c82v21 = c82v22 + c82v23
      v21 = c82v21
    end
    c82v21 = mMovie
    c82v23 = "Popup.TagSeparator"
    c82v24 = 1
    c82v25 = v21
    c82v21:SetNumberVariable(c82v23, c82v24, c82v25)
    c82v21 = v17
    c82v21 = c82v21.CustomEntry
    if c82v21 then
      c82v21 = v17
      c82v21 = c82v21.RankedProgress
      if c82v21 ~= nil then
        c82v21 = v10
        c82v21 = c82v21.DrawRankIndicator
        c82v22 = mMovie
        c82v23 = "Popup.RankedProgress.Rank"
        c82v24 = { Level = nil }
        c82v25 = v17
        c82v25 = c82v25.RankedProgress
        c82v25 = c82v25.Rank
        c82v24.Level = c82v25
        c82v21(c82v22, c82v23, c82v24)
        c82v21 = mMovie
        c82v23 = "Popup.RankedProgress.Bar.Fill"
        c82v24 = _G
        c82v24 = c82v24.UIMaterial_RectangleNoDepth
        c82v21:OverrideMaterial(c82v23, c82v24)
        c82v21 = mMovie
        c82v23 = "Popup.RankedProgress.Bar.Bg"
        c82v24 = _G
        c82v24 = c82v24.UIMaterial_RectangleNoDepth
        c82v21:OverrideMaterial(c82v23, c82v24)
        c82v21 = mMovie
        c82v23 = "Popup.RankedProgress.Title"
        c82v24 = 44
        c82v25 = v61
        c82v25 = c82v25.FloatingContent
        c82v21:SetNumberVariable(c82v23, c82v24, c82v25)
        c82v21 = mMovie
        c82v23 = "Popup.RankedProgress.Progress"
        c82v24 = 44
        c82v25 = v61
        c82v25 = c82v25.FloatingContentHighlight
        c82v21:SetNumberVariable(c82v23, c82v24, c82v25)
        c82v21 = v61
        c82v21 = c82v21.Background1RGB
        c82v22 = v61
        c82v22 = c82v22.FloatingContentRGB
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress.Bar.Fill"
        c82v26 = "RectInnerColor"
        c82v27 = c82v22.r
        c82v28 = c82v22.g
        c82v29 = c82v22.b
        c82v30 = 1
        c82v23:Name__e243d995(c82v25, c82v26, c82v27, c82v28, c82v29, c82v30)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress.Bar.Fill"
        c82v26 = "RectEdgeColor"
        c82v27 = c82v22.r
        c82v28 = c82v22.g
        c82v29 = c82v22.b
        c82v30 = 1
        c82v23:Name__e243d995(c82v25, c82v26, c82v27, c82v28, c82v29, c82v30)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress.Bar.Bg"
        c82v26 = "RectInnerColor"
        c82v27 = c82v21.r
        c82v28 = c82v21.g
        c82v29 = c82v21.b
        c82v30 = 0
        c82v23:Name__e243d995(c82v25, c82v26, c82v27, c82v28, c82v29, c82v30)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress.Bar.Bg"
        c82v26 = "RectEdgeColor"
        c82v27 = c82v22.r
        c82v28 = c82v22.g
        c82v29 = c82v22.b
        c82v30 = 1
        c82v23:Name__e243d995(c82v25, c82v26, c82v27, c82v28, c82v29, c82v30)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress.Bar.Bg"
        c82v26 = 14
        c82v27 = 256
        c82v23:SetNumberVariable(c82v25, c82v26, c82v27)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress.Bar.Fill"
        c82v26 = 14
        c82v29 = 252
        c82v32 = v17
        c82v32 = c82v32.RankedProgress
        c82v32 = c82v32.Progress
        c82v33 = v17
        c82v33 = c82v33.RankedProgress
        c82v33 = c82v33.Required
        c82v31 = math.min
        c82v31 = c82v31(c82v32, c82v33)
        c82v32 = v17
        c82v32 = c82v32.RankedProgress
        c82v32 = c82v32.Required
        c82v30 = c82v31 / c82v32
        c82v28 = c82v29 * c82v30
        c82v29 = 0.1
        c82v27 = math.max
        c82v27 = c82v27(c82v28, c82v29)
        c82v23:SetNumberVariable(c82v25, c82v26, c82v27)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress.Progress"
        c82v26 = 14
        c82v27 = 256
        c82v23:SetNumberVariable(c82v25, c82v26, c82v27)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress.Title"
        c82v26 = 36
        c82v27 = v17
        c82v27 = c82v27.RankedProgress
        c82v27 = c82v27.Name
        c82v23:SetStringVariable(c82v25, c82v26, c82v27)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress.Progress"
        c82v26 = 36
        c82v28 = v17
        c82v28 = c82v28.RankedProgress
        c82v28 = c82v28.ProgressPrefix
        c82v32 = v2
        c82v32 = c82v32.FormatNumber
        c82v33 = v17
        c82v33 = c82v33.RankedProgress
        c82v33 = c82v33.Progress
        c82v29 = c82v32(c82v33)
        c82v30 = "/"
        c82v31 = v2
        c82v31 = c82v31.FormatNumber
        c82v32 = v17
        c82v32 = c82v32.RankedProgress
        c82v32 = c82v32.Required
        c82v31 = c82v31(c82v32)
        c82v27 = c82v28 .. c82v29 .. c82v30 .. c82v31
        c82v23:SetStringVariable(c82v25, c82v26, c82v27)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress"
        c82v26 = 13
        c82v27 = true
        c82v23:Name__d9713943(c82v25, c82v26, c82v27)
        c82v23 = mMovie
        c82v25 = "Popup.RankedProgress"
        c82v26 = 1
        c82v27 = v21
        c82v23:SetNumberVariable(c82v25, c82v26, c82v27)
        c82v24 = v21
        c82v25 = 64
        c82v23 = c82v24 + c82v25
        v21 = c82v23
      end
    end
    c82v22 = v17
    c82v22 = c82v22.PreviewImage
    if c82v22 == nil then
      c82v21 = false
    else
      c82v21 = true
    end
    if c82v5 < c82v21 then
      c82v22 = 185
      c82v23 = mMovie
      c82v25 = "Popup.VideoPreview"
      c82v26 = 1
      c82v27 = v21
      c82v23:SetNumberVariable(c82v25, c82v26, c82v27)
      c82v23 = mMovie
      c82v25 = "Popup.VideoPreview.Mask"
      c82v26 = 14
      c82v27 = 330
      c82v23:SetNumberVariable(c82v25, c82v26, c82v27)
      c82v23 = mMovie
      c82v25 = "Popup.VideoPreview.Mask"
      c82v26 = 15
      c82v23:SetNumberVariable(c82v25, c82v26, c82v22)
      c82v23 = v17
      c82v23 = c82v23.PreviewImage
      c82v25 = gVideoTextureType
      c82v23 = c82v23:IsA(c82v25)
      if c82v23 then
        c82v23 = mMovie
        c82v25 = "Popup.VideoPreview.Image"
        c82v26 = 1
        c82v27 = 0
        c82v23:SetNumberVariable(c82v25, c82v26, c82v27)
        c82v23 = mMovie
        c82v25 = "Popup.VideoPreview.Image"
        c82v26 = 14
        c82v27 = 330
        c82v23:SetNumberVariable(c82v25, c82v26, c82v27)
        c82v23 = mMovie
        c82v25 = "Popup.VideoPreview.Image"
        c82v26 = 15
        c82v23:SetNumberVariable(c82v25, c82v26, c82v22)
      else
        c82v23 = 330
        c82v24 = v17
        c82v24 = c82v24.PreviewImageHeightRatio
        if c82v24 then
          c82v25 = v17
          c82v25 = c82v25.PreviewImageHeightRatio
          c82v24 = tonumber
          c82v24 = c82v24(c82v25)
          c82v26 = 185
          c82v25 = c82v26 / c82v24
          c82v26 = 12
          c82v22 = c82v25 - c82v26
          c82v23 = c82v23 * c82v24
        end
        c82v24 = mMovie
        c82v26 = "Popup.VideoPreview.Image"
        c82v27 = 1
        c82v29 = v17
        c82v29 = c82v29.AbilityInitialized
        if c82v29 then
          c82v28 = -30
        else
          c82v30 = 330
          c82v29 = c82v22 - c82v30
          c82v30 = 2
          c82v28 = c82v29 / c82v30
        end
        c82v24:SetNumberVariable(c82v26, c82v27, c82v28)
        c82v24 = mMovie
        c82v26 = "Popup.VideoPreview.Image"
        c82v27 = 14
        c82v28 = 330
        c82v24:SetNumberVariable(c82v26, c82v27, c82v28)
        c82v24 = mMovie
        c82v26 = "Popup.VideoPreview.Image"
        c82v27 = 15
        c82v24:SetNumberVariable(c82v26, c82v27, c82v23)
        c82v24 = mMovie
        c82v26 = "Popup.VideoPreview.Image"
        c82v27 = parallaxIconMaterial
        c82v24:OverrideMaterial(c82v26, c82v27)
        c82v24 = mMovie
        c82v26 = "Popup.VideoPreview.Image"
        c82v27 = "DetailMapParams"
        c82v28 = 0
        c82v29 = 0
        c82v30 = 1
        c82v31 = 1
        c82v24:Name__e243d995(c82v26, c82v27, c82v28, c82v29, c82v30, c82v31)
        c82v24 = mMovie
        c82v26 = "Popup.VideoPreview.Image"
        c82v27 = "BlendOffsetParallax"
        c82v28 = 1
        c82v29 = 0.5
        c82v30 = 1
        c82v31 = 0.025
        c82v24:Name__e243d995(c82v26, c82v27, c82v28, c82v29, c82v30, c82v31)
        c82v24 = mMovie
        c82v26 = "Popup.VideoPreview.Image"
        c82v27 = "TintColor"
        c82v28 = 1
        c82v29 = 1
        c82v30 = 1
        c82v31 = 0
        c82v24:Name__e243d995(c82v26, c82v27, c82v28, c82v29, c82v30, c82v31)
        c82v25 = v17
        c82v25 = c82v25.AutoParallaxX
        if c82v25 then
          c82v24 = 1
        else
          c82v24 = 0
        end
        c82v26 = v17
        c82v26 = c82v26.AutoParallaxY
        if c82v26 then
          c82v25 = 1
        else
          c82v25 = 0
        end
        c82v26 = mMovie
        c82v28 = "Popup.VideoPreview.Image"
        c82v29 = "AutoOffsetParallax"
        c82v32 = 1
        c82v33 = 0
        c82v26:Name__e243d995(c82v28, c82v29, c82v24, c82v25, c82v32, c82v33)
      end
      c82v24 = IsWeak
      c82v25 = v17
      c82v25 = c82v25.PreviewImage
      c82v24 = c82v24(c82v25)
      c82v23 = not c82v24
      c82v24 = mMovie
      c82v26 = "Popup.VideoPreview.Image"
      c82v27 = 13
      c82v24:Name__d9713943(c82v26, c82v27, c82v23)
      if c82v23 then
        c82v24 = v17
        c82v24 = c82v24.SkipVideoReset
        if not c82v24 then
          c82v24 = mMovie
          c82v26 = "Popup.VideoPreview.Image"
          c82v24:StopVideoTexture(c82v26)
          c82v24 = mMovie
          c82v26 = "Popup.VideoPreview.Image"
          c82v27 = v17
          c82v27 = c82v27.PreviewImage
          c82v24:OverrideTexture(c82v26, c82v27)
          c82v24 = mMovie
          c82v26 = "Popup.VideoPreview.Image"
          c82v24:Name__f55ae1a2(c82v26)
        else
          c82v24 = mMovie
          c82v26 = "Popup.VideoPreview.Image"
          c82v27 = v17
          c82v27 = c82v27.PreviewImage
          c82v24:OverrideTexture(c82v26, c82v27)
          c82v24 = v17
          c82v25 = nil
          c82v24.SkipVideoReset = c82v25
        end
      else
        c82v24 = v38
        c82v26 = true
        c82v24:SetActive(c82v26)
        c82v24 = mMovie
        c82v26 = "Popup.Spinner"
        c82v27 = 1
        c82v29 = v20
        c82v30 = 93
        c82v28 = c82v29 + c82v30
        c82v24:SetNumberVariable(c82v26, c82v27, c82v28)
      end
      c82v24 = v17
      c82v24 = c82v24.PreviewImageHeightRatio
      if c82v24 then
        c82v22 = 185
      end
      c82v26 = v21
      c82v25 = c82v26 + c82v22
      c82v26 = 6
      c82v24 = c82v25 + c82v26
      v21 = c82v24
    else
      c82v23 = v21
      c82v24 = 10
      c82v22 = c82v23 + c82v24
      v21 = c82v22
    end
    c82v22 = mMovie
    c82v24 = "Popup.VideoPreview"
    c82v25 = 13
    c82v22:Name__d9713943(c82v24, c82v25, c82v21)
    c82v22 = mMovie
    c82v24 = "Popup.Description"
    c82v25 = 1
    c82v26 = v21
    c82v22:SetNumberVariable(c82v24, c82v25, c82v26)
    c82v22 = v27
    if c82v22 ~= 0 then
      c82v22 = "\r\n\r\n"
      c82v3 = c82v22 .. c82v3
    end
    c82v22 = v17
    c82v22 = c82v22.FontNameOverride
    if c82v22 then
      c82v22 = mMovie
      c82v24 = "Popup.Description"
      c82v25 = 49
      c82v26 = v17
      c82v26 = c82v26.FontNameOverride
      c82v22:SetStringVariable(c82v24, c82v25, c82v26)
    else
      c82v22 = mMovie
      c82v24 = "Popup.Description"
      c82v25 = 49
      c82v26 = "Roboto Regular"
      c82v22:SetStringVariable(c82v24, c82v25, c82v26)
    end
    c82v22 = v17
    c82v22 = c82v22.ReplaceAndReduceMissingChars
    if c82v22 then
      c82v22 = v1
      c82v22 = c82v22.ReplaceAndReduceMissingChars
      c82v23 = v24
      c82v22 = c82v22(c82v23)
      v24 = c82v22
      c82v22 = v1
      c82v22 = c82v22.ReplaceAndReduceMissingChars
      c82v3 = c82v22(c82v3)
    end
    if not c82v0 then
      c82v28 = v32
      if c82v7 < c82v28 then
        c82v29 = c82v7 + 1
        c82v30 = 2
        c82v28 = math.max
        c82v31 = c82v28(c82v29, c82v30)
        c82v29 = v32
        c82v30 = 1
        for c82v31 = c82v31, c82v29, c82v30 do
          c82v32 = FlashMethod
          c82v33 = mMovie
          c82v35 = "Popup.Affiliation"
          c82v37 = ".removeMovieClip"
          c82v34 = c82v35 .. c82v31 .. c82v37
          c82v32(c82v33, c82v34)
        end
      end
      c82v29 = 1
      c82v28 = math.max
      c82v28 = c82v28(c82v29, c82v7)
      v32 = c82v28
      c82v28 = ipairs
      c82v29 = v17
      c82v29 = c82v29.Affiliations
      c82v28, c82v29, c82v30 = c82v28(c82v29)
      for c82v31, c82v32 in c82v28, c82v29, c82v30 do
        c82v34 = "Popup.Affiliation"
        c82v33 = c82v34 .. c82v31
        c82v34 = mMovie
        c82v37 = 13
        c82v38 = true
        c82v34:Name__d9713943(c82v33, c82v37, c82v38)
        c82v34 = mMovie
        c82v37 = 1
        c82v38 = v21
        c82v34:SetNumberVariable(c82v33, c82v37, c82v38)
        c82v35 = c82v32.Level
        c82v36 = 0
        if c82v35 < c82v36 then
          c82v34 = false
        else
          c82v34 = true
        end
        c82v35 = mMovie
        c82v38 = "Border"
        c82v39 = 13
        c82v40 = false
        c82v35:Makeposshield(c82v33, c82v38, c82v39, c82v40)
        c82v35 = mMovie
        c82v38 = "Bg"
        c82v39 = 13
        c82v40 = false
        c82v35:Makeposshield(c82v33, c82v38, c82v39, c82v40)
        c82v35 = mMovie
        c82v38 = "Border"
        c82v39 = 14
        c82v40 = v22
        c82v35:Name__52c1b74e(c82v33, c82v38, c82v39, c82v40)
        c82v35 = mMovie
        c82v38 = "Bg"
        c82v39 = 14
        c82v40 = v22
        c82v35:Name__52c1b74e(c82v33, c82v38, c82v39, c82v40)
        c82v35 = mMovie
        c82v38 = "Border"
        c82v39 = 11
        c82v40 = v61
        c82v40 = c82v40.Background1
        c82v35:Name__52c1b74e(c82v33, c82v38, c82v39, c82v40)
        c82v35 = mMovie
        c82v39 = ".Bg"
        c82v37 = c82v33 .. c82v39
        c82v38 = midBgTexture
        c82v39 = midBgMaterial
        c82v35:Name__9c27ee88(c82v37, c82v38, c82v39)
        c82v35 = mMovie
        c82v39 = ".Bg"
        c82v37 = c82v33 .. c82v39
        c82v38 = "StartColor"
        c82v39 = v61
        c82v39 = c82v39.Background1RGB
        c82v39 = c82v39.r
        c82v40 = v61
        c82v40 = c82v40.Background1RGB
        c82v40 = c82v40.g
        c82v41 = v61
        c82v41 = c82v41.Background1RGB
        c82v41 = c82v41.b
        c82v42 = 1
        c82v35:Name__e243d995(c82v37, c82v38, c82v39, c82v40, c82v41, c82v42)
        c82v35 = v2
        c82v35 = c82v35.Ternary
        c82v37 = v61
        c82v37 = c82v37.PositiveRGB
        c82v38 = v61
        c82v38 = c82v38.NegativeRGB
        c82v35 = c82v35(c82v34, c82v37, c82v38)
        c82v36 = mMovie
        c82v40 = ".Bg"
        c82v38 = c82v33 .. c82v40
        c82v39 = "EndColor"
        c82v41 = c82v35.r
        c82v40 = c82v41 / 1
        c82v42 = c82v35.g
        c82v41 = c82v42 / 1
        c82v43 = c82v35.b
        c82v42 = c82v43 / 1
        c82v43 = 1
        c82v36:Name__e243d995(c82v38, c82v39, c82v40, c82v41, c82v42, c82v43)
        c82v36 = mMovie
        c82v40 = ".Icon"
        c82v38 = c82v33 .. c82v40
        c82v39 = c82v32.Icon
        c82v36:OverrideTexture(c82v38, c82v39)
        c82v36 = mMovie
        c82v39 = "Icon"
        c82v40 = 11
        c82v41 = v61
        c82v41 = c82v41.FloatingContentHighlight
        c82v36:Name__52c1b74e(c82v33, c82v39, c82v40, c82v41)
        c82v36 = mMovie
        c82v39 = "Name"
        c82v40 = 44
        c82v41 = v61
        c82v41 = c82v41.Content
        c82v36:Name__52c1b74e(c82v33, c82v39, c82v40, c82v41)
        c82v36 = mMovie
        c82v39 = "Label"
        c82v40 = 36
        c82v41 = c82v32.Label
        c82v36:Name__f4a9016a(c82v33, c82v39, c82v40, c82v41)
        c82v36 = mMovie
        c82v39 = "Label"
        c82v40 = 41
        c82v36 = c82v36:Name__46690123(c82v33, c82v39, c82v40)
        c82v37 = mMovie
        c82v40 = "Label"
        c82v41 = 1
        c82v43 = 36
        c82v45 = 2
        c82v44 = c82v36 / c82v45
        c82v42 = c82v43 - c82v44
        c82v37:Name__52c1b74e(c82v33, c82v40, c82v41, c82v42)
        c82v38 = v21
        c82v39 = v2
        c82v39 = c82v39.Ternary
        c82v42 = v17
        c82v42 = c82v42.Affiliations
        c82v41 = #c82v42
        if c82v31 == c82v41 then
          c82v40 = false
        else
          c82v40 = true
        end
        c82v41 = 70
        c82v42 = 60
        c82v39 = c82v39(c82v40, c82v41, c82v42)
        c82v37 = c82v38 + c82v39
        v21 = c82v37
      end
    end
    c82v28 = v17
    c82v28 = c82v28.IsAbility
    if c82v28 then
      c82v28 = v33
      c82v29 = v33
      c82v30 = v33
      c82v31 = v33
      c82v32 = v5
      c82v32 = c82v32.GetStatsTextForAbility
      c82v33 = v17
      c82v32, c82v33, c82v34, c82v35 = c82v32(c82v33)
      c82v28.Labels = c82v32
      c82v29.Values = c82v33
      c82v30.BaseValues = c82v34
      c82v31.StatChanges = c82v35
    else
      c82v28 = v17
      c82v28 = c82v28.mDisplayStats
      if c82v28 ~= nil then
        c82v28 = v17
        c82v28 = c82v28.mDisplayStats
        v33 = c82v28
      end
    end
    do return c82v1, c82v3, c82v7 end
  end
  v65 = function()
    local c83v0, c83v1, c83v2, c83v3, c83v4, c83v5, c83v6, c83v7, c83v8, c83v9, c83v10, c83v11, c83v12, c83v13, c83v14, c83v15, c83v16, c83v17, c83v18, c83v19, c83v20, c83v21, c83v22, c83v23, c83v24, c83v25, c83v26, c83v27, c83v28, c83v29, c83v30, c83v31, c83v32, c83v33, c83v34, c83v35, c83v36, c83v37
    local p390 = 156
    if p390 == 0 then
      c83v2 = v41
      c83v1 = IsNull
      c83v1 = c83v1(c83v2)
      if c83v1 then
        p390 = 9
      else
        p390 = 1
      end
    end
    if p390 == 1 then
      c83v1 = v63
      c83v2 = v64
      c83v2 = c83v2.BASE
      if c83v1 ~= c83v2 then
        p390 = 5
      else
        p390 = 2
      end
    end
    if p390 == 2 then
      c83v1 = v17
      c83v1 = c83v1.AllInOne
      if c83v1 then
        p390 = 5
      else
        p390 = 3
      end
    end
    if p390 == 3 then
      c83v1 = v17
      c83v1 = c83v1.Category
      c83v2 = 43
      if c83v1 == c83v2 then
        p390 = 5
      else
        p390 = 4
      end
    end
    if p390 == 4 then
      c83v1 = v17
      c83v1 = c83v1.Category
      c83v2 = 46
      if c83v1 ~= c83v2 then
        p390 = 9
      else
        p390 = 5
      end
    end
    if p390 == 5 then
      c83v1 = v18
      c83v1 = c83v1.mSelectedElement
      c83v2 = IsNull
      c83v2 = c83v2(c83v1)
      if c83v2 then
        p390 = 8
      else
        p390 = 6
      end
    end
    if p390 == 6 then
      c83v3 = c83v1.SuitOverride
      c83v2 = IsNull
      c83v2 = c83v2(c83v3)
      if c83v2 then
        p390 = 8
      else
        p390 = 7
      end
    end
    if p390 == 7 then
      c83v2 = Resource
      c83v3 = c83v1.SuitOverride
      c83v0 = c83v2(c83v3)
      p390 = 9
    end
    if p390 == 8 then
      c83v2 = Resource
      c83v3 = v41
      c83v0 = c83v2(c83v3)
      p390 = 9
    end
    if p390 == 9 then
      c83v1 = v17
      c83v1 = c83v1.IsAbility
      if not c83v1 then
        p390 = 14
      else
        p390 = 10
      end
    end
    if p390 == 10 then
      c83v1 = v17
      c83v1 = c83v1.AbilityInitialized
      if c83v1 then
        p390 = 12
      else
        p390 = 11
      end
    end
    if p390 == 11 then
      c83v1 = v67
      c83v1(c83v0)
      p390 = 14
    end
    if p390 == 12 then
      c83v2 = v17
      c83v2 = c83v2.Resource
      c83v1 = IsNull
      c83v1 = c83v1(c83v2)
      if c83v1 then
        p390 = 14
      else
        p390 = 13
      end
    end
    if p390 == 13 then
      c83v1 = v87
      c83v2 = v17
      c83v2 = c83v2.Resource
      c83v3 = v17
      c83v3 = c83v3.mSuit
      c83v1(c83v2, c83v3)
      c83v1 = v88
      c83v2 = v17
      c83v2 = c83v2.Resource
      c83v1(c83v2)
      p390 = 14
    end
    if p390 == 14 then
      c83v1 = _T.InfoPopup_Grid
      c83v2 = v17
      c83v2 = c83v2.StoreItem
      c83v3 = nil
      c83v4 = IsNull
      c83v4 = c83v4(c83v2)
      if c83v4 then
        p390 = 16
      else
        p390 = 15
      end
    end
    if p390 == 15 then
      c83v3 = c83v2:GetProductCategory()
      p390 = 16
    end
    if p390 == 16 then
      c83v5 = v20
      c83v4 = c83v5 + 10
      v21 = c83v4
      c83v5 = true
      c83v6 = v63
      c83v7 = v64
      c83v7 = c83v7.BASE
      if c83v6 == c83v7 then
        p390 = 20
      else
        p390 = 17
      end
    end
    if p390 == 17 then
      c83v6 = v63
      c83v7 = v64
      c83v7 = c83v7.INFO
      if c83v6 == c83v7 then
        p390 = 19
      else
        p390 = 18
      end
    end
    if p390 == 18 then
      c83v5 = false
      p390 = 20
    end
    if p390 == 19 then
      c83v5 = true
      p390 = 20
    end
    if p390 == 20 then
      c83v6 = mMovie
      c83v8 = "Popup.TagSeparator"
      c83v9 = 13
      c83v11 = v63
      c83v12 = v64
      c83v12 = c83v12.BASE
      if c83v11 == c83v12 then
        p390 = 22
      else
        p390 = 21
      end
    end
    if p390 == 21 then
      c83v10 = false
      p390 = 23
    end
    if p390 == 22 then
      c83v10 = true
      p390 = 23
    end
    if p390 == 23 then
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = mMovie
      c83v8 = "Popup.Ingredients"
      c83v9 = 13
      c83v11 = v63
      c83v12 = v64
      c83v12 = c83v12.CRAFTING
      if c83v11 == c83v12 then
        p390 = 25
      else
        p390 = 24
      end
    end
    if p390 == 24 then
      c83v10 = false
      p390 = 26
    end
    if p390 == 25 then
      c83v10 = true
      p390 = 26
    end
    if p390 == 26 then
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = mMovie
      c83v8 = "Popup.IngredientsSeparator"
      c83v9 = 13
      c83v10 = false
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = mMovie
      c83v8 = "Popup.IngredientsSecondary"
      c83v9 = 13
      c83v10 = false
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = mMovie
      c83v8 = "Popup.PrereqSeparator"
      c83v9 = 13
      c83v11 = v63
      c83v12 = v64
      c83v12 = c83v12.CRAFTING
      if c83v11 == c83v12 then
        p390 = 28
      else
        p390 = 27
      end
    end
    if p390 == 27 then
      c83v10 = false
      p390 = 29
    end
    if p390 == 28 then
      c83v10 = true
      p390 = 29
    end
    if p390 == 29 then
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = mMovie
      c83v8 = "Popup.PrereqSeparator.Separator"
      c83v9 = 13
      c83v11 = v63
      c83v12 = v64
      c83v12 = c83v12.CRAFTING
      if c83v11 ~= c83v12 then
        p390 = 31
      else
        p390 = 30
      end
    end
    if p390 == 30 then
      c83v10 = false
      p390 = 32
    end
    if p390 == 31 then
      c83v10 = true
      p390 = 32
    end
    if p390 == 32 then
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = mMovie
      c83v8 = "Popup.Prerequisite"
      c83v9 = 13
      c83v10 = false
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = mMovie
      c83v8 = "Popup.RankedProgress"
      c83v9 = 13
      c83v10 = false
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = mMovie
      c83v8 = "Popup.Affiliation1"
      c83v9 = 13
      c83v10 = false
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = mMovie
      c83v8 = "Popup.GenericIcon"
      c83v9 = 13
      c83v10 = false
      c83v6:Name__d9713943(c83v8, c83v9, c83v10)
      c83v6 = 1
      c83v7 = 0
      c83v8 = ""
      c83v9 = ""
      v24 = c83v9
      c83v9 = 0
      v27 = c83v9
      c83v9 = 10
      v28 = c83v9
      c83v9 = {}
      v33 = c83v9
      c83v9 = v33
      c83v10 = {}
      c83v9.Labels = c83v10
      c83v9 = v33
      c83v10 = {}
      c83v9.Values = c83v10
      c83v9 = v2
      c83v9 = c83v9.Ternary
      c83v11 = v17
      c83v11 = c83v11.StatWeapon
      if c83v11 ~= nil then
        p390 = 34
      else
        p390 = 33
      end
    end
    if p390 == 33 then
      c83v10 = false
      p390 = 35
    end
    if p390 == 34 then
      c83v10 = true
      p390 = 35
    end
    if p390 == 35 then
      c83v11 = v17
      c83v11 = c83v11.StatWeapon
      c83v9 = c83v9(c83v10, c83v11, c83v0)
      c83v10 = v63
      c83v11 = v64
      c83v11 = c83v11.STATS
      if c83v10 == c83v11 then
        p390 = 38
      else
        p390 = 36
      end
    end
    if p390 == 36 then
      c83v10 = v17
      c83v10 = c83v10.AllInOne
      if not c83v10 then
        p390 = 57
      else
        p390 = 37
      end
    end
    if p390 == 37 then
      c83v10 = v18
      c83v10 = c83v10.mStatsAvailable
      if not c83v10 then
        p390 = 57
      else
        p390 = 38
      end
    end
    if p390 == 38 then
      c83v10 = v2
      c83v10 = c83v10.Ternary
      c83v12 = v17
      c83v12 = c83v12.StatOwner
      if c83v12 ~= nil then
        p390 = 40
      else
        p390 = 39
      end
    end
    if p390 == 39 then
      c83v11 = false
      p390 = 41
    end
    if p390 == 40 then
      c83v11 = true
      p390 = 41
    end
    if p390 == 41 then
      c83v12 = v17
      c83v12 = c83v12.StatOwner
      c83v13 = nil
      c83v10 = c83v10(c83v11, c83v12, c83v13)
      c83v11 = true
      c83v13 = v17
      c83v13 = c83v13.StatWeapon
      c83v12 = IsNull
      c83v12 = c83v12(c83v13)
      if not c83v12 then
        p390 = 46
      else
        p390 = 42
      end
    end
    if p390 == 42 then
      c83v12 = v8
      c83v12 = c83v12.GetModularType
      c83v13 = v41
      c83v12, c83v13 = c83v12(c83v13)
      if c83v12 == nil then
        p390 = 44
      else
        p390 = 43
      end
    end
    if p390 == 43 then
      c83v11 = false
      p390 = 46
    end
    if p390 == 44 then
      c83v14 = v17
      c83v14 = c83v14.IsAmp
      if not c83v14 then
        p390 = 46
      else
        p390 = 45
      end
    end
    if p390 == 45 then
      c83v14 = v17
      c83v14 = c83v14.RawItem
      c83v15 = gRegion
      c83v17 = Type
      c83v17 = c83v17(c83v9)
      c83v19 = 0
      c83v9 = c83v15:CreateObject(c83v17, c83v10, c83v19)
      c83v9:SetOwner(c83v10)
      c83v17 = c83v14.mModularParts
      c83v20 = 3
      c83v9:SetModularParts(c83v17, c83v14:HasFeature(c83v20))
      p390 = 46
    end
    if p390 == 46 then
      if c83v11 then
        p390 = 48
      else
        p390 = 47
      end
    end
    if p390 == 47 then
      c83v12 = v33
      c83v14 = mMovie
      c83v16 = "/Lotus/Language/Menu/StatsUnavailable"
      c83v17 = false
      c83v13 = {c83v14:GetLocalized(c83v16, c83v17)}
      c83v12.Labels = c83v13
      c83v12 = v33
      c83v14 = ""
      c83v13 = {c83v14}
      c83v12.Values = c83v13
      p390 = 53
    end
    if p390 == 48 then
      c83v12 = IsNull
      c83v12 = c83v12(c83v9)
      if c83v12 then
        p390 = 53
      else
        p390 = 49
      end
    end
    if p390 == 49 then
      c83v12 = v4
      c83v12 = c83v12.GetDisplayStats
      c83v13 = c83v9
      c83v14 = true
      c83v15 = c83v10
      c83v16 = v2
      c83v16 = c83v16.Ternary
      c83v18 = v30
      if c83v18 == nil then
        p390 = 51
      else
        p390 = 50
      end
    end
    if p390 == 50 then
      c83v17 = false
      p390 = 52
    end
    if p390 == 51 then
      c83v17 = true
      p390 = 52
    end
    if p390 == 52 then
      c83v18 = 1
      c83v19 = v30
      c83v12 = c83v12(c83v13, c83v14, c83v15, c83v16(c83v17, c83v18, c83v19))
      v33 = c83v12
      p390 = 53
    end
    if p390 == 53 then
      c83v13 = v17
      c83v13 = c83v13.StatWeapon
      c83v12 = IsNull
      c83v12 = c83v12(c83v13)
      if not c83v12 then
        p390 = 56
      else
        p390 = 54
      end
    end
    if p390 == 54 then
      c83v12 = v17
      c83v12 = c83v12.IsAmp
      if not c83v12 then
        p390 = 56
      else
        p390 = 55
      end
    end
    if p390 == 55 then
      c83v12 = gRegion
      c83v12:DestroyObject(c83v9)
      c83v9 = c83v0
      p390 = 56
    end
    if p390 == 56 then
      c83v12 = mMovie
      c83v14 = "Popup.ItemStats"
      c83v15 = 12
      c83v16 = 0
      c83v12:SetNumberVariable(c83v14, c83v15, c83v16)
      c83v12 = FlashInterpolate
      c83v13 = mMovie
      c83v14 = "Popup.ItemStats"
      c83v15 = 8
      c83v17 = 12
      c83v16 = {c83v17}
      c83v18 = 100
      c83v17 = {c83v18}
      c83v18 = 0.2
      c83v12(c83v13, c83v14, c83v15, c83v16, c83v17, c83v18)
      p390 = 57
    end
    if p390 == 57 then
      c83v10 = v33
      c83v11 = {}
      c83v10.BaseValues = c83v11
      c83v10 = v33
      c83v11 = {}
      c83v10.StatChanges = c83v11
      c83v11 = v17
      c83v11 = c83v11.StatWeapon
      c83v10 = IsNull
      c83v10 = c83v10(c83v11)
      if not c83v10 then
        p390 = 82
      else
        p390 = 58
      end
    end
    if p390 == 58 then
      c83v10 = IsNull
      c83v10 = c83v10(c83v9)
      if c83v10 then
        p390 = 82
      else
        p390 = 59
      end
    end
    if p390 == 59 then
      c83v10 = v17
      c83v10 = c83v10.Category
      c83v11 = 43
      if c83v10 == c83v11 then
        p390 = 61
      else
        p390 = 60
      end
    end
    if p390 == 60 then
      c83v10 = v17
      c83v10 = c83v10.Category
      c83v11 = 46
      if c83v10 ~= c83v11 then
        p390 = 82
      else
        p390 = 61
      end
    end
    if p390 == 61 then
      c83v10 = c83v2:GetItem()
      c83v12 = v17
      c83v12 = c83v12.ResultItemType
      c83v11 = IsNull
      c83v11 = c83v11(c83v12)
      if c83v11 then
        p390 = 63
      else
        p390 = 62
      end
    end
    if p390 == 62 then
      c83v11 = v17
      c83v10 = c83v11.ResultItemType
      p390 = 69
    end
    if p390 == 63 then
      c83v11 = v17
      c83v11 = c83v11.RawItem
      if c83v11 == nil then
        p390 = 69
      else
        p390 = 64
      end
    end
    if p390 == 64 then
      c83v11 = v17
      c83v11 = c83v11.RawItem
      c83v13 = c83v11.mUpgradeType
      c83v12 = IsNull
      c83v12 = c83v12(c83v13)
      if not c83v12 then
        p390 = 67
      else
        p390 = 65
      end
    end
    if p390 == 65 then
      c83v13 = c83v11.Item
      c83v12 = IsNull
      c83v12 = c83v12(c83v13)
      if c83v12 then
        p390 = 67
      else
        p390 = 66
      end
    end
    if p390 == 66 then
      c83v11 = c83v11.Item
      p390 = 67
    end
    if p390 == 67 then
      c83v13 = c83v11.mUpgradeType
      c83v12 = IsNull
      c83v12 = c83v12(c83v13)
      if c83v12 then
        p390 = 69
      else
        p390 = 68
      end
    end
    if p390 == 68 then
      c83v12 = Lotus_Game.UpgradeInfo
      c83v12 = c83v12()
      c83v13 = c83v11.mUpgradeType
      c83v12.mItemType = c83v13
      c83v10 = c83v12.mInstance
      p390 = 69
    end
    if p390 == 69 then
      c83v11 = Resource
      c83v11 = c83v11(c83v10)
      c83v12 = ""
      c83v13 = v17
      if c83v13 == nil then
        p390 = 74
      else
        p390 = 70
      end
    end
    if p390 == 70 then
      c83v13 = v17
      c83v13 = c83v13.RawItem
      if c83v13 == nil then
        p390 = 74
      else
        p390 = 71
      end
    end
    if p390 == 71 then
      c83v13 = v17
      c83v13 = c83v13.RawItem
      c83v12 = c83v13.mUpgradeFingerprint
      c83v13 = #c83v12
      if c83v13 ~= 0 then
        p390 = 74
      else
        p390 = 72
      end
    end
    if p390 == 72 then
      c83v13 = v17
      c83v13 = c83v13.RawItem
      c83v13 = c83v13.Item
      if c83v13 == nil then
        p390 = 74
      else
        p390 = 73
      end
    end
    if p390 == 73 then
      c83v13 = v17
      c83v13 = c83v13.RawItem
      c83v13 = c83v13.Item
      c83v12 = c83v13.mUpgradeFingerprint
      p390 = 74
    end
    if p390 == 74 then
      if c83v12 ~= nil then
        p390 = 76
      else
        p390 = 75
      end
    end
    if p390 == 75 then
      c83v12 = ""
      p390 = 76
    end
    if p390 == 76 then
      c83v13 = IsNull
      c83v13 = c83v13(c83v11)
      if c83v13 then
        p390 = 82
      else
        p390 = 77
      end
    end
    if p390 == 77 then
      c83v15 = gLotusWeaponUpgradeBaseType
      c83v13 = c83v11:IsA(c83v15)
      if not c83v13 then
        p390 = 82
      else
        p390 = 78
      end
    end
    if p390 == 78 then
      c83v13 = c83v11:Name__0f7cb43a(c83v12)
      c83v14 = { mUpgradeType = nil, mDesc = "" }
      c83v14.mUpgradeType = c83v3
      c83v15 = v9
      c83v15 = c83v15.UpdateCrewShipCard
      c83v18 = mMovie
      c83v15(c83v14, c83v13, c83v18)
      c83v8 = c83v14.mDesc
      if c83v8 == "" then
        p390 = 82
      else
        p390 = 79
      end
    end
    if p390 == 79 then
      c83v15 = StringSplit
      c83v16 = "\r\n"
      c83v15 = c83v15(c83v16, c83v8)
      c83v16 = { Values = nil, Labels = nil, CompareValues = nil }
      c83v17 = {}
      c83v16.Values = c83v17
      c83v17 = {}
      c83v16.Labels = c83v17
      c83v17 = {}
      c83v16.CompareValues = c83v17
      c83v19 = 1
      c83v17 = #c83v15
      c83v18 = 1
      if (c83v18 > 0 and c83v19 > c83v17) or (c83v18 < 0 and c83v19 < c83v17) then
        p390 = 81
      else
        p390 = 80
      end
    end
    if p390 == 80 then
      c83v21 = string.match
      c83v22 = c83v15[c83v19]
      c83v23 = "%p*%d*%.?%d+[^%s]*"
      c83v21 = c83v21(c83v22, c83v23)
      c83v20 = c83v21 or 0
      c83v22 = c83v16.Values
      c83v21 = table.insert
      c83v21(c83v22, c83v20)
      c83v22 = c83v16.CompareValues
      c83v24 = string.match
      c83v26 = "%d*%.?%d+"
      c83v23 = tonumber
      c83v23 = c83v23(c83v24(c83v20, c83v26))
      c83v21 = table.insert
      c83v21(c83v22, c83v23)
      c83v21 = c83v20
      c83v22 = string.gsub
      c83v24 = "[%(%)%.%%%+%-%*%?%[%]%^%$]"
      c83v25 = "%%%0"
      c83v20 = c83v22(c83v21, c83v24, c83v25)
      c83v21 = string.gsub
      c83v22 = c83v15[c83v19]
      c83v24 = "[STAT]"
      c83v21 = c83v21(c83v22, c83v20, c83v24)
      c83v23 = c83v16.Labels
      c83v22 = table.insert
      c83v22(c83v23, c83v21)
      p390 = 81
    end
    if p390 == 81 then
      c83v17 = v33
      c83v17.BonusStats = c83v16
      p390 = 82
    end
    if p390 == 82 then
      c83v10 = v17
      c83v10 = c83v10.NumItemPopupPages
      if not c83v10 then
        p390 = 86
      else
        p390 = 83
      end
    end
    if p390 == 83 then
      c83v11 = v17
      c83v11 = c83v11.NumItemPopupPages
      c83v12 = 1
      if c83v12 < c83v11 then
        p390 = 85
      else
        p390 = 84
      end
    end
    if p390 == 84 then
      c83v10 = false
      p390 = 86
    end
    if p390 == 85 then
      c83v10 = true
      p390 = 86
    end
    if p390 == 86 then
      c83v11 = v63
      c83v12 = v64
      c83v12 = c83v12.BASE
      if c83v11 ~= c83v12 then
        p390 = 88
      else
        p390 = 87
      end
    end
    if p390 == 87 then
      c83v11 = v109
      c83v6, c83v8, c83v7 = c83v11(c83v1, c83v6, c83v2, c83v8, c83v3, c83v4, c83v0, c83v7, c83v10)
      p390 = 102
    end
    if p390 == 88 then
      c83v11 = v63
      c83v12 = v64
      c83v12 = c83v12.CRAFTING
      if c83v11 ~= c83v12 then
        p390 = 93
      else
        p390 = 89
      end
    end
    if p390 == 89 then
      c83v12 = v21
      c83v11 = c83v12 - 13
      v21 = c83v11
      c83v11 = mMovie
      c83v13 = "Popup.PrereqSeparator"
      c83v14 = 1
      c83v15 = v21
      c83v11:SetNumberVariable(c83v13, c83v14, c83v15)
      c83v13 = v21
      c83v14 = mMovie
      c83v16 = "Popup.PrereqSeparator.Description"
      c83v17 = 41
      c83v14 = c83v14:GetNumberVariable(c83v16, c83v17)
      c83v12 = c83v13 + c83v14
      c83v11 = c83v12 + 21
      v21 = c83v11
      c83v11 = v107
      c83v11()
      c83v11 = mMovie
      c83v13 = "Popup.Ingredients"
      c83v14 = 1
      c83v15 = v21
      c83v11:SetNumberVariable(c83v13, c83v14, c83v15)
      c83v11 = 0
      c83v12 = ipairs
      c83v13 = v43
      c83v13 = c83v13.mElements
      c83v12, c83v13, c83v14 = c83v12(c83v13)
      p390 = 91
    end
    if p390 == 90 then
      c83v17 = c83v11 + 5
      c83v19 = v43
      c83v19 = c83v19.mForcedVerticalSeparation
      c83v21 = c83v16.mHeight
      c83v20 = c83v21 or 0
      c83v18 = math.max
      c83v18 = c83v18(c83v19, c83v20)
      c83v11 = c83v17 + c83v18
      p390 = 91
    end
    if p390 == 91 then
      p390 = 92
    end
    if p390 == 92 then
      c83v15 = v21
      c83v16 = mMovie
      c83v18 = "Popup.Ingredients.ingredient"
      c83v19 = 1
      c83v16 = c83v16:GetNumberVariable(c83v18, c83v19)
      c83v14 = c83v15 + c83v16
      c83v13 = c83v14 + c83v11
      c83v12 = c83v13 - 10
      v21 = c83v12
      p390 = 102
    end
    if p390 == 93 then
      c83v11 = v63
      c83v12 = v64
      c83v12 = c83v12.INFO
      if c83v11 ~= c83v12 then
        p390 = 102
      else
        p390 = 94
      end
    end
    if p390 == 94 then
      c83v11 = IsNull
      c83v11 = c83v11(c83v1)
      if c83v11 then
        p390 = 97
      else
        p390 = 95
      end
    end
    if p390 == 95 then
      c83v11 = c83v1.AdditionalTabInfo
      if c83v11 == nil then
        p390 = 97
      else
        p390 = 96
      end
    end
    if p390 == 96 then
      c83v11 = c83v1.AdditionalTabInfo
      c83v12 = v17
      c83v11 = c83v11(c83v12)
      v24 = c83v11
      p390 = 97
    end
    if p390 == 97 then
      c83v12 = v24
      c83v11 = type
      c83v11 = c83v11(c83v12)
      if c83v11 == "string" then
        p390 = 99
      else
        p390 = 98
      end
    end
    if p390 == 98 then
      c83v11 = print
      c83v13 = "AdditionalTabInfo returned "
      c83v17 = v24
      c83v16 = type
      c83v14 = c83v16(c83v17)
      c83v15 = ", should be string"
      c83v12 = c83v13 .. c83v14 .. c83v15
      c83v11(c83v12)
      c83v11 = ""
      v24 = c83v11
      p390 = 99
    end
    if p390 == 99 then
      c83v12 = v21
      c83v11 = c83v12 - 2
      v21 = c83v11
      c83v11 = mMovie
      c83v13 = "Popup.Description"
      c83v14 = 1
      c83v15 = v21
      c83v11:SetNumberVariable(c83v13, c83v14, c83v15)
      c83v11 = mMovie
      c83v13 = "Popup.Description"
      c83v14 = 36
      c83v16 = "<p><font color=\""
      c83v17 = v61
      c83v17 = c83v17.ContentHex
      c83v18 = "\">"
      c83v19 = v24
      c83v20 = "</font></p>"
      c83v15 = c83v16 .. c83v17 .. c83v18 .. c83v19 .. c83v20
      c83v11:SetStringVariable(c83v13, c83v14, c83v15)
      c83v11 = v24
      if c83v11 == "" then
        p390 = 101
      else
        p390 = 100
      end
    end
    if p390 == 100 then
      c83v12 = v21
      c83v13 = mMovie
      c83v15 = "Popup.Description"
      c83v16 = 41
      c83v13 = c83v13:GetNumberVariable(c83v15, c83v16)
      c83v11 = c83v12 + c83v13
      v21 = c83v11
      p390 = 102
    end
    if p390 == 101 then
      c83v12 = v21
      c83v11 = c83v12 - 17
      v21 = c83v11
      p390 = 102
    end
    if p390 == 102 then
      c83v11 = true
      c83v12 = v63
      c83v13 = v64
      c83v13 = c83v13.ABILITIES
      if c83v12 == c83v13 then
        p390 = 108
      else
        p390 = 103
      end
    end
    if p390 == 103 then
      c83v12 = v17
      c83v12 = c83v12.AllInOne
      if not c83v12 then
        p390 = 105
      else
        p390 = 104
      end
    end
    if p390 == 104 then
      c83v12 = v18
      c83v12 = c83v12.mAbilitiesAvailable
      p390 = 105
    end
    if p390 == 105 then
      if c83v12 == true then
        p390 = 107
      else
        p390 = 106
      end
    end
    if p390 == 106 then
      c83v11 = false
      p390 = 108
    end
    if p390 == 107 then
      c83v11 = true
      p390 = 108
    end
    if p390 == 108 then
      c83v12 = mMovie
      c83v14 = "Popup.AbilityInfo"
      c83v15 = 13
      c83v12:Name__d9713943(c83v14, c83v15, c83v11)
      if not c83v11 then
        p390 = 127
      else
        p390 = 109
      end
    end
    if p390 == 109 then
      c83v12 = mMovie
      c83v14 = "Popup.AbilityInfo.Ability1"
      c83v15 = 1
      c83v12 = c83v12:GetNumberVariable(c83v14, c83v15)
      c83v13 = mMovie
      c83v15 = "Popup.AbilityInfo"
      c83v16 = 1
      c83v17 = v21
      c83v13:SetNumberVariable(c83v15, c83v16, c83v17)
      c83v13 = IsNull
      c83v13 = c83v13(c83v0)
      if not c83v13 then
        p390 = 111
      else
        p390 = 110
      end
    end
    if p390 == 110 then
      c83v13 = print
      c83v14 = "WARNING: no suit for ability info!"
      c83v13(c83v14)
      p390 = 127
    end
    if p390 == 111 then
      c83v14 = v5
      c83v14 = c83v14.GetPowerSuitStats
      c83v15 = mMovie
      c83v16 = nil
      c83v14 = c83v14(c83v15, c83v16, c83v0)
      c83v13 = c83v14[1]
      c83v13 = c83v13.mStats
      c83v14 = v17
      c83v14 = c83v14.mIsNemesis
      if not c83v14 then
        p390 = 114
      else
        p390 = 112
      end
    end
    if p390 == 112 then
      c83v14 = Resource
      c83v15 = v17
      c83v15 = c83v15.mExtraAbility
      c83v14 = c83v14(c83v15)
      c83v15 = IsNull
      c83v15 = c83v15(c83v14)
      if c83v15 then
        p390 = 114
      else
        p390 = 113
      end
    end
    if p390 == 113 then
      c83v15 = mMovie
      c83v17 = c83v14:GetLocalizeTag()
      c83v17 = c83v17:c_str()
      c83v18 = false
      c83v15 = c83v15:GetLocalized(c83v17, c83v18)
      c83v13.Ability4 = c83v15
      c83v15 = mMovie
      c83v17 = c83v14:GetLocalizeDescTag()
      c83v17 = c83v17:c_str()
      c83v18 = true
      c83v15 = c83v15:GetLocalized(c83v17, c83v18)
      c83v13.AbilityDescription4 = c83v15
      c83v15 = c83v14:GetIconTexture()
      c83v13.AbilityIcon4 = c83v15
      c83v13.AbilityType4 = c83v14
      p390 = 114
    end
    if p390 == 114 then
      c83v16 = 1
      c83v14 = 4
      c83v15 = 1
      if (c83v15 > 0 and c83v16 > c83v14) or (c83v15 < 0 and c83v16 < c83v14) then
        p390 = 118
      else
        p390 = 115
      end
    end
    if p390 == 115 then
      c83v18 = "Popup.AbilityInfo.Ability"
      c83v19 = tostring
      c83v19 = c83v19(c83v16)
      c83v17 = c83v18 .. c83v19
      c83v20 = "Ability"
      c83v19 = c83v20 .. c83v16
      c83v18 = c83v13[c83v19]
      if c83v18 == nil then
        p390 = 117
      else
        p390 = 116
      end
    end
    if p390 == 116 then
      c83v18 = mMovie
      c83v21 = 1
      c83v18:SetNumberVariable(c83v17, c83v21, c83v12)
      c83v18 = mMovie
      c83v22 = ".Name"
      c83v20 = c83v17 .. c83v22
      c83v21 = 36
      c83v22 = string.upper
      c83v25 = "Ability"
      c83v24 = c83v25 .. c83v16
      c83v23 = c83v13[c83v24]
      c83v18:SetStringVariable(c83v20, c83v21, c83v22(c83v23))
      c83v18 = v2
      c83v18 = c83v18.SetFitText
      c83v19 = mMovie
      c83v22 = ".Description"
      c83v20 = c83v17 .. c83v22
      c83v21 = "..."
      c83v18(c83v19, c83v20, c83v21)
      c83v18 = mMovie
      c83v21 = "Description"
      c83v22 = 91
      c83v23 = 6
      c83v18:Name__52c1b74e(c83v17, c83v21, c83v22, c83v23)
      c83v18 = mMovie
      c83v22 = ".Description"
      c83v20 = c83v17 .. c83v22
      c83v21 = 36
      c83v24 = "AbilityDescription"
      c83v23 = c83v24 .. c83v16
      c83v22 = c83v13[c83v23]
      c83v18:SetStringVariable(c83v20, c83v21, c83v22)
      c83v20 = "AbilityIcon"
      c83v19 = c83v20 .. c83v16
      c83v18 = c83v13[c83v19]
      c83v19 = mMovie
      c83v23 = ".Icon"
      c83v21 = c83v17 .. c83v23
      c83v19:OverrideTexture(c83v21, c83v18)
      c83v19 = mMovie
      c83v22 = "Icon"
      c83v23 = 13
      c83v25 = IsNull
      c83v25 = c83v25(c83v18)
      c83v24 = not c83v25
      c83v19:Makeposshield(c83v17, c83v22, c83v23, c83v24)
      c83v19 = mMovie
      c83v23 = ".Name"
      c83v21 = c83v17 .. c83v23
      c83v22 = 41
      c83v19 = c83v19:GetNumberVariable(c83v21, c83v22)
      c83v20 = mMovie
      c83v24 = ".Description"
      c83v22 = c83v17 .. c83v24
      c83v23 = 41
      c83v20 = c83v20:GetNumberVariable(c83v22, c83v23)
      c83v22 = c83v12 + c83v19
      c83v21 = c83v22 + c83v20
      c83v12 = c83v21 + 20
      p390 = 117
    end
    if p390 == 117 then
      p390 = 118
    end
    if p390 == 118 then
      c83v12 = c83v12 + 4
      c83v14 = ""
      c83v16 = gRegion
      c83v15 = IsNull
      c83v15 = c83v15(c83v16)
      if c83v15 then
        p390 = 121
      else
        p390 = 119
      end
    end
    if p390 == 119 then
      c83v15 = v17
      c83v15 = c83v15.mIsNemesis
      if c83v15 then
        p390 = 121
      else
        p390 = 120
      end
    end
    if p390 == 120 then
      c83v15 = v7
      c83v15 = c83v15.GetPassiveDescription
      c83v16 = mMovie
      c83v17 = gRegion
      c83v17 = c83v17:GetLocalPlayerAvatar()
      c83v14 = c83v15(c83v16, c83v17, c83v0)
      p390 = 121
    end
    if p390 == 121 then
      if c83v14 ~= "" then
        p390 = 123
      else
        p390 = 122
      end
    end
    if p390 == 122 then
      c83v15 = false
      p390 = 124
    end
    if p390 == 123 then
      c83v15 = true
      p390 = 124
    end
    if p390 == 124 then
      c83v16 = mMovie
      c83v18 = "Popup.AbilityInfo.Passive"
      c83v19 = 13
      c83v16:Name__d9713943(c83v18, c83v19, c83v15)
      c83v16 = mMovie
      c83v18 = "Popup.AbilityInfo.PassiveSeparator"
      c83v19 = 13
      c83v16:Name__d9713943(c83v18, c83v19, c83v15)
      if not c83v15 then
        p390 = 126
      else
        p390 = 125
      end
    end
    if p390 == 125 then
      c83v16 = mMovie
      c83v18 = "Popup.AbilityInfo.Passive.Name.text"
      c83v19 = "/Lotus/Language/Menu/Ability_Passive"
      c83v16:SetLocalized(c83v18, c83v19)
      c83v16 = v2
      c83v16 = c83v16.SetFitText
      c83v17 = mMovie
      c83v18 = "Popup.AbilityInfo.Passive.Description"
      c83v19 = "..."
      c83v16(c83v17, c83v18, c83v19)
      c83v16 = mMovie
      c83v18 = "Popup.AbilityInfo.Passive.Description"
      c83v19 = 91
      c83v20 = 6
      c83v16:SetNumberVariable(c83v18, c83v19, c83v20)
      c83v16 = mMovie
      c83v18 = "Popup.AbilityInfo.Passive.Description"
      c83v19 = 36
      c83v16:SetStringVariable(c83v18, c83v19, c83v14)
      c83v16 = mMovie
      c83v18 = "Popup.AbilityInfo.PassiveSeparator"
      c83v19 = 1
      c83v16:SetNumberVariable(c83v18, c83v19, c83v12)
      c83v16 = mMovie
      c83v18 = "Popup.AbilityInfo.Passive"
      c83v19 = 1
      c83v20 = c83v12 + 12
      c83v16:SetNumberVariable(c83v18, c83v19, c83v20)
      p390 = 126
    end
    if p390 == 126 then
      c83v18 = v21
      c83v17 = c83v18 + c83v12
      c83v18 = v2
      c83v18 = c83v18.Ternary
      c83v21 = mMovie
      c83v23 = "Popup.AbilityInfo.Passive.Description"
      c83v24 = 41
      c83v21 = c83v21:GetNumberVariable(c83v23, c83v24)
      c83v20 = c83v21 + 38
      c83v21 = -20
      c83v18 = c83v18(c83v15, c83v20, c83v21)
      c83v16 = c83v17 + c83v18
      v21 = c83v16
      p390 = 127
    end
    if p390 == 127 then
      if c83v8 == "" then
        p390 = 131
      else
        p390 = 128
      end
    end
    if p390 == 128 then
      c83v12 = v63
      c83v13 = v64
      c83v13 = c83v13.STATS
      if c83v12 ~= c83v13 then
        p390 = 130
      else
        p390 = 129
      end
    end
    if p390 == 129 then
      c83v12 = mMovie
      c83v14 = "Popup.Description"
      c83v15 = 1
      c83v16 = v21
      c83v12:SetNumberVariable(c83v14, c83v15, c83v16)
      c83v13 = v21
      c83v12 = c83v13 + 5
      v21 = c83v12
      p390 = 130
    end
    if p390 == 130 then
      c83v12 = mMovie
      c83v14 = "Popup.Description"
      c83v15 = 36
      c83v17 = "<p><font color=\""
      c83v18 = v61
      c83v18 = c83v18.ContentHex
      c83v19 = "\">"
      c83v21 = "</font></p>"
      c83v16 = c83v17 .. c83v18 .. c83v19 .. c83v8 .. c83v21
      c83v12:SetStringVariable(c83v14, c83v15, c83v16)
      c83v13 = v21
      c83v14 = mMovie
      c83v16 = "Popup.Description"
      c83v17 = 41
      c83v14 = c83v14:GetNumberVariable(c83v16, c83v17)
      c83v12 = c83v13 + c83v14
      v21 = c83v12
      c83v5 = true
      p390 = 131
    end
    if p390 == 131 then
      c83v12 = v32
      c83v13 = 1
      if c83v12 <= c83v13 then
        p390 = 135
      else
        p390 = 132
      end
    end
    if p390 == 132 then
      c83v13 = c83v7 + 1
      c83v14 = 2
      c83v12 = math.max
      c83v15 = c83v12(c83v13, c83v14)
      c83v13 = v32
      c83v14 = 1
      if (c83v14 > 0 and c83v15 > c83v13) or (c83v14 < 0 and c83v15 < c83v13) then
        p390 = 134
      else
        p390 = 133
      end
    end
    if p390 == 133 then
      c83v16 = FlashMethod
      c83v17 = mMovie
      c83v19 = "Popup.Affiliation"
      c83v21 = ".removeMovieClip"
      c83v18 = c83v19 .. c83v15 .. c83v21
      c83v16(c83v17, c83v18)
      p390 = 134
    end
    if p390 == 134 then
      c83v14 = 1
      c83v13 = math.max
      c83v13 = c83v13(c83v14, c83v7)
      v32 = c83v13
      p390 = 135
    end
    if p390 == 135 then
      c83v12 = false
      c83v13 = v17
      if not c83v13 then
        p390 = 137
      else
        p390 = 136
      end
    end
    if p390 == 136 then
      c83v13 = v17
      c83v13 = c83v13.mShowOnlyStats
      p390 = 137
    end
    if p390 == 137 then
      c83v15 = v33
      c83v15 = c83v15.Labels
      c83v14 = #c83v15
      c83v15 = 0
      if c83v14 <= c83v15 then
        p390 = 185
      else
        p390 = 138
      end
    end
    if p390 == 138 then
      c83v14 = v17
      c83v14 = c83v14.AreStatsBuried
      if not c83v14 then
        p390 = 140
      else
        p390 = 139
      end
    end
    if p390 == 139 then
      c83v14 = v18
      c83v14 = c83v14.mCurrentElementIndex
      c83v16 = v18
      c83v16 = c83v16.mElements
      c83v15 = #c83v16
      if c83v14 ~= c83v15 then
        p390 = 185
      else
        p390 = 140
      end
    end
    if p390 == 140 then
      c83v14 = v63
      c83v15 = v64
      c83v15 = c83v15.STATS
      if c83v14 == c83v15 then
        p390 = 142
      else
        p390 = 141
      end
    end
    if p390 == 141 then
      c83v15 = v21
      c83v16 = v2
      c83v16 = c83v16.Ternary
      c83v18 = 10
      c83v19 = 23
      c83v16 = c83v16(c83v13, c83v18, c83v19)
      c83v14 = c83v15 + c83v16
      v21 = c83v14
      p390 = 142
    end
    if p390 == 142 then
      c83v14 = v31
      c83v16 = v33
      c83v16 = c83v16.Labels
      c83v15 = type
      c83v15 = c83v15(c83v16)
      if c83v15 ~= "table" then
        p390 = 178
      else
        p390 = 143
      end
    end
    if p390 == 143 then
      c83v16 = v33
      c83v16 = c83v16.Labels
      c83v15 = #c83v16
      v31 = c83v15
      if not c83v10 then
        p390 = 156
      else
        p390 = 144
      end
    end
    if p390 == 144 then
      c83v15 = v17
      c83v15 = c83v15.AreStatsBuried
      if c83v15 then
        p390 = 156
      else
        p390 = 145
      end
    end
    if p390 == 145 then
      c83v15 = {}
      c83v16 = {}
      c83v17 = {}
      c83v18 = {}
      c83v19 = 0
      c83v22 = 1
      c83v20 = v31
      c83v21 = 1
      if (c83v21 > 0 and c83v22 > c83v20) or (c83v21 < 0 and c83v22 < c83v20) then
        p390 = 155
      else
        p390 = 146
      end
    end
    if p390 == 146 then
      c83v24 = v33
      c83v24 = c83v24.Labels
      c83v23 = c83v24[c83v22]
      if c83v23 == "" then
        p390 = 149
      else
        p390 = 147
      end
    end
    if p390 == 147 then
      c83v24 = v33
      c83v24 = c83v24.Values
      c83v23 = c83v24[c83v22]
      if c83v23 ~= "" then
        p390 = 149
      else
        p390 = 148
      end
    end
    if p390 == 148 then
      c83v19 = c83v19 + 1
      p390 = 149
    end
    if p390 == 149 then
      if c83v19 == 0 then
        p390 = 153
      else
        p390 = 150
      end
    end
    if p390 == 150 then
      c83v23 = v18
      c83v23 = c83v23.mCurrentElementIndex
      if c83v19 == c83v23 then
        p390 = 153
      else
        p390 = 151
      end
    end
    if p390 == 151 then
      c83v23 = v18
      c83v23 = c83v23.mCurrentElementIndex
      c83v25 = v18
      c83v25 = c83v25.mElements
      c83v24 = #c83v25
      if c83v23 ~= c83v24 then
        p390 = 154
      else
        p390 = 152
      end
    end
    if p390 == 152 then
      c83v23 = v18
      c83v23 = c83v23.mCurrentElementIndex
      if c83v19 <= c83v23 then
        p390 = 154
      else
        p390 = 153
      end
    end
    if p390 == 153 then
      c83v26 = v33
      c83v26 = c83v26.Labels
      c83v25 = c83v26[c83v22]
      c83v23 = table.insert
      c83v23(c83v15, c83v25)
      c83v26 = v33
      c83v26 = c83v26.Values
      c83v25 = c83v26[c83v22]
      c83v23 = table.insert
      c83v23(c83v16, c83v25)
      c83v26 = v33
      c83v26 = c83v26.BaseValues
      c83v25 = c83v26[c83v22]
      c83v23 = table.insert
      c83v23(c83v17, c83v25)
      c83v26 = v33
      c83v26 = c83v26.StatChanges
      c83v25 = c83v26[c83v22]
      c83v23 = table.insert
      c83v23(c83v18, c83v25)
      p390 = 154
    end
    if p390 == 154 then
      p390 = 155
    end
    if p390 == 155 then
      c83v20 = v33
      c83v20.Labels = c83v15
      c83v20 = v33
      c83v20.Values = c83v16
      c83v20 = v33
      c83v20.BaseValues = c83v17
      c83v20 = v33
      c83v20.StatChanges = c83v18
      c83v20 = #c83v15
      v31 = c83v20
      p390 = 156
    end
    if p390 == 156 then
      c83v15 = 0
      c83v18 = 1
      c83v16 = v31
      c83v17 = 1
      if (c83v17 > 0 and c83v18 > c83v16) or (c83v17 < 0 and c83v18 < c83v16) then
        p390 = 173
      else
        p390 = 157
      end
    end
    if p390 == 157 then
      c83v20 = "Popup.ItemStats.Item"
      c83v19 = c83v20 .. c83v18
      c83v20 = mMovie
      c83v20 = c83v20:HasVariable(c83v19)
      if c83v20 then
        p390 = 159
      else
        p390 = 158
      end
    end
    if p390 == 158 then
      c83v20 = FlashMethod
      c83v21 = mMovie
      c83v22 = "Popup.ItemStats.Item1.duplicateMovieClip"
      c83v24 = "Item"
      c83v23 = c83v24 .. c83v18
      c83v20(c83v21, c83v22, c83v23, c83v18)
      p390 = 159
    end
    if p390 == 159 then
      c83v21 = v33
      c83v21 = c83v21.Labels
      c83v20 = c83v21[c83v18]
      c83v21 = v84
      c83v23 = v33
      c83v23 = c83v23.Values
      c83v22 = c83v23[c83v18]
      c83v24 = v33
      c83v24 = c83v24.BaseValues
      c83v23 = c83v24[c83v18]
      c83v25 = v33
      c83v25 = c83v25.StatChanges
      c83v24 = c83v25[c83v18]
      c83v25 = true
      c83v21 = c83v21(c83v22, c83v23, c83v24, c83v25)
      c83v22 = mMovie
      c83v25 = 1
      c83v22:SetNumberVariable(c83v19, c83v25, c83v15)
      c83v22 = mMovie
      c83v25 = "Backer"
      c83v26 = 12
      c83v29 = c83v18 % 2
      c83v28 = c83v29 * 35
      c83v27 = 35 - c83v28
      c83v22:Name__52c1b74e(c83v19, c83v25, c83v26, c83v27)
      c83v22 = mMovie
      c83v25 = "Backer"
      c83v26 = 1
      c83v27 = 1
      c83v22:Name__52c1b74e(c83v19, c83v25, c83v26, c83v27)
      c83v22 = mMovie
      c83v25 = "Labels"
      c83v26 = 52
      c83v27 = false
      c83v22:Makeposshield(c83v19, c83v25, c83v26, c83v27)
      c83v22 = mMovie
      c83v26 = ".Labels"
      c83v24 = c83v19 .. c83v26
      c83v25 = 36
      c83v22:SetStringVariable(c83v24, c83v25, c83v20)
      c83v22 = mMovie
      c83v26 = ".Stats"
      c83v24 = c83v19 .. c83v26
      c83v25 = 36
      c83v22:SetStringVariable(c83v24, c83v25, c83v21)
      c83v22 = 1
      c83v23 = mMovie
      c83v27 = ".Labels"
      c83v25 = c83v19 .. c83v27
      c83v26 = 40
      c83v23 = c83v23:GetNumberVariable(c83v25, c83v26)
      c83v25 = mMovie
      c83v29 = ".Stats"
      c83v27 = c83v19 .. c83v29
      c83v28 = 40
      c83v25 = c83v25:GetNumberVariable(c83v27, c83v28)
      c83v24 = c83v25 + 20
      c83v24 = 330 - c83v24
      c83v26 = v33
      c83v26 = c83v26.Values
      c83v25 = c83v26[c83v18]
      if (not (c83v25 == "") and c83v24 < c83v23) then
        p390 = 162
      else
        p390 = 161
      end
    end
    if p390 == 161 then
      c83v25 = 330
      if c83v23 <= c83v25 then
        p390 = 163
      else
        p390 = 162
      end
    end
    if p390 == 162 then
      c83v25 = mMovie
      c83v28 = "Stats"
      c83v29 = 52
      c83v30 = true
      c83v25:Makeposshield(c83v19, c83v28, c83v29, c83v30)
      c83v25 = mMovie
      c83v28 = "Stats"
      c83v29 = 0
      c83v30 = 0
      c83v25:Name__52c1b74e(c83v19, c83v28, c83v29, c83v30)
      c83v25 = mMovie
      c83v28 = "Stats"
      c83v29 = 14
      c83v30 = 330
      c83v25:Name__52c1b74e(c83v19, c83v28, c83v29, c83v30)
      c83v25 = mMovie
      c83v29 = ".Stats"
      c83v27 = c83v19 .. c83v29
      c83v28 = 36
      c83v30 = "\r\n"
      c83v29 = c83v30 .. c83v21
      c83v25:SetStringVariable(c83v27, c83v28, c83v29)
      c83v25 = mMovie
      c83v29 = ".Stats"
      c83v27 = c83v19 .. c83v29
      c83v28 = 43
      c83v22 = c83v25:GetNumberVariable(c83v27, c83v28)
      p390 = 163
    end
    if p390 == 163 then
      c83v25 = mMovie
      c83v28 = "Backer"
      c83v29 = 14
      c83v25 = c83v25:Name__46690123(c83v19, c83v28, c83v29)
      if c83v23 <= c83v25 then
        p390 = 165
      else
        p390 = 164
      end
    end
    if p390 == 164 then
      c83v26 = mMovie
      c83v29 = "Labels"
      c83v30 = 14
      c83v31 = 310
      c83v26:Name__52c1b74e(c83v19, c83v29, c83v30, c83v31)
      c83v26 = mMovie
      c83v29 = "Labels"
      c83v30 = 52
      c83v31 = true
      c83v26:Makeposshield(c83v19, c83v29, c83v30, c83v31)
      p390 = 165
    end
    if p390 == 165 then
      c83v26 = 1
      c83v27 = 2
      c83v28 = 0
      if not c83v13 then
        p390 = 168
      else
        p390 = 166
      end
    end
    if p390 == 166 then
      c83v29 = v31
      if c83v18 ~= c83v29 then
        p390 = 168
      else
        p390 = 167
      end
    end
    if p390 == 167 then
      c83v27 = 10
      c83v28 = 10
      c83v29 = mMovie
      c83v33 = ".Labels"
      c83v31 = c83v19 .. c83v33
      c83v32 = 43
      c83v26 = c83v29:GetNumberVariable(c83v31, c83v32)
      c83v29 = mMovie
      c83v32 = "Labels"
      c83v33 = 1
      c83v36 = c83v26 - 1
      c83v35 = c83v36 * 23
      c83v34 = c83v35 + c83v27
      c83v29:Name__52c1b74e(c83v19, c83v32, c83v33, c83v34)
      p390 = 169
    end
    if p390 == 168 then
      c83v29 = mMovie
      c83v32 = "Labels"
      c83v33 = 1
      c83v34 = 2
      c83v29:Name__52c1b74e(c83v19, c83v32, c83v33, c83v34)
      p390 = 169
    end
    if p390 == 169 then
      c83v29 = c83v22 * 23
      c83v30 = #c83v20
      if c83v30 ~= 0 then
        p390 = 171
      else
        p390 = 170
      end
    end
    if p390 == 170 then
      c83v29 = 16
      p390 = 172
    end
    if p390 == 171 then
      c83v30 = mMovie
      c83v33 = "Stats"
      c83v34 = 1
      c83v37 = c83v22 - 1
      c83v36 = c83v37 * 23
      c83v35 = c83v36 + c83v27
      c83v30:Name__52c1b74e(c83v19, c83v33, c83v34, c83v35)
      p390 = 172
    end
    if p390 == 172 then
      c83v30 = mMovie
      c83v33 = "Backer"
      c83v34 = 15
      c83v35 = c83v29 + c83v28
      c83v30:Name__52c1b74e(c83v19, c83v33, c83v34, c83v35)
      c83v15 = c83v15 + c83v29
      p390 = 173
    end
    if p390 == 173 then
      c83v17 = _T.ItemInfoStatComparison
      c83v16 = IsNull
      c83v16 = c83v16(c83v17)
      if not c83v16 then
        p390 = 175
      else
        p390 = 174
      end
    end
    if p390 == 174 then
      p390 = 179
    end
    if p390 == 175 then
      c83v16 = v58
      if not c83v16 then
        p390 = 177
      else
        p390 = 176
      end
    end
    if p390 == 176 then
      c83v16 = _T.ItemInfoStatComparison
      c83v16()
      p390 = 179
    end
    if p390 == 177 then
      c83v16 = _T.ItemInfoStatComparison
      c83v17 = v33
      c83v18 = v85
      c83v16(c83v17, c83v18)
      p390 = 179
    end
    if p390 == 178 then
      c83v15 = 1
      v31 = c83v15
      c83v15 = mMovie
      c83v17 = "Popup.ItemStats.Item1.Backer"
      c83v18 = 12
      c83v19 = 0
      c83v15:SetNumberVariable(c83v17, c83v18, c83v19)
      c83v15 = mMovie
      c83v17 = "Popup.ItemStats.Item1.Labels"
      c83v18 = 36
      c83v19 = v33
      c83v19 = c83v19.Labels
      c83v15:SetStringVariable(c83v17, c83v18, c83v19)
      c83v15 = mMovie
      c83v17 = "Popup.ItemStats.Item1.Stats"
      c83v18 = 36
      c83v19 = v33
      c83v19 = c83v19.Values
      c83v15:SetStringVariable(c83v17, c83v18, c83v19)
      p390 = 179
    end
    if p390 == 179 then
      c83v15 = v31
      c83v16 = 0
      if c83v15 <= c83v16 then
        c83v12 = false
      else
        c83v12 = true
      end
      c83v19 = v31
      c83v18 = c83v19 + 1
      c83v19 = 2
      c83v17 = math.max
      c83v17 = c83v17(c83v18, c83v19)
      c83v15 = c83v14
      c83v16 = 1
      if c83v16 < c83v15 then
        for c83v17 = c83v17, c83v15, c83v16 do
          c83v18 = FlashMethod
          c83v19 = mMovie
          c83v21 = "Popup.ItemStats.Item"
          c83v23 = ".removeMovieClip"
          c83v20 = c83v21 .. c83v17 .. c83v23
          c83v18(c83v19, c83v20)
        end
      end
      p390 = 192
    end
    if p390 == 185 then
      c83v14 = v33
      c83v14 = c83v14.BonusStats
      if c83v14 == nil then
        p390 = 192
      else
        p390 = 186
      end
    end
    if p390 == 186 then
      c83v15 = v33
      c83v15 = c83v15.BonusStats
      c83v15 = c83v15.Labels
      c83v14 = #c83v15
      c83v15 = 0
      if c83v14 <= c83v15 then
        p390 = 192
      else
        p390 = 187
      end
    end
    if p390 == 187 then
      c83v15 = _T.ItemInfoStatComparison
      c83v14 = IsNull
      c83v14 = c83v14(c83v15)
      if not c83v14 then
        p390 = 189
      else
        p390 = 188
      end
    end
    if p390 == 188 then
      p390 = 192
    end
    if p390 == 189 then
      c83v14 = v58
      if not c83v14 then
        p390 = 191
      else
        p390 = 190
      end
    end
    if p390 == 190 then
      c83v14 = _T.ItemInfoStatComparison
      c83v14()
      p390 = 192
    end
    if p390 == 191 then
      c83v14 = _T.ItemInfoStatComparison
      c83v15 = v33
      c83v16 = v85
      c83v14(c83v15, c83v16)
      p390 = 192
    end
    if p390 == 192 then
      c83v14 = mMovie
      c83v16 = "Popup.Description"
      c83v17 = 13
      c83v14:Name__d9713943(c83v16, c83v17, c83v5)
      c83v14 = mMovie
      c83v16 = "Popup.ItemStats"
      c83v17 = 13
      c83v14:Name__d9713943(c83v16, c83v17, c83v12)
      if not c83v12 then
        p390 = 194
      else
        p390 = 193
      end
    end
    if p390 == 193 then
      c83v14 = mMovie
      c83v16 = "Popup.ItemStats"
      c83v17 = 1
      c83v18 = v21
      c83v14:SetNumberVariable(c83v16, c83v17, c83v18)
      c83v15 = v21
      c83v16 = mMovie
      c83v18 = "Popup.ItemStats"
      c83v19 = 15
      c83v16 = c83v16:GetNumberVariable(c83v18, c83v19)
      c83v14 = c83v15 + c83v16
      v21 = c83v14
      p390 = 194
    end
    if p390 == 194 then
      c83v14 = v102
      c83v14(c83v6)
      c83v14 = v80
      c83v14()
      c83v14 = 9
      if not c83v13 then
        p390 = 203
      else
        p390 = 195
      end
    end
    if p390 == 195 then
      c83v16 = Engine.IsPlayingWithTouchscreen
      c83v16 = c83v16()
      if c83v16 then
        p390 = 197
      else
        p390 = 196
      end
    end
    if p390 == 196 then
      c83v15 = false
      p390 = 201
    end
    if p390 == 197 then
      c83v16 = _T.InfoPopup_Grid
      if c83v16 == nil then
        p390 = 200
      else
        p390 = 198
      end
    end
    if p390 == 198 then
      c83v17 = c83v16.ShowSelectButton
      if c83v17 == nil then
        p390 = 200
      else
        p390 = 199
      end
    end
    if p390 == 199 then
      c83v17 = c83v16.ShowSelectButton
      c83v18 = _T.InfoPopup_Data
      c83v15 = c83v17(c83v18)
      p390 = 201
    end
    if p390 == 200 then
      c83v15 = false
      p390 = 201
    end
    if p390 == 201 then
      if c83v15 then
        p390 = 203
      else
        p390 = 202
      end
    end
    if p390 == 202 then
      c83v14 = 2
      p390 = 238
    end
    if p390 == 203 then
      c83v16 = Engine.IsPlayingWithTouchscreen
      c83v16 = c83v16()
      if c83v16 then
        p390 = 205
      else
        p390 = 204
      end
    end
    if p390 == 204 then
      c83v15 = false
      p390 = 209
    end
    if p390 == 205 then
      c83v16 = _T.InfoPopup_Grid
      if c83v16 == nil then
        p390 = 208
      else
        p390 = 206
      end
    end
    if p390 == 206 then
      c83v17 = c83v16.ShowSelectButton
      if c83v17 == nil then
        p390 = 208
      else
        p390 = 207
      end
    end
    if p390 == 207 then
      c83v17 = c83v16.ShowSelectButton
      c83v18 = _T.InfoPopup_Data
      c83v15 = c83v17(c83v18)
      p390 = 209
    end
    if p390 == 208 then
      c83v15 = false
      p390 = 209
    end
    if p390 == 209 then
      if not c83v15 then
        p390 = 211
      else
        p390 = 210
      end
    end
    if p390 == 210 then
      c83v15 = mMovie
      c83v17 = "Popup.SelectButton"
      c83v18 = 15
      c83v15 = c83v15:GetNumberVariable(c83v17, c83v18)
      c83v14 = c83v14 + c83v15
      p390 = 237
    end
    if p390 == 211 then
      c83v15 = v2
      c83v15 = c83v15.Ternary
      c83v18 = _T.InfoPopup_Grid
      c83v19 = false
      if c83v18 == nil then
        p390 = 213
      else
        p390 = 212
      end
    end
    if p390 == 212 then
      c83v19 = c83v18.CanPreviewElements
      p390 = 213
    end
    if p390 == 213 then
      c83v20 = v17
      if c83v20 == nil then
        p390 = 218
      else
        p390 = 214
      end
    end
    if p390 == 214 then
      c83v20 = v17
      c83v20 = c83v20.CanPreviewOverride
      if c83v20 == nil then
        p390 = 218
      else
        p390 = 215
      end
    end
    if p390 == 215 then
      c83v20 = c83v19
      if not c83v20 then
        p390 = 217
      else
        p390 = 216
      end
    end
    if p390 == 216 then
      c83v20 = v17
      c83v20 = c83v20.CanPreviewOverride
      p390 = 217
    end
    if p390 == 217 then
      c83v19 = c83v20
      p390 = 218
    end
    if p390 == 218 then
      c83v17 = c83v19
      if c83v17 then
        p390 = 229
      else
        p390 = 219
      end
    end
    if p390 == 219 then
      c83v17 = false
      c83v18 = v17
      if c83v18 == nil then
        p390 = 223
      else
        p390 = 220
      end
    end
    if p390 == 220 then
      c83v18 = v17
      c83v18 = c83v18.mUnequipItem
      if c83v18 ~= nil then
        p390 = 222
      else
        p390 = 221
      end
    end
    if p390 == 221 then
      c83v17 = false
      p390 = 223
    end
    if p390 == 222 then
      c83v17 = true
      p390 = 223
    end
    if p390 == 223 then
      if c83v17 then
        p390 = 229
      else
        p390 = 224
      end
    end
    if p390 == 224 then
      c83v16 = false
      c83v17 = v17
      if c83v17 == nil then
        p390 = 228
      else
        p390 = 225
      end
    end
    if p390 == 225 then
      c83v17 = v17
      c83v17 = c83v17.RightPressedCallback
      if c83v17 ~= nil then
        p390 = 227
      else
        p390 = 226
      end
    end
    if p390 == 226 then
      c83v16 = false
      p390 = 228
    end
    if p390 == 227 then
      c83v16 = true
      p390 = 228
    end
    if p390 == 228 then
      if not c83v16 then
        p390 = 236
      else
        p390 = 229
      end
    end
    if p390 == 229 then
      c83v18 = Engine.IsPlayingWithTouchscreen
      c83v18 = c83v18()
      if c83v18 then
        p390 = 231
      else
        p390 = 230
      end
    end
    if p390 == 230 then
      c83v17 = false
      p390 = 235
    end
    if p390 == 231 then
      c83v18 = _T.InfoPopup_Grid
      if c83v18 == nil then
        p390 = 234
      else
        p390 = 232
      end
    end
    if p390 == 232 then
      c83v19 = c83v18.ShowSelectButton
      if c83v19 == nil then
        p390 = 234
      else
        p390 = 233
      end
    end
    if p390 == 233 then
      c83v19 = c83v18.ShowSelectButton
      c83v20 = _T.InfoPopup_Data
      c83v17 = c83v19(c83v20)
      p390 = 235
    end
    if p390 == 234 then
      c83v17 = false
      p390 = 235
    end
    if p390 == 235 then
      c83v16 = not c83v17
      p390 = 236
    end
    if p390 == 236 then
      c83v17 = 25
      c83v18 = 0
      c83v15 = c83v15(c83v16, c83v17, c83v18)
      c83v14 = c83v14 + c83v15
      p390 = 237
    end
    if p390 == 237 then
      c83v17 = v21
      c83v16 = c83v17 + 10
      c83v15 = c83v16 + c83v14
      v21 = c83v15
      p390 = 238
    end
    if p390 == 238 then
      c83v15 = v103
      c83v15(c83v14)
      do return end
    end
  end
  v110 = function()
    local c84v0, c84v1, c84v2, c84v3, c84v4, c84v5, c84v6, c84v7, c84v8, c84v9, c84v10, c84v11, c84v12
    local p118 = 0
    if p118 == 0 then
      c84v1 = v60
      if c84v1 ~= "" then
        p118 = 2
      else
        p118 = 1
      end
    end
    if p118 == 1 then
      c84v0 = false
      p118 = 3
    end
    if p118 == 2 then
      c84v0 = true
      p118 = 3
    end
    if p118 == 3 then
      c84v1 = mMovie
      c84v3 = "Popup.Header"
      c84v4 = 13
      c84v1:Name__d9713943(c84v3, c84v4, c84v0)
      if not c84v0 then
        p118 = 5
      else
        p118 = 4
      end
    end
    if p118 == 4 then
      c84v1 = 22
      p118 = 6
    end
    if p118 == 5 then
      c84v1 = 0
      p118 = 6
    end
    if p118 == 6 then
      v23 = c84v1
      c84v1 = mMovie
      c84v3 = "Popup.Header.Label"
      c84v4 = 14
      c84v5 = 330
      c84v1:SetNumberVariable(c84v3, c84v4, c84v5)
      c84v1 = mMovie
      c84v3 = "Popup.Header.Label"
      c84v4 = 36
      c84v5 = v60
      c84v1:SetStringVariable(c84v3, c84v4, c84v5)
      c84v1 = _T.InfoPopup_Grid
      c84v2 = string.upper
      c84v3 = v1
      c84v3 = c84v3.GetGridItemName
      c84v4 = mMovie
      c84v6 = v17
      c84v7 = v17
      c84v7 = c84v7.MetaData
      c84v2 = c84v2(c84v3(c84v4, c84v1, c84v6, c84v7))
      v25 = c84v2
      c84v2 = v25
      if c84v2 == "" then
        p118 = 9
      else
        p118 = 7
      end
    end
    if p118 == 7 then
      c84v2 = v17
      c84v2 = c84v2.IsEliteCrewMember
      if not c84v2 then
        p118 = 9
      else
        p118 = 8
      end
    end
    if p118 == 8 then
      c84v3 = v25
      c84v4 = mMovie
      c84v6 = " <ELITE_CREW_MEMBER>"
      c84v7 = true
      c84v4 = c84v4:GetLocalized(c84v6, c84v7)
      c84v2 = c84v3 .. c84v4
      v25 = c84v2
      p118 = 9
    end
    if p118 == 9 then
      c84v2 = 0
      v21 = c84v2
      c84v2 = 0
      v20 = c84v2
      c84v2 = v105
      c84v2(c84v1)
      c84v2 = 0
      c84v3 = v18
      c84v3 = c84v3:GetHowManyElements()
      c84v4 = 1
      if c84v4 < c84v3 then
        p118 = 11
      else
        p118 = 10
      end
    end
    if p118 == 10 then
      c84v3 = v18
      c84v3 = c84v3.mLeaveRoom
      if not c84v3 then
        p118 = 12
      else
        p118 = 11
      end
    end
    if p118 == 11 then
      c84v4 = mMovie
      c84v6 = "Popup.InfoToggle.Callout"
      c84v7 = 40
      c84v4 = c84v4:GetNumberVariable(c84v6, c84v7)
      c84v3 = c84v4 or 0
      c84v5 = 5
      c84v4 = c84v5 + c84v3
      c84v6 = v18
      c84v6 = c84v6.mForcedHorizontalSeparation
      c84v7 = v18
      c84v7 = c84v7:GetHowManyElements()
      c84v5 = c84v6 * c84v7
      c84v2 = c84v4 + c84v5
      p118 = 12
    end
    if p118 == 12 then
      c84v3 = mMovie
      c84v5 = "Popup.Title"
      c84v6 = 14
      c84v7 = 330
      c84v3:SetNumberVariable(c84v5, c84v6, c84v7)
      c84v3 = mMovie
      c84v5 = "Popup.Title"
      c84v6 = 36
      c84v8 = "<p><font color=\""
      c84v9 = v61
      c84v9 = c84v9.FloatingContentHighlightHex
      c84v10 = "\">"
      c84v11 = v25
      c84v12 = "</font></p>"
      c84v7 = c84v8 .. c84v9 .. c84v10 .. c84v11 .. c84v12
      c84v3:SetStringVariable(c84v5, c84v6, c84v7)
      c84v3 = v25
      if c84v3 == "" then
        p118 = 16
      else
        p118 = 13
      end
    end
    if p118 == 13 then
      c84v5 = v20
      c84v6 = mMovie
      c84v8 = "Popup.Title"
      c84v9 = 41
      c84v6 = c84v6:GetNumberVariable(c84v8, c84v9)
      c84v4 = c84v5 + c84v6
      c84v3 = c84v4 - 9
      v20 = c84v3
      c84v4 = mMovie
      c84v6 = "Popup.Title"
      c84v7 = 93
      c84v4 = c84v4:GetNumberVariable(c84v6, c84v7)
      c84v3 = c84v4 + c84v2
      c84v4 = 330
      if c84v3 <= c84v4 then
        p118 = 15
      else
        p118 = 14
      end
    end
    if p118 == 14 then
      c84v4 = v20
      c84v3 = c84v4 + 20
      v20 = c84v3
      p118 = 15
    end
    if p118 == 15 then
      c84v3 = mMovie
      c84v5 = "Popup.InfoToggle"
      c84v6 = 1
      c84v7 = v20
      c84v3:SetNumberVariable(c84v5, c84v6, c84v7)
      c84v4 = v20
      c84v3 = c84v4 + 25
      v20 = c84v3
      p118 = 17
    end
    if p118 == 16 then
      c84v4 = v20
      c84v3 = c84v4 + 9
      v20 = c84v3
      p118 = 17
    end
    if p118 == 17 then
      c84v3 = v92
      c84v3()
      c84v3 = nil
      c84v4 = true
      c84v5 = v17
      c84v5 = c84v5.BuySlot
      if not c84v5 then
        p118 = 24
      else
        p118 = 18
      end
    end
    if p118 == 18 then
      c84v5 = v17
      c84v5 = c84v5.Disabled
      if c84v5 then
        p118 = 24
      else
        p118 = 19
      end
    end
    if p118 == 19 then
      c84v5 = v17
      c84v5 = c84v5.EmptyCount
      c84v6 = v17
      c84v6 = c84v6.MaxCount
      if c84v6 == nil then
        p118 = 21
      else
        p118 = 20
      end
    end
    if p118 == 20 then
      c84v6 = mMovie
      c84v8 = "/Lotus/Language/Menu/Global_LimitedExtraSlots"
      c84v9 = true
      c84v10 = { CUR = nil, MAX = nil }
      c84v10.CUR = c84v5
      c84v11 = v17
      c84v11 = c84v11.MaxCount
      c84v10.MAX = c84v11
      c84v3 = c84v6:GetLocalized(c84v8, c84v9, c84v10)
      p118 = 37
    end
    if p118 == 21 then
      if c84v5 ~= 1 then
        p118 = 23
      else
        p118 = 22
      end
    end
    if p118 == 22 then
      c84v6 = mMovie
      c84v8 = "/Lotus/Language/Menu/Global_FreeSlot"
      c84v9 = true
      c84v3 = c84v6:GetLocalized(c84v8, c84v9)
      p118 = 37
    end
    if p118 == 23 then
      c84v6 = mMovie
      c84v8 = "/Lotus/Language/Menu/Global_FreeSlots"
      c84v9 = true
      c84v10 = { free = nil }
      c84v10.free = c84v5
      c84v3 = c84v6:GetLocalized(c84v8, c84v9, c84v10)
      p118 = 37
    end
    if p118 == 24 then
      c84v5 = v17
      c84v5 = c84v5.IsAbility
      if not c84v5 then
        p118 = 31
      else
        p118 = 25
      end
    end
    if p118 == 25 then
      c84v5 = v17
      c84v5 = c84v5.HideAbilityRank
      if c84v5 then
        p118 = 31
      else
        p118 = 26
      end
    end
    if p118 == 26 then
      c84v5 = v17
      c84v5 = c84v5.Level
      if c84v5 ~= 3 then
        p118 = 28
      else
        p118 = 27
      end
    end
    if p118 == 27 then
      c84v5 = TitleCase
      c84v6 = mMovie
      c84v8 = "/Lotus/Language/Ranks/MaxRank"
      c84v9 = true
      c84v3 = c84v5(c84v6:GetLocalized(c84v8, c84v9))
      p118 = 29
    end
    if p118 == 28 then
      c84v5 = TitleCase
      c84v6 = mMovie
      c84v8 = "/Lotus/Language/Menu/Global_FormattedRankCaps"
      c84v9 = true
      c84v10 = { RANK = nil }
      c84v11 = v17
      c84v11 = c84v11.Level
      c84v10.RANK = c84v11
      c84v3 = c84v5(c84v6:GetLocalized(c84v8, c84v9, c84v10))
      p118 = 29
    end
    if p118 == 29 then
      c84v5 = v17
      c84v5 = c84v5.Locked
      if not c84v5 then
        p118 = 37
      else
        p118 = 30
      end
    end
    if p118 == 30 then
      c84v6 = mMovie
      c84v8 = "<LOCKED>"
      c84v9 = true
      c84v6 = c84v6:GetLocalized(c84v8, c84v9)
      c84v3 = c84v3 .. c84v6
      p118 = 37
    end
    if p118 == 31 then
      c84v5 = v17
      c84v5 = c84v5.IsPAUpgrade
      if not c84v5 then
        p118 = 33
      else
        p118 = 32
      end
    end
    if p118 == 32 then
      c84v5 = mMovie
      c84v7 = "/Lotus/Language/PrimeStore/PrimeAccessUpgradeSubtitle"
      c84v8 = true
      c84v3 = c84v5:GetLocalized(c84v7, c84v8)
      p118 = 37
    end
    if p118 == 33 then
      c84v5 = v17
      c84v5 = c84v5.WeeklyLocked
      if not c84v5 then
        p118 = 35
      else
        p118 = 34
      end
    end
    if p118 == 34 then
      c84v5 = mMovie
      c84v7 = "/Lotus/Language/Store/PerWeekPurchase"
      c84v8 = false
      c84v3 = c84v5:GetLocalized(c84v7, c84v8)
      c84v4 = false
      p118 = 37
    end
    if p118 == 35 then
      c84v5 = v17
      c84v5 = c84v5.SubtitleOverride
      if not c84v5 then
        p118 = 37
      else
        p118 = 36
      end
    end
    if p118 == 36 then
      c84v5 = v17
      c84v3 = c84v5.SubtitleOverride
      p118 = 37
    end
    if p118 == 37 then
      if c84v3 ~= nil then
        p118 = 39
      else
        p118 = 38
      end
    end
    if p118 == 38 then
      c84v5 = false
      p118 = 40
    end
    if p118 == 39 then
      c84v5 = true
      p118 = 40
    end
    if p118 == 40 then
      c84v6 = mMovie
      c84v8 = "Popup.Subtitle"
      c84v9 = 13
      c84v6:Name__d9713943(c84v8, c84v9, c84v5)
      if not c84v5 then
        p118 = 44
      else
        p118 = 41
      end
    end
    if p118 == 41 then
      c84v6 = mMovie
      c84v8 = "Popup.Subtitle"
      c84v9 = 1
      c84v11 = v20
      c84v10 = c84v11 - 8
      c84v6:SetNumberVariable(c84v8, c84v9, c84v10)
      if not c84v4 then
        p118 = 43
      else
        p118 = 42
      end
    end
    if p118 == 42 then
      c84v6 = string.upper
      c84v3 = c84v6(c84v3)
      p118 = 43
    end
    if p118 == 43 then
      c84v6 = mMovie
      c84v8 = "Popup.Subtitle"
      c84v9 = 36
      c84v6:SetStringVariable(c84v8, c84v9, c84v3)
      c84v7 = v20
      c84v8 = mMovie
      c84v10 = "Popup.Subtitle"
      c84v11 = 41
      c84v8 = c84v8:GetNumberVariable(c84v10, c84v11)
      c84v6 = c84v7 + c84v8
      v20 = c84v6
      p118 = 44
    end
    if p118 == 44 then
      c84v6 = v17
      c84v6 = c84v6.DefaultItemInfoTab
      if c84v6 == nil then
        p118 = 47
      else
        p118 = 45
      end
    end
    if p118 == 45 then
      c84v6 = v18
      c84v8 = v17
      c84v8 = c84v8.DefaultItemInfoTab
      c84v6 = c84v6:GetElementInIndex(c84v8)
      if c84v6 == nil then
        p118 = 47
      else
        p118 = 46
      end
    end
    if p118 == 46 then
      c84v6 = v18
      c84v8 = v17
      c84v8 = c84v8.DefaultItemInfoTab
      c84v6:FocusElement(c84v8)
      p118 = 48
    end
    if p118 == 47 then
      c84v6 = v18
      c84v8 = 1
      c84v6:FocusElement(c84v8)
      p118 = 48
    end
    if p118 == 48 then
      c84v6 = v18
      c84v6:SelectCurrentElement()
      c84v8 = _T.InfoPopup_Grid
      c84v9 = false
      if c84v8 == nil then
        p118 = 50
      else
        p118 = 49
      end
    end
    if p118 == 49 then
      c84v9 = c84v8.CanPreviewElements
      p118 = 50
    end
    if p118 == 50 then
      c84v10 = v17
      if c84v10 == nil then
        p118 = 55
      else
        p118 = 51
      end
    end
    if p118 == 51 then
      c84v10 = v17
      c84v10 = c84v10.CanPreviewOverride
      if c84v10 == nil then
        p118 = 55
      else
        p118 = 52
      end
    end
    if p118 == 52 then
      c84v10 = c84v9
      if not c84v10 then
        p118 = 54
      else
        p118 = 53
      end
    end
    if p118 == 53 then
      c84v10 = v17
      c84v10 = c84v10.CanPreviewOverride
      p118 = 54
    end
    if p118 == 54 then
      c84v9 = c84v10
      p118 = 55
    end
    if p118 == 55 then
      c84v7 = c84v9
      if c84v7 then
        p118 = 66
      else
        p118 = 56
      end
    end
    if p118 == 56 then
      c84v7 = false
      c84v8 = v17
      if c84v8 == nil then
        p118 = 60
      else
        p118 = 57
      end
    end
    if p118 == 57 then
      c84v8 = v17
      c84v8 = c84v8.mUnequipItem
      if c84v8 ~= nil then
        p118 = 59
      else
        p118 = 58
      end
    end
    if p118 == 58 then
      c84v7 = false
      p118 = 60
    end
    if p118 == 59 then
      c84v7 = true
      p118 = 60
    end
    if p118 == 60 then
      if c84v7 then
        p118 = 66
      else
        p118 = 61
      end
    end
    if p118 == 61 then
      c84v6 = false
      c84v7 = v17
      if c84v7 == nil then
        p118 = 65
      else
        p118 = 62
      end
    end
    if p118 == 62 then
      c84v7 = v17
      c84v7 = c84v7.RightPressedCallback
      if c84v7 ~= nil then
        p118 = 64
      else
        p118 = 63
      end
    end
    if p118 == 63 then
      c84v6 = false
      p118 = 65
    end
    if p118 == 64 then
      c84v6 = true
      p118 = 65
    end
    if p118 == 65 then
      if not c84v6 then
        p118 = 73
      else
        p118 = 66
      end
    end
    if p118 == 66 then
      c84v8 = Engine.IsPlayingWithTouchscreen
      c84v8 = c84v8()
      if c84v8 then
        p118 = 68
      else
        p118 = 67
      end
    end
    if p118 == 67 then
      c84v7 = false
      p118 = 72
    end
    if p118 == 68 then
      c84v8 = _T.InfoPopup_Grid
      if c84v8 == nil then
        p118 = 71
      else
        p118 = 69
      end
    end
    if p118 == 69 then
      c84v9 = c84v8.ShowSelectButton
      if c84v9 == nil then
        p118 = 71
      else
        p118 = 70
      end
    end
    if p118 == 70 then
      c84v9 = c84v8.ShowSelectButton
      c84v10 = _T.InfoPopup_Data
      c84v7 = c84v9(c84v10)
      p118 = 72
    end
    if p118 == 71 then
      c84v7 = false
      p118 = 72
    end
    if p118 == 72 then
      c84v6 = not c84v7
      p118 = 73
    end
    if p118 == 73 then
      c84v7 = mMovie
      c84v9 = "Popup.PreviewTag"
      c84v10 = 13
      c84v7:Name__d9713943(c84v9, c84v10, c84v6)
      c84v7 = mMovie
      c84v9 = "Popup.PreviewCallout"
      c84v10 = 13
      c84v7:Name__d9713943(c84v9, c84v10, c84v6)
      c84v8 = v54
      c84v7 = IsNull
      c84v7 = c84v7(c84v8)
      if not c84v7 then
        p118 = 75
      else
        p118 = 74
      end
    end
    if p118 == 74 then
      do return end
    end
    if p118 == 75 then
      c84v7 = v54
      c84v9 = v77
      c84v7:SetText(c84v9())
      c84v7 = mMovie
      c84v9 = "Popup.SelectButton"
      c84v10 = 14
      c84v11 = v22
      c84v7:SetNumberVariable(c84v9, c84v10, c84v11)
      c84v7 = mMovie
      c84v9 = "Popup.SelectButton"
      c84v10 = 0
      c84v11 = 54
      c84v7:SetNumberVariable(c84v9, c84v10, c84v11)
      do return end
    end
  end
  v111 = function()
    local c85v0, c85v1, c85v2, c85v3, c85v4, c85v5, c85v6
    c85v0 = mMovie
    c85v2 = "Popup"
    c85v3 = 12
    c85v4 = 0
    c85v0:SetNumberVariable(c85v2, c85v3, c85v4)
    c85v0 = FlashInterpolate
    c85v1 = mMovie
    c85v2 = "Popup"
    c85v3 = 1
    c85v5 = 12
    c85v4 = {c85v5}
    c85v6 = 100
    c85v5 = {c85v6}
    c85v6 = 0.2
    c85v0(c85v1, c85v2, c85v3, c85v4, c85v5, c85v6)
    c85v0 = Engine.IsMobile
    c85v0 = c85v0()
    if c85v0 then
      c85v1 = _T.MobileInfoPopup
      c85v0 = IsNull
      c85v0 = c85v0(c85v1)
      if not c85v0 then
        c85v0 = mMovie
        c85v2 = "Popup"
        c85v3 = 5
        c85v4 = _T.MobileInfoPopup.InfoPopupScale
        c85v0:SetNumberVariable(c85v2, c85v3, c85v4)
        c85v0 = mMovie
        c85v2 = "Popup"
        c85v3 = 6
        c85v4 = _T.MobileInfoPopup.InfoPopupScale
        c85v0:SetNumberVariable(c85v2, c85v3, c85v4)
        do return end
      end
      c85v0 = mMovie
      c85v2 = "Popup"
      c85v3 = 5
      c85v4 = 100
      c85v0:SetNumberVariable(c85v2, c85v3, c85v4)
      c85v0 = mMovie
      c85v2 = "Popup"
      c85v3 = 6
      c85v4 = 100
      c85v0:SetNumberVariable(c85v2, c85v3, c85v4)
    end
    do return end
  end
  v67 = function(c86v0, c86v1)
    local c86v2, c86v3, c86v4, c86v5, c86v6, c86v7, c86v8, c86v9, c86v10, c86v11, c86v12, c86v13, c86v14, c86v15, c86v16
    local c76 = -1
    repeat
      c86v9 = ipairs
      c86v10 = verticalParallaxFrameTypes
      c86v9, c86v10, c86v11 = c86v9(c86v10)
      for c86v12, c86v13 in c86v9, c86v10, c86v11 do
        c86v14 = c86v2:IsA(c86v13)
        if c86v14 then
          c76 = 15
          break
        end
        c86v13 = c86v10.AbilityResource
        c86v11 = c86v0:IsA(c86v13)
        local p71 = 0
        if p71 == 0 then
          c86v2 = v17
          c86v2 = c86v2.AbilityInitialized
          if c86v2 then
            p71 = 2
          else
            p71 = 1
          end
        end
        if p71 == 1 then
          c86v2 = IsNull
          c86v2 = c86v2(c86v0)
          if not c86v2 then
            p71 = 3
          else
            p71 = 2
          end
        end
        if p71 == 2 then
          do return end
        end
        if p71 == 3 then
          c86v2 = nil
          c86v3 = IsNull
          c86v3 = c86v3(c86v1)
          if c86v3 then
            p71 = 5
          else
            p71 = 4
          end
        end
        if p71 == 4 then
          c86v2 = c86v1
          p71 = 8
        end
        if p71 == 5 then
          c86v4 = v17
          c86v4 = c86v4.Suit
          c86v3 = IsNull
          c86v3 = c86v3(c86v4)
          if c86v3 then
            p71 = 8
          else
            p71 = 6
          end
        end
        if p71 == 6 then
          c86v3 = v17
          c86v2 = c86v3.Suit
          c86v3 = IsWeak
          c86v3 = c86v3(c86v2)
          if not c86v3 then
            p71 = 8
          else
            p71 = 7
          end
        end
        if p71 == 7 then
          c86v3 = Resource
          c86v2 = c86v3(c86v2)
          p71 = 8
        end
        if p71 == 8 then
          c86v3 = c86v0:GetVideoTexture()
          c86v4 = nil
          c86v5 = nil
          c86v6 = pairs
          c86v7 = v70
          c86v6, c86v7, c86v8 = c86v6(c86v7)
        end
        for c86v9, c86v10 in c86v6, c86v7, c86v8 do
        end
        if c76 ~= -1 then break end
        if c86v11 then
          c86v4 = c86v10.Images
          c86v5 = c86v10.PageCallout
        end
        c86v6 = mMovie
        c86v8 = c86v0:GetLocalizeTag()
        c86v8 = c86v8:c_str()
        c86v9 = false
        c86v6 = c86v6:GetLocalized(c86v8, c86v9)
        c86v7 = c86v0:GetIconTexture()
        c86v8 = true
        c86v9 = IsNull
        c86v9 = c86v9(c86v2)
        if c86v9 then
          c76 = 17
          break
        end
      end
      if c76 ~= -1 then break end
      break
    until true
    if c76 == 15 then
      c86v8 = false
    end
    c86v10 = v17
    c86v10 = c86v10.ResLoader
    c86v9 = IsNull
    c86v9 = c86v9(c86v10)
    if c86v9 then
      c86v9 = IsNull
      c86v9 = c86v9(c86v3)
      if not c86v9 then
        c86v9 = {c86v3:GetFullName()}
        c86v10 = ipairs
        c86v10, c86v11, c86v12 = c86v10(c86v4)
        for c86v13, c86v14 in c86v10, c86v11, c86v12 do
          c86v15 = table.insert
          c86v15(c86v9, c86v14:GetFullName())
        end
        for c86v13, c86v14 in c86v10, c86v11, c86v12 do
        end
        c86v10 = v17
        c86v11 = UISys.ScriptResLoader_Create
        c86v11 = c86v11(c86v9)
        c86v10.ResLoader = c86v11
        c86v10 = v17
        c86v11 = true
        c86v10.ResLoading = c86v11
      end
    end
    c86v9 = v88
    c86v9(c86v0)
    c86v9 = v17
    c86v10 = string.upper
    c86v10 = c86v10(c86v6)
    c86v9.Name = c86v10
    c86v9 = v17
    c86v12 = true
    c86v13 = false
    c86v10 = c86v0:GetActivationEnergyCost(c86v12, c86v13)
    c86v9.Energy = c86v10
    c86v9 = v17
    c86v12 = false
    c86v13 = false
    c86v10 = c86v0:GetActivationEnergyCost(c86v12, c86v13)
    c86v9.BaseEnergy = c86v10
    c86v9 = v17
    c86v9.Icon = c86v7
    c86v9 = v17
    c86v9.PreviewImage = c86v3
    c86v9 = v17
    c86v9.AdditionalPreviewImages = c86v4
    c86v9 = v17
    c86v9.PageCallout = c86v5
    c86v9 = v17
    c86v10 = 3
    c86v9.MaxLevel = c86v10
    c86v9 = v17
    c86v10 = c86v0:GetScript()
    c86v9.Script = c86v10
    c86v9 = v17
    c86v10 = c86v0:GetLocalizeTag()
    c86v9.LocTag = c86v10
    c86v9 = v17
    c86v9.Resource = c86v0
    c86v9 = v17
    c86v9.AutoParallaxX = c86v8
    c86v9 = v17
    c86v10 = not c86v8
    c86v9.AutoParallaxY = c86v10
    c86v9 = nil
    c86v10 = v17
    c86v10 = c86v10.AbilityLevelOverride
    if c86v10 ~= nil then
      c86v10 = v17
      c86v9 = c86v10.AbilityLevelOverride
    else
      c86v10 = IsNull
      c86v10 = c86v10(c86v2)
      if not c86v10 then
        c86v11 = v17
        c86v11 = c86v11.AbilityIndex
        c86v10 = IsNull
        c86v10 = c86v10(c86v11)
        if not c86v10 then
          c86v12 = v17
          c86v12 = c86v12.AbilityIndex
          c86v10 = c86v2:GetAbilityLevel(c86v12)
          c86v9 = c86v10 - 1
        end
      end
    end
    c86v10 = 0
    c86v11 = v17
    c86v12 = false
    c86v11.Locked = c86v12
    if not c86v9 then
      c86v11 = v17
      c86v13 = 0
      c86v12 = math.max
      c86v12 = c86v12(c86v13, c86v9)
      c86v11.Level = c86v12
      c86v11 = IsNull
      c86v11 = c86v11(c86v2)
      if not c86v11 then
        c86v11 = c86v2:GetLevel()
        c86v14 = v17
        c86v14 = c86v14.AbilityIndex
        c86v10 = c86v2:Name__5682bdb4(c86v14)
        c86v12 = v17
        if c86v10 <= c86v11 then
          c86v13 = false
        else
          c86v13 = true
        end
        c86v12.Locked = c86v13
      end
    end
    c86v11 = v17
    c86v12 = true
    c86v11.IsAbility = c86v12
    c86v11 = v17
    c86v11 = c86v11.HideRankUp
    if not c86v11 then
      c86v11 = v17
      c86v11 = c86v11.Locked
      if not c86v11 then
        c86v11 = IsNull
        c86v11 = c86v11(c86v2)
        if not c86v11 then
          c86v11 = v17
          c86v14 = v17
          c86v14 = c86v14.AbilityIndex
          c86v16 = v17
          c86v16 = c86v16.Level
          c86v15 = c86v16 + 2
          c86v12 = c86v2:Name__0f88464a(c86v14, c86v15)
          c86v11.NextSuitLevel = c86v12
          c86v11 = v17
          c86v14 = v17
          c86v14 = c86v14.AbilityIndex
          c86v16 = v17
          c86v16 = c86v16.Level
          c86v15 = c86v16 + 1
          c86v12 = c86v2:Name__0f88464a(c86v14, c86v15)
          c86v11.LastSuitLevel = c86v12
          c86v11 = v17
          c86v11 = c86v11.NextSuitLevel
          if c86v11 == 255 then
            c86v11 = v17
            c86v12 = nil
            c86v11.NextSuitLevel = c86v12
          end
        end
      else
        c86v11 = v17
        c86v11.NextSuitLevel = c86v10
        c86v11 = v17
        c86v12 = 0
        c86v11.LastSuitLevel = c86v12
      end
      c86v11 = v17
      c86v11 = c86v11.NextSuitLevel
      if c86v11 ~= nil then
        c86v11 = gGameConfig
        c86v13 = v17
        c86v13 = c86v13.LastSuitLevel
        c86v11 = c86v11:Name__a534be9c(c86v13, c86v2)
        c86v13 = c86v2:GetXP()
        c86v12 = c86v13 - c86v11
        c86v14 = gGameConfig
        c86v16 = v17
        c86v16 = c86v16.NextSuitLevel
        c86v14 = c86v14:Name__a534be9c(c86v16, c86v2)
        c86v13 = c86v14 - c86v11
        c86v14 = v17
        c86v15 = c86v12 / c86v13
        c86v14.LevelProgress = c86v15
      end
    end
    c86v11 = v17
    c86v12 = true
    c86v11.AbilityInitialized = c86v12
    do return end
  end
  v112 = function()
    local c88v0, c88v1, c88v2, c88v3, c88v4, c88v5, c88v6, c88v7, c88v8, c88v9, c88v10, c88v11, c88v12, c88v13, c88v14, c88v15, c88v16, c88v17, c88v18, c88v19, c88v20, c88v21, c88v22, c88v23, c88v24, c88v25, c88v26, c88v27, c88v28, c88v29, c88v30, c88v31, c88v32, c88v33, c88v34
    local p272 = 0
    if p272 == 0 then
      c88v1 = mMovie
      c88v0 = IsNull
      c88v0 = c88v0(c88v1)
      if not c88v0 then
        p272 = 2
      else
        p272 = 1
      end
    end
    if p272 == 1 then
      do return end
    end
    if p272 == 2 then
      c88v0 = RealDeltaTime
      c88v0 = c88v0()
      c88v2 = v37
      c88v1 = IsNull
      c88v1 = c88v1(c88v2)
      if c88v1 then
        p272 = 4
      else
        p272 = 3
      end
    end
    if p272 == 3 then
      c88v1 = v37
      c88v1:Update(c88v0)
      p272 = 4
    end
    if p272 == 4 then
      c88v1 = mMovie
      c88v1:Name__b7f5bbc5(c88v0)
      c88v2 = v38
      c88v1 = IsNull
      c88v1 = c88v1(c88v2)
      if c88v1 then
        p272 = 6
      else
        p272 = 5
      end
    end
    if p272 == 5 then
      c88v1 = v38
      c88v1:Update()
      p272 = 6
    end
    if p272 == 6 then
      c88v1 = v62
      if not c88v1 then
        p272 = 9
      else
        p272 = 7
      end
    end
    if p272 == 7 then
      c88v1 = v58
      if c88v1 then
        p272 = 9
      else
        p272 = 8
      end
    end
    if p272 == 8 then
      do return end
    end
    if p272 == 9 then
      c88v2 = _T
      c88v4 = "InfoPopup_Data"
      c88v5 = v59
      c88v3 = c88v4 .. c88v5
      c88v1 = c88v2[c88v3]
      if c88v1 == nil then
        p272 = 16
      else
        p272 = 10
      end
    end
    if p272 == 10 then
      c88v2 = c88v1.StoreItem
      if c88v2 ~= nil then
        p272 = 12
      else
        p272 = 11
      end
    end
    if p272 == 11 then
      c88v2 = c88v1.mStoreItem
      c88v1.StoreItem = c88v2
      p272 = 12
    end
    if p272 == 12 then
      c88v2 = c88v1.StoreItem
      if c88v2 ~= nil then
        p272 = 16
      else
        p272 = 13
      end
    end
    if p272 == 13 then
      c88v2 = c88v1.CodexEntry
      if c88v2 ~= nil then
        p272 = 16
      else
        p272 = 14
      end
    end
    if p272 == 14 then
      c88v2 = c88v1.CustomEntry
      if c88v2 then
        p272 = 16
      else
        p272 = 15
      end
    end
    if p272 == 15 then
      c88v1 = nil
      p272 = 16
    end
    if p272 == 16 then
      c88v2 = v17
      if (c88v2 ~= nil or c88v1 ~= nil) then
        p272 = 19
      else
        p272 = 18
      end
    end
    if p272 == 18 then
      do return end
    end
    if p272 == 19 then
      c88v2 = true
      c88v3 = _T.RadialSolarMapOpen
      if c88v3 == true then
        p272 = 21
      else
        p272 = 20
      end
    end
    if p272 == 20 then
      c88v4 = _T.ShawzinMovie
      c88v3 = IsNull
      c88v3 = c88v3(c88v4)
      c88v2 = not c88v3
      p272 = 21
    end
    if p272 == 21 then
      c88v3 = v42
      if c88v3 == c88v2 then
        p272 = 23
      else
        p272 = 22
      end
    end
    if p272 == 22 then
      v42 = c88v2
      c88v3 = mMovie
      c88v5 = v42
      c88v3:SetPreDrawUpdate(c88v5)
      p272 = 23
    end
    if p272 == 23 then
      c88v3 = v39
      if not c88v3 then
        p272 = 27
      else
        p272 = 24
      end
    end
    if p272 == 24 then
      c88v4 = v40
      c88v3 = IsNull
      c88v3 = c88v3(c88v4)
      if c88v3 then
        p272 = 27
      else
        p272 = 25
      end
    end
    if p272 == 25 then
      c88v3 = v40
      c88v3 = c88v3:IsDone()
      if not c88v3 then
        p272 = 27
      else
        p272 = 26
      end
    end
    if p272 == 26 then
      c88v3 = v66
      c88v4 = false
      c88v3(c88v4)
      c88v3 = v65
      c88v3()
      p272 = 27
    end
    if p272 == 27 then
      c88v3 = v17
      if c88v3 ~= c88v1 then
        p272 = 30
      else
        p272 = 28
      end
    end
    if p272 == 28 then
      if c88v1 == nil then
        p272 = 85
      else
        p272 = 29
      end
    end
    if p272 == 29 then
      c88v3 = c88v1.Refresh
      if not c88v3 then
        p272 = 85
      else
        p272 = 30
      end
    end
    if p272 == 30 then
      c88v3 = true
      if c88v1 == nil then
        p272 = 34
      else
        p272 = 31
      end
    end
    if p272 == 31 then
      c88v4 = v17
      if c88v4 ~= nil then
        p272 = 33
      else
        p272 = 32
      end
    end
    if p272 == 32 then
      c88v3 = false
      p272 = 34
    end
    if p272 == 33 then
      c88v3 = true
      p272 = 34
    end
    if p272 == 34 then
      v17 = c88v1
      c88v4 = v37
      c88v6 = v36
      c88v4:RemoveTimer(c88v6)
      c88v4 = v38
      c88v6 = false
      c88v4:SetActive(c88v6)
      c88v4 = nil
      v41 = c88v4
      c88v4 = 1
      v29 = c88v4
      c88v4 = false
      v50 = c88v4
      c88v4 = false
      v53 = c88v4
      c88v4 = v17
      if c88v4 == nil then
        p272 = 79
      else
        p272 = 35
      end
    end
    if p272 == 35 then
      c88v4 = v17
      c88v4 = c88v4.mApplyThemes
      c88v5 = v89
      if c88v5 == c88v4 then
        p272 = 37
      else
        p272 = 36
      end
    end
    if p272 == 36 then
      v89 = c88v4
      c88v5 = v90
      c88v5()
      p272 = 37
    end
    if p272 == 37 then
      c88v5 = v17
      c88v5 = c88v5.mStatsCountOverride
      if not c88v5 then
        p272 = 39
      else
        p272 = 38
      end
    end
    if p272 == 38 then
      c88v5 = v17
      c88v5 = c88v5.mStatsCountOverride
      v29 = c88v5
      p272 = 39
    end
    if p272 == 39 then
      c88v5 = v17
      c88v6 = mMovie
      c88v5.Movie = c88v6
      c88v5 = v17
      c88v6 = v81
      c88v5.IsWithinPopup = c88v6
      c88v5 = v17
      c88v6 = 0
      c88v5.CompareHeight = c88v6
      c88v6 = v17
      c88v6 = c88v6.Refresh
      c88v5 = not c88v6
      c88v6 = v17
      c88v6 = c88v6.Refresh
      if not c88v6 then
        p272 = 43
      else
        p272 = 40
      end
    end
    if p272 == 40 then
      c88v6 = v17
      c88v7 = nil
      c88v6.Refresh = c88v7
      c88v6 = v17
      c88v6 = c88v6.IsAbility
      if not c88v6 then
        p272 = 42
      else
        p272 = 41
      end
    end
    if p272 == 41 then
      c88v6 = v17
      c88v7 = true
      c88v6.SkipVideoReset = c88v7
      p272 = 42
    end
    if p272 == 42 then
      c88v3 = false
      p272 = 43
    end
    if p272 == 43 then
      c88v6 = v17
      c88v6 = c88v6.IsAbility
      if not c88v6 then
        p272 = 62
      else
        p272 = 44
      end
    end
    if p272 == 44 then
      c88v6 = v17
      c88v6 = c88v6.AbilityInitialized
      if not c88v6 then
        p272 = 46
      else
        p272 = 45
      end
    end
    if p272 == 45 then
      c88v7 = v17
      c88v7 = c88v7.Resource
      c88v6 = IsNull
      c88v6 = c88v6(c88v7)
      if not c88v6 then
        p272 = 62
      else
        p272 = 46
      end
    end
    if p272 == 46 then
      c88v6 = v17
      c88v7 = false
      c88v6.AbilityInitialized = c88v7
      c88v7 = v17
      c88v7 = c88v7.Suit
      c88v6 = IsNull
      c88v6 = c88v6(c88v7)
      if not c88v6 then
        p272 = 51
      else
        p272 = 47
      end
    end
    if p272 == 47 then
      c88v7 = v17
      c88v7 = c88v7.SourceAvatar
      c88v6 = IsNull
      c88v6 = c88v6(c88v7)
      if c88v6 then
        p272 = 51
      else
        p272 = 48
      end
    end
    if p272 == 48 then
      c88v6 = v17
      c88v6 = c88v6.SourceAvatarAlternateSuit
      if not c88v6 then
        p272 = 50
      else
        p272 = 49
      end
    end
    if p272 == 49 then
      c88v6 = v17
      c88v7 = v17
      c88v7 = c88v7.SourceAvatar
      c88v7 = c88v7:InventoryControl()
      c88v7 = c88v7:Name__d22c79ce()
      c88v6.Suit = c88v7
      p272 = 51
    end
    if p272 == 50 then
      c88v6 = v17
      c88v7 = v17
      c88v7 = c88v7.SourceAvatar
      c88v7 = c88v7:InventoryControl()
      c88v7 = c88v7:GetActivePowerSuit()
      c88v6.Suit = c88v7
      p272 = 51
    end
    if p272 == 51 then
      c88v6 = v17
      c88v6 = c88v6.Resource
      c88v7 = nil
      c88v9 = v17
      c88v9 = c88v9.Suit
      c88v8 = IsNull
      c88v8 = c88v8(c88v9)
      if c88v8 then
        p272 = 54
      else
        p272 = 52
      end
    end
    if p272 == 52 then
      c88v8 = v17
      c88v7 = c88v8.Suit
      c88v8 = IsWeak
      c88v8 = c88v8(c88v7)
      if not c88v8 then
        p272 = 54
      else
        p272 = 53
      end
    end
    if p272 == 53 then
      c88v8 = Resource
      c88v7 = c88v8(c88v7)
      p272 = 54
    end
    if p272 == 54 then
      c88v8 = IsNull
      c88v8 = c88v8(c88v6)
      if not c88v8 then
        p272 = 58
      else
        p272 = 55
      end
    end
    if p272 == 55 then
      c88v9 = v17
      c88v9 = c88v9.AbilityIndex
      c88v8 = IsNull
      c88v8 = c88v8(c88v9)
      if c88v8 then
        p272 = 58
      else
        p272 = 56
      end
    end
    if p272 == 56 then
      c88v8 = IsNull
      c88v8 = c88v8(c88v7)
      if c88v8 then
        p272 = 58
      else
        p272 = 57
      end
    end
    if p272 == 57 then
      c88v10 = v17
      c88v10 = c88v10.AbilityIndex
      c88v6 = c88v7:GetAbilityByIndex(c88v10)
      p272 = 58
    end
    if p272 == 58 then
      c88v8 = IsNull
      c88v8 = c88v8(c88v6)
      if c88v8 then
        p272 = 62
      else
        p272 = 59
      end
    end
    if p272 == 59 then
      c88v8 = IsWeak
      c88v8 = c88v8(c88v6)
      if not c88v8 then
        p272 = 61
      else
        p272 = 60
      end
    end
    if p272 == 60 then
      c88v8 = v17
      c88v9 = true
      c88v8.AllInOne = c88v9
      c88v8 = v17
      c88v8.ResultItemType = c88v6
      p272 = 62
    end
    if p272 == 61 then
      c88v8 = v67
      c88v8(c88v6, c88v7)
      p272 = 62
    end
    if p272 == 62 then
      c88v7 = v17
      c88v7 = c88v7.CrewMemberInfo
      c88v6 = IsNull
      c88v6 = c88v6(c88v7)
      if c88v6 then
        p272 = 64
      else
        p272 = 63
      end
    end
    if p272 == 63 then
      c88v6 = v17
      c88v6 = c88v6.CrewMemberInfo
      c88v6 = c88v6.mPowersuitInfo
      c88v6 = c88v6.mItemType
      v41 = c88v6
      c88v6 = v17
      c88v8 = v17
      c88v8 = c88v8.CrewMemberInfo
      c88v8 = c88v8:IsNemesis()
      c88v7 = not c88v8
      c88v6.AllInOne = c88v7
      p272 = 73
    end
    if p272 == 64 then
      c88v7 = v17
      c88v7 = c88v7.StoreItem
      c88v6 = IsNull
      c88v6 = c88v6(c88v7)
      if c88v6 then
        p272 = 72
      else
        p272 = 65
      end
    end
    if p272 == 65 then
      c88v6 = v17
      c88v6 = c88v6.StoreItem
      c88v8 = c88v6:GetStatsCount()
      c88v9 = v29
      c88v7 = math.max
      c88v7 = c88v7(c88v8, c88v9)
      v29 = c88v7
      c88v9 = gLotusWeaponStoreItemType
      c88v7 = c88v6:IsA(c88v9)
      if not c88v7 then
        p272 = 69
      else
        p272 = 66
      end
    end
    if p272 == 66 then
      c88v7 = c88v6:IsEvolvingWeapon()
      if not c88v7 then
        p272 = 69
      else
        p272 = 67
      end
    end
    if p272 == 67 then
      c88v7 = v29
      c88v8 = 1
      if c88v7 <= c88v8 then
        p272 = 69
      else
        p272 = 68
      end
    end
    if p272 == 68 then
      c88v7 = v29
      c88v7 = c88v7 - 1
      v29 = c88v7
      p272 = 69
    end
    if p272 == 69 then
      c88v9 = gRecipeStoreItemType
      c88v7 = c88v6:IsA(c88v9)
      if not c88v7 then
        p272 = 71
      else
        p272 = 70
      end
    end
    if p272 == 70 then
      c88v7 = c88v6:GetResultType()
      v41 = c88v7
      p272 = 73
    end
    if p272 == 71 then
      c88v7 = c88v6:GetItem()
      v41 = c88v7
      p272 = 73
    end
    if p272 == 72 then
      c88v6 = v17
      c88v6 = c88v6.ResultItemType
      v41 = c88v6
      p272 = 73
    end
    if p272 == 73 then
      c88v7 = v41
      c88v6 = IsNull
      c88v6 = c88v6(c88v7)
      if c88v6 then
        p272 = 76
      else
        p272 = 74
      end
    end
    if p272 == 74 then
      c88v6 = v41
      c88v8 = v14
      c88v6 = c88v6:IsA(c88v8)
      if not c88v6 then
        p272 = 76
      else
        p272 = 75
      end
    end
    if p272 == 75 then
      c88v6 = v17
      c88v7 = true
      c88v6.AllInOne = c88v7
      p272 = 76
    end
    if p272 == 76 then
      c88v6 = v37
      c88v8 = 0.01
      c88v9 = function()
        local c87v0, c87v1, c87v2
        local p9 = 0
        if p9 == 0 then
          v36 = c87v0
          c87v0 = c88v5
          if c87v0 == nil then
            p9 = 3
          else
            p9 = 1
          end
        end
        if p9 == 1 then
          c87v0 = c88v5
          c87v0 = c87v0.mTipSoundOverride
          if c87v0 == nil then
            p9 = 3
          else
            p9 = 2
          end
        end
        if p9 == 2 then
          c87v0 = v2
          c87v0 = c87v0.PlaySound
          c87v1 = c88v5
          c87v1 = c87v1.mTipSoundOverride
          c87v0(c87v1)
          p9 = 4
        end
        if p9 == 3 then
          c87v0 = v2
          c87v0 = c87v0.PlaySound
          c87v1 = _G
          c87v1 = c87v1.UISound_ItemTip
          c87v0(c87v1)
          p9 = 4
        end
        if p9 == 4 then
          c87v0 = v110
          c87v0()
          c87v0 = false
          v62 = c87v0
          c87v0 = mMovie
          c87v2 = true
          c87v0:SetVisible(c87v2)
          c87v0 = c88v5
          if not c87v0 then
            p9 = 6
          else
            p9 = 5
          end
        end
        if p9 == 5 then
          c87v0 = v111
          c87v0()
          p9 = 6
        end
        if p9 == 6 then
          do return end
        end
      end
      c88v6 = c88v6:AddTimer(c88v8, c88v9)
      v36 = c88v6
      c88v6 = v17
      c88v6 = c88v6.MetaData
      if c88v6 ~= nil then
        p272 = 78
      else
        p272 = 77
      end
    end
    if p272 == 77 then
      c88v6 = v17
      c88v7 = { HideOwned = true }
      c88v6.MetaData = c88v7
      p272 = 79
    end
    if p272 == 78 then
      c88v6 = v17
      c88v6 = c88v6.MetaData
      c88v7 = true
      c88v6.HideOwned = c88v7
      c88v6 = v17
      c88v6 = c88v6.MetaData
      c88v7 = nil
      c88v6.ShowCheckmark = c88v7
      p272 = 79
    end
    if p272 == 79 then
      if not c88v3 then
        p272 = 81
      else
        p272 = 80
      end
    end
    if p272 == 80 then
      c88v4 = v71
      c88v4()
      p272 = 81
    end
    if p272 == 81 then
      c88v5 = v17
      if c88v5 ~= nil then
        p272 = 83
      else
        p272 = 82
      end
    end
    if p272 == 82 then
      c88v4 = false
      p272 = 84
    end
    if p272 == 83 then
      c88v4 = true
      p272 = 84
    end
    if p272 == 84 then
      c88v5 = mMovie
      c88v7 = not c88v4
      c88v5:SetIgnoreInput(c88v7)
      c88v5 = mMovie
      c88v5:SetForcedInput(c88v4)
      p272 = 85
    end
    if p272 == 85 then
      c88v3 = v17
      if c88v3 == nil then
        p272 = 153
      else
        p272 = 86
      end
    end
    if p272 == 86 then
      c88v3 = v50
      if not c88v3 then
        p272 = 89
      else
        p272 = 87
      end
    end
    if p272 == 87 then
      c88v4 = v17
      c88v4 = c88v4.StoreItem
      c88v3 = IsNull
      c88v3 = c88v3(c88v4)
      if c88v3 then
        p272 = 89
      else
        p272 = 88
      end
    end
    if p272 == 88 then
      c88v3 = v106
      c88v3()
      p272 = 89
    end
    if p272 == 89 then
      c88v3 = v17
      c88v3 = c88v3.RarityChances
      if c88v3 == nil then
        p272 = 91
      else
        p272 = 90
      end
    end
    if p272 == 90 then
      c88v3 = v47
      c88v6 = c88v0 / 2
      c88v7 = v47
      c88v7 = c88v7.x
      c88v5 = c88v6 + c88v7
      c88v4 = c88v5 % 1
      c88v3.x = c88v4
      c88v3 = v47
      c88v7 = -c88v0
      c88v6 = c88v7 / 40
      c88v7 = v47
      c88v7 = c88v7.y
      c88v5 = c88v6 + c88v7
      c88v4 = c88v5 % 1
      c88v3.y = c88v4
      c88v3 = v1
      c88v3 = c88v3.UpdateRarityBar
      c88v4 = mMovie
      c88v5 = "Popup.RarityBar"
      c88v6 = v47
      c88v7 = false
      c88v3(c88v4, c88v5, c88v6, c88v7)
      p272 = 91
    end
    if p272 == 91 then
      c88v3 = v17
      c88v3 = c88v3.ResLoading
      if c88v3 ~= nil then
        p272 = 95
      else
        p272 = 92
      end
    end
    if p272 == 92 then
      c88v4 = v17
      c88v4 = c88v4.PreviewImage
      c88v3 = IsNull
      c88v3 = c88v3(c88v4)
      if c88v3 then
        p272 = 95
      else
        p272 = 93
      end
    end
    if p272 == 93 then
      c88v3 = IsWeak
      c88v4 = v17
      c88v4 = c88v4.PreviewImage
      c88v3 = c88v3(c88v4)
      if not c88v3 then
        p272 = 95
      else
        p272 = 94
      end
    end
    if p272 == 94 then
      c88v3 = v17
      c88v4 = UISys.ScriptResLoader_Create
      c88v6 = v17
      c88v6 = c88v6.PreviewImage
      c88v5 = {c88v6:GetFullName()}
      c88v4 = c88v4(c88v5)
      c88v3.ResLoader = c88v4
      c88v3 = v17
      c88v4 = true
      c88v3.ResLoading = c88v4
      p272 = 95
    end
    if p272 == 95 then
      c88v3 = v17
      c88v3 = c88v3.ResLoading
      if c88v3 then
        p272 = 97
      else
        p272 = 96
      end
    end
    if p272 == 96 then
      c88v3 = v17
      c88v3 = c88v3.RefreshImage
      if not c88v3 then
        p272 = 102
      else
        p272 = 97
      end
    end
    if p272 == 97 then
      c88v4 = v17
      c88v4 = c88v4.ResLoader
      c88v3 = IsNull
      c88v3 = c88v3(c88v4)
      if c88v3 then
        p272 = 99
      else
        p272 = 98
      end
    end
    if p272 == 98 then
      c88v3 = v17
      c88v3 = c88v3.ResLoader
      c88v3 = c88v3:IsDone()
      if not c88v3 then
        p272 = 102
      else
        p272 = 99
      end
    end
    if p272 == 99 then
      c88v3 = print
      c88v4 = "loader done"
      c88v3(c88v4)
      c88v3 = v38
      c88v5 = false
      c88v3:SetActive(c88v5)
      c88v3 = v17
      c88v4 = false
      c88v3.ResLoading = c88v4
      c88v3 = v17
      c88v4 = false
      c88v3.RefreshImage = c88v4
      c88v4 = v17
      c88v4 = c88v4.PreviewImage
      c88v3 = IsNull
      c88v3 = c88v3(c88v4)
      if not c88v3 then
        p272 = 101
      else
        p272 = 100
      end
    end
    if p272 == 100 then
      c88v3 = mMovie
      c88v5 = "Popup.VideoPreview.Image"
      c88v6 = 13
      c88v7 = false
      c88v3:Name__d9713943(c88v5, c88v6, c88v7)
      p272 = 102
    end
    if p272 == 101 then
      c88v3 = v17
      c88v4 = Resource
      c88v5 = v17
      c88v5 = c88v5.PreviewImage
      c88v4 = c88v4(c88v5)
      c88v3.PreviewImage = c88v4
      c88v3 = mMovie
      c88v5 = "Popup.VideoPreview.Image"
      c88v6 = 13
      c88v7 = true
      c88v3:Name__d9713943(c88v5, c88v6, c88v7)
      c88v3 = mMovie
      c88v5 = "Popup.VideoPreview.Image"
      c88v3:StopVideoTexture(c88v5)
      c88v3 = mMovie
      c88v5 = "Popup.VideoPreview.Image"
      c88v6 = v17
      c88v6 = c88v6.PreviewImage
      c88v3:OverrideTexture(c88v5, c88v6)
      c88v3 = mMovie
      c88v5 = "Popup.VideoPreview.Image"
      c88v3:Name__f55ae1a2(c88v5)
      p272 = 102
    end
    if p272 == 102 then
      c88v3 = v37
      c88v5 = v36
      c88v3 = c88v3:HasTimer(c88v5)
      if c88v3 then
        p272 = 153
      else
        p272 = 103
      end
    end
    if p272 == 103 then
      c88v4 = _T
      c88v3 = c88v4.InfoPopup_Data
      if c88v3 == nil then
        p272 = 147
      else
        p272 = 104
      end
    end
    if p272 == 104 then
      c88v4 = c88v3.Rect
      c88v5 = nil
      c88v6 = 10
      c88v7 = mMovie
      c88v7 = c88v7:GetMovieWidth()
      c88v8 = mMovie
      c88v8 = c88v8:GetMovieHeight()
      c88v9 = _T.InfoPopup_Grid
      if c88v9 == nil then
        p272 = 107
      else
        p272 = 105
      end
    end
    if p272 == 105 then
      c88v10 = c88v9.PopupPadding
      if c88v10 == nil then
        p272 = 107
      else
        p272 = 106
      end
    end
    if p272 == 106 then
      c88v6 = c88v9.PopupPadding
      p272 = 107
    end
    if p272 == 107 then
      c88v10 = Engine.IsMobile
      c88v10 = c88v10()
      if not c88v10 then
        p272 = 110
      else
        p272 = 108
      end
    end
    if p272 == 108 then
      c88v10 = v1
      c88v10 = c88v10.DisableTooltips
      if c88v10 ~= true then
        p272 = 110
      else
        p272 = 109
      end
    end
    if p272 == 109 then
      c88v10 = mMovie
      c88v12 = false
      c88v10:SetVisible(c88v12)
      do return end
    end
    if p272 == 110 then
      c88v10 = c88v4.UseCursor
      if not c88v10 then
        p272 = 115
      else
        p272 = 111
      end
    end
    if p272 == 111 then
      c88v10 = mMovie
      c88v10 = c88v10:GetDrawScale()
      c88v12 = c88v7 / c88v10
      c88v13 = mMovie
      c88v13 = c88v13:GetViewportWidth()
      c88v11 = c88v12 / c88v13
      c88v13 = c88v8 / c88v10
      c88v14 = mMovie
      c88v14 = c88v14:GetViewportHeight()
      c88v12 = c88v13 / c88v14
      if c88v11 <= c88v12 then
        p272 = 113
      else
        p272 = 112
      end
    end
    if p272 == 112 then
      c88v10 = c88v11
      p272 = 114
    end
    if p272 == 113 then
      c88v10 = c88v12
      p272 = 114
    end
    if p272 == 114 then
      c88v13 = { x = nil, y = nil }
      c88v15 = mMovie
      c88v15 = c88v15:GetCursorX()
      c88v14 = c88v15 * c88v10
      c88v13.x = c88v14
      c88v15 = mMovie
      c88v15 = c88v15:GetCursorY()
      c88v14 = c88v15 * c88v10
      c88v13.y = c88v14
      c88v5 = c88v13
      p272 = 118
    end
    if p272 == 115 then
      c88v10 = c88v4.IsDiegetic
      if not c88v10 then
        p272 = 117
      else
        p272 = 116
      end
    end
    if p272 == 116 then
      c88v10 = c88v4.Movie
      c88v12 = c88v4.Movie
      c88v14 = c88v4.ClipName
      c88v15 = 2
      c88v12 = c88v12:GetNumberVariable(c88v14, c88v15)
      c88v13 = c88v4.Movie
      c88v15 = c88v4.ClipName
      c88v16 = 3
      c88v10 = c88v10:Name__3565d54e(c88v12, c88v13:GetNumberVariable(c88v15, c88v16))
      c88v11 = mMovie
      c88v14 = gRegion
      c88v14 = c88v14:GetLocalPlayer()
      c88v14 = c88v14:GetCamera()
      c88v15 = true
      c88v5 = c88v11:ProjectPosition(c88v10, c88v14, c88v15)
      p272 = 118
    end
    if p272 == 117 then
      c88v10 = v2
      c88v10 = c88v10.TransformViewportToPixelCoordinates
      c88v11 = mMovie
      c88v12 = { x = nil, y = nil }
      c88v13 = c88v4.X
      c88v12.x = c88v13
      c88v13 = c88v4.Y
      c88v12.y = c88v13
      c88v5 = c88v10(c88v11, c88v12)
      p272 = 118
    end
    if p272 == 118 then
      c88v10 = c88v4.W
      c88v11 = c88v4.H
      c88v12 = c88v3.CenterAlign
      if not c88v12 then
        p272 = 120
      else
        p272 = 119
      end
    end
    if p272 == 119 then
      c88v13 = v22
      c88v12 = -c88v13
      c88v10 = c88v12 / 2
      c88v11 = c88v11 / 2
      c88v6 = 0
      p272 = 122
    end
    if p272 == 120 then
      c88v12 = c88v3.TopLeftAligned
      if c88v12 then
        p272 = 122
      else
        p272 = 121
      end
    end
    if p272 == 121 then
      c88v10 = c88v10 / 2
      c88v11 = c88v11 / 2
      p272 = 122
    end
    if p272 == 122 then
      c88v12 = v21
      c88v14 = _T
      c88v13 = c88v14.InfoPopup_Data2
      if c88v13 == nil then
        p272 = 124
      else
        p272 = 123
      end
    end
    if p272 == 123 then
      c88v15 = c88v3.CompareHeight
      c88v14 = c88v15 or 0
      c88v13 = math.max
      c88v12 = c88v13(c88v14, c88v12)
      c88v3.CompareHeight = c88v12
      p272 = 124
    end
    if p272 == 124 then
      c88v15 = v59
      c88v14 = tonumber
      c88v14 = c88v14(c88v15)
      c88v13 = c88v14 or 1
      c88v17 = c88v5.x
      c88v16 = c88v17 + c88v10
      c88v15 = c88v16 + c88v6
      c88v18 = v22
      c88v17 = c88v18 + 2
      c88v18 = c88v13 - 1
      c88v16 = c88v17 * c88v18
      c88v14 = c88v15 + c88v16
      c88v15 = c88v5.y
      c88v16 = c88v3.CenterAlign
      if not c88v16 then
        p272 = 126
      else
        p272 = 125
      end
    end
    if p272 == 125 then
      c88v15 = c88v15 + c88v11
      p272 = 130
    end
    if p272 == 126 then
      c88v16 = c88v3.BottomAnchor
      if not c88v16 then
        p272 = 128
      else
        p272 = 127
      end
    end
    if p272 == 127 then
      c88v16 = c88v15 - c88v12
      c88v15 = c88v16 + c88v11
      p272 = 130
    end
    if p272 == 128 then
      c88v16 = c88v3.TopLeftAligned
      if c88v16 then
        p272 = 130
      else
        p272 = 129
      end
    end
    if p272 == 129 then
      c88v15 = c88v15 - c88v11
      p272 = 130
    end
    if p272 == 130 then
      c88v16 = v2
      c88v16 = c88v16.GetScreenDimensions
      c88v17 = mMovie
      c88v16, c88v17 = c88v16(c88v17)
      c88v18 = c88v8 * 0.05
      c88v20 = c88v18 + c88v12
      c88v19 = c88v17 - c88v20
      c88v20 = c88v3.CenterAlign
      if not c88v20 then
        p272 = 133
      else
        p272 = 131
      end
    end
    if p272 == 131 then
      if c88v15 <= c88v19 then
        p272 = 134
      else
        p272 = 132
      end
    end
    if p272 == 132 then
      c88v21 = c88v5.y
      c88v20 = c88v21 - c88v11
      c88v15 = c88v20 - c88v12
      p272 = 134
    end
    if p272 == 133 then
      c88v20 = Clamp
      c88v15 = c88v20(c88v15, c88v18, c88v19)
      p272 = 134
    end
    if p272 == 134 then
      c88v18 = c88v7 * 0.05
      c88v20 = c88v16 - c88v18
      c88v25 = _T.ItemInfoPopupCount
      c88v24 = c88v25 or 1
      c88v25 = c88v13 - 1
      c88v23 = c88v24 - c88v25
      c88v25 = v22
      c88v24 = c88v25 + 2
      c88v22 = c88v23 * c88v24
      c88v21 = c88v22 - 2
      c88v22 = c88v20 - c88v21
      if c88v22 < c88v14 then
        p272 = 136
      else
        p272 = 135
      end
    end
    if p272 == 135 then
      c88v22 = c88v3.RightAligned
      if not c88v22 then
        p272 = 139
      else
        p272 = 136
      end
    end
    if p272 == 136 then
      c88v22 = 0
      c88v23 = c88v3.TopLeftAligned
      if c88v23 then
        p272 = 138
      else
        p272 = 137
      end
    end
    if p272 == 137 then
      c88v22 = c88v10
      p272 = 138
    end
    if p272 == 138 then
      c88v26 = c88v5.x
      c88v25 = c88v26 - c88v22
      c88v24 = c88v25 - c88v6
      c88v27 = v22
      c88v26 = c88v27 + 2
      c88v25 = c88v26 * c88v13
      c88v23 = c88v24 - c88v25
      c88v14 = c88v23 + 2
      p272 = 139
    end
    if p272 == 139 then
      c88v23 = _T.ItemInfoPopupCount
      c88v22 = c88v23 or 1
      c88v24 = v22
      c88v23 = c88v24 + 2
      c88v26 = c88v22 - c88v13
      c88v25 = c88v23 * c88v26
      c88v24 = c88v23 + c88v25
      c88v20 = c88v20 - c88v24
      c88v24 = Clamp
      c88v14 = c88v24(c88v14, c88v18, c88v20)
      c88v24 = mMovie
      c88v26 = "Popup"
      c88v27 = 0
      c88v28 = math.ceil
      c88v28 = c88v28(c88v14)
      c88v24:SetNumberVariable(c88v26, c88v27, c88v28)
      c88v24 = mMovie
      c88v26 = "Popup"
      c88v27 = 1
      c88v28 = math.ceil
      c88v28 = c88v28(c88v15)
      c88v24:SetNumberVariable(c88v26, c88v27, c88v28)
      c88v24 = Engine.IsMobile
      c88v24 = c88v24()
      if not c88v24 then
        p272 = 147
      else
        p272 = 140
      end
    end
    if p272 == 140 then
      c88v25 = _T.MobileInfoPopup
      c88v24 = IsNull
      c88v24 = c88v24(c88v25)
      if c88v24 then
        p272 = 147
      else
        p272 = 141
      end
    end
    if p272 == 141 then
      c88v24 = c88v15
      c88v26 = _T.MobileInfoPopup.InfoPopupScale
      c88v25 = c88v26 / 100
      c88v26 = c88v12 * c88v25
      c88v28 = c88v15 + c88v26
      c88v27 = c88v28 + 20
      if c88v27 <= c88v17 then
        p272 = 143
      else
        p272 = 142
      end
    end
    if p272 == 142 then
      c88v28 = c88v17 - c88v26
      c88v24 = c88v28 - 50
      p272 = 143
    end
    if p272 == 143 then
      c88v28 = v2
      c88v28 = c88v28.Ternary
      c88v30 = _T.MobileInfoPopup.TaskInfoXOffset
      if c88v30 == 0 then
        p272 = 145
      else
        p272 = 144
      end
    end
    if p272 == 144 then
      c88v29 = false
      p272 = 146
    end
    if p272 == 145 then
      c88v29 = true
      p272 = 146
    end
    if p272 == 146 then
      c88v30 = _T.MobileInfoPopup.RewardInfoXOffset
      c88v31 = _T.MobileInfoPopup.TaskInfoXOffset
      c88v28 = c88v28(c88v29, c88v30, c88v31)
      c88v29 = mMovie
      c88v31 = "Popup"
      c88v32 = 0
      c88v34 = math.ceil
      c88v34 = c88v34(c88v14)
      c88v33 = c88v34 + c88v28
      c88v29:SetNumberVariable(c88v31, c88v32, c88v33)
      c88v29 = mMovie
      c88v31 = "Popup"
      c88v32 = 1
      c88v33 = math.ceil
      c88v33 = c88v33(c88v24)
      c88v29:SetNumberVariable(c88v31, c88v32, c88v33)
      p272 = 147
    end
    if p272 == 147 then
      c88v4 = v17
      c88v4 = c88v4.MetaData
      c88v4 = c88v4.UpdateExpiry
      if not c88v4 then
        p272 = 153
      else
        p272 = 148
      end
    end
    if p272 == 148 then
      c88v4 = ipairs
      c88v5 = v26
      c88v4, c88v5, c88v6 = c88v4(c88v5)
      p272 = 152
    end
    if p272 == 149 then
      c88v9 = c88v8.ExcludeFromInfoPopup
      if c88v9 then
        p272 = 152
      else
        p272 = 150
      end
    end
    if p272 == 150 then
      c88v9 = c88v8.Type
      c88v10 = v1
      c88v10 = c88v10.LABEL_TYPE_TIMER
      if c88v9 ~= c88v10 then
        p272 = 152
      else
        p272 = 151
      end
    end
    if p272 == 151 then
      c88v9 = Engine.Name__b38e1642
      c88v10 = v17
      c88v10 = c88v10.MetaData
      c88v10 = c88v10.Expiry
      c88v9 = c88v9(c88v10)
      c88v10 = v0
      c88v10 = c88v10.SecondsToFormattedTime
      c88v11 = mMovie
      c88v13 = "CompactTwoMax"
      c88v10 = c88v10(c88v11, c88v9, c88v13)
      c88v8.Name = c88v10
      c88v10 = v1
      c88v10 = c88v10.DrawPriceLabel
      c88v11 = mMovie
      c88v12 = c88v8.ClipName
      c88v10(c88v11, c88v12, c88v8)
      do return end
    end
    if p272 == 152 then
      p272 = 153
    end
    if p272 == 153 then
      do return end
    end
  end
  Update = v112
  v112 = function(c89v0, c89v1)
    local c89v2, c89v3
    c89v3 = v17
    c89v2 = IsNull
    c89v2 = c89v2(c89v3)
    if not c89v2 then
      c89v2 = v17
      c89v2 = c89v2.mPreset
      if c89v2 ~= nil then
        c89v2 = v17
        c89v2 = c89v2.mPreset
        c89v2 = c89v2.mFavorite
        do return c89v2 end
      end
    end
    c89v2 = false
    do return c89v2 end
  end
  FocusedFavoriteCallback = v112
  v112 = function()
    local c90v0
    c90v0 = v90
    c90v0()
    do return end
  end
  OnStyleChangedCallback = v112
  v112 = function()
    local c91v0
    c91v0 = v92
    c91v0()
    do return end
  end
  IconCacheFlushed = v112
  v112 = function(c92v0)
    local c92v1, c92v2
    c92v2 = v18
    c92v1 = IsNull
    c92v1 = c92v1(c92v2)
    if not c92v1 then
      c92v1 = v18
      c92v1 = c92v1:GetHowManyElements()
      c92v2 = 1
      if c92v2 < c92v1 then
        c92v1 = v17
        if c92v1 ~= nil then
          c92v1 = v39
          if not c92v1 then
            c92v1 = v2
            c92v1 = c92v1.INCREMENT
            if c92v0 == c92v1 then
              c92v1 = v18
              c92v1:FocusNextElement()
            else
              c92v1 = v18
              c92v1:FocusPreviousElement()
            end
            c92v1 = v18
            c92v1:SelectCurrentElement()
            c92v1 = v17
            c92v1 = c92v1.mPageSoundOverride
            if c92v1 ~= nil then
              c92v1 = v2
              c92v1 = c92v1.PlaySound
              c92v2 = v17
              c92v2 = c92v2.mPageSoundOverride
              c92v1(c92v2)
            else
              c92v1 = v2
              c92v1 = c92v1.PlaySound
              c92v2 = _G
              c92v2 = c92v2.UISound_ItemTipSection
              c92v1(c92v2)
            end
            c92v1 = true
            do return c92v1 end
          end
        end
      end
    end
    c92v1 = false
    do return c92v1 end
  end
  v113 = function()
    local c93v0, c93v1, c93v3, c93v4
    c93v0 = _T.InfoPopup_Grid
    local c93v2 = _T.InfoPopup_Grid
    c93v3 = false
    if c93v2 ~= nil then
      c93v3 = c93v2.CanPreviewElements
    end
    c93v4 = v17
    if c93v2 == nil then
      c93v4 = v17
      c93v4 = c93v4.CanPreviewOverride
      if c93v4 ~= nil then
        c93v4 = c93v3
        if c93v4 then
          c93v4 = v17
          c93v4 = c93v4.CanPreviewOverride
        end
        c93v3 = c93v4
      end
    end
    c93v1 = c93v3
    if not ((not c93v1 or c93v0 == nil)) then
      c93v1 = c93v0.PreviewCallback
      if c93v1 ~= nil then
        c93v0:PreviewCallback()
        c93v1 = true
        do return c93v1 end
      end
    end
    c93v1 = false
    c93v2 = v17
    if c93v2 ~= nil then
      c93v2 = v17
      c93v2 = c93v2.mUnequipItem
      if c93v2 == nil then
        c93v1 = false
      else
        c93v1 = true
      end
    end
    if not ((not c93v1 or c93v0 == nil)) then
      c93v1 = c93v0.UnequipCallback
      if c93v1 ~= nil then
        c93v0:UnequipCallback()
        c93v1 = true
        do return c93v1 end
      end
    end
    c93v1 = false
    c93v2 = v17
    if c93v2 ~= nil then
      c93v2 = v17
      c93v2 = c93v2.RightPressedCallback
      if c93v2 == nil then
        c93v1 = false
      else
        c93v1 = true
      end
    end
    if c93v1 then
      c93v1 = v17
      c93v1 = c93v1.RightPressedCallback
      c93v1()
      c93v1 = true
      do return c93v1 end
    end
    c93v1 = false
    do return c93v1 end
  end
  v114 = function()
    local c94v0
    c94v0 = v113
    c94v0 = c94v0()
    do return c94v0 end
  end
  onKeyDown_MENU_RTHUMB = v114
  v114 = function()
    local c95v0
    c95v0 = v113
    c95v0 = c95v0()
    do return c95v0 end
  end
  onKeyDown_MENU_RIGHT_CLICK = v114
  v114 = function()
    local c96v0, c96v1
    c96v0 = v112
    c96v1 = v2
    c96v1 = c96v1.INCREMENT
    c96v0 = c96v0(c96v1)
    do return c96v0 end
  end
  onKeyDown_MENU_RTRIGGER1 = v114
  v114 = function()
    local c97v0, c97v1, c97v2
    c97v2 = v18
    c97v1 = IsNull
    c97v1 = c97v1(c97v2)
    c97v0 = not c97v1
    if c97v0 then
      c97v0 = false
      c97v1 = v18
      c97v1 = c97v1:GetHowManyElements()
      c97v2 = 1
      if c97v2 < c97v1 then
        c97v0 = false
        c97v1 = v17
        if c97v1 ~= nil then
          c97v1 = v39
          c97v0 = not c97v1
        end
      end
    end
    do return c97v0 end
  end
  onKeyUp_MENU_RTRIGGER1 = v114
  v114 = function()
    local c98v0
    c98v0 = true
    do return c98v0 end
  end
  onKeyDown_NEXT_MENU = v114
  v114 = function(c99v0, c99v1, c99v2)
    local c99v3, c99v4, c99v5, c99v6, c99v7, c99v8, c99v9, c99v10, c99v11, c99v12, c99v13, c99v14, c99v15, c99v18
    c99v3 = Engine.IsMobile
    c99v3 = c99v3()
    if c99v3 then
      c99v3 = string.find
      c99v5 = "MOUSE_B0"
      c99v3 = c99v3(c99v1, c99v5)
      if c99v3 ~= nil then
        c99v3 = mMovie
        c99v3 = c99v3:GetViewportWidth()
        c99v4 = mMovie
        c99v4 = c99v4:GetViewportHeight()
        c99v5 = mMovie
        c99v5 = c99v5:GetMovieWidth()
        c99v6 = mMovie
        c99v6 = c99v6:GetMovieHeight()
        c99v7 = c99v3 / c99v5
        c99v8 = c99v4 / c99v6
        c99v10 = mMovie
        c99v10 = c99v10:GetCursorX()
        c99v9 = c99v10 / c99v7
        c99v11 = mMovie
        c99v11 = c99v11:GetCursorY()
        c99v10 = c99v11 / c99v8
        if c99v2 == "1" then
          c99v12 = mMovie
          c99v12 = c99v12:GetCursorX()
          c99v11 = c99v12 / c99v3
          c99v13 = mMovie
          c99v13 = c99v13:GetCursorY()
          c99v12 = c99v13 / c99v4
          c99v13 = v81
          c99v13 = c99v13(c99v11, c99v12)
          if c99v13 then
            c99v14 = v68
            c99v15 = true
            c99v14.mouseDown = c99v15
            c99v14 = v68
            c99v15 = Vector
            c99v18 = 0
            c99v15 = c99v15(c99v9, c99v10, c99v18)
            c99v14.mouseDownPos = c99v15
          else
            c99v14 = _T.UpdateButtons
            if c99v14 ~= nil then
              c99v14 = _T.UpdateButtons
              c99v14()
            end
          end
        else
          if c99v2 == "0" then
            c99v11 = v68
            c99v11 = c99v11.mouseDown
            if c99v11 then
              c99v11 = v68
              c99v12 = false
              c99v11.mouseDown = c99v12
              c99v11 = Vector
              c99v14 = 0
              c99v11 = c99v11(c99v9, c99v10, c99v14)
              c99v13 = v68
              c99v13 = c99v13.mouseDownPos
              c99v12 = c99v11 - c99v13
              c99v14 = c99v12.x
              c99v13 = math.abs
              c99v13 = c99v13(c99v14)
              c99v14 = 80
              if c99v14 < c99v13 then
                c99v13 = c99v12.x
                c99v14 = 0
                if c99v14 < c99v13 then
                  c99v13 = v112
                  c99v14 = v2
                  c99v14 = c99v14.DECREMENT
                  c99v13(c99v14)
                else
                  c99v13 = v112
                  c99v14 = v2
                  c99v14 = c99v14.INCREMENT
                  c99v13(c99v14)
                end
              end
              c99v13 = v68
              c99v14 = false
              c99v13.dragStarted = c99v14
            end
          end
        end
      end
    end
    c99v3 = Engine.IsSwitch2
    c99v3 = c99v3()
    if c99v3 then
      c99v3 = Engine.KBMControlsDisabled
      c99v3 = c99v3()
      if not (((c99v3 or c99v1 ~= "EN_MOUSE_B0") or c99v2 ~= "1")) then
        c99v3 = v112
        c99v4 = v2
        c99v4 = c99v4.INCREMENT
        c99v3(c99v4)
      end
    end
    if c99v2 ~= "1" then
      c99v2 = false
    else
      c99v2 = true
    end
    if not ((not (c99v1 == "EN_LSHIFT") and c99v1 ~= "EN_RSHIFT")) then
      v16 = c99v2
      do return end
    end
    if not ((not c99v2 or c99v1 ~= "EN_TAB")) then
      c99v3 = v112
      c99v4 = v2
      c99v4 = c99v4.Ternary
      c99v5 = v16
      c99v6 = v2
      c99v6 = c99v6.DECREMENT
      c99v7 = v2
      c99v7 = c99v7.INCREMENT
      c99v3(c99v4(c99v5, c99v6, c99v7))
    end
    do return end
  end
  onRawInputEvent = v114
  v114 = function(c100v0)
    local c100v1
    c100v1 = v92
    c100v1()
    c100v1 = v93
    c100v1()
    do return end
  end
  OnGamepadTransition = v114
  v114 = function()
    local c101v0
    c101v0 = true
    do return c101v0 end
  end
  SupportsThemes = v114
  v114 = function()
    local c102v0
    c102v0 = true
    do return c102v0 end
  end
  AlwaysShowLabels = v114
  v114 = function()
    local c103v0
    c103v0 = v17
    if c103v0 ~= nil then
      c103v0 = v17
      c103v0 = c103v0.ShowDisposition
      do return c103v0 end
    end
    c103v0 = false
    do return c103v0 end
  end
  ShouldShowOmegaAttenStat = v114
  v114 = function(c104v0, c104v1)
    local c104v2, c104v3, c104v5
    c104v2 = false
    v58 = c104v2
    v59 = c104v0
    c104v2 = string.upper
    c104v3 = Localize
    c104v5 = true
    c104v2 = c104v2(c104v3(c104v1, c104v5))
    v60 = c104v2
    c104v2 = v90
    c104v2()
    do return end
  end
  OverrideItemInfoData = v114
  do return end
end
