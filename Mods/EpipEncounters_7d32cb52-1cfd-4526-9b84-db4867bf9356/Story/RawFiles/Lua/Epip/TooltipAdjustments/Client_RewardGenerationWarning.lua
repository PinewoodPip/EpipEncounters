
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if TooltipAdjustments:IsEnabled() and ev.UI:GetTypeId() == Client.UI.Reward.TypeID then
        ev.Tooltip:InsertAfter("ItemLevel", {
            Type = "PickpocketInfo",
            Label = Text.Format("Modifiers are added after you choose your reward.", {FontType = Text.FONTS.ITALIC})
        })
    end
end)