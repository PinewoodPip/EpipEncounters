
local T = Epip.GetFeature("Feature_GenericUITextures")
local ButtonTextures = T.TEXTURES.BUTTONS
local StateButtonTextures = T.TEXTURES.STATE_BUTTONS
local Generic = Client.UI.Generic

local Button = Generic.GetPrefab("GenericUI_Prefab_Button") ---@class GenericUI_Prefab_Button

---Creates a Button styles from a table of textures with keys `IDLE`, `HIGHLIGHTED`, `PRESSED` and `DISABLED`.
---@param textures {IDLE:TextureLib_Texture?, HIGHLIGHTED:TextureLib_Texture?, PRESSED:TextureLib_Texture?, DISABLED:TextureLib_Texture?}
---@param otherFields GenericUI_Prefab_Button_Style? Will be merged.
---@return GenericUI_Prefab_Button_Style
local function CreateStyle(textures, otherFields)
    ---@type GenericUI_Prefab_Button_Style
    local style = otherFields or {}
    style.IdleTexture = textures.IDLE
    style.HighlightedTexture = textures.HIGHLIGHTED
    style.PressedTexture = textures.PRESSED
    style.DisabledTexture = textures.DISABLED
    return style
end

----@type table<string, GenericUI_Prefab_Button_Style> Type annotation must be omitted as it breaks autocompletion.
Button.STYLES = {
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
    DiamondArrowUp = {
        IdleTexture = ButtonTextures.ARROWS.UP_DIAMOND.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.UP_DIAMOND.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.UP_DIAMOND.PRESSED,
        DisabledTexture = ButtonTextures.ARROWS.UP_DIAMOND.DISABLED,
    },
    AddSlot = {
        IdleTexture = ButtonTextures.ADD.SLOT.IDLE,
        HighlightedTexture = ButtonTextures.ADD.SLOT.HIGHLIGHTED,
    },
    BrownLong = {
        IdleTexture = ButtonTextures.BROWN.LONG.IDLE,
        HighlightedTexture =  ButtonTextures.BROWN.LONG.HIGHLIGHTED,
        PressedTexture =  ButtonTextures.BROWN.LONG.PRESSED,
    },
    BrownMicro = {
        IdleTexture = ButtonTextures.BROWN.MICRO.IDLE,
        HighlightedTexture =  ButtonTextures.BROWN.MICRO.HIGHLIGHTED,
        PressedTexture =  ButtonTextures.BROWN.MICRO.PRESSED,
    },
    CancelListen = {
        IdleTexture = ButtonTextures.CANCEL.LISTEN.IDLE,
        HighlightedOverlay = ButtonTextures.CANCEL.LISTEN.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CANCEL.LISTEN.PRESSED,
    },
    DOS1Blue = {
        IdleTexture = ButtonTextures.BLUE_DOS1.IDLE,
        HighlightedTexture =  ButtonTextures.BLUE_DOS1.HIGHLIGHTED,
        PressedTexture =  ButtonTextures.BLUE_DOS1.PRESSED,
    },
    DiamondDown = {
        IdleTexture = ButtonTextures.ARROWS.DIAMOND.DOWN.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DIAMOND.DOWN.HIGHLIGHTED,
    },
    Diamond = {
        IdleTexture = ButtonTextures.ARROWS.DIAMOND.NORMAL.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DIAMOND.NORMAL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.DIAMOND.NORMAL.PRESSED,
        DisabledTexture = ButtonTextures.ARROWS.DIAMOND.NORMAL.DISABLED,
    },
    DiamondUp = {
        IdleTexture = ButtonTextures.ARROWS.DIAMOND.UP.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DIAMOND.UP.HIGHLIGHTED,
    },
    DoubleDiamond = {
        IdleTexture = ButtonTextures.ARROWS.DIAMOND.DOUBLE.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DIAMOND.DOUBLE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.DIAMOND.DOUBLE.PRESSED,
        DisabledTexture = ButtonTextures.ARROWS.DIAMOND.DOUBLE.DISABLED,
    },
    DoubleUp = {
        IdleTexture = ButtonTextures.ARROWS.DIAMOND.UP_DOUBLE.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DIAMOND.UP_DOUBLE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.DIAMOND.UP_DOUBLE.PRESSED,
    },
    DownSlate = {
        IdleTexture = ButtonTextures.ARROWS.DOWN_SLATE.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DOWN_SLATE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.DOWN_SLATE.PRESSED,
    },
    DownSlateSmall = {
        IdleTexture = ButtonTextures.ARROWS.DOWN_SLATE_SMALL.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DOWN_SLATE_SMALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.DOWN_SLATE_SMALL.PRESSED,
    },
    DownGreen = {
        IdleTexture = ButtonTextures.ARROWS.DOWN_GREEN.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DOWN_GREEN.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.DOWN_GREEN.PRESSED,
    },
    ScrollBarHorizontal = CreateStyle(ButtonTextures.SCROLL_BARS.HORIZONTAL),
    ScrollLeft = CreateStyle(ButtonTextures.SCROLL.LEFT),
    ScrollRight = CreateStyle(ButtonTextures.SCROLL.RIGHT),
    RoundWhiteDot = CreateStyle(ButtonTextures.ROUND.WHITE_DOT),
    SquareUp = {
        IdleTexture = ButtonTextures.ARROWS.SQUARE.UP.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.SQUARE.UP.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.SQUARE.UP.PRESSED,
    },
    SquareDown = {
        IdleTexture = ButtonTextures.ARROWS.SQUARE.DOWN.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.SQUARE.DOWN.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.SQUARE.DOWN.PRESSED,
    },
    UpSlate = {
        IdleTexture = ButtonTextures.ARROWS.UP_SLATE.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.UP_SLATE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.UP_SLATE.PRESSED,
    },
    UpSlateSmall = {
        IdleTexture = ButtonTextures.ARROWS.UP_SLATE_SMALL.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.UP_SLATE_SMALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.UP_SLATE_SMALL.PRESSED,
    },
    UpBrownSmall = {
        IdleTexture = ButtonTextures.ARROWS.UP_BROWN_SMALL.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.UP_BROWN_SMALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.UP_BROWN_SMALL.PRESSED,
    },
    DownBrownSmall = {
        IdleTexture = ButtonTextures.ARROWS.DOWN_BROWN_SMALL.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.DOWN_BROWN_SMALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.DOWN_BROWN_SMALL.PRESSED,
    },
    SettingsRed = {
        IdleTexture = ButtonTextures.SETTINGS.RED.IDLE,
        HighlightedTexture = ButtonTextures.SETTINGS.RED.HIGHLIGHTED,
        PressedTexture = ButtonTextures.SETTINGS.RED.PRESSED,
    },
    LeftTall = {
        IdleTexture = ButtonTextures.ARROWS.LEFT_TALL.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.LEFT_TALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.LEFT_TALL.PRESSED,
    },
    LeftcharacterSheet = {
        IdleTexture = ButtonTextures.ARROWS.LEFT_CHARACTER_SHEET.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.LEFT_CHARACTER_SHEET.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.LEFT_CHARACTER_SHEET.PRESSED,
    },
    LeftDecorated = {
        IdleTexture = ButtonTextures.ARROWS.LEFT_DECORATED.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.LEFT_DECORATED.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.LEFT_DECORATED.PRESSED,
    },
    RightTall = {
        IdleTexture = ButtonTextures.ARROWS.RIGHT_TALL.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.RIGHT_TALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.RIGHT_TALL.PRESSED,
    },
    RightCharacterSheet = {
        IdleTexture = ButtonTextures.ARROWS.RIGHT_CHARACTER_SHEET.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.RIGHT_CHARACTER_SHEET.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.RIGHT_CHARACTER_SHEET.PRESSED,
    },
    RightDecorated = {
        IdleTexture = ButtonTextures.ARROWS.RIGHT_DECORATED.IDLE,
        HighlightedTexture = ButtonTextures.ARROWS.RIGHT_DECORATED.HIGHLIGHTED,
        PressedTexture = ButtonTextures.ARROWS.RIGHT_DECORATED.PRESSED,
    },
    EditGreen = {
        IdleTexture = ButtonTextures.EDIT.GREEN.IDLE,
        HighlightedTexture = ButtonTextures.EDIT.GREEN.HIGHLIGHTED,
        PressedTexture = ButtonTextures.EDIT.GREEN.PRESSED,
    },
    EditWide = {
        IdleTexture = ButtonTextures.EDIT_WIDE.IDLE,
        HighlightedTexture = ButtonTextures.EDIT_WIDE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.EDIT_WIDE.PRESSED,
    },
    StopRed = {
        IdleTexture = ButtonTextures.STOP.RED.IDLE,
        HighlightedTexture = ButtonTextures.STOP.RED.HIGHLIGHTED,
        PressedTexture = ButtonTextures.STOP.RED.PRESSED,
    },
    SaveGreen = {
        IdleTexture = ButtonTextures.SAVE.GREEN.IDLE,
        HighlightedTexture = ButtonTextures.SAVE.GREEN.HIGHLIGHTED,
        PressedTexture = ButtonTextures.SAVE.GREEN.PRESSED,
    },
    InfoYellow = {
        IdleTexture = ButtonTextures.INFO.YELLOW.IDLE,
        HighlightedTexture = ButtonTextures.INFO.YELLOW.HIGHLIGHTED,
    },
    MenuSlate = {
        IdleTexture = ButtonTextures.MENU.SLATE.IDLE,
        HighlightedTexture = ButtonTextures.MENU.SLATE.HIGHLIGHTED,
    },
    MenuSlateTall = {
        IdleTexture = ButtonTextures.MENU.SLATE_TALL.IDLE,
        HighlightedTexture = ButtonTextures.MENU.SLATE_TALL.HIGHLIGHTED,
    },
    TradeLarge = {
        IdleTexture = ButtonTextures.TRADE.LARGE.IDLE,
        PressedTexture = ButtonTextures.TRADE.LARGE.PRESSED,
    },
    TradeDialogue = {
        IdleTexture = ButtonTextures.TRADE.DIALOG.IDLE,
        HighlightedTexture = ButtonTextures.TRADE.DIALOG.HIGHLIGHTED,
        PressedTexture = ButtonTextures.TRADE.DIALOG.PRESSED,
    },
    LabelPointy = {
        IdleTexture = ButtonTextures.LABEL.POINTY.IDLE,
        HighlightedTexture = ButtonTextures.LABEL.POINTY.HIGHLIGHTED,
    },
    Blue = {
        IdleTexture = ButtonTextures.BLUE.IDLE,
        HighlightedTexture = ButtonTextures.BLUE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.BLUE.PRESSED,
        DisabledTexture = ButtonTextures.BLUE.DISABLED,
    },
    GreenMedium = {
        IdleTexture = ButtonTextures.GREEN.MEDIUM.IDLE,
        HighlightedTexture = ButtonTextures.GREEN.MEDIUM.HIGHLIGHTED,
        PressedTexture = ButtonTextures.GREEN.MEDIUM.PRESSED,
        DisabledTexture = ButtonTextures.GREEN.MEDIUM.DISABLED,
    },
    GreenMediumTextured = {
        IdleTexture = ButtonTextures.GREEN.MEDIUM_TEXTURED.IDLE,
        HighlightedTexture = ButtonTextures.GREEN.MEDIUM_TEXTURED.HIGHLIGHTED,
        PressedTexture = ButtonTextures.GREEN.MEDIUM_TEXTURED.PRESSED,
        DisabledTexture = ButtonTextures.GREEN.MEDIUM_TEXTURED.DISABLED,
    },
    GreenSmallTextured = {
        IdleTexture = ButtonTextures.GREEN.SMALL_TEXTURED.IDLE,
        HighlightedTexture = ButtonTextures.GREEN.SMALL_TEXTURED.HIGHLIGHTED,
        PressedTexture = ButtonTextures.GREEN.SMALL_TEXTURED.PRESSED,
        DisabledTexture = ButtonTextures.GREEN.SMALL_TEXTURED.DISABLED,
    },
    ComboBox = {
        IdleTexture = ButtonTextures.COMBO_BOX.IDLE,
        HighlightedTexture = ButtonTextures.COMBO_BOX.HIGHLIGHTED,
    },
    Close = {
        IdleTexture = ButtonTextures.CLOSE.IDLE,
        HighlightedTexture = ButtonTextures.CLOSE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CLOSE.PRESSED,
    },
    CloseSimple = {
        IdleTexture = ButtonTextures.CLOSE.SIMPLE.IDLE,
        HighlightedTexture = ButtonTextures.CLOSE.SIMPLE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CLOSE.SIMPLE.PRESSED,
    },
    CloseGreen = {
        IdleTexture = ButtonTextures.CLOSE_GREEN.IDLE,
        HighlightedTexture = ButtonTextures.CLOSE_GREEN.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CLOSE_GREEN.PRESSED,
    },
    CloseBackgroundless = {
        IdleTexture = ButtonTextures.CLOSE.BACKGROUNDLESS.IDLE,
        HighlightedTexture = ButtonTextures.CLOSE.BACKGROUNDLESS.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CLOSE.BACKGROUNDLESS.PRESSED,
    },
    CloseBackgroundlessShaded = {
        IdleTexture = ButtonTextures.CLOSE.BACKGROUNDLESS.SHADED.IDLE,
        HighlightedTexture = ButtonTextures.CLOSE.BACKGROUNDLESS.SHADED.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CLOSE.BACKGROUNDLESS.SHADED.PRESSED,
    },
    CloseDOS1Square = {
        IdleTexture = ButtonTextures.CLOSE.DOS1_SQUARE.IDLE,
        HighlightedTexture = ButtonTextures.CLOSE.DOS1_SQUARE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CLOSE.DOS1_SQUARE.PRESSED,
    },
    CloseSlate = {
        IdleTexture = ButtonTextures.CLOSE.SLATE.IDLE,
        HighlightedTexture = ButtonTextures.CLOSE.SLATE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CLOSE.SLATE.PRESSED,
    },
    CloseStone = {
        IdleTexture = ButtonTextures.CLOSE.STONE.IDLE,
        HighlightedTexture = ButtonTextures.CLOSE.STONE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.CLOSE.STONE.PRESSED,
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
    IncrementGreen = {
        IdleTexture = ButtonTextures.COUNTER.GREEN.INCREMENT.IDLE,
    },
    DecrementGreen = {
        IdleTexture = ButtonTextures.COUNTER.GREEN.DECREMENT.IDLE,
    },
    IncrementWhite = {
        IdleTexture = ButtonTextures.COUNTER.WHITE.INCREMENT.IDLE,
    },
    DecrementWhite = {
        IdleTexture = ButtonTextures.COUNTER.WHITE.DECREMENT.IDLE,
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
    IncrementSmallStone = {
        IdleTexture = ButtonTextures.COUNTER.SMALL_STONE.INCREMENT.IDLE,
        HighlightedTexture = ButtonTextures.COUNTER.SMALL_STONE.INCREMENT.HIGHLIGHTED,
        PressedTexture = ButtonTextures.COUNTER.SMALL_STONE.INCREMENT.PRESSED,
    },
    DecrementSmallStone = {
        IdleTexture = ButtonTextures.COUNTER.SMALL_STONE.DECREMENT.IDLE,
        HighlightedTexture = ButtonTextures.COUNTER.SMALL_STONE.DECREMENT.HIGHLIGHTED,
        PressedTexture = ButtonTextures.COUNTER.SMALL_STONE.DECREMENT.PRESSED,
    },
    IncrementCharacterSheet = {
        IdleTexture = ButtonTextures.COUNTER.CHARACTER_SHEET.INCREMENT.IDLE,
        HighlightedTexture = ButtonTextures.COUNTER.CHARACTER_SHEET.INCREMENT.HIGHLIGHTED,
        PressedTexture = ButtonTextures.COUNTER.CHARACTER_SHEET.INCREMENT.PRESSED,
    },
    DecrementCharacterSheet = {
        IdleTexture = ButtonTextures.COUNTER.CHARACTER_SHEET.DECREMENT.IDLE,
        HighlightedTexture = ButtonTextures.COUNTER.CHARACTER_SHEET.DECREMENT.HIGHLIGHTED,
        PressedTexture = ButtonTextures.COUNTER.CHARACTER_SHEET.DECREMENT.PRESSED,
    },
    LargeNotch = {
        IdleTexture = ButtonTextures.NOTCHES.LARGE.IDLE,
        HighlightedTexture = ButtonTextures.NOTCHES.LARGE.HIGHLIGHTED,
    },
    Notch = {
        IdleTexture = ButtonTextures.NOTCHES.SMALL.IDLE,
        HighlightedTexture = ButtonTextures.NOTCHES.SMALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.NOTCHES.SMALL.PRESSED,
        DisabledTexture = ButtonTextures.NOTCHES.SMALL.DISABLED,
    },
    TabCharacterSheet = {
        IdleTexture = ButtonTextures.TABS.CHARACTER_SHEET.IDLE,
        HighlightedTexture = ButtonTextures.TABS.CHARACTER_SHEET.HIGHLIGHTED,
        PressedTexture = ButtonTextures.TABS.CHARACTER_SHEET.PRESSED,
    },
    TabCharacterSheetWide = {
        IdleTexture = ButtonTextures.TABS.CHARACTER_SHEET_WIDE.IDLE,
        HighlightedTexture = ButtonTextures.TABS.CHARACTER_SHEET_WIDE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.TABS.CHARACTER_SHEET_WIDE.PRESSED,
    },
    Transparent = {
        IdleTexture = ButtonTextures.TRANSPARENT.IDLE,
        HighlightedTexture = ButtonTextures.TRANSPARENT.HIGHLIGHTED,
        PressedTexture = ButtonTextures.TRANSPARENT.PRESSED,
        DisabledTexture = ButtonTextures.TRANSPARENT.DISABLED,
    },
    TransparentMedium = {
        IdleTexture = ButtonTextures.TRANSPARENT_MEDIUM.IDLE,
        HighlightedTexture = ButtonTextures.TRANSPARENT_MEDIUM.HIGHLIGHTED,
        PressedTexture = ButtonTextures.TRANSPARENT_MEDIUM.PRESSED,
    },
    TransparentLong = {
        IdleTexture = ButtonTextures.TRANSPARENT_LONG.IDLE,
        HighlightedTexture = ButtonTextures.TRANSPARENT_LONG.HIGHLIGHTED,
        PressedTexture = ButtonTextures.TRANSPARENT_LONG.PRESSED,
    },
    TransparentLargeDark = CreateStyle(ButtonTextures.TRANSPARENT_LARGE_DARK, {PressedLabelYOffset = 2}),
    LargeRed = CreateStyle(ButtonTextures.RED.LARGE, {PressedLabelYOffset = 2}),
    LargeRedWithArrows = CreateStyle(ButtonTextures.RED.LARGE_WITH_ARROWS, {PressedLabelYOffset = 2}),
    MediumRed = CreateStyle(ButtonTextures.RED.MEDIUM),
    SmallRed = {
        IdleTexture = ButtonTextures.RED.SMALL.IDLE,
        HighlightedTexture = ButtonTextures.RED.SMALL.HIGHLIGHTED,
        PressedTexture = ButtonTextures.RED.SMALL.PRESSED,
    },
    RedTinySquare = CreateStyle(ButtonTextures.RED.TINY_SQUARE),
    RedDOS1 = {
        IdleTexture = ButtonTextures.RED.DOS1.IDLE,
        HighlightedTexture = ButtonTextures.RED.DOS1.HIGHLIGHTED,
        PressedTexture = ButtonTextures.RED.DOS1.PRESSED,
        DisabledTexture = ButtonTextures.RED.DOS1.DISABLED,
    },
    SquareStone = {
        IdleTexture = ButtonTextures.SQUARE.STONE.IDLE,
        HighlightedTexture = ButtonTextures.SQUARE.STONE.HIGHLIGHTED,
        PressedTexture = ButtonTextures.SQUARE.STONE.PRESSED,
        DisabledTexture = ButtonTextures.SQUARE.STONE.DISABLED,
    },
    YellowDecorated = {
        IdleTexture = ButtonTextures.YELLOW.DECORATED.IDLE,
        HighlightedTexture = ButtonTextures.YELLOW.DECORATED.HIGHLIGHTED,
        PressedTexture = ButtonTextures.YELLOW.DECORATED.PRESSED,
        DisabledTexture = ButtonTextures.YELLOW.DECORATED.DISABLED,
    },
    WhiteMedium = {
        IdleTexture = ButtonTextures.WHITE.MEDIUM.IDLE,
        HighlightedTexture = ButtonTextures.WHITE.MEDIUM.HIGHLIGHTED,
        PressedTexture = ButtonTextures.WHITE.MEDIUM.PRESSED,
    },

    -- State Buttons
    Armor_Inactive = {
        IdleTexture = StateButtonTextures.ARMOR.INACTIVE_IDLE,
    },
    Armor_Active = {
        IdleTexture = StateButtonTextures.ARMOR.ACTIVE_IDLE,
    },
    ArmorBorderless_Inactive = {
        IdleTexture = StateButtonTextures.ARMOR_BORDERLESS.INACTIVE_IDLE,
    },
    ArmorBorderless_Active = {
        IdleTexture = StateButtonTextures.ARMOR_BORDERLESS.ACTIVE_IDLE,
    },
    BrownSimple_Inactive = CreateStyle(StateButtonTextures.BROWN_SIMPLE.INACTIVE),
    BrownSimple_Active = CreateStyle(StateButtonTextures.BROWN_SIMPLE.ACTIVE),
    Helmet_Inactive = {
        IdleTexture = StateButtonTextures.HELMET.INACTIVE_IDLE,
        HighlightedTexture = StateButtonTextures.HELMET.INACTIVE_HIGHLIGHTED,
        PressedTexture = StateButtonTextures.HELMET.INACTIVE_PRESSED,
    },
    Helmet_Active = {
        IdleTexture = StateButtonTextures.HELMET.ACTIVE_IDLE,
        HighlightedTexture = StateButtonTextures.HELMET.ACTIVE_HIGHLIGHTED,
        PressedTexture = StateButtonTextures.HELMET.ACTIVE_PRESSED,
    },
    HelmetBorderless_Inactive = {
        IdleTexture = StateButtonTextures.HELMET_BORDERLESS.INACTIVE_IDLE,
    },
    HelmetBorderless_Active = {
        IdleTexture = StateButtonTextures.HELMET_BORDERLESS.ACTIVE_IDLE,
    },
    GenderMaleBorderless_Inactive = {
        IdleTexture = StateButtonTextures.GENDER.MALE.BORDERLESS.INACTIVE_IDLE,
    },
    GenderMaleBorderless_Active = {
        IdleTexture = StateButtonTextures.GENDER.MALE.BORDERLESS.ACTIVE_IDLE,
    },
    GenderFemaleBorderless_Inactive = {
        IdleTexture = StateButtonTextures.GENDER.FEMALE.BORDERLESS.INACTIVE_IDLE,
    },
    GenderFemaleBorderless_Active = {
        IdleTexture = StateButtonTextures.GENDER.FEMALE.BORDERLESS.ACTIVE_IDLE,
    },
    SimpleCheckbox_Inactive = {
        IdleTexture = StateButtonTextures.CHECKBOXES.SIMPLE.BACKGROUND,
        HighlightedTexture = StateButtonTextures.CHECKBOXES.SIMPLE.BACKGROUND_HIGHLIGHTED,
    },
    SimpleCheckbox_Active = {
        IdleTexture = StateButtonTextures.CHECKBOXES.SIMPLE.BACKGROUND,
        HighlightedTexture = StateButtonTextures.CHECKBOXES.SIMPLE.BACKGROUND_HIGHLIGHTED,
        IdleOverlay = StateButtonTextures.CHECKBOXES.SIMPLE.CHECKMARK,
        HighlightedOverlay = StateButtonTextures.CHECKBOXES.SIMPLE.CHECKMARK_HIGHLIGHTED,
    },
    SmallDiamond_Inactive = CreateStyle(StateButtonTextures.SMALL_DIAMOND),
    RoundCheckbox_Inactive = {
        IdleTexture = StateButtonTextures.CHECKBOXES.ROUND.BACKGROUND,
    },
    RoundCheckbox_Active = {
        IdleTexture = StateButtonTextures.CHECKBOXES.ROUND.BACKGROUND,
        IdleOverlay = StateButtonTextures.CHECKBOXES.ROUND.CHECKMARK,
    },
    SimpleCheckboxSmall_Inactive = {
        IdleTexture = StateButtonTextures.CHECKBOXES.SIMPLE_SMALL.BACKGROUND_INACTIVE_IDLE,
        HighlightedTexture = StateButtonTextures.CHECKBOXES.SIMPLE_SMALL.BACKGROUND_INACTIVE_HIGHLIGHTED,
    },
    SimpleCheckboxSmall_Active = {
        IdleTexture = StateButtonTextures.CHECKBOXES.SIMPLE_SMALL.BACKGROUND_ACTIVE_IDLE,
        HighlightedTexture = StateButtonTextures.CHECKBOXES.SIMPLE_SMALL.BACKGROUND_ACTIVE_HIGHLIGHTED,
    },
    StoneCheckbox_Inactive = {
        IdleTexture = StateButtonTextures.CHECKBOXES.STONE.BACKGROUND_INACTIVE_IDLE,
        HighlightedTexture = StateButtonTextures.CHECKBOXES.STONE.BACKGROUND_INACTIVE_HIGHLIGHTED,
        PressedTexture = StateButtonTextures.CHECKBOXES.STONE.BACKGROUND_INACTIVE_PRESSED,
    },
    StoneCheckbox_Active = {
        IdleTexture = StateButtonTextures.CHECKBOXES.STONE.BACKGROUND_ACTIVE_IDLE,
        HighlightedTexture = StateButtonTextures.CHECKBOXES.STONE.BACKGROUND_ACTIVE_HIGHLIGHTED,
        PressedTexture = StateButtonTextures.CHECKBOXES.STONE.BACKGROUND_ACTIVE_PRESSED,
    },
    FormCheckbox_Inactive = {
        IdleTexture = StateButtonTextures.CHECKBOXES.FORM.BACKGROUND_IDLE,
        HighlightedTexture = StateButtonTextures.CHECKBOXES.FORM.BACKGROUND_HIGHLIGHTED,
        PressedTexture = StateButtonTextures.CHECKBOXES.FORM.BACKGROUND_PRESSED,
    },
    FormCheckbox_Active = {
        IdleTexture = StateButtonTextures.CHECKBOXES.FORM.BACKGROUND_IDLE,
        HighlightedTexture = StateButtonTextures.CHECKBOXES.FORM.BACKGROUND_HIGHLIGHTED,
        PressedTexture = StateButtonTextures.CHECKBOXES.FORM.BACKGROUND_PRESSED,
        IdleOverlay = StateButtonTextures.CHECKBOXES.FORM.CHECKMARK,
    },
}

for id,style in pairs(Button.STYLES) do
    Button:RegisterStyle(id, style)
end
