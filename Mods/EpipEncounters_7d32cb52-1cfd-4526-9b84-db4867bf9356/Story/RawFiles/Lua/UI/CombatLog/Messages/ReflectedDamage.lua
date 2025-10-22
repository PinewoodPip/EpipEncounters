
---------------------------------------------
-- Handler for "X was hit for Y Damage (reflected)" messages.
---------------------------------------------

local Log = Client.UI.CombatLog
local DamageClass = Log:GetClass("UI.CombatLog.Messages.Damage")

---@class UI.CombatLog.Messages.ReflectedDamage : UI.CombatLog.Messages.Damage
local _Reflect = {
    REFLECTED_TSKHANDLE = "h5c7e82f0gf29dg4dd8g973eg7ba53972207f", -- "(reflected)"

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

    -- Add "(reflected)" suffix
    msg = msg .. " " .. Text.GetTranslatedString(_Reflect.REFLECTED_TSKHANDLE)

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
        -- This string has parenthesis in English, thus must be escaped for the pattern to work.
        [[<font color="#(%x%x%x%x%x%x)">(%d+) (.+)]] .. Text.EscapePatternCharacters(Text.GetTranslatedString(_Reflect.REFLECTED_TSKHANDLE)) .. [[</font>]]
    )
    local charColor, charName, dmgColor, dmgAmount, dmgType
    local params = {message:match(pattern)}
    if tonumber(params[2]) then -- In some languages (ex. Spanish) the damage comes before character name.
        charColor, charName, dmgColor, dmgAmount, dmgType = params[4], params[5], params[1], params[2], params[3]
    else
        charColor, charName, dmgColor, dmgAmount, dmgType = table.unpack(params)
    end
    if charColor then
        obj = _Reflect.Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    end
    return obj
end)