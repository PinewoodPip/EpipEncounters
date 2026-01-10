
---------------------------------------------
-- Server scripting for the toggle shroud option.
---------------------------------------------

---@type Feature
local Shroud = {
    ---@enum Features.ShroudToggle.State
    STATE = {
        UNSET = -1,
        DISABLED = 0,
        ENABLED = 1,
    },

    ---@type Features.ShroudToggle.State
    _CurrentState = -1,
}
Epip.RegisterFeature("Features.ShroudToggle", Shroud)
local OrigEnabledFunctor = Shroud:GetEnabledFunctor()

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function Shroud:GetEnabledFunctor()
    return function ()
        ---`ShroudRender()` is known to cause crashes in GM mode,
        ---thus the feature by default is dummied out there.
        return OrigEnabledFunctor() and Ext.GetGameMode() ~= "GameMaster"
    end
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Update shroud state when the setting changes.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting
    if setting.ModTable == "EpipEncounters" and setting.ID == "RenderShroud" then
        Shroud._CurrentState = ev.Value
        Osiris.ShroudRender(Shroud._CurrentState)
    end
end, {EnabledFunctor = Shroud:GetEnabledFunctor()}) -- Note: the support to disable this feature exists due to a hardware-specific crash with the shroud functions.

-- Update shroud state when loading into a session, as the state of the shroud in the savegame might be different from the setting.
GameState.Events.GameReady:Subscribe(function (_)
    if Shroud._CurrentState ~= Shroud.STATE.UNSET then
        Osiris.ShroudRender(Shroud._CurrentState)
    end
end, {EnabledFunctor = Shroud:GetEnabledFunctor()}) -- See note in other listeners.