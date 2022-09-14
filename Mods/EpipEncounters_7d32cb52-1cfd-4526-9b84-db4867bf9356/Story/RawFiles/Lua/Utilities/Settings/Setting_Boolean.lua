
local Settings = Settings

---@class SettingsLib_Setting_Boolean : SettingsLib_Setting
---@field Enabled boolean
local _BooleanSetting = {
    Type = "Boolean",
    DefaultValue = false,
}
Inherit(_BooleanSetting, Settings._SettingClass)
Settings.RegisterSettingType("Boolean", _BooleanSetting)