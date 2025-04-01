
---@class ImageLib : Library
local Image = {
    _Decoders = {}, ---@type table<string, ImageLib_Decoder>
}
_G.Image = Image
Epip.InitializeLibrary("Image", Image)
Image.LibDeflate = Ext.Require("Utilities/LibDeflate.lua") ---@type unknown TODO annotate

if Ext.IsClient() then
    Client.Image = Image -- Legacy alias.
end

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

---Returns a copy of the image.
---@return ImageLib_Image
function _Image:Copy()
    local newImg = Image.CreateImage(self.Width, self.Height)
    for i=1,self.Height,1 do
        for j=1,self.Width,1 do
            local pixel = self.Pixels[i][j]
            newImg:AddPixel(pixel)
        end
    end
    return newImg
end

---Returns the image data as a comma-separated string, starting with width and height.
---@return string
function _Image:ToRawData()
    local fields = {self.Width, self.Height}
    for i=1,self.Height,1 do
        for j=1,self.Width,1 do
            local pixel = self.Pixels[i][j]
            local r, g, b = pixel:Unpack()
            table.insert(fields, r)
            table.insert(fields, g)
            table.insert(fields, b)
        end
    end
    return Text.Join(fields, ",")
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

---@class ImageLib.Image.RawData
---@field Width integer
---@field Height integer
---@field Pixels {Red:integer, Green:integer, Blue:integer}[]

---Creates an image out of a stream of RGB values (in ASCII, comma-separated), prefixed with image width and height (also comma-separated).
---@param data string
function Image.CreateFromRawData(data)
    data = Text.Split(data, ",")
    local width, height = data[1], data[2]
    local img = Image.CreateImage(tonumber(width), tonumber(height))
    for i=3,#data,3 do -- Start after width & height fields.
        local r, g, b = data[i], data[i + 1], data[i + 2]
        r, g, b = tonumber(r), tonumber(g), tonumber(b)
        img:AddPixel(Color.Create(r, g, b))
    end
    return img
end

