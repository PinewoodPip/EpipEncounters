
---------------------------------------------
-- Display +X-type damage delatmods as Extra Properties in tooltips.
---------------------------------------------

---@class Feature_TooltipAdjustments
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local TSK = TooltipAdjustments.TranslatedStrings

TSK.DamageTypeDeltamods_WeaponDamage = TooltipAdjustments:RegisterTranslatedString("h37cf1748g9dafg4d2ag9744g00e75e764ee5", {
    Text = "+%s%% Weapon %s Damage",
    ContextDescription = "Tooltip for weapon elemental damage boost",
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    local item = ev.Item

    if TooltipAdjustments.IsAdjustmentEnabled(TooltipAdjustments.Settings.DamageTypeDeltamods) and item.Stats and item.Stats.IsIdentified and Item.IsWeapon(item) then
        local damageBoosts = {} ---@type {Type:string, Value:number}[]

        -- Look for +damage deltamods.
        for _,deltamodID in ipairs(item:GetDeltaMods()) do
            local deltamodStat = Stats.Get("DeltaModifier", deltamodID)
            local dmgType, amount = nil, nil

            for _,boost in ipairs(deltamodStat.Boosts) do
                -- Not sure if Count field is used for anything.
                local boostStat = Stats.Get("Boost", boost.Boost) ---@type StatsLib_StatsEntry_Weapon

                if boostStat["Damage Type"] ~= "None" then
                    dmgType = boostStat["Damage Type"]
                    amount = boostStat.DamageFromBase
                end
            end

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

        -- Insert tooltip elements for each damage type
        for _,boost in ipairs(damageBoosts) do
            local damageTypeDef = Damage.GetDamageTypeDefinition(boost.Type)

            if damageTypeDef then
                TooltipAdjustments:DebugLog("Inserting +damage tooltip")
                TooltipAdjustments:Dump(boost)
    
                ev.Tooltip:InsertElement({
                    Type = "ExtraProperties",
                    Label = Text.Format(TooltipAdjustments.TranslatedStrings.DamageTypeDeltamods_WeaponDamage:GetString(), {
                        FormatArgs = {
                            boost.Value, Text.GetTranslatedString(damageTypeDef.NameHandle, damageTypeDef.StringID)
                        }
                    })
                })
            else
                TooltipAdjustments:LogWarning("Unknown damage type " .. boost.Type)
            end
        end
    end
end)