
---@class ImageLib : Library
local Image = {
    _Decoders = {}, ---@type table<string, ImageLib_Decoder>
}
Client.Image = Image
Epip.InitializeLibrary("Image", Image)
Image.LibDeflate = Ext.Require("Utilities/LibDeflate.lua")
Image:Debug()

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias ImageLib_DecoderClassName "ImageLib_Decoder_PNG"|"ImageLib_Decoder"

---@alias ImageLib_ByteStream integer[]

---------------------------------------------
-- METHODS
---------------------------------------------

---@param className string
---@param decoderClass ImageLib_Decoder
function Image.RegisterDecoder(className, decoderClass)
    Image._Decoders[className] = decoderClass
end

---@generic T
---@param className `T`|ImageLib_DecoderClassName
---@return T
function Image.GetDecoder(className)
    return Image._Decoders[className]
end

---------------------------------------------
-- TESTS
---------------------------------------------

local testFilename = "test.png"
function Image:__Test()
    local PNG = Image.GetDecoder("ImageLib_Decoder_PNG")
    local pngDecoder = PNG:Create(testFilename)
    pngDecoder:Decode()
end