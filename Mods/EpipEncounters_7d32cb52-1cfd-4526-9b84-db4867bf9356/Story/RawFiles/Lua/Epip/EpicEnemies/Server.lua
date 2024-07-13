
---@class Feature_EpicEnemies
local EpicEnemies = Epip.Features.EpicEnemies
local InitRequest = EpicEnemies:GetClass("Features.EpicEnemies.InitRequest")
local Settings = Settings

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Server-only.
---@class Features.EpicEnemies.Events.EffectApplied
---@field Character EsvCharacter
---@field Effect Features.EpicEnemies.Effect

---Server-only.
---@class Features.EpicEnemies.Events.EffectRemoved
---@field Character EsvCharacter
---@field Effect Features.EpicEnemies.Effect

---Server-only.
---@class Features.EpicEnemies.Hooks.IsCharacterEligible
---@field Character EsvCharacter
---@field Eligible boolean Hookable. Defaults to `false`.

---Server-only.
---@class Features.EpicEnemies.Hooks.IsEffectApplicable
---@field Character EsvCharacter
---@field Effect Features.EpicEnemies.Effect
---@field Request Features.EpicEnemies.InitRequest
---@field Applicable boolean Hookable. Defaults to `true`.

---Server-only.
---@class Features.EpicEnemies.Events.EffectActivated
---@field Character EsvCharacter
---@field Effect Features.EpicEnemies.Effect

---Server-only.
---@class Features.EpicEnemies.Events.EffectDeactivated : Features.EpicEnemies.Events.EffectActivated

---Server-only.
---@class Features.EpicEnemies.Hooks.CanActivateEffect
---@field Character EsvCharacter
---@field Effect Features.EpicEnemies.Effect
---@field Condition EpicEnemiesActivationCondition
---@field Params any
---@field CanActivate boolean Hookable. Defaults to `false`.

---Server-only.
---@class Features.EpicEnemies.Hooks.GetPointsForCharacter
---@field Character EsvCharacter
---@field Points integer Hookable. Defaults to setting value.

---Server-only.
---@class Features.EpicEnemies.Events.CharacterInitialized
---@field Character EsvCharacter
---@field Effects Features.EpicEnemies.Effect[]

---Server-only.
---@class Features.EpicEnemies.Events.CharacterCleanedUp
---@field Character EsvCharacter

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EsvCharacter|GUID
---@return boolean
function EpicEnemies.IsInitialized(char)
    return Osiris.IsTagged(char, EpicEnemies.INITIALIZED_TAG) == 1
end

---Returns a map of priorities and corresponding effects.
---@return table<number, Features.EpicEnemies.Effect[]>
function EpicEnemies.GetEffectPriorityTiers()
    local tiers = {} ---@type table<number, Features.EpicEnemies.Effect[]>
    for _,effect in pairs(EpicEnemies.GetRegisteredEffects()) do
        local priority = effect.Priority or EpicEnemies.DEFAULT_EFFECT_PRIORITY
        tiers[priority] = tiers[priority] or {}
        tiers[priority][effect.ID] = effect
    end
    return tiers
end

---@param char EsvCharacter
function EpicEnemies.InitializeCharacter(char)
    if not Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_Toggle") then return nil end

    local eligible = EpicEnemies.IsEligible(char)
    if eligible then
        local request = InitRequest.Create({
            Character = char,
            Budget = EpicEnemies.GetPointsForCharacter(char),
        })
        local addedEffects = {}

        -- Group effects into pool based on priority.
        local tiers = EpicEnemies.GetEffectPriorityTiers()
        local sortedPools = {} ---@type {Effects: table<string, Features.EpicEnemies.Effect>, Priority: number}[]
        for prio,effects in pairs(tiers) do
            table.insert(sortedPools, {
                Effects = effects,
                Priority = prio,
            })
        end
        table.sort(sortedPools, function (a, b)
            return a.Priority > b.Priority
        end)

        -- Roll effects from pools in order of priority.
        local attempts = 0
        for _,poolData in ipairs(sortedPools) do
            local pool = poolData.Effects
            while request.Budget > 0 and attempts < 100 do
                local effect = EpicEnemies.GetRandomEffect(char, pool, request)
                if effect then
                    request:AddEffect(effect)

                    table.insert(addedEffects, effect)

                    -- Effects cannot be rolled twice
                    pool[effect.ID] = nil
                else -- Break if no valid effects remain.
                    break
                end

                attempts = attempts + 1
            end
        end

        -- Apply all effects from the request.
        for effectID,_ in pairs(request.Effects) do
            local effect = EpicEnemies.GetEffectData(effectID)
            EpicEnemies.ApplyEffect(char, effect)
        end

        Osiris.SetTag(char, EpicEnemies.INITIALIZED_TAG)
        Osiris.ApplyStatus(char, "PIP_OSITOOLS_EpicBossesDisplay", -1, 1, NULLGUID)

        Net.Broadcast("EPIPENCOUNTERS_EpicEnemies_EffectsApplied", {
            Effects = addedEffects,
            CharacterNetID = char.NetID,
        })

        EpicEnemies:DebugLog("Initialized effects on " .. char.DisplayName)

        EpicEnemies.Events.CharacterInitialized:Throw({
            Character = char,
            Effects = addedEffects,
        })
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

        EpicEnemies.Events.CharacterCleanedUp:Throw({
            Character = char,
        })
    end
