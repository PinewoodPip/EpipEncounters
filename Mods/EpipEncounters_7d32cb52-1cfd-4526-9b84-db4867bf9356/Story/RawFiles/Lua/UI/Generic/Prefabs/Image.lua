
---------------------------------------------
-- Renders an arbitrary image.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local V = Vector.Create

---@class GenericUI.Prefabs.Image : GenericUI_Prefab, GenericUI_I_Elementable
---@field Root GenericUI_Element_Empty
---@field _ImageContainer GenericUI_Element_Empty
---@field _CurrentImage ImageLib_Image
---@field _Chunks GenericUI_Prefab_Text[][]
local Image = {
    CHUNK_SIZE = 16,
}
Generic:RegisterClass("GenericUI.Prefabs.Image", Image, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI.Prefabs.Image", Image)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.Image"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an Image instance.
---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param image ImageLib_Image
---@return GenericUI.Prefabs.Image
function Image.Create(ui, id, parent, image)
    local instance = Image:_Create(ui, id, ui, parent) ---@cast instance GenericUI.Prefabs.Image

    local root = instance:CreateElement("Root", "GenericUI_Element_Empty", parent)
    instance.Root = root

    instance:SetImage(image)

    return instance
end

---Sets the image to render.
---@param img ImageLib_Image
function Image:SetImage(img)
    local oldImg = self._CurrentImage
    local CHUNK_SIZE = self.CHUNK_SIZE
    local width, height = img.Width, img.Height

    local imageMatrix = {} ---@type ImageLib_Image[][] Matrix of image chunks.

    -- Add rows
    for _=1,height,CHUNK_SIZE do
        table.insert(imageMatrix, {})
    end

    -- Divide the image into chunks
    for i=1,height,CHUNK_SIZE do
        for j=1,width,CHUNK_SIZE do
            local chunkWidth = math.min(width - j + 1, CHUNK_SIZE)
            local chunkHeight = math.min(height - i + 1, CHUNK_SIZE)
            local subImg = Client.Image.CreateImage(chunkWidth, chunkHeight)
            for i2=i,i+chunkHeight-1,1 do
                for j2=j,j+chunkWidth-1,1 do
                    subImg:AddPixel(img.Pixels[i2][j2])
                end
            end
            table.insert(imageMatrix[i // CHUNK_SIZE + 1], subImg)
        end
    end

    -- Create text fields for each chunk.
    -- Recreate elements only if dimensions have changed.
    local needsInstancing = self._ImageContainer == nil
    if self._ImageContainer and (oldImg.Width ~= img.Width or oldImg.Height ~= img.Height) then
        self._ImageContainer:Destroy()
        needsInstancing = true
    end
    local container = self._ImageContainer
    if needsInstancing then
        container = self:CreateElement("Container", "GenericUI_Element_Empty", self.Root)
        self._ImageContainer = container
        self._Chunks = {}
        for rowIndex,_ in ipairs(imageMatrix) do
            self._Chunks[rowIndex] = {}
        end
    end
    local TEXT_SIZE ---@type vec2 Used for positioning, see below.
    for i,row in ipairs(imageMatrix) do
        for j,subImage in ipairs(row) do
            -- Update or instantiate the text field for the chunk
            local subImageText = Image.ImageToText(subImage)
            local text = self._Chunks[i][j]
            if text then
                text:SetText(subImageText)
            else -- Reinstantiate the text field
                text = TextPrefab.Create(self.UI, self:PrefixID("ImageText" .. i .. "." .. j), container, subImageText, "Left", V(150, 150))
                self._Chunks[i][j] = text
            end

            -- Shrink kerning and line height to remove seams
            text:SetTextFormat({
                letterSpacing = -2,
                leading = -15,
            })
            text:FitSize()

            -- Determine text size from the first chunk only, which will be the largest one. Chunks near the right and bottom edges might be smaller, but their positioning assumes previous ones are same size.
            if i == 1 and j == 1 then
                TEXT_SIZE = text:GetTextSize()
            end

            -- Position chunk
            text:SetPosition((j - 1) * TEXT_SIZE[1] - 6 * (j - 1), (i - 1) * TEXT_SIZE[2] - 11.7 * (i - 1)) -- The text size is lying a bit still, need to subtract a bit to get them to sit tight with each other
        end
    end

    container:SetScale(V(0.415, 0.45)) -- Necessary for a roughly square pixel ratio

    self._CurrentImage = img
end

---Returns the image being displayed.
---@return ImageLib_Image
function Image:GetImage()
    return self._CurrentImage
end

---@override
function Image:GetRootElement()
    return self.Root
end

---Converts an image to a text representation using the "■" character.
---@param img ImageLib_Image
---@return string
function Image.ImageToText(img)
    local str = ""
    for _,row in ipairs(img.Pixels) do
        for _,value in ipairs(row) do
            str = str .. Text.Format("■", {Color = value:ToHex()})
        end
        str = str .. "\n"
    end
    return str
end
