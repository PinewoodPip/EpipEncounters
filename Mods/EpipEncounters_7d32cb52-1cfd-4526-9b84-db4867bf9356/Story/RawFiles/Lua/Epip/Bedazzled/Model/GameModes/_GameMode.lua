
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Features.Bedazzled.GameMode : Feature_Bedazzled_Board, I_Describable
---@field LongName TextLib_TranslatedString Should be the gamemode name prefixed by "Bedazzled ".
local Game = {}
Bedazzled:RegisterClass("Features.Bedazzled.GameMode", Game, {"Feature_Bedazzled_Board"})
Interfaces.Apply(Game, "I_Describable")

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Features.Bedazzled.GameMode.Events.MovePerformed
---@field Position Vector2
---@field InteractedGems Feature_Bedazzled_Board_Gem[]

---@class Features.Bedazzled.GameMode.Events.InvalidMovePerformed : Features.Bedazzled.GameMode.Events.MovePerformed

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the long name of the gamemode.
---@return TextLib_TranslatedString
function Game.GetLongName()
    return Game.LongName
end

---Throws a MovePerformed event and increments move counter.
---@param ev Features.Bedazzled.GameMode.Events.MovePerformed
function Game:ReportMove(ev)
    self.MovesMade = self.MovesMade + 1

    -- Reset cascade counter
    self.MatchesSinceLastMove = 0

    -- Reset hint cooldown
    self.HintCooldown = self.HINT_COOLDOWN

    self.Events.MovePerformed:Throw(ev)
end

---Throws a InvalidMovePerformed event.
---@param ev Features.Bedazzled.GameMode.Events.InvalidMovePerformed
function Game:ReportInvalidMove(ev)
    self.Events.InvalidMovePerformed:Throw(ev)
end
