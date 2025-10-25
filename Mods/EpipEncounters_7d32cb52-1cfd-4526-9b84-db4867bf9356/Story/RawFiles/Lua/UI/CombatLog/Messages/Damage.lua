
---------------------------------------------
-- Base class for messages involving damage hits.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Damage : UI.CombatLog.Messages.Character
---@field Damage UI.CombatLog.Messages.Damage.Hit[]
local _DamageMessage = {
    HIT_TSKHANDLE = "h8ade1bb0gb79eg44c0gbe01g1dd0d51935df", -- "hit"

    DAMAGE_PATTERN = [[<font color="#(%x%x%x%x%x%x)">(%d+):? (.+)</font>]], -- Pattern for damage color, amount & type. Russian language includes a ":" after the amount, but only for armor restoration.
}
Log:RegisterClass("UI.CombatLog.Messages.Damage", _DamageMessage, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(_DamageMessage)

local TSKs = {
    Suffix_FromXHits = Log:RegisterTranslatedString({
        Handle = "hf09d887cgd6bbg43e9g9947g7bbbcb4f661f",
        Text = [[from %s hits]],
        ContextDescription = [[Suffix added to merged combat log hit messages; param is amount of hits. Ex. "<character> took 10 damage from 2 hits"]],
    }),
}

---@class UI.CombatLog.Messages.Damage.Hit
---@field Type string
---@field Amount integer Amount of damage dealt across all hits of this type.
---@field Color string
---@field Hits integer
---@field HitTime integer

---------------------------------------------
-- METHODS
---------------------------------------------

---@param charName string
---@param charColor htmlcolor
---@param damageType string
---@param amount integer
---@param color htmlcolor
---@return UI.CombatLog.Messages.Damage
function _DamageMessage:Create(charName, charColor, damageType, amount, color)
    ---@type UI.CombatLog.Messages.Damage
    local obj = self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Damage = {},
    })

    -- Insert initial hit
    table.insert(obj.Damage, {
        Type = damageType,
        Amount = amount,
        Color = color,
        Hits = 1,
        HitTime = Ext.MonotonicTime(),
    })

    return obj
end

---@override
---@param msg UI.CombatLog.Messages.Damage
function _DamageMessage:CombineWith(msg)
    local hasType = false

    for _,dmg in ipairs(self.Damage) do
        -- TODO support merging multiple at once.
        -- 2025 note: is the above msg relevant? New messages would only ever have one damage entry.
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
            FormatArgs = {Text.RemoveTrailingZeros(dmg.Amount), dmg.Type},
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
        -- Use Epip's TSK is translated for the current language
        if Text.GetTranslatedStringTranslation(TSKs.Suffix_FromXHits.Handle) then
            addendum = TSKs.Suffix_FromXHits:Format(totalHits)
        else -- Otherwise fallback to "<amount>x hit" to avoid showing the english suffix in an otherwise-translated message. The "hit" is awkward in singular, but sadly no plural string for it exists in the vanilla TSKs.
            addendum = Text.Format("(%sx %s)", {FormatArgs = {
                totalHits,
                Text.GetTranslatedString(_DamageMessage.HIT_TSKHANDLE)
            }})
        end
    end

    return damages, addendum
end

---@override
---@return string
function _DamageMessage:ToString()
    local dmgString, addendum = self:GetDamageString()
    local msg = Text.FormatLarianTranslatedString(Log.CHARACTER_RECEIVED_ACTION_TSKHANDLE,
        self:GetCharacterLabel(),
        Text.GetTranslatedString(_DamageMessage.HIT_TSKHANDLE),
        dmgString .. addendum
    )
    return msg
end

---Returns the pattern that matches damage amount & type messages (ex. "X Fire Damage"), including their color.
---@return pattern
function _DamageMessage:__GetDamagePattern()
    return [[<font color="#(%x%x%x%x%x%x)">]] .. [[(%d+) (.+)]] .. [[</font>]]
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local message = ev.RawMessage
    local pattern = Text.FormatLarianTranslatedString(Log.CHARACTER_RECEIVED_ACTION_TSKHANDLE,
        _DamageMessage.KEYWORD_PATTERN,
        Text.GetTranslatedString(_DamageMessage.HIT_TSKHANDLE),
        _DamageMessage:__GetDamagePattern()
    )
    local characterColor, characterName, dmgColor, dmgAmount, dmgType
    local params = {message:match(pattern)}
    if tonumber(params[2]) then -- In some languages (ex. Spanish) the damage comes before character name.
        characterColor, characterName, dmgColor, dmgAmount, dmgType = params[4], params[5], params[1], params[2], params[3]
    else
        characterColor, characterName, dmgColor, dmgAmount, dmgType = table.unpack(params)
    end
    if characterColor then
        ev.ParsedMessage = _DamageMessage:Create(characterName, characterColor, dmgType, dmgAmount, dmgColor)
    end
end)

-- Merge consecutive damage messages.
local damageClassName = _DamageMessage:GetClassName()
Log.Hooks.CombineMessage:Subscribe(function (ev)
    local prevMsg, newMsg = ev.PreviousMessage.Message, ev.NewMessage.Message
    if prevMsg:GetClassName() == damageClassName and newMsg:GetClassName() == damageClassName then
        prevMsg:MergeWith(newMsg)
        ev.Combined = true
    end
end)