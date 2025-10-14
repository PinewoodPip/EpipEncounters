
---------------------------------------------
-- Handler for "X was hit for Y Damage by a surface" messages.
---------------------------------------------

local Log = Client.UI.CombatLog
local DamageClass = Log:GetClass("UI.CombatLog.Messages.Damage")

---@class UI.CombatLog.Messages.SurfaceDamage : UI.CombatLog.Messages.Damage
local _Surface = {
    PATTERN = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> was hit for <font color="#(%x%x%x%x%x%x)">(%d+) (.+) Damage</font> by a surface</font>',
}
Log:RegisterClass("UI.CombatLog.Messages.SurfaceDamage", _Surface, {"UI.CombatLog.Messages.Damage"})
Log.RegisterMessageHandler(_Surface)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a surface damage message.
---@param charName UI.CombatLog.Messages.Damage
---@param charColor htmlcolor
---@param dmgType string
---@param dmgAmount integer
---@param dmgColor htmlcolor
---@return UI.CombatLog.Messages.SurfaceDamage
function _Surface:Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    ---@type UI.CombatLog.Messages.SurfaceDamage
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Damage = {
            {
                Type = dmgType,
                Amount = tonumber(dmgAmount),
                Color = dmgColor,
                Hits = 1,
                HitTime = Ext.MonotonicTime(),
            },
        },
    })
end

---@override
function _Surface:ToString()
    local str = Text.Format("%s by a surface", {
        FormatArgs = {
            DamageClass.ToString(self),
        },
        Color = Log.COLORS.TEXT,
    })

    return str
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, dmgColor, dmgAmount, dmgType = message:match(_Surface.PATTERN)

    if charColor then
        obj = _Surface:Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    end

    return obj
end)

-- Combine consecutive surface damage messages from the same character.
local surfaceDamageClassName = _Surface:GetClassName()
Log.Hooks.CombineMessage:RegisterHook(function (combined, msg1, msg2)
    if msg1.Message:GetClassName() == surfaceDamageClassName and msg2.Message:GetClassName() == surfaceDamageClassName then
        msg1.Message:CombineWith(msg2.Message)
        combined = true
    end
    return combined
end)