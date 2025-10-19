
---------------------------------------------
-- Handler for "X Action Points preserved" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.APPreservation : UI.CombatLog.Messages.Character
---@field PATTERN pattern
---@field COLOR string
---@field AP integer
local APPreservation = {
    AP_PRESERVED_TSKHANDLE = "hc0dcc2c7g3fe4g4292g9492g16bd87b30185", -- "Action Points preserved"
    PATTERN = '<font color="#FFAB00">(.+): (%d+) [1]</font>',
    COLOR = "FFAB00", -- This message is oddly distinctive due to being a DOS1 leftover.
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
    local pattern = Text.ReplaceLarianPlaceholders(APPreservation.PATTERN, {
        Text.GetTranslatedString(APPreservation.AP_PRESERVED_TSKHANDLE)
    })
    local charName, ap = message:match(pattern)
    if charName then
        obj = APPreservation:Create(charName, ap)
    end
    return obj
end)