
local Interfaces = Interfaces

---@class I_Describable : InterfaceLib_Interface
---@field NameHandle TranslatedStringHandle|TextLib_TranslatedString
---@field DescriptionHandle TranslatedStringHandle|TextLib_TranslatedString
---@field Name string Fallback if NameHandle isn't set.
---@field Description string Fallback if DescriptionHandle isn't set.
local _Describable = {

}
Interfaces.RegisterInterface("I_Describable", _Describable)

---@return string
function _Describable:GetName()
    local name = self.Name or "MISSING NAME"

    if self.NameHandle then
        name = Text.GetTranslatedString(self.NameHandle, name)
    end

    return name
end

---@return string
function _Describable:GetDescription()
    local desc = self.Description or "MISSING DESCRIPTION"

    if self.DescriptionHandle then
        desc = Text.GetTranslatedString(self.DescriptionHandle, desc)
    end

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