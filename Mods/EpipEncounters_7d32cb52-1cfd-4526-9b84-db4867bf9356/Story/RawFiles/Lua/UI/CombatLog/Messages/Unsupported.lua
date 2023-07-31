
local Log = Client.UI.CombatLog

---@class CombatLogUnsupportedMessage : CombatLogMessage
---@field Text string
local _CombatLogUnsupportedMessage = {}
setmetatable(_CombatLogUnsupportedMessage, {__index = Client.UI.CombatLog.MessageTypes.Base})
Client.UI.CombatLog.MessageTypes.Unsupported = _CombatLogUnsupportedMessage

---------------------------------------------
-- METHODS
---------------------------------------------

---@param str string
---@return CombatLogUnsupportedMessage
function _CombatLogUnsupportedMessage.Create(str)
    ---@type CombatLogUnsupportedMessage
    local obj = {Type = "Unsupported", Text = str}

    setmetatable(obj, {__index = _CombatLogUnsupportedMessage})

    return obj
end

function _CombatLogUnsupportedMessage:ToString() return self.Text end