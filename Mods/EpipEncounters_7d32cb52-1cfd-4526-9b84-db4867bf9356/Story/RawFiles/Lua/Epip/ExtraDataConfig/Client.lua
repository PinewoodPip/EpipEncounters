
---@class Feature_ExtraDataConfig : Feature
local DataConfig = Epip.Features.ExtraDataConfig
local OptionsSettings = Client.UI.OptionsSettings

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

OptionsSettings:RegisterListener("OptionSet", function(data, value)
    if data.IsExtraData then
        local extraData = Stats.ExtraData[data.ID]

        DataConfig.SetValue(extraData.ID, value)

        Net.PostToServer("EPIPENCOUNTERS_SetExtraData", {
            Key = extraData.ID,
            Value = value,
        })

        DataConfig.SaveSettings()
    end
end)

OptionsSettings:RegisterListener("ButtonClicked", function(element)
    if element.ID == "ExtraDataConfig_Reset" then
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
OptionsSettings.RegisterMod("ExtraDataConfig", {
    TabHeader = "Extra Data",
    SideButtonLabel = "Extra Data",
    ServerOnly = true,
})

local entries = {}
for _,entry in pairs(Stats.ExtraData) do
    table.insert(entries, entry) 
end
table.sort(entries, function (a, b) return a:GetName() < b:GetName() end)

OptionsSettings.RegisterOption("ExtraDataConfig", {
    ID = "ExtraDataConfig_Reset",
        Type = "Button",
        ServerOnly = true,
        Label = "Reset to Defaults",
        Tooltip = "Resets the settings to default. You will still need to reload for many keys to apply.",
        DefaultValue = false,
})

for _,entry in ipairs(entries) do
    OptionsSettings.RegisterOption("ExtraDataConfig", DataConfig.GetOptionData(entry.ID))
end