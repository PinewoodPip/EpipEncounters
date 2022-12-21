
local Image = Client.Image
local PNG = Image.GetDecoder("ImageLib_Decoder_PNG")

---@type ImageLib_Decoder_PNG_ChunkParser
local IEND = {

}
PNG.RegisterChunkParser("49 45 4E 44", IEND)

function IEND.ReadChunk(png, byteCount)
    Image:DebugLog("ReadChunk", "Found IEND/eof chunk")
    png:ConsumeBytes(byteCount)

    png._Finished = true
    png:DecompressData()
end