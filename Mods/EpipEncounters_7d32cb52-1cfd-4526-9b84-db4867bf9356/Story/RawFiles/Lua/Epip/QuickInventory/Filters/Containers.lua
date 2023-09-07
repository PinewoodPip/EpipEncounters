
---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")
local UI = QuickInventory.UI

---------------------------------------------
-- TSKS
---------------------------------------------

QuickInventory.TranslatedStrings.Setting_Containers_ShowEmpty_Name = QuickInventory:RegisterTranslatedString("had445364gfe3dg43c1ga8a3g855bc9d11c27", {
    Text = "Show Empty",
    ContextDescription = "Option name for showing empty containers",
})
QuickInventory.TranslatedStrings.Setting_Containers_ShowEmpty_Description = QuickInventory:RegisterTranslatedString("h39e10fefg8a83g4390gad94g1dc051c2f943", {
    Text = "If enabled, containers with no items will shown.",
    ContextDescription = "Option tooltip",
})

---------------------------------------------
-- SETTINGS
---------------------------------------------

QuickInventory.Settings.Containers_ShowEmpty = QuickInventory:RegisterSetting("Containers_ShowEmpty", {
    Type = "Boolean",
    Name = QuickInventory.TranslatedStrings.Setting_Containers_ShowEmpty_Name,
    Description = QuickInventory.TranslatedStrings.Setting_Containers_ShowEmpty_Description,
    DefaultValue = false,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Apply filters.
QuickInventory.Hooks.IsItemVisible:Subscribe(function (ev)
    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Containers" then
        local visible = Item.IsContainer(ev.Item)
        local showEmpty = QuickInventory:GetSettingValue(QuickInventory.Settings.Containers_ShowEmpty) == true

        visible = visible and (showEmpty or ev.Item:GetInventoryItems()[1])

        ev.Visible = visible
    end
end)

-- Render subsettings.
UI.Events.RenderSettings:Subscribe(function (ev)
    if ev.ItemCategory == "Containers" then
        UI.RenderSetting(QuickInventory.Settings.Containers_ShowEmpty)
    end
end)