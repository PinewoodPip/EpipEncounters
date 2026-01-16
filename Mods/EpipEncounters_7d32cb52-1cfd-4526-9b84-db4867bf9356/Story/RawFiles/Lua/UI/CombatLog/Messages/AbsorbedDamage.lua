
---------------------------------------------
-- Handler for "X regained Y due to high resistance!" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.AbsorbedDamage : UI.CombatLog.Messages.Damage
local _AbsorbedMessage = {
    ABSORBED_TSKHANDLE = "h0e887403gc986g470cgbdc1gf58f232da39e", -- "[1] regained [2] due to high resistance!"
}
Log:RegisterClass("UI.CombatLog.Messages.AbsorbedDamage", _AbsorbedMessage, {"UI.CombatLog.Messages.Damage"})
Log.RegisterMessageHandler(_AbsorbedMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an absorbed damage message.
---@param charName string
---@param charColor string
---@param damageType string
---@param amount string
---@param color htmlcolor
---@return UI.CombatLog.Messages.AbsorbedDamage
function _AbsorbedMessage:Create(charName, charColor, damageType, amount, color)
    ---@type UI.CombatLog.Messages.AbsorbedDamage
    return self:__Create({
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
end

---@override
function _AbsorbedMessage:ToString()
    -- Concatenate all absorbed damage
    local absorbed = {}
    local absorbedStr = ""
    for i=1,#self.Damage,1 do
        absorbedStr = absorbedStr .. Text.Format("%s %s", {
            FormatArgs = {Text.RemoveTrailingZeros(self.Damage[i].Amount), self.Damage[i].Type,},
            Color = self.Damage[i].Color,
        })

        if i ~= #self.Damage then
            absorbedStr = absorbedStr .. ", "
        end
    end
    for _,v in ipairs(absorbed) do
        absorbedStr = absorbedStr .. v
    end

    -- Build final string
    local str = Text.FormatLarianTranslatedString(_AbsorbedMessage.ABSORBED_TSKHANDLE,
        self:GetCharacterLabel(),
        absorbedStr
    )
    return str
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
-- Both Absorbed and armor restoration become the same object type, Absorbed.
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local AbsorbedPattern = Text.FormatLarianTranslatedString(_AbsorbedMessage.ABSORBED_TSKHANDLE, _AbsorbedMessage.KEYWORD_PATTERN, _AbsorbedMessage.DAMAGE_PATTERN)
    local charColor, char, color, amount, damageType = ev.RawMessage:match(AbsorbedPattern)
    if char then
        ev.ParsedMessage = _AbsorbedMessage:Create(char, charColor, damageType, amount, color)
        ev:StopPropagation() -- Must prevent the Healing parser from also picking this up, as the pattern is similar, at least in English.
    end
end)

-- Merge consecutive Absorbed messages.
local AbsorbedClassName = _AbsorbedMessage:GetClassName()
Log.Hooks.CombineMessage:Subscribe(function (ev)
    local prevMsg, newMsg = ev.PreviousMessage.Message, ev.NewMessage.Message
    if prevMsg:GetClassName() == AbsorbedClassName and newMsg:GetClassName() == AbsorbedClassName then
        prevMsg:MergeWith(newMsg)
        ev.Combined = true
    end
end)