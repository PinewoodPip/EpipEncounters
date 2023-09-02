
---@class Feature_MoreWorldTooltips : Feature
local MoreWorldTooltips = {
    SETTING_ID = "WorldTooltip_MoreTooltips",
}
Epip.RegisterFeature("MoreWorldTooltips", MoreWorldTooltips)

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function MoreWorldTooltips:IsEnabled()
    return Settings.GetSettingValue("Epip_Tooltips", MoreWorldTooltips.SETTING_ID)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Enable tooltips for all registered items on the level.
GameState.Events.GameReady:Subscribe(function (_)
    if MoreWorldTooltips:IsEnabled() then
        local level = Ext.Entity.GetCurrentLevel()
        local levelID = level.LevelDesc.LevelName -- EntityManager uses non-unique ID.
        local items = level.EntityManager.ItemConversionHelpers.RegisteredItems[levelID]

        for _,item in ipairs(items) do
            item.RootTemplate.Tooltip = 2
        end

        -- Patch root templates
        local templates = Ext.Template.GetAllRootTemplates()
        for _,template in pairs(templates) do
            if GetExtType(template) == "ItemTemplate" then
                ---@cast template ItemTemplate
                template.Tooltip = 2
            end
        end
    end
end)