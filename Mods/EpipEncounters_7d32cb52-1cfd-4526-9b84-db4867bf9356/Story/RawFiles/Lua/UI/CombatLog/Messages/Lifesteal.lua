
local Log = Client.UI.CombatLog

---@class CombatLogLifestealMessage : CombatLogDamageMessage
local _LifestealMessage = {
    Type = "Lifesteal",
}
setmetatable(_LifestealMessage, {__index = Log.MessageTypes.Damage})
Log.MessageTypes.Lifesteal = _LifestealMessage

---------------------------------------------
-- METHODS
---------------------------------------------

function _LifestealMessage.Create(charName, charColor, damageType, amount, color)
    local obj = Log.MessageTypes.Damage.Create(charName, charColor, damageType, amount, color)
    setmetatable(obj, {__index = _LifestealMessage})

    obj.Type = _LifestealMessage.Type

    return obj
end

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

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local pattern = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> regained <font color="#(%x%x%x%x%x%x)">(%d+) (.+)</font> using vampiric means...</font>'

    local charColor, charName, dmgColor, dmgAmount, dmgType = message:match(pattern)

    if charColor then
        obj = _LifestealMessage.Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    end

    return obj
end)