
---------------------------------------------
-- Modernized, UI-independent settings library.
-- Successor to the previous system bound to OptionsSettings.
---------------------------------------------

---@class SettingsLib : Library
Settings = {
    Modules = {}, ---@type table<string, SettingsLib_Module>
    SettingTypes = {}, ---@type table<SettingsLib_SettingType, SettingsLib_Setting>

    unregisteredSettingValues = {}, ---@type table<string, table<string, {Value: any, Deserialize: boolean?}>>

    _unregisteredSettingWarningShown = false,

    NET_SYNC_CHANNEL = "EPIP_SETTINGS_SYNC",

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        SettingValueChanged = {}, ---@type Event<SettingsLib_Event_SettingValueChanged>
    },
    Hooks = {
        GetSettingValue = {}, ---@type Event<SettingsLib_Hook_GetSettingValue>
    }
}
Epip.InitializeLibrary("Settings", Settings)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias SettingsLib_SettingType "Boolean"|"Number"|"ClampedNumber"|"Choice"|"Set"|"Map"

---@class EPIP_SETTINGS_SYNC
---@field Module string
---@field ID string
---@field Value any

---A module defines the settings registered for a particular mod.
---@class SettingsLib_Module
---@field ModTable string
---@field Settings table<string, SettingsLib_Setting>

---Represents a setting and holds its value.
---For serialization, you are expected to implement value getter/setters as functions that return only one value. Additional ones will be discarded.
---@class SettingsLib_Setting : I_Identifiable, I_Describable
---@field Type SettingsLib_SettingType
---@field Context "Client"|"Server"|"Host"
---@field ModTable string
---@field Value any
---@field DefaultValue any
local _Setting = {}
Settings._SettingClass = _Setting

---Creates a new setting.
---@param data SettingsLib_Setting
function _Setting:Create(data)
    Inherit(data, self)
    data.Value = data:GetDefaultValue()

    data:_Init()
    data:SetValue(data.DefaultValue or data:GetDefaultValue())

    return data
end
Interfaces.Apply(_Setting, "I_Describable")
Interfaces.Apply(_Setting, "I_Identifiable")

---@return any
function _Setting:GetDefaultValue()
    return self.DefaultValue
end

---Returns whether this setting's intended context matches the current environment.
---@return boolean
function _Setting:IsInValidContext()
    local isValid

    if Ext.IsClient() then
        isValid = self.Context == "Client" or (self.Context == "Host" and Client.IsHost())
    else
        isValid = self.Context == "Server"
    end

    return isValid
end

---Serializes the setting's current value to be saved.
---@return any
function _Setting:SerializeValue()
    return self:GetValue()
end

---Deserializes a saved value for this setting type.
---@param value any
---@return any
function _Setting.DeserializeValue(value)
    return value
end

function _Setting:GetValue() return self.Value end
function _Setting:SetValue(value) self.Value = value end
function _Setting:_Init() end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class SettingsLib_Event_SettingValueChanged
---@field Setting SettingsLib_Setting
---@field Value any

---@class SettingsLib_Hook_GetSettingValue
---@field Setting SettingsLib_Setting
---@field Value any Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets a setting's value and fires corresponding events.
---@param moduleID string
---@param settingID string
---@param value any
---@param notify boolean? Defaults to `true`.
---@param deserialize boolean? Defaults to `false`.
function Settings.SetValue(moduleID, settingID, value, notify, deserialize)
    local setting = Settings.GetSetting(moduleID, settingID)
    if notify == nil then notify = true end

    if not setting then
        if GameState.IsInSession() and not Settings._unregisteredSettingWarningShown then
            Settings:LogWarning("Tried to set value of an unregistered setting: " .. moduleID .. " " .. settingID .. ". The value will be stored until the setting is registered (this warning is only shown once per session).")

            Settings._unregisteredSettingWarningShown = true
        end
        if not Settings.unregisteredSettingValues[moduleID] then
            Settings.unregisteredSettingValues[moduleID] = {}
        end

        Settings.unregisteredSettingValues[moduleID][settingID] = {Value = value, Deserialize = deserialize}
    else
        if deserialize then
            value = setting.DeserializeValue(value)
        end

        setting:SetValue(value)

        if notify then
            Settings.Events.SettingValueChanged:Throw({
                Setting = setting,
                Value = value,
            })
        end
    end
