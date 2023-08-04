
local T = Epip.GetFeature("Feature_GenericUITextures").TEXTURES.SLICED
local Generic = Client.UI.Generic

local SlicedTexture = Generic.GetPrefab("GenericUI.Prefabs.SlicedTexture")

---@type table<string, GenericUI.Prefabs.SlicedTexture.Style>
local styles = {
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
}

for id,style in pairs(styles) do
    SlicedTexture:RegisterStyle(id, style)
end