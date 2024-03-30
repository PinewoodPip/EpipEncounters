
local Tooltip = Client.Tooltip

---@type Feature
local AprilFoolsTooltips = {
    TranslatedStrings = {
        Label_GaleConsumable = {
            Handle = "h1ca15e96g0bf6g4ba6gaa64g1dec7a28d3af",
            Text = "Gale can absorb this item's magic, destroying it.",
            ContextDescription = [[April Fools tooltip for unique items; "Gale" refers to the Baldur's Gate 3 character]],
        },
    },
}
Epip.RegisterFeature("Features.TooltipAdjustments.AprilFools", AprilFoolsTooltips)
local TSK = AprilFoolsTooltips.TranslatedStrings

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

GameState.Events.ClientReady:Subscribe(function (_)
    if Epip.IsAprilFools() then
        -- Append Gale hint to unique and Artifact items.
        Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
            local item = ev.Item
            if Item.IsArtifact(item) or Item.IsUnique(item) then
                ev.Tooltip:InsertElement({
                    Type = "StatMEMSlot",
                    Label = TSK.Label_GaleConsumable:GetString(),
                })
            end
        end)
    end
end)

