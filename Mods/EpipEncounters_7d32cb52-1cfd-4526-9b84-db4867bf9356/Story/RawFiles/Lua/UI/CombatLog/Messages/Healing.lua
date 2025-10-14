
---------------------------------------------
-- Handler for messages involving heals.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Healing : UI.CombatLog.Messages.Damage
local _HealingMessage = {
    Type = "Healing",
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
            },
        },
    })
end

---@override
function _HealingMessage:ToString()
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

    local str = Text.Format("%s restored %s", {
        FormatArgs = {{
            Text = self.CharacterName,
            Color = self.CharacterColor,
        },
        {
            Text = healStr,
        }},
        Color = Log.COLORS.TEXT,
    })

    return str
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
-- Both healing and armor restoration become the same object type, Healing.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local healingPattern = "<font color=\"#DBDBDB\"><font color=\"#(%x%x%x%x%x%x)\">(.+)</font> regained <font color=\"#(%x%x%x%x%x%x)\">(%d+) (.+)</font></font>"
    local charColor, char, color, amount, damageType = message:match(healingPattern)
    if not char then
        -- Check armor restoration pattern
        healingPattern = "<font color=\"#DBDBDB\"><font color=\"#(%x%x%x%x%x%x)\">(.+)</font> restored <font color=\"#(%x%x%x%x%x%x)\">(%d+) (.+)</font></font>"

        charColor, char, color, amount, damageType = message:match(healingPattern)
    end

    if char then
        obj = _HealingMessage:Create(char, charColor, damageType, amount, color)
    end

    return obj
end)

-- Merge consecutive healing messages.
Log.Hooks.CombineMessage:RegisterHook(function (combined, msg1, msg2)
    if msg1.Message.Type == "Healing" and msg2.Message.Type == "Healing" then
        msg1.Message:CombineWith(msg2.Message)
        combined = true
    end
    return combined
end)