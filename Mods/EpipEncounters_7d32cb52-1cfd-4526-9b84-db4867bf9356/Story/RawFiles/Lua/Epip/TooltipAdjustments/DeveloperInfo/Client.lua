---------------------------------------------
-- Shows various technical details in tooltips useful for developers,
-- such as skill stat object IDs.
---------------------------------------------

local Tooltip = Client.Tooltip
local Input = Client.Input

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

-- Show item stat object IDs and tags while shift is held (since this information isn't needed as often).
Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local item = ev.Item
    local labels = {} ---@type string[]

    -- Show stats object ID.
    table.insert(labels, Text.Format("StatsId: %s", {
        FormatArgs = {item.StatsId},
    }))

    -- Show tags.
    local tags = item:GetTags()
    if tags[1] then
        table.insert(labels, Text.Format("Tags: %s", {
            FormatArgs = {Text.Join(tags, ", ")},
        }))
    else
        table.insert(labels, "No tags")
    end

    -- Add all labels as a single element, since the ordering of multiple engraving elements appears to be inconsistent.
    ev.Tooltip:InsertElement({
        Type = "Engraving",
        Label = Text.Format(Text.Join(labels, "<br>"), {Color = Color.LARIAN.GREEN}),
    })
end, {EnabledFunctor = Input.IsShiftPressed})

-- Show talent IDs in Talent tooltips.
Game.Tooltip.RegisterListener("Talent", nil, function(_, talentID, tooltip)
    table.insert(tooltip.Data, 1, {Type = "Engraving", Label = Text.Format("ID: %s", {FormatArgs = {talentID}, Color = Color.GREEN})})
end)
