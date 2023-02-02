
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
    local iggy = mc.iggy_mc

    -- Incredible fucking life hack for culling issues:
    -- set MC to be 1x1, set icon to be 1x1, scale MC to desired size
    iggy.width = width
    iggy.height = height
    mc.SetIconSize(width, height)
    ui:SetCustomIcon(self.ID, icon, 1, 1, materialGUID)
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("IggyIcon", IggyIcon)