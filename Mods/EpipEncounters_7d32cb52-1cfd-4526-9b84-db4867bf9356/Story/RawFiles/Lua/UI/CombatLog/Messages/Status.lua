
---------------------------------------------
-- Handler for status applied/removed messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Status : UI.CombatLog.Messages.Character
---@field Statuses UI.CombatLog.Messages.Status.Entry[]
---@field LosingStatuses boolean
local _StatusMessage = {}
Log:RegisterClass("UI.CombatLog.Messages.Status", _StatusMessage, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(_StatusMessage)

---@class UI.CombatLog.Messages.Status.Entry
---@field Name string
---@field Color string

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a status message.
---@param charName string
---@param charColor htmlcolor
---@param statusName string
---@param statusColor htmlcolor
---@param gained? boolean True if the status was applied, false if being removed. Defaults to true.
function _StatusMessage:Create(charName, charColor, statusName, statusColor, gained)
    if gained == nil then gained = true end

    ---@type UI.CombatLog.Messages.Status
    local obj = self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Statuses = {{Name = statusName, Color = statusColor}},
        LosingStatuses = not gained
    })
    return obj
end

---@override
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
    if msg:ImplementsClass("UI.CombatLog.Messages.Status") then
        ---@cast msg UI.CombatLog.Messages.Status
        for _,status in ipairs(msg.Statuses) do
            -- TODO make sure they dont repeat?
            table.insert(self.Statuses, status)
        end
    end
end

function _StatusMessage:CanMerge(msg)
    ---@cast msg UI.CombatLog.Messages.Status
    return msg:ImplementsClass("UI.CombatLog.Messages.Status") and self.CharacterName == msg.CharacterName and self.LosingStatuses == msg.LosingStatuses
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local pattern = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> has the status: <font color="#(%x%x%x%x%x%x)">(.+)</font></font>'

    local lostStatusPattern = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> no longer has the status: <font color="#(%x%x%x%x%x%x)">(.+)</font></font>'

    local charColor, charName, statusColor, statusName = message:match(pattern)

    if charColor then
        obj = _StatusMessage:Create(charName, charColor, statusName, statusColor)
    else
        charColor, charName, statusColor, statusName = message:match(lostStatusPattern)

        if charColor then
            obj = _StatusMessage:Create(charName, charColor, statusName, statusColor, false)
        end
    end

    return obj
end)

-- Merge consecutive status messages from the same character.
local statusClassName = _StatusMessage:GetClassName()
Log.Hooks.CombineMessage:RegisterHook(function (combined, msg1, msg2)
    if msg1.Message:GetClassName() == statusClassName and msg2.Message:GetClassName() == statusClassName then
        msg1.Message:CombineWith(msg2.Message)
        combined = true
    end
    return combined
end)