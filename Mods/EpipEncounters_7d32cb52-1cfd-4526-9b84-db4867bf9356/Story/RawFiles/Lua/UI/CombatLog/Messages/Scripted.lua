
---------------------------------------------
-- Handler for generic "X: Y" messages,
-- mainly intended to cover messages coming from behaviour scripting.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Scripted : UI.CombatLog.Messages.Character
---@field PATTERN pattern
---@field Text string
---@field Color string
local _ScriptedMessage = {
    PATTERN = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: <font color="(%x%x%x%x%x%x)">(.+)</font>',
    PATTERN_ALT = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: (.+)',
}
Log:RegisterClass("UI.CombatLog.Messages.Scripted", _ScriptedMessage, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(_ScriptedMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a scripted message.
---@param charName string
---@param charColor htmlcolor
---@param text string
---@param msgColor htmlcolor
---@return UI.CombatLog.Messages.Scripted
function _ScriptedMessage:Create(charName, charColor, text, msgColor)
    ---@type UI.CombatLog.Messages.Scripted
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Text = text,
        Color = msgColor or Log.COLORS.TEXT,
    })
end

---@override
function _ScriptedMessage:ToString()
    local msg = Text.Format("%s: %s", {
        FormatArgs = {
            {Text = self.CharacterName, Color = self.CharacterColor},
            {Text = self.Text, Color = self.Color},
        },
    })

    return msg
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, msgColor, text = message:match(_ScriptedMessage.PATTERN)

    if charColor then
        obj = _ScriptedMessage:Create(charName, charColor, text, msgColor)
    else
        charColor, charName, text = message:match(_ScriptedMessage.PATTERN_ALT)
        msgColor = Log.COLORS.TEXT

        if charColor then
            obj = _ScriptedMessage:Create(charName, charColor, text, msgColor)
        end
    end

    return obj
end)