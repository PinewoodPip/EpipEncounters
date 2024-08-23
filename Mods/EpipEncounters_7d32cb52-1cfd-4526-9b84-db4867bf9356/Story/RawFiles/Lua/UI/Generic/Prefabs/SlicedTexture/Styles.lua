
local T = Epip.GetFeature("Feature_GenericUITextures").TEXTURES.SLICED
local Generic = Client.UI.Generic

local SlicedTexture = Generic.GetPrefab("GenericUI.Prefabs.SlicedTexture") ---@class GenericUI.Prefabs.SlicedTexture

---Creates a 9-sliced texture style.
---@param tbl table Must have all 9 textures named in uppercase with underscore separator.
---@return GenericUI.Prefabs.SlicedTexture.Style
local function Create9SlicedStyle(tbl)
    return {
        Type = "9-Sliced",
        Bottom = tbl.BOTTOM,
        BottomLeft = tbl.BOTTOM_LEFT,
        BottomRight = tbl.BOTTOM_RIGHT,
        TopLeft = tbl.TOP_LEFT,
        Top = tbl.TOP,
        TopRight = tbl.TOP_RIGHT,
        Left = tbl.LEFT,
        Center = tbl.CENTER,
        Right = tbl.RIGHT,
    }
end

----@type table<string, GenericUI.Prefabs.SlicedTexture.Style> Annotation must be omitted as it breaks autocompletion.
SlicedTexture.STYLES = {
    AztecSquiggles = {
        Type = "9-Sliced",
        Bottom = T.AZTEC_SQUIGGLES.BOTTOM,
        BottomLeft = T.AZTEC_SQUIGGLES.BOTTOM_LEFT,
        BottomRight = T.AZTEC_SQUIGGLES.BOTTOM_RIGHT,
        TopLeft = T.AZTEC_SQUIGGLES.TOP_LEFT,
        Top = T.AZTEC_SQUIGGLES.TOP,
        TopRight = T.AZTEC_SQUIGGLES.TOP_RIGHT,
        Left = T.AZTEC_SQUIGGLES.LEFT,
        Center = T.AZTEC_SQUIGGLES.CENTER,
        Right = T.AZTEC_SQUIGGLES.RIGHT,
    },
    ContextMenu = {
        Type = "3-Sliced Vertical",
        Top = T.CONTEXT_MENU.TOP,
        Center = T.CONTEXT_MENU.CENTER,
        Bottom = T.CONTEXT_MENU.BOTTOM,
    },
    ControllerContextMenu = Create9SlicedStyle(T.CONTROLLER_CONTEXT_MENU),
    SimpleTooltip = {
        Type = "9-Sliced",
        Bottom = T.SIMPLE_TOOLTIP.BOTTOM,
        BottomLeft = T.SIMPLE_TOOLTIP.BOTTOM_LEFT,
        BottomRight = T.SIMPLE_TOOLTIP.BOTTOM_RIGHT,
        TopLeft = T.SIMPLE_TOOLTIP.TOP_LEFT,
        Top = T.SIMPLE_TOOLTIP.TOP,
        TopRight = T.SIMPLE_TOOLTIP.TOP_RIGHT,
        Left = T.SIMPLE_TOOLTIP.LEFT,
        Center = T.SIMPLE_TOOLTIP.CENTER,
        Right = T.SIMPLE_TOOLTIP.RIGHT,
    },
    WhiteMessage = {
        Type = "3-Sliced Horizontal",
        Left = T.MESSAGES.WHITE.LEFT,
        Center = T.MESSAGES.WHITE.CENTER,
        Right = T.MESSAGES.WHITE.RIGHT,
    },
    BlackMessage = {
        Type = "3-Sliced Horizontal",
        Left = T.MESSAGES.BLACK.LEFT,
        Center = T.MESSAGES.BLACK.CENTER,
        Right = T.MESSAGES.BLACK.RIGHT,
    },
    HorizontalShadow = {
        Type = "3-Sliced Horizontal",
        Left = T.SHADOWS.HORIZONTAL.LEFT,
        Center = T.SHADOWS.HORIZONTAL.CENTER,
        Right = T.SHADOWS.HORIZONTAL.RIGHT,
    },
}

for id,style in pairs(SlicedTexture.STYLES) do
    SlicedTexture:RegisterStyle(id, style)
end
