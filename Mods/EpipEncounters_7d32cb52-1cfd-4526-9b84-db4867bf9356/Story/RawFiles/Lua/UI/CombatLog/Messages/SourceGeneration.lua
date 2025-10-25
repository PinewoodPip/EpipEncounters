
---------------------------------------------
-- Handler for Epic Encounter's source generation messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.SourceGeneration : UI.CombatLog.Messages.Character
---@field PATTERN_NEXT_ROUND pattern
---@field Text string
---@field Color htmlcolor
local _SourceGenMessage = {
    PATTERN_NEXT_ROUND = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: <font color="(%x%x%x%x%x%x)">(.+)</font>',
}
Log:RegisterClass("UI.CombatLog.Messages.SourceGeneration", _SourceGenMessage, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(_SourceGenMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a source generation message.
---@param charName string
---@param charColor htmlcolor
---@param text string
---@param msgColor htmlcolor
---@return UI.CombatLog.Messages.SourceGeneration
function _SourceGenMessage:Create(charName, charColor, text, msgColor)
    ---@type UI.CombatLog.Messages.SourceGeneration
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Text = text,
        Color = msgColor or Log.COLORS.TEXT,
    })
end

---@override
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

-- Create message objects.
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local charColor, charName, msgColor, text = ev.RawMessage:match(_SourceGenMessage.PATTERN_NEXT_ROUND)
    if charColor then
        ev.ParsedMessage = _SourceGenMessage:Create(charName, charColor, text, msgColor)
    end
end)