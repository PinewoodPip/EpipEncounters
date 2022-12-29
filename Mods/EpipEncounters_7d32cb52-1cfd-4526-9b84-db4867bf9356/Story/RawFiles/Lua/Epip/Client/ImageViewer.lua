
local Generic = Client.UI.Generic

---@class Feature_ImageViewer : Feature
local ImageViewer = {

}
Epip.RegisterFeature("ImageViewer", ImageViewer)
local UI = Generic.Create("PIP_ImageViewer")

function ImageViewer.RenderImage(filename)
    local decoder = Client.Image.GetDecoder("ImageLib_Decoder_PNG")
    local dec = decoder:Create(filename)
    local image = dec:Decode()
    
    if UI.PreviousElement then
        UI.PreviousElement:SetVisible(false) -- TODO dispose properly
    end
    local container = UI:CreateElement(filename, "GenericUI_Element_Empty")
    container:SetAsDraggableArea()
    UI.PreviousElement = container

    local graphics = container:GetMovieClip().graphics
    for i=1,image.Height,1 do
        for j=1,image.Width,1 do
            local pixel = image.Pixels[i][j]

            graphics.beginFill(pixel:ToDecimal(), 1) -- TODO alpha
            graphics.drawRect(j - 1, i - 1, 1, 1)
            graphics.endFill()
        end
    end

    UI:Show()
    UI:GetUI():SetPosition(900, 400)
end

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.RegisterConsoleCommand("drawimage", function (_, filename)
    ImageViewer.RenderImage(filename)
end)

function ImageViewer:__Setup()
    UI:Hide()

    local canvas = UI:CreateElement("Root", "GenericUI_Element_Empty")
    canvas:SetAsDraggableArea()
    UI.RootElement = canvas
end