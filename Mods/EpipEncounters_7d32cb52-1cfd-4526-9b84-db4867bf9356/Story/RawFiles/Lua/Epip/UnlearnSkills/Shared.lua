
---@class Feature_UnlearnSkills : Feature
local Unlearn = {
    BLOCKED_SKILLS = {
        Summon_Cat = true,
        Shout_NexusMeditate = true,
        Shout_SourceInfusion = true,
    }
}
Epip.RegisterFeature("UnlearnSkills", Unlearn)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_UnlearnSkill : NetMessage_Character
---@field SkillID string

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char Character
---@param skillID string
---@return boolean, string -- Whether the character can unlearn the skill, and a string explaining the reason as to why (in the case of being unable to)
function Unlearn.CanUnlearn(char, skillID)
    local playerData = char.SkillManager.Skills[skillID]
    local stat = Stats.Get("SkillData", skillID)
    local canUnlearn = false
    local reason

    if not stat then
        reason = "I cannot unlearn skills that do not exist."
        Unlearn:LogError("Tried to unlearn skill that doesn't exist: " .. skillID)
    elseif playerData.CauseListSize > 0 then -- This and the condition after are already checked for by Character.IsSkillInnate(), but we wanted a different message for them.
        reason = "I cannot unlearn skills granted by external sources."
    elseif playerData.ZeroMemory then
        reason = "I cannot unlearn skills that take up no memory."
    elseif Character.IsInCombat(char) then
        reason = "I cannot unlearn skills while in combat."
    elseif Unlearn.IsSkillBlocked(skillID) then
        reason = "I cannot unlearn this skill."

        -- Easter egg messages.
        if skillID == "Shout_NexusMeditate" then
            reason = "I would lose my special spark if I were to give that up."
        elseif skillID == "Shout_SourceInfusion" then
            reason = "Sourcery is an innate part of who I am; I cannot get rid of it."
        end
    elseif Character.IsSkillInnate(char, skillID) then
        local skillName = Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName)

        reason = Text.Format("%s is an innate skill; it might be unwise to rid myself of it.", {FormatArgs = {skillName}})
    else
        canUnlearn = true
    end

    return canUnlearn, reason
end

---@param skillID string
---@return boolean
function Unlearn.IsSkillBlocked(skillID)
    return Unlearn.BLOCKED_SKILLS[skillID] == true
end