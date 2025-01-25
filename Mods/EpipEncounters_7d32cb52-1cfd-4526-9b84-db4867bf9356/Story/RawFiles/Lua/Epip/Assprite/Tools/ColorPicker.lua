
---------------------------------------------
-- Basic paint brush tool with support for multiple shapes and sizes.
---------------------------------------------

local ICONS = Epip.GetFeature("Feature_GenericUITextures").ICONS
local Assprite = Epip.GetFeature("Features.Assprite")

---@class Features.Assprite.Tools.ColorPicker : Features.Assprite.Tool
local ColorPicker = {
    ICON = ICONS.FRAMED_GEMS.BLUE, -- TODO
    Name = Assprite:RegisterTranslatedString({
        Handle = "hd1e74dcfg9fe7g4757g996fgdddb6b22eadc",
        Text = [[Color Picker]],
        ContextDescription = [[Tool name]],
    }),

    SHAPES = {
        SQUARE = "Square",
        ROUND = "Round",
    },
}
Assprite:RegisterClass("Features.Assprite.Tools.ColorPicker", ColorPicker, {"Features.Assprite.Tool"})

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
