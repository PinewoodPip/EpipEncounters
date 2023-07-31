
local Log = Client.UI.CombatLog

---@class CombatLogCharacterMessage : CombatLogMessage
---@field CharacterName string
---@field CharacterColor string
local _CharacterMessage = {}
setmetatable(_CharacterMessage, Log.MessageTypes.Base)
Log.MessageTypes.Character = _CharacterMessage

---------------------------------------------
-- METHODS
---------------------------------------------

function _CharacterMessage.Create(charName, charColor)
    ---@type CombatLogCharacterMessage
    local obj = {
        CharacterName = charName,
        CharacterColor = charColor,
    }
    Inherit(obj, _CharacterMessage)

    return obj
end

function _CharacterMessage:CanMerge(msg)
    return self.CharacterName == msg.CharacterName
end