
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