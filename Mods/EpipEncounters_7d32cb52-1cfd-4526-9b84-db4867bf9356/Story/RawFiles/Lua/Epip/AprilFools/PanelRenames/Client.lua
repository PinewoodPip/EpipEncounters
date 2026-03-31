
---------------------------------------------
-- Renames the titles of main UI panels during April Fools.
---------------------------------------------

local CharacterSheet = Client.UI.CharacterSheet
local PartyInventory = Client.UI.PartyInventory
local GameMenu = Client.UI.GameMenu

---@type Feature
local PanelRenames = {
    HEADER_REPLACEMENTS = {
        CHARACTER_SHEET = {
            "The Gang",
            "The Squad",
            "Your Homies",
            "The Party Animals",
            "Partners in Crime",
        },
        PARTY_INVENTORY = {
            "Junk",
            "The Hoard",
            "Random Crap",
            "That one pile in the corner of the bedroom",
        },
        LOAD_BUTTON = {
            "Savescum",
        }
    },
}
Epip.RegisterFeature("Features.AprilFools.PanelRenames", PanelRenames)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Change Character Sheet and Party Inventory panel header texts when they're opened for the first time in a session.
local characterSheetWasVisible = false
local partyInventoryWasVisible = false
GameState.Events.ClientReady:Subscribe(function (_)
    GameState.Events.RunningTick:Subscribe(function (_)
        if not characterSheetWasVisible and CharacterSheet:IsVisible() then
            local headerReplacement = PanelRenames.HEADER_REPLACEMENTS.CHARACTER_SHEET[Ext.Random(1, #PanelRenames.HEADER_REPLACEMENTS.CHARACTER_SHEET)]
            CharacterSheet:GetRoot().stats_mc.title_txt.htmlText = headerReplacement:upper()
            characterSheetWasVisible = true
        end
        if not partyInventoryWasVisible and PartyInventory:IsVisible() then
            local headerReplacement = PanelRenames.HEADER_REPLACEMENTS.PARTY_INVENTORY[Ext.Random(1, #PanelRenames.HEADER_REPLACEMENTS.PARTY_INVENTORY)]
            PartyInventory:GetRoot().inventory_mc.title_txt.htmlText = headerReplacement:upper()
            partyInventoryWasVisible = true
        end
    end)
end, {EnabledFunctor = Epip.IsAprilFools})

-- Change the "Load" button's text in the pause menu when it's opened.
GameMenu:RegisterInvokeListener("addMenuButton", function (_, id, _, _)
    if Epip.IsAprilFools() and id == GameMenu.BUTTON_IDS.LOAD then
        local menu = GameMenu:GetRoot().gameMenu_mc
        local buttons = menu.arrItems
        Timer.StartTickTimer(2, function ()
            for i=0,buttons.length-1,1 do
                local button = buttons[i]
                if button.id == GameMenu.BUTTON_IDS.LOAD then
                    local replacement = PanelRenames.HEADER_REPLACEMENTS.LOAD_BUTTON[Ext.Random(1, #PanelRenames.HEADER_REPLACEMENTS.LOAD_BUTTON)]
                    button.label_mc.text_txt.htmlText = replacement:upper()
                end
            end
        end)
    end
end, "Before")
