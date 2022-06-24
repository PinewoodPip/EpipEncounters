
---------------------------------------------
-- Extensions to Game.Tooltip
---------------------------------------------

_ENV = Game.Tooltip
if setfenv ~= nil then
    setfenv(1, Game.Tooltip)
end

function TooltipData:IsIdentified()
    return self:GetElement("NeedsIdentifyLevel") == nil
end