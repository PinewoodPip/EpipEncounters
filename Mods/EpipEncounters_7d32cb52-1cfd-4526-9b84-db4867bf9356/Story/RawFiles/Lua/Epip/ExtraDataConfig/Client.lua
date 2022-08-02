
---@class Feature_ExtraDataConfig : Feature
local DataConfig = Epip.Features.ExtraDataConfig
local OptionsSettings = Client.UI.OptionsSettings

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.OptionsSettings:RegisterListener("OptionSet", function(data, value)
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

for _,entry in ipairs(entries) do
    OptionsSettings.RegisterOption("ExtraDataConfig", DataConfig.GetOptionData(entry.ID))
end