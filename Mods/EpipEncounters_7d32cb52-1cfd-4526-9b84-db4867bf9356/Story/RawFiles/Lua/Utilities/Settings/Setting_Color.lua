
local Settings = Settings

---@class SettingsLib.Setting.Color : SettingsLib_Setting
---@field Value RGBColor
local _Color = {
    Type = "Color",
}
Settings:RegisterClass("SettingsLib.Setting.Color", _Color, {"SettingsLib_Setting"})
Settings.RegisterSettingType("Color", _Color)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias SettingsLib_SettingType "Color"

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
---@param value RGBColor
function _Color:SetValue(value)
    local mt =  getmetatable(value)
    ---@diagnostic disable-next-line: invisible
    if not mt or mt.__name ~= Color.RGBColor.__name then
        error("Value is not a color instance")
    end
    self.Value = value
end

---@override
function _Color:SerializeValue()
    local color = self.Value
    return {Red = color.Red, Green = color.Green, Blue = color.Blue}
end

---@override
function _Color.DeserializeValue(value)
    return Color.CreateFromRGB(value.Red, value.Green, value.Blue, value.Alpha)
end
