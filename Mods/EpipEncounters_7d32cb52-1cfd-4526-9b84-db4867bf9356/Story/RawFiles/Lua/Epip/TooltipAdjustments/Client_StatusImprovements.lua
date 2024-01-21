
---------------------------------------------
-- Displays extra information within status tooltips:
-- - Status source (including from items)
-- - Flanker count for FLANKED
-- - Status Type (in developer mode)
-- Additionally, allows centering the camera to the status source by left-clicking while a status tooltip is visible.
---------------------------------------------

local TooltipLib = Client.Tooltip
local Input = Client.Input

local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local TSK = TooltipAdjustments.TranslatedStrings

---------------------------------------------
-- TRANSLATED STRINGS
---------------------------------------------

TSK.StatusImprovements_AppliedBy = TooltipAdjustments:RegisterTranslatedString("h35bb3fefg60e1g4498gba12g4b44112b6239", {
    Text = "Applied by %s",
    ContextDescription = "Tooltip for statuses with a source character",
})
TSK.StatusImprovements_FromItem = TooltipAdjustments:RegisterTranslatedString("h688e725agb3f5g4adega349g0df981cfab97", {
    Text = "From item: %s",
    ContextDescription = "Tooltip for statuses from an equipped item",
})

TSK.Adjustment_StatusImprovements_Name = TooltipAdjustments:RegisterTranslatedString("h0ef05becgc584g447agaa9cg797786d46dcf", {
    Text = "Show status source",
    ContextDescription = "Setting name",
})
TSK.Adjustment_StatusImprovements_Description = TooltipAdjustments:RegisterTranslatedString("h2095b033g942eg400agb596g45d9ba3294c7", {
    Text = "If enabled, status tooltips will show the name of the character that applied the status, if any. Also allows you to click statuses to center the camera on the source character.",
    ContextDescription = "Setting tooltip",
})

TSK.Adjustment_StatusImprovements_FlankedEnemyCount = TooltipAdjustments:RegisterTranslatedString("hd2f56e74gcb60g4d26g9243g0a44a26672c2", {
    Text = "Flanked by %s enemies.",
    ContextDescription = "Tooltip for Flanked status",
})

---------------------------------------------
-- SETTINGS
---------------------------------------------

TooltipAdjustments.Settings.StatusImprovements = TooltipAdjustments:RegisterSetting("StatusImprovements", {
    Type = "Boolean",
    Name = TSK.Adjustment_StatusImprovements_Name,
    Description = TSK.Adjustment_StatusImprovements_Description,
    DefaultValue = true,
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show status source (character and item).
TooltipLib.Hooks.RenderStatusTooltip:Subscribe(function (ev)
    if not TooltipAdjustments.IsAdjustmentEnabled(TooltipAdjustments.Settings.StatusImprovements) then return end
    local source = Character.Get(ev.Status.StatusSourceHandle)
    local statusesFromItems = Character.GetStatusesFromItems(ev.Character)
    local tooltip = ev.Tooltip

    if source then
        local text = Text.Format(TSK.StatusImprovements_AppliedBy:GetString(), {
            FormatArgs = {source.DisplayName},
            FontType = Text.FONTS.ITALIC,
            Color = Color.LARIAN.LIGHT_GRAY,
        })
        local elements = tooltip:GetElements("StatusDescription")
        local element = elements[#elements] -- Append to the last description (usually the duration text)

        if not element then
            tooltip:InsertElement({
                Type = "StatusDescription",
                Label = text,
            })
        else
            element.Label = element.Label .. "<br>" .. text
        end
    end

    -- Check if the status is from an equipped item
    for _,entry in ipairs(statusesFromItems) do
        if entry.Status == ev.Status then
            local addendum = Text.Format(TSK.StatusImprovements_FromItem:GetString(), {
                FormatArgs = {entry.ItemSource.DisplayName},
                FontType = Text.FONTS.ITALIC,
                Color = Color.LARIAN.LIGHT_GRAY,
            })

            local elements = tooltip:GetElements("StatusDescription")
            local element = elements[#elements] -- Append to the last description (usually the duration text)

            if not element then
                tooltip:InsertElement({
                    Type = "StatusDescription",
                    Label = addendum,
                })
            else
                element.Label = element.Label .. "<br>" .. addendum
            end
        end
    end
end)

-- Center camera on the source of a status when a status element is clicked.
Input.Events.MouseButtonPressed:Subscribe(function (ev)
    if not TooltipAdjustments.IsAdjustmentEnabled(TooltipAdjustments.Settings.StatusImprovements) then return end
    if ev.InputID == "left2" then
        local currentTooltip = TooltipLib.GetCurrentTooltipSourceData()
        if currentTooltip and currentTooltip.Type == "Status" then
            local char = Character.Get(currentTooltip.FlashCharacterHandle, true)
            local statusHandle = Ext.UI.DoubleToHandle(currentTooltip.FlashStatusHandle)
            local status = Character.GetStatusByHandle(char, statusHandle)
            local sourceChar = Ext.Utils.IsValidHandle(status.StatusSourceHandle) and Character.Get(status.StatusSourceHandle) or nil

            if sourceChar then
                Client.UI.PlayerInfo:ExternalInterfaceCall("centerCamOnCharacter", Ext.UI.HandleToDouble(sourceChar.Handle))
            end
        end
    end
end)

-- Show amount of flankers for the FLANKED status.
TooltipLib.Hooks.RenderStatusTooltip:Subscribe(function (ev)
    if ev.Status.StatusType == "FLANKED" then
        local char = ev.Character
        ev.Tooltip:InsertElement({
            Type = "StatusDescription",
            Label = TSK.Adjustment_StatusImprovements_FlankedEnemyCount:Format(char.Stats.Flanked)
        })
    end
end)

-- Show status object information in dev mode.
TooltipLib.Hooks.RenderStatusTooltip:Subscribe(function (ev)
    if Epip.IsDeveloperMode() then
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
    end
end)
