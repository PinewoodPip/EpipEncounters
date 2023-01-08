
local Generic = Client.UI.Generic

---@class GenericUI_Element_IggyIcon : GenericUI_Element
---@field SetIcon fun(self, icon:string, width:number, height:number, materialGUID:GUID?)
local IggyIcon = {
    
}
Generic.Inherit(IggyIcon, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets the icon displayed by the element.
---@param icon string
---@param width number
---@param height number
---@param materialGUID GUID?
function IggyIcon:SetIcon(icon, width, height, materialGUID)
    local mc = self:GetMovieClip()
    local ui = self.UI:GetUI()

    mc.SetIconSize(width, height)
    ui:SetCustomIcon(self.ID, icon, width, height, materialGUID)
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("IggyIcon", IggyIcon)