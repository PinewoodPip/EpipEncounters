
---@class EpicEncounters.MeditateLib
local Meditate = EpicEncounters.Meditate

---------------------------------------------
-- METHODS
---------------------------------------------

---Attempts to cast the meditate skill.
---Does not queue the skill.
---@param char EsvCharacter
function Meditate.RequestMeditate(char)
    if not Character.GetCurrentSkill(char) then
        Osiris.CharacterUseSkill(char, Meditate.MEDITATE_SKILL_ID, char, 0, 0, 0)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to meditate.
Net.RegisterListener(Meditate.NETMSG_REQUEST_MEDITATE, function (payload)
    local char = payload:GetCharacter()
    Meditate.RequestMeditate(char)
end)