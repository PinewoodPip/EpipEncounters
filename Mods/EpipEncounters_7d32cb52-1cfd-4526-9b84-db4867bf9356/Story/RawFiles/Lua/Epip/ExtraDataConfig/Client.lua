
---@class Feature_ExtraDataConfig : Feature
local DataConfig = Epip.Features.ExtraDataConfig
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- TODO rework this into server settings, so it synchs automatically?
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting ---@type {IsExtraData: boolean} | SettingsLib_Setting
    if setting.IsExtraData and GameState.IsInSession() then
        local extraData = Stats.ExtraData[setting.ID]

        DataConfig.SetValue(extraData.ID, ev.Value)

        Net.PostToServer("EPIPENCOUNTERS_SetExtraData", {
            Key = extraData.ID,
            Value = ev.Value,
        })

        DataConfig.SaveSettings()
    end
end)

SettingsMenu.Events.ButtonPressed:Subscribe(function (ev)
    if ev.ButtonID == "ExtraDataConfig_Reset" then
        for key,_ in pairs(DataConfig.ModifiedEntries) do
            local defaultValue = Stats.ExtraData[key]:GetDefaultValue()

            DataConfig.SetValue(key, defaultValue, true)

            DataConfig.SaveSettings()
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Generate settings.
local tab = {
    ID = DataConfig.SETTINGS_MODULE_ID,
    ButtonLabel = "Extra Data",
    HeaderLabel = "Extra Data",
    HostOnly = true,
    Entries = {
        {Type = "Button", ID = "ExtraDataConfig_Reset", Label = "Reset to Defaults", Tooltip = "Resets the settings to default. You will still need to reload for many keys to apply."},
    },
}
SettingsMenu.RegisterTab(tab)

local entries = {}
for _,entry in pairs(Stats.ExtraData) do
    table.insert(entries, entry)
end
table.sort(entries, function (a, b) return a:GetName() < b:GetName() end)

for _,entry in ipairs(entries) do
    Settings.RegisterSetting(DataConfig.GetOptionData(entry.ID))

    table.insert(tab.Entries, {Type = "Setting", Module = DataConfig.SETTINGS_MODULE_ID, ID = entry.ID})
end