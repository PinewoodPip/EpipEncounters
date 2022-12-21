
local Image = Client.Image
local PNG = Image.GetDecoder("ImageLib_Decoder_PNG")

---@type ImageLib_Decoder_PNG_ChunkParser
local IHDR = {

}
PNG.RegisterChunkParser("49 48 44 52", IHDR)

function IHDR.ReadChunk(png, _)
    local width, height, bitDepth, colorType, compressionType, filterMethod, interlaceMethod

    Image:DebugLog("Found IHDR chunk")

    width = png:ConsumeInteger(4)
    height = png:ConsumeInteger(4)
    bitDepth = png:ConsumeInteger(1)
    colorType = png:ConsumeInteger(1)
    compressionType = png:ConsumeInteger(1)
    filterMethod = png:ConsumeInteger(1)
    interlaceMethod = png:ConsumeInteger(1)

    png.Width = width
    png.Height = height
    png.BitDepth = bitDepth
    png.ColorType = colorType
    png.CompressionType = compressionType
    png.FilterMethod = filterMethod
    png.InterlaceMethod = interlaceMethod

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

    -- Can initialize image at this point
    png:CreateImage(width, height)
end

