
local ForceStoryPatching = {}
Epip.RegisterFeature("ForceStoryPatching", ForceStoryPatching)

function ForceStoryPatching.Toggle(state)
    local switches = Ext.Utils.GetGlobalSwitches()
    local enabled = state or not switches.ForceStoryPatching

    switches.ForceStoryPatching = enabled

    ForceStoryPatching:DebugLog("Toggled: " .. tostring(enabled))
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting

    if setting.ModTable == "Epip_Developer" and setting.ID == "DEBUG_ForceStoryPatching" then
        ForceStoryPatching.Toggle(ev.Value)
    end
end)