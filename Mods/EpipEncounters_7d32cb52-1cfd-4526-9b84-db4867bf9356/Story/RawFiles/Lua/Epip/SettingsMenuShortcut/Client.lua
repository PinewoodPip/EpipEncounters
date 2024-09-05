
---------------------------------------------
-- Adds a shortcut to the Epip settings menu when shift+clicking
-- the vanilla "Options" button in the game menu.
---------------------------------------------

local GameMenu = Client.UI.GameMenu
local SettingsMenu = Epip.GetFeature("Feature_SettingsMenu")
local Input = Client.Input

---@type Feature
local Shortcut = {}
Epip.RegisterFeature("Features.SettingsMenuShortcut", Shortcut)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

GameMenu.Events.ButtonPressed:Subscribe(function (ev)
    if Input.IsShiftPressed() and ev.NumID == GameMenu.BUTTON_IDS.OPTIONS then
        SettingsMenu.Open()
        -- Play the button sound manually, as preventing the UICall prevents the sound as well.
        GameMenu:PlaySound(GameMenu.SOUNDS.BUTTON_PRESS)
        GameMenu:Hide() -- Must be done after playing the sound.
        ev:Prevent()
    end
end)
