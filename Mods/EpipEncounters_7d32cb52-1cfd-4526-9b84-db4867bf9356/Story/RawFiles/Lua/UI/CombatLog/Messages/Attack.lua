
local Log = Client.UI.CombatLog

---@class CombatLogAttackMessage : CombatLogDamageMessage
---@field TargetCharacter string
---@field TargetCharacterColor string
local _Attack = {
    PATTERN = '<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> attacked <font color="#(%x%x%x%x%x%x)">(.+)</font>, for <font color="#(%x%x%x%x%x%x)">(%d+) (.+) Damage</font></font>',
    Type = "Attack",
}
Inherit(_Attack, Log.MessageTypes.Damage)
Log.MessageTypes.Attack = _Attack

---------------------------------------------
-- METHODS
---------------------------------------------

function _Attack.Create(charName, charColor, targetName, targetColor, dmgType, dmgAmount, dmgColor)
    ---@type CombatLogAttackMessage
    local obj = Log.MessageTypes.Damage.Create(charName, charColor, dmgType, dmgAmount, dmgColor)
    Inherit(obj, _Attack)

    obj.TargetCharacter = targetName
    obj.TargetCharacterColor = targetColor

    return obj
end

function _Attack:ToString()
    local dmg,addendum = self:GetDamageString()
    local msg = Text.Format("%s attacked %s for %s damage %s", {
        Color = Log.COLORS.TEXT,
        FormatArgs = {
            {Text = self.CharacterName, Color = self.CharacterColor},
            {Text = self.TargetCharacter, Color = self.TargetCharacterColor},
            dmg,
            addendum,
        }
    })

    return msg
end

function _Attack:CanMerge(_)
    -- Merging these might be confusing. Let's not.
    -- return self.CharacterName == msg.CharacterName and self.TargetCharacter == msg.TargetCharacter
    return false
end

---------------------------------------------
-- PARSING
---------------------------------------------

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, targetColor, targetName, damageColor, damageAmount, damageType = message:match(_Attack.PATTERN)

    if charColor then
        obj = _Attack.Create(charName, charColor, targetName, targetColor, damageType, damageAmount, damageColor)
    end

    return obj
end)

Log.Hooks.CombineMessage:RegisterHook(function (combined, msg1, msg2)
    if msg1.Message.Type == "Attack" and msg2.Message.Type == "Attack" then
        msg1.Message:CombineWith(msg2.Message)
        combined = true
    end

    return combined
end)