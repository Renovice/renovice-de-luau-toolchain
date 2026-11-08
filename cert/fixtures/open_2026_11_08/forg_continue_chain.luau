local function f()
  while true do
    local players = gRegion:GetHumanPlayers()
    for _, p in players do
      if not IsNull(p) then
        if not IsNull(av) then
          local suit = av:InventoryControl():GetActivePowerSuit()
          if not IsNull(suit) then
            if not IsNull(av2) then
              if not IsNull(suit2) then
                if IsNull(ult) or not suit2:IsAbilityUnlocked(suit2:Find(ult:GetType())) then
                  Give(p:GetLoadOut(), true, 2)
                end
              end
            end
          end
        end
      end
    end
  end
end
return f
