
local Log = Client.UI.CombatLog

---------------------------------------------
-- COMBAT LOG MESSAGE OBJECT
---------------------------------------------

---@class DamageInstance
---@field Type string
---@field Amount integer
---@field Color string
---@field Hits integer
---@field HitTime integer

---@class CombatLogMessage
---@field Type string
local _CombatLogMessage = {}
Client.UI.CombatLog.MessageTypes.Base = _CombatLogMessage

---------------------------------------------
-- METHODS
---------------------------------------------

---Converts the message object to a string.
---@return string
function _CombatLogMessage:ToString() return "" end

---Combines 2 messages together.
---@param msg CombatLogMessage
function _CombatLogMessage:CombineWith(msg) end

---Returns whether 2 messages can be combined.
---@param msg CombatLogMessage
---@return boolean
function _CombatLogMessage:CanMerge(msg)
    return false
end