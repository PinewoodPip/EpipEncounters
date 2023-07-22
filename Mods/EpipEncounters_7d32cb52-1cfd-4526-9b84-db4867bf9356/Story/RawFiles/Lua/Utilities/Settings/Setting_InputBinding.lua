
local Settings = Settings

---A setting that accepts multiple keybindings.
---@class SettingsLib.Settings.InputBinding : SettingsLib_Setting
---@field TargetActionID string?
---@field Value InputLib_Action_KeyCombination[]
local _InputBinding = {
    Type = "InputBinding",
}
Settings:RegisterClass("SettingsLib.Settings.InputBinding", _InputBinding, {"SettingsLib_Setting"})
Settings.RegisterSettingType("InputBinding", _InputBinding)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias SettingsLib_SettingType "InputBinding"