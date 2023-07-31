
local Log = Client.UI.CombatLog

---@class CombatLogCharacterInteractionMessage : CombatLogCharacterMessage
---@field TargetName string
---@field TargetColor string
local _CharacterInteractionMessage = {
    Type = "CharacterInteraction",
}
Inherit(_CharacterInteractionMessage, Log.MessageTypes.Character)
Log.MessageTypes.CharacterInteraction = _CharacterInteractionMessage

---------------------------------------------
-- METHODS
---------------------------------------------

---@param charName string
---@param charColor string
---@param targetName string
---@param targetColor string
---@return CombatLogCharacterInteractionMessage
function _CharacterInteractionMessage.Create(charName, charColor, targetName, targetColor)
    ---@type CombatLogCharacterInteractionMessage
    local obj = Log.MessageTypes.Character.Create(charName, charColor)

    obj.TargetName = targetName
    obj.TargetColor = targetColor

    Inherit(obj, _CharacterInteractionMessage)

    return obj
end

function _CharacterInteractionMessage:CanMerge(msg)
    return self.CharacterName == msg.CharacterName and self.TargetName == msg.TargetName
end