end

---Returns true if the character is eligible to receive Epic Enemies effects.
---@param char EsvCharacter
function EpicEnemies.IsEligible(char)
    return EpicEnemies.Hooks.IsCharacterEligible:Throw({
        Character = char,
        Eligible = false,
    }).Eligible
end

---@param char EsvCharacter
---@param effect Features.EpicEnemies.Effect
function EpicEnemies.ApplyEffect(char, effect)
    EpicEnemies:DebugLog("Applying effect: " .. Text.Resolve(effect.Name) .. " to " .. char.DisplayName)

    Osiris.DB_PIP_EpicEnemies_AppliedEffect:Set(char.MyGuid, effect.ID)
    Osiris.SetTag(char, EpicEnemies.EFFECT_TAG_PREFIX .. effect.ID)

    EpicEnemies.ActivateEffects(char, "EffectApplied")
end

---@param char EsvCharacter
---@param effect Features.EpicEnemies.Effect
function EpicEnemies.ActivateEffect(char, effect)
    local _, _, activationCount = Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Get(char.MyGuid, effect.ID, nil)

    if activationCount == nil then activationCount = 0 end

    -- TODO move to hook
    if activationCount < effect.ActivationCondition.MaxActivations then
        EpicEnemies:DebugLog("Activating effect: " .. Text.Resolve(effect.Name) .. " of " .. char.DisplayName .. " to " .. tostring(activationCount + 1) .. " activations")

        activationCount = activationCount + 1

        Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Delete(char.MyGuid, effect.ID, nil)
        Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Set(char.MyGuid, effect.ID, activationCount)

        if activationCount == 1 then
            EpicEnemies.Events.EffectActivated:Throw({
                Character = char,
                Effect = effect,
            })
        end
    end
end

---@param char EsvCharacter
---@param predicate (fun(char:EsvCharacter, effect:Features.EpicEnemies.Effect):boolean)?
---@return table<string, Features.EpicEnemies.Effect>
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
---@param effect Features.EpicEnemies.Effect
---@return boolean
function EpicEnemies.EffectIsActive(char, effect)
    return EpicEnemies.GetEffectActivationCount(char, effect) > 0
end

---@param char EsvCharacter
---@param effect Features.EpicEnemies.Effect
---@return integer
function EpicEnemies.GetEffectActivationCount(char, effect)
    local _, _, activationCount = Osiris.DB_PIP_EpicEnemies_ActivatedEffect:Get(char.MyGuid, effect.ID, nil)

    return activationCount or 0
end

---@param char EsvCharacter|GUID.Character
---@param effectType string
---@param params table?
function EpicEnemies.ActivateEffects(char, effectType, params)
    if type(char) ~= "userdata" then char = Character.Get(char) end

    for _,effect in pairs(EpicEnemies.GetAppliedEffects(char, function(_, eff) return eff.ActivationCondition.Type == effectType end)) do
        if EpicEnemies.Hooks.CanActivateEffect:Throw({
            Character = char,
            Effect = effect,
            Condition = effect.ActivationCondition,
            Params = params,
            CanActivate = false,
        }).CanActivate then
            EpicEnemies.ActivateEffect(char, effect)
        end
    end
end

---@param char EsvCharacter
---@param effect Features.EpicEnemies.Effect
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
        EpicEnemies.Events.EffectDeactivated:Throw({
            Character = char,
            Effect = effect,
        })
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

    EpicEnemies:DebugLog("Removing effect: " .. Text.Resolve(effect.Name) .. " from " .. char.DisplayName)

    EpicEnemies.Events.EffectRemoved:Throw({
        Character = char,
        Effect = effect,
    })
end

---Returns the points cost of an effect.
---@param effect Features.EpicEnemies.Effect
---@param initRequest Features.EpicEnemies.InitRequest? If passed, already-obtained prerequisites will be considered.
---@return number -- 0 if the request already has the effect.
function EpicEnemies.GetEffectCost(effect, initRequest)
    if initRequest and initRequest:HasEffect(effect) then return 0 end
    local cost = effect:GetCost()
    if initRequest then
        -- Sum costs of unmet prerequisites
        for prereq in pairs(effect.Prerequisites or {}) do
            if not effect.DiscountPrerequisites or not initRequest:HasEffect(prereq) then
                local prereqEffect = EpicEnemies.GetEffectData(prereq)
                -- cost = cost + EpicEnemies.GetEffectCost(prereqEffect, initRequest) -- Nesting prerequisites is unsupported atm. TODO?
                cost = cost + prereqEffect:GetCost()
            end
        end
    end
    return cost
