
local ForceStoryPatching = {}
Epip.AddFeature("ForceStoryPatching", "ForceStoryPatching", ForceStoryPatching)

function ForceStoryPatching.Toggle(state)
    local switches = Ext.Utils.GetGlobalSwitches()
    local enabled = state or not switches.ForceStoryPatching

    switches.ForceStoryPatching = enabled

    ForceStoryPatching:DebugLog("Toggled: " .. tostring(enabled))
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_ServerOptionChanged", function(channel, payload)
    if payload.Mod == "EpipEncounters" and payload.Setting == "DEBUG_ForceStoryPatching" then
        ForceStoryPatching.Toggle(payload.Value)
    end
end)