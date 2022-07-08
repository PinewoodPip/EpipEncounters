
local Generic = Client.UI.Generic

---@class GenericUI_Element_TiledBackground : GenericUI_Element
---@field SetBackground fun(self, bgID:integer, width:number, height:number)
---@field BACKGROUND_TYPES table<string, integer>

---@type GenericUI_Element_TiledBackground
Client.UI.Generic.ELEMENTS.TiledBackground = {
    BACKGROUND_TYPES = {
        BOX = 0,
    }
}
local BG = Generic.ELEMENTS.TiledBackground
Inherit(BG, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

BG.SetBackground = Generic.ExposeFunction("SetBackground")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("TiledBackground", BG)