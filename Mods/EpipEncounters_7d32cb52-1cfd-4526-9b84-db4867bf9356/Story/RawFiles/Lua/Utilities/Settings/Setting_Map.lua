
local Settings = Settings

---@class SettingsLib_Setting_Map : SettingsLib_Setting
---@field Value table
local _Map = {
    Type = "Map",
    DefaultValue = {},
}
Settings:RegisterClass("SettingsLib_Setting_Map", _Map, {"SettingsLib_Setting"})
Settings.RegisterSettingType("Map", _Map)

function _Map:GetDefaultValue()
    return {}
end

function _Map:SetKeyValue(key, value)
    self.Value[key] = value
end