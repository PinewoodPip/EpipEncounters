
---@class SettingsLib
local Settings = Settings

---------------------------------------------
-- METHODS
---------------------------------------------

---Saves current settings of a module to a file.
---@param modTable string
---@param fileName string? Defaults to "Epip/Settings/{modTable}_{profileGUID}.json"
function Settings.Save(modTable, fileName)
    local module = Settings.GetModule(modTable)
    fileName = fileName or string.format(Settings.DEFAULT_SAVE_FILENAME, modTable, Client.GetProfileGUID())

    Settings:DebugLog("Saving settings for module " .. modTable)

    if module then
        local settingValues = Settings.GetModuleSettingValues(modTable)
        local save = {
            SaveVersion = Settings.SAVE_VERSION,
            Settings = settingValues,
        }

        -- Temporary workaround for not being able to created nested directories in one go. TODO remove once/if Norbyte fixes this.
        IO.SaveFile("Epip/ignore.txt", "")

        IO.SaveFile(fileName, save)
    else
        Settings:LogError("Save(): module not registered: " .. modTable)
    end
end

---Loads settings for a module from a file, replacing current values.
---@param modTable string
---@param fileName string? Defaults to "Epip/Settings/{modTable}_{profileGUID}.json"
function Settings.Load(modTable, fileName)
    local module = Settings.GetModule(modTable)
    fileName = fileName or string.format(Settings.DEFAULT_SAVE_FILENAME, modTable, Client.GetProfileGUID())

    Settings:DebugLog("Loading settings for module " .. modTable)

    if module then
        local save = IO.LoadFile(fileName)

        if save and save.SaveVersion == 0 then
            -- Set values of all stored settings.
            for settingID,value in pairs(save.Settings) do
                Settings.SetValue(modTable, settingID, value)
            end
        end
    else
        Settings:LogError("Load(): module not registered: " .. modTable)
    end
end