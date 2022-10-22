
---@class Feature_EpicEnemies
local EpicEnemies = Epip.Features.EpicEnemies
local Settings = Settings

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class EpicEnemies_Event_EffectApplied : Event
---@field RegisterListener fun(self, listener:fun(char:EsvCharacter, effect:EpicEnemiesEffect))
---@field Fire fun(self, char:EsvCharacter, effect:EpicEnemiesEffect)

---@class EpicEnemies_Event_EffectRemoved : Event
---@field RegisterListener fun(self, listener:fun(char:EsvCharacter, effect:EpicEnemiesEffect))
---@field Fire fun(self, char:EsvCharacter, effect:EpicEnemiesEffect)

---@class EpicEnemies_Hook_IsEligible : Hook
---@field RegisterHook fun(self, handler:fun(eligible:boolean, char:EsvCharacter))
---@field Return fun(self, eligible:boolean, char:EsvCharacter)

---@class EpicEnemies_Hook_IsEffectApplicable : Hook
---@field RegisterHook fun(self, handler:fun(applicable:boolean, effect:EpicEnemiesEffect, char:EsvCharacter, activeEffects:EpicEnemiesEffect[]))
---@field Return fun(self, applicable:boolean, effect:EpicEnemiesEffect, char:EsvCharacter, activeEffects:EpicEnemiesEffect[])

---@class EpicEnemies_Event_EffectActivated : Event
---@field RegisterListener fun(self, listener:fun(char:EsvCharacter, effect:EpicEnemiesEffect))
---@field Fire fun(self, char:EsvCharacter, effect:EpicEnemiesEffect)

---@class EpicEnemies_Event_EffectDeactivated : Event
---@field RegisterListener fun(self, listener:fun(char:EsvCharacter, effect:EpicEnemiesEffect))
---@field Fire fun(self, char:EsvCharacter, effect:EpicEnemiesEffect)

---@class EpicEnemies_Hook_CanActivateEffect : Hook
---@field RegisterHook fun(self, handler:fun(activate:boolean, char:EsvCharacter, effect:EpicEnemiesEffect, params:any))
---@field Return fun(self, activate:boolean, char:EsvCharacter, effect:EpicEnemiesEffect, params:any)

---@class EpicEnemies_Hook_GetPointsForCharacter : Hook
---@field RegisterHook fun(self, handler:fun(points:integer, char:EsvCharacter))
---@field Return fun(self, points:integer, char:EsvCharacter)

---@class EpicEnemies_Event_CharacterInitialized : Event
---@field RegisterListener fun(self, listener:fun(char:EsvCharacter, effects:EpicEnemiesEffect[]))
---@field Fire fun(self, char:EsvCharacter, effects:EpicEnemiesEffect[])

---@class EpicEnemies_Event_CharacterCleanedUp : Event
---@field RegisterListener fun(self, listener:fun(char:EsvCharacter))
---@field Fire fun(self, char:EsvCharacter)

---@type EpicEnemies_Event_CharacterInitialized
EpicEnemies.Events.CharacterInitialized = EpicEnemies:AddEvent("CharacterInitialized")
---@type EpicEnemies_Event_CharacterCleanedUp
EpicEnemies.Events.CharacterCleanedUp = EpicEnemies:AddEvent("CharacterCleanedUp")

---@type EpicEnemies_Hook_GetPointsForCharacter
EpicEnemies.Hooks.GetPointsForCharacter = EpicEnemies:AddHook("GetPointsForCharacter")

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EsvCharacter|GUID
---@return bool
function EpicEnemies.IsInitialized(char)
    return Osiris.IsTagged(char, EpicEnemies.INITIALIZED_TAG) == 1
end

---@param char EsvCharacter
function EpicEnemies.InitializeCharacter(char)
    if not Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_Toggle") then return nil end

    local eligible = EpicEnemies.IsEligible(char)

    if eligible then
        local points = EpicEnemies.GetPointsForCharacter(char)

        local addedEffects = {}
        local pool = {}
        for id,effect in pairs(EpicEnemies.EFFECTS) do
            pool[id] = effect
        end

        local attempts = 0
        while points > 0 or attempts > 100 do
            local effect = EpicEnemies.GetRandomEffect(char, pool, addedEffects)

            if effect then
                EpicEnemies.ApplyEffect(char, effect)

                table.insert(addedEffects, effect)

                -- Effects cannot be rolled twice
                pool[effect.ID] = nil

                points = points - effect:GetCost()
            else
                break
            end

            attempts = attempts + 1
        end

        Osiris.SetTag(char, EpicEnemies.INITIALIZED_TAG)
        Osiris.ApplyStatus(char, "PIP_OSITOOLS_EpicBossesDisplay", -1, 1, NULLGUID)

        Net.Broadcast("EPIPENCOUNTERS_EpicEnemies_EffectsApplied", {
            Effects = addedEffects,
            CharacterNetID = char.NetID,
        })

        EpicEnemies:DebugLog("Initialized effects on " .. char.DisplayName)

        EpicEnemies.Events.CharacterInitialized:Fire(char, addedEffects)
    end
