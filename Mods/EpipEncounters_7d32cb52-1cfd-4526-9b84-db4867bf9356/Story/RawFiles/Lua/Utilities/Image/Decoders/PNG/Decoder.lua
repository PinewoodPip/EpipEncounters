
local Image = Client.Image

---@class ImageLib_Decoder_PNG_ChunkDescriptor
---@field Hex string Spaced.
---@field Essential true?
---@field Name string

---@class ImageLib_Decoder_PNG_ChunkParser
---@field ReadChunk fun(self:ImageLib_Decoder_PNG, byteCount:integer)

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
    _ChunkParsers = {}, ---@type table<string, ImageLib_Decoder_PNG_ChunkParser>
    _Finished = false,
}
for k,v in pairs(_PNG.CHUNKS) do v.Name = k end
Inherit(_PNG, Image.GetDecoder("ImageLib_Decoder"))
Image.RegisterDecoder("ImageLib_Decoder_PNG", _PNG)

---@param chunkHex string
---@param parserClass ImageLib_Decoder_PNG_ChunkParser
function _PNG.RegisterChunkParser(chunkHex, parserClass)
    _PNG._ChunkParsers[chunkHex] = parserClass
end

---@param chunkHex string
---@return ImageLib_Decoder_PNG_ChunkParser
function _PNG.GetChunkParser(chunkHex)
    return _PNG._ChunkParsers[chunkHex]
end

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
    while self.Index <= #self.Bytes and not self._Finished do
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
    local parser = _PNG.GetChunkParser(chunkType)
    if parser then
        parser.ReadChunk(self, chunkSize)
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