
---@class Feature_InfiniteCarryWeight
local Encumbrance = Epip.GetFeature("Feature_InfiniteCarryWeight")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting.ModTable == "Epip_Inventory" and ev.Setting.ID == "Inventory_InfiniteCarryWeight" then
        Encumbrance.Toggle(ev.Value)

        Net.Broadcast("EPIPENCOUNTERS_ToggleEncumbrance", {Enabled = ev.Value})
    end
end)

-- Send Net message on GameReady - the Net listener happens too early to ping back the clients.
GameState.Events.GameReady:Subscribe(function (_)
    Net.Broadcast("EPIPENCOUNTERS_ToggleEncumbrance", {Enabled = Encumbrance.enabled})
end)