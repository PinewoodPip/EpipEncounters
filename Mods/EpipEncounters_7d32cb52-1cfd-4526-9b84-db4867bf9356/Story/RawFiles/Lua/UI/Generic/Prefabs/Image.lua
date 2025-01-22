
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
    local CHUNK_SIZE = self.CHUNK_SIZE
    local width, height = img.Width, img.Height

    if height % CHUNK_SIZE ~= 0 or width % CHUNK_SIZE ~= 0 then
        Image:__Error("SetImage", "Image dimensions should be multiple of", CHUNK_SIZE)
    end

    local imageMatrix = {} ---@type ImageLib_Image[][] Matrix of image chunks.

    -- Add rows
    for _=1,height,CHUNK_SIZE do
        table.insert(imageMatrix, {})
    end

    -- Divide the image into chunks
    for i=1,height,CHUNK_SIZE do
        for j=1,width,CHUNK_SIZE do
            local subImg = Client.Image.CreateImage(CHUNK_SIZE, CHUNK_SIZE)
            for i2=i,i+CHUNK_SIZE-1,1 do
                for j2=j,j+CHUNK_SIZE-1,1 do
                    subImg:AddPixel(img.Pixels[i2][j2])
                end
            end
            table.insert(imageMatrix[i // CHUNK_SIZE + 1], subImg)
        end
    end

    -- Create text fields for each chunk
    if self._ImageContainer then
        self._ImageContainer:Destroy()
    end
    local container = self:CreateElement("Container", "GenericUI_Element_Empty", self.Root)
    self._ImageContainer = container
    for i,row in ipairs(imageMatrix) do
        for j,subImage in ipairs(row) do
            local text = TextPrefab.Create(self.UI, self:PrefixID("ImageText" .. i .. "." .. j), container, Image.ImageToText(subImage), "Left", V(100, 100))
            -- Shrink kerning and line height to remove seams
            text:SetTextFormat({
                letterSpacing = -2,
                leading = -18,
            })
            text:FitSize()
            local textSize = text:GetTextSize()
            text:SetPosition((j - 1) * textSize[1] - 6 * (j - 1), (i - 1) * textSize[2] - 15 * (i - 1)) -- The text size is lying a bit still, need to subtract a bit to get them to sit tight with each other
        end
    end

    container:SetScale(V(0.33, 0.5)) -- Necessary for a roughly square pixel ratio

    self._CurrentImage = img
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
