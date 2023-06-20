
local T = Epip.GetFeature("Feature_GenericUITextures")
local ButtonTextures = T.TEXTURES.BUTTONS
local Generic = Client.UI.Generic

local Button = Generic.GetPrefab("GenericUI_Prefab_Button")

---@type table<string, GenericUI_Prefab_Button_Style>
local styles = {
    ArrowDown = {
        IdleTexture = ButtonTextures.ARROWS.DOWN.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DOWN.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.DOWN.PRESSED,
    },
    ArrowUp = {
        IdleTexture = ButtonTextures.ARROWS.UP.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.UP.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.UP.PRESSED,
    },
    DiamondDown = {
        IdleTexture = ButtonTextures.ARROWS.DIAMOND.DOWN.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DIAMOND.DOWN.HIGHLIGHTED,
    },
    Diamond = {
        IdleTexture = ButtonTextures.ARROWS.DIAMOND.NORMAL.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DIAMOND.NORMAL.HIGHLIGHTED,
    },
    DiamondUp = {
        IdleTexture = ButtonTextures.ARROWS.DIAMOND.UP.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DIAMOND.UP.HIGHLIGHTED,
    },
    DoubleDiamond = {
        IdleTexture = ButtonTextures.ARROWS.DIAMOND.DOUBLE.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DIAMOND.DOUBLE.HIGHLIGHTED,
    },
    SquareUp = {
        IdleTexture = ButtonTextures.ARROWS.SQUARE.UP.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.SQUARE.UP.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.SQUARE.UP.PRESSED,
    },
    Blue = {
        IdleTexture = ButtonTextures.BLUE.IDLE,
        HighlightedTexture = ButtonTextures.BLUE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.BLUE.PRESSED,
        DisabledTexture = ButtonTextures.BLUE.DISABLED,
    },
    Close = {
        IdleTexture = ButtonTextures.CLOSE.IDLE,
        HighlightedTexture = ButtonTextures.CLOSE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CLOSE.PRESSED,
    },
    LargeBrown = {
        IdleTexture = ButtonTextures.BROWN.LARGE.IDLE,
        HighlightedTexture = ButtonTextures.BROWN.LARGE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.BROWN.LARGE.PRESSED,
    },
    SmallBrown = {
        IdleTexture = ButtonTextures.BROWN.SMALL.IDLE,
        HighlightedTexture = ButtonTextures.BROWN.SMALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.BROWN.SMALL.PRESSED,
        DisabledTexture = ButtonTextures.BROWN.SMALL.DISABLED,
    },
    DOS1DecrementLarge = {
        IdleTexture = ButtonTextures.COUNTER.DOS1.DECREMENT.IDLE,
        HighlightedTexture = ButtonTextures.COUNTER.DOS1.DECREMENT.HIGHLIGHTED,
        PressedTexture = ButtonTextures.COUNTER.DOS1.DECREMENT.PRESSED,
    },
    DOS1IncrementLarge = {
        IdleTexture = ButtonTextures.COUNTER.DOS1.INCREMENT.IDLE,
        HighlightedTexture = ButtonTextures.COUNTER.DOS1.INCREMENT.HIGHLIGHTED,
        PressedTexture = ButtonTextures.COUNTER.DOS1.INCREMENT.PRESSED,
    },
    LargeNotch = {
        IdleTexture = ButtonTextures.NOTCHES.LARGE.IDLE,
        HighlightedTexture = ButtonTextures.NOTCHES.LARGE.HIGHLIGHTED,
    },
    Notch = {
        IdleTexture = ButtonTextures.NOTCHES.SMALL.IDLE,
        HighlightedTexture = ButtonTextures.NOTCHES.SMALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.NOTCHES.SMALL.PRESSED,
    },
    Transparent = {
        IdleTexture = ButtonTextures.TRANSPARENT.IDLE,
        HighlightedTexture = ButtonTextures.TRANSPARENT.HIGHLIGHTED,
        PressedTexture = ButtonTextures.TRANSPARENT.PRESSED,
    },
    LargeRed = {
        IdleTexture = ButtonTextures.RED.LARGE.IDLE,
        HighlightedTexture = ButtonTextures.RED.LARGE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.RED.LARGE.PRESSED,
    },
}

for id,style in pairs(styles) do
    Button:RegisterStyle(id, style)
end