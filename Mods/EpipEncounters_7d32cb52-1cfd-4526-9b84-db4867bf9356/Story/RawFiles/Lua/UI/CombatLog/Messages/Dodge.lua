
---------------------------------------------
-- Handler for "X dodged Y" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Dodge : UI.CombatLog.Messages.CharacterInteraction
local _Dodge = {
    Type = "Dodge",
    PATTERN = "<font color=\"#DBDBDB\"><font color=\"#(%x%x%x%x%x%x)\">(.+)</font> missed <font color=\"#(%x%x%x%x%x%x)\">(.+)</font></font>",
}
Log:RegisterClass("UI.CombatLog.Messages.Dodge", _Dodge, {"UI.CombatLog.Messages.CharacterInteraction"})
Log.RegisterMessageHandler(_Dodge)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a dodge message.
---@param charName string
---@param charColor string
---@param targetName string
---@param targetColor string
---@return UI.CombatLog.Messages.Dodge
function _Dodge:Create(charName, charColor, targetName, targetColor)
    ---@type UI.CombatLog.Messages.Dodge
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        TargetName = targetName,
        TargetColor = targetColor,
    })
end

---@override
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

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function(obj, message)
    local charColor, charName, targetColor, targetName = message:match(_Dodge.PATTERN)
    if charColor then
        obj = _Dodge:Create(charName, charColor, targetName, targetColor)
    end
    return obj
end)