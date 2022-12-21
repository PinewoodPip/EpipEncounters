
local Image = Client.Image
local PNG = Image.GetDecoder("ImageLib_Decoder_PNG")

---@type ImageLib_Decoder_PNG_ChunkParser
local IDAT = {

}
PNG.RegisterChunkParser("49 44 41 54", IDAT)

function IDAT.ReadChunk(png, byteCount)
    Image:DebugLog("ReadChunk", "Found IDAT chunk")
    local method = png:ConsumeInteger(1)
    local flag = png:ConsumeInteger(1)
    local bytes = png:ConsumeBytes(byteCount - 1 - 1 - 4)
    local adler32 = png:ConsumeInteger(4)

    print("Method, flag, adler32")
    print(method, flag, adler32)

    local compressed = ""
    for _,byte in ipairs(bytes) do
        compressed = compressed .. string.char(byte)
    end
    local decompressed, unprocessed = Image.LibDeflate:DecompressDeflate(compressed)

    local bytesDecompressed = {}
    for i=1,#decompressed,1 do
        table.insert(bytesDecompressed, string.byte(decompressed:sub(i, i)))
    end

    png:PrintHex(bytesDecompressed, "Image data")

    local channelCount
    if png.ColorType == 2 then
        channelCount = 3
    -- elseif png.ColorType == 3 then
        -- channelCount = 4
    else
        Image:Error("IDAT.ReadChunk", "ColorType not supported")
    end

    -- Parse bytes into an array for easier de-filtering.
    local byteArray = {}
    for i=1,png.Height,1 do
        byteArray[i] = {}
    end

    local rowLength = (png.Width * channelCount) + 1
    for i,byte in ipairs(bytesDecompressed) do
        local rowIndex = (i - 1) // (rowLength) + 1
        local columnIndex = i - ((rowIndex - 1) * (rowLength))

        byteArray[rowIndex][columnIndex] = byte
    end

    for i=1,png.Height,1 do -- For each row/scanline
        local row = byteArray[i]
        local scanlineFiltering = row[1]

        for j=2,rowLength,1 do -- For each pixel (X bytes, based on channel count). j is 2 because first byte is filter type
            local filteringValue
            local byteX, byteY = i, j
            local currentByte = byteArray[byteX][byteY]

            if scanlineFiltering == 2 then
                local byte = byteArray[i - 1][j] -- Directly above
                filteringValue = byte
            elseif scanlineFiltering == 0 then
                filteringValue = 0
            else
                Image:Error("IDAT.ReadChunk", "Unimplemented filtering type", scanlineFiltering)
            end

            -- print("defiltered val", byteX, byteY, currentByte + filteringValue)
            byteArray[byteX][byteY] = currentByte + filteringValue
        end
    end

    for i=1,png.Height,1 do
        local row = byteArray[i]

        for j=2,rowLength,3 do
            local r, g, b
            r, g, b = row[j], row[j + 1], row[j + 2]
            -- TODO check channel count

            png.Image:AddPixel(Color.CreateFromRGB(r, g, b)) -- TODO alpha
        end
    end
end