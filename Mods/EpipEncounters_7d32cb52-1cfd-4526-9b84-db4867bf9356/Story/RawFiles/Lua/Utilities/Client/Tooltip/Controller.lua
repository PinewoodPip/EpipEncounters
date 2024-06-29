
local ExamineC = Client.UI.Controller.Examine

---@class TooltipLib
local Tooltip = Client.Tooltip
-- Controller UIs to handle tooltips for.
-- These are assumed to have the tooltip elements embedded or imported.
Tooltip.CONTROLLER_UIS = {
    ExamineC,
}

---@type {UICall:string, TooltipType:TooltipLib_TooltipType}[]
Tooltip.CONTROLLER_EXAMINE_TOOLTIP_TYPES = {
    {"selectStat", "Stat"},
    {"selectAbility", "Stat"}, -- TODO distinguish these as Ability
    -- {"selectTalent", "Talent"},
    -- {"selectTitle", "Title"},
    {"selectStatus", "Status"},
}

---------------------------------------------
-- EXAMINE UI
---------------------------------------------

-- Handle selection changing, upon which the tooltip is sent to the UI
-- ahead of the user choosing to display it.
for _,examineTooltipType in ipairs(Tooltip.CONTROLLER_EXAMINE_TOOLTIP_TYPES) do
    ExamineC:RegisterCallListener(examineTooltipType[1], function (ev, id)
        local char = ExamineC.GetCharacter()
        ---@type TooltipLib_TooltipSourceData
        local sourceData = {
            UIType = ev.UI:GetTypeId(),
            UICall = ev.Function,
            Type = examineTooltipType[2],
            FlashCharacterHandle = Ext.UI.HandleToDouble(char.Handle),
            IsFromGame = true,
            FlashStatusHandle = id,
            StatID = id,
            FlashParams = {id},
        }
        Tooltip.nextTooltipData = sourceData
    end)
end

---------------------------------------------
-- OTHER
---------------------------------------------

-- Handle controller formatted tooltips.
for _,ui in ipairs(Tooltip.CONTROLLER_UIS) do
    ui:RegisterInvokeListener("showFormattedTooltip", function (ev)
        Tooltip._HandleFormattedTooltip(ev, "tooltipArray", Tooltip.nextTooltipData)
    end)
end
