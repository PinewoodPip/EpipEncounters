
---------------------------------------------
-- Displays whether an item has been masterworked within its tooltip.
---------------------------------------------

---@type Feature
local MasterworkedHint = {
    ---@type table<string, true>
    MASTERWORKED_DELTAMODS = {
        ["Boost_Weapon_Masterwork"] = true,
        ["Boost_Armor_Masterwork"] = true,
        ["Boost_Shield_Masterwork"] = true,
    },

    Settings = {},
    TranslatedStrings = {
        Setting_Enabled_Name = {
           Handle = "h5018b6b9g7897g429fg9440gb60d076ace93",
           Text = "Show Masterworked hint",
           ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
           Handle = "h420215fegeaecg4ccdg9e74gf68ed7bd72b9",
           Text = "If enabled, item tooltips will show a hint if the item has been Masterworked.",
           ContextDescription = "Setting tooltip",
        },
    }
}
Epip.RegisterFeature("TooltipAdjustments.MasterworkedHint", MasterworkedHint)
local TSK = MasterworkedHint.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

MasterworkedHint.Settings.Enabled = MasterworkedHint:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = TSK.Setting_Enabled_Description,
    DefaultValue = true,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Adds a hint to the tooltip of Masterworked items.
---@param item EclItem Must have stats.
---@param tooltip TooltipLib_FormattedTooltip
function MasterworkedHint.AddHint(item, tooltip)
    if not item.Stats then return nil end

    local isMasterworked = false
    for _,deltaModID in pairs(item:GetDeltaMods()) do
        if MasterworkedHint.MASTERWORKED_DELTAMODS[deltaModID] then
            isMasterworked = true
        end
    end

    if not isMasterworked then return nil end

    tooltip:InsertElement({
        Type = "StatsTalentsMalus",
        Label = Text.CommonStrings.Masterworked:GetString(),
    })
end

---@override
function MasterworkedHint:IsEnabled()
    return self:GetSettingValue(MasterworkedHint.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if Item.IsEquipment(ev.Item) and MasterworkedHint:IsEnabled() then
        MasterworkedHint.AddHint(ev.Item, ev.Tooltip)
    end
end)