
---------------------------------------------
-- Handler for skill cast messages ("X used Y [on Z]").
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Skill : UI.CombatLog.Messages.Character
---@field Skill string
---@field SkillColor htmlcolor
---@field Target UI.CombatLog.Messages.Skill.Type
---@field TargetCharacter string?
---@field TargetCharacterColor string?
local _Skill = {
    PATTERN = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> u?s?e?d?c?a?s?t? <font color="#(%x%x%x%x%x%x)">(.+)</font></font>',
    PATTERN_CHARACTER = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> used <font color="#(%x%x%x%x%x%x)">(.+)</font> on <font color="#(%x%x%x%x%x%x)">(.+)</font></font>',
    PATTERN_GROUND = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> cast <font color="#(%x%x%x%x%x%x)">(.+)</font> on the ground</font>',
    TARGET_TYPES = {
        CHARACTER = "Character",
        GROUND = "Ground",
        SELF = "Self",
    }
}
Log:RegisterClass("UI.CombatLog.Messages.Skill", _Skill, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(_Skill)

---@alias UI.CombatLog.Messages.Skill.Type "Character" | "Ground" | "Self"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a skill message.
---@param charName string
---@param charColor string
---@param skillName string
---@param skillColor string
---@param targetType UI.CombatLog.Messages.Skill.Type
---@param targetName string?
---@param targetColor string?
function _Skill:Create(charName, charColor, skillName, skillColor, targetType, targetName, targetColor)
    ---@type UI.CombatLog.Messages.Skill
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,

        Skill = skillName,
        SkillColor = skillColor,
        Target = targetType,
        TargetCharacter = targetName,
        TargetCharacterColor = targetColor,
    })
end

---@override
function _Skill:ToString()
    local targetStr = ""

    if self.Target == self.TARGET_TYPES.GROUND then
        targetStr = "on the ground"
    elseif self.Target == self.TARGET_TYPES.CHARACTER then
        targetStr = Text.Format("on %s", {
            FormatArgs = {
                {Text = self.TargetCharacter, Color = self.TargetCharacterColor},
            },
        })
    end

    local msg = Text.Format("%s used %s %s", {
        Color = Log.COLORS.TEXT,
        FormatArgs = {
            {Text = self.CharacterName, Color = self.CharacterColor},
            {Text = self.Skill, Color = self.SkillColor},
            targetStr,
        },
    })

    return msg
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local targetType = _Skill.TARGET_TYPES.CHARACTER
    local charColor, charName, skillColor, skillName, targetColor, targetName = message:match(_Skill.PATTERN_CHARACTER)

    -- Self-cast
    if not charColor then
        charColor, charName, skillColor, skillName = message:match(_Skill.PATTERN)

        targetType = _Skill.TARGET_TYPES.SELF
    end

    -- Ground-cast
    if not charColor then
        charColor, charName, skillColor, skillName = message:match(_Skill.PATTERN_GROUND)

        targetType = _Skill.TARGET_TYPES.GROUND
    end

    if charColor then
        obj = _Skill:Create(charName, charColor, skillName, skillColor, targetType, targetName, targetColor)
    end

    return obj
end)