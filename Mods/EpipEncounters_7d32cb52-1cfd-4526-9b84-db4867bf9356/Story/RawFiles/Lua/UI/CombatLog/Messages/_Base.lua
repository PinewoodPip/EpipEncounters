
---------------------------------------------
-- Base class for message handlers.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Message : Class
---@field Type UI.CombatLog.MessageType
local _CombatLogMessage = {}
Log:RegisterClass("UI.CombatLog.Message", _CombatLogMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Converts the message object to a string.
---@virtual
---@return string
function _CombatLogMessage:ToString() return "" end

---Merges 2 messages together.
---@virtual
---@param msg UI.CombatLog.Message
---@diagnostic disable-next-line: unused-local
function _CombatLogMessage:CombineWith(msg) end -- TODO rename

---Returns whether another message can be merged with this one.
---@param msg UI.CombatLog.Message
---@return boolean
---@diagnostic disable-next-line: unused-local
function _CombatLogMessage:CanMerge(msg)
    return false
end