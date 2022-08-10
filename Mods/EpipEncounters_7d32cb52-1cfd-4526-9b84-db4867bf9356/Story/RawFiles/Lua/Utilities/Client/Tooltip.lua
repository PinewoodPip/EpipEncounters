
local TextDisplay = Client.UI.TextDisplay

---@class TooltipLib : Feature
local Tooltip = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        RenderFormattedTooltip = {}, ---@type SubscribableEvent<TooltipLib_Hook_RenderFormattedTooltip>
    },
}
Epip.InitializeLibrary("TooltipLib", Tooltip)

---@alias TooltipLib_FormattedTooltipType "Surface"
---@alias TooltipLib_Element table See `Game.Tooltip`. TODO

---@class TooltipLib_FormattedTooltip
---@field Elements TooltipLib_Element[]
local _FormattedTooltip = {}

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---@class TooltipLib_Hook_RenderFormattedTooltip
---@field Type TooltipLib_FormattedTooltipType
---@field Tooltip TooltipLib_FormattedTooltip Hookable.
---@field UI UIObject

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui UIObject
---@param tooltipType TooltipLib_FormattedTooltipType
---@param data TooltipLib_Element[]
---@return TooltipLib_FormattedTooltip
function Tooltip._SendFormattedTooltipHook(ui, tooltipType, data)
    local obj = {Elements = data} ---@type TooltipLib_FormattedTooltip
    Inherit(obj, _FormattedTooltip)

    ---@type TooltipLib_FormattedTooltip
    local hook = {
        Type = tooltipType,
        Tooltip = obj,
        UI = ui,
    }

    Tooltip.Hooks.RenderFormattedTooltip:Throw(hook)

    return hook.Tooltip
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for surface tooltips.
-- TODO place dummy values.
TextDisplay:RegisterInvokeListener("displaySurfaceText", function(ev, _, _)
    local ui = ev.UI
    local arrayFieldName = "tooltipArray"

    local tbl = Game.Tooltip.ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, "tooltipArray"))

    local formattedTooltip = Tooltip._SendFormattedTooltipHook(ui, "Surface", tbl)
    local newTable = Game.Tooltip.EncodeTooltipArray(formattedTooltip.Elements)

    Game.Tooltip.ReplaceTooltipArray(ui, arrayFieldName, newTable, tbl)
end)