---Converts an image to a BCT1 DDS stream.
---@param img ImageLib_Image
---@return string
function Image.ToDDS(img)
    local bct1 = Image.ToBCT1Stream(img)
    local width, height = img.Width, img.Height
    local widthBytes = {
        width & 0xFF,
        (width >> 8) & 0xFF,
        (width >> 16) & 0xFF,
        (width >> 24) & 0xFF,
    }
    local heightBytes = {
        height & 0xFF,
        (height >> 8) & 0xFF,
        (height >> 16) & 0xFF,
        (height >> 24) & 0xFF,
    }
    if width >= 2^31 - 1 or height >= 2^31 - 1 then
        Image:__Error("ToDDS", "Image too large; width and height must be int32")
    end
    -- TODO calculate pitch; currently hardcoded for 80x100 textures
    local header = string.char(0x44, 0x44, 0x53, 0x20, 0x7c, 0x00, 0x00, 0x00, 0x07, 0x10, 0x0a, 0x00, heightBytes[1], heightBytes[2], heightBytes[3], heightBytes[4], widthBytes[1], widthBytes[2], widthBytes[3], widthBytes[4], 0xa0, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x44, 0x58, 0x54, 0x31, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
    return header .. bct1
end

---Converts an image to a DirectX BCT1 block-compressed stream (very lossy).
---@param img ImageLib_Image Dimensions must be multiple of 4.
---@return string -- Raw data with no width/height encoded.
function Image.ToBCT1Stream(img)
    local blocks = {}
    if img.Width % 4 ~= 0 or img.Height % 4 ~= 0 then
        Image:__Error("ToBCT1Stream", "Image dimensions must be a multiple of 4")
    end

    -- Encode blocks
    for i=1,img.Height,4 do
        for j=1,img.Width,4 do
            -- Determine min & max colors of the block
            local maxColor = {0, 0, 0}
            local minColor = {255, 255, 255}
            local minScore = 255
            local maxScore = 0
            for i2=0,3,1 do
                for j2=0,3,1 do
                    local otherColor = img.Pixels[i + i2][j + j2]
                    local otherColorSum = otherColor.Red + otherColor.Green + otherColor.Blue
                    local pixelScore = otherColorSum / 3
                    if pixelScore <= minScore then
                        minColor = otherColor
                        minScore = pixelScore
                    end
                    if pixelScore >= maxScore then
                        maxColor = otherColor
                        maxScore = pixelScore
                    end
                end
            end

            local minR, minG, minB = minColor:Unpack()
            local maxR, maxG, maxB = maxColor:Unpack()
            local colorMiddle = Color.Create(math.floor(1/2 * minR + 1/2 * maxR), math.floor(1/2 * minG + 1/2 * maxG), math.floor(1/2 * minB + 1/2 * maxB))

            -- TODO support no-transparency mode; the color blending is different in that case
            -- local color2 = Color.Create(math.floor(2/3 * minR + 1/3 * maxR), math.floor(2/3 * minG + 1/3 * maxG), math.floor(2/3 * minB + 1/3 * maxB))
            -- local color3 = Color.Create(math.floor(1/3 * minR + 2/3 * maxR), math.floor(1/3 * minG + 2/3 * maxG), math.floor(1/3 * minB + 2/3 * maxB))

            ---Converts a color to BCT1 16-bit space (5-6-5 bits for RGB respectively)
            ---@param color RGBColor
            ---@return integer
            local function toBits(color)
                local minRed = math.floor(color.Red / 255 * (2^5 - 1))
                local minGreen = math.floor(color.Green / 255 * (2^6 - 1))
                local minBlue = math.floor(color.Blue / 255 * (2^5 - 1))
                -- local minColorBits = (minBlue << 10) | (minRed << 6) | minGreen -- Was 11, 5, as per the Microsoft documentation, but that appears to be wrong
                local minColorBits = (minRed << 11) | (minGreen << 5) | minBlue
                return minColorBits
            end

            -- Convert colors to 5-6-5 bit space
            local minColorBits = toBits(minColor)
            local maxColorBits = toBits(maxColor)

            local function ColorDistance(c1, c2)
                local r1, g1, b1 = c1:Unpack()
                local r2, g2, b2 = c2:Unpack()
                return math.abs(r1 - r2) + math.abs(g1 - g2) + math.abs(b1 - b2) -- TODO different metric?
            end

            local block = {
                string.char(minColorBits & 0xFF),
                string.char(minColorBits >> 8),
                string.char(maxColorBits & 0xFF),
                string.char(maxColorBits >> 8),
            }

            -- Determine color indexes for the pixels of the block
            local colors = {
                minColor,
                maxColor,
                colorMiddle,
                -- Transparent - TODO support?

                -- TODO support the non-transparency mode; in this case the color mapping is:
                -- minColor,
                -- color2,
                -- color3,
                -- maxColor
            }
            local pixelColorIndexes = 0
            local places= 0
            for i2=0,3,1 do
                for j2=0,3,1 do
                    local pixel = img.Pixels[i + i2][j + j2]
                    local colorIndex = nil
                    local bestDist = nil
                    for index,color in ipairs(colors) do
                        local dist = ColorDistance(pixel, color)
                        if bestDist == nil or dist < bestDist then
                            colorIndex = index - 1 -- Convert to 0-based index.
                            bestDist = dist
                        end
                    end

                    -- 1: max color, 0: min color, 2: linear blend, 3: transparent for all image - color 3 is always reserved for pure transparency, min/max color doesn't matter
                    pixelColorIndexes = pixelColorIndexes | (colorIndex << (((3- i2) * 4 + j2) * 2))

                    places = places + 1
                end
            end

            table.insert(block, string.char(pixelColorIndexes >> 24))
            table.insert(block, string.char((pixelColorIndexes >> 16) & 0xFF))
            table.insert(block, string.char((pixelColorIndexes >> 8) & 0xFF))
            table.insert(block, string.char((pixelColorIndexes) & 0xFF))

            local blockData = Text.Join(block, "")
            table.insert(blocks, blockData)
        end
    end
    return Text.Join(blocks, "")
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
