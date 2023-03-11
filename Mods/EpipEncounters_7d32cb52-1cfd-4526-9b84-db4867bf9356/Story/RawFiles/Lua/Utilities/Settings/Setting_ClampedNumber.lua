
local Settings = Settings

---A numeric setting that only accepts values within an inclusive range.
---Default value is the minimum one.
---@class SettingsLib_Setting_ClampedNumber : SettingsLib_Setting_Number
---@field Min number
---@field Max number
local _ClampedNumber = {
    Type = "ClampedNumber",
}
Settings:RegisterClass("SettingsLib_Setting_ClampedNumber", _ClampedNumber, {"SettingsLib_Setting"})
Settings.RegisterSettingType("ClampedNumber", _ClampedNumber)

---------------------------------------------
-- METHODS
---------------------------------------------

---Override, clamps the value.
---@override
---@param value number
function _ClampedNumber:SetValue(value)
    self.Value = math.clamp(value, self.Min, self.Max)
end