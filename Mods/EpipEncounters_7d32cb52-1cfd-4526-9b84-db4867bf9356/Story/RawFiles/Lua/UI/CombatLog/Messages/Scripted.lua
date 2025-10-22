
---------------------------------------------
-- Handler for generic "X: Y" messages,
-- mainly intended to cover messages coming from behaviour scripting.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Scripted : UI.CombatLog.Messages.Character
---@field PATTERN pattern
---@field Text string
local _ScriptedMessage = {
    MESSAGE_TSKHANDLE = "ha020d932g69e4g4957g998dg9204aa232200", -- "[1]:[2]"
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
---@return UI.CombatLog.Messages.Scripted
function _ScriptedMessage:Create(charName, charColor, text)
    ---@type UI.CombatLog.Messages.Scripted
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Text = text,
    })
end

---@override
function _ScriptedMessage:ToString()
    local msg = Text.Format("%s: %s", {
        FormatArgs = {
            {Text = self.CharacterName, Color = self.CharacterColor},
            self.Text,
        },
    })

    return msg
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    if obj then return obj end -- Do not override any existing messages. Some languages (ex. Polish) use this format for vanilla messages, such as attacks ("<postać> atakuje: ...").
    local pattern = Text.FormatLarianTranslatedString(_ScriptedMessage.MESSAGE_TSKHANDLE,
        _ScriptedMessage.KEYWORD_PATTERN,
        "(.+)"
    )
    local charColor, charName, text = message:match(pattern)
    if charColor then
        obj = _ScriptedMessage:Create(charName, charColor, text)
    end
    return obj
end)