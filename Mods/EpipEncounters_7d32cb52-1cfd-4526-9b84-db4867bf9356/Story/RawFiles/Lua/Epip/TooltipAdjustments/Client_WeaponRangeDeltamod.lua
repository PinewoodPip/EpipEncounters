
---------------------------------------------
-- Displays weapon range deltamods in tooltips.
---------------------------------------------

---@class Feature_TooltipAdjustments
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
TooltipAdjustments.WEAPON_RANGE_DELTAMOD_PATTERN = "Boost_Weapon_Range_(.*)$"

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show range deltamods as an ExtraProperty
Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local item = ev.Item

    if item.Stats and item.Stats.IsIdentified then
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
                Label = string.format("+%sm Weapon Range", weaponBoostString) 
            })

            -- Reflect the addition in the weapon range label
            local element = ev.Tooltip:GetFirstElement("WeaponRange")
            if element then
                local amount = element.Value:gsub("m", "")
                ---@diagnostic disable cast-local-type
                amount = tonumber(amount)
                amount = amount - (weaponRangeBoostValue / 100)
                ---@diagnostic enable cast-local-type
    
                element.Value = string.format("%sm + %sm", Text.RemoveTrailingZeros(amount), weaponBoostString)
            end
        end
    end
end)