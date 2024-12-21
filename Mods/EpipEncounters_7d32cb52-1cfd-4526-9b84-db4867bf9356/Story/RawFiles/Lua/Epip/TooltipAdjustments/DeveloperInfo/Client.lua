---------------------------------------------
-- Shows various technical details in tooltips useful for developers,
-- such as skill stat object IDs.
---------------------------------------------

local Tooltip = Client.Tooltip

---@type Feature
local DeveloperInfo = {}
Epip.RegisterFeature("Features.TooltipAdjustments.DeveloperInfo", DeveloperInfo)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show skill IDs in skill tooltips.
Tooltip.Hooks.RenderSkillTooltip:Subscribe(function (ev)
    ev.Tooltip:InsertElement({
        Type = "Engraving",
        Label = Text.Format("StatsId: %s", {
            FormatArgs = {ev.SkillID},
            Color = Color.LARIAN.GREEN,
        })
    })
end)

-- Show status IDs and types in status tooltips.
Tooltip.Hooks.RenderStatusTooltip:Subscribe(function (ev)
    ev.Tooltip:InsertElement({
        Type = "Engraving",
        Label = Text.Format("StatusId: %s<br>StatusType: %s", {
            FormatArgs = {
                ev.Status.StatusId,
                ev.Status.StatusType,
            },
            Color = Color.LARIAN.GREEN,
        })
    })
end)

-- Show talent IDs in Talent tooltips.
Game.Tooltip.RegisterListener("Talent", nil, function(_, talentID, tooltip)
    table.insert(tooltip.Data, 1, {Type = "Engraving", Label = Text.Format("ID: %s", {FormatArgs = {talentID}, Color = Color.GREEN})})
end)
