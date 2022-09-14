
---@class SettingsLib
local Settings = Settings
Settings.DEFAULT_SAVE_FILENAME = "Epip/Settings/%s/%s.json"
Settings.SAVE_VERSION = 0

---------------------------------------------
-- METHODS
---------------------------------------------

---Saves current settings of a module to a file.
---@param moduleName string
---@param fileName string? Defaults to "Epip/Settings/{profileGUID}/{moduleName}.json"
function Settings.Save(moduleName, fileName)
    local module = Settings.GetModule(moduleName)
    fileName = fileName or string.format(Settings.DEFAULT_SAVE_FILENAME, Client.GetProfileGUID(), moduleName)

    Settings:DebugLog("Saving settings for module " .. moduleName)

    if module then
        local settingValues = Settings.GetModuleSettingValues(moduleName)
        local save = {
            SaveVersion = Settings.SAVE_VERSION,
            Settings = settingValues,
        }

        -- Temporary workaround for not being able to created nested directories in one go. TODO remove once/if Norbyte fixes this.
        IO.SaveFile("Epip/ignore.txt", "")
        IO.SaveFile("Epip/Settings/ignore.txt", "")

        IO.SaveFile(fileName, save)
    else
        Settings:LogError("Save(): module not registered: " .. moduleName)
    end
end

---Loads settings for a module from a file, replacing current values.
---@param moduleName string
---@param fileName string? Defaults to "Epip/Settings/{profileGUID}/{moduleName}.json"
function Settings.Load(moduleName, fileName)
    local module = Settings.GetModule(moduleName)
    fileName = fileName or string.format(Settings.DEFAULT_SAVE_FILENAME, Client.GetProfileGUID(), moduleName)

    Settings:DebugLog("Loading settings for module " .. moduleName)

    if module then
        local save = IO.LoadFile(fileName)

        if save and save.SaveVersion == 0 then
            -- Set values of all stored settings.
            for settingID,value in pairs(save.Settings) do
                Settings.SetValue(moduleName, settingID, value)
            end
        end
    else
        Settings:LogError("Load(): module not registered: " .. moduleName)
    end
end