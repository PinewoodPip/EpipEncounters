
local Log = Client.UI.CombatLog

---@class CombatLogSourceGenerationMessage : CombatLogCharacterMessage
---@field PATTERN_NEXT_ROUND pattern
---@field Text string
---@field Color string
local _SourceGenMessage = {
    PATTERN_NEXT_ROUND = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: <font color="(%x%x%x%x%x%x)">(.+)</font>',
    Type = "SourceGeneration",
}
setmetatable(_SourceGenMessage, {__index = Log.MessageTypes.Character})
Log.MessageTypes.SourceGeneration = _SourceGenMessage

---------------------------------------------
-- METHODS
---------------------------------------------

function _SourceGenMessage.Create(charName, charColor, text, msgColor)
    ---@type CombatLogSourceGenerationMessage
    local obj = {}
    setmetatable(obj, {__index = _SourceGenMessage})

    obj.Text = text
    obj.CharacterColor = charColor
    obj.CharacterName = charName
    obj.Color = msgColor

    return obj
end

function _SourceGenMessage:CanMerge(msg) return false end

function _SourceGenMessage:ToString()
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
    local charColor, charName, msgColor, text = message:match(_SourceGenMessage.PATTERN_NEXT_ROUND)

    if charColor then
        obj = _SourceGenMessage.Create(charName, charColor, text, msgColor)
    end

    return obj
end)