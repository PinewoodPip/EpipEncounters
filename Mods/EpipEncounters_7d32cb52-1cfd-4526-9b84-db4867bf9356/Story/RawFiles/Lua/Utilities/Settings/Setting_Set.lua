
local Settings = Settings
local SetDataStructure = DataStructures.Get("DataStructures_Set")

---@class SettingsLib_Setting_Set : SettingsLib_Setting
---@field Value DataStructures_Set
local _Set = {
    Type = "Set",
}
Inherit(_Set, Settings._SettingClass)
Settings.RegisterSettingType("Set", _Set)

function _Set:GetDefaultValue()
    return SetDataStructure.Create()
end

function _Set:SetValue(elements)
    self.Value = SetDataStructure.Create(elements)
end