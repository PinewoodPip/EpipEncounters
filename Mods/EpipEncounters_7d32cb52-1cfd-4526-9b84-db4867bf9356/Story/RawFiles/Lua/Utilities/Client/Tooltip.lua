
local TextDisplay = Client.UI.TextDisplay

---@class TooltipLib : Feature
local Tooltip = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        RenderFormattedTooltip = {}, ---@type SubscribableEvent<TooltipLib_Hook_RenderFormattedTooltip>
    },
}
Client.Tooltip = Tooltip
Epip.InitializeLibrary("TooltipLib", Tooltip)

---@alias TooltipLib_FormattedTooltipType "Surface"
---@alias TooltipLib_Element table See `Game.Tooltip`. TODO

---@class TooltipLib_FormattedTooltip
---@field Elements TooltipLib_Element[]
local _FormattedTooltip = {}

---@param element TooltipLib_Element
---@param index integer? Defaults to next index.
function _FormattedTooltip:InsertElement(element, index)
    table.insert(self.Elements, index or #self.Elements + 1, element)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---@class TooltipLib_Hook_RenderFormattedTooltip
---@field Type TooltipLib_FormattedTooltipType
---@field Tooltip TooltipLib_FormattedTooltip Hookable.
---@field UI UIObject
---@field Prevented boolean Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui UIObject
---@param tooltipType TooltipLib_FormattedTooltipType
---@param tooltip TooltipLib_FormattedTooltip
function Tooltip.ShowFormattedTooltip(ui, tooltipType, tooltip)
    local root = ui:GetRoot()

    if tooltipType == "Surface" then
        local originalTbl = Game.Tooltip.ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, "tooltipArray"))
        local newTable = Game.Tooltip.EncodeTooltipArray(tooltip.Elements)

        Game.Tooltip.ReplaceTooltipArray(ui, "tooltipArray", newTable, originalTbl)

        root.displaySurfaceText(Client.GetMousePosition())
    end
end

---@param ui UIObject
---@param tooltipType TooltipLib_FormattedTooltipType
---@param data TooltipLib_Element[]
---@return TooltipLib_Hook_RenderFormattedTooltip
function Tooltip._SendFormattedTooltipHook(ui, tooltipType, data)
    local obj = {Elements = data} ---@type TooltipLib_FormattedTooltip
    Inherit(obj, _FormattedTooltip)

    ---@type TooltipLib_Hook_RenderFormattedTooltip
    local hook = {
        Type = tooltipType,
        Tooltip = obj,
        UI = ui,
        Prevented = false,
    }

    Tooltip.Hooks.RenderFormattedTooltip:Throw(hook)

    return hook
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for surface tooltips from TextDisplay.
-- TODO place dummy values.
TextDisplay:RegisterInvokeListener("displaySurfaceText", function(ev, _, _)
    local ui = ev.UI
    local arrayFieldName = "tooltipArray"

    local tbl = Game.Tooltip.ParseTooltipArray(Game.Tooltip.TableFromFlash(ui, "tooltipArray"))

    local hook = Tooltip._SendFormattedTooltipHook(ui, "Surface", tbl)

    if not hook.Prevented then
        local newTable = Game.Tooltip.EncodeTooltipArray(hook.Tooltip.Elements)

        Game.Tooltip.ReplaceTooltipArray(ui, arrayFieldName, newTable, tbl)
    else
        ev:PreventAction()
    end
end)