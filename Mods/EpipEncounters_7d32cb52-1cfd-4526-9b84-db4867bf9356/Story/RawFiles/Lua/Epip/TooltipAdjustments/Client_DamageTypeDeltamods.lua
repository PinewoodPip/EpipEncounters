
---------------------------------------------
-- Display +X-type damage delatmods as Extra Properties in tooltips.
---------------------------------------------

---@class Feature_TooltipAdjustments
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
TooltipAdjustments.WEAPON_DAMAGE_BOOST_PATTERN = "^Boost_Weapon_Damage_(.+)_(%d+)$"

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local item = ev.Item

    if TooltipAdjustments.IsAdjustmentEnabled(TooltipAdjustments.Settings.DamageTypeDeltamods) and item.Stats and item.Stats.IsIdentified then
        local damageBoosts = {} ---@type {Type:string, Value:number}[]

        -- Look for +damage deltamods.
        for _,deltamodID in ipairs(item:GetDeltaMods()) do
            local dmgType, amount = deltamodID:match(TooltipAdjustments.WEAPON_DAMAGE_BOOST_PATTERN)

            if dmgType and amount then
                local alreadyHadType = false
                for _,boost in ipairs(damageBoosts) do
                    if boost.Type == dmgType then
                        boost.Value = math.max(boost.Value, amount) -- Keep highest value.
                        alreadyHadType = true
                    end
                end

                if not alreadyHadType then
                    table.insert(damageBoosts, {Type = dmgType, Value = amount})
                end
            end
        end

        for _,boost in ipairs(damageBoosts) do
            TooltipAdjustments:DebugLog("Inserting +damage tooltip")
            TooltipAdjustments:Dump(boost)

            ev.Tooltip:InsertElement({
                Type = "ExtraProperties",
                Label = Text.Format("+%s%% Weapon %s Damage", {
                    FormatArgs = {
                        boost.Value, boost.Type -- TODO localize dmg type name
                    }
                })
            })
        end
    end
end)