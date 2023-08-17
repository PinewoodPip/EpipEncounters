
---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI_Element_Texture : GenericUI_Element
local Texture = {
    Events = {}, ---@type GenericUI_Element_Events
}
Generic.Inherit(Texture, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets the texture resource used.
---@param texture GUID|TextureLib_Texture
---@param size Vector2? Defaults to native size of the texture resource.
function Texture:SetTexture(texture, size)
    if type(texture) == "table" then -- TextureLib_Texture overload.
        texture = texture.GUID ---@cast texture string
    end
    local w, h = -1, -1
    if size then
        w, h = size:unpack()
    end
    self:GetMovieClip().SetTexture(texture, w, h)
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Texture", Texture)