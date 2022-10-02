
Game.AMERUI = {

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------
    characterStates = {}, -- contains CharGUIDs and a table containing their current UI instance, interface ID and page ID

    INTERFACES = {
        GREATFORGE = {
            ID = "AMER_UI_Greatforge",
            PAGES = {
                MAINHUB = "Page_MainHub",
            },
        },
    },

    ITEM_EVENTS = {
        ELEMENTWHEEL_SCROLL_DOWN = "AMER_UI_ElementWheel_ScrollButton_0",
        ELEMENTWHEEL_SCROLL_UP = "AMER_UI_ElementWheel_ScrollButton_1",
    },
}
local AMERUI = Game.AMERUI

Epip.InitializeLibrary("AMERUI", AMERUI)

---@class AMERUI_CharacterState
---@field Instance integer
---@field Interface string
---@field Page string