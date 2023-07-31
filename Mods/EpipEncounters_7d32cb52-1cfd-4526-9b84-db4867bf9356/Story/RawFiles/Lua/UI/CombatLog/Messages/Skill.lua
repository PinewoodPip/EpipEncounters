
local Log = Client.UI.CombatLog

---@alias SkillTargetType "Character" | "Ground" | "Self"

---@class CombatLogSkillMessage : CombatLogCharacterMessage
---@field Skill string
---@field SkillColor string
---@field Target SkillTargetType
---@field TargetCharacter string?
---@field TargetCharacterColor string?
local _Skill = {
    PATTERN = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> u?s?e?d?c?a?s?t? <font color="#(%x%x%x%x%x%x)">(.+)</font></font>',
    PATTERN_CHARACTER = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> used <font color="#(%x%x%x%x%x%x)">(.+)</font> on <font color="#(%x%x%x%x%x%x)">(.+)</font></font>',
    PATTERN_GROUND = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> cast <font color="#(%x%x%x%x%x%x)">(.+)</font> on the ground</font>',
    Type = "Skill",
    TARGET_TYPES = {
        CHARACTER = "Character",
        GROUND = "Ground",
        SELF = "Self",
    }
}
Inherit(_Skill, Log.MessageTypes.Character)
Log.MessageTypes.Skill = _Skill

---------------------------------------------
-- METHODS
---------------------------------------------

---@param charName string
---@param charColor string
---@param skillName string
---@param skillColor string
---@param targetType SkillTargetType
---@param targetName string?
---@param targetColor string?
function _Skill.Create(charName, charColor, skillName, skillColor, targetType, targetName, targetColor)
    ---@type CombatLogSkillMessage
    local obj = Log.MessageTypes.Character.Create(charName, charColor)
    Inherit(obj, _Skill)

    obj.Skill = skillName
    obj.SkillColor = skillColor
    obj.Target = targetType
    obj.TargetCharacter = targetName
    obj.TargetCharacterColor = targetColor

    return obj
end

function _Skill:CanMerge(msg) return false end

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
        obj = _Skill.Create(charName, charColor, skillName, skillColor, targetType, targetName, targetColor)
    end

    return obj
end)