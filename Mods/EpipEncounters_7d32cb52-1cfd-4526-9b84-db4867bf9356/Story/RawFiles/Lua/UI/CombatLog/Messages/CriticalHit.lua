
---------------------------------------------
-- Handler for "X dealt a Critical Hit to Y" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.CriticalHit : UI.CombatLog.Messages.CharacterInteraction
local _CriticalHit = {
    PATTERN = "<font color=\"#DBDBDB\"><font color=\"#(%x%x%x%x%x%x)\">(.+)</font> dealt a <font color=\"#C80030\">Critical Hit</font> to <font color=\"#(%x%x%x%x%x%x)\">(.+)</font></font>",
    CRITICAL_COLOR = "C80030",
}
Log:RegisterClass("UI.CombatLog.Messages.CriticalHit", _CriticalHit, {"UI.CombatLog.Messages.CharacterInteraction"})
Log.RegisterMessageHandler(_CriticalHit)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a critical hit message.
---@param charName string
---@param charColor string
---@param targetName string
---@param targetColor string
---@return UI.CombatLog.Messages.CriticalHit
function _CriticalHit:Create(charName, charColor, targetName, targetColor)
    ---@type UI.CombatLog.Messages.CriticalHit
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        TargetName = targetName,
        TargetColor = targetColor,
    })
end

---@override
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

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function(obj, message)
    local charColor, charName, targetColor, targetName = message:match(_CriticalHit.PATTERN)
    if charColor then
        obj = _CriticalHit:Create(charName, charColor, targetName, targetColor)
    end
    return obj
end)