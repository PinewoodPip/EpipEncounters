
---------------------------------------------
-- Quick Find filter for runes and equipment with inserted runes.
---------------------------------------------

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")
local UI = QuickInventory.UI

---------------------------------------------
-- TSKS
---------------------------------------------

QuickInventory.TranslatedStrings.Setting_ShowEquipmentWithRunes_Name = QuickInventory:RegisterTranslatedString({
    Handle = "h77aca1e5g43f9g4d07g8211g512f6068554c",
    Text = [[Show equipment with runes]],
    ContextDescription = [[Setting name in "Runes" category filter]],
})
QuickInventory.TranslatedStrings.Setting_ShowEquipmentWithRunes_Description = QuickInventory:RegisterTranslatedString({
    Handle = "h49bc9f8fga5abg4fd9g8435g752a08186863",
    Text = [[If enabled, equipment with inserted runes will be shown.]],
    ContextDescription = [[Setting tooltip for "Show equipment with runes"]],
})

---------------------------------------------
-- SETTINGS
---------------------------------------------

QuickInventory.Settings.ShowEquipmentWithRunes = QuickInventory:RegisterSetting("ShowEquipmentWithRunes", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.Setting_ShowEquipmentWithRunes_Name,
    Description = QuickInventory.TranslatedStrings.Setting_ShowEquipmentWithRunes_Description,
    DefaultValue = false,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Apply filters.
QuickInventory.Hooks.IsItemVisible:Subscribe(function (ev)
    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Runes" and ev.Visible then
        local visible = Item.IsRune(ev.Item)

        -- Also show equipment with runes inserted.
        if QuickInventory:GetSettingValue(QuickInventory.Settings.ShowEquipmentWithRunes) and not visible then
            if Item.IsEquipment(ev.Item) then
                for i=0,Item.GetRuneSlots(ev.Item)-1,1 do
                    local rune = Item.GetRune(ev.Item, i)
                    if rune then visible = true break end
                end
            end
        end

        ev.Visible = visible
    end
end)

-- Sort runes by their tier, and show equipment with runes before runes themselves.
QuickInventory.Hooks.SortItems:Subscribe(function (ev)
    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Runes" then
        -- Sort by rune tier
        local statsA, statsB = ev.ItemA.StatsId, ev.ItemB.StatsId
        local runeLevelA = Stats.GetRuneTier(statsA) or math.maxinteger -- Non-runes displays first.
        local runeLevelB = Stats.GetRuneTier(statsB) or math.maxinteger
        if runeLevelA ~= runeLevelB then
            ev.Result = runeLevelA > runeLevelB
        end
    end
end)

-- Render category settings.
UI.Events.RenderSettings:Subscribe(function (ev)
    if ev.ItemCategory == "Runes" then
        UI.RenderSetting(QuickInventory.Settings.ShowEquipmentWithRunes)
    end
end)
