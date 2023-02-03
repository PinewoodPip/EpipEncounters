
---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Consumables filter.
QuickInventory.Hooks.IsItemVisible:Subscribe(function (ev)
    local item = ev.Item
    local visible = ev.Visible

    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Consumables" then
        visible = visible and Item.HasUseAction(item, "Consume")
    end
    
    ev.Visible = visible
end)