end

---Returns a random effect from a pool that is valid for the character.
---@param char EsvCharacter
---@param effectPool table<string, Features.EpicEnemies.Effect>
---@param request Features.EpicEnemies.InitRequest
---@return Features.EpicEnemies.Effect? `nil` if no valid effects are in the pool.
function EpicEnemies.GetRandomEffect(char, effectPool, request)
    local totalWeight = 0
    local chosenEffect

    local filteredPool = {}
    for id,effect in pairs(effectPool) do
        -- Skip inclusion checks for effects that cannot randomly roll or have already been added - rolling an effect twice would be a no-op (no budget reduced).
        local included = effect:GetWeight() > 0 and not request:HasEffect(id) and EpicEnemies.GetEffectCost(effect, request) <= request.Budget and EpicEnemies.Hooks.IsEffectApplicable:Throw({
            Character = char,
            Effect = effect,
            Request = request,
            Applicable = true,
        }).Applicable
        if included then
            filteredPool[id] = effect
        end
    end

    for _,effect in pairs(filteredPool) do
        totalWeight = totalWeight + effect:GetWeight()
    end

    local seed = math.random() * totalWeight
    for _,effect in pairs(filteredPool) do
        seed = seed - effect:GetWeight()

        if seed < 0 then
            chosenEffect = effect
            break
        end
    end

    return chosenEffect
end

---Returns the points budget for a character.
---@param char EsvCharacter
---@return integer
function EpicEnemies.GetPointsForCharacter(char)
    return EpicEnemies.Hooks.GetPointsForCharacter:Throw({
        Character = char,
        Points = Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsBudget"),
    }).Points
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Multiply point budget by slider settings.
EpicEnemies.Hooks.GetPointsForCharacter:Subscribe(function(ev)
    local char, points = ev.Character, ev.Points
    local isBoss = Character.IsBoss(char)

    if isBoss then
        points = points * Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsMultiplier_Bosses")
    else
        points = points * Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsMultiplier_Normies")
    end

    ev.Points = points
end, {StringID = "Settings.PointsMultiplier"})

-- Reset state upon lua reset
Ext.Events.ResetCompleted:Subscribe(function()
    if Ext.Osiris.IsCallable() and EpicEnemies:IsDebug() then
        local _, _, tuples = Osiris.DB_PIP_EpicEnemies_AppliedEffect:Get(nil, nil)

        for _,tuple in ipairs(tuples or {}) do
            EpicEnemies.CleanupCharacter(Character.Get(tuple[1]))
        end
    end
end)

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
EpicEnemies.Hooks.IsCharacterEligible:Subscribe(function (ev)
    local char, eligible = ev.Character, ev.Eligible
    if eligible then return end -- Do nothing if an earlier listener already made this character eligible.

    -- Eligibility based on slider settings
    if Osi.IsBoss(char.MyGuid) == 1 then
        eligible = Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsMultiplier_Bosses") > 0
    else
        eligible = Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_PointsMultiplier_Normies") > 0
    end

    -- Players cannot be affected.
    if Character.IsPlayer(char) then
        eligible = false
    end

    -- Origins cannot be affected.
    if Character.IsOrigin(char) then
        eligible = false
    end

    -- Cannot initialize the same character multiple times, nor initialize characters specifically excluded from this feature
    eligible = eligible and not char:IsTagged(EpicEnemies.INITIALIZED_TAG) and not char:IsTagged(EpicEnemies.INELIGIBLE_TAG)

    -- Summons and party followers are ineligible.
    eligible = eligible and not Osi.QRY_IsSummonOrPartyFollower(char.MyGuid)

    ev.Eligible = eligible
end, {Priority = -99, StringID = "DefaultImplementation"})

-- AI archetype filter.
EpicEnemies.Hooks.IsEffectApplicable:Subscribe(function (ev)
    local char, effect = ev.Character, ev.Effect
    if effect.AllowedAIArchetypes then
        ev.Applicable = ev.Applicable and effect.AllowedAIArchetypes[char.Archetype] == true
    end
end)

---------------------------------------------
-- ACTIVATION CONDITIONS
---------------------------------------------

-- Activate effects with the "EffectApplied" condition always.
EpicEnemies.Hooks.CanActivateEffect:Subscribe(function(ev)
    local condition = ev.Condition.Type
    if condition == "EffectApplied" then
        ev.CanActivate = true
    end
end, {StringID = "Condition.EffectApplied"})
