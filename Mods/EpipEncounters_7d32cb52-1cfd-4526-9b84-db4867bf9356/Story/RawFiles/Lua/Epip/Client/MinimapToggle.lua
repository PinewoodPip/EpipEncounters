
---------------------------------------------
-- Allows toggling the visibility of the minimap via a setting or call.
---------------------------------------------

local Set = DataStructures.Get("DataStructures_Set")
local Minimap = Client.UI.Minimap

---@class Feature_MinimapToggle : Feature
local MinimapToggle = {
    _ModulesRequestingDisable = Set.Create(),

    SupportedGameStates = _Feature.GAME_STATES.RUNNING_SESSION | _Feature.GAME_STATES.PAUSED_SESSION,
}
Epip.RegisterFeature("MinimapToggle", MinimapToggle)

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
    if Minimap:Exists() then -- TODO restore visibility when feature is disabled
        local root = Minimap:GetRoot()
        local uiState = root.visible
        local featureState = MinimapToggle.IsVisible()

        -- No need to set this every tick.
        if uiState ~= featureState then
            root.visible = featureState
        end
    end
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