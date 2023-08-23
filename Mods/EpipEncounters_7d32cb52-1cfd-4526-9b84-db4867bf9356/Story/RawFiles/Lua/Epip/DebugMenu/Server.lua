
---@class Feature_DebugMenu
local DebugMenu = Epip.GetFeature("Feature_DebugMenu")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener(DebugMenu.NETMSG_LIBRARY_STATE_CHANGED, function (payload)
    local feature = pcall(Epip.GetFeature, payload.ModTableID, payload.ID)

    if feature then
        if payload.Property == "Debug" then
            DebugMenu.SetDebugState(payload.ModTableID, payload.ID, payload.Value)
        elseif payload.Property == "Enabled" then
            DebugMenu.SetEnabledState(payload.ModTableID, payload.ID, payload.Value)
        end
    else
        DebugMenu:DebugLog("Received request to change state of a feature with no server table; doing nothing.")
    end
end)