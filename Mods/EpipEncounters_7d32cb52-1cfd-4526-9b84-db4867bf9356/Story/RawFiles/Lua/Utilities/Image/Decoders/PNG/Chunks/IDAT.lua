
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
    local decompressed = Image.LibDeflate:DecompressDeflate(compressed)
    -- print(compressed, #compressed)
    -- print(decompressed, #decompressed)

    local bytesDecompressed = {}
    for i=1,#decompressed,1 do
        table.insert(bytesDecompressed, string.byte(decompressed:sub(i, i)))
    end

    png:PrintHex(bytesDecompressed, "Image data")
end