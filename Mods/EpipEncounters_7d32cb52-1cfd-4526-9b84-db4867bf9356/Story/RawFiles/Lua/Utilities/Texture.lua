
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
---@field Name string Resource name.
---@field GUID GUID

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a texture resource.
---@param name string
---@param data TextureLib_Texture `Name` is auto-initialized.
---@return TextureLib_Texture
function Texture.RegisterTexture(name, data)
    Texture._Textures[name] = data
    data.Name = name

    return data
end

---Returns a texture by name.
---@param name string
---@return TextureLib_Texture
function Texture.GetTexture(name)
    return Texture._Textures[name]
end