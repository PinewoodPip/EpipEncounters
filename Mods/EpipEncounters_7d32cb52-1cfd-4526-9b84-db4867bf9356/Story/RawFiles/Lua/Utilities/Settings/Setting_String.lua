
local Settings = Settings

---@class SettingsLib_Setting_String : SettingsLib_Setting
---@field Value string
local _String = {
    Type = "String",
    DefaultValue = "",
}
Settings:RegisterClass("SettingsLib_Setting_String", _String, {"SettingsLib_Setting"})
Settings.RegisterSettingType("String", _String)

---------------------------------------------
-- METHODS
---------------------------------------------

function _String:SetValue(value)
    self.Value = tostring(value)
end