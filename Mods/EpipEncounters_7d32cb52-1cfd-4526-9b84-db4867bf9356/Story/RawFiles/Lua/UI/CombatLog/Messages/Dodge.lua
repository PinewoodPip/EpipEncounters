
local Log = Client.UI.CombatLog

---@class CombatLogDodgeMessage : CombatLogCharacterInteractionMessage
local _Dodge = {
    Type = "Dodge",
    PATTERN = "<font color=\"#DBDBDB\"><font color=\"#(%x%x%x%x%x%x)\">(.+)</font> missed <font color=\"#(%x%x%x%x%x%x)\">(.+)</font></font>",
}
Inherit(_Dodge, Log.MessageTypes.CharacterInteraction)
Client.UI.CombatLog.MessageTypes.Dodge = _Dodge

---------------------------------------------
-- METHODS
---------------------------------------------

---@param charName string
---@param charColor string
---@param targetName string
---@param targetColor string
---@return CombatLogDodgeMessage
function _Dodge.Create(charName, charColor, targetName, targetColor)
    ---@type CombatLogDodgeMessage
    local obj = Log.MessageTypes.CharacterInteraction.Create(charName, charColor, targetName, targetColor)

    Inherit(obj, _Dodge)

    return obj
end

function _Dodge:CanMerge(msg) return false end

function _Dodge:ToString()
    local msg = Text.Format("%s missed %s", {
        FormatArgs = {
            {Text = self.CharacterName, Color = self.CharacterColor},
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
    local charColor, charName, targetColor, targetName = message:match(_Dodge.PATTERN)

    if charColor then
        obj = _Dodge.Create(charName, charColor, targetName, targetColor)
    end

    return obj
end)