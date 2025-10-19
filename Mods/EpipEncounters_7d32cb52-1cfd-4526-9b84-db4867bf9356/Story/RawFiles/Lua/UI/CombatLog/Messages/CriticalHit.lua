
---------------------------------------------
-- Handler for "X dealt a Critical Hit to Y" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.CriticalHit : UI.CombatLog.Messages.CharacterInteraction
local _CriticalHit = {
    CRITICAL_HIT_MESSAGE_TSKHANDLE = "he1a120c4g47beg4540gbc3dgd979ecef67d8", -- "[1] dealt a [2] to [3]"
    CRITICAL_HIT_TSKHANDLE = "h0a6c96bcg5d64g4226gb2eegc14f09676f65", -- "Critical Hit"

    CRITICAL_HIT_COLOR = "C80030",
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
            {Text = "critical hit", Color = self.CRITICAL_HIT_COLOR},
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
    local pattern = Text.FormatLarianTranslatedString(_CriticalHit.CRITICAL_HIT_MESSAGE_TSKHANDLE,
        [[<font color="#(%x%x%x%x%x%x)">(.+)</font>]],
        [[<font color="#C80030">]] .. Text.GetTranslatedString(_CriticalHit.CRITICAL_HIT_TSKHANDLE) .. [[</font>]], -- This keyword is colored red.
        [[<font color="#(%x%x%x%x%x%x)">(.+)</font>]]
    )
    local charColor, charName, targetColor, targetName = message:match(pattern)
    if charColor then
        obj = _CriticalHit:Create(charName, charColor, targetName, targetColor)
    end
    return obj
end)