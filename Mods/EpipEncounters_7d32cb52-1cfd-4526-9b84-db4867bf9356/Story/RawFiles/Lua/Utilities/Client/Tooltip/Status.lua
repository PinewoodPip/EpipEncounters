
---------------------------------------------
-- Support for status tooltips.
---------------------------------------------

---@class TooltipLib
local Tooltip = Client.Tooltip

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class TooltipLib.FormattedTooltip.Status.CreationOptions
---@field Position Vector2D? Defaults to mouse position.
---@field Align ("right"|"left"|"bottom"|"top"|"")? Using empty string or any other invalid value will position the tooltip on the bottom-right of the position. Defaults to empty string.

---------------------------------------------
-- METHODS
---------------------------------------------

---Shows a tooltip for a status.
---@param status EclStatus
---@param options TooltipLib.FormattedTooltip.Status.CreationOptions? If not present, default values of the class will be used.
function Tooltip.ShowStatusTooltip(status, options)
    options = options or {}
    local ui = Tooltip._GetDefaultCustomTooltipUI()
    local mouseX, mouseY = Client.GetMousePosition()
    local position = options.Position or Vector.Create(mouseX, mouseY)

    ui:ExternalInterfaceCall("showStatusTooltip", Client.Flash.ToFlashHandle(status.OwnerHandle), Client.Flash.ToFlashHandle(status.StatusHandle), position[1], position[2], 0, 0, options.Align or "") -- Offset can be applied onto Position instead.
end