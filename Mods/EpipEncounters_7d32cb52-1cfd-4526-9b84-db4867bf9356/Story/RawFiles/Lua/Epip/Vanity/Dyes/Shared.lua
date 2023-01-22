
---@class Feature_Vanity_Dyes : Feature
local Dyes = {
    Tab = nil,
    CustomDyes = {},
    DyeHistory = {}, ---@type VanityDye[]
    lockColorSlider = false,
    colorPasteIndex = nil,

    currentSliderColor = {
        Color1 = Color.Create(),
        Color2 = Color.Create(),
        Color3 = Color.Create(),
    },

    DYE_CATEGORIES = {},
    DYE_DATA = {},
    DYE_CATEGORY_ORDER = {},
    DYE_PALETTE_BITS = 1,
    COLOR_NAMES = {"Primary", "Secondary", "Tertiary"},
    CACHE = {},
    DYE_HISTORY_LIMIT = 10,
    DYED_ITEM_TAG = "^PIP_DYE_(%x+)_(%x+)_(%x+)$",

    activeCharacterDyes = {},

    Events = {},
    Hooks = {},
}
Epip.RegisterFeature("Vanity_Dyes", Dyes)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class EPIPENCOUNTERS_DyeItem : NetLib_Message_Character, NetLib_Message_Item
---@field Dye VanityDye

---@class VanityDye
---@field Name string? Can be anonymous.
---@field ID string
---@field Type string
---@field Icon string?
---@field Color1 RGBColor
---@field Color2 RGBColor
---@field Color3 RGBColor

---@class VanityDyeCategory
---@field ID string
---@field Name string
---@field Dyes VanityDye[]