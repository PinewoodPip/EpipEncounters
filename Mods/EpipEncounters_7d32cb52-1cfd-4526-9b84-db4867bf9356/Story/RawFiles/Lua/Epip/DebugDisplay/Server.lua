
---@class Feature_DebugDisplay
local DebugDisplay = Epip.GetFeature("EpipEncounters", "DebugDisplay")
DebugDisplay.tickBroadcastRate = 0.1

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Server tickrate counting is only enabled if the host is in Ext developer mode, for network performance reasons.
if Epip.IsDeveloperMode() then
    Ext.Events.Tick:Subscribe(function (_)
        DebugDisplay.AddTick()
    end)

    local timer = Timer.Start(DebugDisplay.tickBroadcastRate, function (_)
        Net.Broadcast("EPIPENCOUNTERS_DebugDisplay_ServerTicks", {
            Ticks = #DebugDisplay.ticks,
        })
    end)
    timer:SetRepeatCount(-1)
end

-- Respond to pings.
Net.RegisterListener("EPIPENCOUNTERS_DebugDisplay_Ping", function (payload)
    local char = Character.Get(payload.NetID)

    Net.PostToOwner(char, "EPIPENCOUNTERS_DebugDisplay_Ping", payload)
end)