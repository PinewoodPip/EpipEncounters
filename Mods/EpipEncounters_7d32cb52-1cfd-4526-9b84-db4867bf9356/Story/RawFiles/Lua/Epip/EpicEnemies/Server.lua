
local EpicEnemies = Epip.Features.EpicEnemies
local ServerSettings = Epip.Features.ServerSettings

local settings = {
    EpicEnemies_Toggle = {
        ID = "EpicEnemies_Toggle",
        Type = "Checkbox",
        Label = "Enabled",
        ServerOnly = true,
        SaveOnServer = true,
        Tooltip = "Enables the Epic Enemies feature.",
        DefaultValue = false,
    },
    EpicEnemies_PointsBudget = {
        ID = "EpicEnemies_PointsBudget",
        Type = "Slider",
        Label = "Points Budget",
        SaveOnServer = true,
        ServerOnly = true,
        MinAmount = 1,
        MaxAmount = 100,
        Interval = 1,
        DefaultValue = 30,
        HideNumbers = false,
        Tooltip = "Controls how many effects enemies affected by Epic Enemies can receive. Effects cost a variable amount of points based on how powerful they are.",
    },
}
for id,effect in pairs(EpicEnemies.EFFECTS) do
    settings[id] = EpicEnemies.GenerateOptionData(effect)
end
EpicEnemies:Debug()

ServerSettings.AddModule("EpicEnemies", settings)

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

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EsvCharacter
function EpicEnemies.InitializeCharacter(char)
    if not ServerSettings.GetValue("EpicEnemies", "EpicEnemies_Toggle") then return nil end

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

        SetTag(char.MyGuid, EpicEnemies.INITIALIZED_TAG)
        ApplyStatus(char.MyGuid, "PIP_OSITOOLS_EpicBossesDisplay", -1, 1)

        Game.Net.Broadcast("EPIPENCOUNTERS_EpicEnemies_EffectsApplied", {
            Effects = addedEffects,
            CharacterNetID = char.NetID,
        })

        EpicEnemies:DebugLog("Initialized effects on " .. char.DisplayName)
    end
end

---Remove all effects from a character.
---@param char EsvCharacter
function EpicEnemies.CleanupCharacter(char)
    if char:IsTagged(EpicEnemies.INITIALIZED_TAG) then
        local _, _, tuples = Osiris.DB_PIP_EpicEnemies_AppliedEffect:Get(char.MyGuid, nil)

        if tuples then
            for i,tuple in ipairs(tuples) do
                EpicEnemies.RemoveEffect(char, tuple[2])
            end
        end

        Osi.ClearTag(char.MyGuid, EpicEnemies.INITIALIZED_TAG)

        Game.Net.Broadcast("EPIPENCOUNTERS_EpicEnemies_EffectsRemoved", {
            CharacterNetID = char.NetID,
        })

        EpicEnemies:DebugLog("Removed effects from " .. char.DisplayName)
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

    EpicEnemies.Events.EffectApplied:Fire(char, effect)
end

---Remove an effect from a character.
---@param char EsvCharacter
---@param effectID string
function EpicEnemies.RemoveEffect(char, effectID)
    local effect = EpicEnemies.GetEffectData(effectID)

    Osiris.DB_PIP_EpicEnemies_AppliedEffect:Delete(char.MyGuid, effectID)

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
        local included = EpicEnemies.Hooks.IsEffectApplicable:Return(true, effect, char, activeEffects)

        if included then
            filteredPool[id] = effect
        end
    end

    for id,effect in pairs(filteredPool) do
        totalWeight = totalWeight + effect:GetWeight()
    end

    local seed = Ext.Random(1, totalWeight)

    for id,effect in pairs(filteredPool) do
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
    -- TODO!
    return ServerSettings.GetValue("EpicEnemies", "EpicEnemies_PointsBudget")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

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
Ext.Osiris.RegisterListener("PROC_AMER_CharLeftCombat", 2, "after", function(char, combatID)
    if Ext.IsDeveloperMode() then
        EpicEnemies.CleanupCharacter(Ext.GetCharacter(char))
    end
end)

