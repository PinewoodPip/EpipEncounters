
---------------------------------------------
-- Handler for messages involving heals.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Healing : UI.CombatLog.Messages.Damage
local _HealingMessage = {
    REGAINED_TSKHANDLE = "h7aec4117g5f25g45eaga9edg744a2b5d1856", -- "[1] regained [2]"
}
Log:RegisterClass("UI.CombatLog.Messages.Healing", _HealingMessage, {"UI.CombatLog.Messages.Damage"})
Log.RegisterMessageHandler(_HealingMessage)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a heal message.
---@param charName UI.CombatLog.Messages.Damage
---@param charColor string
---@param damageType string
---@param amount string
---@param color htmlcolor
---@return UI.CombatLog.Messages.Damage
function _HealingMessage:Create(charName, charColor, damageType, amount, color)
    ---@type UI.CombatLog.Messages.Damage
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
function _HealingMessage:ToString()
    -- Concatenate all heals
    local heals = {}
    local healStr = ""
    for i=1,#self.Damage,1 do
        healStr = healStr .. Text.Format("%s %s", {
            FormatArgs = {Text.RemoveTrailingZeros(self.Damage[i].Amount), self.Damage[i].Type,},
            Color = self.Damage[i].Color,
        })

        if i ~= #self.Damage then
            healStr = healStr .. ", "
        end
    end
    for _,v in ipairs(heals) do
        healStr = healStr .. v
    end

    -- Build final string
    local str = Text.FormatLarianTranslatedString(_HealingMessage.REGAINED_TSKHANDLE,
        self:GetCharacterLabel(),
        healStr
    )
    return str
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
-- Both healing and armor restoration become the same object type, Healing.
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local healingPattern = Text.FormatLarianTranslatedString(_HealingMessage.REGAINED_TSKHANDLE, _HealingMessage.KEYWORD_PATTERN, _HealingMessage.DAMAGE_PATTERN)
    local charColor, char, color, amount, damageType = ev.RawMessage:match(healingPattern)
    if char then
        ev.ParsedMessage = _HealingMessage:Create(char, charColor, damageType, amount, color)
    end
end)

-- Merge consecutive healing messages.
local healingClassName = _HealingMessage:GetClassName()
Log.Hooks.CombineMessage:Subscribe(function (ev)
    local prevMsg, newMsg = ev.PreviousMessage.Message, ev.NewMessage.Message
    if prevMsg:GetClassName() == healingClassName and newMsg:GetClassName() == healingClassName then
        prevMsg:CombineWith(newMsg)
        ev.Combined = true
    end
end)