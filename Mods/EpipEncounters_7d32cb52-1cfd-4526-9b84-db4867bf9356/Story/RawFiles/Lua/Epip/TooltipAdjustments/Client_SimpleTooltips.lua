
---------------------------------------------
-- Makes the delay of simple tooltips configurable.
---------------------------------------------

local TooltipLib = Client.Tooltip
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")

TooltipAdjustments.SIMPLE_TOOLTIP_WORLD_DELAY_SETTING = "Tooltip_SimpleTooltipDelay_World"
TooltipAdjustments.SIMPLE_TOOLTIP_UI_DELAY_SETTING = "Tooltip_SimpleTooltipDelay_UI"

local currentTimer = nil ---@type TimerLib_Entry

local function CancelTimer()
    if currentTimer and not currentTimer:IsFinished() then
        currentTimer:Cancel()
        currentTimer = nil
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

TooltipLib.Hooks.RenderSimpleTooltip:Subscribe(function (ev)
    local settingID = TooltipAdjustments.SIMPLE_TOOLTIP_WORLD_DELAY_SETTING

    if TooltipAdjustments:IsEnabled() then
        -- We assume context based on this variable.
        if ev.Tooltip.TooltipStyle == "Simple" then
            settingID = TooltipAdjustments.SIMPLE_TOOLTIP_UI_DELAY_SETTING
        end
    
        local delay = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", settingID)

        ev.Tooltip.UseDelay = false

        -- Cancel current rescheduled tooltip, if any.
        if currentTimer and not currentTimer:IsFinished() then
            currentTimer:Cancel()
            currentTimer = nil
        end

        -- Reschedule tooltip call.
        if delay > 0 then
            ev:Prevent()

            currentTimer = Timer.Start(delay, function (_)
                TooltipLib.ShowSimpleTooltip(ev.Tooltip)
            end)
        end
    end
end)

-- Remove our rescheduled tooltip if a tooltip removal occurs. 
Ext.Events.UICall:Subscribe(function (ev)
    if ev.Function == "hideTooltip" then
        CancelTimer()
    end
end)
Client.UI.Tooltip:RegisterInvokeListener("removeTooltip", function (_)
    CancelTimer()
end)