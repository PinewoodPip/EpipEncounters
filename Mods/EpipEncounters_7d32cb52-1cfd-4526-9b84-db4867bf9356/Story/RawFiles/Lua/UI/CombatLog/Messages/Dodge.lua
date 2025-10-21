
---------------------------------------------
-- Handler for "X dodged Y" messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class UI.CombatLog.Messages.Dodge : UI.CombatLog.Messages.CharacterInteraction
local _Dodge = {
    MISSED_TSKHANDLE = "hdc96a2c4g48d3g44a4g9c2aga85d059d43e5", -- "[2] missed [1]" (yes, the order of params is reversed from the usual)
}
Log:RegisterClass("UI.CombatLog.Messages.Dodge", _Dodge, {"UI.CombatLog.Messages.CharacterInteraction"})
Log.RegisterMessageHandler(_Dodge)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a dodge message.
---@param charName string
---@param charColor string
---@param targetName string
---@param targetColor string
---@return UI.CombatLog.Messages.Dodge
function _Dodge:Create(charName, charColor, targetName, targetColor)
    ---@type UI.CombatLog.Messages.Dodge
    return self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        TargetName = targetName,
        TargetColor = targetColor,
    })
end

---@override
function _Dodge:ToString()
    local msg = Text.FormatLarianTranslatedString(_Dodge.MISSED_TSKHANDLE,
        self:GetTargetLabel(), -- First param ([1]) in this TSK is target, oddly.
        self:GetCharacterLabel()
    )
    return msg
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function(obj, message)
    local pattern = Text.FormatLarianTranslatedString(_Dodge.MISSED_TSKHANDLE,
        _Dodge.KEYWORD_PATTERN,
        _Dodge.KEYWORD_PATTERN
    )
    local charColor, charName, targetColor, targetName = message:match(pattern)
    if charColor then
        obj = _Dodge:Create(charName, charColor, targetName, targetColor)
    end
    return obj
end)