-- Initialize characters when combat starts.
Ext.Osiris.RegisterListener("PROC_AMER_CharAddedToCombat", 2, "after", function(char, combatID)
    EpicEnemies.InitializeCharacter(Ext.GetCharacter(char))
end)

-- TODO register this later so it runs last.
EpicEnemies.Hooks.IsEligible:RegisterHook(function (eligible, char)
    -- Bosses
    if Osi.IsBoss(char.MyGuid) == 1 then
        eligible = true
    end

    -- Players cannot be affected.
    if Osiris.DB_IsPlayer:Get(char.MyGuid) then
        eligible = false
    end

    -- Origins cannot be affected.
    if Osiris.DB_Origins:Get(char.MyGuid) then
        eligible = false
    end

    -- Cannot initialize the same character multiple times
    if eligible then
        eligible = not char:IsTagged(EpicEnemies.INITIALIZED_TAG)
    end

    return eligible
end)

---------------------------------------------
-- PREMADE EFFECTS
---------------------------------------------

EpicEnemies.Events.EffectApplied:RegisterListener(function(char, effect)
    -- Special logic effects.
    if effect.SpecialLogic then
        Osi.PROC_AMER_UI_Ascension_SpecialLogic_Add(char.MyGuid, effect.SpecialLogic, 1)
    end

    -- Artifact.
    if effect.Artifact then
        Osi.PROC_AMER_Artifacts_EquipEffects(char.MyGuid, effect.Artifact, "Rune")

        -- TODO
        -- Osi.ApplyStatus(char.MyGuid, string.format("AMER_ARTIFACTPOWER_%s_DISPLAY", string.upper(effect.Artifact)), -1, 1)
    end
end)

EpicEnemies.Events.EffectRemoved:RegisterListener(function (char, effect)
    -- SpecialLogic
    if effect.SpecialLogic then
        Osi.PROC_AMER_UI_Ascension_SpecialLogic_Add(char.MyGuid, effect.SpecialLogic, -1)
    end

    -- Artifacts
    if effect.Artifact then
        Osi.PROC_AMER_Artifacts_UnequipEffects(char.MyGuid, effect.Artifact, "Rune")
    end
end)

EpicEnemies.Events.EffectApplied:RegisterListener(function (char, effect)
    if effect.Status then
        local statusData = effect.Status

        Osi.ApplyStatus(char.MyGuid, statusData.StatusID, statusData.Duration, 1)
    end

    if effect.Summon then
        local pos = char.WorldPos

        local guid = Osi.CharacterCreateAtPosition(pos[1], pos[2], pos[3], effect.Summon, 1)
        Osi.CharacterLevelUpTo(guid, char.Stats.Level)
        Osi.CharacterChangeToSummon(guid, char.MyGuid)
        Osi.EnterCombat(guid, char.MyGuid)
    end

    if effect.ExtendedStats then
        for i,extendedStat in ipairs(effect.ExtendedStats) do
            Osi.PROC_AMER_ExtendedStat_CharacterAddStat(char.MyGuid, extendedStat.StatID, extendedStat.Property1, extendedStat.Property2, extendedStat.Property3, extendedStat.Amount)
        end
    end
end)

EpicEnemies.Events.EffectRemoved:RegisterListener(function (char, effect)
    if effect.Status then
        local statusData = effect.Status
        
        Osi.RemoveStatus(char.MyGuid, statusData.StatusID)
    end
end)

-- Make mutator effects only available if character already has an activator
EpicEnemies.Hooks.IsEffectApplicable:RegisterHook(function (applicable, effect, char, activeEffects)
    if effect.Keyword then
        if effect.Keyword.BoonType == "Mutator" then
            local hasActivator = false
            local keywordID = effect.Keyword.Keyword

            -- Search for an activator for this keyword
            for i,appliedEffect in ipairs(activeEffects) do
                if appliedEffect.Keyword and appliedEffect.Keyword.Keyword == keywordID then
                    hasActivator = true
                    break
                end
            end

            if not hasActivator then
                applicable = false
            end
        end
    end

    return applicable
end)