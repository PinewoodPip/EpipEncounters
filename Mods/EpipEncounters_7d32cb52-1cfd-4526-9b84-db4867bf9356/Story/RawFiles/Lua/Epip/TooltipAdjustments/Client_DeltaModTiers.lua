
local DeltaMods = EpicEncounters.DeltaMods
local Tooltip = Client.Tooltip

---------------------------------------------
-- Displays tiers of EE deltamods in tooltips.
---------------------------------------------

---@class Feature_TooltipAdjustments
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")

---------------------------------------------
-- METHODS
---------------------------------------------

---Adds deltamod tiers display to a tooltip.
---@param item EclItem
---@param tooltip TooltipLib_FormattedTooltip
function TooltipAdjustments._AddDeltamodTiersToTooltip(item, tooltip)
    local groups = DeltaMods.GetItemDeltaMods(item, "Any")

    -- Add tooltip entries for each deltamod
    for _,mod in pairs(groups) do
        local groupTiersCount = mod.GroupDefinition:GetTiersCount()
        local label = Text.Format("%s +%s (Max %s; Tier %s/%s)", {
            FormatArgs = {
                mod.ChildModID or mod.GroupDefinition.Name,
                mod.Value,
                mod.GroupDefinition.Values[groupTiersCount],
                mod.Tier,
                groupTiersCount,
            }
        })
        local element = {
            Type = "Engraving",
            Label = label,
        }

        tooltip:InsertElement(element)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Add tier display to item tooltips when shift is held.
Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local item = ev.Item

    if TooltipAdjustments:IsEnabled() and Client.Input.IsShiftPressed() and Item.IsEquipment(item) and EpicEncounters.IsEnabled() then
        TooltipAdjustments._AddDeltamodTiersToTooltip(item, ev.Tooltip)
    end
end)