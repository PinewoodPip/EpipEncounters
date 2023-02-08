
local Generic = Client.UI.Generic

---@class GenericUI_Element_Texture : GenericUI_Element
local Texture = {
    Events = {},
}
Generic.Inherit(Texture, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets the texture resource used.
---@param guid GUID
---@param size Vector2? Defaults to native size of the texture resource.
function Texture:SetTexture(guid, size)
    local w, h = -1, -1
    if size then
        w, h = size:unpack()
    end
    self:GetMovieClip().SetTexture(guid, w, h)
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Texture", Texture)