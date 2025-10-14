
---------------------------------------------
-- Base class for messages that involve a target character in addition to a user.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.CharacterInteraction : UI.CombatLog.Messages.Character
---@field TargetName string
---@field TargetColor string
local _CharacterInteractionMessage = {
    Type = "CharacterInteraction",
}
Log:RegisterClass("UI.CombatLog.Messages.CharacterInteraction", _CharacterInteractionMessage, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(_CharacterInteractionMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param charName string
---@param charColor string
---@param targetName string
---@param targetColor string
---@return UI.CombatLog.Messages.CharacterInteraction
function _CharacterInteractionMessage:Create(charName, charColor, targetName, targetColor)
    ---@type UI.CombatLog.Messages.CharacterInteraction
    local instance = self:__Create({
        -- Base class fields
        CharacterName = charName,
        CharacterColor = charColor,

        -- Interaction fields
        TargetName = targetName,
        TargetColor = targetColor,
    })
    return instance
end

---@override
function _CharacterInteractionMessage:CanMerge(msg)
    ---@cast msg UI.CombatLog.Messages.CharacterInteraction
    return msg:ImplementsClass("UI.CombatLog.Messages.CharacterInteraction") and
    self.CharacterName == msg.CharacterName and self.TargetName == msg.TargetName -- Can merge into messages involving the same characters.
end
