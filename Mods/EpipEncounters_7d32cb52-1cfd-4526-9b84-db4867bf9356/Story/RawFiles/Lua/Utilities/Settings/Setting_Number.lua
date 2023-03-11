
local Settings = Settings

---@class SettingsLib_Setting_Number : SettingsLib_Setting
---@field Value number
local _Number = {
    Type = "Number",
    DefaultValue = 0,
}
Settings:RegisterClass("SettingsLib_Setting_Number", _Number, {"SettingsLib_Setting"})
Settings.RegisterSettingType("Number", _Number)