
---------------------------------------------
-- Handler for character death reason messages.
-- *Does not handle kill messages ("X killed Y")*.
---------------------------------------------

local Log = Client.UI.CombatLog
local DEATH_REASON_TSKHANDLES = Log.DEATH_REASON_TSKHANDLES

---@class UI.CombatLog.Messages.Death : UI.CombatLog.Messages.Character
---@field DeathReason DeathType
local Death = {}
Log:RegisterClass("UI.CombatLog.Messages.Death", Death, {"UI.CombatLog.Messages.Character"})
Log.RegisterMessageHandler(Death)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a death message.
---@param charName string
---@param charColor string
---@param deathReason DeathType
---@return UI.CombatLog.Messages.Death
function Death:Create(charName, charColor, deathReason)
    ---@type UI.CombatLog.Messages.Death
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        DeathReason = deathReason,
    })
end

---@override
function Death:ToString()
    return Text.FormatLarianTranslatedString(DEATH_REASON_TSKHANDLES[self.DeathReason], self:GetCharacterLabel())
end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

-- Create message objects.
Log.Hooks.ParseMessage:Subscribe(function (ev)
    local message = ev.RawMessage
    for deathType,tskHandle in pairs(DEATH_REASON_TSKHANDLES) do
        local deathText = Text.GetTranslatedString(tskHandle)
        local deathPattern = Text.FormatLarianTranslatedString(Text.EscapePatternCharacters(deathText), Death.KEYWORD_PATTERN)
        deathPattern = Text.Replace(deathPattern, "%[1%]", Death.KEYWORD_PATTERN) -- Necessary as EscapePatternCharacters() screws with the Larian placeholder due to the square brackets.
        local charColor, charName = message:match(deathPattern)
        if charName then
            ev.ParsedMessage = Death:Create(charName, charColor, deathType)
            break
        end
    end
end)
