
local Image = Client.Image

---@class ImageLib_Decoder
local _Decoder = {
    Bytes = nil, ---@type ImageLib_ByteStream
    Index = 1, ---@type integer
    FileName = nil, ---@type string
}
Image.RegisterDecoder("ImageLib_Decoder", _Decoder)

---@param filename string
---@return ImageLib_Decoder
function _Decoder:Create(filename)
    local file = IO.LoadFile(filename, "user", true) -- TODO
    local bytes = {string.byte(file, 1, #file)}

    ---@type ImageLib_Decoder
    local tbl = {
        Bytes = bytes,
        Index = 1,
        FileName = filename,
    }
    Inherit(tbl, self)

    return tbl
end

local function toHex(str)
    local valStr = string.format("%x", str)
    
    while string.len(valStr) < 2 do
        valStr = "0" .. valStr
    end

    return valStr:upper()
end

---@param bytes ImageLib_ByteStream
---@return integer
function _Decoder:BytesToNumber(bytes)
    local num = ""

    for i=1,#bytes,1 do -- Assuming big endian
        num = num .. toHex(bytes[i])
    end

    return tonumber(num, 16)
end

function _Decoder:Decode()
    error("Not implemented")
end

---@param bytes ImageLib_ByteStream
---@param description string?
function _Decoder:PrintHex(bytes, description)
    Image:DebugLog("HEX", description or "", self:ToSpacedHex(bytes))
end

---@param bytes ImageLib_ByteStream
---@return string
function _Decoder:ToSpacedHex(bytes)
    local hexStr = self:ToHex(bytes)
    local str = ""

    for i=1,#hexStr,1 do
        str = str .. hexStr:sub(i, i)

        if i % 2 == 0 and i ~= #hexStr then
            str = str .. " "
        end
    end

    return str
end

---@param bytes ImageLib_ByteStream
---@return string
function _Decoder:ToHex(bytes)
    local str = ""

    for i=1,#bytes,1 do
        str = str .. toHex(bytes[i])
    end

    return str
end

---@param count integer
---@return number[] --  bytes.
function _Decoder:ConsumeBytes(count)
    local output = {}

    for i=0,count-1,1 do
        table.insert(output, self.Bytes[self.Index + i])
    end

    self:MoveIndex(count)
    
    return output
end

---@param byteCount integer
---@return integer
function _Decoder:ConsumeInteger(byteCount)
    local bytes = self:ConsumeBytes(byteCount)

    return self:BytesToNumber(bytes)
end

---@param offset integer
function _Decoder:MoveIndex(offset)
    self.Index = self.Index + offset
end