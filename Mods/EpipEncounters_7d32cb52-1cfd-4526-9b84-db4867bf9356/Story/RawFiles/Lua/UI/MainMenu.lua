
---@class UI.MainMenu : UI
local Menu = {
    -- Button IDs.
    BUTTONS = {
        STORY = 0,
        CONTINUE = 1,
        GAMEMASTER = 2,
        GAMEMASTER_CONTINUE = 3,
        ARENA = 4,
        OPTIONS = 8,
        MODS = 9,
        PROFILES = 10,
        CREDITS = 13,
        QUIT = 15,
        LOAD = 17,
        GAMEMASTER_PREPARE = 19,
        GAMEMASTER_PLAY = 20,
        GAMEMASTER_LOAD = 21,
        SINGLEPLAYER = 23,
        MULTIPLAYER = 24,
        DIFFICULTY_EXPLORER = 25,
        DIFFICULTY_CLASSIC = 26,
        DIFFICULTY_TACTICIAN = 27,
        DIFFICULTY_STORY = 28,
        DIFFICULTY_TACTICIAN_REGULAR = 29,
        DIFFICULTY_TACTICIAN_HONOUR = 30,
        BEGIN = 31,
        BACK = 32,
    },
    -- Combobox IDs.
    COMBOBOXES = {
        CAMPAIGN = 22,
    }
}
Epip.InitializeUI(Ext.UI.TypeID.mainMenu, "MainMenu", Menu)
