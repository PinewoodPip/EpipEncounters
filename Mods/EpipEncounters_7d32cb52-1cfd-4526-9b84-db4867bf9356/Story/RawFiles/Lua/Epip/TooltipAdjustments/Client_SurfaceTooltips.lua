
---------------------------------------------
-- Displays surface ownership, and hints regarding damage scaling.
---------------------------------------------

---@class Feature_TooltipAdjustments
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local TSK = TooltipAdjustments.TranslatedStrings
local TooltipLib = Client.Tooltip

---------------------------------------------
-- TSKS
---------------------------------------------

TSK.SurfaceTooltips_ScalingHint = TooltipAdjustments:RegisterTranslatedString("h6d7395dbgd11eg4fc2g8859gb3a903853b1c", {
    Text = "Damage scales only with character level.",
    ContextDescription = "Hint for surface tooltips",
})
TSK.SurfaceTooltips_OwnedBy = TooltipAdjustments:RegisterTranslatedString("h61ee7e1ag46beg4da5g9ba9g8763560995b6", {
    Text = "Owned by %s",
    ContextDescription = "Used in surface tooltips",
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---@type TooltipLib_FormattedTooltip
local pendingSurfaceTooltip = nil

-- Prevent surface tooltips, and re-render them once we've obtained extra surface data from the server.
Client.Tooltip.Hooks.RenderSurfaceTooltip:Subscribe(function (ev)
    local position = Ext.UI.GetPickingState().WalkablePosition

    if TooltipAdjustments.IsAdjustmentEnabled(TooltipAdjustments.Settings.SurfaceTooltips) then
        pendingSurfaceTooltip = ev.Tooltip

        Net.PostToServer("EPIPENCOUNTERS_GetSurfaceData", {
            Position = position,
            CharacterNetID = Client.GetCharacter().NetID,
        })
        ev:Prevent()
    end
end)
Net.RegisterListener("EPIPENCOUNTERS_ReturnSurfaceData", function(payload)
    if pendingSurfaceTooltip then
        local groundOwner
        local cloudOwner
        local dealsDamage = false

        -- Look for the first damage element - we will insert a dmg scaling hint before it.
        for elementType,_ in pairs(TooltipLib.SURFACE_DAMAGE_ELEMENT_TYPES) do
            local damageElements =  pendingSurfaceTooltip:GetElements(elementType)

            if #damageElements > 0 then
                dealsDamage = true
                break
            end
        end

        if payload.GroundSurfaceOwnerNetID then
            groundOwner = Character.Get(payload.GroundSurfaceOwnerNetID) or Item.Get(payload.GroundSurfaceOwnerNetID)
        end
        if payload.CloudSurfaceOwnerNetID then
            cloudOwner = Character.Get(payload.CloudSurfaceOwnerNetID) or Item.Get(payload.CloudSurfaceOwnerNetID)
        end

        if groundOwner then
            pendingSurfaceTooltip:InsertElement({Type = "Duration", Label = Text.Format(TSK.SurfaceTooltips_OwnedBy:GetString(), {FormatArgs = {groundOwner.DisplayName}})}, 3)
        end
        if cloudOwner then
            pendingSurfaceTooltip:InsertElement({Type = "Duration", Label = Text.Format(TSK.SurfaceTooltips_OwnedBy:GetString(), {FormatArgs = {cloudOwner.DisplayName}})}, #pendingSurfaceTooltip.Elements)
        end

        -- Also add a hint on how surface damage scales, only for surfaces that deal damage
        if (groundOwner or cloudOwner) and dealsDamage and EpicEncounters.IsEnabled() then
            pendingSurfaceTooltip:InsertBefore("Duration", {
                Type = "SurfaceDescription",
                Label = Text.Format(TSK.SurfaceTooltips_ScalingHint:GetString(), {FontType = Text.FONTS.ITALIC, Color = Color.LARIAN.LIGHT_GRAY})
            })
        end

        Client.Tooltip.ShowFormattedTooltip(Client.UI.TextDisplay:GetUI(), "Surface", pendingSurfaceTooltip)

        pendingSurfaceTooltip = nil
    end
end)

-- Remove the pending tooltip data when the tooltip is removed,
-- to prevent it from being rendered if the mouse was moved outside the surface
-- while the request was still being processed.
TooltipLib.Events.TooltipHidden:Subscribe(function (_)
    pendingSurfaceTooltip = nil
end)
