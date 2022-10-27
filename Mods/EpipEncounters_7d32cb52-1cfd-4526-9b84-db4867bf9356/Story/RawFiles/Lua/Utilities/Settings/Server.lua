
---@class SettingsLib
local Settings = Settings
Settings._SettingsLoaded = false

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
    Settings:Dump(vars)

    for moduleID,settings in pairs(vars) do
        for id,value in pairs(settings) do
            Settings.SetValue(moduleID, id, value)
        end
    end

    Settings._SettingsLoaded = true

    Settings.SynchronizeSettings()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to sync settings from the host.
Net.RegisterListener(Settings.NET_SYNC_CHANNEL, function (payload)
    local setting = Settings.GetSetting(payload.Module, payload.ID)

    if setting then
        Settings:DebugLog("Synched setting from host: " .. setting.ID)

        Settings.SetValue(setting.ModTable, setting.ID, payload.Value, true)

        -- Synchronize setting changes to PersistentVars.
        if setting.Context == "Server" then
            Settings.SynchronizeSetting(setting)
    
            if Settings._SettingsLoaded then
                local vars = Settings:GetPersistentVariables()
                
                Settings:DebugLog("Saved setting to PersistentVars", setting.ID, payload.Value)
                
                -- TODO optimize
                vars[setting.ModTable] = Settings.GetModuleSettingValues(setting.ModTable)
            end
        end
    else
        Settings:LogError("Tried to sync an unregistered setting: " .. payload.ID)
    end
end)

-- Load and synchronize server settings upon the game starting.
Ext.Osiris.RegisterListener("GameStarted", 2, "after", function()
    Settings.Load()
end)

-- Load and synchronize server settings after a reset.
Ext.Events.ResetCompleted:Subscribe(function (_)
    Ext.OnNextTick(function ()
        local vars = IO.LoadFile("_Epip_PersistentVars", "user")
    
        if vars then
            PersistentVars = vars
        end
        Settings.Load()
    end)
end)