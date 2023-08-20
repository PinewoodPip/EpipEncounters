
---@class Feature_TooltipAdjustments
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local TSK = TooltipAdjustments.TranslatedStrings

---------------------------------------------
-- TSK
---------------------------------------------

TSK.Setting_RewardGenerationWarning_Name = TooltipAdjustments:RegisterTranslatedString("ha0a0a085g359ag4f0dga54bgcf40d0f6af9d", {
    Text = "Display quest reward deltamod generation warning",
    ContextDescription = "Setting name",
})
TSK.Setting_RewardGenerationWarning_Description = TooltipAdjustments:RegisterTranslatedString("h72d280e5gde61g49bdgbbdbg7c6e6eec9dde", {
    Text = Text.Format("If enabled, the quest rewards screen will warn about deltamod generation only occuring afterwards.<br>%s", {
        FormatArgs = {
            {Text = "Applies only to EE.", Color = Color.LARIAN.YELLOW},
        },
    }),
    ContextDescription = "Setting tooltip",
})

---------------------------------------------
-- SETTINGS
---------------------------------------------

TooltipAdjustments.Settings.RewardGenerationWarning = TooltipAdjustments:RegisterSetting("RewardGenerationWarning", {
    Type = "Boolean",
    Name = TSK.Setting_RewardGenerationWarning_Name,
    Description = TSK.Setting_RewardGenerationWarning_Description,
    DefaultValue = true,
    RequiredMods = {Mod.GUIDS.EE_CORE},
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if TooltipAdjustments.IsAdjustmentEnabled(TooltipAdjustments.Settings.RewardGenerationWarning) and ev.UI:GetTypeId() == Ext.UI.TypeID.reward then
        ev.Tooltip:InsertAfter("ItemLevel", {
            Type = "PickpocketInfo",
            Label = Text.Format("Modifiers are added after you choose your reward.", {FontType = Text.FONTS.ITALIC})
        })
    end
end)