
local Settings = Settings

---@class SettingsLib_Setting_String : SettingsLib_Setting
---@field Value string
local _String = {
    Type = "String",
    DefaultValue = "",
}
Inherit(_String, Settings._SettingClass)
Settings.RegisterSettingType("String", _String)

---------------------------------------------
-- METHODS
---------------------------------------------

function _String:SetValue(value)
    self.Value = tostring(value)
end