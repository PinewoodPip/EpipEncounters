
---@meta Library: EpicEnemiesEffectTemplates, ContextServer, Epip.Features.EpicEnemiesEffectTemplates

---------------------------------------------
-- Pre-made effects for Epic Enemies that achieve generic functionality like applying specific statuses, Special Logic, etc.
---------------------------------------------

local Templates = {
    ---@type table<Keyword, boolean>
    KEYWORD_ACTIVATOR_REQUIREMENT_EXCLUSIONS = {
        Presence = true,
        IncarnateChampion = true,
        Disintegrate = true,
        VolatileArmor = true,
        Voracity = true,
    },
}
Epip.RegisterFeature("EpicEnemiesEffectTemplates", Templates)
Epip.Features.EpicEnemiesEffectTemplates = Templates

local EpicEnemies = Epip.Features.EpicEnemies

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class EpicEnemiesExtendedEffect : Features.EpicEnemies.Effect
---@field SpecialLogic (string|string[])? Special logic to grant when the effect is rolled.
---@field Artifact string? Artifact Power to grant.
---@field Artifacts string[]? Artifact Powers to grant.
---@field Keyword EpicEnemiesKeywordData? Used for activation conditions; certain keyword mutators will not be granted if the target has no activators of the keyword.
---@field Summon GUID? Template to summon.
---@field Status EpicEnemiesStatus?
---@field FlexStats EpicEnemiesFlexStat[]?
---@field ExtendedStats EpicEnemiesExtendedStat[]?
---@field KeywordStats Keyword[]? List of keywords to grant; i.e. basic activators.
---@field RequiredSkills string[]? The effect is ineligible if the character does not have any of the required skills.

---@class EpicEnemiesStatus
---@field StatusID string
---@field Duration integer

---@class EpicEnemiesFlexStat
---@field Type string
---@field Stat string
---@field Amount number

---@class EpicEnemiesExtendedStat
---@field StatID string The ID of the ExtendedStat.
---@field Amount number
---@field Property1 string?
---@field Property2 string?
---@field Property3 string?

---------------------------------------------
-- EFFECTS
---------------------------------------------

---Returns a list of the SpecialLogic to apply from an effect.
---@param effect EpicEnemiesExtendedEffect
---@return string[]
local function GetSpecialLogicList(effect)
    return type(effect.SpecialLogic) == "string" and {effect.SpecialLogic} or effect.SpecialLogic
end

EpicEnemies.Events.EffectActivated:Subscribe(function(ev)
    local char, effect = ev.Character, ev.Effect
    ---@type EpicEnemiesExtendedEffect
    effect = effect

    -- Special logic effects.
    if effect.SpecialLogic then
        local logicList = GetSpecialLogicList(effect)
        for _,logic in ipairs(logicList) do
            Osi.PROC_AMER_UI_Ascension_SpecialLogic_Add(char.MyGuid, logic, 1)
        end
    end

    -- Grant keyword stats.
    for _,keyword in ipairs(effect.KeywordStats or {}) do
        Osi.PROC_AMER_KeywordStat_Add(char.MyGuid, keyword, 1)
    end

    -- Grant Artifact Powers.
    if effect.Artifact then
        Osi.PROC_AMER_Artifacts_EquipEffects(char.MyGuid, effect.Artifact, "Rune")
    end
    for _,artifact in ipairs(effect.Artifacts or {}) do
        Osi.PROC_AMER_Artifacts_EquipEffects(char.MyGuid, artifact, "Rune")
    end

    -- Statuses.
    if effect.Status then
        local statusData = effect.Status

        Osi.ApplyStatus(char.MyGuid, statusData.StatusID, statusData.Duration or -1, 1)
    end

    -- Summons.
    if effect.Summon then
        local pos = char.WorldPos

        local guid = Osi.CharacterCreateAtPosition(pos[1], pos[2], pos[3], effect.Summon, 1)
        Osi.CharacterLevelUpTo(guid, char.Stats.Level)
        Osi.CharacterChangeToSummon(guid, char.MyGuid)
        Osi.EnterCombat(guid, char.MyGuid)
    end

    -- Flex Stats.
    if effect.FlexStats then
        for _,flexStat in ipairs(effect.FlexStats) do
            Osi.PROC_AMER_FlexStat_CharacterAddStat(char.MyGuid, flexStat.Type, flexStat.Stat, flexStat.Amount)
        end
    end

    -- Extended Stats.
    if effect.ExtendedStats then
        for _,extendedStat in ipairs(effect.ExtendedStats) do
            Osi.PROC_AMER_ExtendedStat_CharacterAddStat(char.MyGuid, extendedStat.StatID, extendedStat.Property1 or "", extendedStat.Property2 or "", extendedStat.Property3 or "", extendedStat.Amount)
        end
    end
end)

