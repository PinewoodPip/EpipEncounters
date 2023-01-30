
---@meta

---------------------------------------------
-- DEBUG GLOBAL FUNCTIONS
---------------------------------------------

---@deprecated Use Feature:Dump() instead.
---@param value any
function _D(value) end

---@deprecated Use the Feature logging functions instead.
function print(...) end

---@deprecated Not intended for production! Use Client.GetCharacter() instead.
---@return Character
function _C() end

---@deprecated Not intended for production!
---@return EsvItem
function _W() end

---@deprecated Not intended for production! Use Client.UI.Examine.GetCharacter() instead.
---@return EclCharacter
function _E() end