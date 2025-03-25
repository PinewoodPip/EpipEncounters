
---------------------------------------------
-- Basic paint brush tool with support for multiple shapes and sizes.
---------------------------------------------

local Assprite = Epip.GetFeature("Features.Assprite")

---@class Features.Assprite.Tools.ColorPicker : Features.Assprite.Tool
local ColorPicker = {
    ICON = "statcons_Arrowhead_Blood",
    Name = Assprite:RegisterTranslatedString({
        Handle = "hd1e74dcfg9fe7g4757g996fgdddb6b22eadc",
        Text = [[Insight]],
        ContextDescription = [[Tool name]],
    }),
    Description = Assprite:RegisterTranslatedString({
        Handle = "h41d3fa39g650fg4382gad13gb70f9a1a943c",
        Text = [[Performs reflection on image data points.]],
        ContextDescription = [[Tooltip for color picker tool]],
    }),

    SHAPES = {
        SQUARE = "Square",
        ROUND = "Round",
    },
}
Assprite:RegisterClass("Features.Assprite.Tools.ColorPicker", ColorPicker, {"Features.Assprite.Tool"})
ColorPicker:__RegisterInputAction({Keys = {"p"}})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function ColorPicker:OnUseStarted(context)
    self:_Pick(context)
    return false
end

---@override
function ColorPicker:OnCursorChanged(context) -- Allows click-and-drag to pick colors.
    self:_Pick(context)
    return false
end

---@override
function ColorPicker:GetSettings()
    return {
        Assprite.Settings.Color,
    }
end

---Picks the color from the context's cursor.
---@param context Features.Assprite.Context
function ColorPicker:_Pick(context)
    local img = context.Image
    local pos = context.CursorPos
    if pos then -- Pick color from the pixel coords
        local color = img:GetPixel(pos)
        Assprite.SetColor(color)
    end
end