end

---Remove all effects from a character.
---@param char EsvCharacter
function EpicEnemies.CleanupCharacter(char)
    if EpicEnemies.IsInitialized(char) then
        local _, _, tuples = Osiris.DB_PIP_EpicEnemies_AppliedEffect:Get(char.MyGuid, nil)

        if tuples then
            for _,tuple in ipairs(tuples) do
                EpicEnemies.RemoveEffect(char, tuple[2])
            end
        end

        Osiris.ClearTag(char, EpicEnemies.INITIALIZED_TAG)

        Net.Broadcast("EPIPENCOUNTERS_EpicEnemies_EffectsRemoved", {
            CharacterNetID = char.NetID,
        })

        EpicEnemies:DebugLog("Removed effects from " .. char.DisplayName)

        Osiris.RemoveStatus(char, "PIP_OSITOOLS_EpicBossesDisplay")

        EpicEnemies.Events.CharacterCleanedUp:Fire(char)
    end
end

---Returns true if the character is eligible to receive Epic Enemies effects.
---@param char EsvCharacter
function EpicEnemies.IsEligible(char)
    return EpicEnemies.Hooks.IsEligible:Return(false, char)
end

---@param char EsvCharacter
---@param effect EpicEnemiesEffect
function EpicEnemies.ApplyEffect(char, effect)
    EpicEnemies:DebugLog("Applying effect: " .. effect.Name .. " to " .. char.DisplayName)

    Osiris.DB_PIP_EpicEnemies_AppliedEffect:Set(char.MyGuid, effect.ID)
    Osiris.SetTag(char, EpicEnemies.EFFECT_TAG_PREFIX .. effect.ID)

    EpicEnemies.ActivateEffects(char, "EffectApplied")
end

---@param char EsvCharacter
---@param effect EpicEnemiesEffect
function EpicEnemies.ActivateEffect(char, effect)
    local _, _, activationCount = Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Get(char.MyGuid, effect.ID, nil)

    if activationCount == nil then activationCount = 0 end

    -- TODO move to hook
    if activationCount < effect.ActivationCondition.MaxActivations then
        EpicEnemies:DebugLog("Activating effect: " .. effect.Name .. " of " .. char.DisplayName .. " to " .. tostring(activationCount + 1) .. " activations")

        activationCount = activationCount + 1

        Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Delete(char.MyGuid, effect.ID, nil)
        Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Set(char.MyGuid, effect.ID, activationCount)

        -- TODO event
        if activationCount == 1 then
            EpicEnemies.Events.EffectActivated:Fire(char, effect)
        end
    end
end

---@param char EsvCharacter
---@param predicate fun(char:EsvCharacter, effect:EpicEnemiesEffect)?
---@return table<string, EpicEnemiesEffect>
function EpicEnemies.GetAppliedEffects(char, predicate)
    local _, _, tuples = Osiris.DB_PIP_EpicEnemies_AppliedEffect:Get(char.MyGuid, nil)
    local effects = {}

    if tuples then
        for _,tuple in ipairs(tuples) do
            local effect = EpicEnemies.GetEffectData(tuple[2])
    
            if not predicate or predicate(char, effect) then
                effects[effect.ID] = effect
            end
        end
    end

    return effects
end

---@param char EsvCharacter
---@param effect EpicEnemiesEffect
---@return boolean
function EpicEnemies.EffectIsActive(char, effect)
    return EpicEnemies.GetEffectActivationCount(char, effect) > 0
end

---@param char EsvCharacter
---@param effect EpicEnemiesEffect
---@return integer
function EpicEnemies.GetEffectActivationCount(char, effect)
    local _, _, activationCount = Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Get(char.MyGuid, effect.ID, nil)

    return activationCount or 0
end

---@param char EsvCharacter
---@param effectType string
---@param params table?
function EpicEnemies.ActivateEffects(char, effectType, params)
    if type(char) ~= "userdata" then char = Ext.GetCharacter(char) end

    for _,effect in pairs(EpicEnemies.GetAppliedEffects(char, function(_, eff) return eff.ActivationCondition.Type == effectType end)) do
        if EpicEnemies.Hooks.CanActivateEffect:Return(false, char, effect, effect.ActivationCondition, params) then
            EpicEnemies.ActivateEffect(char, effect)
        end
    end
end

---@param char EsvCharacter
---@param effect EpicEnemiesEffect
---@param charges integer? Defaults to 1.
function EpicEnemies.DeactivateEffect(char, effect, charges)
    local _, _, activationCount = Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Get(char.MyGuid, effect.ID, nil)
    if charges == nil then charges = 1 end
    if activationCount == nil then return nil end

    activationCount = activationCount - 1

    Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Delete(char.MyGuid, effect.ID, nil)

    if activationCount > 1 then
        Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Set(char.MyGuid, effect.ID, activationCount)
        -- TODO event
    else
        EpicEnemies.Events.EffectDeactivated:Fire(char, effect)
    end
end

