
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

    local min, max = 0, defaultValue * 2

    -- Set max value to 10 for stats that default to 0 (we can't really know an appropriate range)
    if defaultValue == 0 then
        max = 10
    elseif defaultValue < 0 then -- Allow negative values for keys with a negative default value
        min = defaultValue * 2
        max = -defaultValue * 2
    end

    ---@type OptionsSettingsOption
    local option = {
        ID = key,
        Label = data:GetName(),
        Tooltip = Text.Format("%s<br>Default value: %s", {
            FormatArgs = {
                data:GetDescription(),
                defaultValue,
            }
        }),
        Type = "Slider",
        MinAmount = min,
        MaxAmount = max,
        DefaultValue = defaultValue,
        HideNumbers = false,
        Interval = 0.1,
        IsExtraData = true,
    }

    return option
end