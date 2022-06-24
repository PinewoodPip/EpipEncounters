
local Log = Client.UI.CombatLog

---@class CombatLogDamageMessage : CombatLogCharacterMessage
---@field Damage DamageInstance[]

---@type CombatLogDamageMessage
local _DamageMessage = {}
setmetatable(_DamageMessage, {__index = Client.UI.CombatLog.MessageTypes.Character})
Client.UI.CombatLog.MessageTypes.Damage = _DamageMessage

---------------------------------------------
-- METHODS
---------------------------------------------

---@param charName string
---@param charColor string
---@param damageType string
---@param amount integer
---@param color string
---@return CombatLogDamageMessage
function _DamageMessage.Create(charName, charColor, damageType, amount, color)
    ---@type CombatLogDamageMessage
    local obj = {Type = "Damage"}
    setmetatable(obj, {__index = _DamageMessage})

    obj.CharacterName = charName
    obj.CharacterColor = charColor

    obj.Damage = {}
    table.insert(obj.Damage, {
        Type = damageType,
        Amount = amount,
        Color = color,
        Hits = 1,
        HitTime = Ext.MonotonicTime(),
    })

    return obj
end

---@param msg CombatLogDamageMessage
function _DamageMessage:CombineWith(msg)
    local hasType = false

    for i,dmg in ipairs(self.Damage) do
        -- TODO support merging multiple at once.
        if dmg.Type == msg.Damage[1].Type then
            dmg.Amount = dmg.Amount + msg.Damage[1].Amount

            -- Dmg within 25ms is considered the same hit
            if msg.Damage[1].HitTime - self.Damage[#self.Damage].HitTime > 25 then
                dmg.Hits = dmg.Hits + 1
            end

            hasType = true
            break
        end
    end

    if not hasType then
        table.insert(self.Damage, msg.Damage[1])

        if msg.Damage[1].HitTime - self.Damage[#self.Damage].HitTime > 25 then
            msg.Damage[1].Hits = msg.Damage[1].Hits + 1
        else
            msg.Damage[1].Hits = 0
        end
    end
end

---@return string, string
function _DamageMessage:GetDamageString()
    local damages = ""
    local totalHits = 0

    for i=1,#self.Damage,1 do
        local dmg = self.Damage[i]
        local str = Text.Format("%s %s ", {
            FormatArgs = {RemoveTrailingZeros(dmg.Amount), dmg.Type},
            Color = dmg.Color,
        })

        totalHits = totalHits + dmg.Hits

        if i ~= #self.Damage then
            str = str .. ", "
        end

        damages = damages .. str
    end

    local addendum = ""
    if totalHits > 1 then
        addendum = string.format("from %s hits", totalHits)
    end

    return damages, addendum
end

---@return string
function _DamageMessage:ToString()
    local dmgString,addendum = self:GetDamageString()

    local msg = Text.Format("%s was hit for %s damage %s", {
        Color = Log.COLORS.TEXT,
        FormatArgs = {
            {Text = self.CharacterName, Color = self.CharacterColor},
            dmgString,
            addendum,
        }
    })

    return msg
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- local pattern = "<font color=\"#DBDBDB\"><font color=\"#(%x%x%x%x%x%x)\">(.+)</font> has the status: <font color="#4197E2">Elementalist: x3</font></font>"

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local pattern = '^<font color="#DBDBDB"><font color="#(%x%x%x%x%x%x)">(.+)</font> was hit for <font color="#(%x%x%x%x%x%x)">(%d+) (.+) Damage</font></font>$'

    local characterColor, characterName, dmgColor, dmgAmount, dmgType = message:match(pattern)

    if characterColor then
        obj = _DamageMessage.Create(characterName, characterColor, dmgType, dmgAmount, dmgColor)
    end

    return obj
end)

Log.Hooks.CombineMessage:RegisterHook(function (combined, msg1, msg2)
    if msg1.Message.Type == "Damage" and msg2.Message.Type == "Damage" then
        msg1.Message:CombineWith(msg2.Message)
        combined = true
    end

    return combined
end)