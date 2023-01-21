
---------------------------------------------
-- Displays surface ownership, and hints regarding damage scaling.
---------------------------------------------

local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local TooltipLib = Client.Tooltip

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
            pendingSurfaceTooltip:InsertElement({Type = "Duration", Label = Text.Format("Owned by %s", {FormatArgs = {groundOwner.DisplayName}})}, 3)
        end
        if cloudOwner then
            pendingSurfaceTooltip:InsertElement({Type = "Duration", Label = Text.Format("Owned by %s", {FormatArgs = {cloudOwner.DisplayName}})}, #pendingSurfaceTooltip.Elements)
        end

        -- Also add a hint on how surface damage scales
        if (groundOwner or cloudOwner) and dealsDamage then
            pendingSurfaceTooltip:InsertBefore("Duration", {
                Type = "SurfaceDescription",
                Label = Text.Format("Damage scales only with character level.", {FontType = Text.FONTS.ITALIC, Color = Color.LARIAN.LIGHT_GRAY})
            })
        end

        Client.Tooltip.ShowFormattedTooltip(Client.UI.TextDisplay:GetUI(), "Surface", pendingSurfaceTooltip)

        pendingSurfaceTooltip = nil
    end
end)