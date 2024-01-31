
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Features.Bedazzled.Board.Modifier : Class, I_Describable
local Modifier = {}
Bedazzled:RegisterClass("Features.Bedazzled.Board.Modifier", Modifier)
Interfaces.Apply(Modifier, "I_Identifiable")
Interfaces.Apply(Modifier, "I_Describable")

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Bedazzled.Board.Modifier.Configuration

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a modifier from a configuration table.
---@abstract
---@param config Features.Bedazzled.Board.Modifier.Configuration
---@return Features.Bedazzled.Board.Modifier
---@diagnostic disable-next-line: unused-local
function Modifier:Create(config)
    ---@diagnostic disable-next-line: missing-return
    self:__ThrowNotImplemented("Create")
end

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

---Returns a string representation of a configuration.
---@abstract
---@param config Features.Bedazzled.Board.Modifier.Configuration
---@return string
---@diagnostic disable-next-line: unused-local
function Modifier.StringifyConfiguration(config)
    ---@diagnostic disable-next-line: missing-return
    Modifier:__ThrowNotImplemented("StringifyConfiguration")
end

---Returns whether 2 configurations are equal.
---@param config1 Features.Bedazzled.Board.Modifier.Configuration
---@param config2 Features.Bedazzled.Board.Modifier.Configuration
---@return boolean
---@diagnostic disable-next-line: unused-local
function Modifier.ConfigurationEquals(config1, config2)
    ---@diagnostic disable-next-line: missing-return
    Modifier:__ThrowNotImplemented("ConfigurationEquals")
end

---Returns whether a configuration is valid to apply the modifier.
---@param config Features.Bedazzled.Board.Modifier.Configuration
---@return boolean
---@diagnostic disable-next-line: unused-local
function Modifier.IsConfigurationValid(config)
    ---@diagnostic disable-next-line: missing-return
    Modifier:__ThrowNotImplemented("IsConfigurationValid")
end
