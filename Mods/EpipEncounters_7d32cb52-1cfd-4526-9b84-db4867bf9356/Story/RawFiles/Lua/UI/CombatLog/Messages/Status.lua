
local Log = Client.UI.CombatLog

---@class CombatLogStatusMessage : CombatLogCharacterMessage
---@field Statuses CombatLogStatus[]
---@field LosingStatuses boolean

---@class CombatLogStatus
---@field Name string
---@field Color string

---@type CombatLogStatusMessage
local _StatusMessage = {}
setmetatable(_StatusMessage, {__index = Log.MessageTypes.Character})
Log.MessageTypes.Status = _StatusMessage

---------------------------------------------
-- METHODS
---------------------------------------------


---@param charName string
---@param charColor string
---@param statusName string
---@param statusColor string
---@param gained? boolean
function _StatusMessage.Create(charName, charColor, statusName, statusColor, gained)
    if gained == nil then gained = true end

    ---@type CombatLogStatusMessage
    local obj = {}
    setmetatable(obj, {__index = _StatusMessage})

    obj.Type = "Status"
    obj.CharacterName = charName
    obj.CharacterColor = charColor
    obj.Statuses = {{Name = statusName, Color = statusColor}}
    obj.LosingStatuses = not gained

    return obj
end

function _StatusMessage:ToString()
    local statuses = ""

    for i,status in ipairs(self.Statuses) do
        statuses = statuses .. Text.Format(status.Name, {Color = status.Color})

        if i ~= #self.Statuses then
            statuses = statuses .. ", "
        end
    end

    local moreStatusForDisplayString = "status"

    if #self.Statuses > 1 then
        moreStatusForDisplayString = "statuses"
    end

    local msg = ""

    -- if #self.Statuses > 1 then
        -- TODO filter out reappled status
    local word = "gained"
    if self.LosingStatuses then word = "lost" end

    msg = msg .. Text.Format("%s %s the %s %s", {
        Color = Log.COLORS.TEXT,
        FormatArgs = {
            {Text = self.CharacterName, Color = self.CharacterColor},
            word,
            moreStatusForDisplayString,
            statuses,
        }
    })
    -- end

    return msg
end

function _StatusMessage:CombineWith(msg)
    for i,status in ipairs(msg.Statuses) do
        -- TODO make sure they dont repeat
        table.insert(self.Statuses, status)
    end
end

function _StatusMessage:CanMerge(msg)
    return self.Type == msg.Type and self.CharacterName == msg.CharacterName and self.LosingStatuses == msg.LosingStatuses
end

---------------------------------------------
-- PARSING
---------------------------------------------

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local pattern = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> has the status: <font color="#(%x%x%x%x%x%x)">(.+)</font></font>'

    local lostStatusPattern = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> no longer has the status: <font color="#(%x%x%x%x%x%x)">(.+)</font></font>'

    local charColor, charName, statusColor, statusName = message:match(pattern)

    if charColor then
        obj = _StatusMessage.Create(charName, charColor, statusName, statusColor)
    else
        charColor, charName, statusColor, statusName = message:match(lostStatusPattern)

        if charColor then
            obj = _StatusMessage.Create(charName, charColor, statusName, statusColor, false)
        end
    end

    return obj
end)

Log.Hooks.CombineMessage:RegisterHook(function (combined, msg1, msg2)
    if msg1.Message.Type == "Status" and msg2.Message.Type == "Status" then
        msg1.Message:CombineWith(msg2.Message)

        return true
    end

    return combined
end)