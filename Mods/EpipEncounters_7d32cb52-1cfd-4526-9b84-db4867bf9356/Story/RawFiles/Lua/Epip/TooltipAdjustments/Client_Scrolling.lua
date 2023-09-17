
local TooltipUI = Client.UI.Tooltip

---@class Feature_TooltipScrolling : Feature
local TooltipScrolling = {
    active = false,
    tooltipExists = false,
    originalTooltipPosition = {0, 0}, ---@type Vector2D

    ----@type table<string, TextLib_TranslatedString>
    TranslatedStrings = {
        Label_Enabled = {
           Handle = "h89b8939cga077g4a2egb700g3d22e477c3f6",
           Text = "Tooltip scrolling enabled.",
           ContextDescription = "Shown when enabling scrolling",
        },
        Label_Disabled = {
           Handle = "h53c5d893gb6f2g4e4bg94aega9462369df7d",
           Text = "Tooltip scrolling disabled.",
           ContextDescription = "Shown when disabling scrolling.",
        },
    },

    INPUT_ACTION = "EpipEncounters_ScrollTooltip",
    SCROLLING_STEP = 40,
}
Epip.RegisterFeature("TooltipScrolling", TooltipScrolling)
local TSK = TooltipScrolling.TranslatedStrings

---------------------------------------------
-- METHODS
---------------------------------------------

---@param active boolean
---@param notify boolean?
function TooltipScrolling.Toggle(active, notify)
    if active ~= TooltipScrolling.active then
        Client.UI.Input.SetMouseWheelBlocked(active) -- We do not block the mouse wheel motion directly as that breaks the middle click events from firing, apparently - and this is the default binding for this feature.

        if notify then
            local message = active and TSK.Label_Enabled:GetString() or TSK.Label_Disabled:GetString()
            Client.UI.Notification.ShowNotification(message)
        end

        if active then
            TooltipScrolling.originalTooltipPosition = Vector.Create(TooltipUI:GetPosition())

            TooltipUI:ExternalInterfaceCall("keepUIinScreen", false)
        elseif TooltipScrolling.tooltipExists then
            TooltipUI:GetUI():SetPosition(table.unpack(TooltipScrolling.originalTooltipPosition))

            TooltipUI:ExternalInterfaceCall("keepUIinScreen", true)
        end

        TooltipScrolling.active = active
    end
end

function TooltipScrolling.IsActive()
    return TooltipScrolling.active and TooltipScrolling.tooltipExists
end

-- This feature is disabled if TooltipAdjustments is disabled.
function TooltipScrolling:IsEnabled()
    return _Feature.IsEnabled(self) and Epip.GetFeature("EpipEncounters", "TooltipAdjustments"):IsEnabled()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.Input.Events.KeyPressed:Subscribe(function (ev)
    if (ev.InputID == "wheel_ypos" or ev.InputID == "wheel_yneg") and TooltipScrolling.IsActive() then
        local offset = TooltipScrolling.SCROLLING_STEP
        if ev.InputID == "wheel_yneg" then offset = -offset end

        local x, y = TooltipUI:GetPosition()
        TooltipUI:GetUI():SetPosition(x, y + offset)

        TooltipScrolling:DebugLog("Scrolling tooltip", ev.InputID)
    end
end)

-- Listen for tooltips being created; this listener is fired as late as possible to check if any other listeners has chosen to block the tooltip.
TooltipUI:RegisterInvokeListener("addFormattedTooltip", function (_)
    TooltipScrolling.tooltipExists = true

    TooltipScrolling:DebugLog("Tooltip now exists")

    -- It's possible for a tooltip to be rendered without removeTooltip being called for a previous one.
    if TooltipScrolling.IsActive() then
        TooltipScrolling.Toggle(false, false)
    end
end)

TooltipUI:RegisterInvokeListener("removeTooltip", function (_)
    TooltipScrolling.tooltipExists = false
    TooltipScrolling.Toggle(false, false)

    TooltipScrolling:DebugLog("Tooltip now removed")
end)

Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == TooltipScrolling.INPUT_ACTION and TooltipScrolling.tooltipExists and TooltipScrolling:IsEnabled() then
        TooltipScrolling.Toggle(not TooltipScrolling.IsActive(), true)
    end
end)