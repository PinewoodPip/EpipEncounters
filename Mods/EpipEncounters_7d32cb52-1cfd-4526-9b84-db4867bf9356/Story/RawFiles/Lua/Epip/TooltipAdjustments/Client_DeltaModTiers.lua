
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
    local mods = item:GetDeltaMods()
    local groups = {} ---@type table<string, {Group: EpicEncounters_DeltaModsLib_DeltaModGroupDefinition, Value: integer}>
    for _,mod in ipairs(mods) do
        local group, level = DeltaMods.GetGroupDefinitionForMod(item, mod)

        if group then
            local groupName = group.Name
            
            if groups[groupName] and level > groups[groupName].Value then
                groups[groupName] = {
                    Group = group,
                    Value = level,
                }
            elseif groups[groupName] == nil then
                groups[groupName] = {
                    Group = group,
                    Value = level,
                }
            end
        end
    end

    for _,mod in pairs(groups) do
        local groupTiersCount = mod.Group:GetTiersCount()
        local label = Text.Format("%s +%s (Max %s; Tier %s/%s)", {
            FormatArgs = {
                mod.Group.Name,
                mod.Value,
                mod.Group.Values[groupTiersCount],
                mod.Group:GetTierForValue(mod.Value),
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