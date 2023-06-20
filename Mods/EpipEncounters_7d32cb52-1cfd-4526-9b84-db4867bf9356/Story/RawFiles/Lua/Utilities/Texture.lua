
---@class TextureLib : Library
Texture = {
    ---@type table<string, TextureLib_Texture>
    _Textures = {},
}
Epip.InitializeLibrary("Texture", Texture)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class TextureLib_Texture
---@field GUID GUID

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a texture resource.
---@param name string
---@param data TextureLib_Texture
---@return TextureLib_Texture
function Texture.RegisterTexture(name, data)
    Texture._Textures[name] = data

    return data
end

---Returns a texture by name.
---@param name string
---@return TextureLib_Texture
function Texture.GetTexture(name)
    return Texture._Textures[name]
end