
---------------------------------------------
-- Handler for "X was hit for Y Damage (reflected)" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.ReflectedDamage : UI.CombatLog.Messages.Damage
local _Reflect = {
    PATTERN = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> was hit for <font color="#(%x%x%x%x%x%x)">(%d+) (.+) Damage%(reflected%)</font></font>',
    Type = "ReflectedDamage",
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
            },
        },
    })
    return obj
end

---@override
function _Reflect:ToString()
    local msg = Log.MessageTypes.Damage.ToString(self)

    msg = string.gsub(msg, " damage ", " reflected damage ")

    return msg
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, dmgColor, dmgAmount, dmgType = message:match(_Reflect.PATTERN)

    if charColor then
        obj = _Reflect.Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    end

    return obj
end)