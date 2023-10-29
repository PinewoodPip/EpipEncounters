
---------------------------------------------
-- Displays weapon range deltamods in tooltips.
---------------------------------------------

---@class Feature_TooltipAdjustments
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
TooltipAdjustments.WEAPON_RANGE_DELTAMOD_PATTERN = "Boost_Weapon_Range_(.*)$"

local WeaponRangeBoostTSK = TooltipAdjustments:RegisterTranslatedString("h56298a9agd232g45d3ga079g28bedb59e95d", {
    Text = "+%sm Weapon Range",
    ContextDescription = "Tooltip for boost. First parameter is range in meters",
})
local TotalWeaponRangeTSK = TooltipAdjustments:RegisterTranslatedString("hb7c72307g365dg4b59g9cf2gf9c9093d2ec3", {
    Text = "%sm + %sm",
    ContextDescription = "Range indicator at the bottom of the tooltip. Params are base weapon range and boosted range from the deltamod",
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show range deltamods as an ExtraProperty
Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local item = ev.Item

    if TooltipAdjustments.IsAdjustmentEnabled(TooltipAdjustments.Settings.WeaponRangeDeltamods) and item.Stats and Item.IsIdentified(item) then
        local weaponRangeBoostValue = 0;

        for _,deltaModName in pairs(item:GetDeltaMods()) do
            local match = deltaModName:match(TooltipAdjustments.WEAPON_RANGE_DELTAMOD_PATTERN)

            if match then
                local value = tonumber(match)

                -- We keep the highest value, as per deltamod behaviour of max(a, b)
                if value > weaponRangeBoostValue then
                    weaponRangeBoostValue = value
                end
            end
        end

        if weaponRangeBoostValue > 0 then
            TooltipAdjustments:DebugLog("Found item with boosted weapon range")

            -- weapon range is in centimeters within stats
            local weaponBoostString = Text.RemoveTrailingZeros(weaponRangeBoostValue / 100)

            -- Add Extra Properties display
            ev.Tooltip:InsertElement({
                Type = "ExtraProperties",
                Label = WeaponRangeBoostTSK:Format(weaponBoostString)
            })

            -- Reflect the addition in the weapon range label
            local element = ev.Tooltip:GetFirstElement("WeaponRange")
            if element then
                local amount = element.Value:gsub("m", "")
                ---@diagnostic disable cast-local-type
                amount = tonumber(amount)
                amount = amount - (weaponRangeBoostValue / 100)
                ---@diagnostic enable cast-local-type

                element.Value = TotalWeaponRangeTSK:Format(Text.RemoveTrailingZeros(amount), weaponBoostString)
            end
        end
    end
end)