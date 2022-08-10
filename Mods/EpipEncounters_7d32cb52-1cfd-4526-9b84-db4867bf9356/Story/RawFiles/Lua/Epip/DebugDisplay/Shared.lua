
---@class Feature_DebugDisplay : Feature
local DebugDisplay = {
    ticks = {}, ---@type integer[] Tick tracker for current context.

    DEVELOPER_ONLY = true,
}
Epip.RegisterFeature("DebugDisplay", DebugDisplay)

---------------------------------------------
-- METHODS
---------------------------------------------

function DebugDisplay.AddTick()
    local now = Ext.Utils.MonotonicTime()

    table.insert(DebugDisplay.ticks, now)

    while #DebugDisplay.ticks > 0 and now - DebugDisplay.ticks[1] > 1000 do
        table.remove(DebugDisplay.ticks, 1)
    end
end