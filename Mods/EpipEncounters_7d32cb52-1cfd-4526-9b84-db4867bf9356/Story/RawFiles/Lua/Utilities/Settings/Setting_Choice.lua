
local Settings = Settings

---A setting that only permits values from a defined list.
---@class SettingsLib_Setting_Choice : SettingsLib_Setting
---@field Enabled boolean
local _Choice = {
    Type = "Choice",
    Choices = {}, ---@type SettingsLib_Setting_Choice_Entry[]
    DefaultValue = "",
}
Inherit(_Choice, Settings._SettingClass)
Settings.RegisterSettingType("Choice", _Choice)

---@class SettingsLib_Setting_Choice_Entry
---@field Name string?
---@field NameHandle TranslatedStringHandle?
---@field ID string? Defaults to stringified index of the choice.
local _Entry = {}

---@param data SettingsLib_Setting_Choice_Entry
function _Entry.Create(data)
    Inherit(data, _Entry)
end

---@return string?
function _Entry:GetName()
    return Ext.L10N.GetTranslatedString(self.NameHandle, self.Name)
end

---------------------------------------------
-- METHODS
---------------------------------------------

function _Choice:_Init()
    for i,choice in ipairs(self.Choices) do
        _Entry.Create(choice)

        -- Default to numbered IDs for choices.
        if not choice.ID then
            choice.ID = tostring(i)
        end
    end
    -- Default to first choice if unspecified
    if self.DefaultValue == "" then
        self.DefaultValue = self.Choices[1].ID
    end
end

---@param value integer|string Index or string ID.
function _Choice:SetValue(value)
    if type(value) ~= "string" then
        value = self.Choices[value].ID
    end

    self.Value = value
end