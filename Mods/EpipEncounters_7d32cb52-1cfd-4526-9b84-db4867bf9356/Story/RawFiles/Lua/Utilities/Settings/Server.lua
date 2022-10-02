
---@class SettingsLib
local Settings = Settings

---------------------------------------------
-- METHODS
---------------------------------------------

function Settings.SynchronizeSettings()
    for _,module in pairs(Settings.Modules) do
        for _,setting in pairs(module.Settings) do
            Settings.SynchronizeSetting(setting)
        end
    end
end

---@param setting SettingsLib_Setting
function Settings.SynchronizeSetting(setting)
    local value = setting:GetValue()

    if setting.Context == "Server" then
        Net.Broadcast(Settings.NET_SYNC_CHANNEL, {
            Module = setting.ModTable,
            ID = setting.ID,
            Value = value,
        })
    end
end

function Settings.Load()
    local vars = Settings:GetPersistentVariables()

    Settings:DebugLog("Loading server settings")

    for moduleID,settings in pairs(vars) do
        for id,value in pairs(settings) do
            Settings.SetValue(moduleID, id, value)
        end
    end

    Settings.SynchronizeSettings()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Synchronize setting changes to PersistentVars.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting

    if setting.Context == "Server" then
        local vars = Settings:GetPersistentVariables()
        
        vars[setting.ModTable] = Settings.GetModuleSettingValues(setting.ModTable)
    end
end)

-- Listen for requests to sync settings from the host.
Net.RegisterListener(Settings.NET_SYNC_CHANNEL, function (payload)
    local setting = Settings.GetSetting(payload.Module, payload.ID)

    if setting then
        Settings:DebugLog("Synched setting from host: " .. setting.ID)

        Settings.SetValue(setting.ModTable, setting.ID, payload.Value)
    else
        Settings:LogError("Tried to sync an unregistered setting: " .. payload.ID)
    end
end)

-- Load saved settings.
Ext.Events.SessionLoading:Subscribe(function (_)
    Settings.Load()
end)

-- Synchronize server settings upon the game starting.
Ext.Osiris.RegisterListener("GameStarted", 2, "after", function()
    Settings.SynchronizeSettings()
end)