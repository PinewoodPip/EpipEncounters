
local Log = Client.UI.CombatLog

---@class CombatLogSourceInfusionLevelMessage : CombatLogScriptedMessage
---@field Level integer
local _SourceInfusionLevel = {
    PATTERN = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: Source Infusion: (%d+)', -- + just in case someone mods in SI 10 (Derby mod in 20XX)
    PATTERN_ALT = '<font color="#(%x%x%x%x%x%x)">(.+)</font>: Source Infusion cleared',
    Type = "SourceInfusionLevel",
}
Inherit(_SourceInfusionLevel, Log.MessageTypes.Scripted)
Log.MessageTypes.SourceInfusionLevel = _SourceInfusionLevel

---------------------------------------------
-- METHODS
---------------------------------------------

function _SourceInfusionLevel.Create(charName, charColor, level)
    local text = Text.Format("Source Infusion: %s", {FormatArgs = {level}})

    if level == 0 then
        text = "Source Infusion cleared"
    end

    ---@type CombatLogSourceInfusionLevelMessage
    local obj = Log.MessageTypes.Scripted.Create(charName, charColor, text, nil)
    setmetatable(obj, {__index = _SourceInfusionLevel})

    obj.Level = tonumber(level)

    return obj
end

---------------------------------------------
-- PARSING
---------------------------------------------

Log.Hooks.GetMessageObject:RegisterHook(function (obj, message)
    local charColor, charName, level = message:match(_SourceInfusionLevel.PATTERN)

    if not charColor then
        charColor, charName = message:match(_SourceInfusionLevel.PATTERN_ALT)
        level = 0
    end

    if charColor then
        obj = _SourceInfusionLevel.Create(charName, charColor, level)
    end

    return obj
end)