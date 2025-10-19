
---------------------------------------------
-- Handler for "X regained Y from Lifesteal" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Lifesteal : UI.CombatLog.Messages.Damage
local _LifestealMessage = {
    LIFESTEAL_TSKHANDLE = "h071d5329g54c5g4f35g82b9g128f7774a73c", -- "[1] regained [2] using vampiric means..."
}
Log:RegisterClass("UI.CombatLog.Messages.Lifesteal", _LifestealMessage, {"UI.CombatLog.Messages.Damage"})
Log.RegisterMessageHandler(_LifestealMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a lifesteal message.
---@param charName string
---@param charColor htmlcolor
---@param damageType string
---@param amount integer
---@param color htmlcolor
---@return UI.CombatLog.Messages.Lifesteal
function _LifestealMessage:Create(charName, charColor, damageType, amount, color)
    ---@type UI.CombatLog.Messages.Lifesteal
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Damage = {
            {
                Type = damageType,
                Amount = tonumber(amount),
                Color = color,
            },
        },
    })
end

---@override
function _LifestealMessage:ToString()
    local msg = Text.Format("%s regained %s from Lifesteal", {
        Color = Log.COLORS.TEXT,
        FormatArgs = {
            {Text = self.CharacterName, Color = self.CharacterColor},
            {Text = "%s %s", Color = self.Damage[1].Color, FormatArgs = {Text.RemoveTrailingZeros(self.Damage[1].Amount), self.Damage[1].Type}}
        },
    })

    return msg
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local pattern = Text.FormatLarianTranslatedString(_LifestealMessage.LIFESTEAL_TSKHANDLE, _LifestealMessage.KEYWORD_PATTERN, _LifestealMessage.DAMAGE_PATTERN)
    local charColor, charName, dmgColor, dmgAmount, dmgType = message:match(pattern)
    if charColor then
        obj = _LifestealMessage:Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    end
    return obj
end)