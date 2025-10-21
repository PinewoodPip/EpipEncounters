
---------------------------------------------
-- Handler for Epic Encounter's source infusion level messages.
---------------------------------------------

local Log = Client.UI.CombatLog

---@class CombatLog.Messages.SourceInfusionLevel : UI.CombatLog.Messages.Scripted
---@field Level integer
local _SourceInfusionLevel = {
    PATTERN = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: Source Infusion: (%d+)', -- "+" just in case someone mods in SI 10 (Derby mod in 20XX)
    PATTERN_ALT = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: Source Infusion cleared',
}
Log:RegisterClass("UI.CombatLog.Messages.SourceInfusionLevel", _SourceInfusionLevel, {"UI.CombatLog.Messages.Scripted"})
Log.RegisterMessageHandler(_SourceInfusionLevel)

local TSKs = {
    SourceInfusion_Level = Log:RegisterTranslatedString({
        Handle = "h6d73a6cbg2e37g406dg8059gf047e7bcbaf1",
        Text = [[Source Infusion: %s]],
        ContextDescription = [[Message for a character's source infusion level changing; param is the new level.]],
    }),
    SourceInfusion_Cleared = Log:RegisterTranslatedString({
        Handle = "h3f4e1c2bgf4edg4b8bg9f5fg2d3e1e2f6b2a",
        Text = [[Source Infusion cleared]],
        ContextDescription = [[Message for a character's source infusion being cleared.]],
    }),
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a source infusion message.
---@param charName UI.CombatLog.Messages.Scripted
---@param charColor htmlcolor
---@param level integer
---@return CombatLog.Messages.SourceInfusionLevel
function _SourceInfusionLevel:Create(charName, charColor, level)
    local text = level > 0 and TSKs.SourceInfusion_Level:Format(level) or TSKs.SourceInfusion_Cleared:Format()

    ---@type CombatLog.Messages.SourceInfusionLevel
    local obj = self:__Create({
        CharacterName = charName,
        CharacterColor = charColor,
        Text = text,
        Color = Log.COLORS.TEXT,
        Level = level,
    })
    return obj
end

---------------------------------------------
-- PARSING
---------------------------------------------

-- Create message objects.
Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, level = message:match(_SourceInfusionLevel.PATTERN)

    if not charColor then
        charColor, charName = message:match(_SourceInfusionLevel.PATTERN_ALT)
        level = 0
    end

    if charColor then
        obj = _SourceInfusionLevel:Create(charName, charColor, level)
    end

    return obj
end)