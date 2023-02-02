
local Interfaces = Interfaces

---@class I_Describable : InterfaceLib_Interface
---@field NameHandle TranslatedStringHandle|TextLib_TranslatedString Deprecated, set Name instead.
---@field DescriptionHandle TranslatedStringHandle|TextLib_TranslatedString Deprecated, set Description instead.
---@field Name string|TranslatedStringHandle|TextLib_TranslatedString Fallback if NameHandle isn't set.
---@field Description string|TranslatedStringHandle|TextLib_TranslatedString Fallback if DescriptionHandle isn't set.
local _Describable = {

}
Interfaces.RegisterInterface("I_Describable", _Describable)

---@return string
function _Describable:GetName()
    local name = "MISSING NAME"

    if type(self.Name) == "table" then
        name = self.Name:GetString()
    else
        name = Text.GetTranslatedString(self.NameHandle or self.Name, self.Name or name)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return name
end

---@return string
function _Describable:GetDescription()
    local desc = "MISSING DESCRIPTION"

    if type(self.Description) == "table" then
        desc = self.Description:GetString()
    else
        desc = Text.GetTranslatedString(self.DescriptionHandle or self.Description, self.Description or desc)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return desc
end

---@return TooltipLib_FormattedTooltip
function _Describable:GetTooltip()
    ---@type TooltipLib_FormattedTooltip
    local tooltip = {
        Elements = {
            {
                Type = "ItemName",
                Label = self:GetName(),
            },
            {
                Type = "ItemDescription",
                Label = self:GetDescription(),
            },
        }
    }

    return tooltip
end