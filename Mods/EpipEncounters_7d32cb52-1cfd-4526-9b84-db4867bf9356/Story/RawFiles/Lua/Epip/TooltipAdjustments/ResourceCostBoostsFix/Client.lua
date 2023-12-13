
---------------------------------------------
-- Fixes APCostBoost and SPCostBoost not being reflected in skill and item tooltips.
---------------------------------------------

local TooltipLib = Client.Tooltip

---@class Features.TooltipAdjustments.ResourceCostBoostsFix : Feature
local ResourceCostsFix = {}
Epip.RegisterFeature("Features.TooltipAdjustments.ResourceCostBoostsFix", ResourceCostsFix)

---------------------------------------------
-- METHODS
---------------------------------------------

---Applies APCostBoost and SPCostBoost to corresponding elements within a tooltip.
---@param char EclCharacter
---@param tooltip TooltipLib_FormattedTooltip
function ResourceCostsFix._Apply(char, tooltip)
    local apCostBoost = Character.GetDynamicStat(char, "APCostBoost")
    local spCostBoost = Character.GetDynamicStat(char, "SPCostBoost")

    -- Apply APCostBoost
    local apCostElement = tooltip:GetFirstElement("SkillAPCost") or tooltip:GetFirstElement("ItemUseAPCost")
    if apCostElement and apCostElement.Value > 0 then -- 0 AP skills and items are not affected by AP cost boost.
        apCostElement.Value = math.max(0, apCostElement.Value + apCostBoost)
    end

    -- Apply SPCostBoost
    local spCostElement = tooltip:GetFirstElement("SkillMPCost") -- Items cannot have an SP cost.
    if spCostElement and spCostElement.Value > 0 then -- 0 SP skills are not affected by SP cost boost.
        spCostElement.Value = math.max(0, spCostElement.Value + spCostBoost)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Apply APCostBoost to skill and item tooltips.
TooltipLib.Hooks.RenderSkillTooltip:Subscribe(function (ev)
    ResourceCostsFix._Apply(ev.Character, ev.Tooltip)
end, {EnabledFunctor = ResourceCostsFix:GetEnabledFunctor()})
TooltipLib.Hooks.RenderItemTooltip:Subscribe(function (ev)
    ResourceCostsFix._Apply(Client.GetCharacter(), ev.Tooltip)
end, {EnabledFunctor = ResourceCostsFix:GetEnabledFunctor()})