
---------------------------------------------
-- Fallback handler for combat log messages that lack them.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Unsupported : UI.CombatLog.Message
---@field Text string The raw message.
local _CombatLogUnsupportedMessage = {}
Log:RegisterClass("UI.CombatLog.Messages.Unsupported", _CombatLogUnsupportedMessage, {"UI.CombatLog.Message"})
Log.RegisterMessageHandler(_CombatLogUnsupportedMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an unsupported message.
---@param str string
---@return UI.CombatLog.Messages.Unsupported
function _CombatLogUnsupportedMessage:Create(str)
    ---@type UI.CombatLog.Messages.Unsupported
    return self:__Create({
        Text = str
    })
end

---@override
function _CombatLogUnsupportedMessage:ToString()
    return self.Text
end
