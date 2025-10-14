
---------------------------------------------
-- Handler for "X Action Points preserved" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.APPreservation : UI.CombatLog.Messages.Character
---@field PATTERN pattern
---@field COLOR string
---@field AP integer
local APPreservation = {
    PATTERN = '<font color="#FFAB00">(.+): (%d+) Action Points preserved</font>',
    COLOR = "FFAB00", -- This message is oddly distinctive due to being a DOS1 leftover.
    Type = "APPreservation",
}
Log:RegisterClass("UI.CombatLog.Messages.APPreservation", APPreservation, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(APPreservation)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an AP preservation message.
---@param charName string
---@param ap integer
---@return UI.CombatLog.Messages.APPreservation
function APPreservation:Create(charName, ap)
    ---@type UI.CombatLog.Messages.APPreservation
    return self:__Create({
        CharacterName = charName,
        AP = ap
    })
end

---@override
function APPreservation:ToString()
    local msg = Text.Format("%s: %s Action Points unspent", {
        FormatArgs = {
            self.CharacterName, self.AP
        },
        Color = self.COLOR,
    })

    return msg
end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charName, ap = message:match(APPreservation.PATTERN)
    if charName then
        obj = APPreservation:Create(charName, ap)
    end
    return obj
end)