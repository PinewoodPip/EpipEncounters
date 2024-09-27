
---------------------------------------------
-- Allows toggling the visibility of the minimap via a setting or call.
---------------------------------------------

local Set = DataStructures.Get("DataStructures_Set")
local Input = Client.Input
local Minimap = Client.UI.Minimap
local MinimapC = Client.UI.Controller.Minimap

---@class Feature_MinimapToggle : Feature
local MinimapToggle = {
    _ModulesRequestingDisable = Set.Create(),

    TranslatedStrings = {
        InputAction_Toggle_Name = {
            Handle = "h4909f5e1g70d6g4b89g98f3g3dda794aec4f",
            Text = "Toggle Minimap",
            ContextDescription = [[Keybind name]],
        },
        InputAction_Toggle_Description = {
            Handle = "h6ef014f9g75f8g4c3fga5dbg6b7407405e1c",
            Text = "Toggles visibility of the Minimap UI.",
            ContextDescription = [[Tooltip for "Toggle Minimap" keybind]],
        },
    },

    SupportedGameStates = _Feature.GAME_STATES.RUNNING_SESSION | _Feature.GAME_STATES.PAUSED_SESSION,
}
Epip.RegisterFeature("MinimapToggle", MinimapToggle)
local TSK = MinimapToggle.TranslatedStrings

---------------------------------------------
-- SETTINGS/INPUT ACTIONS
---------------------------------------------

MinimapToggle.InputActions = {
    Toggle = MinimapToggle:RegisterInputAction("Toggle", {
        Name = TSK.InputAction_Toggle_Name,
        Description = TSK.InputAction_Toggle_Description,
    })
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests the minimap's visibility to be set to a particular state.
---@param requestID string
---@param state boolean `false` to request the UI to be hidden.
function MinimapToggle.RequestState(requestID, state)
    if state == false then
        MinimapToggle._ModulesRequestingDisable:Add(requestID)
    else
        MinimapToggle._ModulesRequestingDisable:Remove(requestID)
    end
end

---Returns whether the minimap should be visible,
---based on requests to set its state.
---@return boolean
function MinimapToggle.IsVisible()
    local visible = true

    if MinimapToggle:IsEnabled() then
        visible = visible and #MinimapToggle._ModulesRequestingDisable == 0

        -- Check setting
        visible = visible and Settings.GetSettingValue("EpipEncounters", "Minimap")
    end

    return visible
end

-- Updates visibility of the UI based on settings and modules requesting it to be hidden.
function MinimapToggle._Update()
    local ui = MinimapToggle._GetUI()
    if ui:Exists() then -- TODO restore visibility when feature is disabled
        local root = ui:GetRoot()
        local uiState = root.visible
        local featureState = MinimapToggle.IsVisible()

        -- No need to set this every tick.
        if uiState ~= featureState then
            root.visible = featureState
        end
    end
end

---Returns the UI library to use, based on current input mode.
---@return UI
function MinimapToggle._GetUI()
    return Client.IsUsingController() and MinimapC or Minimap
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update the UI's visibility based on desired state.
-- TODO with the root.visibility approach there probably aren't issues with not using a tick listener?
GameState.Events.RunningTick:Subscribe(function (_)
    if MinimapToggle:IsEnabled() then
        MinimapToggle._Update()
    end
end)

-- Update visibility immediately when setting changes.
-- Desirable to preview the effect while within the setting menu
-- (where the game can be paused)
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting.ModTable == "EpipEncounters" and ev.Setting.ID == "Minimap" then
        MinimapToggle._Update()
    end
end)

-- Toggle setting when using the input action.
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == MinimapToggle.InputActions.Toggle.ID then
        local setting = Settings.GetSetting("EpipEncounters", "Minimap")
        Settings.SetValue("EpipEncounters", "Minimap", not setting:GetValue())
        MinimapToggle._Update()
    end
end)