EpicEnemies.Events.EffectRemoved:Subscribe(function (ev)
    local char, effect = ev.Character, ev.Effect
    ---@cast effect EpicEnemiesExtendedEffect

    -- Clear SpecialLogic.
    if effect.SpecialLogic then
        local logicList = GetSpecialLogicList(effect)
        for _,logic in ipairs(logicList) do
            Osi.PROC_AMER_UI_Ascension_SpecialLogic_Add(char.MyGuid, logic, -1)
        end
    end

    -- Clear keyword stats.
    for _,keyword in ipairs(effect.KeywordStats or {}) do
        Osi.PROC_AMER_KeywordStat_Add(char.MyGuid, keyword, -1)
    end

    -- Clear Artifact Powers.
    if effect.Artifact then
        Osi.PROC_AMER_Artifacts_UnequipEffects(char.MyGuid, effect.Artifact, "Rune")
    end
    for _,artifact in ipairs(effect.Artifacts or {}) do
        Osi.PROC_AMER_Artifacts_UnequipEffects(char.MyGuid, artifact, "Rune")
    end

    -- Clear Statuses.
    if effect.Status then
        local statusData = effect.Status
        Osi.RemoveStatus(char.MyGuid, statusData.StatusID)
    end

    -- Flex Stats.
    if effect.FlexStats then
        for _,flexStat in ipairs(effect.FlexStats) do
            Osi.PROC_AMER_FlexStat_CharacterAddStat(char.MyGuid, flexStat.Type, flexStat.Stat, -flexStat.Amount)
        end
    end

    -- Extended Stats.
    if effect.ExtendedStats then
        for _,extendedStat in ipairs(effect.ExtendedStats) do
            Osi.PROC_AMER_ExtendedStat_CharacterAddStat(char.MyGuid, extendedStat.StatID, extendedStat.Property1 or "", extendedStat.Property2 or "", extendedStat.Property3 or "", -extendedStat.Amount)
        end
    end
end)

-- Make mutator effects only available if character already has an activator
EpicEnemies.Hooks.IsEffectApplicable:Subscribe(function (ev)
    if not ev.Applicable then return end -- Do nothing if another listener already filtered this effect out.

    local activeEffects = ev.ActiveEffects
    local effect = ev.Effect ---@cast effect EpicEnemiesExtendedEffect
    if effect.Keyword then
        local excluded = Templates.KEYWORD_ACTIVATOR_REQUIREMENT_EXCLUSIONS[effect.Keyword.Keyword]

        if effect.Keyword.BoonType == "Mutator" and not excluded then
            local hasActivator = false
            local keywordID = effect.Keyword.Keyword

            -- Search for an activator for this keyword
            for _,appliedEffect in ipairs(activeEffects) do
                ---@cast appliedEffect EpicEnemiesExtendedEffect
                -- Boon type check is technically redundant, as activators must be applied first before any mutators are applied - thus even if we run into a mutator first while iterating, an activator must be present *under normal conditions*.
                if appliedEffect.Keyword and appliedEffect.Keyword.Keyword == keywordID then
                    hasActivator = true
                    break
                end
            end

            if not hasActivator then
                ev.Applicable = false
            end
        end
    end
end)

-- RequiredSkills condition.
EpicEnemies.Hooks.IsEffectApplicable:Subscribe(function (ev)
    local char = ev.Character
    local effect = ev.Effect ---@cast effect EpicEnemiesExtendedEffect

    if ev.Applicable and effect.RequiredSkills then
        -- The effect will be applicable if any of the skills are present.
        ev.Applicable = false
        for _,skillID in ipairs(effect.RequiredSkills) do
            if Osi.CharacterHasSkill(char.MyGuid, skillID) == 1 then
                ev.Applicable = true
                break
            end
        end
        -- Templates:DebugLog("RequiredSkills availability for", char.DisplayName, ev.Applicable)
    end
end)
