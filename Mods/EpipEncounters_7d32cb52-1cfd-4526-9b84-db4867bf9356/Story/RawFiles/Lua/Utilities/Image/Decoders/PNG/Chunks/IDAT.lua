
local Image = Client.Image
local PNG = Image.GetDecoder("ImageLib_Decoder_PNG")

---@type ImageLib_Decoder_PNG_ChunkParser
local IDAT = {

}
PNG.RegisterChunkParser("49 44 41 54", IDAT)

function IDAT.ReadChunk(png, byteCount)
    Image:DebugLog("ReadChunk", "Found IDAT chunk")
    local bytes = png:ConsumeBytes(byteCount)

    local compressed = ""
    for _,byte in ipairs(bytes) do
        compressed = compressed .. string.char(byte)
    end

    png:ConcatenateCompressedData(compressed)
end