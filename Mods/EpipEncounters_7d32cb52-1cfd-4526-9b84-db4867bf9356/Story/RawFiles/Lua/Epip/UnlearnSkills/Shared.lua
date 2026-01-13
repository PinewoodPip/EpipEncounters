
local Meditate, SourceInfusion = EpicEncounters.Meditate, EpicEncounters.SourceInfusion

---@class Feature_UnlearnSkills : Feature
local Unlearn = {
    BLOCKED_SKILLS = {
        Summon_Cat = true,
        Shout_NexusMeditate = true,
        Shout_SourceInfusion = true,
    },

    ---@enum Features.UnlearnSkills.CannotUnlearnReason
    CANNOT_UNLEARN_REASONS = {
        SKILL_DOESNT_EXIST = 1,
        GRANTED_BY_EXTERNAL_SOURCE = 2,
        ZERO_MEMORY = 3,
        IN_COMBAT = 4,
        BLACKLISTED = 5, -- See `BLOCKED_SKILLS`
        EE_SPECIAL_NEXUS_MEDITATE = 6,
        EE_SPECIAL_SOURCE_INFUSE = 7,
        INNATE = 8,
        NOT_IN_SKILLMANAGER = 9,
    },

    TranslatedStrings = {
        MsgBox_Title = {
            Handle = "h88ea1fb2g6f70g445ag9aa3ga209b6ed7feb",
            Text = "Unlearn Skill",
            ContextDescription = "Message box header",
        },
        MsgBox_Confirmation = {
            Handle = "h663a33aeg894cg428eg8d9eg799a8bd07386",
            Text = "Are you sure you want to unlearn %s?",
            ContextDescription = "Message box. First param is skill name",
        },
        MsgBox_Button_Unlearn = {
            Handle = "h27591100g7b7dg4d6ag8c2eg3597762db593",
            Text = "Unlearn",
            ContextDescription = "Button in message box",
        },
        Tooltip_HintLabel = {
            Handle = "hc2778b10ge61fg46bfga656g1bac3d5b44ec",
            Text = "Right-click to unlearn.",
            ContextDescription = "Hint in tooltip in skillbook",
            FormatOptions = {
                Color = Color.GREEN,
            }
        },
        CannotUnlearnReason_SkillDoesntExist = {
            Handle = "hb931ea77g4e56g47c3g9a69g923b8f76482b",
            Text = "I cannot unlearn skills that do not exist.",
            ContextDescription = "Warning when trying to unlearn skills that don't exist (failsafe)",
        },
        CannotUnlearnReason_ExternalSource = {
            Handle = "hcc3ddb27g8770g4d1bg9964gb2387308d99c",
            Text = "I cannot unlearn skills granted by external sources.",
            ContextDescription = "Warning when trying to unlearning skills granted by ex. a status or equipped item",
        },
        CannotUnlearnReason_ZeroMemory = {
            Handle = "h616fdab7g67c9g4db0g80f4gc04d25dc0e4e",
            Text = "I cannot unlearn skills that take up no memory.",
        },
        CannotUnlearnReason_InCombat = {
            Handle = "h651ef6a9gf376g47b7gb230gb73521021f74",
            Text = "I cannot unlearn skills while in combat.",
        },
        CannotUnlearnReason_Blacklisted = {
            Handle = "hf29be376g590ag4cd8gac23gc527f2c7a610",
            Text = "I cannot unlearn this skill.",
            ContextDescription = "Shown for manually blacklisted skills",
        },
        CannotUnlearnReason_EE_NexusMeditate = {
            Handle = "h9b5014e1gb9d4g4dc8g8c47g11f06fe3e576",
            Text = "I would lose my special spark if I were to give that up.",
            ContextDescription = "Easter egg when trying to unlearn EE Meditate",
        },
        CannotUnlearnReason_EE_SourceInfuse = {
            Handle = "ha58ca030gdf7bg42ffga616gcda9d8f3b753",
            Text = "Sourcery is an innate part of who I am; I cannot get rid of it.",
            ContextDescription = "Easter egg when trying to unlearn EE Source Infuse",
        },
        CannotUnlearnReason_Innate = {
            Handle = "hc8131fa1g3bf9g4773gb244gcdf8b1b45f7c",
            Text = "%s is an innate skill; it might be unwise to rid myself of it.",
            ContextDescription = "First param is skill name.",
        },
        CannotUnlearnReason_NotInSkillManager = {
            Handle = "h3ee0c6bage095g44b1g93a3ga464220f42b7",
            Text = "I cannot unlearn a skill I do not have.",
            ContextDescription = [[Warning when trying to unlearn a skill the character doesn't have (failsafe).]],
        },
    },
}
Epip.RegisterFeature("UnlearnSkills", Unlearn)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_UnlearnSkill : NetLib_Message_Character
---@field SkillID skill

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char Character
---@param skillID skill
---@return boolean, Features.UnlearnSkills.CannotUnlearnReason? -- Whether the character can unlearn the skill (in the case of being unable to)
function Unlearn.CanUnlearn(char, skillID)
    local playerData = char.SkillManager.Skills[skillID]
    local stat = Stats.Get("StatsLib_StatsEntry_SkillData", skillID)
    local REASONS = Unlearn.CANNOT_UNLEARN_REASONS
    local canUnlearn = false
    local reason = nil

    if not stat then
        reason = REASONS.SKILL_DOESNT_EXIST
        Unlearn:LogError("Tried to unlearn skill that doesn't exist: " .. skillID)
    elseif not playerData then -- Failsafe; necessary for edgecases when skill tooltips are displayed after the character unlearnt the skill
        reason = REASONS.NOT_IN_SKILLMANAGER
    elseif playerData.CauseListSize > 0 then -- This and the condition after are already checked for by Character.IsSkillInnate(), but we wanted a different message for them.
        reason = REASONS.GRANTED_BY_EXTERNAL_SOURCE
    elseif playerData.ZeroMemory then
        reason = REASONS.ZERO_MEMORY
    elseif Character.IsInCombat(char) then
        reason = REASONS.IN_COMBAT
    elseif Unlearn.IsSkillBlocked(skillID) then
        reason = REASONS.BLACKLISTED

        -- Easter egg messages.
        if EpicEncounters.IsEnabled() then
            if skillID == Meditate.MEDITATE_SKILL_ID then
                reason = REASONS.EE_SPECIAL_NEXUS_MEDITATE
            elseif skillID == SourceInfusion.SOURCE_INFUSE_SKILL_ID then
                reason = REASONS.EE_SPECIAL_SOURCE_INFUSE
            end
        end
    elseif Character.IsSkillInnate(char, skillID) then
        reason = REASONS.INNATE
    else
        canUnlearn = true
    end

    return canUnlearn, reason
end

---@param skillID skill
---@return boolean
function Unlearn.IsSkillBlocked(skillID)
    return Unlearn.BLOCKED_SKILLS[skillID] == true
end
