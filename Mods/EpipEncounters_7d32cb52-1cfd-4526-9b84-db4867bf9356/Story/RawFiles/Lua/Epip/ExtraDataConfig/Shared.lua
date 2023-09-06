
---@class Feature_ExtraDataConfig : Feature
local DataConfig = {
    ModifiedEntries = {}, ---@type table<string, number>
    SAVE_VERSION = 0,
    SAVE_FILENAME = "EpipEncounters_ExtraData.json",
    SETTINGS_MODULE_ID = "ExtraDataConfig",
}
Epip.RegisterFeature("ExtraDataConfig", DataConfig)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_SetExtraData : NetMessage
---@field Key string
---@field Value number

---------------------------------------------
-- METHODS
---------------------------------------------

---@param key string
---@param value number
---@param save boolean? TODO better name
function DataConfig.SetValue(key, value, save)
    local data = Stats.ExtraData[key]

    if data then
        local defaultValue = data:GetDefaultValue()

        Stats.Update("Data", key, value)

        -- Track which entries have modified values (relative to the default ones)
        if value ~= defaultValue then
            DataConfig.ModifiedEntries[key] = value
        else
            DataConfig.ModifiedEntries[key] = nil
        end

        -- Save settings.
        if save then
            if Ext.IsClient() then
                Settings.SetValue(DataConfig.SETTINGS_MODULE_ID, key, value)
            else 
                DataConfig.SaveSettings()
            end
        end
    else
        DataConfig:LogError("Invalid key: " .. key)
    end
end

---@param key string
---@return SettingsLib_Setting_ClampedNumber
function DataConfig.GetOptionData(key)
    local data = Stats.ExtraData[key]
    local defaultValue = data:GetDefaultValue()

    local min, max = 0, defaultValue * 2

    -- Set max value to 10 for stats that default to 0 (we can't really know an appropriate range)
    if defaultValue == 0 then
        max = 10
    elseif defaultValue < 0 then -- Allow negative values for keys with a negative default value
        min = defaultValue * 2
        max = -defaultValue * 2
    end

    ---@type SettingsLib_Setting_ClampedNumber
    local option = {
        ID = key,
        Type = "ClampedNumber",
        ModTable = DataConfig.SETTINGS_MODULE_ID,
        Name = data:GetName(),
        Description = Text.Format("%s<br>Default value: %s", {
            FormatArgs = {
                data:GetDescription(),
                defaultValue,
            }
        }),
        Min = min,
        Max = max,
        Step = 0.1,
        HideNumbers = false,
        IsExtraData = true,
        SaveOnServer = true,
        ServerOnly = true,
        DefaultValue = defaultValue,
    }

    return option
end

---@param path string?
function DataConfig.LoadSettings(path)
    path = path or DataConfig.SAVE_FILENAME
    local save = IO.LoadFile(path)

    if save then
        for key,value in pairs(save.Keys) do
            DataConfig.SetValue(key, value, true)
        end
    end
end

---@param path string?
function DataConfig.SaveSettings(path)
    path = path or DataConfig.SAVE_FILENAME

    local save = {
        Version = DataConfig.SAVE_VERSION,
        Keys = DataConfig.ModifiedEntries,
    }

    IO.SaveFile(path, save)
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Load settings.
DataConfig.LoadSettings()