---Remove an effect from a character.
---@param char EsvCharacter
---@param effectID string
function EpicEnemies.RemoveEffect(char, effectID)
    local effect = EpicEnemies.GetEffectData(effectID)

    -- Lose all activations first
    EpicEnemies.DeactivateEffect(char, effect, EpicEnemies.GetEffectActivationCount(char, effect))

    Osiris.DB_PIP_EpicEnemies_AppliedEffect:Delete(char.MyGuid, effectID)
    Osiris.ClearTag(char, EpicEnemies.EFFECT_TAG_PREFIX .. effectID)

    EpicEnemies:DebugLog("Removing effect: " .. effect.Name .. " from " .. char.DisplayName)

    EpicEnemies.Events.EffectRemoved:Fire(char, effect)
end

---@param char EsvCharacter
---@param effectPool table<string, EpicEnemiesEffect>
---@param activeEffects? EpicEnemiesEffect[]
function EpicEnemies.GetRandomEffect(char, effectPool, activeEffects)
    local totalWeight = 0
    local chosenEffect
    activeEffects = activeEffects or {}

    local filteredPool = {}

    for id,effect in pairs(effectPool) do
        local included = EpicEnemies.Hooks.IsEffectApplicable:Return(true, effect, char, activeEffects) and effect:GetWeight() > 0

        if included then
            filteredPool[id] = effect
        end
    end

    for _,effect in pairs(filteredPool) do
        totalWeight = totalWeight + effect:GetWeight()
    end

    local seed = Ext.Random(0, math.floor(totalWeight))

    for _,effect in pairs(filteredPool) do
        seed = seed - effect:GetWeight()

        if seed < 0 then
            chosenEffect = effect
            break
        end
    end

    return chosenEffect
end

---@param char EsvCharacter
function EpicEnemies.GetPointsForCharacter(char)
    return EpicEnemies.Hooks.GetPointsForCharacter:Return(Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsBudget"), char)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Multiply points by slider settings.
EpicEnemies.Hooks.GetPointsForCharacter:RegisterHook(function(points, char)
    local isBoss = Osi.IsBoss(char.MyGuid) == 1

    if isBoss then
        points = points * Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsMultiplier_Bosses")
    else
        points = points * Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsMultiplier_Normies")
    end

    return points
end)

-- Reset state upon lua reset
Ext.Events.ResetCompleted:Subscribe(function()
    if Ext.Osiris.IsCallable() and EpicEnemies:IsDebug() then
        local _, _, tuples = Osiris.DB_PIP_EpicEnemies_AppliedEffect:Get(nil, nil)

        for _,tuple in ipairs(tuples or {}) do
            EpicEnemies.CleanupCharacter(Character.Get(tuple[1]))
        end
    end
end)

-- TODO better workaround for context-specific events
if false then
    ---@type EpicEnemies_Event_EffectApplied
    EpicEnemies.Events.EffectApplied = {}
    ---@type EpicEnemies_Hook_IsEligible
    EpicEnemies.Hooks.IsEligible = {}
    ---@type EpicEnemies_Event_EffectRemoved
    EpicEnemies.Events.EffectRemoved = {}
    ---@type EpicEnemies_Hook_IsEffectApplicable
    EpicEnemies.Hooks.IsEffectApplicable = {}
end

-- In developer mode, remove effects after exiting combat
Ext.Osiris.RegisterListener("PROC_AMER_CharLeftCombat", 2, "after", function(char, _)
    if Epip.IsDeveloperMode(true) then
        EpicEnemies.CleanupCharacter(Character.Get(char))
    end
end)

-- Initialize characters when combat starts.
Ext.Osiris.RegisterListener("PROC_AMER_CharAddedToCombat", 2, "after", function(char, _)
    EpicEnemies.InitializeCharacter(Character.Get(char))
end)

-- TODO register this later so it runs last.
EpicEnemies.Hooks.IsEligible:RegisterHook(function (eligible, char)
    -- Eligibility based on slider settings
    if Osi.IsBoss(char.MyGuid) == 1 then
        eligible = Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsMultiplier_Bosses") > 0
    else
        eligible = Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsMultiplier_Normies") > 0
    end

    -- Players cannot be affected.
    if Osiris.DB_IsPlayer:Get(char.MyGuid) then
        eligible = false
    end

    -- Origins cannot be affected.
    if Osiris.DB_Origins:Get(char.MyGuid) then
        eligible = false
    end

    -- Cannot initialize the same character multiple times, nor initialize characters specifically excluded from this feature, nor initialize summons
    if eligible then
        eligible = not char:IsTagged(EpicEnemies.INITIALIZED_TAG) and not char:IsTagged(EpicEnemies.INELIGIBLE_TAG)
    end

    -- Summons and party followers are ineligible.
    if eligible then
        eligible = not Osi.QRY_IsSummonOrPartyFollower(char.MyGuid)
    end

    return eligible
end)

---------------------------------------------
-- ACTIVATION CONDITIONS
---------------------------------------------

-- Activate effects with the "EffectApplied" condition always.
EpicEnemies.Hooks.CanActivateEffect:RegisterHook(function(activate, _, _, activationCondition, _)
    local condition = activationCondition.Type

    if condition == "EffectApplied" then
        activate = true
    end

    return activate
end)