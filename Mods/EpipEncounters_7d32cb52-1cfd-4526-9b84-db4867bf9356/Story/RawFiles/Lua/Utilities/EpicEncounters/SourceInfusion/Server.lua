
---@class EpicEncounters_SourceInfusionLib
local SourceInfusion = EpicEncounters.SourceInfusion

---------------------------------------------
-- METHODS
---------------------------------------------

---Casts the Source Infusion spell, if possible.
---If char is already busy casting a skill, it will *not* be queued.
---@param char EsvCharacter
function SourceInfusion.RequestInfusion(char)
    local combatID = Character.GetCombatID(char)
    if Character.IsInCombat(char) and Combat.GetActiveCombatant(combatID) == char and not Character.IsCastingSkill(char) then
        Osiris.CharacterUseSkill(char, SourceInfusion.SOURCE_INFUSE_SKILL_ID, char, 0, 0, 0)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to cast the Source Infuse skill.
Net.RegisterListener(SourceInfusion.NETMSG_REQUEST_INFUSE, function (payload)
    local char = payload:GetCharacter()
    SourceInfusion.RequestInfusion(char)
end)