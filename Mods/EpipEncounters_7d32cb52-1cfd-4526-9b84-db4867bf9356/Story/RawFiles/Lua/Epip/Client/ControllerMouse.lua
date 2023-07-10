
---------------------------------------------
-- Allows mouse usage while playing in controller mode.
-- This will only have an effect on UIs designed to be used with mouse.
---------------------------------------------

local Input = Client.Input

---@type Feature
local ControllerMouse = {}
Epip.RegisterFeature("ControllerMouse", ControllerMouse)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Enable mouse input upon loading into the session.
GameState.Events.GameReady:Subscribe(function (_)
    if ControllerMouse:IsEnabled() and Client.IsUsingController() then
        local manager = Input.GetManager()
        manager.ControllerAllowKeyboardMouseInput = true

        -- Prevent the mouse from hiding when idle.
        GameState.Events.Tick:Subscribe(function (_)
            local uiManager = Ext.UI.GetCursorControl()
            uiManager.HideTimer = 99
        end)
    end
end)