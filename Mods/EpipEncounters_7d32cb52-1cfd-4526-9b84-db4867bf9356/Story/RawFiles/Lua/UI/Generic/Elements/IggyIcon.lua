
local Generic = Client.UI.Generic

---@class GenericUI_Element_IggyIcon : GenericUI_Element
---@field SetIcon fun(self, icon:string, width:number, height:number)
Client.UI.Generic.ELEMENTS.IggyIcon = {
    Events = {},
}
local IggyIcon = Client.UI.Generic.ELEMENTS.IggyIcon ---@class GenericUI_Element_IggyIcon
Generic.Inherit(IggyIcon, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

function IggyIcon:SetIcon(icon, width, height)
    local mc = self:GetMovieClip()
    local ui = self.UI:GetUI()

    mc.SetIconSize(width, height)
    ui:SetCustomIcon(self.ID, icon, width, height)
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("IggyIcon", IggyIcon)