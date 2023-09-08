
---------------------------------------------
-- Removes empty ItemRequirement tooltip elements.
---------------------------------------------

local Tooltip = Client.Tooltip

---@type Feature
local RequirementFix = {}
Epip.RegisterFeature("Features.TooltipAdjustments.EmptyItemRequirementFix", RequirementFix)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if RequirementFix:IsEnabled() then
        local itemRequirements = ev.Tooltip:GetElements("ItemRequirement")
        for _,element in ipairs(itemRequirements) do
            if element.Label == "" then
                ev.Tooltip:RemoveElement(element) -- Slightly inefficient due to extra iterations, but not a critical concern.
            end
        end
    end
end)