end

---@param moduleID string
---@param settingID string
---@param value any
function Settings._SetValueFromSave(moduleID, settingID, value)
    Settings.SetValue(moduleID, settingID, value, nil, true)
end

---Returns a table of setting IDs and their current values.
---@param modTable string
---@param includeInvalidContexts boolean? If true, settings with a mismatched context will be included, if any are registered. Defaults to false.
---@return table<string, any> -- Maps setting ID to value.
function Settings.GetModuleSettingValues(modTable, includeInvalidContexts)
    local module = Settings.GetModule(modTable)
    local output = {}

    for id,setting in pairs(module.Settings) do
        if includeInvalidContexts or setting:IsInValidContext() then
            output[id] = setting:SerializeValue()
        end
    end

    return output
end

---@param modTable string
---@return SettingsLib_Module
function Settings.GetModule(modTable)
    local mod = Settings.Modules[modTable]

    -- Initialize module
    if not mod then
        mod = {
            ModTable = modTable,
            Settings = {},
        }

        Settings.Modules[modTable] = mod
    end

    return mod
end

---@param modTable string
---@param id string
---@return SettingsLib_Setting
function Settings.GetSetting(modTable, id)
    local mod = Settings.GetModule(modTable)
    local setting

    if mod then
        setting = mod.Settings[id]
    else
        Settings:LogError("GetSetting(): setting doesn't exist: " .. id)
    end

    return setting
end

---@overload fun(setting:SettingsLib_Setting):any
---@param modTable string
---@param id string
---@return any
function Settings.GetSettingValue(modTable, id)
    local value = nil
    local setting = modTable -- Setting overload.
    if type(modTable) ~= "table" then
        setting = Settings.GetSetting(modTable, id)
    end

    if setting then
        value = setting:GetValue()

        value = Settings.Hooks.GetSettingValue:Throw({
            Setting = setting,
            Value = value
        }).Value
    elseif Settings.unregisteredSettingValues[modTable] then
        local settingPendingData = Settings.unregisteredSettingValues[modTable][id]

        if settingPendingData then
            value = settingPendingData.Value -- TODO error if value has not been deserialized yet
        end
    else
        error("Setting not found: " .. id)
    end

    return value
end

function Settings.RegisterSettingType(settingType, baseTable)
    Settings.SettingTypes[settingType] = baseTable
end

---Registers a setting.
---Any additional data on the table is preserved.
---@param data SettingsLib_Setting
function Settings.RegisterSetting(data)
    local settingTable = Settings.SettingTypes[data.Type] ---@type SettingsLib_Setting
    local setting = settingTable:Create(data)

    if not data.ID or not data.ModTable then
        Settings:LogError("Settings must declare ID and ModTable")
        return nil
    end

    -- Default to client context
    data.Context = data.Context or "Client"

    -- Pre-load saved client setting values.
    -- For server, we must wait for PersistentVars to be available.
    if not Settings.Modules[data.ModTable] and Ext.IsClient() then
        Settings.Load(data.ModTable)
    end

    local mod = Settings.GetModule(data.ModTable)

    mod.Settings[data.ID] = setting

    -- Initialize saved value
    local unregisteredSettingValues = Settings.unregisteredSettingValues[data.ModTable]
    if unregisteredSettingValues and unregisteredSettingValues[data.ID] ~= nil then
        Settings.SetValue(data.ModTable, data.ID, unregisteredSettingValues[data.ID].Value, nil, unregisteredSettingValues[data.ID].Deserialize)
    end
end

---Returns a table of all the registered modules.
---@return table<string, SettingsLib_Module>
function Settings.GetModules()
    local modules = {}

    for id,module in pairs(Settings.Modules) do
        modules[id] = module
    end

    return modules
end