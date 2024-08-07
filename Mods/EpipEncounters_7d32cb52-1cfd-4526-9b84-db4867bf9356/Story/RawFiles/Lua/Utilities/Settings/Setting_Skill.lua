
---------------------------------------------
-- String-type setting intended to hold skill IDs.
---------------------------------------------

local Settings = Settings

---@class SettingsLib.Setting.Skill : SettingsLib_Setting_String
---@field Value skill|StatsLib_Action_ID|""
local SkillSetting = {
    Type = "String",
    DefaultValue = "",
}
Settings:RegisterClass("SettingsLib.Setting.Skill", SkillSetting, {"SettingsLib_Setting_String"})
Settings.RegisterSettingType("Skill", SkillSetting)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias SettingsLib_SettingType "Skill"

---------------------------------------------
-- METHODS
---------------------------------------------

function SkillSetting:SetValue(value)
    self.Value = tostring(value)
end
