
local Log = Client.UI.CombatLog

---@class CombatLogSurfaceDamage : CombatLogDamageMessage

---@type CombatLogSurfaceDamage
local _Surface = {
    PATTERN = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> was hit for <font color="#(%x%x%x%x%x%x)">(%d+) (.+) Damage</font> by a surface</font>',
    Type = "SurfaceDamage",
}
Inherit(_Surface, Log.MessageTypes.Damage)
Log.MessageTypes.Surface = _Surface

---------------------------------------------
-- METHODS
---------------------------------------------

function _Surface.Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    ---@type CombatLogSurfaceDamage
    local obj = Log.MessageTypes.Damage.Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    Inherit(obj, _Surface)
    obj.Type = "SurfaceDamage"

    return obj
end

function _Surface:ToString()
    local str = Text.Format("%s by a surface", {
        FormatArgs = {
            Log.MessageTypes.Damage.ToString(self),
        },
        Color = Log.COLORS.TEXT,
    })

    return str
end

---------------------------------------------
-- PARSING
---------------------------------------------

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, dmgColor, dmgAmount, dmgType = message:match(_Surface.PATTERN)

    if charColor then
        obj = _Surface.Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    end

    return obj
end)

Log.Hooks.CombineMessage:RegisterHook(function (combined, msg1, msg2)
    if msg1.Message.Type == "SurfaceDamage" and msg2.Message.Type == "SurfaceDamage" then
        msg1.Message:CombineWith(msg2.Message)
        combined = true
    end

    return combined
end)