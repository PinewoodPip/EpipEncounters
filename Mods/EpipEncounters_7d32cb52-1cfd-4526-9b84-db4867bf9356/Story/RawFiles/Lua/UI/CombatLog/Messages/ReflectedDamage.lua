
---------------------------------------------
-- Handler for "X was hit for Y Damage (reflected)" messages.
---------------------------------------------

local Log = Client.UI.CombatLog
local DamageClass = Log:GetClass("UI.CombatLog.Messages.Damage")

---@class UI.CombatLog.Messages.ReflectedDamage : UI.CombatLog.Messages.Damage
local _Reflect = {
    REFLECTED_TSKHANDLE = "h359e50f7g14f3g476bg8717g92e9a23576ef", -- "(reflected)"

    REFLECTED_DAMAGE_PATTERN = [[<font color="#(%x%x%x%x%x%x)">[1][2]</font>]], -- Param is "(reflected)" label.
}
Log:RegisterClass("UI.CombatLog.Messages.ReflectedDamage", _Reflect, {"UI.CombatLog.Messages.Damage"})
Log.RegisterMessageHandler(_Reflect)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a reflection message.
---@param charName UI.CombatLog.Messages.Damage
---@param charColor htmlcolor
---@param damageType string
---@param amount string
---@param color htmlcolor
---@return UI.CombatLog.Messages.ReflectedDamage
function _Reflect.Create(charName, charColor, damageType, amount, color)
    ---@type UI.CombatLog.Messages.ReflectedDamage
    local obj = _Reflect:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Damage = {
            {
                Type = damageType,
                Amount = tonumber(amount),
                Color = color,
                Hits = 1,
                HitTime = Ext.MonotonicTime(),
            },
        },
    })
    return obj
end

---@override
function _Reflect:ToString()
    local msg = DamageClass.ToString(self)

    msg = string.gsub(msg, " damage ", " reflected damage ")

    return msg
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local pattern = Text.FormatLarianTranslatedString(Log.CHARACTER_RECEIVED_ACTION_TSKHANDLE,
        _Reflect.KEYWORD_PATTERN,
        Text.GetTranslatedString(_Reflect.HIT_TSKHANDLE),

        -- "X damage(reflected)"; lack of space is intentional (vanilla oversight).
        Text.FormatLarianTranslatedString(_Reflect.REFLECTED_DAMAGE_PATTERN,
            Text.FormatLarianTranslatedString(Log.DAMAGE_TSKHANDLE, "(%d+) (.+)"),
            Text.EscapePatternCharacters(Text.GetTranslatedString(_Reflect.REFLECTED_TSKHANDLE)) -- This string has parenthesis in English, thus must be escaped for the pattern to work.
        )
    )
    local charColor, charName, dmgColor, dmgAmount, dmgType = message:match(pattern)
    if charColor then
        obj = _Reflect.Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    end
    return obj
end)