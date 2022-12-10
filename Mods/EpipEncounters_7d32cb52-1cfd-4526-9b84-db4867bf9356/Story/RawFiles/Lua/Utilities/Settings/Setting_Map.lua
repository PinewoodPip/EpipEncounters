
local Settings = Settings

---@class SettingsLib_Setting_Map : SettingsLib_Setting
---@field Value table
local _Map = {
    Type = "Map",
    DefaultValue = {},
}
Inherit(_Map, Settings._SettingClass)
Settings.RegisterSettingType("Map", _Map)

function _Map:GetDefaultValue()
    return {}
end

function _Map:SetKeyValue(key, value)
    self.Value[key] = value
end