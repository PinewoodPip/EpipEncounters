
---@class Feature_ExtraDataConfig : Feature
local DataConfig = {
    ModifiedEntries = {}, ---@type table<string, number>
}
Epip.AddFeature("ExtraDataConfig", "ExtraDataConfig", DataConfig)

---------------------------------------------
-- METHODS
---------------------------------------------

function DataConfig.SetValue(key, value)
    local data = Stats.ExtraData[key]

    if data then
        local defaultValue = data:GetDefaultValue(Mod.GUIDS.EE_CORE)

        Stats.Update("Data", key, value)

        -- Track which entries have modified values (relative to the default ones)
        if value ~= defaultValue then
            DataConfig.ModifiedEntries[key] = value
        else
            DataConfig.ModifiedEntries[key] = nil
        end
    else
        DataConfig:LogError("Invalid key: " .. key)
    end
end

---@param key string
---@return OptionsSettingsOption
function DataConfig.GetOptionData(key)
    local data = Stats.ExtraData[key]
    local defaultValue = data:GetDefaultValue(Mod.GUIDS.EE_CORE)

    ---@type OptionsSettingsOption
    local option = {
        ID = key,
        Label = data:GetName(),
        Tooltip = data:GetDescription(),
        Type = "Slider",
        MinAmount = 0,
        MaxAmount = defaultValue * 2,
        DefaultValue = defaultValue,
        HideNumbers = false,
        Interval = 0.1,
        IsExtraData = true,
    }

    return option
end