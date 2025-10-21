
---------------------------------------------
-- Base class for messages that reference a character.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Character : UI.CombatLog.Message
---@field CharacterName string
---@field CharacterColor string
local _CharacterMessage = {}
Log:RegisterClass("UI.CombatLog.Messages.Character", _CharacterMessage, {"UI.CombatLog.Message"})
Log.RegisterMessageHandler(_CharacterMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns a color-formatted label of the character involved with this message.
---@return string
function _CharacterMessage:GetCharacterLabel()
    return Text.Format(self.CharacterName, {Color = self.CharacterColor})
end

---@override
function _CharacterMessage:CanMerge(msg)
    ---@cast msg UI.CombatLog.Messages.Character
    return msg:ImplementsClass("UI.CombatLog.Messages.Character") and self.CharacterName == msg.CharacterName -- Can merge into messages of the same character.
end
