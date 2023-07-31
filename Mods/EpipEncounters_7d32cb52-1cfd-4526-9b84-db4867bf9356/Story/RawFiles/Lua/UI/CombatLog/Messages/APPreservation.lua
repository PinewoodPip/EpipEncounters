
local Log = Client.UI.CombatLog

---@class CombatLogAPPreservationMessage : CombatLogCharacterMessage
---@field PATTERN pattern
---@field COLOR string
---@field AP integer
local _APPreservation = {
    PATTERN = '<font color="#FFAB00">(.+): (%d+) Action Points preserved</font>',
    COLOR = "FFAB00",
    Type = "APPreservation",
}
setmetatable(_APPreservation, {__index = Log.MessageTypes.Character})
Log.MessageTypes.APPreservation = _APPreservation

---------------------------------------------
-- METHODS
---------------------------------------------

function _APPreservation.Create(charName, ap)
    ---@type CombatLogAPPreservationMessage
    local obj = {CharacterName = charName, AP = ap}
    Inherit(obj, _APPreservation)

    return obj
end

function _APPreservation:CanMerge(msg) return false end

function _APPreservation:ToString()
    local msg = Text.Format("%s: %s Action Points unspent", {
        FormatArgs = {
            self.CharacterName, self.AP
        },
        Color = self.COLOR,
    })

    return msg
end

---------------------------------------------
-- PARSING
---------------------------------------------

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charName, ap = message:match(_APPreservation.PATTERN)

    if charName then
        obj = _APPreservation.Create(charName, ap)
    end

    return obj
end)