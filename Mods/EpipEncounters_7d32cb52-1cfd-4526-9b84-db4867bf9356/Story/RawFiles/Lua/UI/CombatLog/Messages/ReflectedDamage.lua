
local Log = Client.UI.CombatLog

---@class CombatLogReflectedDamageMessage : CombatLogDamageMessage

---@type CombatLogReflectedDamageMessage
local _Reflect = {
    PATTERN = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> was hit for <font color="#(%x%x%x%x%x%x)">(%d+) (.+) Damage%(reflected%)</font></font>',
    Type = "ReflectedDamage",
}
Inherit(_Reflect, Log.MessageTypes.Damage)
Log.MessageTypes.ReflectedDamage = _Reflect

---------------------------------------------
-- METHODS
---------------------------------------------

function _Reflect.Create(charName, charColor, damageType, amount, color)
    ---@type CombatLogReflectedDamageMessage
    local obj = Log.MessageTypes.Damage.Create(charName, charColor, damageType, amount, color)
    Inherit(obj, _Reflect)
    obj.Type = "ReflectedDamage"

    return obj
end

function _Reflect:CanMerge(msg) return false end -- TODO should these merge?

function _Reflect:ToString()
    local msg = Log.MessageTypes.Damage.ToString(self)

    msg = string.gsub(msg, " damage ", " reflected damage ")

    return msg
end

---------------------------------------------
-- PARSING
---------------------------------------------

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, dmgColor, dmgAmount, dmgType = message:match(_Reflect.PATTERN)

    if charColor then
        obj = _Reflect.Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    end

    return obj
end)