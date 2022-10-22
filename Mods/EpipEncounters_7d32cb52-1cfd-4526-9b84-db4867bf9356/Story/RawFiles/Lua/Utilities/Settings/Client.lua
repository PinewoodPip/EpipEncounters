
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

        -- Don't save server settings.
        for id,_ in pairs(settingValues) do
            local setting = Settings.GetSetting(moduleName, id)

            if setting and setting.Context == "Server" then
                settingValues[id] = nil
            end
        end

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

---@param setting SettingsLib_Setting
function Settings.SynchronizeSetting(setting)
    local value = setting:GetValue()

    if setting.Context ~= "Client" and Client.IsHost() then
        Net.PostToServer(Settings.NET_SYNC_CHANNEL, {
            Module = setting.ModTable,
            ID = setting.ID,
            Value = value,
        })
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Synchronize host setting changes to the server.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting.Context ~= "Client" then
        Settings.SynchronizeSetting(ev.Setting)
    end
end)

-- Synchronize host settings to the server.
Client:RegisterListener("DeterminedAsHost", function ()
    local modules = Settings.GetModules()

    for _,module in pairs(modules) do
        for _,setting in pairs(module.Settings) do
            Settings.SynchronizeSetting(setting)
        end
    end
end)

-- Listen for sync requests from the server.
Net.RegisterListener(Settings.NET_SYNC_CHANNEL, function (payload)
    local setting = Settings.GetSetting(payload.Module, payload.ID)

    if setting then
        Settings:DebugLog("Synched setting from server: " .. setting.ID)

        Settings.SetValue(setting.ModTable, setting.ID, payload.Value, false)
    else
        Settings:LogError("Tried to sync an unregistered setting: " .. payload.ID)
    end
end)