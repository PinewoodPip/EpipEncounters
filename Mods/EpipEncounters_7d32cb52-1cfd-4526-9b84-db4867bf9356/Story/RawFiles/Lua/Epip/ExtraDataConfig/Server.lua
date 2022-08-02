
---@class Feature_ExtraDataConfig : Feature
local DataConfig = Epip.Features.ExtraDataConfig
local ServerSettings = Epip.Features.ServerSettings

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

ServerSettings.Events.SettingChanged:RegisterListener(function (setting, value)
    if setting.IsExtraData then
        local data = Stats.ExtraData[setting.ID]
        
        DataConfig.SetValue(data.ID, value)
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Generate settings.
for key,_ in pairs(Stats.ExtraData) do
    ServerSettings.AddOption("ExtraDataConfig", DataConfig.GetOptionData(key))
end