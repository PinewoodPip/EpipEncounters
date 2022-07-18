
local Log = Client.UI.CombatLog

---@class CombatLogCriticalHitMessage : CombatLogCharacterInteractionMessage
local _CriticalHit = {
    Type = "CriticalHit",
    PATTERN = "<font color=\"#DBDBDB\"><font color=\"#(%x%x%x%x%x%x)\">(.+)</font> dealt a <font color=\"#C80030\">Critical Hit</font> to <font color=\"#(%x%x%x%x%x%x)\">(.+)</font></font>",
    CRITICAL_COLOR = "C80030",
}
Inherit(_CriticalHit, Log.MessageTypes.CharacterInteraction)
Client.UI.CombatLog.MessageTypes.CriticalHit = _CriticalHit

---------------------------------------------
-- METHODS
---------------------------------------------

---@param charName string
---@param charColor string
---@param targetName string
---@param targetColor string
---@return CombatLogCriticalHitMessage
function _CriticalHit.Create(charName, charColor, targetName, targetColor)
    ---@type CombatLogCriticalHitMessage
    local obj = Log.MessageTypes.CharacterInteraction.Create(charName, charColor, targetName, targetColor)

    Inherit(obj, _CriticalHit)

    return obj
end

function _CriticalHit:CanMerge(msg) return false end

function _CriticalHit:ToString()
    local msg = Text.Format("%s dealt a %s to %s", {
        FormatArgs = {
            {Text = self.CharacterName, Color = self.CharacterColor},
            {Text = "critical hit", Color = self.CRITICAL_COLOR},
            {Text = self.TargetName, Color = self.TargetColor},
        },
        Color = Log.COLORS.TEXT,
    })

    return msg
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Log.Hooks.GetMessageObject:RegisterHook(function(obj, message)
    local charColor, charName, targetColor, targetName = message:match(_CriticalHit.PATTERN)

    if charColor then
        obj = _CriticalHit.Create(charName, charColor, targetName, targetColor)
    end

    return obj
end)