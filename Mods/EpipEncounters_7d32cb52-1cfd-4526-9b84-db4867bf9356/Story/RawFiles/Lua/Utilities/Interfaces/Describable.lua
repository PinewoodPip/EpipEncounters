
local Interfaces = Interfaces

---@class I_Describable : InterfaceLib_Interface
---@field NameHandle TranslatedStringHandle
---@field DescriptionHandle TranslatedStringHandle
local _Describable = {

}
Interfaces.RegisterInterface("I_Describable", _Describable)

---@return string
function _Describable:GetName()
    local name = "MISSING NAME"

    if self.NameHandle then
        name = Ext.L10N.GetTranslatedString(self.NameHandle, name)
    end

    return name
end

---@return string
function _Describable:GetDescription()
    local desc = "MISSING DESCRIPTION"

    if self.DescriptionHandle then
        desc = Ext.L10N.GetTranslatedString(self.DescriptionHandle, desc)
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