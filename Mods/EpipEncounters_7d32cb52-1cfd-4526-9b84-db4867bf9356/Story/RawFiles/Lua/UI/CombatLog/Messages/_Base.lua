
---------------------------------------------
-- Base class for message handlers.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Message : Class
local _CombatLogMessage = {
    KEYWORD_PATTERN = [[<font color="#(%x%x%x%x%x%x)">(.+)</font>]], -- Used to color keywords such as character/skill names or damage instances.
}
Log:RegisterClass("UI.CombatLog.Message", _CombatLogMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Converts the message object to a string.
---@virtual
---@return string -- Does not need to be wrapped in the base combat log color.
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