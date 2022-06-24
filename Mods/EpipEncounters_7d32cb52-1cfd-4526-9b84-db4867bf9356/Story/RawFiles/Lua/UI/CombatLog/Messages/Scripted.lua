
local Log = Client.UI.CombatLog

---@class CombatLogScriptedMessage : CombatLogCharacterMessage
---@field PATTERN pattern
---@field Text string
---@field Color string

---@type CombatLogScriptedMessage
local _ScriptedMessage = {
    PATTERN = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: <font color="(%x%x%x%x%x%x)">(.+)</font>',
    PATTERN_ALT = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: (.+)',
    Type = "Scripted",
}
setmetatable(_ScriptedMessage, {__index = Log.MessageTypes.Character})
Log.MessageTypes.Scripted = _ScriptedMessage

---------------------------------------------
-- METHODS
---------------------------------------------

function _ScriptedMessage.Create(charName, charColor, text, msgColor)
    ---@type CombatLogSourceGenerationMessage
    local obj = {}
    setmetatable(obj, {__index = _ScriptedMessage})

    obj.Text = text
    obj.CharacterColor = charColor
    obj.CharacterName = charName
    obj.Color = msgColor or Log.COLORS.TEXT

    return obj
end

function _ScriptedMessage:CanMerge(msg) return false end

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

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, msgColor, text = message:match(_ScriptedMessage.PATTERN)

    if charColor then
        obj = _ScriptedMessage.Create(charName, charColor, text, msgColor)
    else
        charColor, charName, text = message:match(_ScriptedMessage.PATTERN_ALT)
        msgColor = Log.COLORS.TEXT

        if charColor then
            obj = _ScriptedMessage.Create(charName, charColor, text, msgColor)
        end
    end

    return obj
end)