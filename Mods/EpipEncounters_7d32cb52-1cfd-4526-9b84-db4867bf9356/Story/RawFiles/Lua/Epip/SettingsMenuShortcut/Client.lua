
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
        -- Cannot just open the UI directly, as it softlocks the game with a black screen if done before having opened the settings UI at least once in that session before.
        Timer.StartTickTimer(2, function (_)
            -- Find the correct optionsSettings instance and hide it
            for _,ui in ipairs(Ext.UI.GetUIObjectManager().UIObjects) do
                if ui.Type == Ext.UI.TypeID.optionsSettings.Default and ui.OF_Visible then
                    -- Hiding settings menu brings the pause menu back, which we must hide.
                    ui:ExternalInterfaceCall("requestCloseUI")
                    Ext.OnNextTick(function ()
                        GameMenu:Hide()
                    end)
                end
            end
        end)
        -- Open the Epip settings menu shortly after.
        -- Shortest working timing for this is unknown. Trying to do it too fast will cause the unpause to resize the UI.
        Timer.StartTickTimer(10, function (_)
            SettingsMenu.Open()
        end)
    end
end)
