
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

local TSK = {
    Msg_StatusesApplied = Log:RegisterTranslatedString({
        Handle = "h62429127g04c8g406fga3cag4a440c430c2f",
        Text = [[%s has the statuses: %s]],
        ContextDescription = [[Message for a character gaining multiple statuses. Params are character name and statuses gained (ex. "<character> has the statuses: Hasted, Fortified")]],
    }),
    Msg_StatusesRemoved = Log:RegisterTranslatedString({
        Handle = "h5fa98726g2c12g453fg80afg6d315b23be7c",
        Text = [[%s no longer has the statuses: %s]],
        ContextDescription = [[Message for a character losing multiple statuses. Params are character name and statuses lost (ex. "<character> no longer has the statuses: Hasted, Fortified")]],
    }),
}

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
    local msg ---@type string
    local statusLabels = {} ---@type string[]
    for i,status in ipairs(self.Statuses) do
        statusLabels[i] = Text.Format(status.Name, {Color = status.Color})
    end

    -- Check whether plural should be used and whether it is supported by the current language;
    -- The vanilla game has no plural TSKs for "statuses", so displaying the plural is only supported if the Epip localization has it.
    -- Otherwise, the singular form is used as fallback.
    local usePlural = #statusLabels > 1 and (self.LosingStatuses and (Text.GetTranslatedStringTranslation(TSK.Msg_StatusesRemoved.Handle) ~= nil) or (Text.GetTranslatedStringTranslation(TSK.Msg_StatusesApplied.Handle) ~= nil))

    -- Format string
    if usePlural then
        -- Show multiple statuses
        local tsk = self.LosingStatuses and TSK.Msg_StatusesRemoved or TSK.Msg_StatusesApplied
        msg = tsk:Format(
            Text.Format(self.CharacterName, {Color = self.CharacterColor}),
            Text.Join(statusLabels, ", ")
        )
    else
        -- Show single status
        local tskHandle = self.LosingStatuses and _StatusMessage.STATUS_REMOVED_TSKHANDLE or _StatusMessage.STATUS_APPLIED_TSKHANDLE
        msg = Text.FormatLarianTranslatedString(tskHandle,
            self:GetCharacterLabel(),
            Text.Join(statusLabels, ", ")
        )
    end

    return msg
end

function _StatusMessage:MergeWith(msg)
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
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local statusAppliedPattern = Text.FormatLarianTranslatedString(_StatusMessage.STATUS_APPLIED_TSKHANDLE,
        _StatusMessage.KEYWORD_PATTERN,
        _StatusMessage.KEYWORD_PATTERN
    )
    local charColor, charName, statusColor, statusName = ev.RawMessage:match(statusAppliedPattern)
    if charColor then
        ev.ParsedMessage = _StatusMessage:Create(charName, charColor, statusName, statusColor)
    end
end)
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local lostStatusPattern = Text.FormatLarianTranslatedString(_StatusMessage.STATUS_REMOVED_TSKHANDLE,
        _StatusMessage.KEYWORD_PATTERN,
        _StatusMessage.KEYWORD_PATTERN
    )
    local charColor, charName, statusColor, statusName = ev.RawMessage:match(lostStatusPattern)
    if charColor then
        ev.ParsedMessage = _StatusMessage:Create(charName, charColor, statusName, statusColor, false)
    end
end)

-- Merge consecutive status messages from the same character.
local statusClassName = _StatusMessage:GetClassName()
Log.Hooks.CombineMessage:Subscribe(function (ev)
    local prevMsg, newMsg = ev.PreviousMessage.Message, ev.NewMessage.Message
    if prevMsg:GetClassName() == statusClassName and newMsg:GetClassName() == statusClassName then
        prevMsg:MergeWith(newMsg)
        ev.Combined = true
    end
end)