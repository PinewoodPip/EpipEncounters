
local Settings = Settings

---A setting that only permits values from a defined list.
---@class SettingsLib_Setting_Choice : SettingsLib_Setting
---@field Enabled boolean
local _Choice = {
    Type = "Choice",
    Choices = {}, ---@type SettingsLib_Setting_Choice_Entry[]
    DefaultValue = "",
}
Settings:RegisterClass("SettingsLib_Setting_Choice", _Choice, {"SettingsLib_Setting"})
Settings.RegisterSettingType("Choice", _Choice)

---@class SettingsLib_Setting_Choice_Entry
---@field Name string?
---@field NameHandle TranslatedStringHandle?
---@field ID any? Defaults to stringified index of the choice.
local _Entry = {}

---@param data SettingsLib_Setting_Choice_Entry
function _Entry.Create(data)
    Inherit(data, _Entry)
end

---@return string?
function _Entry:GetName()
    return Ext.L10N.GetTranslatedString(self.NameHandle or "", self.Name or "")
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
        local choice = self.Choices[value]

        if choice then
            value = choice.ID
        else
            error("SetValue(): Invalid choice index " .. (tostring(value) or "nil"))
        end
    end

    self.Value = value
end

---@param choiceID string
---@return integer?
function _Choice:GetChoiceIndex(choiceID)
    local index

    for i,choice in ipairs(self.Choices) do
        if choice.ID == choiceID then
            index = i
            break
        end
    end

    return index
end