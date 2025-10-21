
---------------------------------------------
-- Handler for status applied/removed messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Status : UI.CombatLog.Messages.Character
---@field Statuses UI.CombatLog.Messages.Status.Entry[]
---@field LosingStatuses boolean
local _StatusMessage = {
    STATUS_APPLIED_TSKHANDLE = "hd7eb5503g3894g4ce9ga7b4g26836f5356d5", -- "[1] has the status: [3]"
    STATUS_REMOVED_TSKHANDLE = "h5e6ac140g634bg46dcg903ag0597244d57c4", -- "[1] no longer has the status: [3]"
}
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
    local statusLabels = {} ---@type string[]
    for i,status in ipairs(self.Statuses) do
        statusLabels[i] = Text.Format(status.Name, {Color = status.Color})
    end

    -- TODO reimplement plural "statuses" label; the game TSKs do not have strings for it,
    -- thus we'd have to add our own.
    local tskHandle = self.LosingStatuses and _StatusMessage.STATUS_REMOVED_TSKHANDLE or _StatusMessage.STATUS_APPLIED_TSKHANDLE
    local msg = Text.FormatLarianTranslatedString(tskHandle,
        self:GetCharacterLabel(),
        Text.Join(statusLabels, ", ")
    )

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

-- Create message objects for applied & removed statuses.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local statusAppliedPattern = Text.FormatLarianTranslatedString(_StatusMessage.STATUS_APPLIED_TSKHANDLE,
        _StatusMessage.KEYWORD_PATTERN,
        _StatusMessage.KEYWORD_PATTERN
    )
    local charColor, charName, statusColor, statusName = message:match(statusAppliedPattern)
    if charColor then
        obj = _StatusMessage:Create(charName, charColor, statusName, statusColor)
    end
    return obj
end)
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local lostStatusPattern = Text.FormatLarianTranslatedString(_StatusMessage.STATUS_REMOVED_TSKHANDLE,
        _StatusMessage.KEYWORD_PATTERN,
        _StatusMessage.KEYWORD_PATTERN
    )
    local charColor, charName, statusColor, statusName = message:match(lostStatusPattern)
    if charColor then
        obj = _StatusMessage:Create(charName, charColor, statusName, statusColor, false)
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