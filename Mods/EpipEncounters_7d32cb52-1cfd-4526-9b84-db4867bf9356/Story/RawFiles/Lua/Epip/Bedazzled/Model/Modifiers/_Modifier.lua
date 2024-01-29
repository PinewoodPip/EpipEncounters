
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Features.Bedazzled.Board.Modifier : Class, I_Describable
local Modifier = {}
Bedazzled:RegisterClass("Features.Bedazzled.Board.Modifier", Modifier)
Interfaces.Apply(Modifier, "I_Identifiable")
Interfaces.Apply(Modifier, "I_Describable")

---------------------------------------------
-- METHODS
---------------------------------------------

---Applies the modifier to a board.
---@abstract
---@param board Feature_Bedazzled_Board
---@diagnostic disable-next-line: unused-local
function Modifier:Apply(board) end

---Returns a table representing the configuration of the modifier.
---@abstract
---@return table -- Must contain only simple tables and primitive types as values.
function Modifier:GetConfigurationSchema()
    ---@diagnostic disable-next-line: missing-return
    self:__ThrowNotImplemented("GetConfigurationSchema")
end
