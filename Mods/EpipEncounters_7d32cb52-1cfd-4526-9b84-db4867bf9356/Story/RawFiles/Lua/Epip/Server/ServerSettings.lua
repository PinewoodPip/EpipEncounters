
local Settings = {
    MODULES = {

    },
    Events = {
        ---@type ServerSettings_Event_SettingChanged
        SettingChanged = {},
    },
}
Epip.AddFeature("ServerSettings", "ServerSettings", Settings)
Epip.Features.ServerSettings = Settings
Settings:Debug()

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired when a setting's value changes or is set for the first time.
---@class ServerSettings_Event_SettingChanged : Event
---@field RegisterListener fun(self, listener:fun(setting:OptionsSettingsOption, value:any))
---@field Fire fun(self, setting:OptionsSettingsOption, value:any)

---------------------------------------------
-- METHODS
---------------------------------------------

---Register a set of options. Must be called before GameStarted.
---@param module string
---@param settings table<string, OptionsSettingsOption>
function Settings.AddModule(module, data)
    Settings.MODULES[module] = data
end

---Register an option to an existing module. Must be called before GameStarted.
---@param modID string
---@param data OptionsSettingsOption
function Settings.AddOption(modID, data)
    local mod = Settings.MODULES[modID]

    if not mod then
        Settings.AddModule(modID, {})
    end

    Settings.MODULES[modID][data.ID] = data
end

---Sets an option's value and saves it to the savefile.
---@param module string
---@param setting string
---@param value any
function Settings.SetValue(module, setting, value)
    value = Settings.ConvertToReal(value)

    Osiris.DB_PIP_Setting_Real:Delete(module, setting, nil)
    Osiris.DB_PIP_Setting_Real:Set(module, setting, value)

    Settings.Events.SettingChanged:Fire(Settings.GetSettingData(module, setting), value)
end

---Returns the data for a settings.
---@param module string Module ID.
---@param setting string Setting ID.
---@return OptionsSettingsOption
function Settings.GetSettingData(module, setting)
    local module = Settings.MODULES[module]
    local data = nil

    if module then
        data = module[setting]
    end

    return data
end

function Settings.GetValue(module, setting)
    -- Check if DB exists
    local _, _, value = Osiris.DB_PIP_Setting_Real:Get(module, setting, nil)
    local settingData = Settings.GetSettingData(module, setting)

    if settingData then
        -- Use default setting value.
        if not value then
            value = settingData.DefaultValue
        end

        value = Settings.ConvertFromReal(settingData, value)
    else
        value = nil
    end

    return value
end

---@param setting OptionsSettingsOption
---@param value number
---@return any
function Settings.ConvertFromReal(setting, value)
    local valueType = type(setting.DefaultValue)

    -- Convert real to inteded type
    if valueType == "boolean" and type(value) ~= "boolean" then
        if value > 0 then
            value = true
        else
            value = false
        end
    end

    return value
end

function Settings.ConvertToReal(value)
    local type = type(value)
    local convertedValue = value

    if type == "boolean" then
        if value then
            convertedValue = 1
        else
            convertedValue = 0
        end
    end

    return convertedValue
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for option changes from the client.
Net.RegisterListener("EPIPENCOUNTERS_ServerOptionChanged", function(cmd, payload)
    local setting = payload.Setting
    local value = payload.Value
    local module = payload.Mod

    -- Only call SetValue for settings registered to be tracked on server.
    if Settings.GetSettingData(module, setting) then
        Settings.SetValue(module, setting, value)
    end
end)

local function Init()
    for module,optionSet in pairs(Settings.MODULES) do
        for i,setting in pairs(optionSet) do
            local id = setting.ID
            if setting.SaveOnServer then
                local _, _, value = Osiris.DB_PIP_Setting_Real:Get(module, id, nil)
    
                if not value then
                    Settings.SetValue(module, id, setting.DefaultValue)
    
                    Settings:DebugLog("Set default value for setting " .. id .. " from module " .. module)

                    Net.PostToCharacter(CharacterGetHostCharacter(), "EPIPENCOUNTERS_ServerSettingSynch", {
                        Module = module,
                        Setting = setting.ID,
                        Value = setting.DefaultValue,
                    })
                else
                    Settings:DebugLog("Synching setting from server to host: " .. setting.ID)

                    Net.PostToCharacter(CharacterGetHostCharacter(), "EPIPENCOUNTERS_ServerSettingSynch", {
                        Module = module,
                        Setting = setting.ID,
                        Value = Settings.ConvertFromReal(setting, value),
                    })
                end
            end
        end
    end
end

-- Initialize setting DBs with default values upon loading.
Ext.Events.ResetCompleted:Subscribe(function()
    Osi.TimerLaunch("_ResetCompleted", 100)
end)

Ext.Osiris.RegisterListener("GameStarted", 2, "after", Init)

Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(t)
    if t == "_ResetCompleted" then
        Init()
    end
end)