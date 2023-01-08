
local Generic = Client.UI.Generic

---@class GenericUI_Element_TiledBackground : GenericUI_Element
---@field Events GenericUI_Element_Events
local TiledBackground = {
    ---@enum GenericUI_Element_TiledBackground_Type
    BACKGROUND_TYPES = {
        RED_PROMPT = "RedPrompt",
        BLACK = "Black",
        FORMATTED_TOOLTIP = "FormattedTooltip",
        NOTE = "Note",
    },
    Events = {},
}
Generic.Inherit(TiledBackground, Generic._Element)
local BG = TiledBackground

---------------------------------------------
-- METHODS
---------------------------------------------

BG.SetBackground = Generic.ExposeFunction("SetBackground")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("TiledBackground", TiledBackground)