
local Settings = Settings

---@class SettingsLib_Setting_Boolean : SettingsLib_Setting
---@field Enabled boolean
local _BooleanSetting = {
    Type = "Boolean",
    DefaultValue = false,
}
Settings:RegisterClass("SettingsLib_Setting_Boolean", _BooleanSetting, {"SettingsLib_Setting"})
Settings.RegisterSettingType("Boolean", _BooleanSetting)