
local Settings = Settings

---@class SettingsLib_Setting_Number : SettingsLib_Setting
---@field Value number
local _Number = {
    Type = "Number",
    DefaultValue = 0,
}
Inherit(_Number, Settings._SettingClass)
Settings.RegisterSettingType("Number", _Number)