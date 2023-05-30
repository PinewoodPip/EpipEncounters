
local Generic = Client.UI.Generic

---@class GenericUI_Element_IggyIcon : GenericUI_Element
---@field SetIcon fun(self, icon:string, width:number, height:number, materialGUID:GUID?)
local IggyIcon = {
    _CurrentIcon = nil, ---@type GenericUI_Element_IggyIcon_Icon
}
Generic.Inherit(IggyIcon, Generic._Element)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class GenericUI_Element_IggyIcon_Icon
---@field Icon string
---@field Width integer
---@field Height integer

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets the icon displayed by the element.
---@param icon string
---@param width number
---@param height number
---@param materialGUID GUID?
function IggyIcon:SetIcon(icon, width, height, materialGUID)
    -- Iggy calls are expensive;
    -- they should only be called if there was a change in the setup
    if self:_IsIconDifferent(icon, width, height) then
        local mc = self:GetMovieClip()
        local ui = self.UI:GetUI()
        local iggy = mc.iggy_mc

        -- Incredible fucking life hack for culling issues:
        -- set MC to be 1x1, set icon to be 1x1, scale MC to desired size
        iggy.width = width
        iggy.height = height
        mc.SetIconSize(width, height)
        ui:SetCustomIcon(self.ID, icon, 1, 1, materialGUID)

        self._CurrentIcon = {Icon = icon, Width = width, Height = height}
    end
end

---Returns whether an icon setup is different from the one
---currently set on the element.
---@param icon string
---@param width integer
---@param height integer
---@return boolean
function IggyIcon:_IsIconDifferent(icon, width, height)
    local isDifferent = true

    if self._CurrentIcon then
        local currentIcon = self._CurrentIcon
        isDifferent = currentIcon.Icon ~= icon or currentIcon.Width ~= width or currentIcon.Height ~= height
    end

    return isDifferent
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("IggyIcon", IggyIcon)