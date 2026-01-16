
---------------------------------------------
-- Handler for "X took no damage" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.NoDamage : UI.CombatLog.Messages.Character
local NoDamage = {
    NO_DAMAGE_TSKHANDLE = "hdf07d3a2gf1c7g44acg9149g3623f1ccf3bf", -- "[1] took no damage"
}
Log:RegisterClass("UI.CombatLog.Messages.NoDamage", NoDamage, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(NoDamage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a no damage message.
---@param charName string
---@param charColor string
---@return UI.CombatLog.Messages.NoDamage
function NoDamage:Create(charName, charColor)
    ---@type UI.CombatLog.Messages.NoDamage
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
    })
end

---@override
function NoDamage:ToString()
    return Text.FormatLarianTranslatedString(NoDamage.NO_DAMAGE_TSKHANDLE, self:GetCharacterLabel())
end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

-- Create message objects.
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local message = ev.RawMessage
    local pattern = Text.FormatLarianTranslatedString(NoDamage.NO_DAMAGE_TSKHANDLE, NoDamage.KEYWORD_PATTERN)
    local charColor, charName = message:match(pattern)
    if charName then
        ev.ParsedMessage = NoDamage:Create(charName, charColor)
    end
end)
