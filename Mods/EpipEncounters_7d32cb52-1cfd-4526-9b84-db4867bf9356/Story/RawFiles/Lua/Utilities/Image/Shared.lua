
---@class ImageLib : Library
local Image = {
    _Decoders = {}, ---@type table<string, ImageLib_Decoder>
}
Client.Image = Image
Epip.InitializeLibrary("Image", Image)
Image.LibDeflate = Ext.Require("Utilities/LibDeflate.lua") ---@type unknown TODO annotate

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias ImageLib_DecoderClassName "ImageLib_Decoder_PNG"|"ImageLib_Decoder"

---@alias ImageLib_ByteStream integer[]

---@class ImageLib_Image
---@field Pixels RGBColor[][] Pixel matrix. Indexing is row, column.
---@field Width integer
---@field Height integer
local _Image = {
    _PixelsAdded = 0,
}

---@param width integer
---@param height integer
---@return ImageLib_Image
function _Image.Create(width, height)
    ---@type ImageLib_Image
    local tbl = {
        Pixels = {},
        Width = width,
        Height = height
    }
    Inherit(tbl, _Image)

    -- Create rows
    for i=1,height,1 do
        tbl.Pixels[i] = {}
    end

    return tbl
end

---@param color RGBColor
function _Image:AddPixel(color)
    if self._PixelsAdded >= self.Width * self.Height then
        Image:Error("Image:AddPixel", "All pixels have already been added.")
    end

    local row = (self._PixelsAdded // self.Width) + 1
    local column = (self._PixelsAdded - (row - 1)*self.Width) + 1

    self.Pixels[row][column] = color

    self._PixelsAdded = self._PixelsAdded + 1
end

---Returns the color of a pixel.
---@param coords vec2 Row, column coordinates.
---@return RGBColor
function _Image:GetPixel(coords)
    return self.Pixels[coords[1]][coords[2]]
end

---Sets the color of a pixel.
---@param coords vec2 Row and column coordinates.
---@param color RGBColor
function _Image:SetPixel(coords, color)
    self.Pixels[coords[1]][coords[2]] = color
end

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

---@param width integer
---@param height integer
---@return ImageLib_Image
function Image.CreateImage(width, height)
    return _Image.Create(width, height)
end

---------------------------------------------
-- TESTS
---------------------------------------------

local testFilename = "test_rgb.png"
function Image:__Test()
    local PNG = Image.GetDecoder("ImageLib_Decoder_PNG")
    local pngDecoder = PNG:Create(testFilename)
    pngDecoder:Decode()
end