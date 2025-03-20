---------------------------------------------
-- Decoder for DirectX BC1 .dds files.
---------------------------------------------
local Image = Image

---@class ImageLib.Decoders.DDS : ImageLib_Decoder
local DDS = {
    Width = nil, ---@type integer
    Height = nil, ---@type integer
}
Inherit(DDS, Image.GetDecoder("ImageLib_Decoder"))
Image.RegisterDecoder("ImageLib.Decoders.DDS", DDS)

---@alias ImageLib_DecoderClassName "ImageLib.Decoders.DDS"

---@override
---@param str string? -- TODO adjust base class interface to allow passing a buffer str directly as well
function DDS:Decode(str)
    if str == nil then
        str = IO.LoadFile(self.FileName, "user", true)
    end
    self.Bytes = {string.byte(str, 1, #str)}
    self.Index = 1
    local header = self:ReadHeader()
    self.Height = (header[16] << 24) | (header[15] << 16) | (header[14] << 8) | header[13]
    self.Width = (header[20] << 24) | (header[19] << 16) | (header[18] << 8) | header[17]
    local useAlt = false

    local img = Image.CreateImage(self.Width, self.Height)

    -- Read blocks
    for i=1,img.Height,4 do
        for j=1,img.Width,4 do
            local minColorBits = self:ConsumeBytes(2)
            local maxColorBits = self:ConsumeBytes(2)

            -- Calculate min color
            local minR = minColorBits[2] >> 3
            local minG = ((minColorBits[2] & 7) << 3) | (minColorBits[1] >> 5)
            local minB = minColorBits[1] & 31
            local minColor = Color.Create(
                minR / 31 * 255,
                minG / 63 * 255,
                minB / 31 * 255
            )

            -- Calculate max color
            local maxR = maxColorBits[2] >> 3
            local maxG = ((maxColorBits[2] & 7) << 3) | (maxColorBits[1] >> 5)
            local maxB = maxColorBits[1] & 31
            local maxColor = Color.Create(
                maxR / 31 * 255,
                maxG / 63 * 255,
                maxB / 31 * 255
            )

            -- Calculate middle color
            local colorMiddle = Color.Create(math.floor(1/2 * minColor.Red + 1/2 * maxColor.Red), math.floor(1/2 * minColor.Green + 1/2 * maxColor.Green), math.floor(1/2 * minColor.Blue + 1/2 * maxColor.Blue))

            -- Color map for textures with transparency (which we ignore, lol)
            local colorMap = {
                minColor,
                maxColor,
                colorMiddle,
            }
            -- 4-color map for textures with no transparency
            local altColorMap = {
                minColor,
                maxColor,
                Color.Create(math.floor(2/3 * minColor.Red + 1/3 * maxColor.Red), math.floor(2/3 * minColor.Green + 1/3  * maxColor.Green), math.floor(2/3 * minColor.Blue + 1/3  * maxColor.Blue)),
                Color.Create(math.floor(1/3  * minColor.Red + 2/3 * maxColor.Red), math.floor(1/3  * minColor.Green + 2/3 * maxColor.Green), math.floor(1/3  * minColor.Blue + 2/3 * maxColor.Blue))
            }

            -- Read color indices
            -- From bottom-left to top-right
            local blocks = self:ConsumeBytes(4)
            for z2=4,1,-1 do
                local row4 = blocks[z2]
                for z=1,4,1 do
                    local index = (row4 >> ((6 - (z - 1) * 2))) & 3
                    if index == 3 then
                        -- TODO this is a lazy solution; pixels parsed before this will be wrong! Check the data "sex" instead to determine if transparency is used
                        useAlt = true
                    end
                    local map = useAlt and altColorMap or colorMap
                    local color = map[index + 1]
                    img:SetPixel({i + z2 - 1, j + 4 - z}, color)
                end
            end
        end
    end
    self.Image = img
    return self.Image
end

---Reads the header from the file.
---@return integer[]
function DDS:ReadHeader()
    local header = self:ConsumeBytes(128)
    return header
end
