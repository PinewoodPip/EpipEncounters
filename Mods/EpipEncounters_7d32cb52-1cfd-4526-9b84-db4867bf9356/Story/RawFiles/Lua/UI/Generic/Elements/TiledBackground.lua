
local Generic = Client.UI.Generic

---@class GenericUI_Element_TiledBackground : GenericUI_Element
---@field SetBackground fun(self, bgID:GenericUI_Element_TiledBackground_Type, width:number, height:number)
Client.UI.Generic.ELEMENTS.TiledBackground = {
    ---@enum GenericUI_Element_TiledBackground_Type
    BACKGROUND_TYPES = {
        RED_PROMPT = "RedPrompt",
        BLACK = "Black",
        FORMATTED_TOOLTIP = "FormattedTooltip",
        NOTE = "Note",
    },
    Events = {},
}
local BG = Generic.ELEMENTS.TiledBackground
Generic.Inherit(BG, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

BG.SetBackground = Generic.ExposeFunction("SetBackground")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("TiledBackground", BG)