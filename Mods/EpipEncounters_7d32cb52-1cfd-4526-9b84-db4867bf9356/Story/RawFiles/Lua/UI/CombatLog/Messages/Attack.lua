
---------------------------------------------
-- Handler for "X attacked Y for Z damage" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Attack : UI.CombatLog.Messages.Damage
---@field TargetCharacter string
---@field TargetCharacterColor string
local _Attack = {
    ATTACKED_TSKHANDLE = "h2ad55999g203eg4468g84abg99f66b50f5ec", -- "Attacked"
    Type = "Attack",
}
Log:RegisterClass("UI.CombatLog.Messages.Attack", _Attack, {"UI.CombatLog.Messages.Damage"})
Log.RegisterMessageHandler(_Attack)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an attack message.
---@param charName string
---@param charColor htmlcolor
---@param targetName string
---@param targetColor htmlcolor
---@param dmgType string
---@param dmgAmount integer
---@param dmgColor htmlcolor
---@return UI.CombatLog.Messages.Attack
function _Attack:Create(charName, charColor, targetName, targetColor, dmgType, dmgAmount, dmgColor)
    ---@type UI.CombatLog.Messages.Attack
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        DamageType = dmgType,
        DamageAmount = dmgAmount,
        DamageColor = dmgColor,
        TargetCharacter = targetName,
        TargetCharacterColor = targetColor,
        Damage = {
            {
                Type = dmgType,
                Amount = dmgAmount,
                Color = dmgColor,
                Hits = 1,
                HitTime = Ext.MonotonicTime(),
            },
        },
    })
end

---@override
function _Attack:ToString()
    local dmg,addendum = self:GetDamageString()
    local msg = Text.FormatLarianTranslatedString(Log.CHARACTER_ACTION_TSKHANDLE, 
        self:GetCharacterLabel(),
        Text.GetTranslatedString(_Attack.ATTACKED_TSKHANDLE),
        Text.Format(self.TargetCharacter, {Color = self.TargetCharacterColor}),
        dmg .. addendum
    )
    return msg
end

---@override
function _Attack:CanMerge(_)
    -- Merging these might be confusing, as attacks are often spaced quite far apart time-wise. Let's not.
    -- return self.CharacterName == msg.CharacterName and self.TargetCharacter == msg.TargetCharacter
    return false
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    -- In some languages (ex. Polish) this string contains parenthesis, thus we must escape them.
    -- Text.EscapePatternCharacters() cannot be used here as it would also escape the Larian string placeholders.
    local baseString = Text.GetTranslatedString(Log.CHARACTER_ACTION_TSKHANDLE)
    baseString = baseString:gsub("%(", "%%(")
    baseString = baseString:gsub("%)", "%%)")
    local pattern = Text.ReplaceLarianPlaceholders(baseString, {
        _Attack.KEYWORD_PATTERN,
        Text.GetTranslatedString(_Attack.ATTACKED_TSKHANDLE),
        _Attack.KEYWORD_PATTERN,
        _Attack:__GetDamagePattern(),
    })
    local charColor, charName, targetColor, targetName, damageColor, damageAmount, damageType = message:match(pattern)
    if charColor then
        obj = _Attack:Create(charName, charColor, targetName, targetColor, damageType, damageAmount, damageColor)
    end
    return obj
end)

-- Merge with other attack messages.
local attackClassName = _Attack:GetClassName()
Log.Hooks.CombineMessage:RegisterHook(function (combined, msg1, msg2)
    if msg1.Message:GetClassName() == attackClassName and msg2.Message:GetClassName() == attackClassName then
        msg1.Message:CombineWith(msg2.Message)
        combined = true
    end
    return combined
end)