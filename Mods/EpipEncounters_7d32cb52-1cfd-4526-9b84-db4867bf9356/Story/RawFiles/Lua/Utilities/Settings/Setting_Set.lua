
local Settings = Settings
local SetDataStructure = DataStructures.Get("DataStructures_Set")

---@class SettingsLib_Setting_Set : SettingsLib_Setting
---@field Value DataStructures_Set
local _Set = {
    Type = "Set",
}
Settings:RegisterClass("SettingsLib_Setting_Set", _Set, {"SettingsLib_Setting"})
Settings.RegisterSettingType("Set", _Set)

function _Set:GetDefaultValue()
    return SetDataStructure.Create()
end

---@param elements any[]|DataStructures_Set
function _Set:SetValue(elements)
    if OOP.IsClass(elements) and elements:GetClassName() == "DataStructures_Set" then
        self.Value = elements
    else
        self.Value = SetDataStructure.Create(elements)
    end
end

---@return any[]
function _Set:SerializeValue()
    local tbl = {} -- Sets are serialized to a list.

    for element in self:GetValue():Iterator() do
        table.insert(tbl, element)
    end

    return tbl
end