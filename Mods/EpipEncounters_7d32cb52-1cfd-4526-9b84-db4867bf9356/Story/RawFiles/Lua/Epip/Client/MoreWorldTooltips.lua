
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
    return Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", MoreWorldTooltips.SETTING_ID)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Enable tooltips for all registered items on the level.
GameState.Events.GameReady:Subscribe(function (_)
    if MoreWorldTooltips:IsEnabled() then
        local level = Ext.Entity.GetCurrentLevel()
        local levelID = level.LevelDesc.UniqueKey
        local items = level.EntityManager.ItemConversionHelpers.RegisteredItems[levelID]
    
        for _,item in ipairs(items) do
            item.RootTemplate.Tooltip = 2
        end
    end
end)