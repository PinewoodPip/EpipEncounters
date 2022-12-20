
local Image = Client.Image

---@class ImageLib_Decoder_PNG_ChunkDescriptor
---@field Hex string Spaced.
---@field Essential true?
---@field Name string

---@class ImageLib_Decoder_PNG : ImageLib_Decoder
local _PNG = {
    ---@type table<string, ImageLib_Decoder_PNG_ChunkDescriptor>
    CHUNKS = {
        IHDR = {Hex = "49 48 44 52", Essential = true},
        IDAT = {Hex = "49 44 41 54", Essential = true},
        IEND = {Hex = "49 45 4E 44", Essential = true},
        iICC = {Hex = "69 43 43 50"}, -- https://en.wikipedia.org/wiki/ICC_profile
        pHYs = {Hex = "70 48 59 73"},
        tIME = {Hex = "74 49 4D 45"},
        tEXt = {Hex = "74 45 58 74"},
        zTXt = {Hex = "7A 54 58 74"},
        iTXt = {Hex = "69 54 58 74"},
    },
}
for k,v in pairs(_PNG.CHUNKS) do v.Name = k end
Inherit(_PNG, Image.GetDecoder("ImageLib_Decoder"))
Image.RegisterDecoder("ImageLib_Decoder_PNG", _PNG)

local function toHex(str)
    local valStr = string.format("%x", str)
    
    while string.len(valStr) < 2 do
        valStr = "0" .. valStr
    end

    return valStr:upper()
end

---@param chunkID string
---@return ImageLib_Decoder_PNG_ChunkDescriptor
function _PNG:GetChunkData(chunkID)
    local chunk = nil

    for _,v in pairs(self.CHUNKS) do
        if v.Hex == chunkID then
            chunk = v
            break
        end
    end

    return chunk
end

function _PNG:Decode()
    self.Index = 1

    self:ReadHeader()
    while self.Index <= #self.Bytes do
        self:ReadChunk()
    end

    Image:DebugLog("PNG.Decode()", "Decoder reached end")
end

function _PNG:ReadHeader()
    local header = self:ConsumeBytes(8)

    if header[2] ~= 0x50 or header[3] ~= 0x4E or header[4] ~= 0x47 then
        Image:Error("ReadHeader", "File header is not that of a PNG.")
    else
        Image:DebugLog("PNG file header OK.")
    end
end

function _PNG:ReadChunk()
    local chunkSize, chunkType
    local chunkSizeBytes = self:ConsumeBytes(4) -- Read chunk size
    chunkSize = self:BytesToNumber(chunkSizeBytes) 
    local chunkTypeStartIndex = self.Index
    chunkType = self:ToSpacedHex(self:ConsumeBytes(4)) -- Read chunk type

    Image:DebugLog("ReadChunk", "Next chunk size", self:ToSpacedHex(chunkSizeBytes))

    -- IHDR chunk, first one
    local width, height, bitDepth, colorType, compressionType, filterMethod, interlaceMethod
    if chunkType == self.CHUNKS.IHDR.Hex then -- IHDR chunk
        Image:DebugLog("Found IHDR chunk")

        width = self:ConsumeInteger(4)
        height = self:ConsumeInteger(4)
        bitDepth = self:ConsumeInteger(1)
        colorType = self:ConsumeInteger(1)
        compressionType = self:ConsumeInteger(1)
        filterMethod = self:ConsumeInteger(1)
        interlaceMethod = self:ConsumeInteger(1)

        self.Width = width
        self.Height = height
        self.BitDepth = bitDepth
        self.ColorType = colorType
        self.CompressionType = compressionType
        self.FilterMethod = filterMethod
        self.InterlaceMethod = interlaceMethod
        
        Image:DebugLog("IHDR chunk:")
        Image:Dump({
            Width = width,
            Height = height,
            BitDepth = bitDepth,
            ColorType = colorType, -- TODO implement the various color types, at least 2 (truecolor, rgb) and 6 (truecolor and alpha)
            CompressionType = compressionType,
            FilterMethod = filterMethod, -- TODO implement; alters the compression
            InterlaceMethod = interlaceMethod, -- TODO only allow 0 (no Adam7)
        })
    elseif chunkType == self.CHUNKS.IDAT.Hex then
        Image:DebugLog("ReadChunk", "Found IDAT chunk")
        -- local dataChunkByteCount = self:ConsumeInteger(4)
        local method = self:ConsumeInteger(1)
        local flag = self:ConsumeInteger(1)
        local bytes = self:ConsumeBytes(chunkSize - 1 - 1 - 4)
        local adler32 = self:ConsumeInteger(4)

        print("Method, flag, adler32")
        print(method, flag, adler32)

        local compressed = ""
        for _,byte in ipairs(bytes) do
            compressed = compressed .. string.char(byte)
        end
        local decompressed = Image.LibDeflate:DecompressDeflate(compressed)
        -- print(compressed, #compressed)
        -- print(decompressed, #decompressed)

        local bytesDecompressed = {}
        for i=1,#decompressed,1 do
            table.insert(bytesDecompressed, string.byte(decompressed:sub(i, i)))
        end

        self:PrintHex(bytesDecompressed, "Image data")
    elseif chunkType == self.CHUNKS.IEND.Hex then
        Image:DebugLog("ReadChunk", "Found IEND/eof chunk")
        self:ConsumeBytes(chunkSize)
    else
        local chunkData = self:GetChunkData(chunkType)

        if not chunkData then
            Image:Error("ReadChunk", "Unrecognized chunk", chunkType, "at index", toHex(chunkTypeStartIndex - 1))
        elseif not chunkData.Essential then
            Image:DebugLog("ReadChunk", "found ancillary chunk with no parsing implemented:", chunkData.Name)

            -- Consume its bytes
            self:ConsumeBytes(chunkSize)
        else
            Image:Error("ReadChunk", "Chunk parsing not implemented for non-optional chunk", chunkType)
        end
    end

    local crcBytes = self:ConsumeBytes(4) -- Read CRC data (TODO not currently checked)
end