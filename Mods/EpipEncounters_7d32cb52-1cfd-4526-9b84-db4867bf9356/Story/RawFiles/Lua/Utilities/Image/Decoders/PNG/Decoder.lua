
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

    Width = nil, ---@type integer
    Height = nil, ---@type integer
    BitDepth = nil, ---@type integer
    ColorType = nil, ---@type integer -- TODO implement the various color types, at least 2 (truecolor, rgb) and 6 (truecolor and alpha)
    CompressionType = nil, ---@type integer
    FilterMethod = nil, ---@type integer
    InterlaceMethod = nil, ---@type integer -- TODO only allow 0 (no Adam7)
    CompressedData = nil, ---@type string
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

---@param data string
function _PNG:ConcatenateCompressedData(data)
    if not self.CompressedData then
        self.CompressedData = ""
    end

    self.CompressedData = self.CompressedData .. data
end

function _PNG:DecompressData()
    if not self.CompressedData then
        Image:Error("PNG.DecompressData", "No compressed data added")
    end

    local data = self.CompressedData
    data = data:sub(3) -- Remove method, flag bytes
    data = data:sub(1, #data-4) -- Remove adler32

    local decompressed, unprocessed = Image.LibDeflate:DecompressDeflate(data)

    local bytesDecompressed = {}
    for i=1,#decompressed,1 do
        table.insert(bytesDecompressed, string.byte(decompressed:sub(i, i)))
    end

    -- self:PrintHex(bytesDecompressed, "Image data")

    local channelCount
    if self.ColorType == 2 then
        channelCount = 3
    -- elseif png.ColorType == 3 then
        -- channelCount = 4
    else
        Image:Error("IDAT.ReadChunk", "ColorType not supported")
    end

    -- Parse bytes into an array for easier de-filtering.
    local byteArray = {}
    for i=1,self.Height,1 do
        byteArray[i] = {}
    end

    local rowLength = (self.Width * channelCount) + 1
    for i,byte in ipairs(bytesDecompressed) do
        local rowIndex = (i - 1) // (rowLength) + 1
        local columnIndex = i - ((rowIndex - 1) * (rowLength))

        byteArray[rowIndex][columnIndex] = byte
    end

    for i=1,self.Height,1 do -- For each row/scanline
        local row = byteArray[i]
        local scanlineFiltering = row[1]

        Image:DebugLog("IDAT.ReadChunk", "Scanline filtering", scanlineFiltering)

        for j=2,rowLength,1 do -- For each pixel (X bytes, based on channel count). j is 2 because first byte is filter type
            local filteringValue
            local byteX, byteY = i, j
            local currentByte = byteArray[byteX][byteY]
            local pixelIndex = ((byteY - 2) % (channelCount)) + 1

            local previousByte = byteArray[byteX][byteY - 3] or 0 -- Corresponding byte of previous pixel
            if byteY - 1 == 1 and scanlineFiltering ~= 0 and (byteX > 1) then -- Use last byte of previous row instead - TODO is this correct?
                -- previousByte = byteArray[byteX - 1][rowLength - channelCount - 1 + pixelIndex]
                previousByte = 0
            end
            local upperByte
            if scanlineFiltering > 1 then
                upperByte = byteArray[i - 1][j] -- Directly above
            end
            local byteC
            if scanlineFiltering > 2 then
                byteC = byteArray[byteX - 1][byteY - 3] or 0
                if byteX - 1 == 1 then
                    -- byteC = byteArray[byteX - 2][rowLength - channelCount - 1 + pixelIndex] -- Wrap to last byte of 2 rows prior - TODO is this correct?
                    byteC = 0
                end
            end

            if scanlineFiltering == 1 then
                if (byteY - 1) > channelCount then -- Does not apply to first pixel in a scanline
                    filteringValue = previousByte
                else
                    filteringValue = 0
                end
            elseif scanlineFiltering == 2 then
                filteringValue = upperByte
            elseif scanlineFiltering == 3 then
                filteringValue = (upperByte + previousByte + byteC) // 3
            elseif scanlineFiltering == 4 then -- Paeth
                local p = previousByte + upperByte - byteC
                local closestVal = 99999
                local candidates = {previousByte, upperByte, byteC}

                for _,candidate in ipairs(candidates) do
                    local dist = math.abs(candidate - p)
                    if dist < closestVal then
                        filteringValue = candidate
                        closestVal = dist
                    end
                end
            elseif scanlineFiltering == 0 then
                filteringValue = 0
            else
                Image:Error("IDAT.ReadChunk", "Unimplemented filtering type", scanlineFiltering)
            end

            print("defiltered val", byteX, byteY, currentByte, filteringValue)
            currentByte = currentByte + filteringValue
            currentByte = currentByte % 256
            byteArray[byteX][byteY] = currentByte
        end
    end

    for i=1,self.Height,1 do
        local row = byteArray[i]

        for j=2,rowLength,3 do
            local r, g, b
            r, g, b = row[j], row[j + 1], row[j + 2]
            -- TODO check channel count

            self.Image:AddPixel(Color.CreateFromRGB(r, g, b)) -- TODO alpha
        end
    end
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
    Image:Dump(self.Image)
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