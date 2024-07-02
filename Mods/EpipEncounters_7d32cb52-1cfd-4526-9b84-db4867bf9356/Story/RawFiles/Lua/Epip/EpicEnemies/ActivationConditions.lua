
---------------------------------------------
-- Pre-made activation conditions for Epic Enemies effects.
---------------------------------------------

---@meta Library: EpicEnemiesEffectConditions, ContextServer, Epip.Features.EpicEnemiesEffectConditions

local Conditions = {

}
Epip.RegisterFeature("EpicEnemiesEffectConditions", Conditions)

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

---@class EpicEnemiesCondition_BatteredHarried : EpicEnemiesActivationCondition
---@field StackType StackType
---@field Amount integer

---@class EpicEnemiesCondition_StatusGained : EpicEnemiesActivationCondition
---@field StatusID string

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

        EpicEnemies.ActivateEffects(char, "HealthThreshold", {
            Vitality = hpFraction,
            PhysicalArmor = physArmorFraction,
            MagicArmor = magicArmorFraction,
        })
    end
end)

-- BatteredHarried
Osiris.RegisterSymbolListener("PROC_AMER_BatteredHarried_StacksChanged", 5, "after", function(char, source, stackType, addedStacks, newStacks)
    if addedStacks > 0 and EpicEnemies.IsInitialized(char) then
        local battered, harried, total = Osiris.QRY_AMER_BatteredHarried_GetCurrentStacks(char)

        EpicEnemies.ActivateEffects(char, "BatteredHarried", {
            Battered = battered,
            Harried = harried,
            Total = total,
        })
    end
end)

-- StatusGained
Osiris.RegisterSymbolListener("PROC_AMER_GEN_FilteredStatus_Applied", 4, "after", function(char, source, status, turns)
    if EpicEnemies.IsInitialized(char) then
        EpicEnemies.ActivateEffects(char, "StatusGained", {
            StatusID = status,
        })
    end
end)

EpicEnemies.Hooks.CanActivateEffect:Subscribe(function(ev)
    local condition, params = ev.Condition, ev.Params
    local conditionType = condition.Type

    if conditionType == "TurnStart" then
        ---@type EpicEnemiesCondition_TurnStart
        condition = condition

        if params.Round > condition.Round then
            if condition.Repeat then
                local freq = condition.RepeatFrequency or 1
                local roundsAfter = params.Round - condition.Round

                ev.CanActivate = roundsAfter % freq == 0
            end
        else
            ev.CanActivate = params.Round == condition.Round
        end
        ev.CanActivate = params.Round == condition.Round or (params.Round >= condition.Round and condition.Repeat)
    elseif conditionType == "HealthThreshold" then
        ---@type EpicEnemiesCondition_HealthThreshold
        condition = condition

        local vit = condition.Vitality
        if vit == nil then vit = 0 end
        local phys = condition.PhysicalArmor
        if phys == nil then phys = 0 end
        local mag = condition.MagicArmor
        if mag == nil then mag = 0 end

        local vitality = params.Vitality <= vit
        local physArmor = params.PhysicalArmor <= phys
        local magicArmor = params.MagicArmor <= mag

        if condition.RequireAll then
            ev.CanActivate = vitality and physArmor and magicArmor
        else
            ev.CanActivate = vitality or physArmor or magicArmor
        end
    end
end, {StringID = "Conditions.TurnStartAndHealthThreshold"})

EpicEnemies.Hooks.CanActivateEffect:Subscribe(function(ev)
    local condition, params = ev.Condition, ev.Params
    ---@type EpicEnemiesCondition_BatteredHarried
    condition = condition

    if condition.Type == "BatteredHarried" then
        if condition.StackType == "Both" then
            ev.CanActivate = params.Total >= condition.Amount
        elseif condition.StackType == "Battered" or condition.StackType == "B" then
            ev.CanActivate = params.Battered >= condition.Amount
        elseif condition.StackType == "Harried" or condition.StackType == "H" then
            ev.CanActivate = params.Harried >= condition.Amount
        end
    end
end, {StringID = "Condition.BatteredHarried"})

EpicEnemies.Hooks.CanActivateEffect:Subscribe(function(ev)
    local condition, params = ev.Condition, ev.Params
    ---@type EpicEnemiesCondition_StatusGained
    condition = condition

    if condition.Type == "StatusGained" then
        ev.CanActivate = params.StatusID == condition.StatusID
    end
end, {StringID = "Condition.StatusGained"})