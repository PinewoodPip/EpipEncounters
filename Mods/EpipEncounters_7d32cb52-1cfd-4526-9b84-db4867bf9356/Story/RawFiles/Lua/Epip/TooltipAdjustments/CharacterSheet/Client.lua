
---------------------------------------------
-- Various adjustments for Character Sheet tooltips.
---------------------------------------------

local Tooltip = Client.Tooltip

---@type Feature
local CharacterSheet = {}
Epip.RegisterFeature("Features.TooltipAdjustments.CharacterSheet", CharacterSheet)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Remove "From X: +0%" lines, common in EE (ex. damage tooltip with Guerrilla).
Tooltip.Hooks.RenderStatTooltip:Subscribe(function (ev)
    local maluses = ev.Tooltip:GetElements("StatsPercentageMalus")
    for i=#maluses,1,-1 do
        local malus = maluses[i]
        if malus.Label:find("+0%%") then
            ev.Tooltip:RemoveElement(malus)
        end
    end
end)
