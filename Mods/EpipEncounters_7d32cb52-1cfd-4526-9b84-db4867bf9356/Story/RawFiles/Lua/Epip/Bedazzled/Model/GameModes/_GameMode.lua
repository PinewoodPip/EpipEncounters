
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Features.Bedazzled.GameMode : Feature_Bedazzled_Board, I_Describable
---@field LongName TextLib_TranslatedString Should be the gamemode name prefixed by "Bedazzled ".
local Game = {}
Bedazzled:RegisterClass("Features.Bedazzled.GameMode", Game, {"Feature_Bedazzled_Board"})
Interfaces.Apply(Game, "I_Describable")

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the long name of the gamemode.
---@return TextLib_TranslatedString
function Game.GetLongName()
    return Game.LongName
end
