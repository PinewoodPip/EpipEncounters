
---------------------------------------------
-- Pre-made activation conditions for Epic Enemies effects.
---------------------------------------------

local Conditions = {

}
Epip.AddFeature("EpicEnemiesEffectConditions", "EpicEnemiesEffectConditions", Conditions)

local EpicEnemies = Epip.Features.EpicEnemies

---@class EpicEnemiesCondition_TurnStart : EpicEnemiesActivationCondition
---@field Round integer Which round to activate the effect on.
---@field Repeat boolean Whether to re-activate the effect on subsequent rounds as well.
---@field RepeatFrequency uint64? How many turns must pass between re-activations if Repeat is true. Defaults to 1.

---@class EpicEnemiesCondition_HealthThreshold : EpicEnemiesActivationCondition
---@field Vitality number From 0-1. Use 0 to ignore this health metric.
---@field PhysicalArmor number From 0-1. Use 0 to ignore this health metric.
---@field MagicArmor number From 0-1. Use 0 to ignore this health metric.
---@field RequireAll boolean If true, all thresholds must be met for the activation.

---------------------------------------------
-- CONDITIONS
---------------------------------------------

-- TurnStart
Osiris.RegisterSymbolListener("PROC_AMER_Combat_TurnStarted", 2, "after", function(char, hasActed)
    if Osi.IsTagged(char, EpicEnemies.INITIALIZED_TAG) == 1 then
        local _, round = Osiris.DB_PIP_CharacterCombatRound:Get(char, nil)
        if round == nil then round = 1 end
        char = Ext.GetCharacter(char)

        EpicEnemies.ActivateEffects(char, "TurnStart", {Round = round})
    end
end)

-- HealthThreshold
Osiris.RegisterSymbolListener("PROC_AMER_CharacterReceivedDamage_PhysMagicDefined", 4, "after", function(char, source, physDmg, magicDmg)
    if Osi.IsTagged(char, EpicEnemies.INITIALIZED_TAG) == 1 then
        local hpFraction = Osi.CharacterGetHitpointsPercentage(char) / 100
        local physArmorFraction = Osi.CharacterGetArmorPercentage(char) / 100
        local magicArmorFraction = Osi.CharacterGetMagicArmorPercentage(char) / 100

        EpicEnemies.ActivateEffects(Ext.GetCharacter(char), "HealthThreshold", {
            Vitality = hpFraction,
            PhysicalArmor = physArmorFraction,
            MagicArmor = magicArmorFraction,
        })
    end
end)

EpicEnemies.Hooks.CanActivateEffect:RegisterHook(function(activate, char, effect, condition, params)
    local conditionType = condition.Type

    if conditionType == "TurnStart" then
        ---@type EpicEnemiesCondition_TurnStart
        condition = condition

        if params.Round > condition.Round then
            if condition.Repeat then
                local freq = condition.RepeatFrequency or 1
                local roundsAfter = params.Round - condition.Round

                return roundsAfter % freq == 0
            end
        else
            return params.Round == condition.Round
        end
        return params.Round == condition.Round or (params.Round >= condition.Round and condition.Repeat)
    elseif conditionType == "HealthThreshold" then
        ---@type EpicEnemiesCondition_HealthThreshold
        condition = condition

        print((condition.Vitality or 0), params.Vitality, condition.Vitality)
        local vitality = params.Vitality <= (condition.Vitality or 0)
        local physArmor = params.PhysicalArmor <= (condition.PhysicalArmor or 0)
        local magicArmor = params.MagicArmor <= (condition.MagicArmor or 0)

        if condition.RequireAll then
            return vitality and physArmor and magicArmor
        else
            return vitality or physArmor or magicArmor
        end
    end

    return activate
end)